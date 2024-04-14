# fg.yazi


https://github.com/DreamMaoMao/fg.yazi/assets/30348075/4b34ff25-800f-4250-b109-172f12a8b0ce


A Yazi plugin for rg search with fzf file preview

> [!NOTE]
> The latest main branch of Yazi is required at the moment.
> 
> Support shell: `bash`, `zsh` ,`fish` ,`nushell`

## Dependcy
- fzf
- ripgrep
- bat

## Install

```bash
git clone https://github.com/DreamMaoMao/fg.yazi.git ~/.config/yazi/plugins/fg.yazi
```

## Usage

```toml
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "find file by content"
```

```toml
[[manager.prepend_keymap]]
on   = [ "f","f" ]
run  = "plugin fg --args='fzf'"
desc = "find file by file name"
```
