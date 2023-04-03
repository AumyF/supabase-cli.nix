{
  description = "Supabase CLI";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.supabase-cli = {
    url = "github:supabase/cli/v1.47.2";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, supabase-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree
          {
            supabase-cli = pkgs.buildGo120Module rec {
              pname = "supabase-cli";
              version = "v1.47.2";
              src = supabase-cli;
              vendorSha256 = "sha256-3X02RBh9kGXybY9ahkraFiROi8PJDIQb888DP2ObBjg=";

              doCheck = false; # FIXME test fails due to network accesses
              postInstall = ''
                cd $out/bin
                mv ./cli ./supabase
              '';
            };
          };
        defaultPackage = packages.supabase-cli;
        apps.supabase-cli = flake-utils.lib.mkApp { drv = packages.supabase-cli; };
        defaultApp = apps.supabase-cli;
        devShell = pkgs.callPackage ./shell.nix { };
      }
    );
}
