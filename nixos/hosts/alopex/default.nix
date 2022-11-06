{ inputs, pkgs, lib, config, ... }:
let
  keyfiles = import (inputs.self + "/keys/keyfiles.nix") { inherit lib; };
in
{
  imports = [
    (inputs.self + "/nixos/modules/profiles/base.nix")
    (inputs.self + "/nixos/modules/profiles/contabo.nix")
    inputs.vscode-server.nixosModule
    inputs.agenix.nixosModule
  ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;
  services.vscode-server.enable = true;
  services.netdata = {
    enable = true;
    config = {
      db = {
        "mode" = "dbengine";
        "update every" = 1;
        "storage tiers" = 3;
        "dbengine multihost disk space MB" = 1100;
        "dbengine tier 1 multihost disk space MB" = 330;
        "dbengine tier 2 multihost disk space MB" = 67;
      };
    };
  };
  # see https://discourse.nixos.org/t/how-to-create-folder-in-var-lib-with-nix/15647
  # https://github.com/NixOS/nixpkgs/blob/2ddc335e6f32b875e14ad9610101325b306a0add/nixos/modules/system/activation/activation-script.nix#L214-L228
  system.activationScripts.disableNetdataCloud = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/netdata/cloud.d
    cat > /var/lib/netdata/cloud.d/cloud.conf <<EOF
    [global]
      enabled = no
    EOF
    chmod -R 0770 /var/lib/netdata/cloud.d
    chown -R netdata:netdata /var/lib/netdata/cloud.d
  '';
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts =
      let
        base = {
          forceSSL = true;
          enableACME = true;
        };
        rootBase = root: base // {
          locations."/" = root;
        };
      in
      {
        "alopex.6xr.de" = rootBase {
          return = "302 https://eliko.ga/";
        };
        "netdata.alopex.6xr.de" = rootBase {
          proxyPass = "http://localhost:19999/";
        };
        "auth.alopex.6xr.de" = rootBase { };
      };
  };

  age.secrets.alopex_oauth2_proxy_keyFile.file = inputs.self + "/secrets/alopex_oauth2_proxy_keyFile.age";
  age.secrets.swtpra12draft-gitlab-runner-registration.file = inputs.self + "/secrets/swtpra12draft-gitlab-runner-registration.age";
  age.secrets.swtpra-gitlab-runner-registration.file = inputs.self + "/secrets/swtpra-gitlab-runner-registration.age";

  services.gitlab-runner = {
    enable = true;
    concurrent = 4;
    gracefulTermination = true;
    gracefulTimeout = "5min";
    services = {
      default-swtpra12draft = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = config.age.secrets.swtpra12draft-gitlab-runner-registration.path;
        dockerImage = "debian:stable";
      };
      docker-swtpra12draft = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = config.age.secrets.swtpra12draft-gitlab-runner-registration.path;
        dockerImage = "docker:stable";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        tagList = [ "docker-images" ];
      };
      default-swtpra12 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = config.age.secrets.swtpra-gitlab-runner-registration.path;
        dockerImage = "debian:stable";
      };
      docker-swtpra12 = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = config.age.secrets.swtpra-gitlab-runner-registration.path;
        dockerImage = "docker:stable";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        tagList = [ "docker-images" "docker" ];
      };
    };
  };

  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "hourly";

  services.oauth2_proxy = {
    enable = true;
    nginx.virtualHosts = [
      "netdata.alopex.6xr.de"
      "auth.alopex.6xr.de"
    ];
    redirectURL = "https://auth.alopex.6xr.de/oauth2/callback";
    provider = "github";
    keyFile = config.age.secrets.alopex_oauth2_proxy_keyFile.path;
    email.addresses = "elikowa" + "@" + "gmail.com";
    reverseProxy = true;
    setXauthrequest = true;
    scope = "user:email";
    cookie.domain = ".alopex.6xr.de";
    extraConfig = {
      "whitelist-domain" = "*.alopex.6xr.de";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "elikowa" + "@" + "gmail.com";
  };

  users.users.elikoga = {
    openssh.authorizedKeys.keys = keyfiles.elikoga;
    isNormalUser = true;
  };
  users.users.root.openssh.authorizedKeys.keys = keyfiles.elikoga;
  users.mutableUsers = false;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

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

    inputs.agenix.defaultPackage.x86_64-linux
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  # The comment: Read the changelogs.
  system.stateVersion = "22.05"; # Did you read the comment?
}




