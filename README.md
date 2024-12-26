# HammerSpoon - Open in Neovim

Set up a URL event to open a file in neovim. Can be used with [phoenix-live-reload](https://github.com/phoenixframework/phoenix_live_reload) to jump to the definition (or caller) of a phoenix live-view component.

## Installation

Clone this repository to `~/.hammespoon/Spoons/OpenInNeovim.spoon`, like so...

```sh
git clone https://github.com/JuneKelly/OpenInNeovim.spoon ~/.hammerspoon/Spoons/OpenInNeovim.spoon
```

## Usage

### 1. Find the full path to `nvim`

```sh
command -v nvim
# => /opt/homebrew/bin/nvim
```

### 2. Start `nvim` with `--listen`, and a path to a pipe file

```sh
nvim --listen ~/.cache/nvim/server.pipe
```

You can make this easier to do repeatedly by creating an alias, for example, in `zsh`:

```sh
alias nvim-server 'nvim --listen ~/.cache/nvim/server.pipe'
```

...or in `fish`:

```sh
alias --save nvim-server='nvim --listen ~/.cache/nvim/server.pipe'
```

### 3. Generate a secret token

An easy way to do this is by running `uuidgen` in the shell.

```sh
uuidgen
# => 07048977-9...
```

### 4. Configure OpenInNeovim, in Hammerspoon Config

Add the following to `~/.hammerspoon/init.lua`:

```lua
openInNeovim = hs.loadSpoon("OpenInNeovim")

openInNeovim.bind({
 nvimPath = "<full path to nvim executable>",
 nvimServerPipePath = "<full path to nvim server pipe>",
 token = "<random token string>",
})
```

Quit and re-open Hammerspoon. Look in the Hammerspoon console, and you should see log lines indicating that OpenInNeovim has been loaded, and a URL handler has been bound:

```
2024-12-26 14:26:31: -- Loading Spoon: OpenInNeovim
2024-12-26 14:26:31: [OpenInNeovim] Binding to URL event 'openInNeovim'.
```

## 5. Configure Phoenix Live Reload to Trigger this URL Event

```
PLUG_EDITOR = 'hammerspoon://openInNeovim?token=<TOKEN>&file=__FILE__&line=__LINE__'
```

Now, when you hold `d` and click a phoenix live-view component in the browser, it _should_ open the component definition in neovim, and show a notification to that effect. If not, check the hammerspoon logs.

## URL Parameters

- `file`: path to the file to open
- `line`: line number to open
- `token`: (optional) secret token to check against `config.token`

## Configuration

`openInNeovim.bind` takes the following configuration options:

- `nvimPath`: (required) full path to the `nvim` executable.

- `nvimServerPipePath`: (required) full path to the `nvim` server pipe file.

- `token`: (optional, default `nil`) if present, the URL _must_ include this token as a query parameter `token`. If the URL does not contain this parameter, or it does not match, then the error will be shown in a notification

- `focusTerminalApp`: (optional, default `nil`) if present, bring this app to the foreground after the file has been opened. Must be the name of a MacOS app, like `"iTerm2"`

- `eventName`: (optional, default `"openInNeovim"`)

- `translateRootPath`: (optional, default `nil`) a table with two fields: `from`, and `to`. If non-nil, the file path is altered to replace the segment matching `from` at the start, with to string `to`. Useful if your phoenix server runs in a docker environment where it's filesystem is different from the host where your `nvim` editor is running.

Here's an example using all of the configuration options:

```lua
openInNeovim = hs.loadSpoon("OpenInNeovim")

openInNeovim.bind({
 nvimPath = "/opt/homebrew/bin/nvim",
 nvimServerPipePath = "/Users/somebody/.cache/nvim/server.pipe",
 token = "a_dreadful_secret",
 focusTerminalApp = "iTerm2",
  eventName = "customOpenInNeoVimForSomeReason",
  translateRootPath = {
    from = "/app/inside/docker/",
    to = "/Users/somebody/projects/cool-web-app/"
  }
})
```
