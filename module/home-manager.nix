{pkgs, lib, ...}: {
    # add home-manager user settings here
    home.packages = with pkgs; [
        alacritty
        awscli2
        devenv
        eza
        fzf
        git
        jq
        just
        lazygit
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
      hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
        source = ./../dot_hammerspoon;
        target = ".hammerspoon";
        recursive = true;
      };
    };

    home.sessionVariables = {
        EDITOR = "vim";
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

    programs.alacritty = {
        enable = true;
        settings = {
            env = {
                "TERM" = "xterm-256color";
            };
            window = {
                padding.x = 10;
                padding.y = 10;
                decorations = "buttonless";
                opacity = 0.8;
                blur = true;
            };
            font = {
                size = 12.0;
                normal.family = "JetBrainsMono Nerd Font";
            };
            shell = {
                program = "/bin/zsh";
                args = ["-l" "-c" "zellij"];
            };
        };
    };
}
