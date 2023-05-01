{
  description = "A flake to deploy and configure Clicks' NixOS server";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";

  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.inputs.utils.follows = "deploy-rs/utils";

  outputs = { self, nixpkgs, deploy-rs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.clicks =
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./default/configuration.nix
            ./default/hardware-configuration.nix
            ./modules/caddy.nix
            ./modules/clamav.nix
            ./modules/code-server.nix
            ./modules/dnsmasq.nix
            ./modules/doas.nix
            ./modules/docker.nix
            ./modules/ecryptfs.nix
            ./modules/fail2ban.nix
            ./modules/fuck.nix
            ./modules/git.nix
            ./modules/home-manager-users.nix
            ./modules/kitty.nix
            ./modules/mongodb.nix
            ./modules/node.nix
            ./modules/samba.nix
            ./modules/tesseract.nix
            {
              users.mutableUsers = false;
            }
          ];
        };

      deploy.nodes.clicks = {
        sudo = "doas -u";
        profiles = {
          system = {
            remoteBuild = true;
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.clicks;
          };
        } // (
          let
            mkServiceConfig = service: {
              remoteBuild = true;
              user = service;

              profilePath = "/nix/var/nix/profiles/per-user/${service}/home-manager";
              path =
                deploy-rs.lib.x86_64-linux.activate.home-manager (home-manager.lib.homeManagerConfiguration
                  {
                    inherit pkgs;
                    modules = [
                      {
                        home.homeDirectory = "/services/${service}";
                        home.username = service;
                        home.stateVersion = "22.11";
                        programs.home-manager.enable = true;
                      }
                      "${./services}/${service}"
                    ];
                  });
            };
          in
          nixpkgs.lib.pipe ./services [
            builtins.readDir
            (nixpkgs.lib.filterAttrs (_name: value: value == "directory"))
            builtins.attrNames
            (map (name: {
              inherit name; value = mkServiceConfig name;
            }))
            builtins.listToAttrs
          ]
        );
        hostname = "clicks";
        profilesOrder = [ "system" ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
