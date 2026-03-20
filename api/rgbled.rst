RGB-LED (WS2812B)
=================

.. py:module:: rgbled

Introduction
------------

The RGB-LED feature is supported for board shields that have the WS2812B RGB-LED
module.  If present, the RGB-LED firmware interface component will be activated
and built with the final firmware image.

This interface utilises the open-source driver from
`ESP32-NeoPixel-WS2812-RMT <https://github.com/JSchaenzle/ESP32-NeoPixel-WS2812-RMT>`_.

The component offers extra services such as heartbeat and decorated light
sequencing.

RGB LED Functions
-----------------

Initialization
~~~~~~~~~~~~~~

The module is initialised automatically when imported.  After initialisation it
can be de-initialised and re-initialised manually:

.. py:function:: rgbled.deinit()

   De-initialise the RGB LED module.

.. py:function:: rgbled.initialize()

   Re-initialise the RGB LED module after ``deinit()``.

Color
~~~~~

.. py:function:: rgbled.color(color_value)

   Set the LED to a continuous colour.  The colour follows the hex format
   ``0xXXRRGGBB`` where ``RR``, ``GG`` and ``BB`` are the red, green, and blue
   components respectively.  ``XX`` is a don't-care value.

   :param int color_value: Colour value in ``0xXXRRGGBB`` format.

   .. code-block:: python

      import rgbled
      rgbled.color(0x00FF0000)    # red
      rgbled.color(0x0000FF00)    # green
      rgbled.color(0x000000FF)    # blue
      rgbled.color(0x00FFFF00)    # yellow

Heartbeat
~~~~~~~~~

.. py:function:: rgbled.heartbeat([enable_or_color, [cycle_time, blink_percentage]])

   Control the heartbeat blinking service.  Three call signatures are supported:

   **Signature 1** — query status:

   .. code-block:: python

      rgbled.heartbeat()   # returns True or False

   **Signature 2** — enable / disable:

   .. code-block:: python

      rgbled.heartbeat(True)    # start with current/default config
      rgbled.heartbeat(False)   # stop

   **Signature 3** — configure and start:

   .. code-block:: python

      rgbled.heartbeat(color, cycle_time, blink_percentage)

   :param bool/int enable_or_color: Boolean to enable/disable, or a colour value.
   :param int cycle_time: Total duty-cycle period in milliseconds (light-on + light-off).
   :param int blink_percentage: Percentage ``(0 < p < 100)`` of the cycle where the light is on.

   .. code-block:: python

      import rgbled

      rgbled.heartbeat()                      # False (not running)
      rgbled.heartbeat(True)                  # start with defaults
      rgbled.heartbeat()                      # True

      # Blue, blink 200 ms each second
      rgbled.heartbeat(0x000000FF, 1000, 20)

      rgbled.heartbeat(False)                 # stop

      # Red, very fast blink (10 ms each 50 ms)
      rgbled.heartbeat(0x00FF0000, 50, 20)

Decoration
~~~~~~~~~~

.. py:function:: rgbled.decoration(blink_desc_list, repeat)

   Start a decorative light sequence.

   :param list blink_desc_list: A list of 4-element tuples, each describing a blinking window:
       ``(color_value, duty_period, light_on_percent, loop_count)``.
   :param bool repeat: If ``True``, repeat the whole sequence continuously.

   Each tuple element:

   * **color_value** — colour in ``0xXXRRGGBB`` format
   * **duty_period** — total duty cycle period in milliseconds
   * **light_on_percent** — percentage of the cycle with light on
   * **loop_count** — number of repetitions of this window

   .. code-block:: python

      import rgbled
      rgbled.decoration([
          (0x00001100, 100, 50, 2),     # two green pulses
          (0, 2000 - 200, 0, 1),        # off between green and blue
          (0x00000011, 100, 50, 2),     # two blue pulses
          (0, 2000 - 200, 0, 1),        # off after blue
          (0x00110000, 500, 100, 1),    # red period
          (0x00111100, 500, 100, 1),    # yellow period
          (0, 1000, 0, 1)              # off before repeat
      ], True)

Predefined Colours
~~~~~~~~~~~~~~~~~~

.. py:class:: rgbled._color

   Class carrying basic colour definitions.  Can be used directly in place of
   colour values.

   Available constants:

   * ``rgbled._color.RED``
   * ``rgbled._color.GREEN``
   * ``rgbled._color.BLUE``
   * ``rgbled._color.YELLOW``
   * ``rgbled._color.MAGENTA``
   * ``rgbled._color.CYAN``
   * ``rgbled._color.WHITE``

   .. code-block:: python

      import rgbled
      rgbled.color(rgbled._color.RED)
      rgbled.color(rgbled._color.GREEN)
      rgbled.color(rgbled._color.BLUE)
