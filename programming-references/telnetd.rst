Telnet Server
=============

Contents
--------

-  Introduction
-  Using with CTRL (recommended)
-  Standalone ``telnetd`` module
-  C API

Introduction
------------

The Telnet server component provides a single-client TCP server on port 23 that
gives remote access to the MicroPython REPL over a WiFi or LTE-M connection.
When a client connects, the server attaches the socket to the MicroPython REPL
engine via ``os.dupterm()``, giving a fully interactive ``>>>`` prompt —
identical to the serial REPL.

Only one client can be connected at a time. Disconnecting the Telnet client
(including hard closes like Ctrl-C / window close) cleanly detaches ``dupterm``
without generating spurious error messages in the serial log.

After a MicroPython soft reset the server automatically re-attaches to the new
REPL instance so a connected client does not need to reconnect.

   **Note on LTE-M**: Most LTE-M SIM cards do not provide a routable IP
   address, so inbound connections will not reach the device. The server will
   only auto-start on LTE-M when explicitly enabled with ``start_lte=True``
   (typically for SIMs with a static or VPN-routed address).

Using with CTRL (recommended)
-----------------------------

The ``ctrl.telnetd()`` function controls the Telnet server as part of the CTRL
lifecycle. When a persistent config is saved, the server auto-starts whenever
CTRL connects over a qualifying network.

.. _ctrltelnetd:

``ctrl.telnetd()``
~~~~~~~~~~~~~~~~~~

With no arguments, returns ``True`` if the Telnet server is currently running,
``False`` otherwise.

.. code:: python

   ctrl.telnetd()   # returns True or False

.. _ctrltelnetdenable:

``ctrl.telnetd(enable)``
~~~~~~~~~~~~~~~~~~~~~~~~

Start (``True``) or stop (``False``) the Telnet server immediately.

.. code:: python

   ctrl.telnetd(True)    # start
   ctrl.telnetd(False)   # stop

.. _ctrltelnetdenable-save_persistentfalse-usernamenone-passwordnone-start_ltefalse:

``ctrl.telnetd(enable, save_persistent=False, username=None, password=None, start_lte=False)``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Full signature. All keyword arguments are optional.

.. list-table::
   :header-rows: 1

   - 

      - Argument
      - Type
      - Default
      - Description
   - 

      - ``enable``
      - ``bool``
      - —
      - ``True`` to start, ``False`` to stop
   - 

      - ``save_persistent``
      - ``bool``
      - ``False``
      - Persist the config so the server auto-starts on the next qualifying
         connect
   - 

      - ``username``
      - ``str``
      - ``None``
      - Login username; ``None`` leaves the current value unchanged. Only
         relevant when ``password`` is also set — a username without a password
         is not a supported combination
   - 

      - ``password``
      - ``str``
      - ``None``
      - Login password; ``None`` leaves the current value unchanged (no
         password required)
   - 

      - ``start_lte``
      - ``bool``
      - ``False``
      - Also auto-start on LTE-M connections (default: WiFi only)

.. code:: python

   # Enable with a password and persist:
   ctrl.telnetd(True, save_persistent=True, password='secret')

   # Enable without a password:
   ctrl.telnetd(True, save_persistent=True)

   # Enable with a username + password (adds a "Login as:" prompt before "Password:"):
   ctrl.telnetd(True, save_persistent=True, username='admin', password='secret')

   # Also allow auto-start on LTE (requires a routable SIM):
   ctrl.telnetd(True, save_persistent=True, password='secret', start_lte=True)

   # Disable and clear persistent state:
   ctrl.telnetd(False, save_persistent=True)

The persisted config is saved alongside the CTRL activation config (in NVS or
``ctrl_config.json``, whichever backend is active).

Connecting
~~~~~~~~~~

Once the server is running, connect with any standard Telnet client:

.. code:: sh

   telnet <device-ip> 23

or with ``nc``:

.. code:: sh

   nc <device-ip> 23

You will receive the MicroPython ``>>>`` prompt. Use Ctrl-] then ``quit``
(standard Telnet) or simply close the connection to disconnect.

Standalone ``telnetd`` module
-----------------------------

When not using the CTRL integration, the ``telnetd`` module can be used
directly to start the server independently of the CTRL connection state.

.. _telnetdinitpassword-username:

``telnetd.init([password[, username]])``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start the Telnet server.

-  ``password`` — optional login password (string). Omit for no authentication.
-  ``username`` — optional login username (string). Only relevant when
   ``password`` is also set — adds a "Login as:" prompt before "Password:".
   Omit for no username prompt.

.. code:: python

   import telnetd
   telnetd.init()                      # no password
   telnetd.init('secret')              # with password, no username prompt
   telnetd.init('secret', 'admin')     # with username + password

.. _telnetddeinit:

``telnetd.deinit()``
~~~~~~~~~~~~~~~~~~~~

Stop the Telnet server.

.. code:: python

   telnetd.deinit()

.. _telnetdrunning:

``telnetd.running()``
~~~~~~~~~~~~~~~~~~~~~

Returns ``True`` if the server is currently running.

.. code:: python

   if telnetd.running():
       print("Telnet server is active")

C API
-----

The low-level C API is declared in ``inc/sg_telnetd.h``.

.. code:: c

   esp_err_t sg_telnetd_start(const sg_telnetd_config_t *cfg);
   void      sg_telnetd_stop(void);
   bool      sg_telnetd_is_running(void);
   void      sg_telnetd_mpy_reset(void);

``sg_telnetd_config_t`` fields:

.. list-table::
   :header-rows: 1

   - 

      - Field
      - Type
      - Default
      - Description
   - 

      - ``port``
      - ``uint16_t``
      - ``23``
      - TCP listen port
   - 

      - ``username``
      - ``const char *``
      - ``NULL``
      - Login username; ``NULL``/``""`` skips the ``Login as:`` prompt. Only
         relevant when ``password`` is also set — a username without a password
         is not a supported combination
   - 

      - ``password``
      - ``const char *``
      - ``NULL``
      - Login password; ``NULL`` = no authentication required
   - 

      - ``client_cb``
      - ``sg_telnetd_client_fn_t``
      - ``NULL``
      - Native C build only: called with the accepted socket fd for each
         connection; ``NULL`` uses a built-in echo handler

Pass ``NULL`` for ``cfg`` to use all defaults (REPL attachment in MicroPython
builds, echo handler in native C builds).

When both ``username`` and ``password`` are set, the login sequence is
``Login as:`` (echoed back visibly) followed by ``Password:`` (not echoed at
all — no mask character either, matching standard ``telnet``/``login``
behaviour). Up to 3 attempts are allowed before the connection is closed. On
the MicroPython build, the success message includes the exact wording expected
by ``tools/pyboard.py``'s ``TelnetToSerial`` (used by
``mpremote``/``run-tests`` over telnet):
``Type "help()" for more information.``

The higher-level ``ctrl_api.h`` functions ``ctrlc_telnet_set()``,
``ctrlc_telnet_enable()``, and ``ctrlc_telnet_disable()`` wrap the above and
integrate with the CTRL connection lifecycle.
