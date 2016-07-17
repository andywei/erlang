%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2016 11:45 PM
%%%-------------------------------------------------------------------

%% @doc emqttd jwt plugin application
-module(emqttd_plugin_jwt_app).

-behaviour(application).

%% Application callbacks
-export([start/2, prep_stop/1, stop/1]).

%%--------------------------------------------------------------------
%% Application callbacks
%%--------------------------------------------------------------------

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqttd_plugin_jwt_sup:start_link(),
    emqttd_plugin_jwt:load(),
    {ok, Sup}.

prep_stop(State) ->
    emqttd_plugin_jwt:unload(),
    State.

stop(_State) ->
    ok.

