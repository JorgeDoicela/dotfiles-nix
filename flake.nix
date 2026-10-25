{
  description = "Configuración declarativa profesional de Nix + Home Manager para Jorge";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Detección y generación declarativa dinámica de perfiles para todos los directorios en hosts/
      hostDirs = builtins.attrNames (
        nixpkgs.lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHostConfig = hostName: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          (./hosts + "/${hostName}")
        ];
      };

      generatedHosts = builtins.listToAttrs (map (hostName: {
        name = "jorge@${hostName}";
        value = mkHostConfig hostName;
      }) hostDirs);
    in {
      homeConfigurations = generatedHosts // {
        # Alias por defecto para compatibilidad directa
        "jorge" = mkHostConfig "jorge-terciaria";
      };
    };
}
