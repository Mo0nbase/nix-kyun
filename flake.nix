{
  description = "Danbo cloud-init qcow2 image builder for kyun.host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          danbo-cloud-init = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./modules/danbo-base.nix
            ];
          };
        };
      };
    };
}
