FUOTA Module - Firmware Update Over The Air
===========================================

The ``fuota`` module provides Python APIs for managing OTA (Over-The-Air)
firmware updates on ESP32 devices.

Features
--------

- ✅ **Simple one-line upgrade**: ``fuota.upgrade(url)`` handles everything
- ✅ **Non-blocking mode**: Background OTA with status monitoring
- ✅ **Blocking mode**: Traditional synchronous operation
- ✅ **HTTPS support**: Built-in certificate bundle for secure downloads
- ✅ **Automatic partition management**: Selects next available OTA partition
- ✅ **Validation**: Verifies firmware image before flashing
- ✅ **Low memory usage**: Runs in C, no 64KB Python thread stack needed
- ✅ **Progress tracking**: Real-time status and progress monitoring
- ✅ **Percentage logging**: 1% increment progress updates
- ✅ **Network detection**: Automatic WiFi/LTE connectivity check
- ✅ **Automatic validation**: Validates new firmware on first boot
- ✅ **Soft reset safe**: Cleanly cancels OTA on Ctrl+D

API Reference
-------------

.. _fuotaupgradeurl:

``fuota.upgrade(url)``
~~~~~~~~~~~~~~~~~~~~~~

**BLOCKING MODE** - Downloads and installs firmware synchronously.

**Parameters:**

- ``url`` (str, required): HTTPS/HTTP URL to firmware binary

**Returns:**

- ``True`` on success, ``False`` on failure

**Blocks until complete** - REPL will be frozen during download and
installation.

**Example:**

.. code:: python

   import fuota
   import machine

   # Blocking upgrade - waits for completion
   if fuota.upgrade('https://example.com/firmware.bin'):
       print("Success!")
       machine.reset()
   else:
       print("Failed!")

--------------

.. _fuotastart_upgradeurl:

``fuota.start_upgrade(url)``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**NON-BLOCKING MODE (RECOMMENDED)** - Downloads and installs firmware in
background.

**Parameters:**

- ``url`` (str, required): HTTPS/HTTP URL to firmware binary

**Returns:**

- ``None`` - Returns immediately, use ``fuota.status()`` to monitor progress

**Raises:**

- ``OSError``: If OTA already in progress, network error, or failed to create
  task

**Example:**

.. code:: python

   import fuota
   import time
   import machine

   # Start OTA in background - returns immediately
   fuota.start_upgrade('https://example.com/firmware.bin')

   # Monitor progress
   while True:
       status = fuota.status()
       print(f"State: {status['state']}, Progress: {status['bytes_written']}/{status.get('total_size', '?')}")
       
       if status['state'] == 'success':
           print("Upgrade successful!")
           machine.reset()
           break
       elif status['state'] == 'failed':
           print(f"Upgrade failed: {status.get('err_msg', 'Unknown error')}")
           break
       
       time.sleep(1)

--------------

.. _fuotastatus:

``fuota.status()``
~~~~~~~~~~~~~~~~~~

Returns current OTA operation status (for non-blocking mode).

**Returns:** Dictionary with keys:

- ``state`` (str): ``'idle'``, ``'running'``, ``'success'``, ``'failed'``, or
  ``'aborted'``
- ``bytes_written`` (int): Bytes downloaded so far
- ``total_size`` (int, optional): Total firmware size (if known)
- ``error_code`` (int, optional): ESP-IDF error code (on failure)
- ``err_msg`` (str, optional): Error description (on failure)

**Example:**

.. code:: python

   >>> fuota.status()
   {'state': 'running', 'bytes_written': 524288, 'total_size': 2621440}

   >>> fuota.status()
   {'state': 'failed', 'bytes_written': 100000, 'error_code': -1, 'err_msg': 'Network timeout'}

--------------

.. _fuotaabort_upgrade:

``fuota.abort_upgrade()``
~~~~~~~~~~~~~~~~~~~~~~~~~

Cancels an ongoing OTA upgrade (non-blocking mode).

**Raises:**

- ``OSError``: If no OTA upgrade is in progress

**Example:**

.. code:: python

   fuota.start_upgrade('https://example.com/firmware.bin')
   time.sleep(5)
   fuota.abort_upgrade()  # Cancel after 5 seconds

--------------

.. _fuotainfo:

``fuota.info()``
~~~~~~~~~~~~~~~~

Prints current partition information to console.

**Example:**

.. code:: python

   >>> fuota.info()
   Next update partition: ota_1
   Running partition: ota_0
   Boot partition: ota_0

--------------

.. _fuotapartition_info:

``fuota.partition_info()``
~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns partition information as a named tuple (use this instead of ``info()``
for programmatic access).

**Returns:** Named tuple with fields:

- ``next_update_partition`` (str): Partition for next OTA
- ``running_partition`` (str): Currently running partition
- ``boot_partition`` (str): Partition system booted from

**Example:**

.. code:: python

   >>> info = fuota.partition_info()
   >>> print(f"Running: {info.running_partition}, Next: {info.next_update_partition}")
   Running: ota_0, Next: ota_1

   >>> info.running_partition
   'ota_0'

--------------

.. _fuotavalid:

``fuota.valid()``
~~~~~~~~~~~~~~~~~

Marks current firmware as valid, preventing automatic rollback.

**Important:** Call this after validating new firmware works correctly!

--------------

.. _fuotarollback:

``fuota.rollback()``
~~~~~~~~~~~~~~~~~~~~

Marks current firmware as invalid and reboots to previous version.

--------------

Low-Level API (Advanced)
~~~~~~~~~~~~~~~~~~~~~~~~

.. _fuotastart:

``fuota.start()``
~~~~~~~~~~~~~~~~~

Begins manual OTA process.

.. _fuotawritedata:

``fuota.write(data)``
~~~~~~~~~~~~~~~~~~~~~

Writes firmware data chunk.

**Parameters:**

- ``data`` (bytes): Firmware data chunk

.. _fuotafinish:

``fuota.finish()``
~~~~~~~~~~~~~~~~~~

Completes manual OTA and sets boot partition.

Usage Patterns
--------------

Pattern 1: Non-Blocking Upgrade with Progress (Recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   import fuota
   import time
   import machine

   url = 'https://example.com/firmware.bin'

   # Start OTA in background
   fuota.start_upgrade(url)
   print("OTA started in background...")

   # Monitor progress
   while True:
       status = fuota.status()
       state = status['state']
       
       if state == 'running':
           bytes_written = status['bytes_written']
           total = status.get('total_size')
           if total:
               pct = (bytes_written * 100) // total
               print(f"Downloading: {pct}% ({bytes_written}/{total} bytes)")
           else:
               print(f"Downloading: {bytes_written} bytes")
       
       elif state == 'success':
           print("✓ Upgrade successful! Rebooting...")
           time.sleep(1)
           machine.reset()
           break
       
       elif state == 'failed':
           print(f"✗ Upgrade failed: {status.get('err_msg', 'Unknown error')}")
           print(f"  Error code: {status.get('error_code')}")
           break
       
       elif state == 'aborted':
           print("OTA was aborted")
           break
       
       time.sleep(1)

Pattern 2: Simple Blocking Upgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   import fuota
   import machine

   try:
       # Blocks until complete
       if fuota.upgrade('https://example.com/firmware.bin'):
           print("Upgrade successful, rebooting...")
           machine.reset()
       else:
           print("Upgrade failed")
   except OSError as e:
       print(f"Error: {e}")

Pattern 3: User-Cancelable Upgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   import fuota
   import time
   import sys

   url = 'https://example.com/firmware.bin'
   fuota.start_upgrade(url)

   print("Upgrading... Press Ctrl+C to cancel")

   try:
       while True:
           status = fuota.status()
           if status['state'] in ('success', 'failed', 'aborted'):
               break
           time.sleep(0.5)
           
   except KeyboardInterrupt:
       print("\nCanceling upgrade...")
       fuota.abort_upgrade()
       print("Upgrade canceled")

Pattern 4: Safe Upgrade with Automatic Validation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The firmware automatically validates on first boot after OTA! Just reset after
successful upgrade:

.. code:: python

   import fuota
   import machine

   # No need to manually call fuota.valid() anymore!
   if fuota.upgrade('https://example.com/firmware.bin'):
       print("Rebooting to new firmware...")
       machine.reset()  # New firmware auto-validates on boot

Pattern 5: Safe Upgrade with Manual Validation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: python

   import fuota
   import machine

   # Check current state
   info = fuota.partition_info()
   print(f"Current partition: {info.running_partition}")

   # Perform upgrade
   if fuota.upgrade('https://example.com/firmware.bin'):
       print("Upgrade complete, rebooting...")
       machine.reset()

   # After reboot, in boot.py or main.py:
   def validate_firmware():
       """Test critical functionality"""
       try:
           # Test your critical features
           import important_module
           important_module.test()
           return True
       except Exception as e:
           print(f"Validation failed: {e}")
           return False

   if validate_firmware():
       print("✓ Firmware validated")
       fuota.valid()  # Mark as valid
   else:
       print("✗ Validation failed, rolling back...")
       fuota.rollback()  # Reboot to previous version

Memory Usage
------------

The new ``fuota.upgrade()`` function is implemented in C and uses the ESP-IDF's
optimized HTTPS OTA stack:

- **No Python thread needed**: Runs directly in main thread
- **No 64KB stack allocation**: Uses default C stack
- **Efficient streaming**: Downloads and flashes in chunks
- **PSRAM available**: All 8MB PSRAM remains free for other uses

Old vs New Approach
~~~~~~~~~~~~~~~~~~~

**Old (Python thread with urequests):**

.. code:: python

   _thread.start_new_thread(download_thread, ())  # 64KB internal RAM!

- Required 64KB thread stack in internal RAM
- Used Python HTTP libraries (slower, more memory)
- Complex error handling

**New (C implementation):**

.. code:: python

   fuota.upgrade(url)  # No extra stack needed

- Uses default C stack
- ESP-IDF optimized HTTP/TLS stack
- Automatic error handling

Network Requirements
--------------------

- Active WiFi or LTE connection
- DNS resolution for HTTPS URLs
- Sufficient bandwidth for firmware download
- Stable connection (30s - several minutes depending on size)

Security
--------

- **HTTPS recommended**: Use certificate bundle or custom cert
- **Firmware validation**: Automatic integrity checking
- **Rollback protection**: Mark firmware valid after testing
- **Partition isolation**: Failed upgrades don't affect running firmware

Troubleshooting
---------------

"OTA upgrade already in progress"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- An OTA operation is already running
- Wait for it to complete or call ``fuota.abort_upgrade()``

"Network not connected - please connect to WiFi or LTE first"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- No active network connection detected
- Connect to WiFi or LTE before starting OTA
- Verify IP address is assigned

"ESP HTTPS OTA Begin failed"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Invalid URL or unreachable server
- Check URL is correct and server is running
- Test URL in browser first

"Image validation failed, image is corrupted"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Downloaded firmware is corrupted or incomplete
- Check network stability during download
- Verify firmware binary is valid for your hardware

"Unable to read remote firmware descriptor"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Server returned invalid firmware image
- Ensure URL points to actual firmware binary (not HTML page)
- Check firmware is built for ESP32-S3

Slow Downloads
~~~~~~~~~~~~~~

- Increase HTTP buffer size (requires code modification)
- Current: 128 bytes for fast flash writes
- Trade-off: Larger buffers = faster download but slower flash writes

REPL Hangs During Blocking Mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Fixed in current version with ``is_background_task`` flag
- Ensure you're using latest firmware
- Use non-blocking mode if issues persist

Partition Shows Wrong Subtype After Downgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Flashing new firmware updates partition table
- Subtype changes from ``6`` (IDF v4) to ``131/0x83`` (IDF v5)
- This is normal - indicates which firmware version is active
- **Important**: Downgrading from IDF v5 to IDF v4 requires ``--erase-flash``
  due to LittleFS version incompatibility

Implementation Details
----------------------

Architecture
~~~~~~~~~~~~

- **C-based implementation**: Uses ESP-IDF ``esp_https_ota`` API
- **Two distinct APIs**:

  - ``fuota.upgrade(url)``: **Blocking** - runs in calling thread, returns
    after completion
  - ``fuota.start_upgrade(url)``: **Non-blocking** - runs in FreeRTOS task
    (priority 5, 8KB stack)

- **Automatic partition selection**: Toggles between ota_0/ota_1
- **Built-in certificate bundle**: Support for common CA certificates
- **Configurable HTTP timeout**: Default 30 seconds
- **Efficient streaming**: 128-byte HTTP buffers for fast flash writes

Progress Logging
~~~~~~~~~~~~~~~~

- **Percentage-based**: Logs every 1% when total size known
- **Byte-based**: Logs every write when size unknown
- **Event-driven**: Uses ESP-IDF OTA event system
- **Debug output**: Comprehensive firmware metadata logging

Network Detection
~~~~~~~~~~~~~~~~~

Automatically checks connectivity before starting:

1. Checks WiFi (WIFI_STA_DEF interface)
2. Falls back to LTE (PPP_DEF interface)
3. Fails fast if no IP address available

Automatic Validation
~~~~~~~~~~~~~~~~~~~~

New firmware is automatically validated on first boot:

- Checks if running from OTA partition
- Detects pending validation state
- Calls ``esp_ota_mark_app_valid_cancel_rollback()`` automatically
- No manual ``fuota.valid()`` call needed (unless you want extra validation)

Soft Reset Safety
~~~~~~~~~~~~~~~~~

When you press Ctrl+D (soft reset):

- Automatically cancels any running OTA operation
- Cleans up background task
- Prevents orphaned OTA tasks
- Safe to restart Python environment during OTA

Task Priority
~~~~~~~~~~~~~

Background OTA task runs at priority 5 to:

- Avoid preemption during flash writes
- Ensure stable flash operations
- Allow REPL to remain responsive
- Priority higher than MicroPython main task (priority 1)

Future Enhancements
-------------------

- ☒ Non-blocking mode with status monitoring
- ☒ Progress tracking with percentage updates
- ☒ Automatic firmware validation on boot
- ☒ Soft reset safety (clean OTA cancellation)
- ☒ Network connectivity detection
- ☐ Resume interrupted downloads
- ☐ Delta/differential updates
- ☐ Custom progress callbacks
- ☐ Configurable HTTP buffer size via API
- ☐ Multi-stage bootloader support

See Also
--------

- Example: ``/examples/fuota/ota_example.py``
- ESP-IDF OTA docs:
  https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-reference/system/ota.html
