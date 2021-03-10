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


<a name="4.0.0-beta1"></a>
## [4.0.0-beta1] - 2021-03-10
### 🍒 Features
- Deprecate Docker Hub image ([b41ed98](https://github.com/tprasadtp/protonvpn-docker/commits/b41ed98d5471e17e1470822407756d239d575124))

### 🐛 Bug Fixes
- `SIGTERM` and `SIGINT` not being handled properly ([aecf1d4](https://github.com/tprasadtp/protonvpn-docker/commits/aecf1d4eb32e11749faebf38068e468266422775))

### 📖 Documentation
- document internal healthcheck intervals and update badges ([5583614](https://github.com/tprasadtp/protonvpn-docker/commits/5583614d9954826a3077f1567f2818d0e4771635))

### 🤖 Continuous Integration & Automation
- use github environments for secrets ([3536ada](https://github.com/tprasadtp/protonvpn-docker/commits/3536adabb497f2368d08b6dca26fda171b26e92e))
- use goreleaser to build docker images ([b34aa11](https://github.com/tprasadtp/protonvpn-docker/commits/b34aa11b61614579b46dd389ce97bf61992d2b21))
- **automation:** PR automation via kodiak ([06f6307](https://github.com/tprasadtp/protonvpn-docker/commits/06f63078ac79de67c4f6d315a16ac75bbf6b99c4))
- **dependabot:** enable dependabot ([37d0faa](https://github.com/tprasadtp/protonvpn-docker/commits/37d0faa2633cf50a37868a521035d8402066dc6c))
- **labels:** Manage issue labels via tprasadtp/labels ([d818d85](https://github.com/tprasadtp/protonvpn-docker/commits/d818d856fe6660b48ed90c82a7a3c23eea2483cd))

### 🥺 Maintanance
- add generated files to gitignore ([af65559](https://github.com/tprasadtp/protonvpn-docker/commits/af6555906a4ea95f342cfbe947c4f6fc00b7357f))
- **changelog:** automate changelog generation ([99c72e1](https://github.com/tprasadtp/protonvpn-docker/commits/99c72e1233757c5cf79412709977212156c31434))
- **deps:** update python deps ([c668530](https://github.com/tprasadtp/protonvpn-docker/commits/c668530e252a6969d0f3f782b282feea0875a4b6))

### BREAKING CHANGES
- Docker Hub image is deprecated and will not be updated.
- You **MUST** use GHCR image. (`ghcr.io/tprasadtp/protonvpn`)
- rename `LIVE_PROBE_INTERVAL` to `PROTONVPN_CHECK_INTERVAL`
- rename `RECONNECT_THRESHOLD` to `PROTONVPN_FAIL_THRESHOLD`
- increase `S6_KILL_GRACETIME` from default to 10000 (10s) to avoid timeouts

<a name="3.1.0"></a>
## [3.1.0] - 2021-02-27

<a name="3.0.0"></a>
## [3.0.0] - 2021-02-20

<a name="2.2.6"></a>
## 2.2.6 - 2021-01-12

<!-- tag references -->
[Unreleased]: https://github.com/tprasadtp/protonvpn-docker/compare/4.0.0-beta1...HEAD
[4.0.0-beta1]: https://github.com/tprasadtp/protonvpn-docker/compare/3.1.0...4.0.0-beta1
[3.1.0]: https://github.com/tprasadtp/protonvpn-docker/compare/3.0.0...3.1.0
[3.0.0]: https://github.com/tprasadtp/protonvpn-docker/compare/2.2.6...3.0.0

