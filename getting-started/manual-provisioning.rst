Manual Provisioning for F1
==========================

.. TODO:: Migrate content from https://docs.sgwireless.com/getting-started/manual-provisioning-f1/

If Zero-Touch Provisioning is not available, you can manually provision your F1
device using the ``ctrl.activate()`` command.

Steps
-----

1. Log in to the `Ctrl. Cloud Platform <https://app.sgwireless.com/>`_.
2. Navigate to **Devices → Add Device**.
3. Copy the activation string from the provisioning page.
4. On the device REPL, run::

      ctrl.activate('<paste-activation-string-here>')

5. The device will connect to Ctrl. and begin sending data.
