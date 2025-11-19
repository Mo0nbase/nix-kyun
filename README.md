# Danbo - NixOS Cloud Image for Kyun.host

A production-ready NixOS qcow2 cloud image builder for [kyun.host](https://kyun.host) VPS hosting with full cloud-init support.

## Features

- **Cloud-Init Integration**: Reads configuration dynamically from `/dev/sr1`
- **Static Networking**: Supports kyun.host's static IPv4/IPv6 configuration
- **QEMU/KVM Optimized**: Virtio drivers and QEMU guest agent enabled
- **Secure by Default**: SSH key-based authentication only
- **Production Ready**: Minimal, hardened configuration
- **Reproducible**: Declarative configuration with Nix flakes

## Quick Start

### Build the Image

```bash
# Clone the repository
git clone <repository-url>
cd nix-danbo

# Build the qcow2 image
nix build

# Or use the convenience app
nix run

# Output will be at: result/nixos.qcow2
```

### Deploy to Kyun.host

1. Build the image using the command above
2. Upload `result/nixos.qcow2` to the kyun.host dashboard
3. Create a new instance using the uploaded image
4. The system will boot and cloud-init will configure it automatically

## How It Works

Kyun.host provides cloud-init configuration at `/dev/sr1` (labeled `cidata`) containing:

- **`meta-data`**: Instance ID, hostname
- **`user-data`**: SSH keys, users, initialization scripts
- **`network-config`**: Static IPv4/IPv6 addresses, gateways, DNS
- **`vendor-data`**: Vendor-specific configuration

The NixOS image:

1. Mounts `/dev/sr1` to `/mnt/cloud-init` at boot
2. Cloud-init reads and applies all configuration
3. Networking is configured with static IPs (no DHCP)
4. SSH keys are installed for root user
5. System is fully configured and ready

## Configuration

### Base System

Edit `modules/danbo-base.nix` to customize:

```nix
# Add packages
environment.systemPackages = with pkgs; [
  vim
  wget
  curl
  git
  htop
  tmux
  # Add your packages here
];

# Enable services
services.tailscale.enable = true;
services.docker.enable = true;

# Configure firewall
networking.firewall.allowedTCPPorts = [ 22 80 443 ];
```

### Disk Layout

Edit `modules/disk-config.nix` to modify partitioning:

```nix
# Change root partition size, filesystem, or mount options
root = {
  size = "100%";
  content = {
    type = "filesystem";
    format = "btrfs";  # or "ext4"
    mountpoint = "/";
    mountOptions = [
      "compress-force=zstd"
      "noatime"
    ];
  };
};
```

### Image Build Options

Edit `modules/image-builder.nix` to adjust:
- Disk size (default: 10GB)
- Image format
- Build options

## System Specifications

- **OS**: NixOS 24.11
- **Bootloader**: GRUB (BIOS mode)
- **Filesystem**: 
  - BTRFS root with zstd compression
  - ext4 boot partition
  - 1MB BIOS boot partition
- **Kernel**: Latest stable with virtio drivers
- **Networking**: Static IP via cloud-init (no DHCP)
- **Services**:
  - SSH (port 22, key-based auth only)
  - QEMU guest agent
  - Cloud-init
- **Console**: Serial console enabled (`ttyS0`)
- **Network Interfaces**: Non-predictable names (`net.ifnames=0`)

## Development

### Requirements

- Nix with flakes enabled
- 10GB+ free disk space for building

### Commands

```bash
# Check flake validity
nix flake check

# Update dependencies
nix flake update

# Build specific outputs
nix build .#default
nix build .#nixosConfigurations.danbo-cloud-init.config.system.build.toplevel

# Enter development shell
nix develop
```

### Testing Locally

You can test the image locally with QEMU:

```bash
# Build the image
nix build

# Run with QEMU (requires QEMU installed)
qemu-system-x86_64 \
  -m 2048 \
  -drive file=result/nixos.qcow2,format=qcow2 \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -nographic
```

## Troubleshooting

### Cloud-init not applying configuration

SSH into the instance and verify:

```bash
# Check if cloud-init drive is mounted
mount | grep cidata
ls -la /mnt/cloud-init

# View cloud-init logs
journalctl -u cloud-init-local
journalctl -u cloud-init
journalctl -u cloud-init-network
journalctl -u cloud-final

# Check cloud-init status
cloud-init status
```

### Networking not working

```bash
# Check network configuration from cloud-init
cat /mnt/cloud-init/network-config

# Verify network interfaces
ip addr
ip route

# Check if networking service is running
systemctl status systemd-networkd
systemctl status network
```

### SSH access issues

```bash
# Verify SSH keys were installed
cat /mnt/cloud-init/user-data | grep -A 10 ssh
cat /root/.ssh/authorized_keys

# Check SSH service
systemctl status sshd

# View SSH logs
journalctl -u sshd
```

### Serial console access

If you can't SSH in, use kyun.host's serial console feature:

- The image has serial console enabled on `ttyS0`
- Access it through the kyun.host dashboard
- Login as root (if cloud-init configured a password)

## Security Considerations

- SSH password authentication is disabled
- Root login requires SSH keys (provided via cloud-init)
- Firewall enabled (only SSH allowed by default)
- No default passwords set
- Minimal package installation
- All credentials managed by cloud-init

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build with `nix build`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
- [Kyun.host Documentation](https://kyun.host/docs)
- [Disko Documentation](https://github.com/nix-community/disko)

## Support

For issues or questions:
- Open an issue in this repository
- Check kyun.host documentation
- Join NixOS community channels
