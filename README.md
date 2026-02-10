# dotfiles

<img width="888" alt="image" src="https://user-images.githubusercontent.com/538584/215024100-863d58c8-c35b-4bcc-be75-a8ba39421d53.png">

<img width="1307" alt="image" src="https://user-images.githubusercontent.com/538584/215228825-d056478e-d8a4-46eb-85a8-f7e500d6736f.png">

## Install

```bash
git clone git@github.com:xissy/dotfiles.git ~/dev/xissy/dotfiles
cd ~/dev/xissy/dotfiles
./scripts/install.sh
```

## Uninstall

Removes symlinks and restores backed-up originals:

```bash
./scripts/uninstall.sh
```

## Structure

```
dotfiles/
├── scripts/
│   ├── install.sh      # create symlinks (backs up existing files)
│   ├── uninstall.sh    # remove symlinks (restores from backup)
│   └── links.sh        # source -> target mapping
├── zshrc               # ~/.zshrc
├── vimrc               # ~/.vimrc
├── tmux.conf           # ~/.tmux.conf
├── ghostty.conf        # ~/Library/Application Support/com.mitchellh.ghostty/config
├── karabiner.json      # ~/.config/karabiner/karabiner.json
├── config.omp.json     # ~/.config.omp.json
├── tool-versions       # ~/.tool-versions
├── default-python-packages  # ~/.default-python-packages
└── Brewfile
```
