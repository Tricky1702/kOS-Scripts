// Automatic Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Acknowledgement: Modifications of some routines by space-is-hard
// * <a href="https://github.com/space-is-hard/kOS-Utils/blob/master/boot_kos_utils.ks">boot_kos_utils.ks</a>

@LAZYGLOBAL off.
{
  global _LIBS_AUTOMATIC is scriptpath().

  // Lexicon that we'll store all of the parachute modules in
  local chuteLex is lexicon().
  // Lists that we will store all of the fairings in
  local sfList is list(). local pfList is list().

  // Stores all Real chute modules in the chute lexicon. Marks that they haven't been deployed yet
  for m in ship:modulesnamed("RealChuteModule") chuteLex:add(m, false).
  // Stores all stock parachute modules in the chute lexicon. Marks that they haven't been deployed yet
  for m in ship:modulesnamed("ModuleParachute") chuteLex:add(m, false).
  // Stock and KW Fairings
  for m in ship:modulesnamed("ModuleProceduralFairing") sfList:add(m).
  // Procedural Fairings
  for m in ship:modulesnamed("ProceduralFairingDecoupler") pfList:add(m).

  local checkChutes is
  {
    if chuteLex:keys:empty return.

    local batm is body:atm.

    // Determines whether we're in atmosphere, and less than 5km above the terrain, and descending safely
    if batm:exists and ship:altitude < batm:height and alt:radar < 5000 and ship:verticalspeed < -7 and ship:verticalspeed > -240
      // Goes over the chute lexicon
      for m in chuteLex:keys
        // Checks to see if the chute is already deployed
        if not chuteLex[m]
          // Checks to see if it is safe to deploy
          if m:hasevent("Deploy Chute") and m:getfield("Safe To Deploy?") = "Safe"
          {
            // Deploy/arm this chute that has shown up as safe and ready to deploy
            m:doaction("Deploy", true).
            // Inform the user that we did so
            sysioNotify("Safe to deploy; Arming parachute").
            // Marks the chute has been deployed
            set chuteLex[m] to true.
          }
  }.

  local checkFairings is
  {
    parameter minAlt is 0.

    if sfList:empty and pfList:empty return.

    local batm is body:atm.

    if batm:exists set minAlt to batm:height * (5.5 / 7).
    else if not minAlt:istype("Scalar") or minAlt < 2000 set minAlt to 2000.

    if ship:altitude > minAlt
    {
      if not sfList:empty
      {
        sysioNotify("Approaching edge of atmosphere; Deploying Fairings").

        // Iterates over a list of all parts with the stock fairings module
        // and deploys them
        for m in sfList m:doevent("deploy").

        sfList:clear.
      }
      if not pfList:empty
      {
        sysioNotify("Approaching edge of atmosphere; Jettisoning Fairings").

        // Iterates over a list of all parts using the fairing module from the Procedural Fairings Mod
        // and jettisons them (PF uses the word jettison in the right click menu instead of deploy)
        for m in pfList m:doevent("jettison").

        pfList:clear.
      }
    }
  }.

  local export is lexicon
  (
    "checkChutes", checkChutes,
    "checkFairings", checkFairings
  ).

  sysioExport(export).
}.