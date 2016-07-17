%%%-------------------------------------------------------------------
%%% @author ping
%%% @copyright (C) 2016, Joyy Inc. All rights reserved.
%%% @doc
%%%
%%% @end
%%% Created : 25. Apr 2016 8:35 PM
%%%-------------------------------------------------------------------

%% @doc emqttd plugin observer supervisor.
-module(emqttd_plugin_observer_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    start_ekaf(),
    {ok, { {one_for_one, 5, 10}, []} }.

%% @doc config and start ekaf
start_ekaf() ->
    {ok, Broker} = application:get_env(emqttd_plugin_observer, ekaf_bootstrap_broker),
    application:set_env(ekaf, ekaf_bootstrap_broker, Broker),

    {ok, PerPartitionWorkers} = application:get_env(emqttd_plugin_observer, ekaf_per_partition_workers),
    application:set_env(ekaf, ekaf_per_partition_workers, PerPartitionWorkers),

    {ok, MaxBufferSize} = application:get_env(emqttd_plugin_observer, ekaf_max_buffer_size),
    application:set_env(ekaf, ekaf_max_buffer_size, MaxBufferSize),

    {ok, PartitionStrategy} = application:get_env(emqttd_plugin_observer, ekaf_partition_strategy),
    application:set_env(ekaf, ekaf_partition_strategy, PartitionStrategy),

    {ok, PartitionPicker} = application:get_env(emqttd_plugin_observer, ekaf_callback_custom_partition_picker),
    application:set_env(ekaf, ekaf_callback_custom_partition_picker, PartitionPicker),

    ekaf:start().
