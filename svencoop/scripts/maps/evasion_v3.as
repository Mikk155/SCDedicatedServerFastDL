#include "point_checkpoint"
#include "beast/game_hudsprite"

#include "opfor/nvision"

#include "mikk/entities/utils"
#include "mikk/entities/trigger_once_mp"
#include "cubemath/polling_check_players"

const float flSurvivalVoteAllow = g_EngineFuncs.CVarGetFloat( "mp_survival_voteallow" );

void MapInit()
{
	RegisterPointCheckPointEntity();
	RegisterGameHudSpriteEntity();
	NightVision::Enable();
	RegisterAntiRushEntity();
  poll_check();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	if( g_Engine.mapname == "evasion1_v3" )
	{
		g_SurvivalMode.SetStartOn( false );

		if( flSurvivalVoteAllow > 0 )
			g_EngineFuncs.CVarSetFloat( "mp_survival_voteallow", 0 );
	}
}

// Trigger Script for Survival Mode
void TurnOnSurvival(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_EngineFuncs.CVarSetFloat( "mp_survival_voteallow", flSurvivalVoteAllow ); // Revert to the original cvar setting as per server

	if( g_SurvivalMode.IsEnabled() && g_SurvivalMode.MapSupportEnabled() && !g_SurvivalMode.IsActive() )
		g_SurvivalMode.Activate( true );
}
