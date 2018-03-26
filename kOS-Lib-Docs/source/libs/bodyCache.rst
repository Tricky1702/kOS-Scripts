.. _bodyCacheLib:

BodyCache
=========

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Steven Mading (Dubaratu) - `Kerboscripts`__

The global variable ``_LIBS_BODYCACHE`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_BODYCACHE)
    {
      knuImport(lexicon("input", "bodyCache", "import", importLibDir, "export", exportLibDir)).
      knuRun(lexicon("input", "bodyCache", "directory", exportLibDir)).
    }

    local bodyCacheLib is knuGetImport(lexicon("input", "bodyCache", "directory", exportLibDir)).
    // Do stuff with this lib.
    ...

.. note::

    |commonLib| and |knuLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`BodyCache example <bodyCacheLib example>`)::

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
            knuNotify("Ready", true).
          else
          {
            print "common: " + (defined _LIBG_COMMON).
            print "knu:    " + (defined _LIBG_SYSIO).
          }
        }.

.. note::

    If `ishomeworld`__ was publically advertized on a body::

        local _h is 0. local _bl is list(). list bodies in _bl.
        for b in _bl if b:ishomeworld { set _h to b. break. }






.. _bodyCacheLib example:

Example of using BodyCache
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
            knuImport(lexicon("input", "bodyCache", "import", importLibDir, "export", exportLibDir)).

            local bodyCacheLib is knuRun(lexicon("input", "bodyCache", "directory", exportLibDir)).

            ...
            knuDelete(bodyCacheLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |knuLib| replace:: :ref:`KNU <knuLib>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/Dunbaratu/
__ https://kerbalspaceprogram.com/api/class_celestial_body.html#a0c52d87c84bcf8d88ac158d44d087368
