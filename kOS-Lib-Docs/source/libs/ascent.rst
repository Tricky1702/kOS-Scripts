.. _ascentLib:

Ascent
======

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Kevin Gisi (CheersKevin) - `ascent.ks`__
    * Steven Mading (Dunbaratu) - `launch.ks`__
    * Tony Spataro (Xeger) - `launch_asc.ks`__

The global variable ``_LIBS_ASCENT`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_ASCENT)
    {
      sysioImport(lexicon("input", "ascent", "import", importLibDir, "export", exportLibDir)).
      sysioRun(lexicon("input", "ascent", "directory", exportLibDir)).
    }

    local ascentLib is sysioGetImport(lexicon("input", "ascent", "directory", exportLibDir)).

    ascentLib["doAscent"]().
    ...

.. note::

    |commonLib| and |sysioLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Ascent example <ascentLib example>`)::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS-Lib/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if homeconnection:isconnected and body:distance < kerbin:soiradius and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          if exists(initLocal) runoncepath(initLocal).

          // Done
          if defined _LIBG_COMMON and defined _LIBG_SYSIO
            sysioNotify("Ready", true).
          else
          {
            print "common: " + (defined _LIBG_COMMON).
            print "knu:    " + (defined _LIBG_SYSIO).
          }
        }.

.. note::

    Requires:
        * |automaticLib|
        * |bodyCacheLib|
        * |enginesLib|
        * |maneuverLib|

Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 1 3

    * - Method
      - Description

    * - :func:`doAscent`
      -
    * - :func:`raisePeriapsis`
      -

.. function:: doAscent(dir, minApo, autoStage)

    :parameter dir: |kOSScalar|
    :parameter minApo: |kOSScalar|
    :parameter autoStage: |kOSBoolean|
    :return: None

.. function:: raisePeriapsis(minPeri, autoStage)

    :parameter minPeri: |kOSScalar|
    :parameter autoStage: |kOSBoolean|
    :return: None

.. _ascentLib example:

Example of using Ascent
-----------------------

    ::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS-Lib/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if homeconnection:isconnected and body:distance < kerbin:soiradius and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          // Make sure all scripts are compiled to disk to keep files small.
          if exists(initLocal) runoncepath(initLocal, lexicon("compile", true)).

          if defined _LIBG_COMMON and defined _LIBG_SYSIO
          {
            sysioImport(lexicon("input", "ascent", "import", importLibDir, "export", exportLibDir)).

            local ascentLib is sysioRun(lexicon("input", "ascent", "directory", exportLibDir)).

            // Ascend east until the apoapsis is 80km.
            ascentLib["doAscent"](90, 80000).
            // Raise the periapsis to 50km so the ascent stage will splash down.
            ascentLib["raisePeriapsis"](50000).
            // Remove the file from the local drive and memory (if not required by anything else).
            sysioDelete(ascentLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |sysioLib| replace:: :ref:`SysIO <sysioLib>`
.. |automaticLib| replace:: :ref:`Automatic <automaticLib>`
.. |bodyCacheLib| replace:: :ref:`BodyCache <bodyCacheLib>`
.. |enginesLib| replace:: :ref:`Engines <enginesLib>`
.. |maneuverLib| replace:: :ref:`Maneuver <maneuverLib>`

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/gisikw/ksprogramming/blob/master/library/ascent.ks
__ https://github.com/Dunbaratu/kerboscripts/blob/master/lib/launch.ks
__ https://github.com/xeger/kos-ramp/blob/master/launch_asc.ks
