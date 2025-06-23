{ pkgs, inputs, lib, additionalPackages ? [], isDesktop ? true }:

let vscode-extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system}; in
  (import ./packages.nix { inherit pkgs inputs lib additionalPackages; }) ++ (with pkgs; [
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
])
