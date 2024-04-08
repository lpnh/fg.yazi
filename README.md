# fg.yazi

A Yazi plugin for rg search with fzf file preview

> [!NOTE]
> The latest main branch of Yazi is required at the moment.

## Dependcy
- fzf
- ripgrep
- bat
- fish

## Install

```bash
git clone https://github.com/DreamMaoMao/fg.yazi.git ~/.config/yazi/plugins/fg.yazi
chmod +x ~/.config/yazi/plugins/fg.yazi/rfzf
sudo ln -s ~/.config/yazi/plugins/fg.yazi/rfzf /usr/local/bin/rfzf
```

## Usage

```toml
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "rg search"
```

