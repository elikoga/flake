{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.05";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = {
        qcow2 = nixos-generators.nixosGenerate {
          inherit system;
          modules = [
            ./init-image.nix
            ./contaboBaseModule.nix
            ./keys/nixosModule.nix
          ];
          format = "qcow";
        };

        contabo-cli = pkgs.callPackage ./contabo-cli.nix { };
      };
    };
}
