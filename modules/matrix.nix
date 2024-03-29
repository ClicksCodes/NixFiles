{ base, config, lib, pkgs, ... }:
lib.recursiveUpdate
{
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    plugins = with config.services.matrix-synapse.package.plugins; [
      matrix-synapse-mjolnir-antispam
    ];

    settings = rec {
      server_name = "coded.codes";
      auto_join_rooms = [ "#general:${server_name}" ];
      enable_registration = true;
      registration_requires_token = true;
      registration_shared_secret = "!!registration_shared_secret!!";
      public_baseurl = "https://matrix-backend.coded.codes/";
      max_upload_size = "100M";
      listeners = [{
        x_forwarded = true;
        tls = false;
        resources = [{
          names = [
            "client"
            "federation"
          ];
          compress = true;
        }];
        port = 4527;
      }];
      enable_metrics = true;
      database.args.database = "synapse";
      turn_uris = [

        /* "turn:turn.coded.codes:3478?transport=udp"
        "turn:turn.coded.codes:3478?transport=tcp"
        "turns:turn.coded.codes:5349?transport=udp"
        "turns:turn.coded.codes:5349?transport=tcp" */
      ]; # Please use matrix.org turn
      # turn_shared_secret = "!!turn_shared_secret!!";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3478 5349 ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 ];

  services.mjolnir = {
    enable = true;

    settings = {
      autojoinOnlyIfManager = true;
      automaticallyRedactForReasons = [ "nsfw" "gore" "spam" "harassment" "hate" ];
      recordIgnoredInvites = true;
      admin.enableMakeRoomAdminCommand = true;
      allowNoPrefix = true;
      protections.wordlist.words = [ ];
      protectedRooms = [ "https://matrix.to/#/#global:coded.codes" ];
    };

    pantalaimon = {
      enable = true;
      username = "system";
      passwordFile = config.sops.secrets.mjolnir_password.path;
      options = {
        ssl = false;
        listenAddress = "127.0.0.1";
      };
    };

    homeserverUrl = "http://localhost:4527";

    managementRoom = "#moderation-commands:coded.codes";
  };

  services.coturn = {
    enable = false;

    use-auth-secret = true;
    # static-auth-secret-file = config.sops.secrets.turn_shared_secret.path;

    realm = "turn.coded.codes";

    no-tcp-relay = true;

    no-cli = true;

    extraConfig = ''
      external-ip=turn.coded.codes
    '';
  };

  sops.secrets = {
    #turn_shared_secret = {
    #  mode = "0440";
    #  owner = "turnserver";
    #  group = "matrix-synapse";
    #  sopsFile = ../secrets/matrix.json;
    #  format = "json";
    #};
    registration_shared_secret = {
      mode = "0400";
      owner = config.users.users.root.name;
      group = config.users.users.nobody.group;
      sopsFile = ../secrets/matrix.json;
      format = "json";
    };
    matrix_private_key = {
      mode = "0600";
      owner = config.users.users.matrix-synapse.name;
      group = config.users.users.matrix-synapse.group;
      sopsFile = ../secrets/matrix_private_key.pem;
      format = "binary";
      path = config.services.matrix-synapse.settings.signing_key_path;
    };
    mjolnir_password = {
      mode = "0600";
      owner = config.users.users.mjolnir.name;
      group = config.users.users.mjolnir.group;
      sopsFile = ../secrets/matrix.json;
      format = "json";
    };
  };
}
  (
    let
      isDerived = base != null;
    in
    if isDerived
    # We cannot use mkIf as both sides are evaluated no matter the condition value
    # Given we use base as an attrset, mkIf will error if base is null in here
    then
      let
        synapse_cfgfile = config.services.matrix-synapse.configFile;
      in
      {
        scalpel.trafos."synapse.yaml" = {
          source = toString synapse_cfgfile;
          matchers."registration_shared_secret".secret =
            config.sops.secrets.registration_shared_secret.path;
          # matchers."turn_shared_secret".secret =
          #   config.sops.secrets.turn_shared_secret.path;
          owner = config.users.users.matrix-synapse.name;
          group = config.users.users.matrix-synapse.group;
          mode = "0400";
        };

        systemd.services.matrix-synapse.serviceConfig.ExecStart = lib.mkForce (
          builtins.replaceStrings
            [ "${synapse_cfgfile}" ]
            [ "${config.scalpel.trafos."synapse.yaml".destination}" ]
            "${base.config.systemd.services.matrix-synapse.serviceConfig.ExecStart}"
        );

        systemd.services.matrix-synapse.preStart = lib.mkForce (
          builtins.replaceStrings
            [ "${synapse_cfgfile}" ]
            [ "${config.scalpel.trafos."synapse.yaml".destination}" ]
            "${base.config.systemd.services.matrix-synapse.preStart}"
        );

        systemd.services.matrix-synapse.restartTriggers = [ synapse_cfgfile ];

        environment.systemPackages =
          with lib; let
            cfg = config.services.matrix-synapse;
            registerNewMatrixUser =
              let
                isIpv6 = x: lib.length (lib.splitString ":" x) > 1;
                listener =
                  lib.findFirst
                    (
                      listener: lib.any
                        (
                          resource: lib.any
                            (
                              name: name == "client"
                            )
                            resource.names
                        )
                        listener.resources
                    )
                    (lib.last cfg.settings.listeners)
                    cfg.settings.listeners;
                # FIXME: Handle cases with missing client listener properly,
                # don't rely on lib.last, this will not work.

                # add a tail, so that without any bind_addresses we still have a useable address
                bindAddress = head (listener.bind_addresses ++ [ "127.0.0.1" ]);
                listenerProtocol =
                  if listener.tls
                  then "https"
                  else "http";
              in
              pkgs.writeShellScriptBin "matrix-synapse-register_new_matrix_user" ''
                exec ${cfg.package}/bin/register_new_matrix_user \
                  $@ \
                  ${lib.concatMapStringsSep " " (x: "-c ${x}") ([
                    config.scalpel.trafos."synapse.yaml".destination ] ++ cfg.extraConfigFiles)} \
                  "${listenerProtocol}://${
                    if (isIpv6 bindAddress) then
                      "[${bindAddress}]"
                    else
                      "${bindAddress}"
                  }:${builtins.toString listener.port}/"
              '';
          in
          [ (lib.meta.hiPrio registerNewMatrixUser) ];
      }
    else { }
  )
