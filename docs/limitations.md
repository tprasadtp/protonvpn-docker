## Known issues

- Kill switch is **NOT** reliable. This is due to the way protonvpn cli works because on issuing reconnect they remove
re-initialize iptables rules which removes block on outgoing connections for a short duration until iptables rules are applied again.

## Included protonvpn-cli is old

- Err, Yeah, cant help! Newer versions depend on network-manager and are integrated with network manager, which obviously is not in the docker image nor supported!
