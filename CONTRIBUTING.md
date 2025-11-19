# Contributing

Contributions are welcome! Here's how to contribute to nix-danbo.

## Development Setup

**Requirements:**
- Nix with flakes enabled
- 10GB+ free disk space

**Build the image:**
```bash
nix build
```

**Test locally:**
```bash
qemu-system-x86_64 \
  -m 2048 \
  -drive file=result/nixos.qcow2,format=qcow2 \
  -net nic -net user,hostfwd=tcp::2222-:22 \
  -nographic
```

## Development Commands

```bash
# Validate flake
nix flake check

# Update dependencies
nix flake update

# Build specific outputs
nix build .#default
nix build .#nixosConfigurations.danbo-cloud-init.config.system.build.toplevel
```

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test the build (`nix build`)
5. Test on kyun.host if nessecary (VE likely required)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to your fork (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Guidelines

- Keep the image minimal (only essential packages)
- Test cloud-init integration thoroughly
- Update documentation for any user-facing changes
- Follow existing code style and patterns
- Ensure `nix flake check` passes

## Questions?

Open an issue for discussion before starting major changes.
