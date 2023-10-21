{ config, ... }: {
  services.keycloak = {
    enable = true;
    settings = {
      http-host = "127.0.0.1";
      http-port = 9083;
      https-port = 9084;
      http-enabled = true;

      proxy = "edge";

      # https-port = 9084;
      hostname = "login.clicks.codes";
      hostname-strict = false;

      https-certificate-file = "/var/keycloak/login.clicks.codes.rsa.cert.pem";
      https-certificate-key-file =
        "/var/keycloak/login.clicks.codes.rsa.private.pem";
    };
    database = {
      createLocally = false;
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.clicks_keycloak_db_password.path;
    };
  };
}
