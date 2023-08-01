{ prev, lib, buildGoModule, installShellFiles, plugins, vendorSha256 ? "", ... }:

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
  oldAttrs = prev.caddy;
  dist = oldAttrs.src; in
    buildGoModule rec {
      pname = oldAttrs.pname;
      version = oldAttrs.version;
      src = oldAttrs.src;
      inherit vendorSha256;

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

      subPackages = [ "cmd/caddy" ];
    
      nativeBuildInputs = [ installShellFiles ];
    
      meta = with lib; {
        homepage = "https://caddyserver.com";
        description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
        license = licenses.asl20;
        maintainers = with maintainers; [ Br1ght0ne emilylange techknowlogick ];
      };
    }
