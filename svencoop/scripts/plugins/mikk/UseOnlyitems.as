/*
	Simple script that requires players press E on items to take them.
	
	"plugin"
	{
		"name" "UseOnlyItems"
		"script" "mikk/UseOnlyItems"
	}
*/
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
	
	g_Scheduler.SetInterval( "EntityCreate", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

array<string> Items = { "weapon_*", "item_healthkit", "item_battery", "ammo_*" };

void EntityCreate()
{
	for( uint i = 0; i < Items.length(); ++i )
	{
		CBaseEntity@ pEntity = null;
		while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, Items[i] ) ) !is null)
		{
			if( pEntity.pev.spawnflags == "0" )
			{
				pEntity.pev.spawnflags = 256;
			}
		}
	}
}