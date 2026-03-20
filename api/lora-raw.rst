:mod:`lora` --- LoRa RAW API
============================

.. module:: lora
   :noindex:

This page documents the LoRa RAW mode APIs.  Switch to RAW mode with
``lora.mode(lora._mode.RAW)`` before using these functions.

.. seealso:: :doc:`lora` for initialization, :doc:`lora-wan` for WAN mode,
   :doc:`lora-callbacks` for the event system.

API Summary
-----------

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - API Call
     - Description
   * - :func:`lora.stats`
     - Display current RAW radio settings
   * - :func:`lora.radio_params`
     - Set one or more radio parameters
   * - :func:`lora.callback`
     - Set a user-level callback
   * - :func:`lora.send`
     - Transmit data over LoRa
   * - :func:`lora.recv`
     - Open a timed RX window
   * - :func:`lora.recv_cont_start`
     - Enter continuous RX mode
   * - :func:`lora.recv_cont_stop`
     - Exit continuous RX mode
   * - :func:`lora.tx_continuous_wave_start`
     - Start TX continuous wave test
   * - :func:`lora.tx_continuous_wave_stop`
     - Stop TX continuous wave test


RAW Settings
------------

.. function:: lora.stats()

   Display full radio settings: region, frequency, modulation (SF, BW,
   coding rate), packet parameters, transceiver info, and TX/RX params.

   .. code-block:: text

      >>> lora.stats()
          regional params
              region         : EU868
              frequency      : 868000000 Hz
          modulation params
              sf             : 12
              bandwidth      : 125 KHz
              coding_rate    : 4_7
          tx params
              tx_power       : +10 dBm
              antenna_gain   : +1.00 dBi
              tx_power_eff   : +9 dBm
          rx params
              rx_timeout     : 6000 msec


Radio Parameters
----------------

.. function:: lora.radio_params(**kwargs)

   Modify one or more radio parameters.

   :param region: Region value (e.g. ``lora._region.REGION_EU868``).
   :param int frequency: Frequency in Hz.
   :param float freq_khz: Frequency in kHz.
   :param float freq_mhz: Frequency in MHz.
   :param int tx_power: Desired TX power in dBm.
   :param float antenna_gain: Antenna gain in dBi.
   :param int sf: Spreading factor (7--12).
   :param bandwidth: Bandwidth (``lora._bw.BW_125KHZ``, ``BW_250KHZ``, ``BW_500KHZ``).
   :param coding_rate: Coding rate (``lora._cr.CODING_4_5`` through ``CODING_4_8``).
   :param int preamble: Preamble length.
   :param bool tx_iq: Inverted IQ polarity.
   :param bool reset_all: Reset all parameters to region defaults.

   .. note::

      Changing the region resets all radio parameters to the new region's
      defaults.  If multiple frequency parameters are given, ``frequency``
      has the highest priority, ``freq_mhz`` the lowest.

   .. code-block:: python

      # Change region
      lora.radio_params(region=lora._region.REGION_EU433)

      # Set frequency and modulation
      lora.radio_params(freq_mhz=433.3, sf=8,
                        bandwidth=lora._bw.BW_250KHZ,
                        coding_rate=lora._cr.CODING_4_6)

      # Reset to defaults
      lora.radio_params(reset_all=True)

   **Class constants:**

   .. code-block:: python

      lora._bw.BW_125KHZ / BW_250KHZ / BW_500KHZ
      lora._cr.CODING_4_5 / CODING_4_6 / CODING_4_7 / CODING_4_8
      lora._region.REGION_EU868 / REGION_US915 / ...


Callback
--------

.. function:: lora.callback(handler=, [trigger=])
   :no-index:

   Register a callback for RAW mode events.

   See :doc:`lora-callbacks` for full documentation.

   .. code-block:: python

      def lora_callback(context):
          print('event:', context)

      lora.callback(handler=lora_callback)


Sending Data
------------

.. function:: lora.send(message, [timeout=, sync=False])

   Transmit data.

   :param message: Data buffer (string or bytes).
   :param int timeout: TX operation deadline in ms (default: radio
       ``tx_timeout``).
   :param bool sync: If ``True``, block until TX completes or times out.

   .. code-block:: python

      lora.send("test message")
      lora.send("test message", timeout=1000, sync=True)


Receiving Data
--------------

.. function:: lora.recv([timeout=, sync=True])

   Open a receive window.

   :param int timeout: RX window time in ms (default: radio ``rx_timeout``).
   :param bool sync: If ``True`` (default), block and return the received
       message.  If ``False``, deliver via callback.

   .. code-block:: python

      msg = lora.recv()                 # blocking
      lora.recv(timeout=3000, sync=False)  # async — result in callback


Continuous RX Mode
------------------

.. function:: lora.recv_cont_start()

   Enter continuous reception mode.  Received data is delivered via
   the registered callback.

.. function:: lora.recv_cont_stop()

   Exit continuous reception mode.


Continuous TX Wave
------------------

.. function:: lora.tx_continuous_wave_start(tx_power=, [frequency=868000000, timeout=10000])

   Start TX continuous wave mode for testing.

   :param int tx_power: TX power in dBm.
   :param int frequency: Test frequency in Hz.
   :param int timeout: Timeout in ms (default 10 seconds).

   .. warning:: Any in-progress send/receive operation will be cancelled.

.. function:: lora.tx_continuous_wave_stop()

   Stop TX continuous wave mode.

   .. code-block:: python

      lora.tx_continuous_wave_start(tx_power=20, frequency=433000000, timeout=20000)
      # ... after testing:
      lora.tx_continuous_wave_stop()
