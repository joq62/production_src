%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc : represent a logical vm  
%%% 
%%% Supports the system with standard erlang vm functionality, load and start
%%% of an erlang application (downloaded from git hub) and "dns" support 
%%% 
%%% Make and start the board start SW.
%%%  boot_service initiates tcp_server and l0isten on port
%%%  Then it's standby and waits for controller to detect the board and start to load applications
%%% 
%%%     
%%% -------------------------------------------------------------------
-module(production). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("infra.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{git_path_app_specs,git_user,git_pw,cl_dir,cl_file,app_specs_dir,dbase_nodes}).

	  
%% --------------------------------------------------------------------

-define(StartConfigFile,"./start.config").
%% ====================================================================
%% External functions
%% ====================================================================


%% server interface

-export([]).

-export([create/0,
	 config_info/0,
	 ping/0	 
	]).




-export([start/0,
	 stop/0
	 ]).
%% internal 
%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================



start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


%%----------------------------------------------------------------------
config_info()->
     gen_server:call(?MODULE,{config_info},infinity).
create()->
    gen_server:call(?MODULE,{create},infinity).

    
ping()->
    gen_server:call(?MODULE,{ping},infinity).

%%___________________________________________________________________



%%-----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    {ok,ConfigInfo}=file:consult(?StartConfigFile),
    io:format("ConfigInfo = ~p~n",[ConfigInfo]),
    {git_path_app_specs,GitPath}=lists:keyfind(git_path_app_specs,1,ConfigInfo),
    {app_specs_dir,AppSpecsDir}=lists:keyfind(app_specs_dir,1,ConfigInfo),
    GitDest="./"++AppSpecsDir,
    rpc:call(node(),file,del_dir_r,[GitDest],3000),
   
    io:format("Module, Line = ~p~n",[
				     {?LINE,?MODULE,rpc:call(node(),os,cmd,
							     ["git clone "++GitPath++" "++GitDest],10*1000)}]),
   % rpc:cast(node(),misc_log,msg,
%	     [
%	      ["Start gen server =", ?MODULE, node()],
%	      node(),?MODULE,?LINE
%	     ]),
    {git_user,GitUser}=lists:keyfind(git_user,1,ConfigInfo),
    {git_pw,GitPw}=lists:keyfind(git_pw,1,ConfigInfo),
    {cl_dir,ClDir}=lists:keyfind(cl_dir,1,ConfigInfo),
    {cl_file,ClFile}=lists:keyfind(cl_file,1,ConfigInfo),
   
    {dbase_nodes,DbaseNodes}=lists:keyfind(dbase_nodes,1,ConfigInfo),

    io:format("Module, Line = ~p~n",[{?LINE,?MODULE}]),


    {ok, #state{git_path_app_specs=GitPath,
		git_user=GitUser,
		git_pw=GitPw,
		cl_dir=ClDir,
		cl_file=ClFile,
		app_specs_dir=AppSpecsDir,
		dbase_nodes=DbaseNodes}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------

handle_call({ping}, _From, State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({config_info}, _From, State) ->
    Reply=State,
    {reply, Reply, State};


handle_call({create}, _From, State) ->
    Reply=glurk_not_implemented,
    {reply, Reply, State};


handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,?LINE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({glurk}, State) ->

    {noreply, State};

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------
