{ dotfilesPath, ... }:
{
  home.file = {
    ".zshrc".source = dotfilesPath + /config/zshrc;

    ".bin".source = dotfilesPath + /bin;

    ".gitconfig".source = dotfilesPath + /config/gitconfig;
    ".gitattributes".source = dotfilesPath + /config/gitattributes;
    ".gitignore_global".source = dotfilesPath + /config/gitignore_global;

    ".editorconfig".source = dotfilesPath + /config/editorconfig;
    ".config/starship.toml".source = dotfilesPath + /config/starship.toml;

    "docker.yaml".source = dotfilesPath + /config/docker.yaml;

    ".nvm/default-packages".source = dotfilesPath + /nvm/default-packages;

    ".agents".source = dotfilesPath + /agents;

    ".config/rex".source = dotfilesPath + /rex;

    ".codex/AGENTS.md".source = dotfilesPath + /codex/AGENTS.md;
  };
}
