# Version control: git identity and the tools around it.
{ user, ... }:
{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        settings = {
          user = {
            name = user.fullName;
            email = user.email;
            # signingKey = config.gpgKey;
          };
          github.user = user.github;
          gitlab.user = user.github;
          commit = {
            # gpgSign = true;
          };
          pull.ff = "only";
          init.defaultBranch = "main";
        };
      };

      # delta moved out of programs.git into its own module. Git integration used
      # to be implied by enabling it here; it must now be requested explicitly.
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options.light = true;
      };

      programs.lazygit.enable = true;

      home.packages = with pkgs; [
        gitui
        gh
        jujutsu
        lazyjj
        fossil
        act
        mercurialFull
      ];
    };
}
