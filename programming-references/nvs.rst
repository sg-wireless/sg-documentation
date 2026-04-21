Non-Volatile Storage (NVS) Interface
====================================

Contents
--------

- Introduction
- NVS Statistics
- NVS Query
- NVS Key-Value Operations

Introduction
------------

The NVS (Non-Volatile Storage) interface provides access to the ESP32's NVS
flash memory system. NVS is used to persistently store key-value pairs,
configuration data, and other application state that must survive system resets
and power cycles.

The NVS interface component exposes the underlying ESP NVS library
functionality through a micropython module, allowing applications to read,
write, and manage data stored in dedicated NVS partitions.

NVS Statistics
--------------

``nvs_if.stat()`` displays comprehensive statistics about the NVS partitions
and their contents. It can be called with optional filters to view specific
partitions or namespaces.

Function Signature
~~~~~~~~~~~~~~~~~~

.. code:: BNF

   (1) nvs_if.stat()
   (2) nvs_if.stat( dump_blobs=<bool> )
   (3) nvs_if.stat( partition=<name>, namespace=<name>, dump_blobs=<bool> )

Parameters
~~~~~~~~~~

- ``dump_blobs`` (bool, default: False) - If True, displays hexadecimal content
  of BLOB entries in addition to their size.
- ``partition`` (str, optional) - Filter output to a specific NVS partition
  (e.g., "nvs"). If omitted, all partitions are displayed.
- ``namespace`` (str, optional) - Filter output to a specific namespace within
  the partition(s).

Output Format
~~~~~~~~~~~~~

The output displays all key-value pairs organized by partition and namespace,
with the following information for each entry:

- **namespace** - The namespace the key belongs to
- **key** - The key name
- **type** - The data type (U8, I32, STR, BLOB, etc.)
- **val** - The current value or size (for BLOBs)

At the end of each partition, a summary is displayed showing:

- **partition size** - Total capacity of the NVS partition in bytes
- **used entries** - Number of entries currently used / total available entries
- **free** - Percentage of available free space

Examples
~~~~~~~~

.. code:: python

   import nvs_if

   # Display all NVS statistics for all partitions
   nvs_if.stat()

   # Display statistics for a specific partition
   nvs_if.stat(partition="nvs")

   # Display statistics for a specific namespace
   nvs_if.stat(namespace="app")

   # Display all entries with BLOB hex data
   nvs_if.stat(dump_blobs=True)

Example Output
~~~~~~~~~~~~~~

::

   ====================================================================================================
   namespace   key              type    val                                                            
   ====================================================================================================

   ---( nvs )------------------------------------------------------------------------------------------
   ctrl        ztp              U8      0                                                               
   lora-stack  lora-mgr         BLOB    size: 12
   lora-stack  lw-radio-proc    BLOB    size: 20
   app         frame            STR     Frame #3                                                       
   app         iframe           I32     3                                                               
   phy         cal_data         BLOB    size: 1904
   phy         cal_version      U32     540                                                               

       partition size : 24576 bytes
       used entries   : 32 / 126
       free           : 74%
   ====================================================================================================

NVS Query
---------

``nvs_if.exists()`` checks whether a key exists in NVS storage, either in a
specific partition and namespace or in one of the default partitions.

.. _function-signature-1:

Function Signature
~~~~~~~~~~~~~~~~~~

.. code:: BNF

   nvs_if.exists( key, namespace, partition=<name> )

.. _parameters-1:

Parameters
~~~~~~~~~~

- ``key`` (str) - The key name to check for existence. If None, checks for
  namespace existence only.
- ``namespace`` (str) - The namespace in which to search.
- ``partition`` (str, optional) - The NVS partition name. If omitted, searches
  the default "nvs" partition.

Return Value
~~~~~~~~~~~~

- **True** if the key (or namespace) exists
- **False** if the key (or namespace) does not exist

.. _examples-1:

Examples
~~~~~~~~

.. code:: python

   import nvs_if

   # Check if a key exists in the default partition
   if nvs_if.exists(key="ztp", namespace="ctrl"):
       print("ZTP key found")
   else:
       print("ZTP key not found")

   # Check namespace existence
   if nvs_if.exists(key=None, namespace="app"):
       print("app namespace exists")

   # Check in a specific partition
   if nvs_if.exists(key="data", namespace="myapp", partition="nvs"):
     print("data key found in nvs partition")

NVS Key-Value Operations
------------------------

``nvs_if.set()`` stores or updates a key-value pair in NVS storage.

.. _function-signature-2:

Function Signature
~~~~~~~~~~~~~~~~~~

.. code:: BNF

   nvs_if.set( key, value, namespace, partition=<name> )

.. _parameters-2:

Parameters
~~~~~~~~~~

- ``key`` (str) - The key name
- ``value`` - The value to store (bytes, int, or str, depending on intended
  type)
- ``namespace`` (str) - The namespace in which to store the key
- ``partition`` (str, optional) - The NVS partition name. If omitted, uses the
  default "nvs" partition

.. _return-value-1:

Return Value
~~~~~~~~~~~~

- **True** if the operation was successful
- **False** if the operation failed

.. _examples-2:

Examples
~~~~~~~~

.. code:: python

   import nvs_if

   # Store an integer value
   nvs_if.set(key="counter", value=42, namespace="app")

   # Store a string value
   nvs_if.set(key="ssid", value="WiFiNetwork", namespace="config")

   # Store binary data (BLOB)
   nvs_if.set(key="data", value=b"\x01\x02\x03\x04", namespace="app")

   # Store in a specific partition
   nvs_if.set(key="setting", value=100, namespace="app", partition="nvs")

Reading Values
~~~~~~~~~~~~~~

``nvs_if.get()`` retrieves a stored value from NVS storage.

.. _function-signature-3:

Function Signature
~~~~~~~~~~~~~~~~~~

.. code:: BNF

   nvs_if.get( key, namespace, partition=<name>, default=None )

.. _parameters-3:

Parameters
~~~~~~~~~~

- ``key`` (str) - The key name to retrieve
- ``namespace`` (str) - The namespace containing the key
- ``partition`` (str, optional) - The NVS partition name. If omitted, searches
  the default "nvs" partition
- ``default`` (optional) - Value to return if the key is not found. If not
  specified and key doesn't exist, raises an exception.

.. _return-value-2:

Return Value
~~~~~~~~~~~~

The stored value, or the default value if the key doesn't exist.

.. _examples-3:

Examples
~~~~~~~~

.. code:: python

   import nvs_if

   # Retrieve a value
   counter = nvs_if.get(key="counter", namespace="app")
   print(f"Counter: {counter}")

   # Retrieve with a default value
   ssid = nvs_if.get(key="ssid", namespace="config", default="DefaultSSID")

   # Retrieve from a specific partition
   setting = nvs_if.get(key="setting", namespace="app", partition="nvs")
