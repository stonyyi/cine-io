# Cine.io

Hassle-free live-streaming.

Configure device-agnostic live-streaming for your app in minutes.


# How to run the signaling server under SSL in development

1. Obtain the SSL certificate files for localhost.cine.io and save them to your local system.
2. Invoke the server in this way:

   ```bash
   $ SSL_CERTS_PATH=../certificates RUN_AS=signaling PORT=8443 coffee server.coffee
   ```
