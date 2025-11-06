{ stdenv, lib, writeScriptBin, cabextract, winetricks, runtimeShell, wine-staging }:
let
  inherit (builtins) length concatStringsSep;
  inherit (lib) makeBinPath optionalString;
in
{ name
, is64bits ? stdenv.hostPlatform.system == "x86_64-linux"

, tricks ? [ ]
, silent ? true

, setupScript ? ""

, wine ? wine-staging

, fsync ? false
, esync ? false
}:
let
  requiredPackages = [ wine cabextract ];

  tricksHook = optionalString ((length tricks) > 0) /* bash */ ''
    pushd $(mktemp -d)
      ${winetricks}/bin/winetricks ${optionalString silent "-q"} ${concatStringsSep " " tricks}
    popd
  '';

  boolToInt = x: if x then "1" else "0";
in writeScriptBin name /* bash */ ''
  #!${runtimeShell}

  WINEARCH=win${if is64bits then "64" else "32"}

  WINEFSYNC=${boolToInt fsync}
  WINEESYNC=${boolToInt esync}

  PATH=${makeBinPath requiredPackages}:$PATH

  WINE_NIX="$HOME/.wine-nix"
  WINEPREFIX="$WINE_NIX/${name}"
  mkdir -p "$WINE_NIX"

  if [ ! -d "$WINEPREFIX" ]; then
    wineboot --init
    wineserver -w

    ${tricksHook}
    wineserver -w

    ${setupScript}
  fi
''
