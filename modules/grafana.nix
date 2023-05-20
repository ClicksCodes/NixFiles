{ lib, config, ... }: {
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
    };

    provision.datasources.settings.datasources = [{
      name = "clicks-postgresql";
      type = "postgres";
      access = "proxy";

      url = "postgres://localhost:${toString config.services.postgresql.port}";
      user = "clicks_grafana";
      password = "$__file{${config.sops.secrets.clicks_grafana_db_password.path}}";
      # defined in postgres.nix
    }];
  };
}
