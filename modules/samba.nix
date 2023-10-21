{ lib, config, pkgs, ... }: {
  services.samba = {
    enable = true;
    shares = {
      HDD = {
        path = "/services/kavita/Kavita/drive1";
        browseable = "yes";
        "guest ok" = "no";
        comment =
          "Jellyfin, torrents & tempfiles. Use for large amounts of data that don't necessarily need to be accessed at top speed";
      };
      SSD = {
        path = "/services/kavita/Kavita/drive2";
        browseable = "yes";
        "guest ok" = "no";
        comment = "Manga & LNs. Use for smaller, faster storage";
      };
    };
  };

  fileSystems = {
    "/services/kavita/Kavita/drive1".device =
      "/dev/disk/by-uuid/dda57e4d-81b7-4f52-b3ac-f14544b3aaf4";
    "/services/kavita/Kavita/drive2".device =
      "/dev/disk/by-uuid/24d30ffe-91ed-4e41-b40d-f42b02e144a9";
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
}
