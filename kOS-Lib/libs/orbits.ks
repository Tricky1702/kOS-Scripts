// Orbits Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/library/orbit.ks">orbit.ks</a>
// Acknowledgement: Steven Mading, <a href="https://github.com/Dunbaratu/kerboscripts/blob/master/lib/prediction.ks">prediction.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_ORBITS is scriptpath().

  local _oBodies is list(). list bodies in _oBodies.
  local _oNames is list(). for bod in _oBodies _oNames:add(bod:name).

  local lngToDeg is { parameter l. if not l:istype("Scalar") return 0. return mod(l + 360, 360). }.
  local orbitable is
  {
    parameter o.

    if not o:istype("String")
    {
      if o:hassuffix("name") set o to o:name.
      else { sysioNotifyError("orbits/orbitable::Param 1 `" + o:tostring + "' not a String!"). return 0. }
    }
    if _oNames:contains(o) return body(o).

    local orbs is list(). list targets in orbs. orbs:add(ship).

    for orb in orbs if orb:name = o return vessel(o).

    sysioNotifyWarn("orbits/orbitable::`" + o + "' not found!").

    return 0.
  }.
  // Angular velocity of the orbitable.
  // Returns: Angular velocity (ms⁻¹)
  local angVel is
  {
    parameter o is ship.

    if o:istype("String") set o to orbitable(o).
    if o:istype("Vessel") return sqrt(o:body:mu / (o:body:radius + o:altitude)).
    if o:istype("Body") return o:angularvel:mag.

    sysioNotifyWarn("orbits/angVel::Param 1 `" + o:tostring + "' not found!").

    return 0.
  }.
  // Geostationary orbit radius for the local body.
  // Returns: A radius (m)
  // * r = ∛(μ/ω²)
  // * μ = Geocentric gravitational constant of the local body (m³s⁻²)
  // * ω = Angular velocity of the local body (ms⁻¹)
  local geoOrbit is
  {
    parameter o is body.

    if o:istype("String") set o to orbitable(o).
    if o:istype("Vessel") set o to o:body.
    else if not o:istype("Body") set o to body.

    return cbrt(o:mu / o:angularvel:mag^2).
  }.
  local phaseAngle is
  {
    parameter tgt, src is ship.

    if tgt:istype("String") set tgt to orbitable(tgt).
    if src:istype("String") set src to orbitable(src).
    if not tgt:istype("Orbitable") { sysioNotifyWarn("orbits/phaseAngle::Param 1 `" + tgt:tostring + "' not an Orbitable!"). return -1. }
    if not src:istype("Orbitable") { sysioNotifyWarn("orbits/phaseAngle::Param 2 `" + src:tostring + "' not an Orbitable!"). return -1. }

    local a1 is src:obt:lan + src:obt:argumentofperiapsis + src:obt:trueanomaly.
    local a2 is tgt:obt:lan + tgt:obt:argumentofperiapsis + tgt:obt:trueanomaly.
    local a3 is a2 - a1.

    return a3 - 360 * floor(a3 / 360).
  }.
  local phaseAngleTransfer is
  {
    parameter tgt, src is ship.

    if tgt:istype("String") set tgt to orbitable(tgt).
    if src:istype("String") set src to orbitable(src).
    if not tgt:istype("Orbitable") { sysioNotifyWarn("orbits/phaseAngleTransfer::Param 1 `" + tgt:tostring + "' not an Orbitable!"). return -1. }
    if not src:istype("Orbitable") { sysioNotifyWarn("orbits/phaseAngleTransfer::Param 2 `" + src:tostring + "' not an Orbitable!"). return -1. }

    return constant:pi * (1 - (1 / (2 * sqrt(2))) * sqrt((src:obt:semimajoraxis / tgt:obt:semimajoraxis + 1)^3)) * constant:RadToDeg.
  }.
  local vNormal is { return vcrs(ship:velocity:orbit, -body:position):normalized. }.
  local vAntiNormal is { return -vNormal(). }.
  local vRadialIn is { local vn is vNormal(). return vcrs(ship:velocity:orbit, vn):normalized. }.
  local vRadialOut is { return -vRadialIn(). }.
  local vSrfPro is { return ship:velocity:surface:normalized. }.
  local vSrfRetro is { return -vSrfPro(). }.
  local dNormal is { return lookdirup(vNormal, up:vector). }.
  local dAntiNormal is { return lookdirup(vAntiNormal, up:vector). }.
  local dRadialIn is { return lookdirup(vRadialIn, up:vector). }.
  local dRadialOut is { return lookdirup(vRadialOut, up:vector). }.
  local dSrfPro is { return lookdirup(vSrfPro, up:vector). }.
  local dSrfRetro is { return lookdirup(vSrfRetro, up:vector). }.
  local etaToApo is
  {
    parameter craft is ship.

    if not craft:istype("Vessel") { sysioNotifyWarn("orbits/etaToApo::Param 1 `" + craft:tostring + "' not a Vessel!"). return 0. }
    if craft:obt:eccentricity > 1 { sysioNotifyWarn("orbits/etaToApo::Param 1 `" + craft:name + "' eccentricity > 1!"). return 0. }
    if craft:name = shipname return eta:apoapsis.

    local r1 is craft:body:radius + altitude.
    local r2 is craft:body:radius + craft:obt:apoapsis.
    local tta is constant:pi * sqrt((r1 + r2)^3 / (8 * craft:body:mu)).
    local ut1 is time:seconds + 3600 / craft:obt:period.

    if r1 > (positionat(craft, ut1) - craft:body:position):mag
      set tta to tta + craft:obt:period / 2.

    return tta.
  }.
  local etaToPeri is
  {
    parameter craft is ship.

    if not craft:istype("Vessel") { sysioNotifyWarn("orbits/etaToPeri::Param 1 `" + craft:tostring + "' not a Vessel!"). return 0. }
    if craft:name = shipname return eta:periapsis.

    local r1 is craft:body:radius + altitude.
    local r2 is craft:body:radius + craft:obt:periapsis.
    local ttp is constant:pi * sqrt((r1 + r2)^3 / (8 * craft:body:mu)).
    local ut1 is time:seconds + 3600 / craft:obt:period.

    if r1 < (positionat(craft, ut1) - craft:body:position):mag
      set ttp to ttp + craft:obt:period / 2.

    return ttp.
  }.
  local timePeriToTA is
  {
    parameter
      iobt,  // orbit to predict for
      TAdeg. // true anomaly we're looking for, in degrees.

    if not iobt:istype("Orbit") { sysioNotifyWarn("orbits/timePeriToTA::Param 1 `" + iobt:tostring + "' not an Orbit!"). return -1. }
    if not TAdeg:istype("Scalar") { sysioNotifyWarn("orbits/timePeriToTA::Param 2 `" + TAdeg:tostring + "' not a Scalar!"). return -1. }

    local ecc is iobt:eccentricity.
    local sma is iobt:semimajoraxis.
    local e_anom_deg is arctan2(sqrt(1 - ecc^2) * sin(TAdeg), ecc + cos(TAdeg)).
    local e_anom_rad is e_anom_deg * DegToRad.
    local m_anom_rad is e_anom_rad - ecc * sin(e_anom_deg).

    return m_anom_rad / sqrt(iobt:body:mu / sma^3).
  }.
  local etaToTA is
  {
    parameter
      iobt,  // orbit to predict for.
      TAdeg. // true anomaly we're looking for, in degrees.

    if not iobt:istype("Orbit") { sysioNotifyWarn("orbits/etaToTA::Param 1 `" + iobt:tostring + "' not an Orbit!"). return -1. }
    if not TAdeg:istype("Scalar") { sysioNotifyWarn("orbits/etaToTA::Param 2 `" + TAdeg:tostring + "' not a Scalar!"). return -1. }

    local targetTime is timePeriToTA(iobt, TAdeg).
    local curTime is timePeriToTA(iobt, iobt:trueanomaly).
    local ta is targetTime - curTime.

    // If negative so we already passed it this orbit,
    // then get the one from the next orbit:
    if ta < 0 { set ta to ta + iobt:period. }

    return ta.
  }.
  local orbitNormal is
  {
    parameter iobt.

    if not iobt:istype("Orbit") return vNormal().

    return vcrs(iobt:body:position - iobt:position, iobt:velocity:orbit):normalized.
  }.
  local findAscendingNodeTA is
  {
    parameter obt1, obt2. // orbits to predict for

    if not obt1:istype("Orbit") { sysioNotifyWarn("orbits/findAscendingNodeTA::Param 1 `" + obt1:tostring + "' not an Orbit!"). return -1. }
    if not obt1:istype("Orbit") { sysioNotifyWarn("orbits/findAscendingNodeTA::Param 2 `" + obt2:tostring + "' not an Orbit!"). return -1. }

    local n1 is orbitNormal(obt1).
    local n2 is orbitNormal(obt2).
    // unit vector pointing from body's center toward the node:
    local vecBodyToNode is vcrs(n1, n2).
    // vector pointing from body's center to orbit 1's current position:
    local pos1BodyRel is obt1:position - obt1:body:position.
    // how many true anomaly degrees ahead of my current true anomaly:
    local TAahead is vang(vecBodyToNode, pos1BodyRel).

    if vmxp(n1, vecBodyToNode, pos1BodyRel) < 0
      set TAahead to 360 - TAahead.

    // Add current true anomaly to get the absolute true anomaly:
    return mod(obt1:trueanomaly + TAahead, 360).
  }.
  local hohmannTransfer is
  {
    parameter dr is false.

    if not dr:istype("Scalar") { sysioNotifyWarn("orbits/hohmannTransfer::Desired radius not set!"). return list(0, 0). }

    // Initial radius. For a circle, r1 = semimajoraxis
    local r1 is body:radius + (obt:apoapsis + obt:periapsis) / 2.
    // Desired radius
    local r2 is body:radius + dr.
    // Initial maneuver dV (ms⁻¹)
    local dV1 is sqrt(body:mu / r1) * (sqrt((2 * r2) / (r1 + r2)) - 1).
    // Final maneuver dV (ms⁻¹)
    local dV2 is sqrt(body:mu / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

    return list(dV1, dV2).
  }.
  local circularizeAtApsis is
  {
    parameter apsis is -1, etaapsis is -1.

    if not (apsis:istype("Scalar") and apsis >= 0) set apsis to obt:apoapsis.
    if not (etaapsis:istype("Scalar") and etaapsis >= 0) set etaapsis to eta:apoapsis.

    local ut is time:seconds + etaapsis.
    local bmu is body:mu.
    local br is body:radius.
    // ship orbit at ut
    local sobtut is orbitat(ship, ut).
    // actual velocity squared at ut
    local vsqrmag is sobtut:velocity:orbit:sqrmagnitude.
    // actual distance to body at ut
    local r1 is (body:position - sobtut:position):mag.
    // apsis radius after burn
    local r2 is br + apsis.
    // first dV
    local dV1 is sqrt(vsqrmag + 2 * bmu * (1 / r2 - 1 / r1)).
    // present semimajoraxis
    local sma1 is br + (obt:apoapsis + obt:periapsis) / 2.
    // // future semimajoraxis. Same as apsis radius after burn
    // local sma2 is br + apsis.
    // // second dV. Can be simplified as sma2 = r2
    // local dV2 is sqrt(vsqrmag + bmu * (2 / r2 - 2 / r1 + 1 / sma1 - 1 / sma2)).
    local dv2 is sqrt(vsqrmag + bmu * (1 / r2 - 2 / r1 + 1 / sma1)).

    // Total dV for the circularize maneuver
    return dV2 - dV1.
  }.
  local circularizeAtApoapsis is { return circularizeAtApsis(obt:apoapsis, eta:apoapsis). }.
  local circularizeAtPeriapsis is { return circularizeAtApsis(obt:periapsis, eta:periapsis). }.
  local circularize is
  {
    if eta:apoapsis <= eta:periapsis return circularizeAtApoapsis().
    else return circularizeAtPeriapsis().
  }.

  local export is lexicon
  (
    "angVelocity", angVel,
    "circularize", circularize,
    "circularizeAtApoapsis", circularizeAtApoapsis,
    "circularizeAtApsis", circularizeAtApsis,
    "circularizeAtPeriapsis", circularizeAtPeriapsis,
    "dirAntiNormal", dAntiNormal,
    "dirNormal", dNormal,
    "dirRadialIn", dRadialIn,
    "dirRadialOut", dRadialOut,
    "dirSurfacePrograde", dSrfPro,
    "dirSurfaceRetrograde", dSrfRetro,
    "etaToApoapsis", etaToApo,
    "etaToPeriapsis", etaToPeri,
    "etaToTA", etaToTA,
    "findAscendingNodeTA", findAscendingNodeTA,
    "geoOrbit", geoOrbit,
    "hohmannTransfer", hohmannTransfer,
    "longitudeToDeg", lngToDeg,
    "orbitable", orbitable,
    "orbitNormal", orbitNormal,
    "phaseAngle", phaseAngle,
    "phaseAngleTransfer", phaseAngleTransfer,
    "vecAntiNormal", vAntiNormal,
    "vecNormal", vNormal,
    "vecRadialIn", vRadialIn,
    "vecRadialOut", vRadialOut,
    "vecSurfacePrograde", vSrfPro,
    "vecSurfaceRetrograde", vSrfRetro
  ).

  sysioExport(export).
  sysioDLog("orbits lib finished!").
}.