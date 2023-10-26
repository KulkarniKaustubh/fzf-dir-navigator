# fzf-dir-navigator

This is a directory navigation tool for zsh. It uses `fzf` to provide an interactive TUI.

This plugin allows the user to switch to any directory from anywhere and to anywhere. It also maintains a history of recently visited directories. Additionally, you can use hotkeys to move back and forth between directories in the shell session.

Here is a demo:

https://user-images.githubusercontent.com/55317079/226093381-87d26d2d-8845-4627-8ce5-4d93be671e31.mp4

## Pre-requisites

- `fzf`
- `fd` (falls back to `find`, but `fd` highly recommended.)
- `tree` (falls back to `ls`) - this is for the preview of the directory in the `fzf` window.

Specific to MacOS:
- This plugin uses the `tac` command which is not available on macOS by default. It can be installed using `brew install coreutils`.
- Access must be given to access folders on the system since the tool searches for all directories in `/Users/<username/`.
- In the [configuration](#Configuration), there is an instruction to add the `os` option to the config file. Please set that to `os="mac"`.

## Installation

- [Antigen](#antigen)
- [Oh My Zsh](#oh-my-zsh)
- [Manual](#manual)

### Antigen

1. Add the following to your `~/.zshrc`.
    ```sh
    antigen bundle KulkarniKaustubh/fzf-dir-navigator
    ```

2. Start a new terminal session or `source ~/.zshrc`

### Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

    ```sh
    git clone https://www.github.com/KulkarniKaustubh/fzf-dir-navigator ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-dir-navigator
    ```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

    ```sh
    plugins=( 
        # other plugins...
        fzf-dir-navigator
    )
    ```

3. Start a new terminal session or `source ~/.zshrc`

### Manual

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/fzf-dir-navigator`.

    ```sh
    git clone https://www.github.com/KulkarniKaustubh/fzf-dir-navigator ~/.zsh/fzf-dir-navigator
    ```

2. Add the following to your `.zshrc`:

    ```sh
    source ~/.zsh/fzf-dir-navigator/fzf-dir-navigator.zsh
    ```

3. Start a new terminal session or `source ~/.zshrc`

## Keybindings

Below are the set of default keybindings and the actions they perform:

| Default Keybinding | Action
| :-----: | -----
| <kbd>Ctrl</kbd><kbd>f</kbd> | When in the `$HOME` folder, it brings up the global search window on the terminal and the directory history. If you are inside a different folder, it searches folders inside the current folder. Upon pressing <kbd>Ctrl</kbd><kbd>f</kbd> again, it brings back the global search window.
| <kbd>Ctrl</kbd><kbd>v</kbd> | Brings back the current directory search window on the terminal if you are searching globally.
| <kbd>Ctrl</kbd><kbd>r</kbd> | Resets the recent directory history and brings up the global search window on the terminal.
| <kbd>Alt</kbd><kbd>←</kbd> | Goes to the previous working directory. (similar to `prevd` in `fish`)
| <kbd>Alt</kbd><kbd>→</kbd>|Goes to the next working directory. (similar to `nextd` in `fish`)

## Configuration

There is a default [config](https://www.github.com/KulkarniKaustubh/fzf-dir-navigator/blob/main/fzf-dir-navigator.conf) file where some values can be tweaked.
To make your own config file, please copy this file and rename it as `fzf-dir-navigator-custom.conf`. The plugin will automatically use this config file or fall back to the default config file.

```sh
cp /path/to/cloned/repo/fzf-dir-navigator.conf /path/to/cloned/repo/fzf-dir-navigator-custom.conf
```

| Option | Description | Default
| :-----: | ----- | -----
| `dir_histsize` | Number of recent directories to store and display. | `10`
| `history_file` | File to store the history.| `$HOME/.local/share/zsh/widgets/fzf-dir-navigator-history`
| `exclusions` |The directories to exclude while using this widget. | ( ".git" "node_modules" ".venv" "\_\_pycache\_\_" ".vscode" ".cache" )
| `search_home` | Keybinding used to search the `$HOME` directory. If you are changing the `search_home` keybinding, please be sure to add it to your `.zshrc` file as well. For example, if you are changing it to <kbd>ctrl-p</kbd>, add `bindkey "^P" fzf-dir-navigator` to your `.zshrc` after sourcing the plugin. Otherwise the keybinding to open the plugin on the terminal would still remain <kbd>ctrl-f</kbd>, and <kbd>ctrl-p</kbd> would work only after the plugin is open. | <kbd>ctrl-f</kbd>
| `search_pwd` | Keybinding used to search the `$PWD` directory. | <kbd>ctrl-v</kbd>
| `reset_history` | Keybinding used to reset the directory history. | <kbd>ctrl-r</kbd>
| `os` | To set which OS is being used. | The default assumes Linux and does not need a value. If you have a Mac, set `os="mac"`.

## Bugs and Features

Please feel free to open an issue for any bugs encountered or feature requests you may have.
