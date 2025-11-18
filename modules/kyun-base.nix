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

  # Nix settings
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Enable automatic garbage collection
      auto-optimise-store = true;
    };
    # Clean up old generations weekly
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Bootloader configuration for BIOS boot
  boot.loader.grub = {
    enable = true;
    device = lib.mkDefault "/dev/vda"; # nixos-generators will override if needed
  };

  boot.loader.timeout = lib.mkDefault 3;

  # Enable serial console for headless operation and disable predictable interface names
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200"
    "net.ifnames=0"
    "earlyprintk=serial,ttyS0,115200"
    "debug"
    "loglevel=7"
    "initcall_debug"
    "boot.shell_on_fail"
  ];

  # Kernel modules for QEMU/KVM virtio drivers
  # Kyun.host uses virtio-scsi, so the disk appears as /dev/sda but uses virtio
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "virtio_ring"
    "sd_mod"
    "sr_mod"
    "scsi_mod"
  ];

  # Enable required filesystems
  boot.supportedFilesystems = [ "ext4" ];

  # No swap by default
  swapDevices = [ ];

  # Filesystem configuration
  # nixos-generators will create the actual filesystems, but we need to declare them
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # Enable QEMU guest agent for VPS dashboard features
  services.qemuGuest.enable = true;

  # Security
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Networking - will be configured via cloud-init from /dev/sr1
  # kyun.host provides static IP configuration, not DHCP
  # Hostname will also be set by cloud-init from meta-data
  networking.hostName = lib.mkDefault "";
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # Minimal firewall - allow SSH
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Time zone
  time.timeZone = "UTC";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
    # Generate new host keys on first boot
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # Cloud-init support - reads from /dev/sr1 provided by kyun.host
  services.cloud-init = {
    enable = true;
    # Enable cloud-init network configuration
    # This will read network-config from /dev/sr1 and apply static IPs
    network.enable = true;
    # Use NoCloud data source which reads from /dev/sr1
    ext4.enable = false;
  };

  # Disable systemd.network to avoid conflict with cloud-init networking
  # Cloud-init will manage network configuration via traditional networking scripts
  systemd.network.enable = lib.mkForce false;

  # Allow cloud-init to manage networking through NixOS networking module
  # This ensures cloud-init's network-config is applied to NixOS networking
  networking.useNetworkd = false;

  # Ensure cloud-init can find the config drive
  # kyun.host provides cloud-init data at /dev/sr1 with label "cidata"
  fileSystems."/mnt/cloud-init" = {
    device = "/dev/disk/by-label/cidata";
    fsType = "iso9660";
    options = [
      "ro"
      "nofail"
    ];
  };

  # Cloud-init will read network config from the mounted drive
  # This allows kyun.host to dynamically configure networking
  systemd.services.cloud-init-local = {
    after = [ "mnt-cloud\\x2dinit.mount" ];
    wants = [ "mnt-cloud\\x2dinit.mount" ];
  };

  # Default user shell
  users.defaultUserShell = pkgs.bash;

  # Root user - SSH keys and password will be configured via cloud-init
  # Cloud-init reads authorized_keys from user-data at /dev/sr1
  users.users.root = {
    # Allow root login but keys will be provided by cloud-init
    openssh.authorizedKeys.keys = [ ];
  };

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    tmux
  ];

  # Set platform architecture
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # System state version
  system.stateVersion = "24.11";
}
