# COMPOSE-STACK

## Prerequisites

Create the external Docker network:
```bash
docker network create web
```

## Generate Self-Signed Certificates

### 1. Create Certificate Directory
```bash
mkdir -p traefik/certs
mkdir -p traefik/dynamic
```

### 2. Generate Certificate for Whoami Service
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout traefik/certs/whoami.whatever.com.key \
  -out traefik/certs/whoami.whatever.com.crt \
  -subj "/CN=whoami.whatever.com"
```

### 3. Generate Certificate for Traefik Dashboard
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout traefik/certs/traefik.whatever.com.key \
  -out traefik/certs/traefik.whatever.com.crt \
  -subj "/CN=traefik.whatever.com"
```

### 4. Create TLS Configuration

Create `traefik/dynamic/tls.yml`:
```yaml
tls:
  certificates:
    - certFile: /etc/traefik/certs/whoami.whatever.com.crt
      keyFile: /etc/traefik/certs/whoami.whatever.com.key
    - certFile: /etc/traefik/certs/traefik.whatever.com.crt
      keyFile: /etc/traefik/certs/traefik.whatever.com.key
```

## Generate Password for Traefik Dashboard
```bash
# Install htpasswd if needed
sudo apt-get install apache2-utils

# Generate password hash (replace 'your-password' with your desired password)
echo $(htpasswd -nB admin) | sed -e s/\\$/\\$\\$/g
```

Copy the output and use it in the Traefik compose file's `basicauth.users` label.

## Deploy Services
```bash
# Start Traefik
docker compose -f traefik-compose.yml up -d

# Start Whoami
docker compose -f whoami-compose.yml up -d
```

## Access Services

### Traefik Dashboard

**Browser:**
```
https://traefik.whatever.com/dashboard/
```

**Username:** `admin`
**Password:** (the password you set when generating the hash)

**Alternative (without DNS):**
```
http://your-server-ip:8080/dashboard/
```

### Whoami Service

**Browser:**
```
https://whoami.whatever.com
```

**curl (skip certificate verification):**
```bash
curl -k https://whoami.whatever.com
```

**curl (with certificate):**
```bash
curl --cacert traefik/certs/whoami.whatever.com.crt https://whoami.whatever.com
```

## Trust Self-Signed Certificates (Optional)

To avoid certificate warnings and use curl without `-k`:

### On Ubuntu/Debian:
```bash
sudo cp traefik/certs/whoami.whatever.com.crt /usr/local/share/ca-certificates/
sudo cp traefik/certs/traefik.whatever.com.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

### On RHEL/CentOS:
```bash
sudo cp traefik/certs/whoami.whatever.com.crt /etc/pki/ca-trust/source/anchors/
sudo cp traefik/certs/traefik.whatever.com.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

After adding to system trust store:
```bash
# No -k flag needed
curl https://whoami.whatever.com
curl -u admin:your-password https://traefik.whatever.com/dashboard/
```

## Testing

### Test Whoami Service
```bash
# With Host header (if DNS not configured)
curl -k -H "Host: whoami.whatever.com" https://your-server-ip

# HTTP to HTTPS redirect
curl -I http://whoami.whatever.com
```

### Test Traefik Dashboard
```bash
# With authentication
curl -k -u admin:your-password https://traefik.whatever.com/dashboard/

# Should require auth (returns 401)
curl -k https://traefik.whatever.com/dashboard/
```

## Directory Structure
```
compose-stack/
├── traefik-compose.yml
├── whoami-compose.yml
└── traefik/
    ├── certs/
    │   ├── whoami.whatever.com.crt
    │   ├── whoami.whatever.com.key
    │   ├── traefik.whatever.com.crt
    │   └── traefik.whatever.com.key
    └── dynamic/
        └── tls.yml
```
