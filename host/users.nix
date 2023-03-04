{ pkgs, ... }:
let
  createUser = { username, realname, founder = false, sudo = false, ... }: {
    description = realname;
    extraGroups = (
      (if founder then [ "founder" ] else [ ]) ++
      (if founder || sudo then [ "wheel" ] else [ ])
    );
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ "./sshKeys/${username}" ];
  };

  users = {
    "coded" = { realname = "Sam"; founder = true; };
    "minion" = { realname = "Skyler"; founder = true; };
    "pineapplefan" = { realname = "Ash"; founder = true; };
    "eek" = { realname = "Nexus"; sudo = true; };
  };
in
{
  users = {
    mutableUsers = false;
    motd = ''
      Welcome to Clicks! Please make sure to follow all guidelines for using the server, which you can find by typing
      `guidelines` in your terminal. In particular, please remember to use this server as minimally as possible (e.g.
      by keeping as much of your work as is possible stateless and by using your personal
      "${builtins.readFile ./texts/MOTD}"
    '';
    defaultUserShell = pkgs.zsh;
    users = builtins.mapAttrs (name: value: createUser { username = name; } // value) users;
    groups = { };
  };
}
