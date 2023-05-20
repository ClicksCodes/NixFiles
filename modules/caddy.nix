{ config, pkgs, lib, ... }: {
  services.caddy.enable = true;
  services.caddy.configFile = lib.pipe ./caddy/caddyfile.nix [
    import
    builtins.toJSON
    (pkgs.writeText "caddy.json")
  ];
  services.caddy.package = pkgs.callPackage ../packages/caddy.nix {
    vendorSha256 = "sha256-3KcoOAB+YkOU8qKM75uQo58/dljRBmP25dionr9r2dc=";
  };
  services.caddy.user = "root";
  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;
}
