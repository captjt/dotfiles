{
  lib,
  username,
  homeDirectory,
  ...
}:
{
  imports = [
    ./homebrew.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = username;
  system.stateVersion = 6;

  users.users.${username}.home = lib.mkDefault homeDirectory;
}
