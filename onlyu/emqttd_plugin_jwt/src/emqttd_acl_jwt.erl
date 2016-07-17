%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 09. May 2016 11:45 PM
%%%-------------------------------------------------------------------

%% @doc ACL with JWT. The mqtt_client.username field is used for jwt token.
-module(emqttd_acl_jwt).

-behaviour(emqttd_acl_mod).

-include("../../../include/emqttd.hrl").

%% ACL callbacks
-export([init/1, check_acl/2, reload_acl/1, description/0]).

-record(state, {alg, key}).

-define(LOG(Format, Args), lager:info("emqttd_acl_jwt: " ++ Format, Args)).

-define(UNDEFINED(S), (S =:= undefined orelse S =:= <<>>)).

-define(IS_PUB(PubSub), PubSub =:= publish orelse PubSub =:= pubsub).

-define(IS_SUB(PubSub), PubSub =:= subscribe orelse PubSub =:= pubsub).

init({Alg, Key}) ->
    {ok, #state{alg = Alg, key = Key}}.

check_acl({#mqtt_client{username = <<$$, _/binary>>}, _PubSub, _Topic}, _State) ->
    {error, bad_username};

check_acl({Client, PubSub, Topic}, State) ->
    if
        ?IS_PUB(PubSub) -> check_pub(Client, Topic, State);
        ?IS_SUB(PubSub) -> check_sub(Client, Topic, State);
        true -> deny
    end.

%% the strict check_pub is not used until fid is included in the jwt token
%% rule of pub: one can only pub to his Fid
%%check_pub(#mqtt_client{client_id = ClientId, username = Username}, Topic, #state{key = Key}) ->
%%    Token = Username,
%%    case ejwt:parse_jwt(Token, Key) of
%%        invalid ->
%%            deny;
%%        expired ->
%%            deny;
%%        ContentMap ->
%%            check_pub_map(ContentMap, ClientId, Topic)
%%    end.
%%
%%check_pub_map(ContentMap, ClientId, Topic) ->
%%    Uid = maps:get(id, ContentMap, none),
%%    Fid = maps:get(fid, ContentMap, none),
%%    ?LOG("decode token success - ~p", [ContentMap]),
%%    ?LOG("Uid - ~p", [Uid]),
%%    ?LOG("Fid - ~p", [Fid]),
%%    if
%%        Uid == ClientId andalso Fid == Topic -> allow;
%%        true -> deny
%%    end.

%% tmp solution: allow all for pub
check_pub(_Client, _Topic, _State) -> allow.

%% rule of sub: one can only sub to his own Uid
check_sub(#mqtt_client{client_id = ClientId, username = Username}, Topic, _State) ->
    ?LOG("ClientId - ~p Username - ~p Topic - ~p", [ClientId, Username, Topic]),
    if
        ClientId == Topic andalso ClientId == Username -> allow;
        true -> deny
    end.

reload_acl(_State) -> ok.

description() -> "ACL with jwt".