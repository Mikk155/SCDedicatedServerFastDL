/*
* This script implements HLSP survival mode
*/

#include "DefaultCampaigns"
#include "point_checkpoint"

void MapInit()
{
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	LPMapInitialization();
	RegisterPointCheckPointEntity();
}

void MapActivate()
{
	LPMapActivate();
}