{ inputs, ... }:
{
  imports = [
    (inputs.self + "/keys") # gives access to the system's via ssh
    ./base.nix
  ];
  services.openssh.enable = true;
}
