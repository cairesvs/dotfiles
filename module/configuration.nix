{ pkgs, ... }:

{
  # add more system settings here
  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = ["flakes" "nix-command"];
      substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["@wheel"];
      warn-dirty = false;
    };
  };

  programs.zsh.enable = true;

  fonts.packages = [
    pkgs.atkinson-hyperlegible
    pkgs.jetbrains-mono
  ];

  homebrew = {
      enable = true;

      casks = [
          #"1password"
          #"firefox"
          #"hammerspoon"
          #"obsidian"
      ];
  };

  system = {
      defaults = {
          dock = {
              autohide = true;
              orientation = "left";
              show-process-indicators = false;
              show-recents = false;
              static-only = true;
          };
          finder = {
              AppleShowAllExtensions = true;
              FXDefaultSearchScope = "SCcf";
              FXEnableExtensionChangeWarning = false;
              ShowPathbar = true;
          };
          NSGlobalDomain = {
              AppleKeyboardUIMode = 3;
              "com.apple.keyboard.fnState" = true;
              NSAutomaticWindowAnimationsEnabled = false;
          };
      };
  };
}
