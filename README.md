# GVE releases

Public download page for GVE distributables. The source lives in private
repositories; this repository exists only so signed builds can be downloaded
without a GitHub account.

Releases are tagged `<product>/vX.Y.Z`. Every release here is published
automatically by the owning repository's release pipeline after the build
passes signing, notarization, and a strict package check. Tags in this
repository mark the release only; they do not point at source.

## GVE Secure Proxy (macOS, Apple silicon)

Tags: `secure-proxy/vX.Y.Z`. Each release ships two assets:

| Asset | Use when |
|---|---|
| `GVE-Secure-Proxy-X.Y.Z-macos-arm64.zip` | macOS 15 (Sequoia) or newer |
| `GVE-Secure-Proxy-X.Y.Z-macos-arm64.macos14.zip` | macOS 14 (Sonoma) |

Unzip and open `GVE Secure Proxy.app`. Builds are signed with a Developer ID
certificate, notarized by Apple, and stapled, so Gatekeeper opens them
without warnings.

## gve — the GVE OS command line (macOS, Linux)

Tags: `gve-cli/vX.Y.Z`. One-line install (downloads the newest `gve-cli` release,
verifies `SHA256SUMS`, installs to `/usr/local/bin` or `~/.local/bin`):

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/gveltd/gve-releases/HEAD/install.sh)"
```

`GVE_VERSION=X.Y.Z` pins a version; `GVE_INSTALL_DIR=…` picks the directory.

| Asset | Platform |
|---|---|
| `gve-X.Y.Z-darwin-arm64.tar.gz` | macOS, Apple silicon |
| `gve-X.Y.Z-darwin-amd64.tar.gz` | macOS, Intel |
| `gve-X.Y.Z-linux-arm64.tar.gz` / `gve-X.Y.Z-linux-amd64.tar.gz` | Linux |
| `SHA256SUMS` | checksums for every asset |

`gve` talks to GVE OS through the locally running GVE Secure Proxy and holds
no credential of its own: `gve gsm login` waits for the proxy's session and
prints who you are. macOS binaries are ad-hoc signed; a `curl` download carries
no quarantine attribute, so Gatekeeper does not intercept them.
