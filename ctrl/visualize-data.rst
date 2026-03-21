Visualize Data
==============

By default, two line charts have been created for you. These show data usage for
the last hour and the past 24 hours. In this section, we will explain how to see
the data coming from your device on Ctrl.

.. note::

   We're assuming that you have already connected your device to Ctrl. In case
   you haven't, check how to :doc:`add your device </getting-started/ztp>`.
   After you're done with that, you can proceed to the next example.

.. image:: /_static/images/ctrl/visualize-data/ctrl-visualize-dashboard.png
   :width: 80%
   :alt: Ctrl data visualization dashboard

Step 1: Set up a CtrlR Project
------------------------------

Create a project in CtrlR called ``CtrlR_signals``, and add the following code to
``main.py``. This Python application will send data every 10 seconds to Ctrl.

.. code-block:: python

   import time
   import math

   # Send data continuously to Ctrl
   while True:
       for i in range(0, 20):
           ctrl.send_signal(1, math.sin(i / 10 * math.pi))
           print('sent signal {}'.format(i))
           time.sleep(10)

Press the **Upload** button to upload the code into your device.

Step 2: Monitor a signal from your device
-----------------------------------------

1. Go to the Ctrl device page and select your device.
2. Then go to the ``Signals`` tab and view signals received.
3. Select a signal number to view message history.

Done!
-----

Now you've learned how to view your data on the device.
