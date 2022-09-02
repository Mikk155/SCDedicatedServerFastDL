/*
	A simple script that adds a cooldown for respawn to maps that has survival mode disabled.
	Waiting in your dead body spot seems to be boring. so why not let dead people spec mode for some seconds?
	

	"plugin"
	{
		"name" "Cooldown On Respawn"
		"script" "mikk/respawn_cooldown"
	}
*/

// This is the time players must wait to resurrect
// 0 = based on mp_respawndelay cvar.

float RespawnDelay = 30;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

void MapStart()
{
	if( g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 0 )
	{
		g_Scheduler.SetTimeout( "SurvivalModeEnable", 10.0f );
		g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
		g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
	}
	if( RespawnDelay == 0 )
	{
		RespawnDelay = g_EngineFuncs.CVarGetFloat( "mp_respawndelay" );
	}
}

void SurvivalModeEnable()
{
	g_Scheduler.SetInterval( "CheckTime", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);

	g_SurvivalMode.Activate( true );
	g_SurvivalMode.Enable();
	
	g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "On respawn cooldown ("+RespawnDelay+"s) activated.\n" );
}

HUDTextParams SpawnCountHudText;

void CheckTime()
{
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
			ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs + int(RespawnDelay) );
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