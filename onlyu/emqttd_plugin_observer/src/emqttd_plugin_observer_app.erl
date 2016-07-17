%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 25. Apr 2016 8:35 PM
%%%-------------------------------------------------------------------

%% @doc emqttd plugin observer application.
-module(emqttd_plugin_observer_app).

-behaviour(application).

%% Application callbacks
-export([start/2, prep_stop/1, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqttd_plugin_observer_sup:start_link(),
    emqttd_plugin_observer:load(application:get_all_env()),
    {ok, Sup}.

prep_stop(State) ->
    emqttd_plugin_observer:unload(), State.

stop(_State) ->
    ok.