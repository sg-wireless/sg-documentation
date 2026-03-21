Your First Sensor Data
======================

The final step to your set-up is also the most important -- getting data.

Let's start with the CAP/T Sensor which comes with temperature and humidity
sensors.

- :ref:`Add your Sensor <fsd-add-sensor>`
- :ref:`Link your Sensor <fsd-link-sensor>`
- :ref:`Map Sensor data <fsd-map-data>`

.. note::

   - You can skip this step if you provisioned your device through ZTP.
   - This sensor configuration method is only applicable for CAP/T sensors at the
     moment. Other sensors or peripherals need to be configured directly on the
     device.

.. _fsd-add-sensor:

Add your CAP/T Sensor
---------------------

1. In the side menu, click "Sensors", then "Add sensor".

   .. image:: /_static/images/getting-started/first-sensor-data/image-300x181.png
      :width: 80%
      :alt: Add sensor in Ctrl

2. Enter the last 6 digits of the MAC address of your CAP/T Sensor, which can be
   found on the Sensor's battery lid. The first 6 digits have been automatically
   filled for your convenience.

   .. image:: /_static/images/getting-started/first-sensor-data/cap-t-batt-mac-300x274.png
      :width: 50%
      :alt: CAP/T sensor MAC address on battery lid

3. Name the Sensor and add a description as needed.

4. Click "Add sensor".

   .. image:: /_static/images/getting-started/first-sensor-data/image2-300x181.png
      :width: 80%
      :alt: Add sensor form

.. _fsd-link-sensor:

Link your CAP/T Sensor to your F1 Starter Kit
----------------------------------------------

One CAP/T Sensor can send data to more than one F1 Starter Kit, giving you the
flexibility to use the same set of data in multiple ways for different projects.

This is done by linking the Sensor to the required Kit(s), as follows:

1. Since we are attempting to update the sensor configuration remotely to the
   Starter Kit, ensure that your Starter Kit has a stable Internet connection.
   Otherwise, you can regenerate the configuration key and run it through your
   CtrlR Visual Studio Code plugin after completing the "Map your CAP/T Sensor
   data" steps.

2. Remove the transparent film from the CAP/T Sensor. Ensure that the sensor LED
   is blinking green.

   .. image:: /_static/images/getting-started/first-sensor-data/cap-t-batt-tab-300x233.png
      :width: 40%
      :alt: Remove battery tab from CAP/T sensor

   .. image:: /_static/images/getting-started/first-sensor-data/image2-269x300.jpeg
      :width: 40%
      :alt: CAP/T sensor LED blinking green

3. Initiate the device linkage through one of the two methods:

   **Through "Devices":**

   a. Find the target device on your device list, and go to the "Sensors" tab.

   b. Click "Link sensor" and select the target Sensor.

      .. image:: /_static/images/getting-started/first-sensor-data/image3-300x181.png
         :width: 80%
         :alt: Link sensor from Devices tab

   c. Select a sensor to be linked.

      .. image:: /_static/images/getting-started/first-sensor-data/Screenshot-from-2025-09-23-16-39-35-300x181.png
         :width: 80%
         :alt: Select sensor to link

   **Through "Projects":**

   a. Go to the "Sensors" tab, and find the target Sensor. Click the "..." button.

   b. Click "Link device", then select the target Kit.

      .. image:: /_static/images/getting-started/first-sensor-data/image1-300x181.jpeg
         :width: 80%
         :alt: Link device from Projects tab

   c. Select a device to be linked.

      .. image:: /_static/images/getting-started/first-sensor-data/Screenshot-from-2025-09-23-16-40-35-300x181.png
         :width: 80%
         :alt: Select device to link

.. _fsd-map-data:

Map your CAP/T Sensor data
---------------------------

Sensor data is stored in "Device Fields" -- consider them as individual buckets
that store different types of sensor data.

1. After you select a device or sensor to be linked, the field mapping options
   will be displayed.

   By default, a new Device Field is created for each type of telemetry data
   received from CAP/T sensors. You will see four Device Fields automatically
   created for the CAP/T Sensor:

   - Temperature
   - Humidity
   - Battery Level
   - RSSI

   .. image:: /_static/images/getting-started/first-sensor-data/Screenshot-from-2025-09-23-18-57-15-231x300.png
      :width: 50%
      :alt: Device field mapping

2. You can also disable the "Create new field" option to map the data to existing
   compatible Device Fields.

   .. image:: /_static/images/getting-started/first-sensor-data/image3-231x300.jpeg
      :width: 50%
      :alt: Map to existing device fields

3. Click "Link device" when you're done.

4. If your device is not currently connected to the internet,
   :ref:`deploy the sensor configuration <mp-deploy>` by regenerating the
   activation code and running it through your CtrlR Visual Studio Code plugin.

5. View the incoming data by checking the latest value columns on your device's
   "Fields" tab.

   .. image:: /_static/images/getting-started/first-sensor-data/Screenshot-from-2025-09-23-22-44-07-300x170.png
      :width: 80%
      :alt: Incoming sensor data on Fields tab

Next Steps
----------

You can continue your IoT journey by either configuring your dashboards or
:doc:`programming your F1 Starter Kit <first-f1-code>`.
