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
    in {
      homeConfigurations = {
        # Configuración para la máquina: jorge-terciaria
        "jorge@jorge-terciaria" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./hosts/jorge-terciaria
          ];
        };

        # Configuración para la máquina: jorge-secundaria (Dual Display)
        "jorge@jorge-secundaria" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./hosts/jorge-secundaria
          ];
        };

        # Alias por defecto para compatibilidad directa
        "jorge" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./hosts/jorge-terciaria
          ];
        };
      };
    };
}
