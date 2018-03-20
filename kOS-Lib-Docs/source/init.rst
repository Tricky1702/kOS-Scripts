.. _init:

init.ks
=======

.. contents:: Contents
    :local:
    :depth: 1

Initialises the system to use the library.

.. function:: init(l)

    :parameter l: |kOSLexicon|, optional input.

    The input is comprised of the following key/value pairs:

        * compile: |kOSBoolean|, compile kOS scripts if true.
        * debug: |kOSString|, sets the debug filename and turns debugging on.
        * keep: |kOSList|, list of local files/directories that won't be deleted.
        * roundtrip: |kOSBoolean|, waits for the communication roundtrip to KSC during imports and compiling to the local drive if true.

.. |kOSBoolean| replace:: :ref:`Boolean <kosdoc:bool>`
.. |kOSLexicon| replace:: :ref:`Lexicon <kosdoc:lexicon>`
.. |kOSList| replace:: :ref:`List <kosdoc:list>`
.. |kOSString| replace:: :ref:`String <kosdoc:string>`
