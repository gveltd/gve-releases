#!/usr/bin/env bash
# install.sh — install the `gve` command (GVE OS CLI) from the latest public release.
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/gveltd/gve-releases/HEAD/install.sh)"
#
# Detects OS/arch (macOS or Linux, arm64 or amd64), downloads the matching
# tarball from the newest `gve-cli/vX.Y.Z` release here, verifies it against
# SHA256SUMS, and installs `gve` to /usr/local/bin (or ~/.local/bin when
# /usr/local/bin is not writable). Environment:
#   GVE_VERSION=X.Y.Z   install that version instead of the latest
#   GVE_INSTALL_DIR=…   install there instead
set -euo pipefail

REPO="gveltd/gve-releases"
API="https://api.github.com/repos/${REPO}/releases"

say() { printf '%s\n' "$*" >&2; }
die() { say "install.sh: $*"; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "$1 is required"; }
need curl; need tar

os="$(uname -s)"
case "$os" in
  Darwin) os=darwin ;;
  Linux)  os=linux ;;
  *) die "unsupported OS: $os (macOS and Linux only)" ;;
esac
arch="$(uname -m)"
case "$arch" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64)  arch=amd64 ;;
  *) die "unsupported architecture: $arch" ;;
esac

# Newest gve-cli tag, unless pinned. Releases of other products share this
# repository, so the tag prefix is what selects gve.
if [ -n "${GVE_VERSION:-}" ]; then
  tag="gve-cli/v${GVE_VERSION#v}"
else
  tag="$(curl -fsSL "${API}?per_page=100" | grep -o '"tag_name": *"gve-cli/v[^"]*"' | head -n1 | sed 's/.*"\(gve-cli\/v[^"]*\)"/\1/')"
  [ -n "$tag" ] || die "no gve-cli release found in ${REPO}"
fi
version="${tag#gve-cli/v}"
asset="gve-${version}-${os}-${arch}.tar.gz"
base="https://github.com/${REPO}/releases/download/${tag}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
say "Downloading gve ${version} (${os}/${arch})…"
curl -fsSL -o "${tmp}/${asset}" "${base}/${asset}" || die "download failed: ${base}/${asset}"
curl -fsSL -o "${tmp}/SHA256SUMS" "${base}/SHA256SUMS" || die "download failed: ${base}/SHA256SUMS"

expected="$(grep " ${asset}\$" "${tmp}/SHA256SUMS" | awk '{print $1}')"
[ -n "$expected" ] || die "${asset} is not listed in SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "${tmp}/${asset}" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "${tmp}/${asset}" | awk '{print $1}')"
fi
[ "$expected" = "$actual" ] || die "checksum mismatch for ${asset}"

tar -xzf "${tmp}/${asset}" -C "$tmp"
bin="${tmp}/gve-${version}-${os}-${arch}"
[ -f "$bin" ] || die "archive did not contain the gve binary"
chmod +x "$bin"

dir="${GVE_INSTALL_DIR:-}"
if [ -z "$dir" ]; then
  if [ -w /usr/local/bin ]; then dir=/usr/local/bin; else dir="${HOME}/.local/bin"; fi
fi
mkdir -p "$dir"
install -m 0755 "$bin" "${dir}/gve"

say "Installed ${dir}/gve ($("${dir}/gve" version 2>/dev/null || echo "gve ${version}"))"
case ":${PATH}:" in
  *":${dir}:"*) ;;
  *) say "Add ${dir} to your PATH, e.g.:  export PATH=\"${dir}:\$PATH\"" ;;
esac
say ""
say "Next:  gve gsm login        # waits for your GVE Secure Proxy session"
say "       gve iam list actions  # what you may do"
