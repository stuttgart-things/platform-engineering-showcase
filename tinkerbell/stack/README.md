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

### HARDWARE

```bash
cat <<EOF | kubectl apply -f -
apiVersion: tinkerbell.org/v1alpha1
kind: Hardware
metadata:
  name: machine1
spec:
  disks:
    - device: /dev/sda   # replace with actual VM disk device if different
  metadata:
    facility:
      facility_code: playground
    instance:
      hostname: "machine1"
      id: "00:0c:29:aa:bb:cc"   # must match the MAC
      operating_system:
        distro: "ubuntu"
        os_slug: "ubuntu_20_04"
        version: "20.04"
  interfaces:
    - dhcp:
        arch: x86_64
        hostname: machine1
        ip:
          address: 192.168.56.50       # replace with your VM’s PXE IP
          netmask: 255.255.255.0
          gateway: 192.168.56.2
        lease_time: 86400
        mac: "00:0c:29:aa:bb:cc"
        name_servers:
          - 1.1.1.1
          - 8.8.8.8
        uefi: false                   # set true if your VM boots in UEFI mode
      netboot:
        allowPXE: true
        allowWorkflow: true
EOF
```

### TEMPLATE

```bash
cat <<EOF | kubectl apply -f -
apiVersion: "tinkerbell.org/v1alpha1"
kind: Template
metadata:
  name: ubuntu22
spec:
  data: |
    version: "0.1"
    name: ubuntu
    global_timeout: 1800
    tasks:
      - name: "os installation"
        worker: "{{.device_1}}"
        volumes:
          - /dev:/dev
          - /dev/console:/dev/console
          - /lib/firmware:/lib/firmware:ro
        actions:
          - name: "stream ubuntu image"
            image: quay.io/tinkerbell/actions/image2disk:latest
            timeout: 600
            environment:
              DEST_DISK: {{ index .Hardware.Disks 0 }}
              IMG_URL: "http://192.168.56.117:7173/jammy-server-cloudimg-amd64.raw.gz"
              COMPRESSED: true
          - name: "grow-partition"
            image: quay.io/tinkerbell/actions/cexec:latest
            timeout: 90
            environment:
              BLOCK_DEVICE: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              CHROOT: y
              DEFAULT_INTERPRETER: "/bin/sh -c"
              CMD_LINE: "growpart {{ index .Hardware.Disks 0 }} 1 && resize2fs {{ index .Hardware.Disks 0 }}1"
          - name: "install openssl"
            image: quay.io/tinkerbell/actions/cexec:latest
            timeout: 90
            environment:
              BLOCK_DEVICE: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              CHROOT: y
              DEFAULT_INTERPRETER: "/bin/sh -c"
              CMD_LINE: "apt -y update && apt -y install openssl"
          - name: "create user"
            image: quay.io/tinkerbell/actions/cexec:latest
            timeout: 90
            environment:
              BLOCK_DEVICE: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              CHROOT: y
              DEFAULT_INTERPRETER: "/bin/sh -c"
              CMD_LINE: "useradd -p $(openssl passwd -1 tink) -s /bin/bash -d /home/tink/ -m -G sudo tink"
          - name: "enable ssh"
            image: quay.io/tinkerbell/actions/cexec:latest
            timeout: 90
            environment:
              BLOCK_DEVICE: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              CHROOT: y
              DEFAULT_INTERPRETER: "/bin/sh -c"
              CMD_LINE: "ssh-keygen -A; systemctl enable ssh.service; echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
          - name: "disable apparmor"
            image: quay.io/tinkerbell/actions/cexec:latest
            timeout: 90
            environment:
              BLOCK_DEVICE: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              CHROOT: y
              DEFAULT_INTERPRETER: "/bin/sh -c"
              CMD_LINE: "systemctl disable apparmor; systemctl disable snapd"
          - name: "write netplan"
            image: quay.io/tinkerbell/actions/writefile:latest
            timeout: 90
            environment:
              DEST_DISK: {{ index .Hardware.Disks 0 }}1
              FS_TYPE: ext4
              DEST_PATH: /etc/netplan/config.yaml
              CONTENTS: |
                network:
                  version: 2
                  renderer: networkd
                  ethernets:
                    id0:
                      match:
                        name: en*
                      dhcp4: true
              UID: 0
              GID: 0
              MODE: 0644
              DIRMODE: 0755
          - name: "kexec into os"
            image: ghcr.io/jacobweinstock/waitdaemon:latest
            timeout: 90
            pid: host
            environment:
              BLOCK_DEVICE: {{ formatPartition ( index .Hardware.Disks 0 ) 1 }}
              FS_TYPE: ext4
              IMAGE: quay.io/tinkerbell/actions/kexec:latest
              WAIT_SECONDS: 10
            volumes:
              - /var/run/docker.sock:/var/run/docker.sock
EOF
```

### WORKFLOW

```bash
cat <<EOF | kubectl apply -f -
apiVersion: "tinkerbell.org/v1alpha1"
kind: Workflow
metadata:
  name: u22-machine1-workflow
spec:
  templateRef: ubuntu22
  hardwareRef: machine1
  hardwareMap:
    device_1: "00:0c:29:aa:bb:cc"
EOF
```

</details>

### VERIFY

```bash
Every 2.0s: kubectl get workflow -A                                                   
NAMESPACE   NAME                    TEMPLATE   STATE     ACTION          AGENT               HARDWARE
default     u22-machine1-workflow   ubuntu22   SUCCESS   kexec into os   00:0c:29:aa:bb:cc   machine1
```
