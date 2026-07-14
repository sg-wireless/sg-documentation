SG SDK QuickStart
=================

.. _1-installation-esp-idf-prerequisites:

1) Installation (ESP-IDF prerequisites)
---------------------------------------

Start here and complete the ESP-IDF v5.5 prerequisite/setup steps:

-  https://docs.espressif.com/projects/esp-idf/en/release-v5.5/esp32s3/get-started/linux-macos-setup.html#get-started-prerequisites

Important for SG SDK:

-  Only **Step 1 (Get Started Prerequisites)** is required.
-  **Step 2 (Get ESP-IDF)** and any further ESP-IDF setup steps are not
   required for this workflow.
-  ``fw_builder.sh`` handles the SDK-managed ESP-IDF checkout/setup during the
   build flow.

Windows note:

-  Use WSL2 with Ubuntu, then follow the Linux instructions.
-  For VS Code, use the Remote - WSL extension so all builds run inside WSL2.
-  To flash your device in WSL2, a tool like
   (wsl-usb-manager)[https://github.com/nickbeth/wsl-usb-manager] or
   (wsl-usb-gui)[https://gitlab.com/alelec/wsl-usb-gui] is useful.

.. _2-clone-the-repository:

2) Clone the repository
-----------------------

.. code:: bash

   git clone https://github.com/sg-wireless/sg-sdk.git
   cd sg-sdk

.. _3-optional-defaultssdk-setup:

3) Optional: defaults.sdk setup
-------------------------------

To avoid repeating ``--board``, ``--port``, ``--variant``, and
``--project-dir`` every command:

.. code:: bash

   # from the sg-sdk repository root
   cp defaults.sdk.example defaults.sdk
   # Edit defaults.sdk and set at least: board
   # Recommended defaults: port, variant, project-dir

CLI arguments always override values in ``defaults.sdk``.

Example (when ``variant = "native"`` and
``project-dir = "examples/ctrl_client_c"`` are set):

.. code:: bash

   ./fw_builder.sh --board SGW3501-F1-StarterKit build
   ./fw_builder.sh --board SGW3501-F1-StarterKit flash --port /dev/ttyUSB0
   ./fw_builder.sh --board SGW3501-F1-StarterKit --flash monitor --port /dev/ttyUSB0

.. _4-build-and-flash-micropython-firmware:

4) Build and flash MicroPython firmware
---------------------------------------

Example (StarterKit board):

.. code:: bash

   # from the sg-sdk repository root
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant micropython build
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant micropython flash --port /dev/ttyUSB0

If ``variant`` is omitted, MicroPython is the default.

.. _5-optional-mpremote-for-device-workflows:

5) Optional: mpremote for device workflows
------------------------------------------

``mpremote`` is useful for:

-  File copy to/from device
-  REPL access
-  Running scripts
-  Installing packages with ``mip``

Installation: Via pip / pipx: Use ``pip install mpremote`` or
``pipx install mpremote`` Via package manager: On Ubuntu use:
``sudo apt install micropython-mpremote`` Via sg-sdk/ext/micropython submodule
``ext/micropython/tools/mpremote/mpremote.py``

Typical commands:

``mpremote`` or ``mpremote.py`` automatically connects to the first available
serial port and opens the REPL If you have multiple open serial ports, specify
on the command line as shown below.

.. code:: bash

   mpremote connect /dev/ttyUSB0 # opens MicroPython REPL
   mpremote connect /dev/ttyUSB0 cp app.py : # copy local app.py to the device
   mpremote connect /dev/ttyUSB0 cp :app.py app.backup # copy device file /app.py to local file app.backup
   mpremote connect /dev/ttyUSB0 run app.py  # execute local app.py on the device
   mpremote connect /dev/ttyUSB0 mip install <package> # download package via mip and upload to device

.. _6-build-and-flash-the-ctrl_client_c-example:

6) Build and flash the ctrl_client_c example
--------------------------------------------

``ctrl_client_c`` is native-only (C API), configured through:

-  ``examples/ctrl_client_c/board_config.toml``

Build and flash:

.. code:: bash

   # from the sg-sdk repository root
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c build
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c flash --port /dev/ttyUSB0
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c --flash monitor --port /dev/ttyUSB0

Activation token notes:

-  The platform gives ``ctrl.activate("<base64-token>")``, copy only
   ``<base64-token>`` into ``ACTIVATION_TOKEN``.

See `examples/ctrl_client_c/README.md <examples/ctrl_client_c/README.md>`__ for
a complete token conversion snippet and full example details.
