{pkgs, lib, ...}: {
    # add home-manager user settings here
    home.packages = with pkgs; [
        awscli2
        devenv
        eza
        fzf
        git
        jq
        just
        kitty
        lazygit
		micro
        ripgrep
        starship
        yq
        zellij
        zoxide
        zsh-fzf-tab
    ];
    home.stateVersion = "23.11";

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    
    # hammerspoon
    home.file = {
      #hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
      #  source = ./../dot_hammerspoon;
      #  target = ".hammerspoon";
      #  recursive = true;
      #};
    };

    home.sessionVariables = {
        EDITOR = "micro";
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LC_CTYPE = "en_US.UTF-8";
        PATH = "$PATH:$GOPATH/bin";
    };

    programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
    };

    programs.fzf = {
        enable = true;
        enableZshIntegration = true;
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        initExtra = ''
            # force fzf tab to work (https://discourse.nixos.org/t/darwin-home-manager-zsh-fzf-and-zsh-fzf-tab/33943)
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';
        shellAliases = {
            worklog = "vim ~/Documents/worklog.md";
            dr = "docker container run --interactive --rm --tty";
            lg = "lazygit";
            nb = "nix build --json --no-link --print-build-logs";
            wt = "git worktree";
        };
        oh-my-zsh = {
            enable = true;
            plugins = ["git" "z"];
            theme = "robbyrussell";
        };
    };

    programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
            add_newline = false;
        };
    };

    programs.kitty = {
        enable = true;
        font = {
            size = 12.0;
            name =  "JetBrainsMono Nerd Font";
        };
        settings = {
            scrollback_lines = 10000;
            enable_audio_bell = false;
            update_check_interval = 0;

            background_opacity = "0.8";
            background_blur = "1";

            hide_window_decorations = "titlebar-and-corners";
            macos_quit_when_last_window_closed = "yes";
            confirm_os_window_close = 0;
            remember_window_size = "yes";

            tab_bar_style = "powerline";
        };
    };
}
