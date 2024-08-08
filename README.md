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

```console
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

5. Answer the following with y to setup <darwin> in nix-channel (though it won't be used):

```console
Would you like to manage <darwin> with nix-channel? [y/n]
```

