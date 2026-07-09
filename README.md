# captjt's dotfiles

### To Install

#### Note: Ensure git is installed

```shell
git clone https://github.com/captjt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### Shared agent skills

Global skills live in `agents/skills` and are installed through `~/.agents`. The installer also fans them out to supported coding-agent skill directories when those agents are present.

Refresh only the shared agent-skill links with:

```shell
just agent-skills
```

### Nix migration

The `nix-migration` branch is adding Nix alongside the existing Dotbot installer. The current `install.sh`, Dotbot configs, and `Brewfile` are intentionally left in place while the Nix setup matures.

The initial Nix layout uses:

- `flake.nix` as the entrypoint.
- `nix/darwin` for macOS and Homebrew via `nix-darwin`.
- `nix/home` for a small first wave of Home Manager packages, dotfile links, and shared agent-skill fanout.

Build without changing the machine:

```shell
nix build --no-link .#homeConfigurations.jordan-aarch64-darwin.activationPackage
nix build --no-link .#darwinConfigurations.Mac.system
```

Apply Home Manager only, backing up any conflicting files:

```shell
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#jordan-aarch64-darwin -b dotbot-pre-nix
```

Apply the macOS system config only after reviewing the build:

```shell
sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#Mac
```

Homebrew activation is configured with `cleanup = "none"`, `autoUpdate = false`, and `upgrade = false` so a first switch should not uninstall or upgrade unrelated Homebrew packages.
