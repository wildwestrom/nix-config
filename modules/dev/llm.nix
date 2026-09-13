# Coding agents and LLM tooling.
{ inputs, ... }:
{
  flake.modules.homeManager.llm =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      home.packages = [
        inputs.codex-cli.packages.${system}.default
        inputs.claude-code.packages.${system}.default
        inputs.pi-agent.packages.${system}.default
        inputs.grok-build.packages.${system}.default
        pkgs.claude-desktop # overlay in core/nixpkgs.nix; repackaged from Anthropic's .deb
        pkgs.opencode
      ];

      services.ollama = {
        enable = true;
        package = pkgs.ollama-rocm;
      };

      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        "x-scheme-handler/claude" = "com.anthropic.Claude.desktop";
      };
    };
}
