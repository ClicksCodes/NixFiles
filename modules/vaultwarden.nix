{ pkgs, drive_paths, ... }: {
    environment.systemPackages = with pkgs; [ vaultwarden ];

    services.vaultwarden.enable = true;
    services.vaultwarden.dbBackend = "postgresql";

    services.vaultwarden.config = {
        # Server Settings
        DOMAIN = "https://passwords.clicks.codes";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8452;


        # General Settings
        SIGNUPS_ALLOWED=false;
        INVITATIONS_ALLOWED=true;
        SIGNUPS_DOMAINS_WHITELIST="clicks.codes,coded.codes,thecoded.prof,starrysky.fyi,hopescaramels.com,pinea.dev";

        # TODO: Set folder locations for storing data.
        RSA_KEY_FILENAME="${drive_paths.root}/bitwarden/rsa_key";
        ICON_CACHE_FOLDER="${drive_paths.root}/bitwarden/icon_cache";
        ATTACHMENTS_FOLDER="${drive_paths.External4000HDD}/bitwarden/attachments";
        SENDS_FOLDER="${drive_paths.External4000HDD}/bitwarden/sends";
        TMP_FOLDER="${drive_paths.External4000HDD}/bitwarden/tmp";

        DISABLE_2FA_REMEMBER=true;

        # Admin Account
        ADMIN_TOKEN="!!ADMIN_TOKEN!!";


        # Database Settings
        DATABASE_URL="postgresql://bitwarden:!!clicks_bitwarden_db_secret!!@127.0.0.1:${}/bitwarden";


        # Mail Settings
        SMTP_HOST = "127.0.0.1";
        SMTP_FROM = "bitwarden@clicks.codes";
        SMTP_FROM_NAME = "Clicks Bitwarden";
        SMTP_SECURITY = "starttls";
        SMTP_PORT = 587;

        SMTP_USERNAME="FILL_ME_IN";
        SMTP_PASSWORD="!!SMTP_PASSWORD!!";

        REQUIRE_DEVICE_EMAIL=true;


        # YubiKey Settings
        YUBICO_CLIENT_ID="89788";
        YUBICO_SECRET_KEY="!!YUBICO_SECRET_KEY!!";


        # TODO: Buy a license
        # HIBP Settings
        # HIBP_API_KEY="!!HIBP_API_KEY!!";
    };
}