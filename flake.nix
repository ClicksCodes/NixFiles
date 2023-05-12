{
  description = "A flake to deploy and configure Clicks' NixOS server";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.home-manager.url = "github:nix-community/home-manager/release-22.11";
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.inputs.utils.follows = "deploy-rs/utils";

  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, deploy-rs, home-manager, sops-nix, nixpkgs-unstable, ... }@inputs:
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
            ./modules/mongodb.nix
            ./modules/node.nix
            ./modules/samba.nix
            ./modules/tesseract.nix
            sops-nix.nixosModules.sops
            {
              users.mutableUsers = false;
              _module.args = { inherit pkgs-unstable; };
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
