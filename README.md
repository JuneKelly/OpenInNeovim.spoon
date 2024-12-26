# HammerSpoon - Open in Neovim

## Installation

Clone this repository to `~/.hammespoon/Spoons/OpenInNeovim.spoon`, like so...

```sh
git clone https://github.com/JuneKelly/OpenInNeovim.spoon ~/.hammerspoon/Spoons/OpenInNeovim.spoon
```

## Usage

### 1. Find the full path to `nvim`

```sh
command -v nvim
```

### 2. Start `nvim` with `--listen`, and a path to a pipe file

```sh
nvim --listen ~/.cache/nvim/server.pipe
```

You can make this easier by creating an alias, for example, in `zsh`:

```sh
alias nvim-server 'nvim --listen ~/.cache/nvim/server.pipe'
```

...or in `fish`:

```sh
alias --save nvim-server='nvim --listen ~/.cache/nvim/server.pipe'
```

### 3. Generate a secret token

An easy way to do this is by running `uuidgen` in the shell.

### 4. Configure OpenInNeovim, in Hammerspoon config file

Add the following to `~/.hammerspoon/init.lua`:

```lua
openInNeovim = hs.loadSpoon("OpenInNeovim")

openInNeovim.bind({
 nvimPath = "<Full path to nvim executable>",
 nvimServerPipePath = "< full path to nvim server pipe>",
 token = "<random token string>",
})
```

Quit and re-open Hammerspoon. Look in the Hammerspoon console, and you should see log lines indicating that OpenInNeovim has been loaded, and a URL handler has been bound:

```
2024-12-26 14:26:31: -- Loading Spoon: OpenInNeovim
2024-12-26 14:26:31: [OpenInNeovim] Binding to event 'openInNeovim'.
```
