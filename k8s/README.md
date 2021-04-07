# Kubernetes

<p align="center">
  <a href="https://protonvpn.com" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/proton/scalable/protonvpn-wide.svg" height="64" alt="protonvpn">
  </a>
  <a href="https://k8.io" target="_blank" rel="noreferrer">
    <img src="https://static.prasadt.com/logos/k8s/svg/kubernetes-horizontal.svg" height="64" alt="k8s">
  </a>
</p>

## Create a namespace or switch to namespace

```bash
# CREATE
kubectl create ns pyload
# OR SWITCH TO EXISTING NAMESPACE
kubectl config set-context --namespace pyload --current
```


## Create kubernetes `Secret` to save protonvpn credentials and tier

```bash
kubectl create secret generic protonvpn-credentials \
    --from-literal=PROTONVPN_USERNAME=$PROTONVPN_USERNAME \
    --from-literal=PROTONVPN_PASSWORD=$PROTONVPN_PASSWORD \
    --from-literal=PROTONVPN_TIER=$PROTONVPN_TIER
```

## Create a `ConfigMap` to save settings

Please include your Pod CIDR, service CIDR, Loadbalancer IP Pool CIDR in the `PROTONVPN_EXCLUDE_CIDRS`. Here we are including all private subnets for simplicity.

```bash
kubectl create configmap protonvpn-settings \
    --from-literal=PROTONVPN_EXCLUDE_CIDRS="10.0.0.0/8,191.168.0.0/16,172.16.0.0/12" \
    --from-literal=PROTONVPN_COUNTRY=NL \
    --from-literal=PROTONVPN_DNS_LEAK_PROTECT=0 \
    --from-literal=PROTONVPN_CHECK_INTERVAL=10
```

## Create `Pod` & `Service`

Please note that we are using Pod here. In real world scenario please use Deployments or other higher level constructs.
This is for ease of use as the application you may want to use with protonvpn will vary. also we are using service of type `NodePort` for simplicity.

```bash
kubectl appy -f pod.yml
kubectl apply -f service.yml
```

## Verify

- Verify Pod is running

    ```bash
    kubectl get po
    NAME               READY   STATUS    RESTARTS   AGE
    pyload-protonvpn   2/2     Running   0          19m
    ```

- Verify protonvpn is running

    ```console
    kubectl logs pyload-protonvpn protonvpn -f
    [s6-init] making user provided files available at /var/run/s6/etc...exited 0.
    [s6-init] ensuring user provided files have correct perms...exited 0.
    [fix-attrs.d] applying ownership & permissions fixes...
    [fix-attrs.d] done.
    [cont-init.d] executing container initialization scripts...
    [cont-init.d] 70-vpn-setup: executing...
    [VPN-Config-Setup] Using Fastest Server from NL
    [VPN-Config-Setup] Free Plan
    [VPN-Config-Setup] TCP
    [VPN-Config-Split] Validating CIDRs
    [VPN-Config-Split] CIDR 10.244.0.0/24 is valid
    [VPN-Config-Split] CIDR 10.96.0.0/12 is valid
    [VPN-Config-DNS  ] Disabling DNS leak protection!!
    [VPN-Config-Split] Following CIDRs will be excluded from VPN 10.244.0.0/24 10.96.0.0/12
    [Path Init       ] Creating folders
    [Path Init       ] Permissions
    [VPN-Config-Setup] Getting Server List
    [VPN-Config-Setup] Writing config file
    [VPN-Config-Setup] Writing Split Tunnel Config file
    [VPN-Config-Setup] Writing credentials file
    [VPN-Config-Setup] Restrict credentials file
    [cont-init.d] 70-vpn-setup: exited 0.
    [cont-init.d] done.
    [services.d] starting services
    [Service - INIT] Daemon check interval is set to #60
    [Service - INIT] Reconnect treshold is #3
    [Service - INIT] checking orphaned openvpn process
    [Service - INIT] This appears to be a fresh start!
    [Service - CONN] Using Fastest Server from NL
    [services.d] done.
    Connecting to NL-FREE#7 via UDP...
    Connected!
    [Service - CHCK] Is Service Disconnecting: 0
    [Service - CHCK] OK!
    ```

- check pylaod is accessible via nodeport

    ```bash
    kubectl get service
    # If using minikube
    minikube service pyload --namespace pyload
    ```
