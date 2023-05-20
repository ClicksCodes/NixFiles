{ base, config, lib, pkgs, ... }:
{
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

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
    };
  };

  sops.secrets = {
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
      synapse_cfgfile = config.services.matrix-synapse.configFile;
    in
    {
      scalpel.trafos."synapse.yaml" = {
        source = toString synapse_cfgfile;
        matchers."registration_shared_secret".secret =
          config.sops.secrets.registration_shared_secret.path;
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
