# platform-engineering-showcase/tinkerbell/stack

## DEPLOYMENT STACK/TINKERBELL-SERVER

<details><summary>INSTALL REQUIREMENTS</summary>

```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install build-essential procps curl file git -y
```

### INSTALL BREW

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### INSTALL TASK

```bash
brew install go-task/tap/go-task gum
brew install kubectl helm k9s
```

</details>

<details><summary>INSTALL K3S CLUSTER</summary>

</details>

<details><summary>DEPLOY TINKERBELL</summary>

### DEPLOY CHART

```bash
TINKERBELL_CHART_VERSION=v0.21.0
TRUSTED_PROXIES=$(kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}' | tr ' ' ',')
LB_IP=192.168.56.116
ARTIFACTS_FILE_SERVER=http://192.168.56.117:7173

helm upgrade --install tinkerbell \
oci://ghcr.io/tinkerbell/charts/tinkerbell \
--version $TINKERBELL_CHART_VERSION \
--create-namespace \
--namespace tinkerbell \
--wait \
--set "trustedProxies={${TRUSTED_PROXIES}}" \
--set "publicIP=$LB_IP" \
--set "artifactsFileServer=$ARTIFACTS_FILE_SERVER" \
--set "deployment.agentImageTag=latest" \
--set "deployment.imageTag=latest"
```

### VERIFY

```bash
pat@machine2:~$ kubectl get po -n tinkerbell
NAME                          READY   STATUS    RESTARTS   AGE
hookos-569c8c9df4-59mrq       2/2     Running   0          111m
kube-vip-sclp9                1/1     Running   0          111m
tinkerbell-5d657c68fc-75ctj   1/1     Running   0          111m

pat@machine2:~$ kubectl get svc -n tinkerbell
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                                                                                AGE
hookos       LoadBalancer   10.43.37.23    192.168.56.117   7173:32084/TCP                                                                                         111m
tinkerbell   LoadBalancer   10.43.33.145   192.168.56.116   67:31808/UDP,69:31464/UDP,514:32233/UDP,7171:32420/TCP,7172:31066/TCP,42113:30288/TCP,2222:31460/TCP   111m
```

</details>

<details><summary>CREATE HARDWARE, TEMPLATE + WORKFLOW</summary>



</details>



