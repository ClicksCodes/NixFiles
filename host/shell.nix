{ pkgs, ... }: {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
        enable = true;
        ohMyZsh = [ "zsh-syntax-highlighting" "git" "git-auto-fetch" "gh" ];
        autosuggestions = {
            enable = true;
            async = true;
        };
        syntaxHighlighting.enable = true;
    };
}
