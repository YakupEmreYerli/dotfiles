# Shell shortcuts: a short cd that finds a project folder by a loose name, and completion.
# Set DOTFILES_PROJECTS to your projects folder and DOTFILES_VAULT to your notes folder to use the
# short names "proje" and "vault". Without them, cd still finds a project under ~/projects.
[[ $- == *i* ]] || return  # interactive shells only (ssh commands stay quiet)
_P="${DOTFILES_PROJECTS:-$HOME/projects}"
CDPATH=".:$_P:$HOME"
[ -n "${DOTFILES_PROJECTS:-}" ] && alias p='cd "$DOTFILES_PROJECTS"'
# Short names: cd proje (a local folder of the same name wins).
# Tam ad tutmazsa proje klasörleri gevşek aranır: büyük-küçük harf, Türkçe harf, nokta ve tire fark etmez,
_project_key() {
  local LC_ALL=C.UTF-8
  REPLY=$1
  REPLY=${REPLY//[çÇ]/c}; REPLY=${REPLY//[ğĞ]/g}
  REPLY=${REPLY//[ıİ]/i}; REPLY=${REPLY//[öÖ]/o}
  REPLY=${REPLY//[şŞ]/s}; REPLY=${REPLY//[üÜ]/u}
  REPLY=${REPLY,,}; REPLY=${REPLY//[^a-z0-9]/}
}
_cd_project() {
  local want root="${DOTFILES_PROJECTS:-$HOME/projects}" d key bare REPLY
  local -a exact prefix contains
  _project_key "$1"; want=$REPLY; [ -n "$want" ] || return 1
  for d in "$root"/*/; do
    [ -d "$d" ] || continue
    d=${d%/}; _project_key "${d##*/}"; key=$REPLY; bare=${key%comtr}; bare=${bare%com}
    if [ "$key" = "$want" ] || [ "$bare" = "$want" ]; then exact+=("$d")
    elif [[ $key == "$want"* ]]; then prefix+=("$d")
    elif [[ $key == *"$want"* ]]; then contains+=("$d")
    fi
  done
  local -a hits
  for hits in exact prefix contains; do
    local -n list=$hits
    if [ ${#list[@]} -eq 1 ]; then builtin cd "${list[0]}" && pwd; return; fi
    if [ ${#list[@]} -gt 1 ]; then
      echo "\"$1\" birden çok projeye uyuyor:"; printf '  %s\n' "${list[@]##*/}"; return 2
    fi
  done
  return 1
}
cd() {
  if [ $# -eq 1 ] && [ ! -d "$1" ]; then
    case "$1" in
      proje|projeler) [ -n "${DOTFILES_PROJECTS:-}" ] && builtin cd "$DOTFILES_PROJECTS" && return ;;
      vault) [ -n "${DOTFILES_VAULT:-}" ] && builtin cd "$DOTFILES_VAULT" && return ;;
    esac
    builtin cd "$1" 2>/dev/null && return
    _cd_project "$1"; case $? in 0) return 0 ;; 2) return 1 ;; esac
    echo "cd: $1: böyle bir klasör ya da proje yok" >&2; return 1
  fi
  builtin cd "$@"
}

# Complete local paths first, then short project names.
_cd_project_complete() {
  local cur=${COMP_WORDS[COMP_CWORD]} root="${DOTFILES_PROJECTS:-$HOME/projects}"
  local d name key bare want REPLY shortcut
  local -a exact=() prefix=() contains=()
  local -A seen=()
  COMPREPLY=()
  compopt -o filenames 2>/dev/null || :
  while IFS= read -r d; do
    name=${d##*/}
    [[ $name == .* && ${cur##*/} != .* ]] && continue
    COMPREPLY+=("$d")
  done < <(compgen -d -- "$cur")
  [[ $cur == */* || $cur == '~'* || $cur == -* ]] && return 0
  for shortcut in proje projeler; do
    if [[ $shortcut == "$cur" ]]; then COMPREPLY=("$shortcut"); return 0; fi
    [[ $shortcut == "$cur"* ]] && prefix+=("$shortcut")
  done
  _project_key "$cur"; want=$REPLY
  [[ -n $cur && -z $want ]] && return 0
  COMPREPLY=()
  for d in ./*/ ./.[!.]*/ ./..?*/ "$root"/*/; do
    [[ -d $d ]] || continue
    name=${d%/}; name=${name##*/}
    [[ $name == .* && $cur != .* ]] && continue
    [[ ${seen[$name]+yes} ]] && continue
    seen[$name]=1
    _project_key "$name"; key=$REPLY; bare=${key%comtr}; bare=${bare%com}
    if [[ $key == "$want" || $bare == "$want" ]]; then exact+=("$name")
    elif [[ $key == "$want"* ]]; then prefix+=("$name")
    elif [[ $key == *"$want"* ]]; then contains+=("$name")
    fi
  done
  if (( ${#exact[@]} )); then COMPREPLY=("${exact[@]}")
  elif (( ${#prefix[@]} )); then COMPREPLY=("${prefix[@]}")
  else COMPREPLY=("${contains[@]}")
  fi
  return 0
}
complete -F _cd_project_complete cd
# Complete unique matches and show ambiguous candidates by their short names.
bind '"\C-i": complete'
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
