.. _fuel-gauge--bq27421-:

Fuel-Gauge ( BQ27421 )
======================

Contents
--------

-  Introduction
-  Fuel-Gauge Functions
-  Battery Info Fields
-  Example

Introduction
------------

The Fuel-Gauge feature is supported for board shields that have the BQ27421
fuel gauge IC on board. If present, the fuel-gauge firmware interface component
will be activated and built with the final firmware image.

This interface component utilizes the open-source driver for this fuel gauge
which can be found at this git repository
https://github.com/svcguy/lib-BQ27421/tree/master

I2C Bridge Architecture
~~~~~~~~~~~~~~~~~~~~~~~

The fuel gauge implementation uses the MicroPython I2C Bridge architecture for
ESP-IDF v5.4+ compatibility:

-  **Driver**: BQ27421 fuel gauge IC communicates via I2C
-  **Device Address**: 0x55 (7-bit I2C address)
-  **Bridge**: ``mp_i2c_bridge`` component provides a C interface to
   MicroPython I2C
-  **I2C Pins**: SCL and SDA are configurable (defaults in
   ``fuel_gauge.config``)
-  **Frequency**: 100 kHz I2C bus frequency

Fuel-Gauge Functions
--------------------

-  ``fuel_gauge.init()`` initializes the module with given battery parameters.
   It accepts the following optional keyword arguments:

   .. code:: BNF

      fuel_gauge.init( designCapacity_mAh=<int>,
                       minSysVoltage_mV=<int>,
                       taperCurrent_mA=<int> )

   -  ``designCapacity_mAh`` (int, default: 1200) - the design capacity of the
      battery in mAh.
   -  ``minSysVoltage_mV`` (int, default: 0) - an optional system minimum
      operating voltage in mV. Pass 0 if not specified.
   -  ``taperCurrent_mA`` (int, default: 0) - an optional taper current
      detection threshold of the charger (including charger tolerances). The
      charger will stop charging below this value. Pass 0 if not specified.

   Raises ``OSError`` if the fuel gauge cannot be initialized (e.g. no battery
   connected).

-  ``fuel_gauge.deinit()`` deinitializes the module. Before using the module
   again it has to be re-initialized using ``fuel_gauge.init()``.

-  ``fuel_gauge.info()`` reads current information from the fuel gauge IC and
   returns a named tuple with all battery parameters. See Battery Info Fields
   for the complete list of returned fields. Raises ``OSError`` if the module
   is not initialized or the battery is not present.

-  ``fuel_gauge.print()`` reads and prints all fuel gauge information in a
   human-readable format to the console output.

Battery Info Fields
-------------------

The named tuple returned by ``fuel_gauge.info()`` contains the following
fields:

.. list-table::
   :header-rows: 1

   - 

      - Field
      - Type
      - Unit
      - Description
   - 

      - ``voltage_mV``
      - int
      - mV
      - Current battery voltage
   - 

      - ``current_mA``
      - int
      - mA
      - Current draw (positive = charging)
   - 

      - ``temp_degC``
      - float
      - °C
      - Battery temperature
   - 

      - ``charge_percent``
      - int
      - %
      - State of Charge (SOC)
   - 

      - ``health_percent``
      - int
      - %
      - State of Health (SOH)
   - 

      - ``designCapacity_mAh``
      - int
      - mAh
      - Battery design capacity
   - 

      - ``remainingCapacity_mAh``
      - int
      - mAh
      - Current usable capacity remaining
   - 

      - ``fullChargeCapacity_mAh``
      - int
      - mAh
      - Current full charge capacity
   - 

      - ``isCritical``
      - bool
      - —
      - Battery voltage critically low
   - 

      - ``isLow``
      - bool
      - —
      - Battery voltage low
   - 

      - ``isFull``
      - bool
      - —
      - Battery fully charged
   - 

      - ``isCharging``
      - bool
      - —
      - Battery is currently charging
   - 

      - ``isDischarging``
      - bool
      - —
      - Battery is currently discharging

Example
-------

.. code:: python

   import fuel_gauge

   # initialize with a 1500 mAh battery
   fuel_gauge.init(designCapacity_mAh=1500)

   # print formatted battery status to the console
   fuel_gauge.print()

Example output of ``fuel_gauge.print()``:

::

   Voltage               4200 mV
   Current               62 mA
   Temprature            30.10 degC
   Charge State          100 %
   Health State          91 %
   Design Capacity       1200 mAh
   Remaining Capacity    497 mAh
   Full Charge Capacity  497 mAh
   is critical           no
   is low                no
   is full               no
   is charging           yes
   is discharging        no

Using ``fuel_gauge.info()`` for scripting:

.. code:: python

   import fuel_gauge

   fuel_gauge.init()

   info = fuel_gauge.info()

   print(f"Battery voltage : {info.voltage_mV} mV")
   print(f"Charge          : {info.charge_percent} %")
   print(f"Health          : {info.health_percent} %")
   print(f"Temperature     : {info.temp_degC} degC")
   print(f"Remaining       : {info.remainingCapacity_mAh} mAh")

   if info.isCharging:
       print("Battery is charging")
   elif info.isDischarging:
       print("Battery is discharging")

   if info.isCritical:
       print("WARNING: Battery critically low!")

   # cleanup
   fuel_gauge.deinit()
