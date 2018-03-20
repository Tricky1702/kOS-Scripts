.. _index:

kOS-Lib
=======

==================================== ===================== ========================= ===========================
:ref:`Full Documentation <contents>` :ref:`init.ks <init>` :ref:`Global libs <libg>` :ref:`Standard libs <libs>`
==================================== ===================== ========================= ===========================

*Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...*
    *"There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..."*

Introduction
------------

A `kOS: Kerbal Operating System`_ library to make programming more modular.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in rutrum libero. Vestibulum rhoncus risus quis nisl mollis convallis. Integer facilisis quam id sapien molestie vestibulum. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus vestibulum a augue porttitor fermentum. Pellentesque euismod in tellus nec vulputate. Nullam tempor urna libero, ornare imperdiet enim congue in. In id vestibulum sapien. Aliquam sagittis mi lorem, in vehicula nisl dignissim at. Aliquam non odio et lacus bibendum egestas vel et quam. Maecenas pellentesque lorem maximus, placerat nunc sed, dapibus tortor. Proin eu sodales mauris, quis auctor dui.

Using
-----

Nam eu augue eget lacus faucibus semper ultricies vel augue. Nulla commodo quis elit sed fermentum. Vivamus in luctus lectus. Nullam venenatis egestas diam sit amet maximus. Nam sit amet egestas odio, ac blandit dui. Fusce sodales efficitur pellentesque. Suspendisse est felis, iaculis sit amet nisl eu, blandit interdum tortor. Morbi neque mi, imperdiet eu diam ut, lobortis mattis nulla. In vel felis sapien. Nunc pretium magna elit, pellentesque ultrices urna volutpat eu. Ut auctor magna lorem, at venenatis tellus porttitor vitae. Ut id ligula tempor, rhoncus tellus vitae, sodales dui. Phasellus vel tincidunt tortor. Nam magna nunc, tristique nec finibus vitae, condimentum sed orci.

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

      if defined _LIBG_COMMON and defined _LIBG_KNU
      {
        knuImport(lexicon("input", "docking", "import", importLibDir, "export", exportLibDir)).

        local dockLib is knuRun(lexicon("input", "docking", "directory", exportLibDir)).
        local station is vessel("My Space Station").
        local stationPort is "Main Docking Port".
        local myDockingPort is "My Docking Port".

        dockLib["dock"](station, stationPort, myDockingPort).
        knuDelete(dockLib).
      }
    }.

Acknowledgements
----------------

I would like to thank `Scott Manley`_ (who else) who made me aware of `kOS: Kerbal Operating System`_
mod for `Kerbal Space Program`_ through one of his excellent YouTube videos. Also I would like to
thank `Kevin Gisi`_ for giving me the inspiration to create this library.

References
----------

* Geoff Banks (ElWanderer) - `kOS scripts and libraries`__
* Kevin Gisi (CheersKevin) - `Kerbal Space Programming`__
* Steven Mading (Dubaratu) - `Kerboscripts`__
* space-is-hard - `Simple utility script for kOS and Kerbal Space Program`__
* Tony Spataro (Xeger) - `Relatively Adequate Mission Planner: a rudimentary, scriptable autopilot for kOS`__

.. _kOS\: Kerbal Operating System: http://ksp-kos.github.io/KOS_DOC/
.. _Kerbal Space Program: https://kerbalspaceprogram.com/
.. _Kevin Gisi: https://github.com/gisikw/ksprogramming
.. _Scott Manley: https://www.youtube.com/user/szyzyg

__ https://github.com/ElWanderer/kOS_scripts
__ https://github.com/gisikw/ksprogramming
__ https://github.com/Dunbaratu/kerboscripts
__ https://github.com/space-is-hard/kOS-Utils
__ https://github.com/xeger/kos-ramp
