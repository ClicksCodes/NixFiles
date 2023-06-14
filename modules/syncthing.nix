{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ syncthing ];

  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;

  services.syncthing.extraOptions.gui = {
    user = "admin";
    password = "$2y$10$nXJNERNUllFWDUrP4Io1zeJQUtiiZwUj1Js8dglDoc.SvhC9kqddm";
  };
}
