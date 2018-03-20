// Body Cache Library for the Valentine system
// Copyright © 2017-2018, Richard Thomas Harrison.

@LAZYGLOBAL off.
{
  global _LIBS_BODYCACHE_BCVALENTINE is scriptpath().

  // The Extrasolar Kerbol system.
  local export is lexicon
  (
    // Companion star of Kerbol.
    "Valentine", lexicon("type", "Star"),
    // Planets and moons.
    "Fust", lexicon("type", "Planet"),
    "Heba", lexicon("type", "Planet"),
    "Serex", lexicon("type", "Moon"),
    "Lomina", lexicon("type", "Planet"),
    "Deemo", lexicon("type", "Moon"),
    "Javine", lexicon("type", "Moon"),
    "Maol", lexicon("type", "Moon"),
    "Ucella", lexicon("type", "Moon"),
    "Mir", lexicon("type", "Planet"),
    "Solyth", lexicon("type", "Planet"),
    "Semth", lexicon("type", "Moon")
  ).

  sysioExport(export).
}.