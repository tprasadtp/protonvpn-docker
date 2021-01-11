# Changelog

## 2.2.6

- **BREAKING CHANGE**: `PROTONVPN_SERVER` and `PROTONVPN_COUNTRY` are now exclusive. Only one of the can be used at a time.
- **BREAKING CHANGE**: DNS argument(`--dns`) is no longer mandatory to run the image.
- **NEW**: Support split tunnel settings.
- **NEW**: Support for disabling DNS leak protection
- (Internal) Update protonvpn-cli to 2.2.6
- (Internal) Removes included templates as its handled by protonvpn-cli
- (Internal) Removes fetching server configs as it is handled by updated cli
- (Internal) Update s6 overlay
- (Internal) Use CLI request headers for API endpoint
- (Internal) Use updated configs fields during container init (`api_domain`)
- (CI/CD) Added support for `ghcr.io` GitHub container registry
- (Internal) Changes health-check url to `https://ipinfo.io` as ProtonVPN API is inconsistent.

## 2.2.2-hotfix-2

- Add Health-check script
- Initial stable release
