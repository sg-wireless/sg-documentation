Timers
======

Detailed information about this class can be found in the ``Timer`` API reference.

Timer
-----

The following example showcases a simple stopwatch application.

.. code-block:: python

   import time

   initial_time = time.time()  # time.time() gets the system time tick
   time.sleep(3)               # simulate 3 seconds time off
   end_time = time.time()
   difference = end_time - initial_time

   print("\nthe time difference [in second] is:", difference)
