inputs: ps: { pkgs, lib,... }:

let
  inherit (pkgs.stdenv) isAarch64 isDarwin;
  llamaCppPythonOsSpecific =
    if isAarch64 && isDarwin then
      with pkgs.darwin.apple_sdk_11_0.frameworks; [
        Accelerate
        MetalKit
        MetalPerformanceShaders
        MetalPerformanceShadersGraph
      ]
    else if isDarwin then
      with pkgs.darwin.apple_sdk.frameworks; [
          Accelerate
          CoreGraphics
          CoreVideo
        ]
    else
      [ ];
  buildPythonPackageFromFlake = { name, ... }@attrs:
  ps.buildPythonPackage (
    lib.trivial.mergeAttrs attrs {
      name = "${name}";
      src = inputs.${name}.outPath;
    }
  ); in
[
  (buildPythonPackageFromFlake {
    name="llama-cpp-python";
    format="other";
    nativeBuildInputs=[ pkgs.cmake ps.numpy ps.pip ps.scikit-build ps.setuptools ];
    buildInputs=([
      (buildPythonPackageFromFlake {
        name="diskcache";
        doCheck=false;
      })] ++ llamaCppPythonOsSpecific);
    preShellHook=if isDarwin && isAarch64 then ''
      export CMAKE_ARGS="-DLLAMA_METAL=on"
      export FORCE_CMAKE=1
    '' else "";
    dontUsePip=true;
    phases=[
      "unpackPhase"
      "installPhase"
      "fixupPhase"
    ];
    installPhase=''
    export SITE_PACKAGES=$out/lib/python3.11/site-packages
    mkdir -p $SITE_PACKAGES
    python3 setup.py install --root $out
    echo "$(ls -alh $out)"
    '';
  }) 
]
