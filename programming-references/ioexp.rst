IO Expander Interface (PCAL6408A)
=================================

Contents
--------

-  Introduction
-  MicroPython Interface
-  C Interface
-  Hardware Connection

Introduction
------------

This component wraps the PCAL6408A GPIO expander chip on the F1 board to
control the **power/reset lines of onboard chips** — LoRa, LTE, and the secure
element. It is **not** a generic GPIO-expander API; there is no per-pin
``read``/``write``/``set_direction`` surface exposed. Each controlled signal
has its own dedicated function.

MicroPython Interface
---------------------

.. code:: python

   import ioexp

.. _ioexpinit:

``ioexp.init()``
~~~~~~~~~~~~~~~~

Initialize the io-expander interfacing component. Hardware resources for each
signal are brought up on demand by the specific control functions below.

.. _ioexpreset:

``ioexp.reset()``
~~~~~~~~~~~~~~~~~

Reset the io-expander driver. Causes all previously initialized signals to be
lost — for debugging only.

.. _ioexpstats:

``ioexp.stats()``
~~~~~~~~~~~~~~~~~

Print the status of the signals currently tracked by the io-expander.

LoRa chip power control (requires the ``lora`` feature)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ioexp.lora_power_on()          # power on the LoRa chip
   ioexp.lora_power_off()         # power off the LoRa chip
   ioexp.lora_power()             # -> bool: current power status
   ioexp.lora_power(True)         # power on
   ioexp.lora_power(False)        # power off
   ioexp.lora_reset()             # send a reset pulse to the LoRa chip

LTE chip power control (requires the ``lte`` feature)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ioexp.lte_power_on()
   ioexp.lte_power_off()
   ioexp.lte_power()              # -> bool: current power status
   ioexp.lte_power(True)
   ioexp.lte_power(False)
   ioexp.lte_reset()              # send a reset pulse to the LTE chip

Secure element power control (requires the ``secure-element`` feature)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   ioexp.secure_chip_on()
   ioexp.secure_chip_off()
   ioexp.secure_chip_power()      # -> bool: current power status
   ioexp.secure_chip_power(True)
   ioexp.secure_chip_power(False)

.. _ioexpopen_drainbool:

``ioexp.open_drain(bool)``
~~~~~~~~~~~~~~~~~~~~~~~~~~

Configure the PCAL6408A's output stage as open-drain (``True``) or push-pull
(``False``).

C Interface
-----------

``ioexp.h`` (``src/platforms/F1/comps/ioexp-if/ioexp.h``):

.. code:: c

   void ioexp_init(void);
   void ioexp_reset(void);
   void ioexp_stats(void);

   // LoRa chip controls
   void ioexp_lora_chip_power_on(void);
   void ioexp_lora_chip_power_off(void);
   bool ioexp_lora_chip_power_status(void);
   void ioexp_lora_chip_reset(void);
   void ioexp_lora_chip_set_int_signal_callback(ioexp_callback_t cb);
   bool ioexp_lora_chip_read_int_pin(void);
   void ioexp_lora_chip_set_busy_signal_callback(ioexp_callback_t cb);
   bool ioexp_lora_chip_is_busy(void);

   // LTE chip controls
   void ioexp_lte_chip_power_on(void);
   void ioexp_lte_chip_power_off(void);
   bool ioexp_lte_chip_power_status(void);
   void ioexp_lte_chip_reset(void);
   void ioexp_lte_chip_set_ring_signal_callback(ioexp_callback_t cb);

   // Secure element controls, MicroPython I2C fusion hooks, etc. — see ioexp.h

Hardware Connection
-------------------

The PCAL6408A is accessed over I2C via the shared ``mp_i2c_bridge`` (see
`mp_i2c_bridge/README.md <../../../../comps/mp_i2c_bridge/README.md>`__), which
is hardcoded to **SCL=GPIO7, SDA=GPIO8** at 100kHz (``ioexp_mp.c``:
``mp_i2c_bridge_init(7, 8, 100000)``).
