#include "gaftherman/misc/ammo_individual"
#include "mikk/multi_language"
#include "mikk/entities/utils"
#include "mikk/entities/game_text_custom"
#include "limitless_potential/weapon_knife"
#include "limitless_potential/nvision"
#include "limitless_potential/weapon_hl9mmhandgun"
#include "hl_weapons/weapons"
#include "cubemath/geneworm"
#include "mikk/multi_language"
#include "mikk/entities/trigger_once_mp"
#include "mikk/entities/point_checkpoint"

array<ItemMapping@> g_ClassicWeapons = 
{
	ItemMapping( "weapon_357", HL_PYTHON::GetName() ),
	ItemMapping( "weapon_python", HL_PYTHON::GetName() ),
	ItemMapping( "weapon_eagle", OF_EAGLE::GetName() ),
	ItemMapping( "weapon_mp5", "weapon_9mmAR" ),
	ItemMapping( "weapon_9mmhandgun", "weapon_hl9mmhandgun" ),
	ItemMapping( "weapon_glock", "weapon_hl9mmhandgun" ),
	ItemMapping( "weapon_sniperrifle", OF_SNIPERRIFLE::GetName() ),
	ItemMapping( "weapon_m249", OF_M249::GetName() ),
	ItemMapping( "weapon_saw", OF_M249::GetName() ),
	ItemMapping( "weapon_shockrifle", OF_SHOCKRIFLE::GetName() ),
	ItemMapping( "ammo_762", OF_SNIPERRIFLE::GetAmmoName() ),
	ItemMapping( "ammo_556", OF_M249::GetAmmoName() )
};

void LPMapInitialization()
{
	RegisterClassicWeapons();
	RegisterAmmoIndividual();
	RegisterCustomTextGame();
	RegisterHL9mmhandgun();
	RegisterAntiRushEntity();
	RegisterPointCheckPointEntity();
	
	if( string(g_Engine.mapname).StartsWith("of"))
	{
		g_nv.MapInit();
		RegisterKnife();

		if( string(g_Engine.mapname) == "of6a5" )
			RegisterGenewormCustomEntity();
	}

	g_ClassicMode.SetItemMappings(@g_ClassicWeapons);
	g_ClassicMode.EnableMapSupport();
	g_ClassicMode.ForceItemRemap(true);
}

void LPMapActivate()
{
	AmmoIndividualRemap();
	MultiLanguageRemap();
}