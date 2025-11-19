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
        # Minimal qcow2 image - configured for Kyun.host (/dev/sda)
        default = inputs.nixos-generators.nixosGenerate {
          inherit system;
          format = "qcow";
          modules = [
            ../modules/danbo-base.nix
            {
              virtualisation.diskSize = 10 * 1024;
            }
          ];
        };
      };
    };
}
