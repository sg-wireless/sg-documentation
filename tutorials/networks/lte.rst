LTE Examples
============

The following tutorial demonstrates the use of the LTE CAT-M1 and NB-IoT
functionality on cellular enabled SG modules.

.. note::

   For F1 Starter Kit purchasers, a pre-registered SIM card is provided in the
   F1 Starter Kit. In case you would like to use your own SIM card, please make
   sure that your SIM card is registered and activated with your carrier.

This page discusses the usage of the LTE modem in more detail:

- `General remarks`_
- `SG SIM card`_
- `LTE Connectivity check`_
- `LTE Mode check and LTE Mode switching`_
- `Custom APN setting`_

General remarks
---------------

To check the current modem firmware, you can use the following commands:

.. code-block:: python

   from LTE import LTE
   lte = LTE()
   print(lte.send_at_cmd('ATI1'))

To check whether the LTE connection has been established, you can use the
following command:

.. code-block:: python

   from LTE import LTE
   lte = LTE()
   print(lte.isconnected())  # if True is returned, LTE connection is established

.. note::

   The first time, it can take a long while to attach to the network.

SG SIM card
-----------

For F1 Starter Kit purchasers, a pre-registered and pre-setup SIM card is placed
inside the SIM card slot on the F1 Starter Kit.

There is pre-stored value in each SIM card for use. The SIM card is intended to
support nominal development/evaluation and operating under nominal IoT application
data usage. In case you need to implement data-heavy applications or would like to
have batch deployment of LTE-enabled devices, please contact the SG sales
representative for enquiry and special discussions.

LTE Connectivity check
----------------------

To check whether the LTE connection has been established, you can use the
following command:

.. code-block:: python

   from LTE import LTE
   lte = LTE()
   print(lte.isconnected())  # if True is returned, LTE connection is established

LTE Mode check and LTE Mode switching
--------------------------------------

For the F1 Starter Kit pre-registered and pre-setup SIM card, the LTE mode is set
up for users based on the purchasing order.

In case you are using your own SIM card and would like to check the current LTE
mode (CAT-M1 or NB-IoT) and switch your LTE mode, you can use the following
commands:

.. code-block:: python

   from LTE import LTE
   lte = LTE()
   lte_mode = lte.mode()  # Return current mode
   if lte_mode == LTE.CATM1:
       print('Modem is in CAT-M1 mode!')
   if lte_mode == LTE.NBIOT:
       print('Modem is in NB-IoT mode!')

   # The below will automatically reset the modem
   lte.mode(LTE.CATM1)  # switch to CAT-M1
   lte.mode(LTE.NBIOT)  # switch to NB-IoT

.. note::

   If you are using your own SIM card and would like to change LTE mode, please
   check carefully with your network service provider whether the LTE mode you
   would like to change to is supported or not.

Custom APN setting
------------------

In case you are using your own SIM card with a different service provider, the APN
(Access Point Name) should be changed and set correctly.

Below you will find the command for setting a custom APN:

.. code-block:: python

   from LTE import LTE
   import time
   lte = LTE()
   lte.attach(apn='iot.1nce.net')  # use 'iot.1nce.net' for SG SIM card,
                                    # change to your ISP's APN if using your own SIM
   while not lte.isattached():
       time.sleep(1)
   lte.connect()
   while not lte.isconnected():
       time.sleep(1)
