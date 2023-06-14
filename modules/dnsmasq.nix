{ config, ... }: {
  services = {
    nscd.enableNsncd = true;
    dnsmasq = {
      enable = true;
      settings = {
        server = [ "1.1.1.1" "1.0.0.1" ];
        local = "/local/";
        domain = "local";
        expand-hosts = true;
      };
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
