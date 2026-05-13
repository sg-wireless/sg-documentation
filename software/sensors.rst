Sensors
=======

.. _ctrl-add-sensor:

Add a Sensor to Ctrl
--------------------

In this section, we will explain how to add an SG Wireless sensor to Ctrl.

1. Navigate to **Sensors** and click on ``Add Sensor``.

   .. image:: /_static/images/ctrl/sensors/sensor_page.png
      :width: 80%
      :alt: Sensors page in Ctrl

2. Enter the Sensor's MAC address. You can enter just the last 3 segments.

3. Choose the device you want the sensor to be initially linked to.

4. Enter an appropriate ``Sensor Name`` and ``Sensor Description`` to better
   identify it.

   .. image:: /_static/images/ctrl/sensors/add_sensor_popup.png
      :width: 80%
      :alt: Add sensor popup

5. The new sensor will appear on the ``Sensors`` page and in the linked device's
   ``Sensor`` tab.

   .. image:: /_static/images/ctrl/sensors/sensor_page_2.png
      :width: 80%
      :alt: Sensor added to list

Each sensor can be linked to multiple devices, allowing for versatile
integration. The data collected by the sensor will flow through the connected
devices and ultimately reach Ctrl.

On your Dashboard, there should now be a Temperature and Humidity widget. These
will update when the device sends sensor data to Ctrl. Multiple sensors will show
up in a different colour with their name in the legend.

.. _ctrl-update-sensor:

Update Sensor Information
-------------------------

1. Navigate to the ``Sensors`` page.

2. Click on the "..." (ellipsis) icon next to the sensor you wish to edit.

3. Select the ``Edit`` option from the dropdown menu.

   .. image:: /_static/images/ctrl/sensors/sensor_page_update.png
      :width: 80%
      :alt: Edit sensor option

4. Update the ``Name`` or ``Description`` fields as needed.

5. Save your changes by clicking ``Edit Sensor``.

   .. image:: /_static/images/ctrl/sensors/update_sensor_popup.png
      :width: 80%
      :alt: Update sensor popup

.. _ctrl-remove-sensor:

Remove a Sensor from Ctrl
-------------------------

1. Navigate to the ``Sensors`` page.

2. Click on the "..." (ellipsis) icon next to the sensor you wish to remove.

3. Select the ``Remove Sensor`` option from the dropdown menu.

   .. image:: /_static/images/ctrl/sensors/sensors_page_remove.png
      :width: 80%
      :alt: Remove sensor option

4. Confirm by clicking ``Delete``.

5. Deleting will unlink sensors from any linked devices and remove the sensor from
   the platform.

   .. image:: /_static/images/ctrl/sensors/remove_prompt.png
      :width: 80%
      :alt: Confirm remove sensor

.. _ctrl-link-sensor:

Link Sensor to a Device
------------------------

This action is necessary to send data from sensors to Ctrl. The linked device
transmits the data readings with the sensor as the source.

1. Navigate to the ``Device`` page and select the device that you want to link to
   the sensor.

2. Go to the ``Sensors`` tab within the device page.

3. Click on ``Link Sensor``.

   .. image:: /_static/images/ctrl/sensors/device_sensor_page.png
      :width: 80%
      :alt: Device sensors tab

4. Choose the sensor you want to link from the list provided.

5. Click the ``Link Sensor`` button to confirm.

   .. image:: /_static/images/ctrl/sensors/link_sensor_prompt.png
      :width: 80%
      :alt: Link sensor prompt

6. Ctrl will send a message to the device, instructing it to listen for the
   sensor's MAC address and establish the link.

.. _ctrl-unlink-sensor:

Unlink Sensor from a Device
----------------------------

After unlinking, no data readings will be sent to Ctrl from the device for this
sensor.

1. Navigate to the ``Device`` page and select the device from which you want to
   unlink the sensor.

2. Go to the ``Sensors`` tab within the device page.

3. Click on the "..." (ellipsis) icon next to the sensor you wish to unlink.

4. Select the ``Unlink Sensor from Device`` option from the dropdown menu.

   .. image:: /_static/images/ctrl/sensors/device_sensor_page_unlink.png
      :width: 80%
      :alt: Unlink sensor option

5. Confirm the action by clicking on the ``Unlink`` button in the confirmation
   dialog.

   .. image:: /_static/images/ctrl/sensors/unlink_prompt.png
      :width: 80%
      :alt: Confirm unlink sensor
