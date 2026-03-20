:mod:`lora` --- LoRa Callback System
=====================================

.. module:: lora
   :noindex:

The LoRa stack provides a flexible callback system that notifies user code
of TX/RX events in both RAW and WAN modes.

.. seealso:: :doc:`lora`, :doc:`lora-wan`, :doc:`lora-raw`


LoRa Events
-----------

.. list-table::
   :header-rows: 1
   :widths: 35 12 53

   * - Event
     - Mode
     - Description
   * - ``lora._event.EVENT_RX_DONE``
     - RAW, WAN
     - Data received successfully
   * - ``lora._event.EVENT_RX_FAIL``
     - RAW
     - Receive operation failed
   * - ``lora._event.EVENT_RX_TIMEOUT``
     - RAW
     - Receive timed out
   * - ``lora._event.EVENT_TX_DONE``
     - RAW, WAN
     - Transmission completed
   * - ``lora._event.EVENT_TX_CONFIRM``
     - WAN
     - Network server confirmed reception
   * - ``lora._event.EVENT_TX_FAILED``
     - RAW, WAN
     - Transmission failed
   * - ``lora._event.EVENT_TX_TIMEOUT``
     - RAW, WAN
     - Transmission deadline exceeded


Event Details
~~~~~~~~~~~~~

**EVENT_RX_DONE** callback context:

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Mode
     - Description
   * - ``event``
     - RAW, WAN
     - The event constant
   * - ``data``
     - RAW, WAN
     - Received data (bytes)
   * - ``RSSI``
     - RAW, WAN
     - RSSI of received signal
   * - ``SNR``
     - RAW, WAN
     - SNR of received signal
   * - ``port``
     - WAN
     - LoRa WAN port number
   * - ``DR``
     - WAN
     - Data rate
   * - ``dl_frame_counter``
     - WAN
     - Downlink frame counter

**TX events** (WAN only) include a ``msg_id`` key containing the user-defined
message ID passed to :func:`lora.send`.


Generic Callback Interface
--------------------------

.. function:: lora.callback(handler=, [trigger=, port=])

   Register a callback routine.

   :param handler: A function that receives a ``context`` dict.
   :param trigger: One or more ``lora._event.*`` constants combined with
       ``|``.  If omitted, the handler receives all events.
   :param int port: (WAN only) Restrict to a specific port's events.

   .. important::

      In WAN mode, registering a callback for a port that has not been
      opened yet will be ignored.

   **Callback dispatch rules:**

   - A handler registered with a specific ``trigger`` takes priority over
     the generic handler for those events.
   - In WAN mode, a port-specific handler takes priority over the generic
     handler for that port's events.


Example --- LoRa RAW
--------------------

.. code-block:: python

   import lora
   lora.mode(lora._mode.RAW)

   def lora_raw_callback(context):
       print('event:', context)

   def lora_raw_rx_done(context):
       print('received:', context.get('data'))

   def lora_raw_timeout(context):
       print('timeout!')

   # Generic handler
   lora.callback(handler=lora_raw_callback)

   # Specialized handler for RX_DONE
   lora.callback(
       handler=lora_raw_rx_done,
       trigger=lora._event.EVENT_RX_DONE
   )

   # Combined handler for timeouts
   lora.callback(
       handler=lora_raw_timeout,
       trigger=lora._event.EVENT_TX_TIMEOUT | lora._event.EVENT_RX_TIMEOUT
   )


Example --- LoRa WAN
--------------------

.. code-block:: python

   import lora
   lora.mode(lora._mode.WAN)

   def wan_callback(context):
       event = context.get('event')
       if event == lora._event.EVENT_RX_DONE:
           print('RX:', context.get('data'))
       elif event == lora._event.EVENT_TX_DONE:
           print('TX done, msg_id:', context.get('msg_id'))
       elif event == lora._event.EVENT_TX_CONFIRM:
           print('TX confirmed, msg_id:', context.get('msg_id'))

   def port1_rx(context):
       print('port 1 data:', context.get('data'))

   lora.port_open(1)
   lora.port_open(2)

   # Generic handler
   lora.callback(handler=wan_callback)

   # Port-specific handler
   lora.callback(handler=port1_rx, port=1)

   # Port + event specific
   lora.callback(
       handler=port1_rx,
       port=1,
       trigger=lora._event.EVENT_TX_CONFIRM
   )
