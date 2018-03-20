// Docking Ports Library
// Copyright © 2016-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_DOCKINGPORTS is scriptpath().

  local isdp is { parameter p. return p:istype("DockingPort"). }.
  local pt is
  {
    local tl is list(). list targets in tl. tl:add(ship).

    for t in tl:clone { if t:dockingports:empty tl:remove(t). }

    return tl.
  }.
  local grpft is
  {
    parameter t is ship.
    local pl is list().

    if t:istype("Vessel")
    {
      local dp is t:dockingports.

      if not dp:empty for p in dp if p:state = "ready" pl:add(p).
    }

    return pl.
  }.
  local grp is
  {
    local rp is lexicon().

    for t in pt() { local pl is grpft(t). if not pl:empty rp:add(t, pl). }

    return rp.
  }.
  local gpftrp is
  {
    parameter t is ship, n is "".

    if t:istype("Vessel") and n:istype("String")
    {
      local pl is grpft(t).

      if not pl:empty for p in pl if p:tag = n return p.
    }

    return 0.
  }.
  local gpfrp is
  {
    parameter n is "".

    if t:istype("String") for t in pt() { local p is gpftrp(t, n). if isdp(p) return p. }

    return 0.
  }.
  local gpft is
  {
    parameter t is ship, n is "".

    if t:istype("Vessel") and n:istype("String")
    {
      local dp is t:dockingports.

      if not dp:empty for p in dp if p:tag = n return p.
    }

    return 0.
  }.
  local gp is
  {
    parameter n is "".

    if n:istype("String") for t in pt() { local p is gpft(t, n). if isdp(p) return p. }

    return 0.
  }.
  local srch is
  {
    parameter pl is list(), wpl is list().

    if isdp(pl) set pl to list(pl). if isdp(wpl) set wpl to list(wpl).

    if pl:istype("List") and wpl:istype("List") and not (pl:empty or wpl:empty)
      for wp in wpl if isdp(wp) for p in pl if isdp(p) and p:nodetype = wp:nodetype return list(p, wp).

    return list(0, 0).
  }.

  local export is lexicon
  (
    "isDockingPort", isdp,
    "getPort", gp,
    "getPortFromTarget", gpft,
    "getPortFromReadyPorts", gpfrp,
    "getPortFromTargetReadyPorts", gpftrp,
    "getReadyPorts", grp,
    "getReadyPortsFromTarget", grpft,
    "potentialTargets", pt,
    "search", srch
  ).

  sysioExport(export).
}.