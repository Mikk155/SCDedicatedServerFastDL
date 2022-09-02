/*
* This script implements HLSP survival mode
*/

#include "point_checkpoint"
#include "DefaultCampaigns"

void MapInit()
{
	RegisterPointCheckPointEntity();
	
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	LPMapInitialization();
}

void MapActivate()
{
	LPMapActivate();
}