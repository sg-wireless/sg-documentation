LoRa Examples
=============

The following tutorials demonstrate the use of the LoRa functionality. LoRa can
work in 2 different modes: LoRa-MAC (which we also call Raw-LoRa) and LoRaWAN mode.

When using LoRa, always connect the appropriate LoRa antenna to your device. See
the figure below for the correct antenna placement.

.. figure:: /_static/images/tutorials/networks/lora-antenna-placement.png
   :width: 80%
   :alt: LoRa antenna placement on F1 Starter Kit

   F1 Starter Kit

.. note::

   A standalone pluggable LoRa antenna in u.FL connector type is included in
   the F1 Starter Kit.

- **LoRaWAN mode** implements the full LoRaWAN stack for a class A device. It supports
  both OTAA and ABP connection methods, as well as advanced features like adding and
  removing custom channels to support "special" frequency plans like those used in
  New Zealand. There are two basic ways of accessing the LoRaWAN network:

  - :ref:`lorawan-otaa`
  - :ref:`lorawan-abp`

.. note::

   When using LoRaWAN, first register with one of the networks.

- **LoRa-MAC mode** basically accesses the radio directly and packets are sent using
  the LoRa modulation on the selected frequency without any headers, addressing
  information or encryption. Only a CRC is added at the tail of the packet and this
  is removed before the received frame is passed on to the application. This mode can
  be used to build any higher level protocol that can benefit from the long range
  features of the LoRa modulation.

  - :ref:`lora-raw`


.. _lorawan-otaa:

LoRaWAN with OTAA
-----------------

OTAA stands for Over The Air Authentication. With this method the device sends a
Join request to the LoRaWAN Gateway using the ``app_eui`` and ``app_key`` provided
in your LoRaWAN application (like TheThingsNetwork, Chirpstack etc.). If the keys
are correct the Gateway will reply with a join accept message and from that point
on the device is able to send and receive packets to/from the Gateway. If the keys
are incorrect no response will be received and the ``has_joined()`` method will always
return ``False``.

The example below attempts to get any data received after sending the frame. Keep
in mind that the Gateway might not be sending any data back, therefore we make the
socket non-blocking before attempting to receive, in order to prevent getting stuck
waiting for a packet that will never arrive.

If everything works correctly, the device will print ``Joined`` to the terminal, and
you should see a data packet arrive in your LoRaWAN application containing
``0x01 0x02 0x03``.

.. note::

   If the ``dev_eui`` is not provided, the LoRa MAC of the device will be used in
   its place. You will need to change the ``dev_eui`` in your LoRaWAN application
   to the LoRa MAC address of the device. You can get the LoRa MAC using:

   .. code-block:: python

      from network import LoRa
      import binascii
      print(binascii.hexlify(LoRa().mac()).upper())

.. note::

   **US915 / AU915 regions:** Most LoRaWAN gateways are configured to listen to
   8 channels only, while the region supports up to 64 uplink channels. In order to
   receive packets, please confirm the frequency plan of your gateway with the channels
   configured on your device. By default, our devices will transmit on all 64 channels,
   meaning you might receive packets intermittently. The most common configuration is
   ``FSB2``, or channels 8-15. Uncomment the respective section in the example below
   to select these uplink channels.

**For LoRaWAN v1.0.x:**

.. code-block:: python

   # ---------------------------------------------------------------------------- #
   # Copyright (c) 2023-2024 SG Wireless - All Rights Reserved
   #
   # Permission is hereby granted, free of charge, to any person obtaining a copy
   # of this software and associated documentation files(the "Software"), to deal
   # in the Software without restriction, including without limitation the rights
   # to use,  copy,  modify,  merge, publish, distribute, sublicense, and/or sell
   # copies  of  the  Software,  and  to  permit  persons to whom the Software is
   # furnished to do so, subject to the following conditions:
   #
   # The above copyright notice and this permission notice shall be included in
   # all copies or substantial portions of the Software.
   #
   # THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
   # IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY
   # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
   # AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
   # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   # OUT OF OR IN  CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
   # THE SOFTWARE.
   #
   # Desc      Implements simple lora OTAA activation.
   # ---------------------------------------------------------------------------- #

   # required imports
   import logs         # for system logging management
   import lora         # for lora-stack
   import ubinascii    # for hex/string conversions
   import time         # for time manipulation

   # disable fw logs
   logs.filter_subsystem('lora', False)

   # switch to lora-wan if not
   lora.mode(lora._mode.WAN)

   # configure the stack on region EU-868
   lora.wan_params(region=lora._region.REGION_EU868, lwclass=lora._class.CLASS_A)

   # start end-device commissioning
   lora.commission(
       type    = lora._commission.OTAA,
       version = lora._version.VERSION_1_0_X,
       DevEUI  = ubinascii.unhexlify('0000000000000000'),
       JoinEUI = ubinascii.unhexlify('0000000000000000'),
       AppKey  = ubinascii.unhexlify('00000000000000000000000000000000')
       )

   # start join procedure
   lora.join()

   # wait until join
   while lora.is_joined() == False:
       print("wait joining ...")
       time.sleep(2)
       pass
   print("-- JOINED --")
   lora.stats()

   # open a working port
   lora.port_open(1)

   # attach required callback
   def get_event_str(event):
       if event == lora._event.EVENT_TX_CONFIRM:
           return 'EVENT_TX_CONFIRM'
       elif event == lora._event.EVENT_TX_DONE:
           return 'EVENT_TX_DONE'
       elif event == lora._event.EVENT_TX_TIMEOUT:
           return 'EVENT_TX_TIMEOUT'
       elif event == lora._event.EVENT_TX_FAILED:
           return 'EVENT_TX_FAILED'
       elif event == lora._event.EVENT_RX_DONE:
           return 'EVENT_RX_DONE'
       elif event == lora._event.EVENT_RX_TIMEOUT:
           return 'EVENT_RX_TIMEOUT'
       elif event == lora._event.EVENT_RX_FAIL:
           return 'EVENT_RX_FAIL'
       else:
           return 'UNKNOWN'

   def port_any_cb(event, evt_data):
       print('lora event [ {} ] --> data: {}'
           .format(get_event_str(event), evt_data))

   lora.callback(handler=port_any_cb)

   # start duty cycle
   lora.duty_set(10000)
   lora.enable_rx_listening()
   lora.duty_start()

   # schedule sending some test messages
   i = 1000
   while i < 1010:
       lora.send('tx-message-with-id-{}'.format(i), port=1, confirm=True, id = i)
       i = i + 1

   # --- end of file ------------------------------------------------------------ #

**For LoRaWAN v1.1.x:**

.. code-block:: python

   # ---------------------------------------------------------------------------- #
   # Copyright (c) 2023-2024 SG Wireless - All Rights Reserved
   #
   # Permission is hereby granted, free of charge, to any person obtaining a copy
   # of this software and associated documentation files(the "Software"), to deal
   # in the Software without restriction, including without limitation the rights
   # to use,  copy,  modify,  merge, publish, distribute, sublicense, and/or sell
   # copies  of  the  Software,  and  to  permit  persons to whom the Software is
   # furnished to do so, subject to the following conditions:
   #
   # The above copyright notice and this permission notice shall be included in
   # all copies or substantial portions of the Software.
   #
   # THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
   # IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY
   # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
   # AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
   # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   # OUT OF OR IN  CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
   # THE SOFTWARE.
   #
   # Desc      Implements simple lora OTAA activation.
   # ---------------------------------------------------------------------------- #

   # required imports
   import logs         # for system logging management
   import lora         # for lora-stack
   import ubinascii    # for hex/string conversions
   import time         # for time manipulation

   # disable fw logs
   logs.filter_subsystem('lora', False)

   # switch to lora-wan if not
   lora.mode(lora._mode.WAN)

   # configure the stack on region EU-868
   lora.wan_params(region=lora._region.REGION_EU868, lwclass=lora._class.CLASS_A)

   # start end-device commissioning
   # for DevEUI, AppKey and NwkKey, please replace zeros with your specific
   # device information
   lora.commission(
       type    = lora._commission.OTAA,
       version = lora._version.VERSION_1_1_X,
       DevEUI  = ubinascii.unhexlify('0000000000000000'),
       JoinEUI = ubinascii.unhexlify('0000000000000000'),
       AppKey  = ubinascii.unhexlify('00000000000000000000000000000000'),
       NwkKey  = ubinascii.unhexlify('00000000000000000000000000000000')
       )

   # start join procedure
   lora.join()

   # wait until join
   while lora.is_joined() == False:
       print("wait joining ...")
       time.sleep(2)
       pass
   print("-- JOINED --")
   lora.stats()

   # open a working port
   lora.port_open(1)

   # attach required callback
   def get_event_str(event):
       if event == lora._event.EVENT_TX_CONFIRM:
           return 'EVENT_TX_CONFIRM'
       elif event == lora._event.EVENT_TX_DONE:
           return 'EVENT_TX_DONE'
       elif event == lora._event.EVENT_TX_TIMEOUT:
           return 'EVENT_TX_TIMEOUT'
       elif event == lora._event.EVENT_TX_FAILED:
           return 'EVENT_TX_FAILED'
       elif event == lora._event.EVENT_RX_DONE:
           return 'EVENT_RX_DONE'
       elif event == lora._event.EVENT_RX_TIMEOUT:
           return 'EVENT_RX_TIMEOUT'
       elif event == lora._event.EVENT_RX_FAIL:
           return 'EVENT_RX_FAIL'
       else:
           return 'UNKNOWN'

   def port_any_cb(event, evt_data):
       print('lora event [ {} ] --> data: {}'
           .format(get_event_str(event), evt_data))

   lora.callback(handler=port_any_cb)

   # start duty cycle
   lora.duty_set(10000)
   lora.enable_rx_listening()
   lora.duty_start()

   # schedule sending some test messages
   i = 1000
   while i < 1010:
       lora.send('tx-message-with-id-{}'.format(i), port=1, confirm=True, id = i)
       i = i + 1

   # --- end of file ------------------------------------------------------------ #


.. _lorawan-abp:

LoRaWAN with ABP
----------------

ABP stands for Authentication By Personalization. It means that the encryption keys
are configured manually on the device and can start sending frames to the Gateway
without needing a 'handshake' procedure to exchange the keys (such as the one
performed during an OTAA join procedure).

The example below attempts to get any data received after sending the frame. Keep
in mind that the Gateway might not be sending any data back, therefore we make the
socket non-blocking before attempting to receive, in order to prevent getting stuck
waiting for a packet that will never arrive.

.. note::

   **US915 / AU915 regions:** Most LoRaWAN gateways are configured to listen to
   8 channels only, while the region supports up to 64 uplink channels. In order to
   receive packets, please confirm the frequency plan of your gateway with the channels
   configured on your device. By default, our devices will transmit on all 64 channels,
   meaning you might receive packets intermittently. The most common configuration is
   ``FSB2``, or channels 8-15. Uncomment the respective section in the example below
   to select these uplink channels.

**For LoRaWAN v1.0.x:**

.. code-block:: python

   # ---------------------------------------------------------------------------- #
   # Copyright (c) 2023-2024 SG Wireless - All Rights Reserved
   #
   # Permission is hereby granted, free of charge, to any person obtaining a copy
   # of this software and associated documentation files(the "Software"), to deal
   # in the Software without restriction, including without limitation the rights
   # to use,  copy,  modify,  merge, publish, distribute, sublicense, and/or sell
   # copies  of  the  Software,  and  to  permit  persons to whom the Software is
   # furnished to do so, subject to the following conditions:
   #
   # The above copyright notice and this permission notice shall be included in
   # all copies or substantial portions of the Software.
   #
   # THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
   # IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY
   # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
   # AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
   # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   # OUT OF OR IN  CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
   # THE SOFTWARE.
   #
   # Desc      Implements simple lora ABP activation.
   # ---------------------------------------------------------------------------- #

   # required imports
   import logs         # for system logging management
   import lora         # for lora-stack
   import ubinascii    # for hex/string conversions
   import time         # for time manipulation

   # disable fw logs
   logs.filter_subsystem('lora', False)

   # switch to lora-wan if not
   lora.mode(lora._mode.WAN)

   # configure the stack on region EU-868
   lora.wan_params(region=lora._region.REGION_EU868, lwclass=lora._class.CLASS_A)

   # start end-device commissioning
   lora.commission(
       type    = lora._commission.ABP,
       version = lora._version.VERSION_1_0_X,
       DevAddr = 0x00000000,
       DevEUI  = ubinascii.unhexlify('0000000000000000'),
       AppSKey = ubinascii.unhexlify('00000000000000000000000000000000'),
       NwkSKey = ubinascii.unhexlify('00000000000000000000000000000000')
       )

   # start join procedure
   lora.join()

   # wait until join
   while lora.is_joined() == False:
       print("wait joining ...")
       time.sleep(2)
       pass
   print("-- JOINED --")
   lora.stats()

   # open a working port
   lora.port_open(1)

   # attach required callback
   def get_event_str(event):
       if event == lora._event.EVENT_TX_CONFIRM:
           return 'EVENT_TX_CONFIRM'
       elif event == lora._event.EVENT_TX_DONE:
           return 'EVENT_TX_DONE'
       elif event == lora._event.EVENT_TX_TIMEOUT:
           return 'EVENT_TX_TIMEOUT'
       elif event == lora._event.EVENT_TX_FAILED:
           return 'EVENT_TX_FAILED'
       elif event == lora._event.EVENT_RX_DONE:
           return 'EVENT_RX_DONE'
       elif event == lora._event.EVENT_RX_TIMEOUT:
           return 'EVENT_RX_TIMEOUT'
       elif event == lora._event.EVENT_RX_FAIL:
           return 'EVENT_RX_FAIL'
       else:
           return 'UNKNOWN'

   def port_any_cb(event, evt_data):
       print('lora event [ {} ] --> data: {}'
           .format(get_event_str(event), evt_data))

   lora.callback(handler=port_any_cb)

   # start duty cycle
   lora.duty_set(10000)
   lora.enable_rx_listening()
   lora.duty_start()

   # schedule sending some test messages
   i = 1000
   while i < 1010:
       lora.send('tx-message-with-id-{}'.format(i), port=1, confirm=True, id = i)
       i = i + 1

   # --- end of file ------------------------------------------------------------ #

**For LoRaWAN v1.1.x:**

.. code-block:: python

   # ---------------------------------------------------------------------------- #
   # Copyright (c) 2023-2024 SG Wireless - All Rights Reserved
   #
   # Permission is hereby granted, free of charge, to any person obtaining a copy
   # of this software and associated documentation files(the "Software"), to deal
   # in the Software without restriction, including without limitation the rights
   # to use,  copy,  modify,  merge, publish, distribute, sublicense, and/or sell
   # copies  of  the  Software,  and  to  permit  persons to whom the Software is
   # furnished to do so, subject to the following conditions:
   #
   # The above copyright notice and this permission notice shall be included in
   # all copies or substantial portions of the Software.
   #
   # THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
   # IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY
   # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
   # AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
   # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   # OUT OF OR IN  CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
   # THE SOFTWARE.
   #
   # Desc      Implements simple lora ABP activation.
   # ---------------------------------------------------------------------------- #

   # required imports
   import logs         # for system logging management
   import lora         # for lora-stack
   import ubinascii    # for hex/string conversions
   import time         # for time manipulation

   # disable fw logs
   logs.filter_subsystem('lora', False)

   # switch to lora-wan if not
   lora.mode(lora._mode.WAN)

   # configure the stack on region EU-868
   lora.wan_params(region=lora._region.REGION_EU868, lwclass=lora._class.CLASS_A)

   # start end-device commissioning
   lora.commission(
       type    = lora._commission.ABP,
       version = lora._version.VERSION_1_1_X,
       DevAddr = 0x00000000,
       DevEUI  = ubinascii.unhexlify('0000000000000000'),
       AppSKey = ubinascii.unhexlify('00000000000000000000000000000000'),
       NwkSKey = ubinascii.unhexlify('00000000000000000000000000000000')
       )

   # start join procedure
   lora.join()

   # wait until join
   while lora.is_joined() == False:
       print("wait joining ...")
       time.sleep(2)
       pass
   print("-- JOINED --")
   lora.stats()

   # open a working port
   lora.port_open(1)

   # attach required callback
   def get_event_str(event):
       if event == lora._event.EVENT_TX_CONFIRM:
           return 'EVENT_TX_CONFIRM'
       elif event == lora._event.EVENT_TX_DONE:
           return 'EVENT_TX_DONE'
       elif event == lora._event.EVENT_TX_TIMEOUT:
           return 'EVENT_TX_TIMEOUT'
       elif event == lora._event.EVENT_TX_FAILED:
           return 'EVENT_TX_FAILED'
       elif event == lora._event.EVENT_RX_DONE:
           return 'EVENT_RX_DONE'
       elif event == lora._event.EVENT_RX_TIMEOUT:
           return 'EVENT_RX_TIMEOUT'
       elif event == lora._event.EVENT_RX_FAIL:
           return 'EVENT_RX_FAIL'
       else:
           return 'UNKNOWN'

   def port_any_cb(event, evt_data):
       print('lora event [ {} ] --> data: {}'
           .format(get_event_str(event), evt_data))

   lora.callback(handler=port_any_cb)

   # start duty cycle
   lora.duty_set(10000)
   lora.enable_rx_listening()
   lora.duty_start()

   # schedule sending some test messages
   i = 1000
   while i < 1010:
       lora.send('tx-message-with-id-{}'.format(i), port=1, confirm=True, id = i)
       i = i + 1

   # --- end of file ------------------------------------------------------------ #


.. _lora-raw:

LoRa-MAC (Raw LoRa)
--------------------

Basic LoRa connection example, sending and receiving data. In LoRa-MAC mode the
LoRaWAN layer is bypassed and the radio is used directly. The data sent is not
formatted or encrypted in any way, and no addressing information is added to the
frame.

For the example below, you will need two F1 starter kits. Run the code below on
the two F1 starter kits, you will see the word 'Hello from LoRa chat' being
received on both sides.

.. code-block:: python

   # ---------------------------------------------------------------------------- #
   # Copyright (c) 2023-2024 SG Wireless - All Rights Reserved
   #
   # Permission is hereby granted, free of charge, to any person obtaining a copy
   # of this software and associated documentation files(the "Software"), to deal
   # in the Software without restriction, including without limitation the rights
   # to use,  copy,  modify,  merge, publish, distribute, sublicense, and/or sell
   # copies  of  the  Software,  and  to  permit  persons to whom the Software is
   # furnished to do so, subject to the following conditions:
   #
   # The above copyright notice and this permission notice shall be included in
   # all copies or substantial portions of the Software.
   #
   # THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS OR
   # IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE  WARRANTIES  OF  MERCHANTABILITY
   # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
   # AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER
   # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   # OUT OF OR IN  CONNECTION WITH  THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
   # THE SOFTWARE.
   #
   # Desc      Implements simple lora chat demo for the lora-raw mode
   #           should be run on two different devices.
   # ---------------------------------------------------------------------------- #

   # disable logs
   import logs
   logs.filter_subsystem('lora', False)

   # import the responsible module
   import lora

   # switch to lora raw if not there
   if lora.mode() != lora._mode.RAW:
       lora.mode(lora._mode.RAW)

   # define the callback
   def lora_callback(event, bytes):
       if event == lora._event.EVENT_RX_DONE:
           print(bytes)
       pass
   lora.callback(handler=lora_callback)

   # start continuous reception
   lora.recv_cont_start()

   # start chatting by sending
   lora.send('Hello from LoRa chat')

   # --- end of file ------------------------------------------------------------ #
