{
  description = "Kyun.host cloud-init qcow2 image builder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./modules/image-builder.nix
      ];

      flake = {
        nixosConfigurations = {
          kyun-cloud-init = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              inputs.disko.nixosModules.disko
              ./modules/kyun-base.nix
              ./modules/disk-config.nix
            ];
          };
        };
      };
    };
}
