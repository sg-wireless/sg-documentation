System Inspection
=================

.. module:: sys_inspect
   :synopsis: Memory and peripheral inspection utilities


Memory Dump
-----------

.. function:: dump_memory(**kwargs)

   Display a formatted hex dump of a memory region.

   :param int address: Start address (default ``0x3FF00000``)
   :param int size: Number of bytes to dump (default ``256``)
   :param int wordsize: Group width in bytes --- 1, 2, or 4 (default ``1``)
   :param int linesize: Bytes per line (default ``16``)
   :param bool disp_text: Show ASCII column (default ``True``)

   Example::

      import sys_inspect
      sys_inspect.dump_memory(address=0x3FF00000, size=64)


Peripheral Power Inspection
----------------------------

.. function:: periph_module_list()

   Print the list of all ESP32 peripheral modules and their identifiers.

.. function:: periph_power(module_id)

   Check whether a specific peripheral module is currently powered on.

   :param int module_id: Peripheral identifier from :func:`periph_module_list`

   Example::

      sys_inspect.periph_module_list()
      sys_inspect.periph_power(0)   # check first peripheral
