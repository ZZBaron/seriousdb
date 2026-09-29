{
  description = "Development environment for seriousdb";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      pyproject = nixpkgs.lib.importTOML ./pyproject.toml;
    in
    {
      packages = forAllSystems (
        system:
        let
          py = nixpkgs.legacyPackages.${system}.python3Packages;
        in
        {
          default = py.buildPythonPackage {
            pname = "seriousdb";
            inherit (pyproject.project) version;
            pyproject = true;
            src = ./.;
            build-system = [ py.setuptools ];
            dependencies = [ py.python-dotenv ];
          };
        }
      );

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