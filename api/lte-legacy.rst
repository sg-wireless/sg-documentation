:mod:`LTE` --- Legacy LTE Class (Python)
=========================================

.. module:: LTE
   :synopsis: Legacy Python-based LTE modem driver

.. deprecated::
   This module is superseded by the C-based :doc:`lte` module.
   It is retained for backwards compatibility with existing scripts.

.. code-block:: python

   from LTE import LTE
   lte = LTE()

Constructor
-----------

.. class:: LTE([carrier='standard', cid=1, mode=None, baudrate=115200, debug=None])

   Create and configure an LTE object.

   :param str carrier: Carrier name (``'standard'``, ``'att'``, ``'verizon'``,
       ``'docomo'``, ``'kddi'``, ``'telstra'``, ``'tmo'``,
       ``'verizon-no-roaming'``, ``'3gpp-conformance'``).
   :param int cid: Connection ID (Verizon uses 3).
   :param mode: ``LTE.CATM1`` or ``LTE.NBIOT``.
   :param int baudrate: UART speed (default 115200).
   :param bool debug: Enable debug output.


Methods
-------

.. method:: lte.deinit([reset=False])

   Disable the modem completely (minimum power consumption).
   Call before entering deep sleep.

.. method:: lte.attach([apn=None, type='IP', cid=None, band=None, bands=None])

   Enable radio and attach to the network.

   :param str apn: Access Point Name.
   :param str type: ``'IP'`` or ``'IPV4V6'``.
   :param int band: Single band to scan.
   :param list bands: Multiple bands.

.. method:: lte.isattached()

   Return ``True`` if attached to the network.

.. method:: lte.is_attached()

   Alias for :meth:`isattached`.

.. method:: lte.detach()

   Detach from the network and disable radio.

.. method:: lte.connect([cid=None])

   Start a data session.

.. method:: lte.isconnected()

   Return ``True`` if connected with an IP address.

.. method:: lte.is_connected()

   Alias for :meth:`isconnected`.

.. method:: lte.disconnect()

   End the data session.

.. method:: lte.send_at_cmd(cmd, [timeout=-1, wait_ok_error=False, check_error=False])

   Send a raw AT command.

   .. note::

      If a data session is active, you must call :meth:`pause_ppp` /
      :meth:`resume_ppp` around the AT command.

.. method:: lte.reset()

   Hardware-reset the modem (up to 5 seconds).

.. method:: lte.pause_ppp()

   Suspend the PPP session to allow AT commands.

.. method:: lte.resume_ppp()

   Resume the PPP session.

.. method:: lte.mode([new_mode=None])

   Get or set operating mode (``LTE.CATM1`` / ``LTE.NBIOT``).

.. method:: lte.power_on([wait_ok=True])

   Power on the modem.

.. method:: lte.power_off([force=False])

   Power off the modem.

.. method:: lte.check_power()

   Return ``True`` if the modem is powered.

.. method:: lte.check_sim_present()

   Return ``True`` if a SIM card is present.

.. method:: lte.ifconfig()

   Return ``(ip, netmask, gateway, dns)``.

.. method:: lte.imei()

   Return the IMEI string.

.. method:: lte.iccid()

   Return the SIM ICCID string.

.. method:: lte.read_rsp([size=None, timeout=-1, wait_ok_error=False, check_error=False])

   Read unsolicited responses from the modem.

.. method:: lte.print_pretty_response(rsp, [flush=False, prefix=None])

   Pretty-print a modem response.

.. method:: lte.return_pretty_response(resp)

   Return a cleaned-up modem response string.

.. method:: lte.check_ppp()

   Raise an exception if the modem is in active PPP mode.


Constants
---------

- ``LTE.CATM1`` --- CAT-M1 mode
- ``LTE.NBIOT`` --- NB-IoT mode
