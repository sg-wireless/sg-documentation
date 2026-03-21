Webhook
=======

Whenever one of your integrated devices sends a signal to Ctrl, we perform an
HTTP request defined by the user. You can use some presets (``DEVICE_TOKEN``,
``USER_ID``, etc.), which will act like placeholders and will be dynamically
replaced at the moment of performing the request with the relative content.

Setting up your integration
---------------------------

1. Click **Integrations** on the side menu, then click "Add integration" on the
   top right corner.

   .. image:: /_static/images/ctrl/integrations/webhook-step-1.png
      :width: 80%
      :alt: Add integration in Ctrl

2. Select **Webhook** as the integration type.

   .. image:: /_static/images/ctrl/integrations/webhook-step-2.png
      :width: 80%
      :alt: Select Webhook

3. Input a friendly name to identify the webhook integration and the webhook URL
   where the payloads will be sent to. Additionally, you can configure your custom
   HTTP headers.

   .. note::

      For testing, you can use the URL generated from https://webhook.site/.

   .. image:: /_static/images/ctrl/integrations/webhook-step-3.png
      :width: 80%
      :alt: Webhook configuration form

4. Click "Save" when you are done. You should be able to see the incoming Ctrl
   telemetry data on your destination system.
