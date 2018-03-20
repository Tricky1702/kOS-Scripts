// Rendezvous Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/library/rendezvous.ks">rendezvous.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_RENDEZVOUS is scriptpath().

  // Required libs
  sysioRequires
  (
    lexicon
    (
      "scriptpath", _LIBS_RENDEZVOUS,
      "input", list("maneuver", "orbits"),
      "import", importLibDir,
      "export", exportLibDir,
      "volume", exportVol
    )
  ).
  local _orbLib is sysioGetImport(lexicon("input", "orbits")).
  local _mnvLib is sysioGetImport(lexicon("input", "maneuver")).

  // Internal
  local _apCraft is
  {
    parameter craft, pos, aSpd.

    _mnvLib["steer"](pos, 10). lock steering to pos. wait 0.01.

    // Cut down on the access time
    local mnvTime is _mnvLib["timeForManeuver"].
    lock rV to craft:velocity:orbit - ship:velocity:orbit.
    lock aV to abs(aSpd - rV:mag).
    lock throt to max(min(mnvTime(aV), 1), 0.1).
    lock throttle to throt. wait 0.01.

    until rV:mag >= aSpd
    {
      printAt("Throttle:          " + fmtScalar(throttle, 3), 2, 2).
      printAt("Relative velocity: " + fmtScalarA(rV:mag, "ms⁻¹", 3), 2, 3).

      wait 0.01.
    }

    lock throttle to 0. wait 0.01.
    unlock rV. unlock aV. unlock throt.
  }.
  local approachTrailing is
  {
    parameter craft.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("rendezvous/approachTrailing::No orbits lib!"). return. }
    if not (defined _LIBS_MANEUVER) { sysioNotifyError("rendezvous/approachTrailing::No maneuver lib!"). return. }
    if not craft:istype("Vessel") { sysioNotifyWarn("rendezvous/approachTrailing::Craft not a vessel!"). return. }

    // Are we actually leading in front of the craft
    local ang is _orbLib["phaseAngle"](craft).

    if ang >= 180 and ang < 360 { approachLeading(craft). return. }

    clearscreen. sysioNotify("[Trailing] Approaching " + craft:name, true).
    _apCraft(craft, positionat(craft, time:seconds + 25), max(craft:distance / 150, 50)).
  }.
  local approachLeading is
  {
    parameter craft.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("rendezvous/approachLeading::No orbits lib!"). return. }
    if not (defined _LIBS_MANEUVER) { sysioNotifyError("rendezvous/approachLeading::No maneuver lib!"). return. }
    if not craft:istype("Vessel") { sysioNotifyWarn("rendezvous/approachLeading::Craft not a vessel!"). return. }

    // Are we actually trailing behind the craft
    local ang is _orbLib["phaseAngle"](craft).

    if ang >= 0 and ang < 180 { approachTrailing(craft). return. }

    clearscreen. sysioNotify("[Leading] Approaching " + craft:name, true).
    _apCraft(craft, positionat(craft, time:seconds + 10), max(craft:distance / 150, 30)).
  }.
  local approach is
  {
    parameter craft.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("rendezvous/approach::No orbits lib!"). return. }
    if not (defined _LIBS_MANEUVER) { sysioNotifyError("rendezvous/approach::No maneuver lib!"). return. }
    if not craft:istype("Vessel") { sysioNotifyWarn("rendezvous/approach::Craft not a vessel!"). return. }

    local deltaT is 0. local maxVel is 0. local ang is _orbLib["phaseAngle"](craft).

    if ang >= 0 and ang < 180 { set deltaT to 25. set maxVel to 50. }
    else { set deltaT to 10. set maxVel to 30. }

    _apCraft(craft, positionat(craft, time:seconds + deltaT), max(craft:distance / 150, maxVel)).
  }.
  local awaitNearest is
  {
    parameter craft, aDist is 0.

    if not craft:istype("Vessel") { sysioNotifyWarn("rendezvous/awaitNearest::Craft not a vessel!"). return. }
    if not (aDist:istype("Scalar") and aDist > 0) set aDist to 200.

    lock throttle to 0.
    lock steering to craft:velocity:orbit - ship:velocity:orbit.
    wait 0.01.

    clearscreen. sysioNotify("Waiting for nearest approach with " + craft:name, true).

    local lDist is craft:distance. wait 0.5.
    lock deltaD to lDist - craft:distance.

    until deltaD < 0 or craft:distance <= aDist
    {
      printAt("Distance:       " + fmtScalarA(craft:distance, "m", 1), 2, 2).
      printAt("Last distance:  " + fmtScalarA(lDist, "m", 1), 2, 3).
      printAt("deltaD:         " + fmtScalarA(deltaD, "m", 3), 2, 4).
      printAt("Approach speed: " + fmtScalarA(deltaD / 0.5, "ms⁻¹", 1), 2, 5).

      set lDist to craft:distance. wait 0.5.
    }

    unlock deltaD.
  }.
  /// <summary>
  /// </summary>
  /// <param name="craft"><see cref="Vessel" /> to approach.</param>
  /// <param name="maxDist"><see cref="Scalar" /> distance of the maximum flyby (m).</param>
  /// <param name="aDist"><see cref="Scalar" /> distance of the maximum approach to the craft (m).</param>
  local rendezvous is
  {
    parameter craft, maxDist is 0, aDist is 0.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("rendezvous/rendezvous::No orbits lib!"). return. }
    if not (defined _LIBS_MANEUVER) { sysioNotifyError("rendezvous/rendezvous::No maneuver lib!"). return. }
    if not craft:istype("Vessel") { sysioNotifyWarn("rendezvous/rendezvous::Craft not a vessel!"). return. }
    if not (maxDist:istype("Scalar") and maxDist > 0) set maxDist to 10000.
    if not (aDist:istype("Scalar") and aDist > 0) set aDist to 200.

    lock steering to craft:velocity:orbit - ship:velocity:orbit. wait 0.01.
    local ang is _orbLib["phaseAngle"](craft).

    // Are we actually leading in front of the craft and nore than 97.5% of the maxDist away
    // Leading the target so raise the orbit to allow it to catch up
    if ang >= 180 and ang < 360 and craft:distance > maxDist * 0.975
      _mnvLib["changeOrbit"]((craft:obt:semimajoraxis - body:radius) + (maxDist * 0.8), eta:periapsis, false, craft:obt:eccentricity > 0.0025).

    clearscreen. sysioNotify("Awaiting flyby of " + fmtScalarA(maxDist / 1000, "km", 1, false), true).

    until craft:distance < maxDist * 1.025
    {
      printAt("Distance: " + fmtScalarA(craft:distance / 1000, "km", 1), 2, 2).

      wait 1.
    }

    // Cut down on the access times
    local cancel is _mnvLib["cancel"].

    clearscreen. sysioNotify("Approaching to " + fmtScalarA(aDist, "m", 1, false), true).
    cancel(craft).

    until craft:distance <= aDist
    {
      approach(craft).
      awaitNearest(craft, aDist).
      cancel(craft).
    }

    sysioNotify("Within " + fmtScalarA(aDist, "m", 1, false)).

    lock throttle to 0. unlock steering. wait 0.01.
  }.

  local export is lexicon
  (
    "approach", approach,
    "approachLeading", approachLeading,
    "approachTrailing", approachTrailing,
    "awaitNearest", awaitNearest,
    "rendezvous", rendezvous
  ).

  sysioExport(export).
}.