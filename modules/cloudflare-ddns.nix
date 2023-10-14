{ config, ... }: {
  services.cloudflare-dyndns = {
    enable = true;
    proxied = false;
    ipv4 = true;
    ipv6 = false;
    domains = [ "d1.a1.crawling.us" ];
    apiTokenFile = config.sops.secrets.cloudflare_ddns__api_token.path;
  };

  sops.secrets.cloudflare_ddns__api_token = {
    mode = "0600";
    owner = config.users.users.root.name;
    group = config.users.users.root.group;
    sopsFile = ../secrets/cloudflare-ddns.env.bin;
    format = "binary";
  };
}
