.. _automaticLib:

Automatic
=========

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * space-is-hard - `boot_kos_utils.ks`__

The global variable ``_LIBS_AUTOMATIC`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_AUTOMATIC)
    {
      sysioImport(lexicon("input", "automatic", "import", importLibDir, "export", exportLibDir)).
      sysioRun(lexicon("input", "automatic", "directory", exportLibDir)).
    }

    local automaticLib is sysioGetImport(lexicon("input", "automatic", "directory", exportLibDir)).
    // Do stuff with this lib.
    ...

.. note::

    |commonLib| and |sysioLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Automatic example <automaticLib example>`)::

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








.. _automaticLib example:

Example of using Automatic
--------------------------

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
            sysioImport(lexicon("input", "automatic", "import", importLibDir, "export", exportLibDir)).

            local automaticLib is sysioRun(lexicon("input", "automatic", "directory", exportLibDir)).

            ...
            sysioDelete(automaticLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |sysioLib| replace:: :ref:`SysIO <sysioLib>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/space-is-hard/kOS-Utils/blob/master/boot_kos_utils.ks
