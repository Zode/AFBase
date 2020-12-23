// ----------------------------------------
// |Adminfuckery3.0                       |
// |Also known as AFBase                  |
// |--------------------------------------|
// |Do not directly modify AFBase files   |
// |instead copy the expansion you want to|
// |modify and modify that (remember to   |
// |disable original version first)       |
// ----------------------------------------
// 		 WARNING: MESSSY CODE AHEAD!
#include "AFBase/AFBEnums"
#include "AFBase/AFBUtil"
#include "AFBase/AFBaseClass"
#include "AFBase/AFBArgs"
#include "AFBase/AFBUser"
#include "AFBase/AFBHandler"
#include "AFBase/AFBFileIO"

#include "AFBase/AFBStock"
#include "AFBaseExpansions"

void PluginInit()
{
	AFBase::BaseLog(AFBase::g_afInfo+" - Plugin init");
	g_Module.ScriptInfo.SetAuthor("Zode");
	g_Module.ScriptInfo.SetContactInfo("Zodemon @ Sven co-op forums, Zode @ Sven co-op discord");
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @AFBase::HandleClientChat);
	g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @AFBase::HandleClientConnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @AFBase::HandleClientPreConnect);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @AFBase::HandleClientDisconnect);
	
	@AFBase::g_cvar_afb_ignoreAccess = CCVar("afb_access_ignore", 0, "0/1 ignore access file and use admins.txt instead", ConCommandFlag::AdminOnly, @AFBase::AccessIgnoreCB);
	
	AFBase::g_afbIsSafePlugin = false;
	AFBase::BaseLog("Loading expansions.");
	AFBase::g_afbUserList.deleteAll(); //af1/2 fix: reset incase shit gets stuck 
	AFBase::g_afbExpansionList.deleteAll();
	AFBase::g_afbConCommandList.deleteAll();
	AFBase::g_afbChatCommandList.deleteAll();
	AFBase::g_afbTempUser.deleteAll();
	AFBase::g_afbVisualCommandList.resize(0);
	AFBaseBaseExpansionCall();
	AFBaseCallExpansions();
	AFBase::g_afbVisualCommandList.sortAsc();
	AFBase::BaseLog("Expansions loaded!");
	
	CBasePlayer@ pSearch = null; //af2.1 fix: handle connected clients on reload
	for(int i = 1; i <= g_Engine.maxClients; i++)
	{
		@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pSearch !is null && pSearch.IsConnected())
		{
			string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch));
			if(sFixId == "")
			{
				AFBase::BaseLog("PLUGININIT: Error handling user steamid "+pSearch.pev.netname);
			}
			if(!AFBase::g_afbUserList.exists(pSearch.entindex()))
			{
				AFBase::AFBaseUser afbUser;
				afbUser.bLock = false;
				afbUser.iAccess = ACCESS_Z;
				afbUser.sAccess = "z";
				afbUser.sLastTarget = "";
				afbUser.sNick = pSearch.pev.netname;
				afbUser.sOldNick = pSearch.pev.netname;
				afbUser.sSteam = sFixId;
				afbUser.sIp = "";
				afbUser.bSprayBan = false;
				afbUser.iGagMode = -1;
				afbUser.bLock = true;
				AFBase::g_afbUserList[pSearch.entindex()] = afbUser;
			}
			
			AFBase::HandleAccess(sFixId, pSearch.entindex());
			AFBase::HandleSprayban(sFixId, pSearch.entindex());
			AFBase::HandleGagban(sFixId, pSearch.entindex());
			//AFBaseBase::CheckSprayBan(pSearch);
			AFBaseBase::CheckGagBan(pSearch);
		}
	}
	
	if(AFBase::g_afbThink !is null)
		g_Scheduler.RemoveTimer(AFBase::g_afbThink);
		
	@AFBase::g_afbThink = g_Scheduler.SetInterval("AFBaseThink", 2.0f+Math.RandomFloat(0.01f, 0.09f));
}

void MapInit()
{
	AFBase::g_afbUserList.deleteAll();
	CBasePlayer@ pSearch = null; //af2.1 fix: handle connected clients on reload
	for(int i = 1; i <= g_Engine.maxClients; i++)
	{
		@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pSearch !is null && pSearch.IsConnected())
		{
			string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch));
			if(sFixId == "")
			{
				AFBase::BaseLog("MAPINIT: Error handling user steamid "+pSearch.pev.netname);
			}

			if(!AFBase::g_afbUserList.exists(pSearch.entindex()))
			{
				AFBase::AFBaseUser afbUser;
				afbUser.bLock = false;
				afbUser.iAccess = ACCESS_Z;
				afbUser.sAccess = "z";
				afbUser.sLastTarget = "";
				afbUser.sNick = pSearch.pev.netname;
				afbUser.sOldNick = pSearch.pev.netname;
				afbUser.sSteam = sFixId;
				afbUser.sIp = "";
				afbUser.bSprayBan = false;
				afbUser.iGagMode = -1;
				afbUser.bLock = true;
				AFBase::g_afbUserList[pSearch.entindex()] = afbUser;
			}
			
			AFBase::HandleAccess(sFixId, pSearch.entindex());
			AFBase::HandleSprayban(sFixId, pSearch.entindex());
			AFBase::HandleGagban(sFixId, pSearch.entindex());
			//AFBaseBase::CheckSprayBan(pSearch);
			AFBaseBase::CheckGagBan(pSearch);
		}
	}

	AFBase::g_afbIsSafePlugin = false;
	if(AFBase::g_afbThink !is null)
		g_Scheduler.RemoveTimer(AFBase::g_afbThink);
		
	AFBaseClass@ AFBClass = null;
	array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
	for(uint i = 0; i < afbKeys.length(); i++)
	{
		@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
		if(AFBClass !is null)
			AFBClass.MapInit();
	}
		
	@AFBase::g_afbThink = g_Scheduler.SetInterval("AFBaseThink", 2.0f+Math.RandomFloat(0.01f, 0.09f));
	AFBase::g_afbIsSafePlugin = true;
	AFBase::BaseLog("Map init(s) called in expansion(s).");
}

void MapActivate()
{
	AFBaseClass@ AFBClass = null;
	array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
	for(uint i = 0; i < afbKeys.length(); i++)
	{
		@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
		if(AFBClass !is null)
			AFBClass.MapActivate();
	}
	AFBase::BaseLog("Map activate(s) called in expansion(s).");
}

void AFBaseThink()
{
	array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
	AFBaseClass@ AFBClass = null;
	CBasePlayer@ pSearch = null;
	
	for(int i = 1; i <= g_Engine.maxClients; i++)
	{
		@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
		if(pSearch !is null && pSearch.IsConnected())
		{
			if(!AFBase::g_afbUserList.exists(pSearch.entindex()))
			{
				string sFixId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch));
				AFBase::AFBaseUser afbUser;
				afbUser.bLock = false;
				afbUser.iAccess = ACCESS_Z;
				afbUser.sAccess = "z";
				afbUser.sLastTarget = "";
				afbUser.sNick = pSearch.pev.netname;
				afbUser.sOldNick = pSearch.pev.netname;
				afbUser.sSteam = sFixId;
				afbUser.bSprayBan = false;
				afbUser.iGagMode = -1;
				string sHoldTemp = "";
				if(AFBase::g_afbTempUser.exists(AFBase::FormatSafe(pSearch.pev.netname)))
				{
					sHoldTemp = string(AFBase::g_afbTempUser[AFBase::FormatSafe(pSearch.pev.netname)]);
					int iPos = sHoldTemp.FindFirstOf(":", 0);
					if(iPos > -1)
						sHoldTemp = sHoldTemp.SubString(0, iPos);
					
					AFBase::g_afbTempUser.delete(AFBase::FormatSafe(pSearch.pev.netname));
				}
				afbUser.sIp = sHoldTemp;
				afbUser.bLock = true;
				AFBase::g_afbUserList[pSearch.entindex()] = afbUser;
				AFBase::HandleAccess(sFixId, pSearch.entindex());
				AFBase::HandleSprayban(sFixId, pSearch.entindex());
				AFBase::HandleGagban(sFixId, pSearch.entindex());
				//AFBaseBase::CheckSprayBan(pSearch);
				AFBaseBase::CheckGagBan(pSearch);
			}else{
				AFBase::AFBaseUser@ afbUser = AFBase::GetUser(pSearch);
				if(afbUser is null)
					continue;
				
				if(afbUser.sNick != string(pSearch.pev.netname))
				{
					afbUser.bLock = false;
					afbUser.sOldNick = afbUser.sNick;
					afbUser.sNick = pSearch.pev.netname;
					afbUser.bLock = true;
					AFBase::g_afbUserList[pSearch.entindex()] = afbUser;
					for(uint j = 0; j < afbKeys.length(); j++)
					{
						@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[j]]);
						if(AFBClass !is null)
							AFBClass.NameChange(afbUser);
					}
				}
			}
		}
	}
}

namespace AFBase
{
	CScheduledFunction@ g_afbThink = null;
	dictionary g_afbUserList;
	dictionary g_afbExpansionList;
	dictionary g_afbConCommandList;
	dictionary g_afbChatCommandList;
	array<VisualCommand@> g_afbVisualCommandList;
	dictionary g_afbTempUser;
	CCVar@ g_cvar_afb_ignoreAccess;
	
	bool g_afbIsSafePlugin = false;
	
	const string g_afInfo = "AFBase 1.6.0 PUBLIC";
	const string g_afServerPrefix = "s_";
	bool IsSafe()
	{
		return g_afbIsSafePlugin;
	}
	
	void BaseLog(string sMsg)
	{
		g_Game.AlertMessage(at_logged, "[AFB] "+sMsg+"\n");
	}
	
	HookReturnCode HandleClientPreConnect(edict_t@ eEdict, const string &in sNick, const string &in sIp, bool &out bNoJoin, string &out sReason)
	{
		g_afbTempUser[FormatSafe(sNick)] = sIp;
		BaseLog("User "+sNick+" connected from "+sIp);
		
		return HOOK_CONTINUE;
	}
	
	HookReturnCode HandleClientConnect(CBasePlayer@ pPlayer)
	{
		string sFixId = FormatSafe(GetFixedSteamID(pPlayer));
		if(sFixId == "")
			BaseLog("CONNECT: Error handling user "+pPlayer.pev.netname);
		
		//if(!g_afbUserList.exists(pPlayer.entindex()))
		//{
			AFBaseUser afbUser;
			afbUser.bLock = false;
			afbUser.iAccess = ACCESS_Z;
			afbUser.sAccess = "z";
			afbUser.sLastTarget = "";
			afbUser.sNick = pPlayer.pev.netname;
			afbUser.sOldNick = pPlayer.pev.netname;
			afbUser.sSteam = sFixId;
			afbUser.bSprayBan = false;
			afbUser.iGagMode = -1;
			string sHoldTemp = "";
			if(g_afbTempUser.exists(FormatSafe(pPlayer.pev.netname)))
			{
				 sHoldTemp = string(g_afbTempUser[FormatSafe(pPlayer.pev.netname)]);
				int iPos = sHoldTemp.FindFirstOf(":", 0);
				if(iPos > -1)
					sHoldTemp = sHoldTemp.SubString(0, iPos);
					
				g_afbTempUser.delete(FormatSafe(pPlayer.pev.netname));
			}
			afbUser.sIp = sHoldTemp;
			afbUser.bLock = true;
			
			string sBanOutput = HandleBan(sFixId, false); 
			string sBanReason = "";
			int iBanMinutes = -1;
			ReadBanString(sBanOutput, iBanMinutes, sBanReason);
			if(iBanMinutes >= 0)
			{
				if(iBanMinutes == 0)
				{
					g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pPlayer.edict()))+" \""+sBanReason+" (ban time left: permanent)\"\n");
					BaseLog("GATEKEEP: kicking "+pPlayer.pev.netname+": has permanent ban with reason \""+sBanReason+"\"");
					afbasebase.TellAll("GATEKEEP: kicking "+pPlayer.pev.netname+": has permanent ban with reason \""+sBanReason+"\"", HUD_PRINTTALK);
				}else{
					g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pPlayer.edict()))+" \""+sBanReason+" (ban left: "+string(iBanMinutes)+"m)\"\n");
					BaseLog("GATEKEEP: kicking "+pPlayer.pev.netname+": has ban with reason \""+sBanReason+"\", "+string(iBanMinutes)+" minute(s) left.");
					afbasebase.TellAll("GATEKEEP: kicking "+pPlayer.pev.netname+": has ban with reason \""+sBanReason+"\", "+string(iBanMinutes)+" minute(s) left", HUD_PRINTTALK);
				}
				
				return HOOK_CONTINUE;
			}else if(iBanMinutes == -2)
			{
				UpdateBanFile(sFixId, -1, "unban", false);
			}
			
			sBanOutput = HandleBan(afbUser.sIp, true); 
			sBanReason = "";
			iBanMinutes = -1;
			ReadBanString(sBanOutput, iBanMinutes, sBanReason);
			if(iBanMinutes >= 0)
			{
				if(iBanMinutes == 0)
				{
					g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pPlayer.edict()))+" \""+sBanReason+" (ban time left: permanent)\"\n");
					BaseLog("GATEKEEP: kicking "+pPlayer.pev.netname+": has permanent ban with reason \""+sBanReason+"\"");
					afbasebase.TellAll("GATEKEEP: kicking "+pPlayer.pev.netname+": has permanent ban with reason \""+sBanReason+"\"", HUD_PRINTTALK);
				}else{
					g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pPlayer.edict()))+" \""+sBanReason+" (ban left: "+string(iBanMinutes)+"m)\"\n");
					BaseLog("GATEKEEP: kicking "+pPlayer.pev.netname+": has ban with reason \""+sBanReason+"\", "+string(iBanMinutes)+" minutes left.");
					afbasebase.TellAll("GATEKEEP: kicking "+pPlayer.pev.netname+": has ban with reason \""+sBanReason+"\", "+string(iBanMinutes)+" minutes left", HUD_PRINTTALK);
				}
				
				return HOOK_CONTINUE;
			}else if(iBanMinutes == -2)
			{
				UpdateBanFile(afbUser.sIp, -1, "unban", true);
			}
			
			g_afbUserList[pPlayer.entindex()] = afbUser;
			HandleAccess(sFixId, pPlayer.entindex());
			HandleSprayban(sFixId, pPlayer.entindex());
			HandleGagban(sFixId, pPlayer.entindex());
			//AFBaseBase::CheckSprayBan(pPlayer);
			AFBaseBase::CheckGagBan(pPlayer);
		//}
		
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = g_afbExpansionList.getKeys();
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
				AFBClass.ClientConnect(pPlayer);
		}
		
		return HOOK_CONTINUE;
	}
	
	HookReturnCode HandleClientDisconnect(CBasePlayer@ pPlayer)
	{	
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = g_afbExpansionList.getKeys();
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
				AFBClass.ClientDisconnect(pPlayer);
		}
		
		if(g_afbUserList.exists(pPlayer.entindex()))
			g_afbUserList.delete(pPlayer.entindex());
		
		return HOOK_CONTINUE;
	}
	
	void BaseTell(string sMsg, CBasePlayer@ pUser, HUD hudTarget)
	{
		if(pUser is null)
		{
			BaseTellServer(sMsg);
			return;
		}
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "[AFB] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "[AFB] "+sMsg+"\n");
	}
	
	void BaseTellServer(string sMsg)
	{
		g_EngineFuncs.ServerPrint("[AFB] "+sMsg+"\n");
	}
	
	void BaseTellLong(string sMsg, CBasePlayer@ pUser, HUD targetHud)
	{
		if(pUser is null)
		{
			BaseTellLongServer(sMsg);
			return;
		}
		string sHoldIn;
		if(targetHud == HUD_PRINTTALK)
			sHoldIn = "[AFB] "+sMsg+"\n";
		else
			sHoldIn = "[AFB] "+sMsg+"\n";
			
		while(sHoldIn.Length() > 128)
		{
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn);
	}
	
	void BaseTellLongServer(string sMsg)
	{
		string sHoldIn = "[AFB] "+sMsg+"\n";
			
		while(sHoldIn.Length() > 128)
		{
			g_EngineFuncs.ServerPrint(sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
			g_EngineFuncs.ServerPrint(sHoldIn);
	}
	
	void BaseTellAll(string sMsg, HUD hudTarget)
	{
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrintAll(hudTarget, "[AFB] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrintAll(hudTarget, "[AFB] "+sMsg+"\n");
	}
	
	void AccessIgnoreCB(CCVar@ cvar, const string &in sOld, float fOld)
	{
		if(cvar.GetInt() < 0)
			cvar.SetInt(0);
		if(cvar.GetInt() > 1)
			cvar.SetInt(1);
			
		//rescan
		g_afbUserList.deleteAll();
		CBasePlayer@ pSearch = null;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null && pSearch.IsConnected())
			{
				string sFixId = FormatSafe(GetFixedSteamID(pSearch));
				if(sFixId == "")
				{
					AFBase::BaseLog("CALLBACK: Error handling user steamid "+pSearch.pev.netname);
				}

				if(!AFBase::g_afbUserList.exists(pSearch.entindex()))
				{
					AFBase::AFBaseUser afbUser;
					afbUser.bLock = false;
					afbUser.iAccess = ACCESS_Z;
					afbUser.sAccess = "z";
					afbUser.sLastTarget = "";
					afbUser.sNick = pSearch.pev.netname;
					afbUser.sOldNick = pSearch.pev.netname;
					afbUser.sSteam = sFixId;
					afbUser.sIp = "";
					afbUser.bSprayBan = false;
					afbUser.iGagMode = -1;
					afbUser.bLock = true;
					AFBase::g_afbUserList[pSearch.entindex()] = afbUser;
				}
				
				AFBase::HandleAccess(sFixId, pSearch.entindex());
				AFBase::HandleSprayban(sFixId, pSearch.entindex());
				AFBase::HandleGagban(sFixId, pSearch.entindex());
				//AFBaseBase::CheckSprayBan(pSearch);
				AFBaseBase::CheckGagBan(pSearch);
			}
		}
	}
}