# Split Tunneling

- You can specify list of CIDR blocks to exclude from VPN via `PROTONVPN_EXCLUDE_CIDRS` environment variable.
This will use split tunneling feature to exclude routing these CIDR blocks over VPN connection.
By default instance metadata IPs which are commonly used on cloud environments are excluded.
- Split tunneling can be disabled by setting `PROTONVPN_EXCLUDE_CIDRS` to empty string.
