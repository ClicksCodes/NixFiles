{ base, config, pkgs, lib, ... }: lib.recursiveUpdate
{
  services.caddy.enable = true;
  services.caddy.configFile = lib.pipe ./caddy/caddyfile.nix [
    import
    (f: f { inherit pkgs lib config; })
    builtins.toJSON
    (pkgs.writeText "caddy.json")
  ];
  services.caddy.package = pkgs.callPackage ../packages/caddy.nix { };
  services.caddy.user = "root";
  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;

  sops.secrets.cloudflare_token = {
    mode = "0600";
    owner = config.users.users.root.name;
    group = config.users.users.nobody.group;
    sopsFile = ../secrets/caddy.json;
    format = "json";
  };
}
  (
    let
      isDerived = base != null;
    in
    if isDerived
    then
      let
        caddy_json = base.config.services.caddy.configFile;
      in
      {
        scalpel.trafos."caddy.json" = {
          source = toString caddy_json;
          matchers."cloudflare_token".secret =
            config.sops.secrets.cloudflare_token.path;
          owner = config.users.users.root.name;
          group = config.users.users.nobody.group;
          mode = "0400";
        };

        services.caddy.configFile = lib.mkForce config.scalpel.trafos."caddy.json".destination;

        systemd.services.caddy.reloadTriggers = [ caddy_json ];
      }
    else { }
  )
