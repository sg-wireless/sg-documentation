CTRL API Documentation
======================

In normal firmware builds, the CTRL module is imported and started
automatically during boot. In most user scripts you can call the CTRL API
directly without adding an ``import ctrl`` line first.

If you want to disable that automatic startup, set
``ctrl_cfg.ctrl_on_boot(False)`` before the next boot/reset.

Contents
--------

- Sending Fields
- Configuration
- Connection
- Callbacks and Events
- Servers
- Security
- Miscellaneous
- Examples
- Logging & Debugging

Fields
------

.. _ctrlsend_fieldpin-value-ts0:

ctrl.send_field(pin, value, [ts=0])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Send a field value to CTRL. Arguments are:

- ``pin``: The pin/field number in CTRL. Can be any integer value.
- ``value``: The value to send. Supported types are ``int``, ``float``, and
  ``str``.
- ``ts``: Optional. Unix timestamp in seconds. If omitted or set to ``0``, the
  server will use the current time — *unless* the message ends up buffered in
  the offline send-queue (see ``ctrl.message_queue()``), in which case the
  device's own clock time at the moment of the call is used instead, so a
  reading taken while offline keeps its real timestamp rather than being
  stamped with whenever it's finally sent. This substitution only happens when
  the device's clock is actually set (e.g. after NTP sync); otherwise it falls
  back to the original "let the server decide" behavior.

.. _ctrlsend_field_mapmap-timestamp0:

ctrl.send_field_map(map, [timestamp=0])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Send multiple field values to CTRL in a single message.

Arguments are:

- ``map``: Either a list/tuple of ``[pin, value]`` pairs or a dict of
  ``{pin: value}`` entries.
- ``timestamp``: Optional. Unix timestamp in seconds. Same offline-queue
  timestamp behavior as ``ctrl.send_field()`` above.

.. _ctrlsend_ping:

ctrl.send_ping()
~~~~~~~~~~~~~~~~

Send a ping (is-alive) message to CTRL. The platform will answer with a
``pong`` message.

.. _ctrlsend_info_messageversion0:

ctrl.send_info_message([version=0])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Send an info message to CTRL containing the device firmware version and
connection state information.

--------------

Configuration
-------------

The new CTRL binding stores its configuration through the active configuration
backend. The default backend is NVS, and an optional file-based backend can
also be used.

The following helpers are available:

.. _ctrlinittoken--ssl_verifynone-silent_failfalse-backgroundnone:

ctrl.init([token], \*, ssl_verify=None, silent_fail=False, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Initialize the CTRL client.

Arguments:

- ``token``: Optional activation token. If supplied, the token is parsed,
  stored, and used for the initial connection.
- ``ssl_verify``: Optional. Explicitly override SSL certificate verification
  for this call.
- ``silent_fail``: Optional. If ``True``, initialization returns silently when
  no stored configuration is present.
- ``background``: Optional. If ``True``, the connection runs in a background
  task and ``ctrl.init()`` returns immediately. If omitted, uses the
  ``ctrl.async_mode()`` persistent default. If another connect/reload/reconnect
  operation (including the SDK's own automatic reconnect) is already in
  progress, raises ``OSError`` immediately instead of starting a second one.

.. _ctrlactivatetoken:

ctrl.activate(token)
~~~~~~~~~~~~~~~~~~~~

Re-provision the device from a new activation token. The new token is merged
with the existing stored configuration and the client reconnects.

.. _ctrlinitialized:

ctrl.initialized()
~~~~~~~~~~~~~~~~~~

Returns ``True`` when the CTRL client has been initialized and connected
successfully.

.. _ctrlread_configfilectrl_configjson-reconnectfalse:

ctrl.read_config([file='/ctrl_config.json', reconnect=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Read a config JSON file from the file system, validate it, save it to the
active configuration backend, and optionally reconnect.

.. _ctrlget_configkeynone:

ctrl.get_config([key=None])
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Return the loaded configuration as a dict. If ``key`` is given, return only
that entry.

.. _ctrlupdate_configkey-valuenone-permanenttrue-silentfalse-reconnectfalse:

ctrl.update_config(key, [value=None, permanent=True, silent=False, reconnect=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Update an existing configuration entry.

Additional options:

- ``permanent``: If ``True``, persist the new value to the active configuration
  backend.
- ``silent``: Suppress console output when saving.
- ``reconnect``: Trigger a reconnect after updating the configuration.

.. _ctrlset_configkeynone-valuenone-permanenttrue-silentfalse-reconnectfalse:

ctrl.set_config([key=None, value=None, permanent=True, silent=False, reconnect=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set a configuration entry or replace the entire configuration dict.

.. _ctrlwrite_configfilectrl_configjson-silentfalse:

ctrl.write_config([file='/ctrl_config.json', silent=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Write the active configuration to a file path.

.. _ctrlprint_config:

ctrl.print_config()
~~~~~~~~~~~~~~~~~~~

Print the current configuration to the REPL.

.. _ctrlcfg_storemode:

ctrl.cfg_store([mode])
~~~~~~~~~~~~~~~~~~~~~~

Select the configuration backend.

- ``0``: use NVS
- ``1``: use the file-backed ``ctrl_config.json`` path

.. _ctrlasync_modeenabled:

ctrl.async_mode([enabled])
~~~~~~~~~~~~~~~~~~~~~~~~~~

Get or set the persistent default for background (asynchronous) connect/reload
behavior. When enabled, ``ctrl.init()``, ``ctrl.connect()``, ``ctrl.reload()``,
and the four ``ctrl.connect_<transport>()`` functions all run in a background
task by default, returning immediately — unless overridden per-call with that
function's own ``background=`` argument.

.. _ctrlssl_verifyenabled:

ctrl.ssl_verify([enabled])
~~~~~~~~~~~~~~~~~~~~~~~~~~

Get or set SSL verification behavior. When disabled, certificate verification
is skipped for development use.

--------------

Connection
----------

Every function below takes an optional keyword-only ``background`` argument:
``background=None`` (default) uses the ``ctrl.async_mode()`` persistent
setting; ``background=True``/``False`` overrides it for that call only. When
backgrounded, the function returns immediately and the connection attempt runs
in a background task — watch ``ctrl.isconnected()`` or a ``CB_CTRL`` callback
for completion. Regardless of ``background``, if another
connect/reload/reconnect operation (including the SDK's own automatic
reconnect) is already in progress, these functions raise ``OSError``
immediately rather than queueing or silently doing nothing.

.. _ctrlconnect-backgroundnone:

ctrl.connect(\*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reconnect the device to CTRL using the configuration already loaded by
``ctrl.init()``.

.. _ctrlconnect_wifitimeout120--backgroundnone:

ctrl.connect_wifi([timeout=120], \*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Force a connection over WiFi using the configured credentials. The ``timeout``
option is in seconds.

.. _ctrlconnect_ltetimeout0--backgroundnone:

ctrl.connect_lte([timeout=0], \*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Force a connection over LTE. The ``timeout`` option is in seconds. A value of
``0`` uses the default timeout.

.. _ctrlconnect_lora_otaatimeout240--backgroundnone:

ctrl.connect_lora_otaa([timeout=240], \*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Force a connection over LoRa OTAA. The ``timeout`` option is in seconds.

.. _ctrlconnect_lora_abptimeout240--backgroundnone:

ctrl.connect_lora_abp([timeout=240], \*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Force a connection over LoRa ABP. The ``timeout`` option is in seconds.

.. _ctrlreload-backgroundnone:

ctrl.reload(\*, background=None)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reload the active configuration, disconnect, and reconnect.

.. _ctrldisconnect:

ctrl.disconnect()
~~~~~~~~~~~~~~~~~

Disconnect from CTRL gracefully while keeping the loaded configuration
available for a later reconnect.

.. _ctrldeinit:

ctrl.deinit()
~~~~~~~~~~~~~

Fully tear down the client. This clears the active initialization state and
requires a new ``ctrl.init()`` call.

.. _ctrlsafe_mode:

ctrl.safe_mode()
~~~~~~~~~~~~~~~~

Enter safe mode by stopping the client, disconnecting the network, and leaving
the module initialized state cleared.

.. _ctrlisconnected:

ctrl.isconnected()
~~~~~~~~~~~~~~~~~~

Return the current connection state as ``True`` or ``False``.

.. _ctrlifconfig:

ctrl.ifconfig()
~~~~~~~~~~~~~~~

Return a tuple with IP information for the active network interface as
``(ip, netmask, gateway, dns)``. Returns ``None`` when no IP interface is
available.

.. _ctrlget_network_type:

ctrl.get_network_type()
~~~~~~~~~~~~~~~~~~~~~~~

Return the active network type as an integer:

- ``ctrl.NET_WIFI`` = ``0``
- ``ctrl.NET_LTE`` = ``1``
- ``ctrl.NET_LORA`` = ``2``
- ``ctrl.NET_SIGFOX`` = ``3``

--------------

Callbacks and Events
--------------------

.. _ctrlcallbacktype-fn:

ctrl.callback(type, fn)
~~~~~~~~~~~~~~~~~~~~~~~

Register a Python callback for a message category. The supported callback types
are:

- ``ctrl.CB_USER`` (0)
- ``ctrl.CB_FCOTA`` (1)
- ``ctrl.CB_CAPT`` (2)
- ``ctrl.CB_ZTP`` (3)
- ``ctrl.CB_CTRL`` (4)
- ``ctrl.CB_ALL`` (254)

The callback signature is:

.. code:: python

   fn(net_type, msg_type, body)

``body`` is a ``bytes`` object or ``None``.

.. _ctrlset_message_callbackfn:

ctrl.set_message_callback(fn)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Legacy alias for registering a callback for the user message slot.

.. _ctrlpublish_rawdata:

ctrl.publish_raw(data)
~~~~~~~~~~~~~~~~~~~~~~

Publish raw bytes to the device upload topic.

.. _ctrlcb_-and-ctrlev_-constants:

ctrl.CB\_\* and ctrl.EV\_\* constants
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The module exports constants for callback and event handling:

- ``ctrl.CB_USER``, ``ctrl.CB_FCOTA``, ``ctrl.CB_CAPT``, ``ctrl.CB_ZTP``,
  ``ctrl.CB_CTRL``, ``ctrl.CB_ALL``
- ``ctrl.EV_CONNECTED``, ``ctrl.EV_DISCONNECTED``, ``ctrl.EV_MSG``
- ``ctrl.NET_WIFI``, ``ctrl.NET_LTE``, ``ctrl.NET_LORA``, ``ctrl.NET_SIGFOX``

--------------

Servers
-------

The FTP and Telnet servers are controlled through ``ctrl.ftpd()`` and
``ctrl.telnetd()``. When a persistent config is saved, the servers auto-start
whenever CTRL connects over a qualifying network (WiFi by default; LTE-M
optionally). They stop automatically when CTRL disconnects.

.. _ctrlftpdenable-save_persistentfalse-usernamenone-passwordnone-root_pathnone-start_ltefalse:

ctrl.ftpd([enable, save_persistent=False, username=None, password=None, root_path=None, start_lte=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Query or control the FTP server.

- Called with no arguments: returns ``True`` if the FTP server is currently
  running, ``False`` otherwise.
- ``enable`` (``bool``): ``True`` to start the server, ``False`` to stop it.
- ``save_persistent`` (``bool``): when ``True``, the supplied config is saved
  to the active config backend so the server auto-starts on the next qualifying
  connect.
- ``username`` (``str``): FTP login username. ``None`` leaves the stored value
  unchanged.
- ``password`` (``str``): FTP login password. ``None`` leaves the stored value
  unchanged.
- ``root_path`` (``str``): VFS path exposed as the FTP root (e.g.
  ``'/flash'``). ``None`` leaves the stored value unchanged.
- ``start_lte`` (``bool``): when ``True``, also auto-start on LTE-M connections
  (default ``False`` — WiFi only, because most LTE-M providers block inbound
  connections without a static/VPN-routed SIM).

.. code:: python

   ctrl.ftpd()          # returns True or False

   ctrl.ftpd(True)      # start immediately
   ctrl.ftpd(False)     # stop immediately

   # Enable with credentials and persist for auto-start on next WiFi connect:
   ctrl.ftpd(True, save_persistent=True, username='admin', password='secret')

   # Also allow auto-start on LTE:
   ctrl.ftpd(True, save_persistent=True, username='admin', password='secret',
            start_lte=True)

   # Disable and clear persistent state:
   ctrl.ftpd(False, save_persistent=True)

.. _ctrltelnetdenable-save_persistentfalse-usernamenone-passwordnone-start_ltefalse:

ctrl.telnetd([enable, save_persistent=False, username=None, password=None, start_lte=False])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Query or control the Telnet server. When running, a Telnet client connecting to
the device receives a full interactive MicroPython REPL (``>>>`` prompt) via
``os.dupterm()``.

- Called with no arguments: returns ``True`` if the Telnet server is currently
  running, ``False`` otherwise.
- ``enable`` (``bool``): ``True`` to start the server, ``False`` to stop it.
- ``save_persistent`` (``bool``): when ``True``, the supplied config is saved
  to the active config backend so the server auto-starts on the next qualifying
  connect.
- ``username`` (``str``): login username. ``None`` leaves the stored value
  unchanged. Only relevant when ``password`` is also set — adds a ``Login as:``
  prompt before ``Password:``; a username without a password is not a supported
  combination.
- ``password`` (``str``): login password. ``None`` means no authentication is
  required.
- ``start_lte`` (``bool``): when ``True``, also auto-start on LTE-M connections
  (default ``False``).

.. code:: python

   ctrl.telnetd()       # returns True or False

   ctrl.telnetd(True)   # start immediately (no password)
   ctrl.telnetd(False)  # stop immediately

   # Enable with a password and persist:
   ctrl.telnetd(True, save_persistent=True, password='secret')

   # Enable with a username + password and persist:
   ctrl.telnetd(True, save_persistent=True, username='admin', password='secret')

   # Disable and clear persistent state:
   ctrl.telnetd(False, save_persistent=True)

Connect with any standard Telnet client once the server is running. You'll see
a ``Login as:`` prompt first if a username is configured, then ``Password:``
(with no visible feedback while typing, matching standard ``telnet``/``login``
behaviour):

.. code:: sh

   telnet <device-ip> 23

--------------

Security
--------

The device security policy lets you disable specific remote-control
functionality per device. Blocked features cause the matching inbound platform
messages to be dropped before any handling — they never reach C handlers or
Python callbacks. Essential cloud plumbing (PING/PONG keepalive) is never
blockable, so the device stays manageable on the platform.

Features
~~~~~~~~

.. list-table::
   :header-rows: 1

   * - Feature
     - Blocks
   * - ``fcota``
     - All file-content OTA: file list/get/put/delete, remote command
       execution, BLE sensor updates — and also **network configuration
       updates** and **release deployments** (FCOTA, RELEASE_DEPLOY and
       DEVICE_NETWORK_DEPLOY messages)
   * - ``fota``
     - Firmware OTA triggers
   * - ``ctrl``
     - Remote CTRL commands: connect/disconnect/switch network, network status
       queries, device reset
   * - ``read_field``
     - Remote field-read requests
   * - ``user``
     - USER messages and any inbound message type without a dedicated handler
   * - ``uart_repl``
     - The UART0 REPL/console (see below)

Where the platform expects a response, the device answers with a failure so the
operation doesn't just time out: FOTA reports a failed status with
``"Operation not permitted"``, a blocked release deployment reports
``update_failed``, remote exec responds ``rc=4`` (``not_permitted``), and
blocked file operations return the FCOTA error form ``{"e": "not permitted"}``.
Blocked CTRL and READ_FIELD requests are dropped silently (their wire format
has no error response), so those requests time out on the platform side.

Kconfig
~~~~~~~

Every feature has two build-time parameters under
``SDK → Network → Ctrl Client → Security policy``:

- ``SDK_CTRL_CLIENT_SEC_<FEATURE>_DEFAULT`` — enabled by default? (default: y)
- ``SDK_CTRL_CLIENT_SEC_<FEATURE>_RUNTIME`` — runtime configurable? (default:
  y)

A feature with ``_RUNTIME=n`` is locked at its ``_DEFAULT`` value: it does not
appear in ``ctrl.security()`` and cannot be changed at runtime. When **no**
feature is runtime-configurable, every ``ctrl.security()`` call raises
``OSError: Operation not permitted``.

Additionally ``SDK_CTRL_CLIENT_SEC_UART_TX_DEBUG`` (default: n) keeps UART
console *output* alive when the UART REPL is disabled — see below.

.. _ctrlsecurityfeature-value--savetrue:

ctrl.security([feature[, value]], \*, save=True)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Query or change the security policy. Mirrors the ``ctrl.dbg()`` call styles:

.. code:: python

   ctrl.security()                      # dict of runtime-configurable features
                                        # {'fcota': True, 'fota': True, ...}
   ctrl.security('fota')                # single get -> True/False
   ctrl.security('fota', False)         # single set
   ctrl.security({'fota': False,        # bulk update, returns the updated dict
                  'read_field': False})

- ``True`` means the feature is **enabled** (messages processed normally).
- Message-feature changes apply **immediately** — no reconnect needed.
- ``save=False`` makes the change RAM-only: it reverts on reset (or on the next
  set). Useful to briefly enable a feature from trusted user code, e.g. inside
  a callback. Not valid for ``uart_repl``, which is a boot-time flag.
- Setting (or single-getting) a locked feature raises ``OSError EPERM``;
  unknown feature names raise ``ValueError``. Unknown keys in a bulk dict are
  ignored (``ctrl.dbg()`` convention).
- Works before ``ctrl.init()``.
- Persistent values are stored in NVS (outside ``ctrl_config.json``), so the
  platform cannot re-enable features through a network config deployment.

Disabling the UART REPL
~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ctrl.security('uart_repl', False)    # takes effect on the next boot

On the next boot UART0 is **fully silenced**: no REPL input, no Ctrl+C
interrupt, no console/log output. With the
``SDK_CTRL_CLIENT_SEC_UART_TX_DEBUG`` Kconfig option, output (boot logs,
``print()``) stays visible and only the input path is dead. The Telnet REPL and
USB interfaces are not affected. The ROM bootloader banner cannot be suppressed
from the application — burn the download-mode efuse (below) for a fully dark
UART.

The flag is honoured in safeboot as well — there is deliberately **no
backdoor**. Re-enable it over Telnet/remote exec with
``ctrl.security('uart_repl', True)`` + reboot, or recover a locked-out device
via USB download mode by erasing NVS (which resets the whole policy).

Locking down a device
~~~~~~~~~~~~~~~~~~~~~

The policy protects against *remote* misuse, but it is stored in NVS. For a
production lock-down:

1. Build with ``--secure`` (secure boot v2 + flash encryption) so the firmware
   and NVS cannot be tampered with or swapped.
2. Disable esptool/UART download mode so an attacker with physical access
   cannot erase NVS to reset the policy:
   ``espefuse.py --port <port> burn_efuse DIS_DOWNLOAD_MODE``. **This is
   irreversible** — the device can never be reflashed over serial again;
   firmware updates must go through OTA from then on.
3. Mind the order: while ``fcota`` (remote exec) is still enabled, the platform
   can run ``ctrl.security(...)`` remotely. Disable the features you don't need
   *before* deploying, or as the final provisioning step.
4. Note that blocking ``ctrl`` also blocks ZTP provisioning downlinks —
   activate the device before locking down.

--------------

Miscellaneous
-------------

.. _ctrldeepsleepms:

ctrl.deepsleep(ms)
~~~~~~~~~~~~~~~~~~

Disconnects the current connection, then puts the device into deep sleep for
``ms`` milliseconds. ``ms=0`` sleeps until an externally configured wake source
fires (e.g. an RTC GPIO configured separately), or forever if none is set.

Waking up is a full reset — this call never returns, and the client must be
reconnected from scratch (e.g. via ``ctrl.activate()`` / stored config) on the
next boot, same as after any other reset. Also available from native C via
``ctrlc_deepsleep(ms)``.

.. _ctrlmessage_queue_len:

ctrl.message_queue_len()
~~~~~~~~~~~~~~~~~~~~~~~~

Return the length of the pending message queue.

.. _ctrlmessage_queuesizenone-on_fullnone-savetrue:

ctrl.message_queue(size=None, on_full=None, save=True)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get or set the **offline send-queue**: how many messages to buffer while
disconnected, and what to do once it's full. Default: 10 slots,
``ctrl.MQ_IGNORE``.

.. code:: python

   ctrl.message_queue()                  # → current capacity (int)
   ctrl.message_queue(20)                # resize to 20; on_full/save unchanged/default
   ctrl.message_queue(20, ctrl.MQ_OLDEST) # resize and set the on-full policy
   ctrl.message_queue(0)                 # disable offline queueing entirely

``on_full`` is one of:

.. list-table::
   :header-rows: 1

   * - Constant
     - Behavior when the queue is full
   * - ``ctrl.MQ_IGNORE``
     - Drop the new message, keep the queue as-is (default).
   * - ``ctrl.MQ_OLDEST``
     - Replace the oldest message; prefers a queued message with the same pin
       over the true oldest, if one exists.
   * - ``ctrl.MQ_NEWEST``
     - Replace the newest message; prefers a queued message with the same pin
       over the true newest, if one exists.
   * - ``ctrl.MQ_PURGE``
     - Drop every queued message, then enqueue the new one.

Omitting ``on_full`` on a resize call keeps whatever policy is already in
effect.

Queued messages always drain in the order they were generated (oldest first)
once reconnected — including the message that replaces an evicted one under
``MQ_OLDEST``/``MQ_NEWEST``, which is re-inserted as the newest entry rather
than overwriting the evicted slot in place. Each buffered message also keeps
the timestamp of when it was actually generated (see ``ctrl.send_field()``
above), not when it's eventually sent.

``save=True`` (default) persists both settings via ``cfg_store`` (NVS or
``ctrl_config.json``, whichever backend is active) so ``ctrl.init()``
re-applies them on the next boot. ``save=False`` only changes the current
session.

Also available from native C via ``ctrlc_message_queue_get_size()``,
``ctrlc_message_queue_get_policy()``, and
``ctrlc_message_queue_set(size, on_full, save)``.

.. _ctrldebuglevel:

ctrl.debug([level])
~~~~~~~~~~~~~~~~~~~

Set or get the global CTRL subsystem debug level.

.. _ctrldbgcomponent-level:

ctrl.dbg([component[, level]])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set or get the per-component debug level.

.. _ctrlztpenabled:

ctrl.ztp([enabled])
~~~~~~~~~~~~~~~~~~~

Get or set the zero-touch provisioning enable flag.

--------------

Examples
--------

Example 1: Basic initialization and sending data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ctrl.send_field(1, 25.5)

Example 2: Configuration helpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ctrl.set_config("device_name", "my-device", permanent=True)
   print(ctrl.get_config())

Example 3: Callback handling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   def on_msg(net_type, msg_type, body):
       print(net_type, msg_type, body)

   ctrl.callback(ctrl.CB_USER, on_msg)

.. _logging--debugging:

Logging & Debugging
-------------------

The new CTRL binding uses the same subsystem and component logging model as the
legacy implementation. The available component names are:

.. list-table::
   :header-rows: 1

   * - Component Name
     - Meaning
   * - ``library``
     - protocol packing / unpacking
   * - ``protocol``
     - message protocol helpers
   * - ``connection``
     - transport and MQTT connection
   * - ``config``
     - config load / save logic
   * - ``sensors``
     - sensor integration
   * - ``main``
     - core module state
   * - ``mpy``
     - MicroPython wrapper / module glue

Enabling Debug Output
~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ctrl.debug(4)      # enable informational and debug output
   ctrl.dbg("connection", 5)

Querying Debug Levels
~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   print(ctrl.debug())
   print(ctrl.dbg("connection"))

Removed Commands and Compatibility Notes
----------------------------------------

The new CTRL client binding replaces several older entry points. The most
relevant changes are listed below:

- ``ctrl.start(autoconnect=True)`` is **deprecated** — it still works (accepted
  positionally or as a keyword, same as the old ``Ctrl.start()``) and calls
  ``ctrl.init(autoconnect=...)`` internally, but prints a deprecation warning.
  Use ``ctrl.init()`` directly instead.
- ``ctrl.enable_lte()`` no longer exists. Configure the network through the
  activation token / configuration and use ``ctrl.connect_lte()``.
- ``ctrl.enable_wifi()`` no longer exists. Configure the network through the
  activation token / configuration and use ``ctrl.connect_wifi()``.
- ``ctrl.connect_lora()`` no longer exists. Use ``ctrl.connect_lora_otaa()`` or
  ``ctrl.connect_lora_abp()``.
- ``ctrl.reconnect()`` is **deprecated** — it still works and calls
  ``ctrl.reload()`` internally, but prints a deprecation warning. Use
  ``ctrl.reload()`` directly instead.
- ``from ctrl import Ctrl; ctrl = Ctrl(config, activation, autoconnect, user_callback)``
  still works as a **deprecated** compatibility shim — it prints a deprecation
  warning, then behaves like ``ctrl.init()`` and returns the ``ctrl`` module
  itself (so ``ctrl.*`` calls keep working on the resulting object). Use
  ``ctrl.init()`` directly instead.
- ``ctrl.ztp()`` still exists, but its behavior is now tied to the current
  NVS-backed ZTP flags and is documented above.
