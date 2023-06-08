{
  description = "A flake to deploy and configure Clicks' NixOS server";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.scalpel.url = "github:polygon/scalpel";

  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.inputs.utils.follows = "deploy-rs/utils";

  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.scalpel.inputs.nixpkgs.follows = "nixpkgs";
  inputs.scalpel.inputs.sops-nix.follows = "sops-nix";

  outputs = { self, nixpkgs, deploy-rs, home-manager, sops-nix, scalpel, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    rec {
      nixosConfigurations.clicks =
        let
          base = nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            modules = [
              ./default/configuration.nix
              ./default/hardware-configuration.nix
              ./modules/cache.nix
              ./modules/caddy.nix
              ./modules/clamav.nix
              ./modules/code-server.nix
              ./modules/dmarc.nix
              ./modules/dnsmasq.nix
              ./modules/doas.nix
              ./modules/docker.nix
              ./modules/ecryptfs.nix
              ./modules/fail2ban.nix
              ./modules/fuck.nix
              ./modules/git.nix
              ./modules/grafana.nix
              ./modules/home-manager-users.nix
              ./modules/kitty.nix
              ./modules/loginctl-linger.nix
              ./modules/matrix.nix
              ./modules/mongodb.nix
              ./modules/node.nix
              ./modules/postgres.nix
              ./modules/samba.nix
              ./modules/scalpel.nix
              ./modules/static-ip.nix
              ./modules/tesseract.nix
              sops-nix.nixosModules.sops
              {
                users.mutableUsers = false;
                _module.args = { inherit pkgs-unstable; };
              }
            ];
            specialArgs = { base = null; };
          };
        in
        base.extendModules {
          modules = [
            scalpel.nixosModules.scalpel
          ];
          specialArgs = { inherit base; };
        };

      nixosConfigurations.clicks-without-mongodb =
        nixosConfigurations.clicks.extendModules {
          modules = [
            { services.mongodb.enable = nixpkgs.lib.mkForce false; }
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
        ) // (
          let
            mkBlankConfig = username:
              {
                remoteBuild = true;
                user = username;

                profilePath = "/nix/var/nix/profiles/per-user/${username}/home-manager";
                path =
                  deploy-rs.lib.x86_64-linux.activate.home-manager (home-manager.lib.homeManagerConfiguration
                    {
                      inherit pkgs;
                      modules = [
                        {
                          home.username = username;
                          home.stateVersion = "22.11";
                          programs.home-manager.enable = true;
                        }
                        "${./homes}/${username}"
                      ];
                    });
              };
          in
          nixpkgs.lib.pipe ./homes [
            builtins.readDir
            (nixpkgs.lib.filterAttrs (_name: value: value == "directory"))
            builtins.attrNames
            (map (name: {
              inherit name; value = mkBlankConfig name;
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
