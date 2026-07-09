{ lib, pkgs, ... }:
let
  optionalPackage = name: lib.optional (builtins.hasAttr name pkgs) (builtins.getAttr name pkgs);

  optionalPackages = names: lib.concatMap optionalPackage names;
in
{
  # Keep this intentionally smaller than the Brewfile while the migration is new.
  # The full current macOS package set is mirrored in nix/darwin/homebrew.nix.
  home.packages = optionalPackages [
    "bat"
    "direnv"
    "eza"
    "fd"
    "fzf"
    "gh"
    "git"
    "git-lfs"
    "gitleaks"
    "go"
    "jq"
    "just"
    "kubectl"
    "neovim"
    "ripgrep"
    "ruff"
    "shellcheck"
    "shfmt"
    "sops"
    "starship"
    "tree"
    "uv"
    "wget"
    "yq-go"
    "zoxide"
  ];
}
