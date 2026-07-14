LoRa Certification API Documentation
====================================

Contents
--------

-  Introduction
-  LoRaWAN Modes
-  LoRaWAN Modes Operation Types
-  End-Device Configurations
-  LoRa Certification Mode Example

--------------

Introduction
~~~~~~~~~~~~

The purpose of this documentation is to present how to operate the system to
work with the LoRa-Certification Test Tool (LCTT) and how to prepare the device
for ATH (Authorization House).

The LoRa subsystem is equipped with certification test mode handling to adhere
to the TCL (Test Control Layer) and perform the requested commands.

LoRaWAN Modes
~~~~~~~~~~~~~

-  **Application Mode**: The normal application mode and this mode is enabled
   by default for all end- devices that don't have LCT mode enabled.

-  **LoRa Certification Mode**: In this mode, the system is ready to listen to
   the TCL (Test Control Layer) commands. The device will not respond to the
   user requests to send or reecive data or any other functionality that may
   affect the certification mode operation.

LoRaWAN Modes Operation Types:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  **Only Application mode Operation type**: End-devices that have LoRaWAN with
   this operation type will operate only in normal application mode and can not
   be switched to Certification mode at all.

-  **Switched Mode Operation Type**: The end-device can switch between the two
   modes of operations.

      This type of operation is usefull during development phase.

-  **Certification Mode Once Operation Type**: The end-device will be set to
   LoRa Certification mode only once just after the firmware is newly flashed
   and once it exits from this mode, it will be set to normal application mode
   and can not be returned back to certification mode again unless the NVM
   memory in the flash is erased.

      This is usefull for devices that are planned to go to the ATH for
      certification. After the certification tool issued the close comand of
      port 224, the device will switch automatically to the normal mode and
      will no longer operate in the certification mode.

End-Device Configurations
~~~~~~~~~~~~~~~~~~~~~~~~~

To open the configuration page, issue the following command:
``./fw_builder.sh --board SGW3501-F1-StarterKit config``, then select the
following options in order ``*** SDK Components`` -> ``Network Components`` ->
``LoRa Stack Configurations``, then the following page will eventually show up:
|LoRa Mode Operation Type Selection|

The description of each configuration is as follows:

-  ``CONFIG_LORA_LCT_MODE`` "LoRa Certification test mode"

   The global mode that opts to operate LoRa certification port or not. If
   disabled, the device will operate in
   ``Only Application mode Operation type``

-  ``CONFIG_LORA_LCT_CONTROL_API`` "Enable LoRa Certification mode control API"

   If this config is selected, the end-device will operate in the
   ``Switched Mode Operation Type``. Hence a new LoRa API will be activated to
   support the switching between the two modes. The following example shows
   those APIs and their usages

   .. code:: python

      >>> import lora
      >>> lora.certification_mode() # will get the current efffective mode
      # output example
      # --------------
      # LCT mode is off
      # False

      >>> lora.certification_mode(True)     # activate the certification mode
      >>> lora.certification_mode(False)    # deactivate the certification mode

-  ``CONFIG_LORA_LCT_INIT_DEVICE_INTO_CERTIFICATION_MODE_ONCE``

   It enables the ``Certification Mode Once Operation Type``. The device will
   be set into the certification mode only once in a newly flashed end-device
   or after erasing the flash then flashing the firmware.

-  ``CONFIG_LORA_LCT_OPERATE_AFTER_RESET``

   It ensures lora stack operation after system reset to continue automatically
   working with the corresponding TCL.

   We have two distinct cases after system reset based on the reset cause:

   -  Reset caused by TCL command DutResetReq:

      After initialising the LoRa stack, it will do automatically a join-req
      and the system will continue working with the TCL.

   -  Reset caused by the manual reset or normal system power-up:

      After initialising the LoRa stack the LoRa subsystem will reside in an
      idle state, in which the user can freely opt to change the commissioning
      parameters. And the uer shall issue join-request manually using
      ``lora.join()``, then the LoRa stack will start its active operation.

::

   # example of switched mode operation type:

   # Step(1): set the configs as follows:
   # ------------------------------------
   #   - CONFIG_LORA_LCT_MODE                                      y
   #   - CONFIG_LORA_LCT_CONTROL_API                               y
   #   - CONFIG_LORA_LCT_INIT_DEVICE_INTO_CERTIFICATION_MODE_ONCE  n
   #   - CONFIG_LORA_LCT_OPERATE_AFTER_RESET                       y

   # Step(2): build and flash the Firmware:

   # Step(3): runing with the LCTT tool
   # ----------------------------------
   #   - power-up the board and open a termnal and connect to the board RPEL
   #   - prepare the required test campaign in the LCTT, and start its running
   #   - in the RPEL terminal;
   #     import lora
   #     lora.certification_mode(True) \
   #       if   not lora.certification_mode() \
   #       else lora.join()

.. |LoRa Mode Operation Type Selection| image:: images/lora-mode-sel.png
