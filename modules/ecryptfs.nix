{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    let
      unlock-database-script = writeScriptBin "unlock-database-encryption" ''
        if [ $UID -ne 0 ]; then
          echo "unlock-database-encryption must be run as root"
          exit 1
        fi
        ECRYPTFS_SIG=$(( stty -echo; printf "Passphrase: " 1>&2; read PASSWORD; stty echo; echo $PASSWORD; ) | ecryptfs-insert-wrapped-passphrase-into-keyring ~/.ecryptfs/wrapped-passphrase - | sed -nr 's/.*\[(.*)\].*/\1/p')

        keyctl link @u @s

        mount -i -t ecryptfs /var/db/.mongodb-encrypted/ /var/db/mongodb -o ecryptfs_sig=$ECRYPTFS_SIG,ecryptfs_fnek_sig=$ECRYPTFS_SIG,ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_unlink_sigs
      '';
    in [ ecryptfs keyutils unlock-database-script ];
}
