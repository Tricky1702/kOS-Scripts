.. _init:

init.ks
=======

.. contents:: Contents
    :local:
    :depth: 1

Initialises the system to use the library.

.. function:: init.ks(l)

    :parameter l: |kOSLexicon|, optional input.

    The input is comprised of the following key/value pairs:

        * compile: |kOSBoolean|, compile kOS scripts if true.
        * debug: |kOSString|, sets the debug filename and turns debugging on.
        * keep: |kOSList|, list of local files/directories that won't be deleted.
        * roundtrip: |kOSBoolean|, waits for the communication roundtrip to KSC during imports and compiling to the local drive if true.

.. _init example:

Example of using init.ks
------------------------

::

    @LAZYGLOBAL off.
    {
      // Open the terminal for the user
      core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

      local kLib is "kOS-Lib".
      local initMaster is "0:/" + kLib + "/init.ks". local initLocal is "1:/init.ksm".
      local hc is { if addons:available("RT") return addons:RT:hasKSCConnection(ship). return homeconnection:isconnected. }.

      // Only do this in Kerbin's SOI
      if hc() and kerbin:distance < kerbin:soiradius and exists(initMaster)
        compile initMaster to initLocal.

      // Make sure we are on the local drive
      switch to 1.

      if exists(initLocal) runoncepath(initLocal, lexicon("debug", "0:/debug.log")).

      // Done
      if defined _LIBG_COMMON and defined _LIBG_SYSIO
        sysioNotify("Ready", true).
      else
      {
        print "common: " + (defined _LIBG_COMMON).
        print "sysio:  " + (defined _LIBG_SYSIO).
      }
    }.

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSList| replace:: :ref:`List <kosdoc:list>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`
