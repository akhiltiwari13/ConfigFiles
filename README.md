# MY_DOT_FILES

- This repository has my **configuration files.**

- I use i3wm. Required dependencies: dunst, i3blocks, compton.

- As I use neovim as my primary text-editor/IDE, the idea behind this repository was to facilitate a quick setup on any workstation I may have to work on. It is assumed that existance of required external programs is a common understanding; programs such as LSP servers, any font family(some asthetic plugins may need special fonts) or other utilities such as ack & silversearcher.
- Following are some useful external tools.

  - [fzf](https://github.com/junegunn/fzf)
  - [ccls](https://github.com/MaskRay/ccls)
  - [clangd](https://clangd.llvm.org/)
  - [pyls](https://github.com/palantir/python-language-server)
  - [gitPython](https://gitpython.readthedocs.io/en/stable/)

- Process for setting up i3wm on a new Fedora setup requires the following installations before copying the dot-files at appropriate locations.
  sudo dnf install i3 i3status dmenu i3lock xbacklight feh conky compton dunst xrandr i3blocks
