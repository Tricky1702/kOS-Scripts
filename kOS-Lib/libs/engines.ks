// Engines Library
// Copyright © 2016-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_ENGINES is scriptpath().

  local _staged is false. local _maxthrust is 0

  local burnout is
  {
    parameter autoStage is false.

    if not autoStage:istype("Boolean") set autoStage to false.
    if _maxthrust = 0 { set _maxthrust to maxthrust. return false. }
    if _maxthrust - maxthrust <= 10 return false.

    if autoStage
    {
      // Slow down to prevent the engines burning the stage
      lock throttle to 0.1. wait 0.01.

      // Stage and wait until it has finished
      stage. wait until stage:ready.

      // Reset the steering feedback for the lighter craft
      if steeringmanager:enabled steeringmanager:resettodefault().

      // Wait a little for separation
      wait 0.25.

      // Mark that staging happened
      set _staged to true.
    }

    set _maxthrust to maxthrust.

    return true.
  }.
  local activeEngs is
  {
    local sEngs is list().
    local engs is list(). list engines in engs.

    if engs:empty sysioNotifyWarn("No engines available!").
    else
    {
      for eng in engs if eng:ignition and not eng:flameout sEngs:add(eng).

      if sEngs:empty sysioNotifyWarn("No engines active!").
    }

    return sEngs.
  }.
  local curisp is
  {
    local sEngs is activeEngines().

    if sEngs:empty return 0.

    local eFlow is 0. local eThrust is 0.

    for eng in sEngs
    {
      set eFlow to eFlow + (eng:availablethrust / eng:isp).
      set eThrust to eThrust + eng:availablethrust.
    }

    if eThrust = 0 return 1.

    return eThrust / eFlow.
  }.

  local export is lexicon
  (
    "hasAutostaged", { return _staged. },
    "activeEngines", activeEngs,
    "burnoutCheck", burnout,
    "currentISP", curisp,
    "resetChecks", { set _staged to false. set _maxthrust to 0. }
  ).

  sysioExport(export).
  sysioDLog("engines lib finished!").
}.