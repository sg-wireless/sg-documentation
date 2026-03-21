AWS IoT Core
============

Whenever one of your integrated devices sends a signal to our broker, we
republish the binary payload to the endpoint specified for its integration
through MQTT connection.

Setting up your integration
---------------------------

1. Click **Integrations** on the side menu, then click "Add integration" on the
   top right corner.

   .. image:: /_static/images/ctrl/integrations/aws-step-1.png
      :width: 80%
      :alt: Add integration in Ctrl

2. Select **AWS IoT Core** as the integration type.

   .. image:: /_static/images/ctrl/integrations/aws-step-2.png
      :width: 80%
      :alt: Select AWS IoT Core

3. Complete your AWS IoT Core information.

   .. image:: /_static/images/ctrl/integrations/aws-step-3.png
      :width: 80%
      :alt: AWS IoT Core configuration form

   - **Name:** User-friendly name to identify a specific integration config.
   - **Region:** Region of your AWS instance.
   - **Endpoint:** AWS IoT Core MQTT endpoint found on the "Connection details"
     section on the upper part of the "MQTT test client" tab.

   .. image:: /_static/images/ctrl/integrations/aws-step-4.png
      :width: 80%
      :alt: AWS IoT Core endpoint

   - **Topic:** MQTT subscription topic that you define on the MQTT test client
     page.

   .. image:: /_static/images/ctrl/integrations/aws-step-5.png
      :width: 80%
      :alt: MQTT subscription topic

   - **Access key ID and secret access key:** You can find the access key ID and
     secret through the user account details page of the IAM service. Steps to
     manage the access keys can be found
     `here <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html>`_.

   .. image:: /_static/images/ctrl/integrations/aws-step-6.png
      :width: 80%
      :alt: AWS access keys

4. Click "Save" once you're done. From now on, you can start seeing the incoming
   telemetry data through the MQTT test client page of your AWS IoT service page.
