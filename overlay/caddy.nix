{ prev, lib, plugins, ... }:

let imports = lib.concatMapStringsSep "\n" (plugin: "\t\t\t_ \"${plugin}\"\n") plugins;
  main = ''
    package main

    import (
      caddycmd "github.com/caddyserver/caddy/v2/cmd"

      _ "github.com/caddyserver/caddy/v2/modules/standard"
${imports}
    )

    func main() {
      caddycmd.Main()
    }
  '';
in {
  caddy = prev.caddy.overrideAttrs (oldAttrs: {
    go-module = lib.buildGoModule {
      name = oldAttrs.name;
      version = oldAttrs.version;
      src = oldAttrs.src;
      vendorHash = oldAttrs.vendorHash;

      overrideModAttrs = (_: {
        preBuild = "echo '${main}' > cmd/caddy/main.go && go mod tidy";
        postInstall = "cp go.mod go.sum $out/ && ls $out/";
      });
  
      postPatch = ''
        echo '${main}' > cmd/caddy/main.go
        cat cmd/caddy/main.go
      '';
  
      postConfigure = ''
        cp vendor/go.sum ./
        cp vendor/go.mod ./
      '';
    }.go-module;
  });
}
