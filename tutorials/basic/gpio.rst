GPIO
====

The F1 smart module has more than twenty spare General Purpose Input-Output (GPIO)
pins available for you to use with your own sensors and actuators. Below outlines
the basics for configuring and controlling the GPIO as output and input pins.

Output
------

Controlling the GPIO pins of the module is straightforward. The example below shows
how to generate a 1 Hz clock signal at Pin 9.

.. code-block:: python

   from machine import Pin
   import time

   Pin9 = Pin(Pin.P9, mode=Pin.OUT)

   while True:
       print("high")
       Pin9.value(1)
       time.sleep(1)
       print("low")
       Pin9.value(0)
       time.sleep(1)

Input
-----

Sometimes, it is useful to know the state of a pin. For example, you could use the
SBOOT button on the Starter Kit to toggle the LED.

.. code-block:: python

   from machine import Pin
   import rgbled

   button = Pin(Pin.P12, mode=Pin.IN)  # SBOOT button on Starter Kit

   while True:
       if button() == 1:
           rgbled.color(0x00003300)  # turn LED to Green
       else:
           rgbled.color(0x00000000)  # turn off LED
