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

# Sourcing the fzf-dir-navigator.conf shell script.
# If a custom config exists, it will use that, else it will use the default.
dir="$(dirname "$(realpath "$0")")"
source "${dir}/fzf-dir-navigator.conf"
source "$dir/fzf-dir-navigator-custom.conf" 2> /dev/null

# Make `cd` use `pushd`
setopt AUTO_PUSHD

function run-precmd() {
    # precmd functions are the functions/hooks run everytime to reset the prompt
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt
}

fzf-dir-navigator() {
    # ---------------------------------------------------------------------------
    #                            PRE-REQUISITE CHECKS                            
    # ---------------------------------------------------------------------------

    # `fzf` is a must have for this to work!
    if ! command -v "fzf" &> /dev/null; then
        echo "Install fzf for this feature to work."
        return -1
    fi

    # `fzf` is a must have for this to work!
    if ! command -v "tac" &> /dev/null; then
        echo "Install coreutils to get the tac command."
        return -1
    fi

    # If `fd` does not exist, the `find` command will be used
    # to look for directories.
    # NOTE: If you are switching from `find` to `fd`, please use C-r
    # to reset the history.
    # "exclusions" taken from the .conf file.
    local options
    local find_cmd

    if ! command -v "fd" &> /dev/null; then
        options=" -type d"

        if (( ${#exclusions[@]} != 0 )); then
            options+=" \("

            for exclude in "${exclusions[@]:0:${#exclusions[@]}-1}"
            do
                options+=" -name $exclude -o"
            done

            options+=" -name ${exclusions[@]: -1} \) -prune -o -type d -print"
        fi

        options+=" | sed '1d'"

        find_cmd="find"
    else
        options=" -Ha --type directory"

        for exclude in "${exclusions[@]}"
        do
            options+=" --exclude $exclude"
        done

        find_cmd="fd ."
    fi

    # If `tree` does not exist, the `ls` command will be used
    # for the dir preview.
    if ! command -v "tree" &> /dev/null; then
        local preview_tool="ls -a"
    else
        local preview_tool="tree -a -C -L 1"
    fi
    local preview_cmd=" | tr '\n' '\0' | xargs -0 $preview_tool | head -n 20"

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

    # Replace $HOME with a "~" and $PWD with a "." for UI eye-candy using the
    # sed command.
    local home_find_cmd="$find_cmd ${directories_to_search[*]} $options | ($history_cmd && \cat) | sed 's|$HOME|~|g'"
    local pwd_find_cmd="$find_cmd \"$PWD\" $options | sed 's|$PWD|\.|g'" 

    local home_preview_cmd="echo {} | sed 's|~|$HOME|g' $preview_cmd"
    local pwd_preview_cmd="echo {} | sed 's|^\.|$PWD|g' $preview_cmd"

    local dir

    # Single `fzf` command with all config options.
    local fzf_cmd="fzf --height=60% \
        --header=\"\"$search_home\": search ~ | \"$search_pwd\" : search . | \"$reset_history\": reset history\" \
        --border \"top\" \
        --prompt=\"Search for a directory > \" \
        --bind \"change:first\" \
        --bind \"\"$search_home\":change-preview(\$home_preview_cmd)+reload:\$home_find_cmd\" \
        --bind \"\"$search_pwd\":change-preview(\$pwd_preview_cmd)+reload:\$pwd_find_cmd\" \
        --bind \"\"$reset_history\":execute-silent(rm \$history_file \&\& touch \$history_file)+reload:\$home_find_cmd\" \
        --preview-window 35%,border-left"

    if [[ $PWD == $HOME ]]; then
        dir=$(eval "$home_find_cmd | awk 'NF==0{print;next} !seen[\$0]++' | $fzf_cmd --preview \"$home_preview_cmd\"")
    else
        dir=$(eval "$pwd_find_cmd | awk 'NF==0{print;next} !seen[\$0]++' | $fzf_cmd --preview \"$home_preview_cmd\"")
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
        if [ -n "$os" ] && [ "$os" = "mac" ]; then
            sed -i '.bak' '1d' $history_file
        else
            sed -i '1d' $history_file
        fi
    fi
    echo $dir >> $history_file

    run-precmd

    return $?
}

zle -N fzf-dir-navigator
bindkey "^F" fzf-dir-navigator

prevd() {
    pushd +1 >/dev/null 2>&1
    run-precmd

    return $?
}

zle -N prevd
# Binds Alt-left to `prevd`.
bindkey "^[[1;3D" prevd

nextd() {
    pushd -0 >/dev/null 2>&1
    run-precmd

    return $?
}

zle -N nextd
# Binds Alt-right to `prevd`.
bindkey "^[[1;3C" nextd
