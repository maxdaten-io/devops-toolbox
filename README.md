# devops-toolbox

Reusable [devenv](https://devenv.sh) modules that bundle DevOps tools not available in nixpkgs.

## Tools

### xpdig

[xpdig](https://github.com/brunoluiz/xpdig) is a Crossplane trace explorer TUI.
It visualizes relationships between Claims, Composites, and Managed Resources.

Includes a k9s plugin installer for quick access via the `t` shortcut.

### ASH (Automated Security Helper)

[ASH](https://github.com/awslabs/automated-security-helper) is an extensible SAST, SCA, and IaC security scanner orchestration engine by AWS.

Wrapped via `uvx` to avoid managing ASH's large Python dependency tree natively.

## Usage

Add to your `flake.nix` inputs:

```nix
inputs.devops-toolbox.url = "github:maxdaten-io/devops-toolbox";
```

Import in your devenv shell:

```nix
devenv.shells.default = {
  imports = [ inputs.devops-toolbox.devenvModules.default ];

  devops-toolbox.xpdig.enable = true;
  devops-toolbox.ash.enable = true;
};
```

### Module Options

```nix
# xpdig — Crossplane trace explorer TUI
devops-toolbox.xpdig.enable = true;
devops-toolbox.xpdig.k9s-plugin.enable = true;  # default: true

# ASH — Automated Security Helper
devops-toolbox.ash.enable = true;
```

### k9s Plugin

When `xpdig` is enabled, run `install-k9s-xpdig-plugin` to merge the xpdig plugin
into your k9s configuration. Press `t` on any resource in k9s to trace Crossplane relationships.

## Development

```bash
devenv shell
```

## Building Packages

```bash
nix build .#xpdig
nix build .#ash
```
