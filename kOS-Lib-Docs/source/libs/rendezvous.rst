.. _rendezvousLib:

Rendezvous
==========

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Kevin Gisi (CheersKevin) - `rendezvous.ks`__

The global variable ``_LIBS_RENDEZVOUS`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_RENDEZVOUS) sysioImport("rendezvous", importLibDir, exportLibDir).

    local rendezvousLib is sysioGetImport("rendezvous", exportLibDir).
    // Do stuff with this lib.
    ...

.. note::

    |commonLib| and |sysioLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Rendezvous example <rendezvousLib example>`)::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if ship:obt:body:name = "Kerbin" and homeconnection:isconnected and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          if exists(initLocal) runoncepath(initLocal).

          // Done
          if defined _LIBG_COMMON and defined _LIBG_SYSIO
            notify("Ready", true).
          else
          {
            print "common: " + (defined _LIBG_COMMON).
            print "knu:    " + (defined _LIBG_SYSIO).
          }
        }.

.. note::

    Requires:
        * |orbitsLib|
        * |maneuverLib|







.. _rendezvousLib example:

Example of using Rendezvous
---------------------------

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

          if defined _LIBG_COMMON and defined _LIBG_SYSIO
          {
            local rendezvousLib is sysioImport("rendezvous", importLibDir, exportLibDir).

            ...
            sysioDelete(rendezvousLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |sysioLib| replace:: :ref:`SysIO <sysioLib>`
.. |orbitsLib| replace:: :ref:`Orbits <orbitsLib>`
.. |maneuverLib| replace:: :ref:`Maneuver <maneuverLib>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/gisikw/ksprogramming/blob/master/library/rendezvous.ks
