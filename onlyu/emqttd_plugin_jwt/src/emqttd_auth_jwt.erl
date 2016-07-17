%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2016 11:45 PM
%%%-------------------------------------------------------------------

%% @doc Authentication with JWT. The mqtt_client.username field is used for jwt token.
-module(emqttd_auth_jwt).

-behaviour(emqttd_auth_mod).

-include("../../../include/emqttd.hrl").

-export([init/1, check/3, description/0]).

-record(state, {alg, key}).

-define(LOG(Format, Args), lager:info("emqttd_auth_jwt: " ++ Format, Args)).
-define(UNDEFINED(S), (S =:= undefined orelse S =:= <<>>)).

init({Alg, Key}) ->
    {ok, #state{alg = Alg, key = Key}}.

check(#mqtt_client{username = Username}, Password, _State)
    when ?UNDEFINED(Username) orelse ?UNDEFINED(Password) ->
    {error, username_or_passwd_undefined};

check(#mqtt_client{client_id = ClientId}, Password, #state{alg = _Alg, key = Key}) ->
    Token = Password,
    case ejwt:parse_jwt(Token, Key) of
        invalid ->
            {error, invalid};
        expired ->
            {error, expired};
        ContentMap ->
            check_content(ContentMap, ClientId)
    end.

check_content(ContentMap, ClientId) ->
    Uid = maps:get(id, ContentMap, none),

    ?LOG("decode token success - ~p", [ContentMap]),
    ?LOG("Uid - ~p", [Uid]),
    ?LOG("ClientId - ~p", [ClientId]),

    if
        Uid == ClientId -> ok;
        true -> {error, invalid}
    end.

description() -> "Authentication with jwt".


