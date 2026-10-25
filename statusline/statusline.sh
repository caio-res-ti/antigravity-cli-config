#!/usr/bin/env bash

data="$(cat)"

reset='\033[0m'
bold='\033[1m'
dim='\033[2m'

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[35m'
cyan='\033[36m'

state="$(jq -r '.agent_state // "idle"' <<< "$data")"

model="$(jq -r '
  .model.display_name
  // .model.id
  // "unknown"
' <<< "$data")"

project="$(jq -r '
  .workspace.project_dir
  // .workspace.current_dir
  // .cwd
  // ""
' <<< "$data")"

project="${project##*/}"

branch="$(jq -r '.vcs.branch // empty' <<< "$data")"
dirty="$(jq -r '.vcs.dirty // false' <<< "$data")"

ctx="$(jq -r '
  .context_window.used_percentage
  // 0
  | floor
' <<< "$data")"

artifacts="$(jq -r '.artifact_count // 0' <<< "$data")"
tasks="$(jq -r '.task_count // 0' <<< "$data")"
mode="$(jq -r '.execution_mode // empty' <<< "$data")"

# Quota com reset mais próximo
quota="$(jq -r '
  [
    .quota[]?
    | select(
        .remaining_fraction != null
        and .reset_in_seconds != null
        and .reset_in_seconds > 0
      )
  ]
  | sort_by(.reset_in_seconds)
  | first
  | if .
    then (.remaining_fraction * 100 | floor)
    else empty
    end
' <<< "$data")"

reset_seconds="$(jq -r '
  [
    .quota[]?
    | select(
        .remaining_fraction != null
        and .reset_in_seconds != null
        and .reset_in_seconds > 0
      )
  ]
  | sort_by(.reset_in_seconds)
  | first
  | .reset_in_seconds // empty
' <<< "$data")"

# Agent state
case "$state" in
  idle)
    state_color="$green"
    ;;
  thinking)
    state_color="$yellow"
    ;;
  working|tool_use)
    state_color="$cyan"
    ;;
  initializing)
    state_color="$magenta"
    ;;
  *)
    state_color="$dim"
    ;;
esac

# Contexto
if (( ctx >= 85 )); then
  ctx_color="$red"
elif (( ctx >= 65 )); then
  ctx_color="$yellow"
else
  ctx_color="$green"
fi

# Quota
quota_color="$green"

if [[ -n "$quota" ]]; then
  if (( quota <= 20 )); then
    quota_color="$red"
  elif (( quota <= 40 )); then
    quota_color="$yellow"
  fi
fi

# Formata reset
reset_text=""

if [[ -n "$reset_seconds" ]]; then
  days=$((reset_seconds / 86400))
  hours=$(((reset_seconds % 86400) / 3600))
  minutes=$(((reset_seconds % 3600) / 60))

  if (( days > 0 )); then
    reset_text="${days}d ${hours}h"
  elif (( hours > 0 )); then
    reset_text="${hours}h ${minutes}m"
  else
    reset_text="${minutes}m"
  fi
fi

parts=()

# Agent state
parts+=("${state_color}${bold}● ${state^^}${reset}")

# Model
parts+=("${magenta}⬢ ${model}${reset}")

# Project
if [[ -n "$project" ]]; then
  parts+=("${blue}▣ ${project}${reset}")
fi

# Git branch
if [[ -n "$branch" ]]; then
  git=" ${branch}"

  if [[ "$dirty" == "true" ]]; then
    git+="*"
  fi

  parts+=("${cyan}${git}${reset}")
fi

# Context
parts+=("${ctx_color}ctx ${ctx}%${reset}")

# Quota + reset
if [[ -n "$quota" ]]; then
  quota_text="quota ${quota}%"

  if [[ -n "$reset_text" ]]; then
    quota_text+=" ↻ ${reset_text}"
  fi

  parts+=("${quota_color}${quota_text}${reset}")
fi

# Artifacts
if (( artifacts > 0 )); then
  parts+=("${blue}◫ ${artifacts}${reset}")
fi

# Background tasks
if (( tasks > 0 )); then
  parts+=("${yellow}⚙ ${tasks}${reset}")
fi

# Execution mode
if [[ -n "$mode" ]]; then
  parts+=("${dim}${mode^^}${reset}")
fi

IFS="  "
printf '%b\n' "${parts[*]}"
