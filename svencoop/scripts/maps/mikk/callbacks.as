/*
	Call for Toggle survival mode.
*/
void togglesurvival( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
    if( !g_SurvivalMode.IsActive()
    or !g_SurvivalMode.IsEnabled() )
    {
        g_SurvivalMode.Activate( true );
        g_SurvivalMode.Enable();
    }
    else
    {
        g_SurvivalMode.Disable();
    }
}

/*
	Call for trigger something depending the ammt of players connected
*/
void currentplayers( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	g_EntityFuncs.FireTargets( "players_" + g_PlayerFuncs.GetNumPlayers(), null, null, USE_TOGGLE, 0.0f, 0.0f );
	// Your entities logics should be named "players_+(number of players)" stack your map logics up to 32
}

/*
	Call for implementation of "Stealth" in Episode-One series.
	Mode: Think
*/
void Stealth(CBaseEntity@ pTriggerScript)
{
    CBaseEntity@ pEnemy = null;
    while( ( @pEnemy = g_EntityFuncs.FindEntityByTargetname( pEnemy, "Vigilant" )) !is null ) // Name of the monster to watch for.
    {
        CBaseMonster@ pMoster = cast<CBaseMonster@>(pEnemy);
        
        if( pMoster.m_hEnemy.GetEntity() !is null )
        {
            CBaseEntity@ pTeleport = null;
            while( ( @pTeleport = g_EntityFuncs.FindEntityByTargetname( pTeleport, "GAME_LOSE" )) !is null ) // Name of the entity to teleport the player.
                pMoster.m_hEnemy.GetEntity().SetOrigin( pTeleport.pev.origin );

            pMoster.m_hEnemy = null;
        }
    }
}

/*
	Call for Render something progressively
	Mode: Think
	open SmartEdit and add renderamt to the trigger_script.
	when fire trigger_script it'll increase/decrease its target's renderamt until both are the same value.
	then trigger_script will self-stop
*/
void RenderProgressive(CBaseEntity@ pTriggerScript)
{
	CBaseEntity@ pEntity = null;
	while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, pTriggerScript.pev.target)) !is null)
	{
		if( pTriggerScript.pev.renderamt > pEntity.pev.renderamt )
		{
			pEntity.pev.renderamt += 1;
		}
		else
		{
			pEntity.pev.renderamt -= 1;
		}

		if( pEntity.pev.renderamt == pTriggerScript.pev.renderamt )
		{
			g_EntityFuncs.FireTargets( ""+pTriggerScript.pev.targetname+"", null, null, USE_TOGGLE );
		}
	}
}