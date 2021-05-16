# Changelog

<a name="unreleased"></a>
## [Unreleased]

### 📖 Documentation
- Reorganize to better handle GitHub Pages ([ad47fde](https://github.com/tprasadtp/protonvpn-docker/commit/ad47fdee4a07956515b3380fd64c60ac99bcd695))
- Enable Github pages and add troubleshooting docs ([a0ba4ee](https://github.com/tprasadtp/protonvpn-docker/commit/a0ba4eec74f5b8ab89db7ed77aae30f786404e59))
- Update debugging compose file ([c127608](https://github.com/tprasadtp/protonvpn-docker/commit/c1276081a57e737a0b549abc3b839ae4cdca0610))
- Fix docker logo URL in README ([4cf3b0d](https://github.com/tprasadtp/protonvpn-docker/commit/4cf3b0d189c6a493d8d75c440a884eb58c6c64f2))

### 🚧 Maintanance
- Update templates ([51d120c](https://github.com/tprasadtp/protonvpn-docker/commit/51d120c312860930d35efa9005ac3870c530a6d0))
- Update templates ([c122bed](https://github.com/tprasadtp/protonvpn-docker/commit/c122bed299f910c197fb90f1d21523d22849ed17))
- **automation:** Allow automerge of docker image updates done via dependabot ([74ee95e](https://github.com/tprasadtp/protonvpn-docker/commit/74ee95e83ebdd56e4215fcd83f79c4ddc6df8783))
- **changelog:** Update changelog emojis to follow common snippets ([91cd108](https://github.com/tprasadtp/protonvpn-docker/commit/91cd108bc2979984ce24d279080cf39ca7083cd1))

### 🤖 CI/CD & Automation
- Checkout tag corresponding to latest release, before doing scheduled security scan to help populate required fields for codeql action ([842e834](https://github.com/tprasadtp/protonvpn-docker/commit/842e8348be330743ab708d081a61440c7c0e7c56))
- **deps:** bump aquasecurity/trivy-action from 0.0.16 to 0.0.17 ([#47](https://github.com/tprasadtp/protonvpn-docker/issues/47)) ([a995116](https://github.com/tprasadtp/protonvpn-docker/commit/a995116c8077e8fa2970c5450109b412dff14e06))
- **deps:** bump aquasecurity/trivy-action from 0.0.15 to 0.0.16 ([#46](https://github.com/tprasadtp/protonvpn-docker/issues/46)) ([7e90b7d](https://github.com/tprasadtp/protonvpn-docker/commit/7e90b7d06dcbd2d85e06393cd109c7575d36fd2d))
- **deps:** bump aquasecurity/trivy-action from 0.0.14 to 0.0.15 ([#44](https://github.com/tprasadtp/protonvpn-docker/issues/44)) ([a19d7aa](https://github.com/tprasadtp/protonvpn-docker/commit/a19d7aa4aae72f7d883f6e4b6ea3f2f036bd3a9c))
- **kodiak:** Remove default block on GH-Actions dependency updates ([b5172d4](https://github.com/tprasadtp/protonvpn-docker/commit/b5172d45934d5438a9f9a8007b25ec3c0291d9cf))


<a name="4.2.1"></a>
## [4.2.1] - 2021-05-05

### 🚧 Maintanance
- **deps:** bump ubuntu from focal-20210401 to focal-20210416 ([#43](https://github.com/tprasadtp/protonvpn-docker/issues/43)) ([e4c35e0](https://github.com/tprasadtp/protonvpn-docker/commit/e4c35e0997c8604edf0a06fe5a1d75c6d93b88ae))


<a name="4.2.0"></a>
## [4.2.0] - 2021-04-20

### 🍒 Features & Enhancements
- Option to connect to P2P friendly servers  ([#41](https://github.com/tprasadtp/protonvpn-docker/issues/41)) ([aaa7835](https://github.com/tprasadtp/protonvpn-docker/commit/aaa7835b951e83dacff4a3aa0324ca2b0beb8890))

### 🤖 CI/CD & Automation
- Use granular actions permissions ([78a1b6d](https://github.com/tprasadtp/protonvpn-docker/commit/78a1b6df62caae6477e01b459c1b692d7ce09c47))
- fix stale wokflow messages to match settings ([6469584](https://github.com/tprasadtp/protonvpn-docker/commit/6469584bcd90e63a905faa33568e837939d4c3a2))


<a name="4.1.5"></a>
## [4.1.5] - 2021-04-13

### 🐛 Bug Fixes
- the wrong print message for config protocol ([#39](https://github.com/tprasadtp/protonvpn-docker/issues/39)) ([919de45](https://github.com/tprasadtp/protonvpn-docker/commit/919de4594d49de9f2886f1559c0756692158134c))

### 📖 Documentation
- Fix misspelt 'labels' in README.md ([#40](https://github.com/tprasadtp/protonvpn-docker/issues/40)) ([be9c379](https://github.com/tprasadtp/protonvpn-docker/commit/be9c3791780cd750188f63f81ad5c3fd88729de5))
- fix k8s url ([be00b51](https://github.com/tprasadtp/protonvpn-docker/commit/be00b51330b831da5b7e64bc643917bab98dcfe7))
- fix typos ([0fbd4dd](https://github.com/tprasadtp/protonvpn-docker/commit/0fbd4dd89007b9a392f440e11f51797a0172a215))
- Add working k8s examples ([9e14f52](https://github.com/tprasadtp/protonvpn-docker/commit/9e14f5253d92cadb0a4af5ba24ffacff1efce086))

### 🚧 Maintanance
- **changelog:** set log level to info for changelog script ([7074eed](https://github.com/tprasadtp/protonvpn-docker/commit/7074eed97db34249954025d7151e025c74d34340))

### 🤖 CI/CD & Automation
- do not use ci cache for trivy db as cache is broken on 0.0.14 release ([12251d2](https://github.com/tprasadtp/protonvpn-docker/commit/12251d23e278f013391a645cc2c6572680cbb709))
- update workflows and automation configs ([32c14eb](https://github.com/tprasadtp/protonvpn-docker/commit/32c14ebf93b0990a3e502ca3e3dfe0e8051a34eb))
- **deps:** bump aquasecurity/trivy-action from 0.0.13 to 0.0.14 ([#38](https://github.com/tprasadtp/protonvpn-docker/issues/38)) ([1b2676a](https://github.com/tprasadtp/protonvpn-docker/commit/1b2676a2ad04586f1ea88bd8245b10e9bb0ddc8e))


<a name="4.1.4"></a>
## [4.1.4] - 2021-04-07

### 🐛 Bug Fixes
- ([#36](https://github.com/tprasadtp/protonvpn-docker/issues/36)) connection to random server  ([#37](https://github.com/tprasadtp/protonvpn-docker/issues/37)) ([99ce05b](https://github.com/tprasadtp/protonvpn-docker/commit/99ce05bd6714e3c19b8cba775a5557deeace2072))


<a name="4.1.3"></a>
## [4.1.3] - 2021-04-05

### 🚧 Maintanance
- **deps:** bump ubuntu from focal-20210325 to focal-20210401 ([#34](https://github.com/tprasadtp/protonvpn-docker/issues/34)) ([f8d3c38](https://github.com/tprasadtp/protonvpn-docker/commit/f8d3c384460e3cfeabbfaa8b7188b400a8c10b40))

### 🤖 CI/CD & Automation
- update dependabot configs ([117fa9c](https://github.com/tprasadtp/protonvpn-docker/commit/117fa9ce13284cf9b7f2a4ba7512c0ab47d11529))
- **deps:** bump goreleaser/goreleaser-action ([#33](https://github.com/tprasadtp/protonvpn-docker/issues/33)) ([ced9ead](https://github.com/tprasadtp/protonvpn-docker/commit/ced9ead448615a230144fbfee174e337daca4cff))


<a name="4.1.2"></a>
## [4.1.2] - 2021-03-26

### 🚧 Maintanance
- **deps:** bump ubuntu from focal-20210217 to focal-20210325 ([#30](https://github.com/tprasadtp/protonvpn-docker/issues/30)) ([1c25946](https://github.com/tprasadtp/protonvpn-docker/commit/1c2594684f9d43f702a19983d99b9433356ec693))
- **deps:** bump urllib3 from 1.26.3 to 1.26.4 in /root ([#26](https://github.com/tprasadtp/protonvpn-docker/issues/26)) ([4148872](https://github.com/tprasadtp/protonvpn-docker/commit/4148872439bb6499855ca1ba3488a4bb3cd8de60))

### 🤖 CI/CD & Automation
- Fix Trivy workflow ([#31](https://github.com/tprasadtp/protonvpn-docker/issues/31)) ([91e23cd](https://github.com/tprasadtp/protonvpn-docker/commit/91e23cd9f5577fe8e66d8fe921f82a8fa83d8b7e))
- **deps:** bump aquasecurity/trivy-action from 0.0.11 to 0.0.12 ([#28](https://github.com/tprasadtp/protonvpn-docker/issues/28)) ([b340412](https://github.com/tprasadtp/protonvpn-docker/commit/b340412df2f151377603e5d4e5eed1218e81ef23))


<a name="4.1.1"></a>
## [4.1.1] - 2021-03-14

### 🚧 Maintanance
- **changelog:** fix release notes script ([#23](https://github.com/tprasadtp/protonvpn-docker/issues/23)) ([19c01e3](https://github.com/tprasadtp/protonvpn-docker/commit/19c01e38f1b1622807b4b9fccc08bc86741e7cfd))

### 🤖 CI/CD & Automation
- (experimental) add image scanning as a cron job ([#24](https://github.com/tprasadtp/protonvpn-docker/issues/24)) ([4ad9d7c](https://github.com/tprasadtp/protonvpn-docker/commit/4ad9d7cd6573f77c3b2fa3b19a9722c727a1c029))


<a name="4.1.0"></a>
## [4.1.0] - 2021-03-12

###  SECURITY UPDATES
- Updated base image from python to ubuntu:focal

### 🤖 CI/CD & Automation
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

### 🚧 Maintanance
- add generated files to gitignore ([af65559](https://github.com/tprasadtp/protonvpn-docker/commit/af6555906a4ea95f342cfbe947c4f6fc00b7357f))
- **changelog:**  add helper script ([9bc8194](https://github.com/tprasadtp/protonvpn-docker/commit/9bc8194dc373e6e34a791d044f1afc2c2fb32002))
- **changelog:** automate changelog generation ([99c72e1](https://github.com/tprasadtp/protonvpn-docker/commit/99c72e1233757c5cf79412709977212156c31434))
- **deps:** update python deps ([c668530](https://github.com/tprasadtp/protonvpn-docker/commit/c668530e252a6969d0f3f782b282feea0875a4b6))

### 🤖 CI/CD & Automation
- use github environments for secrets ([3536ada](https://github.com/tprasadtp/protonvpn-docker/commit/3536adabb497f2368d08b6dca26fda171b26e92e))
- use goreleaser to build docker images ([b34aa11](https://github.com/tprasadtp/protonvpn-docker/commit/b34aa11b61614579b46dd389ce97bf61992d2b21))
- **automation:** PR automation via kodiak ([06f6307](https://github.com/tprasadtp/protonvpn-docker/commit/06f63078ac79de67c4f6d315a16ac75bbf6b99c4))
- **dependabot:** enable dependabot ([37d0faa](https://github.com/tprasadtp/protonvpn-docker/commit/37d0faa2633cf50a37868a521035d8402066dc6c))
- **labels:** Manage issue labels via tprasadtp/labels ([d818d85](https://github.com/tprasadtp/protonvpn-docker/commit/d818d856fe6660b48ed90c82a7a3c23eea2483cd))

### Reverts
- ci: use github environments for secrets ([cc62463](https://github.com/tprasadtp/protonvpn-docker/commit/cc62463de3e35c318a94147c55e38a921d7f9287))


<!-- tag references -->
[Unreleased]: https://github.com/tprasadtp/protonvpn-docker/compare/4.2.1...HEAD
[4.2.1]: https://github.com/tprasadtp/protonvpn-docker/compare/4.2.0...4.2.1
[4.2.0]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.5...4.2.0
[4.1.5]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.4...4.1.5
[4.1.4]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.3...4.1.4
[4.1.3]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.2...4.1.3
[4.1.2]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.1...4.1.2
[4.1.1]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.0...4.1.1
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
