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
	
	AFBase::g_afbIsSafePlugin = false;
	AFBase::BaseLog("Loading expansions.");
	AFBase::g_afbUserList.deleteAll(); //af1/2 fix: reset incase shit gets stuck 
	AFBase::g_afbExpansionList.deleteAll();
	AFBase::g_afbConCommandList.deleteAll();
	AFBase::g_afbChatCommandList.deleteAll();
	AFBase::g_afbTempUser.deleteAll();
	AFBase::g_afbCommandList.resize(0);
	AFBaseBaseExpansionCall();
	AFBase::AFBaseCallExpansions();
	AFBase::g_afbCommandList.sortAsc();
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
			AFBaseBase::CheckSprayBan(pSearch);
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
			AFBaseBase::CheckSprayBan(pSearch);
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
	AFBase::BaseLog("Map init.");
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
				AFBaseBase::CheckSprayBan(pSearch);
				AFBaseBase::CheckGagBan(pSearch);
			}else{
				AFBase::AFBaseUser afbUser;
				afbUser = AFBase::GetUser(pSearch);
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

enum AccessLevels
{
	ACCESS_Z = 1, // default access, plugin info / expansion info, help command, who command
	ACCESS_Y = 2, // custom access 17
	ACCESS_X = 4, // custom access 16
	ACCESS_W = 8, // custom access 15
	ACCESS_V = 16, // custom access 14
	ACCESS_U = 32, // custom access 13
	ACCESS_T = 64, // custom access 12
	ACCESS_S = 128, // custom access 11
	ACCESS_R = 256, // custom access 10
	ACCESS_Q = 512, // custom access 9
	ACCESS_P = 1024, // custom access 8
	ACCESS_O = 2048, // custom access 7
	ACCESS_N = 4096, // custom access 6
	ACCESS_M = 8192, // custom access 5
	ACCESS_L = 16384, // custom access 4
	ACCESS_K = 32768, // custom access 3
	ACCESS_J = 65536, // custom access 2
	ACCESS_I = 131072, // custom access 1
	ACCESS_H = 262144, // fun_ commands, say
	ACCESS_G = 524288, // player_ commands, player quickmenu, slap, slay, trackdecals
	ACCESS_F = 1048576, // ent_ commands
	ACCESS_E = 2097152, // kick, changelevel, "highrisk"
	ACCESS_D = 4194304, // ban/unban
	ACCESS_C = 8388608, // rcon
	ACCESS_B = 16777216, // set access, stop/start expansion
	ACCESS_A = 33554432 // immunity
}

enum PlayerTargeters
{
	TARGETS_NOALL = 1,
	TARGETS_NOME = 2,
	TARGETS_NODEAD = 4,
	TARGETS_NOAIM = 8,
	TARGETS_NORANDOM = 16,
	TARGETS_NOLAST = 32,
	TARGETS_NONICK = 64,
	TARGETS_NOIMMUNITYCHECK = 128,
	TARGETS_NOALIVE = 256
}

namespace AFBase
{
	CScheduledFunction@ g_afbThink = null;
	dictionary g_afbUserList;
	dictionary g_afbExpansionList;
	dictionary g_afbConCommandList;
	dictionary g_afbChatCommandList;
	array<string> g_afbCommandList;
	dictionary g_afbTempUser;
	
	bool g_afbIsSafePlugin = false;
	
	const string g_afInfo = "AFBase 1.3.2 PUBLIC";
	
	bool IsSafe()
	{
		return g_afbIsSafePlugin;
	}
	
	void BaseLog(string sMsg)
	{
		g_Game.AlertMessage(at_logged, "[AFB] "+sMsg+"\n");
	}
	
	const array<string> g_validChars = {
	"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
	"A", "S", "D", "F", "G", "H", "J", "K", "L",
	"Z", "X", "C", "V", "B", "N", "M",
	"q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
	"a", "s", "d", "f", "g", "h", "j", "k", "l",
	"z", "x", "c", "v", "b", "n", "m",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"-", "_", ":"
	};
	
	string FormatSafe(string sIn)
	{
		string sHold = sIn;
		for(uint i = 0; i < sHold.Length(); i++)
		{
			if(g_validChars.find(string(sHold.opIndex(i))) <= -1)
				sHold.SetCharAt(i, char("-"));
		}
		
		return sHold;
	}
	
	string GetFixedSteamID(CBasePlayer@ pUser)
	{
		if(pUser is null or !pUser.IsConnected())
		{
			BaseLog("Player steamID check failed");
			return "";
		}
		
		string steamID = g_EngineFuncs.GetPlayerAuthId(pUser.edict());
		if(steamID == "")
			for(int i = 0; i < 8; i++) // lowered search amount
			{
				steamID = g_EngineFuncs.GetPlayerAuthId(pUser.edict());
				if(steamID != "")
					break;
			}

		if(steamID == "STEAM_ID_LAN" or steamID == "BOT")
			steamID = pUser.pev.netname;
			
		return steamID;
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
			AFBaseBase::CheckSprayBan(pPlayer);
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
	
	class AFBaseUser
	{
		private int c_iAccess;
		//bool bHighRisk;
		private string c_sAccess;
		private string c_sLastTarget;
		private string c_sNick;
		private string c_sOldNick;
		private string c_sSteam;
		private string c_sIp;
		private bool c_bLock; // slapped on
		private bool c_bSprayBan; // slapped on x2
		private int c_iGagMode; // x3
		
		int iAccess
		{
			get const
			{
				return c_iAccess;
			}
			set
			{
				c_iAccess = c_bLock ? c_iAccess : value;
			}
		}
		
		string sSteam
		{
			get const
			{
				return c_sSteam;
			}
			set
			{
				c_sSteam = c_bLock ? c_sSteam : value;
			}
		}
		
		string sAccess
		{
			get const
			{
				return c_sAccess;
			}
			set
			{
				c_sAccess = c_bLock ? c_sAccess : value;
			}
		}
		
		string sLastTarget
		{
			get const
			{
				return c_sLastTarget;
			}
			set
			{
				c_sLastTarget = c_bLock ? c_sLastTarget : value;
			}
		}
		
		string sNick
		{
			get const
			{
				return c_sNick;
			}
			set
			{
				c_sNick = c_bLock ? c_sNick : value;
			}
		}
		
		string sOldNick
		{
			get const
			{
				return c_sOldNick;
			}
			set
			{
				c_sOldNick = c_bLock ? c_sOldNick : value;
			}
		}
		
		string sIp
		{
			get const
			{
				return c_sIp;
			}
			set
			{
				c_sIp = c_bLock ? c_sIp : value;
			}
		}
		
		bool bLock
		{
			get const
			{
				return c_bLock;
			}
			set
			{
				c_bLock = value;
			}
		}
		
		bool bSprayBan
		{
			get const
			{
				return c_bSprayBan;
			}
			set
			{
				c_bSprayBan = c_bLock ? c_bSprayBan : value;
			}
		}
		
		int iGagMode
		{
			get const
			{
				return c_iGagMode;
			}
			set
			{
				c_iGagMode = c_bLock ? c_iGagMode : value;
			}
		}
	}
	
	AFBaseUser@ GetUser(CBasePlayer@ pUser)
	{
		return g_afbUserList.exists(pUser.entindex()) ? cast<AFBaseUser@>(g_afbUserList[pUser.entindex()]) : null;
	}
	
	AFBaseUser@ GetUser(int iIndex)
	{
		return g_afbUserList.exists(iIndex) ? cast<AFBaseUser@>(g_afbUserList[iIndex]) : null;
	}
	
	funcdef void AFBaseCommandCallback(AFBaseArguments@);
	
	class AFBaseCommand
	{
		private string sName = "";
		private string sENameID = "";
		private string sDescription = "";
		private string sReqArgs = "";
		private int iAccess = 0;
		private AFBaseCommandCallback@ cCallback;
		private bool bSupressChat = false;
		private CClientCommand@ c_cClientCom;
		private bool bPrecacheGuard = false;
		
		bool PrecacheGuard
		{
			get const
			{
				return bPrecacheGuard;
			}
			set
			{
				bPrecacheGuard = value;
			}
		}
		
		CClientCommand@ ClientCommand
		{
			get
			{
				return c_cClientCom;
			}
			set
			{
				@c_cClientCom = value;
			}
		}
		
		bool SupressChat
		{
			get const
			{
				return bSupressChat;
			}
			set
			{
				bSupressChat = value;
			}
		}
		
		AFBaseCommandCallback@ CallBack
		{
			get const
			{
				return cCallback;
			}
			set
			{
				@cCallback = value;
			}
		}
		
		int AccessFlags
		{
			get const
			{
				return iAccess;
			}
			set
			{
				iAccess = value;
			}
		}
		
		string ReqArguments
		{
			get const
			{
				return sReqArgs;
			}
			set
			{
				sReqArgs = value;
			}
		}
		
		string Description
		{
			get const
			{
				return sDescription;
			}
			set
			{
				sDescription = value;
			}
		}
		
		string ExpansionNameID
		{
			get const
			{
				return sENameID;
			}
			set
			{
				sENameID = value;
			}
		}
		
		string Name
		{
			get const
			{
				return sName;
			}
			set
			{
				sName = value;
			}
		}
	}
	
	void ParseCommand(string &in sInput, int &out iCmdAccess, string &out sENameID, string &out sVisual)
	{
		array<string> parsed = sInput.Split("§!%§");
		iCmdAccess = atoi(parsed[0]);
		sENameID = parsed[1];
		sVisual = parsed[2];
	}
	
	bool InsertCommand(string sENameID, string sName, string sReqArgs, string sDescription, int iAccess, AFBaseCommandCallback@ callback, bool bPrecacheGuard, bool bSupressChat)
	{
		AFBaseCommand command;
		
		@command.CallBack = callback;
		command.AccessFlags = iAccess;
		command.Description = sDescription;
		command.ReqArguments = sReqArgs;
		command.ExpansionNameID = sENameID;
		command.Name = sName;
		command.SupressChat = bSupressChat;
		command.PrecacheGuard = bPrecacheGuard;

		if(sName.SubString(0, 4) == "say ")
		{
			string sFixName = sName.SubString(4, sName.Length()-4);
			array<string> sHold = g_afbChatCommandList.getKeys();
			if(sHold.find(sFixName) > -1)
			{
				BaseLog("Can't register command \""+sName+"\": command already exists!");
				return false;
			}
			string sLowerCommand = sFixName;
			sLowerCommand = sLowerCommand.ToLowercase();
			
			g_afbChatCommandList[sLowerCommand] = command;
			g_afbCommandList.insertLast(string(iAccess)+"§!%§"+sENameID+"§!%§"+sName+" "+sDescription);
		}else{
			@command.ClientCommand = CClientCommand(sName, "", @HandleClientConsole);
			array<string> sHold = g_afbConCommandList.getKeys();
			if(sHold.find(sName) > -1)
			{
				BaseLog("Can't register command \""+sName+"\": command already exists!");
				return false;
			}
			
			g_afbConCommandList[sName] = command;
			g_afbCommandList.insertLast(string(iAccess)+"§!%§"+sENameID+"§!%§."+sName+" "+sDescription);
		}
		
		
		return true;
	}
	
	void AddExpansion(AFBaseClass@ afbExpansion)
	{
		BaseLog("Registering expansion: "+afbExpansion.ExpansionName+" (SID: "+afbExpansion.ShortName+") by "+afbExpansion.AuthorName);
		array<string> sHold = g_afbExpansionList.getKeys();
		if(sHold.find(afbExpansion.ShortName) > -1)
		{
			BaseLog("Can't register expansion \""+afbExpansion.ExpansionName+"\": SID \""+afbExpansion.ShortName+"\" is already reserved!");
			return;
		}
		
		g_afbExpansionList[afbExpansion.ShortName] = @afbExpansion;
		afbExpansion.Running = true;
		afbExpansion.ExpansionInit();
	}
	
	HookReturnCode HandleClientChat(SayParameters@ sparams)
	{
		CBasePlayer@ pUser = sparams.GetPlayer();
		const CCommand@ args = sparams.GetArguments();
		if(args.ArgC() <= 0)
			return HOOK_CONTINUE;
		
		array<string> parsedCommand;
		for(int i = 0; i < args.ArgC(); i++)
			parsedCommand.insertLast(args.Arg(i));
			
		string sLowerCommand = parsedCommand[0];
		sLowerCommand = sLowerCommand.ToLowercase();
			
		if(g_afbChatCommandList.exists(sLowerCommand))
		{
			if(HandleCommandExecution(pUser, parsedCommand, HUD_PRINTTALK, sparams.GetSayType(), false))
			{
				sparams.set_ShouldHide(true);
				return HOOK_HANDLED;
			}
		}
		
		return HOOK_CONTINUE;
	}
	
	void HandleClientConsole(const CCommand@ args)
	{
		array<string> parsedCommand;
		for(int i = 0; i < args.ArgC(); i++)
			parsedCommand.insertLast(args.Arg(i));
		
		int iFix = parsedCommand[0].FindFirstOf(".", 0);
		if(iFix > -1)
			parsedCommand[0] = parsedCommand[0].SubString(iFix+1, parsedCommand[0].Length()-(iFix+1));
		
		CBasePlayer@ pUser = g_ConCommandSystem.GetCurrentPlayer();
		HandleCommandExecution(pUser, parsedCommand, HUD_PRINTCONSOLE, CLIENTSAY_SAY, true);
	}
	
	bool HandleCommandExecution(CBasePlayer@ pUser, array<string> parsedCommand, HUD targetPrint, ClientSayType cSayType, bool bConsole)
	{
		AFBaseCommand@ command;
		string sLowerCommand = parsedCommand[0];
		sLowerCommand = sLowerCommand.ToLowercase();
		if(bConsole)
			@command = cast<AFBaseCommand@>(g_afbConCommandList[parsedCommand[0]]);
		else
			@command = cast<AFBaseCommand@>(g_afbChatCommandList[sLowerCommand]);
		if(command is null)
		{
			BaseLog("Command execution failed: callback null!");
			BaseLog("Caller: "+pUser.pev.netname);
			BaseLog("Contents: ");
			for(uint i = 0; i < parsedCommand.length(); i++)
			{
				BaseLog(string(i)+" -> "+parsedCommand[i]);
			}
			return false;
		}
		
		if(!CheckAccess(pUser, command.AccessFlags))
		{
			BaseTell("You do not have access to this command!", pUser, targetPrint);
			return command.SupressChat;
		}
		
		AFBaseClass@ AFBClass = cast<AFBaseClass@>(g_afbExpansionList[command.ExpansionNameID]);
		if(!AFBClass.Running)
		{
			BaseTell("Extension stopped: can't execute command.", pUser, targetPrint);
			return command.SupressChat;
		}
		
		if(command.PrecacheGuard && !g_afbIsSafePlugin)
		{
			BaseTell("Command blocked, requires precaching first! Please wait for a map change.", pUser, targetPrint);
			return command.SupressChat;
		}
		
		AFBaseArguments afbArguments;
		@afbArguments.User = pUser;
		afbArguments.SayType = cSayType;
		afbArguments.IsChat = !bConsole;
		
		uint iArgCount = 0;
		for(uint i = 0; i < command.ReqArguments.Length(); i++)
		{
			if(command.ReqArguments.opIndex(i) == '!')
				break;
				
			if(command.ReqArguments.opIndex(i) == 'v')
				iArgCount += 2;
				
			iArgCount++;
		}
		
		if(iArgCount > parsedCommand.length()-1)
		{
			BaseTell("Missing arguments! Usage:", pUser, targetPrint);
			if(bConsole)
				BaseTellLong("."+command.Name+" "+command.Description, pUser, targetPrint);
			else
				BaseTellLong(command.Name+" "+command.Description, pUser, targetPrint);
				
			return command.SupressChat;
		}	
		
		dictionary dOutArguments;
		uint iDLength = 0;
		uint iOffset = 1;
		for(uint i = 0; i < command.ReqArguments.Length(); i++)
		{
			char cCharAtIndex = command.ReqArguments.opIndex(i);
			if(cCharAtIndex == '!')
				continue;

			if(iDLength+iOffset > parsedCommand.length()-1)
				break;

			string sCurrent = parsedCommand[iDLength+iOffset];
			if(cCharAtIndex == 'b')
			{
				int bBool = atoi(sCurrent) == 1 || sCurrent.ToLowercase() == "true" ? 1 : 0;
				dOutArguments[iDLength] = bBool;
			}else if(cCharAtIndex == 's')
			{
				string sString = "";
				if(sCurrent.SubString(0, 2) == "r#")
					sString = string(rxytoval(sCurrent));
				else
					sString = sCurrent;
				dOutArguments[iDLength] = sString;
			}else if(cCharAtIndex == 'f')
			{
				float fFloat = 0.0f;
				if(sCurrent.SubString(0, 2) == "r#")
					fFloat = rxytoval(sCurrent);
				else
					fFloat = atof(sCurrent);
				dOutArguments[iDLength] = fFloat;
			}else if(cCharAtIndex == 'i')
			{
				int iInt = 0;
				if(sCurrent.SubString(0, 2) == "r#")
					iInt = intrxytoval(sCurrent);
				else
					iInt = atoi(sCurrent);
				dOutArguments[iDLength] = iInt;
			}else if(cCharAtIndex == 'v')
			{
				Vector vVector = Vector(0,0,0);
				if(sCurrent.SubString(0, 2) == "r#")
					vVector.x = rxytoval(sCurrent);
				else
					vVector.x = atof(sCurrent);
					
				string sOff = parsedCommand[iDLength+iOffset+1];
					
				if(sOff.SubString(0, 2) == "r#")
					vVector.y = rxytoval(sOff);
				else
					vVector.y = atof(sOff);
					
				sOff = parsedCommand[iDLength+iOffset+2];
					
				if(sOff.SubString(0, 2) == "r#")
					vVector.z = rxytoval(sOff);
				else
					vVector.z = atof(sOff);
				dOutArguments[iDLength] = vVector;
				iOffset += 2;
			}
			
			iDLength++;
		}
		
		afbArguments.Args = dOutArguments;
		afbArguments.RawArgs = parsedCommand;
		afbArguments.bWLock = true;
		AFBaseCommandCallback@ callback = @command.CallBack;
		callback(afbArguments);
		return command.SupressChat;
	}
	
	float rxytoval(string input)
	{
		string inputb = input;
		if(inputb.SubString(0, 2) == "r#") // rechecking input
			inputb = input.SubString(2, input.Length()-2);
			
		array<string> inputc = inputb.Split("-");
		
		if(inputc.length() >= 2)
		{
			float fff = Math.RandomFloat(atof(inputc[0]), atof(inputc[1]));
			return fff;
		}
			
		if(inputc.length() == 1)
		{
			return atof(inputc[0]);
		}
			
		return 0.0f;
	}
	
	int intrxytoval(string input)
	{
		return int(floor(rxytoval(input)+0.5f));
	}
	
	array<string> ExplodeString(string sIn, string sNo)
	{
		array<string> aSHold;
		for(uint i = 0; i < sIn.Length(); i++)
		{
			if(sNo == string(sIn.opIndex(i)))
				continue;
				
			aSHold.insertLast(string(sIn.opIndex(i)));
		}
		
		return aSHold;
	}
	
	string ImplodeString(array<string> sIn)
	{
		string sHold = "";
		for(uint i = 0; i < sIn.length(); i++)
		{
			sHold += sIn[i];
		}
		
		return sHold;
	}
	
	void UpdateAccessFile(string sId, string sAccess)
	{
		array<string> aSHold;
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseAccess.txt", OpenFile::READ);
		bool bUpdatedEntry = false;
		bool bReadFile = false;
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				array<string> parsed = sLine.Split(" ");
				if(parsed.length() < 2)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(parsed[0] != sId)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				//just makin sure linux wont fuck
				sFix = parsed[1].SubString(parsed[1].Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					parsed[1] = parsed[1].SubString(0, parsed[1].Length()-1);
					
				if(sAccess != "")
				{
					aSHold.insertLast(parsed[0]+" "+sAccess);
					BaseLog("Updated access ("+sAccess+"z) to "+sId);
					bUpdatedEntry = true;
				}else{
					BaseLog("Updated access (z) to "+sId);
					bUpdatedEntry = true;
				}
			}
			
			bReadFile = true;
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate access file");
			return;
		}
		
		if(bReadFile)
			if(!bUpdatedEntry)
			{
				aSHold.insertLast(sId+" "+sAccess);
				BaseLog("Added new access ("+sAccess+"z) to "+sId);
			}
		
		@file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseAccess.txt", OpenFile::WRITE);
		if(file !is null && file.IsOpen())
		{
			for(uint i = 0; i < aSHold.length(); i++)
			{
				if(i < aSHold.length()-1)
					file.Write(aSHold[i]+"\n");
				else
					file.Write(aSHold[i]);
			}
			
			file.Close();
		}
	}
	
	void UpdateSprayFile(string sId, bool bMode)
	{
		array<string> aSHold;
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseSprayBans.txt", OpenFile::READ);
		bool bUpdatedEntry = false;
		bool bReadFile = false;
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(sLine != sId)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(!bMode)
				{
					BaseLog("Updated spraybanfile: unbanned "+sId);
					bUpdatedEntry = true;
				}
			}
			
			bReadFile = true;
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate sprayban file");
			return;
		}
		
		if(bReadFile)
			if(!bUpdatedEntry && bMode)
			{
				aSHold.insertLast(sId);
				BaseLog("Updated spraybanfile: banned "+sId);
			}
		
		@file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseSprayBans.txt", OpenFile::WRITE);
		if(file !is null && file.IsOpen())
		{
			for(uint i = 0; i < aSHold.length(); i++)
			{
				if(i < aSHold.length()-1)
					file.Write(aSHold[i]+"\n");
				else
					file.Write(aSHold[i]);
			}
			
			file.Close();
		}
	}
	
	void UpdateGagFile(string sId, int iMode)
	{
		array<string> aSHold;
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseGagBans.txt", OpenFile::READ);
		bool bUpdatedEntry = false;
		bool bReadFile = false;
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
				{
					aSHold.insertLast(sLine);
					continue;
				}
				
				array<string> parsed = sLine.Split(" ");
					
				if(parsed.length() < 2)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(parsed[0] != sId)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(iMode == -1)
				{
					BaseLog("Updated gagbanfile: unbanned "+sId);
					bUpdatedEntry = true;
				}
			}
			
			bReadFile = true;
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate gagban file");
			return;
		}
		
		if(bReadFile)
			if(!bUpdatedEntry && iMode != -1)
			{
				aSHold.insertLast(sId+" "+string(iMode));
				BaseLog("Updated gagban: banned "+sId);
			}
		
		@file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseGagBans.txt", OpenFile::WRITE);
		if(file !is null && file.IsOpen())
		{
			for(uint i = 0; i < aSHold.length(); i++)
			{
				if(i < aSHold.length()-1)
					file.Write(aSHold[i]+"\n");
				else
					file.Write(aSHold[i]);
			}
			
			file.Close();
		}
	}
	
	bool UpdateBanFile(string sInput, int iMinutes, string sReason, bool bIsIp)
	{
		array<string> aSHold;
		string sFileToUse = bIsIp ? "scripts/plugins/store/AFBaseIPBans.txt" : "scripts/plugins/store/AFBaseIDBans.txt";
		File@ file = g_FileSystem.OpenFile(sFileToUse, OpenFile::READ);
		bool bUpdatedEntry = false;
		bool bReadFile = false;
		bool bOutput = false;
		
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
				{
					aSHold.insertLast(sLine);
					continue;
				}
				
				array<string> parsed = sLine.Split(" ");
					
				if(parsed.length() < 3)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(parsed[0] != sInput)
				{
					aSHold.insertLast(sLine);
					continue;
				}
					
				if(iMinutes == -1)
				{
					if(bIsIp)
						BaseLog("Updated IP ban file: unbanned "+sInput);
					else
						BaseLog("Updated ID ban file: unbanned "+sInput);
					bUpdatedEntry = true;
					bOutput = true;
				}
			}
			
			bReadFile = true;
			file.Close();
		}else{
			if(bIsIp)
				BaseLog("Installation error: cannot locate IP ban file");
			else
				BaseLog("Installation error: cannot locate ID ban file");
			return false;
		}
		
		if(bReadFile)
			if(!bUpdatedEntry && iMinutes != -1)
			{
				if(iMinutes == 0)
				{
					aSHold.insertLast(sInput+" 0 "+sReason);
				}else{
					DateTime datetime;
					time_t unixtime = datetime.ToUnixTimestamp();
					datetime.SetUnixTimestamp(unixtime + (iMinutes*60));
					string unixTime = datetime.ToUnixTimestamp();
					aSHold.insertLast(sInput+" "+string(unixTime)+" "+sReason);
				}
				
				if(bIsIp)
					BaseLog("Updated ip ban: banned "+sInput);
				else
					BaseLog("Updated id ban: banned "+sInput);
			}
		
		@file = g_FileSystem.OpenFile(sFileToUse, OpenFile::WRITE);
		if(file !is null && file.IsOpen())
		{
			for(uint i = 0; i < aSHold.length(); i++)
			{
				if(i < aSHold.length()-1)
					file.Write(aSHold[i]+"\n");
				else
					file.Write(aSHold[i]);
			}
			
			file.Close();
		}
		
		return bOutput;
	}
	
	bool CheckAccess(CBasePlayer@ pUser, int iCheckAccess)
	{		
		AFBaseUser@ afbUser = cast<AFBaseUser@>(g_afbUserList[pUser.entindex()]);
		if(afbUser is null)
			return false;
		
		if(afbUser.iAccess & iCheckAccess == iCheckAccess)
			return true;
			
		return false;
	}
	
	bool CheckAccess(int sId, int iCheckAccess)
	{
		AFBaseUser@ afbUser = cast<AFBaseUser@>(g_afbUserList[sId]);
		if(afbUser.iAccess & iCheckAccess == iCheckAccess)
			return true;
			
		return false;
	}
	
	void translateAccess(string &in sIn, string &out sAcc, int &out iAcc)
	{
		int iOutAccess = ACCESS_Z;
		// pretty sure theres a better way, GOOD THING NOTEPAD++ CAN COLLAPSE PARTS
		for(uint i = 0; i < sIn.Length(); i++)
		{
			char cChar = sIn.ToLowercase().opIndex(i);
			if(cChar == 'a')					// thank god for automation :> typing this out would be a pain in the ass
			{
				iOutAccess |= ACCESS_A;
			}else if(cChar == 'b')
				iOutAccess |= ACCESS_B;
			else if(cChar == 'c')
				iOutAccess |= ACCESS_C;
			else if(cChar == 'd')
				iOutAccess |= ACCESS_D;
			else if(cChar == 'e')
				iOutAccess |= ACCESS_E;
			else if(cChar == 'f')
				iOutAccess |= ACCESS_F;
			else if(cChar == 'g')
				iOutAccess |= ACCESS_G;
			else if(cChar == 'h')
				iOutAccess |= ACCESS_H;
			else if(cChar == 'i')
				iOutAccess |= ACCESS_I;
			else if(cChar == 'j')
				iOutAccess |= ACCESS_J;
			else if(cChar == 'k')
				iOutAccess |= ACCESS_K;
			else if(cChar == 'l')
				iOutAccess |= ACCESS_L;
			else if(cChar == 'm')
				iOutAccess |= ACCESS_M;
			else if(cChar == 'n')
				iOutAccess |= ACCESS_N;
			else if(cChar == 'o')
				iOutAccess |= ACCESS_O;
			else if(cChar == 'p')
				iOutAccess |= ACCESS_P;
			else if(cChar == 'q')
				iOutAccess |= ACCESS_Q;
			else if(cChar == 'r')
				iOutAccess |= ACCESS_R;
			else if(cChar == 's')
				iOutAccess |= ACCESS_S;
			else if(cChar == 't')
				iOutAccess |= ACCESS_T;
			else if(cChar == 'u')
				iOutAccess |= ACCESS_U;
			else if(cChar == 'v')
				iOutAccess |= ACCESS_V;
			else if(cChar == 'w')
				iOutAccess |= ACCESS_W;
			else if(cChar == 'x')
				iOutAccess |= ACCESS_X;
			else if(cChar == 'y')
				iOutAccess |= ACCESS_Y;
		}
		
		sAcc = sIn.ToLowercase()+"z";
		iAcc = iOutAccess;
	}
	
	void HandleAccess(string sID, int iIndex)
	{
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseAccess.txt", OpenFile::READ);
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
					
				array<string> parsed = sLine.Split(" ");
				if(parsed.length() < 2)
					continue;
					
				if(parsed[0] != sID)
					continue;
					
				//just makin sure linux wont fuck
				sFix = parsed[1].SubString(parsed[1].Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					parsed[1] = parsed[1].SubString(0, parsed[1].Length()-1);
					
				string sHacc = "";
				int iHacc = 0;
				translateAccess(parsed[1], sHacc, iHacc);
				array<string> sHold = ExplodeString(sHacc, "z"); // hackfix: remove extra z:s
				sHacc = ImplodeString(sHold);
				sHacc += "z";
				
				BaseLog("Granted access ("+sHacc+") to "+sID);
				AFBaseUser afbUser = cast<AFBaseUser@>(g_afbUserList[iIndex]);
				afbUser.bLock = false;
				afbUser.iAccess = iHacc;
				afbUser.sAccess = sHacc;
				afbUser.bLock = true;
				g_afbUserList[iIndex] = afbUser;
				file.Close();
				break;
			}
			
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate access file");
		}
	}
	
	void HandleSprayban(string sID, int iIndex)
	{
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseSprayBans.txt", OpenFile::READ);
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
					
				if(sLine != sID)
					continue;
				
				BaseLog("Applied spray block for "+sID);
				AFBaseUser afbUser = cast<AFBaseUser@>(g_afbUserList[iIndex]);
				afbUser.bLock = false;
				afbUser.bSprayBan = true;
				afbUser.bLock = true;
				g_afbUserList[iIndex] = afbUser;
				file.Close();
				break;
			}
			
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate sprayban file");
		}
	}
	
	void HandleGagban(string sID, int iIndex)
	{
		File@ file = g_FileSystem.OpenFile("scripts/plugins/store/AFBaseGagBans.txt", OpenFile::READ);
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
					
				array<string> parsed = sLine.Split(" ");
				if(parsed.length() < 2)
					continue;
					
				if(parsed[0] != sID)
					continue;
					
				//just makin sure linux wont fuck
				sFix = parsed[1].SubString(parsed[1].Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					parsed[1] = parsed[1].SubString(0, parsed[1].Length()-1);
				
				BaseLog("Applied gag block for "+sID);
				AFBaseUser afbUser = cast<AFBaseUser@>(g_afbUserList[iIndex]);
				afbUser.bLock = false;
				afbUser.iGagMode = atoi(parsed[1]);
				afbUser.bLock = true;
				g_afbUserList[iIndex] = afbUser;
				file.Close();
				break;
			}
			
			file.Close();
		}else{
			BaseLog("Installation error: cannot locate gagban file");
		}
	}
	
	void ReadBanString(string &in sInput, int &out iMinutes, string &out sReason)
	{
		array<string> parsed = sInput.Split("§§§§");
		sReason = parsed[1];
		//BaseLog("reading: time is "+parsed[0]);
		//BaseLog("reading: reason is "+parsed[1]);
		
		
		if(parsed[0] != "-1" && parsed[0] != "0")
		{
			DateTime datetime;
			time_t unixtime = datetime.ToUnixTimestamp();
			DateTime datetime2 = datetime;
			datetime2.SetUnixTimestamp(atoi(parsed[0]));
			time_t unixtime2 = datetime2.ToUnixTimestamp();
			time_t unixtimeleft = unixtime2-unixtime;
			bool bPass = unixtime2 < unixtime ? true : false;
			if(bPass)
			{
				iMinutes = -2;
			}else{
				int iWanted = int(unixtimeleft/60);
				if(iWanted < 1)
					iWanted = 1; // fix: dont show "Permanent ban" for last minute lmao
				iMinutes = iWanted;
			}
		}else if(parsed[0] == "0")
		{
			iMinutes = 0;
		}else{
			iMinutes = -1;
		}
		
	}
	
	string HandleBan(string sInput, bool bIsIp) // special!
	{
		string sFileToUse = bIsIp ? "scripts/plugins/store/AFBaseIPBans.txt" : "scripts/plugins/store/AFBaseIDBans.txt";
		string sOutput = "-1§§§§N/A";
		File@ file = g_FileSystem.OpenFile(sFileToUse, OpenFile::READ);
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				//fix for linux
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
					
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
					
				array<string> parsed = sLine.Split(" ");
				if(parsed.length() < 3)
					continue;
					
				if(parsed[0] != sInput)
					continue;
					
				string sMinutes = parsed[1];
				string sReason = "";
				for(uint i = 2; i < parsed.length; i++)
					if(i > 2)
						sReason += " "+parsed[i];
					else
						sReason += parsed[i];
					
				sOutput = sMinutes+"§§§§"+sReason;
				file.Close();
				break;
			}
			
			file.Close();
		}else{
			if(bIsIp)
				BaseLog("Installation error: cannot locate IP ban file");
			else
				BaseLog("Installation error: cannot locate ID ban file");
		}
		
		return sOutput;
	}
	
	void BaseTell(string sMsg, CBasePlayer@ pUser, HUD hudTarget)
	{
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "[AFB] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "[AFB] "+sMsg+"\n");
	}
	
	void BaseTellLong(string sMsg, CBasePlayer@ pUser, HUD targetHud)
	{
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
	
	void BaseTellAll(string sMsg, HUD hudTarget)
	{
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrintAll(hudTarget, "[AFB] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrintAll(hudTarget, "[AFB] "+sMsg+"\n");
	}
	
	bool GetTargetPlayers(CBasePlayer@ &in pSelf, HUD &in hudTarget, string &in sInput, int &in iFlags, array<CBasePlayer@> &out pTargets)
	{
		string sFilterInput = sInput.ToLowercase();
		array<CBasePlayer@> aCBPHold;
		if(sFilterInput == "@all" && iFlags & TARGETS_NOALL == 0)
		{
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
					if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
						aCBPHold.insertLast(pSearch);
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Failed to find targets.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@admins" && iFlags & TARGETS_NOALL == 0)
		{
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
					if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
						if(afbUser.iAccess >= 2)
							aCBPHold.insertLast(pSearch);
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find targets.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@noadmins" && iFlags & TARGETS_NOALL == 0)
		{
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
					if(afbUser.iAccess <= 1)
						aCBPHold.insertLast(pSearch);
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Failed to find targets.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@dead" && iFlags & TARGETS_NODEAD == 0 && iFlags & TARGETS_NOALL == 0)
		{	
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive())
					{
						afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
						if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
							aCBPHold.insertLast(pSearch);
					}
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find targets.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@alive" && iFlags & TARGETS_NOALIVE == 0 && iFlags & TARGETS_NOALL == 0)
		{	
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(pSearch.IsAlive())
					{
						afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
						if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
							aCBPHold.insertLast(pSearch);
					}
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find targets.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@aim" && iFlags & TARGETS_NOAIM == 0)
		{
			TraceResult tr;
			g_EngineFuncs.MakeVectors(pSelf.pev.v_angle);
			Vector vecSrc = pSelf.GetGunPosition();
			Vector vecAiming = g_Engine.v_forward;
			g_Utility.TraceLine(vecSrc, vecSrc+vecAiming*4096, dont_ignore_monsters, pSelf.edict(), tr);
			CBaseEntity@ pHitEnt = g_EntityFuncs.Instance(tr.pHit);
			CBasePlayer@ pHold = null;
			AFBaseUser afbUser;
			if(pHitEnt !is null)
			{
				if(!pHitEnt.IsPlayer())
				{
					BaseTell("Failed to find target (4096 units).", pSelf, hudTarget);
					return false;
				}
				
				@pHold = cast<CBasePlayer@>(pHitEnt);
				if(pHold !is null)
				{
					afbUser = cast<AFBaseUser@>(g_afbUserList[pHold.entindex()]);
					if(!CheckAccess(pHold, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
					{
							aCBPHold.insertLast(pHold);
					}
				}
			}
			
			if(pHold !is null)
			{
				afbUser = cast<AFBaseUser@>(g_afbUserList[pSelf.entindex()]);
				afbUser.bLock = false;
				afbUser.sLastTarget = string(pHold.entindex());
				afbUser.bLock = true;
				g_afbUserList[pSelf.entindex()] = afbUser;
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Failed to find target (4096 units).", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@random" && iFlags & TARGETS_NORANDOM == 0)
		{
			array<CBasePlayer@> pTemporary;
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
					if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
						pTemporary.insertLast(pSearch);
				}
			}
			
			if(pTemporary.length() > 0)
			{
				@pSearch = pTemporary[Math.RandomLong(0,pTemporary.length()-1)];
				aCBPHold.insertLast(pSearch);
				afbUser = cast<AFBaseUser@>(g_afbUserList[pSelf.entindex()]);
				afbUser.bLock = false;
				afbUser.sLastTarget = string(pSearch.entindex());
				afbUser.bLock = true;
				g_afbUserList[pSelf.entindex()] = afbUser;
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Failed to find target.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@last" && iFlags & TARGETS_NOLAST == 0)
		{
			CBasePlayer@ pSearch = null;
			AFBaseUser afbUser = cast<AFBaseUser@>(g_afbUserList[pSelf.entindex()]);
			int sTargId = atoi(afbUser.sLastTarget);
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					if(sTargId == pSearch.entindex())
					{
						afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
						if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
							aCBPHold.insertLast(pSearch);
					}
				}
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find target. @last is probably empty, it is only set by @aim, @random, nick/steamid.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput == "@me" && iFlags & TARGETS_NOME == 0)
		{
			aCBPHold.insertLast(pSelf);
		
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Something went horribly wrong, if you see this message it probably means you dont exist.", pSelf, hudTarget);
			return false;
		}else if(sFilterInput.SubString(0,6) == "steam_")
		{
			CBasePlayer@ pSearch = null;
			CBasePlayer@ pHold = null;
			AFBaseUser afbUser;
			string sFixId = "";
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					sFixId = FormatSafe(GetFixedSteamID(pSearch));
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
						
					if(sFixId != "")
					{
						string sFix = sFixId; // HACKFIX: calling lowercase and using sFixId causes null pointer
						if(sFixId.ToLowercase() == sFilterInput)
						{
							afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
							if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
							{
								aCBPHold.insertLast(pSearch);
								@pHold = pSearch;
							}
						}
					}
				}
			}
			
			if(pHold !is null)
			{
				afbUser = cast<AFBaseUser@>(g_afbUserList[pSelf.entindex()]);
				afbUser.bLock = false;
				afbUser.sLastTarget = string(pHold.entindex());
				afbUser.bLock = true;
				g_afbUserList[pSelf.entindex()] = afbUser;
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find target steamid, you need quotes around the steamid or you need to check the steamid itself.", pSelf, hudTarget);
			return false;
		}else if(iFlags & TARGETS_NONICK == 0){
			CBasePlayer@ pSearch = null;
			CBasePlayer@ pHold = null;
			AFBaseUser afbUser;
			bool bMatchFull = true;
			string sNick;
			if(sFilterInput.SubString(sFilterInput.Length()-1,1) == "*")
			{
				bMatchFull = false;
				sNick = sFilterInput.SubString(0,sFilterInput.Length()-1);
			}else{
				sNick = sFilterInput;
			}
			
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null && pSearch.IsConnected())
				{
					if(!pSearch.IsAlive() && iFlags & TARGETS_NODEAD > 0)
						continue;
						
					if(pSearch.IsAlive() && iFlags & TARGETS_NOALIVE > 0)
						continue;
					
					afbUser = cast<AFBaseUser@>(g_afbUserList[pSearch.entindex()]);
					if(!CheckAccess(pSearch, ACCESS_A) || iFlags & TARGETS_NOIMMUNITYCHECK > 0)
					{
						if(bMatchFull)
						{
							if(sNick == string(pSearch.pev.netname).ToLowercase())
							{
								aCBPHold.insertLast(pSearch);
								@pHold = pSearch;
							}
						}else{
							string sHold = string(pSearch.pev.netname).ToLowercase();
							if(sNick == sHold.SubString(0,sNick.Length()))
							{
								aCBPHold.insertLast(pSearch);
								@pHold = pSearch;
								break;
							}
						}
					}
				}
			}
			
			if(pHold !is null)
			{
				afbUser = cast<AFBaseUser@>(g_afbUserList[pSelf.entindex()]);
				afbUser.bLock = false;
				afbUser.sLastTarget = string(pHold.entindex());
				afbUser.bLock = true;
				g_afbUserList[pSelf.entindex()] = afbUser;
			}
			
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
		
			BaseTell("Failed to find target nickname, try using quotes and/or wildcard search?", pSelf, hudTarget);
			return false;
		}
		
		BaseTell("Failed to find target, something went horribly wrong.", pSelf, hudTarget);
		return false;
	}
	
	uint cclamp(uint nIn, uint nMin, uint nMax)
	{
		return Math.min(Math.max(nIn, nMin), nMax);
	}

	float cclamp(float fIn, float fMin, float fMax)
	{
		return Math.min(Math.max(fIn, fMin), fMax);
	}

	int cclamp(int iIn, int iMin, int iMax)
	{
		return Math.min(Math.max(iIn, iMin), iMax);
	}
	
	void SendMessage(MessageData@ msgData)
	{
		array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
		AFBase::AFBaseClass@ AFBClass;
		for(uint i = 0; i < afbKeys.length(); i++)
		{
			@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[afbKeys[i]]);
			if(AFBClass !is null)
			{
				if(msgData.sReceiver == "*" && AFBClass.ShortName != msgData.sSender)
					AFBClass.receiveMessage(msgData);
				else if(AFBClass.ShortName == msgData.sReceiver && AFBClass.ShortName != msgData.sSender)
					AFBClass.receiveMessage(msgData);
			}
		}
	}
}

class AFBaseArguments
{
	private CBasePlayer@ c_ehUser;
	private ClientSayType c_csType;
	private dictionary c_dArguments;
	private array<string> c_asRawArgs;
	private bool c_bLock;
	private bool c_bChat;
	
	bool IsChat
	{
		get const
		{
			return c_bChat;
		}
		set
		{
			c_bChat = c_bLock ? c_bChat : value;
		}
	}
	
	array<string> RawArgs
	{
		get const
		{
			return c_asRawArgs;
		}
		set
		{
			c_asRawArgs = c_bLock ? c_asRawArgs : value;
		}
	}
	
	bool bWLock
	{
		get const
		{
			return c_bLock;
		}
		set
		{
			c_bLock = value;
		}
	}
	
	CBasePlayer@ User
	{
		get const
		{
			return c_ehUser;
		}
		set
		{
			 @c_ehUser = c_bLock ? c_ehUser : value;
		}
	}
	
	ClientSayType SayType
	{
		get const
		{
			return c_csType;
		}
		set
		{
			c_csType = c_bLock ? c_csType : value;
		}
	}
	
	dictionary Args
	{
		get const
		{
			return c_dArguments;
		}
		set
		{
			c_dArguments = c_bLock ? c_dArguments : value;
		}
	}
	
	int GetCount()
	{
		return c_dArguments.getSize();
	}
	
	bool GetBool(int i)
	{
		bool bOut = int(c_dArguments[i]) > 0 ? true : false;
		return bOut;
	}
	
	int GetInt(int i)
	{
		int iOut = int(c_dArguments[i]);
		return iOut;
	}
	
	float GetFloat(int i)
	{
		float fOut = float(c_dArguments[i]);
		return fOut;
	}
	
	string GetString(int i)
	{
		string sOut = string(c_dArguments[i]);
		return sOut;
	}
	
	Vector GetVector(int i)
	{
		Vector vOut = Vector(c_dArguments[i]);
		return vOut;
	}
}

class MessageData
{
	string sSender;
	string sReceiver;
	string sIdentifier;
	dictionary dData;
}

abstract class AFBaseClass
{
	private string c_sAuthorName;
	private string c_sExpansionName;
	private string c_sShortName;
	private bool c_bRunning;
	private bool c_bOverride;
	
	bool Running
	{
		get const
		{
			return c_bRunning;
		}
		set
		{
			c_bRunning = value;
		}
	}
	
	bool StatusOverride
	{
		get const
		{
			return c_bOverride;
		}
		set
		{
			c_bOverride = value;
		}
	}
	
	string AuthorName
	{
		get const
		{
			return c_sAuthorName;
		}
		set
		{
			c_sAuthorName = value;
		}
	}
	
	string ExpansionName
	{
		get const
		{
			return c_sExpansionName;
		}
		set
		{
			c_sExpansionName = value;
		}
	}
	
	string ShortName
	{
		get const
		{
			return c_sShortName;
		}
		set
		{
			c_sShortName = AFBase::FormatSafe(value);
		}
	}
	
	void ExpansionInfo() {} // user define
	
	void ExpansionInit() {} // user define
	
	void MapInit() {} // user define
	
	void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, AFBase::AFBaseCommandCallback@ callback, bool bPrecacheGuard, bool bSupressChat) final
	{
		bool bInserted = AFBase::InsertCommand(this.ShortName, sCommand, sReqArgs, sDescription, iAccess, callback, bPrecacheGuard, bSupressChat);
		if(!bInserted)
		{
			this.Running = false;
			this.Log("Stopped: command register failed!");
		}
	}
	
	void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, AFBase::AFBaseCommandCallback@ callback, bool bPrecacheGuard) final
	{
		bool bInserted = AFBase::InsertCommand(this.ShortName, sCommand, sReqArgs, sDescription, iAccess, callback, bPrecacheGuard, false);
		if(!bInserted)
		{
			this.Running = false;
			this.Log("Stopped: command register failed!");
		}
	}
	
	void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, AFBase::AFBaseCommandCallback@ callback) final
	{
		bool bInserted = AFBase::InsertCommand(this.ShortName, sCommand, sReqArgs, sDescription, iAccess, callback, false, false);
		if(!bInserted)
		{
			this.Running = false;
			this.Log("Stopped: command register failed!");
		}
	}
	
	void RegisterExpansion(AFBaseClass@ afbExpansion) final
	{
		afbExpansion.ExpansionInfo();
		AFBase::AddExpansion(afbExpansion);
	}
	
	void ClientConnect(CBasePlayer@ pUser) final
	{
		if(this.Running)
			ClientConnectEvent(pUser);
	}
	
	void ClientConnectEvent(CBasePlayer@ pUser) {} // user define
	
	void ClientDisconnect(CBasePlayer@ pUser) final
	{
		if(this.Running)
			ClientDisconnectEvent(pUser);
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pUser) {} // user define
	
	void NameChange(AFBase::AFBaseUser@ afbUser) final
	{
		if(this.Running)
			NameChangeEvent(afbUser);
	}
	
	void NameChangeEvent(AFBase::AFBaseUser@ afbUser) {} // user define
	
	void Stop() final
	{
		this.Running = false;
		StopEvent();
	}
	
	void Start() final
	{
		this.Running = true;
		StartEvent();
	}
	
	void StopEvent() {} // user define
	
	void StartEvent() {} // user define
	
	void SendMessage(string sReceiver, string sIdentifier, dictionary dData) final
	{
		if(sIdentifier == "")
			this.Log("Can't send message, identifier missing!");
			
		if(sReceiver == "")
			this.Log("Can't send message \""+sIdentifier+"\", receiver missing!");
			
		MessageData msgData;
		msgData.sSender = this.ShortName;
		msgData.sReceiver = sReceiver;
		msgData.sIdentifier = sIdentifier;
		msgData.dData = dData;
		AFBase::SendMessage(msgData);
	}
	
	void receiveMessage(MessageData@ msgData) final
	{
		if(this.Running)
			ReceiveMessageEvent(msgData.sSender, msgData.sIdentifier, msgData.dData);
	}
	
	void ReceiveMessageEvent(string sSender, string sIdentifier, dictionary dData) {} // user define
	
	void Log(string sMsg) final
	{
		g_Game.AlertMessage(at_logged, "[AFB -> "+this.ShortName+"] "+sMsg+"\n");
	}
	
	void Tell(string sMsg, CBasePlayer@ pUser, HUD hudTarget) final
	{
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
	}
	
	void TellAll(string sMsg, HUD hudTarget) final
	{
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrintAll(hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrintAll(hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
	}
	
	void TellLong(string sMsg, CBasePlayer@ pUser, HUD targetHud)
	{
		string sHoldIn;
		if(targetHud == HUD_PRINTTALK)
			sHoldIn = "["+this.ShortName+"] "+sMsg+"\n";
		else
			sHoldIn = "["+this.ShortName+"] "+sMsg+"\n";
		while(sHoldIn.Length() > 128)
		{
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn);
	}
}

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
		RegisterCommand("afb_help", "!ib", "<page> <0/1 show expansion> - List available commands", ACCESS_Z, @AFBaseBase::help);
		RegisterCommand("afb_info", "", "- Show info", ACCESS_Z, @AFBaseBase::info);
		RegisterCommand("afb_who", "!b", "<0/1 don't shorten nicks> - Show client information", ACCESS_Z, @AFBaseBase::who);
		RegisterCommand("afb_listextensions", "", "- List extensions", ACCESS_Z, @AFBaseBase::extlist);
		RegisterCommand("afb_extension_stop", "s", "(\"extension SID\") - stop extension", ACCESS_B, @AFBaseBase::extstop);
		RegisterCommand("afb_extension_start", "s", "(\"extension SID\") - start extension", ACCESS_B, @AFBaseBase::extstart);
		RegisterCommand("afb_access", "s!s", "(target) <accessflags> - get/set accessflags, add + or - before flags to add or remove", ACCESS_B, @AFBaseBase::access); 
		RegisterCommand("admin_kick", "s!s", "(target) <\"reason\"> - kicks target with reason", ACCESS_E, @AFBaseBase::kick);
		RegisterCommand("admin_rcon", "s", "(command) - remote console", ACCESS_C, @AFBaseBase::rcon);
		RegisterCommand("admin_changelevel", "s", "(level) - change level", ACCESS_E, @AFBaseBase::changelevel);
		RegisterCommand("admin_slay", "s", "(target) - slay target(s)", ACCESS_G, @AFBaseBase::slay);
		RegisterCommand("admin_slap", "s!i", "(target) <damage> - slap target(s)", ACCESS_G, @AFBaseBase::slap);
		RegisterCommand("admin_say", "bis!isiiiff", "(0/1 showname) (0/1/2 chat/hud/middle) (\"text\") <holdtime> <target> <r> <g> <b> <x> <y> - say text", ACCESS_H, @AFBaseBase::say);
		RegisterCommand("admin_trackdecals", "!i", "<0/1 mode> - track player sprays, don't define mode to toggle", ACCESS_G, @AFBaseBase::trackdecals);
		RegisterCommand("admin_ban", "s!sib", "(\"steamid\") <\"reason\"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid> - ban target", ACCESS_D, @AFBaseBase::ban);
		RegisterCommand("admin_unban", "s", "(\"steamid or ip\") - unban target", ACCESS_D, @AFBaseBase::unban);
		RegisterCommand("afb_setlast", "s", "(target) - sets last target, use if you only want to select somebody without running a command on them", ACCESS_G, @AFBaseBase::selectlast);
		RegisterCommand("admin_banlate", "s!si", "(\"steamid/ip\") <\"reason\"> <duration in minutes, 0 for infinite> - late ban target, basically adds to ban list. Doesn't validate player like admin_ban does.", ACCESS_D, @AFBaseBase::banlate);
		RegisterCommand("admin_blockdecals", "sb", "(target) (0/1 unban/ban) - Ban target from spraying", ACCESS_G, @AFBaseBase::bandecals);
		RegisterCommand("admin_gag", "ss", "(targets) (mode a/c/v) - gag player, a = all, c = chat, v = voice", ACCESS_G, @AFBaseBase::gag);
		RegisterCommand("admin_ungag", "s", "(targets) - ungag player", ACCESS_G, @AFBaseBase::ungag);
		
		@AFBaseBase::cvar_iBanMaxMinutes = CCVar("afb_maxban", 10080, "maximum time for bans in minutes (default: 10080)", ConCommandFlag::AdminOnly, CVarCallback(this.afb_cvar_ibanmaxminutes));
		
		g_Hooks.RegisterHook(Hooks::Player::PlayerDecal, @AFBaseBase::PlayerDecalHook);
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
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pUser)
	{
		if(AFBaseBase::g_decaltrackers.find(pUser.entindex()) > -1)
			AFBaseBase::g_decaltrackers.removeAt(AFBaseBase::g_decaltrackers.find(pUser.entindex()));
	}
}

namespace AFBaseBase
{
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
				AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[iIndex]);
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
				
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" ungagged player \""+AFArgs.GetString(0)+"\"", HUD_PRINTTALK);
				afbasebase.Tell("Ungagged \""+AFArgs.GetString(0)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" ungagged \""+AFArgs.GetString(0)+"\"");
			}
		}
	}

	HookReturnCode PlayerTalk(SayParameters@ sparams)
	{
		CBasePlayer@ pUser = sparams.GetPlayer();
		
		if(AFBase::g_afbUserList.exists(pUser.entindex()))
		{
			AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[pUser.entindex()]);
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
			return;
			
		if(AFBase::g_afbUserList.exists(pPlayer.entindex()))
		{
			AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[pPlayer.entindex()]);
			if(afbUser.iGagMode >= 2)
			{
				CBasePlayer@ pSearch = null;
				for(int i = 1; i <= g_Engine.maxClients; i++)
				{
					if(pSearch !is null)
						g_EngineFuncs.Voice_SetClientListening(pSearch.entindex(), pPlayer.entindex(), false);
				}
			}else{
				CBasePlayer@ pSearch = null;
				for(int i = 1; i <= g_Engine.maxClients; i++)
				{
					if(pSearch !is null)
						g_EngineFuncs.Voice_SetClientListening(pSearch.entindex(), pPlayer.entindex(), true);
				}
			}
		}
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
				AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[iIndex]);
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
				
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" gagged player \""+AFArgs.GetString(0)+"\" (mode: "+sOutMode+")", HUD_PRINTTALK);
				afbasebase.Tell("Gagged \""+AFArgs.GetString(0)+"\" (mode: "+sOutMode+")", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" gagged \""+AFArgs.GetString(0)+"\" (mode: "+sOutMode+" )");
			}
		}
	}

	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{
		EHandle ePlayer = pPlayer;
		g_Scheduler.SetTimeout("PlayerPostSpawn", 0.1f, ePlayer);
		
		return HOOK_CONTINUE;
	}
	
	void PlayerPostSpawn(EHandle ePlayer)
	{
		if(ePlayer)
		{
			CBaseEntity@ pPlayer = ePlayer;
			CheckSprayBan(cast<CBasePlayer@>(pPlayer));
			CheckGagBan(cast<CBasePlayer@>(pPlayer));
		}
	}
	
	void CheckSprayBan(CBasePlayer@ pTarget)
	{	
		if(pTarget is null)
			return;
			
		if(AFBase::g_afbUserList.exists(pTarget.entindex()))
		{
			AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[pTarget.entindex()]);
			if(afbUser.bSprayBan)
				pTarget.m_flNextDecalTime = Math.FLOAT_MAX;
			else
				pTarget.m_flNextDecalTime = Math.FLOAT_MIN;
		}
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
				AFBase::AFBaseUser afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[iIndex]);
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
				CheckSprayBan(pTarget);
				
				if(bMode)
				{
					afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned player \""+AFArgs.GetString(0)+"\" from spraying decals", HUD_PRINTTALK);
					afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" from spraying decals", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" from spraying decals");
				}else{
					afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" unbanned player \""+AFArgs.GetString(0)+"\" from spraying decals", HUD_PRINTTALK);
					afbasebase.Tell("Unbanned \""+AFArgs.GetString(0)+"\" from spraying decals", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.Log("Admin "+AFArgs.User.pev.netname+" unbanned \""+AFArgs.GetString(0)+"\" from spraying decals");
				}
			}
		}
	}

	void banlate(AFBaseArguments@ AFArgs)
	{
		string sReason = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "banned";
		int iMinutes = AFArgs.GetCount() >= 3 ? AFArgs.GetInt(2) : 30;
		if(iMinutes < 0)
			iMinutes = 0;
			
		if(iMinutes == 0)
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes");
			}else{
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" permanently", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" permanently", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" permanently");
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" for "+string(iMinutes)+" minutes");
			}else{
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" permanently", HUD_PRINTTALK);
				afbasebase.Tell("Banned \""+AFArgs.GetString(0)+"\" permanently", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned \""+AFArgs.GetString(0)+"\" permanently");
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
					AFBase::AFBaseUser afbUser = AFBase::GetUser(pTarget);
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
					
					if(iMinutes == 0)
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
						afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes (reason: "+sReason+")", HUD_PRINTTALK);
						afbasebase.Tell("Banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned player "+pTarget.pev.netname+" ("+sFill+") for "+string(iMinutes)+" minutes with reason \""+sReason+"\"");
					}else{
						afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" banned player "+pTarget.pev.netname+" ("+sFill+") permanently (reason: "+sReason+")", HUD_PRINTTALK);
						afbasebase.Tell("Banned player "+pTarget.pev.netname+" ("+sFill+") permanently with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						afbasebase.Log("Admin "+AFArgs.User.pev.netname+" banned player "+pTarget.pev.netname+" ("+sFill+") permanently with reason \""+sReason+"\"");
					}
					
					AddBan(pTarget, iMinutes, sReason, bBanIp);
					
					/*if(iMinutes > 0)
						g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+" (ban duration: "+string(iMinutes)+")\"\n");
					else
						g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+" (ban duration: permanent)\"\n");
					g_EngineFuncs.ServerCommand("wait\n");
					if(!bBanIp)
						g_EngineFuncs.ServerCommand("banid "+string(iMinutes)+" "+sId+"\n");
					if(bBanIp)
						g_EngineFuncs.ServerCommand("addip "+string(iMinutes)+" "+sIp+"\n");
					g_EngineFuncs.ServerCommand("wait\n");
					if(!bBanIp)
						g_EngineFuncs.ServerCommand("writeid\n");
					if(bBanIp)
						g_EngineFuncs.ServerCommand("writeip\n");*/
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" unbanned "+sHold, HUD_PRINTTALK);
				afbasebase.Tell("Unbanned "+sHold, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" unbanned "+sHold);
			}else{
				afbasebase.Tell("No such entry in ban list!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			if(RemoveBan(sHold, true))
			{
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" unbanned "+sHold, HUD_PRINTTALK);
				afbasebase.Tell("Unbanned "+sHold, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" unbanned "+sHold);
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
			sMessage = " [ADMIN] "+AFArgs.User.pev.netname+": "+sMessage;
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" slapped player "+pTarget.pev.netname+" with "+string(iDamage)+" damage", HUD_PRINTTALK);
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" slayed player "+pTarget.pev.netname, HUD_PRINTTALK);
				afbasebase.Tell("Slayed player "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" slayed player "+pTarget.pev.netname);
				entvars_t@ world = g_EntityFuncs.Instance(0).pev;
				pTarget.TakeDamage(world, world, 2048.0f, DMG_ALWAYSGIB|DMG_CRUSH);
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
		afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" changed level to "+sMap, HUD_PRINTTALK);
		afbasebase.Log("Admin "+AFArgs.User.pev.netname+" changed level to "+sMap);
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
		}
		
		string sOut = AFArgs.GetString(0);
		
		array<string> parsed = sOut.Split(" ");
		if(parsed.length >= 2)
		{
			sOut = parsed[0]+" \"";
			for(uint i = 1; i < parsed.length; i++)
				if(i > 1)
					sOut += " "+parsed[i];
				else
					sOut += parsed[i];
			
			sOut += "\"";
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
				afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" kicked player "+pTarget.pev.netname+" (reason: "+sReason+")", HUD_PRINTTALK);
				afbasebase.Tell("Kicked player "+pTarget.pev.netname+" with reason \""+sReason+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				afbasebase.Log("Admin "+AFArgs.User.pev.netname+" kicked player "+pTarget.pev.netname+" with reason \""+sReason+"\"");
				g_EngineFuncs.ServerCommand("kick #"+string(g_EngineFuncs.GetPlayerUserId(pTarget.edict()))+" \""+sReason+"\"\n");
			}
		}
	}

	void access(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		string sFlags = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1).ToLowercase() : "!";
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
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
					afbasebase.Log(string(AFArgs.User.pev.netname)+" updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z");
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" updated "+pTarget.pev.netname+" access to \""+sNewAccess+"z\"", HUD_PRINTTALK);
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
					afbasebase.Log(string(AFArgs.User.pev.netname)+" updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z");
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAccess+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" updated "+pTarget.pev.netname+" access to \""+sNewAccess+"z\"", HUD_PRINTTALK);
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
					afbasebase.Log(string(AFArgs.User.pev.netname)+" updated "+string(pTarget.pev.netname)+" access to "+sNewAcc);
					afbasebase.Tell("updated "+string(pTarget.pev.netname)+" access to "+sNewAcc+"z", AFArgs.User, HUD_PRINTCONSOLE);
					afbasebase.TellAll("Admin "+AFArgs.User.pev.netname+" updated "+pTarget.pev.netname+" access to \""+sNewAcc+"\"", HUD_PRINTTALK);
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
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----AdminFuckeryBase: Info------------------------------------------------------\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "AFB Version: "+AFBase::g_afInfo+"\n");
		string sSafe = AFBase::g_afbIsSafePlugin ? "Yes" : "No";
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "Safeplugin: "+sSafe+"\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "AFB Users: "+string(AFBase::g_afbUserList.getSize())+"\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "AFB Extensions: "+string(AFBase::g_afbExpansionList.getSize())+"\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "AFB Commands: CON/CHAT "+string(AFBase::g_afbConCommandList.getSize())+"/"+string(AFBase::g_afbChatCommandList.getSize())+" (total: "+string(AFBase::g_afbCommandList.length())+")\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "--------------------------------------------------------------------------------\n");
	}

	void who(AFBaseArguments@ AFArgs)
	{
		AFBase::AFBaseUser@ AFBUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[AFArgs.User.entindex()]);
		bool bNoFormat = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) : false;
		bool bShowAll = false;
		if(AFBUser.iAccess >= 2)
			bShowAll = true;
		array<string> afbKeys = AFBase::g_afbUserList.getKeys();
		string sSpace = "                                                                                                                                                                ";
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----AdminFuckeryBase: Clients on server-----------------------------------------\n");
		if(!bNoFormat)
			g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----Nicks longer than 15 characters have been cut off with \"~\", use .afb_who 1 to remove this\n");
		else
			g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----Nicks are no longer cut off. formatting may fuck up, use .afb_who 0 to fix this\n");
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
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "--------------------------------------------------------------------------------\n");
	}

	void extlist(AFBaseArguments@ AFArgs)
	{
		AFBaseClass@ AFBClass = null;
		array<string> afbKeys = AFBase::g_afbExpansionList.getKeys();
		string sSpace = "                                                                                                                                                                ";
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----AdminFuckeryBase: Extensions------------------------------------------------\n");
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
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "--------------------------------------------------------------------------------\n");
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
						g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Error: Extension "+AFBClass.ShortName+" can't be stopped: locked!\n");
						afbasebase.Log(string(AFArgs.User.pev.netname)+" attempted to stop locked extension "+string(AFBClass.ShortName));
						return;
					}else{
						if(AFBClass.Running)
						{
							g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Stopped extension: "+AFBClass.ShortName+".\n");
							afbasebase.Log(string(AFArgs.User.pev.netname)+" stopped extension "+string(AFBClass.ShortName));
							AFBClass.Stop();
							return;
						}else{
							g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Can't stop extension "+AFBClass.ShortName+": Already stopped!\n");
							afbasebase.Log(string(AFArgs.User.pev.netname)+" attempted to stop already stopped extension "+string(AFBClass.ShortName));
							return;
						}
					}
				}
			}
		}
		
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Failed to find expansion SID, check your spelling (case sensetive).\n");
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
						g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Error: Extension "+AFBClass.ShortName+" can't be started: locked!\n");
						afbasebase.Log(string(AFArgs.User.pev.netname)+" attempted to start locked extension "+string(AFBClass.ShortName));
						return;
					}else{
						if(AFBClass.Running)
						{
							g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Can't start extension "+AFBClass.ShortName+": Already running!\n");
							afbasebase.Log(string(AFArgs.User.pev.netname)+" attempted to start already running extension "+string(AFBClass.ShortName));
							return;
						}else{
							g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Started extension: "+AFBClass.ShortName+".\n");
							afbasebase.Log(string(AFArgs.User.pev.netname)+" started extension "+string(AFBClass.ShortName));
							AFBClass.Start();
							return;
						}
					}
				}
			}
		}
		
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] Failed to find expansion SID, check your spelling (case sensetive).\n");
	}
	
	void help(AFBaseArguments@ AFArgs)
	{
		array<string> sComm;
		int iCmdAccess = 0;
		string sENameID = "";
		string sVisual = "";
		AFBaseClass@ AFBClass = null;
			
		bool bShowExp = AFArgs.GetCount() >= 2 ? AFArgs.GetBool(1) : false;
		AFBase::AFBaseUser@ afbUser = cast<AFBase::AFBaseUser@>(AFBase::g_afbUserList[AFArgs.User.entindex()]);
		for(uint i = 0; i < AFBase::g_afbCommandList.length(); i++)
		{
			AFBase::ParseCommand(AFBase::g_afbCommandList[i], iCmdAccess, sENameID, sVisual);
			if(afbUser.iAccess & iCmdAccess == iCmdAccess)
			{
				@AFBClass = cast<AFBaseClass@>(AFBase::g_afbExpansionList[sENameID]);
				if(AFBClass !is null)
					if(AFBClass.Running)
						if(bShowExp)
							sComm.insertLast("["+sENameID+"] "+sVisual);
						else
							sComm.insertLast(sVisual);
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
			g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] No such page! attempted page "+(1+cStart/10)+", but list length is "+(1+((sComm.length()-1)/10))+" pages!\n");
			return;
		}

		uint pLength = 0;
		for(uint i = cStart; i < cEnd; i++)
		{
			if(i < sComm.length())
				pLength++;
		}
		
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "----AdminFuckeryBase help: Command list-----------------------------------------\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "Quick quide: (arg) required parameter, <arg> optional parameter. Targets: @all, @admins, @noadmins, @alive\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, " @dead, @aim, @random, @last, @me, \"nickname\" (supports * wildcard), \"STEAM_0:1:ID\"\n");
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "--------------------------------------------------------------------------------\n");
		for(uint i = 0; i < pLength; i++)
		{
				TellLongCustom(" "+(1+i+cStart)+": "+sComm[i+cStart]+"\n", AFArgs.User, HUD_PRINTCONSOLE);
		}
		
		g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "--------------------------------------------------------------------------------\n");
		if(cStart+10 < sComm.length())
			g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] type \".afb_help "+(1+(cEnd)/10)+"\" for more - showing page "+(1+cStart/10)+" of "+(1+((sComm.length()-1)/10))+".\n");
		else
			g_PlayerFuncs.ClientPrint(AFArgs.User, HUD_PRINTCONSOLE, "[AFB] showing page "+(1+cStart/10)+" of "+(1+((sComm.length()-1)/10))+".\n");
	}
	
	void TellLongCustom(string sIn, CBasePlayer@ pUser, HUD targetHud)
	{
		string sHoldIn = sIn;
		while(sHoldIn.Length() > 128)
		{
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
			g_PlayerFuncs.ClientPrint(pUser, targetHud, sHoldIn);
	}
}