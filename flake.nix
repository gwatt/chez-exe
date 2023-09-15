{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        bootpath = if system == "x86_64-darwin"
                   then "${pkgs.chez}/lib/csv${pkgs.chez.version}/ta6osx"
                   else "${pkgs.chez}/lib/csv${pkgs.chez.version}/ta6le";
        platformSpecificInputs = if system == "x86_64-darwin"
                                 then [ pkgs.darwin.libiconv ]
                                 else [ pkgs.libuuid ];
      in {

        packages.default = pkgs.stdenv.mkDerivation {
          name = "chez-exe";
          version = "0.0.1";
          src = ./.;

          buildInputs = with pkgs; [
            chez
          ] ++ platformSpecificInputs;

          buildPhase = ''
            mkdir -p $out/{bin,lib}
            scheme --script gen-config.ss \
            --prefix $out \
            --bindir $out/bin \
            --libdir $out/lib \
            --bootpath ${bootpath} \
            --scheme scheme
          '';
        };
      }
    );
}
