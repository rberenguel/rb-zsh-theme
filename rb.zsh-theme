# Rip of agnoster's zsh theme (https://github.com/agnoster/agnoster-zsh-theme),
# removing some things I don't need and adding a few I do. General appearance is
# preserved

CURRENT_BG='NONE'
if [[ -z "$PRIMARY_FG" ]]; then
	PRIMARY_FG=black
fi

SEGMENT_SEPARATOR="\ue0b0"
PLUSMINUS="\u00b1"
BRANCH="\ue0a0"
DETACHED="\u27a6"

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  CURRENT_BG=''
}

# Context is (for now) the git project. Might make sense to also have the
# virtual environment here?

prompt_context() {
    ref="$vcs_info_msg_0_"
    if [[ -n "$ref" ]]; then
        git_project=$(git rev-parse --show-toplevel)
        if [[ -n "$git_project" ]]; then
            project=$(basename $git_project)
            prompt_segment 98 260 " ${project} "
        else
            prompt_segment 98 260 " ??? "
        fi
    fi
}

# Reduce git branch names to 4 characters per / separated segment, unless it
# matches our internal JIRA issue numbering, in that case preserve it completely

JIRA_PROJECT="SAS-"

shorten_git() {
    branch_ref=$1
    dashes=$(echo $branch_ref | tr -cd '-' | wc -c)
    slashes=$(echo $branch_ref | tr -cd '/' | wc -c)
    if [ "$slashes" -gt "$dashes" ]; then
        echo $branch_ref | awk  'BEGIN{RS="/"; acum=""}!/^'${JIRA_PROJECT}'/{if(FNR==1){acum=substr($1, 1, 3)}else{acum=acum "/" substr($1, 1, 3)}} /^'$JIRA_PROJECT'/{acum=acum "/" $1 }END{print acum}'
    else
        echo $branch_ref | awk  'BEGIN{RS="-"; acum=""}{if(FNR==1){acum=substr($1, 1, 3)}else{acum=acum "-" substr($1, 1, 3)}}END{print acum}'
    fi
}


# Helper to open a JIRA issue related to a git branch. I alias this to oj

open_jira() {
    branch="$vcs_info_msg_0_"
    issue=$(echo $branch | awk  'BEGIN{RS="/";}/^${JIRA_PROJECT}/{print $1 }')
    open "https://affectv.atlassian.net/browse/$issue"
}

# Helper to open the github page of the project. I alias this to og

open_github() {
    url=$(git config --get remote.origin.url)
    open $url
}

# Git prompt, essentially the same from agnoster

prompt_git() {
    local color ref status ret
    is_dirty() {
        if [[ -n "$(git rev-parse --show-toplevel)" ]]; then
            ret="$(git status --porcelain --ignore-submodules)"
        else
            ret="aaa"
        fi
        test -n "$ret"
    }
    ref="$vcs_info_msg_0_"
    if [[ -n "$ref" ]]; then
        if is_dirty; then
            color=yellow
        else
            color=green
        fi
        if [[ "${ref/.../}" == "$ref" ]]; then
            shortref=$(shorten_git $ref)
            ref="$BRANCH $shortref"
        else
            shortref=$(shorten_git $ref)
            ref="$DETACHED ${shortref/.../}"
        fi
        prompt_segment $color 235
        print -n " $ref "
    fi
}

# Current dir, in red if last command returned non 0

prompt_dir() {
    if [[ $RETVAL -ne 0 ]]; then
        prompt_segment red black " $(basename $(pwd)) "
    else
        prompt_segment blue 12 " $(basename $(pwd)) "
    fi

}

# Display current virtual environment, same as in agnoster

prompt_virtualenv() {
  if [[ -n $VIRTUAL_ENV ]]; then
    color=cyan
    prompt_segment $color $PRIMARY_FG
    print -Pn " $(basename $VIRTUAL_ENV) "
  fi
}

prompt_rb_main() {
  RETVAL=$?
  CURRENT_BG='NONE'
  prompt_context
  prompt_virtualenv
  prompt_dir
  prompt_git
  prompt_end
}

prompt_rb_precmd() {
  vcs_info
  PROMPT='%{%f%b%k%}$(prompt_rb_main) '
}

prompt_rb_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_rb_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_rb_setup "$@"
