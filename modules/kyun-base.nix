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
  # The /dev/sda1 assumption may be wrong
  fileSystems."/" = lib.mkDefault {
    fsType = "ext4";
    autoResize = true;
  };

  # Kernel parameters with debugging
  boot.kernelParams = [
    "console=ttyS0,115200"
    "net.ifnames=0"
    "earlyprintk=serial,ttyS0,115200"
    "loglevel=7"
    "boot.shell_on_fail"
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

  # Cloud-init support - minimal configuration
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # SSH - minimal secure config
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;

  # Emergency console access - cloud-init will override with SSH keys
  users.users.root.initialPassword = "nixos";

  # Networking - let cloud-init handle it
  networking.useDHCP = false;
  networking.useNetworkd = false;
  systemd.network.enable = lib.mkForce false;

  # Minimal firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  # System state version
  system.stateVersion = "25.05";
}
