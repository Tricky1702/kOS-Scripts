// Body Cache Library for the Kerbol system
// Copyright © 2017-2018, Richard Thomas Harrison.
// Acknowledgement: Steven Mading, <a href="https://github.com/Dunbaratu/">Steve Mading</a>

@LAZYGLOBAL off.
{
  global _LIBS_BODYCACHE_BCKERBOL is scriptpath().

  // The Kerbol system.
  local export is lexicon
  (
    // Home planet.
    "$home", "Kerbin",
    // Sun aka Kerbol.
    "Sun", lexicon("type", "Star", "alias", list("Kerbol", "Kun", "Kol", "Zun")),
    // Planets and moons.
    "Moho", lexicon(
      "type", "Planet",
      "maxElevation", 6817,
      "landingSpeed", 3),
    "Eve", lexicon(
      "type", "Planet",
      "maxElevation", 7526,
      "aerocapture", 62000,
      "landingSpeed", 4),
    "Gilly", lexicon(
      "type", "Moon",
      "maxElevation", 6400,
      "landingSpeed", 1),
    "Kerbin", lexicon(
      "type", "Planet",
      "maxElevation", 6764.1,
      "aerocapture", 30000,
      "landingSpeed", 4),
    "Mun", lexicon(
      "type", "Moon",
      "maxElevation", 7061,
      "landingSpeed", 3),
    "Minmus", lexicon(
      "type", "Moon",
      "maxElevation", 5725,
      "landingSpeed", 2),
    "Duna", lexicon(
      "type", "Planet",
      "maxElevation", 8264,
      "aerocapture", 15000,
      "landingSpeed", 4),
    "Ike", lexicon(
      "type", "Moon",
      "maxElevation", 12750,
      "landingSpeed", 3),
    "Dres", lexicon(
      "type", "Planet",
      "maxElevation", 5700,
      "landingSpeed", 4),
    "Jool", lexicon(
      "type", "Planet",
      "aerocapture", 155000),
    "Laythe", lexicon(
      "type", "Moon",
      // Not listed in the wiki.
      "maxElevation", 6000,
      "aerocapture", 40000,
      "landingSpeed", 3),
    "Vall", lexicon(
      "type", "Moon",
      "maxElevation", 7976,
      "landingSpeed", 3),
    "Tylo", lexicon(
      "type", "Moon",
      "maxElevation", 11290,
      "landingSpeed", 4),
    "Bop", lexicon(
      "type", "Moon",
      "maxElevation", 21758,
      "landingSpeed", 2),
    "Pol", lexicon(
      "type", "Moon",
      "maxElevation", 4000,
      "landingSpeed", 2),
    "Eeloo", lexicon(
      "type", "Planet",
      "maxElevation", 3900,
      "landingSpeed", 3)
  ).

  sysioExport(export).
}.