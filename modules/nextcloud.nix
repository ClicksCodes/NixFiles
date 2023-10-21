{ config, pkgs, lib, ... }: {
  sops.secrets.clicks_nextcloud_db_password = {
    mode = lib.mkForce "0440";
    group = lib.mkForce "nextcloud";
  };

  users.users.nextcloud = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/nextcloud";
    group = config.users.groups.nextcloud.name;
    shell = pkgs.bashInteractive;
  };
  users.groups.nextcloud = { };

  services.nextcloud.enable = true;
  services.nextcloud.https = true;
  services.nextcloud.config.adminpassFile =
    config.sops.secrets.nextcloud_admin_password.path;
  services.nextcloud.hostName = "nextcloud.clicks.codes";
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    enableACME = true;
    forceSSL = true;
  };
  services.nextcloud.package = pkgs.nextcloud27;
  services.nextcloud.poolSettings = {
    pm = "dynamic";
    "pm.max_children" = "32";
    "pm.max_requests" = "500";
    "pm.max_spare_servers" = "4";
    "pm.min_spare_servers" = "2";
    "pm.start_servers" = "2";
    "listen.owner" = config.users.users.nextcloud.name;
    "listen.group" = config.users.users.nextcloud.group;
  };

  services.nextcloud.config = {
    dbtype = "pgsql";
    dbport = config.services.postgresql.port;
    dbpassFile = config.sops.secrets.clicks_nextcloud_db_password.path;
    dbname = "nextcloud";
    dbhost = "localhost";
    extraTrustedDomains = [ "cloud.clicks.codes" "docs.clicks.codes" ];
  };

  services.nextcloud.extraOptions = { social_login_auto_redirect = true; };

  services.nextcloud.extraApps = {
    sociallogin = pkgs.fetchNextcloudApp {
      url =
        "https://github.com/zorn-v/nextcloud-social-login/releases/download/v5.5.3/release.tar.gz";
      sha256 = "sha256-96/wtK7t23fXVRcntDONjgb5bYtZuaNZzbvQCa5Gsj4=";
    };
    richdocumentscode = pkgs.fetchNextcloudApp {
      url = "redacted";
      sha256 = "sha256-XYtjBZCIQ6+PL3BNLSZfJTgLLpOyphzR5HOAwI7bWx0=";
    };
    richdocuments = pkgs.fetchNextcloudApp {
      url =
        "https://github.com/nextcloud-releases/richdocuments/releases/download/v8.2.0/richdocuments-v8.2.0.tar.gz";
      sha256 = "sha256-PKw7FXSWvden2+6XjnUDOvbTF71slgeTF/ktS/l2+Dk=";
    };
  };

  sops.secrets.nextcloud_admin_password = {
    mode = "0600";
    owner = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group;
    sopsFile = ../secrets/nextcloud.json;
    format = "json";
  };
}
