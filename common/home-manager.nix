{ config, pkgs, ... }:

let userName = "tpdns90321"; userEmail = "tpdns9032100@gmail.com"; in {
  zsh.enable = true;
  zsh.oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
  };

  zsh.initExtraFirst = ''
    # editor
    export EDITOR=nvim

    # react-native android
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
  '';

  tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      # https://blog.sanctum.geek.nz/vi-mode-in-tmux/
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

      # https://unix.stackexchange.com/questions/12032/how-to-create-a-new-window-on-the-current-directory-in-tmux
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = userName;
    userEmail = userEmail;
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
