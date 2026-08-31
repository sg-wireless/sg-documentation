SG SDK Arduino packaging
========================

This folder contains the initial Arduino packaging scaffold for the SG SDK.

The goal is to generate a custom Arduino board-manager package without creating
a separate repository or requiring the SG SDK's Linux-only CMake/MicroPython
build flow.

Board selection
---------------

``boards.toml`` is the single source of truth for which SG boards ship in the
package. Hardware features, partition tables and sdkconfig overrides are read
from each board's own file in ``src/platforms/F1/boards/``, so they are never
duplicated.

Every board file under ``src/platforms/F1/boards/`` must appear in
``boards.toml`` with an explicit ``include = true/false``; the generator fails
otherwise, so a new SDK board cannot silently miss the Arduino package.
Excluded boards must carry a ``reason``.

Currently 7 boards ship (the SGW3501/3401/3201 families). The SGW3101 board and
every secure-element (``*S``) variant are excluded, as is ESP32S3-F1-WROOM — it
uses a second memory configuration (8 MB / octal PSRAM) and so would need a
second harvested library set.

To review the resolved selection:

.. code:: bash

   python3 tools/arduino/boards_config.py

What is included
----------------

- LTE-M modem support
- CTRL client support
- SG board profile metadata for the selected boards

Intentionally excluded for now:

- MicroPython runtime glue

- Secure-element support (not implemented anywhere in the SDK yet)

Generate the package
--------------------

There are two flavours, and they differ only in which boards ship.

The full package -- ``release``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ./fw_builder.sh --variant arduino release

Ships every board ``boards.toml`` includes. It takes no ``--board``: the build
always comes from the ``build_board`` declared there, and a ``--board`` on the
command line or in ``defaults.sdk`` is reported and ignored rather than quietly
narrowing a release. That board must be a feature superset of the others -- the
library set is harvested from its build, so a board in the list whose features
were not compiled would have nothing to link against.

Writes:

- ``build/arduino/package_sgwireless_index.json``
- ``build/arduino/sgwireless-esp32s3-<version>.zip``

A single-board package -- ``package``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

   ./fw_builder.sh --board SGW3201-F1L-OEM --variant arduino package

Ships that board alone, carrying only the components its features build -- a
LoRa-only board's package has no modem support in it, for example. Requires a
board, from the command line or ``defaults.sdk``. The artifacts are named after
the board so they can never be mistaken for, or overwrite, a release:

- ``build/arduino/package_sgwireless-<board_id>_index.json``
- ``build/arduino/sgwireless-esp32s3-<board_id>-<version>.zip``

Note a single-board package still installs as ``sgwireless:esp32`` at the same
version as a release, so the two indexes cannot both be configured in the IDE
at once.

Both flavours build the arduino variant first, then harvest that build tree
(``tools/arduino/harvest_libs.py``) and assemble the board-manager layout
(``tools/arduino/generate_arduino_release.py``). Every included board shares
one memory configuration, so a single build covers all of them.

Versioning
~~~~~~~~~~

The version is not written anywhere in the packaging tooling: it is derived
from the repo's git tag, via the same ``fw_version`` module the firmware build
uses. A tag ``v0.0.1-arduino`` produces ``sgwireless-esp32s3-0.0.1.zip`` — the
``-arduino`` suffix marks the lineage without changing the version, so the
Arduino package and the MicroPython firmware share one version scheme.

``src/comps/fw-version/fw_version.h`` is maintained by hand and must agree with
the tag; the generator refuses to build a package when the two disagree, rather
than shipping an archive whose contents report a different version than its
label. Pass ``--version`` to ``generate_arduino_release.py`` to override
deliberately.

Releases
--------

Pushing a ``v*`` tag runs ``.github/workflows/release.yml``, which publishes
one GitHub release named after the tag, carrying whatever that tag asked for:

.. list-table::
   :header-rows: 1

   * - Tag
     - Builds
   * - ``v1.5.0``
     - MicroPython firmware **and** the Arduino package
   * - ``v1.5.0-rc1``
     - the same, with ``rc1`` in the firmware version
   * - ``v1.5.0-rc1-micropython``
     - firmware only
   * - ``v1.5.0-rc1-arduino``
     - the Arduino package only

The ``-micropython`` / ``-arduino`` suffix must come last. It selects the build
and is stripped before the version string is derived, so a suffixed tag reports
the same version as the plain one -- public releases are tagged without a
suffix so a single release carries both packages, while the suffixed forms
exist for internal pre-releases of one package at a time.

The index embeds the URL Board Manager fetches the archive from, and there are
three ways it gets set:

- **Local builds** default to ``http://127.0.0.1:8765``, the test server
  installed by ``tools/arduino/install_http_service.sh``. Build, then point the
  IDE at ``http://127.0.0.1:8765/package_sgwireless_index.json``.
- **CI** sets ``SGW_ARDUINO_BOARD_URL`` to
  ``https://swserver.sgwireless.com/arduino``.
- **Publishing** rewrites it regardless: ``publish_arduino_release.py`` sets
  the URL of every version as it rebuilds the index on the download server, so
  the index served there always matches the files next to it.

Note the URL must point at the index *file*, not the directory holding it.

The index currently describes exactly one version — publishing a new one
replaces it rather than adding to the list.

Install in Arduino IDE
----------------------

1. Open Arduino IDE
2. File -> Preferences -> Additional Boards Manager URLs
3. Add the URL to the generated ``package_sgwireless_index.json`` file or the
   uploaded server URL
4. Tools -> Board -> Boards Manager -> install ``esp32 by SG Wireless``
5. Select your SG board under Tools -> Board -> ``esp32``

Status
------

The package installs, its boards resolve to valid FQBNs and sketches compile
against it. ``platform.txt`` and the Arduino core come from the pinned
``ext/arduino-esp32`` 3.3.11 checkout (the release based on ESP-IDF v5.5.1,
which matches this repo's ``ext/esp-idf`` submodule) rather than being
reproduced by hand; the only edits are the identity lines, the tool paths Board
Manager resolves differently, and the flash offsets of the SG partition layout.

The precompiled IDF library set is not taken from Espressif. It is harvested
from an SDK arduino-variant build, so it carries the SG sdkconfig, the SG
partition layout and the patched safeboot bootloader by construction, instead
of maintaining a second build of them through ``esp32-arduino-lib-builder``.

LoRaWAN reaches a sketch through the CTRL client rather than a separate API:
``ctrlc_connect()`` walks the device configuration's network preferences, and a
``"lora"`` entry makes it build the commissioning parameters from the token
(DevEUI, region, MAC version, OTAA or ABP keys) and join. The whole stack --
``lora_stack``, ``lora_if``, ``loramac_handler`` and the LoRaMac-node archives
-- is on the sketch link line already. It has seen less hardware testing than
the other two bearers.

One thing a sketch does need to get right: LoRaWAN is duty-cycle limited, so
uplinks have to be paced far more slowly than on WiFi or LTE-M, or the stack
starts refusing them. ``SGW_Ctrl`` shows the pattern with
``LORA_SEND_INTERVAL_MS``.

Still open: raw (non-WAN) LoRa from a sketch, which is a separate API
(``lora_ioctl``, see ``examples/lora-chat``), and a board-manager index that
lists several versions rather than one.

Hardware note
-------------

The SG modem power and reset lines are not driven directly by the ESP32 GPIOs.
They are routed through the SG GPIO expander on the board, matching the SG SDK
implementation in the IO expander interface and the LTE modem driver.

The generated board profile includes these mappings:

- IO expander I2C: port 0, SCL 7, SDA 8, interrupt 9
- LTE power control: IO expander pin 1
- LTE reset control: IO expander pin 3
- Lora power/reset: pins 0 and 2

This is the board-level contract the Arduino package now exposes to sketches.

Notes
-----

This is intentionally a bootstrap implementation. The generated package is
designed to make the board-manager path work on Windows without requiring
``fw_builder.sh`` or the SG SDK's ESP-IDF build scripts.

The production pin map, modem configuration, and hardware profile should be
refined once the exact SG ESP32-S3 board wiring is finalized.
