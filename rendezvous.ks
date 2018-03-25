// Rendezvous script
// Copyright © 2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  parameter _l is lexicon().
  local _c is false. local _d is "0:/rendezvous.log". local _rt is false.

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
    sysioRequires(lexicon("scriptpath", scriptpath(), "input", list("orbits", "maneuver", "rendezvous"))).

    clearscreen.

    if not hastarget
    {
      sysioNotify("Select a target.", true).

      wait until hastarget.
    }

    local _sas is sas. local _rcs is rcs.

    sas off. rcs off.
    set ship:control:pilotmainthrottle to 0.
    lock throttle to 0. lock steering to prograde. wait 0.01.

    local orbLib is sysioGetImport(lexicon("input", "orbits")).
    local mnvLib is sysioGetImport(lexicon("input", "maneuver")).
    local rdvLib is sysioGetImport(lexicon("input", "rendezvous")).

    if obt:eccentricity > 0.0025
    {
      mnvLib["addCircularizeNode"]().
      mnvLib["execNode"](true).
    }

    if not nearlyEquals(obt:inclination, target:obt:inclination, 0.01)
    {
      mnvLib["addInclinationMatchNode"](target:obt).
      mnvLib["execNode"]().
    }

    // Match orbit
    if tgt:obt:eccentricity > 0.0025
    {
      // Target orbit is eccentric
      local tobt is orbitat(target, time:seconds + orbLib["etaToPeriapsis"](target)).
      local a1 is obt:lan + obt:argumentofperiapsis + obt:trueanomaly.
      local a2 is tobt:lan + tobt:argumentofperiapsis + tobt:trueanomaly.
      local a3 is a2 - a1.
      local tang is a3 - 360 * floor(a3 / 360).
      local tgtEtaPeri is obt:period * (tang / 360).
      local etaBurn is obt:period / 2.

      if etaBurn > tgtEtaPeri set etaBurn to etaBurn + tgtEtaPeri.
      else set etaBurn to tgtEtaPeri - etaBurn.

      mnvLib["addNode"](target:obt:apoapsis - 8000, etaBurn, false).
      mnvLib["execNode"]().
      mnvLib["addNode"](target:obt:periapsis - 8000, eta:apoapsis, false).
      mnvLib["execNode"]().
    }
    else
    {
      // Target orbit is circular
      local phAng is orbLib["phaseAngle"](target).
      local phAngTr is orbLib["phaseAngleTransfer"](target).
      local angDiff is mod(360 + (phAng - phAngTr), 360).
      local etaBurn is obt:period * (angDiff / 360).

      mnvLib["addHohmannNodes"](target:obt:apoapsis - 8000, etaBurn, false).
      mnvLib["execNode"]().
    }

    rdvLib["rendezvous"](target).

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