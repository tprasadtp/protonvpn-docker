<!-- markdownlint-disable MD033 -->

## Changelog

<p align="center">
  <a href="https://protonvpn.com" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/proton/scalable/protonvpn-wide.svg" height="64" alt="protonvpn">
  </a>
  <a href="https://ghcr.io/tprasadtp/protonvpn" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/software/docker-engine-wide.svg" height="64" alt="protonvpn">
  </a>
</p>

<a name="unreleased"></a>
## [Unreleased]


<a name="4.0.0-alpha1"></a>
## [4.0.0-alpha1] - 2021-03-09
### 🍒 Features
- update base image and files ([ef3ffb3](https://github.com/tprasadtp/protonvpn-docker/commits/ef3ffb37882bc86172e473085a40aa9a7008908e))

### 📖 Documentation
- update badges ([1707b1b](https://github.com/tprasadtp/protonvpn-docker/commits/1707b1be2f558fbcb2e5fa06314ab64bee65a489))

### 🤖 Continuous Integration & Automation
- use goreleaser for building images and docker manifests ([e414f40](https://github.com/tprasadtp/protonvpn-docker/commits/e414f40aae5290dd181d719e339c6659615712bc))
- prepare to use goreleaser ([790ed6f](https://github.com/tprasadtp/protonvpn-docker/commits/790ed6f853f50fd147ab07730e5ec38cf3499252))
- **labels:** Manage issue labels via tprasadtp/labels ([65bb5db](https://github.com/tprasadtp/protonvpn-docker/commits/65bb5db05c12994525af46d9a69a4df5c86f72a4))

### 🥺 Chore
- **automation:** PR automation via kodiak ([25fc41c](https://github.com/tprasadtp/protonvpn-docker/commits/25fc41c9e25daf30f53fddbd53420216bd3f43f9))
- **automation:** enable dependabot ([e8cf292](https://github.com/tprasadtp/protonvpn-docker/commits/e8cf2927773a4ee76cd0fe32751d35fec7ca2800))
- **changelog:** update configs ([5676b3d](https://github.com/tprasadtp/protonvpn-docker/commits/5676b3d9e181cad40815fcbae2252768459043fb))
- **changelog:** use git-chglog for changelog generation ([4c75f1a](https://github.com/tprasadtp/protonvpn-docker/commits/4c75f1a4cb365f89b27fa2d870ac4c49b2cb7470))

### BREAKING CHANGES
- `LIVE_PROBE_INTERVAL` is now `PROTONVPN_CHECK_INTERVAL`
- `RECONNECT_THRESHOLD` is now `PROTONVPN_FAIL_THRESHOLD`
- Verify s6-overlay GPG signature before install
- `S6_KILL_GRACETIME` to 10000 (10s) to avoid timeouts

FIXES:
- `SIGTERM` and `SIGINT` not being handled properly

<a name="3.1.0"></a>
## [3.1.0] - 2021-02-27
<!-- old changelog ported here for compatibility -->
<!-- header 3.1.0 is added by the git-chglog -->

- **FIX** Unreachable ports/Connection Timeouts. Disable internal protonvpn's internal killswitch. This should fix #18, #15, #11. This was enabled in 2.2.6+. Killswitch is not reliable anyway inside container.
- _(Internal)_ Update base docker image.

## 3.0.0

- **NEW**: (🍒) Support connecting to random server [#14](https://github.com/tprasadtp/protonvpn-docker/pull/14).
by [Milutin Jovanović](https://github.com/tprasadtp/protonvpn-docker/pull/14).
- **BREAKING CHANGE**: Version tags prior to this release always matched included protonvpn-cli version.
From this release onwards that will no longer be the case. Use image label `io.github.tprasadtp.metadata.upstream.version`,
to check version of included cli.
- _(Fix)_ Config issues with visionary plan [#16](https://github.com/tprasadtp/protonvpn-docker/issues/16)

## 2.2.6

- **BREAKING CHANGE**: `PROTONVPN_SERVER` and `PROTONVPN_COUNTRY` are now mutually exclusive.
- **BREAKING CHANGE**: DNS argument(`--dns`) is no longer mandatory to run the image.
- **NEW**: Support split tunnel settings.
- **NEW**: Support for disabling DNS leak protection.
- _(Internal)_ Update protonvpn-cli to 2.2.6.
- _(Internal)_ Removes included templates.
- _(Internal)_ Update s6 overlay.
- _(Internal)_ Update base docker image.
- _(Internal)_ Use CLI request headers for API endpoint
- _(Internal)_ Use updated configs fields during container init (`api_domain`).
- _(CI/CD)_ Added support for GitHub container registry.
- _(Internal)_ Changes health-check url to `https://ipinfo.io` as ProtonVPN API is inconsistent.


<!-- tag references -->
[Unreleased]: https://github.com/tprasadtp/protonvpn-docker/compare/4.0.0-alpha1...HEAD
[4.0.0-alpha1]: https://github.com/tprasadtp/protonvpn-docker/compare/3.1.0...4.0.0-alpha1
[3.1.0]: https://github.com/tprasadtp/protonvpn-docker/compare/3.0.0...3.1.0

