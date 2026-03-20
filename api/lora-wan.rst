:mod:`lora` --- LoRa WAN API
============================

.. module:: lora
   :noindex:

This page documents the LoRa WAN mode APIs.  Switch to WAN mode with
``lora.mode(lora._mode.WAN)`` before using these functions.

.. seealso:: :doc:`lora` for initialization, :doc:`lora-raw` for RAW mode,
   :doc:`lora-callbacks` for the event system.

API Summary
-----------

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - API Call
     - Description
   * - :func:`lora.stats`
     - Display current LoRa WAN stats
   * - :func:`lora.wan_params`
     - Set regional WAN parameters
   * - :func:`lora.commission`
     - Set commissioning parameters
   * - :func:`lora.join`
     - Start the join procedure
   * - :func:`lora.send`
     - Transmit a LoRa WAN packet
   * - :func:`lora.port_open`
     - Open a LoRa WAN port
   * - :func:`lora.port_close`
     - Close a LoRa WAN port
   * - :func:`lora.callback`
     - Set a user-level callback
   * - :func:`lora.duty_set`
     - Set the duty-cycle timer
   * - :func:`lora.duty_get`
     - Get the current duty-cycle
   * - :func:`lora.duty_start`
     - Start duty-cycle operation
   * - :func:`lora.duty_stop`
     - Stop duty-cycle operation
   * - :func:`lora.enable_rx_listening`
     - Enable RX listening
   * - :func:`lora.disable_rx_listening`
     - Disable RX listening
   * - :func:`lora.tx_airtime`
     - Get last TX time-on-air (ms)
   * - :func:`lora.last_rx_at`
     - Get timestamp of last network reception


Stats
-----

.. function:: lora.stats()

   Display current LoRa WAN settings: region, class, DevEUI, JoinEUI,
   DevAddr, LoRaWAN version, and activation type.

   .. code-block:: python

      >>> lora.stats()
          # - region               : EU-868
          # - class                : class-A
          # - dev eui              : 39 2C 39 D1 5D 3E 12 10
          # - join eui             : EA 68 DE 1C 4B E0 20 F4
          # - dev addr             : 01 88 DB B8
          # - lorawan version      : val: 16778240 ( 1.0.4.0 )
          # - activation           : OTAA


WAN Parameters
--------------

.. function:: lora.wan_params(region=, lwclass=)

   Change the operating region and/or force a device class.

   :param region: One of ``lora._region.REGION_EU868``, ``REGION_US915``, etc.
   :param lwclass: One of ``lora._class.CLASS_A``, ``CLASS_B``, ``CLASS_C``.

   .. code-block:: python

      lora.wan_params(
          region=lora._region.REGION_EU868,
          lwclass=lora._class.CLASS_A
      )


Commissioning
-------------

.. function:: lora.commission(type=, version=, ...)

   Prepare a new LoRa WAN end-device with the given credentials.  If the
   device was previously joined, it will need to rejoin with the new
   parameters.

   **Common parameters:**

   :param type: ``lora._commission.OTAA`` or ``lora._commission.ABP``.
   :param version: ``lora._version.VERSION_1_0_X`` or ``VERSION_1_1_X``.
   :param bytes DevEUI: Device EUI (8 bytes).

   **OTAA additional parameters:**

   :param bytes JoinEUI: Join EUI (8 bytes).
   :param bytes AppKey: Application Key (16 bytes).
   :param bytes NwkKey: Network Key (16 bytes, v1.1.x only).

   **ABP additional parameters:**

   :param int DevAddr: Device network address.
   :param bytes AppSKey: Application session key (16 bytes).
   :param bytes NwkSKey: Network session key (16 bytes).

   **Verification:**

   :param bool verify: If ``True``, check whether the current commissioning
       matches the given parameters without modifying anything.  Returns
       ``True``/``False``.

   .. code-block:: python

      import lora, ubinascii

      # OTAA v1.0.x
      lora.commission(
          type    = lora._commission.OTAA,
          version = lora._version.VERSION_1_0_X,
          DevEUI  = ubinascii.unhexlify('0000000000000000'),
          JoinEUI = ubinascii.unhexlify('0000000000000000'),
          AppKey  = ubinascii.unhexlify('00000000000000000000000000000000')
      )

      # OTAA v1.1.x
      lora.commission(
          type    = lora._commission.OTAA,
          version = lora._version.VERSION_1_1_X,
          DevEUI  = ubinascii.unhexlify('0000000000000000'),
          JoinEUI = ubinascii.unhexlify('0000000000000000'),
          AppKey  = ubinascii.unhexlify('00000000000000000000000000000000'),
          NwkKey  = ubinascii.unhexlify('00000000000000000000000000000000')
      )

      # ABP v1.0.x
      lora.commission(
          type    = lora._commission.ABP,
          version = lora._version.VERSION_1_0_X,
          DevAddr = 0x00000000,
          DevEUI  = ubinascii.unhexlify('0000000000000000'),
          AppSKey = ubinascii.unhexlify('00000000000000000000000000000000'),
          NwkSKey = ubinascii.unhexlify('00000000000000000000000000000000')
      )


Join
----

.. function:: lora.join()

   Start the LoRa WAN join procedure.  For ABP activation the device is
   considered joined after commissioning and this call has no effect.

.. function:: lora.is_joined()

   Return ``True`` if the device has joined the network.

   .. code-block:: python

      import lora, time

      lora.join()
      while not lora.is_joined():
          time.sleep(2)


Sending & Receiving Data
------------------------

.. function:: lora.send(message, [confirm=False, port=1, retries=0, timeout=0, sync=False, id=0])

   Plan an uplink message for transmission.

   :param message: Data buffer (string or bytes).
   :param bool confirm: Request ACK from the network server.
   :param int port: LoRa WAN port (1--223).
   :param int retries: Number of retry attempts.
   :param int timeout: Deadline in milliseconds (0 = no timeout).
   :param bool sync: Block until success/failure/timeout.
   :param int id: User-defined message ID returned in the callback.

   .. code-block:: python

      lora.send('hello')
      lora.send('hello', timeout=20000, retries=2, confirm=True, sync=True)


LoRa Ports
----------

.. function:: lora.port_open(port)

   Open a LoRa WAN port.  Valid application ports are 1--223.
   A port must be opened before sending or receiving data on it.

.. function:: lora.port_close(port)

   Close a previously opened port.

   .. code-block:: python

      lora.port_open(1)
      lora.send('data', port=1)
      lora.port_close(1)


Callbacks
---------

.. function:: lora.callback(handler=, [trigger=, port=])

   Register a callback for LoRa WAN events.

   See :doc:`lora-callbacks` for full documentation and examples.


Duty Cycle
----------

.. function:: lora.duty_set(ms)

   Set the duty-cycle timer in milliseconds.

.. function:: lora.duty_get()

   Return the current duty-cycle timer value.

.. function:: lora.duty_start()

   Start duty-cycle operation.

.. function:: lora.duty_stop()

   Stop duty-cycle operation.

   .. code-block:: python

      lora.duty_set(15000)   # every 15 seconds
      lora.duty_start()


RX Listening
------------

.. function:: lora.enable_rx_listening()

   Enable RX listening.  The device sends a dummy uplink when no pending
   TX exists so the server can schedule a downlink.

.. function:: lora.disable_rx_listening()

   Disable RX listening (default).


Adaptive Data Rate (ADR)
------------------------

ADR allows the network server to optimise data rate and TX power.
It is **enabled by default** when switching to WAN mode.

.. code-block:: python

   lora.mode(lora._mode.WAN, adr=False)   # disable ADR
   lora.mode(lora._mode.WAN, adr=True)    # re-enable


TX Airtime
----------

.. function:: lora.tx_airtime()

   Return the time-on-air in milliseconds of the most recently transmitted
   packet.  Returns ``0`` until the first packet has been sent.

   .. code-block:: python

      lora.send('hello')
      airtime_ms = lora.tx_airtime()
      min_off = airtime_ms * 99       # 1% duty-cycle guard
      time.sleep_ms(min_off)


Last RX Timestamp
-----------------

.. function:: lora.last_rx_at()

   Return the monotonic millisecond timestamp (``utime.ticks_ms()``
   compatible) of the most recent downlink frame.  Returns ``0`` until
   the first downlink has been received.

   Updated on application downlinks, MAC-only downlinks, and uplink ACKs.

   .. code-block:: python

      import utime
      TIMEOUT = 10 * 60 * 1000  # 10 minutes

      last = lora.last_rx_at()
      if last and utime.ticks_diff(utime.ticks_ms(), last) > TIMEOUT:
          print('no network contact — triggering rejoin')
