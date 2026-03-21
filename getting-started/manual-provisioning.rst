Manual Provisioning for F1
==========================

Slightly trickier, greater flexibility! These steps allow you to provision your
F1 Starter Kit according to your preferences.

- :ref:`Configure your network profile <mp-add-network>`
- :ref:`Add your F1 Starter Kit <mp-add-f1>`
- :ref:`Configure your F1 Starter Kit Network <mp-configure-f1>`
- :ref:`Deploy to your F1 Starter Kit <mp-deploy>`

Prerequisites
-------------

Make sure that you have set up the following software beforehand:

- **CP210x USB to UART Bridge Virtual COM Port driver** --
  `link <https://www.silabs.com/software-and-tools/usb-to-uart-bridge-vcp-drivers?tab=overview>`_
  (only required for Windows and Mac users)
- **Microsoft Visual Studio Code with CtrlR plugin** --
  :doc:`link <setup-computer>`

Last but not least, sign in to Ctrl `here <https://app.sgwireless.com/>`_ --
create an account or log in, if you already have one.

Provisioning Steps
------------------

.. _mp-add-network:

Part 1 -- Configure your network profile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once configured, you can apply these profiles to multiple devices in your
project.

1. In the side menu, click "Networks", then "Add network profile".

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.23.02-PM-scaled.png
      :width: 80%
      :alt: Add network profile in Ctrl

2. Choose "Wi-Fi" or "LTE", and enter the required network credentials.

3. Click "Add network profile" -- you'll see the added network in "Networks".

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.22.07-PM-scaled.png
      :width: 80%
      :alt: Network profile added

.. _mp-add-f1:

Part 2 -- Add your F1 Starter Kit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. In the side menu, click "Devices", then "Add device".

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.27.29-PM-scaled.png
      :width: 80%
      :alt: Add device in Ctrl

2. Choose "Manual provisioning".

3. Choose "SG F1 Starter Kit" as your device model. Enter a name and description.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.30.39-PM-scaled.png
      :width: 80%
      :alt: Select device model

4. Select a Device Template -- as this is your first device, you'll land on "New
   device template" by default and you'll be given a system-generated template
   identifier. (Device Templates will be important as you scale -- more on this
   later!)

5. Click "Add device" to complete the device creation flow.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.32.10-PM-scaled.png
      :width: 80%
      :alt: Device template and add device

.. _mp-configure-f1:

Part 3 -- Configure your F1 Starter Kit Network
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Click "View device details" to view your newly-created device page.

2. Click on the "Networks" tab and choose the network type that you want to
   activate.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.44.15-PM-scaled.png
      :width: 80%
      :alt: Device networks tab

3. Toggle the target connection to activate it, then select the target network
   profile.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.45.30-PM-scaled.png
      :width: 80%
      :alt: Activate network connection

4. If you're enabling more than one network type, hold and drag the network type
   to adjust the priority.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.46.39-PM-scaled.png
      :width: 80%
      :alt: Adjust network priority

.. _mp-deploy:

Part 4 -- Deploy to your F1 Starter Kit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. In the device's "Deployment Management" tab, click "Generate activation key".
   You'll need this key in a bit.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.47.53-PM-scaled.png
      :width: 80%
      :alt: Generate activation key

2. Connect the F1 evaluation board to a power source and toggle SW200 from OFF to
   ON (LEDs will light up).

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-18-at-3.45.12-PM-e1758188262398.png
      :width: 80%
      :alt: Power on F1 evaluation board

3. Open the CtrlR plugin in Visual Studio Code and click "Connect device" on the
   detected device.

   .. image:: /_static/images/getting-started/manual-provisioning/image-1-300x255.png
      :width: 50%
      :alt: Connect device in CtrlR

4. Invoke a terminal to access the REPL interface by clicking the "Create
   terminal" icon.

   .. image:: /_static/images/getting-started/manual-provisioning/image-3-300x122.png
      :width: 50%
      :alt: Create terminal in CtrlR

5. Remember the key you generated earlier? Copy it from your Ctrl "Deployment
   Manager".

6. Paste it into the terminal, and press Enter.

   .. image:: /_static/images/getting-started/manual-provisioning/Screenshot-2025-09-19-at-5.49.02-PM-scaled.png
      :width: 80%
      :alt: Paste activation key

7. Monitor the RGB LED on the F1 evaluation board:

   - **Blinking blue** = registering
   - **Blinking green** = cellular connected
   - **Solid green** = provisioning complete

   .. image:: /_static/images/getting-started/manual-provisioning/F1-Starter-Kit-RGB-LED-On-1-e1758182212474.png
      :width: 60%
      :alt: F1 Starter Kit RGB LED blinking blue

   .. image:: /_static/images/getting-started/manual-provisioning/F1-Starter-Kit-Green-LED-On.png-1-e1758182462770.jpg
      :width: 60%
      :alt: F1 Starter Kit green LED on

8. When provisioning is complete, you're now ready to
   :doc:`link your first CAP/T Sensor <first-sensor-data>` to start collecting
   data.
