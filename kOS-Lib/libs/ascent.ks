// Ascent Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Tony Spataro, <a href="https://github.com/xeger/kos-ramp/blob/master/launch_asc.ks>launch_asc.ks</a>
// Acknowledgement: Steven Mading, <a href="https://github.com/Dunbaratu/kerboscripts/blob/master/lib/launch.ks">launch.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_ASCENT is scriptpath().

  // Required libs
  sysioRequires
  (
    lexicon
    (
      "scriptpath", _LIBS_ASCENT,
      "input", list("automatic", "bodyCache", "engines", "maneuver"),
      "import", importLibDir,
      "export" , exportLibDir,
      "volume", exportVol
    )
  ).
  local _autoLib is sysioGetImport(lexicon("input", "automatic")).
  local _bcLib is sysioGetImport(lexicon("input", "bodyCache")).
  local _engLib is sysioGetImport(lexicon("input", "engines")).
  local _mnvLib is sysioGetImport(lexicon("input", "maneuver")).

  local doAscent is
  {
    parameter dir is -1, minApo is -1, autoStage is 0.

    if not (defined _LIBS_ENGINES) { sysioNotifyError("ascent/doAscent::No engines lib!"). return. }
    if not (defined _LIBS_AUTOMATIC) { sysioNotifyError("ascent/doAscent::No automatic lib!"). return. }
    if not dir:istype("Scalar") or dir < 0 set dir to 90.
    if not minApo:istype("Scalar") set minApo to -1.
    if not autoStage:istype("Boolean") set autoStage to true.

    local batm is body:atm. local atmAlt is batm:height. local atmLow is 0. local atmHigh is 0.
    // Get the extended data for the body we are orbiting
    local bData is getKeyWithType(_bcLib, body:name, "Lexicon", 0).
    // Figure out the lowest orbit altitude
    local lowOrbit is getKeyWithType(bData, "lowOrbit", "Scalar", 0).

    if lowOrbit = 0
    {
      if batm:exists set lowOrbit to atmAlt * 1.05.
      else set lowOrbit to body:radius * 0.125.
    }

    if minApo < lowOrbit set minApo to lowOrbit.

    local atmDiv is minApo / 3.

    if batm:exists
    {
      set atmLow to atmAlt * (1.8 / 7).
      set atmHigh to atmAlt * (3.5 / 7).
      set atmDiv to atmAlt * (5.5 / 7).
    }

    _engLib["resetChecks"]().

    // Cut down on the access times
    local burnoutCheck is _engLib["burnoutCheck"].
    local checkFairings is _autoLib["checkFairings"].
    // Throttle function
    local ascentThrottle is
    {
      local newThrot is 1. local salt is ship:altitude.
      local spd is ship:velocity:surface:mag. local cutoff is 500 + (500 * (salt / atmAlt)).

      if not (salt > atmHigh or salt <= atmLow) and spd > cutoff
        set newThrot to max(min(1 - ((spd - cutoff) / cutoff), 1), 0.2).

      printAt("New throttle: " + fmtScalar(newThrot, 5), 2, 8).
      printAt("Speed:        " + fmtScalar(spd, 3), 2, 9).
      printAt("Cutoff:       " + fmtScalar(cutoff, 3), 2, 10).

      return newThrot.
    }.
    // Steering function
    local ascentSteering is
    {
      if ship:velocity:surface:mag < 100 or ship:altitude < 1000 return heading(dir, 90).

      return heading(dir, max(90 * (1 - (ship:altitude / atmDiv)^(2 / 5)), 0)).
    }.

    local throt is ascentThrottle().
    lock throttle to throt.
    lock steering to ascentSteering().
    wait 0.01.

    clearscreen. sysioNotify("Ignition!", true).
    stage. wait until stage:ready.

    until obt:apoapsis >= minApo
    {
      set throt to ascentThrottle().

      // Lock throttle back to throt if staging happened
      if burnoutCheck(autoStage) lock throttle to throt.

      wait 0.01.

      checkFairings().
    }

    unlock throttle. unlock steering. wait 0.01.
    local w is terminal:width - 1.

    printAtPadR("", 0, 8, w).
    printAtPadR("", 0, 9, w).
    printAtPadR("", 0, 10, w).

    if batm:exists and ship:altitude < atmAlt
    {
      sysioNotify("Coasting in low thrust mode", true).

      lock steering to body:angularvel.

      until ship:altitude > atmAlt
      {
        if obt:apoapsis < minApo lock throttle to 0.05.
        else lock throttle to 0.

        wait 0.01.

        checkFairings().
        printAt("Throttle: " + fmtScalar(throttle, 5), 2, 8).
      }

      unlock throttle. unlock steering. wait 0.01.
    }

    sysioNotify("Finished ascent stage", true).
  }.
  local raisePeri is
  {
    parameter minPeri, autoStage is 0.

    if not (defined _LIBS_MANEUVER) { sysioNotifyError("ascent/raisePeri::No maneuver lib!"). return. }
    if not minPeri:istype("Scalar") { sysioNotifyError("ascent/raisePeri::Minimum periapsis not a Scalar!"). return. }
    if not autoStage:istype("Boolean") set autoStage to true.

    clearscreen.
    sysioNotify("Raising periapsis to at least " + fmtScalar(minPeri / 1000, 2, false) + "km", true).

    lock throttle to 0. lock steering to prograde. wait 0.01.

    sysioNotify("Waiting until 60s from apoapsis.", true).

    until eta:apoapsis <= 60
    {
      printAt("Apoapsis eta: " + fmtScalar(eta:apoapsis, 2), 2, 4).

      wait 0.01.
    }

    printAtPadR("", 0, 4, terminal:width - 1).

    // Use the circularizeAtApsis method to create a burn 10 seconds before the apoapsis
    _mnvLib["circularizeAtApsis"](obt:apoapsis, eta:apoapsis - 10).
    // Stage if needed and end the burn early once minimum periapsis is reached
    _mnvLib["execNode"](autoStage, { return obt:periapsis >= minPeri. }).

    sysioNotify("Periapsis: " + fmtScalar(obt:periapsis / 1000, 2, false) + "km", true).
  }.

  local export is lexicon
  (
    "doAscent", doAscent,
    "raisePeriapsis", raisePeri
  ).

  sysioExport(export).
}.