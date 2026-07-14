FTP Server
==========

Contents
--------

-  Introduction
-  Using with CTRL (recommended)
-  Standalone ``ftpd`` module
-  C API

Introduction
------------

The FTP server component provides a passive-mode FTP server backed by the
ESP-IDF VFS layer. It exposes the device flash filesystem (or any other mounted
VFS path) to an FTP client such as FileZilla, allowing file upload, download,
and deletion over a WiFi or LTE-M network connection.

Only one client can be connected at a time. The server listens on TCP port 21
by default.

The FTP server is most conveniently controlled through the ``ctrl`` module,
which ties its lifecycle to the MQTT connection state: the server starts
automatically when CTRL connects over a supported network and stops when CTRL
disconnects.

   **Note on LTE-M**: Most LTE-M SIM cards do not provide a routable IP
   address, so inbound connections from an FTP client will not reach the
   device. The server will only auto-start on LTE-M when explicitly enabled
   with ``start_lte=True`` (typically for SIMs with a static or VPN-routed
   address).

Using with CTRL (recommended)
-----------------------------

The ``ctrl.ftpd()`` function controls the FTP server as part of the CTRL
lifecycle. When a persistent config is saved, the server auto-starts whenever
CTRL connects over a qualifying network.

.. _ctrlftpd:

``ctrl.ftpd()``
~~~~~~~~~~~~~~~

With no arguments, returns ``True`` if the FTP server is currently running,
``False`` otherwise.

.. code:: python

   ctrl.ftpd()   # returns True or False

.. _ctrlftpdenable:

``ctrl.ftpd(enable)``
~~~~~~~~~~~~~~~~~~~~~

Start (``True``) or stop (``False``) the FTP server immediately.

.. code:: python

   ctrl.ftpd(True)    # start
   ctrl.ftpd(False)   # stop

.. _ctrlftpdenable-save_persistentfalse-usernamenone-passwordnone-root_pathnone-start_ltefalse:

``ctrl.ftpd(enable, save_persistent=False, username=None, password=None, root_path=None, start_lte=False)``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
      - FTP login username; ``None`` leaves the current value unchanged
   - 

      - ``password``
      - ``str``
      - ``None``
      - FTP login password; ``None`` leaves the current value unchanged
   - 

      - ``root_path``
      - ``str``
      - ``None``
      - VFS path to expose as the FTP root (e.g. ``'/flash'``); ``None`` uses
         the default
   - 

      - ``start_lte``
      - ``bool``
      - ``False``
      - Also auto-start on LTE-M connections (default: WiFi only)

.. code:: python

   # Enable and persist with credentials — auto-starts on next WiFi connect:
   ctrl.ftpd(True, save_persistent=True, username='admin', password='secret')

   # Same but also allow auto-start on LTE (requires a routable SIM):
   ctrl.ftpd(True, save_persistent=True, username='admin', password='secret',
            start_lte=True)

   # Change root path without re-entering credentials:
   ctrl.ftpd(True, save_persistent=True, root_path='/flash/data')

   # Disable and clear persistent state:
   ctrl.ftpd(False, save_persistent=True)

The persisted config is saved alongside the CTRL activation config (in NVS or
``ctrl_config.json``, whichever backend is active).

Standalone ``ftpd`` module
--------------------------

When not using the CTRL integration, the ``ftpd`` module can be used directly.
Import it to start the server independently of the CTRL connection state.

.. _ftpdinitusername-password-path:

``ftpd.init(username, password[, path])``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start the FTP server.

-  ``username`` — required login username (string).
-  ``password`` — required login password (string).
-  ``path`` — optional VFS root path (default ``'/flash'``).

.. code:: python

   import ftpd
   ftpd.init('admin', 'secret')
   ftpd.init('admin', 'secret', '/flash/data')

.. _ftpddeinit:

``ftpd.deinit()``
~~~~~~~~~~~~~~~~~

Stop the FTP server.

.. code:: python

   ftpd.deinit()

.. _ftpdrunning:

``ftpd.running()``
~~~~~~~~~~~~~~~~~~

Returns ``True`` if the server is currently running.

.. code:: python

   if ftpd.running():
       print("FTP server is active")

C API
-----

The low-level C API is declared in ``inc/sg_ftpd.h``.

.. code:: c

   esp_err_t sg_ftpd_start(const sg_ftpd_config_t *cfg);
   void      sg_ftpd_stop(void);
   bool      sg_ftpd_is_running(void);

``sg_ftpd_config_t`` fields:

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
      - ``21``
      - TCP listen port
   - 

      - ``username``
      - ``const char *``
      - ``"anonymous"``
      - Required login username
   - 

      - ``password``
      - ``const char *``
      - any
      - Required login password; ``NULL`` = accept any password
   - 

      - ``base_path``
      - ``const char *``
      - ``"/flash"``
      - VFS path exposed as FTP root

Pass ``NULL`` for ``cfg`` to use all defaults.

The higher-level ``ctrl_api.h`` functions ``ctrlc_ftp_set()``,
``ctrlc_ftp_enable()``, and ``ctrlc_ftp_disable()`` wrap the above and
integrate with the CTRL connection lifecycle.
