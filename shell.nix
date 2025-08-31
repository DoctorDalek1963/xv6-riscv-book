{
  pkgs ? import <nixpkgs> { },
}:
let
  texGnuplot = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnuplot";
    inherit (pkgs.gnuplot) version;

    outputs = [ "tex" ];

    nativeBuildInputs = [
      pkgs.lua
      pkgs.gnuplot

      # multiple-outputs.sh fails if $out is not defined
      (pkgs.writeShellScript "force-tex-output.sh" ''
        out="''${tex-}"
      '')
    ];

    dontUnpack = true;

    buildPhase = ''
      lua ${pkgs.gnuplot}/share/gnuplot/6.0/lua/gnuplot-tikz.lua style
    '';

    installPhase = ''
      mkdir -p $tex/tex/latex/gnuplot
      cp *.{tex,sty} $tex/tex/latex/gnuplot/
    '';
  };

  texlive = pkgs.texlive.withPackages (
    p:
    (with p; [
      scheme-medium
      imakeidx
      preprint
    ])
    ++ [ texGnuplot ]
  );
in
pkgs.mkShell {
  buildInputs =
    (with pkgs; [
      git
      ghostscript
      gnumake
      gnuplot
      mpage
      perl
    ])
    ++ [ texlive ];
}
