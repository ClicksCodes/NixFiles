{
  services.grafana = {
    enable = true;

    settings = {
      server = rec {
        domain = "logs.clicks.codes";
        root_url ="https://${domain}";
        http_port = 9052;
        enable_gzip = true;
      };
      analytics.reporting_enabled = false;
    };
  };
}
