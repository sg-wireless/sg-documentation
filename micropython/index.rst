MicroPython Libraries
=====================

The SG Wireless firmware is built on **MicroPython** and includes its full
standard library.  The upstream documentation applies directly---use the
cross-references below to find detailed API descriptions.


Standard Libraries
------------------

These modules ship with every MicroPython port and behave identically on
SG Wireless hardware:

.. hlist::
   :columns: 3

   * :doc:`builtins <micropython:library/builtins>`
   * :doc:`array <micropython:library/array>`
   * :doc:`binascii <micropython:library/binascii>`
   * :doc:`collections <micropython:library/collections>`
   * :doc:`errno <micropython:library/errno>`
   * :doc:`gc <micropython:library/gc>`
   * :doc:`hashlib <micropython:library/hashlib>`
   * :doc:`io <micropython:library/io>`
   * :doc:`json <micropython:library/json>`
   * :doc:`math <micropython:library/math>`
   * :doc:`os <micropython:library/os>`
   * :doc:`random <micropython:library/random>`
   * :doc:`re <micropython:library/re>`
   * :doc:`select <micropython:library/select>`
   * :doc:`socket <micropython:library/socket>`
   * :doc:`ssl <micropython:library/ssl>`
   * :doc:`struct <micropython:library/struct>`
   * :doc:`sys <micropython:library/sys>`
   * :doc:`time <micropython:library/time>`
   * :doc:`uasyncio <micropython:library/asyncio>`


Hardware & System Libraries
---------------------------

.. hlist::
   :columns: 3

   * :doc:`machine <micropython:library/machine>`
   * :doc:`machine.Pin <micropython:library/machine.Pin>`
   * :doc:`machine.I2C <micropython:library/machine.I2C>`
   * :doc:`machine.SPI <micropython:library/machine.SPI>`
   * :doc:`machine.UART <micropython:library/machine.UART>`
   * :doc:`machine.ADC <micropython:library/machine.ADC>`
   * :doc:`machine.Timer <micropython:library/machine.Timer>`
   * :doc:`machine.RTC <micropython:library/machine.RTC>`
   * :doc:`machine.WDT <micropython:library/machine.WDT>`
   * :doc:`micropython <micropython:library/micropython>`
   * :doc:`network <micropython:library/network>`
   * :doc:`bluetooth <micropython:library/bluetooth>`
   * :doc:`esp32 <micropython:library/esp32>`


SG Wireless Extensions
-----------------------

The following modules are **SG Wireless specific** and are documented in the
:doc:`API Reference </api/index>` section:

- :doc:`/api/lora` --- LoRa WAN and RAW radio
- :doc:`/api/lte` --- LTE Cat-M1 / NB-IoT
- :doc:`/api/ctrl-client` --- Ctrl Cloud client
- :doc:`/api/rgbled` --- RGB LED


Further Reading
---------------

* `MicroPython documentation <https://docs.micropython.org/en/latest/>`_
* `MicroPython quick reference for ESP32 <https://docs.micropython.org/en/latest/esp32/quickref.html>`_
