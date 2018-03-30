// Common Library
// Copyright © 2016-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBG_COMMON is scriptpath().

  // Vars
  global importLibDir is "kOS-Lib/libs". global importVol is archive:name + ":".
  global exportLibDir is "libs". global exportVol is _LIBG_COMMON:tostring:split(":/")[0] + ":".
  global g0 is 9.80665.
  global vecorigin is v(0, 0, 0).
  global bignum is 1.0e35. global smallnum is 1.0e-35.
  global onethird is 1 / 3.
  global twoPi is 2 * constant:pi. global halfPi is constant:pi / 2.
  // Funcs
  // Lexicons
  global checkKey is { parameter l, k. if l:istype("Lexicon") and l:haskey(k) return true. return false. }.
  global checkKeyType is { parameter l, k, t. if checkKey(l, k) and t:istype("String") and l[k]:istype(t) return true. return false. }.
  global getKeyWithType is { parameter l, k, t, d. if checkKeyType(l, k, t) return l[k]. return d. }.
  // Terminal
  global openTerminal is
  {
    parameter kpr, wid is 0, hgt is 0.

    if not kpr:istype("kOSProcessor") return.

    if wid:istype("String") set wid to wid:tonumber().
    else if not wid:istype("Scalar") set wid to 0.

    if hgt:istype("String") set hgt to hgt:tonumber().
    else if not hgt:istype("Scalar") set hgt to 0.

    if wid > 0 set terminal:width to wid. if hgt > 0 set terminal:height to hgt.

    kpr:doevent("Open Terminal").
  }.
  global closeTerminal is { parameter kpr. if not kpr:istype("kOSProcessor") return. kpr:doevent("Close Terminal"). }.
  global openCoreTerminal is { parameter wid is 0, hgt is 0. openTerminal(core:part:getmodule("kOSProcessor"), wid, hgt). }.
  global closeCoreTerminal is { closeTerminal(core:part:getmodule("kOSProcessor")). }.
  // Formatting
  global printAtPadL is
  {
    parameter t, px, py, pad.

    if px:istype("String") set px to px:tonumber().
    if py:istype("String") set py to py:tonumber().
    if pad:istype("String") set pad to pad:tonumber().

    printAt(("" + t):padleft(pad - px), px, py).
  }.
  global printAtPadR is
  {
    parameter t, px, py, pad.

    if px:istype("String") set px to px:tonumber().
    if py:istype("String") set py to py:tonumber().
    if pad:istype("String") set pad to pad:tonumber().

    printAt(("" + t):padright(pad - px), px, py).
  }.
  global fmtScalarA is
  {
    parameter n, ap is 0, dp is -1.

    if n:istype("String") set n to n:tonumber().
    if n:istype("Scalar")
    {
      if not ap:istype("String") set ap to "".
      if not dp:istype("Scalar") or dp < 0 set dp to 3.

      set dp to min(15, dp).

      if dp = 0 set n to round(n).
      else set n to round(n, dp).

      return n:tostring() + ap.
    }

    return "NaN".
  }.
  global fmtScalar is { parameter n, dp is -1. return fmtScalarA(n, "", dp). }.
  // Math
  // Test whether 2 numbers are nearly equal to within 1.0x10⁻⁶
  global nearlyEquals is
  {
    parameter n1, n2, ep is 0.

    if n1:istype("String") set n1 to n1:tonumber().
    else if not n1:istype("Scalar") return false.
    if n2:istype("String") set n2 to n2:tonumber().
    else if not n2:istype("Scalar") return false.

    if ep:istype("String") set ep to ep:tonumber().
    else if not (ep:istype("Scalar") and ep > 0) set ep to 1.0e-6.

    return abs(n1 - n2) < ep.
  }.
  // Test whether a vector is a normalised vector, 1² is still 1
  global isnormalized is { parameter v1. if not v1:istype("Vector") return false. return nearlyEquals(v1:sqrmagnitude, 1). }.
    // Alias
    global isnormalised is isnormalized.
  // Cubed root - ∛n
  global cbrt is { parameter n. if n:istype("String") set n to n:tonumber(). if not n:istype("Scalar") return 0. return n^onethird. }.
  // <a href="https://en.wikipedia.org/wiki/Triple_product">Triple product</a>
  global vectormixedproduct is { parameter v1, v2, v3. return vdot(v1, vcrs(v2, v3)). }.
    // Aliases
    global vmxp is vectormixedproduct.
    global scalartripleproduct is vectormixedproduct.
    global strp is vectormixedproduct.
  global vectortripleproduct is { parameter v1, v2, v3. return vcrs(v1, vcrs(v2, v3)). }.
    // Alias
    global vtrp is vectortripleproduct.
  // Fourth wall
  global killWarp is { local tw is kuniverse:timewarp. if tw:warp > 0 { tw:cancelwarp(). wait until tw:issettled and ship:unpacked. } }.
  global doWarp is { parameter tm. if not tm:istype("Scalar") return. if tm > time:seconds { kuniverse:timewarp:warpto(tm). killWarp(). } }.
}.