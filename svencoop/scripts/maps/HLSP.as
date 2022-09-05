/*
* This script implements HLSP survival mode
*/

#include "DefaultCampaigns"

void MapInit()
{
	g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
	
	LPMapInitialization();
}

void MapActivate()
{
	LPMapActivate();
}