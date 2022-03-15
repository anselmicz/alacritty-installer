#!/bin/bash
# adopted from https://github.com/alacritty/alacritty
# GPL v3 where it applies

############################
### CONFIG
## colors
#
color_ok='\033[0;32m'
color_pending='\033[1;33m'
color_end='\033[0m'
#
## functions
pending ()
{
        echo -e "${color_pending}$@${color_end}"
}
#
okay ()
{
        echo -e "${color_ok}[OK]${color_end}"
}
#
############################
# Debian clean install

pending "Installing system dependencies..."
sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 desktop-file-utils && okay || exit 1

# install rustup
pending "Installing Rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > .rustup.tmp && chmod +x .rustup.tmp || exit 2
sh .rustup.tmp -y && okay && rm .rustup.tmp || exit 3
source $HOME/.cargo/env

pending "Verifying Rustup..."
rustup override set stable || exit 4
rustup update stable && okay || exit 5

pending "Downloading Alacritty..."
git clone https://github.com/alacritty/alacritty.git && cd alacritty || exit 6

# building
pending "Building Alacritty..."
cargo build --release && okay || exit 7

# terminfo
pending "Setting up terminfo..."
infocmp alacritty || ( sudo tic -xe alacritty,alacritty-direct extra/alacritty.info && infocmp alacritty && okay || exit 8 )

pending "Creating desktop entry..."
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop && okay || exit 9
sudo update-desktop-database

pending "Creating man page..."
sudo mkdir -p /usr/local/share/man/man1
# rewrite this shit!
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null && okay || exit 10

pending "Adding bash completion..."
mkdir -p ~/.bash_completion_files
cp extra/completions/alacritty.bash ~/.bash_completion_files/alacritty

# the folder was originally called '.bash_completion', but this causes problems with default configs in /etc, which source file '.bash_completion' if it exists
grep -qxF "source ~/.bash_completion_files/alacritty" ~/.bashrc || \
	(echo "" >> ~/.bashrc; echo "# Alacritty bash completion" >> ~/.bashrc; echo "source ~/.bash_completion_files/alacritty" >> ~/.bashrc)
okay

pending "Creating sensible config file at ~/.config/alacritty..."
mkdir -p ~/.config/alacritty
cp -f ../alacritty.yml ~/.config/alacritty/alacritty.yml && okay || exit 11

pending "Cleaning up..."
cd ../ && yes | rm -r alacritty || exit 12
rustup self uninstall -y && okay || exit 13
yes | rm -r $HOME/.cargo || exit 14

echo ""
pending "Installation complete."
echo ""
