.. _sysioLib:

SysIO
=====

.. contents:: Contents
    :local:
    :depth: 1

References
----------

    * Kevin Gisi (CheersKevin) - `knu.ks`__

The global variable ``_LIBG_SYSIO`` is defined as the `scriptpath`_ when this library is loaded.
This can be used to figure out if the library is available::

    if not (defined _LIBG_SYSIO) and exists("0:/kOS-Lib/libg/sysio.ks")
    {
      copypath("0:/kOS-Lib/libg/sysio.ks", "1:/libg/sysio.ks").
      runoncepath("1:/libg/sysio.ks").
    }

Methods
-------

.. list-table::
    :header-rows: 1
    :widths: 2 1 4

    * - Method
      - Return Type
      - Description

    * - :func:`sysioFixDir`
      - |kOSString|
      -
    * - :func:`sysioFixExt`
      - |kOSString|
      -
    * - :func:`sysioFixPath`
      - |kOSString|
      -
    * - :func:`sysioFixVol`
      - |kOSString|
      -
    * - :func:`sysioNotify`
      -
      - Displays a message on the HUD.
    * - :func:`sysioNotifyDebug`
      -
      - Displays a debug message on the HUD.
    * - :func:`sysioNotifyError`
      -
      - Displays an error message on the HUD.
    * - :func:`sysioNotifyWarn`
      -
      - Displays a warning message on the HUD.
    * - :func:`sysioDebugOff`
      - 
      - 
    * - :func:`sysioDebugOn`
      - 
      - 
    * - :func:`sysioLog`
      - 
      - 
    * - :func:`sysioDLog`
      - 
      - 
    * - :func:`sysioDPrint`
      - 
      - 
    * - :func:`sysioRunmodeName`
      - |kOSString|
      -
    * - :func:`sysioGetRunmode`
      - |kOSScalar|
      -
    * - :func:`sysioSetRunmode`
      - |kOSScalar|
      -
    * - :func:`sysioUseCompile`
      -
      - Compile kOS scripts.
    * - :func:`sysioUseRoundtrip`
      -
      - Waits for the communication roundtrip to KSC during imports and compiling to the local drive.
    * - :func:`sysioCompile`
      -
      - Compiles a kOS script or list of kOS scripts.
    * - :func:`sysioDelete`
      -
      - Deletes a kOS script, list of kOS scripts, or imported lexicon.
    * - :func:`sysioDeleteAll`
      -
      - Deletes all imported kOS scripts.
    * - :func:`sysioExport`
      -
      - Store returned data from imported kOS script.
    * - :func:`sysioGetImport`
      - |kOSLexicon|
      - Get an import or list of imports.
    * - :func:`sysioImport`
      -
      - Imports a kOS script or list of kOS scripts to the local drive.
    * - :func:`sysioRequires`
      - |kOSLexicon|
      - Ensures the required kOS script or list of kOS scripts are imported.
    * - :func:`sysioRun`
      - |kOSLexicon|
      - Runs a kOS script or list of kOS scripts on the local drive.

.. function:: sysioFixDir(d)

    :parameter d: |kOSString|
    :return: Blah
    :rtype: |kOSString|


.. function:: sysioFixExt(n, ksm)

    :parameter n: |kOSString|
    :parameter ksm: |kOSBoolean|, default false.
    :return: Blah
    :rtype: |kOSString|


.. function:: sysioFixPath(vol)

    :parameter p: |kOSString|
    :return: Blah
    :rtype: |kOSString|


.. function:: sysioFixVol(vol)

    :parameter vol: |kOSString|
    :return: Blah
    :rtype: |kOSString|


.. function:: sysioNotify(s, p, col)

    :parameter s: |kOSString| - Message to be displayed.
    :parameter p: |kOSBoolean| - Print the message to the terminal, default false.
    :parameter col: |kOSColor| - Colour of the message on the HUD, default green.
    :return: None

    Displays a message on the HUD. If *p* is true, the message will also be printed to the terminal.


.. function:: sysioNotifyDebug(s)

    :parameter s: |kOSString| - Debug message to be displayed.
    :return: None

    Displays a debug message on the HUD. Also prints the message to the terminal.

    The colour of the message displayed on the HUD will be RGB(0.5, 0.5, 1.0), see `RGB(r,g,b)`_.


.. function:: sysioNotifyError(s)

    :parameter s: |kOSString| - Error message to be displayed.
    :return: None

    Displays an error message on the HUD. Also prints the message to the terminal.

    The colour of the message displayed on the HUD will be red.


.. function:: sysioNotifyWarn(s)

    :parameter s: |kOSString| - Warning message to be displayed.
    :return: None

    Displays a warning message on the HUD. Also prints the message to the terminal.

    The colour of the message displayed on the HUD will be yellow.


.. function:: sysioDebugOff()

    :return: None


.. function:: sysioDebugOn(f)

    :parameter f: |kOSString|, default "".
    :return: None


.. function:: sysioLog(t, f)

    :parameter t: |kOSString|
    :parameter f: |kOSString|
    :return: None


.. function:: sysioDLog(t, f)

    :parameter t: |kOSString|
    :parameter f: |kOSString|
    :return: None


.. function:: sysioDPrint(s, p)

    :parameter s: |kOSString|
    :parameter p: |kOSBoolean|, default false.
    :return: None


.. function:: sysioRunmodeName(f)

    :parameter f: |kOSString|, default "".
    :return: Blah
    :rtype: |kOSString|


.. function:: sysioGetRunmode()

    :return: Blah
    :rtype: The variable type stored in the runmode file.


.. function:: sysioSetRunmode(rm)

    :parameter rm: |kOSBoolean|, |kOSScalar|, or |kOSString|, default 0.
    :return: Blah
    :rtype: The type that was passed in to ``rm``.


.. function:: sysioUseCompile(f)

    :parameter f: |kOSBoolean| - Compile kOS scripts if true.
    :return: None

    Compile kOS scripts.

    Helps if you are low on disk space. Not guaranteed to stop you running out of space.


.. function:: sysioUseRoundtrip(f)

    :parameter f: |kOSBoolean| - Wait for roundtrip if true.
    :return: None

    Waits for the communication roundtrip to KSC during imports and compiling to the local drive.

    This can be used for immersion.


.. function:: sysioCompile(il)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: None

    The input lexicon is comprised of the following:

        * "input", |kOSString| or |kOSList| - kOS script or list of kOS scripts.
        * "import", |kOSString| - Import directory, default "kOS-Lib/libs".
        * "export", |kOSString| - Export directory, default "libs".
        * "volume", |kOSString| - Export volume name/id, default "1:".

    Compiles a kOS script or list of kOS scripts.


.. function:: sysioDelete(il)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: None

    The input lexicon is comprised of the following:

        * "input", |kOSString|, |kOSList|, or |kOSLexicon| - kOS script, list of kOS scripts, or lexicon of imports.
        * "directory", |kOSString| - Directory, default "libs".
        * "volume", |kOSString| - Export volume name/id, default "1:".

    Deletes a kOS script, list of kOS scripts, or lexicon of imports.


.. function:: sysioDeleteAll()

    :return: None

    Deletes all imported kOS scripts.


.. function:: sysioExport(d)

    :parameter d: Any kOS type.
    :return: None

    Store returned data from imported kOS script.


.. function:: sysioGetImport(n, d)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: A lexicon containing the imported data.
    :rtype: |kOSLexicon|

    The input lexicon is comprised of the following:

        * "input", |kOSString| or |kOSList| - kOS script or list of kOS scripts.
        * "directory", |kOSString| - Directory, default "libs".

    Get an import or list of imports.


.. function:: sysioImport(il)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: None

    The input lexicon is comprised of the following:

        * "input", |kOSString| or |kOSList| - kOS script or list of kOS scripts.
        * "import", |kOSString| - Import directory, default "kOS-Lib/libs".
        * "export", |kOSString| - Export directory, default "libs".
        * "volume", |kOSString| - Export volume name/id, default "1:".

    Imports a kOS script or list of kOS scripts to the local drive.


.. function:: sysioRequires(il)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: A lexicon containing the imported data.
    :rtype: |kOSLexicon|

    The input lexicon is comprised of the following:

        * "scriptpath", |kOSString| - Calling local `scriptpath`_.
        * "input", |kOSString| or |kOSList| - kOS script or list of kOS scripts.
        * "import", |kOSString| - Import directory, default "kOS-Lib/libs".
        * "export", |kOSString| - Export directory, default "libs".
        * "volume", |kOSString| - Export volume name/id, default "1:".

    Ensures the required kOS script or list of kOS scripts are imported.


.. function:: sysioRun(il)

    :parameter il: |kOSLexicon|, input lexicon.
    :return: A lexicon containing the imported data.
    :rtype: |kOSLexicon|

    The input lexicon is comprised of the following:

        * "input", |kOSString| or |kOSList| - kOS script or list of kOS scripts.
        * "directory", |kOSString| - Directory, default "libs".
        * "volume", |kOSString| - Export volume name/id, default "1:".

    Runs a kOS script or list of kOS scripts on the local drive.

    The file is left on the drive so that it doesn't need to be re-imported if you have
    to re-run the script due to a problem.

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSColor| replace:: :ref:`Colour <kosdoc:color>`
.. |kOSList| replace:: :ref:`List <kosdoc:list>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSScalar| replace:: :ref:`Scalar <kosdoc:scalar>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`

.. |RemoteTech| replace:: :ref:`RemoteTech <kosdoc:remotetech>`

.. _RGB(r,g,b): http://ksp-kos.github.io/KOS_DOC/structures/misc/colors.html#function:RGB
.. _scriptpath: http://ksp-kos.github.io/KOS_DOC/commands/files.html#scriptpath

__ https://github.com/gisikw/ksprogramming/blob/master/episodes/e045/knu.ks
