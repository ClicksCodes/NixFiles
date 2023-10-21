{ lib, config, base, pkgs, helpers, ... }:
lib.recursiveUpdate {
  services.grafana = {
    enable = true;

    settings = {
      server = rec {
        domain = "logs.clicks.codes";
        root_url = "https://${domain}";
        http_port = 9052;
        enable_gzip = true;
      };
      analytics.reporting_enabled = false;
      "auth.generic_oauth" = {
        enabled = true;
        name = "Clicks OAuth";
        allow_sign_up = true;
        client_id = "grafana";
        client_secret = "!!client_secret!!";
        scopes = "openid email profile offline_access roles";
        email_attribute_path = "email";
        login_attribute_path = "login";
        name_attribute_path = "name";
        auth_url =
          "https://login.clicks.codes/realms/clicks/protocol/openid-connect/auth";
        token_url =
          "https://login.clicks.codes/realms/clicks/protocol/openid-connect/token";
        api_url =
          "https://login.clicks.codes/realms/clicks/protocol/openid-connect/userinfo";
        role_attribute_path =
          "contains(resource_access.grafana.roles[*], 'server_admin') && 'GrafanaAdmin' || contains(resource_access.grafana.roles[*], 'admin') && 'Admin' || contains(resource_access.grafana.roles[*], 'editor') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
        auto_login = true;
      };
      "auth.basic".enabled = false;
      auth.disable_login_form = true;
    };

    provision.datasources.settings.datasources = [{
      name = "clicks-postgresql";
      type = "postgres";
      access = "proxy";

      url = "postgres://localhost:${toString config.services.postgresql.port}";
      user = "clicks_grafana";
      password =
        "$__file{${config.sops.secrets.clicks_grafana_db_password.path}}";
      # defined in postgres.nix
    }];
  };

  sops.secrets.clicks_grafana_client_secret = {
    mode = "0600";
    owner = "root";
    group = "nobody";
    sopsFile = ../secrets/grafana.json;
    format = "json";
  };
} (let isDerived = base != null;
in if isDerived then
  let
    generators = lib.generators;
    cfg = config.services.grafana;
    settingsFormatIni = pkgs.formats.ini {
      listToValue =
        lib.concatMapStringsSep " " (generators.mkValueStringDefault { });
      mkKeyValue = generators.mkKeyValueDefault {
        mkValueString = v:
          if v == null then "" else generators.mkValueStringDefault { } v;
      } "=";
    };
    grafana_cfgfile = settingsFormatIni.generate "config.ini" cfg.settings;
  in {
    scalpel.trafos."grafana.ini" = {
      source = toString grafana_cfgfile;
      matchers."client_secret".secret =
        config.sops.secrets.clicks_grafana_client_secret.path;
      owner = config.users.users.grafana.name;
      group = "nobody";
      mode = "0400";
    };

    systemd.services.grafana.serviceConfig.ExecStart = lib.mkForce
      (pkgs.writeShellScript "grafana-start" ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit

        exec ${cfg.package}/bin/grafana-server -homepath ${cfg.dataDir} -config ${
          config.scalpel.trafos."grafana.ini".destination
        }
      '');
    systemd.services.grafana.restartTriggers = [ grafana_cfgfile ];
  }
else
  { })
