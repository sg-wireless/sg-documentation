SafeBoot Feature
================

SafeBoot introduces two boot modes:

- **Normal mode** --- full startup sequence including ``boot.py`` and
  ``main.py``.
- **SafeBoot mode** --- basic hardware initialization only, skipping
  application scripts.


Entering SafeBoot
-----------------

**Software reset:**
  Press ``Ctrl+F`` in the MicroPython REPL, or call
  ``bootif_safeboot_soft_reset()`` from code.

**Hardware button:**
  If a SafeBoot button is present on the board, press and hold it during
  reset.  The hold time determines which firmware image is loaded:

  .. list-table::
     :header-rows: 1
     :widths: 25 75

     * - Hold Time
       - Action
     * - 0--3 sec
       - SafeBoot into latest firmware
     * - 3--7 sec
       - SafeBoot into previous OTA firmware
     * - > 7 sec
       - SafeBoot into factory firmware


Configuration
-------------

SafeBoot hold times and GPIO assignment are configurable through the SDK
``menuconfig``:

.. code-block:: text

   ./fw_builder.sh --board SGW3501-F1-EVB config
   # Navigate to: SDK Platform → F1 Platform → Safeboot Feature


C API
-----

The SafeBoot functions are declared in
``src/platforms/F1/bootloader_components/boot-if/boot_if.h``:

.. function:: bootif_state_set()

   Set the boot state.  Used as a ping-pong between the bootloader and the
   application.

.. function:: bootif_state_get()

   Get the current boot state (normal or safeboot) so the application can
   take appropriate action.

.. function:: bootif_safeboot_soft_reset()

   Hard-reset the system into SafeBoot mode.

.. function:: bootif_safeboot_soft_reset_init()

   Initialize the software reset mechanism.  Must be called during system
   startup.
