{ self, inputs, ... }:

{
  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    {
      packages = {
        # Build the qcow2 image using make-disk-image
        default = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix" {
          inherit pkgs lib;

          # Use our NixOS configuration
          config = self.nixosConfigurations.kyun-cloud-init.config;

          # Image format
          format = "qcow2";

          # Disk size (10GB)
          diskSize = 10 * 1024;

          # Partition table type
          partitionTableType = "legacy";

          # Install bootloader
          installBootLoader = true;

          # Additional space for /boot
          additionalSpace = "512M";

          # Copy the system closure to the image
          copyChannel = false;
        };
      };

      # Add convenience app for building
      apps = {
        default = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "build-kyun-image" ''
              set -e
              echo "Building kyun.host cloud-init qcow2 image..."
              ${pkgs.nix}/bin/nix build .#default
              echo ""
              echo "✓ Image built successfully!"
              echo "  Output: result/nixos.qcow2"
              echo ""
              echo "Upload this image to kyun.host dashboard."
              echo "Cloud-init configuration will be provided by kyun.host at /dev/sr1"
            ''
          );
          meta = {
            description = "Build kyun.host cloud-init compatible qcow2 image";
          };
        };
      };
    };
}
