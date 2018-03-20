// Node burn script
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  parameter _l is lexicon().
  local _c is false. local _d is "0:/kOS-Lib/nodeburn.log". local _rt is false.

  if _l:istype("Lexicon") and _l:length > 0
  {
    if _l:haskey("compile") and _l["compile"]:istype("Booloean") set _c to _l["compile"].
    if _l:haskey("debug") and _l["debug"]:istype("String") set _d to _l["debug"].
    if _l:haskey("roundtrip") and _l["roundtrip"]:istype("Booloean") set _rt to _l["roundtrip"].
  }

  local _hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.
  local kLib is "kOS-Lib".
  local initMaster is "0:/" + kLib + "/init.ks". local initLocal is "1:/init.ksm".

  // Only do this in Kerbin's SOI
  if _hc() and kerbin:distance < kerbin:soiradius and exists(initMaster)
    compile initMaster to initLocal.

  switch to 1.

  if exists(initLocal) runoncepath(initLocal, lexicon("compile", _c, "debug", _d, "roundtrip", _rt)).

  if defined _LIBG_COMMON and defined _LIBG_KNU
  {
    local mnvLib is knuRequires
    (
      lexicon
      (
        "scriptpath", scriptpath(),
        "input", "maneuver",
        "import", importLibDir,
        "export", exportLibDir,
        "volume", exportVol
      )
    ).

    mnvLib["execNode"]().
    knuDelete(mnvLib).

    if exists(exportLibDir) deletepath(exportLibDir).
  }
}.