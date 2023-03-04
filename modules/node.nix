{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs-19_x
    nodePackages.typescript
    yarn
    nodePackages.pm2
  ];
}
