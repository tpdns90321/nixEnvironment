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
    nativeBuildInputs=[ pkgs.cmake ps.pip ps.scikit-build ps.setuptools ];
    buildInputs = llamaCppPythonOsSpecific;
    phases=[
      "unpackPhase"
      "installPhase"
      "fixupPhase"
    ];
    installPhase=(if isDarwin && isAarch64 then ''
      export CMAKE_ARGS="-DLLAMA_METAL=on"
      export FORCE_CMAKE=1
    '' else "") + ''
    mkdir -p $out/lib/python3.11/site-packages/
    mkdir ./dist
    python3 -m pip install . --prefix ./dist
    printf "$(ls -alh ./dist)"
    cp -r ./dist/lib/python3.11/site-packages/llama_cpp $out/lib/python3.11/site-packages/
    '';
  })
  (buildPythonPackageFromFlake {
    name="diskcache";
    doCheck=false;
  })
  ps.numpy
  ps.typing-extensions
]
