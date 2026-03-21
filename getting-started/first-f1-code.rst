Your First F1 Code
==================

The F1 smart module has MicroPython pre-installed as its operating system (OS),
which is equipped with REPL. REPL stands for Read-Eval-Print Loop -- an
interactive interpreter mode that allows you to input code, execute it, and
immediately see the results.

Using the CtrlR Plugin, open and connect a device -- or use a serial terminal
(PuTTY, screen, picocom, etc.). Upon connecting, there should be a blank screen
with a flashing cursor. Press Enter and a MicroPython prompt should appear, i.e.
``>>>``. Let's make sure it is working with the obligatory test:

.. code-block:: python

   >>> print("Hello F1!")
   Hello F1!

In the example above, the ``>>>`` characters should not be typed. They are there
to indicate that the text should be placed after the prompt. Once the text has
been entered (``print("Hello F1!")``) and Enter has been pressed, the output
should appear on screen, identical to the example above.

Basic Python commands can be tested out in a similar fashion.

If this is not working, try either a hard reset or a soft reset; see below.

Resetting the Device
--------------------

If something goes wrong, the device can be reset with two methods: hard reset and
soft reboot.

Hard reset
^^^^^^^^^^

Press the RESET button on the F1 Starter Kit (or apply a high signal to the F1
module reset signal). The F1 module will reset itself.

Please notice that any serial/COM port connection will reset and may need to be
manually reconnected if the auto-connect option is not enabled in the CtrlR
plugin.

After reset, the normal MicroPython boot message will appear in the terminal of
the CtrlR plugin or other serial terminals that have been connected, as shown
below:

.. image:: /_static/images/getting-started/first-f1-code/Documentation_F1_hard_reset.jpg
   :width: 80%
   :alt: F1 hard reset terminal output

Soft reboot
^^^^^^^^^^^

Press **Ctrl-D** at the MicroPython prompt to perform a soft reset. A soft reboot
message will appear in the terminal of the CtrlR plugin or other serial terminals
that have been connected, as shown below:

.. image:: /_static/images/getting-started/first-f1-code/Documentation_F1_soft_reset.jpg
   :width: 80%
   :alt: F1 soft reboot terminal output
