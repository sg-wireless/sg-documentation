SG Firmware API Reference
=========================

This section documents the MicroPython modules available on the SG Wireless F1
platform.  Each module is implemented as a built-in C extension and can be
imported directly from the MicroPython REPL or from user scripts.

.. toctree::
   :maxdepth: 1
   :caption: Application

   ctrl-client

.. toctree::
   :maxdepth: 1
   :caption: Network Interfaces

   lora
   lora-wan
   lora-raw
   lora-callbacks
   lte
   lte-legacy

.. toctree::
   :maxdepth: 1
   :caption: Peripherals & System

   rgbled
   nvs
   sysinfo
   ioexp
   fuel-gauge
   can
   efuse
   fuota
   safeboot
   sys-inspect
