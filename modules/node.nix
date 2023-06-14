{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.typescript
    nodePackages.pnpm
    yarn
    nodePackages.pm2
  ];
}
