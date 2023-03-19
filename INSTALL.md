# Installation

- [Antigen](#antigen)
- [Oh My Zsh](#oh-my-zsh)
- [Manual](#manual)

## Antigen

1. Add the following to your `~/.zshrc`.
    ```sh
    antigen bundle KulkarniKaustubh/fzf-dir-navigator
    ```

2. Start a new terminal session or `source ~/.zshrc`

## Oh My Zsh

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

## Manual

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/fzf-dir-navigator`.

    ```sh
    git clone https://www.github.com/KulkarniKaustubh/fzf-dir-navigator ~/.zsh/fzf-dir-navigator
    ```

2. Add the following to your `.zshrc`:

    ```sh
    source ~/.zsh/fzf-dir-navigator/fzf-dir-navigator.zsh
    ```

3. Start a new terminal session or `source ~/.zshrc`

