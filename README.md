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
