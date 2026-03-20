:mod:`ioexp` --- IO Expander (PCAL6408A)
========================================

.. module:: ioexp
   :synopsis: 8-bit I2C GPIO expander interface

The ``ioexp`` module provides access to the PCAL6408A 8-bit I2C GPIO expander
available on SGW3501-F1-StarterKit boards.  The device communicates via I2C
at address ``0x20``.


Initialization
--------------

.. function:: ioexp.init()

   Initialize the IO expander.


Pin Configuration
-----------------

.. function:: ioexp.set_direction(pin_number, direction)

   Set pin direction.

   :param int pin_number: Pin number (0--7).
   :param int direction: ``1`` = input, ``0`` = output.

   .. code-block:: python

      ioexp.set_direction(0, 0)  # output
      ioexp.set_direction(1, 1)  # input


Digital I/O
-----------

.. function:: ioexp.write_pin(pin_number, value)

   Write to an output pin.

   :param int pin_number: Pin number (0--7).
   :param int value: ``0`` or ``1``.

.. function:: ioexp.read_pin(pin_number)

   Read an input pin.

   :param int pin_number: Pin number (0--7).
   :returns: Pin state (``0`` or ``1``).


Port Operations
---------------

.. function:: ioexp.write_port(value)

   Write the entire 8-bit port at once.

   :param int value: 8-bit value (e.g. ``0b10101010``).

.. function:: ioexp.read_port()

   Read the entire port.

   :returns: 8-bit port state.


Pull-up & Polarity
-------------------

.. function:: ioexp.set_pullup(pin_number, enable)

   Enable or disable the internal weak pull-up resistor.

.. function:: ioexp.set_polarity(pin_number, inverted)

   Configure input polarity inversion.


Register Map
------------

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - Register
     - Address
     - Function
   * - Input Port
     - 0x00
     - Read input levels
   * - Output Port
     - 0x01
     - Write output levels
   * - Polarity Inversion
     - 0x02
     - Configure input polarity
   * - Configuration
     - 0x03
     - Set pin direction
   * - Pull-up Enable
     - 0x43
     - Pull resistor enable
   * - Pull-up Select
     - 0x44
     - Pull resistor direction
   * - Interrupt Mask
     - 0x45
     - Interrupt enable
   * - Interrupt Status
     - 0x46
     - Interrupt status


Example
-------

.. code-block:: python

   import ioexp, time

   ioexp.init()

   # pins 0-3 output, 4-7 input with pull-ups
   for pin in range(4):
       ioexp.set_direction(pin, 0)
   for pin in range(4, 8):
       ioexp.set_direction(pin, 1)
       ioexp.set_pullup(pin, 1)

   while True:
       for pin in range(4):
           ioexp.write_pin(pin, 1)
       time.sleep(0.5)
       for pin in range(4):
           ioexp.write_pin(pin, 0)
       time.sleep(0.5)
