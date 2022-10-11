let
  keyfiles = import ../keys/keyfiles.nix { };
in
{
  "alopex_oauth2_proxy_keyFile.age".publicKeys = keyfiles.elikoga ++ keyfiles.alopex-host;
  "swtpra-gitlab-runner-registration.age".publicKeys = keyfiles.elikoga ++ keyfiles.alopex-host;
}
