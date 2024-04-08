# fg.yazi



https://github.com/DreamMaoMao/fg.yazi/assets/30348075/aff8866b-d5df-4ba3-9cd4-0ec0e8869385



A Yazi plugin for rg search with fzf file preview

> [!NOTE]
> The latest main branch of Yazi is required at the moment.
> only support fish now,if you use other shell, change the rfzf scipts

## Dependcy
- fzf
- ripgrep
- bat
- fish

## Install

```bash
git clone https://github.com/DreamMaoMao/fg.yazi.git ~/.config/yazi/plugins/fg.yazi
chmod +x ~/.config/yazi/plugins/fg.yazi/rfzf

# fish
sudo ln -s ~/.config/yazi/plugins/fg.yazi/rfzf_fish /usr/local/bin/rfzf

# zsh or bash
sudo ln -s ~/.config/yazi/plugins/fg.yazi/rfzf_bash /usr/local/bin/rfzf

```

## Usage

```toml
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "rg search"
```

