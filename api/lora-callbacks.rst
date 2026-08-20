LoRa Callback System
====================

Introduction
------------

LoRa APIs provides very flexible interface to enable the user to connect a special callback routine to listen to emmitted LoRa events.

When LoRa is in its operation whether sending or receiving, it generates an event to let the user knows and listen to its occurred events, so that the user can take a proper action based on his application logic.

LoRa Events
-----------

LoRa stack can emmit the events described in the following table:

+------------------------------+------------+---------------------------------------------------------+
| LoRa Event                   | Valid Mode | Brief description                                       |
+==============================+============+=========================================================+
| lora._event.EVENT_RX_DONE    | RAW, WAN   | occurs when the LoRa stack receives something           |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_RX_FAIL    | RAW        | occurs if the receiving operation failed                |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_RX_TIMEOUT | RAW        | occurs if the receiving operation timed-out             |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_TX_DONE    | RAW, WAN   | when the requested transmission operation is fullfilled |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_TX_CONFIRM | WAN        | when a LoRa-WAN confirmation is received                |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_TX_FAILED  | RAW, WAN   | requested transmission operation failed                 |
+------------------------------+------------+---------------------------------------------------------+
| lora._event.EVENT_TX_TIMEOUT | RAW, WAN   | requested tx operation timedout (deadline)              |
+------------------------------+------------+---------------------------------------------------------+

lora._event.EVENT_RX_DONE
^^^^^^^^^^^^^^^^^^^^^^^^^

This event occurs when the lora stack received something from the air.

In LoRa-RAW mode

It is generated if the device is set to receive something from the air and successfully received new data. or the device is set in continuout receiving mode and new data received and present to be delivered to the user.

In LoRa-WAN mode

It is generated automatically if a Class-A cycle occurs and a scheduled data from the network side is successfully received by the device.

It is also generated when the device is working in Class-C and the device receives a message from the network.

In LoRa-WAN, only data dedicated for this device identity (DevEUI, AppEUI) will be received and the user will be notified by the received data by this event.

lora._event.EVENT_RX_FAIL
^^^^^^^^^^^^^^^^^^^^^^^^^

This event is only generated in case of the LoRa-RAW mode when the user request to receive something and the receiving operation failed to be fulfilled.

lora._event.EVENT_RX_TIMEOUT
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This event is only generated in case of the LoRa-RAW mode when the user request to receive something within a certain timeout and the receiving operation instantiated successfully, but nothing is received within the user given timeout.

lora._event.EVENT_TX_DONE
^^^^^^^^^^^^^^^^^^^^^^^^^

This event occurs when the user request to sent data on the air and the device managed successfully to fullfil the sending operation.

In case of the LoRa-WAN, it depends on whether the user wants a confirmation from the network upon receiving this message or not.

If a confirmation is requested, this event will not occur at all, and the user should be waiting for either lora._event.EVENT_TX_CONFIRM or lora._event.EVENT_TX_FAILED

If a confirmation is not requested, this event will be generated upon an an operation fulfillment from the device perspective without waiting a network confirmation on the requested transmission data.

lora._event.EVENT_TX_CONFIRM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This event is only generated in case of the LoRa-WAN mode when the user request to send data with a network confirmation. If the device manages to send the data and received a network confirmation upon this data, this event will be generated.

lora._event.EVENT_TX_FAILED
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This event occurs in the following cases:

In LoRa-RAW: If the user requested to send a data and the device failed to fullfil the transmission operation.

In LoRa-WAN: It can occur in two distinct situations:

If the user requested to send a data to the network and the device failed to fullfil the transmission operation from the device side. If the user wants a reception confirmation from the network side and the confirmation is not received.

lora._event.EVENT_TX_TIMEOUT
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This event is generated if the device failed to fullfill the transmission operation within the user provided timeout(deadline) time.

LoRa Callback Generic Interface
-------------------------------

To set a callback routine to the LoRa Stack, the following generic interface shall be used at the micropython level:

.. code-block:: python

   lora.callback(
       handler = 
       [, trigger = ]
       [, port = ]
   )

The parameters description is as follows:

handler This is the real micropython function to be called when a LoRa event occurs. The full handler description is in the following typical handler:

.. code-block:: python

   def lora_generic_callback(context):
     # the handler receives a single context dict. 'event' is always present,
     # the remaining keys depend on the event: 'data', 'RSSI' and 'SNR' on a
     # receive (plus 'port', 'DR' and 'dl_frame_counter' in lora-wan), and
     # 'msg_id' on a lora-wan tx outcome.
     event = context.get('event')
   
     # --- lora raw case
     if lora.mode() == lora._mode.RAW:
   
         if event == lora._event.EVENT_RX_DONE:
             # context['data'] is a byte array holding the received data
             print('received data: {}'.format(context.get('data')))
             pass
         elif event == lora._event.EVENT_RX_FAIL:
             pass
         elif event == lora._event.EVENT_RX_TIMEOUT:
             pass
         elif event == lora._event.EVENT_TX_DONE:
             pass
         elif event == lora._event.EVENT_TX_CONFIRM:
             # unexpected event in lora-raw
             pass
         elif event == lora._event.EVENT_TX_FAILED:
             pass
         elif event == lora._event.EVENT_TX_TIMEOUT:
             pass
         else:
             print('error: unknown error')
   
     # --- lora wan case
     elif lora.mode() == lora._mode.WAN:
   
         # the message id provided in the tx request
         msg_id = context.get('msg_id')
   
         if event == lora._event.EVENT_RX_DONE:
             # context['data'] is a byte array holding the received data
             print('received data: {}'.format(context.get('data')))
             pass
         elif event == lora._event.EVENT_RX_FAIL:
             # unexpected event in lora-wan
             pass
         elif event == lora._event.EVENT_RX_TIMEOUT:
             # unexpected event in lora-wan
             pass
         elif event == lora._event.EVENT_TX_DONE:
             print("message ID {} has transmitted successfully".format(msg_id))
             pass
         elif event == lora._event.EVENT_TX_CONFIRM:
             print("message ID {} has been confirmed".format(msg_id))
             pass
         elif event == lora._event.EVENT_TX_FAILED:
             print("message ID {} is not transmitted".format(msg_id))
             pass
         elif event == lora._event.EVENT_TX_TIMEOUT:
             print("message ID {} tx timeout".format(msg_id))
             pass
         else:
             print('error: unknown error')
   
     else:
         print('error: unknown lora mode')
         pass
   
     pass

trigger It is an optional argument to set a callback routine dedicated for a certain lora stack event. It shall be equal to one or more of the expected mode lora events. If more than one event shall be used they shall be combined using an OR operation (ex: lora._event.EVENT_TX_TIMEOUT | lora._event.EVENT_RX_TIMEOUT)

port It is an optional argument applicable only for LoRa-WAN mode. It gives the user more flexibility in callbacks to be able to receive lora-stack events for dedicated LoRa-WAN port in a specialized callback routine.

Example LoRa-RAW
----------------

.. code-block:: python

   # initialization
   import lora
   lora.mode(lora._mode.RAW)
   
   # generic method for conatant value retrieval
   def get_class_const_name(__class, __const):
       for k,v in __class.__dict__.items():
           if v == __const:
               return k
       return 'unknown'
   
   # any event callback
   def lora_raw_callback(context):
       print('lora-raw event: {} with data: {}'.format(
           get_class_const_name(lora._event, context['event']), context))
       pass
   
   def lora_raw_callback_rx_done(context):
       event = context.get('event')
       if event != lora._event.EVENT_RX_DONE:
           print("unexpected event in this callback")
           return
       print('lora-raw received data: {}'.format(context.get('data')))
       pass
   
   def lora_raw_callback_timeout(context):
       event = context.get('event')
       if event != lora._event.EVENT_RX_TIMEOUT and \
               event != lora._event.EVENT_TX_TIMEOUT:
           print("unexpected event in this callback")
           return
       print('lora-raw timeout event: {}'.format(
           get_class_const_name(lora._event, event)))
       pass
   
   # registering the callbacks
   lora.callback( handler = lora_raw_callback )    # for all event
   
   lora.callback(      # specialized callback for EVENT_RX_DONE event
       handler = lora_raw_callback_rx_done,
       trigger = lora._event.EVENT_RX_DONE )
   
   # to specialize a callback for two different events, the events shall be
   # combined using OR operation
   lora.callback(      # specialized callback for EVENT_TX_TIMEOUT event
       handler = lora_raw_callback_timeout,
       trigger = lora._event.EVENT_TX_TIMEOUT |
                 lora._event.EVENT_RX_TIMEOUT
       )
   
   # at this point the incoming lora events will be like this:
   #   [ event ]                       [ triggered callback ]
   #   ---------                       ----------------------
   #   lora._event.EVENT_RX_DONE       lora_raw_callback_rx_done()
   #   lora._event.EVENT_RX_FAIL       lora_raw_callback()
   #   lora._event.EVENT_RX_TIMEOUT    lora_raw_callback_timeout()
   #   lora._event.EVENT_TX_DONE       lora_raw_callback()
   #   lora._event.EVENT_TX_CONFIRM    -- unexpected --
   #   lora._event.EVENT_TX_FAILED     lora_raw_callback()
   #   lora._event.EVENT_TX_TIMEOUT    lora_raw_callback_timeout

Example LoRa-WAN
----------------

.. code-block:: python

   # basic initialization
   import lora                 # init lora stack
   lora.mode(lora._mode.WAN)   # switch to lora-wan
   # make sure that the device is commissioned before completing the following
   lora.stats()
   
   # defining some example callbacks
   
   def get_class_const_name(__class, __const):
       for k,v in __class.__dict__.items():
           if v == __const:
               return k
       return 'unknown'
   
   def lora_wan_callback(context):
       event = context.get('event')
       print('lora-wan event: {} with data: {}'.format(
           get_class_const_name(lora._event, event), context))
       pass
   
   def lora_wan_callback_port_1_any(context):
       event = context.get('event')
       print('lora-wan port 1 event: {} with data: {}'.format(
           get_class_const_name(lora._event, event), context))
       pass
   
   def lora_wan_callback_port_1_tx_confirm(context):
       event = context.get('event')
       if event != lora._event.EVENT_TX_CONFIRM:
           print("unexpected event in this callback")
           return
       print('lora-wan port 1 tx confirm on message id : {}'.format(
           context.get('msg_id')))
       pass
   
   def lora_wan_callback_port_2_timeout(context):
       event = context.get('event')
       if event != lora._event.EVENT_RX_TIMEOUT and \
               event != lora._event.EVENT_TX_TIMEOUT:
           print("unexpected event in this callback")
           return
       print('lora-wan port 2 timeout event: {}'.format(
           get_class_const_name(lora._event, event)))
       pass
   
   # respective ports shall be opened before registering their specialized callbacks
   lora.port_open(1)
   lora.port_open(2)
   
   # registering callbacks
   lora.callback(  # for all event on all port
       handler = lora_wan_callback
       )
   
   lora.callback(  # for port 1 events only
       handler = lora_wan_callback_port_1_any,
       port = 1
       )
   
   lora.callback(  # for port 1 event lora._event.EVENT_TX_CONFIRM only
       handler = lora_wan_callback_port_1_any,
       port = 1,
       trigger = lora._event.EVENT_TX_CONFIRM
       )
   
   lora.callback(  # for port 2 events lora._event.EVENT_RX_TIMEOUT and
                   # event != lora._event.EVENT_TX_TIMEOUT only
       handler = lora_wan_callback_port_2_timeout,
       port = 1,
       trigger = lora._event.EVENT_RX_TIMEOUT |
                 lora._event.EVENT_TX_TIMEOUT
       )

Remarks
-------

If only a specialized callback is defined and registered, the user will be able to listen to this specialized event only and not the other at all.

In LoRa-WAN mode; Registering a callback for a didicated port which is opened yet, will be ignored. The call back registeration shall be done again after opening the port.
