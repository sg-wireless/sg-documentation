SG Firmware API Reference
=========================

This section documents the MicroPython modules available on the SG Wireless F1
platform.  Each module is implemented as a built-in C extension and can be
imported directly from the MicroPython REPL or from user scripts.

Application
------------------
.. toctree::
   :maxdepth: 1

   ctrl-client

Network Interfaces
------------------
.. toctree::
   :maxdepth: 1

   lora
   lora-wan
   lora-raw
   lora-callbacks
   lte
   lte-legacy

Peripherals & System
------------------
.. toctree::
   :maxdepth: 1

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
