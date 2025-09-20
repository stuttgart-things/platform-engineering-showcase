# platform-engineering-showcase/tinkerbell/testing

# PXE SERVER VMWARE WORKSTATION (JUST TESTING PXE-SERVER)

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

# PXE CLIENT (MACHINE1)

### VMWARE CONFIG

* 1CPU 1CORES
* 4GB RAM
* 20GB HDD
* NETWORK1: VMnet0
* NO DISK (WILL INSTALL OPERATING SYSTEM LATER)

# GATEWAY/ROUTER CONFIG

* VM Configuration in VMware Workstation
	* VM: Alpine Router
	* NIC1: NAT (WAN side, internet access)
	* NIC2: Host-only (VMnet1) (LAN side, your other VMs connect here)

* Other VMs (clients):
    * Single NIC: Host-only (VMnet1)
	* Gateway = Alpine router LAN IP (we’ll use 192.168.56.2)


Alpine Router Setup
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

5. Configure Client VMs (on Host-only)

* Example client config:

IP: 192.168.56.10/24
Gateway: 192.168.56.2
DNS: 8.8.8.8 (or same as host)

Now the client VM will reach the internet through the Alpine router 🎉

6. TESTS

```bash
1. Check WAN (NAT interface) connectivity
ip addr show eth0

You should see an IP (likely 192.168.x.x assigned by VMware NAT DHCP).

Then try:

ping -c3 8.8.8.8


If this works, your router can reach the internet.

2. Check LAN (host-only interface)
ip addr show eth1


Should show 192.168.56.2/24.

Verify it’s up:

ping -c3 192.168.56.2

3. Check packet forwarding is enabled
sysctl net.ipv4.ip_forward


Should return net.ipv4.ip_forward = 1.

4. Verify NAT rules
iptables -t nat -L -n -v


You should see a MASQUERADE rule for eth0.

Packets/bytes counters should increase when clients use the internet.

5. Test client reachability from router

Suppose client = 192.168.56.10:

ping -c3 192.168.56.10


This ensures LAN connectivity works.

6. Final test (end-to-end from a client VM)

On the client VM (with gateway 192.168.56.2):

ping -c3 8.8.8.8        # raw internet
ping -c3 google.com     # with DNS
```

