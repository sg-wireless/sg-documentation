Zero-Touch Provisioning (ZTP)
=============================

.. TODO:: Migrate content from https://docs.sgwireless.com/getting-started/zero-touch-provisioning-ztp/

Zero-Touch Provisioning allows your F1 Starter Kit to automatically register
itself with the Ctrl. Cloud Platform on first boot.

Prerequisites
-------------

* F1 Starter Kit or F1 OEM Module with Starter Kit carrier board
* USB-C cable
* Active internet connection (WiFi or LTE)

Steps
-----

1. Connect your F1 Starter Kit to your computer via USB-C.
2. Open a serial terminal (PuTTY, screen, picocom, or the VS Code CtrlR Plugin).
3. The device will automatically begin the ZTP process on first boot.
4. Follow the on-screen prompts to complete provisioning.

.. note::

   If ZTP does not start automatically, you can trigger it manually::

      import ctrl
      ctrl.ztp(True)
