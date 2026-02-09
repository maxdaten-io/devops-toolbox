{ pkgs, ... }:
{
  programs.nixfmt.enable = pkgs.lib.meta.availableOn pkgs.stdenv.buildPlatform pkgs.nixfmt-rfc-style.compiler;
  programs.nixfmt.package = pkgs.nixfmt-rfc-style;

  programs.yamlfmt.enable = true;
  programs.shfmt.enable = true;
  programs.prettier.enable = true;
}
