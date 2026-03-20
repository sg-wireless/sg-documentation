Your First F1 Code
==================

.. TODO:: Migrate content from https://docs.sgwireless.com/getting-started/your-first-f1-code/

This guide shows you how to write and run your first MicroPython program on the
F1 Smart Module.

Hello F1
--------

Connect to your device via the REPL and type::

   print("Hello F1!")

You should see ``Hello F1!`` printed on the terminal.

Running a Script
----------------

Create a file called ``main.py`` on the device::

   # main.py - runs automatically on boot
   import time
   import rgbled

   rgbled.heartbeat(False)

   while True:
       rgbled.color(0x00FF0000)  # Red
       time.sleep(0.5)
       rgbled.color(0x0000FF00)  # Green
       time.sleep(0.5)
       rgbled.color(0x000000FF)  # Blue
       time.sleep(0.5)

Upload it using ``mpremote``::

   mpremote cp main.py :main.py
   mpremote reset
