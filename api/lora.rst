LoRa Module
===========

.. py:module:: lora

The ``lora`` module provides the MicroPython interface to the LoRa radio stack,
supporting both LoRa-RAW and LoRa-WAN operating modes.

Initialisation
--------------

Import the module to initialise the LoRa stack and restore the saved operating
mode:

.. code-block:: python

   import lora     # mandatory before any lora function call
                   # automatically initialises for the current operating mode

.. py:function:: lora.deinit()

   De-initialise the LoRa stack.  All subsequent LoRa calls will be ignored.

.. py:function:: lora.initialize()

   Re-initialise the LoRa stack after :py:func:`lora.deinit`.

LoRa Modes
----------

Two operating modes are available: **LoRa-RAW** and **LoRa-WAN**.

.. py:function:: lora.mode([new_mode, adr=None])

   Get or set the current LoRa operating mode.

   :param new_mode: ``lora._mode.RAW`` or ``lora._mode.WAN``.
   :param bool adr: Enable or disable Adaptive Data Rate when switching to WAN mode.
      ADR is **enabled by default**.
   :returns: The current mode when called without arguments.

   .. code-block:: python

      lora.mode()                              # query current mode
      lora.mode(lora._mode.RAW)               # switch to LoRa-RAW
      lora.mode(lora._mode.WAN)               # switch to LoRa-WAN (ADR on)
      lora.mode(lora._mode.WAN, adr=False)    # switch to LoRa-WAN with ADR off
      lora.mode(lora._mode.WAN, adr=True)     # switch to LoRa-WAN with ADR on

   .. note::

      The ``adr`` argument is only meaningful when switching to ``lora._mode.WAN``.
      It has no effect when querying the current mode or switching to ``lora._mode.RAW``.

Mode Constants
~~~~~~~~~~~~~~

.. py:attribute:: lora._mode.RAW

   LoRa-RAW operating mode.

.. py:attribute:: lora._mode.WAN

   LoRa-WAN operating mode.

LoRa Test Stub
--------------

For testing without a user-level callback, the LoRa stack provides an internal
stub:

.. py:function:: lora.callback_stub_connect()

   Connect the internal LoRa stack callback stub.

.. py:function:: lora.callback_stub_disconnect()

   Disconnect the internal stub and allow a user-provided callback.

Sub-module Documentation
------------------------

* :doc:`lora-wan` — LoRa-WAN mode APIs (join, send, receive, duty-cycle, etc.)
* :doc:`lora-raw` — LoRa-RAW mode APIs (radio params, continuous RX, etc.)
* :doc:`lora-callbacks` — LoRa callback/event system
