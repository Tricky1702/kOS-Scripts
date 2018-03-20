// Boot init script
// Copyright © 2016-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  parameter _l is lexicon().
  // Compile, Debug, Keep, Roundtrip
  local _c is false. local _d is "". local _k is list(). local _rt is false.

  if _l:istype("Lexicon") and _l:length > 0
  {
    if _l:haskey("compile") and _l["compile"]:istype("Boolean") set _c to _l["compile"].
    if _l:haskey("debug") and _l["debug"]:istype("String") set _d to _l["debug"].
    if _l:haskey("keep") and _l["keep"]:istype("List") set _k to _l["keep"].
    if _l:haskey("roundtrip") and _l["roundtrip"]:istype("Boolean") set _rt to _l["roundtrip"].
  }

  // Import volume, Export volume
  local _iv is archive:name + ":". local _ev is scriptpath():tostring:split(":/")[0] + ":".
  // List of global libs
  local libg is list("common.ks", "sysio.ks").
  // List of files to run
  local rl is list().

  // Internal helper functions
  local _tl is
  {
    parameter t, ws.
    local w is ws:split(""). local i is 0. local tl is t:length.

    until i = tl or not w:contains(t[i]) set i to i + 1.

    if i = tl return "".

    return t:substring(i, tl - i).
  }.
  local _tr is
  {
    parameter t, ws.
    local w is ws:split(""). local i is t:length - 1.

    until i < 0 or not w:contains(t[i]) set i to i - 1.

    if i < 0 return "".

    return t:substring(0, i + 1).
  }.
  local _trim is { parameter t, ws. return _tr(_tl(t, ws), ws). }.
  local _fp is { parameter p. local sp is p:split(":"). if sp:length = 1 return _trim(p, "/"). return sp[0] + ":/" + _trim(sp[1], "/"). }.
  local _join is
  {
    parameter ls.
    local l is list().

    if ls:istype("List") set l to ls:copy.
    else return "Incorrect type - " + ls:typename.

    if l:empty return "Empty".

    return "`" + l:join("', `") + "'".
  }.
  local _hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.
  local _ls is
  {
    parameter t.

    if _d <> ""
    {
      local sf is _fp(_d):split(":"). local vol is sf[0]. local f is _tl(sf[sf:length - 1], "/").

      if sf:length = 1 set vol to _ev:substring(0, _ev:length - 1).

      local lf is list(vol, f):join(":").

      if not (vol = "0" or vol = archive:name) log t to lf.
      else
      {
        local elf is _ev + "/" + f.

        if not _hc() log t to elf.
        else
        {
          if exists(elf) { log open(elf):readall():string to lf. deletepath(elf). }

          log t to lf.
        }
      }
    }
  }.
  local _dp is { parameter t. if _d <> "" { set t to "init::" + t. print t. _ls(t). } }.
  local _ht is { parameter t. hudtext(t, 3, 2, 20, green, false). }.
  local _dh is { parameter t. _dp(t). _ht(t). }.

  local tw is kuniverse:timewarp.

  if tw:warp > 0 { _dh("Cancelling warp"). tw:cancelwarp(). until tw:issettled and ship:unpacked wait 0.01. }
  if not _k:contains("*")
  {
    _dh("Initialising local drive").
    for n in list("boot", "libg", "init.ks", "init.ksm") _k:add(n).
    for n in core:volume:files:keys if not _k:contains(n) { _dp("Deleting `" + n + "'"). core:volume:delete(n). }
  }

  if _hc()
  {
    local kLib is "kOS-Lib". local ivkLib is _iv + "/" + kLib.
    // Filesizes, Filesizes store
    local _fs is lexicon(). local _fsjs is ivkLib + "/fsize.json".
    // Compiled, Compiled store
    local _pc is lexicon(). local _pcjs is ivkLib + "/csize.json".

    if exists(ivkLib + "/sysio.log") deletepath(ivkLib + "/sysio.log").

    _dh("Checking files...").

    // Load script filesizes if available
    if exists(_fsjs) set _fs to readjson(_fsjs).
    if _c and exists(_pcjs) set _pc to readjson(_pcjs).

    local nl is list().

    for n in libg
    {
      local f is kLib + "/libg/" + n. local fa is _iv + "/" + f.

      if exists(fa)
      {
        local fasz is open(fa):size. local fl is _ev + "/libg/" + n.

        if not _fs:haskey(f) _fs:add(f, -1).
        if _c { if not _pc:haskey(f) _pc:add(f, -1). set fl to fl + "m". }
        if not exists(fl) or _fs[f] <> fasz { set _fs[f] to fasz. nl:add(n). }
      }
    }

    if not nl:empty
    {
      _ls("init::nl - " + _join(nl)).

      local t is 0.

      if addons:available("RT")
      {
        local d is addons:RT:kscDelay(ship).

        if d > 0 set t to 2 * d.
      }
      if _rt and t = 0
      {
        // Try to work out the home planet
        local home is 0. local bl is list(). list bodies in bl.

        for bod in bl if bod:name = "Kerbin" or bod:name = "Gael" or bod:name = "Earth" { set home to bod. break. }

        if home:istype("Body") set t to 2 * (home:distance - home:radius) / constant:c.
      }
      if t >= 0.1
      {
        _dh("Waiting " + round(t, 3) + "s for communications delay with KSC").

        local s is time:seconds + t.

        until s <= time:seconds
        {
          local rem is s - time:seconds.

          _ht("Remain: " + round(rem, 3) + "s").

          if rem > 5 wait 5.
          else wait min(5, max(0.01, rem)).
        }
      }

      for n in nl
      {
        local df is "/libg/" + n. local fa is ivkLib + df. local fl is _ev + df.

        if _c
        {
          local f is kLib + df.

          if _pc[f] <> _fs[f] { set _pc[f] to _fs[f]. _dp("Compiling `" + fa + "'"). compile fa. }

          set fa to fa + "m". set fl to fl + "m".
        }

        _dp("Importing `" + fa + "' to `" + fl + "'"). copypath(fa, fl). rl:add(fl).
      }

      writejson(_fs, _fsjs).

      if _c writejson(_pc, _pcjs).
    }
  }

  for n in rl { if exists(n) { _dp("Loading `" + n + "'"). runoncepath(n). } }

  if defined _LIBG_SYSIO { sysioUseCompile(_c). if _d <> "" sysioDebugOn(_d). sysioUseRoundtrip(_rt). }
}.