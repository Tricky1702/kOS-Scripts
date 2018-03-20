// test

@LAZYGLOBAL off.
{
  local _ipu is config:ipu.
  // set config:ipu to 500.

  // Open the terminal for the user
  core:doevent("Open Terminal").

  print "Core volume capacity:  " + core:volume:capacity.
  print "Core volume freespace: " + core:volume:freespace.

  local sp is scriptpath().

  print "sp: `" + sp:tostring + "'".  

  local kLib is "kOS-Lib".
  local initMaster is "0:/" + kLib + "/init.ks". local initLocal is "1:/init.ksm".

  // Only do this in Kerbin's SOI
  if homeconnection:isconnected and kerbin:distance < kerbin:soiradius and exists(initMaster)
    compile initMaster to initLocal.

  switch to 1.

  if exists(initLocal) runoncepath(initLocal, lexicon("compile", true, "debug", "0:/" + kLib + "debug.log", "keep", list("*"), "roundtrip", true)).

  print "Core volume freespace: " + core:volume:freespace.

  // Done
  if defined _LIBG_COMMON and defined _LIBG_SYSIO
  {
    sysioNotify("Test", true).
    sysioNotifyWarn("Test warn").
    sysioNotifyError("Test error").

    local helperLibs is list("bodyCache", "orbits", "telemetry", "maneuver").
    local libs is list
    (
      "ascent",
      "automatic",
      "bodyCache",
      "comms",
      "docking",
      "dockingports",
      "engines",
      "maneuver",
      "orbits",
      "rendezvous",
      "telemetry"
    ).

    local h is sysioRequires
    (
      lexicon
      (
        "scriptpath", sp,
        "input", helperLibs,
        "import", importLibDir,
        "export", exportLibDir,
        "volume", exportVol
      )
    ).
    local t is sysioRequires
    (
      lexicon
      (
        "scriptpath", sp,
        "input", libs,
        "import", importLibDir,
        "export", exportLibDir,
        "volume", exportVol
      )
    ).
    sysioImport
    (
      lexicon
      (
        "input", "comms",
        "import", importLibDir,
        "export", exportLibDir
      )
    ).
    local commsLib is sysioRun
    (
      lexicon
      (
        "input", "comms",
        "directory", exportLibDir
      )
    ).

    print "Core volume freespace: " + core:volume:freespace.

    sysioImport
    (
      lexicon
      (
        "input", list("ferry/ferry", "ksat1/ksat1", "kss/kss"),
        "import", "craft",
        "export", "",
        "volume", exportVol
      )
    ).

    print "Core volume freespace: " + core:volume:freespace.

    local orbitsLib is sysioGetImport
    (
      lexicon
      (
        "input", "orbits",
        "directory", exportLibDir
      )
    ).
    local telemLib is sysioGetImport
    (
      lexicon
      (
        "input", "telemetry",
        "directory", exportLibDir
      )
    ).

    print "Core volume freespace: " + core:volume:freespace.

    // clearscreen.
    commsLib["waitRoundtrip"]("Kerbin", 2, terminal:height - 1).

    sysioDebugOn("0:/" + kLib + "test.log").
    sysioDLog("**** h:dump. ****").
    sysioDLog(h:dump).
    sysioDLog("**** t:dump. ****").
    sysioDLog(t:dump).
    sysioDLog("**** automatic:dump. and engines:dump. ****").
    sysioDLog
    (
      sysioGetImport
      (
        lexicon
        (
          "input", list("automatic", "engines"),
          "directory", exportLibDir
        )
      ):dump
    ).
    sysioDLog("**** orbitsLib:dump. ****").
    sysioDLog(orbitsLib:dump).
    sysioDLog("**** telemLib:dump. ****").
    sysioDLog(telemLib:dump).

    local bl is list(). list bodies in bl.

    for b in bl
    {
      local batm is b:atm.

      if batm:exists
      {
        sysioDPrint("Calculating aerocapture height for `" + b:name + "'").

        // Use a binary search to find aerocapture height at 0.002 atmospheric pressure.
        local bpAeroCap is 0.002.
        // First guess at half way between the surface and the top of the atmosphere.
        local bhAeroCap to batm:height / 2. local aeroCapDiff is bhAeroCap.
        // Find the pressure at this altitude.
        local p is batm:altitudePressure(bhAeroCap). local i is 0.

        until i >= 32 or nearlyEquals(p, bpAeroCap)
        {
          set i to i + 1. set aeroCapDiff to aeroCapDiff / 2.

          // Too high.
          if p < bpAeroCap set bhAeroCap to bhAeroCap - aeroCapDiff.
          // Too low.
          else if p > bpAeroCap set bhAeroCap to bhAeroCap + aeroCapDiff.

          set p to batm:altitudePressure(bhAeroCap).
        }

        sysioDPrint("* (" + ("" + i):padleft(2) + ") " + fmtScalar(bhAeroCap, 2, false)).
      }
    }

    local vessels is list(). list targets in vessels.
    local vs is vessels[floor(random() * vessels:length)].

    print vs:name + ": Phase angle = " + fmtScalar(orbitsLib["phaseAngle"](vs)).
    print vs:name + ": Roundtrip =   " + fmtScalar(commsLib["roundtrip"](vs)).
    print "dV: " + fmtScalar(telemLib["deltaV"](), 5).
    print "TTI: " + fmtScalar(telemLib["timeToImpact"](), 2).
    print "Impact velocity: " + fmtScalar(telemLib["velocityAtImpact"](), 3).

    print "Deleting telemLib".

    sysioDelete
    (
      lexicon
      (
        "input", "telemetry",
        "directory", exportLibDir
      )
    ).

    print "Core volume freespace: " + core:volume:freespace.
    print "Deleting orbitsLib".

    sysioDelete(orbitsLib).

    print "Core volume freespace: " + core:volume:freespace.
    print "Deleting all libs".

    sysioDeleteAll().

    print "Core volume freespace: " + core:volume:freespace.
    print "Deleting exportLibDir".

    if exportLibDir <> "" and exists(exportLibDir) deletepath(exportLibDir).
    if exists("kOS-Lib") deletepath("kOS-Lib").
    if exists("ferry") deletepath("ferry").
    if exists("ksat1") deletepath("ksat1").
    if exists("kss") deletepath("kss").

    print "Core volume freespace: " + core:volume:freespace.
  }
  else
  {
    print "common: " + (defined _LIBG_COMMON).
    print "sysio:  " + (defined _LIBG_SYSIO).
  }

  set config:ipu to _ipu.
}.