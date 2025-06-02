# m4.1_basic_infrastructure_on_docker

To rollout the M4.1 infrastructure on docker instead of kuberenets.
It's only a temporary quick&dirty project and the following steps are meant to be
performed directly on the target machine.

## Prerequisites

### Install requires packages

```bash
sudo apt-get update && sudo apt-get install \
    git \
    gpg \
    ca-certificates \
    curl
```

### Install sops

```bash
VERSION=$(curl -Ls https://api.github.com/repos/mozilla/sops/releases/latest | grep tag_name | cut -d '"' -f4)
sudo curl -Lso /usr/local/bin/sops "https://github.com/mozilla/sops/releases/download/$VERSION/sops-$VERSION.linux.amd64"
sudo chmod +x /usr/local/bin/sops
```

### Install docker

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin
```

### Checkout this repo

```bash
git clone 
```

## How to deploy

This is how to deploy:

```bash
sops exec-env environments/productive/secrets.enc.env 'docker compose up -d'
```