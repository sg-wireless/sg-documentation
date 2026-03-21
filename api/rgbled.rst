RGB LED
=======

By default the heartbeat LED flashes in blue colour once every 4s to signal that the system is alive. This can be overridden through the F1 starter kit command.

initialization: the module will be initialized once it is imported. after its initialization, it could be deinitialized by calling rgbled.deinit() and to initialize it again use rgbled.initialize()

rgbled.color() to set the LED color continuously. The color follows this hex formatting xxRRGGBB, in which the RR, GG and BB are representint the red, green and blue components of the color respectively and xx is a don’t care value.

.. code-block:: python

   # rgbled.heartbeat() example:
   
   import rgbled
   
   rgbled.heartbeat( False )   # stop the heartbeat service
   rgbled.color(0x00FF0000)    # sets the LED color to red
   rgbled.color(0x0000FF00)    # sets the LED color to green
   rgbled.color(0x000000FF)    # sets the LED color to blue
   rgbled.color(0x00FFFF00)    # sets the LED color to yellow

rgbled.heartbeat() to start the heartbeat blinking service. it has three signature as follows:

rgbled.heartbeat()

rgbled.heartbeat( <enable> )

rgbled.heartbeat( <color>, <cycle-time>, <blink-percentage> )

The description of each signature is as follows:

Check the current status of the heartbeat service and returns True or False.

To enable/disable the service

To set new configuration for the service and start or restart it

The description of the available argument are:

<enable> the enable or disable flag and it is a boolean value.

<color> the color value similar to the rgbled.color() function.

<cycle-time> the total period of the duty-cycle (the light on + light off periods).

<blink-percentage> the percentage(p) value (0 < p < 100) where the light is on

.. code-block:: python

   # rgbled.heartbeat() example:
   
   import rgbled
   
   rgbled.heartbeat()             # check the status of the service
          # returns False
   
   rgbled.heartbeat( True )       # start the heartbeat service
          # start with the default configs
   
   rgbled.heartbeat()             # check the status of the service
          # returns True
   
   # to set the blue color blinking for about 200 msec each one second.
   
   rgbled.heartbeat(0x000000FF, 1000, 20)    # new config is set and service restarted
   rgbled.heartbeat()                        # check the status of the service
          # returns True
   
   rgbled.heartbeat( False )                 # stop the heartbeat service
   
   # to set the red color blinking for about 10 msec each 50 ms. (very fast)
   
   rgbled.heartbeat(0x00FF0000, 50, 20)      # new config is set and service started
   rgbled.heartbeat()                        # check the status of the service
          # returns True
   rgbled.heartbeat( True )                  # start the heartbeat service
          # it will start with latest config (0x00FF0000, 50, 20)
   
   rgbled.heartbeat()                        # check the status of the service
          # returns True

rgbled.decoration() It provide a fancy way of doing a decorative light blinking by specifying a sequence of blinking descriptors. it follows the following syntax:

rgbled.decoration()
-------------------

It provides a fancy way of doing a decorative light blinking by specifying a
sequence of blinking descriptors. It follows the following syntax::

   rgbled.decoration( <blink-desc-list>, <repeat> )

   <blink-desc-list> ::= [ <blink-desc-tuple>, ... ]

   <blink-desc-tuple> ::= ( <color-value>, <duty-period>, <light-on-percent>, <loop-count> )

where:

<blink-desc-list> is a list of four elements tuples to describe a time window of blinking.

<blink-desc-tuple> a tuple which specify a time window of blinking.

<color-value> the color value as described in rgbled.color()

<duty-period> the total light blinking duty cycle

<light-on-percent> the ligh on time percentage of the duty cycle period

<loop-count> number of repetition of this duty cycle period

.. code-block:: python

   # assume we want the following time light sequence
   #  
   #  ___ 50 ___         ___ 50 ___           __________ __________ 
   # | G |__| G |_______| B |__| B |_________|    R     |     Y    |
   # |--------2 Sec-----|--------2 Sec-------|- 0.5 sec-|- 0.5 sec-|
   # 
   # where G and R period are 50 msec
   # The sequence above shall be repeated and a one second color should be
   # off between each repetition
   #
   
   import rgbled
   
   rgbled.decoration([
     (0x00001100, 100, 50, 2),   # the first two G's pulses
     (0, 2000 - 200, 0, 1),      # the light off between G's and B's pulses
     (0x00000011, 100, 50, 2),   # the second two B's pulses
     (0, 2000 - 200, 0, 1),      # the light off after b's pulses
     (0x00110000, 500, 100,1),   # the R period
     (0x00111100, 500, 100,1),   # the Y period
     (0, 1000, 0, 1)             # the light off time before repeating
   ],
   True)                         # repeat the whole sequence again

Here is the expected result:

rgbled._color it is a class carrying the basic color definitions, it can be used directly in place of the color value.

.. code-block:: python

   import rgbled
   
   rgbled.color( rgbled._color.RED )
   rgbled.color( rgbled._color.GREEN )
   rgbled.color( rgbled._color.BLUE )
   rgbled.color( rgbled._color.YELLOW )
   rgbled.color( rgbled._color.MAGENTA )
   rgbled.color( rgbled._color.CYAN )
   rgbled.color( rgbled._color.WHITE )
