# Disko configuration for qcow2 cloud-init image
# This creates a disk image with BIOS boot + /boot + btrfs root
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02"; # BIOS boot partition for GRUB
            };
            boot = {
              size = "512M";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };

  # Configure GRUB bootloader
  # Note: disko already configures the boot device, so we just enable GRUB
  boot.loader.grub = {
    enable = true;
  };
}
