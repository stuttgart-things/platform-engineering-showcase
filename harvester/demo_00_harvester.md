# HARVESTER DEMO

<details>
  <summary>VM DEFINITION</summary>

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  annotations:
    description: dev9-complete-vm-setup
    harvesterhci.io/mac-address: '{"default":"9a:57:4a:63:37:db"}'
    harvesterhci.io/vmRunStrategy: RerunOnFailure
    kubevirt.io/latest-observed-api-version: v1
    kubevirt.io/storage-observed-api-version: v1
  creationTimestamp: '2026-02-04T07:25:30Z'
  finalizers:
    - kubevirt.io/virtualMachineControllerFinalize
    - wrangler.cattle.io/VMController.CleanupPVCAndSnapshot
  generation: 1
  labels:
    os: linux
      manager: provider-kubernetes/dev9-2f55584f2008
      operation: Apply
      time: '2026-02-04T07:25:30Z'
    - apiVersion: kubevirt.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        f:metadata:
          f:annotations:
            f:kubevirt.io/latest-observed-api-version: {}
            f:kubevirt.io/storage-observed-api-version: {}
          f:finalizers:
            .: {}
            v:"kubevirt.io/virtualMachineControllerFinalize": {}
      manager: virt-controller
      operation: Update
      time: '2026-02-04T07:25:30Z'
    - apiVersion: kubevirt.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        f:metadata:
          f:annotations:
            f:harvesterhci.io/mac-address: {}
            f:harvesterhci.io/vmRunStrategy: {}
          f:finalizers:
            v:"wrangler.cattle.io/VMController.CleanupPVCAndSnapshot": {}
      manager: harvester
      operation: Update
      time: '2026-02-04T07:25:56Z'
    - apiVersion: kubevirt.io/v1
      fieldsType: FieldsV1
      fieldsV1:
        f:status:
          .: {}
          f:conditions: {}
          f:created: {}
          f:desiredGeneration: {}
          f:observedGeneration: {}
          f:printableStatus: {}
          f:ready: {}
          f:runStrategy: {}
          f:volumeSnapshotStatuses: {}
      manager: virt-controller
      operation: Update
      subresource: status
      time: '2026-02-04T07:26:25Z'
  name: dev9
  namespace: default
  resourceVersion: '2769293'
  uid: b4ff3a6b-32bf-4801-b893-3a2f996df681
spec:
  runStrategy: RerunOnFailure
  template:
    metadata:
      creationTimestamp: null
      labels:
        vmName: dev9
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: network.harvesterhci.io/mgmt
                    operator: In
                    values:
                      - 'true'
      architecture: amd64
      domain:
        cpu:
          cores: 4
          maxSockets: 1
          sockets: 1
          threads: 1
        devices:
          disks:
            - bootOrder: 1
              disk:
                bus: virtio
              name: rootdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
          interfaces:
            - bridge: {}
              model: virtio
              name: default
        features:
          acpi:
            enabled: true
        machine:
          type: q35
        memory:
          guest: 8Gi
        resources:
          limits:
            cpu: '4'
            memory: 8Gi
          requests:
            cpu: 250m
            memory: 5461Mi
      evictionStrategy: LiveMigrateIfPossible
      hostname: dev9
      networks:
        - multus:
            networkName: default/vms
          name: default
      terminationGracePeriodSeconds: 120
      volumes:
        - name: rootdisk
          persistentVolumeClaim:
            claimName: dev9-disk-0
        - cloudInitNoCloud:
            networkDataSecretRef:
              name: dev9-cloud-init
            secretRef:
              name: dev9-cloud-init
          name: cloudinitdisk
```

</details>

<details>
  <summary>CLOUD-INIT SECRET</summary>

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: dev9-cloud-init
  namespace: default
stringData:
  networkdata: ""
  userdata: |
    #cloud-config
    hostname: dev9
    fqdn: dev9.local
    manage_etc_hosts: true
    users:
      - name: sthings
        ssh_authorized_keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        lock_passwd: false
    chpasswd:
      list: |
        sthings:"TOBEDEFINED"
      expire: false
    packages:
      - qemu-guest-agent
    runcmd:
      - systemctl enable --now qemu-guest-agent.service

    package_update: true
    package_upgrade: false

    ssh_pwauth: true
    disable_root: true
```

</details>

<details>
  <summary>PVC DEFINITION</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    harvesterhci.io/imageId: default/image-t9w92
    pv.kubernetes.io/bind-completed: 'yes'
    pv.kubernetes.io/bound-by-controller: 'yes'
    volume.beta.kubernetes.io/storage-provisioner: driver.longhorn.io
    volume.kubernetes.io/storage-provisioner: driver.longhorn.io
  finalizers:
    - kubernetes.io/pvc-protection
    - wrangler.cattle.io/persistentvolumeclaim-controller
  name: dev9-disk-0
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi
  storageClassName: longhorn-image-t9w92
  volumeMode: Block
  volumeName: pvc-6a47a13f-3aef-499b-acc7-c13057ab49f9
status:
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 20Gi
  phase: Bound
```

</details>
