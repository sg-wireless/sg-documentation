Programming the Basics
======================

Now that the F1 Starter Kit is connected to the Ctrl Cloud Platform, this
tutorial covers how to program basic I/O on the F1 Starter Kit.

Light up the Onboard RGB LED
------------------------------

.. image:: /_static/images/custom-projects/programming/StarterKit-V1-RGBLED.png
   :width: 80%
   :alt: F1 Starter Kit RGB LED location

The F1 Starter Kit has an onboard, fully addressable RGB LED. You can set
different colours and brightness levels.

1. Open the CtrlR REPL terminal and type the following commands to experiment
   with the RGB LED:

   .. code-block:: python

      # Test RGB LED heartbeat
      rgbled.heartbeat(True)

   The RGB LED should now be pulsing.

   .. code-block:: python

      # Stop heartbeat and set a solid colour (R, G, B)
      rgbled.heartbeat(False)
      rgbled.color(0xff0000)   # Red
      rgbled.color(0x00ff00)   # Green
      rgbled.color(0x0000ff)   # Blue

Creating a project in CtrlR
-----------------------------

1. In a known destination on your computer, create a new project folder called
   **RGB-Blink**.

   .. image:: /_static/images/custom-projects/programming/qsg-img28-300x85.png
      :width: 80%
      :alt: Create RGB-Blink folder

2. Launch VS Code and open the **RGB-Blink** project folder you created.

   .. image:: /_static/images/custom-projects/programming/qsg-img29-300x215.png
      :width: 60%
      :alt: Open folder in VS Code

   .. image:: /_static/images/custom-projects/programming/qsg-img30-300x221.png
      :width: 60%
      :alt: Select RGB-Blink folder

3. Create a new file called ``main.py`` and add the following code:

   .. image:: /_static/images/custom-projects/programming/qsg-img31-300x120.png
      :width: 80%
      :alt: Create main.py file

   .. code-block:: python

      import time

      colours = [0xff0000, 0x00ff00, 0x0000ff]  # Red, Green, Blue

      while True:
          for colour in colours:
              rgbled.color(colour)
              time.sleep(1)

Uploading code to your F1 Starter Kit
---------------------------------------

You can test code on the F1 Starter Kit by choosing one of two options in
CtrlR:

**Run file on device**

.. image:: /_static/images/custom-projects/programming/qsg-img32-300x279.png
   :width: 80%
   :alt: Run file on device button

This option sends the script to the F1 Starter Kit and runs it immediately. The
script is **not** stored on the device and will not persist after a reboot. This
is useful for testing.

.. image:: /_static/images/custom-projects/programming/qsg-img33-300x62.png
   :width: 80%
   :alt: Running file on device

**Upload to device**

.. image:: /_static/images/custom-projects/programming/qsg-img34-300x109.png
   :width: 80%
   :alt: Upload to device button

This option uploads the script to the F1 Starter Kit's file system. The script
will persist and run on boot. Use this when your code is ready for deployment.
