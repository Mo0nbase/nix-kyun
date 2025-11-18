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
        # Build the qcow2 image using nixos-generators
        default = inputs.nixos-generators.nixosGenerate {
          inherit system;

          # Use qcow2 format for cloud/VPS providers
          format = "qcow";

          # Use our NixOS configuration
          modules = [
            ../modules/kyun-base.nix
            {
              # Override some settings for image generation
              system.stateVersion = "24.11";

              # Ensure the image is bootable
              boot.loader.grub.device = "/dev/vda";

              # Set a reasonable disk size
              virtualisation.diskSize = 10 * 1024; # 10GB

              # Don't set nixpkgs.config, let nixos-generators handle it
              nixpkgs.config = lib.mkForce { };
            }
          ];
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
