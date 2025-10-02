# platform-engineering-showcase/tinkerbell/stack

## OPTIONAL: VMWARE WORKSTATION TESTING ENVIRONMENT

<details><summary>🔌 NETWORK CONFIG</summary>

* OPEN VMWARE NETTWORK EDITOR

### 🌐 Custom Network: **VMnet0**
- **Type:** Custom
- **Host Connection:** ❌ Not connected
- **DHCP:** ❌ Disabled
- **Subnet:** `192.168.56.0/24`
- **Mode:** ✅ Host-only

</details>

<details><summary>📡 VM0: GATEWAY ROUTER</summary>

### ⚙️ VMware Config

- 🖥 **CPU:** 1 × 2 cores
- 🧠 **Memory:** 2 GB RAM
- 💽 **Disk:** 10 GB HDD
- 🌍 **Network 1:** NAT (WAN side, internet access)
- 🌍 **Network 2:** Host-only (VMnet1) (LAN side, your other VMs connect here)
- 📀 **Boot Media:** `Alpine.iso`

</details>

<details><summary>📡 VM1: PXE Server (Stack)</summary>

### ⚙️ VMware Config

- 🖥 **CPU:** 2 × 4 cores
- 🧠 **Memory:** 4 GB RAM
- 💽 **Disk:** 20 GB HDD
- 🌍 **Network 1:** VMnet0
- 📀 **Boot Media:** `U25.iso`

</details>

<details><summary>📡 VM2: PXE Client</summary>

### ⚙️ VMware Config

- 🖥 **CPU:** 1 × 2 cores
- 🧠 **Memory:** 4 GB RAM
- 💽 **Disk:** 20 GB HDD
- 🌍 **Network 1:** VMnet0
- 📀 **Boot Media:** NO DISK (WILL INSTALL OPERATING SYSTEM LATER)

Prior starting the vm add the following line to the vmx file (e.g. machine1.vmx)

```bash
ethernet0.virtualDev = "e1000" # add this line
```

(otherwise hookos will not know the network adapter from vmware workstation)

</details>

<details><summary>SSH INTO VMS OF HOST ONLY NETWORK</summary>

You need to put the host on the same host-only network as the VM.

Open Virtual Network Editor.

Select VMnet0 (your 192.168.56.0/24 host-only network).

Tick “Connect a host virtual adapter to this network”.

Click Apply.
→ Windows will then get a new virtual adapter (e.g. “VMware Network Adapter VMnet0”).

Run ipconfig again – you should see something like:

```bash
Ethernet adapter VMware Network Adapter VMnet0:
    IPv4 Address. . . . . . : 192.168.56.1
```

Now you can SSH to 192.168.56.2 from Windows.

</details>

## OPTIONAL: CONFIGURE ROUTER VM

<details><summary>🔌 OVERVIEW</summary>

* VM Configuration in VMware Workstation
	* VM: Alpine Router
	* NIC1: NAT (WAN side, internet access)
	* NIC2: Host-only (VMnet1) (LAN side, your other VMs connect here)

* Other VMs (clients):
    * Single NIC: Host-only (VMnet1)
	* Gateway = Alpine router LAN IP (we’ll use 192.168.56.2)

</details>

<details><summary>ALPINE ROUTER SETUP</summary>

1. Install Alpine

When asked during setup:
* Use eth0 for NAT interface (DHCP).
* Use eth1 for Host-only (we’ll configure static).

2. Configure Networking

Edit /etc/network/interfaces:

```bash
# /etc/network/interfaces
auto lo
iface lo inet loopback

# WAN (NAT)
auto eth0
iface eth0 inet dhcp

# LAN (Host-only)
auto eth1
iface eth1 inet static
    address 192.168.56.2
    netmask 255.255.255.0
```

/etc/init.d/networking restart

3. Enable IP Forwarding

```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

4. Set Up NAT

```bash
apk add iptables

# Masquerade traffic from LAN to WAN
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Allow LAN → WAN
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Allow established connections back
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT

rc-update add iptables
service iptables save
```

</details>

## DEPLOYMENT STACK/TINKERBELL-SERVER

<details><summary>OPTIONAL IP CONFIG</summary>

5. Configure Client VMs (on Host-only)

```bash
* Example client config:
IP: 192.168.56.10/24
Gateway: 192.168.56.2
DNS: 8.8.8.8 (or same as host)
```

Now the client VM will reach the internet through the Alpine router 🎉

</details>

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
brew install go-task/tap/go-task gum kubectl helm k9s
```

</details>

<details><summary>INSTALL K3S CLUSTER</summary>

### PARTITION DISK

```bash
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```

### INSTALL

```bash
export TASK_X_REMOTE_TASKFILES=1
task --taskfile https://raw.githubusercontent.com/stuttgart-things/docs/c7a842d8bf817209868fe253d98b4f927890a600/tasks/k3s.yaml install
```

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

<details><summary>DOWNLOAD UBUNTU IMAGE</summary>

```bash
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: download-image
data:
  entrypoint.sh: |-
    #!/usr/bin/env bash
    # This script is designed to download a cloud image file (.img) and then convert it to a .raw.gz file.
    # This is purpose built so non-raw cloud image files can be used with the "image2disk" action.
    # See https://artifacthub.io/packages/tbaction/tinkerbell-community/image2disk.
    set -euxo pipefail
    if ! which pigz qemu-img &>/dev/null; then
    	apk add --update pigz qemu-img
    fi
    image_url=$1
    file=$2/${image_url##*/}
    file=${file%.*}.raw.gz
    if [[ ! -f "$file" ]]; then
    	wget "$image_url" -O image.img
    	qemu-img convert -O raw image.img image.raw
    	pigz <image.raw >"$file"
    	rm -f image.img image.raw
    fi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: download-ubuntu-jammy
spec:
  template:
    spec:
      containers:
        - name: download-ubuntu-jammy
          image: bash:5.2.2
          command: ["/script/entrypoint.sh"]
          args:
            [
              "https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-amd64.img",
              "/output",
            ]
          volumeMounts:
            - mountPath: /output
              name: hook-artifacts
            - mountPath: /script
              name: configmap-volume
      restartPolicy: OnFailure
      volumes:
        - name: hook-artifacts
          hostPath:
            path: /tmp
            type: DirectoryOrCreate
        - name: configmap-volume
          configMap:
            defaultMode: 0700
            name: download-image
EOF
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

<details><summary>VERIFY</summary>

### TEST IMAGE AVAILABILITY

```bash
wget --spider http://192.168.56.117:7173/jammy-server-cloudimg-amd64.raw.gz
```

### WORKFLOW STATE

```bash
Every 2.0s: kubectl get workflow -A
NAMESPACE   NAME                    TEMPLATE   STATE     ACTION          AGENT               HARDWARE
default     u22-machine1-workflow   ubuntu22   SUCCESS   kexec into os   00:0c:29:aa:bb:cc   machine1
```

</details>
