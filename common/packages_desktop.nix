{ pkgs, inputs, lib }:

(import ./packages.nix { pkgs = pkgs; inputs = inputs; lib = lib; }) ++ (with pkgs; [
  # GUI Application for work
  alacritty
  gimp
  postman
  
  # VSCode
  (
    vscode-with-extensions.override {
      vscodeExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "copilot";
          publisher = "Github";
          version = "1.121.453";
          sha256 = "sha256-uhwAwdgHt9jk+Hmm01LTB2vI6HOS7R9E9kair6so4Ao=";
        }
        {
          name = "vim";
          publisher = "vscodevim";
          version = "1.26.0";
          sha256 = "sha256-XPD8Rr6yy8rWieup8+sOWaz4fxAkhzsrNhMv+Twqq0M=";
        }
      ];
    }
  )
]) ++ [
  # llamacpp
  inputs.llama_cpp.packages.${pkgs.system}.default
]

