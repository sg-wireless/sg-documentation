:mod:`lte` --- LTE Module (C Implementation)
=============================================

.. module:: lte
   :synopsis: LTE modem control (C-based driver)

The ``lte`` module provides MicroPython bindings for LTE modem functionality
using a C implementation built on top of the ESP modem library.  This is the
recommended driver, replacing the legacy Python-based :doc:`lte-legacy` module.

Quick Start
-----------

.. code-block:: python

   import lte

   lte.init(carrier='standard')
   lte.attach(apn='iot.1nce.net')

   import time
   for _ in range(180):
       if lte.isconnected():
           break
       if lte.isattached() and not lte.isconnected():
           lte.connect()
       time.sleep(1)

   print(lte.ifconfig())

   lte.disconnect()
   lte.deinit()


Initialization
--------------

.. function:: lte.init([carrier='standard'])

   Initialize the LTE modem subsystem.  Idempotent --- safe to call multiple
   times.

   The modem handles three possible power states automatically:

   1. **Powered off** --- powers on and initializes from scratch
   2. **Normal AT mode** (crash recovery) --- resumes from existing state
   3. **CMUX mode** (soft reset) --- cleans up and reinitializes

   :param str carrier: Carrier conformance mode.  Options: ``'standard'``
       (default), ``'verizon'``, ``'att'``, ``'docomo'``, ``'kddi'``,
       ``'telstra'``, ``'tmo'``, ``'verizon-no-roaming'``,
       ``'3gpp-conformance'``, or ``None`` (keep current mode).

   .. note::

      Changing the conformance mode triggers a modem reset.  The driver
      handles this automatically.

.. function:: lte.deinit([detach=True, power_off=True])

   Deinitialize the modem.

   :param bool detach: Detach from cellular network.
   :param bool power_off: Power off the modem hardware.

   **Use cases:**

   - ``lte.deinit()`` --- full shutdown (default)
   - ``lte.deinit(power_off=False)`` --- quick restart
   - ``lte.deinit(detach=False, power_off=False)`` --- low power with PSM/eDRX

.. function:: lte.reset()

   Hardware reset the modem (``AT^RESET``).  Takes up to 10 seconds.


Network Attachment
------------------

.. function:: lte.attach([apn=None, type='IP', cid=None, band=None, bands=None])

   Enable radio and attach to the cellular network.  **Non-blocking** ---
   poll with :func:`isattached`.

   :param str apn: Access Point Name (e.g. ``'iot.1nce.net'``).
   :param str type: PDP context type: ``'IP'``, ``'IPV6'``, or ``'IPV4V6'``.
   :param int cid: Context identifier (default 1; Verizon uses 3).
   :param int band: Single frequency band (0 = auto).
   :param list bands: List of bands (e.g. ``[2, 4, 12]``).

.. function:: lte.isattached()

   Return ``True`` if registered on the network (home or roaming).

.. function:: lte.is_attached()

   Alias for :func:`isattached`.

.. function:: lte.detach()

   Detach from the cellular network and disable radio.


Data Session
------------

.. function:: lte.connect([cid=None])

   Start a data session using CMUX + PPP.  **Non-blocking** --- poll with
   :func:`isconnected`.

.. function:: lte.isconnected()

   Return ``True`` if PPP is active and an IP address has been obtained.

.. function:: lte.is_connected()

   Alias for :func:`isconnected`.

.. function:: lte.disconnect()

   End the data session (keeps network attachment).

.. function:: lte.ifconfig()

   Return ``(ip, netmask, gateway, dns)`` or ``None`` if not connected.


AT Commands
-----------

.. function:: lte.send_at_cmd(cmd='AT', [timeout=-1, wait_ok_error=False, check_error=False, buffer_size=4096])

   Send a raw AT command and return the response.

   :param str cmd: AT command (without ``\r\n``).
   :param int timeout: Timeout in ms (``-1`` = default 5000 ms).
   :param bool wait_ok_error: Wait for OK/ERROR response.
   :param bool check_error: Raise exception on ERROR.
   :param int buffer_size: Response buffer (1024--32768).

   .. important:: CMUX allows simultaneous AT commands and data sessions.

   .. code-block:: python

      lte.send_at_cmd('AT+CEREG?')
      lte.send_at_cmd('AT+CSQ')


Mode & Identity
---------------

.. function:: lte.mode([new_mode=None])

   Get or set the operating mode.

   :param new_mode: ``lte.CATM1`` (0) or ``lte.NBIOT`` (1).

   .. note:: Setting a new mode causes a modem reset.

.. function:: lte.imei()

   Return the 15-digit IMEI string.

.. function:: lte.iccid()

   Return the SIM card ICCID string.

   :raises OSError: If SIM card is not present or not ready.


Status & Signal
---------------

.. function:: lte.get_signal_strength()

   Return ``(rssi, rssi_dbm, ber)``.

   - *rssi*: Raw value (0--31, 99=unknown)
   - *rssi_dbm*: dBm (-113 to -51, -999=unknown)
   - *ber*: Bit Error Rate (0--7, 99=unknown)

.. function:: lte.get_status()

   Return a dict with comprehensive modem status:

   .. code-block:: python

      {
          'powered': True,
          'sim_ready': True,
          'network_attached': True,
          'ppp_connected': True,
          'cmux_active': True,
          'baudrate': 921600,
          'rssi': 20,
          'ber': 99
      }


Power Management
----------------

.. function:: lte.power_on([wait_ok=True])

   Power on the modem hardware.

.. function:: lte.power_off([force=False])

   Power off the modem.  *force=True* skips graceful shutdown.

.. function:: lte.is_powered()

   Return ``True`` if the modem is powered.

.. function:: lte.check_sim_present()

   Return ``True`` if a SIM card is present and ready.


Event Handler
-------------

.. function:: lte.set_event_handler(handler, [event_mask=EVENT_ALL, lock=False])

   Register a callback for LTE modem events.

   :param handler: Event handler function or ``None`` to unregister.
   :param int event_mask: Bitmask of events to subscribe to.
   :param bool lock: Lock the handler to prevent overrides until
       ``lte.deinit()``.

   **Event types:**

   .. list-table::
      :header-rows: 1
      :widths: 35 65

      * - Constant
        - Description
      * - ``lte.EVENT_REGISTRATION_STATUS``
        - Network registration changes
      * - ``lte.EVENT_PPP_CONNECTED``
        - PPP connection established
      * - ``lte.EVENT_PPP_DISCONNECTED``
        - PPP connection lost
      * - ``lte.EVENT_MODEM_CRASH``
        - Modem crash detected
      * - ``lte.EVENT_MODEM_RESET``
        - Modem was reset
      * - ``lte.EVENT_SIGNAL_QUALITY``
        - Signal strength update
      * - ``lte.EVENT_URC``
        - Raw unsolicited response
      * - ``lte.EVENT_ERROR``
        - Error occurred
      * - ``lte.EVENT_ALL``
        - Subscribe to all events

   **Example:**

   .. code-block:: python

      def lte_handler(event):
          if event['type'] == lte.EVENT_REGISTRATION_STATUS:
              if event['stat'] == 1:
                  print('Registered (home)')
          elif event['type'] == lte.EVENT_PPP_CONNECTED:
              print('IP:', event['ip'])

      lte.set_event_handler(lte_handler, lte.EVENT_ALL)


Constants
---------

- ``lte.CATM1`` (0) --- CAT-M1 mode
- ``lte.NBIOT`` (1) --- NB-IoT mode
- ``lte.EVENT_REGISTRATION_STATUS`` (0x0001)
- ``lte.EVENT_PPP_CONNECTED`` (0x0002)
- ``lte.EVENT_PPP_DISCONNECTED`` (0x0004)
- ``lte.EVENT_MODEM_CRASH`` (0x0008)
- ``lte.EVENT_MODEM_RESET`` (0x0010)
- ``lte.EVENT_SIGNAL_QUALITY`` (0x0020)
- ``lte.EVENT_URC`` (0x0040)
- ``lte.EVENT_ERROR`` (0x0080)
- ``lte.EVENT_ALL`` (0xFFFF)
