# Changelog

## 2.2.6

- **BREAKING CHANGE**: `PROTONVPN_SERVER` and `PROTONVPN_COUNTRY` are now
exclusive. Only one of the can be used at a time.
- **BREAKING CHANGE**: DNS argument(`--dns`) is no longer mandatory to run the image.
- **NEW**: Support split tunnel settings.
- **NEW**: Support for disabling DNS leak protection
- _(Internal)_ Update protonvpn-cli to 2.2.6
- _(Internal)_ Removes included templates as its handled by protonvpn-cli
- _(Internal)_ Update s6 overlay
- _(Internal)_ Update base docker image
- _(Internal)_ Use CLI request headers for API endpoint
- _(Internal)_ Use updated configs fields during container init (`api_domain`)
- _(CI/CD)_ Added support for GitHub container registry
- _(Internal)_ Changes health-check url to `https://ipinfo.io` as ProtonVPN API is inconsistent.

## 2.2.2-hotfix-2

- Add Health-check script
- Initial stable release

> Please noe that this version is not available on GitHub package registry.
