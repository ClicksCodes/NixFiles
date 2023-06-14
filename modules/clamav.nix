{ pkgs, ... }: {
  services.clamav = {
    updater.enable = true;
    daemon = {
      enable = true;
      settings.TCPSocket = 3310;
    };
  };
  environment.systemPackages = [ pkgs.clamav ];
}
