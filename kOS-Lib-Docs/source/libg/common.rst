.. _commonLib:

Common
======

.. contents:: Contents
    :local:
    :depth: 1

The global variable ``_LIBG_COMMON`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    if not (defined _LIBG_COMMON) and exists("0:/kOS-Lib/libg/common.ks")
    {
      copypath("0:/kOS-Lib/libg/common.ks", "1:/libg/common.ks").
      runoncepath("1:/libg/common.ks").
    }

Variables
---------

.. list-table::
    :header-rows: 1
    :widths: 1 4

    * - Identifier
      - Description

    * - :global:`importLibDir`
      - Default directory for libs on the archive.
    * - :global:`importVol`
      - Default volume name/id for the imported libs.
    * - :global:`exportLibDir`
      - Default directory for libs on the local drive.
    * - :global:`exportVol`
      - Default volume name/id for the exported libs.
    * - :global:`g0`
      - Standard value of **g**, :math:`9.80665 ms^{-2}`, at Kerbin sea level.
    * - :global:`vecorigin`
      - Vector origin.
    * - :global:`bignum`
      - A big number.
    * - :global:`smallnum`
      - A small number.
    * - :global:`onethird`
      - :math:`\frac{1}{3}`
    * - :global:`twoPi`
      - :math:`2 \pi`
    * - :global:`halfPi`
      - :math:`\frac{\pi}{2}`

.. global:: importLibDir

    Default directory for libs on the archive, *kOS-Lib/libs*.

.. global:: importVol

    Default volume name/id for the imported libs, will be set to the archive volume name/id.

.. global:: exportLibDir

    Default directory for libs on the local drive, *libs*.

.. global:: exportVol

    Default volume name/id for the exported libs, will be set to the volume name/id this script is run on.

.. global:: g0

    Standard value of **g**, :math:`9.80665 ms^{-2}`, at Kerbin sea level. Used in engine ISP calculations.

.. global:: vecorigin

    Vector origin, :math:`\vec{v} = \left(0, 0, 0\right)`

.. global:: bignum

    A big number, :math:`1.0 \times 10^{35}`

.. global:: smallnum

    A small number, :math:`1.0 \times 10^{-35}`

.. global:: onethird

    One third, :math:`\frac{1}{3}`

    .. note::

        :math:`x^{\frac{1}{3}} \equiv \sqrt[3]{x}`

.. global:: twoPi

    Twice the ratio of circumference of a circle to its diameter, :math:`6.28318530...`

.. global:: halfPi

    Half the ratio of circumference of a circle to its diameter, :math:`1.57079632...`

Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 2 1 4

    * - Method
      - Return Type
      - Description

    * - :func:`checkKey`
      - 
      - Checks if a lexicon has the requested key.
    * - :func:`checkKeyWithType`
      - 
      - Checks if a lexicon has the requested key and the value is the requested type.
    * - :func:`getKeyWithType`
      - 
      - Gets a value from a lexicon pointed to by a key if it matches the requested type.
    * - :func:`openTerminal`
      - 
      - Open the terminal on the provided |kOSProcessor|.
    * - :func:`closeTerminal`
      - 
      - Close the terminal on the provided |kOSProcessor|.
    * - :func:`openCoreTerminal`
      - 
      - Open the terminal on the core |kOSProcessor|.
    * - :func:`closeCoreTerminal`
      - 
      - Close the terminal on the core |kOSProcessor|.
    * - :func:`printAtPadL`
      - 
      - Print text to terminal at a specified x, y position. Right-align the string padded to the given width by spaces.
    * - :func:`printAtPadR`
      - 
      - Print text to terminal at a specified x, y position. Left-align the string padded to the given width by spaces.
    * - :func:`fmtScalar`
      - |kOSString|
      - Return a formatted string of the scalar rounded to the required decimal place.
    * - :func:`fmtScalarA`
      - |kOSString|
      - Return a formatted string of the scalar rounded to the required decimal place with a string appended to the end.
    * - :func:`nearlyEquals`
      - |kOSBoolean|
      - Checks if two numbers are nearly equal to each other within a specified margin.
    * - :func:`isnormalized`
      - |kOSBoolean|
      - Checks if a vector is normalised.
    * - :func:`isnormalised`
      - |kOSBoolean|
      - Alias of :func:`isnormalized`
    * - :func:`cbrt`
      - |kOSScalar|
      - Cube root
    * - :func:`vectormixedproduct`
      - |kOSScalar|
      - `Scalar triple product`_
    * - :func:`vmxp`
      - |kOSScalar|
      - Alias of :func:`vectormixedproduct`
    * - :func:`scalartripleproduct`
      - |kOSScalar|
      - Alias of :func:`vectormixedproduct`
    * - :func:`strp`
      - |kOSScalar|
      - Alias of :func:`vectormixedproduct`
    * - :func:`vectortripleproduct`
      - `Vector`_
      - `Vector triple product`_
    * - :func:`vtrp`
      - `Vector`_
      - Alias of :func:`vectortripleproduct`
    * - :func:`killWarp`
      - 
      - Cancels any active warp and returns when the warp has settled to a stop and the active vessel has fully unpacked.
    * - :func:`doWarp`
      - 
      - Warp to a specified universal time stamp.

.. function:: checkKey(l, k)

    :parameter l: |kOSLexicon|
    :parameter k: Any kOS type.
    :return: true if the lexicon has the requested key, false otherwise.
    :rtype: |kOSBoolean|

    Checks if a lexicon has a requested key.

.. function:: checkKeyWithType(l, k, t)

    :parameter l: |kOSLexicon|
    :parameter k: Any kOS type.
    :parameter t: |kOSString|
    :return: true if the lexicon has the requested key with the requested type, false otherwise.
    :rtype: |kOSBoolean|

    Checks if a lexicon has a requested key and the value is the requested type.

.. function:: getKeyWithType(l, k, t, d)

    :parameter l: |kOSLexicon|
    :parameter k: Any kOS type.
    :parameter t: |kOSString|
    :parameter d: Any kOS type.
    :return: Value from the lexicon pointed to by the requested key if it matches the requested type, return **d** otherwise.
    :rtype: Any kOS type.

    Gets a value from a lexicon pointed to by the requested key if it matches the requested type,
    otherwise return the default provided value **d**.

.. function:: openTerminal(kpr, wid, hgt)

    :parameter kpr: |kOSProcessor|
    :parameter wid: |kOSScalar|, default 0.
    :parameter hgt: |kOSScalar|, default 0.
    :return: None

    Open the terminal on the provided |kOSProcessor|. Resize the window if width and height are provided.

.. function:: closeTerminal(kpr)

    :parameter kpr: |kOSProcessor|
    :return: None

    Close the terminal on the provided |kOSProcessor|.

.. function:: openCoreTerminal(wid, hgt)

    :parameter wid: |kOSScalar|, default 0.
    :parameter hgt: |kOSScalar|, default 0.
    :return: None

    Open the terminal on the core |kOSProcessor|. Resize the window if width and height are provided.

.. function:: closeCoreTerminal()

    :return: None

    Close the terminal on the core |kOSProcessor|.

.. function:: printAtPadL(t, px, py, pad)

    :parameter t: |kOSString|
    :parameter px: |kOSScalar|
    :parameter py: |kOSScalar|
    :parameter pad: |kOSScalar|
    :return: None

    Print text to terminal at a specified x, y position. Right-align the string padded to the given width by spaces.

.. function:: printAtPadR(t, px, py, pad)

    :parameter t: |kOSString|
    :parameter px: |kOSScalar|
    :parameter py: |kOSScalar|
    :parameter pad: |kOSScalar|
    :return: None

    Print text to terminal at a specified x, y position. Left-align the string padded to the given width by spaces.

.. function:: fmtScalar(n, dp)

    :parameter n: |kOSString| or |kOSScalar|
    :parameter dp: |kOSScalar|, default 3.
    :return: A formatted string of the scalar.
    :rtype: |kOSString|

    Return a formatted string of the scalar rounded to the required decimal place.

.. function:: fmtScalarA(n, ap, dp)

    :parameter n: |kOSString| or |kOSScalar|
    :parameter ap: |kOSString|, default "".
    :parameter dp: |kOSScalar|, default 3.
    :return: A formatted string of the scalar appended with a string.
    :rtype: |kOSString|

    Return a formatted string of the scalar rounded to the required decimal place with a string appended to the end.

.. function:: nearlyEquals(n1, n2, ep)

    :parameter n1: |kOSScalar|
    :parameter n2: |kOSScalar|
    :parameter ep: |kOSScalar|, default :math:`1.0 \times 10^{-6}`
    :return: true if :math:`n_1` nearly equals :math:`n_2`, false otherwise.
    :rtype: |kOSBoolean|

    Checks if two numbers are nearly equal to each other within a specified margin.

.. function:: isnormalized(v1)

    :parameter v1: `Vector`_
    :return: true if :math:`\vec{v_1}` is normalised, false otherwise.
    :rtype: |kOSBoolean|

    Checks if a vector is normalised.

.. function:: isnormalised(v1)

    :parameter v1: `Vector`_
    :return: true if :math:`\vec{v_1}` is normalised, false otherwise.
    :rtype: |kOSBoolean|

    Alias of :func:`isnormalized`

.. function:: cbrt(n)

    :parameter n: |kOSScalar|
    :return: :math:`\sqrt[3]{n}`
    :rtype: |kOSScalar|

    Cube root of **n**.

.. function:: vectormixedproduct(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \cdot \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: |kOSScalar|

    `Scalar triple product`_ of the 3 input vectors.

.. function:: vmxp(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \cdot \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: |kOSScalar|

    Alias of :func:`vectormixedproduct`

.. function:: scalartripleproduct(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \cdot \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: |kOSScalar|

    Alias of :func:`vectormixedproduct`

.. function:: strp(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \cdot \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: |kOSScalar|

    Alias of :func:`vectormixedproduct`

.. function:: vectortripleproduct(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \times \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: `Vector`_

    `Vector triple product`_ of the 3 input vectors.

.. function:: vtrp(v1, v2, v3)

    :parameter v1: `Vector`_
    :parameter v2: `Vector`_
    :parameter v3: `Vector`_
    :return: :math:`\vec{v_1} \times \left(\vec{v_2} \times \vec{v_3}\right)`
    :rtype: `Vector`_

    Alias of :func:`vectortripleproduct`

.. function:: killWarp()

    :return: None

    Cancels any active warp and returns when the warp has `settled`__ to a stop and the active vessel has fully `unpacked`__.

.. function:: doWarp(tm)

    :parameter tm: |kOSScalar|
    :return: None

    `Warp`__ to a specified universal time stamp.

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSProcessor| replace:: :ref:`kOSProcessor <kosdoc:kosprocessor>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath
.. _Vector: http://ksp-kos.github.io/KOS_DOC/math/vector.html#vectors
.. _Scalar triple product: https://en.wikipedia.org/wiki/Triple_product#Scalar_triple_product
.. _Vector triple product: https://en.wikipedia.org/wiki/Triple_product#Vector_triple_product

__ http://ksp-kos.github.io/KOS_DOC/structures/misc/timewarp.html#attribute:TIMEWARP:ISSETTLED
__ http://ksp-kos.github.io/KOS_DOC/structures/vessels/vessel.html#attribute:VESSEL:UNPACKED
__ http://ksp-kos.github.io/KOS_DOC/structures/misc/timewarp.html#method:TIMEWARP:WARPTO
