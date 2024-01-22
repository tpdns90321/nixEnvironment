inputs: { pkgs, ... }:

let buildVimPluginFromFlake = name:
  pkgs.vimUtils.buildVimPlugin {
    name = "${name}";
    src = inputs.${name}.outPath;
  }; in
[
  (buildVimPluginFromFlake "copilot-vim")
  (buildVimPluginFromFlake "vim-rzip")
]
