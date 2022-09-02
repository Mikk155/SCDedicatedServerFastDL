/*
	simple script for remove the cooldown messages for survival start delay and activate it when it is supposed.
	also disables the ammo drop/suicide/respawn aka ammo dupe. this script will automatically detect the maps that has survival enabled and actived.
	
	
	"plugin"
	{
		"name" "survival_mode"
		"script" "mikk/survival_mode"
	}
	
	Special thanks to Outerbeast and Gaftherman for help.
	https://github.com/Outerbeast
	https://github.com/Gaftherman
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

float flSurvivalStartDelay = 10;

void MapStart()
{
	flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );
	
	if( g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1 && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1 )
	{
		g_SurvivalMode.Disable();
		g_Scheduler.SetTimeout( "SurvivalModeEnable", flSurvivalStartDelay );
		g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
		g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 0 );
		g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
	}
}

void SurvivalModeEnable()
{
	g_SurvivalMode.Activate( true );
	g_SurvivalMode.Enable();
	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 1 );
    NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
    message.WriteString( "spk buttons/bell1" );
    message.End();
}