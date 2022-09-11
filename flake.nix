{
  inputs = {
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
          ];
          format = "qcow";
        };

        contabo-cli = pkgs.callPackage ./contabo-cli.nix { };
      };
    };
}
