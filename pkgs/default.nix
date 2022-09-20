{ system ? "x86_64-linux"
, pkgs ? import <nixpkgs> { inherit system; }
}:
{
  contabo-cli = pkgs.callPackage ./contabo-cli.nix { };
}
