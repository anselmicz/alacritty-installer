Alacritty is now packaged in Debian; therefore, I have no use for this project anymore.

# alacritty-installer
Installation script for Alacritty - a GPU accelerated, higly customizable terminal emulator.

Adopted from [Alacritty](https://github.com/alacritty/alacritty).

## Differences from the Alacritty INSTALL instructions

* fully automates deployment process on a Debian GNU/Linux system
  * fixes a problem with the `.bash_completion` folder having the same name as a directory which is being sourced by default in `/etc`
  * includes sensible defaults
  * removes `rustup` from the system upon completion

## Usage

```
sudo apt update && sudo apt upgrade -y
git clone https://github.com/anselmicz/alacritty-installer.git
cd alacritty-installer/
chmod +x alacritty.sh && ./$_
cd - && rm -rf alacritty-installer/
```
