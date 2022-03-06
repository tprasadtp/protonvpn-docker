## Known issues

- Kill switch is **NOT** reliable. This is due to the way ProtonVPN cli works because on issuing reconnect they remove
re-initialize iptables rules which removes block on outgoing connections for a short duration until iptables rules are applied again.

## Included protonvpn-cli is old

- Newer versions depend on network-manager and are integrated with network manager, which obviously is not in the docker image nor supported!
- The Cli is just a wrapper to ProtonVPN API and some subprocess calls to start openvpn client. Dependencies are updated whenever security issues are found (You can check in security tab of the repo). So that should be more than enough as long as the ProtonVPN API does not change.
