{
  description = "A flake to deploy and configure Clicks' NixOS server";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  inputs.nixpkgs-clicksforms.url = "github:nixos/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.home-manager.url = "github:nix-community/home-manager/release-23.05";
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.scalpel.url = "github:polygon/scalpel";

  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.scalpel.inputs.nixpkgs.follows = "nixpkgs";
  inputs.scalpel.inputs.sops-nix.follows = "sops-nix";

  inputs.nixpkgs-privatebin.url = "github:e1mo/nixpkgs/privatebin";

  outputs =
    { self
    , nixpkgs
    , deploy-rs
    , home-manager
    , sops-nix
    , scalpel
    , nixpkgs-privatebin
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: { inherit (nixpkgs-privatebin.legacyPackages.${system}) privatebin pbcli; })
        ];
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
              ./modules/cloudflare-ddns.nix
              ./modules/dmarc.nix
              ./modules/dnsmasq.nix
              ./modules/doas.nix
              ./modules/docker.nix
              ./modules/drivePaths.nix
              ./modules/ecryptfs.nix
              ./modules/fail2ban.nix
              ./modules/fuck.nix
              ./modules/gerrit.nix
              ./modules/git.nix
              ./modules/grafana.nix
              ./modules/home-manager-users.nix
              ./modules/keycloak.nix
              ./modules/kitty.nix
              ./modules/loginctl-linger.nix
              ./modules/matrix.nix
              ./modules/mongodb.nix
              ./modules/nextcloud.nix
              ./modules/node.nix
              ./modules/postgres.nix
              ./modules/privatebin.nix
              ./modules/samba.nix
              ./modules/scalpel.nix
              ./modules/ssh.nix
              ./modules/static-ip.nix
              ./modules/syncthing.nix
              ./modules/tesseract.nix
              ./modules/vaultwarden.nix
              sops-nix.nixosModules.sops
              "${nixpkgs-privatebin}/nixos/modules/services/web-apps/privatebin.nix"
              {
                users.mutableUsers = false;
              }
            ];
            specialArgs = { base = null; drive_paths = import ./variables/drive_paths.nix; inherit system; };
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
                    extraSpecialArgs = { inherit (inputs) nixpkgs-clicksforms; inherit system; };
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

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [ pkgs.deploy-rs ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
