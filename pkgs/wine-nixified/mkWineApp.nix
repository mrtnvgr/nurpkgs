{ mkWineEnv, writeScriptBin, lib, runtimeShell }:

{ name

, executable
, workdir ? null

, preScript ? ""
, postScript ? ""

, isWindowsExe ? true
, wineFlags ? ""

} @ envArgs:

let
  inherit (lib) optionalString;

  env = mkWineEnv (envArgs // {
    inherit name;
  });
in

writeScriptBin name /* bash */ ''
  #!${runtimeShell}

  . ${env}

  # $REPL is defined => start a shell in the env
  if [ ! "$REPL" == "" ]; then
    bash; exit 0
  fi

  ${optionalString (workdir != null) "cd \"${workdir}\""}

  ${preScript}

  ${optionalString isWindowsExe "wine ${wineFlags}"} "${executable}" "$@"

  wineserver -w

  ${postScript}
''
