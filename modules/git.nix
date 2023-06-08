{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ gh git ];

  services.gitea = {
    enable = false;
    settings.mailer = {
      ENABLED = true;
      FROM = "git@clicks.codes";
      PROTOCOL = "smtps";
      SMTP_ADDR = "smtp.coded.codes";
      SMTP_PORT = "465";
      USER = "git@clicks.codes";
      PASSWD = "ilIfASM@U5Z4XOEoH99gA8jPvGiOiEdx";
      HELO_HOSTNAME = "git.clicks.codes";
    };
    settings.service = {
      REGISTER_EMAIL_CONFIG = false;
      ENABLE_NOTIFY_MAIL = false;
      DISABLE_REGISTRATION = true;
      ENABLE_CAPTCHA = false;
      REQUIRE_SIGNIN_VIEW = false;
      DEFAULT_KEEP_EMAIL_PRIVATE = false;
      DEFAULT_ENABLE_TIMETRACKING = true;
    };
    settings.server = {
      ROOT_URL = "https://git.clicks.codes/";
      HTTP_PORT = 6064;
      SSH_DOMAIN = "ssh.clicks.codes";
      DOMAIN = "localhost";
      DISABLE_SSH = false;
      OFFLINE_MODE = false;
    };
    settings.openid.ENABLE_OPENID_SIGNIN = true;
    settings.log = {
      MODE = "console";
      LEVEL = "Info";
      ROUTER = "console";
    };
    settings.repository = {
      ENABLE_PUSH_CREATE_USER = true;
      ENABLE_PUSH_CREATE_ORG = true;
    };
    settings."repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
    settings."repository.signing".DEFAULT_TRUST_MODEL = "committer";
    settings.security = {
      INSTALL_LOCK = true;
      PASSWORD_HASH_ALGO = "pbkdf2";
    };
    settings.indexer = {
      REPO_INDEXER_ENABLED = true;
      UPDATE_BUFFER_LEN = 20;
      MAX_FILE_SIZE = 1048576;
    };
    settings.session.PROVIDER = "file";
  };
}
