{pkgs, ...}: {
# add home-manager user settings here
    home.packages = with pkgs; [
        awscli2
        eza
        fzf
        git
        jq
        lazygit
        ripgrep
        yq
        zellij
        zoxide
    ];
    home.stateVersion = "23.11";
}
