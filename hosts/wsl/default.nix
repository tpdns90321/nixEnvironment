{ user, ... }:

{
  home.file."/home/${user}/.zprofile".source = ./zprofile;
}
