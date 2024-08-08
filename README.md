# Setup macos

1. Install nix:

```console
sh <(curl -L https://nixos.org/nix/install)
```

2. Install nix-darwin with official steps:

```console
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
```

```console
./result/bin/darwin-installer
```

4. Add the following to configuration.nix to enable nix-command and flakes features:

Add devenv to system packages:

```console
environment.systemPackages =
[
    pkgs.devenv
    pkgs.vim
];
```

Enable flakes:
```console
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

5. Answer the following with y to setup <darwin> in nix-channel (though it won't be used):

```console
Would you like to manage <darwin> with nix-channel? [y/n]
```

6. Execute and install all the packages (this might take a while)

```console
just darwin-switch
```

## Todo

Move the Mac Applications to nix:

1password
cleanshot
font-jetbrains-mono-nerd-font
hammerspoon
hiddenbar
stats
yubico-yubikey-manager
