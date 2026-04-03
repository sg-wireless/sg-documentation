Dashboards & Widgets
====================

Dashboards let you customize how to view incoming data exactly as you like it.
After all, the true value of data lies in the insights that can be drawn from it,
and having the data organized definitely helps!

.. note::

   We're assuming that you have already connected your device to Ctrl. In case
   you haven't, check how to :doc:`add your device </getting-started/ztp>`.
   After you're done with that, you can proceed to the next example.

You can view data in various ways, using **widgets**. Below is an overview so you
can see which widgets will be useful for your use case. Each widget can be
configured, from the type of data it shows, to how this data is shown.

Once you have your widgets, you can arrange and rearrange them in your dashboard
in **Edit Mode**, so the data that matters most is always on top.

- :ref:`value-widget`
- :ref:`boolean-widget`
- :ref:`data-log-table-widget`
- :ref:`bar-chart-widget`
- :ref:`line-chart-widget`
- :ref:`gauge-widget`
- :ref:`map-widget`

.. _value-widget:

Value Widget
------------

Displays the latest data point of a specific data field.

By default, data points are displayed in black, but you can also set colour
thresholds for specific values (such as green for normal readings, and red for
abnormal readings).

.. _boolean-widget:

Boolean Widget
--------------

Displays the binary state of a specified data field.

Useful for logical operations with a ``True`` or ``False`` condition, such as
switch states (on/off) and device status (online/offline). You can customize the
text and colours for each condition.

.. _data-log-table-widget:

Data Log Table Widget
---------------------

Presents incoming data in timestamped, chronological order.

.. _bar-chart-widget:

Bar Chart Widget
----------------

Visualizes changes in data over time, useful for spotting patterns and trends
that may not be obvious from individual readings.

Each bar chart supports up to 10 data fields. In each bar chart, you can
customize:

- **Bar labels and colours**
- **Which Y-axis to use:** Helpful when comparing different types of data like
  temperature and humidity
- **Reference lines:** Up to 4 horizontal lines can be added for data
  comparison, such as average values or thresholds
- **Time range:** Choose from preset ranges (last hour, day, month) or set
  custom periods -- shorter for fluctuations and seasonal patterns, longer for
  long-term trends. The minimum time interval is automatically set to keep the
  chart loading quickly.
- **Data aggregation:** Show maximum, minimum, or average values for each time
  interval
- **Display options:** On/off toggle for bar labels and axis labels

.. _line-chart-widget:

Line Chart Widget
-----------------

Visualizes changes in data over time, useful for spotting patterns and trends
that may not be obvious from individual readings.

Each line chart supports up to 10 data fields. In each line chart, you can
customize:

- **Line labels and colours**
- **Which Y-axis to use:** Helpful when comparing different types of data like
  temperature and humidity
- **Reference lines:** Up to 4 horizontal lines can be added for data
  comparison, such as average values or thresholds
- **Time range:** Choose from preset ranges (last hour, day, month) or set
  custom periods -- shorter for fluctuations and seasonal patterns, longer for
  long-term trends. The minimum time interval is automatically set to keep the
  chart loading quickly.
- **Data aggregation:** Show maximum, minimum, or average values for each time
  interval
- **Display options:** On/off toggle for line labels and axis labels

.. _gauge-widget:

Gauge Widget
------------

Displays the latest data point against a performance metric.

You can choose from radial, horizontal, or vertical styles, and set threshold
ranges with custom labels and colours.

.. _map-widget:

Map Widget (coming soon)
------------------------

Displays geolocation data.

Arranging Your Widgets
----------------------

**Edit Mode** lets you arrange your widgets for a custom dashboard that works for
you.

- **Add widgets** to your dashboard
- **Edit widgets** to update their configuration
- **Delete widgets** you no longer need
- **Resize widgets** to emphasize the most important data
- **Reposition widgets** by dragging them to the desired location
