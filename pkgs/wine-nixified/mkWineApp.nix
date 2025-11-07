{ mkWineEnv, writeShellApplication, lib }:

{ name

, executable
, workdir ? null

, preScript ? ""
, postScript ? ""

, isWindowsExe ? true
, wineFlags ? ""

, meta ? { }

, allowSubstitutes ? false

, ...
} @ envArgs:

let
  inherit (lib) optionalString;

  env = mkWineEnv (envArgs // {
    inherit name allowSubstitutes;
  });
in
writeShellApplication {
  inherit name meta allowSubstitutes;

  runtimeInputs = [ env ];

  text = /* bash */ ''
    source ${name}

    # $REPL is defined => start a shell in the env
    if [ ! "$REPL" == "" ]; then
      bash; exit 0
    fi

    ${optionalString (workdir != null) "cd \"${workdir}\""}

    ${preScript}

    ${optionalString isWindowsExe "wine ${wineFlags}"} "${executable}" "$@"

    wineserver -w

    ${postScript}
  '';
}
