System Inspection
=================

Contents
--------

- Introduction
- Memory Dump
- Peripherals Power

Introduction
------------

This component introduces some miscellaneous functions to help in system
inspection and debugging.

.. _memory-dump-sys_inspectdump_memory:

Memory Dump ``sys_inspect.dump_memory()``
-----------------------------------------

It is a utility function to dump a certain memory space.

It takes the following keyword argument:

- ``address`` the start address of the dump memory space
- ``size`` size of data to dumpped
- ``wordsize`` display word size of dumped data (32, 16, or 8)
- ``linesize`` number of display bytes per line
- ``disp_text`` show the printable ascii character of the data.

Example: the following picture shows an example of the memory dump

|Memory Dump Screen Shot|

Peripherals Power
-----------------

It is a set of utilities that help in inspection of the enabled system
peripherals. That could help in power management inspection. The current
available methods are:

- ``sys_inspect.periph_module_list()`` It lists the whole list of system
  peripherals and indicate the peripheral along with how many other system
  actors are using it. The periphiral in use indicate that its power is on.

- ``sys_inspect.periph_power(<periph>, True|False)`` It tries to disabled the
  module compulsory, in this case, the system may perform in undesired
  behaviour

The following is a screen shot to the ``periph_module_list()``

|Peripherals List Screen Shot|

.. |Memory Dump Screen Shot| image:: mem-dump-screen-shot.png
.. |Peripherals List Screen Shot| image:: periph-list-screen-shot.png
