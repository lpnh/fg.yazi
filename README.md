# fg.yazi

A Yazi plugin for searching file content or filenames using `ripgrep` with
`fzf` preview

> [!NOTE]
> The latest main branch of Yazi is required at the moment.
>
> Support shell: `bash`, `zsh` ,`fish` ,`nushell`

## Dependencies

- fzf
- ripgrep
- bat
- ripgrep-all (optional)

## Install

```bash
# Add the plugin
ya pack -a lpnh/fg

# Install plugin
ya pack -i

# Update plugin
ya pack -u
```

## Usage

This option uses `ripgrep` to output all the lines of all files, and then uses
`fzf` to fuzzy matching.

```toml
[[manager.prepend_keymap]]
on   = [ "f","g" ]
run  = "plugin fg"
desc = "find file by content (fuzzy match)"
```

The following option passes the input to `ripgrep` for a match search, reusing
the `rg` search each time the input is changed. This is useful for searching in
large folders due to increased speed, but it does not support fuzzy matching.

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

⚠️ EXPERIMENTAL ⚠️ This option uses `ripgrep-all` to output all the lines of all
files, and then uses `fzf` to fuzzy matching.

```toml
[[manager.prepend_keymap]]
on   = [ "f","a" ]
run  = "plugin fg --args='rga'"
desc = "find file by content (ripgrep-all)"
```
