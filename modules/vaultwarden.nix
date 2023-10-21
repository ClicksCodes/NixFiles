{ base, pkgs, drive_paths, lib, config, ... }:
lib.recursiveUpdate {
  environment.systemPackages = with pkgs; [ vaultwarden ];

  services.vaultwarden.enable = true;
  services.vaultwarden.dbBackend = "postgresql";

  sops.secrets = lib.pipe [
    "ADMIN_TOKEN"
    "SMTP_PASSWORD"
    "YUBICO_SECRET_KEY"
    "HIBP_API_KEY"
  ] [
    (map (name: {
      inherit name;
      value = {
        mode = "0400";
        owner = config.users.users.root.name;
        group = config.users.users.nobody.group;
        sopsFile = ../secrets/vaultwarden.json;
        format = "json";
      };
    }))
    builtins.listToAttrs
  ];
} (let isDerived = base != null;
in if isDerived
# We cannot use mkIf as both sides are evaluated no matter the condition value
# Given we use base as an attrset, mkIf will error if base is null in here
then
  with lib;
  let
    cfg = config.services.vaultwarden;

    vaultwarden_config = {
      # Server Settings
      DOMAIN = "https://passwords.clicks.codes";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8452;

      # General Settings
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;
      SIGNUPS_DOMAINS_WHITELIST =
        "clicks.codes,coded.codes,thecoded.prof,starrysky.fyi,hopescaramels.com,pinea.dev,trans.gg";
      SIGNUPS_VERIFY = true;

      RSA_KEY_FILENAME =
        "${drive_paths.External1000SSD.path}/bitwarden/rsa_key";
      ICON_CACHE_FOLDER =
        "${drive_paths.External1000SSD.path}/bitwarden/icon_cache";
      ATTACHMENTS_FOLDER =
        "${drive_paths.External4000HDD.path}/bitwarden/attachments";
      SENDS_FOLDER = "${drive_paths.External4000HDD.path}/bitwarden/sends";
      TMP_FOLDER = "${drive_paths.External4000HDD.path}/bitwarden/tmp";

      DISABLE_2FA_REMEMBER = true;

      # Admin Account
      ADMIN_TOKEN = "!!ADMIN_TOKEN!!";

      # Database Settings
      DATABASE_URL =
        "postgresql://vaultwarden:!!clicks_bitwarden_db_secret!!@127.0.0.1:${
          toString config.services.postgresql.port
        }/vaultwarden";

      # Mail Settings
      SMTP_HOST = "mail.clicks.codes";
      SMTP_FROM = "bitwarden@clicks.codes";
      SMTP_FROM_NAME = "Clicks Bitwarden";
      SMTP_SECURITY = "starttls";
      SMTP_PORT = 587;

      SMTP_USERNAME = "bitwarden@clicks.codes";
      SMTP_PASSWORD = "!!SMTP_PASSWORD!!";

      REQUIRE_DEVICE_EMAIL = true;

      IP_HEADER = "X-Forwarded-For";

      # YubiKey Settings
      YUBICO_CLIENT_ID = "89788";
      YUBICO_SECRET_KEY = "!!YUBICO_SECRET_KEY!!";

      # TODO: Buy a license
      # HIBP Settings
      # HIBP_API_KEY="!!HIBP_API_KEY!!";

      ORG_ENABLE_GROUPS = true;
      # I have looked at the risks. They seem relatively small in comparison to the utility
      # (stuff like sync issues if you don't refresh your page)
      # Also a general lack of real-world testing. Which, honestly, doesn't
      # seem too bad. Please contact me *immediately* upon noticing issues
      # as I want to make sure that as little as possible is lost if we need
      # to restore from backups (although I doubt it'll come to that)
    };

    nameToEnvVar = name:
      let
        parts = builtins.split "([A-Z0-9]+)" name;
        partsToEnvVar = parts:
          foldl' (key: x:
            let last = stringLength key - 1;
            in if isList x then
              key
              + optionalString (key != "" && substring last 1 key != "_") "_"
              + head x
            else if key != "" && elem (substring 0 1 x)
            lowerChars then # to handle e.g. [ "disable" [ "2FAR" ] "emember" ]
              substring 0 last key
              + optionalString (substring (last - 1) 1 key != "_") "_"
              + substring last 1 key + toUpper x
            else
              key + toUpper x) "" parts;
      in if builtins.match "[A-Z0-9_]+" name != null then
        name
      else
        partsToEnvVar parts;

    # Due to the different naming schemes allowed for config keys,
    # we can only check for values consistently after converting them to their corresponding environment variable name.
    configEnv = let
      configEnv = concatMapAttrs (name: value:
        optionalAttrs (value != null) {
          ${nameToEnvVar name} =
            if isBool value then boolToString value else toString value;
        }) vaultwarden_config;
    in {
      DATA_FOLDER = "/var/lib/bitwarden_rs";
    } // optionalAttrs (!(configEnv ? WEB_VAULT_ENABLED)
      || configEnv.WEB_VAULT_ENABLED == "true") {
        WEB_VAULT_FOLDER = "${cfg.webVaultPackage}/share/vaultwarden/vault";
      } // configEnv;

    configFile = pkgs.writeText "vaultwarden.env" (concatStrings (mapAttrsToList
      (name: value: ''
        ${name}=${value}
      '') configEnv));
  in {
    scalpel.trafos."vaultwarden.env" = {
      source = toString configFile;
      matchers."ADMIN_TOKEN".secret = config.sops.secrets.ADMIN_TOKEN.path;
      matchers."SMTP_PASSWORD".secret = config.sops.secrets.SMTP_PASSWORD.path;
      matchers."YUBICO_SECRET_KEY".secret =
        config.sops.secrets.YUBICO_SECRET_KEY.path;
      matchers."HIBP_API_KEY".secret = config.sops.secrets.HIBP_API_KEY.path;
      matchers."clicks_bitwarden_db_secret".secret =
        config.sops.secrets.clicks_bitwarden_db_password.path;
      owner = config.users.users.vaultwarden.name;
      group = config.users.groups.vaultwarden.name;
      mode = "0400";
    };

    services.vaultwarden.environmentFile =
      config.scalpel.trafos."vaultwarden.env".destination;
  }
else
  { })
