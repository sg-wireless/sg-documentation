:mod:`fuel_gauge` --- Fuel Gauge (BQ27421)
==========================================

.. module:: fuel_gauge
   :synopsis: Battery fuel gauge interface

The ``fuel_gauge`` module provides access to the BQ27421 fuel gauge IC
available on boards with battery support.  It uses the MicroPython I2C Bridge
architecture (device address ``0x55``).


Functions
---------

.. function:: fuel_gauge.init([designCapacity_mAh=1200, minSysVoltage_mV=0, taperCurrent_mA=0])

   Initialize the fuel gauge with battery parameters.

   :param int designCapacity_mAh: Battery design capacity in mAh.
   :param int minSysVoltage_mV: Minimum system operating voltage in mV.
   :param int taperCurrent_mA: Charger taper current threshold in mA.
   :raises OSError: If the fuel gauge cannot be initialized (e.g. no battery).

.. function:: fuel_gauge.deinit()

   Deinitialize the module.

.. function:: fuel_gauge.info()

   Read current battery information.

   :returns: Named tuple with all battery parameters (see table below).
   :raises OSError: If the module is not initialized or battery is absent.

.. function:: fuel_gauge.print()

   Print all fuel gauge information in a human-readable format.


Battery Info Fields
-------------------

The named tuple returned by :func:`fuel_gauge.info`:

.. list-table::
   :header-rows: 1
   :widths: 30 10 10 50

   * - Field
     - Type
     - Unit
     - Description
   * - ``voltage_mV``
     - int
     - mV
     - Current battery voltage
   * - ``current_mA``
     - int
     - mA
     - Current draw (positive = charging)
   * - ``temp_degC``
     - float
     - °C
     - Battery temperature
   * - ``charge_percent``
     - int
     - %
     - State of Charge (SOC)
   * - ``health_percent``
     - int
     - %
     - State of Health (SOH)
   * - ``designCapacity_mAh``
     - int
     - mAh
     - Battery design capacity
   * - ``remainingCapacity_mAh``
     - int
     - mAh
     - Usable capacity remaining
   * - ``fullChargeCapacity_mAh``
     - int
     - mAh
     - Current full charge capacity
   * - ``isCritical``
     - bool
     - ---
     - Battery voltage critically low
   * - ``isLow``
     - bool
     - ---
     - Battery voltage low
   * - ``isFull``
     - bool
     - ---
     - Battery fully charged
   * - ``isCharging``
     - bool
     - ---
     - Currently charging
   * - ``isDischarging``
     - bool
     - ---
     - Currently discharging


Example
-------

.. code-block:: python

   import fuel_gauge

   fuel_gauge.init(designCapacity_mAh=1500)
   fuel_gauge.print()

   info = fuel_gauge.info()
   print(f"Voltage: {info.voltage_mV} mV")
   print(f"Charge:  {info.charge_percent} %")
   print(f"Health:  {info.health_percent} %")

   if info.isCritical:
       print("WARNING: Battery critically low!")

   fuel_gauge.deinit()
