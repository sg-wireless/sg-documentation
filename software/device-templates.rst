Device Templates
=================

Scaling IoT projects is great! Until you realize that it means there'll be hundreds and thousands of devices that you have to configure. By hand.

A Device Template solves this problem: you set up one template that tells a device how to collect and display its data, then apply to all.

You can expect:

- Consistent data handling - All devices using the template store and display data identically
- Unified dashboards - Shared dashboard layouts and widgets
- Bulk management - Update the template to change all associated devices
- Scalability - Essential for managing multiple devices


See how each component comes together to set up your own Device Template:

- :ref:`Device Fields <dt-fields>`
- :ref:`Dashboard Layout <dt-dashboard>`
- :ref:`Associated Devices <dt-devices>`
- :ref:`Software releases <dt-releases>`
- :ref:`Automation <dt-automation>`


.. _dt-fields:

Fields
------------------

Uplink data received from your device is stored in Ctrl's 'Device Fields' - consider them as individual buckets that store different types of data. For example:

- A TEMPERATURE field stores temperature readings from the temperature sensor connected to your F1 Starter Kit
- A HUMIDITY field stores humidity measurements from the humidity sensor

The device field also stores downlink values sent from Ctrl to your device. For example:

- A SET_TEMPERATURE field stores the temperature value adjustment done through your Ctrl dashboard to your device. 

Note that each field can be used for both uplink and downlink data.

Below are the elements of fields:

- **Field name:** User-friendly name to identify the fields
- **Key:** Used to identify the field when exchanging data over MQTT. Only uppercase letters, numbers, and underscores are accepted
- **PIN number:** Connects Ctrl to the device for data sharing. It is non-editable.
- **Data type:** Defines the data type of field data. It is non-editable.
- **Unit:** Identifies the quantification unit of the field data.

There are two types of fields in Ctrl:

- Standard Device Field: Stores direct sensor readings as they come from your device, such as:
-- Numbers (temperature: 23.5°C)
-- Text (status: "online")
-- Boolean (door_open: true/false)
-- Location (GPS coordinates: 22.123,144.123)
Calculated Device Field: Stores derived values created from manipulation of direct sensor readings, such as ...
Offset operations: Add or subtract a constant (convert Celsius to Fahrenheit)
Factor operations: Multiply or divide by a constant (convert voltage to percentage)



.. _dt-dashboard:

Device Dashboard
------------------

All devices using the same template share identical dashboard configurations. This includes:

- **Dashboard layout:** Configure types, positions, and sizes of the widgets on each device dashboard. This dashboard is located on each device details.
- **Widget data sources:** Configure data souce fields of each widget. 

Details regarding the data widget settings can be found on Dashboard & Widgets section

.. _mp-add:

Add Project
-----------

To set up new projects, click on "Add project" and follow the prompts. These can
always be changed later in "Settings".

.. image:: /_static/images/ctrl/managing-projects/Ctrl-Create-New-Project.png
   :width: 80%
   :alt: Create new project in Ctrl

.. _mp-switch:

Switch Project
--------------

Switch between different projects simply by selecting it. The checkmark indicates
the selected project.

.. image:: /_static/images/ctrl/managing-projects/Ctrl-Switch-Project.png
   :width: 80%
   :alt: Switch between projects

.. _mp-edit:

Edit Project
------------

Update your project settings through the following steps:

1. On the target project, go to the Home tab.
2. Click the "Settings" button on the top right corner.
3. Make necessary changes.
4. Click "Confirm" to apply the changes.

.. image:: /_static/images/ctrl/managing-projects/image5.png
   :width: 80%
   :alt: Edit project settings

.. _mp-delete:

Delete Project
--------------

To delete a project, click on "...", then "Delete project". You'll be asked to
confirm this action by inputting your project name.

Upon project deletion, all related information will be deleted. **This action
cannot be undone.**

.. image:: /_static/images/ctrl/managing-projects/image6.png
   :width: 80%
   :alt: Delete project
