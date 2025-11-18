{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  # Import hardware configuration for QEMU/KVM
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
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

  # Root filesystem - Kyun.host uses /dev/sda1
  fileSystems."/" = lib.mkForce {
    device = "/dev/sda1";
    fsType = "ext4";
    autoResize = true;
  };

  # Minimal kernel parameters
  boot.kernelParams = [
    "console=ttyS0,115200"
    "net.ifnames=0"
  ];

  # Cloud-init support - minimal configuration
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # SSH - minimal secure config
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;

  # Networking - let cloud-init handle it
  networking.useDHCP = false;
  networking.useNetworkd = false;
  systemd.network.enable = lib.mkForce false;

  # Minimal firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # QEMU guest agent
  services.qemuGuest.enable = true;

  # Minimize image size aggressively
  documentation.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;

  # Disable GUI/X11 completely
  services.xserver.enable = lib.mkDefault false;
  xdg.autostart.enable = lib.mkDefault false;
  xdg.icons.enable = lib.mkDefault false;
  xdg.mime.enable = lib.mkDefault false;
  xdg.sounds.enable = lib.mkDefault false;

  # Minimal locale support - only en_US
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  # Disable unnecessary firmware
  hardware.enableRedistributableFirmware = lib.mkDefault false;
  hardware.enableAllFirmware = lib.mkDefault false;

  # Don't include default NixOS packages
  environment.defaultPackages = lib.mkDefault [ ];

  # System state version
  system.stateVersion = "24.11";
}
