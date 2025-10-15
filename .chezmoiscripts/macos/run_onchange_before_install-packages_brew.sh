#!/bin/bash
# force to use bash from homebrew on mac
if command -v brew >/dev/null && [[ "$(uname)" == "Darwin" && "$BASH" != "$(brew --prefix)/bin/bash" && -x "$(brew --prefix)/bin/bash" ]]; then
  exec "$(brew --prefix)/bin/bash" "$0" "$@"
fi

set -euo pipefail

PACKAGES=(
  alt-tab
  # completion for bash installed via brew
  bash-completion@2
  bash-language-server
  chezmoi
  coreutils
  dockerfile-language-server
  entr
  firefox
  font-hack-nerd-font
  fzf
  git
  go
  golangci-lint
  golangci-lint-langserver
  granted
  helix
  helm-ls
  htop
  jq
  karabiner-elements
  keepassxc
  kitty
  marksman
  mise
  ncdu
  # required for lang servers
  node
  # provide pdf preview for yazi
  poppler
  rectangle
  qrencode
  shellcheck
  shfmt
  starship
  terraform-ls
  vscode-langservers-extracted
  vscodium
  watch
  yaml-language-server
  yazi
)

REMOVE_PACKAGES=(
)

REPOS=(
  common-fate/granted
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

enableRepo() {
  for repo in "${REPOS[@]}"; do
    if brew tap | grep "$repo" &>/dev/null; then
      continue
    fi
    echo "Enabling $repo"
    brew tap "$repo"
  done
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

# mac uses version 3 ...
installBash() {
  major="${BASH_VERSION%%[^0-9]*}"
  if [ "$major" -ge "4" ]; then
    echo "Installed bash version is new enough"
    return
  fi

  brew install --ask bash
  # allow using shell from brew as the default one
  echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
  # use this shell as default
  chsh -s "$(brew --prefix)/bin/bash"
}
postInstallActions() {
  for package in "$@"; do
    case $package in
    "alt-tab")
      echo "Open alt-tab and allow all neded permissions!"
      ;;
    "karabiner-elements")
      echo "Open Karabiner and allow all neded permissions + write 'System default configuration' in 'Misc' section of settings!"
      ;;
    "vscodium")
      sudo ln -s "$(brew --prefix)/bin/codium" /usr/local/bin/code
      ;;
    "yazi")
      # install all yazi packages (like flavors)
      ya pkg install
      ;;
    *)
      echo "No action for $package"
      ;;
    esac
  done
}

installBrew

installBash

enableRepo

# Chech what packages needs to be removed and put them in to array
IFS=" " read -r -a toRemove <<<"$(getPackagesToRemove)"

remove "${toRemove[@]}"

# Chech what packages needs to be installed and put them in to array
IFS=" " read -r -a toInstall <<<"$(getPackagesToInstall)"

install "${toInstall[@]}"

postInstallActions "${toInstall[@]}"
