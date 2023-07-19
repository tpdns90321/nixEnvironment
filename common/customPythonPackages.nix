{ ps, inputs, lib }:

let buildPythonPackageFromFlake = { name, ... }@attrs:
  ps.buildPythonPackage (
  lib.trivial.mergeAttrs {
    pname = name;
    src = inputs.${name}.outPath;
  } attrs); in [
    (buildPythonPackageFromFlake {
      name = "guidance";
      doCheck = false;
      propagatedBuildInputs = [
        ps.diskcache
        ps.platformdirs
        ps.msal
        ps.pyparsing
        ps.pygtrie
        ps.tiktoken
        ps.nest-asyncio
        (buildPythonPackageFromFlake {
          name = "openai";
          propagatedBuildInputs = [ ps.tqdm ps.aiohttp ps.requests ];
          doCheck = false;
        })
        (buildPythonPackageFromFlake {
          name = "gptcache";
          doCheck = false;
          propagatedBuildInputs = [
            ps.numpy
            ps.cachetools
            ps.requests
            ps.httpx
            ps.transformers
            (buildPythonPackageFromFlake {
              name = "selective_context";
              format = "pyproject";
              nativeBuildInputs = [ ps.setuptools ];
              propagatedBuildInputs = [ ps.transformers ps.torch ps.nltk ps.spacy ];
            })
          ];
        })
      ];
    })
  ]
