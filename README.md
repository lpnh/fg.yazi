# fg.yazi

https://github.com/DreamMaoMao/fg.yazi/assets/30348075/4b34ff25-800f-4250-b109-172f12a8b0ce

A Yazi plugin for searching file content or filenames using `ripgrep` with `fzf` preview

> [!NOTE]
> The latest main branch of Yazi is required at the moment.
>
> Support shell: `bash`, `zsh` ,`fish` ,`nushell`

## Dependencies

- fzf
- ripgrep
- bat

## Install

```bash
git clone https://github.com/DreamMaoMao/fg.yazi.git ~/.config/yazi/plugins/fg.yazi
```

## Usage

This option uses `ripgrep` to output all the lines of all files, and then uses `fzf` to fuzzy matching.

```toml
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "find file by content (fuzzy match)"
```

The following option passes the input to `ripgrep` for a match search, reusing the `rg` search each time the input is changed. This is useful for searching in large folders due to increased speed, but it does not support fuzzy matching.

```toml
[[manager.prepend_keymap]]
on   = [ "f","G" ]
run  = "plugin fg --args='rg'"
desc = "find file by content (ripgrep match)"
```

```toml
[[manager.prepend_keymap]]
on   = [ "f","f" ]
run  = "plugin fg --args='fzf'"
desc = "find file by filename"
```
