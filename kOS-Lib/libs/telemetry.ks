// Telemetry Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/library/telemetry.ks">telemetry.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_TELEMETRY is scriptpath().

  // Gravitational acceleration (ms⁻²) in the local SOI
  local ga is { return body:mu / (body:radius + altitude)^2. }.
  // Ship's dV
  local dV is
  {
    parameter engs is 0.

    if not engs:istype("List") set engs to list().
    if engs:empty list engines in engs.
    if engs:empty return 0.

    local sDryMass is mass - ((ship:liquidfuel + ship:oxidizer) * 0.005).

    return engs[0]:isp * g0 * ln(mass / sDryMass).
  }.
  local calcAltAdj is
  {
    local lx is lexicon
    (
      "LT-2 Landing Strut", 1.7,
      "LT-1 Landing Struts", 1.6,
      "LT-05 Micro Landing Strut", 0.95
    ).
    local adj is 0. local pl is list(). list parts in pl.

    for p in pl
    {
      local ph is vdot(-facing:vector, p:position - ship:rootpart:position). local pt is p:title.

      if lx:haskey(pt) set ph to ph + lx[p:title].
      else if pt:contains("Strut") or pt:contains("Land") or pt:contains("Gear") set ph to ph + 1.5.

      set adj to max(ph, adj).
    }

    return adj.
  }.
  // Time to impact
  local TTI is
  {
    parameter m is "", ht is "".

    if not m:istype("Scalar") set m to 0.
    if not ht:istype("Scalar") set ht to alt:radar.

    local d is max(ht - m, 0). local gAcc is ga(). local vs is verticalspeed.

    return (sqrt(vs^2 + 2 * gAcc * d) + vs) / gAcc.
  }.
  // v = u + at
  local velAtImpact is
  {
    parameter t is -1.

    if not (t:istype("Scalar") and t >= 0) set t to TTI().

    return (-verticalspeed + abs(groundspeed)) + (ga() - maxthrust / mass) * t.
  }.
  // Internal
  local _rotPos is
  {
    parameter bod, p, t.
    local angVel is bod:angularvel.

    if t = 0 or angVel:sqrmagnitude = 0 return ship:position.

    // Quaternion.AngleAxis
    local deg is -t * (angVel:mag * constant:RadToDeg) * 0.5.
    local quatXYZ is angVel:normalized * sin(deg). local quatW is cos(deg).
    // Quaternion.Normalize
    local sc is 1 / sqrt(quatXYZ:sqrmagnitude + quatW^2).
    set quatXYZ to quatXYZ * sc. set quatW to quatW * sc.

    return q(quatXYZ:x, quatXYZ:y, quatXYZ:z, quatW) * p.
  }.
  local aboveGnd is
  {
    parameter bod is 0, p is 0.

    if not bod:istype("Body") set bod to body.
    if not p:istype("Vector") set p to ship:position.

    local th is bod:geopositionof(p):terrainheight. local ba is bod:altitudeof(p).

    if th < ba return 1. if th > ba return -1. return 0.
  }.
  // Predicted impact time
  local _cache_iTime is 0.
  local iTime is
  {
    parameter iEnd is _cache_iTime.

    if verticalspeed >= 0 { set _cache_iTime to 0. return 0. }
    if not (iEnd:istype("Scalar") and iEnd >= 0) set iEnd to eta:periapsis.
    else set iEnd to ceiling(iEnd).

    local sp is ship:position. local iStart is 0. local cnt is 0.

    until abs(iEnd - iStart) < 0.1
    {
      if cnt = 100 { set _cache_iTime to 0. return 0. }

      local mid is (iStart + iEnd) * 0.5. local p is _rotPos(body, sp, mid).

      if body:geopositionof(p):terrainheight < body:altitudeof(p) set iEnd to mid.
      else set iStart to mid.

      set cnt to cnt + 1.
    }

    set _cache_iTime to iEnd.

    return iEnd.
  }.
  // Predicted impact position
  local iPos is
  {
    parameter useTrajectories is 0.

    if not useTrajectories:istype("Boolean") set useTrajectories to true.
    if verticalspeed >= 0 return geoposition.
    if useTrajectories and addons:tr:available { if addons:tr:hasimpact return addons:tr:impactpos. return geoposition. }

    return body:geopositionof(_rotPos(body, sp, iTime())).
  }.
  local slope is
  {
    parameter p is 0, d is 0.

    if not p:istype("GeoCoordinates")
    {
      if addons:tr:available and addons:tr:hasimpact set p to addons:tr:impactpos.
      else set p to geoposition.
    }
    if not (d:istype("Scalar") and d > 0) set d to 5.

    local adj is (d * 360) / (twoPi * body:radius).
    local plat is p:lat. local plng is p:lng.
    local slat is plat - adj. local nlat is plat + adj. local wlng is plng - adj. local elng is plng + adj.
    local pnw is latlng(nlat, wlng).
    local pne is latlng(nlat, elng).
    local ps is latlng(slat, plng).
    local nwv is pnw:altitudeposition(pnw:terrainheight).
    local nev is pne:altitudeposition(pne:terrainheight).
    local sv is ps:altitudeposition(ps:terrainheight).

    return vang(vcrs(sv - nwv, sv - nev), p:position - body:position).
  }.

  local export is lexicon
  (
    "aboveGround", aboveGnd,
    "calcAltitudeAdjust", calcAltAdj,
    "deltaV", dV,
    "impactPosistion", iPos,
    "impactTime", iTime,
    "gAcc", ga,
    "totalAcceleration", { return ga() - maxthrust / mass. },
    "slope", slope,
    "timeToImpact", TTI,
    "velocityAtImpact", velAtImpact
  ).

  sysioExport(export).
  sysioDLog("telemetry lib finished!").
}.