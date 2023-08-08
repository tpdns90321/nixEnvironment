{ pkgs, inputs, lib }:

(import ./packages.nix { pkgs = pkgs; inputs = inputs; lib = lib; }) ++ (with pkgs; [
  # CUI Application for work
  bitwarden-cli

  # GUI Application for work
  gimp
  postman
  (
    vscode-with-extensions.override {
      vscodeExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "copilot";
          publisher = "Github";
          version = "1.98.275";
          sha256 = "sha256-scsuOhzjTxUqq9UfCxeqWR5Dbc2gQoadxLtAD7C0rns=";
        }
      ];
    }
  )
]) ++ [
  # llamacpp
  inputs.llama_cpp.packages.${pkgs.system}.default
]

