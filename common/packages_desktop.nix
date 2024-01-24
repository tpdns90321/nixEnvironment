{ pkgs, inputs, lib }:

let vscode-extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system}; in
  (import ./packages.nix { pkgs = pkgs; inputs = inputs; lib = lib; }) ++ (with pkgs; [
  # GUI Application for work
  alacritty
  gimp
  
  # VSCode
  (
    vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
       {
         name = "copilot";
         publisher = "Github";
         version = "1.121.453";
         sha256 = "sha256-uhwAwdgHt9jk+Hmm01LTB2vI6HOS7R9E9kair6so4Ao=";
       }
      ]) ++ (with vscode-extensions.vscode-marketplace; [
        vscodevim.vim
        arcanis.vscode-zipfs
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
      ]);
    }
  )
]) ++ [
  # llamacpp
  inputs.llama_cpp.packages.${pkgs.system}.default
]

