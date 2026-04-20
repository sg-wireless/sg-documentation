Introducing VS CtrlR
====================

For custom IoT application development, the F1 Starter Kit can be configured on
the Microsoft Visual Studio Code IDE platform with the CtrlR Plugin.

You will need the latest version of Visual Studio Code to proceed, which can be
downloaded and installed `here <https://code.visualstudio.com/>`_.

Installing VS CtrlR Plugin
---------------------------

1. Launch Visual Studio Code and navigate to Extensions. Search for "CtrlR" and
   click Install.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img6-300x191.png
      :width: 80%
      :alt: Install CtrlR plugin in VS Code

2. Press the Reload button to complete the CtrlR Plugin installation.

Configuring F1 Starter Kit for CtrlR Plugin on your PC
------------------------------------------------------

1. Connect your F1 Starter Kit to your PC and turn it on (SW200 switch from OFF
   to ON).

2. If your PC doesn't have the Silabs CP2102N Virtual COM port driver installed
   previously, an unknown device will be shown in your PC's Device Manager.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img8-300x93.png
      :width: 80%
      :alt: Unknown device in Device Manager

3. Download and install the
   `Virtual COM Port driver <https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers>`_.

4. Upon installation of the driver, a new COM port should show up in your PC's
   Device Manager.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img9-300x45.png
      :width: 80%
      :alt: COM port in Device Manager

5. Go back to Visual Studio Code and ensure that the CtrlR Plugin has been
   correctly installed.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img10-300x281.png
      :width: 60%
      :alt: CtrlR plugin installed in VS Code

   .. image:: /_static/images/getting-started/setup-computer/qsg-img11-300x160.png
      :width: 60%
      :alt: CtrlR plugin device view

6. Normally, your device will be auto-detected as shown above. If this does not
   work, click **[List all devices]** in the DEVICES window.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img12-300x114.png
      :width: 60%
      :alt: List all devices button

7. If everything is correct, device details will pop up when your mouse pointer
   is placed on the device:

   .. image:: /_static/images/getting-started/setup-computer/qsg-img13-300x234.png
      :width: 60%
      :alt: Device details tooltip

8. Use the "Connect" button to connect VS Code with the device.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img14-300x80.png
      :width: 60%
      :alt: Connect button

9. Next, you will be able to invoke a terminal, launch file explorer, or
   disconnect from the device with the 3 buttons.

   .. image:: /_static/images/getting-started/setup-computer/qsg-img15-300x167.png
      :width: 60%
      :alt: Terminal, file explorer, and disconnect buttons

10. The terminal will let you interact with the device's MicroPython REPL.
    Invoking a simple command ``os.uname()`` will print the firmware version of
    your device.

    .. image:: /_static/images/getting-started/setup-computer/qsg-img16-300x58.png
       :width: 80%
       :alt: MicroPython REPL with os.uname()

11. The file explorer provides a drag-and-drop interface to view, add, and edit
    the files within your device.

    .. image:: /_static/images/getting-started/setup-computer/qsg-img17-300x230.png
       :width: 60%
       :alt: CtrlR file explorer

Next Steps
----------

Program the Starter Kit to send your data to the Ctrl platform. See
:doc:`first-sensor-data` or :doc:`first-f1-code`.
