LoRa API Documentation
======================

Contents
--------

- Initialization
- LoRa Modes
- LoRa Test Stub
- `LoRa Events and Callback <lora-callback.md>`__
- `LoRa RAW APIs <lora-raw.md>`__
- `LoRa WAN APIs <lora-wan.md>`__
- `LoRa Certification Mode <lora-lctt.md>`__
- Examples

  - Example - LoRa-WAN End-Device Commissioning:

    - `OTAA - LoRaWAN Specs
      v1.0.x <../tst/mpy/lorawan_commission/commission_otaa_v1_0_x.py>`__
    - `OTAA - LoRaWAN Specs
      v1.1.x <../tst/mpy/lorawan_commission/commission_otaa_v1_1_x.py>`__
    - `ABP - LoRaWAN Specs
      v1.0.x <../tst/mpy/lorawan_commission/commission_abp_v1_0_x.py>`__
    - `ABP - LoRaWAN Specs
      v1.1.x <../tst/mpy/lorawan_commission/commission_abp_v1_1_x.py>`__

Initialization
--------------

To initialize the LoRa stack, you need to do ``import lora`` to be able to call
any lora utility and to automatically initialize the saved operating lora mode:

.. code:: python

   import lora     # mandatory before any lora function call
                   # automatically initialize lora for current operating mode

   lora.deinit()   # deinit the stack
                   # all lora calls will be ignored after it

   lora.initialize()
                   # initialize the stack again and back to normal operation

LoRa Modes
----------

There are two available modes for lora; *LoRa-RAW* and *LoRa-WAN*.

.. code:: python

   lora.mode()                              # returns the current operating LoRa mode
   lora.mode(lora._mode.RAW)               # switch mode to LoRa-RAW
   lora.mode(lora._mode.WAN)               # switch mode to LoRa-WAN (ADR enabled by default)
   lora.mode(lora._mode.WAN, adr=False)    # switch to LoRa-WAN with ADR disabled
   lora.mode(lora._mode.WAN, adr=True)     # switch to LoRa-WAN with ADR explicitly enabled

The optional ``adr`` keyword argument controls Adaptive Data Rate (ADR) when
switching to WAN mode. ADR allows the network server to optimise the device's
data rate and transmission power. Disable it when the device is mobile or the
RF environment is expected to change frequently.

   **NOTE**: The ``adr`` argument is only meaningful when switching to
   ``lora._mode.WAN``. It has no effect when querying the current mode or
   switching to ``lora._mode.RAW``.

LoRa Test stub
--------------

In case of testing and no need to connect a user level callback, lora-stack
provides an internal stub for callbacks to be used while testing.

.. code:: python

   lora.callback_stub_connect()    # connect the internal lora-stack callback stub
   lora.callback_stub_disconnect() # to disconnect it and connect user provided one
