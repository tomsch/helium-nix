{
  description = "Helium - private, fast, and honest web browser";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    {
      packages."x86_64-linux" =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./package-x86_64.nix { };
          helium = self.packages.${system}.default;
        };
      packages."aarch64-linux" =
        let
          system = "aarch64-linux";
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.callPackage ./package-aarch64.nix { };
          helium = self.packages.${system}.default;
        };
      overlays.default = final: prev: {
        helium = final.callPackage (
          if final.stdenv.hostPlatform.isAarch64 then ./package-aarch64.nix else ./package-x86_64.nix
        ) { };
      };
    };
}
