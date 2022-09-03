/*
	simple script that 
	"plugin"
	{
		"name" "AfkManager"
		"script" "mikk/AfkManager"
	}
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );

	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}


dictionary dictSteamsID;
dictionary keyvalues;

void MapStart()
{
	g_Scheduler.SetInterval( "CheckTime", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);

	keyvalues =	{
		{ "channel", "8"},
		{ "message",			"[AFK-Manager] Say '/afk' for exiting 'Away From Keyboard' mode.\n"},
		{ "message_spanish",	"[AFK-Manager] \n"},
		{ "message_portuguese",	"[AFK-Manager] \n"},
		{ "message_german",		"[AFK-Manager] \n"},
		{ "message_french",		"[AFK-Manager] \n"},
		{ "message_italian",	"[AFK-Manager] \n"},
		{ "x", "-1"}, { "y", "0.90"}, { "holdtime", "2"}, { "fadein", "0"}, { "spawnflags", "2"}, { "color", "255 0 0"}, { "targetname", "AFKMANAGER_ADVICE" }
	};

	if( g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) )
		g_EntityFuncs.CreateEntity( "game_text_custom", keyvalues, true );
	else
		g_EntityFuncs.CreateEntity( "game_text", keyvalues, true );
}

void CheckTime()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(pPlayer is null )
			continue;

		string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( dictSteamsID.exists(SteamID) )
		{
			g_EntityFuncs.FireTargets( "AFKMANAGER_ADVICE", pPlayer, pPlayer, USE_TOGGLE );
			if( pPlayer.IsAlive() )
				pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles ,false );
		}
	}
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	if( args.ArgC() == 1 && args.Arg(0) == "/afk" )
		ToggleAfk( pPlayer );
	if( args.ArgC() == 1 && args.Arg(0) == "afk" or args.Arg(0) == "brb" )
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AFK Manager] say /afk to join spectator mode.\n" );

	return HOOK_CONTINUE;
}

void ToggleAfk( CBasePlayer@ pPlayer )
{
	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	
	if( dictSteamsID.exists(SteamID) )
		dictSteamsID.delete(SteamID);
	else
		dictSteamsID[SteamID] = @pPlayer;
}