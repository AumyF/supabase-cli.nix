{
  description = "Supabase CLI";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.supabase-cli = {
    url = "github:supabase/cli/v0.15.14";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, supabase-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = flake-utils.lib.flattenTree
          {
            supabase-cli = pkgs.buildGo117Module rec {
              pname = "supabase-cli";
              version = "0.15.14";
              src = supabase-cli;
              vendorSha256 = "sha256-mCZrP6cTrIuPbQiE33+7W1njZz2lNHHjUz6KVb6r8+k=";
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
