# platform-engineering-showcase/tinkerbell/testing

Hardware setup
WIRED SETUP LTE (LAN2/WAN BÜCHSE) -> DDWRT (BLAUE LAN Anschluss)
PC über PXE Boot kompatiblen Anschluss verbinden
Enter BIOS → Enable PXE / Network Boot → set first in boot order.

install required packages:
sudo apt update
sudo apt install isc-dhcp-server tftp-hpa syslinux pxelinux

konfiguriere dhcp server
edit /etc/dhcp/dhcp.conf

(cat output)
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 192.168.50.0 netmask 255.255.255.0 {
    range 192.168.50.100 192.168.50.200;
    option routers 192.168.50.1;
    next-server 192.168.50.5;   # IP of your PXE server (this Ubuntu machine)
    filename "pxelinux.0";
}

start services
sudo systemctl restart isc-dhcp-server
sudo systemctl restart tftpd-hpa

Give Service right interface
vi /etc/default/isc-dhcp-server
INTERFACESv4="<ip a (enter interface)>"INTERFACESv6="" 

restart service:
sudo systemctl restart isc-dhcp-server

Ensure lease file exists:
sudo touch /var/lib/dhcp/dhcpd.leases
sudo chown dhcpd:dhcpd /var/lib/dhcp/dhcpd.leases

test config:
sudo dhcpd -d -cf /etc/dhcp/dhcpd.conf <interface>
If it starts up and begins “Listening on LPF/<interface>/…”, your DHCP server is working

check connection with:
sudo tcpdump -i enx000ec69c8299 port 69
or
watch sudo journalctl -u isc-dhcp-server

Test PXE Boot
when booting it should request an IP via DHCP and fetch pxelinux.0


