let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { overlays = [ ] ; config = {}; };
in pkgs.mkShell {
  buildInputs = [
    pkgs.jdk17_headless
    pkgs.graphviz
    pkgs.gnuplot
    pkgs.leiningen
    pkgs.redpanda
  ];
}
