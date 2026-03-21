ADC
===

This example is a simple ADC sample. In this example F1 Starter Kit pin A1 (i.e.
F1 smart module pin P17) is set to be used for ADC.

.. code-block:: python

   from machine import ADC
   from machine import Pin

   adc = ADC(Pin(Pin.P17))
   adc.read_u16()  # read the ADC analog raw value mapped to 0-65535
   adc.read_uv()   # read the ADC analog value in microvolt
