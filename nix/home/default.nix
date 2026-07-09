{
  lib,
  username ? "jordan",
  homeDirectory ? "/Users/${username}",
  ...
}:
{
  imports = [
    ./agents.nix
    ./files.nix
    ./packages.nix
  ];

  home.username = lib.mkDefault username;
  home.homeDirectory = lib.mkDefault homeDirectory;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
