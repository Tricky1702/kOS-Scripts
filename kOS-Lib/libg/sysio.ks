// SysIO Library
// Copyright © 2016-2018, Richard Thomas Harrison.
// Reference: Kevin Gisi, <a href="https://github.com/gisikw/ksprogramming/blob/master/episodes/e045/knu.ks">knu.ks</a>

@LAZYGLOBAL off.
{
  global _LIBG_SYSIO is scriptpath().

  // Internal vars
  // Base directory on the archive
  local _kLib is "kOS-Lib".
  // Archive libs directory and volume
  local _ild is _kLib + "/libs". local _iv is archive:name + ":". local _ivkLib is _iv + "/" + _kLib.
  // Local libs directory and volume
  local _eld is "libs". local _ev is _LIBG_SYSIO:tostring:split(":/")[0] + ":".
  // Compile, Home, Roundtrip
  local _c is false. local _h is 0. local _rt is false.
  // Debug, Default debug filename, Current debug filename
  local _dbg is false. local _defDbgFN is _ivkLib + "/debug.log". local _dbgFN is _defDbgFN.
  // Libs loaded, Temp store for required libs, Stack
  local _l is lexicon(). local _rl is lexicon(). local _s is stack().
  // Filesizes, Compiled
  local _fs is lexicon(). local _pc is lexicon().
  // Filesizes store, Compiled store
  local _fsjs is _ivkLib + "/fsize.json". local _pcjs is _ivkLib + "/csize.json".
  // Runmode, Runmode filename
  local _sysioRM is 0. local _sysioRMFN is _ev + "/runmode.ks".
  // Internal helper function
  local _hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.

  // Load script filesizes if available
  if _hc()
  {
    if exists(_fsjs) set _fs to readjson(_fsjs).
    if exists(_pcjs) set _pc to readjson(_pcjs).
  }

  if not addons:available("RT")
  {
    // Try to work out the home planet
    local _bl is list(). list bodies in _bl.

    for bod in bl if bod:name = "Kerbin" or bod:name = "Gael" or bod:name = "Earth" { set _h to bod. break. }
  }

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
  local _fe is
  {
    parameter n, ksm is false.

    if n = "" return n.
    if n:endswith(".ksm") { if ksm return n. return n:replace(".ksm", ".ks"). }
    if not n:endswith(".ks") set n to n + ".ks".
    if ksm and _c return n + "m".

    return n.
  }.
  local _fd is { parameter d. if d = "" return d. set d to _trim(d, "/"). if d = "" return d. return d + "/". }.
  local _fv is { parameter vol. set vol to _tr(vol, ":/"). if vol = "" return _ev. return vol + ":". }.
  local _fp is { parameter p. local sp is p:split(":"). if sp:length = 1 return _trim(p, "/"). return sp[0] + ":/" + _trim(sp[1], "/"). }.
  local _ls is
  {
    parameter t, f is _ivkLib + "/sysio.log", dbg is _dbg.

    if dbg
    {
      local sf is _fp(f):split(":"). local vol is sf[0]. set f to _tl(sf[sf:length - 1], "/").

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
  local _dp is { parameter t. if _dbg { print "sysio::" + t. _ls(t). } }.
  local _ht is { parameter t, col is green. hudtext(t, 3, 2, 20, col, false). }.
  local _wr is
  {
    if not _hc() or not _rt return.

    local t is 0.

    if addons:available("RT") set t to 2 * addons:RT:kscDelay(ship).
    else if _h:istype("Body") set t to 2 * (_h:distance - _h:radius) / constant:c.

    if t >= 0.1
    {
      local dn is { parameter t. _dp(t). _ht(t, RGB(0.5, 0.5, 1)). }.

      dn("Waiting " + round(t, 3) + "s for communications delay with KSC.").

      local s is time:seconds + t.

      until s <= time:seconds
      {
        local rem is s - time:seconds.

        _ht("Remain: " + round(rem, 3) + "s").

        if rem > 5 wait 5.
        else wait min(5, max(0.01, rem)).
      }
    }
  }.
  local _ck is { parameter l, k. if l:istype("Lexicon") and l:haskey(k) return true. return false. }.
  local _ckt is { parameter l, k, t. if _ck(l, k) and t:istype("String") and l[k]:istype(t) return true. return false. }.
  local _gkwt is { parameter l, k, t, d. if _ckt(l, k, t) return l[k]. return d. }.
  local _join is
  {
    parameter ls.
    local l is list().

    if ls:istype("List") set l to ls:copy.
    else if ls:istype("Stack") { for s in ls l:add(s). }
    else return "Incorrect type - " + ls:typename.

    if l:empty return "Empty".

    return "`" + l:join("', `") + "'".
  }.
  local _hasBK is { parameter l. return l:istype("Lexicon") and l:haskey("$key") and l:haskey("$path") and l:haskey("$reqLibs"). }.
  local _prBK is
  {
    parameter pre, k, val.

    if not _hasBK(val) { if val:hassuffix("dump") set val to val:dump. _ls(pre + "['" + k + "'] - " + val). return false. }

    _ls(pre + "['" + k + "']['$key'] -     `" + val["$key"] + "'").
    _ls(pre + "['" + k + "']['$path'] -    `" + val["$path"] + "'").
    _ls(pre + "['" + k + "']['$reqLibs'] - " + _join(val["$reqLibs"])).

    return true.
  }.
  local _dpath is
  {
    parameter p.

    if not p:istype("String") or p = "" return. 

    set p to _fp(p). local sp is p:split(":/").

    _ls("delPath::path - `" + p + "'").

    if sp:length = 1 { set sp to list(_ev:substring(0, _ev:length - 1), p). set p to sp:join(":/"). }
    if not (sp[0] = "0" or sp[0] = archive:name) and exists(p) { _ls("delPath::Deleting `" + p + "'"). deletepath(p). }
  }.
  local _dk is
  {
    parameter k, dl.

    if not k:istype("String") or k = "" return. 

    _ls("delKey::key - `" + k + "'").

    if _l:haskey(k)
    {
      local val is _l[k]. local p is list().

      for lk in _l:keys if lk <> k and _ckt(_l[lk], "$reqLibs", "List") and _l[lk]["$reqLibs"]:contains(k) p:add(lk).

      _ls("delKey::* Parents - " + _join(p)).

      if p:empty
      {
        local rl is list().

        if _prBK("delKey::_l", k, val) set rl to val["$reqLibs"]:copy.

        _ls("delKey::Removing `" + k + "'"). _l:remove(k).

        // Remove the children.
        if not rl:empty { _ls("delKey::* Children: " + _join(rl)). for rk in rl if _l:haskey(rk) dl(_l[rk]). }
      }
    }

    _ls("delKey::Finishing - `" + k + "'").

    if _l:keys:empty _ls("delKey::_l - Empty!").
    else if not _l:haskey(k) for lk in _l:keys _prBK("delKey::_l", lk, _l[lk]).
  }.
  local _fchng is { parameter l, n, d is _ild. local k is _fd(d) + _fe(n). return not _ck(l, k) or l[k] <> open(_fp(_iv + k)):size. }.
  local _niKS is { parameter n, j is _ild, k is _eld, vol is _ev. return not exists(_fp(_fv(vol) + _fd(k) + _fe(n, true))) or _fchng(_fs, n, j). }.
  // Internal SysIO functions
  local dLex is
  {
    parameter l.

    if _hasBK(l) { _dpath(l["$path"]). _dk(l["$key"], dLex). }
    else if l:istype("String") and l <> ""
    {
      local dImp is { parameter n, d is _eld. local k is _fd(d) + _fe(n). _dpath(_ev + _fe(k, true)). _dk(k, dLex). }.
      set l to _fp(l). local sl is l:split("/"). local sl0 is sl[0]. local sllen is sl:length.

      if sl0:contains(":")
      {
        if sl0[sl0:length - 1] = ":" { if sllen = 1 return. set sl to sl:sublist(1, sllen - 1). set sl0 to sl[0]. set sllen to sl:length. }
        else set sl0 to sl0:split(":")[1].
      }
      if sllen = 1 dImp(sl0).
      else { local dl is sl:sublist(0, sllen - 1). dImp(sl[sllen - 1], dl:join("/")). }
    }
  }.
  local cKS is
  {
    parameter n, j is _ild, k is _eld, vol is _ev.
    local jn is _fd(j) + _fe(n). local pjn is _fp(_iv + jn).

    if not exists(pjn) { _dp("Compile: `" + pjn + "' does not exist!"). return. }
    if _fchng(_pc, n, j)
    {
      set _pc[jn] to open(pjn):size.

      if k = "*" { _dp("Compiling `" + pjn + "'"). compile pjn. }
      else
      {
        local pkn is _fp(_fv(vol) + _fd(k) + _fe(n) + "m").

        _dp("Compiling `" + pjn + "' to `" + pkn + "'"). compile pjn to pkn.
      }

      writejson(_pc, _pcjs).
    }
  }.
  local iKS is
  {
    parameter n, j is _ild, k is _eld, vol is _ev.

    if not n:istype("String") or n = "" return.
    if not n:matchespattern("[.]ksm?$") set n to n + ".ks".

    local pjn is _fp(_iv + _fd(j) + n).

    if _c
    {
      if not n:endswith(".ksm") set pjn to pjn + "m".
      if not exists(pjn) or _fchng(_pc, n, j) cKS(n, j, "*").
    }
    if not exists(pjn) { _dp("Import: `" + pjn + "' does not exist!"). return. }
    if _niKS(n, j, k, vol)
    {
      local jn is _fd(j) + _fe(n). local pkn is _fp(_fv(vol) + _fd(k) + _fe(n, true)).
      set _fs[jn] to open(_fp(_iv + jn)):size.

      _dp("Importing `" + pjn + "' to `" + pkn + "'"). copypath(pjn, pkn).
      writejson(_fs, _fsjs).
    }
  }.
  local rKS is
  {
    parameter n, d is _eld, vol is _ev.

    if not n:istype("String") or n = "" return lexicon().

    local k is _fd(d) + _fe(n). local p is _fp(_fv(vol) + _fe(k, true)).

    _ls("runKS::k - `" + k + "'").

    if not exists(p) { _dp("Run: `" + p + "' does not exist!"). return lexicon(). }
    if not _l:haskey(k)
    {
      _l:add(k, lexicon()). _s:push(k).

      _ls("runKS::_s - " + _join(_s)).
      _dp("Loading `" + p + "'"). runoncepath(p).
      _ls("runKS::_s - " + _join(_s)).

      if _l:haskey(k) and _l[k]:istype("Lexicon")
      {
        local rl is _gkwt(_rl, k, "List", list()).
        set _l[k]["$key"] to k. set _l[k]["$path"] to p. set _l[k]["$reqLibs"] to rl:copy.
      }

      if _rl:haskey(k) _rl:remove(k).
    }

    _ls("runKS::Finishing - `" + k + "'").

    for lk in _l:keys _prBK("runKS::_l", lk, _l[lk]).

    if _l:haskey(k) return _l[k].

    return lexicon().
  }.
  local pCIR is
  {
    parameter sp.
    local d is "". local vol is sp[0]. local vole is vol[vol:length - 1].

    if sp:length = 2 { if not vole = ":" { set d to vol. set vol to _ev. } }
    else
    {
      local dl is sp:sublist(1, sp:length - 1). set d to dl:join("/").

      if not vole = ":" { set d to vol + "/" + d. set vol to _ev. }
    }

    return list(_fd(d), _fv(vol)).
  }.

  // Global
  global sysioFixDir is { parameter d. if d:istype("String") return _fd(d). return d. }.
  global sysioFixExt is { parameter n, ksm is false. if not ksm:istype("Boolean") set ksm to false. if n:istype("String") return _fe(n, ksm). return n. }.
  global sysioFixPath is { parameter p. if p:istype("String") return _fp(p). return p. }.
  global sysioFixVol is { parameter vol. if vol:istype("String") return _fv(vol). return vol. }.
  global sysioNotify is
  {
    parameter t, p is false, col is green.
    set t to "" + t.

    if not p:istype("Boolean") set p to false.
    if not col:istype("RGBA") set col to green.

    _ht(t, col).

    if p print t.
  }.
  global sysioNotifyDebug is { parameter t. if _dbg sysioNotify("DEBUG: " + t, true, RGB(.5, .5, 1)). }.
  global sysioNotifyError is { parameter t. sysioNotify("ERROR: " + t, true, red). }.
  global sysioNotifyWarn is { parameter t. sysioNotify("WARN: " + t, true, yellow). }.
  global sysioDebugOff is { set _dbg to false. }.
  global sysioDebugOn is { parameter f is "". set _dbg to true. if not f:istype("String") or f = "" set f to _defDbgFN. set _dbgFN to f. }.
  global sysioDLog is { parameter t, f is _dbgFN. set t to "" + t. if not f:istype("String") set f to _defDbgFN. _ls(t, f, _dbg). }.
  global sysioDPrint is { parameter t, f is _dbgFN. sysioNotifyDebug(t). sysioDLog(t, f). }.
  global sysioLog is { parameter t, f. local d is _dbg. set _dbg to true. sysioDLog(t, f). set _dbg to d. }.
  global sysioRunmodeName is
  {
    parameter f is "".

    if f:istype("String") and f <> ""
    {
      local sf is _fp(_fe(f)):split(":/"). local vol is sf[0]. set f to sf[sf:length - 1].

      if sf:length = 1 or sf:length = 2 and (vol = "0" or vol = archive:name) set vol to _ev:substring(0, _ev:length - 1).

      set _sysioRMFN to list(_fv(vol), _tl(f, "/")):join(":/").
    }

    return _sysioRMFN.
  }.
  global sysioGetRunmode is { local sysioRunModeVar is 0. if exists(_sysioRMFN) runpath(_sysioRMFN). return sysioRunModeVar. }.
  global sysioSetRunmode is
  {
    parameter sysioRunModeVar is 0.
    set _sysioRM to sysioRunModeVar.

    if exists(_sysioRMFN) deletepath(_sysioRMFN).

    _ls("set sysioRunModeVar to " + sysioRunModeVar + ".", _sysioRMFN, true).

    return sysioRunModeVar.
  }.
  global sysioUseCompile is { parameter f. if not f:istype("Boolean") set f to false. set _c to f. }.
  global sysioUseRoundtrip is { parameter f. if not f:istype("Boolean") set f to false. set _rt to f. }.
  global sysioGetImport is
  {
    parameter il is lexicon().
    local gImp is { parameter n, d is _eld. local k is _fd(d) + _fe(n). if _l:haskey(k) return _l[k]. return lexicon(). }.

    if il:istype("String") and il <> "" return gImp(il).
    if _ck(il, "input")
    {
      local n is il["input"]. local d is _gkwt(il, "directory", "String", _eld).

      if n:istype("String") and n <> "" return gImp(n, d).
      if n:istype("List") and not n:empty
      {
        local lx is lexicon(). local ul is list().

        for fn in n if fn:istype("String") and fn <> "" and not ul:contains(fn) ul:add(fn).
        for fn in ul
        {
          local l is gImp(fn, d).

          if _ckt(l, "$key", "String") lx:add(l["$key"], l).
          else lx:add(_fd(d) + _fe(fn), l).
        }

        return lx.
      }
    }

    return lexicon().
  }.
  global sysioDelete is
  {
    parameter il is lexicon().

    if il:istype("String") and il <> "" { dLex(il). return. }
    if not il:istype("Lexicon") or il:keys:empty return.
    if _hasBK(il) { dLex(il). return. }
    if il:haskey("input")
    {
      local n is il["input"].

      if _hasBK(n) { dLex(n). return. }

      local dImp is { parameter n, d, vol. local k is _fd(d) + _fe(n). _dpath(_fp(_fv(vol) + _fe(k, true))). _dk(k, dLex). }.
      local d is _gkwt(il, "directory", "String", _eld).
      local vol is _gkwt(il, "volume", "String", _ev).

      if n:istype("String") and n <> "" dImp(n, d, vol).
      else if n:istype("List") and not n:empty
      {
        local ul is list().

        for fn in n if fn:istype("String") and fn <> "" and not ul:contains(fn) ul:add(fn).
        for fn in ul dImp(fn, d, vol).
      }
    }
  }.
  global sysioDeleteAll is { local lc is _l:values:copy. for l in lc dLex(l). }.
  global sysioCompile is
  {
    parameter il is lexicon().

    if not _hc() return.
    if il:istype("String") and il <> ""
    {
      set il to _fp(il).
      local sp is il:split("/"). local n is sp[sp:length - 1].

      if sp:length = 1 cKS(n, "", "*").
      else cKS(n, pCIR(sp)[0], "*").

      return.
    }
    if _ck(il, "input")
    {
      local n is il["input"].
      local j is _gkwt(il, "import", "String", _ild).
      local k is _gkwt(il, "export", "String", _eld).
      local vol is _gkwt(il, "volume", "String", _ev).

      if n:istype("String") and n <> "" { if k <> "*" _wr(). cKS(n, j, k, vol). }
      else if n:istype("List") and not n:empty
      {
        local ul is list().

        if k <> "*" _wr().

        for fn in n if fn:istype("String") and fn <> "" and not ul:contains(fn) ul:add(fn).
        for fn in ul cKS(fn, j, k, vol).
      }
    }
  }.
  global sysioImport is
  {
    parameter il is lexicon().

    if not _hc() return.
    if il:istype("String") and il <> ""
    {
      set il to _fp(il).
      local sp is il:split("/"). local n is sp[sp:length - 1].

      if sp:length = 1 { if _niKS(n) { _wr(). iKS(n). } }
      else { local j is pCIR(sp)[0]. if _niKS(n, j) { _wr(). iKS(n, j). } }

      return.
    }
    if _ck(il, "input")
    {
      local n is il["input"].
      local j is _gkwt(il, "import", "String", _ild).
      local k is _gkwt(il, "export", "String", _eld).
      local vol is _gkwt(il, "volume", "String", _ev).

      if n:istype("String") and n <> "" and _niKS(n, j, k, vol) { _wr(). iKS(n, j, k, vol). }
      else if n:istype("List") and not n:empty
      {
        local ul is list().

        for fn in n if fn:istype("String") and fn <> "" and not ul:contains(fn) and _niKS(fn, j, k, vol) ul:add(fn).

        if not ul:empty { _wr(). for fn in ul iKS(fn, j, k, vol). }
      }
    }
  }.
  global sysioRun is
  {
    parameter il is lexicon().

    if il:istype("String") and il <> ""
    {
      set il to _fp(il).
      local sp is il:split("/"). local n is sp[sp:length - 1].

      if sp:length = 1 return rKS(n).

      local ldv is pCIR(sp).

      return rKS(n, ldv[0], ldv[1]).
    }.
    if _ck(il, "input")
    {
      local n is il["input"].
      local d is _gkwt(il, "directory", "String", _eld).
      local vol is _gkwt(il, "volume", "String", _ev).

      if n:istype("String") and n <> "" return rKS(n, d, vol).
      if n:istype("List") and not n:empty
      {
        local lx is lexicon(). local ul is list().

        for fn in n if fn:istype("String") and fn <> "" and not ul:contains(fn) ul:add(fn).
        for fn in ul
        {
          local l is rKS(fn, d, vol).

          if not l:istype("Lexicon") lx:add(_fd(d) + _fe(fn), l).
          else if not l:keys:empty.
          {
            if _ckt(l, "$key", "String") lx:add(l["$key"], l).
            else lx:add(_fd(d) + _fe(fn), l).
          }
        }

        return lx.
      }
    }

    return lexicon().
  }.
  global sysioRequires is
  {
    parameter il is lexicon().

    if not _ck(il, "scriptpath") and not _ck(il, "input") return lexicon().

    local sp is il["scriptpath"].

    if not sp:istype("String") set sp to sp:tostring.

    set sp to _fp(_fe(sp)).

    if sp = "" return lexicon().

    _ls("sysioRequires::Script path - `" + sp + "'").

    local lx is lexicon(). local ls is il["input"]. local wasStr is false.

    if ls:istype("String") and ls <> "" { _ls("sysioRequires::Input name - `" + ls + "'"). set ls to list(ls). set wasStr to true. }
    if ls:istype("List") and not ls:empty
    {
      local j is _gkwt(il, "import", "String", _ild).
      local k is _gkwt(il, "export", "String", _eld).
      local vol is _gkwt(il, "volume", "String", _ev).
      local ul is list(). local nl is list().

      for n in ls if n:istype("String") and n <> "" and not ul:contains(n) ul:add(n).

      if not wasStr _ls("sysioRequires::Input list - " + _join(ul)).
      if _hc() for n in ul if _niKS(n, j, k, vol) nl:add(n).
      if not nl:empty { _ls("sysioRequires::nl - " + _join(nl)). _wr(). for n in nl iKS(n, j, k, vol). }

      local dk is _fd(k). local spdn is _tl(sp:split(":")[1], "/").

      for n in ul
      {
        local dn is dk + _fe(n).

        _ls("sysioRequires::dn - `" + dn + "'").

        if not _l:haskey(dn) rKS(n, k, vol).
        if _l:haskey(dn)
        {
          if _l:haskey(spdn)
          {
            if not _rl:haskey(spdn) _rl:add(spdn, list()).
            if not _rl[spdn]:contains(dn) _rl[spdn]:add(dn).

            _ls("sysioRequires::_rl['" + spdn + "'] - " + _join(_rl[spdn])).
          }

          lx:add(dn, _l[dn]).
        }
      }

      _ls("sysioRequires::Finishing - `" + sp + "'").

      if _l:haskey(spdn) and _hasBK(_l[spdn])
      {
        local rl is _gkwt(_rl, spdn, "List", list()).

        for l in rl _l[spdn]["$reqLibs"]:add(l).

        _prBK("sysioRequires::_l", spdn, _l[spdn]).
      }

      for lk in lx:keys _prBK("sysioRequires::lx", lk, lx[lk]).

      if lx:length = 1 return lx[lx:keys[0]].
    }

    return lx.
  }.
  global sysioExport is { parameter d. if not _s:empty { local k is _s:pop(). set _l[k] to d. _prBK("sysioExport::_l", k, _l[k]). } }.
}.