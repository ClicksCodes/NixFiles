# README

IMPORTANT: **ONLY UNPRIVILEGED, NIX/SYSTEMD RUN SERVICES ARE INCLUDED HERE.
SERVICES RUN WITH PM2 OR THAT NEED ROOT ARE NOT INCLUDED HERE**

- systemd services should be *user* services so the unprivileged service account
  can run them
- all configuration should be [home-manager](https://github.com/nix-community/home-manager)
  configuration files rather than NixOS configuration files

## Installed services

<!-- spell-checker:words etherpad -->
- etherpad: <https://etherpad.org/>
  - uses git-sync with home-manager to sync the release-3.x
  - runs using a systemd service
