{ config, ... }: {
  services = {
    nscd.enableNsncd = true;
    dnsmasq = {
      enable = true;
      servers = [ "1.1.1.1" "1.0.0.1" ];
      extraConfig = ''
        local=/local/
        domain=local
        expand-hosts
      '';
    };
    avahi = {
      enable = true;
      nssmdns = true;
      ipv4 = true;
      ipv6 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
  };
}
