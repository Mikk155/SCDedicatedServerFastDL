void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Gaftherman & Mikk" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Coop-Multi-language-localizations" );

	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary keyvalues;

void MapStart()
{
	if( g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) )
	{
		g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
		
		keyvalues =	
		{
			{ "message", "[Multi-Language] Now will show maps messages in english.\n"},
			{ "message_spanish", "[Multiples idiomas] Ahora mostrara mensajes de mapas en espaniol.\nAlgunos caracteres no se mostraran por limitaciones.\n"},
			{ "message_portuguese", "[Multi-Language] Agora mostrara mensagens de mapas em Portugues.\nAlguns caracteres nao serao mostrados por limitacoes.\n"},
			{ "message_german", "[Multi-Language] Zeigt Kartennachrichten jetzt auf Deutsch an.\nEinige Zeichen werden aufgrund von Einschrankungen nicht angezeigt.\n"},
			{ "message_french", "[Multilingue] Affichera desormais les messages cartographiques en francaise.\nCertains caracteres ne seront pas affiches en raison des limitations.\n"},
			{ "message_italian", "[Multilingua] Ora mostrera i messaggi delle mappe in francese.\nAlcuni caratteri non verranno mostrati per limitazioni.\n"},
			{ "message_esperanto", "[Multlingva] Nuud kuvab kaarditeateid esperanto keeles.\nMonda tahemarki piirangute tottu ei kuvata.\n"},
			{ "x", "-1"},
			{ "y", "0.90"},
			{ "holdtime", "15"},
			{ "fadein", "0.1"},
			{ "channel", "8"},
			{ "spawnflags", "1"},
			{ "color", "255 0 0"},
			{ "targetname", "MULTILANGUAGE_ADVICE" }
		};
		g_EntityFuncs.CreateEntity( "game_text_custom", keyvalues, true );
	}
}

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
	int lenguage;
}

HookReturnCode MapChange()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null or !pPlayer.IsConnected() )
			continue;

		string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
        int iLanguage = int(ckLenguageIs.GetFloat());

		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
	}

	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	if( g_PlayerKeepLenguage.exists(SteamID) )
	{
        PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict(pPlayer.edict()), SteamID );
	}
    else
    {
		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
		CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
		int iLanguage = int(ckLenguageIs.GetFloat());

		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
    }

	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
    CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
    int iLanguage = int(ckLenguageIs.GetFloat());

    PlayerKeepLenguageData pData;
	pData.lenguage = iLanguage;
	g_PlayerKeepLenguage[SteamID] = pData;   

    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

	if( pPlayer is null )
		return;

	PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	ckLenguage.SetKeyvalue("$f_lenguage", int(pData.lenguage));
}

// This was the most paintful shit to implement by myself until i've start the copy-paste method. i love you Duk0
// https://github.com/Duk0/AngelScript-SvenCoop/blob/master/plugins/AdminVote.as
HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if( args.ArgC() == 1 && args.Arg(0) == "language" or args.Arg(0) == "idioma" or args.Arg(0) == "trans" )
	{
		CreateMenu( pPlayer );
	}
	
	return HOOK_CONTINUE;
}

CTextMenu@ g_VoteMenu;

void CreateMenu(CBasePlayer@ pPlayer)
{
	@g_VoteMenu = CTextMenu( @MainCallback );
	g_VoteMenu.SetTitle( "Choose Language\n" );
	g_VoteMenu.AddItem( "English" );
	g_VoteMenu.AddItem( "Spanish" );
	g_VoteMenu.AddItem( "Portuguese" );
	g_VoteMenu.AddItem( "German" );
	g_VoteMenu.AddItem( "French" );
	g_VoteMenu.AddItem( "Italian" );
	g_VoteMenu.AddItem( "Esperanto" );
	g_VoteMenu.Register();
	g_VoteMenu.Open( 15, 0, pPlayer );
}

void Advice(CBasePlayer@ pPlayer){g_EntityFuncs.FireTargets( "MULTILANGUAGE_ADVICE", pPlayer, pPlayer, USE_TOGGLE );}

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
	int iLanguage = int(ckLenguageIs.GetFloat());
	
	if( pItem !is null )
	{
		string sChoice = pItem.m_szName;
		if( sChoice == "English" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 0 );
			Advice( pPlayer );
		}
		else if( sChoice == "Spanish" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 1 );
			Advice( pPlayer );
		}
		else if( sChoice == "Portuguese" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 2 );
			Advice( pPlayer );
		}
		else if( sChoice == "German" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 3 );
			Advice( pPlayer );
		}
		else if( sChoice == "French" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 4 );
			Advice( pPlayer );
		}
		else if( sChoice == "Italian" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 5 );
			Advice( pPlayer );
		}
		else if( sChoice == "Esperanto" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 6 );
			Advice( pPlayer );
		}
	}
}