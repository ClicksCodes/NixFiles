{ config, lib, pkgs, ... }:

# A temporary hack to `loginctl enable-linger $somebody` (for
# multiplexer sessions to last), until this one is unresolved:
# https://github.com/NixOS/nixpkgs/issues/3702
#
# Usage: `users.extraUsers.somebody.linger = true` or slt.
# Originally from
# https://gist.githubusercontent.com/graham33/fdbdcc18317a621d9dd54beb36be6683/raw/776ed252749313470f1c9a286a0419ba9746d133/loginctl-linger.nix,
# modified by Minion3665

with lib;

let

  dataDir = "/var/lib/systemd/linger";

  lingeringUsers = map (u: u.name) (attrValues (flip filterAttrs config.users.users (n: u: u.linger)));

  lingeringUsersFile = builtins.toFile "lingering-users"
    (concatStrings (map (s: "${s}\n")
      (sort (a: b: a < b) lingeringUsers))); # this sorting is important for `comm` to work correctly

  updateLingering = ''
    if [ -e ${dataDir} ] ; then
      ${pkgs.gawk}/bin/awk -F':' '{ print $1}' /etc/passwd | sort > /tmp/users-that-actually-exist
      ls ${dataDir} | sort | comm -3 -1 ${lingeringUsersFile} - | comm -3 -2 /tmp/users-that-actually-exist - | xargs -r ${pkgs.systemd}/bin/loginctl disable-linger
      ls ${dataDir} | sort | comm -3 -2 ${lingeringUsersFile} - | xargs -r ${pkgs.systemd}/bin/loginctl  enable-linger
      ls ${dataDir} | sort | comm -3 -1 /tmp/users-that-actually-exist - | ${pkgs.gawk}/bin/awk '{print "${dataDir}/"$1}' | xargs -r rm
      rm -f /tmp/users-that-actually-exist
    fi
  '';

  userOptions = {
    options.linger = mkEnableOption "Lingering for the user";
  };

in

{
  options = {
    users.users = mkOption {
      type = with types; attrsOf (submodule userOptions);
    };
  };

  config = {
    system.activationScripts.update-lingering = stringAfter [ "users" ] updateLingering;
  };
}
