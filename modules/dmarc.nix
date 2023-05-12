{ config, lib, pkgs, pkgs-unstable, ... }: {
  users.users.parsedmarc = {
    isSystemUser = true;
    createHome = true;
    home = "/services/parsedmarc";
    group = config.users.groups.clicks.name;
    shell = pkgs.bashInteractive;
  };
  sops.secrets = lib.pipe [
    "imap_password"
    "maxmind_license_key"
  ] [
    (map (name: {
      inherit name;
      value = {
        mode = "0400";
        owner = config.users.users.parsedmarc.name;
        group = config.users.users.parsedmarc.group;
        sopsFile = ../secrets/dmarc.json;
        format = "json";
      };
    }))
    builtins.listToAttrs
  ];

  services.parsedmarc = {
    enable = true;
    settings.imap = {
      host = "mail.clicks.codes";
      user = "dmarc@clicks.codes";
      password = { _secret = config.sops.secrets.imap_password.path; };
      watch = true;
      delete = false;
    };
  };
  services.geoipupdate.settings = {
    AccountID = 863877;
    LicenseKey = { _secret = config.sops.secrets.maxmind_license_key.path; };
  };
  systemd.services.geoipupdate-create-db-dir.script = lib.mkForce ''
    set -o errexit -o pipefail -o nounset -o errtrace
    shopt -s inherit_errexit

    mkdir -p ${config.services.geoipupdate.settings.DatabaseDirectory}
    chmod 0750 ${config.services.geoipupdate.settings.DatabaseDirectory}

    chgrp clicks ${config.services.geoipupdate.settings.DatabaseDirectory}
    # The license agreement does not allow us to let non-clicks users access the database
  '';
  services.elasticsearch.package = pkgs-unstable.elasticsearch;
}
