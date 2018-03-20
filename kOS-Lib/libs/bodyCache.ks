// Body Cache Library
// Copyright © 2017-2018, Richard Thomas Harrison.
// Acknowledgement: Steven Mading, <a href="https://github.com/Dunbaratu/">Steve Mading</a>

@LAZYGLOBAL off.
{
  global _LIBS_BODYCACHE is scriptpath().

  local _bcLex is lexicon(). local _bcHomeList is list().
  local _bcNames is list(). local _bcBodies is list(). list bodies in _bcBodies.

  for bod in _bcBodies _bcNames:add(bod:name).

  local bcInit is
  {
    parameter bod, dbp is lexicon().
    local bmu is bod:mu. local br is bod:radius. local batm is bod:atm.
    local bType is getKeyWithType(dbp, "type", "String", "Unknown").
    local bAlias is getKeyWithType(dbp, "alias", "List", list()).

    if bAlias:empty set bAlias to getKeyWithType(dbp, "alias", "String", "").

    local bMaxElev is getKeyWithType(dbp, "maxElevation", "Scalar", 0).
    local bLandSpd is getKeyWithType(dbp, "landingSpeed", "Scalar", 0).
    local bLowOrb is getKeyWithType(dbp, "lowOrbit", "Scalar", 0).
    local bAeroCap is getKeyWithType(dbp, "aerocapture", "Scalar", 0).

    if bLowOrb = 0
    {
      if batm:exists set bLowOrb to batm:height * 1.05.
      else if bMaxElev > 0 set bLowOrb to bMaxElev * 1.1.
      else set bLowOrb to br * 0.125.
    }

    if bAeroCap = 0 and batm:exists and bType <> "Star"
    {
      sysioNotifyDebug("Calculating aerocapture height for `" + bod:name + "'").

      // Use binary search to find aerocapture height at 0.002 atmospheric pressure.
      local pAeroCap is 0.002.
      // First guess at half way between the surface and the top of the atmosphere.
      set bAeroCap to batm:height / 2. local aeroCapDiff is bAeroCap.
      // Find the pressure at this altitude.
      local p is batm:altitudePressure(bAeroCap). local i is 0.

      until i = 32 or nearlyEquals(p, pAeroCap)
      {
        set i to i + 1. set aeroCapDiff to aeroCapDiff / 2.

        // Too high.
        if p < pAeroCap set bAeroCap to bAeroCap - aeroCapDiff.
        // Too low.
        else if p > pAeroCap set bAeroCap to bAeroCap + aeroCapDiff.

        set p to batm:altitudePressure(bAeroCap).
      }

      sysioNotifyDebug("* (" + ("" + i):padleft(2) + ") " + fmtScalar(bAeroCap, 2, false)).
    }

    return lexicon
    (
      // The body.
      "body", bod,
      // "Star", "Planet", "Moon", or "Unknown".
      "type", bType,
      // Alias name of the body.
      "alias", bAlias,
      // The acceleration (ms⁻²) at "sea level".
      "surfaceGravity", bmu / br^2,
      // The peak of the highest mountain (m).
      "maxElevation", bMaxElev,
      // Lowest safe orbit altitude (m).
      "lowOrbit", bLowOrb,
      // Lowest safe orbit speed (ms⁻¹).
      "lowOrbitSpeed", sqrt(bmu / (br + bLowOrb)),
      // Geo-stationary orbit altitude (m).
      "geoOrbit", cbrt(bmu / bod:angularvel:mag^2) - br,
      // Geo-stationary orbit speed (ms⁻¹).
      "geoOrbitSpeed", sqrt(bmu / cbrt(bmu / bod:angularvel:mag^2)),
      // Approxiamate height to perform an aerocapture (m).
      "aerocapture", bAeroCap,
      // Desried speed to land at (ms⁻¹).
      "landingSpeed", bLandSpd
    ).
  }.
  local bcInitBodies is
  {
    parameter fn.

    local l is sysioRequires
    (
      lexicon
      (
        "scriptpath", _LIBS_BODYCACHE,
        "input", fn,
        "import", importLibDir + "/bodyCache",
        "export" , exportLibDir + "/bodyCache",
        "volume", exportVol
      )
    ).

    if not l:istype("Lexicon") return.

    for n in l:keys
      if n:istype("String") and n <> ""
      {
        if n[0] = "*"
        {
          set n to n:substring(1, n:length - 1).

          if _bcLex:haskey(n) _bcLex:remove(n).
          if not _bcNames:contains(n) _bcNames:add(n).
        }

        if n = "$home" _bcHomeList:add(l["$home"]).
        else if _bcNames:contains(n)
        {
          if not _bcLex:haskey(n)
          {
            local bcBody is bcInit(body(n), l[n]).

            sysioDLog("bcInitBodies::`" + n + "'").
            _bcLex:add(n, bcBody).

            local alias is getKeyWithType(bcBody, "alias", "List", list()).

            if alias:empty set alias to getKeyWithType(bcBody, "alias", "String", "").
            if alias:istype("String") and alias <> "" or alias:istype("List") and not alias:empty
            {
              local bcBodyCopy is bcBody:copy. set bcBodyCopy["alias"] to n.

              if alias:istype("String")
              {
                sysioDLog("bcInitBodies::alias - " + alias).

                if not _bcLex:haskey(alias) _bcLex:add(alias, bcBodyCopy).
              }
              else
              {
                sysioDLog("bcInitBodies::alias - `" + alias:join("', `") + "'").

                for al in alias if al:istype("String") and al <> "" and not _bcLex:haskey(al) _bcLex:add(al, bcBodyCopy).
              }
            }
          }

          local iter is _bcNames:iterator.

          until not iter:next if n = iter:value { _bcNames:remove(iter:index). break. }
        }
      }
  }.

  if _bcNames:contains("Kerbin") bcInitBodies("bcKerbol").
  if _bcNames:contains("Sarnus") bcInitBodies("bcOPM").
  if _bcNames:contains("Valentine") bcInitBodies("bcValentine").
  if _bcNames:contains("Gael") bcInitBodies("bcGalileo").

  // Initialise any other bodies.
  if not _bcNames:empty for n in _bcNames if n <> "" _bcLex:add(n, bcInit(body(n))).

  sysioDLog("bodyCache::_bcLex - " + _bcLex:dump).

  local _bcLexKeys is _bcLex:keys. local bcHome is "".

  if not _bcHomeList:empty set bcHome to _bcHomeList[0].

  local export is lexicon
  (
    "containsName", { parameter n. if not n:istype("String") return false. return _bcLexKeys:contains(n). },
    "home", bcHome,
    "isHome", { parameter n. if not n:istype("String") return false. return n = bcHome. },
    "names", _bcLexKeys
  ).

  for n in _bcLexKeys export:add(n, _bcLex[n]).

  sysioExport(export).
}.