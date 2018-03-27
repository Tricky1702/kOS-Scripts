.. _dockingportsLib:

DockingPorts
============

.. contents:: Contents
    :local:
    :depth: 1

The global variable ``_LIBS_DOCKINGPORTS`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_DOCKINGPORTS)
    {
      sysioImport(lexicon("input", "dockingports", "import", importLibDir, "export", exportLibDir)).
      sysioRun(lexicon("input", "dockingports", "directory", exportLibDir)).
    }

    local dockportsLib is sysioGetImport(lexicon("input", "dockingports", "directory", exportLibDir)).
    // Find all ports in the ready state for the ship.
    local allShipReadyPorts is dockportsLib["getReadyPortsFromTarget"](ship).
    ...

.. note::

    |commonLib| and |sysioLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Docking Ports example <dockingportsLib example>`)::

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
            notify("Ready", true).
          else
          {
            print "common: " + (defined _LIBG_COMMON).
            print "knu:    " + (defined _LIBG_SYSIO).
          }
        }.

Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 2 1 4

    * - Method
      - Return Type
      - Description

    * - :func:`getPort`
      - |kOSDockingPort|
      - Searches for the specified docking port by tag name on all vessels.
    * - :func:`getPortFromReadyPorts`
      - |kOSDockingPort|
      - Searches for the specified docking port by tag name on all vessels that are in the ready |kOSDockingPortState|.
    * - :func:`getPortFromTarget`
      - |kOSDockingPort|
      - Searches for the specified docking port by tag name on the specified vessel.
    * - :func:`getPortFromTargetReadyPorts`
      - |kOSDockingPort|
      - Searches for the specified docking port by tag name on the specified vessel that is in the ready |kOSDockingPortState|.
    * - :func:`getReadyPorts`
      - |kOSLexicon|
      - Creates a lexicon of docking ports that are in the ready |kOSDockingPortState| for all vessels.
    * - :func:`getReadyPortsFromTarget`
      - |kOSList|
      - Creates a list of docking ports that are in the ready |kOSDockingPortState| for the specified vessel.
    * - :func:`isDockingPort`
      - |kOSBoolean|
      - Check if a part is a docking port.
    * - :func:`potentialTargets`
      - |kOSList|
      - Creates a list of targets that have docking ports.
    * - :func:`search`
      - |kOSList|
      - A flexible function to find suitable ports for docking.

.. function:: getPort(n)

    :parameter n: |kOSString| - Tag name of a docking port, default: "".
    :return: The first docking port found or 0 (zero) if not found.
    :rtype: |kOSDockingPort|

    Searches for the specified docking port by tag name on all vessels.

.. function:: getPortFromReadyPorts(n)

    :parameter n: |kOSString| - Tag name of a docking port, default: "".
    :return: The first docking port found or 0 (zero) if not found.
    :rtype: |kOSDockingPort|

    Searches for the specified docking port by tag name on all vessels that are in the ready |kOSDockingPortState|.

.. function:: getPortFromTarget(t, n)

    :parameter t: |kOSVessel| - Vessel to search, default: ``ship``.
    :parameter n: |kOSString| - Tag name of a docking port, default: "".
    :return: The first docking port found or 0 (zero) if not found.
    :rtype: |kOSDockingPort|

    Searches for the specified docking port by tag name on the specified vessel.

.. function:: getPortFromTargetReadyPorts(t, n)

    :parameter t: |kOSVessel| - Vessel to search, default: ``ship``.
    :parameter n: |kOSString| - Tag name of a docking port, default: "".
    :return: The first docking port found or 0 (zero) if not found.
    :rtype: |kOSDockingPort|

    Searches for the specified docking port by tag name on the specified vessel that is in the ready |kOSDockingPortState|.

.. function:: getReadyPorts()

    :return: A lexicon of docking ports that are in the ready |kOSDockingPortState|.
    :rtype: |kOSLexicon|

    Creates a lexicon of docking ports that are in the ready |kOSDockingPortState| for all vessels.

    .. note::

        * The key is a |kOSVessel|.
        * The value is a list of |kOSDockingPort| in the ready |kOSDockingPortState| for that vessel.

.. function:: getReadyPortsFromTarget(s)

    :parameter s: |kOSVessel| - Vessel to search, default: ``ship``.
    :return: A list of docking ports that are in the ready |kOSDockingPortState|.
    :rtype: |kOSList|

    Creates a list of docking ports that are in the ready |kOSDockingPortState| for the specified vessel.

.. function:: isDockingPort(p)

    :parameter p: |kOSDockingPort| to check.
    :return: true if the part is a |kOSDockingPort|, otherwise false.
    :rtype: |kOSBoolean|

    Check if a part is a docking port.

.. function:: potentialTargets()

    :return: A list of targets that have docking ports.
    :rtype: |kOSList|

    Creates a list of targets that have docking ports.


.. _dockingportsLib search:
.. function:: search(pl, wpl)

    :parameter pl: |kOSDockingPort| or |kOSList| - A port to check or a list of ports to search, default: ``list()``.
    :parameter wpl: |kOSDockingPort| or |kOSList| - A port or list of ports searched with, default: ``list()``.
    :return: 2 suitable docking ports.
    :rtype: |kOSList|

    A flexible function to find suitable ports for docking.

    You can search on everything if you supply docking port lists to both parameters. On return
    the 1st index in the list will be a port from **pl** and the 2nd index in the list will
    be a port from **wpl**.

    If **pl** is set to a list of docking ports on the active vessel and **wpl** is set
    to the target vessel port then the 1st index in the returned list is a suitable port on the
    active vessel.

    If **pl** is set to a list of docking ports on the target vessel and **wpl** is set
    to the active vessel port then the 1st index in the returned list is a suitable port on the
    target vessel.

    Code used in :ref:`dock <dockingLib dock>` in the docking lib - **The variable and function
    names are in full here. In the actual docking lib they have been minimized.**

    ::

        local dockingportsLib is sysioRequires
        (
          lexicon
          (
            "scriptpath", _LIBS_DOCKING,
            "input", "dockingports",
            "import", importLibDir,
            "export", exportLibDir,
            "volume", exportVol
          )
        ).

        // Find all ports in the ready state
        local allShipReadyPorts is dockingportsLib["getReadyPortsFromTarget"](ship).
        local allTargetReadyPorts is dockingportsLib["getReadyPortsFromTarget"](oVessel).

        if allShipReadyPorts:empty or allTargetReadyPorts:empty
        {
          if allShipReadyPorts:empty
            sysioNotifyWarn("No docking ports are available to be used on this craft").
          if allTargetReadyPorts:empty
            sysioNotifyWarn("No docking ports are available to be used on the target craft").

          return.
        }

        // Cut down on the access times
        local isdp is dockingportsLib["isDockingPort"].
        // Get a port in the ready DockingPort:State if possible
        local sPort is dockingportsLib["getPortFromTargetReadyPorts"](sPortTag, ship).
        local oPort is dockingportsLib["getPortFromTargetReadyPorts"](oPortTag, oVessel).

        // Choose a new set of ports if we can't find the tags or they are the wrong type/size
        if not isdp(sPort) or not isdp(oPort) or sPort:nodetype <> oPort:nodetype
        {
          // Cut down on the access times
          local dpSearch is dockingportsLib["search"].

          // One or both of the ports has been found
          if isdp(sPort) or isdp(oPort)
          {
            // Ship docking tag not found
            if not isdp(sPort) set sPort to dpSearch(allShipReadyPorts, oPort)[0].
            // Target docking tag not found
            else if not isdp(oPort) set oPort to dpSearch(allTargetReadyPorts, sPort)[0].
            // Port type/size don't match
            else
            {
              local port is dpSearch(allTargetReadyPorts, sPort)[0].

              if isdp(port) set oPort to port.
              else set sPort to dpSearch(allShipReadyPorts, oPort)[0].
            }
          }
          // Both docking tags can't be found
          if not isdp(sPort) and not isdp(oPort)
          {
            local ports is dpSearch(allShipReadyPorts, allTargetReadyPorts).
            set sPort to ports[0]. set oPort to ports[1].
          }
        }

        if not isdp(sPort) or not isdp(oPort)
        {
          sysioNotifyWarn("No suitable docking ports are available").

          return.
        }

.. _dockingportsLib example:

Example of using Docking Ports
------------------------------

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
            sysioImport(lexicon("input", "dockingports", "import", importLibDir, "export", exportLibDir)).

            local dockportsLib is sysioRun(lexicon("input", "dockingports", "directory", exportLibDir)).
            local station is vessel("My Space Station").
            local stationPortTag is "Main Station Docking Port".
            local myPortTag is "My Vessel Docking Port".
            local stationPort is dockingportsLib["getPortFromTargetReadyPorts"](stationPortTag, station).
            local myPort is dockingportsLib["getPortFromTargetReadyPorts"](myPortTag, ship).

            if dockportsLib["isDockingPort"](stationPort) and dockportsLib["isDockingPort"](myPort)
              sysioNotify("Both ports are valid", true).

            sysioDelete(dockportsLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |sysioLib| replace:: :ref:`SysIO <sysioLib>`

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSDockingPort| replace:: :ref:`DockingPort <kosdoc:dockingport>`
.. |kOSDockingPortState| replace:: :attr:`State <kosdoc:attr:dockingport:state>`
.. |kOSList| replace:: :ref:`List <kosdoc:list>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`
.. |kOSVessel| replace:: :ref:`Vessel <kosdoc:vessel>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath
