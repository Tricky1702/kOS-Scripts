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
    parameter kpr, w is 0, h is 0.

    if w:istype("String") set w to w:tonumber().
    if h:istype("String") set h to h:tonumber().
    if not (kpr:istype("kOSProcessor") and w:istype("Scalar") and h:istype("Scalar")) return.
    if w > 0 set terminal:width to w. if h > 0 set terminal:height to h.

    kpr:doevent("Open Terminal").
  }.
  global closeTerminal is { parameter kpr. if not kpr:istype("kOSProcessor") return. kpr:doevent("Close Terminal"). }.
  global openCoreTerminal is { parameter w is 0, h is 0. openTerminal(core:part:getmodule("kOSProcessor"), w, h). }.
  global closeCoreTerminal is { closeTerminal(core:part:getmodule("kOSProcessor")). }.
  // Formatting
  global printAtPadL is
  {
    parameter t, px, py, pad.

    if px:istype("String") set px to px:tonumber().
    if py:istype("String") set py to py:tonumber().
    if pad:istype("String") set pad to pad:tonumber().

    printAt(("" + t):padleft(pad), px, py).
  }.
  global printAtPadR is
  {
    parameter t, px, py, pad.

    if px:istype("String") set px to px:tonumber().
    if py:istype("String") set py to py:tonumber().
    if pad:istype("String") set pad to pad:tonumber().

    printAt(("" + t):padright(pad), px, py).
  }.
  global fmtScalarA is
  {
    parameter str, ap is "", dp is 3, pad is true.

    if str:istype("String") set str to str:tonumber().
    if str:istype("Scalar")
    {
      if not dp:istype("Scalar") set dp to 3.
      if not pad:istype("Boolean") set pad to true.
      if not ap:istype("String") set ap to "".

      set dp to min(15, max(0, dp)). local t is "" + round(str, dp). set t to t + ap.

      if not pad return t.

      return t:padright(t:length + dp + 2).
    }

    return "NaN".
  }.
  global fmtScalar is { parameter str, dp is 3, pad is true. return fmtScalarA(str, "", dp, pad). }.
  // Math
  // Test whether 2 numbers are nearly equal to within 1.0x10⁻⁶
  global nearlyEquals is
  {
    parameter n1, n2, ep is 1.0e-6.

    if n1:istype("String") set n1 to n1:tonumber().
    if n2:istype("String") set n2 to n2:tonumber().
    if ep:istype("String") set ep to ep:tonumber().

    return abs(n1 - n2) < ep.
  }.
  // Test whether a vector is within 1.0x10⁻⁶ of a normalised vector
  global isnormalized is { parameter v1. return nearlyEquals(v1:mag, 1). }.
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
  global killWarp is { local tw is kuniverse:timewarp. if tw:warp > 0 { tw:cancelwarp(). until tw:issettled and ship:unpacked wait 0.01. } }.
  global doWarp is { parameter tm. if not tm:istype("Scalar") return. if tm > time:seconds { kuniverse:timewarp:warpto(tm). killWarp(). } }.
}.