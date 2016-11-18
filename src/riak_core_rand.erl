-module(riak_core_rand).

%% API
-export([
         uniform/1,
         uniform_s/2,
         seed/0,
         seed/1,
         rand_seed/0
        ]).

-define(PRIME1, 30269).
-define(PRIME2, 30307).
-define(PRIME3, 30323).

%%%===================================================================
%%% API
%%%===================================================================
-ifdef(rand_module).
uniform(N) ->
    rand:uniform(N).

uniform_s(N, State) ->
    {rand:uniform(N), State}.

seed() ->
    %% rand module does not need it, just return the same value
    {0,0,0}.

seed({A1, A2, A3}) ->
    %% copy from the random.erl
    %% but we still need it?
    {(abs(A1) rem (?PRIME1-1)) + 1,   % Avoid seed numbers that are
     (abs(A2) rem (?PRIME2-1)) + 1,   % even divisors of the
     (abs(A3) rem (?PRIME3-1)) + 1}.  % corresponding primes.

rand_seed() ->
    %% rand module uses a different seed method, this function is used to be keep backward compatibility
    {0, 0, 0}.

-else.
uniform(N) ->
    riak_core_rand:uniform(N).

uniform_s(N, State) ->
    riak_core_rand:uniform_s(N, State).

seed() ->
    riak_core_rand:seed().

seed({A, B, C}) ->
    riak_core_rand:seed({A, B, C}).

rand_seed() ->
    %% We need to do this since passing in a seed that isn't
    %% properly formated causes horrors!
    OldSeed = random:seed(),
    Result = random:seed({erlang:phash2([node()]),
                          erlang:monotonic_time(),
                          erlang:unique_integer()}),
    random:seed(OldSeed),
    Result.

-endif.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
