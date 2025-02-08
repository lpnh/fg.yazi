# fg.yazi

> [!NOTE]
> this plugin is only guaranteed to be compatible with Yazi nightly

a Yazi plugin that integrates `fzf` with `bat` preview for `rg` search and
`rga` preview for `rga` search

**supports**: `bash`, `fish`, and `zsh`

## dependencies

- [bat](https://github.com/sharkdp/bat)
- [fzf](https://junegunn.github.io/fzf/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [ripgrep-all](https://github.com/phiresky/ripgrep-all) (optional)

## installation

```sh
ya pack -a lpnh/fg
```

## usage

### plugin args

this plugin supports two arguments:

- `rg`:
   - `rg` search
   - `bat` preview
   - `rg` match (default)
   - `fzf` match (alternative)

- `rga`:
   - `rga` search
   - `rga` preview
   - `rga` match

below is an example of how to configure both in the
`~/.config/yazi/keymap.toml` file:

```toml
[[manager.prepend_keymap]]
on = ["f", "r"]
run = "plugin fg rg"
desc = "Search file by content (rg)"

[[manager.prepend_keymap]]
on = ["f", "a"]
run = "plugin fg rga"
desc = "Search file by content (rga)"
```

### fzf binds

this plugin provides three custom `fzf` keybindings:

- `<ctrl-w>`: toggle the preview window size (65%, 80%)
- `<ctrl-\>`: toggle the preview window position (top, right)
- `<ctrl-f>`: toggle the matching method (rg, fzf)

## theme

the default `fzf` colors can be customized using the `FZF_DEFAULT_OPTS` env
variable. for an example, check out the [Catppuccin's
repo](https://github.com/catppuccin/fzf?tab=readme-ov-file#usage)

## acknowledgments

@vvatikiotis for the `rga`
[integration](https://github.com/lpnh/fg.yazi/pull/1)

this is a derivative of @DreamMaoMao's `fg.yazi` plugin. consider using the
original one instead; you can find it at
<https://gitee.com/DreamMaoMao/fg.yazi>, with a mirror available at
<https://github.com/DreamMaoMao/fg.yazi>
