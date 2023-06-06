{ config, ... }: {
  services.fail2ban = {
    enable = true;
    jails = {
      mailu-auth-fail = ''
        enabled = true
        backend = systemd
        filter = mailu-auth-fail
        bantime = 604800
        findtime = 600
        maxretry = 5
      '';
      mailu-auth-limit = ''
        enabled = true
        backend = systemd
        filter = mailu-auth-limit
        bantime = 604800
        findtime = 900
        maxretry = 15
      '';
      samba = ''
        filter=samba-filter
        enabled=true
        logpath=/var/log/messages
        maxretry=1
        findtime=600
        bantime=2592000
      '';
    };
    banaction-allports = "iptables-allports";
    banaction = config.services.fail2ban.banaction-allports;
    bantime = "24h";
    bantime-increment = {
      enable = true;
      rndtime = "1h";
      overalljails = true;
      factor = "24";
    };
  };
  environment.etc = {
    "fail2ban/filter.d/mailu-auth-fail.conf".text = ''
      [Definition]
      failregex = ^\s?\S+ mailu\-front\[\d+\]: \S+ \S+ \[info\] \d+#\d+: \*\d+ client login failed: \"AUTH not supported\" while in http auth state, client: <HOST>, server:
      ignoreregex =
      journalmatch = CONTAINER_TAG=mailu-front
    '';

    "fail2ban/filter.d/mailu-auth-limit.conf".text = ''
      [Definition]
      failregex = : Authentication attempt from <HOST> has been rate-limited\.$
      ignoreregex =
      journalmatch = CONTAINER_TAG=mailu-admin
    '';

    "fail2ban/filter.d/samba-filter.conf".text = ''
      [Definition]
      # Honeypot file regex. The files in the honeypot folder MUST match this regex
      __honeypot_files_re=(-sync-decrypted\.)

      # Known ransomware extensions regex
      __known_ransom_extensions_re=(\.k$|\.encoderpass$|\.key$|\.ecc$|\.ezz$|\.exx$|\.zzz$|\.xyz$|\.aaa$|\.abc$|\.ccc$|\.vvv$|\.xxx$|\.ttt$|\.micro$|\.encrypted$|\.locked$|\.crypto$|_crypt$|\.crinf$|\.r5a$|\.xrtn$|\.XTBL$|\.crypt$|\.R16M01D05$|\.pzdc$|\.good$|\.LOL\!$|\.OMG\!$|\.RDM$|\.RRK$|\.encryptedRSA$|\.crjoker$|\.EnCiPhErEd$|\.LeChiffre$|\.keybtc@inbox_com$|\.0x0$|\.bleep$|\.1999$|\.vault$|\.HA3$|\.toxcrypt$|\.magic$|\.SUPERCRYPT$|\.CTBL$|\.CTB2$|\.locky$|\.wnry$|\.wcry$|\.wncry$|\.wncryt$|\.uiwix$)
      # Known ransomware files regex
      __known_ransom_files_re=(HELPDECRYPT\.TXT$|HELP_YOUR_FILES\.TXT$|HELP_TO_DECRYPT_YOUR_FILES\.txt$|RECOVERY_KEY\.txt$|HELP_RESTORE_FILES\.txt$|HELP_RECOVER_FILES\.txt$|HELP_TO_SAVE_FILES\.txt$|DecryptAllFiles\.txt$|DECRYPT_INSTRUCTIONS\.TXT$|INSTRUCCIONES_DESCIFRADO\.TXT$|How_To_Recover_Files\.txt$|YOUR_FILES\.HTML$|YOUR_FILES\.url$|Help_Decrypt\.txt$|DECRYPT_INSTRUCTION\.TXT$|HOW_TO_DECRYPT_FILES\.TXT$|ReadDecryptFilesHere\.txt$|Coin\.Locker\.txt$|_secret_code\.txt$|About_Files\.txt$|Read\.txt$|ReadMe\.txt$|DECRYPT_ReadMe\.TXT$|DecryptAllFiles\.txt$|FILESAREGONE\.TXT$|IAMREADYTOPAY\.TXT$|HELLOTHERE\.TXT$|READTHISNOW\!\!\!\.TXT$|SECRETIDHERE\.KEY$|IHAVEYOURSECRET\.KEY$|SECRET\.KEY$|HELPDECYPRT_YOUR_FILES\.HTML$|help_decrypt_your_files\.html$|HELP_TO_SAVE_FILES\.txt$|RECOVERY_FILES\.txt$|RECOVERY_FILE\.TXT$|RECOVERY_FILE.*\.txt$|HowtoRESTORE_FILES\.txt$|HowtoRestore_FILES\.txt$|howto_recover_file\.txt$|restorefiles\.txt$|howrecover\+.*\.txt$|_how_recover\.txt$|recoveryfile.*\.txt$|recoverfile.*\.txt$|recoveryfile.*\.txt$|Howto_Restore_FILES\.TXT$|help_recover_instructions\+.*\.txt$|_Locky_recover_instructions\.txt$)

      # Match on known ransomware regex or generic honeypot
      failregex = smbd.*:\ IP=<HOST>\ .*%(__honeypot_files_re)s
            smbd.*:\ IP=<HOST>\ .*%(__known_ransom_extensions_re)s
            smbd.*:\ IP=<HOST>\ .*%(__known_ransom_files_re)s

      # Filter generously provided by https://github.com/CanaryTek/ransomware-samba-tools
      # Provided under GPL3
    '';
  };
}
