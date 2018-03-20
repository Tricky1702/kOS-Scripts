// Docking Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/library/docking.ks">docking.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_DOCKING is scriptpath().

  // Required libs
  sysioRequires
  (
    lexicon
    (
      "scriptpath", _LIBS_DOCKING,
      "input", list("dockingports", "maneuver"),
      "import", importLibDir,
      "export", exportLibDir,
      "volume", exportVol
    )
  ).
  local _dpLib is sysioGetImport(lexicon("input", "dockingports")).
  local _mnvLib is sysioGetImport(lexicon("input", "maneuver")).
  // Display info flags
  local _sStats is false. local _sVecs is false.

  //on ag9 { if _sStats set _sStats to false. else set _sStats to true. ag9 off. return true. }
  //on ag10 { if _sVecs set _sVecs to false. else set _sVecs to true. ag10 off. return true. }

  local apTV is
  {
    parameter op, sp, tv, dst is -1, spd is 0, stp is 0.

    if not (defined _LIBS_DOCKINGPORTS) { sysioNotifyError("docking/apTV::No dockingports lib!"). return. }
    if not (defined _LIBS_MANEUVER) { sysioNotifyError("docking/apTV::No maneuver lib!"). return. }
    if not (_dpLib["isDockingPort"](op) and _dpLib["isDockingPort"](sp) and tv:istype("Vector")) return.
    if not (dst:istype("Scalar") and dst >= 0) set dst to 0.
    if not (spd:istype("Scalar") and spd > 0) set spd to 0.1.
    if not stp:istype("UserDelegate") set stp to { parameter apvec, tvang, dstmag. return apvec:mag < 5. }.

    local tvOff is tv:normalized * dst.
    local oPos is op:ship:position. local sPos is sp:nodeposition.

    if op:ship:unpacked set oPos to op:nodeposition.

    local rp is oPos - sPos.
    local av is rp + tvOff.
    local tvang is abs(180 - vang(rp, tv)).
    local dstmag is abs(dst - rp:mag).

    local rV is ship:velocity:orbit - op:ship:velocity:orbit.
    local ad is (av:normalized * spd) - rV.

    local vdtv is vecdraw(oPos, tvOff, red, "Target Vector").
    local vdav is vecdraw(sPos, av, green, "Approach Vector").
    local vdad is vecdraw(sPos, ad * 100, yellow, "Approach Direction").
    local vdrp is vecdraw(sPos, rp, blue, "Relative Position Vector").
    local vdrv is vecdraw(sPos, rV * 100, purple, "Relative Velocity Vector").

    clearvecdraws().

    // Cut down on the access times
    local trans is _mnvLib["translate"].

    until stp(av, tvang, dstmag)
    {
      trans(ad). wait 0.01.

      set oPos to op:ship:position. set sPos to sp:nodeposition.

      if op:ship:unpacked set oPos to op:nodeposition.

      set rp to oPos - sPos.
      set av to rp + tvOff.
      set tvang to abs(180 - vang(rp, tv)).
      set dstmag to abs(dst - rp:mag).

      set rV to ship:velocity:orbit - op:ship:velocity:orbit.
      set ad to (av:normalized * spd) - rV.

      if op:ship:unpacked
      {
        if _sVecs
        {
          if not mapview
          {
            set vdtv:start to oPos. set vdtv:vec to tvOff.
            set vdav:start to sPos. set vdav:vec to av.
            set vdad:start to sPos. set vdad:vec to ad * 100.
            set vdrp:start to sPos. set vdrp:vec to rp.
            set vdrv:start to sPos. set vdrv:vec to rV * 100.
            set vdtv:show to true. set vdav:show to true. set vdad:show to true. set vdrp:show to true. set vdrv:show to true.
          }
          else clearvecdraws().
        }
        if _sStats
        {
          printAt("Relative position:  " + fmtScalar(rp:mag, 3), 2, 2).
          printAt("Relative velocity:  " + fmtScalar(rV:mag, 3), 2, 3).
          printAt("Vector angle:       " + fmtScalar(tvang, 3), 2, 4).
          printAt("Distance:           " + fmtScalar(dstmag, 2), 2, 6).
          printAt("Approach vector:    " + fmtScalar(av:mag, 3), 2, 7).
          printAt("Approach direction: " + fmtScalar(ad:mag, 3), 2, 8).
        }
      }
      else clearvecdraws().
    }

    clearvecdraws().
    trans(vecorigin). wait 0.01.
  }.
  local apPort is
  {
    parameter op, sp, dst is -1, spd is 0.

    if not (defined _LIBS_DOCKINGPORTS) { sysioNotifyError("docking/apPort::No dockingports lib!"). return. }
    if not (_dpLib["isDockingPort"](op) and _dpLib["isDockingPort"](sp)) return.
    if not (dst:istype("Scalar") and dst >= 0) set dst to 0.
    if not (spd:istype("Scalar") and spd > 0) set spd to 0.1.

    clearscreen.

    if dst > 0 sysioNotify("Approaching to " + dst + "m", true).
    else sysioNotify("Docking...", true).

    apTV
    (
      op,
      sp,
      op:portfacing:forevector,
      dst,
      spd,
      {
        parameter apvec, tvang, dstmag.
        local aerr is 2. local derr is 0.1.

        if dst < 20 { set aerr to 4. set derr to 0.2. }

        return sp:state <> "ready" or (tvang < aerr and dstmag < derr).
      }
    ).
  }.
  local swPort is
  {
    parameter op, sp, dst is -1, spd is 0.

    if not (defined _LIBS_DOCKINGPORTS) { sysioNotifyError("docking/swPort::No dockingports lib!"). return. }
    if not (_dpLib["isDockingPort"](op) and _dpLib["isDockingPort"](sp)) return.
    if not (dst:istype("Scalar") and dst >= 0) set dst to 0.
    if not (spd:istype("Scalar") and spd > 0) set spd to 0.1.

    clearscreen. sysioNotify("Moving to the side", true).

    // Return if we are on the same side as the target docking port
    if vdot(op:ship:position - ship:position, op:portfacing:forevector) < 0 return.

    apTV
    (
      op,
      sp,
      -op:portfacing:topvector,
      dst,
      spd,
      { parameter apvec, tvang, dstmag. return apvec:mag < 5. }
    ).
  }.
  local eRange is
  {
    parameter ov, dst is -1, spd is 0.

    if not (defined _LIBS_MANEUVER) { sysioNotifyError("docking/eRange::No maneuver lib!"). return. }
    if not ov:istype("Vessel") return.
    if not (dst:istype("Scalar") and dst >= 0) set dst to 0.
    if not (spd:istype("Scalar") and spd > 0) set spd to 0.1.

    clearscreen. sysioNotify("Ensuring range of " + dst + "m", true).

    local oPos is ov:position. local sPos is ship:position.

    if op:ship:unpacked set oPos to op:nodeposition.

    local rp is sPos - oPos.
    local dvOff is rp:normalized * dst.
    local dv is dvOff - rp.

    local rV is ship:velocity:orbit - ov:velocity:orbit.
    local dd is (dv:normalized * spd) - rV.

    local vdtv is vecdraw(oPos, dvOff, red, "Target Vector").
    local vddv is vecdraw(sPos, dv, green, "Depart Vector").
    local vddd is vecdraw(sPos, dd * 100, yellow, "Depart Direction").
    local vdrp is vecdraw(sPos, rp, blue, "Relative Position Vector").
    local vdrv is vecdraw(sPos, rV * 100, purple, "Relative Velocity Vector").

    clearvecdraws().

    // Cut down on the access times
    local trans is _mnvLib["translate"].

    until dv:mag < 5
    {
      trans(dd). wait 0.01.

      set oPos to ov:position. set sPos to ship:position.

      if op:ship:unpacked set oPos to op:nodeposition.

      set rp to sPos - oPos.
      set dvOff to rp:normalized * dst.
      set dv to dvOff - rp.

      set rV to ship:velocity:orbit - ov:velocity:orbit.
      set dd to (dv:normalized * spd) - rV.

      if ov:unpacked
      {
        if _sVecs
        {
          if not mapview
          {
            set vdtv:start to oPos. set vdtv:vec to dvOff.
            set vddv:start to sPos. set vddv:vec to dv.
            set vddd:start to sPos. set vddd:vec to dd * 100.
            set vdrp:start to sPos. set vdrp:vec to rp.
            set vdrv:start to sPos. set vdrv:vec to rV * 100.
            set vdtv:show to true. set vddv:show to true. set vddd:show to true. set vdrp:show to true. set vdrv:show to true.
          }
          else clearvecdraws().
        }
        if _sStats
        {
          printAt("Relative position: " + fmtScalar(rp:mag, 3), 2, 2).
          printAt("Relative velocity: " + fmtScalar(rV:mag, 3), 2, 3).
          printAt("Distance:          " + fmtScalar(abs(dst - rp:mag), 2), 2, 5).
          printAt("Depart vector:     " + fmtScalar(dv:mag, 3), 2, 6).
          printAt("Depart direction:  " + fmtScalar(dd:mag, 3), 2, 7).
        }
      }
      else clearvecdraws().
    }

    clearvecdraws().
    trans(vecorigin). wait 0.01.
  }.
  local krv is
  {
    parameter ov.

    if not (defined _LIBS_MANEUVER) { sysioNotifyError("docking/krv::No maneuver lib!"). return. }
    if not (ov:istype("Vessel") and (ship:velocity:orbit - ov:velocity:orbit):mag >= 0.025) return.

    clearscreen. sysioNotify("Killing relative velocity", true).

    local rV is ship:velocity:orbit - ov:velocity:orbit. local rV0 is rV.
    local rvd is vecdraw(vecorigin, vecorigin, purple, "Relative Velocity Vector").
    local dOff is true.
    // Cut down on the access times
    local trans is _mnvLib["translate"].

    until false
    {
      set rV to ship:velocity:orbit - ov:velocity:orbit.

      if rV:mag < 0.025 and vdot(rV, rV0) < 0.5 break.
      if not _sVecs or mapview
      {
        if not dOff { set rvd:show to false. set dOff to true. }
      }
      else
      {
        set rvd:start to ship:position. set rvd:vec to rV * 100.

        if dOff { set rvd:show to true. set dOff to false. }
      }
      if _sStats printAt("Relative velocity: " + fmtScalar(rV:mag, 5), 2, 4).

      trans(-rV). wait 0.01.
    }

    set rvd:show to false.

    trans(vecorigin). wait 0.01.
  }.

  local dock is
  {
    parameter ov, opt is "", spt is "", sStats is 0, sVecs is 0.

    if not (defined _LIBS_MANEUVER) { sysioNotifyError("docking/dock::No maneuver lib!"). return. }
    if not (defined _LIBS_DOCKINGPORTS) { sysioNotifyError("docking/dock::No dockingports lib!"). return. }
    if not ov:istype("Vessel") return.
    if not opt:istype("String") set opt to "".
    if not spt:istype("String") set spt to "".
    if not sStats:istype("Boolean") set sStats to true.
    if not sVecs:istype("Boolean") set sVecs to false.

    //ag9 off. ag10 off.
    set _sStats to sStats. set _sVecs to sVecs.

    clearscreen. sysioNotify("Initiating docking procedure").

    // Find all ports in the ready DockingPort:State
    local asrp is _dpLib["getReadyPortsFromTarget"](ship). local aorp is _dpLib["getReadyPortsFromTarget"](ov).

    if asrp:empty or aorp:empty
    {
      if asrp:empty sysioNotifyWarn("No docking ports are available to be used on this craft").
      if aorp:empty sysioNotifyWarn("No docking ports are available to be used on the target craft").

      return.
    }

    // Cut down on the access times
    local isdp is _dpLib["isDockingPort"].
    // Get a port in the ready DockingPort:State if possible
    local sp is _dpLib["getPortFromTargetReadyPorts"](spt, ship). local op is _dpLib["getPortFromTargetReadyPorts"](opt, ov).

    // Choose a new set of ports if we can't find the tags or they are the wrong type/size
    if not isdp(sp) or not isdp(op) or sp:nodetype <> op:nodetype
    {
      // Cut down on the access times
      local dpSearch is _dpLib["search"].

      // One or both of the ports has been found
      if isdp(sp) or isdp(op)
      {
        // Ship docking tag not found
        if not isdp(op) set sp to dpSearch(asrp, op)[0].
        // Target docking tag not found
        else if not isdp(op) set op to dpSearch(aorp, sp)[0].
        // Port type/size don't match
        else
        {
          local p is dpSearch(aorp, sp)[0].

          if isdp(p) set op to p.
          else set sp to dpSearch(asrp, op)[0].
        }
      }
      // Both docking tags can't be found
      if not isdp(sp) and not isdp(op)
      {
        local ps is dpSearch(asrp, aorp).
        set sp to ps[0]. set op to ps[1].
      }
    }

    if not isdp(sp) or not isdp(op)
    {
      sysioNotifyWarn("No suitable docking ports are available").

      return.
    }

    set target to op.

    if (ship:velocity:orbit - ov:velocity:orbit):mag > 1 _mnvLib["cancel"](ov).

    local orgSAS is sas. local orgRCS is rcs.
    sas off. rcs on.

    sp:controlfrom.
    lock steering to lookdirup(-op:portfacing:forevector, op:portfacing:topvector).
    wait 0.01.

    krv(ov).
    eRange(ov, 100, 2).
    krv(ov).
    swPort(op, sp, 100, 2).
    krv(ov).
    apPort(op, sp, 80, 1.5).
    apPort(op, sp, 20, 1).
    krv(ov).
    apPort(op, sp, 10, 0.5).
    apPort(op, sp, 5, 0.25).

    // Make sure we are pointed at the target docking port for the final approach
    lock steering to lookdirup(-op:portfacing:forevector, op:portfacing:topvector).
    wait 0.01.

    apPort(op, sp, 0, 0.1).

    clearscreen. sysioNotify("Docked").

    unlock steering. wait 0.01.
    set sas to orgSAS. set rcs to orgRCS.
  }.

  local export is lexicon
  (
    "approachPort", apPort,
    "approachTargetVector", apTV,
    "dock", dock,
    "ensureRange", eRange,
    "killRelativeVelocity", krv,
    "sideswipePort", swPort
  ).

  sysioExport(export).
}.