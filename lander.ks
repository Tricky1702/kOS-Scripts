// Lander script
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  parameter _l is lexicon().
  local _c is false. local _d is "0:/lander.log". local _rt is false.

  if _l:istype("Lexicon")
  {
    if _l:haskey("compile") and _l["compile"]:istype("Boolean") set _c to _l["compile"].
    if _l:haskey("debug") and _l["debug"]:istype("String") set _d to _l["debug"].
    if _l:haskey("roundtrip") and _l["roundtrip"]:istype("Boolean") set _rt to _l["roundtrip"].
  }

  local _hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.
  local _ipu is config:ipu. // set config:ipu to 1000.
  local kLib is "kOS-Lib".
  local initMaster is "0:/" + kLib + "/init.ks". local initLocal is "1:/init.ksm".

  // Only do this in Kerbin's SOI
  if _hc() and kerbin:distance < kerbin:soiradius and exists(initMaster)
    compile initMaster to initLocal.

  switch to 1.

  if exists(initLocal) runoncepath(initLocal, lexicon("compile", _c, "debug", _d, "roundtrip", _rt)).

  if defined _LIBG_COMMON and defined _LIBG_SYSIO
  {
    local bcLib is sysioRequires
    (
      lexicon
      (
        "scriptpath", scriptpath(),
        "input", "bodyCache",
        "import", importLibDir,
        "export", exportLibDir,
        "volume", exportVol
      )
    ).
    local mnvLib is sysioRequires
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
    local bData is getKeyWithType(bcLib, body:name, "Lexicon", 0).
    local maxVel is getKeyWithType(bData, "landingSpeed", "Scalar", 2).

    clearscreen.

    if status = "Landed" or status = "Prelaunch"
    {
      stage. wait until stage:ready.

      local mThr is maxthrust.

      until mThr - maxthrust > 10 { printAt("mThr - maxthrust: " + fmtScalar(mThr - maxthrust, 5), 0, 2). wait 0.1. }

      stage. wait until stage:ready.

      lock throttle to 1. wait 0.25.
      unlock throttle. wait 0.01.
    }

    printAtPadR("Waiting to fall.", 0, 2, terminal:width - 1).

    wait until alt:radar > 100 and verticalspeed < -7.

    local _sas is sas. local _rcs is rcs.

    sas off. rcs off.
    set ship:control:pilotmainthrottle to 0.
    lock throttle to 0. lock steering to retrograde. wait 0.01.

    printAtPadR("Starting lander burn...", 0, 2, terminal:width - 1).
    mnvLib["lander"](maxVel).
    printAtPadR("Status: " + status, 0, 2, terminal:width - 1).

    clearvecdraws().

    unlock steering. unlock throttle. wait 0.01.
    set ship:control:pilotmainthrottle to 0.
    set ship:control:neutralize to true.
    set sas to _sas. set rcs to _rcs.

    sysioDeleteAll().
  }
  else
  {
    print "common: " + (defined _LIBG_COMMON).
    print "sysio:  " + (defined _LIBG_SYSIO).
  }

  set config:ipu to _ipu.
}.