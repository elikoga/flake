{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      modulePath = ./nixos/modules;
    in
    {
      packages.${system} = import ./pkgs { inherit system pkgs; };
      nixosConfigurations =
        let
          baseConfiguration = {
            inherit system;
            specialArgs = {
              inherit inputs;
            };
          };
        in
        {
          contaboBootstrap = nixpkgs.lib.nixosSystem (baseConfiguration // {
            modules = [
              (modulePath + "/profiles/contabo-bootstrap.nix")
            ];
          });
          alopex = nixpkgs.lib.nixosSystem (baseConfiguration // {
            modules = [
              ./nixos/hosts/alopex
            ];
          });
        };
    };
}
