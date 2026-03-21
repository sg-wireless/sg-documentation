Firmware & API Reference
========================

This chapter describes modules (function and class libraries) that are built
into MicroPython. For standard modules implemented in MicroPython, refer to the
`MicroPython documentation <https://docs.micropython.org/en/latest/>`_.

SG Modules
----------

These modules are specific to the SG devices and may have slightly different
implementations to other variations of MicroPython.

.. note::

   This documentation in general aspires to describe all modules and
   functions/classes which are implemented in MicroPython. However, MicroPython
   is continuously evolving and some functions, classes or modules may not be
   available on the SG Wireless F1 module yet.

.. toctree::
   :maxdepth: 1
   :caption: Application

   ctrl-client

.. toctree::
   :maxdepth: 1
   :caption: Network Interfaces

   lora
   lora-wan
   lora-raw
   lora-callbacks
   lte

.. toctree::
   :maxdepth: 1
   :caption: Peripherals

   rgbled
