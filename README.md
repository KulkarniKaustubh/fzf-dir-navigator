# fzf-dir-navigator

This is a directory navigation tool for zsh. It uses `fzf` to provide an interactive TUI.

This plugin allows the user to switch to any directory from anywhere and to anywhere. It also maintains a history of recently visited directories. Additionally, you can use hotkeys to move back and forth between directories in the shell session.

Here is a demo:

https://user-images.githubusercontent.com/55317079/226093381-87d26d2d-8845-4627-8ce5-4d93be671e31.mp4

## Installation

Refer [INSTALL.md](https://www.github.com/KulkarniKaustubh/fzf-dir-navigator/blob/main/INSTALL.md)

## Pre-requisites

- `fzf`
- `fd` (falls back to `find`)
- `tree` (falls back to `ls`) - this is for the preview of the directory in the `fzf` window.

## Keybindings

- `C-f`: Brings up the global search window on the terminal.
- `C-v`: Brings up the current directory search window on the terminal.
- `C-r`: Resets the recent directory history and brings up the global search window on the terminal.
- `M(Alt)-left`: Goes to the previous working directory. (similar to `prevd` in `fish`)
- `M(Alt)-right`: Goes to the next working directory. (similar to `nextd` in `fish`)

## Configuration

Update: There is a new "config" file now where some values can be tweaked.
- `dir_histsize`: Number of recent directories to store and display.
- `history_file`: File to store the history.
- `exclusions`: The directories to exclude while using this widget.

You can find this in [this file](https://www.github.com/KulkarniKaustubh/fzf-dir-navigator/blob/main/fzf-dir-navigator.conf).

## Bugs and Features

Please feel free to open an issue for any bugs encountered or feature requests you may have.
