/*
	simple script that makes survival mode (Both disabled and enabled) better.
	
	if survival mode is disabled dead people can join spec mode for some seconds before they can respawn.
	looking from your dead body seems to be boring sometimes x[
	
	ammo dupe or duplication on death is disabled while survival is disabled.
	
	if survival mode is enabled the messages on the screen saying "Survival will start in X seconds" are removed.
	
	"plugin"
	{
		"name" "SurvivalManager"
		"script" "mikk/SurvivalManager"
	}
	
	Special thanks to these people
	
	Outerbeast		https://github.com/Outerbeast
	Gaftherman		https://github.com/Gaftherman
	Duk0			https://github.com/Duk0
*/

// Starts of customizable zone.

// 0 = Disable players votes
// 1 = Enable players votes
float flSurvivalVoteEnabled = 1;

// Time ( in seconds ) that the vote will be on cooldown when a vote ends.
float flCooldown = 360;

// 0 = Survival mode depends on map support.
// 1 = Survival mode will starts always on.
// 2 = Survival mode will starts always off.
float flSurvivalStartsMode = 0;

// Time ( OVERRIDES MAPS ) in seconds that survival will take before initiate.
// 0 = get mp_survival_startdelay value.
float flSurvivalStartDelay = 0;

// Time in seconds that player must wait to resurrect.
// 0 = based on mp_respawndelay value.
float flRespawnDelay = 10;

// Ends of customizable zone.

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

string g_szPlayerName;

bool blSurvivalIs = false;

float flSurvivalWas = 1;
float flNoMoreVotes = 0;
float flSMMEnable	= 0;
float flSMMDisable	= 0;

CTextMenu@ g_VoteMenu;

void MapInit()
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	if( flSurvivalStartDelay != 0 )
	{
		flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );
	}

	// Maps decide.
	if( flSurvivalStartsMode == 0 )
	{
		flSurvivalWas = g_EngineFuncs.CVarGetFloat( "mp_survival_supported" );
	}

	// Add delay based on cvar if not specified.
	if( flRespawnDelay == 0 )
	{
		flRespawnDelay = g_EngineFuncs.CVarGetFloat( "mp_respawndelay" );
	}

	// DO NOT CHANGE INTERVAL TIME
	g_Scheduler.SetInterval( "CheckTime", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
	
}

void MapActivate()
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	// Enable survival mode and use our own mode.
	g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
	g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
	g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 1 );
	g_SurvivalMode.Activate( true );
	g_SurvivalMode.Enable();
	g_Scheduler.SetTimeout( "InitializeSurvivalIsON", flSurvivalStartDelay );
}

void InitializeSurvivalIsON()
{
	// Starts off
	if( flSurvivalStartsMode == 2 )
		return;


	// Starts on
	if( flSurvivalStartsMode == 1 )
	{
		blSurvivalIs = true;
		Sound( 1 );
	}
	
	// Maps decide.
	if( flSurvivalStartsMode == 0 && flSurvivalWas == 1 )
	{
		blSurvivalIs = true;
	}
}

CClientCommand g_SurvivalCommand( "survival", "Enable/Disable survival mode.", @ManipulateSurvival, ConCommandFlag::AdminOnly);

void ManipulateSurvival(const CCommand@ pArguments)
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	if( pArguments.Arg(0) == ".survival" )
	{
		if( pArguments.Arg(1) == "enable" || pArguments.Arg(1) == "1" )
		{
			Sound( 1 );
			blSurvivalIs = true;
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Survival Manager] Survival mode enabled by an admin.\n" );
		}
		if( pArguments.Arg(1) == "disable" || pArguments.Arg(1) == "0" )
		{
			Sound( 0 );
			blSurvivalIs = false;
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Survival Manager] Survival mode disabled by an admin.\n" );
		}
	}
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();

	if ( pArguments.ArgC() >= 1 )
	{
		string szArg = pArguments.Arg( 0 );
		szArg.Trim();
		if ( szArg.ICompare( "/survival" ) == 0 )
		{
			CBasePlayer@ pPlayer = pParams.GetPlayer();

			if ( pPlayer is null || !pPlayer.IsConnected() )
				return HOOK_CONTINUE;

			if( flNoMoreVotes > 1 )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Wait "+flNoMoreVotes+" before start a vote.\n" );
				return HOOK_CONTINUE;
			}

			if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] This map uses a MapScript version.\n" );
				return HOOK_CONTINUE;
			}
			
			CallSurvivalVote( pPlayer );
		}
		if ( szArg.ICompare( "survival" ) == 0 || szArg.ICompare( "spawn" ) == 0 || szArg.ICompare( "join" ) == 0 )
		{
			CBasePlayer@ pPlayer = pParams.GetPlayer();

			if ( pPlayer is null || !pPlayer.IsConnected() )
				return HOOK_CONTINUE;

			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] say /survival to start a vote.\n" );
		}
	}
	return HOOK_CONTINUE;
}

void CallSurvivalVote( CBasePlayer@ pPlayer )
{
	if ( flSurvivalVoteEnabled == 0 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] This type of vote is disabled.\n" );
		return;
	}

	g_szPlayerName = pPlayer.pev.netname;

	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ AllPlayers = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(AllPlayers is null )
			continue;
			
		OpenMenuSurvivalManager( AllPlayers );
	}

	if ( g_szPlayerName.IsEmpty() )
		g_szPlayerName = "*Empty*";
	
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Survival Manager] Vote started by " + g_szPlayerName + "\n" );

	// Timeout vote
	g_Scheduler.SetTimeout( "VoteEndCallBack", 15.0f );
	g_Scheduler.SetTimeout( "VoteEndCallBackEnd", 16.0f );
	
	// Block votes.
	flNoMoreVotes = int(flCooldown);
}

void OpenMenuSurvivalManager( CBasePlayer@ pPlayer )
{
	@g_VoteMenu = CTextMenu( @MainCallback );
	g_VoteMenu.SetTitle( "Survival Mode Vote\n" );
	g_VoteMenu.AddItem( "Enable" );
	g_VoteMenu.AddItem( "Disable" );
	g_VoteMenu.Register();
	g_VoteMenu.Open( 2, 0, pPlayer );
}

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
	if( pItem !is null )
	{
		string sChoice = pItem.m_szName;
		if( sChoice == "Enable"	 )
		{
			flSMMEnable = flSMMEnable + 1;
			g_Game.AlertMessage( at_console, "Float flSMMEnable +1 now "+flSMMEnable+"\n" );
		}
		else
		if( sChoice == "Disable" )
		{
			flSMMDisable = flSMMDisable + 1;
			g_Game.AlertMessage( at_console, "Float flSMMDisable +1 now "+flSMMDisable+"\n" );
		}
	}
}

void VoteEndCallBack()
{
	if ( flSMMEnable >= flSMMDisable )
	{
		Sound( 0 );
		blSurvivalIs = true;
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Survival Manager] Vote passed for Enable survival mode.\n" );
	}
	else
	{
		Sound( 1 );
		blSurvivalIs = false;
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "[Survival Manager] Vote passed for Disable survival mode.\n" );
	}
	g_Game.AlertMessage( at_console, "Float flSMMDisable "+flSMMDisable+" Float flSMMEnable "+flSMMEnable+"\n" );
}

void VoteEndCallBackEnd()
{
	flSMMDisable = 0;
	flSMMEnable = 0;
	g_Game.AlertMessage( at_console, "Float flSMMDisable and flSMMEnable restarted.\n" );
}

void Sound( int dropmode )
{
	// Anti-Ammo duplication
	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", int( dropmode ) );

	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
	message.WriteString( "spk buttons/bell1" );
	message.End();
}

HUDTextParams SpawnCountHudText;

void CheckTime()
{
	if( flNoMoreVotes >= 1 )
		flNoMoreVotes = flNoMoreVotes - 1;
	
	if( blSurvivalIs )
		return;

	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(pPlayer is null )
			continue;

		CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
		int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_survivaln_t").GetInteger();

		if( kvSpawnIs <= 0 && pPlayer.IsAlive() )
		{
			g_Game.AlertMessage( at_console, "continue "+pPlayer.pev.netname+" time "+kvSpawnIs+"\n" );
			ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs + int( flRespawnDelay ) );
			continue;
		}

		if( kvSpawnIs >= 0 )
		{
			if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
			{
				SpawnCountHudText.x = -1;
				SpawnCountHudText.y = -1;
				SpawnCountHudText.effect = 0;
				SpawnCountHudText.r1 = RGBA_SVENCOOP.r;
				SpawnCountHudText.g1 = RGBA_SVENCOOP.g;
				SpawnCountHudText.b1 = RGBA_SVENCOOP.b;
				SpawnCountHudText.a1 = 0;
				SpawnCountHudText.r2 = RGBA_SVENCOOP.r;
				SpawnCountHudText.g2 = RGBA_SVENCOOP.g;
				SpawnCountHudText.b2 = RGBA_SVENCOOP.b;
				SpawnCountHudText.a2 = 0;
				SpawnCountHudText.fadeinTime = 0; 
				SpawnCountHudText.fadeoutTime = 0.25;
				SpawnCountHudText.holdTime = 2;
				SpawnCountHudText.fxTime = 0;
				SpawnCountHudText.channel = 8;

				g_PlayerFuncs.HudMessage(pPlayer, SpawnCountHudText, "Spawn in " + kvSpawnIs +" seconds\n" );

				ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs - 1 );
				g_Game.AlertMessage( at_console, ""+pPlayer.pev.netname+" time "+kvSpawnIs+"\n" );
			}

			if( kvSpawnIs == 0 )
			{
				g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
			}
		}
	}
}