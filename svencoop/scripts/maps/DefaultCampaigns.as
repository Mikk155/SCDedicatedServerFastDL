#include "gaftherman/misc/ammo_individual"
#include "mikk/multi_language"
#include "mikk/entities/utils"
#include "mikk/entities/game_text_custom"
#include "limitless_potential/weapon_knife"
#include "limitless_potential/hl9mmhandgun"
#include "hl_weapons/weapons"

bool IsMultiplayer = false;

array<ItemMapping@> g_ClassicWeapons = 
{
	ItemMapping( "weapon_m16", "weapon_9mmAR" ),
	ItemMapping( "weapon_9mmhandgun", "weapon_hl9mmhandgun" ),
	ItemMapping( "weapon_glock", "weapon_hl9mmhandgun" ),
	ItemMapping( "weapon_357", HL_PYTHON::GetName() ),
	ItemMapping( "weapon_python", HL_PYTHON::GetName() ),
	ItemMapping( "weapon_eagle", OF_EAGLE::GetName() ),
	ItemMapping( "weapon_m249", OF_M249::GetName() ),
	ItemMapping( "weapon_saw", OF_M249::GetName() ),
	ItemMapping( "weapon_sniperrifle", OF_SNIPERRIFLE::GetName() ),
	ItemMapping( "weapon_shockrifle", OF_SHOCKRIFLE::GetName() ),
	ItemMapping( "ammo_762", OF_SNIPERRIFLE::GetAmmoName() ),
	ItemMapping( "ammo_556", OF_M249::GetAmmoName() )
};

void MapInit()
{
	MultiLanguageInit();

	RegisterClassicWeapons();
	RegisterAmmoIndividual();
	RegisterCustomTextGame();

	if(string(g_Engine.mapname).StartsWith("of"))
	{
		NVThink();
		RegisterKnife();
	}

	g_ClassicMode.SetItemMappings(@g_ClassicWeapons);
	g_ClassicMode.EnableMapSupport();
	g_ClassicMode.ForceItemRemap(true);
}

void MapActivate()
{
	AmmoIndividualRemap();
	MultiLanguageRemap();
}