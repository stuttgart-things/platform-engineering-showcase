# platform-engineering-showcase/tinkerbell/testing

# PXE SERVER VMWARE WORKSTATION

## VMWARE NETWORKS

* Create custom network VMnet0:
Type: Custom
Host Connection: - (not connected)
DHCP: - (disabled)
Subnet: 192.168.56.0/24
Host-only selected ✅

## PXE SERVER (STACK)

### VMWARE CONFIG

* 2CPU 4CORES
* 4GB RAM
* 20GB HDD
* NETWORK1: NAT
* NETWORK2: VMnet0
* DISK: U25 ISO

### NETWORK CONFIG

```bash
sudo cat /etc/netplan/50-cloud-init.yaml

network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens34:
      addresses:
      - "192.168.56.1/24"
	  
sudo netplan apply
ip a
```

### PACKAGE INSTALL

```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y dnsmasq syslinux pxelinux syslinux-common
dpkg -L pxelinux | grep pxelinux.0
```

### CONFIGURE TFTPBOOT 

```bash
sudo mkdir -p /var/lib/tftpboot
sudo chmod -R 755 /var/lib/tftpboot

sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/
sudo cp /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/
sudo cp /usr/lib/PXELINUX/lpxelinux.0 /var/lib/tftpboot/
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/
sudo cp /usr/lib/syslinux/modules/bios/menu.c32 /var/lib/tftpboot/
sudo cp /usr/lib/syslinux/modules/bios/libcom32.c32 /var/lib/tftpboot/
sudo cp /usr/lib/syslinux/modules/bios/libutil.c32 /var/lib/tftpboot/

sudo cat /var/lib/tftpboot/pxelinux.cfg/default

DEFAULT menu.c32
PROMPT 0
TIMEOUT 50
ONTIMEOUT local

MENU TITLE PXE Boot Menu
LABEL local
  MENU LABEL Boot from local disk
  LOCALBOOT 0
```

### CONFIGURE DNSMASQ 

```bash
#/etc/dnsmasq.conf

# PXE/TFTP + DHCP server config

# Listen only on host-only NIC
interface=ens34
bind-interfaces

# DHCP range for PXE clients
dhcp-range=192.168.56.100,192.168.56.200,12h

# Gateway (PXE server itself, but usually ignored in host-only setup)
dhcp-option=3,192.168.56.1

# DNS (can use PXE server, or forward to NAT internet)
dhcp-option=6,8.8.8.8

# PXE bootloader
dhcp-boot=pxelinux.0

# Enable TFTP
enable-tftp
tftp-root=/var/lib/tftpboot


### VERIFY/DEBUG DHCP SERVER
```

```bash
sudo systemctl restart dnsmasq
grep -E 'interface|bind' /etc/dnsmasq.conf
sudo tcpdump -i ens34 port 67 or port 68 -n
``` 

## PXE CLIENT (MACHINE1)

### VMWARE CONFIG

* 1CPU 1CORES
* 4GB RAM
* 20GB HDD
* NETWORK1: VMnet0
* NO DISK (WILL INSTALL OPERATING SYSTEM LATER)

