# Changelog


<a name="5.2.0"></a>
## [5.2.0] - 2022-03-06

### 🐛 Bug Fixes
- Change default health-check endpoint to `https://icanhazip.com/` and strip newlines from healthcheck endpoint responses ([14f0796](https://github.com/tprasadtp/protonvpn-docker/commit/14f07967be581517ab86b07a18903c439de9a972))

### 🚧 Maintenance
- **deps:** bump ubuntu from focal-20220113 to focal-20220302 ([#97](https://github.com/tprasadtp/protonvpn-docker/issues/97)) ([4206035](https://github.com/tprasadtp/protonvpn-docker/commit/42060356e9bd905ba0bc430e3d720817daa0654d))

### 🤖 CI/CD & Automation
- **deps:** bump goreleaser/goreleaser-action from 2.8.1 to 2.9.1 ([#98](https://github.com/tprasadtp/protonvpn-docker/issues/98)) ([315fa3b](https://github.com/tprasadtp/protonvpn-docker/commit/315fa3b9c4ad7683cecb9366661d7a8388864a6d))
- **deps:** bump actions/checkout from 2 to 3 ([#99](https://github.com/tprasadtp/protonvpn-docker/issues/99)) ([ed9a212](https://github.com/tprasadtp/protonvpn-docker/commit/ed9a2120a9e3643c2cc058b600a8ec65e20c66ff))


<a name="5.1.2"></a>
## [5.1.2] - 2022-02-14

### 🍒 Features & Enhancements
- Refresh server info using cron (hourly) ([b75a7df](https://github.com/tprasadtp/protonvpn-docker/commit/b75a7dfddd129b895e1b4093b70677fe6135afdf))

### 🐛 Bug Fixes
- Allow checking exit ips for servers with the same domain ([#88](https://github.com/tprasadtp/protonvpn-docker/issues/88)) ([2fbd795](https://github.com/tprasadtp/protonvpn-docker/commit/2fbd7951113a09eea88d2f31758cada9698408ab))

### 📖 Documentation
- Add info about libsecomp issues on 32 bit arm ([4a21b51](https://github.com/tprasadtp/protonvpn-docker/commit/4a21b512126f7f552045010e58aa725ade134dd5))

### 🚧 Maintenance
- Update changelog scripts ([25cab16](https://github.com/tprasadtp/protonvpn-docker/commit/25cab16c12f5c3dcb380dc83e14268e725117e2a))
- **deps:** bump ubuntu from focal-20220105 to focal-20220113 ([#95](https://github.com/tprasadtp/protonvpn-docker/issues/95)) ([3e80ba0](https://github.com/tprasadtp/protonvpn-docker/commit/3e80ba057c4b7d1458065cc2412041ed217afe40))
- **deps:** bump urllib3 from 1.26.7 to 1.26.8 in /root ([#90](https://github.com/tprasadtp/protonvpn-docker/issues/90)) ([d1111c7](https://github.com/tprasadtp/protonvpn-docker/commit/d1111c7cf8f7ec65ced22aa2e6095c98312cc72f))
- **deps:** bump requests from 2.26.0 to 2.27.1 in /root ([e9523c2](https://github.com/tprasadtp/protonvpn-docker/commit/e9523c2ac7a5b1f30defbd49084541b31a0c4524))
- **deps:** bump ubuntu from focal-20211006 to focal-20220105 ([c0a9edd](https://github.com/tprasadtp/protonvpn-docker/commit/c0a9edd1886a22e7ca3e815075ee1de71f1039e5))
- **deps:** bump jinja2 from 3.0.2 to 3.0.3 in /root ([#85](https://github.com/tprasadtp/protonvpn-docker/issues/85)) ([b44b17a](https://github.com/tprasadtp/protonvpn-docker/commit/b44b17afd45086c7af630af23a0bc295e89514d5))
- **deps:** bump ubuntu from focal-20210921 to focal-20211006 ([#81](https://github.com/tprasadtp/protonvpn-docker/issues/81)) ([fe7dca6](https://github.com/tprasadtp/protonvpn-docker/commit/fe7dca622c11a939a7f356a55da20ab6f0d77866))
- **deps:** bump jinja2 from 3.0.1 to 3.0.2 in /root ([#79](https://github.com/tprasadtp/protonvpn-docker/issues/79)) ([f24fb56](https://github.com/tprasadtp/protonvpn-docker/commit/f24fb56380750bba4995786fac230485c231bbef))
- **deps:** bump ubuntu from focal-20210827 to focal-20210921 ([#77](https://github.com/tprasadtp/protonvpn-docker/issues/77)) ([748bcf6](https://github.com/tprasadtp/protonvpn-docker/commit/748bcf6681269066cd70bb038929a6e5e7d66255))
- **deps:** bump urllib3 from 1.26.6 to 1.26.7 in /root ([#75](https://github.com/tprasadtp/protonvpn-docker/issues/75)) ([958f78d](https://github.com/tprasadtp/protonvpn-docker/commit/958f78d3b24c64f0e088a52edaaa6ac5f2f3bf68))

### 🤖 CI/CD & Automation
- Fix duplicate labels in dependabot config ([ea002c4](https://github.com/tprasadtp/protonvpn-docker/commit/ea002c4fad1e65689be0ef5afb20c6bb028eec72))
- Dependeabot and Kodiak - Sync automerge labels ([09e8042](https://github.com/tprasadtp/protonvpn-docker/commit/09e80421e10bcef728d16bc2ce0da5089d6b237c))
- Update logging, CI, script & Issue templates ([fd92c6a](https://github.com/tprasadtp/protonvpn-docker/commit/fd92c6a80210ebefdd4517e088278fb2e3f5cf29))
- Add configuration for Semantic PR app ([d2c74a9](https://github.com/tprasadtp/protonvpn-docker/commit/d2c74a9d9ece83ed401d6cb85e9788224e8b007d))
- Disable homebrew auto update ([9df7e92](https://github.com/tprasadtp/protonvpn-docker/commit/9df7e927888d8b2a6cbd7db0267c06c0e8c00fb8))
- Remove dependabot patch update config for pip config as it dependabot handle splitting patch and major version updates with different settings. ([6a0dd73](https://github.com/tprasadtp/protonvpn-docker/commit/6a0dd73013644b228753e829dad9ee2df8bd2dd8))
- fix trivy checks failing due to wrong image tag in release workflow ([10d9325](https://github.com/tprasadtp/protonvpn-docker/commit/10d93253463e1fcc8e1beaa3a89e83193c6bed9b))
- **chore:** Update labels ([0f8b15d](https://github.com/tprasadtp/protonvpn-docker/commit/0f8b15d445e851c1996f4ea89ef5c2925c5881a6))
- **deps:** bump aquasecurity/trivy-action from 0.2.0 to 0.2.1 ([d86eb2b](https://github.com/tprasadtp/protonvpn-docker/commit/d86eb2b1e9e013687e7029d54cdba298ccc91093))
- **deps:** bump goreleaser/goreleaser-action from 2.8.0 to 2.8.1 ([#94](https://github.com/tprasadtp/protonvpn-docker/issues/94)) ([26cb672](https://github.com/tprasadtp/protonvpn-docker/commit/26cb672152ff587388a94d417c9c1e5c3cc80ad4))
- **deps:** bump aquasecurity/trivy-action from 0.2.1 to 0.2.2 ([#96](https://github.com/tprasadtp/protonvpn-docker/issues/96)) ([1188fc8](https://github.com/tprasadtp/protonvpn-docker/commit/1188fc8f1d59374cff3b6655fe6cae6247fbe4e9))
- **deps:** bump aquasecurity/trivy-action from 0.1.0 to 0.2.0 ([#86](https://github.com/tprasadtp/protonvpn-docker/issues/86)) ([7cec976](https://github.com/tprasadtp/protonvpn-docker/commit/7cec9765383d5fadb9ca63766638e09d05b47d2b))
- **deps:** bump aquasecurity/trivy-action from 0.0.22 to 0.1.0 ([#84](https://github.com/tprasadtp/protonvpn-docker/issues/84)) ([10f05b5](https://github.com/tprasadtp/protonvpn-docker/commit/10f05b52bd201d6a350b367d8cfa1a5bfe809997))
- **deps:** bump aquasecurity/trivy-action from 0.0.19 to 0.0.22 ([#83](https://github.com/tprasadtp/protonvpn-docker/issues/83)) ([6104bd4](https://github.com/tprasadtp/protonvpn-docker/commit/6104bd41efeb803927e0b2707f3d3f48ee7005b1))
- **deps:** bump goreleaser/goreleaser-action from 2.7.0 to 2.8.0 ([#82](https://github.com/tprasadtp/protonvpn-docker/issues/82)) ([4e67ed1](https://github.com/tprasadtp/protonvpn-docker/commit/4e67ed10f83827433a70b182b40a8a6723fda048))


<a name="5.0.1"></a>
## [5.0.1] - 2021-09-24

### 🐛 Bug Fixes
- Conditional checks for `PROTONVPN_TIER` [#74](https://github.com/tprasadtp/protonvpn-docker/issues/74) ([244dbae](https://github.com/tprasadtp/protonvpn-docker/commit/244dbae9ce2989f30976765a4fae459fc4366c7a))


<a name="5.0.0"></a>
## [5.0.0] - 2021-09-23

### ⚠️ BREAKING CHANGES
- Healthchecks now check if client's Public IP is in the list of exit IPs of the connected logical server
- Specifying `PROTONVPN_SERVER` is now required environment variable.
- `PROTONVPN_COUNTRY` is merged into `PROTONVPN_SERVER`.
- Users who are migrating from version 4.x or below rename `PROTONVPN_COUNTRY` to `PROTONVPN_SERVER`.
- You can migrate value of `PROTONVPN_COUNTRY` to `PROTONVPN_SERVER`. Container will detect that you wish to connct to country specified and connect as usual.

### 🍒 Features & Enhancements
- Use Server IPS instead of server country in healthchecks ([f0ffcc2](https://github.com/tprasadtp/protonvpn-docker/commit/f0ffcc22091c9e502791ccef13bef2d448c22cac))
- Merge `PROTONVPN_SERVER` and `PROTONVPN_COUNTRY` into `PROTONVPN_SERVER`. ([e3e55ca](https://github.com/tprasadtp/protonvpn-docker/commit/e3e55caa5b5a305fb2a8b827919db2724813cbd1))

### 🐛 Bug Fixes
- invalid logging functions, `DEBUG=1` now enables debug logs for protonvpn-cli and out container logs ([fe04e5e](https://github.com/tprasadtp/protonvpn-docker/commit/fe04e5e3ab507eb9e2f226329056591a6781f271))

### 📖 Documentation
- In issue form, Extend credential validation checkboxes to include checks for openvpn credentials ([652e0fb](https://github.com/tprasadtp/protonvpn-docker/commit/652e0fb0a9e649c92529f9173b2f3a2cd72fa3d9))
- Fix docker logo URL in README ([4cf3b0d](https://github.com/tprasadtp/protonvpn-docker/commit/4cf3b0d189c6a493d8d75c440a884eb58c6c64f2))
- Improve docs, add gh issue forms ([ed3e672](https://github.com/tprasadtp/protonvpn-docker/commit/ed3e6720feec6371c2e78dac4d9c0a897dca8b1c))
- Reorganize to better handle GitHub Pages ([#48](https://github.com/tprasadtp/protonvpn-docker/issues/48)) ([96bdfc8](https://github.com/tprasadtp/protonvpn-docker/commit/96bdfc8f683091c060b762529fbec0ded89de075))
- Enable Github pages and add troubleshooting docs ([a0ba4ee](https://github.com/tprasadtp/protonvpn-docker/commit/a0ba4eec74f5b8ab89db7ed77aae30f786404e59))
- Update debugging compose file ([c127608](https://github.com/tprasadtp/protonvpn-docker/commit/c1276081a57e737a0b549abc3b839ae4cdca0610))
- **fix:** Issue forms ([7062295](https://github.com/tprasadtp/protonvpn-docker/commit/7062295978448cc086dc80d763b7dd6d4bea1961))
- **fix:** Issue form quore booleans ([1520a11](https://github.com/tprasadtp/protonvpn-docker/commit/1520a1162210212cdf98dd06931f2c9fdbb9e748))

### 🚧 Maintenance
- Beta 5.0 ([585b277](https://github.com/tprasadtp/protonvpn-docker/commit/585b277fcd3ca9199bc12db575671878dd48e0f4))
- Update templates ([c122bed](https://github.com/tprasadtp/protonvpn-docker/commit/c122bed299f910c197fb90f1d21523d22849ed17))
- Update templates ([51d120c](https://github.com/tprasadtp/protonvpn-docker/commit/51d120c312860930d35efa9005ac3870c530a6d0))
- Import updated makefiles and changelog templates ([e1e41fb](https://github.com/tprasadtp/protonvpn-docker/commit/e1e41fb26559622946adbdaa0305519698b8b3b9))
- **automation:** Allow automerge of docker image updates done via dependabot ([74ee95e](https://github.com/tprasadtp/protonvpn-docker/commit/74ee95e83ebdd56e4215fcd83f79c4ddc6df8783))
- **changelog:** Update changelog emojis to follow common snippets ([91cd108](https://github.com/tprasadtp/protonvpn-docker/commit/91cd108bc2979984ce24d279080cf39ca7083cd1))
- **ci:** Cache Trivy DB ([09c68d8](https://github.com/tprasadtp/protonvpn-docker/commit/09c68d823a5cb490870712658b0a3054365baf3d))
- **ci:** vendor justcontainers key as keybase returns 404 and update dockerfiles for better caching ([f3d5a14](https://github.com/tprasadtp/protonvpn-docker/commit/f3d5a14fd4de1a25c7c51038d3999811c520e21c))
- **deps:** bump urllib3 from 1.26.5 to 1.26.6 in /root ([#59](https://github.com/tprasadtp/protonvpn-docker/issues/59)) ([ea649cc](https://github.com/tprasadtp/protonvpn-docker/commit/ea649cca549769377516fd27fa546df71bb6b8d1))
- **deps:** bump ubuntu from focal-20210416 to focal-20210609 ([bf8f27e](https://github.com/tprasadtp/protonvpn-docker/commit/bf8f27e3bcf45ff0c6b9af745af9b382ab5cc2d2))
- **deps:** bump ubuntu from focal-20210416 to focal-20210609 ([#57](https://github.com/tprasadtp/protonvpn-docker/issues/57)) ([18209c3](https://github.com/tprasadtp/protonvpn-docker/commit/18209c3886f20af08f9cc3a06d0049a48d8c81c5))
- **deps:** bump urllib3 from 1.26.4 to 1.26.5 in /root ([#53](https://github.com/tprasadtp/protonvpn-docker/issues/53)) ([075ac2e](https://github.com/tprasadtp/protonvpn-docker/commit/075ac2e33e209ebe0bbb0fa92b38bd0713622cf6))
- **deps:** bump jinja2 from 2.11.3 to 3.0.1 in /root ([#49](https://github.com/tprasadtp/protonvpn-docker/issues/49)) ([ebff6d6](https://github.com/tprasadtp/protonvpn-docker/commit/ebff6d695b1a1beb297c6826b0707717f851a4ac))
- **deps:** bump ubuntu from focal-20210609 to focal-20210713 ([#64](https://github.com/tprasadtp/protonvpn-docker/issues/64)) ([6b3d787](https://github.com/tprasadtp/protonvpn-docker/commit/6b3d787130c89038a8535a2e00fe0531e3acd05b))
- **deps:** bump requests from 2.25.1 to 2.26.0 in /root ([#66](https://github.com/tprasadtp/protonvpn-docker/issues/66)) ([ea16a56](https://github.com/tprasadtp/protonvpn-docker/commit/ea16a56799e9fbc77d29b85acb679ba117ef07c9))
- **deps:** bump ubuntu from focal-20210713 to focal-20210723 ([#68](https://github.com/tprasadtp/protonvpn-docker/issues/68)) ([47caa8e](https://github.com/tprasadtp/protonvpn-docker/commit/47caa8efd58c6774b14cb47c5bf46714a37fffce))
- **deps:** bump ubuntu from focal-20210723 to focal-20210827 ([c15a941](https://github.com/tprasadtp/protonvpn-docker/commit/c15a9412616e8722fd861c5e28939baa008d3d77))
- **deps:** bump protonvpn-cli from 2.2.6 to 2.2.7 in /root ([#58](https://github.com/tprasadtp/protonvpn-docker/issues/58)) ([616e670](https://github.com/tprasadtp/protonvpn-docker/commit/616e670262c5c70b7f5847b6bde37ec15291c942))

### 🤖 CI/CD & Automation
- Checkout tag corresponding to latest release, before doing scheduled security scan to help populate required fields for codeql action ([842e834](https://github.com/tprasadtp/protonvpn-docker/commit/842e8348be330743ab708d081a61440c7c0e7c56))
- **dependabot:** Fix wrong label on docker updates ([3adf882](https://github.com/tprasadtp/protonvpn-docker/commit/3adf882c8c50d7df5cf652502b64b8f0adc64fce))
- **deps:** bump aquasecurity/trivy-action from 0.0.17 to 0.0.18 ([#55](https://github.com/tprasadtp/protonvpn-docker/issues/55)) ([08564f2](https://github.com/tprasadtp/protonvpn-docker/commit/08564f2a3416af3433d7312dad65892d12f5f3e2))
- **deps:** bump aquasecurity/trivy-action from 0.0.14 to 0.0.15 ([#44](https://github.com/tprasadtp/protonvpn-docker/issues/44)) ([a19d7aa](https://github.com/tprasadtp/protonvpn-docker/commit/a19d7aa4aae72f7d883f6e4b6ea3f2f036bd3a9c))
- **deps:** bump aquasecurity/trivy-action from 0.0.15 to 0.0.16 ([#46](https://github.com/tprasadtp/protonvpn-docker/issues/46)) ([7e90b7d](https://github.com/tprasadtp/protonvpn-docker/commit/7e90b7d06dcbd2d85e06393cd109c7575d36fd2d))
- **deps:** bump actions/stale from 3 to 4 ([#65](https://github.com/tprasadtp/protonvpn-docker/issues/65)) ([de1fc14](https://github.com/tprasadtp/protonvpn-docker/commit/de1fc1437411c5561d80b1344702dc75ef3859d8))
- **deps:** bump goreleaser/goreleaser-action from 2.6.0 to 2.6.1 ([#56](https://github.com/tprasadtp/protonvpn-docker/issues/56)) ([af63fa7](https://github.com/tprasadtp/protonvpn-docker/commit/af63fa7bf8ce6e26f78b05442139a905ca4ab6b6))
- **deps:** bump goreleaser/goreleaser-action from 2.6.1 to 2.7.0 ([#70](https://github.com/tprasadtp/protonvpn-docker/issues/70)) ([6bb795a](https://github.com/tprasadtp/protonvpn-docker/commit/6bb795a195dec26fa5048a17b8085a76bf48af2d))
- **deps:** bump goreleaser/goreleaser-action from 2.5.0 to 2.6.0 ([#52](https://github.com/tprasadtp/protonvpn-docker/issues/52)) ([2e05f51](https://github.com/tprasadtp/protonvpn-docker/commit/2e05f518835ac256e65ed814187a934f36da8699))
- **deps:** bump aquasecurity/trivy-action from 0.0.16 to 0.0.17 ([#47](https://github.com/tprasadtp/protonvpn-docker/issues/47)) ([a995116](https://github.com/tprasadtp/protonvpn-docker/commit/a995116c8077e8fa2970c5450109b412dff14e06))
- **deps:** bump aquasecurity/trivy-action from 0.0.18 to 0.0.19 ([#69](https://github.com/tprasadtp/protonvpn-docker/issues/69)) ([2e851e3](https://github.com/tprasadtp/protonvpn-docker/commit/2e851e3f9d664d1477ab1cefe58fee91f792013b))
- **goreleaser:** Migrate from docker.use_buildx to docker.use ([ca7f874](https://github.com/tprasadtp/protonvpn-docker/commit/ca7f874aaee8eba7c166229a2edbea090b92b4b3))
- **kodiak:** Remove default block on GH-Actions dependency updates ([b5172d4](https://github.com/tprasadtp/protonvpn-docker/commit/b5172d45934d5438a9f9a8007b25ec3c0291d9cf))
- **stale:** Change stale workflow to run weekly ([c1a4580](https://github.com/tprasadtp/protonvpn-docker/commit/c1a45803573200ba724a4c8efc62ccbfb0a7e97b))

### Reverts
- chore(deps): bump protonvpn-cli from 2.2.6 to 2.2.7 in /root ([#58](https://github.com/tprasadtp/protonvpn-docker/issues/58)) ([efff4ce](https://github.com/tprasadtp/protonvpn-docker/commit/efff4ce920ad010fdb72637c1701d9aa841fd6b3))


<a name="4.2.1"></a>
## [4.2.1] - 2021-05-05

### 🚧 Maintenance
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

### 🚧 Maintenance
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

### 🚧 Maintenance
- **deps:** bump ubuntu from focal-20210325 to focal-20210401 ([#34](https://github.com/tprasadtp/protonvpn-docker/issues/34)) ([f8d3c38](https://github.com/tprasadtp/protonvpn-docker/commit/f8d3c384460e3cfeabbfaa8b7188b400a8c10b40))

### 🤖 CI/CD & Automation
- update dependabot configs ([117fa9c](https://github.com/tprasadtp/protonvpn-docker/commit/117fa9ce13284cf9b7f2a4ba7512c0ab47d11529))
- **deps:** bump goreleaser/goreleaser-action ([#33](https://github.com/tprasadtp/protonvpn-docker/issues/33)) ([ced9ead](https://github.com/tprasadtp/protonvpn-docker/commit/ced9ead448615a230144fbfee174e337daca4cff))


<a name="4.1.2"></a>
## [4.1.2] - 2021-03-26

### 🚧 Maintenance
- **deps:** bump ubuntu from focal-20210217 to focal-20210325 ([#30](https://github.com/tprasadtp/protonvpn-docker/issues/30)) ([1c25946](https://github.com/tprasadtp/protonvpn-docker/commit/1c2594684f9d43f702a19983d99b9433356ec693))
- **deps:** bump urllib3 from 1.26.3 to 1.26.4 in /root ([#26](https://github.com/tprasadtp/protonvpn-docker/issues/26)) ([4148872](https://github.com/tprasadtp/protonvpn-docker/commit/4148872439bb6499855ca1ba3488a4bb3cd8de60))

### 🤖 CI/CD & Automation
- Fix Trivy workflow ([#31](https://github.com/tprasadtp/protonvpn-docker/issues/31)) ([91e23cd](https://github.com/tprasadtp/protonvpn-docker/commit/91e23cd9f5577fe8e66d8fe921f82a8fa83d8b7e))
- **deps:** bump aquasecurity/trivy-action from 0.0.11 to 0.0.12 ([#28](https://github.com/tprasadtp/protonvpn-docker/issues/28)) ([b340412](https://github.com/tprasadtp/protonvpn-docker/commit/b340412df2f151377603e5d4e5eed1218e81ef23))


<a name="4.1.1"></a>
## [4.1.1] - 2021-03-14

### 🚧 Maintenance
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

### 🚧 Maintenance
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
[5.2.0]: https://github.com/tprasadtp/protonvpn-docker/compare/5.1.2...5.2.0
[5.1.2]: https://github.com/tprasadtp/protonvpn-docker/compare/5.0.1...5.1.2
[5.0.1]: https://github.com/tprasadtp/protonvpn-docker/compare/5.0.0...5.0.1
[5.0.0]: https://github.com/tprasadtp/protonvpn-docker/compare/4.2.1...5.0.0
[4.2.1]: https://github.com/tprasadtp/protonvpn-docker/compare/4.2.0...4.2.1
[4.2.0]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.5...4.2.0
[4.1.5]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.4...4.1.5
[4.1.4]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.3...4.1.4
[4.1.3]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.2...4.1.3
[4.1.2]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.1...4.1.2
[4.1.1]: https://github.com/tprasadtp/protonvpn-docker/compare/4.1.0...4.1.1
[4.1.0]: https://github.com/tprasadtp/protonvpn-docker/compare/4.0.0...4.1.0
[4.0.0]: https://github.com/tprasadtp/protonvpn-docker/compare/3.1.0...4.0.0
<!-- diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type} -->
<!-- diana:2:github:tprasadtp/templates::common/chglog/CHANGELOG.md.tpl:static -->
