I2C
===

The following example receives data from a light sensor using I2C. The sensor used
is the BH1750FVI Digital Light Sensor.

.. note::

   For F1 module and F1 Starter Kit, ``I2C(0)`` is reserved for internal use.
   Please start from ``I2C(1)`` for any new I2C bus.

.. code-block:: python

   import time
   from machine import I2C
   import bh1750fvi

   i2c = I2C(1, freq=100000)
   # Remark: I2C(0) is reserved in F1 as internal I2C bus
   light_sensor = bh1750fvi.BH1750FVI(i2c, addr=i2c.scan()[0])

   while True:
       data = light_sensor.read()
       print(data)
       time.sleep(1)

Drivers for the BH1750FVI
-------------------------

Place this code into a file named ``bh1750fvi.py``. This can then be imported as
a library.

.. code-block:: python

   # Simple driver for the BH1750FVI digital light sensor

   class BH1750FVI:
       MEASUREMENT_TIME = const(120)

       def __init__(self, i2c, addr=0x23, period=150):
           self.i2c = i2c
           self.period = period
           self.addr = addr
           self.time = 0
           self.value = 0
           self.i2c.writeto(addr, bytes([0x10]))  # start continuous 1 Lux readings

       def read(self):
           self.time += self.period
           if self.time >= MEASUREMENT_TIME:
               self.time = 0
               data = self.i2c.readfrom(self.addr, 2)
               self.value = (((data[0] << 8) + data[1]) * 1200) // 1000
           return self.value
