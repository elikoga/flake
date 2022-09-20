{ lib, ... }:
# Module setting access keys for systems
let keyfiles = (import ./keyfiles.nix {
  inherit lib;
}); in
{
  users.users = lib.attrsets.mapAttrs
    (key: value: {
      openssh.authorizedKeys.keys = value;
    })
    {
      root = keyfiles.elikoga;
    }
  ;
}
