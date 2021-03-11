<!-- markdownlint-disable MD033 -->

## Changelog


<a name="4.1.0"></a>
## [4.1.0] - 2021-03-12

###  SECURITY UPDATES
- Updated base image from python to ubuntu:focal

### 🤖 Continuous Integration & Automation
- add trivy scanning for generated images ([#22](https://github.com/tprasadtp/protonvpn-docker/issues/22)) ([d0704a0](https://github.com/tprasadtp/protonvpn-docker/commit/d0704a0e3eb6f9d2ed280c914ea8dca46a48ad3f))


<a name="4.0.0"></a>
## [4.0.0] - 2021-03-11

### ⚠️ BREAKING CHANGES
- Docker Hub image is deprecated and will not be updated.
- You **MUST** use GHCR image. (`ghcr.io/tprasadtp/protonvpn`)
- rename `LIVE_PROBE_INTERVAL` to `PROTONVPN_CHECK_INTERVAL`
- rename `RECONNECT_THRESHOLD` to `PROTONVPN_FAIL_THRESHOLD`
- increase `S6_KILL_GRACETIME` from default to 10000 (10s) to avoid timeouts

### 🍒 Features & Enhancements
- Deprecate Docker Hub image ([b41ed98](https://github.com/tprasadtp/protonvpn-docker/commit/b41ed98d5471e17e1470822407756d239d575124))

### 🐛 Bug Fixes
- incorrect default value for `PROTONVPN_FAIL_THRESHOLD` ([877ce40](https://github.com/tprasadtp/protonvpn-docker/commit/877ce405ba58e5fc643c096912b99c9e97a9d687))
- `SIGTERM` and `SIGINT` not being handled properly ([aecf1d4](https://github.com/tprasadtp/protonvpn-docker/commit/aecf1d4eb32e11749faebf38068e468266422775))

### 📖 Documentation
- document internal healthcheck intervals and update badges ([5583614](https://github.com/tprasadtp/protonvpn-docker/commit/5583614d9954826a3077f1567f2818d0e4771635))

### 🤖 Continuous Integration & Automation
- use github environments for secrets ([3536ada](https://github.com/tprasadtp/protonvpn-docker/commit/3536adabb497f2368d08b6dca26fda171b26e92e))
- use goreleaser to build docker images ([b34aa11](https://github.com/tprasadtp/protonvpn-docker/commit/b34aa11b61614579b46dd389ce97bf61992d2b21))
- **automation:** PR automation via kodiak ([06f6307](https://github.com/tprasadtp/protonvpn-docker/commit/06f63078ac79de67c4f6d315a16ac75bbf6b99c4))
- **dependabot:** enable dependabot ([37d0faa](https://github.com/tprasadtp/protonvpn-docker/commit/37d0faa2633cf50a37868a521035d8402066dc6c))
- **labels:** Manage issue labels via tprasadtp/labels ([d818d85](https://github.com/tprasadtp/protonvpn-docker/commit/d818d856fe6660b48ed90c82a7a3c23eea2483cd))

### 🥺 Maintanance
- add generated files to gitignore ([af65559](https://github.com/tprasadtp/protonvpn-docker/commit/af6555906a4ea95f342cfbe947c4f6fc00b7357f))
- **changelog:**  add helper script ([9bc8194](https://github.com/tprasadtp/protonvpn-docker/commit/9bc8194dc373e6e34a791d044f1afc2c2fb32002))
- **changelog:** automate changelog generation ([99c72e1](https://github.com/tprasadtp/protonvpn-docker/commit/99c72e1233757c5cf79412709977212156c31434))
- **deps:** update python deps ([c668530](https://github.com/tprasadtp/protonvpn-docker/commit/c668530e252a6969d0f3f782b282feea0875a4b6))

### Reverts
- ci: use github environments for secrets ([cc62463](https://github.com/tprasadtp/protonvpn-docker/commit/cc62463de3e35c318a94147c55e38a921d7f9287))


<!-- tag references -->
[4.1.0]: https://github.com/tprasadtp/protonvpn-docker/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/tprasadtp/protonvpn-docker/compare/3.1.0...4.0.0
<!-- old changelog-->
## 3.1.0

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

## 2.2.2

- Initial release
