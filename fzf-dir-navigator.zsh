# Please read the README.md file @ https://www.github.com/KulkarniKaustubh/fzf-dir-navigator
# for all relevant information.

# ---------------------------------------------------------------------------
#                                  DEFAULTS                                  
# ---------------------------------------------------------------------------

# C-f: Brings up the global search window on the terminal.
# C-v: Brings up the current directory search window on the terminal.
# C-r: Resets the history and brings up the global search window on the terminal.
# Alt-left: Goes to the previous working directory. (similar to `prevd` in `fish`)
# Alt-right: Goes to the next working directory. (similar to `nextd` in `fish`)
# NOTE: If Alt-left or Alt-right is spammed, it will keep cycling through the list
#       of directories visited.

# ----------------------------------------------------------------------------

# Sourcing the fzf-dir-navigator-config shell script.
dir="$(dirname "$(realpath "$0")")"
source "${dir}/fzf-dir-navigator.conf"

# Make `cd` use `pushd`
setopt AUTO_PUSHD

fzf-dir() {
    # ---------------------------------------------------------------------------
    #                            PRE-REQUISITE CHECKS                            
    # ---------------------------------------------------------------------------

    # `fzf` is a must have for this to work!
    if ! command -v "fzf" &> /dev/null; then
        echo "Install fzf for this feature to work."
        return -1
    fi

    # If `fd` does not exist, the `find` command will be used
    # to look for directories.
    # NOTE: If you are switching from `find` to `fd`, please use C-r
    # to reset the history.
    # "exclusions" taken from the .conf file.
    if ! command -v "fd" &> /dev/null; then
        local options=" -type d"

        if (( ${#exclusions[@]} != 0 )); then
            options+=" \("

            for exclude in "${exclusions[@]:0:${#exclusions[@]}-1}"
            do
                options+=" -name $exclude -o"
            done

            options+=" -name ${exclusions[@]: -1} \) -prune -o -type d -print"
        fi

        options+=" | sed '1d'"

        local home_find_cmd="find \"$HOME\""$options
        local pwd_find_cmd="find \"$PWD\""$options
    else
        local options=" -Ha --type directory"

        for exclude in "${exclusions[@]}"
        do
            options+=" --exclude $exclude"
        done

        local home_find_cmd="fd . \"$HOME\""$options
        local pwd_find_cmd="fd . \"$PWD\""$options

    fi

    # If `tree` does not exist, the `ls` command will be used
    # for the dir preview.
    if ! command -v "tree" &> /dev/null; then
        local preview_cmd="ls -a"
    else
        local preview_cmd="tree -a -C -L 1"
    fi

    # Taken from the .conf file
    local dir_histsize=$dir_histsize
    local history_dir=$(dirname $history_file)

    # Create history file if it does not exist.
    if [ ! -f $history_file ]; then
        if [ ! -d $history_dir ]; then
            mkdir -p $history_dir
        fi
        touch $history_file
    fi

    # Prompt under which the history will be show on the terminal.
    local history_prompt="---- Recent History ----"
    local history_cmd="\tac \"$history_file\" && echo \"\n$history_prompt\n\""

    # Replace $HOME with a "~" and $PWD with a "." for UI eye-candy.
    local home_sed_cmd="sed 's|$HOME|~|g'"
    local pwd_sed_cmd="sed 's|$PWD|\.|g'"

    home_find_cmd="$home_find_cmd | ($history_cmd && \cat) | $home_sed_cmd"
    pwd_find_cmd="$pwd_find_cmd | $pwd_sed_cmd"

    local home_preview_cmd="echo {} | sed 's|~|$HOME|g' | tr '\n' '\0' | xargs -0 $preview_cmd | head -n 20"
    local pwd_preview_cmd="echo {} | sed 's|^\.|$PWD|g' | tr '\n' '\0' | xargs -0 $preview_cmd | head -n 20"

    local dir

    if [[ $PWD == $HOME ]]; then
        dir=$(eval $home_find_cmd | awk 'NF==0{print;next} !seen[$0]++' |
                  fzf --height=60% \
                      --header="C-f : search ~ | C-r : reset history" \
                      --border "top" \
                      --prompt="Search for a directory > " \
                      --bind "change:first" \
                      --bind "ctrl-f:change-preview($home_preview_cmd)+reload:$home_find_cmd" \
                      --bind "ctrl-r:execute-silent(rm $history_file && touch $history_file)+reload:$home_find_cmd" \
                      --preview "$home_preview_cmd" \
                      --preview-window 35%,border-left \
              )
    else
        dir=$(eval $pwd_find_cmd | awk 'NF==0{print;next} !seen[$0]++' |
                  fzf --header="C-f : search ~ | C-v : search . | C-r : reset history" \
                      --height=60% \
                      --border "top" \
                      --prompt="Search for a directory > " \
                      --bind "change:first" \
                      --bind "ctrl-f:change-preview($home_preview_cmd)+reload:$home_find_cmd" \
                      --bind "ctrl-v:change-preview($pwd_preview_cmd)+reload:$pwd_find_cmd" \
                      --bind "ctrl-r:execute-silent(rm $history_file && touch $history_file)+reload:$home_find_cmd" \
                      --preview "$pwd_preview_cmd" \
                      --preview-window 35%,border-left \
              )
    fi

    # Again replace $PWD with a "." and $HOME with a "~" for changing dir.
    dir=$(echo "$dir" | sed -e "s|^\.|$PWD|g" -e "s|~|$HOME|g")

    # Do nothing if the history prompt is selected.
    if [[ $dir == $history_prompt ]] || [ -z "$dir" ]; then
        zle redisplay
        return 1
    fi

    pushd $dir &>/dev/null

    # If pushd gives an error for the selected directory, remove it from
    # history if it exists.
    if [[ $? == 1 ]]; then
        zle redisplay
        echo "Directory does not exist. Removing this from the directory history."
        awk "\$0 != \"$dir\"" $history_file > "$history_dir/temp" && mv "$history_dir/temp" $history_file
        return 1
    fi

    # Delete existing directory from history file if same as current directory
    awk "\$0 != \"$dir\"" $history_file > "$history_dir/temp" && mv "$history_dir/temp" $history_file

    local curr_dir_histsize=$(wc -l $history_file | awk '{ print $1 }')

    # Remove the oldest entry in history once history size is exceeded.
    if [ $curr_dir_histsize -ge $dir_histsize ]; then
        sed -i '1d' $history_file
    fi
    echo $dir >> $history_file

    # precmd functions are the functions/hooks run everytime to reset the prompt
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt

    return $?
}

zle -N fzf-dir
bindkey "^F" fzf-dir

prevd() {
    pushd +1 >/dev/null 2>&1

    # precmd functions are the functions/hooks run everytime to reset the prompt
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt

    return $?
}

zle -N prevd
bindkey "^[[1;3D" prevd

nextd() {
    pushd -0 >/dev/null 2>&1

    # precmd functions are the functions/hooks run everytime to reset the prompt
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt

    return $?
}

zle -N nextd
bindkey "^[[1;3C" nextd
