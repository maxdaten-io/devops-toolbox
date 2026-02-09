{
  lib,
  writeShellApplication,
  uv,
  python3,
}:

writeShellApplication {
  name = "ash";
  runtimeInputs = [
    uv
    python3
  ];
  text = ''
    exec uvx automated-security-helper "$@"
  '';
  meta = {
    description = "Automated Security Helper — SAST, SCA, and IaC security scanner orchestration engine";
    homepage = "https://github.com/awslabs/automated-security-helper";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ash";
  };
}
