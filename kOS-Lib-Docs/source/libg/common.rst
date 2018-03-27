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
      - 
    * - :func:`checkKeyWithType`
      - 
      - 
    * - :func:`getKeyWithType`
      - 
      - 
    * - :func:`openTerminal`
      - 
      - 
    * - :func:`closeTerminal`
      - 
      - 
    * - :func:`openCoreTerminal`
      - 
      - 
    * - :func:`closeCoreTerminal`
      - 
      - 
    * - :func:`printAtPadL`
      -
      -
    * - :func:`printAtPadR`
      -
      -
    * - :func:`fmtScalar`
      - |kOSString|
      -
    * - :func:`nearlyEquals`
      - |kOSBoolean|
      -
    * - :func:`isnormalized`
      - |kOSBoolean|
      -
    * - :func:`cbrt`
      - |kOSScalar|
      -
    * - :func:`vectormixedproduct`
      - |kOSScalar|
      -
    * - :func:`vmxp`
      - |kOSScalar|
      -
    * - :func:`scalartripleproduct`
      - |kOSScalar|
      -
    * - :func:`strp`
      - |kOSScalar|
      -
    * - :func:`vectortripleproduct`
      - `Vector`_
      -
    * - :func:`vtrp`
      - `Vector`_
      -
    * - :func:`killWarp`
      -
      -
    * - :func:`doWarp`
      -
      -

.. function:: checkKey(l, k)

    :parameter l: |kOSLexicon|
    :parameter k: |kOSString|
    :return: Blah
    :rtype: |kOSBoolean|


.. function:: checkKeyWithType(l, k, t)

    :parameter l: |kOSLexicon|
    :parameter k: |kOSString|
    :parameter t: |kOSString|
    :return: Blah
    :rtype: |kOSBoolean|


.. function:: getKeyWithType(l, k, t, d)

    :parameter l: |kOSLexicon|
    :parameter k: |kOSString|
    :parameter t: |kOSString|
    :parameter d: Any kOS type
    :return: Blah
    :rtype: Any kOS type


.. function:: openTerminal(kpr, w, h)

    :parameter kpr: |kOSProcessor|
    :parameter w: |kOSScalar|, default 0.
    :parameter h: |kOSScalar|, default 0.
    :return: None


.. function:: closeTerminal(kpr)

    :parameter kpr: |kOSProcessor|
    :return: None


.. function:: openCoreTerminal(w, h)

    :parameter w: |kOSScalar|, default 0.
    :parameter h: |kOSScalar|, default 0.
    :return: None


.. function:: closeCoreTerminal()

    :return: None


.. function:: printAtPadL(s, px, py, p)

    :parameter s: |kOSString|
    :parameter px: |kOSScalar|
    :parameter py: |kOSScalar|
    :parameter p: |kOSScalar|
    :return: None


.. function:: printAtPadR(s, px, py, p)

    :parameter s: |kOSString|
    :parameter px: |kOSScalar|
    :parameter py: |kOSScalar|
    :parameter p: |kOSScalar|
    :return: None


.. function:: fmtScalar(s, dp, p)

    :parameter s: |kOSString|
    :parameter dp: |kOSScalar|, default 3.
    :parameter p: |kOSBoolean|, default true.
    :return: A formatted string of the scalar
    :rtype: |kOSString|


.. function:: nearlyEquals(n1, n2, ep)

    :parameter n1: |kOSScalar|
    :parameter n2: |kOSScalar|
    :parameter ep: |kOSScalar|, default :math:`1.0 \times 10^{-6}`.
    :return: Blah
    :rtype: |kOSBoolean|


.. function:: isnormalized(v1)

    :parameter v1: `Vector`_
    :return: true if :math:`\vec{v_1}` is normalised, otherwise false.
    :rtype: |kOSBoolean|


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


.. function:: doWarp(s)

    :parameter s: |kOSScalar|
    :return: None


.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSProcessor| replace:: :ref:`kOSProcessor <kosdoc:kosprocessor>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`

.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath
.. _Vector: http://ksp-kos.github.io/KOS_DOC/math/vector.html#vectors
.. _Scalar triple product: https://en.wikipedia.org/wiki/Triple_product#Scalar_triple_product
.. _Vector triple product: https://en.wikipedia.org/wiki/Triple_product#Vector_triple_product
