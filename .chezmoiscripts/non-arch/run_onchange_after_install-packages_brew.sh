#!/bin/bash

set -euo pipefail

PACKAGES=(
  bash-language-server
  dockerfile-language-server
  entr
  fzf
  go
  golangci-lint
  golangci-lint-langserver
  helix
  helm-ls
  jq
  ncdu
  # required for lang servers
  node
  shellcheck
  shfmt
  starship
  terraform-ls
  vscode-langservers-extracted
  yaml-language-server
  yazi
)

REMOVE_PACKAGES=(
)

cdOrFail() {
  cd "$1" || echo "Can't cd. $1 not found"
}

getPackagesToInstall() {
  local output=()
  for package in "${PACKAGES[@]}"; do
    if ! brew list "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  echo "${output[@]}"
}

getPackagesToRemove() {
  local output=()
  for package in "${REMOVE_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
      output+=("$package")
    fi
  done
  echo "${output[@]}"
}

install() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to install"
    return 0
  fi
  echo "Following packages will be installed: $*"
  local newparams=()
  for package in "$@"; do
    case $package in
    *)
      newparams+=("$package")
      ;;
    esac
  done
  set -- "${newparams[@]}" # overwrites the original positional params
  brew install --ask "$@"
}

remove() {
  if [ "$#" -eq 0 ]; then
    echo "No packages to remove"
    return 0
  fi
  echo "Following packages will be removed: $*"
  local newparams=()
  for package in "$@"; do
    case $package in
    *)
      newparams+=("$package")
      ;;
    esac
  done
  set -- "${newparams[@]}" # overwrites the original positional params
  brew uninstall "$@"
}

installBrew() {
  if brew --version >/dev/null; then
    echo "Brew already installed"
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # workaround for missing brew in PATH
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

postInstallActions() {
  for package in "$@"; do
    case $package in
    node)
      npm config set prefix "${XDG_STATE_HOME}/npm-global"
      ;;
    *)
      echo "No action for $package"
      ;;
    esac
  done
}

installBrew

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
