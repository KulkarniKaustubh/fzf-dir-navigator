# fzf-dir-navigator

This is a directory navigation tool for zsh. It uses `fzf` to provide an interactive TUI.

This plugin allows the user to switch to any directory from anywhere and to anywhere. It also maintains a history of recently visited directories. Additionally, you can use hotkeys to move back and forth between directories in the shell session.

## Pre-requisites

- `fzf`
- `fd` (falls back to `find`)
- `tree` (falls back to `ls`) - this is for the preview of the directory in the `fzf` window.

## Keybindings

- `C-f`: Calls the `fzf-dir` widget and brings up the search window on the terminal.
- `M(Alt)-left`: Goes to the previous working directory. (similar to `prevd` in `fish`)
- `M(Alt)-right`: Goes to the next working directory. (similar to `nextd` in `fish`)

## Configuration


There are only 2 things configurable easily (unless you can hack around with `fzf`'s options, then it is quite configurable).

- `dir_histsize`: Number of recent directories to store and display.
- `history_file`: File to store the history.

You can find this in [this file](https://www.github.com/KulkarniKaustubh/fzf-dir-navigator/blob/main/fzf-dir-navigator.zsh).

```sh
# ---------------------------------------------------------------------------
#                                CONFIGURATION                               
# ---------------------------------------------------------------------------

# Set the history size to display on your terminal.
local dir_histsize=10

# Default history file where all the history will be stored.
local history_file="$HOME/.local/share/zsh/widgets/fzf-dir-navigator-history"

# ----------------------------------------------------------------------------

