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

    ".config/opencode/opencode.json".source = dotfilesPath + /opencode/opencode.jsonc;
    ".opencode/package.json".source = dotfilesPath + /opencode/package.json;
    ".opencode/plugin".source = dotfilesPath + /opencode/plugin;
    ".opencode/tsconfig.json".source = dotfilesPath + /opencode/tsconfig.json;

    ".agents".source = dotfilesPath + /agents;

    ".codex/AGENTS.md".source = dotfilesPath + /codex/AGENTS.md;
  };
}
