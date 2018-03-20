.. _maneuverLib:

Maneuver
========

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Geoff Banks (ElWanderer) - `lib_steer.ks`__
    * Kevin Gisi (CheersKevin) - `maneuver.ks`__
    * Steven Mading (Dunbaratu) - `prediction.ks`__
    * Tony Spataro (Xeger) - `Relatively Adequate Mission Planner: a rudimentary, scriptable autopilot for kOS`__

The global variable ``_LIBS_MANEUVER`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    // Import the library if it isn't available yet.
    if not (defined _LIBS_MANEUVER)
    {
      knuImport(lexicon("input", "maneuver", "import", importLibDir, "export", exportLibDir)).
      knuRun(lexicon("input", "maneuver", "directory", exportLibDir)).
    }

    local maneuverLib is knuGetImport(lexicon("input", "maneuver", "directory", exportLibDir)).
    // Circularize the orbit.
    maneuverLib["circularize"]().
    maneuverLib["execNode"]().
    ...

.. note::

    |commonLib| and |knuLib| need to be loaded for this library to work.

    Simple script to achieve this (expanded :ref:`Maneuver example <maneuverLib example>`)::

        @LAZYGLOBAL off.
        {
          local initMaster is "0:/kOS-Lib/init.ks". local initLocal is "1:/init.ksm".

          // Only do this in Kerbin's SOI
          if homeconnection:isconnected and body:distance < kerbin:soiradius and exists(initMaster)
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
        * |enginesLib|
        * |orbitsLib|
        * |telemetryLib|

Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 25 15 60

    * - Method
      - Return Type
      - Description

    * - :func:`addNode`
      - |kOSNode|
      - Calculate a maneuver to change the orbit and add it to the flight computer.
    * - :func:`addHohmannNodes`
      - |kOSList|
      - Calculate a `Hohmann transfer orbit`_ maneuver and add it to the flight computer.
    * - :func:`addInclinationMatchNode`
      - |kOSNode|
      - Calculate a maneuver to match inclination with an orbit and add it to the flight computer.
    * - :func:`cancel`
      -
      - Kills the relative velocity with respect to another vessel.
    * - :func:`changeOrbit`
      -
      - Changes orbit to a desired altitude.
    * - :func:`circularize`
      - |kOSNode|
      - Circularize an orbit at the next apsis.
    * - :func:`circularizeAtApoapsis`
      - |kOSNode|
      - Circularize an orbit at the apoapsis.
    * - :func:`circularizeAtApsis`
      - |kOSNode|
      - Circularize an orbit at an apsis.
    * - :func:`circularizeAtPeriapsis`
      - |kOSNode|
      - Circularize an orbit at the periapsis.
    * - :func:`execNode`
      -
      - Execute the next set of nodes in the flight computer.
    * - :func:`hohmannTransfer`
      - |kOSList|
      - Calculate a `Hohmann transfer orbit`_.
    * - :func:`lander`
      -
      - Land the active vessel.
    * - :func:`matchInclination`
      -
      - Changes orbit to match inclination with an |kOSOrbitable|.
    * - :func:`steer`
      -
      - Steer towards a `Vector`_ or |kOSDirection|.
    * - :func:`timeForManeuver`
      - |kOSScalar|
      - Calculates the total amount of time needed for a maneuver given a dV magnitude.
    * - :func:`translate`
      -
      - Translate the ship in the direction of a `Vector`_.

.. function:: addNode(dr, burnETA)

    :parameter dr: |kOSScalar| - Desired altitude (m).
    :parameter burnETA: |kOSScalar| - Time before the orbit change burn, default: 300s.
    :returns: A maneuver node.
    :rtype: |kOSNode|

    Calculate a maneuver to change the orbit and add it to the flight computer.

    The burn start time will be pushed forward if half the calculated maneuver time is greater than
    the requested burn eta.

    .. note::

        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

    .. seealso::
        Velocity increment required to circularize an orbit:

        :math:`|\Delta{v}| = \sqrt{\left(\sqrt{\frac{\mu}{r}} - \sqrt{\frac{\mu p}{r}}\right)^2 + \frac{\mu}{p} e^2 \sin^2{f}}`

        where:
            * :math:`p = a \left(1 - e^2\right)`, semi-latus rectum
            * :math:`f = \cos^{-1}{\left(\frac{p - r}{e r}\right)}`, true anomaly

.. function:: addHohmannNodes(dr, burnETA)

    :parameter dr: |kOSScalar| - Desired altitude (m).
    :parameter burnETA: |kOSScalar| - Time before the orbit change burn, default: 300s.
    :returns: A list of 2 maneuver nodes.
    :rtype: |kOSList|

    Calculate a `Hohmann transfer orbit`_ maneuver and add it to the flight computer.

    The burn start time will be pushed forward if half the calculated maneuver time is greater than
    the requested burn eta.

    .. note::

        This assumes an almost circular orbit as it uses the Hohmann transfer method.

        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

.. function:: addInclinationMatchNode(oobt)

    :parameter oobt: |kOSOrbit| - The orbit to match inclination with.
    :returns: A maneuver node.
    :rtype: |kOSNode|

    Calculate a maneuver to match inclination with an orbit and add it to the flight computer.

    The burn start time will be pushed forward to the next orbit if half the calculated maneuver
    time is greater than the requested burn eta.

    .. note::

        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

.. function:: cancel(craft)

    :parameter craft: |kOSVessel| - The target to match orbital velocity with.

    Kills the relative velocity with respect to another vessel.

.. function:: changeOrbit(dr, burnETA, autoStage, elliptical)

    :parameter dr: |kOSScalar| - Desired altitude (m).
    :parameter burnETA: |kOSScalar| - Time before the orbit change burn, default: 300s.
    :parameter autoStage: |kOSBoolean| - Automatically stage if true, default: false.
    :parameter elliptical: |kOSBoolean| - Does not circularize after changing orbit if true, default: false.

    Changes orbit to a desired altitude.

    .. note::

        Will make sure that the initial orbit is circular first.

.. function:: circularize()

    :returns: A maneuver node.
    :rtype: |kOSNode|

    Circularize an orbit at the next apsis.

    The burn start time will be pushed forward to the next orbit if half the calculated maneuver
    time is greater than the next apsis eta.

    .. note::
        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

.. function:: circularizeAtApoapsis()

    :returns: A maneuver node.
    :rtype: |kOSNode|

    Circularize an orbit at the apoapsis.

    The burn start time will be pushed forward to the next orbit if half the calculated maneuver
    time is greater than the apoapsis eta.

    .. note::
        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

.. function:: circularizeAtApsis(apsis, etaapsis)

    :parameter apsis: |kOSScalar| - Apsis altitude, default: ``obt:apoapsis``.
    :parameter etaapsis: |kOSScalar| - ETA to the apsis, default: ``eta:apoapsis``.
    :returns: A maneuver node.
    :rtype: |kOSNode|

    Circularize an orbit at an apsis.

    The burn start time will be pushed forward to the next orbit if half the calculated maneuver
    time is greater than the apsis eta.

    .. note::
        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

    .. seealso::
        Velocity increment required to circularize an orbit:

        :math:`\Delta{v_1} = \sqrt{\mu \left(\frac{2}{r} - \frac{1}{a}\right)}`

        :math:`\Delta{v_2} = \sqrt{\mu \left(\frac{2}{r} - \frac{1}{r}\right)} \to \Delta{v_2} = \sqrt{\frac{\mu}{r}}`

        :math:`\Delta{v} = \Delta{v_2} - \Delta{v_1}`

        where:
            * :math:`r = \text{body:radius} + \text{apsis}`
            * :math:`a = \text{body:radius} + \frac{\text{apoapsis} + \text{periapsis}}{2}`

.. function:: circularizeAtPeriapsis()

    :returns: A maneuver node.
    :rtype: |kOSNode|

    Circularize an orbit at the periapsis.

    The burn start time will be pushed forward to the next orbit if half the calculated maneuver
    time is greater than the next apsis eta.

    .. note::
        If the periapsis is below the SOI body low orbit altitude, the node will not be delayed.

.. function:: execNode(autoStage, endBurnFunc)

    :parameter autoStage: |kOSBoolean| - Automatically stage if true, default: false.
    :parameter endBurnFunc: |kOSDelegate| - Delegate that will end the burn, default: ``{ return false. }``.

    Execute the next set of nodes in the flight computer.

.. function:: hohmannTransfer(dr)

    :parameter dr: |kOSScalar| - Desired altitude (m).
    :returns: A list of 2 maneuver dV's.
    :rtype: |kOSList|

    Calculate a `Hohmann transfer orbit`_.

.. function:: lander(maxVel)

    :parameter maxVel: |kOSScalar| - Maximum velocity at landing.

    Land the active vessel.

.. function:: matchInclination(o, autoStage)

    :parameter o: |kOSString| or |kOSOrbitable| - Name or orbitable.
    :parameter autoStage: |kOSBoolean|, default: false.

    Changes orbit to match inclination with an |kOSOrbitable|.

.. function:: steer(vd, tmOut, aoa, prec)

    :parameter vd: `Vector`_ or |kOSDirection| - Steering direction.
    :parameter tmOut: |kOSScalar| - Maximum time to wait, default: 30s.
    :parameter aoa: |kOSScalar| - Angle of attack, default: 2°.
    :parameter prec: |kOSScalar| - Precision value of the angular velocity match, default: 4 (higher is more precise).

    Steer towards a `Vector`_ or |kOSDirection|.

.. function:: timeForManeuver(dV)

    :parameter dV: |kOSScalar| - Magnitude of the dV maneuver ms⁻¹.
    :returns: Maneuver time (s), -1 if no engines available.
    :rtype: |kOSScalar|

    Calculates the total amount of time needed for a maneuver given a dV magnitude.

.. function:: translate(v1)

    :parameter v1: `Vector`_ - Translate towards.

    Translate the ship in the direction of a `Vector`_.

.. _maneuverLib example:

Example of using Maneuver
-------------------------

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
            knuImport(lexicon("input", "maneuver", "import", importLibDir, "export", exportLibDir)).

            local maneuverLib is knuRun(lexicon("input", "maneuver", "directory", exportLibDir)).

            maneuverLib["circularize"]().
            maneuverLib["execNode"]().
            knuDelete(maneuverLib).
          }
        }.

.. |commonLib| replace:: :ref:`Common <commonLib>`
.. |knuLib| replace:: :ref:`KNU <knuLib>`
.. |bodyCacheLib| replace:: :ref:`BodyCache <bodyCacheLib>`
.. |enginesLib| replace:: :ref:`Engines <enginesLib>`
.. |orbitsLib| replace:: :ref:`Orbits <orbitsLib>`
.. |telemetryLib| replace:: :ref:`Telemetry <telemetryLib>`

.. |kOSBody| replace:: :ref:`Body <kosdoc:body>`
.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSDelegate| replace:: :ref:`kOSDelegate <kosdoc:kosdelegate>`
.. |kOSDirection| replace:: :ref:`Direction <kosdoc:direction>`
.. |kOSList| replace:: :ref:`List <kosdoc:list>`
.. |kOSNode| replace:: :ref:`Node <kosdoc:maneuver node>`
.. |kOSOrbit| replace:: :ref:`Orbit <kosdoc:orbit>`
.. |kOSOrbitable| replace:: :ref:`Orbitable <kosdoc:orbitable>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`
.. |kOSVessel| replace:: :ref:`Vessel <kosdoc:vessel>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath
.. _Vector: http://ksp-kos.github.io/KOS_DOC/math/vector.html#vectors
.. _Hohmann transfer orbit: https://en.wikipedia.org/wiki/Hohmann_transfer_orbit

__ https://github.com/ElWanderer/kOS_scripts/blob/master/scripts/lib_steer.ks
__ https://github.com/gisikw/ksprogramming/blob/master/library/maneuver.ks
__ https://github.com/Dunbaratu/kerboscripts/blob/master/lib/prediction.ks
__ https://github.com/xeger/kos-ramp
