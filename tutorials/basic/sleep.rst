Sleep
=====

There are several methods to make your device sleep. First we cover the basic
sleep. Similar to ``delay()`` used in Arduino, sleep will yield your program until
the time is over. Important is that all microcontroller functions keep running.
Also the LoRa and LTE modems can be used directly (without re-attaching) after
regular sleep.

Basic sleep
-----------

.. code-block:: python

   import time

   time.sleep(1)          # sleep 1 second
   time.sleep_ms(10)      # sleep 10 milliseconds
   time.sleep_us(10)      # sleep 10 microseconds

Similar to ``yield()`` in other languages, in MicroPython we use:

.. code-block:: python

   import machine
   machine.idle()

Power saving
------------

To save power, we can also put the controller into sleep modes using the following
examples.

Light sleep
^^^^^^^^^^^

The ``machine.sleep()`` command will put the controller into a light sleep mode.
WiFi and BLE are switched off, but the main CPU and RAM are still running. The
LoRa and LTE modems are stopped as well and have to be re-initialized after
wakeup. The controller will continue running the code after waking up. GPIO states
are also conserved. Setting the second argument to ``True`` will restore the WiFi
and BLE after wakeup.

.. code-block:: python

   import machine
   import time
   print("this will be printed before: " + str(time.ticks_ms()))
   machine.sleep(1000 * 10)
   print("this will be printed after 10 seconds: " + str(time.ticks_ms()))

Deep sleep
^^^^^^^^^^

Deepsleep disables, next to the lightsleep, the main CPU and RAM. This leaves only
a low power coprocessor and RTC timer running. After waking up, the board will
start again at ``boot.py``, just like with pressing the reset button. The CPU
counter (``time.ticks()``) will continue to count however!

You can also leave the brackets empty to sleep indefinitely, until the reset button
is pressed, the power is removed, or an external wake up signal (interrupt) is
provided. Be aware that the LTE modem will remain switched on unless you actively
switch off its power, or use its own power saving modes.

.. code-block:: python

   import machine
   print("Wake up")
   machine.deepsleep(1000)  # deepsleep 1 second
   print("this will never get printed!")

Wake up reason
--------------

Sometimes, we want to know the reason the board woke up, to differentiate between
pressing the reset button and other ways of waking up from sleep:

.. code-block:: python

   import machine
   import time

   wake_reason = machine.wake_reason()
   print("Device running for: " + str(time.ticks_ms()) + "ms")

   if wake_reason == machine.PWRON_RESET:
       print("Woke up by reset button")
   elif wake_reason == machine.PIN_WAKE:
       print("Woke up by external pin (external interrupt)")
   elif wake_reason == machine.ULP_WAKE:
       print("Woke up by ULP (capacitive touch)")
   elif wake_reason == machine.TOUCHPAD_WAKE:
       print("Woke up by touchpad")

   machine.deepsleep(1000 * 60)  # sleep for 1 minute
   print("This will never be printed")

.. note::

   Using ``deepsleep()`` will also stop the USB connection. Be wary of that when
   trying to upload new code to the device!
