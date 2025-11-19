# nixos-danbo

**Minimal NixOS cloud image for [kyun.host](https://kyun.host) danbo!**

[![Build Status](https://github.com/Mo0nbase/nixos-danbo/workflows/Build%20and%20Release/badge.svg)](https://github.com/Mo0nbase/nixos-danbo/actions)

## Quick Start

### 1. Get the Image URL

Go to [Releases](https://github.com/Mo0nbase/nixos-danbo/releases) and copy the link for the latest `.qcow2` image.

### 2. Deploy on Kyun.host

Paste the image URL into the kyun.host dashboard custom qick start section on the danbo dashboard.

### 3. Reboot After First Boot

Once the instance boots up, SSH in and reboot!

```bash
ssh root@your-server-ip
reboot
```

### 4. Add to Your NixOS Flake

Copy the configuration template to your NixOS flake and deploy:

```bash
# In your NixOS config repository
mkdir -p hosts/kyun
cd hosts/kyun

curl -O https://raw.githubusercontent.com/Mo0nbase/nixos-danbo/main/template/danbo.nix
curl -O https://raw.githubusercontent.com/Mo0nbase/nixos-danbo/main/template/hardware.nix
```

Add to your `flake.nix` and deploy to your server.

**See [template/README.md](template/README.md) for detailed configuration guide.**

---

## Overview

nixos-danbo is a minimal, production-ready NixOS cloud image for kyun.host VPS hosting. It uses cloud-init for automatic configuration of networking, SSH keys, and system settings on first boot.

### What's Included

- NixOS 25.05
- Essential packages: vim, wget, curl, git, htop, tmux
- SSH server, QEMU guest agent, cloud-init
- Static networking via systemd-networkd

## Building from Source

```bash
git clone https://github.com/Mo0nbase/nixos-danbo.git
cd nixos-danbo
nix build
# Output: result/nixos.qcow2
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for development details.

## Documentation

- [User Configuration Guide](template/README.md) - Manage your system with NixOS
- [Contributing Guide](CONTRIBUTING.md) - Development workflow

## Support

- 🐛 [Report Issues](https://github.com/Mo0nbase/nixos-danbo/issues)
- 📚 [Kyun.host Docs](https://kyun.host/docs)

## License

MIT
