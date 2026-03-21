Zero-Touch Provisioning (ZTP)
=============================

Zero-Touch Provisioning (ZTP) automatically performs the following three tasks to
set up your Starter Kit seamlessly:

- Get your F1 Starter Kit online using the default LTE network.
- Add your F1 Starter Kit and CAP/T sensor to your Ctrl account for remote
  monitoring and management.
- Link your F1 Starter Kit and the CAP/T sensor to start viewing its data
  through your Ctrl page.

Regional Coverage
-----------------

Start by checking if you're in a region that supports ZTP as listed below:

.. list-table::
   :header-rows: 1
   :widths: 5 25 70

   * -
     - F1 Starter Kit Configuration
     - Regions with Coverage
   * - 1
     - NA Cat M1
     - Canada, USA, Puerto Rico
   * - 2
     - EU Cat M1
     - Austria, Belgium, Denmark, Estonia, Latvia, Ireland, Finland, Germany,
       Hungary, The Netherlands, Norway, Poland, Spain, Sweden, Switzerland, UK,
       France, Luxembourg, Romania
   * - 3
     - Global Cat M1
     - Argentina, Brazil, Taiwan, South Korea, Japan, Australia, New Zealand
   * - 4
     - Global NB-IoT
     - Bulgaria, Croatia, Czech Republic, Greece, Iceland, Italy, Portugal,
       Slovakia, China, Russia

.. note::

   Regions supporting Cat M1 and/or NB-IoT may change without notice. Check
   `here <https://www.1nce.com/en-ap/1nce-connect/our-coverage>`_ for the latest
   update.

You can continue with :doc:`Manual Provisioning <manual-provisioning>` if ZTP is
not supported in your region.

Provisioning Steps
------------------

1. Unpack the F1 Starter Kit and scan the QR code on the F1 evaluation board.
   You'll be directed to the Ctrl IoT Platform.

   .. image:: /_static/images/getting-started/ztp/Screenshot-2025-09-19-at-4.51.42-PM.png
      :width: 80%
      :alt: Scan QR code on F1 evaluation board

2. Input the email address to be associated with your Ctrl account. Your Starter
   Kit will be tied to this account. (No other Ctrl accounts can use the same
   Starter Kit until it is deleted from the account it is tied to.)

   .. image:: /_static/images/getting-started/ztp/Screenshot-2025-09-18-at-1.12.07-PM.png
      :width: 80%
      :alt: Enter email for Ctrl account

3. Select a Ctrl project & Device Template -- as this is your first device,
   you'll land on both "New Project" and "New device template" pages by default
   and you'll be given system-generated identifiers accordingly. Click "Next".
   (Device Templates will be important as you scale -- more on this later.)

   .. image:: /_static/images/getting-started/ztp/Screenshot-2025-09-18-at-1.13.01-PM.png
      :width: 80%
      :alt: Select project and device template

4. Connect the F1 evaluation board to a power source and toggle SW200 from OFF
   to ON (LEDs will light up).

   .. image:: /_static/images/getting-started/ztp/Screenshot-2025-09-18-at-3.45.12-PM-e1758188262398.png
      :width: 80%
      :alt: Power on F1 evaluation board

5. If you also purchased a CAP/T sensor, you can directly connect your sensor to
   your F1 during the provisioning flow. Remove the transparent battery cover
   from the sensor and press the button on the top corner. Notice that the sensor
   LED will be blinking green.

   .. image:: /_static/images/getting-started/ztp/image2-269x300.jpeg
      :width: 40%
      :alt: CAP/T sensor with LED blinking green

6. Monitor the provisioning status on your screen. You can also check the RGB LED
   on the F1 evaluation board:

   - **Blinking blue** = registering
   - **Blinking green** = cellular connected
   - **Solid green** = provisioning complete

   .. image:: /_static/images/getting-started/ztp/F1-Starter-Kit-RGB-LED-On-1-e1758182212474.png
      :width: 60%
      :alt: F1 Starter Kit RGB LED blinking blue

   .. image:: /_static/images/getting-started/ztp/F1-Starter-Kit-Green-LED-On.png-1-e1758182462770.jpg
      :width: 60%
      :alt: F1 Starter Kit green LED on

7. When provisioning is complete, click "Go to device details" on your Ctrl
   screen to see sensor data coming through.

   .. image:: /_static/images/getting-started/ztp/ZTP-Complete.png
      :width: 80%
      :alt: ZTP provisioning complete

   .. image:: /_static/images/getting-started/ztp/Screenshot-2025-09-22-at-12.28.43-PM.png
      :width: 80%
      :alt: Device details with sensor data

Next Steps
----------

From here on, Ctrl will be best used on a PC environment. You can continue your
IoT journey by either :doc:`programming your F1 Starter Kit <first-f1-code>` or
configuring your dashboards.
