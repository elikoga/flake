{ config, ... }:
{
  services.openssh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
