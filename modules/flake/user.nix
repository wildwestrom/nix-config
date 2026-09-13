# The one human this config is for. Exposed to every flake-parts module as the
# `user` argument; aspects that need the username (users.users.${user.name},
# home-manager.users.${user.name}, git identity) read it from here instead of
# threading it through specialArgs.
{
  _module.args.user = {
    name = "main";
    fullName = "Christian Westrom";
    email = "c.westrom@westrom.xyz";
    github = "wildwestrom";
  };
}
