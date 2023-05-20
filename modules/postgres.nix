{ lib, config, pkgs, ... }: {
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql;
    settings = {
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
    };

    ensureUsers = [
      {
        name = "clicks_grafana";
        ensurePermissions = {
          "ALL TABLES IN SCHEMA public" = "SELECT";
          "SCHEMA public" = "USAGE";
        };
      }
      {
        name = "dendrite";
        ensurePermissions = {
          "DATABASE dendrite_account_database" = "ALL PRIVILEGES";
          "DATABASE dendrite_device_database" = "ALL PRIVILEGES";
          "DATABASE dendrite_sync_api" = "ALL PRIVILEGES";
          "DATABASE dendrite_room_server" = "ALL PRIVILEGES";
          "DATABASE dendrite_mscs" = "ALL PRIVILEGES";
          "DATABASE dendrite_media_api" = "ALL PRIVILEGES";
          "DATABASE dendrite_key_server" = "ALL PRIVILEGES";
          "DATABASE dendrite_federation_api" = "ALL PRIVILEGES";
          "DATABASE dendrite_app_service_api" = "ALL PRIVILEGES";
        };
      }
    ] ++ (map
      (name: (
        {
          inherit name;
          ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
        }
      )) [ "minion" "coded" "pinea" ]);

    ensureDatabases = [
      "dendrite_account_database"
      "dendrite_device_database"
      "dendrite_sync_api"
      "dendrite_sync_api"
      "dendrite_room_server"
      "dendrite_mscs"
      "dendrite_media_api"
      "dendrite_key_server"
      "dendrite_federation_api"
      "dendrite_app_service_api"
    ];
  };

  systemd.services.postgresql.postStart = lib.mkAfter (lib.pipe [
    { user = "clicks_grafana"; passwordFile = config.sops.secrets.clicks_grafana_db_password.path; }
    { user = "dendrite"; passwordFile = config.sops.secrets.dendrite_db_password.path; }
  ] [
    (map (userData: ''
      $PSQL -tAc "ALTER USER ${userData.user} PASSWORD '$(cat ${userData.passwordFile})';"
    ''))
    (lib.concatStringsSep "\n")
  ]);

  sops.secrets = lib.pipe [
    "clicks_grafana_db_password"
    "dendrite_db_password"
  ] [
    (map (name: {
      inherit name;
      value = {
        mode = "0400";
        owner = config.services.postgresql.superUser;
        group = config.users.users.${config.services.postgresql.superUser}.group;
        sopsFile = ../secrets/postgres.json;
        format = "json";
      };
    }))
    builtins.listToAttrs
  ];
}
