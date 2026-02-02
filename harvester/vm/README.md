# VM

## RENDER VM 

```bash
# CREATE CLOUD-CONFIG DATA
CLOUDCFG_B64=$(cat <<'EOF' | base64 -w0
#cloud-config
hostname: xplane
ssh_pwauth: true
users:
  - name: sthings
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...
chpasswd:
  list: |
    sthings:Test123
  expire: false

package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service
EOF
)

# RENDER ALL RESOURCES WITH DAGGER
dagger call -m github.com/stuttgart-things/dagger/kcl run \
  --oci-source ghcr.io/stuttgart-things/harvester-vm:0.1.0 \
  --parameters "enablePvc=true,enableCloudConfig=true,enableVm=true,name=xplane-disk-0,namespace=default,imageNamespace=default,imageId=image-t9w92,storage=35Gi,storageClass=longhorn,volumeMode=Block,accessModes=[\"ReadWriteMany\"],userdata=${CLOUDCFG_B64},secretName=xplane-cloud-init,vmName=xplane,hostname=xplane,description=xplane-complete-vm-setup,osLabel=linux,runStrategy=RerunOnFailure,cpuCores=8,cpuSockets=1,cpuThreads=1,memory=12Gi,pvcName=xplane-disk-0,networkName=vms,evictionStrategy=LiveMigrateIfPossible,terminationGracePeriod=120" \
  export --path ./xplane.yaml
```