let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { overlays = [ ] ; config = {}; };

  maelstrom_tag = "0.2.3";
  maelstrom  = pkgs.stdenv.mkDerivation {
    name  = "jepsen-maelstrom";
    src   = fetchTarball {
      url =  "https://github.com/jepsen-io/maelstrom/releases/download/v${maelstrom_tag}/maelstrom.tar.bz2";
      sha256  =  "sha256:1hkczlbgps3sl4mh6hk49jimp6wmks8hki0bqijxsqfbf0hcakwq";
    };
    phases = ["installPhase" "patchPhase"];

    nativeBuildInputs = [ pkgs.makeWrapper ];
    propagatedBuildInputs = [ pkgs.jdk17_headless ];

    installPhase = ''
      mkdir -p $out/bin/lib
      cp $src/maelstrom $out/bin/maelstrom
      cp $src/lib/maelstrom.jar $out/bin/lib/maelstrom.jar
    '';

    fixupPhase =  ''
      chmod +x $out/bin/maelstrom
      patchShebangs $out/bin/maelstrom
      wrapProgram $out/bin/maelstrom \
        --prefix PATH ":" "${pkgs.lib.makeBinPath [ pkgs.rlwrap pkgs.coreutils ]}" \
        --set JAVA_CMD ${pkgs.jdk17_headless}/bin/java
    '';
  };
in pkgs.mkShell {
  buildInputs = [
    pkgs.jdk17_headless
    pkgs.graphviz
    pkgs.gnuplot
    pkgs.leiningen
    pkgs.redpanda
    pkgs.maven
    maelstrom
  ];
}
