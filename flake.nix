{
  description = "Helium - private, fast, and honest web browser";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system} = {
        default = pkgs.callPackage ./package.nix {};
        helium = self.packages.${system}.default;
      };

      overlays.default = final: prev: {
        helium = final.callPackage ./package.nix {};
      };
    };
}
