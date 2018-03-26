.. _dockingLib:

Docking
=======

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Kevin Gisi (CheersKevin) - `docking.ks`__

The global variable ``_LIBS_DOCKING`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_DOCKING)
    {
      knuImport(lexicon("input", "docking", "import", importLibDir, "export", exportLibDir)).
      knuRun(lexicon("input", "docking", "directory", exportLibDir)).
    }

    local dockLib is knuGetImport(lexicon("input", "docking", "directory", exportLibDir)).
    // Find all ports in the ready state for the ship.
    local allShipReadyPorts is dockLib["getReadyPortsFromTarget"](ship).
    ...

.. note::

    |commonLib| and |knuLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Docking example <dockingLib example>`)::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS-Lib/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if homeconnection:isconnected and body:distance < kerbin:soiradius and exists(initMaster)
            compile initMaster to initLocal.

          switch to 1.

          // Make sure all scripts are compiled to disk to keep files small.
          if exists(initLocal) runoncepath(initLocal, lexicon("compile", true)).

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
        * |dockingportsLib|
        * |maneuverLib|


Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 1 3

    * - Method
      - Description

    * - :func:`approachPort`
      - Approaches the specified target docking port at the specified speed to a specified distance.
    * - :func:`approachTargetVector`
      - Approaches the specified target vector at the specified speed to a specified distance.
    * - :func:`dock`
      - Dock with a target port.
    * - :func:`ensureRange`
      - Ensures a range with the target vessel at the specified speed to a specified distance.
    * - :func:`killRelativeVelocity`
      - Performs a maneuver to almost zero the relative velocity between the active vessel and the target vessel.
    * - :func:`sideswipePort`
      - Figures out a safe starting point.

.. function:: approachPort(op, sp, dst, spd)

    :parameter op: |kOSDockingPort| - Port of the target |kOSVessel|.
    :parameter sp: |kOSDockingPort| - Port of the active |kOSVessel|.
    :parameter dst: |kOSScalar| - Approach distance (m).
    :parameter spd: |kOSScalar| - Speed of approach (ms⁻¹).
    :return: None

    Approaches the specified target docking port at the specified speed to a specified distance.

.. function:: approachTargetVector(op, sp, dst, spd, tv, stp)

    :parameter op: |kOSDockingPort| - Port of the target |kOSVessel|.
    :parameter sp: |kOSDockingPort| - Port of the active |kOSVessel|.
    :parameter dst: |kOSScalar| - Approach distance (m).
    :parameter spd: |kOSScalar| - Speed of approach (ms⁻¹).
    :parameter tv: `Vector`_ - Target vector.
    :parameter stp: |kOSDelegate| - Delegate that will end the approach, default ``{ parameter av, tvang, dstmag. return av:mag < 5. }.``
    :return: None

    Approaches along the specified target vector at the specified speed to a specified distance.

.. _dockingLib dock:
.. function:: dock(ov, opt, spt, sStats, sVecs)

    :parameter ov: |kOSVessel| - Target vessel to dock with.
    :parameter opt: |kOSString| - Tag name of the target |kOSVessel| docking port.
    :parameter spt: |kOSString| - Tag name of the active |kOSVessel| docking port.
    :parameter sStats: |kOSBoolean|, default false.
    :parameter sVecs: |kOSBoolean|, default false.
    :return: None

    Dock with a target port.

    .. note::

        If the port tags can not be found or are not in the ready |kOSDockingPortState| or the
        |kOSDockingPortNodeType| does not match then a suitable set of docking ports will be
        chosen.

        If there are still no docking ports available then a warning is given before returning to the
        caller.

        .. seealso:: :ref:`DockingPorts search <dockingportsLib search>`

.. function:: ensureRange(ov, dst, spd)

    :parameter ov: |kOSVessel| - Target vessel.
    :parameter dst: |kOSScalar| - Approach distance (m).
    :parameter spd: |kOSScalar| - Speed of approach (ms⁻¹).
    :return: None

    Ensures a range with the target vessel at the specified speed to a specified distance.

.. function:: killRelativeVelocity(op)

    :parameter op: |kOSVessel| - Vessel to kill relative velocity with.
    :return: None

    Performs a maneuver to almost zero the relative velocity between the active vessel and the target vessel.

.. function:: sideswipePort(op, sp, dst, spd)

    :parameter op: |kOSDockingPort| - Port of the target |kOSVessel|.
    :parameter sp: |kOSDockingPort| - Port of the active |kOSVessel|.
    :parameter dst: |kOSScalar| - Approach distance (m).
    :parameter spd: |kOSScalar| - Speed of approach (ms⁻¹).
    :return: None

    Works out if the target docking port is blocked by the station for docking. If it is then we
    sideswipe to get to the other side. Otherwise, immediately return to approach the docking port.

.. _dockingLib example:

Example of using Docking
------------------------

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
            knuImport(lexicon("input", "docking", "import", importLibDir, "export", exportLibDir)).

            local dockLib is knuRun(lexicon("input", "docking", "directory", exportLibDir)).
            local station is vessel("My Space Station").
            local stationPort is "Main Station Docking Port".
            local myDockingPort is "My Vessel Docking Port".

            dockLib["dock"](station, stationPort, myDockingPort).
            knuDelete(dockLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |dockingportsLib| replace:: :ref:`DockingPorts <dockingportsLib>`
.. |knuLib| replace:: :ref:`KNU <knuLib>`
.. |maneuverLib| replace:: :ref:`Maneuver <maneuverLib>`

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSDelegate| replace:: :ref:`kOSDelegate <kosdoc:kosdelegate>`
.. |kOSDockingPort| replace:: :ref:`DockingPort <kosdoc:dockingport>`
.. |kOSDockingPortNodeType| replace:: :attr:`NodeType <kosdoc:attr:dockingport:nodetype>`
.. |kOSDockingPortState| replace:: :attr:`State <kosdoc:attr:dockingport:state>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`
.. |kOSVessel| replace:: :ref:`Vessel <kosdoc:vessel>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath
.. _Vector: http://ksp-kos.github.io/KOS_DOC/math/vector.html#vectors

__ https://github.com/gisikw/ksprogramming/blob/master/library/docking.ks
