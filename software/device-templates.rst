Device Templates
=================

Scaling IoT projects is great! Until you realize that it means there'll be hundreds and thousands of devices that you have to configure. By hand.

A Device Template solves this problem: you set up one template that tells a device how to collect and display its data, then apply to all.

You can expect:

- Consistent data handling - All devices using the template store and display data identically
- Unified dashboards - Shared dashboard layouts and widgets
- Bulk management - Update the template to change all associated devices
- Scalability - Essential for managing multiple devices


See how each component comes together to set up your own Device Template:

- :ref:`Device Fields <dt-fields>`
- :ref:`Dashboard Layout <dt-dashboard>`
- :ref:`Switch project <mp-switch>`
- :ref:`Associated Devices <dt-devices>`
- :ref:`Software releases <dt-releases>`
- :ref:`Automation <dt-automation>`


.. _dt-fields:

Fields
------------------

All devices using the same template share identical dashboard configurations. This includes:

- **Dashboard layout:** Configure types, positions, and sizes of the widgets on each device dashboard. This dashboard is located on each device details.
- **Widget data sources:** Configure data souce fields of each widget. 

Details regarding the data widget settings can be found on 


.. _dt-dashboard:

Device Dashboard
------------------

All devices using the same template share identical dashboard configurations. This includes:

- **Dashboard layout:** Configure types, positions, and sizes of the widgets on each device dashboard. This dashboard is located on each device details.
- **Widget data sources:** Configure data souce fields of each widget. 

Details regarding the data widget settings can be found on Dashboard & Widgets section

.. _mp-add:

Add Project
-----------

To set up new projects, click on "Add project" and follow the prompts. These can
always be changed later in "Settings".

.. image:: /_static/images/ctrl/managing-projects/Ctrl-Create-New-Project.png
   :width: 80%
   :alt: Create new project in Ctrl

.. _mp-switch:

Switch Project
--------------

Switch between different projects simply by selecting it. The checkmark indicates
the selected project.

.. image:: /_static/images/ctrl/managing-projects/Ctrl-Switch-Project.png
   :width: 80%
   :alt: Switch between projects

.. _mp-edit:

Edit Project
------------

Update your project settings through the following steps:

1. On the target project, go to the Home tab.
2. Click the "Settings" button on the top right corner.
3. Make necessary changes.
4. Click "Confirm" to apply the changes.

.. image:: /_static/images/ctrl/managing-projects/image5.png
   :width: 80%
   :alt: Edit project settings

.. _mp-delete:

Delete Project
--------------

To delete a project, click on "...", then "Delete project". You'll be asked to
confirm this action by inputting your project name.

Upon project deletion, all related information will be deleted. **This action
cannot be undone.**

.. image:: /_static/images/ctrl/managing-projects/image6.png
   :width: 80%
   :alt: Delete project
