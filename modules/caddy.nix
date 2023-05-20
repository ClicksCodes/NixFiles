{ config, pkgs, lib, ... }: {
  services.caddy.enable = true;
  services.caddy.configFile = lib.pipe ./caddy/caddyfile.nix [
    import
    (f: f { inherit pkgs lib; })
    builtins.toJSON
    (pkgs.writeText "caddy.json")
  ];
  services.caddy.package = pkgs.callPackage ../packages/caddy.nix { };
  services.caddy.user = "root";
  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;
}
