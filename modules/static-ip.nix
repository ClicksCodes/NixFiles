{
  networking.useDHCP = true;
  networking.dhcpcd.extraConfig = ''
    interface enp5s0
    static ip_address=192.168.185.178/16
    static routers=192.168.0.1
    static domain_name_servers=127.0.0.1
  '';
}
