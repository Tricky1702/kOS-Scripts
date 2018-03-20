// Maneuver Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/library/maneuver.ks">maneuver.ks</a>
// Acknowledgement: Steven Mading, <a href="https://github.com/Dunbaratu/kerboscripts/blob/master/lib/prediction.ks">prediction.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_MANEUVER is scriptpath().

  // Required libs
  sysioRequires
  (
    lexicon
    (
      "scriptpath", _LIBS_MANEUVER,
      "input", list("bodyCache", "engines", "orbits", "telemetry"),
      "import", importLibDir,
      "export", exportLibDir,
      "volume", exportVol
    )
  ).
  local _bcLib is sysioGetImport(lexicon("input", "bodyCache")).
  local _engLib is sysioGetImport(lexicon("input", "engines")).
  local _orbLib is sysioGetImport(lexicon("input", "orbits")).
  local _tlmLib is sysioGetImport(lexicon("input", "telemetry")).

  local translate is
  {
    parameter v1.

    if not rcs return.
    if v1:istype("Direction") set v1 to v1:forevector.
    else if not v1:istype("Vector") set v1 to vecorigin.

    local ctrl is ship:control.

    // 1² is still 1
    if v1:sqrmagnitude > 1 set v1 to v1:normalized.

    set ctrl:fore to v1 * facing:forevector.
    set ctrl:starboard to v1 * facing:starvector.
    set ctrl:top to v1 * facing:topvector.
  }.
  local steer is
  {
    parameter vd, tmOut is 0, aoa is 0, prec is 0.

    if not (vd:istype("Vector") or vd:istype("Direction")) return.
    if not (tmOut:istype("Scalar") and tmOut > 0) set tmOut to 30.
    if not (aoa:istype("Scalar") and aoa > 0) set aoa to 2.
    if not (prec:istype("Scalar") and prec > 0) set prec to 0.4.

    local utEnd is time:seconds + tmOut.

    if vd:istype("Vector") set vd to lookdirup(vd, up:vector).

    lock steering to vd. wait 0.01.
    // Temporary assignment
    local v1 is vecorigin.

    if steeringmanager:enabled set v1 to steeringmanager:target:vector.
    else set v1 to vd:forevector.

    until time:seconds > utEnd
    {
      local saoa is vang(v1, facing:forevector). local ut is time:seconds.
      local av is vang(velocityat(ship, ut):orbit, velocityat(ship, ut + 1):orbit) * constant:DegToRad.

      printAt("Current angle of attack (want " + fmtScalar(aoa, 5, false) + "): " + fmtScalar(saoa, 5), 2, 8).
      printAt("Current angular velocity match: " + fmtScalarA(angularvel:mag * prec, "rad/s", 5), 2, 9).
      printAt("Predicted angular velocity:     " + fmtScalarA(av, "rad/s", 5), 2, 10).

      if saoa < aoa and angularvel:mag * prec < max(av, 0.0005) break.

      wait 0.01.
    }

    local w is terminal:width - 1.

    printAtPadR("", 0, 8, w).
    printAtPadR("", 0, 9, w).
    printAtPadR("", 0, 10, w).
  }.
  local tmForMnv is
  {
    parameter dV.

    if not (dV:istype("Scalar") and dV > 0) return -1.

    local sEngs is getKeyWithType(_engLib, "activeEngines", "UserDelegate", { return list(). })().

    if sEngs:empty return -1.

    local eThrust is 0. local eISP is 0.

    for eng in sEngs
    {
      set eThrust to eThrust + eng:availablethrust.
      set eISP to eISP + eng:isp.
    }

    if eThrust = 0 { sysioNotifyWarn("No available thrust!"). return -1. }
    if eISP = 0 { sysioNotifyWarn("No engine ISP!"). return -1. }

    local gp is g0 * eISP / sEngs:length.

    return gp * mass * (1 - constant:e^(-dV / gp)) / eThrust.
  }.
  local cancel is
  {
    parameter craft.

    if not craft:istype("Vessel") return.

    local _sas is sas. sas off.
    lock throttle to 0. wait 0.01.
    lock rV to craft:velocity:orbit - velocity:orbit.

    if rV:mag > 0
    {
      clearscreen. sysioNotify("Killing relative velocity with " + craft:name, true).
      steer(rV, 20, 5). lock steering to rV.

      local rV0 is rV.
      local prStats is
      {
        printAt("Throttle:          " + fmtScalar(throttle, 3), 2, 2).
        printAt("Relative velocity: " + fmtScalarA(rV:mag, "ms⁻¹", 3), 2, 3).
        printAt("rV0:               " + fmtScalarA(rV0:mag, "ms⁻¹", 3), 2, 4).
        printAt("rV0 . rV:          " + fmtScalar(vdot(rV0, rV), 3), 2, 5).
      }.

      prStats().

      // lock throttle to min(tmForMnv(rV:mag), 1). wait 0.01.
      lock throttle to min((rV:mag * mass) / maxthrust, 1). wait 0.01.

      until false
      {
        prStats().

        if vdot(rV0, rV) < 0 { lock throttle to 0. break. }
        if rV:mag < 0.1
        {
          // Burn off the remaining 0.1ms⁻¹
          until vdot(rV0, rV) < 0.5 { prStats(). wait 0.01. }

          lock throttle to 0. break.
        }

        wait 0.01.
      }
    }

    unlock throttle. unlock steering. wait 0.01.
    unlock rV.
    set sas to _sas.
  }.
  local lander is
  {
    parameter maxVel is 0.

    if not (defined _LIBS_TELEMETRY) { sysioNotifyError("maneuver/lander::No telemetry lib!"). return. }
    if not (maxVel:istype("Scalar") and maxVel > 0) set maxVel to 2.

    // Local delegates
    local iPos is _tlmLib["impactPosition"].
    local slope is _tlmLib["slope"].
    local gAcc is _tlmLib["gAcc"].
    local totAcc is _tlmLib["totalAcceleration"].
    local safeRetro is { if groundspeed > 0.01 return srfretrograde. return heading(90, 90). }.
    local prStats is
    {
      printAt("Throttle:            " + fmtScalar(throt, 3), 0, 4).
      printAt("Altitude:            " + fmtScalarA(altitude, "m", 3), 0, 5).
      printAt("Radar altitude:      " + fmtScalarA(alt:radar, "m", 3), 0, 6).
      printAt("geo terrainheight:   " + fmtScalarA(geoPred:terrainheight, "m", 3), 0, 7).
      printAt("geo distance:        " + fmtScalarA(geoPred:distance, "m", 3), 0, 8).
      printAt("Land altitude:       " + fmtScalarA(lndAlt, "m", 3), 0, 9).
      printAt("Distance to impact:  " + fmtScalarA(dist, "m", 3), 0, 10).
      printAt("Descend speed:       " + fmtScalarA(descendSpeed, "ms⁻¹", 3), 0, 11).
      printAt("Gravitational force: " + fmtScalarA(gAcc(), "ms⁻²", 3), 0, 12).
      printAt("Slope:               " + fmtScalarA(slope(geoPred, 2.5), "°", 1), 0, 13).
    }.
    local setHoverAltitude is { parameter sp. set hoverPID:setpoint to sp. }.
    local setHoverDescendSpeed is
    {
      parameter out.

      set hoverPID:maxoutput to out. set hoverPID:minoutput to -out.
      // Control descent speed with throttle
      set climbPID:setpoint to hoverPID:update(time:seconds, altitude).
      set throt to climbPID:update(time:seconds, -velocity:surface:mag).
    }.
    // Local variables
    set maxVel to max(maxVel, 0.5).
    local gearOn is false.
    local geoPred is geoposition. local th is geoPred:terrainheight. local adj is _tlmLib["calcAltitudeAdjust"]().
    local lndAlt is altitude - th - adj. local dist is geoPred:distance.
    local descendSpeed is 150. local distToStartBreak is 250.
    local iCnt is 0.
    local useTrajectories is false.
    // Controls altitude by changing climbPID setpoint
    local hoverPID is pidloop(1, 0.01, 0, -descendSpeed, descendSpeed).
    // Controls vertical speed
    local climbPID is pidloop(0.1, 0.3, 0.005, 0, 1).

    setHoverAltitude(lndAlt + 50 * maxVel).
    gear on. gear off.

    local throt is 0.
    lock throttle to throt. lock steering to safeRetro(). wait 0.01.

    until status = "Landed" or status = "Splashed"
    {
      if dist < 500
      {
        if not gearOn { gear on. set gearOn to true. }

        setHoverAltitude(lndAlt).

        if dist < distToStartBreak set descendSpeed to max(-totAcc() * dist / distToStartBreak, maxVel).
      }
      else if dist < 2500
      {
        // Set altitude to hover at
        setHoverAltitude(lndAlt + 15 * maxVel).

        set descendSpeed to 200 / maxVel.
      }

      if dist < 2500 setHoverDescendSpeed(descendSpeed).

      if mod(iCnt, 10) = 0 prStats().

      wait 0.01.

      if useTrajectories and addons:tr:available and addons:tr:hasimpact set geoPred to addons:tr:impactpos.
      else
      {
        if dist < distToStartBreak and groundspeed < 1 set geoPred to geoposition.
        else if iCnt = 0 and groundspeed > 0.2 set geoPred to iPos(useTrajectories).
      }

      set th to geoPred:terrainheight. set dist to geoPred:distance.

      if th > altitude - adj set lndAlt to altitude - adj.
      else set lndAlt to altitude - th - adj.

      if alt:radar < lndAlt set lndAlt to alt:radar.

      set iCnt to mod(iCnt + 1, 100).
    }

    lock throttle to 0. unlock steering. wait 0.01.

    sysioDLog("Altitude:           " + round(altitude, 3) + "m").
    sysioDLog("Radar:              " + round(alt:radar, 3) + "m").
    sysioDLog("geo terrainheight:  " + round(geoPred:terrainheight, 3) + "m").
    sysioDLog("geo distance:       " + round(geoPred:distance, 3) + "m").
    sysioDLog("Land altitude:      " + round(lndAlt, 3) + "m").
    sysioDLog("Distance to impact: " + round(dist, 3) + "m").
    sysioDLog("Slope:              " + round(slope(geoPred, 2.5), 1) + "°").
  }.
  // Internal
  local _delayMnv is
  {
    parameter ut, dV, etaBurn.
    local batm is body:atm. local lowOrbit is 0.

    if checkKey(_bcLib, body:name) set lowOrbit to getKeyWithType(_bcLib[body:name], "lowOrbit", "Scalar", 0).
    if lowOrbit = 0
    {
      if batm:exists set lowOrbit to batm:height * 1.05.
      else set lowOrbit to body:radius * 0.125.
    }

    if obt:periapsis > lowOrbit
    {
      local tfm2 is tmForMnv(dV) / 2.

      if tfm2 > etaBurn set ut to ut + (obt:period + etaBurn - tfm2).
    }

    return ut.
  }.
  local addCircularizeAtApsisNode is
  {
    parameter apsis is -1, etaapsis is -1, delayNode is 0.

    if not (apsis:istype("Scalar") and apsis >= 0) set apsis to obt:apoapsis.
    if not (etaapsis:istype("Scalar") and etaapsis >= 0) set etaapsis to eta:apoapsis.
    if not delayNode:istype("Boolean") set delayNode to true.

    // Burn UT
    local ut is time:seconds + etaapsis.
    // Total dV for the circularize maneuver
    local dV is _orbLib["circularizeAtApsis"](apsis, etaapsis).

    // Delay if time for maneuver is greater than the apsis eta
    if delayNode set ut to _delayMnv(ut, dV, etaapsis).

    // create node
    local nd is node(ut, 0, 0, dV).

    // Add to the flight plan
    add nd.

    // must be removed by the caller
    return nd.
  }.
  local addCircularizeAtApoapsisNode is { parameter delayNode is 0. return addCircularizeAtApsisNode(obt:apoapsis, eta:apoapsis, delayNode). }.
  local addCircularizeAtPeriapsisNode is { parameter delayNode is 0. return addCircularizeAtApsisNode(obt:periapsis, eta:periapsis, delayNode). }.
  local addCircularizeNode is
  {
    parameter delayNode is 0.

    if eta:apoapsis <= eta:periapsis return addCircularizeAtApoapsisNode(delayNode).
    else return addCircularizeAtPeriapsisNode(delayNode).
  }.
  local addNode is
  {
    parameter dr, etaBurn is -1, delayNode is 0.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("maneuver/addNode::No orbits lib!"). return. }
    if not dr:istype("Scalar") return 0.
    if not (etaBurn:istype("Scalar") and etaBurn >= 0) set etaBurn to 300.
    if not delayNode:istype("Boolean") set delayNode to true.

    local ut is time:seconds + etaBurn. local dV is 0.

    if obt:eccentricity > 0.0025
    {
      // elliptical; do the burn at the periapsis
      set etaBurn to eta:periapsis. set ut to time:seconds + etaBurn.
      // ship orbit at ut
      local sobtut is orbitat(ship, ut).
      // actual velocity squared at ut
      local vsqrmag is sobtut:velocity:orbit:sqrmagnitude.
      // actual distance to body at ut
      local r1 is (body:position - sobtut:position):mag.
      // distance after burn
      local r2 is body:radius + dr.
      // maneuver dV
      set dV to sqrt(vsqrmag + 2 * body:mu * (1 / r2 - 1 / r1)).
    }
    else
      set dV to _orbLib["hohmannTransfer"](dr)[0].

    // Delay if time for maneuver is greater than the burn eta
    if delayNode set ut to _delayMnv(ut, dV, etaBurn).

    // create node
    local nd is node(ut, 0, 0, dV).

    // Add to the flight plan
    add nd.

    // must be removed by the caller
    return nd.
  }.
  local addHohmannNodes is
  {
    parameter dr, etaBurn is -1, delayNode is 0.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("maneuver/addHohmannNodes::No orbits lib!"). return. }
    if not dr:istype("Scalar") return 0.
    if not (etaBurn:istype("Scalar") and etaBurn >= 0) set etaBurn to 300.
    if not delayNode:istype("Boolean") set delayNode to true.

    local ut is time:seconds + etaBurn.
    local ht is _orbLib["hohmannTransfer"](dr).
    local dV1 is ht[0]. local dV2 is ht[1].

    // Delay if time for maneuver is greater than the burn eta
    if delayNode set ut to _delayMnv(ut, dV1, etaBurn).

    // create node
    local nd1 is node(ut, 0, 0, dV1).

    // Add to the flight plan
    add nd1.

    // Calculate expected eta to new apoapsis.
    local r1 is (obt:semimajoraxis + obt:semiminoraxis) / 2.
    local r2 is dr + body:radius.
    local tH is constant:pi * sqrt((r1 + r2)^3 / (8 * body:mu)).
    // create node
    local nd2 is node(ut + tH, 0, 0, dV2).

    // Add to the flight plan
    add nd2.

    // must be removed by the caller
    return list(nd1, nd2).
  }.
  local addInclinationMatchNode is
  {
    parameter oobt, delayNode is 0.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("maneuver/addInclinationMatchNode::No orbits lib!"). return 0. }
    if not oobt:istype("Orbit") { sysioNotifyError("maneuver/addInclinationMatchNode::Target not an orbit!"). return 0. }
    if not delayNode:istype("Boolean") set delayNode to true.

    local sobt is ship:obt.
    local n1 is _orbLib["orbitNormal"](sobt).
    local n2 is _orbLib["orbitNormal"](oobt).
    // pick whichever node, An or Dn, is higher altitude
    // true anomaly of the ascending node:
    local nodeTA is _orbLib["findAscendingNodeTA"](sobt, oobt).

    // (closer to Ap than Pe):
    if nodeTA < 90 or nodeTA > 270 set nodeTA to mod(nodeTA + 180, 360).

    // burn's eta, unit vector direction, and magnitude of burn:
    local etaBurn is _orbLib["etaToTA"](sobt, nodeTA).
    local ut is time:seconds + etaBurn.
    local velAtUT is velocityat(ship, ut):orbit.
    local burnUnit is (n1 + n2):normalized.
    local burnMag is -2 * velAtUT:mag * cos(vang(velAtUT, burnUnit)).
    local dV is burnMag * burnUnit.

    // Delay if time for maneuver is greater than the burn eta
    if delayNode set ut to _delayMnv(ut, dV, etaBurn).

    // create node
    local nd is node(ut, 0, dV, 0).

    // Add to the flight plan
    add nd.

    // must be removed by the caller
    return nd.
  }.
  local execNode is
  {
    parameter autoStage is 0, endBurnFunc is 0.

    if not (defined _LIBS_ENGINES) { sysioNotifyError("maneuver/execNode::No engine lib!"). return. }
    if not autoStage:istype("Boolean") set autoStage to false.
    if not endBurnFunc:istype("UserDelegate") set endBurnFunc to { return false. }.

    lock throttle to 0. wait 0.01.
    local _sas is sas. sas off.
    local prApsis is
    {
      parameter s.

      printAt("Apoapsis:  " + fmtScalarA(obt:apoapsis, "m", 1), 2, 4).
      printAt("Periapsis: " + fmtScalarA(obt:periapsis, "m", 1), 2, 5).
      printAt("ETA:       " + fmtScalarA(s - time:seconds, "s", 1), 2, 4).
    }.
    // Cut down on the access times
    local bc is _engLib["burnoutCheck"].
    local rc is _engLib["resetChecks"].

    for nd in allnodes
    {
      local dV0 is nd:deltav.
      local utStart is time:seconds + nd:eta - tmForMnv(dv0:mag) / 2.
      // local setThrot is { return max(min(tmForMnv(nd:deltav:mag), 1), 0.005). }.
      local setThrot is { return min((nd:deltav:mag * mass) / maxthrust, 1). }.

      if autoStage rc().

      clearscreen. sysioNotify("Waiting for start of burn", true).

      if utStart - 30 > time:seconds { doWarp(utStart - 30). steer(dV0, 20, 5). }

      lock steering to dV0. wait 0.01.

      // Wait until we are 1 default physics tick away from the burn
      until utStart - time:seconds <= 0.04 { prApsis(utStart). wait 0.01. }

      sysioNotify("Starting burn", true).

      lock throttle to setThrot(). wait 0.01.

      until endBurnFunc()
      {
        prApsis(utStart).

        if vdot(dv0, nd:deltav) < 0 { lock throttle to 0. break. }
        if nd:deltav:mag < 0.1
        {
          until endBurnFunc() or vdot(dv0, nd:deltav) < 0.5
          {
            if autoStage and bc(true) lock throttle to setThrot().

            prApsis(utStart). wait 0.01.
          }

          lock throttle to 0. break.
        }

        wait 0.01.
      }

      unlock throttle. unlock steering. wait 0.01.

      sysioNotify("Finished burn", true).

      // Remove from the flight plan
      remove nd.
    }

    set sas to _sas.
  }.
  local matchInclination is
  {
    parameter o, autoStage is 0.

    if not (defined _LIBS_ORBITS) { sysioNotifyError("maneuver/matchInclination::No orbits lib!"). return. }
    if o:istype("String") set o to _orbLib["orbitable"](o).
    if not (o:istype("Vessel") or o:istype("Body")) { sysioNotifyError("maneuver/matchInclination::Target not a vessel or body!"). return. }
    if not autoStage:istype("Boolean") set autoStage to false.

    clearscreen. sysioNotify("Matching inclination with `" + o:name + "'", true).

    addInclinationMatchNode(o:obt). execNode(autoStage).

    sysioNotify("Inclination match achieved", true).
  }.
  local changeOrbit is
  {
    parameter dr, etaBurn is -1, autoStage is 0, elliptical is 0.

    if not dr:istype("Scalar") { sysioNotifyError("maneuver/changeOrbit::Desired radius is not a scalar!"). return. }
    if not (etaBurn:istype("Scalar") and etaBurn >= 0) set etaBurn to 300.
    if not autoStage:istype("Boolean") set autoStage to false.
    if not elliptical:istype("Boolean") set elliptical to false.

    // If the eccentricity > 0.0025 then circularize
    if not elliptical and obt:eccentricity > 0.0025
    {
      clearscreen. sysioNotify("Circularizing", true).

      addCircularizeNode(). execNode(autoStage).
    }

    if not elliptical
    {
      if eta:apoapsis < etaBurn set etaBurn to eta:apoapsis.
      else if eta:periapsis < etaBurn set etaBurn to eta:periapsis.
    }

    clearscreen. sysioNotify("Changing orbit to " + fmtScalarA(dr / 1000, "km", 1), true).

    addNode(dr, etaBurn). execNode(autoStage).

    if not elliptical
    {
      clearscreen. sysioNotify("Circularizing", true).

      addCircularizeNode(). execNode(autoStage).
    }

    sysioNotify("Orbit achieved", true).
  }.

  local export is lexicon
  (
    "addCircularizeNode", addCircularizeNode,
    "addCircularizeAtApoapsisNode", addCircularizeAtApoapsisNode,
    "addCircularizeAtApsisNode", addCircularizeAtApsisNode,
    "addCircularizeAtPeriapsisNode", addCircularizeAtPeriapsisNode,
    "addNode", addNode,
    "addHohmannNodes", addHohmannNodes,
    "addInclinationMatchNode", addInclinationMatchNode,
    "cancel", cancel,
    "changeOrbit", changeOrbit,
    "execNode", execNode,
    "matchInclination", matchInclination,
    "steer", steer,
    "lander", lander,
    "timeForManeuver", tmForMnv,
    "translate", translate
  ).

  sysioExport(export).
  sysioDLog("maneuver lib finished!").
}.