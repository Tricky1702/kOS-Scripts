// Comms Library
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_COMMS is scriptpath().

  // Required lib
  local _bcLib is sysioRequires
  (
    lexicon
    (
      "scriptpath", _LIBS_COMMS,
      "input", "bodyCache",
      "import", importLibDir,
      "export", exportLibDir,
      "volume", exportVol
    )
  ).
  local _isHome is { parameter n. return checkKeyType(_bcLib, "isHome", "UserDelegate") and _bcLib["isHome"](n). }.
  // Has connection to KSC
  local kscConnected is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.
  // Communications latency to a vessel or body
  local latency is
  {
    parameter o is body.

    if o:istype("String")
    {
      if checkKeyType(_bcLib, "containsName", "UserDelegate") and _bcLib["containsName"](o) set o to body(o).
      else
      {
        local tgts is list(). list targets in tgts. tgts:add(ship).

        for tgt in tgts if tgt:name = o { set o to vessel(o). break. }
      }
    }
    if o:istype("Vessel")
    {
      if addons:available("RT") return addons:RT:delay(o).

      return o:distance / constant:c.
    }
    if o:istype("Body")
    {
      if addons:available("RT") and _isHome(o:name) return addons:RT:kscDelay(ship).

      return (o:distance - o:radius) / constant:c.
    }

    return 0.
  }.
  // Communications latency to the home body
  local kscLatency is { if not checkKeyType(_bcLib, "home", "String") return 0. return latency(body(_bcLib["home"])). }.
  // Communications roundtrip to a vessel or body
  local roundtrip is
  {
    parameter o is body.
    local t is 0.

    if o:istype("Body") and _isHome(o:name) set t to kscLatency().
    else set t to latency(o).

    if t <= 0 return 0.

    return 2 * t.
  }.
  // Wait for communications roundtrip to a vessel or body
  local waitRoundtrip is
  {
    parameter o is body, px is -1, py is -1.
    local t is roundtrip(o).

    if t >= 0.1
    {
      local n is o.

      if not o:istype("String") set n to o:name.

      sysioNotify("Waiting " + round(t, 3) + "s for communications delay with " + n + ".", true).

      if px <> -1 and py <> -1
      {
        lock ct to time:seconds.
        local s is ct + t.

        until s <= ct { printAt("Wait: " + fmtScalar(s - ct, 1, true), px, py). wait 0.2. }

        unlock ct.
      }
      else wait t.
    }
  }.

  local export is lexicon
  (
    "hasKSCConnection", kscConnected,
    "latency", latency,
    "kscLatency", kscLatency,
    "roundtrip", roundtrip,
    "waitRoundtrip", waitRoundtrip
  ).

  sysioExport(export).
}.