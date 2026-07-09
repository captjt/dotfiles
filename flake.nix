{
  description = "captjt dotfiles";

  nixConfig.extra-experimental-features = [
    "nix-command"
    "flakes"
  ];

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      defaultUsername = "jordan";
      dotfilesPath = ./.;

      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = lib.genAttrs supportedSystems;

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      darwinHome = username: "/Users/${username}";
      linuxHome = username: "/home/${username}";

      mkHome =
        {
          system,
          username ? defaultUsername,
          homeDirectory ? (
            if lib.hasSuffix "-darwin" system then darwinHome username else linuxHome username
          ),
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {
            inherit
              inputs
              username
              homeDirectory
              dotfilesPath
              ;
          };
          modules = [
            ./nix/home
          ];
        };

      mkDarwin =
        {
          system,
          username ? defaultUsername,
          homeDirectory ? darwinHome username,
          modules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              inputs
              username
              homeDirectory
              dotfilesPath
              ;
          };
          modules = [
            ./nix/darwin
            home-manager.darwinModules.home-manager
            {
              nixpkgs.hostPlatform = system;
              users.users.${username}.home = homeDirectory;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit
                    inputs
                    username
                    homeDirectory
                    dotfilesPath
                    ;
                };
                users.${username} = import ./nix/home;
              };
            }
          ]
          ++ modules;
        };
    in
    {
      formatter = forAllSystems (system: (mkPkgs system).nixfmt);

      devShells = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nixfmt
            ];
          };
        }
      );

      homeConfigurations = {
        "jordan-aarch64-darwin" = mkHome { system = "aarch64-darwin"; };
        "jordan-x86_64-darwin" = mkHome { system = "x86_64-darwin"; };
        "jordan-aarch64-linux" = mkHome { system = "aarch64-linux"; };
        "jordan-x86_64-linux" = mkHome { system = "x86_64-linux"; };
      };

      darwinConfigurations = {
        Mac = mkDarwin { system = "aarch64-darwin"; };
        "jordan-aarch64-darwin" = mkDarwin { system = "aarch64-darwin"; };
        "jordan-x86_64-darwin" = mkDarwin { system = "x86_64-darwin"; };
      };
    };
}
