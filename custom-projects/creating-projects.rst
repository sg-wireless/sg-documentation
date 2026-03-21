Creating Custom Projects
========================

The VS CtrlR Plugin enables the F1 Starter Kit to work with third-party sensors
to create custom projects on the Ctrl Cloud Platform.

Creating a data upload project in CtrlR
----------------------------------------

1. In a known destination on your computer, create a new project folder called
   **Ctrl_signals**.

   .. image:: /_static/images/custom-projects/creating/qsg-img18-300x113.png
      :width: 80%
      :alt: Create Ctrl_signals folder

2. Launch VS Code and open the **Ctrl_signals** project folder you created.

   .. image:: /_static/images/custom-projects/creating/qsg-img19-300x215.png
      :width: 60%
      :alt: Open folder in VS Code

   .. image:: /_static/images/custom-projects/creating/qsg-img20-300x221.png
      :width: 60%
      :alt: Select Ctrl_signals folder

   .. image:: /_static/images/custom-projects/creating/qsg-img21-300x122.png
      :width: 80%
      :alt: Project opened in VS Code

3. Modify the built-in python file **main.py** by adding the code below.

   The ``main.py`` script runs directly after ``boot.py`` and should contain the
   main code to run on the F1 Starter Kit. The modification will program the F1
   Starter Kit for data upload.

   .. image:: /_static/images/custom-projects/creating/qsg-img22-296x300.png
      :width: 60%
      :alt: Edit main.py in VS Code

   .. code-block:: python

      # Import what is necessary to create a thread
      import time
      import math

      # Send data continuously to Ctrl
      while True:
          for i in range(0, 20):
              ctrl.send_signal(1, math.sin(i / 10 * math.pi))  # use signal #1
              print('sent signal {}'.format(i))
              time.sleep(10)

4. To test the code, use **File > Save** or :kbd:`Ctrl+S` on your keyboard to
   save your edit to ``main.py``, and press the Reset button on the F1 Starter
   Kit to reboot it.

   ``main.py`` will persist and run on the F1 Starter Kit when it is booted up.
   To stop the script, click onto the CtrlR terminal and press :kbd:`Ctrl+C` on
   your keyboard.

Visualizing data on Ctrl
-------------------------

1. Back in your Ctrl account, navigate to **Devices** and select your connected
   F1 Starter Kit.

2. Navigate to **Signals** to see the last signal received by the F1 Starter Kit.
   Click on the signal to display historical messages.

   .. image:: /_static/images/custom-projects/creating/Starter-kit-Ctrl-device-signals-1024x431.png
      :width: 100%
      :alt: Ctrl device signals

   .. image:: /_static/images/custom-projects/creating/Starter-kit-Ctrl-device-signals-history-1024x431.png
      :width: 100%
      :alt: Ctrl device signals history
