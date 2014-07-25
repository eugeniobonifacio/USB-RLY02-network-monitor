USB-RLY02-network-monitor
=========================

A bash script for network monitoring. If network is unreachable it uses USB-RLY02 module to switch off the ADSL router for 60 seconds.

Sometimes my ADSL router hangs so I cannot access to my server from outside. This bash script can be executed by a cron job and checks if the listed HTTP hosts are reachable. If only one of these is not reachable, a failure count will occur. When the max failure count is done it uses the [Python-RLY02 script](https://github.com/superalex/Python-RLY02) to take the router switched off for 60 seconds. Once the network returns reachable, it then sends a notification e-mail informing about the event.

