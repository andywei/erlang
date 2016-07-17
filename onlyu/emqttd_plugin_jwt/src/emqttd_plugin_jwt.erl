%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2016 11:45 PM
%%%-------------------------------------------------------------------

%% @doc emqttd jwt plugin.
-module(emqttd_plugin_jwt).

-export([load/0, unload/0]).

load() ->
    {ok, {Alg, Key}} = application:get_env(?MODULE, auth),
    ok = emqttd_access_control:register_mod(auth, emqttd_auth_jwt, {Alg, Key}),
    with_acl_enabled(fun(A, K) ->
        ok = emqttd_access_control:register_mod(acl, emqttd_acl_jwt, {A, K})
    end).

unload() ->
    emqttd_access_control:unregister_mod(auth, emqttd_auth_jwt),
    with_acl_enabled(fun(_Alg, _Key) ->
        emqttd_access_control:unregister_mod(acl, emqttd_acl_jwt)
    end).

with_acl_enabled(Fun) ->
    case application:get_env(?MODULE, acl) of
        {ok, {Alg, Key}} -> Fun(Alg, Key);
        undefined    -> ok
    end.
