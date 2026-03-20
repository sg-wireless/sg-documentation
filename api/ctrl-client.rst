CTRL Client API
===============

.. py:module:: ctrl

The ``ctrl`` module provides the interface for connecting to and exchanging data
with the `CTRL cloud platform <https://app.sgwireless.com/>`_.

Fields
------

.. py:function:: ctrl.send_field(pin_number, value, [timestamp=0, device_token=None])

   Send a field value to CTRL.

   :param int pin_number: The pin/field number in CTRL, can be any integer value.
   :param value: The value to send (int, float, string, etc.).
   :param int timestamp: Optional. Unix timestamp in seconds. If ``0`` (default), the server uses the current time.
   :param str device_token: Optional. Device token for sending data to a different device.

.. py:function:: ctrl.send_field_map(map, [timestamp=0, device_token=None])

   Send multiple field values to CTRL in a single message using a dictionary.

   :param dict map: A dictionary where keys are pin/field numbers and values are the data to send.
   :param int timestamp: Optional. Unix timestamp in seconds. If ``0`` (default), the server uses the current time.
   :param str device_token: Optional. Device token for sending data to a different device.

   .. code-block:: python

      ctrl.send_field_map({1: 25.5, 2: 60.3, 3: "online"})

.. py:function:: ctrl.send_ping_message()

   Send a ping (is-alive) message to CTRL. The platform will answer with a
   ``pong`` message if connected via WiFi or LTE-M.

.. py:function:: ctrl.send_info_message()

   Send an info message to CTRL containing the device type and firmware version.

.. py:function:: ctrl.send_battery_level(battery_level)

   Send the battery level to CTRL.

   :param int battery_level: The battery level value.

   .. code-block:: python

      def battery_level():
          return 3.7
      ctrl.send_battery_level(battery_level())

Configuration
-------------

If CTRL support is active in the current firmware (check
``import ctrl_cfg; ctrl_cfg.ctrl_on_boot()``), it will load automatically.  It
first looks for a file ``ctrl_config.json`` in the file system.

If the file is found and the configuration looks valid, CTRL will try to connect
to the cloud platform based on the configured parameters.  The user can upload a
file ``ctrl_project.json`` onto the local ``/`` to overwrite any of the
parameters from ``ctrl_config.json``.  This allows for project-specific settings
such as forcing SSL to be enabled or disabling automatically starting the CTRL
client on boot.

If no valid configuration is found, CTRL will load with an empty configuration
to allow the ``ctrl.activate()`` command to be executed.

To manually load the CTRL client from your own scripts:

.. code-block:: python

   import ctrl_cfg
   if ctrl_cfg.ctrl_on_boot():
       import os
       import sys

       if 'ctrl_config' not in globals().keys():
           from ctrl_config import CtrlConfig
           from ctrl import Ctrl

           ctrl_config = CtrlConfig().read_config()

       if (not ctrl_config.get('ctrl_autostart', True)) and ctrl_config.get('cfg_msg') is not None:
           print(ctrl_config.get('cfg_msg'))
           print("Not starting CTRL as auto-start is disabled")
       else:
           if 'ctrl' not in globals().keys():
               ctrl = Ctrl(ctrl_config, ctrl_config.get('cfg_msg') is None, True)

.. py:function:: ctrl.read_config([filename='/ctrl_config.json', reconnect=False])

   Load the CTRL configuration file.

   :param str filename: Path to the configuration file. Default: ``/ctrl_config.json``.
   :param bool reconnect: If ``True``, disconnect and re-connect using the new configuration.

.. py:function:: ctrl.get_config([key=None])

   Return the configuration. If *key* is specified, only the value for that key
   is returned.

   :param str key: Optional configuration key to retrieve.

.. py:function:: ctrl.update_config(key, [value=None, permanent=True, silent=False, reconnect=False])

   Update a *key* and *value* in the default configuration file.  This will
   **update** the existing configuration setting to add the new values.

   :param str key: Configuration key.
   :param value: New value.
   :param bool permanent: If ``True``, calls ``ctrl.write_config()``.  If ``False``, the value is only used this session.
   :param bool silent: If ``True``, suppress REPL output.
   :param bool reconnect: If ``True``, calls ``ctrl.reconnect()``.

.. py:function:: ctrl.set_config(key, [value=None, permanent=True, silent=False, reconnect=False])

   Set a *key* and *value* in the default configuration file.  This will
   **overwrite** any existing settings for the specified key.

   :param str key: Configuration key.
   :param value: New value.
   :param bool permanent: If ``True``, calls ``ctrl.write_config()``.  If ``False``, the value is only used this session.
   :param bool silent: If ``True``, suppress REPL output.
   :param bool reconnect: If ``True``, calls ``ctrl.reconnect()``.

.. py:function:: ctrl.write_config([file='/ctrl_config.json', silent=False])

   Write the updated configuration to the default configuration file.

   :param str file: The file name and location.
   :param bool silent: If ``True``, suppress REPL output.

.. py:function:: ctrl.print_config()

   Print the configuration settings to the REPL in a human-readable format.

.. py:function:: ctrl.activate(activation_string)

   Activate CTRL with the configuration string pasted from the CTRL platform
   (under device/provisioning).

   :param str activation_string: The activation configuration string.

Connection
----------

.. py:function:: ctrl.start([autoconnect=True])

   Manually start the CTRL client.

   :param bool autoconnect: If ``False``, the connection will not start immediately.

.. py:function:: ctrl.connect()

   Connect the device to CTRL following the loaded configuration file.  If you
   are using WiFi or LTE-M and it is already available, CTRL will use the
   existing connection.

.. py:function:: ctrl.enable_lte(carrier, apn, [type='IP', cid=1, band=None, bands=None, mode=0, fallback=False])

   Enable connecting via LTE-M to CTRL.

   :param str carrier: Carrier name.
   :param str apn: Access Point Name.
   :param str type: PDP context type (default ``'IP'``).
   :param int cid: Connection ID (default ``1``).
   :param int band: Single frequency band.
   :param list bands: List of frequency bands.
   :param int mode: Operating mode.
   :param bool fallback: If ``True``, add LTE-M as the last option in the network list.

.. py:function:: ctrl.enable_wifi(ssid, [password=None, fallback=False])

   Enable connecting via WiFi to CTRL.

   :param str ssid: WiFi network SSID.
   :param str password: WiFi password.
   :param bool fallback: If ``True``, add WiFi as the last option in the network list.

.. py:function:: ctrl.connect_lte()

   Manually connect to CTRL using LTE and the settings from the configuration file.

.. py:function:: ctrl.connect_wifi([timeout=120])

   Manually connect to CTRL using WiFi and the settings from the configuration file.

   :param int timeout: Timeout in seconds (default ``120``).

.. py:function:: ctrl.connect_lora_otaa([timeout=120])

   Manually connect to CTRL using LoRa OTAA and the settings from the configuration file.

   :param int timeout: Timeout in seconds (default ``120``).

.. py:function:: ctrl.disconnect()

   Disconnect from CTRL gracefully.  Closes the MQTT connection and socket.

.. py:function:: ctrl.reconnect()

   Calls ``ctrl.disconnect()`` followed by ``ctrl.connect()``.

.. py:function:: ctrl.isconnected()

   :returns: ``True`` if connected to CTRL, ``False`` otherwise.

.. py:function:: ctrl.ifconfig()

   :returns: A tuple with IP information when connected over WiFi or LTE-M.

.. py:function:: ctrl.enable_ssl()

   Enable SSL on the CTRL connection.

   .. note::

      SSL might not be supported by your LTE connection.

   .. warning::

      SSL is not currently supported by the CTRL platform.

.. py:function:: ctrl.dump_ca([file='/cert/sgw-ca.pem'])

   Write the CTRL ROOT CA certificate to file.  The certificate must be present
   in the file system for the firmware to load it.

   :param str file: Path to write the certificate.

Miscellaneous
-------------

.. py:function:: ctrl.deepsleep(ms)

   Disconnect the current connection before going to deepsleep.  See
   `machine.deepsleep() <https://docs.micropython.org/en/v1.26.1/library/machine.html#machine.deepsleep>`_
   for more details.

   :param int ms: Sleep duration in milliseconds.

.. py:function:: ctrl.print_cfg_msg()

   Print the configuration status message on the REPL.

.. py:function:: ctrl.message_queue_len()

   :returns: The length of the message queue.

.. py:function:: ctrl.get_network_type()

   :returns: The network type currently in use.

.. py:function:: ctrl.debug(new_level, [update_nvs=True])

   Set the debug level.

   :param int new_level: Debug level (0--65535).
   :param bool update_nvs: If ``True``, preserve the setting after reset.

.. py:function:: ctrl.ztp([new_status=None])

   Get or set the Zero Touch Provisioning status.

   :param bool new_status: ``True`` to enable ZTP on next boot, ``False`` to disable.
   :returns: Current ZTP status when called without a parameter.

Examples
--------

Send data continuously to the CTRL cloud:

.. code-block:: python

   import time
   import math

   while True:
       for i in range(0, 20):
           ctrl.send_field(1, math.sin(i / 10 * math.pi))
           print('sent field {}'.format(i))
           time.sleep(10)

With an explicit timestamp:

.. code-block:: python

   import time
   import math

   while True:
       for i in range(0, 20):
           ctrl.send_field(1, math.sin(i / 10 * math.pi), time.time())
           print('sent signal {}'.format(i))
           time.sleep(10)

Deprecated API
--------------

.. py:function:: ctrl.send_signal(signal_number, value)

   .. deprecated::
      ``send_signal`` has been removed.  Use :py:func:`ctrl.send_field` instead.
