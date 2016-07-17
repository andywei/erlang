
## emqttd plugin observer

This is a plugin for onlyu emqttd project.

The observer listens to 'client.connected', 'client.disconnected' and 'message.publish' events, and writes the events
to a queue (e.g., NSQ).

There will be a reader reading the queue and perform some actions, e.g. send push notifications.

