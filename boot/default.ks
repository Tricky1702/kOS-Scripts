// Default boot script
// Copyright © 2016-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  // Open the terminal for the user
  core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

  local kLib is "kOS-Lib".
  local initMaster is "0:/" + kLib + "/init.ks". local initLocal is "1:/init.ksm".
  local hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.

  // Only do this in Kerbin's SOI
  if hc() and kerbin:distance < kerbin:soiradius and exists(initMaster)
    compile initMaster to initLocal.

  switch to 1.

  if exists(initLocal) runoncepath(initLocal, lexicon("debug", "0:/debug.log")).

  // Done
  if defined _LIBG_COMMON and defined _LIBG_SYSIO
    sysioNotify("Ready", true).
  else
  {
    print "common: " + (defined _LIBG_COMMON).
    print "sysio:  " + (defined _LIBG_SYSIO).
  }
}.