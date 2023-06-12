{ pkgs... }: {
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
        # RSA_KEY_FILENAME=data/rsa_key
        # ICON_CACHE_FOLDER=data/icon_cache
        # ATTACHMENTS_FOLDER=data/attachments
        # SENDS_FOLDER=data/sends
        # TMP_FOLDER=data/tmp

        DISABLE_2FA_REMEMBER=true;

        # Admin Account
        ADMIN_TOKEN="$argon2id$v=19$m=100,t=2,p=10$dWVoN1llNTFpVHRXZXNicA$oXSZOeoCRxgA6aXBmRj0Ow";


        # Database Settings
        DATABASE_URL="postgresql://FILL_ME_IN:FILL_ME_IN@127.0.0.1:FILL_ME_IN/bitwarden";


        # Mail Settings
        SMTP_HOST = "127.0.0.1";
        SMTP_FROM = "bitwarden@clicks.codes";
        SMTP_FROM_NAME = "Clicks Bitwarden";
        SMTP_SECURITY = "starttls";
        SMTP_PORT = 587;

        SMTP_USERNAME="FILL_ME_IN";
        SMTP_PASSWORD="FILL_ME_IN";

        REQUIRE_DEVICE_EMAIL=true;


        # YubiKey Settings
        YUBICO_CLIENT_ID="FILL_ME_IN";
        YUBICO_SECRET_KEY="FILL_ME_IN";


        # TODO: Buy a license
        # HIBP Settings
        # HIBP_API_KEY="FILL_ME_IN";
    };
}