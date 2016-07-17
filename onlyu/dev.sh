make &&
make dist &&
./rel/emqttd/bin/emqttd start &&
./rel/emqttd/bin/emqttd_ctl plugins load emqttd_plugin_observer &&
./rel/emqttd/bin/emqttd_ctl plugins load emqttd_plugin_jwt