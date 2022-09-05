#include "point_checkpoint"

#include "beast/npc_transition"

#include "DefaultCampaigns"
#include "cubemath/polling_check_players"

const float flSurvivalVoteAllow = g_EngineFuncs.CVarGetFloat( "mp_survival_voteallow" );

void MapInit()
{
	// Enable SC CheckPoint Support for Survival Mode
	RegisterPointCheckPointEntity();
	// Global CVars
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 0 );

	NPC_TRANSITION::EntityRegister();
  poll_check();

	if( g_Engine.mapname == "of_utbm_7" || g_Engine.mapname == "of_utbm_8" || g_Engine.mapname == "of_utbm_9" )
		Precache();

	if( g_Engine.mapname == "of_utbm" )
	{
		g_SurvivalMode.SetStartOn( false );

		if( flSurvivalVoteAllow > 0 )
			g_EngineFuncs.CVarSetFloat( "mp_survival_voteallow", 0 );
	}
	LPMapInitialization();
}

void MapActivate()
{
	LPMapActivate();
}

void MapStart()
{
	if( g_Engine.mapname == "of_utbm_7" || g_Engine.mapname == "of_utbm_8" || g_Engine.mapname == "of_utbm_9" )
		InitXenReturn();
}

void Precache()
{
	g_Game.PrecacheModel( "sprites/exit1.spr" );
	g_Game.PrecacheGeneric( "sprites/exit1.spr" );
	g_SoundSystem.PrecacheSound( "weapons/displacer_self.wav" );
}

void InitXenReturn()
{
	CBaseEntity@ pXenReturnDest;

	dictionary xenfx =
	{
		{ "targetname", "xen_return_spawnfx" },
		{ "m_iszScriptFunctionName", "XenReturnFx" },
		{ "m_iMode", "1" }
	};
	g_EntityFuncs.CreateEntity( "trigger_script", xenfx, true );

	while( ( @pXenReturnDest = g_EntityFuncs.FindEntityByTargetname( pXenReturnDest, "xen_return_dest*") ) !is null )
	{
		if( pXenReturnDest.GetClassname() != "info_teleport_destination" )
			continue;

		if( pXenReturnDest.pev.SpawnFlagBitSet( 32 ) )
			continue;

		pXenReturnDest.pev.spawnflags |= 32;
		pXenReturnDest.pev.target = "xen_return_spawnfx";
	}
}

void XenReturnFx(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if( pActivator is null )
		return;

	CSprite@ pSprite = g_EntityFuncs.CreateSprite( "sprites/exit1.spr", pActivator.GetOrigin(), true, 0.0f );
	pSprite.SetScale( 1 );
	pSprite.SetTransparency( kRenderTransAdd, 0, 0, 0, 200, kRenderFxNoDissipation );
	pSprite.AnimateAndDie( 18 );

	g_SoundSystem.EmitSound( pActivator.edict(), CHAN_ITEM, "weapons/displacer_self.wav", 1.0f, ATTN_NORM );
}

void TurnOnSurvival(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	g_EngineFuncs.CVarSetFloat( "mp_survival_voteallow", flSurvivalVoteAllow ); // Revert to the original cvar setting as per server

	if( g_SurvivalMode.IsEnabled() && g_SurvivalMode.MapSupportEnabled() && !g_SurvivalMode.IsActive() )
		g_SurvivalMode.Activate( true );
}
