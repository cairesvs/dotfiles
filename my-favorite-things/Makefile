# Configuration
#
# Variables used in m4 templates
user-email = cairesvs@gmail,com
user-name = caires
user-nick = $(USER)
colorscheme = base16-light

# Template parsing command
macrocmd = m4 \
	   -Duser_name="$(user-name)" \
	   -Duser_nick="$(user-nick)" \
	   -Duser_email="$(user-email)" \
	   macros.m4 \
	   $(colorscheme).m4

# Userspace
#

dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.config/user-dirs.dirs \
	~/.compton.conf \
	~/.ctags \
	~/.bashrc \
	~/.vimrc \
	~/.bash_profile \
	~/.Xresources \
	~/.Xresources.d/colorscheme \
	~/.Xresources.d/rofi \
	~/.Xresources.d/urxvt \
	~/.zshrc

user/simple: $(dotfiles)
	echo "dotfiles <3"

user/desktop: $(dotfiles) \
	applications/i3wm \
	applications/launcher \
	applications/locker \
	applications/ranger \
	applications/redshift \
	applications/urxvt \
	applications/zathura
	pacaur -S --noconfirm --needed \
		compton \
		gnome-keyring \
		hsetroot \
		sxiv

user/environments/golang: ~/.env-golang
	sudo pacman -S --noconfirm --needed \
		go \
		go-tools
	source ~/.env-golang
	vim +GoInstallBinaries +qall
	curl https://glide.sh/get | sh

user/environments/rust: ~/.env-rust
	curl https://sh.rustup.rs -sSf \
		| sh -s -- --no-modify-path
	rustup install nightly
	rustup default nightly
	rustup run nightly cargo install rustfmt-nightly

user/i3: applications/polybar \
	 applications/feh \
	 user/wallpaper \
	 ~/.xinitrc \
	 ~/.config/i3/config \
	 ~/.bin/polybar \
	 ~/.config/polybar/config
	echo "Conf for i3"

user/wallpaper:
	mkdir -vp ~/.my-favorite-things/ \
		&& cp wallpapers/wallpaper.jpeg ~/.my-favorite-things/wallpaper.jpeg

user/company: applications/dev-env
	sudo pacman -S --noconfirm --needed zsh \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Applications
#

applications/polybar:
	pacaur -S --noconfirm --needed \
		polybar

applications/feh:
	sudo pacman -S --noconfirm --needed \
		feh

applications/fzf:
	sudo pacman -S --noconfirm --needed \
	fzf

applications/dev-env:
	sudo pacman -S --noconfirm --needed \
		jq \
		aws-cli \
		intellij-idea-community-edition

applications/pavucontrol:
	sudo pacman -S --noconfirm --needed \
		pavucontrol

applications/i3wm: user/i3
	sudo pacman -S --noconfirm --needed \
		i3-gaps\
		i3lock \

applications/launcher: ~/.bin/launcher \
	~/.Xresources.d/rofi
	sudo pacman -S --noconfirm --needed \
		rofi

applications/dunst: ~/.config/dunst/dunstrc
	pacaur -S --noconfirm --needed \
		dunst-git
	systemctl --user enable dunst.service
	systemctl --user start dunst.service

applications/mpd: ~/.config/mpd/mpd.conf ~/.config/systemd/user/mpd.service
	sudo pacman -S --noconfirm --needed mpd mpc
	mkdir -p ~/.mpd/playlists
	systemctl --user daemon-reload
	systemctl --user enable mpd.service
	systemctl --user start mpd.service

applications/ncmpcpp: ~/.ncmpcpp/bindings ~/.ncmpcpp/config
	sudo pacman -S --noconfirm --needed ncmpcpp

applications/mpv:
	sudo pacman -S --noconfirm --needed \
		mpv

applications/ranger: ~/.config/ranger/rc.conf ~/.bin/previewer ~/.bin/imgt
	sudo pacman -S --noconfirm --needed \
		highlight \
		ranger \
		w3m

applications/zathura:
	sudo pacman -S --noconfirm --needed \
		zathura \
		zathura-pdf-mupdf

applications/urxvt: ~/.Xresources.d/urxvt
	if ! [ -d ~/.config/base16-shell ]; then git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell; fi
	sudo pacman -S --noconfirm --needed \
		rxvt-unicode \
		urxvt-perls
	mkdir -p ~/.urxvt/ext/
	curl -SL -o ~/.urxvt/ext/keyboard-select "https://raw.githubusercontent.com/muennich/urxvt-perls/master/keyboard-select"
	curl -SL -o ~/.urxvt/ext/resize-font "https://raw.githubusercontent.com/simmel/urxvt-resize-font/master/resize-font"
	xrdb -load ~/.Xresources

applications/locker: ~/.bin/my-favorite-things-locker ~/.bin/my-favorite-things-locker /etc/systemd/system/my-favorite-things-locker.service
	sudo systemctl enable my-favorite-things-locker.service
	mkdir -p ~/.my-favorite-things/ \
		&& cp templates/dotfiles/my-favorite-things/lock-icon.png ~/.my-favorite-things/lock-icon.png
	sudo pacman -S --noconfirm --needed \
		maim \
		i3lock \
		imagemagick

applications/firefox:
	pacaur -S --noconfirm --needed \
		iceweasel

applications/docker:
	sudo pacman -S --noconfirm --needed \
		docker \
		lxc
	sudo gpasswd -a $(USER) docker

# Core
#

core/utils:
	sudo pacman -S --noconfirm \
		bash-completion \
		ctags \
		git   \
		openssh  \
		unzip \
		xclip \
		xsel

core/fonts:
	pacaur -S --noconfirm --needed \
		fontconfig-infinality-ultimate \
		cairo-infinality-ultimate \
		bdf-creep \
		cantarell-fonts \
		scientifica-bdf \
		siji-git \
		tamzen-font-git \
		ttf-bitstream-vera \
		ttf-dejavu \
		ttf-droid \
		ttf-fira-mono \
		ttf-fira-sans \
		ttf-opensans \
		ttf-twemoji-color \
		nerd-fonts-complete \
		xorg-fonts-alias

core/aur-helper: core/aur-helper/cower
	cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz" \
		&& tar -xvf pacaur.tar.gz \
		&& cd pacaur \
		&& makepkg -sri --noconfirm

core/aur-helper/cower: clean/tmp
	gpg --recv-keys 487EACC08557AD082088DABA1EB2638FF56C0C53 # Dave Reisner, cower maintainer
	mkdir -p tmp \
		&& cd tmp \
		&& curl -L -O "https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz" \
		&& tar -xvf cower.tar.gz \
		&& cd cower \
		&& makepkg -sri --noconfirm

# Setup Xorg and its basic drivers and tools.
#
# NOTICE: Isn't possible to eliminate DDX intel drivers yet as modesetting generic driver has
# heavy tearing under Thinkpad 460s Skylake Intel GPU.
#
# TODO: Do not forget to re-check this after Xorg updates, modesetting has better performance
# and less bugs than Intel's SNA AccellMethod.
#
# UPDATE: Well, actually using intel DDX drivers is problematic as the system simply freezes
# when RC6 powersaving is being used which makes it impracticable.
#
core/xorg: 
	sudo mkdir -p /etc/X11/xorg.conf.d
	$(MAKE) /etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/00-keyboard.conf
	- sudo pacman -S --noconfirm --needed \
		libva-intel-driver \
		xf86-input-libinput \
		xf86-video-intel \
		xorg-server \
		xorg-xinit \
		xorg-xrandr \
		xorg-xrdb

# System
#

system/power: /etc/modprobe.d/i915.conf
	sudo pacman -S --noconfirm \
		ethtool \
		powertop \
		rfkill \
		tlp \
		x86_energy_perf_policy
	sudo systemctl enable tlp.service tlp-sleep.service
	sudo systemctl start tlp.service tlp-sleep.service

system/sound: /etc/modprobe.d/blacklist.conf /etc/modprobe.d/snd_hda_intel.conf
	pacaur -S --noconfirm --needed \
		pulsemixer \
		pulseaudio \
		pulseaudio-bluetooth
	pulseaudio -D

system/bluetooth:
	sudo pacman -S --noconfirm --needed \
		bluez \
		bluez-utils
	sudo systemctl enable bluetooth.service
	sudo systemctl start bluetooth.service

system/fingerprint-auth:
	sudo pacman -S --noconfirm --needed \
		fprintd
	sudo sed -i "1s/^/auth	sufficient	pam_fprintd.so\n/" /etc/pam.d/system-local-login

# Device specific
#

device/x200: /etc/thinkfan.conf
	sudo pacaur -S --noconfirm --needed \
		acpi_call \
		libva-intel-driver-g45-h264 \
		tp_smapi

# Task utils
#

/etc/vconsole.conf: templates/etc/vconsole.conf
	sudo pacman -S --noconfirm terminus-font
	sudo cp ./templates/vconsole.conf /etc/vconsole.conf

/etc/modprobe.d/%: templates/etc/modprobe.d/*
	sudo cp templates/etc/modprobe.d/$* $@

/etc/%: templates/etc/*
	sudo cp templates/etc/$* $@

/etc/X11/xorg.conf.d/%.conf: templates/etc/X11/xorg.conf.d/*
	sudo cp templates/etc/X11/xorg.conf.d/$*.conf $@

~/.%: templates/dotfiles/*
	mkdir -p $(@D)
	$(macrocmd) \
		templates/dotfiles/$* \
		> $@

/etc/systemd/system/%: templates/etc/systemd/system/*
	sudo mkdir -p $(@D)
	$(macrocmd) \
		templates/etc/systemd/system/$* \
		| sudo dd of=$@

~/.bin/%: templates/dotfiles/bin/*
	mkdir -p $(@D)
	$(macrocmd) \
		templates/dotfiles/bin/$* \
		> $@
	chmod +x $@

clean/tmp:
	mkdir -p tmp
	rm -rf tmp/*
