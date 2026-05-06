# todos

## future changes

- [] ~~migrate to git-lfs to store wallpapers. make wallpapers high quality but limited.~~
- [x] port catppuccin wallpapers to my config from this system and link both wallpapers set in my omarchy.
- [x] is there a way to enable tokyonight-day theming in omarhcy workstation? => using dayfox instead.

- [x] tmux setup => no key conficts | tpm plugins | seamless ghostty<->tmux<->neovim integration | vim like motion/keybindings etcs but don't need to overkill.
- [x] neovim sync

## last strech

- [x] port more configs like opencode/ claudecode/ clangd / ccls (add them to configfiles and stow them as well.)
- [x] mark program's and configs that could be / should be ported / symlinked on my mac air for seamless experience.
- [-] identify more config updates for omarchy defaults and update them and compare changes. I can do that manually but need to identify how and what programs to update.
- [x] how about neovim/tmux navigator plugin? would that be useful in this scenaro?
- [x] update readme... add relevant info about keymap detection and env.d files. also, this config setup is used accross omarhcy and m1 mac air so I need to focus on both m/c.
  - [x] multi-machine focus → Cross-Platform Compatibility table in README (`b190652`)
  - [x] document `omarchy-overrides/.config/bin/keybind-audit` usage (`f44b35b`)
  - [x] document `omarchy-overrides/.config/environment.d/00-omarchy-overrides.conf` PATH-shim mechanism (`f44b35b`)
- [x] fix and link .ssh/config as well... 1. port current ~/.ssh/config here in place of the current .ssh configs and make the changes.
- [-] port and link my .bashrc here... similarly do for my mac's .zshrc(will do later on from that device).
  - [x] .bashrc ported as new bash/ stow package (`44f0ba7`)
  - [] mac .zshrc — pending (will do from mac air)
- [] yazi... I like yazi and need it configured with tokyonight and dayfox and catppuccin / latte themes for dark and light themes respectively and any other plugin/setting to enhance my experience
- [x] fish: link it AND onboard omarchy's default fish configs here first (vendor from `~/.local/share/omarchy/default/fish/` or wherever omarchy ships its fish defaults), then stow.
  - stowed as-is — omarchy doesn't actually ship fish defaults (premise was off); the existing repo `config.fish` + `fish_variables` are now linked into ~/.config/fish/, alongside the live `conf.d/uv.env.fish` (left as real file)
- [x] port/merge configs from the current system into this file and then have it stowed. => alacritty | devbox | eza | fastfetch | ghostty gitconfig/git | lazydocker | lazygit | mise | obsidian | reipgrep-all | tmux
  - new packages added: mise, ripgrep-all (`4a33a3a`)
  - gitconfig: added `ignore` file (`4a33a3a`); `config` + `config-work` were already stowed
  - alacritty, fastfetch, ghostty, lazydocker, lazygit: already stowed since May 4 (no-op)
  - tmux: already stowed (renamed from omtmux in `4a1e012`)
  - skipped: devbox + eza (empty live dirs); obsidian (75MB Electron runtime, not config)
  - cleanup along the way: ghostty/config.ghostty (0-byte cruft), fastfetch/config.jsonc.bak.\* (stale backups) deleted
- [x] for configs that aren't used, we need to move them to dumpyard/ dir. like i3/crush (what even is this?) | karbiner(i didn't like this experiment on my mac) | dunst (from my old arch days) | i3status | neofetch as I prefer fastfetch in omarchy | rename omtmux to tmux because we don't use oh my tmux anymore (full `git mv` + restow, not a symlink shim) | rectangle | sioyek(remove it's current symlink) | ticker | (`4a1e012`)
  - 9 packages dumpyarded (i3, i3status, dunst, crush, karabiner, neofetch, rectangle, sioyek, ticker); old flat-layout archives in dumpyard/{i3,i3status,dunst} replaced with stow-layout versions
  - omtmux → tmux: `git mv` + restow done; doc references in CLAUDE.md/AGENTS.md/KEYBINDINGS.md/README.md updated
  - crush turned out to be Charm's `crush` AI TUI assistant; user didn't recognise it
- [x] keep track of all programs being linked across all 3 m/c omarchy-tp | macair | uburemote
  - source of truth: `scripts/bootstrap.sh` per-profile package arrays (UBUNTU_PKGS / OMARCHY_PKGS / MACAIR_PKGS) (`708c893`)
  - quick reference table in README "Bootstrapping a new machine" section
- [x] clangd/ccls have stupid old defaults that don't reflect this system or a good global setting.. critique and remove them. verify with me. I'd rather have a link to an empty config than a detrimental/stupid config. (`e79ef65`)
  - clangd/config.yaml truncated to empty placeholder (was hardcoding apt gcc 9-12 + LLVM 11/14)
  - clangd/.clangd deleted (was hardcoding /home/akhil/files/projects/platform/... from old work box)
  - ccls/config deleted (same broken paths)
  - ccls/.ccls simplified (kept clang/C++20/C11/usr-include; dropped `-stdlib=libc++` since libstdc++ is the Linux default)

## ubuntu-ready stretch (the final test)

- [x] `scripts/bootstrap.sh <profile>` — takes a profile arg (`ubuntu` | `omarchy` | `macair`), stows the right subset of packages for that machine, optionally installs the minimum deps. Replaces stowing-by-hand on a fresh box. (`708c893`)
  - 3 profiles: ubuntu (18 pkgs), omarchy (29 pkgs), macair (21 pkgs)
  - --dry-run + --list flags
  - special-cases lazyvim's extra `nvim/` nesting via `stow -d <repo>/lazyvim nvim`
  - skips deps install (use scripts/deps_install.sh for that) and skips `stow` itself (chicken-and-egg; manual `stow stow` first)
- [] verify on uburemote — actually clone + run bootstrap on the new ubuntu m/c and confirm everything works end-to-end. The real test of all the refactoring above.
- [] (discovered, not in original list) lazyvim drift on this omarchy box: `~/.config/nvim/.neoconf.json` and `~/.config/nvim/.gitignore` are real files, not symlinks. Bootstrap dry-run reports the conflict. Fix: `rm` both, then `stow -d ~/Work/projects/quomptrade/configfiles/lazyvim nvim`.
