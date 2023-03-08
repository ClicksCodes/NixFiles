{ pkgs, ... }: {
  services.clamav = {
    updater.enable = true;
    daemon.enable = true;
  };
  environment.systemPackages = [ pkgs.clamav ];
}
