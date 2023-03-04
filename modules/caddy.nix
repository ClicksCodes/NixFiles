{ config, pkgs, ... }: {
  services.caddy.enable = true;
  services.caddy.extraConfig = builtins.readFile ./caddy/Caddyfile;
}
