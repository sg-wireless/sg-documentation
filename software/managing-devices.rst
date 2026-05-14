Devices
###########

In general, Ctrl communicates to your device through MQTT. Depending on the type
of device, add your devices to Ctrl through one of the following steps:

- **Adding F1 devices:**
  :doc:`Zero-Touch Provisioning </getting-started/ztp>` or
  :doc:`Manual Provisioning </getting-started/manual-provisioning>`
- **Adding other devices:** Use the
  :doc:`Manual Provisioning </getting-started/manual-provisioning>` flow

Updating Device Firmware
*****************************

Over-the-air update via Ctrl
=============================
Note: this feature is only available for F1 Starter Kits

Once connected to Ctrl, it will detects the current firmware version of the Starter Kit.
Information regarding the firmware version can be found in the following sections: 

- Header part of each device details
- 'Firmware Update' section of the device's Deployment Management tab

User can perform Over-The-Air (OTA) firmware update by clicking the 'Update now' button on the 'Firmware Update' section of the device's Deployment Management tab. This button will be activated **if** the following conditions are fulfilled:

- The current firmware version is older than the latest version
- Device status is online

If user wishes to deploy other firmware versions or if the device is currently offline, user can perform the update  though USB connection using our Visual Studio Code CtrlR plugin.  

Wired update via CtrlR
=============================



Updating File Control 
*****************************

Over-the-air update via Ctrl
=============================

Wired update via CtrlR
=============================

Next Steps
----------

- :doc:`Dashboards & Widgets <visualize-data>`
- :doc:`Link sensors to your device <sensors>`
