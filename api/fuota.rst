:mod:`fuota` --- Firmware Update Over The Air
=============================================

.. module:: fuota
   :synopsis: OTA firmware update management

The ``fuota`` module provides APIs for managing OTA (Over-The-Air) firmware
updates on ESP32 devices.  It supports both blocking and non-blocking modes,
HTTPS downloads, automatic partition management, and progress tracking.


Quick Start
-----------

.. code-block:: python

   import fuota, machine

   if fuota.upgrade('https://example.com/firmware.bin'):
       print("Success!")
       machine.reset()


API Reference
-------------

.. function:: fuota.upgrade(url)

   **Blocking** --- download and install firmware synchronously.

   :param str url: HTTPS/HTTP URL to firmware binary.
   :returns: ``True`` on success, ``False`` on failure.

   .. warning:: REPL will be frozen during download and installation.

.. function:: fuota.start_upgrade(url)

   **Non-blocking (recommended)** --- download and install in background.

   :param str url: URL to firmware binary.
   :raises OSError: If OTA already in progress or network error.

.. function:: fuota.status()

   Return current OTA status dict (non-blocking mode).

   Keys:

   - ``state`` (str): ``'idle'``, ``'running'``, ``'success'``, ``'failed'``,
     or ``'aborted'``
   - ``bytes_written`` (int): Bytes downloaded so far
   - ``total_size`` (int, optional): Total firmware size
   - ``error_code`` (int, optional): ESP-IDF error code on failure
   - ``err_msg`` (str, optional): Error description on failure

.. function:: fuota.abort_upgrade()

   Cancel an ongoing OTA upgrade.

   :raises OSError: If no OTA is in progress.

.. function:: fuota.info()

   Print partition information to the console.

.. function:: fuota.partition_info()

   Return partition information as a named tuple with fields:

   - ``next_update_partition``
   - ``running_partition``
   - ``boot_partition``

.. function:: fuota.valid()

   Mark the current firmware as valid (prevents automatic rollback).

.. function:: fuota.rollback()

   Mark current firmware as invalid and reboot to previous version.


Low-Level API
~~~~~~~~~~~~~

.. function:: fuota.start()

   Begin a manual OTA process.

.. function:: fuota.write(data)

   Write a firmware data chunk.

.. function:: fuota.finish()

   Complete manual OTA and set boot partition.


Usage Patterns
--------------

**Non-blocking with progress monitoring (recommended):**

.. code-block:: python

   import fuota, time, machine

   fuota.start_upgrade('https://example.com/firmware.bin')

   while True:
       status = fuota.status()
       state = status['state']

       if state == 'running':
           total = status.get('total_size')
           if total:
               pct = (status['bytes_written'] * 100) // total
               print(f"Downloading: {pct}%")

       elif state == 'success':
           print("Upgrade successful!")
           machine.reset()
           break

       elif state == 'failed':
           print(f"Failed: {status.get('err_msg')}")
           break

       time.sleep(1)

**Simple blocking upgrade:**

.. code-block:: python

   import fuota, machine

   if fuota.upgrade('https://example.com/firmware.bin'):
       machine.reset()

**User-cancelable:**

.. code-block:: python

   import fuota, time

   fuota.start_upgrade('https://example.com/firmware.bin')
   try:
       while fuota.status()['state'] not in ('success', 'failed', 'aborted'):
           time.sleep(0.5)
   except KeyboardInterrupt:
       fuota.abort_upgrade()
       print("Cancelled")
