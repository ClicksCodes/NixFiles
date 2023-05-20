{ base, config, lib, pkgs, ... }:
let
  postgresUrlFor = service:
    "postgres://dendrite:!!dendrite_db_password!!@localhost:${toString config.services.postgresql.port}/dendrite_${service}?sslmode=disable";
in
{
  services.dendrite = {
    enable = true;
    httpPort = 4527;
    settings = {
      global = {
        server_name = "coded.codes";
        private_key = config.sops.secrets.matrix_private_key.path;
      };
      user_api = {
        account_database.connection_string = postgresUrlFor "account_database";
        device_database.connection_string = postgresUrlFor "device_database";
      };
      sync_api = {
        search.enable = true;
        database.connection_string = postgresUrlFor "sync_api";
      };
      room_server.database.connection_string = postgresUrlFor "room_server";
      mscs.database.connection_string = postgresUrlFor "mscs";
      media_api.database.connection_string = postgresUrlFor "media_api";
      key_server.database.connection_string = postgresUrlFor "key_server";
      federation_api.database.connection_string = postgresUrlFor "federation_api";
      app_service_api.database.connection_string = postgresUrlFor "app_service_api";

      client_api.registration_shared_secret = "!!registration_shared_secret!!";
    };
  };

  users.users.dendrite = {
    isSystemUser = true;
    createHome = true;
    home = config.systemd.services.dendrite.serviceConfig.WorkingDirectory;
    group = "clicks";
    shell = pkgs.bashInteractive;
  };

  systemd.services.dendrite.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = lib.mkForce config.users.users.dendrite.name;
    Group = lib.mkForce config.users.users.dendrite.group;
  };

  sops.secrets = (lib.pipe [
    "registration_shared_secret"
  ] [
    (map (name: {
      inherit name;
      value = {
        mode = "0400";
        owner = config.users.users.root.name;
        group = config.users.users.nobody.group;
        sopsFile = ../secrets/matrix.json;
        format = "json";
      };
    }))
    builtins.listToAttrs
  ]) // {
    matrix_private_key = {
      mode = "0400";
      owner = config.users.users.dendrite.name;
      group = config.users.users.dendrite.group;
      sopsFile = ../secrets/matrix_private_key.pem;
      format = "binary";
    };
  };
} // (
  let
    isDerived = base != null;
  in
  if isDerived
  # We cannot use mkIf as both sides are evaluated no matter the condition value
  # Given we use base as an attrset, mkIf will error if base is null in here
  then
    let
      ExecStartPre = "${base.config.systemd.services.dendrite.serviceConfig.ExecStartPre}";
      dendrite_cfgfile = builtins.head (builtins.match ".*-i ([^[:space:]]+).*" "${ExecStartPre}");
    in
    {
      scalpel.trafos."dendrite.yaml" = {
        source = dendrite_cfgfile;
        matchers."dendrite_db_password".secret =
          config.sops.secrets.dendrite_db_password.path; # Defined in postgres.nix
        matchers."registration_shared_secret".secret =
          config.sops.secrets.registration_shared_secret.path;
        owner = config.users.users.dendrite.name;
        group = config.users.users.dendrite.group;
        mode = "0400";
      };

      systemd.services.dendrite.serviceConfig.ExecStartPre = lib.mkForce (
        builtins.replaceStrings
          [ "${dendrite_cfgfile}" ]
          [ "${config.scalpel.trafos."dendrite.yaml".destination}" ]
          "${ExecStartPre}"
      );
    }
  else { }
)
