{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ syncthing ];

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;

  services.syncthing.extraOptions.gui = {
    user = "admin";
    password = "password";
  };
}
