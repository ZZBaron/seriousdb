{
  description = "Development environment for seriousdb";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };

          python = pkgs.python314.withPackages (
            pythonPackages: with pythonPackages; [
              python-dotenv

              pytest
              pytest-benchmark
              ruff
              ty
            ]
          );
        in
        {
          default = pkgs.mkShell {
            packages = [ python ];

            shellHook = ''
              export PYTHONPATH="${toString ./.}/src''${PYTHONPATH:+:$PYTHONPATH}"
            '';
          };
        }
      );
    };
}
