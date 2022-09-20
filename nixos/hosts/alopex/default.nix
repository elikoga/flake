{ inputs, pkgs, lib, ... }:
let
  keyfiles = import (inputs.self + "/keys/keyfiles.nix") { inherit lib; };
in
{
  imports = [
    (inputs.self + "/nixos/modules/profiles/base.nix")
    (inputs.self + "/nixos/modules/profiles/contabo.nix")
    inputs.vscode-server.nixosModule
  ];

  services.openssh.enable = true;
  services.vscode-server.enable = true;

  users.users.elikoga = {
    openssh.authorizedKeys.keys = keyfiles.elikoga;
    isNormalUser = true;
  };
  users.users.root.openssh.authorizedKeys.keys = keyfiles.elikoga;
  users.mutableUsers = false;

  networking.hostName = "alopex";

  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens18";
  };

  networking.interfaces.ens18.ipv6.addresses = [{
    address = "2a02:c206:3009:7843::1";
    prefixLength = 64;
  }];

  environment.systemPackages = [
    pkgs.git
    pkgs.nixpkgs-fmt
    pkgs.neovim
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  # The comment: Read the changelogs.
  system.stateVersion = "22.05"; # Did you read the comment?
}
