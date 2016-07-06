#!/usr/bin/env zsh

+vi-prompt-nerdish-git-hook-enable() {
  if [ "$(command git rev-parse --is-inside-work-tree 2> /dev/null)" != "true" ]; then
    return 1
  fi

  return 0
}

+vi-prompt-nerdish-git-hook-remote-status() {
  if [ "$1" != "1" ]; then
    return 0
  fi

  command git rev-parse --abbrev-ref @'{u}' &>/dev/null || return 0

  local arrow_status=""
  arrow_status="$(command git rev-list --left-right --count HEAD ...@'{u}' 2>/dev/null)"
  (( !$? )) || return 0

  arrow_status=(${(ps:\t:)status})

  local arrows left="${arrow_status[0]}" right="${arrow_status[1]}"

  (( ${right:-0} > 0 )) && arrows+="%F{cyan}$(echo -e "${NERDISH_SYMBOL_GIT_STATUS_ARROW_DOWN:-"\uf13a"}")%f"
  (( ${left:-0}  > 0 )) && arrows+="%F{magenta}$(echo -e "${NERDISH_SYMBOL_GIT_STATUS_ARROW_UP:-"\uf139"}")%f"

  if [ -n "${arrows:-}" ]; then
    hook_com[misc]+="${arrows}"
  fi
}

prompt_nerdish_precmd() {
  vcs_info
}

prompt_nerdish_setup() {
  local _prompt="$(echo -e "${NERDISH_SYMBOL_PROMPT:-"\uf105"}")"
  local _directory="$(echo -e "${NERDISH_SYMBOL_DIRECTORY:-"\uf0a0"}")"
  local _branch="$(echo -e "${NERDISH_SYMBOL_GIT_BRANCH:-"\ue725"}")"
  local _action="$(echo -e "${NERDISH_SYMBOL_GIT_ACTION:-"\uf101"}")"
  local _staged="$(echo -e "${NERFISH_SYMBOL_GIT_STAGED:-"\uf055"}")"
  local _unstaged="$(echo -e "${NERDISH_SYMBOL_GIT_UNSTAGED:-"\uf059"}")"

  local _machine=""
  if [ "$(uname -s)" = "Darwin" ]; then
    _machine="%F{white}$(echo -e "\uf179")%f"
  elif [[ "$(uname -s)" =~ "^MSYS2_NT" ]]; then
    _machine="%F{blue}$(echo -e "\u17a")%f"
  elif [ "$(uname -s)" = "Linux" ]; then
    : # TODO
  fi

  setopt prompt_subst

  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  add-zsh-hook precmd prompt_nerdish_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' use-simple true
  zstyle ':vcs_info:*' max-exports 3
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "%F{green}${_staged}%f"
  zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}${_unstaged}%f"
  
  zstyle ':vcs_info:git+set-message:*' hooks \
    prompt-nerdish-git-hook-enable \
    prompt-nerdish-git-hook-remote-status


  zstyle ':vcs_info:git*' formats \
    "${_branch}%b" \
    "%c%u %m"
  zstyle ':vcs_info:git*' actionformats \
    "${_branche}%b${_action}%a" \
    "%c%u %m"

  local preline="%F{green}${_directory}%f %F{blue}%~%f"
  local cmdline="%(?.%F{magenta}.%F{red})${_prompt}%f"

  PROMPT="
${preline} \${vcs_info_msg_0_} \${vcs_info_msg_1_}
${_machine} ${cmdline}"
}

prompt_nerdish_setup "${@:-}"
