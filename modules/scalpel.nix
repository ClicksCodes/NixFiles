{ lib, config, ... }: let
  cfg = config.scalpel;
in {
  system.activationScripts.scalpelCreateStore.text = lib.mkForce ''
    echo "[scalpel] Ensuring existance of ${cfg.secretsDir}"
    mkdir -p ${cfg.secretsDir}
    grep -q "${cfg.secretsDir} ramfs" /proc/mounts || mount -t ramfs none "${cfg.secretsDir}" -o nodev,nosuid,mode=0751

    echo "[scalpel] Clearing old secrets from ${cfg.secretsDir}"
    find '${cfg.secretsDir}' -wholename '${cfg.secretsDir}' -o -prune -exec rm -rf -- {} +
  '';
}
