{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
}:

let
  packageMeta = builtins.fromJSON (builtins.readFile ./pi-coding-agent.json);
in
buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = packageMeta.version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = packageMeta.srcHash;
  };

  npmDepsHash = packageMeta.npmDepsHash;
  dontNpmBuild = true;

  nativeBuildInputs = [ jq ];

  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./pi-coding-agent-package-lock.json} package-lock.json
  '';

  meta = with lib; {
    description = "Coding agent CLI with read, bash, edit, and write tools";
    homepage = "https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent";
    license = licenses.mit;
    mainProgram = "pi";
    platforms = platforms.unix;
  };
}
