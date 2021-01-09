# Changelog

## 2.2.6

- Support for specifying custom DNS servers via env variables.
- Support split tunnel settings.
- Update protonvpn-cli to 2.2.6
- DNS argument(`--dns`) is no longer necessary while running docker commands (Though might be necessary on k8s)
- (Internal) Removes included templates as its handled by protonvpn-cli
- (Internal) Removes fetching server configs as it is handled by updated cli
- (Internal) Update s6 overlay
- (Internal) Use CLI request headers for API endpoint
- (Internal) Use updated configs fields during container init (`api_domain`)
- (CI/CD) Added support for `ghcr.io` GitHub container registry

## 2.2.2-hotfix-2

- Add Health-check script
- Initial stable release
