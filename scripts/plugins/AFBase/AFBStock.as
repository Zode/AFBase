//stock

AFBaseBase afbasebase;
void AFBaseBaseExpansionCall()
{
	afbasebase.RegisterExpansion(afbasebase);
}

class AFBaseBase : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery Base";
		this.ShortName = "AFB";
		this.StatusOverride = true; // Base plugin cant be stopped
	}
	
	void ExpansionInit()
	{
		AFBaseBase::g_decaltrackers.resize(0);
		RegisterCommand("afb_help", "!ib", "<page> <0/1 show expansion> - List available commands", ACCESS_Z, @AFBaseBase::help, CMD_SERVER);
		RegisterCommand("afb_info", "", "- Show info", ACCESS_Z, @AFBaseBase::info, CMD_SERVER);
		RegisterCommand("afb_who", "!b", "<0/1 don't shorten nicks> - Show client information", ACCESS_Z, @AFBaseBase::who, CMD_SERVER);
		RegisterCommand("afb_expansion_list", "", "- List expansions", ACCESS_Z, @AFBaseBase::extlist, CMD_SERVER);
		RegisterCommand("afb_expansion_stop", "s", "(\"expansion SID\") - stop expansion", ACCESS_B, @AFBaseBase::extstop, CMD_SERVER);
		RegisterCommand("afb_expansion_start", "s", "(\"expansion SID\") - start expansion", ACCESS_B, @AFBaseBase::extstart, CMD_SERVER);
		RegisterCommand("afb_access", "s!s", "(target) <accessflags> - get/set accessflags, add + or - before flags to add or remove", ACCESS_B, @AFBaseBase::access, CMD_SERVER); 
		RegisterCommand("admin_kick", "s!s", "(target) <\"reason\"> - kicks target with reason", ACCESS_E, @AFBaseBase::kick, CMD_SERVER);
		RegisterCommand("admin_rcon", "s!i", "(command) <noquotes 0/1> - remote console", ACCESS_C, @AFBaseBase::rcon);
		RegisterCommand("admin_changelevel", "s", "(level) - change level", ACCESS_E, @AFBaseBase::changelevel, CMD_SERVER);
		RegisterCommand("admin_slay", "s", "(target) - slay target(s)", ACCESS_G, @AFBaseBase::slay, CMD_SERVER);
		RegisterCommand("admin_slap", "s!i", "(target) <damage> - slap target(s)", ACCESS_G, @AFBaseBase::slap, CMD_SERVER);
		RegisterCommand("admin_say", "bis!isiiiff", "(0/1 showname) (0/1/2 chat/hud/middle) (\"text\") <holdtime> <target> <r> <g> <b> <x> <y> - say text", ACCESS_H, @AFBaseBase::say, CMD_SERVER);
		RegisterCommand("admin_trackdecals", "!i", "<0/1 mode> - track player sprays, don't define mode to toggle", ACCESS_G, @AFBaseBase::trackdecals);
		RegisterCommand("admin_ban", "s!sib", "(\"steamid\") <\"reason\"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid> - ban target", ACCESS_D, @AFBaseBase::ban, CMD_SERVER);
		RegisterCommand("admin_unban", "s", "(\"steamid or ip\") - unban target", ACCESS_D, @AFBaseBase::unban, CMD_SERVER);
		RegisterCommand("afb_setlast", "s", "(target) - sets last target, use if you only want to select somebody without running a command on them", ACCESS_G, @AFBaseBase::selectlast);
		RegisterCommand("admin_banlate", "s!si", "(\"steamid/ip\") <\"reason\"> <duration in minutes, 0 for infinite> - late ban target, basically adds to ban list. Doesn't validate player like admin_ban does.", ACCESS_D, @AFBaseBase::banlate, CMD_SERVER);
		RegisterCommand("admin_blockdecals", "sb", "(target) (0/1 unban/ban) - Ban target from spraying", ACCESS_G, @AFBaseBase::bandecals, CMD_SERVER);
		RegisterCommand("admin_gag", "ss", "(targets) (mode a/c/v) - gag player, a = all, c = chat, v = voice", ACCESS_G, @AFBaseBase::gag, CMD_SERVER);
		RegisterCommand("admin_ungag", "s", "(targets) - ungag player", ACCESS_G, @AFBaseBase::ungag, CMD_SERVER);
		RegisterCommand("afb_peek", "s", "(targets) - peeks into internal AFB info", ACCESS_B, @AFBaseBase::peek, CMD_SERVER);
		RegisterCommand("afb_disconnected", "!b", "<0/1 don't shorten nicks> - Show recently disconnected client information", ACCESS_E, @AFBaseBase::disconnected, CMD_SERVER);
		RegisterCommand("afb_last", "!b", "<0/1 don't shorten nicks> - (alias for afb_disconnected) Show recently disconnected client information", ACCESS_E, @AFBaseBase::disconnected, CMD_SERVER);
		RegisterCommand("afb_whatsnew", "", "- show changelog for this version", ACCESS_Z, @AFBaseBase::whatsnew, CMD_SERVER);
		
		@AFBaseBase::cvar_iBanMaxMinutes = CCVar("afb_maxban", 10080, "maximum time for bans in minutes (default: 10080)", ConCommandFlag::AdminOnly, CVarCallback(this.afb_cvar_ibanmaxminutes));
		
		g_Hooks.RegisterHook(Hooks::Player::PlayerDecal, @AFBaseBase::PlayerDecalHook);
		g_Hooks.RegisterHook(Hooks::Player::PlayerPreDecal, @AFBaseBase::PlayerPreDecalHook);
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @AFBaseBase::PlayerSpawn);
		g_Hooks.RegisterHook(Hooks::Player::ClientSay, @AFBaseBase::PlayerTalk);
	}
	
	void afb_cvar_ibanmaxminutes(CCVar@ cvar, const string &in szOldValue, float flOldValue)
	{
		if(cvar.GetInt() < 0)
			cvar.SetInt(1);
	}
	
	void MapInit()
	{
		AFBaseBase::g_decaltrackers.resize(0);
		g_Game.PrecacheModel("sprites/zbeam3.spr");
		g_SoundSystem.PrecacheSound("zode/thunder.ogg");
		g_Game.PrecacheGeneric("sound/zode/thunder.ogg");
		g_SoundSystem.PrecacheSound("weapons/cbar_hitbod1.wav");
		AFBaseBase::g_PlayerDecalTracker.Reset();
		AFBaseBase::CheckDisconnects();
		
		dictionary MenuCommands = {
			{".admin_slay","slay"},
			{".afb_setlast","set as @last target"}
		}; // purposefully not broadcasting to everything with *, instead using SID
		afbasebase.SendMessage("AF2MS", "RegisterMenuCommand", MenuCommands);
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pUser)
	{
		if(AFBaseBase::g_decaltrackers.find(pUser.entindex()) > -1)
			AFBaseBase::g_decaltrackers.removeAt(AFBaseBase::g_decaltrackers.find(pUser.entindex()));
			
		AFBaseBase::UserDisconnected(pUser);
	}
}

namespace AFBaseBase
{
	void whatsnew(AFBaseArguments@ AFArgs)
	{
		File@ file = g_FileSystem.OpenFile("scripts/plugins/AFBase/chlog.txt", OpenFile::READ);
		
		if(file !is null && file.IsOpen())
		{
			TellLongCustom("----AdminFuckeryBase: What's new------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
			TellLongCustom("AFB Version: "+AFBase::g_afInfo+"\nChangelog:\n", AFArgs.User, HUD_PRINTCONSOLE);
			
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.IsEmpty())
					continue;
					
				TellLongCustom(sLine+"\n", AFArgs.User, HUD_PRINTCONSOLE);
			}
			
			TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
			file.Close();
		}else{
			AFBase::BaseLog("Installation error: cannot locate changelog file");
			afbasebase.Tell("Installation error: cannot locate changelog file", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}

	class DisconnectedUser
	{
		string sTime;
		string sNick;
		string sIp;
		string sSteam;
	}
	
	dictionary g_disconnectedUserList;
	
	void UserDisconnected(CBasePlayer@ pUser)
	{
		DisconnectedUser disUser;
		DateTime datetime;
		time_t unixtime = datetime.ToUnixTimestamp();
		disUser.sTime = string(unixtime);
		AFBase::AFBaseUser@ AFBUser = AFBase::GetUser(pUser);
		if(AFBUser is null)
		{
			afbasebase.Log("Disconnect logging: failed to retrieve cached user info.");
			return;
		}
		
		disUser.sNick = AFBUser.sNick;
		disUser.sIp = AFBUser.sIp;
		disUser.sSteam = AFBUser.sSteam;
		g_disconnectedUserList[disUser.sSteam] = disUser;
	}
	
	void CheckDisconnects()
	{
		array<string> disKeys = g_disconnectedUserList.getKeys();
		array<string> toRemove;
		DisconnectedUser@ disUser = null;
		for(uint i = 0; i < disKeys.length(); i++)
		{
			@disUser = cast<DisconnectedUser@>(g_disconnectedUserList[disKeys[i]]);
			if(disUser !is null)
			{
				DateTime datetime;
				time_t unixtime = datetime.ToUnixTimestamp();
				DateTime datetime2 = datetime;
				datetime2.SetUnixTimestamp(atoi(disUser.sTime));
				time_t unixtime2 = datetime2.ToUnixTimestamp();
				time_t unixtimeleft = unixtime-unixtime2;
				int iTime = int(unixtimeleft/60);
				if(iTime >= 30)
					toRemove.insertLast(disKeys[i]);
			}
		}
		
		for(uint i = 0; i < toRemove.length(); i++)
		{
			g_disconnectedUserList.delete(toRemove[i]);
		}
	}
	
	void disconnected(AFBaseArguments@ AFArgs)
	{
		bool bNoFormat = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) : false;
		array<string> disKeys = g_disconnectedUserList.getKeys();
		string sSpace = "                                                                                                                                                                ";
		TellLongCustom("----AdminFuckeryBase: Clients recently disconnected from server-----------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		if(!bNoFormat)
			TellLongCustom("----Nicks longer than 15 characters have been cut off with \"~\", use .afb_disconnected 1 to remove this\n", AFArgs.User, HUD_PRINTCONSOLE);
		else
			TellLongCustom("----Nicks are no longer cut off. formatting may fuck up, use .afb_disconnected 0 to fix this\n", AFArgs.User, HUD_PRINTCONSOLE);
		int iOffsetId = 0;
		uint iLongestNick = 4;
		uint iLongestAuth = 6;
		uint iLongestIp = 2;
		uint iLongestMinutes = 6;
		string stempip = "";
		DisconnectedUser@ disUser = null;
		for(uint i = 0; i < disKeys.length(); i++)
		{
			@disUser = cast<DisconnectedUser@>(g_disconnectedUserList[disKeys[i]]);
			if(disUser !is null)
			{
				if(disUser.sNick.Length() > iLongestNick)
					if(!bNoFormat)
						if(disUser.sNick.Length() > 14)
							iLongestNick = 14;
						else
							iLongestNick = disUser.sNick.Length();
					else
						iLongestNick = disUser.sNick.Length();
					
				if(disUser.sSteam.Length() > iLongestAuth)
					iLongestAuth = disUser.sSteam.Length();
					
				stempip = disUser.sIp == "" ? "N/A Unknown" : disUser.sIp;
					
				if(stempip.Length() > iLongestIp)
					iLongestIp = stempip.Length();
			}
		}
		
		iOffsetId = int(floor(disKeys.length()/10));
		if(iOffsetId < 1)
			iOffsetId = 1;
		string sVID = sSpace.SubString(0,iOffsetId)+"#  ";
		string sVNICK = "Nick"+sSpace.SubString(0,iLongestNick-4)+"  ";
		string sVAUTH = "Authid"+sSpace.SubString(0,iLongestAuth-6)+"  ";
		string sVIP = "Ip"+sSpace.SubString(0,iLongestIp-2)+"  ";
		string sMIN = "Min(s)"+sSpace.SubString(0,iLongestMinutes-6);
		TellLongCustom(sVID+sVNICK+sVAUTH+sVIP+sMIN+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		for(uint i = 0; i < disKeys.length(); i++)
		{
			@disUser = cast<DisconnectedUser@>(g_disconnectedUserList[disKeys[i]]);
			if(disUser !is null)
			{
				iOffsetId = iOffsetId-int(floor((1+i)/10));
				if(iOffsetId < 1)
					iOffsetId = 1;
					
				if(i >= 9) // 21.7.2017 -- fixes offset by one character when more than 10 players are in the server
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+" ";
				else
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+"  ";
					
				if(!bNoFormat)
					if(disUser.sNick.Length() > 14)
					{
						string sFormNick = disUser.sNick.SubString(0,13)+"~";
						sVNICK = sFormNick+sSpace.SubString(0,iLongestNick-14)+"  ";
					}else
						sVNICK = disUser.sNick+sSpace.SubString(0,iLongestNick-disUser.sNick.Length())+"  ";
				else
					sVNICK = disUser.sNick+sSpace.SubString(0,iLongestNick-disUser.sNick.Length())+"  ";
				
				sVAUTH = disUser.sSteam+sSpace.SubString(0,iLongestAuth-disUser.sSteam.Length())+"  ";
				stempip = disUser.sIp == "" ? "N/A Unknown" : disUser.sIp;
				sVIP = stempip+sSpace.SubString(0, iLongestIp-stempip.Length())+"  ";
				
				DateTime datetime;
				time_t unixtime = datetime.ToUnixTimestamp();
				DateTime datetime2 = datetime;
				datetime2.SetUnixTimestamp(atoi(disUser.sTime));
				time_t unixtime2 = datetime2.ToUnixTimestamp();
				time_t unixtimeleft = unixtime-unixtime2;
				sMIN = string(int(unixtimeleft/60));
				sMIN = sMIN+sSpace.SubString(0, iLongestMinutes-sMIN.Length());
				
				TellLongCustom(sVID+sVNICK+sVAUTH+sVIP+sMIN+"\n", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void peek(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
				if(afbUser is null)
				{
					afbasebase.Tell("Can't peek: AFBaseUser class missing!", AFArgs.User, HUD_PRINTCONSOLE);
					return;
				}
				
				afbasebase.Tell("Peek: "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("bLock: "+(afbUser.bLock ? "True" : "False"), AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("iAccess: "+string(afbUser.iAccess), AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("sAccess: "+afbUser.sAccess, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("sLastTarget: "+afbUser.sLastTarget, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("sNick: "+afbUser.sNick, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("sOldNick: "+afbUser.sOldNick, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("sSteam: "+afbUser.sSteam, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("bSprayBan: "+(afbUser.bSprayBan ? "True" : "False"), AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Tell("iGagMode: "+string(afbUser.iGagMode), AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void AddBan(CBasePlayer@ pTarget, int iMinutes, string sReason, bool bUseIp)
	{
		string sId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
		AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
		string sIp = afbUser.sIp;
		
		if(bUseIp)
			AFBase::UpdateBanFile(sIp, iMinutes, sReason, true);
		else
			AFBase::UpdateBanFile(sId, iMinutes, sReason, false);
		
		if(iMinutes == 0)
			g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+" (ban duration: permanent)\"\n");
		else
			g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+" (ban duration: "+string(iMinutes)+"m)\"\n");
	}
	
	void AddBan(string sInput, int iMinutes, string sReason, bool bIsIp)
	{
		if(bIsIp)
			AFBase::UpdateBanFile(sInput, iMinutes, sReason, true);
		else
			AFBase::UpdateBanFile(sInput, iMinutes, sReason, false);
	}
	
	bool RemoveBan(string sInput, bool bIsIp)
	{
		bool bOut = false;
		if(bIsIp)
			bOut = AFBase::UpdateBanFile(sInput, -1, "unban", true);
		else
			bOut = AFBase::UpdateBanFile(sInput, -1, "unban", false);
			
		return bOut;
	}

	void ungag(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOAIM|TARGETS_NORANDOM, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				int iIndex = pTarget.entindex();
				AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
				if(afbUser.iGagMode == -1)
				{
					afbasebase.Tell("Won't ungag: "+pTarget.pev.netname+"! Target already is ungagged.", AFArgs.User, HUD_PRINTCONSOLE);
					continue;
				}
				
				afbUser.bLock = false;
				afbUser.iGagMode = -1;
				afbUser.bLock = true;
				AFBase::g_afbUserList[iIndex] = afbUser;
				
				CheckGagBan(pTarget);
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
				AFBase::UpdateGagFile(sFixId, -1);
				
				afbasebase.TellAll(AFArgs.FixedNick+" ungagged player \""+pTarget.pev.netname+"\"", HUD_PRINTTALK);
				afbasebase.Tell("Ungagged \""+pTarget.pev.netname+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" ungagged \""+pTarget.pev.netname+"\"");
			}
		}
	}

	HookReturnCode PlayerTalk(SayParameters@ sparams)
	{
		CBasePlayer@ pUser = sparams.GetPlayer();
		
		if(AFBase::g_afbUserList.exists(pUser.entindex()))
		{
			AFBase::AFBaseUser afbUser = AFBase::GetUser(pUser);
			if(afbUser.iGagMode == 1 || afbUser.iGagMode == 3)
			{
				afbasebase.Tell("Can't talk: gagged", pUser, HUD_PRINTTALK);
				sparams.set_ShouldHide(true);
				return HOOK_HANDLED;
			}
		}
		
		return HOOK_CONTINUE;
	}

	void CheckGagBan(CBasePlayer@ pPlayer)
	{
		if(pPlayer is null)
		{
			//since the new ban system doesn't actually care about players but rather the indexes and is cleared when a player disconnects,
			// we just check & apply each index against each other
			for(int i = 1; i < g_Engine.maxClients; i++)
			{
				AFBase::AFBaseUser@ afbUser = AFBase::GetUser(i);
				if(afbUser is null) continue;
				
				if(afbUser.iGagMode >= 2) // voice or all
					for(int j = 1; j < g_Engine.maxClients; j++)
						g_EngineFuncs.Voice_SetClientListening(j, i, true);
				else
					for(int j = 1; j < g_Engine.maxClients; j++)
						g_EngineFuncs.Voice_SetClientListening(j, i, false);
			}
			
			return;
		}
		
		//route for gag/ungag commands
		AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pPlayer);
		if(afbUser is null) return; // shouldn't happen but is a possibility
		
		if(afbUser.iGagMode >= 2)
			for(int i = 1; i <= g_Engine.maxClients; i++)
				g_EngineFuncs.Voice_SetClientListening(i, pPlayer.entindex(), true);
		else
			for(int i = 1; i <= g_Engine.maxClients; i++)
				g_EngineFuncs.Voice_SetClientListening(i, pPlayer.entindex(), false);
	}

	void gag(AFBaseArguments@ AFArgs)
	{
		string sMode = AFArgs.GetString(1);
		if(sMode != "a" && sMode != "c" && sMode != "v")
		{
			afbasebase.Tell("Unknown mode!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		int iMode = 0;
		if(sMode == "a")
			iMode = 3;
		else if(sMode == "c")
			iMode = 1;
		else
			iMode = 2;
			
		string sOutMode = "";
		if(iMode == 3)
			sOutMode = "chat & voice";
		else if(iMode == 2)
			sOutMode = "voice";
		else
			sOutMode = "chat";
	
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOAIM|TARGETS_NORANDOM, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				int iIndex = pTarget.entindex();
				AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
				if(afbUser.iGagMode != -1)
				{
					afbasebase.Tell("Won't gag: "+pTarget.pev.netname+"! Target already has gag mode set.", AFArgs.User, HUD_PRINTCONSOLE);
					continue;
				}
				
				afbUser.bLock = false;
				afbUser.iGagMode = iMode;
				afbUser.bLock = true;
				AFBase::g_afbUserList[iIndex] = afbUser;
				
				CheckGagBan(pTarget);
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
				AFBase::UpdateGagFile(sFixId, iMode);
				
				afbasebase.TellAll(AFArgs.FixedNick+" gagged player \""+pTarget.pev.netname+"\" (mode: "+sOutMode+")", HUD_PRINTTALK);
				afbasebase.Tell("Gagged \""+pTarget.pev.netname+"\" (mode: "+sOutMode+")", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" gagged \""+pTarget.pev.netname+"\" (mode: "+sOutMode+" )");
			}
		}
	}

	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{
		EHandle ePlayer = pPlayer;
		g_Scheduler.SetTimeout("PlayerPostSpawn", 0.01f, ePlayer);
		
		return HOOK_CONTINUE;
	}
	
	void PlayerPostSpawn(EHandle ePlayer)
	{
		CheckGagBan(null); //trigger a check against all indexes so that gag bans are applied for players that join later than when the gag happened
		/*if(ePlayer)
		{
			CBaseEntity@ pPlayer = ePlayer;
			//CheckSprayBan(cast<CBasePlayer@>(pPlayer));
			CheckGagBan(cast<CBasePlayer@>(pPlayer));
		}*/
	}
	
	void CheckSprayBan(CBasePlayer@ pTarget)
	{	
		if(pTarget is null)
			return;
			
		if(AFBase::g_afbUserList.exists(pTarget.entindex()))
		{
			AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
			if(afbUser.bSprayBan)
				pTarget.m_flNextDecalTime = Math.FLOAT_MAX;
			else
				pTarget.m_flNextDecalTime = Math.FLOAT_MIN;
		}
	}
	
	HookReturnCode PlayerPreDecalHook(CBasePlayer@ pPlayer, const TraceResult& in trace, bool& out bResult)
	{
		if(AFBase::g_afbUserList.exists(pPlayer.entindex()))
		{
			AFBase::AFBaseUser afbUser = AFBase::GetUser(pPlayer);
			if(afbUser.bSprayBan)
			{
				bResult = false;
			}
			else
			{
				bResult = true;
			}
		}else{
			bResult = true;
		}
		
		return HOOK_CONTINUE;
	}
	
	void bandecals(AFBaseArguments@ AFArgs)
	{
		bool bMode = AFArgs.GetBool(1);
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOAIM|TARGETS_NORANDOM, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				int iIndex = pTarget.entindex();
				AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
				if(afbUser.bSprayBan && bMode)
				{
					afbasebase.Tell("Can't sprayban: user already spraybanned!", AFArgs.User, HUD_PRINTCONSOLE);
					continue;
				}else if(!afbUser.bSprayBan && !bMode)
				{
					afbasebase.Tell("Can't sprayunban: user not spraybanned!", AFArgs.User, HUD_PRINTCONSOLE);
					continue;
				}
				
				afbUser.bLock = false;
				afbUser.bSprayBan = bMode;
				afbUser.bLock = true;
				AFBase::g_afbUserList[iIndex] = afbUser;
				
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
				AFBase::UpdateSprayFile(sFixId, bMode);
				//CheckSprayBan(pTarget);
				
				if(bMode)
				{
					afbasebase.TellAll(AFArgs.FixedNick+" banned player \""+AFArgs.GetString(0)+"\" from spraying decals", HUD_PRINTTALK);
					afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" from spraying decals", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.Log(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" from spraying decals");
				}else{
					afbasebase.TellAll(AFArgs.FixedNick+" unbanned player \""+AFArgs.GetString(0)+"\" from spraying decals", HUD_PRINTTALK);
					afbasebase.Tell("Unbanned \""+AFArgs.GetString(0)+"\" from spraying decals", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.Log(AFArgs.FixedNick+" unbanned \""+AFArgs.GetString(0)+"\" from spraying decals");
				}
			}
		}
	}

	void banlate(AFBaseArguments@ AFArgs)
	{
		string sReason = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "banned";
		int iMinutes = AFArgs.GetCount() >= 3 ? AFArgs.GetInt(2) : 30;
		
		if(!AFBase::IsNumeric(AFArgs.RawArgs[3]))
		{
			afbasebase.TellLong("Whoops! Seems like you mixed up the arguments. You tried to enter \""+AFArgs.RawArgs[3]+"\" as the ban duration.", AFArgs.User, HUD_PRINTCONSOLE);
			afbasebase.TellLong("Usage: .admin_banlate (\"steamid/ip\") <\"reason\"> <duration in minutes, 0 for infinite>", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		if(iMinutes < 0)
			iMinutes = 0;
			
		if(iMinutes == 0 && !AFArgs.IsServer)
		{
			if(!AFBase::CheckAccess(AFArgs.User, ACCESS_C))
			{
				afbasebase.Tell("Can't permaban: you are missing access flag C!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
		}else if(iMinutes > cvar_iBanMaxMinutes.GetInt()){
			iMinutes = cvar_iBanMaxMinutes.GetInt();
			afbasebase.Tell("Restricting ban time, larger than cvar: "+string(cvar_iBanMaxMinutes.GetInt()), AFArgs.User, HUD_PRINTCONSOLE);
		}
			
		string sHold = AFArgs.GetString(0);
		if(sHold.SubString(0,6).ToLowercase() == "steam_")
		{
			if(iMinutes > 0)
			{
				afbasebase.TellAll(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes");
			}else{
				afbasebase.TellAll(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" permanently", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" permanently", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" permanently");
			}
			
			AddBan(sHold, iMinutes, sReason, false);
		}else{
			if(sHold.ToLowercase() == "loopback" || sHold == "127.0.0.1")
			{
				afbasebase.Tell("Can't ban: user ip is localhost!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(iMinutes > 0)
			{
				afbasebase.TellAll(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes");
			}else{
				afbasebase.TellAll(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" permanently", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" permanently", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" banned \""+AFArgs.GetString(0)+"\" permanently");
			}
			
			AddBan(sHold, iMinutes, sReason, true);
		}
	}

	void selectlast(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				afbasebase.Tell("Last target is now: "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	CCVar@ cvar_iBanMaxMinutes;
	
	void ban(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		string sReason = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "banned";
		int iMinutes = AFArgs.GetCount() >= 3 ? AFArgs.GetInt(2) : 30;
		bool bBanIp = AFArgs.GetCount() >= 4 ? AFArgs.GetBool(3) : false;

		if(sReason == "" || sReason == " ") //fix an edge case where the user inputs "" as the ban reason and completely breaks everything
			sReason = "banned";
		
		if(AFArgs.GetCount() >= 3)
		{
			if(!AFBase::IsNumeric(AFArgs.RawArgs[3]))
			{
				afbasebase.TellLong("Whoops! Seems like you mixed up the arguments. You tried to enter \""+AFArgs.RawArgs[3]+"\" as the ban duration.", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.TellLong("Usage: .admin_ban (\"steamid\") <\"reason\"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid>", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
		}

		if(iMinutes < 0)
			iMinutes = 0;
			
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOAIM|TARGETS_NORANDOM, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				string sHold = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
				if(sHold != "")
				{
					string sId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
					AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
					if(afbUser is null)
					{
						afbasebase.Tell("Can't ban: null player?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					string sIp = afbUser.sIp;
					if(sIp == "" && bBanIp)
					{
						afbasebase.Tell("Can't ban: user ip not collected -- plugin reloaded?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					if(sIp == "loopback" || sIp == "127.0.0.1")
					{
						afbasebase.Tell("Can't ban: user ip is localhost!", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					if(iMinutes == 0 && !AFArgs.IsServer)
					{
						if(!AFBase::CheckAccess(AFArgs.User, ACCESS_C))
						{
							afbasebase.Tell("Can't permaban: you are missing access flag C!", AFArgs.User, HUD_PRINTCONSOLE);
							return;
						}
					}else if(iMinutes > cvar_iBanMaxMinutes.GetInt()){
						iMinutes = cvar_iBanMaxMinutes.GetInt();
						afbasebase.Tell("Restricting ban time, larger than cvar: "+string(cvar_iBanMaxMinutes.GetInt()), AFArgs.User, HUD_PRINTCONSOLE);
					}
					
					string sFill = bBanIp ? "ip: "+sIp : "steamid: "+sId;
					if(iMinutes > 0)
					{
						afbasebase.TellAll(AFArgs.FixedNick+" banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes (reason: "+sReason+")", HUD_PRINTTALK);
						afbasebase.Tell("Banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log(AFArgs.FixedNick+" banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes with reason \""+sReason+"\"");
					}else{
						afbasebase.TellAll(AFArgs.FixedNick+" banned player "+pTarget.pev.netname+" ("+sFill+") permanently (reason: "+sReason+")", HUD_PRINTTALK);
						afbasebase.Tell("Banned player "+pTarget.pev.netname+" ("+sFill+") permanently with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log(AFArgs.FixedNick+" banned player "+pTarget.pev.netname+" ("+sFill+") permanently with reason \""+sReason+"\"");
					}
					
					AddBan(pTarget, iMinutes, sReason, bBanIp);
				}
			}
		}
	}
	
	void unban(AFBaseArguments@ AFArgs)
	{
		string sHold = AFArgs.GetString(0);
		if(sHold.SubString(0,6).ToLowercase() == "steam_")
		{
			if(RemoveBan(sHold, false))
			{
				afbasebase.TellAll(AFArgs.FixedNick+" unbanned "+sHold, HUD_PRINTTALK);
				afbasebase.Tell("Unbanned "+sHold, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" unbanned "+sHold);
			}else{
				afbasebase.Tell("No such entry in ban list!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			if(RemoveBan(sHold, true))
			{
				afbasebase.TellAll(AFArgs.FixedNick+" unbanned "+sHold, HUD_PRINTTALK);
				afbasebase.Tell("Unbanned "+sHold, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" unbanned "+sHold);
			}else{
				afbasebase.Tell("No such entry in ban list!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}
	
	const uint g_uiMaxDecals = 64;
	const float g_flLifetime = 960;
	const float g_flMaxDistance = 128;
	const int g_iMessageLifeTime = 2;
	array<string> g_decaltrackers;
	
	final class PlayerDecal
	{
		private string m_szPlayerName;
		private string m_szAuthId;
		private Vector m_vecPosition;
		private float m_flCreationTime;
		
		string PlayerName
		{
			get const { return m_szPlayerName; }
		}
		
		string AuthId
		{
			get const { return m_szAuthId; }
		}
		
		Vector Position
		{
			get const { return m_vecPosition; }
		}
		
		float CreationTime
		{
			get const { return m_flCreationTime; }
		}
		
		PlayerDecal()
		{
			Reset();
		}
		
		bool Init( CBasePlayer@ pPlayer, const Vector& in vecPosition, const float flCreationTime )
		{
			Reset();
			if(pPlayer is null)
				return false;
				
			m_szPlayerName = pPlayer.pev.netname;
			m_szAuthId = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
			m_vecPosition = vecPosition;
			m_flCreationTime = flCreationTime;
			return IsValid();
		}
		
		void Reset()
		{
			m_szPlayerName 		= "";
			m_szAuthId 			= "";
			m_vecPosition 		= g_vecZero;
			m_flCreationTime 	= 0;
		}
		
		bool IsInitialized() const
		{
			return m_flCreationTime > 0;
		}
		
		bool HasExpired() const
		{
			return ( m_flCreationTime + g_flLifetime ) < g_Engine.time;
		}
		
		bool IsValid() const
		{
			return !HasExpired() && 
					!m_szPlayerName.IsEmpty() && !m_szAuthId.IsEmpty();
		}
	}
	
	final class PlayerDecalTracker
	{
		private array<PlayerDecal@> m_PlayerDecals;
		private array<int> m_iWasLooking;
		private CScheduledFunction@ m_pFunction = null;
		
		PlayerDecalTracker()
		{
			m_PlayerDecals.resize( g_uiMaxDecals );
			for( uint uiIndex = 0; uiIndex < m_PlayerDecals.length(); ++uiIndex )
				@m_PlayerDecals[ uiIndex ] = @PlayerDecal();
				
			m_iWasLooking.resize( g_Engine.maxClients );
			for( uint uiIndex = 0; uiIndex < m_iWasLooking.length(); ++uiIndex )
				m_iWasLooking[ uiIndex ] = 0;
		}
		
		void Reset()
		{
			for( uint uiIndex = 0; uiIndex < m_PlayerDecals.length(); ++uiIndex )
				m_PlayerDecals[ uiIndex ].Reset();
				
			for( uint uiIndex = 0; uiIndex < m_iWasLooking.length(); ++uiIndex )
				m_iWasLooking[ uiIndex ] = 0;
				
			if( m_pFunction !is null )
				g_Scheduler.RemoveTimer( m_pFunction );
				
			//Think every second
			@m_pFunction = g_Scheduler.SetInterval( @this, "Think", 1 +Math.RandomFloat(0.01f, 0.09f) );
		}
		
		private PlayerDecal@ FindFreeEntry( const bool bInvalidateOldest )
		{
			PlayerDecal@ pDecal = null;
			PlayerDecal@ pOldest = null;
			for( uint uiIndex = 0; uiIndex < m_PlayerDecals.length(); ++uiIndex )
			{
				@pDecal = m_PlayerDecals[ uiIndex ];
				if( !pDecal.IsValid() )
					return pDecal;
				else if( bInvalidateOldest )
				{
					if( pOldest is null || pOldest.CreationTime > pDecal.CreationTime )
					{
						@pOldest = pDecal;
					}
				}
			}
			
			return pOldest;
		}
		
		private const PlayerDecal@ FindNearestDecal( const Vector& in vecOrigin ) const
		{
			PlayerDecal@ pDecal = null;
			PlayerDecal@ pNearest = null;
			float flNearestDistance = Math.FLOAT_MAX;
			for( uint uiIndex = 0; uiIndex < m_PlayerDecals.length(); ++uiIndex )
			{
				@pDecal = m_PlayerDecals[ uiIndex ];
				if( !pDecal.IsValid() )
					continue;
				
				const float flDistance = ( pDecal.Position - vecOrigin ).Length();
				if( pNearest is null || flDistance < flNearestDistance )
				{
					flNearestDistance = flDistance;
					@pNearest = pDecal;
				}
			}
			
			return pNearest;
		}
		
		void PlayerDecalInit( CBasePlayer@ pPlayer, const TraceResult& in trace )
		{
			if( pPlayer is null )
				return;
				
			PlayerDecal@ pEntry = FindFreeEntry( true );
			//This shouldn't ever happen, but still
			if( pEntry is null )
				return;
				
			pEntry.Init( pPlayer, trace.vecEndPos, g_Engine.time );
		}
		
		void Think()
		{
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				if( pPlayer is null || pPlayer.IsConnected() == false )
					continue;

				if(g_decaltrackers.find(pPlayer.entindex()) <= -1)
					continue;

				const Vector vecEyes = pPlayer.pev.origin + pPlayer.pev.view_ofs;
				Vector vec;
				
				{
					Vector vecDummy;
					g_EngineFuncs.AngleVectors( pPlayer.pev.v_angle, vec, vecDummy, vecDummy );
				}
				
				TraceResult tr;
				g_Utility.TraceLine( vecEyes, vecEyes + ( vec * WORLD_BOUNDARY ), dont_ignore_monsters, pPlayer.edict(), tr );
				bool bWasLooking = false;
				if( tr.flFraction < 1.0 )
				{
					const PlayerDecal@ pNearest = FindNearestDecal( tr.vecEndPos );
					if( pNearest !is null )
					{
						if( ( pNearest.Position - tr.vecEndPos ).Length() <= g_flMaxDistance )
						{
							bWasLooking = true;
							string szMessage;
							snprintf( szMessage, "Spray by \n%1 \nAuth ID: %2", pNearest.PlayerName, pNearest.AuthId );
							g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, szMessage );
						}
					}
				}
				
				if( bWasLooking )
					m_iWasLooking[ iPlayer - 1 ] = g_iMessageLifeTime;
				else
				{
					if( m_iWasLooking[ iPlayer - 1 ] > 0 )
					{
						g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, " " );
						--m_iWasLooking[ iPlayer - 1 ];
					}
				}
			}
		}
	}
	
	PlayerDecalTracker g_PlayerDecalTracker;
	
	HookReturnCode PlayerDecalHook(CBasePlayer@ pPlayer, const TraceResult& in trace)
	{
		g_PlayerDecalTracker.PlayerDecalInit(pPlayer, trace);
		return HOOK_CONTINUE;
	}

	void trackdecals(AFBaseArguments@ AFArgs)
	{
		int iMode = AFArgs.GetCount() >= 1 ? AFBase::cclamp(AFArgs.GetInt(0), 0, 1) : -1;
		if(iMode == -1)
		{
			if(g_decaltrackers.find(AFArgs.User.entindex()) > -1)
			{
				g_decaltrackers.removeAt(g_decaltrackers.find(AFArgs.User.entindex()));
				afbasebase.Tell("Stopped tracking", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				g_decaltrackers.insertLast(AFArgs.User.entindex());
				afbasebase.Tell("Started tracking", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else if(iMode == 1)
		{
			if(g_decaltrackers.find(AFArgs.User.entindex()) > -1)
			{
				afbasebase.Tell("Can't set: Not tracking!", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				g_decaltrackers.insertLast(AFArgs.User.entindex());
				afbasebase.Tell("Started tracking", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			if(g_decaltrackers.find(AFArgs.User.entindex()) > -1)
			{
				g_decaltrackers.removeAt(g_decaltrackers.find(AFArgs.User.entindex()));
				afbasebase.Tell("Stopped tracking", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				afbasebase.Tell("Can't set: Already tracking!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void say(AFBaseArguments@ AFArgs)
	{
		bool bShowName = AFArgs.GetBool(0);
		int iTargetHud = AFBase::cclamp(AFArgs.GetInt(1), 0, 2);
		string sMessage = AFArgs.GetString(2);
		int iHold = AFArgs.GetCount() >= 4 ? AFArgs.GetInt(3) : 5;
		string sWantedTarget = AFArgs.GetCount() >= 5 ? AFArgs.GetString(4) : "@all";
		int iR = AFArgs.GetCount() >= 6 ? AFArgs.GetInt(5) : 255;
		int iG = AFArgs.GetCount() >= 7 ? AFArgs.GetInt(6) : 255;
		int iB = AFArgs.GetCount() >= 8 ? AFArgs.GetInt(7) : 255;
		float fX = AFArgs.GetCount() >= 9 ? AFArgs.GetFloat(8) : -1.0f;
		float fY = AFArgs.GetCount() >= 10 ? AFArgs.GetFloat(9) : -1.0f;
		if(bShowName)
			sMessage = " [ADMIN] "+AFArgs.FixedNick+": "+sMessage;
		else if(!bShowName && iTargetHud == 0) // fix uglyness in chat
			sMessage = " "+sMessage;
			
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, sWantedTarget, TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			afbasebase.Tell("Broadcasted \""+sMessage+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(iTargetHud == 0)
				{
					g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTTALK, " "+sMessage+"\n");
				}else if(iTargetHud == 1)
				{
					HUDTextParams hudTXT;
					hudTXT.holdTime=iHold;
					hudTXT.r1=iR;
					hudTXT.g1=iG;
					hudTXT.b1=iB;
					hudTXT.x=fX;
					hudTXT.y=fY;
					hudTXT.fadeinTime = 0.2f;
					hudTXT.fadeoutTime = 0.2f;
					hudTXT.channel = 2;
					g_PlayerFuncs.HudMessage(pTarget, hudTXT, sMessage+"\n");
				}else{
					g_PlayerFuncs.ClientPrint(pTarget, HUD_PRINTCENTER, sMessage+"\n");
				}
			}
		}
	}

	void slap(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		int iDamage = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : 5;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				afbasebase.TellAll(AFArgs.FixedNick+" slapped player "+pTarget.pev.netname+" with "+string(iDamage)+" damage", HUD_PRINTTALK);
				afbasebase.Tell("Slapped player "+pTarget.pev.netname+" with "+string(iDamage)+" damage", AFArgs.User, HUD_PRINTCONSOLE);
				entvars_t@ world = g_EntityFuncs.Instance(0).pev;
				pTarget.TakeDamage(world, world, iDamage, DMG_GENERIC);
				pTarget.pev.velocity = Vector(Math.RandomFloat(-512,512), Math.RandomFloat(-512,512), Math.RandomFloat(-512,512));
				pTarget.pev.punchangle = Vector(Math.RandomFloat(-16,16), Math.RandomFloat(-16,16), Math.RandomFloat(-16,16));
				if(AFBase::IsSafe())
				{
					g_SoundSystem.PlaySound(pTarget.edict(), CHAN_STATIC, "weapons/cbar_hitbod1.wav", 1.0f, 1.0f);
				}
			}
		}
	}

	void slay(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				afbasebase.TellAll(AFArgs.FixedNick+" slayed player "+pTarget.pev.netname, HUD_PRINTTALK);
				afbasebase.Tell("Slayed player "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" slayed player "+pTarget.pev.netname);
				entvars_t@ world = g_EntityFuncs.Instance(0).pev;
				//making sure slay works with non-vanilla players (SCXPM/Balancing scripts or when the admin has poked around with _keyvalue health)
				pTarget.pev.health = 1;
				pTarget.pev.armorvalue = 0;
				pTarget.TakeDamage(world, world, 16384.0f, DMG_ALWAYSGIB|DMG_CRUSH);
				if(AFBase::IsSafe())
				{
					TraceResult tr;
					g_EngineFuncs.MakeVectors(pTarget.pev.angles);
					g_Utility.TraceLine(pTarget.pev.origin, pTarget.pev.origin+g_Engine.v_up*4096, ignore_monsters, pTarget.edict(), tr);
					NetworkMessage message(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
						message.WriteByte(TE_BEAMPOINTS);
						message.WriteCoord(pTarget.pev.origin.x);
						message.WriteCoord(pTarget.pev.origin.y);
						message.WriteCoord(pTarget.pev.origin.z);
						message.WriteCoord(tr.vecEndPos.x);
						message.WriteCoord(tr.vecEndPos.y);
						message.WriteCoord(tr.vecEndPos.z);
						message.WriteShort(g_EngineFuncs.ModelIndex("sprites/zbeam3.spr"));
						message.WriteByte(0);
						message.WriteByte(1);
						message.WriteByte(2);
						message.WriteByte(16);
						message.WriteByte(64);
						message.WriteByte(175);
						message.WriteByte(215);
						message.WriteByte(255);
						message.WriteByte(255);
						message.WriteByte(0);
					message.End();
					NetworkMessage message2(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
						message2.WriteByte(TE_DLIGHT);
						message2.WriteCoord(pTarget.pev.origin.x);
						message2.WriteCoord(pTarget.pev.origin.y);
						message2.WriteCoord(pTarget.pev.origin.z);
						message2.WriteByte(24);
						message2.WriteByte(175);
						message2.WriteByte(215);
						message2.WriteByte(255);
						message2.WriteByte(4);
						message2.WriteByte(88);
					message2.End();
					g_SoundSystem.PlaySound(pTarget.edict(), CHAN_STATIC, "zode/thunder.ogg", 1.0f, 1.0f);
				}
			}
		}
	}
	void changelevel(AFBaseArguments@ AFArgs)
	{
		string sMap = AFArgs.GetString(0);
		sMap = sMap.ToLowercase(); //fixes problems with linux and fastdl
		if(!g_EngineFuncs.IsMapValid(sMap))
		{
			afbasebase.Tell("Can't change: \""+sMap+"\" doesn't exist!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		afbasebase.Tell("Changed level to: "+sMap, AFArgs.User, HUD_PRINTCONSOLE);
		afbasebase.TellAll(AFArgs.FixedNick+" changed level to "+sMap, HUD_PRINTTALK);
		afbasebase.Log(AFArgs.FixedNick+" changed level to "+sMap);
		NetworkMessage message(MSG_ALL, NetworkMessages::SVC_INTERMISSION, null);
		message.End();
		g_Scheduler.SetTimeout("changelevelsteptwo", 4.0f, sMap);
	}
	
	void changelevelsteptwo(string &in sMap)
	{
		g_EngineFuncs.ChangeLevel(sMap);
	}

	const array<string> g_blackListCommands =
	{
	"rcon_password",
	"sv_password",
	"hostname",
	"shutdown",
	"exit",
	"quit",
	"shutdownserver"
	};

	void rcon(AFBaseArguments@ AFArgs)
	{
		array<string> aSHold = AFArgs.GetString(0).Split(" ");
		int noquotes = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : 0;
		
		if(aSHold[0] == " " || aSHold[0] == "\n" || aSHold[0] == "\r" || aSHold[0] == "\t")
					aSHold[0] = aSHold[0].SubString(0, aSHold[0].Length()-1);
		
		if(aSHold[0] == "")
		{
			afbasebase.Tell("Can't execute rcon: empty", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}else if(int(AFArgs.GetString(0).FindFirstOf(";", 0)) > -1)
		{
			afbasebase.Tell("Can't execute rcon: contains \";\"", AFArgs.User, HUD_PRINTCONSOLE);
			afbasebase.Log("Admin "+AFArgs.User.pev.netname+" tried to execute rcon with character \";\"");
			return;
		}else if(g_blackListCommands.find(aSHold[0]) > -1)
		{
			afbasebase.Tell("Can't execute rcon: blacklisted command \""+aSHold[0]+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			afbasebase.Log("Admin "+AFArgs.User.pev.netname+" tried to execute rcon with blacklisted command \""+aSHold[0]+"\"");
			return;
		}else if(int(AFArgs.GetString(0).FindFirstOf("as_command", 0)) > -1)
		{
			array<string> t = AFArgs.GetString(0).Split(" ");
			array<string> c = AFBase::g_afbConCommandList.getKeys();
			bool b = false;
			int w = 0;
			for(uint j = 0; j < t.length(); j++)
			{
				for(uint i = 0; i < c.length(); i++)
				{
					if(t[j] == "."+c[i] || t[j] == "."+AFBase::g_afServerPrefix+c[i])
					{
						w = i; b = true; break;
					}
				}
			}
			if(b)
			{
				afbasebase.Tell("Can't execute rcon: contains AFB command \""+c[w]+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" tried to execute rcon with AFB command \""+c[w]+"\"");
				return;
			}
		}
		
		string sOut = AFArgs.GetString(0);
		
		array<string> parsed = sOut.Split(" ");
		if(parsed.length() >= 2)
		{
			sOut = noquotes == 0 ? parsed[0]+" \"" : parsed[0]+" ";
			for(uint i = 1; i < parsed.length(); i++)
				if(i > 1)
					sOut += " "+parsed[i];
				else
					sOut += parsed[i];
			
			sOut += noquotes == 0 ? "\"" : "";
		}
		
		afbasebase.Tell("Executed rcon: "+sOut, AFArgs.User, HUD_PRINTCONSOLE);
		afbasebase.Log("Admin "+AFArgs.User.pev.netname+" executed rcon "+sOut);
		g_EngineFuncs.ServerCommand(sOut+"\n");
	}

	void kick(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		string sReason = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "kicked";
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOAIM|TARGETS_NORANDOM, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				afbasebase.TellAll(AFArgs.FixedNick+" kicked player "+pTarget.pev.netname+" (reason: "+sReason+")", HUD_PRINTTALK);
				afbasebase.Tell("Kicked player "+pTarget.pev.netname+" with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log(AFArgs.FixedNick+" kicked player "+pTarget.pev.netname+" with reason \""+sReason+"\"");
				g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+"\"\n");
			}
		}
	}

	void access(AFBaseArguments@ AFArgs)
	{
		if(AFBase::g_cvar_afb_ignoreAccess.GetInt() >= 1)
		{
			afbasebase.Tell("Can't modify: afb_access_ignore is on.", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		array<CBasePlayer@> pTargets;
		string sFlags = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1).ToLowercase() : "!";
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(!AFArgs.IsServer)
				{
					if(pTarget.entindex() == AFArgs.User.entindex() && sFlags != "!")
					{
						if(int(sFlags.FindFirstOf("b", 0)) > -1 && (sFlags.SubString(0,1) == "-" || sFlags.SubString(0,1) == "+"))
						{
							afbasebase.Tell("Can't modify: can't add or remove flag 'b' on self.", AFArgs.User, HUD_PRINTCONSOLE);
							continue;
						}else if(int(sFlags.FindFirstOf("b", 0)) <= -1 && (sFlags.SubString(0,1) != "-" && sFlags.SubString(0,1) != "+"))
						{
							afbasebase.Tell("Can't modify: can't set flags without flag 'b' on self.", AFArgs.User, HUD_PRINTCONSOLE);
							continue;
						}
					}
				}
				
				if(sFlags.SubString(0,1) == "+")
				{
					string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
					AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
					if(afbUser is null)
					{
						afbasebase.Tell("Can't update: null player?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					array<string> aSHold = AFBase::ExplodeString(afbUser.sAccess, "z");
					array<string> aSHold2 = AFBase::ExplodeString(sFlags.SubString(1,sFlags.Length()-1), "z");
					bool bExists = false;
					for(uint j = 0; j < aSHold2.length(); j++)
					{
						bExists = false;
						for(uint k = 0; k < aSHold.length(); k++)
						{
							if(aSHold2[j] == aSHold[k])
								bExists = true;
						}
						
						if(!bExists)
							aSHold.insertLast(aSHold2[j]);
					}
					
					aSHold.sortAsc();
					string sHold = AFBase::ImplodeString(aSHold);
					string sNewAccess = "";
					int iNewAccess = 0;		
					AFBase::translateAccess(sHold, sNewAccess, iNewAccess);
					if(sNewAccess.SubString(sNewAccess.Length()-1, 1) == "z")
						sNewAccess = sNewAccess.SubString(0, sNewAccess.Length()-1);
						
					afbUser.bLock = false;
					afbUser.iAccess = iNewAccess;
					afbUser.sAccess = sNewAccess+"z";
					afbUser.bLock = true;
					AFBase::g_afbUserList[pTarget.entindex()] = afbUser;
					afbasebase.Log(AFArgs.FixedNick+" updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z");
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll(AFArgs.FixedNick+" updated "+pTarget.pev.netname+" access to \""+sNewAccess+"z\"", HUD_PRINTTALK);
					AFBase::UpdateAccessFile(sFixId, sNewAccess);
				}else if(sFlags.SubString(0,1) == "-")
				{
					string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
					AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
					if(afbUser is null)
					{
						afbasebase.Tell("Can't update: null player?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					array<string> aSHold = AFBase::ExplodeString(afbUser.sAccess, "z");
					array<string> aSHold2 = AFBase::ExplodeString(sFlags.SubString(1,sFlags.Length()-1), "z");
					array<string> aSHold3;
					bool bExists = false;
					for(uint j = 0; j < aSHold.length(); j++)
					{
						bExists = false;
						for(uint k = 0; k < aSHold2.length(); k++)
						{
							if(aSHold[j] == aSHold2[k])
								bExists = true;
						}
						
						if(!bExists)
							aSHold3.insertLast(aSHold[j]);
					}
					
					aSHold3.sortAsc();
					string sHold = AFBase::ImplodeString(aSHold3);
					string sNewAccess = "";
					int iNewAccess = 0;						
					AFBase::translateAccess(sHold, sNewAccess, iNewAccess);
					if(sNewAccess.SubString(sNewAccess.Length()-1, 1) == "z")
						sNewAccess = sNewAccess.SubString(0, sNewAccess.Length()-1);
					
					afbUser.bLock = false;
					afbUser.iAccess = iNewAccess;
					afbUser.sAccess = sNewAccess+"z";
					afbUser.bLock = true;
					AFBase::g_afbUserList[pTarget.entindex()] = afbUser;
					afbasebase.Log(AFArgs.FixedNick+" updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z");
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll(AFArgs.FixedNick+" updated "+pTarget.pev.netname+" access to \""+sNewAccess+"z\"", HUD_PRINTTALK);
					AFBase::UpdateAccessFile(sFixId, sNewAccess);
				}else if(sFlags != "!")
				{
					string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
					AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
					if(afbUser is null)
					{
						afbasebase.Tell("Can't update: null player?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					array<string> sAHold = AFBase::ExplodeString(sFlags, "z");
					sAHold.sortAsc();
					string sHold = AFBase::ImplodeString(sAHold);
					int iNewAcc = 0;
					string sNewAcc = "";		
					AFBase::translateAccess(sHold, sNewAcc, iNewAcc);
					if(sNewAcc.SubString(sNewAcc.Length()-1, 1) == "z")
						sNewAcc = sNewAcc.SubString(0, sNewAcc.Length()-1);
					
					afbUser.bLock = false;
					afbUser.sAccess = sNewAcc+"z";
					afbUser.iAccess = iNewAcc;
					afbUser.bLock = true;
					AFBase::g_afbUserList[pTarget.entindex()] = afbUser;
					afbasebase.Log(AFArgs.FixedNick+" updated "+string(pTarget.pev.netname)+" access to "+sNewAcc);
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAcc+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll(AFArgs.FixedNick+" updated "+pTarget.pev.netname+" access to \""+sNewAcc+"\"", HUD_PRINTTALK);
					AFBase::UpdateAccessFile(sFixId, sNewAcc);
				}else{
					AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pTarget);
					if(afbUser is null)
					{
						afbasebase.Tell("Can't tell: null player?", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
					
					afbasebase.Tell(string(pTarget.pev.netname)+" accessflags: "+afbUser.sAccess, AFArgs.User, HUD_PRINTCONSOLE);
				}
			}
		}
	}

	void info(AFBaseArguments@ AFArgs)
	{
		TellLongCustom("----AdminFuckeryBase: Info------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("AFB Version: "+AFBase::g_afInfo+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		string sSafe = AFBase::g_afbIsSafePlugin ? "Yes" : "No";
		TellLongCustom("Safeplugin: "+sSafe+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("AFB Users: "+string(AFBase::g_afbUserList.getSize())+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("AFB Expansions: "+string(AFBase::g_afbExpansionList.getSize())+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("AFB Commands: CON/CHAT "+string(AFBase::g_afbConCommandList.getSize())+"/"+string(AFBase::g_afbChatCommandList.getSize())+" (total: "+string(AFBase::g_afbVisualCommandList.length())+")\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void who(AFBaseArguments@ AFArgs)
	{
		AFBase::AFBaseUser@ AFBUser;
		if(!AFArgs.IsServer)
			@AFBUser = AFBase::GetUser(AFArgs.User);
		bool bNoFormat = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) : false;
		bool bShowAll = AFArgs.IsServer?true:false;
		if(!AFArgs.IsServer)
			if(AFBUser.iAccess >= 2)
				bShowAll = true;
		array<string> afbKeys = AFBase::g_afbUserList.getKeys();
		string sSpace = "                                                                                                                                                                ";
		TellLongCustom("----AdminFuckeryBase: Clients on server-----------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		if(!bNoFormat)
			TellLongCustom("----Nicks longer than 15 characters have been cut off with \"~\", use .afb_who 1 to remove this\n", AFArgs.User, HUD_PRINTCONSOLE);
		else
			TellLongCustom("----Nicks are no longer cut off. formatting may fuck up, use .afb_who 0 to fix this\n", AFArgs.User, HUD_PRINTCONSOLE);
		int iOffsetId = 0;
		uint iLongestNick = 4;
		uint iLongestOldNick = 8;
		uint iLongestAuth = 6;
		uint iLongestIp = 2;
		uint iLongestAccess = 6;
		string stempip = "";
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[afbKeys[i]]);
			if(AFBUser !is null)
			{
				if(AFBUser.sNick.Length() > iLongestNick)
					if(!bNoFormat)
						if(AFBUser.sNick.Length() > 14)
							iLongestNick = 14;
						else
							iLongestNick = AFBUser.sNick.Length();
					else
						iLongestNick = AFBUser.sNick.Length();
					
				if(AFBUser.sOldNick.Length() > iLongestOldNick)
					if(!bNoFormat)
						if(AFBUser.sNick.Length() > 14)
							iLongestOldNick = 14;
						else
							iLongestOldNick = AFBUser.sOldNick.Length();
					else
						iLongestOldNick = AFBUser.sOldNick.Length();
					
					
				if(AFBUser.sSteam.Length() > iLongestAuth)
					iLongestAuth = AFBUser.sSteam.Length();
					
				stempip = AFBUser.sIp == "" ? "N/A Init" : AFBUser.sIp;
					
				if(stempip.Length() > iLongestIp)
					iLongestIp = stempip.Length();
					
				if(AFBUser.sAccess.Length() > iLongestAccess)
					iLongestAccess = AFBUser.sAccess.Length();
			}
		}
		
		iOffsetId = int(floor(afbKeys.length()/10));
		if(iOffsetId < 1)
			iOffsetId = 1;
		string sVID = sSpace.SubString(0,iOffsetId)+"#  ";
		string sVNICK = "Nick"+sSpace.SubString(0,iLongestNick-4)+"  ";
		string sVOLDNICK = "Old nick"+sSpace.SubString(0,iLongestOldNick-8)+"  ";
		string sVAUTH = "Authid"+sSpace.SubString(0,iLongestAuth-6)+"  ";
		string sVIP = "Ip"+sSpace.SubString(0,iLongestIp-2)+"  ";
		string sVIMM = "Imm  ";
		string sVACCESS = "Access";
		if(bShowAll)
			TellLongCustom(sVID+sVNICK+sVOLDNICK+sVAUTH+sVIP+sVIMM+sVACCESS+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		else
			TellLongCustom(sVID+sVNICK+sVAUTH+sVIMM+sVACCESS+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[afbKeys[i]]);
			if(AFBUser !is null)
			{
				iOffsetId = iOffsetId-int(floor((1+i)/10));
				if(iOffsetId < 1)
					iOffsetId = 1;
					
				if(i >= 9) // 21.7.2017 -- fixes offset by one character when more than 10 players are in the server
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+" ";
				else
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+"  ";
					
				if(!bNoFormat)
					if(AFBUser.sNick.Length() > 14)
					{
						string sFormNick = AFBUser.sNick.SubString(0,13)+"~";
						sVNICK = sFormNick+sSpace.SubString(0,iLongestNick-14)+"  ";
					}else
						sVNICK = AFBUser.sNick+sSpace.SubString(0,iLongestNick-AFBUser.sNick.Length())+"  ";
				else
					sVNICK = AFBUser.sNick+sSpace.SubString(0,iLongestNick-AFBUser.sNick.Length())+"  ";
					
				if(!bNoFormat)
					if(AFBUser.sOldNick.Length() > 14)
					{
						string sFormNick = AFBUser.sOldNick.SubString(0,13)+"~";
						sVOLDNICK = sFormNick+sSpace.SubString(0,iLongestOldNick-14)+"  ";
					}else
						sVOLDNICK = AFBUser.sOldNick+sSpace.SubString(0, iLongestOldNick-AFBUser.sOldNick.Length())+"  ";
				else
					sVOLDNICK = AFBUser.sOldNick+sSpace.SubString(0, iLongestOldNick-AFBUser.sOldNick.Length())+"  ";
				
				sVAUTH = AFBUser.sSteam+sSpace.SubString(0,iLongestAuth-AFBUser.sSteam.Length())+"  ";
				stempip = AFBUser.sIp == "" ? "N/A Init" : AFBUser.sIp;
				sVIP = stempip+sSpace.SubString(0, iLongestIp-stempip.Length())+"  ";
				sVIMM = AFBase::CheckAccess(atoi(afbKeys[i]), ACCESS_A) ? "Yes  " : "No   ";
				sVACCESS = AFBUser.sAccess+sSpace.SubString(0, iLongestAccess-AFBUser.sAccess.Length());
				if(bShowAll)
					TellLongCustom(sVID+sVNICK+sVOLDNICK+sVAUTH+sVIP+sVIMM+sVACCESS+"\n", AFArgs.User, HUD_PRINTCONSOLE);
				else
					TellLongCustom(sVID+sVNICK+sVAUTH+sVIMM+sVACCESS+"\n", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void extlist(AFBaseArguments@ AFArgs)
	{
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
		string sSpace = "                                                                                                                                                                ";
		TellLongCustom("----AdminFuckeryBase: Expansions------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		int iOffsetId = 0;
		uint iLongestSID = 3;
		uint iLongestName = 4;
		uint iLongestAuthor = 6;
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
			{
				if(AFBClass.ShortName.Length() > iLongestSID)
					iLongestSID = AFBClass.ShortName.Length();
					
				if(AFBClass.ExpansionName.Length() > iLongestName)
					iLongestName = AFBClass.ExpansionName.Length();
					
				if(AFBClass.AuthorName.Length() > iLongestAuthor)
					iLongestAuthor = AFBClass.AuthorName.Length();
			}
		}
		
		iOffsetId = int(floor(afbKeys.length()/10));
		if(iOffsetId < 1)
			iOffsetId = 1;
		string sVID = sSpace.SubString(0,iOffsetId)+"#  ";
		string sVSID = "SID"+sSpace.SubString(0,iLongestSID-3)+"  ";
		string sVNAME = "Name"+sSpace.SubString(0,iLongestName-4)+"  ";
		string sVAUTH = "Author"+sSpace.SubString(0,iLongestAuthor-6)+"  ";
		string sVSTAT = "Status";
		TellLongCustom(sVID+sVSID+sVNAME+sVSTAT+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
			{
				iOffsetId = iOffsetId-int(floor((1+i)/10));
				if(iOffsetId < 1)
					iOffsetId = 1;
			
				if(i >= 9) // 17.02.2018 -- fixes offset by one character when more than 10 extensions are in the server
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+" ";
				else
					sVID = sSpace.SubString(0, iOffsetId)+string(1+i)+"  ";
			
				sVSID = AFBClass.ShortName+sSpace.SubString(0,iLongestSID-AFBClass.ShortName.Length())+"  ";
				sVNAME = AFBClass.ExpansionName+sSpace.SubString(0,iLongestName-AFBClass.ExpansionName.Length())+"  ";
				sVAUTH = AFBClass.AuthorName+sSpace.SubString(0,iLongestAuthor-AFBClass.AuthorName.Length())+"  ";
				sVSTAT = AFBClass.Running ? "Running" : "Stopped";
				TellLongCustom(sVID+sVSID+sVNAME+sVSTAT+"\n", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void extstop(AFBaseArguments@ AFArgs)
	{
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
			{
				if(AFArgs.GetString(0) == AFBClass.ShortName)
				{
					if(AFBClass.StatusOverride)
					{
						TellLongCustom("[AFB] Error: Expansion "+AFBClass.ShortName+" can't be stopped: locked!\n", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log(AFArgs.FixedNick+" attempted to stop locked expansion "+string(AFBClass.ShortName));
						return;
					}else{
						if(AFBClass.Running)
						{
							TellLongCustom("[AFB] Stopped expansion: "+AFBClass.ShortName+".\n", AFArgs.User, HUD_PRINTCONSOLE);
							afbasebase.Log(AFArgs.FixedNick+" stopped expansion "+string(AFBClass.ShortName));
							AFBClass.Stop();
							return;
						}else{
							TellLongCustom("[AFB] Can't stop expansion "+AFBClass.ShortName+": Already stopped!\n", AFArgs.User, HUD_PRINTCONSOLE);
							afbasebase.Log(AFArgs.FixedNick+" attempted to stop already stopped expansion "+string(AFBClass.ShortName));
							return;
						}
					}
				}
			}
		}
		
		TellLongCustom("[AFB] Failed to find expansion SID, check your spelling (case sensetive).\n", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void extstart(AFBaseArguments@ AFArgs)
	{
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
			{
				if(AFArgs.GetString(0) == AFBClass.ShortName)
				{
					if(AFBClass.StatusOverride)
					{
						TellLongCustom("[AFB] Error: Expansion "+AFBClass.ShortName+" can't be started: locked!\n", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log(AFArgs.FixedNick+" attempted to start locked expansion "+string(AFBClass.ShortName));
						return;
					}else{
						if(AFBClass.Running)
						{
							TellLongCustom("[AFB] Can't start expansion "+AFBClass.ShortName+": Already running!\n", AFArgs.User, HUD_PRINTCONSOLE);
							afbasebase.Log(AFArgs.FixedNick+" attempted to start already running expansion "+string(AFBClass.ShortName));
							return;
						}else{
							TellLongCustom("[AFB] Started expansion: "+AFBClass.ShortName+".\n", AFArgs.User, HUD_PRINTCONSOLE);
							afbasebase.Log(AFArgs.FixedNick+" started expansion "+string(AFBClass.ShortName));
							AFBClass.Start();
							return;
						}
					}
				}
			}
		}
		
		TellLongCustom("[AFB] Failed to find expansion SID, check your spelling (case sensetive).\n", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void help(AFBaseArguments@ AFArgs)
	{
		array<string> sComm;
		AFBase::VisualCommand@ visCom;
		AFBaseClass@ AFBClass = null;
			
		bool bShowExp = AFArgs.GetCount() >= 2 ? AFArgs.GetBool(1) : false;
		if(!AFArgs.IsServer)
		{
			AFBase::AFBaseUser@ afbUser = AFBase::GetUser(AFArgs.User);
			for(uint i = 0; i < AFBase::g_afbVisualCommandList.length(); i++)
			{
				//AFBase::ParseCommand(AFBase::g_afbVisualCommandList[i], iCmdAccess, sENameID, sVisual);
				@visCom = cast<AFBase::VisualCommand@>(AFBase::g_afbVisualCommandList[i]);
				if(afbUser.iAccess & visCom.iCmdAccess == visCom.iCmdAccess && visCom.iFlags & CMD_SERVERONLY == 0)
				{
					@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[visCom.sENameID]);
					if(AFBClass !is null)
						if(AFBClass.Running)
							if(bShowExp)
								sComm.insertLast("["+visCom.sENameID+"] "+visCom.sVisual);
							else
								sComm.insertLast(visCom.sVisual);
				}
			}
		}else{
			for(uint i = 0; i < AFBase::g_afbVisualCommandList.length(); i++)
			{
				@visCom = cast<AFBase::VisualCommand@>(AFBase::g_afbVisualCommandList[i]);
				if(visCom.iFlags & CMD_SERVERONLY != 0 || visCom.iFlags & CMD_SERVER != 0)
				{
					@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[visCom.sENameID]);
					if(AFBClass !is null)
						if(AFBClass.Running)
							if(bShowExp)
								sComm.insertLast("["+visCom.sENameID+"] "+visCom.sVisual);
							else
								sComm.insertLast(visCom.sVisual);
				}
			}
		}
		sComm.sortAsc();
		
		uint cStart = AFArgs.GetCount() >= 1 ? AFArgs.GetInt(0) : 0;
		
		if(cStart <= 0)
			cStart = 1;
		
		cStart--;
		cStart=cStart*10; // faking pages
		uint cEnd = cStart+10;
		if(cStart >= sComm.length())
		{
			TellLongCustom("[AFB] No such page! attempted page "+(1+cStart/10)+", but list length is "+(1+((sComm.length()-1)/10))+" pages!\n", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}

		uint pLength = 0;
		for(uint i = cStart; i < cEnd; i++)
		{
			if(i < sComm.length())
				pLength++;
		}
		
		TellLongCustom("----AdminFuckeryBase help: Command list-----------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("Quick quide: (arg) required parameter, <arg> optional parameter. Targets: @all, @admins, @noadmins, @alive\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom(" @dead, @aim, @random, @last, @me, \"nickname\" (supports * wildcard), \"STEAM_0:1:ID\"\n", AFArgs.User, HUD_PRINTCONSOLE);
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		for(uint i = 0; i < pLength; i++)
		{
				TellLongCustom(" "+(1+i+cStart)+": "+sComm[i+cStart]+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		}
		
		TellLongCustom("--------------------------------------------------------------------------------\n", AFArgs.User, HUD_PRINTCONSOLE);
		if(cStart+10 < sComm.length())
			TellLongCustom("[AFB] type \".afb_help "+(1+(cEnd)/10)+"\" for more - showing page "+(1+cStart/10)+" of "+(1+((sComm.length()-1)/10))+".\n", AFArgs.User, HUD_PRINTCONSOLE);
		else
			TellLongCustom("[AFB] showing page "+(1+cStart/10)+" of "+(1+((sComm.length()-1)/10))+".\n", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void TellLongCustom(string sIn, CBasePlayer@ pUser, HUD targetHud)
	{
		bool bServer = pUser is null ? true : false;
		string sHoldIn = sIn;
		while(sHoldIn.Length() > 128)
		{
			if(!bServer)
				g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn.SubString(0, 128));
			else
				g_EngineFuncs.ServerPrint(sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
		{
			if(!bServer)
				g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn);
			else
				g_EngineFuncs.ServerPrint(sHoldIn);
		}
	}
}