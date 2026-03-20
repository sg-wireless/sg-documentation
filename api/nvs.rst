:mod:`nvs_if` --- Non-Volatile Storage
======================================

.. module:: nvs_if
   :synopsis: NVS flash key-value storage interface

The ``nvs_if`` module provides access to the ESP32's NVS (Non-Volatile Storage)
flash memory system.  NVS persistently stores key-value pairs, configuration
data, and application state that must survive resets and power cycles.


Statistics
----------

.. function:: nvs_if.stat([partition=None, namespace=None, dump_blobs=False])

   Display NVS partition statistics.

   :param str partition: Filter to a specific partition (e.g. ``"nvs"``).
   :param str namespace: Filter to a specific namespace.
   :param bool dump_blobs: Show hex content of BLOB entries.

   Output shows all key-value pairs organized by partition and namespace,
   plus a summary of partition size, used entries, and free percentage.

   .. code-block:: python

      import nvs_if

      nvs_if.stat()                       # all partitions
      nvs_if.stat(partition="nvs")        # specific partition
      nvs_if.stat(dump_blobs=True)        # include BLOB hex data

   Example output:

   .. code-block:: text

      namespace   key              type    val
      ---( nvs )------------------------------------------
      ctrl        ztp              U8      0
      lora-stack  lora-mgr         BLOB    size: 12
      app         frame            STR     Frame #3

          partition size : 24576 bytes
          used entries   : 32 / 126
          free           : 74%


Query
-----

.. function:: nvs_if.exists(key, namespace, [partition=None])

   Check whether a key exists in NVS.

   :param str key: Key name.  ``None`` to check namespace existence only.
   :param str namespace: Namespace to search.
   :param str partition: Partition name (default: ``"nvs"``).
   :returns: ``True`` if the key (or namespace) exists, ``False`` otherwise.

   .. code-block:: python

      if nvs_if.exists(key="ztp", namespace="ctrl"):
          print("ZTP key found")


Key-Value Operations
--------------------

.. function:: nvs_if.set(key, value, namespace, [partition=None])

   Store or update a key-value pair.

   :param str key: Key name.
   :param value: Value to store (bytes, int, or str).
   :param str namespace: Target namespace.
   :param str partition: Partition name (default: ``"nvs"``).
   :returns: ``True`` on success, ``False`` on failure.

   .. code-block:: python

      nvs_if.set(key="counter", value=42, namespace="app")
      nvs_if.set(key="ssid", value="WiFiNetwork", namespace="config")
      nvs_if.set(key="data", value=b"\x01\x02\x03", namespace="app")


.. function:: nvs_if.get(key, namespace, [partition=None, default=None])

   Retrieve a stored value.

   :param str key: Key name.
   :param str namespace: Namespace containing the key.
   :param str partition: Partition name (default: ``"nvs"``).
   :param default: Value to return if key is not found.  If not given and
       the key doesn't exist, an exception is raised.

   .. code-block:: python

      counter = nvs_if.get(key="counter", namespace="app")
      ssid = nvs_if.get(key="ssid", namespace="config", default="DefaultSSID")
