.. _orbitsLib:

Orbits
======

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Kevin Gisi (CheersKevin) - `orbit.ks`__
    * Steven Mading (Dunbaratu) - `prediction.ks`__

The global variable ``_LIBS_ORBITS`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_ORBITS) knuImport("orbits", importLibDir, exportLibDir).

    local orbitsLib is knuGetImport("orbits", exportLibDir).
    // Do stuff with this lib.
    ...

.. note::

    |commonLib| and |knuLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Orbits example <orbitsLib example>`)::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if ship:obt:body:name = "Kerbin" and homeconnection:isconnected and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          if exists(initLocal) runoncepath(initLocal).

          // Done
          if defined _LIBG_COMMON and defined _LIBG_KNU
            notify("Ready", true).
          else
          {
            print "common: " + (defined _LIBG_COMMON).
            print "knu:    " + (defined _LIBG_KNU).
          }
        }.

.. note::

    Requires:
        * |bodyCacheLib|







.. _orbitsLib example:

Example of using Orbits
-----------------------

    ::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if ship:obt:body:name = "Kerbin" and homeconnection:isconnected and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          // Make sure all scripts are compiled to disk to keep files small.
          if exists(initLocal) runoncepath(initLocal, lexicon("compile", true)).

          if defined _LIBG_COMMON and defined _LIBG_KNU
          {
            local orbitsLib is knuImport("orbits", importLibDir, exportLibDir).

            ...
            knuDelete(orbitsLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |knuLib| replace:: :ref:`KNU <knuLib>`
.. |bodyCacheLib| replace:: :ref:`BodyCache <bodyCacheLib>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/gisikw/ksprogramming/blob/master/library/orbit.ks
__ https://github.com/Dunbaratu/kerboscripts/blob/master/lib/prediction.ks
