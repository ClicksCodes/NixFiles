{ pkgs, config, lib, ... }: {
  home.packages = [ pkgs.nodejs-14_x ];

  services.git-sync = {
    enable = false;

    repositories = {
      "etherpad" = {
        path = "${config.home.homeDirectory}/etherpad/";
        uri = "https://github.com/ether/etherpad-lite";
      };
    };
  };

  systemd.user.services = {
    git-sync-etherpad.Service = {
      Environment = [
        "GIT_SYNC_EXECHOOK_COMMAND=${pkgs.systemd}/bin/systemctl restart etherpad --user"
        "GIT_SYNC_REV=1.8.18"
        "GIT_SYNC_ONE_TIME=true"
      ];
      ExecStart = lib.mkForce (builtins.replaceStrings [ "\n" ] [ "" ]
        ''${pkgs.bashInteractive}/bin/sh -c "
          ${pkgs.coreutils}/bin/mkdir -p ${config.services.git-sync.repositories.etherpad.path}
          && cd ${config.services.git-sync.repositories.etherpad.path}
          && ${pkgs.git}/bin/git clone ${config.services.git-sync.repositories.etherpad.uri} .
          && ${pkgs.git}/bin/git checkout $GIT_SYNC_REV
          ; ${config.services.git-sync.package}/bin/git-sync"'');
    };
    /* etherpad = { */
    /*   Unit.Description = "A service to run etherpad"; */

    /*   Install.WantedBy = [ "default.target" ]; */

    /*   Service = rec { */
    /*     ExecStart = "${pkgs.bashInteractive}/bin/sh -c \"export PATH=$PATH:/run/current-system/sw/bin && ${WorkingDirectory}src/bin/run.sh\""; */
    /*     Restart = "always"; */
    /*     WorkingDirectory = "${config.home.homeDirectory}/etherpad/"; */
    /*   }; */
    /* }; */
  };
}
