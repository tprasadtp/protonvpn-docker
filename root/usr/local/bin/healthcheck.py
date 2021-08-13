#!/usr/bin/env python3
import configparser
import json
import logging
import os
import sys
from pathlib import Path
import urllib.request

if os.getenv("DEBUG", "0") == "1":
    logging.basicConfig(
        format="%(asctime)s  [%(levelname)-8s] %(message)s",
        level=logging.DEBUG,
        datefmt="%Y-%m-%d %H:%M:%S%z",
    )
    logging.getLogger("requests.packages.urllib3").setLevel(logging.DEBUG)
else:
    logging.basicConfig(
        format="%(asctime)s  [%(levelname)-8s] %(message)s",
        level=logging.INFO,
        datefmt="%Y-%m-%d %H:%M:%S%z",
    )

# Define Files
# CFG_DIR = Path("sample")
CFG_DIR = Path("/root/.pvpn-cli/")

SRV_INFO = CFG_DIR / Path("serverinfo.json")
CFG_FILE = CFG_DIR / Path("pvpn-cli.cfg")

logging.debug(f"Detect IP of connected server from {CFG_FILE}")
config = configparser.ConfigParser()
config.read(CFG_FILE)
connected_server = config.get("metadata", "connected_server", fallback="None")

logging.debug(f"Reading {SRV_INFO}")
with open(SRV_INFO, "r") as f:
    servers = json.load(f)
    connected_server_ips = []
    for logical_server in servers["LogicalServers"]:
        # IF logical server name matches
        if logical_server["Name"] == connected_server:
            # Iterate over servers
            for server in logical_server["Servers"]:
                # Get Their IPs and append to allow list
                connected_server_ips.append(server["ExitIP"])

logging.debug(f"Allowed IPs: {connected_server_ips}")

ip_endpoint = os.getenv("PROTONVPN_IPCHECK_ENDPOINT", "https://ip.prasadt.workers.dev/")
logging.debug(f"Fetch Public IP from {ip_endpoint}")

ip_resp_request = urllib.request.Request(
    ip_endpoint,
    data=None,
    headers={"User-Agent": "protonvpn-cli-docker"},
)
with urllib.request.urlopen(ip_resp_request) as ip_response:
    current_ip = str(ip_response.read(), "utf-8")
    logging.debug(f"Current IP is {current_ip}")

ip_match = False
for ip in connected_server_ips:
    if current_ip == ip:
        ip_match = True
        break

if ip_match:
    logging.debug(
        f"Your current public IP {current_ip}, matches one of the IPs from "
        f"server {connected_server}"
    )
    sys.exit(0)
else:
    logging.error(
        f"Your current public IP {current_ip}, does not match any IPs from "
        f"server {connected_server}"
    )
    sys.exit(1)
