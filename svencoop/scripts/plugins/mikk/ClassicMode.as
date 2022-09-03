void MapInit()
{
	g_Scheduler.SetInterval( "AsignModels", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );

	for( uint i = 0; i < ArrayNpcs.length(); ++i )
	{
		g_Game.PrecacheModel( "models/mikk/kezaeiv/" + string(ArrayNpcs[i]) + "_classic.mdl" );
	}
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

dictionary keyvalues;

void MapActivate()
{
	for( uint i = 0; i < ArrayNpcs.length(); ++i )
	{
		keyvalues ={{"target","!activator"},{ "model","models/mikk/kezaeiv/"+string(ArrayNpcs[i])+"_classic.mdl"},{"targetname",ArrayNpcs[i]+"_classic"}};
		g_EntityFuncs.CreateEntity( "trigger_changemodel", keyvalues, true );
	}
}


array<string> ArrayNpcs = {
	"monster_alien_grunt",
	"monster_gonome",
	"monster_pitdrone",
	"monster_alien_voltigore",
	"monster_barney",
	"monster_bullchicken",
	"monster_human_assassin",
	"monster_male_assassin",
	"monster_human_grunt",
	"monster_human_grunt_ally",
	"monster_human_medic_ally",
	"monster_human_torch_ally",
	"monster_robogrunt",
	"monster_shocktrooper",
	"monster_zombie",
	"monster_zombie_barney",
	"monster_alien_tor"
};

void AsignModels()
{
	for( uint i = 0; i < ArrayNpcs.length(); ++i )
	{
		CBaseEntity@ pMonsters = null;
		while( ( @pMonsters = g_EntityFuncs.FindEntityByClassname ( pMonsters, ArrayNpcs[i] ) ) !is null )
		{
			if( !string( pMonsters.pev.model ).StartsWith ( "models/mikk/kezaeiv/" ) )
			{
				g_EntityFuncs.FireTargets( string(pMonsters.pev.classname)+"_classic", pMonsters, pMonsters, USE_TOGGLE );
				g_Game.AlertMessage( at_console, "DEBUG-:"+string(pMonsters.pev.classname)+" Chaged model to "+string(pMonsters.pev.model)+"\n" );
			}
		}
	}
}