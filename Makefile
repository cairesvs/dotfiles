# Configuration
#
# Variables used in m4 templates
user-email = cairesvs@gmail,com
user-name = caires
user-nick = $(USER)
colorscheme = colorschemes/base16-light

# Template parsing command
macrocmd = m4 \
	   -Duser_name="$(user-name)" \
	   -Duser_nick="$(user-nick)" \
	   -Duser_email="$(user-email)" \
	   macros.m4 \
	   $(colorscheme).m4

# Userspace

dotfiles = \
	~/.gitconfig \
	~/.gitignore \
	~/.config/user-dirs.dirs \
	~/.compton.conf \
	~/.ctags \
	~/.bashrc \
	~/.bash_profile \
	~/.Xresources \
	~/.Xresources.d/colorscheme \
	~/.Xresources.d/urxvt \
	~/.zshrc

user/simple: $(dotfiles)
	echo "dotfiles <3"

user/desktop: $(dotfiles) \
	applications/locker \
	applications/ranger \
	applications/urxvt \
	applications/zathura \
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

user/company: applications/dev-env
	sudo pacman -S --noconfirm --needed zsh \
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Applications
#

applications/vscode:
	pacaur -S --noconfirm --needed \
		visual-studio-code-bin 

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

applications/dunst: ~/.config/dunst/dunstrc
	pacaur -S --noconfirm --needed \
		dunst-git
	systemctl --user enable dunst.service
	systemctl --user start dunst.service

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

applications/locker: 
	sudo pacman -S --noconfirm --needed \
		maim \
		slock

applications/docker:
	sudo pacman -S --noconfirm --needed \
		docker \
		lxc
	sudo gpasswd -a $(USER) docker

applications/dwm: 
	git clone https://git.suckless.org/dwm 
	cp config.h dwm/config.h
	cd dwm/ && sudo make clean install

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

/etc/vconsole.conf: templates/root/etc/vconsole.conf
	sudo pacman -S --noconfirm terminus-font
	sudo cp ./templates/vconsole.conf /etc/vconsole.conf

/etc/modprobe.d/%: templates/root/etc/modprobe.d/*
	sudo cp templates/root/etc/modprobe.d/$* $@

/etc/%: templates/root/etc/*
	sudo cp templates/root/etc/$* $@

/etc/X11/xorg.conf.d/%.conf: templates/root/etc/X11/xorg.conf.d/*
	sudo mkdir -vp /etc/X11/xorg.conf.d
	sudo cp templates/root/etc/X11/xorg.conf.d/$*.conf $@

~/.%: templates/home/*
	mkdir -p $(@D)
	$(macrocmd) \
		templates/home/$* \
		> $@

/etc/systemd/system/%: templates/root/etc/systemd/system/*
	sudo mkdir -p $(@D)
	$(macrocmd) \
		templates/etc/systemd/system/$* \
		| sudo dd of=$@

~/.bin/%: templates/home/bin/*
	mkdir -p $(@D)
	$(macrocmd) \
		templates/home/bin/$* \
		> $@
	chmod +x $@

clean/tmp:
	mkdir -p tmp
	rm -rf tmp/*
