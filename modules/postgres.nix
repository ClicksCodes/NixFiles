{ lib, config, pkgs, ... }: {
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql;
    settings = {
      log_connections = true;
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";
    };

    ensureDatabases = [
      "vaultwarden"
      "gerrit"
      "privatebin"
      "keycloak"
      "nextcloud"
    ];

    ensureUsers = [
      {
        name = "clicks_grafana";
        ensurePermissions = {
          "ALL TABLES IN SCHEMA public" = "SELECT";
          "SCHEMA public" = "USAGE";
        };
      }
      {
        name = "synapse";
        ensurePermissions = {
          "DATABASE synapse" = "ALL PRIVILEGES";
        };
      }
      {
        name = "keycloak";
        ensurePermissions = {
          "DATABASE keycloak" = "ALL PRIVILEGES";
        };
      }
      {
        name = "gerrit";
        ensurePermissions = {
          "DATABASE gerrit" = "ALL PRIVILEGES";
        };
      }
      {
        name = "vaultwarden";
        ensurePermissions = {
          "DATABASE vaultwarden" = "ALL PRIVILEGES";
        };
      }
      {
        name = "privatebin";
        ensurePermissions = {
          "DATABASE privatebin" = "ALL PRIVILEGES";
        };
      }
      {
        name = "nextcloud";
        ensurePermissions = {
          "DATABASE nextcloud" = "ALL PRIVILEGES";
        };
      }
    ] ++ (map
      (name: (
        {
          inherit name;
          ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
        }
      )) [ "minion" "coded" "pinea" ]);

  };

  systemd.services.postgresql.postStart = lib.mkMerge [
    (
      let
        database = "synapse";
        cfg = config.services.postgresql;
      in
      lib.mkBefore (
        ''
          PSQL="psql --port=${toString cfg.port}"

          while ! $PSQL -d postgres -c "" 2> /dev/null; do
              if ! kill -0 "$MAINPID"; then exit 1; fi
              sleep 0.1
          done

          $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = '${database}'" | grep -q 1 || $PSQL -tAc 'CREATE DATABASE "${database}" WITH LC_CTYPE="C" LC_COLLATE="C" TEMPLATE="template0"'
        ''
      ) # synapse needs C collation, so we can't use ensureDatabases for it
    )
    (lib.mkAfter (lib.pipe [
      { user = "clicks_grafana"; passwordFile = config.sops.secrets.clicks_grafana_db_password.path; }
      { user = "keycloak"; passwordFile = config.sops.secrets.clicks_keycloak_db_password.path; }
      { user = "gerrit"; passwordFile = config.sops.secrets.clicks_gerrit_db_password.path; }
      { user = "vaultwarden"; passwordFile = config.sops.secrets.clicks_bitwarden_db_password.path; }
      { user = "privatebin"; passwordFile = config.sops.secrets.clicks_privatebin_db_password.path; }
      { user = "nextcloud"; passwordFile = config.sops.secrets.clicks_nextcloud_db_password.path; }
    ] [
      (map (userData: ''
        $PSQL -tAc "ALTER USER ${userData.user} PASSWORD '$(cat ${userData.passwordFile})';"
      ''))
      (lib.concatStringsSep "\n")
    ]))
  ];

  sops.secrets = lib.pipe [
    "clicks_grafana_db_password"
    "clicks_keycloak_db_password"
    "clicks_gerrit_db_password"
    "clicks_bitwarden_db_password"
    "clicks_privatebin_db_password"
    "clicks_nextcloud_db_password"
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
