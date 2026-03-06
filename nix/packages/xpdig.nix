{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "xpdig";
  version = "1.22.0";

  src = fetchFromGitHub {
    owner = "brunoluiz";
    repo = "xpdig";
    rev = "v${version}";
    hash = "sha256-baNtG/C/inFOAWIYzxns3EBkf885ISyjz+UhOMB2VZA=";
  };

  vendorHash = "sha256-T0dlZYq4UOCO8+PYugM5S5jtJGl6gup67KF3+rQMhGc=";

  subPackages = [ "cmd/xpdig" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = {
    description = "Crossplane trace explorer TUI";
    homepage = "https://github.com/brunoluiz/xpdig";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "xpdig";
  };
}
