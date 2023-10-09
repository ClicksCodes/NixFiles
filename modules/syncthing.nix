{ pkgs, ... }: {
  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;

  services.syncthing.guiAddress = "0.0.0.0:8384";
}
