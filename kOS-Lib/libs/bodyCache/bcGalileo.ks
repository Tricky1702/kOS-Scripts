// Body Cache Library for the Galileo system
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_BODYCACHE_BCGALILEO is scriptpath().

  // The Gael system.
  local export is lexicon
  (
    // Home planet.
    "$home", "Gael",
    // Primary star.
    "Ciro", lexicon("type", "Star"),
    // Planets and moons.
    "Icarus", lexicon("type", "Planet"),
    "Thalia", lexicon("type", "Planet"),
    "Eta", lexicon("type", "Moon"),
    "Niven", lexicon("type", "Planet"),
    "Gael", lexicon("type", "Planet"),
    "Iota", lexicon("type", "Moon"),
    "Ceti", lexicon("type", "Moon"),
    "Tellumo", lexicon("type", "Planet"),
    "Lili", lexicon("type", "Moon"),
    "Gratian", lexicon("type", "Planet"),
    "Geminus", lexicon("type", "Moon"),
    "Otho", lexicon("type", "Planet"),
    "Augustus", lexicon("type", "Moon"),
    "Hephaestus", lexicon("type", "Moon"),
    "Jannah", lexicon("type", "Moon"),
    "Gauss", lexicon("type", "Planet"),
    "Loki", lexicon("type", "Moon"),
    "Catullus", lexicon("type", "Moon"),
    "Tarsiss", lexicon("type", "Moon"),
    "Nero", lexicon("type", "Planet"),
    "Hadrian", lexicon("type", "Moon"),
    "Narisse", lexicon("type", "Moon"),
    "Muse", lexicon("type", "Moon"),
    "Minona", lexicon("type", "Moon"),
    "Hox", lexicon("type", "Planet"),
    "Argo", lexicon("type", "Moon"),
    "Leto", lexicon("type", "Planet"),
    // Companion star.
    "Grannus", lexicon("type", "Star")
  ).

  sysioExport(export).
}.