Networks
##############

For each project, you can save multiple LTE and Wi-Fi profiles for use across
various devices through the Networks tab. This eliminates the need to repeatedly
enter settings such as Wi-Fi passwords or LTE APNs during device provisioning.

Furthermore, you can implement these profiles remotely and manage your device's
network settings remotely through Ctrl.

- For each project: manage your :ref:`network profiles <net-profiles>`
- For each device: manage your :ref:`device network settings <net-device>`

.. note::

   Network settings through Ctrl are only enabled for SG devices at the moment.

.. _net-profiles:

Manage Network Profiles
==========================

A *network profile* is a set of network configurations that can be implemented to
multiple devices in the project.

.. note::

   If your device is provisioned via ZTP, an LTE profile will be automatically
   added for you, with name "1NCE".

Create new network profile
------------------------------

1. In the side menu, click "Networks", then "Add network profile".

   .. image:: /_static/images/ctrl/managing-networks/Ctrl_Add-network-1024x607.png
      :width: 80%
      :alt: Add network profile

2. Choose "Wi-Fi" or "LTE", and enter the required network credentials.

   .. image:: /_static/images/ctrl/managing-networks/Ctrl_Add-network_WiFi-and-LTE-1024x607.png
      :width: 80%
      :alt: Wi-Fi and LTE network profile options

3. Click "Add network profile" once it's done. Your new network profile will be
   available under the corresponding tab.

Edit network profile
------------------------------

1. In the side menu, click "Networks".

2. Click the "..." icon on the right-most column of the target network, then
   "Edit".

   .. image:: /_static/images/ctrl/managing-networks/WhatsApp-Image-2025-09-24-at-6.17.38-PM-300x203.jpeg
      :width: 80%
      :alt: Edit network profile option

3. Make changes to the network credentials as needed. Note that **SSID** is **not
   editable for Wi-Fi** profiles while **name** is **not editable for LTE**
   profiles.

   .. image:: /_static/images/ctrl/managing-networks/Screenshot-from-2025-09-24-17-50-30-300x203.png
      :width: 80%
      :alt: Edit network credentials

4. Click "Save" to apply changes.

.. note::

   In order to implement the changes on your devices, you need to deploy the
   changes through each device's network tab.

Delete network profile
------------------------------

A network can only be deleted if it is not being used by an existing device.

1. In the side menu, click "Networks", then choose the target network.

2. Click the "..." icon on the right-most column of the target profile, then
   "Delete".

   .. image:: /_static/images/ctrl/managing-networks/WhatsApp-Image-2025-09-24-at-6.19.05-PM-300x203.jpeg
      :width: 80%
      :alt: Delete network profile

.. _net-device:



Manage Device Network Settings
====================================

The F1 Starter Kit supports multiple network types that can be adjusted according
to your need. You can *enable or disable* particular network types AND adjust the
*network type priority* of your Starter Kit through Ctrl.

Accessing the device network settings
----------------------------------------

1. In the side menu, click "Devices". Then, click on the target device.
2. Click on the device's "Networks" tab.

Activate or deactivate a network
----------------------------------------

1. Click on the arrow icon on the target network.

   .. image:: /_static/images/ctrl/managing-networks/Screenshot-2025-09-19-at-5.44.15-PM-300x171.png
      :width: 80%
      :alt: Device network settings

2. Press the toggle on the top right corner.

   .. image:: /_static/images/ctrl/managing-networks/Screenshot-2025-09-19-at-5.45.30-PM-300x171.png
      :width: 80%
      :alt: Toggle network activation

3. If you are activating the network, choose the preferred network profile before
   saving the update.

4. The activated networks are displayed under the "Activated networks" section,
   while the non-active networks are displayed under "Other networks" section.


Ctrl LoRaWAN integration
----------------------------------------

LoRa connectivity activation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since Ctrl is integrated with SG Wireless TTN LoRaWAN, it will automatically register and connect your devices upon LoRa activation through Ctrl. 

1. First, ensure you have a LoRaWAN gateway within accessible range of your device. Identify the region setting of the gateway and make sure that it's also connected to the internet.
2. Once you activate the LoRa profile toggle, you will need to select the LoRaWAN region that matches with your LoRaWAN gateway region. Upon clicking the ``save`` button, Ctrl will automatically generate TTN device activation information, such as JoinEUI, DevEUI, AppKey, and NwkKey. This information is currently not visible by user in Ctrl. But it can be accessed by calling ``ctr.print_config()`` Ctrl Client endpoint through any IDE of your choice.

.. image:: /_static/images/ctrl/managing-networks/ctrl_network_lora_settings.png
      :width: 80%
      :alt: Enable lora network

3. This device activation information will be passed to the device when you :ref:`deploy the network profile <net-deploy>`. 

If you wish to use your own LoRaWAN setup, you can use the programming resources on this page to configure the LoRa connection: :ref:`Network Interfaces <network-interfaces>`

LoRa Connectivity Limitations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. **Downlink data is not real-time.** As a LoRa Class A device, F1 Starter Kit always initiates communication from the device side and operates fully asynchronously, so downlink messages are not delivered instantly.
2. LoRa’s long-range, low-power design limits the size of data packets, so that these capabilities are not supported over LoRa:
      a. Linking / unlinking sensors
      b. OTA firmware update
      c. OTA file content update
      d. OTA network settings update


Rejoining SGW LoRaWAN TTN Network
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Supposedly, you only need to register your device to SG Wireless TTN network once during activation. However if your device looses connectivity from activities like firmware reflashing, the device needs to rejoin the network. While the device activation credentials remain unchanged, you might encounter errors like 'DevNonce is too small'. In this case, kindly contact us at info@sgwireless.com for support. We will help you to reset the DevNonce. 


Adjust the device network priority
----------------------------------------

In the list of *activated networks*, click and hold the three lines on the left
of the target network, and drag it to its desired priority.

.. image:: /_static/images/ctrl/managing-networks/Screenshot-2025-09-19-at-5.46.39-PM-300x171.png
   :width: 80%
   :alt: Adjust network priority

.. note::

   This priority will only be used during the first-time connection. Automatic
   network switching is not supported after connection has been established.

.. _net-deploy:

Deploy the network setting
----------------------------------------

To implement the updated settings on your device, deploy it using one of the
following approaches:

- **If your device is currently online:** press the "Deploy profiles" button to
  deploy the update over the air.

  .. image:: /_static/images/ctrl/managing-networks/image5-300x201.jpeg
     :width: 80%
     :alt: Deploy profiles over the air

- **If your device is currently offline:**

  1. Generate an activation key by clicking the button under the "..." icon of the
     device's network tab.

     .. image:: /_static/images/ctrl/managing-networks/image7-300x203.png
        :width: 80%
        :alt: Generate activation key

  2. Copy the resulting activation code.

  3. :ref:`Deploy the code through the CtrlR Visual Studio plugin <mp-deploy>`.


