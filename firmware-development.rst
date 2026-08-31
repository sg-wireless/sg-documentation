SG SDK QuickStart
=================

.. _1-installation-esp-idf-prerequisites:

1) Installation (ESP-IDF prerequisites)
---------------------------------------

Start here and complete the ESP-IDF v5.5 prerequisite/setup steps:

- https://docs.espressif.com/projects/esp-idf/en/release-v5.5/esp32s3/get-started/linux-macos-setup.html#get-started-prerequisites

Important for SG SDK:

- Only **Step 1 (Get Started Prerequisites)** is required.
- **Step 2 (Get ESP-IDF)** and any further ESP-IDF setup steps are not required
  for this workflow.
- ``fw_builder.sh`` handles the SDK-managed ESP-IDF checkout/setup during the
  build flow.
- Install toml package ``sudo apt install python3-toml`` or
  ``pip install -U toml``

Windows note:

- Use WSL2 with Ubuntu, then follow the Linux instructions.
- For VS Code, use the Remote - WSL extension so all builds run inside WSL2.
- To flash your device in WSL2, a tool like
  `wsl-usb-manager <https://github.com/nickbeth/wsl-usb-manager>`__ or
  `wsl-usb-gui <https://gitlab.com/alelec/wsl-usb-gui>`__ is useful.

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

- File copy to/from device
- REPL access
- Running scripts
- Installing packages with ``mip``

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

- ``examples/ctrl_client_c/board_config.toml``

Build and flash:

.. code:: bash

   # from the sg-sdk repository root
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c build
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c flash --port /dev/ttyUSB0
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant native --project-dir examples/ctrl_client_c --flash monitor --port /dev/ttyUSB0

Activation token notes:

- The platform gives ``ctrl.activate("<base64-token>")``, copy only
  ``<base64-token>`` into ``ACTIVATION_TOKEN``.

See `examples/ctrl_client_c/README.md <examples/ctrl_client_c/README.md>`__ for
a complete token conversion snippet and full example details.

.. _7-build-and-flash-an-arduino-example:

7) Build and flash an Arduino example
-------------------------------------

The ``arduino`` variant builds any sketch under ``examples/arduino/`` directly
through the SDK — the quickest way to iterate without going through the Arduino
Board Manager. To install the pre-built package in the Arduino IDE (no SDK
checkout needed), see the :doc:`Arduino IDE guide </arduino/ide>` instead.

.. code:: bash

   # compile only
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant arduino \
       --project-dir examples/arduino/SGW_Ctrl build

   # compile, flash and open the serial monitor
   ./fw_builder.sh --board SGW3501-F1-StarterKit --variant arduino \
       --project-dir examples/arduino/SGW_Ctrl --port /dev/ttyUSB0 --flash monitor

Add ``--erase`` to wipe the flash first, and ``--clean`` to force a full
rebuild (needed when you change board or feature flags, since ESP-IDF keeps a
per-directory ``sdkconfig``). The sketch is compiled against the SDK sources
directly, so a change to a component is picked up immediately.

.. _8-build-an-arduino-board-manager-package:

8) Build an Arduino board-manager package
-----------------------------------------

``release`` produces the full package for every board in
```tools/arduino/boards.toml`` <tools/arduino/boards.toml>`__; ``package``
ships a single board. See the :doc:`Arduino packaging reference </arduino/packaging>` for board selection, versioning and
hosting locally.

.. code:: bash

   # full release package (takes no --board)
   ./fw_builder.sh --variant arduino release

   # single-board package
   ./fw_builder.sh --board SGW3201-F1L-OEM --variant arduino package

Output lands in ``build/arduino/``. The version comes from the git tag and must
match ``src/comps/fw-version/fw_version.h``. MicroPython, Arduino and native-C
applications share the same SDK version.
