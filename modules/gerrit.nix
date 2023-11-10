{ pkgs, config, lib, base, system, ... }:
let cfg = config.services.gerrit;
in lib.recursiveUpdate {
  sops.secrets.clicks_gerrit_db_password = {
    mode = lib.mkForce "0440";
    group = lib.mkForce "gerrit";
  };

  users.users.gerrit = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/gerrit";
    group = config.users.groups.gerrit.name;
    shell = pkgs.bashInteractive;
  };
  users.groups.gerrit = { };

  systemd.services.gerrit.serviceConfig.User = "gerrit";
  systemd.services.gerrit.serviceConfig.Group = "gerrit";
  systemd.services.gerrit.serviceConfig.DynamicUser = lib.mkForce false;

  services.gerrit = {
    enable = true;

    /* jvmOpts = [
         "-Djava.class.path=${pkgs.postgresql_jdbc}/share/java"
       ];
    */

    settings = {
      # accountPatchReviewDb.url = "postgresql://localhost:${toString config.services.postgresql.port}/gerrit?user=gerrit&password=!!gerrit_database_password!!";
      accounts = {
        visibility = "SAME_GROUP";
        defaultDisplayName = "USERNAME";
      };
      addReviewer = {
        maxWithoutConfirmation = 3;
        maxAllowed = 10;
      };
      auth = {
        type = "OAUTH";
        registerEmailPrivateKey = "!!gerrit_email_private_key!!";
        userNameCaseInsensitive = true;
        gitBasicAuthPolicy = "HTTP";
      };
      plugin."gerrit-oauth-provider-keycloak-oauth" = {
        root-url = "https://login.clicks.codes";
        realm = "clicks";
        client-id = "git";
        client-secret = "!!gerrit_oauth_client_secret!!";
        use-preferred-username = true;
      };
      change = {
        topicLimit = 0;
        mergeabilityComputationBehavior = "API_REF_UPDATED_AND_CHANGE_REINDEX";
        sendNewPatchsetEmails = false;
        showAssigneeInChangesTable = true;
        submitWholeTopic = true;
        diff3ConflictView = true;
      };
      changeCleanup = {
        abandonAfter = "3 weeks";
        abandonMessage =
          "This change was abandoned due to 3 weeks of inactivity. If you still want it, please restore it";
        startTime = "00:00";
        interval = "1 day";
      };
      attentionSet = {
        readdAfter = "1 week";
        readdMessage =
          "I've given the owner a *ping* as nothing has happened for a week. If in two weeks time the change is still inactive, I'll abandon it for you. If you still want it, please do something before then";
        startTime = "00:00";
        interval = "1 day";
      };
      commentlink.gerrit = {
        match = "(I[0-9a-f]{8,40})";
        link = "/q/$1";
      };
      gc = {
        aggressive = true;
        startTime = "Sun 00:00";
        interval = "1 week";
      };
      gerrit = {
        basePath = "/var/lib/gerrit/repos";
        defaultBranch = "refs/heads/main";
        canonicalWebUrl = "https://git.clicks.codes/";
        canonicalGitUrl = "ssh://ssh.clicks.codes/";
        gitHttpUrl = "https://git.clicks.codes/";
        reportBugUrl =
          "https://discord.gg/bPaNnxe"; # TODO: kinda obnoxious, better to setup bugzilla/similar
        enablePeerIPInReflogRecord = true;
        instanceId = "a1d1";
        instanceName = "a1d1.clicks";
      };
      mimetype = lib.pipe [ "image/*" "video/*" "application/pdf" ] [
        (map (name: {
          inherit name;
          value.safe = true;
        }))
        builtins.listToAttrs
      ];
      receive.enableSignedPush = true;
      sendemail.enable = false; # TODO: add credentials to git@clicks.codes
      sshd.advertisedAddress = "ssh.clicks.codes:29418";
      user = {
        name = "Clicks Gerrit";
        email = "git@clicks.codes";
        anonymousCoward = "Anonymous";
      };
      httpd.listenUrl = "proxy-https://${cfg.listenAddress}";
    };

    plugins = [
      (pkgs.fetchurl {
        url = "https://gerrit-ci.gerritforge.com/job/plugin-oauth-bazel-master-master/55/artifact/bazel-bin/plugins/oauth/oauth.jar";
        hash = "sha256-Qil1CIh/+XC15rKfW0iYR9u370eF2TXnCNSmQfr+7/8=";
      })
    ];
    builtinPlugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];
    serverId = "45f277d0-fce7-43b7-9eb3-2e3234e0110f";

    listenAddress = "127.0.0.255:1000";
  };

  sops.secrets = {
    gerrit_email_private_key = {
      mode = "0400";
      owner = config.users.users.root.name;
      group = config.users.users.nobody.group;
      sopsFile = ../secrets/gerrit.json;
      format = "json";
    };
    gerrit_oauth_client_secret = {
      mode = "0400";
      owner = config.users.users.root.name;
      group = config.users.users.nobody.group;
      sopsFile = ../secrets/gerrit.json;
      format = "json";
    };
  };
} (let isDerived = base != null;
in if isDerived then
  let
    gerrit_cfgfile =
      pkgs.writeText "gerrit.conf" (lib.generators.toGitINI cfg.settings);
  in {
    scalpel.trafos."gerrit.conf" = {
      source = toString gerrit_cfgfile;
      matchers."gerrit_email_private_key".secret =
        config.sops.secrets.gerrit_email_private_key.path;
      matchers."gerrit_oauth_client_secret".secret =
        config.sops.secrets.gerrit_oauth_client_secret.path;
      owner = config.users.users.nobody.name;
      group = "gerrit";
      mode = "0040";
    };

    systemd.services.gerrit.preStart =
      base.config.systemd.services.gerrit.preStart + ''
        rm etc/gerrit.config
        ln -sfv ${
          config.scalpel.trafos."gerrit.conf".destination
        } etc/gerrit.config
      '';
  }
else
  { })
