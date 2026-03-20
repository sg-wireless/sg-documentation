:mod:`can` --- CAN Bus Interface
================================

.. module:: can
   :synopsis: CAN bus send/receive interface

The ``can`` module provides a CAN bus interface for sending and receiving
CAN frames.


Functions
---------

.. function:: can.init([RxPin=1, TxPin=2, Baud=250000, Mode=0])

   Initialize the CAN interface.

   :param int RxPin: Receive pin number.
   :param int TxPin: Transmit pin number.
   :param int Baud: Baud rate.  Supported values: 25000, 50000, 100000,
       125000, 250000, 500000, 800000, 1000000.
   :param int Mode: CAN mode --- 0 = NORMAL, 1 = NO ACK, 2 = LISTEN_ONLY.

.. function:: can.deinit()

   Deinitialize the CAN interface.

.. function:: can.send(flags, id, dat)

   Send a CAN message.

   :param int flags: Message flags bitfield:

      - Bit 0: Extended frame (1) / Standard frame (0)
      - Bit 1: Remote frame (1) / Data frame (0)
      - Bit 2: Single send (1) / Error resend (0)
      - Bit 3: Self-receive (1) / Ignore own messages (0)
      - Bit 4: DLC > 8 non-standard (1) / ISO 11898-1 (0)

   :param int id: Message identifier.
   :param dat: Data to send (string or bytes).

.. function:: can.filter(dat, single_filter)

   Set a CAN acceptance filter.

   :param dat: Filter data (8 bytes: 4-byte acceptance code + 4-byte mask).
   :param bool single_filter: Use single filter mode.

.. function:: can.any()

   Return non-zero if CAN messages are available.

.. function:: can.recv()

   Receive a CAN message.

   :returns: Bytes containing the received message.


Example
-------

.. code-block:: python

   import can, time

   can.init(RxPin=39, TxPin=38, Baud=100000, Mode=0)

   # Set acceptance filter (accept all)
   dat = (0).to_bytes(4, 'little') + (0xFFFFFFFF).to_bytes(4, 'little')
   can.filter(dat, True)

   while True:
       if can.any():
           data = can.recv()
           print(data.hex(' '))
       time.sleep(0.01)
