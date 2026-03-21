LoRa API Documentation
======================

Initialization
--------------

To initialize the LoRa stack, you need to do import lora to be able to call any lora utility and to automatically initialize the saved operating lora mode:

.. code-block:: python

   import lora                 # mandatory before any lora function call
                               # automatically initialize lora for current operating mode
   lora.deinit()               # deinit the stack
                               # all lora calls will be ignored after it
   lora.initialize()      # initialize the stack again and back to normal operation

LoRa Modes
----------

There are two available modes for lora; LoRa-RAW and LoRa-WAN.

.. code-block:: python

   lora.mode()                 # displays the current operating LoRa mode
   lora.mode(lora._mode.RAW)   # switch mode to LoRa-RAW
   lora.mode(lora._mode.WAN)   # switch mode to LoRa-WAN

LoRa Test stub
--------------

In case of testing and no need to connect a user level callback, lora-stack provides an internal stub for callbacks to be used while testing.

.. code-block:: python

   lora.callback_stub_connect()          # connect the internal lora-stack callback stub
   lora.callback_stub_disconnect()       # to disconnect it and connect user provided one

LoRa Events and Callbacks
-------------------------

LoRa events and callback system are explained in :doc:`lora-callbacks`.

LoRa RAW APIs
-------------

LoRa RAW mode API documentation can be found in :doc:`lora-raw`.

LoRa WAN APIs
-------------

LoRa WAN mode API documentation can be found in :doc:`lora-wan`.
