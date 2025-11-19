{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # Import minimal profile and QEMU/KVM hardware config
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];

  # Minimal Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader - Kyun.host uses /dev/sda (not /dev/vda)
  boot.loader.grub = {
    enable = true;
    device = lib.mkForce "/dev/sda";
  };

  # Root filesystem - let nixos-generators determine the device
  fileSystems."/" = lib.mkDefault {
    fsType = "ext4";
    autoResize = true;
  };

  boot.kernelParams = [
    "console=ttyS0,115200"
    "net.ifnames=0"
    # DEBUG
    # "earlyprintk=serial,ttyS0,115200"
    # "loglevel=7"
    # "boot.shell_on_fail"
  ];

  # Essential kernel modules for virtio-scsi boot
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "virtio_net"
    "scsi_mod"
    "sd_mod"
    "sr_mod"
  ];

  # Cloud-init support
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # SSH - minimal secure config
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;

  # Allow cloud-init to manage sudo configuration for created users
  # Don't let NixOS security defaults interfere with cloud-init's user setup
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
  security.sudo.execWheelOnly = lib.mkDefault false;

  # Networking - cloud-init generates systemd-networkd config files with static IPs
  # Enable systemd-networkd to apply cloud-init's network configuration
  networking.useDHCP = false;
  networking.useNetworkd = true;
  systemd.network.enable = true;

  # Minimal firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  # System state version
  system.stateVersion = "25.05";
}
