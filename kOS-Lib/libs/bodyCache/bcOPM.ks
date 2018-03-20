// Body Cache Library for the Outer Planets mod
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_BODYCACHE_BCOPM is scriptpath().

  // The Outer Planets mod system.
  local export is lexicon
  (
    // Planets and moons.
    "Sarnus", lexicon("type", "Planet"),
    "Hale", lexicon("type", "Moon"),
    "Ovok", lexicon("type", "Moon"),
    // Eeloo is a moon of Sarnus in this mod
    "*Eeloo", lexicon("type", "Moon"),
    "Slate", lexicon("type", "Moon"),
    "Tekto", lexicon("type", "Moon"),
    "Urlum", lexicon("type", "Planet"),
    "Polta", lexicon("type", "Moon"),
    "Priax", lexicon("type", "Moon"),
    "Wal", lexicon("type", "Moon"),
    "Tal", lexicon("type", "Moon"),
    "Neidon", lexicon("type", "Planet"),
    "Thatmo", lexicon("type", "Moon"),
    "Nissee", lexicon("type", "Moon"),
    "Plock", lexicon("type", "Planet"),
    "Karen", lexicon("type", "Moon")
  ).

  sysioExport(export).
}.