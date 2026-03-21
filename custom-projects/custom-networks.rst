Setting up Custom Networks
==========================

If you are using a third-party SIM card or need to connect to a specific LTE
network, this guide covers how to configure the F1 Starter Kit's cellular
connectivity.

Ctrl connection status
-----------------------

The F1 Starter Kit indicates its Ctrl connection status through the onboard RGB
LED:

- **Pulsing Blue** — Connected to Ctrl
- **Pulsing Red** — Not connected to Ctrl (network issue or no SIM)
- **Pulsing Green** — Firmware update in progress

Configure for CAT-M1 or NB-IoT
--------------------------------

The F1 Starter Kit supports both CAT-M1 and NB-IoT modes. By default it uses
CAT-M1. To switch modes, use the REPL terminal:

.. code-block:: python

   import LTE

   # Check current mode
   LTE.mode()

   # Set to CAT-M1
   LTE.mode(LTE.CATM1)

   # Set to NB-IoT
   LTE.mode(LTE.NBIOT)

After changing the mode, reboot the device for the setting to take effect.

Customize APN
--------------

If your SIM card requires a specific APN (Access Point Name), you can configure
it using the following code:

.. code-block:: python

   import LTE

   # Attach with a custom APN
   lte = LTE.lte()
   lte.attach(apn='your.apn.here')

Replace ``'your.apn.here'`` with the APN provided by your network operator.

.. note::

   If you are using the SG Wireless SIM card that comes with the F1 Starter Kit,
   the APN is pre-configured and no changes are needed.
