:mod:`efuse_if` --- eFuse Interface
===================================

.. module:: efuse_if
   :synopsis: Read-only access to ESP32-S3 eFuse identity data

The ``efuse_if`` module provides read access to the ESP32-S3 one-time
programmable (OTP) fuse memory.  eFuses store factory-provisioned board
identity data written during manufacturing.


Read Functions
--------------

All functions return a ``bytes`` object.

.. function:: efuse_if.layout_version()

   Return the eFuse user-data block layout version (1 byte).

.. function:: efuse_if.lora_mac()

   Return the LoRa WAN DevEUI (8 bytes).

.. function:: efuse_if.serial_number()

   Return the board serial number (6 bytes).

.. function:: efuse_if.hw_id()

   Return the manufacturer hardware ID (3 bytes).

.. function:: efuse_if.project_id()

   Return the project-specific ID (3 bytes).

.. function:: efuse_if.wifi_mac()

   Return the WiFi MAC address (6 bytes).


Optional LoRa Key Functions
----------------------------

Available when LoRa key storage on eFuses is enabled
(``SDK_BOARD_LORA_WAN_KEYS_ON_EFUSES``):

.. function:: efuse_if.lora_app_key()

   Return the LoRa WAN OTAA AppKey (16 bytes).

.. function:: efuse_if.lora_nwk_key()

   Return the LoRa WAN OTAA NwkKey (16 bytes).


eFuse Layout
------------

Board identity data is stored in **EFUSE_BLK3** (User Data):

.. list-table::
   :header-rows: 1
   :widths: 25 15 60

   * - Field
     - Size
     - Description
   * - LPWAN_MAC
     - 8 bytes
     - LoRa WAN DevEUI
   * - SERIAL_NUMBER
     - 6 bytes
     - Board serial number
   * - HW_ID
     - 3 bytes
     - Hardware ID
   * - PROJECT_ID
     - 3 bytes
     - Project-specific ID
   * - Reserved
     - 4 bytes
     - Reserved for future use
   * - LAYOUT_VERSION
     - 1 byte
     - Layout version number
   * - WIFI_MAC
     - 6 bytes
     - WiFi MAC address
   * - CRC8
     - 1 byte
     - CRC8 checksum


Example
-------

.. code-block:: python

   import efuse_if

   deveui = efuse_if.lora_mac()
   print("DevEUI:", deveui.hex())

   wifi = efuse_if.wifi_mac()
   print("WiFi MAC:", wifi.hex())

   sn = efuse_if.serial_number()
   print("Serial:", sn.hex())

   ver = efuse_if.layout_version()
   print("Layout version:", int.from_bytes(ver, 'little'))
