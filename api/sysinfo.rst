:mod:`sysinfo` --- System Information
=====================================

.. module:: sysinfo
   :synopsis: Board, version, and flash information

The ``sysinfo`` module collects and displays information from different system
components.


Board Information
-----------------

.. function:: sysinfo.board()

   Return a named tuple with board information fields:

   - ``full_name`` --- complete board name (e.g. ``SGW3201-F1-L-OEM``)
   - ``platform`` --- platform name (e.g. ``F1``)
   - ``module_name`` --- OEM module name (``F1``, ``F1-C``, ``F1-L``, ...)
   - ``module_number`` --- part number (``SGW3201``, ``SGW3501``, ...)
   - ``shield`` --- shield name (``StarterKit``) or ``OEM``

   .. code-block:: python

      import sysinfo
      info = sysinfo.board()
      print(info.full_name)      # SGW3201-F1-L-OEM
      print(info.module_name)    # F1-L

.. function:: sysinfo.show_board()

   Display board information on the REPL.


Version Information
-------------------

.. function:: sysinfo.version()

   Return a named tuple with firmware version fields:

   - ``major``, ``minor``, ``patch`` --- version components
   - ``git_delta`` --- commits since base release
   - ``git_tag`` --- short git hash (8 chars)
   - ``build_date``, ``build_time`` --- build timestamp
   - ``custom`` --- custom version string or ``dirty``
   - ``release`` --- base release version (e.g. ``v0.1.0``)
   - ``build`` --- full build version string

   .. code-block:: python

      ver = sysinfo.version()
      print(ver.release)       # v0.1.0
      print(ver.build)         # v0.1.0-1-0b532043-20240418-dirty

.. function:: sysinfo.show_version()

   Display firmware version information on the REPL.


Other Information
-----------------

.. function:: sysinfo.show_efuses()

   Display eFuse information (LoRa MAC, Serial Number, HW ID, WiFi MAC).

.. function:: sysinfo.show_flash()

   Display flash storage information and the deployed partition table.

.. function:: sysinfo.show_spiram()

   Display SPIRAM size information.

.. function:: sysinfo.show_all()

   Display all system information (board + version + eFuses + flash + SPIRAM).
