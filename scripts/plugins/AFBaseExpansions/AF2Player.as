#include "AF2Legacy"

AF2Player af2player;

void AF2Player_Call()
{
	af2player.RegisterExpansion(af2player);
}

class AF2Player : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery2 Player Commands";
		this.ShortName = "AF2P";
	}
	
	void ExpansionInit()
	{
		RegisterCommand("player_teleportaim", "s", "(targets) - teleport target(s) to where you are aiming at", ACCESS_G, @AF2Player::teleportaim);
		RegisterCommand("say !tpaim", "s", "(targets) - teleport target(s) to where you are aiming at", ACCESS_G, @AF2Player::teleportaim, CMD_SUPRESS);
		RegisterCommand("player_teleportmeto", "s", "(target) - teleport you to target", ACCESS_G, @AF2Player::teleportmeto);
		RegisterCommand("say !tpmeto", "s", "(target) - teleport you to target", ACCESS_G, @AF2Player::teleportmeto, CMD_SUPRESS);
		RegisterCommand("player_teleporttome", "s", "(targets) - teleport target(s) to you", ACCESS_G, @AF2Player::teleporttome);
		RegisterCommand("say !tptome", "s", "(targets) - teleport target(s) to you", ACCESS_G, @AF2Player::teleporttome, CMD_SUPRESS);
		RegisterCommand("player_teleportpos", "sv", "(targets) (vector) - teleport target(s) to position", ACCESS_G, @AF2Player::teleportpos);
		RegisterCommand("player_disarm", "s!s", "(targets) <weapon> - disarm target(s), don't define weapon to disarm everything", ACCESS_G, @AF2Player::disarm);
		RegisterCommand("player_getmodel", "s", "(targets) - return target(s) playermodel", ACCESS_Z, @AF2Player::getmodel);
		RegisterCommand("player_give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2Player::give);
		RegisterCommand("say !give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2Player::give, CMD_SUPRESS);
		RegisterCommand("player_giveall", "!ss", "<targets> <set> - give target(s) all stock weapons, don't define target to view all currently possible sets, set defaults to vanilla", ACCESS_G, @AF2Player::giveall);
		RegisterCommand("player_giveammo", "s!i", "(targets) <0/1 all> - give target(s) ammo, defaults to all weapons", ACCESS_G, @AF2Player::giveammo);
		RegisterCommand("say !giveammo", "s!i", "(targets) <0/1 all> - give target(s) ammo, defaults to all weapons", ACCESS_G, @AF2Player::giveammo, CMD_SUPRESS);
		RegisterCommand("player_givemapcfg", "s", "(targets) - apply map cfg to target(s)", ACCESS_G, @AF2Player::givemapcfg);
		RegisterCommand("player_position", "s", "(target) - returns target position,", ACCESS_G, @AF2Player::position);
		RegisterCommand("player_resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2Player::resurrect);
		RegisterCommand("say !resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2Player::resurrect, CMD_SUPRESS);
		RegisterCommand("player_maxspeed", "sf", "(targets) (speed) - set target(s) max speed, -1 to restore to default", ACCESS_G, @AF2Player::maxspeed);
		RegisterCommand("player_keyvalue", "ss!sss", "(targets) (key) <value> <value> <value> - get/set target(s) keyvalue", ACCESS_F|ACCESS_G, @AF2Player::keyvalue);
		RegisterCommand("player_nosolid", "s!b", "(targets) <0/1 mode> - set target(s) solidity, don't define mode to toggle", ACCESS_G, @AF2Player::nosolid);
		RegisterCommand("say !nosolid", "s!i", "(targets) <0/1 mode> - set target(s) nosolid mode, don't define mode to toggle", ACCESS_G, @AF2Player::nosolid, CMD_SUPRESS);
		RegisterCommand("player_noclip", "s!i", "(targets) <0/1 mode> - set target(s) noclip mode, don't define mode to toggle", ACCESS_G, @AF2Player::noclip);
		RegisterCommand("player_god", "s!i", "(targets) <0/1 mode> - set target(s) godmode, don't define mode to toggle", ACCESS_G, @AF2Player::god);
		RegisterCommand("player_freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2Player::freeze);
		RegisterCommand("say !freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2Player::freeze, CMD_SUPRESS);
		RegisterCommand("player_ignite", "s", "(targets) - ignite target(s)", ACCESS_G, @AF2Player::ignite, CMD_PRECACHE);
		RegisterCommand("player_viewmode", "sb", "(targets) (0/1 firstperson/thirdperson) - set target(s) viewmode", ACCESS_G, @AF2Player::viewmode);
		RegisterCommand("player_notarget", "s!i", "(targets) <0/1 mode> - set target(s) notarget, don't define mode to toggle", ACCESS_G, @AF2Player::notarget);
		RegisterCommand("player_tag", "!ss", "<targets> <tag> - tag target, visible only for admins. Run without arguments to view list", ACCESS_G, @AF2Player::tagplayer, CMD_PRECACHE);
		RegisterCommand("say !tag", "!ss", "<targets> <tag> - tag target, visible only for admins. Run without arguments to view list", ACCESS_G, @AF2Player::tagplayer, CMD_PRECACHE|CMD_SUPRESS);
		RegisterCommand("player_tagfix", "", "- refresh tags on your view, in case something fucks up", ACCESS_G, @AF2Player::tagfix, CMD_PRECACHE);
		RegisterCommand("say !tagfix", "", "- refresh tags on your view, in case something fucks up", ACCESS_G, @AF2Player::tagfix, CMD_PRECACHE|CMD_SUPRESS);
		RegisterCommand("player_exec", "ss!i", "(targets) (\"command\") <noquotes 0/1> - execute command on client console", ACCESS_G, @AF2Player::cexec);
		RegisterCommand("player_dumpinfo", "s!b", "(targets) <dirty 0/1> - dump player keyvalues into console", ACCESS_F|ACCESS_G, @AF2Player::dumpinfo);
	
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @AF2Player::PlayerSpawn);
		
		AF2Player::g_playerModes.deleteAll(); // reset player data
		recheckPlayers();
		if(AF2Player::g_playerThink !is null)
			g_Scheduler.RemoveTimer(AF2Player::g_playerThink);
	
		@AF2Player::g_playerThink = g_Scheduler.SetInterval("playerThink", 0.25f);
	}
	
	void MapInit()
	{
		AF2Player::g_playerModes.deleteAll(); // reset player data
		AF2Player::tagListReset();
		recheckPlayers();
		g_SoundSystem.PrecacheSound("ambience/flameburst1.wav");
		g_Game.PrecacheModel("sprites/flame2.spr");
		if(AF2Player::g_playerThink !is null)
			g_Scheduler.RemoveTimer(AF2Player::g_playerThink);
	
		@AF2Player::g_playerThink = g_Scheduler.SetInterval("playerThink", 0.25f);
		
		dictionary MenuCommands = {
			{".player_giveammo","give ammo"},
			{".player_ignite","ignite"},
			{".player_teleporttome","teleport to me"},
			{".player_teleportmeto","teleport me to"},
			{".player_freeze","toggle freeze"},
			{".player_nosolid","toggle nosolid"},
			{".player_noclip","toggle noclip"},
			{".player_god","toggle god"},
			{".player_notarget","toggle notarget"}
		}; // purposefully not broadcasting to everything with *, instead using SID
		af2player.SendMessage("AF2MS", "RegisterMenuCommand", MenuCommands);
	}
	
	void StopEvent()
	{
		if(AF2Player::g_playerThink !is null)
			g_Scheduler.RemoveTimer(AF2Player::g_playerThink);
	}
	
	void StartEvent()
	{
		AF2Player::g_playerModes.deleteAll(); // reset player data
		recheckPlayers();
		if(AF2Player::g_playerThink !is null)
			g_Scheduler.RemoveTimer(AF2Player::g_playerThink);
	
		@AF2Player::g_playerThink = g_Scheduler.SetInterval("playerThink", 0.25f);
	}
	
	void ReceiveMessageEvent(string sSender, string sIdentifier, dictionary dData)
	{
		if(sIdentifier == "RecheckPlayer")
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(cast<CBaseEntity@>(dData["player"]));
			if(pPlayer is null)
				AF2Player::CheckPlayerModes(null);
			else
				AF2Player::CheckPlayerModes(pPlayer);
		}
	}
	
	void recheckPlayers()
	{
		CBasePlayer@ pSearch = null;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(!AF2Player::g_playerModes.exists(pSearch.entindex()))
					AF2Player::g_playerModes[pSearch.entindex()] = 0;
			}
		}
	}
	
	void ClientConnectEvent(CBasePlayer@ pPlayer)
	{
		if(!AF2Player::g_playerModes.exists(pPlayer.entindex()))
			AF2Player::g_playerModes[pPlayer.entindex()] = 0;
			
		string sId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pPlayer));
		string sTag = AF2Player::getTagData(sId);
		if(sTag != "none")
		{
			AF2Player::tagTalk("[AF2P tagtalk] "+pPlayer.pev.netname+" (tag: "+sTag+") has connected");
			AF2Player::tagViewAdd(pPlayer, sTag);
			AF2Player::g_tagList[pPlayer.entindex()] = sTag;
		}
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pPlayer)
	{
		if(AF2Player::g_playerModes.exists(pPlayer.entindex()))
			AF2Player::g_playerModes.delete(pPlayer.entindex());
			
		if(AF2Player::g_tagList.exists(pPlayer.entindex()))
		{
			AF2Player::tagViewRemove(pPlayer);
			AF2Player::g_tagList.delete(pPlayer.entindex());
		}
	}
}

namespace AF2Player
{
	const int g_TagVisibleTo = ACCESS_G;

	void dumpinfo(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		bool bDirty = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) : false;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				dictionary stuff = bDirty ? AF2LegacyCode::reverseGetKeyvalue(pTarget) : AF2LegacyCode::prunezero(AF2LegacyCode::reverseGetKeyvalue(pTarget));
				array<string> dkeys = stuff.getKeys();
				af2player.Tell("Player \""+pTarget.pev.netname+"\" keyvalues:", AFArgs.User, HUD_PRINTCONSOLE);
				for(uint j = 0; j < dkeys.length(); j++)
				{
					string sout = string(stuff[dkeys[j]]);
					af2player.Tell("\""+dkeys[j]+"\" -> \""+sout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				}
				af2player.Tell("========", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}
	
	const array<string> execBlackList = {
	 "say !",
	 "say \"!"
	};

	void cexec(AFBaseArguments@ AFArgs)
	{
		string sOut = AFArgs.GetString(1);
		array<string> parsed = sOut.Split(" ");
		int noquotes = AFArgs.GetCount() >= 3 ? AFArgs.GetInt(2) : 0;
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
		
		for(uint i = 0; i < execBlackList.length(); i++)
		{
			if(sOut.Find(execBlackList[i], 0, String::CaseInsensitive) != String::INVALID_INDEX)
			{
				af2player.Tell("Can't execute, found blacklisted part: \""+execBlackList[i]+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				af2player.Log("Blocked: "+AFArgs.User.pev.netname+" attempted to remote execute \""+sOut+"\" on target(s): "+AFArgs.GetString(0));
				return;
			}
		}
		
		if(sOut.Find(".", 0, String::CaseInsensitive) != String::INVALID_INDEX)
		{
			array<string> coms = AFBase::g_afbConCommandList.getKeys();
			for(uint i = 0; i < coms.length(); i++)
			{
				if(sOut.Find(coms[i], 0, String::CaseInsensitive) != String::INVALID_INDEX)
				{
					af2player.Tell("Can't execute, found blacklisted part: \""+coms[i]+"\"", AFArgs.User, HUD_PRINTCONSOLE);
					af2player.Log("Blocked: "+AFArgs.User.pev.netname+" attempted to remote execute \""+sOut+"\" on target(s): "+AFArgs.GetString(0));
					return;
				}
			}
		}
		
		
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::NetworkMessageType(9), pTarget.edict());
					message.WriteString(sOut);
				message.End();
				
				af2player.Tell("Executed on "+pTarget.pev.netname+": "+sOut, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void tagfix(AFBaseArguments@ AFArgs)
	{
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		tagRefreshView(AFArgs.User);
		af2player.Tell("Refreshed tag view", AFArgs.User, targetHud);
	}

	void tagplayer(AFBaseArguments@ AFArgs)
	{
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		
		if(AFArgs.GetCount() == 0)
		{
			af2player.Tell("Printed list of tags to console", AFArgs.User, targetHud);
			af2player.Tell("Available tags (use \"off\" to remove tag):", AFArgs.User, HUD_PRINTCONSOLE);
			for(uint i = 0; i < g_validTags.length(); i++)
				af2player.Tell(g_validTags[i], AFArgs.User, HUD_PRINTCONSOLE);
				
			return;
		}
		else if(AFArgs.GetCount() == 1)
		{
			af2player.Tell("Missing arguments! Usage: <targets> <tag>", AFArgs.User, targetHud);
			return;
		}
		
		string sTag = AFArgs.GetString(1);
		
		if(g_validTags.find(sTag) <= -1 && sTag != "off")
		{
			af2player.Tell("Invalid tag! Run without arguments to view list of tags", AFArgs.User, targetHud);
			return;
		}
		
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(sTag == "off")
				{
					if(g_tagList.exists(pTarget.entindex()))
					{
						removeTag(pTarget);
						tagTalk("[AF2P tagtalk] Admin "+AFArgs.User.pev.netname+" removed tag from "+pTarget.pev.netname);
						af2player.Tell("Removed tag from "+pTarget.pev.netname, AFArgs.User, targetHud);
					}else{
						af2player.Tell("Can't remove: no tag!", AFArgs.User, targetHud);
					}
				}else{
					addTag(pTarget, sTag);
					tagTalk("[AF2P tagtalk] Admin "+AFArgs.User.pev.netname+" set tag "+sTag+" to "+pTarget.pev.netname);
					af2player.Tell("Set tag "+sTag+" to "+pTarget.pev.netname, AFArgs.User, targetHud);
				}
			}
		}
	}

	dictionary g_tagList;
	string g_tagPath = "sprites/zode/";
	string g_tagFilePath = "scripts/plugins/store/AFBaseTags.txt";
	array<string> g_validTags = {
	"blocker",
	"rusher",
	"suspect",
	"troll"
	};
	
	void reloadPlayerTags()
	{
		g_tagList.deleteAll();
		CBasePlayer@ pSearch;
		for(int i = 1; i < g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				string sId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch));
				string sTag = getTagData(sId);
				if(sTag == "none")
					continue;
				
				g_tagList[pSearch.entindex()] = sTag;
			}
		}
		
		@pSearch = null;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(AFBase::CheckAccess(pSearch, g_TagVisibleTo))
				{
					tagRefreshView(pSearch);
				}
			}
		}
	}
	
	void tagRefreshView(CBasePlayer@ pView)
	{
		if(pView is null)
			return;
			
		if(pView !is null && AFBase::CheckAccess(pView, g_TagVisibleTo))
		{
			CBasePlayer@ pSearch;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(@pSearch !is null)
				{
					if(g_tagList.exists(pSearch.entindex()))
					{
						string sSprite = g_tagPath+string(g_tagList[pSearch.entindex()])+".spr";
						
						NetworkMessage killmessage(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pView.edict());
							killmessage.WriteByte(TE_KILLPLAYERATTACHMENTS);
							killmessage.WriteByte(pSearch.entindex());
						killmessage.End();
					
						NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pView.edict());
							message.WriteByte(TE_PLAYERATTACHMENT);
							message.WriteByte(pSearch.entindex());
							message.WriteCoord(51.0f);
							message.WriteShort(g_EngineFuncs.ModelIndex(sSprite));
							message.WriteShort(32767);
						message.End();
					}
				}
			}
		}
	}
	
	void tagViewAdd(CBasePlayer@ pTarg, string sTag)
	{
		string sSprite = g_tagPath+sTag+".spr";
		CBasePlayer@ pSearch;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(AFBase::CheckAccess(pSearch, g_TagVisibleTo))
				{
					NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pSearch.edict());
						message.WriteByte(TE_PLAYERATTACHMENT);
						message.WriteByte(pTarg.entindex());
						message.WriteCoord(51.0f);
						message.WriteShort(g_EngineFuncs.ModelIndex(sSprite));
						message.WriteShort(32767);
					message.End();
				}
			}
		}
	}
	
	void tagViewRemove(CBasePlayer@ pTarg)
	{
		CBasePlayer@ pSearch;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(AFBase::CheckAccess(pSearch, g_TagVisibleTo))
				{
					NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pSearch.edict());
						message.WriteByte(TE_KILLPLAYERATTACHMENTS);
						message.WriteByte(pTarg.entindex());
					message.End();
				}
			}
		}
	}
	
	void tagListReset()
	{
		g_tagList.deleteAll();
		for(uint i = 0; i < g_validTags.length(); i++)
		{
			g_Game.PrecacheModel(g_tagPath+g_validTags[i]+".spr");
		}
	}
	
	void tagTalk(string sTalk)
	{
		CBasePlayer@ pSearch;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(AFBase::CheckAccess(pSearch, g_TagVisibleTo))
				{
					g_PlayerFuncs.ClientPrint(pSearch, HUD_PRINTTALK, sTalk+"\n");
				}
			}
		}
	}
	
	void addTag(CBasePlayer@ pTarget, string sTag)
	{
		if(g_tagList.exists(pTarget.entindex())) //reset view basically
			tagViewRemove(pTarget);
		
		setTagData(pTarget, sTag);
		tagViewAdd(pTarget, sTag);
	}
	
	void removeTag(CBasePlayer@ pTarget)
	{
		g_tagList.delete(pTarget.entindex());
		setTagData(pTarget, "off");
		tagViewRemove(pTarget);
	}
	
	bool setTagData(CBasePlayer@ pTarget, string sTag)
	{
		string usrId = AFBase::FormatSafe(AFBase::GetFixedSteamID(pTarget));
		File@ file = g_FileSystem.OpenFile(g_tagFilePath, OpenFile::READ);
		dictionary lTags;
		if(file !is null && file.IsOpen())
		{
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
				
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
				
				array<string> parsed = sLine.Split(" ");
				
				//effing linux
				if(parsed[1].SubString(parsed[1].Length()-1,1) == " " || parsed[1].SubString(parsed[1].Length()-1,1) == "\n" || parsed[1].SubString(parsed[1].Length()-1,1) == "\r" || parsed[1].SubString(parsed[1].Length()-1,1) == "\t")
					parsed[1] = parsed[1].SubString(0, parsed[1].Length()-1);
				
				lTags[parsed[0]] = parsed[1];
			}
			file.Close();
		}else{
			af2player.Log("Installation error: cannot locate tag file");
			return false;
		}
		
		if(sTag == "off" && lTags.exists(usrId))
		{
			lTags.delete(usrId);
		}else{
			lTags[usrId] = sTag;
			g_tagList[pTarget.entindex()] = sTag;
		}
		
		@file = g_FileSystem.OpenFile(g_tagFilePath, OpenFile::WRITE);
		if(file !is null)
		{
			array<string> sIds = lTags.getKeys();
			for(uint i = 0; i < sIds.length(); i++)
			{
				file.Write(sIds[i]+" "+string(lTags[sIds[i]])+"\n");
			}
			
			file.Close();
			return true;
		}else{
			af2player.Log("Failed to write tag file");
			return false;
		}
	}
	
	string getTagData(string sId)
	{
		
		File@ file = g_FileSystem.OpenFile(g_tagFilePath, OpenFile::READ);
		if(file !is null && file.IsOpen())
		{
			string sReturn = "none";
			while(!file.EOFReached())
			{
				string sLine;
				file.ReadLine(sLine);
				
				string sFix = sLine.SubString(sLine.Length()-1,1);
				if(sFix == " " || sFix == "\n" || sFix == "\r" || sFix == "\t")
					sLine = sLine.SubString(0, sLine.Length()-1);
				
				if(sLine.SubString(0,1) == "#" || sLine.IsEmpty())
					continue;
					
				array<string> parsed = sLine.Split(" ");
					
				//effing linux
				if(parsed[1].SubString(parsed[1].Length()-1,1) == " " || parsed[1].SubString(parsed[1].Length()-1,1) == "\n" || parsed[1].SubString(parsed[1].Length()-1,1) == "\r" || parsed[1].SubString(parsed[1].Length()-1,1) == "\t")
					parsed[1] = parsed[1].SubString(0, parsed[1].Length()-1);
					
				if(parsed[0] == sId)
					sReturn = parsed[1];
			}
			
			file.Close();
			return sReturn;
		}else{
			af2player.Log("Installation error: cannot locate tag file");
			return "none";
		}
	}

	CScheduledFunction@ g_playerThink = null;

	void playerThink()
	{
		CBasePlayer@ pSearch = null;
		if(AFBase::IsSafe())
		{
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null)
				{
					if(int(AF2Player::g_playerModes[pSearch.entindex()]) & AF2Player::PLAYER_FLAMING > 0)
					{
						float fRand = g_PlayerFuncs.SharedRandomFloat(pSearch.random_seed, 0, 1);
						if(fRand >= 0.66f)
							g_SoundSystem.PlaySound(pSearch.edict(), CHAN_ITEM, "ambience/flameburst1.wav", 1.0f, 1.0f, 0, 100+Math.RandomLong(-16, 16));
					
						Vector vFlame = pSearch.pev.origin+Vector(Math.RandomFloat(-20,20),Math.RandomFloat(-20,20),Math.RandomFloat(-20,20));
						NetworkMessage message(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
							message.WriteByte(TE_SPRITE);
							message.WriteCoord(vFlame.x);
							message.WriteCoord(vFlame.y);
							message.WriteCoord(vFlame.z+32);
							message.WriteShort(g_EngineFuncs.ModelIndex("sprites/flame2.spr"));
							message.WriteByte(10);
							message.WriteByte(200);
						message.End();
						g_PlayerFuncs.ScreenFade(pSearch, Vector(220,120,60), 0.5f, 0.1f, 50, 0);
						pSearch.pev.punchangle = Vector(Math.RandomFloat(-4.0f, 4.0f), Math.RandomFloat(-4.0f, 4.0f), Math.RandomFloat(-4.0f, 4.0f));
						pSearch.TakeHealth(-5.0f, DMG_BURN);
					}
				}
			}
		}
	}

	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{
		EHandle ePlayer = pPlayer;
		g_Scheduler.SetTimeout("PlayerPostSpawn", 0.25f, ePlayer);
		if(int(g_playerModes[pPlayer.entindex()]) & PLAYER_FLAMING > 0)
		{
			int iFlags = int(g_playerModes[pPlayer.entindex()]);
			iFlags &= ~PLAYER_FLAMING;
			g_playerModes[pPlayer.entindex()] = iFlags;
		}
		
		return HOOK_CONTINUE;
	}
	
	void PlayerPostSpawn(EHandle ePlayer)
	{
		if(ePlayer)
		{
			CBaseEntity@ pPlayer = ePlayer;
			CheckPlayerModes(cast<CBasePlayer@>(pPlayer));
		}
	}
	
	void viewmode(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				PlayerViewMode viewMode = AFArgs.GetBool(1) ? ViewMode_ThirdPerson : ViewMode_FirstPerson;
				pTarget.SetViewMode(viewMode);
				string sMode = AFArgs.GetBool(1) ? "thirdperson" : "firstperson";
				af2player.Tell("Set "+pTarget.pev.netname+" viewmode to \""+sMode+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void ignite(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_FLAMING > 0 ? true : false;
				if(!bIsOn)
				{
					af2player.Tell("Set "+pTarget.pev.netname+" on fire", AFArgs.User, HUD_PRINTCONSOLE);
					af2player.TellAll("OMG! "+pTarget.pev.netname+" spontaneously combusted!", HUD_PRINTTALK);
					g_SoundSystem.PlaySound(pTarget.edict(), CHAN_ITEM, "ambience/flameburst1.wav", 1.0f, 1.0f);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags |= PLAYER_FLAMING;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else
					af2player.Tell("Player "+pTarget.pev.netname+" is already burning!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void freeze(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		int iMode = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : -1;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_FROZEN > 0 ? true : false;
				if(iMode == -1)
				{
					af2player.Tell("Toggled freeze for "+pTarget.pev.netname, AFArgs.User, targetHud);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags ^= PLAYER_FROZEN;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else if(iMode == 1)
				{
					if(!bIsOn)
					{
						af2player.Tell("Set freeze on for "+pTarget.pev.netname, AFArgs.User, targetHud);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags |= PLAYER_FROZEN;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already frozen!", AFArgs.User, targetHud);
				}else{
					if(bIsOn)
					{
						af2player.Tell("Set freeze off for "+pTarget.pev.netname, AFArgs.User, targetHud);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags &= ~PLAYER_FROZEN;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is not frozen!", AFArgs.User, targetHud);
				}
			}
			
			CheckPlayerModes(null);
		}
	}

	void god(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		int iMode = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : -1;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_GOD > 0 ? true : false;
				if(iMode == -1)
				{
					af2player.Tell("Toggled godmode for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags ^= PLAYER_GOD;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else if(iMode == 1)
				{
					if(!bIsOn)
					{
						af2player.Tell("Set godmode on for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags |= PLAYER_GOD;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already in godmode!", AFArgs.User, HUD_PRINTCONSOLE);
				}else{
					if(bIsOn)
					{
						af2player.Tell("Set god off for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags &= ~PLAYER_GOD;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is not in godmode!", AFArgs.User, HUD_PRINTCONSOLE);
				}
			}
			
			CheckPlayerModes(null);
		}
	}

	void noclip(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		int iMode = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : -1;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_NOCLIP > 0 ? true : false;
				if(iMode == -1)
				{
					af2player.Tell("Toggled noclip for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags ^= PLAYER_NOCLIP;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else if(iMode == 1)
				{
					if(!bIsOn)
					{
						af2player.Tell("Set noclip on for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags |= PLAYER_NOCLIP;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already noclipped!", AFArgs.User, HUD_PRINTCONSOLE);
				}else{
					if(bIsOn)
					{
						af2player.Tell("Set noclip off for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags &= ~PLAYER_NOCLIP;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already clipping!", AFArgs.User, HUD_PRINTCONSOLE);
				}
			}
			
			CheckPlayerModes(null);
		}
	}

	void nosolid(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		int iMode = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : -1;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_NOSOLID > 0 ? true : false;
				if(iMode == -1)
				{
					af2player.Tell("Toggled solidity for "+pTarget.pev.netname, AFArgs.User, targetHud);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags ^= PLAYER_NOSOLID;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else if(iMode == 1)
				{
					if(!bIsOn)
					{
						af2player.Tell("Set nosolid on for "+pTarget.pev.netname, AFArgs.User, targetHud);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags |= PLAYER_NOSOLID;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already nosolid!", AFArgs.User, targetHud);
				}else{
					if(bIsOn)
					{
						af2player.Tell("Set nosolid off for "+pTarget.pev.netname, AFArgs.User, targetHud);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags &= ~PLAYER_NOSOLID;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already solid!", AFArgs.User, targetHud);
				}
			}
			
			CheckPlayerModes(null);
		}
	}
	
	void CheckPlayerModes(CBasePlayer@ pTarget)
	{
		if(pTarget is null)
		{
			CBasePlayer@ pSearch = null;
			for(int i = 1; i <= g_Engine.maxClients; i++)
			{
				@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
				if(pSearch !is null)
				{
					if(int(g_playerModes[pSearch.entindex()]) & PLAYER_FROZEN > 0)
					{
						if(pSearch.pev.flags & FL_FROZEN == 0)
							pSearch.pev.flags |= FL_FROZEN;
					}else{
						if(pSearch.pev.flags & FL_FROZEN > 0)
							pSearch.pev.flags &= ~FL_FROZEN;
					}
					
					if(int(g_playerModes[pSearch.entindex()]) & PLAYER_GOD > 0)
					{
						if(pSearch.pev.flags & FL_GODMODE == 0)
							pSearch.pev.flags |= FL_GODMODE;
					}else{
						if(pSearch.pev.flags & FL_GODMODE > 0)
							pSearch.pev.flags &= ~FL_GODMODE;
					}
					
					if(int(g_playerModes[pSearch.entindex()]) & PLAYER_NOCLIP > 0)
					{
						if(pSearch.pev.movetype != MOVETYPE_NOCLIP)
							pSearch.pev.movetype = MOVETYPE_NOCLIP;

						if(pSearch.pev.flags & FL_FLY == 0)
							pSearch.pev.flags |= FL_FLY;
					}else{
						if(pSearch.pev.movetype != MOVETYPE_WALK)
							pSearch.pev.movetype = MOVETYPE_WALK;
							
						if(pSearch.pev.flags & FL_FLY > 0)
							pSearch.pev.flags &= ~FL_FLY;
					}
					
					if(int(g_playerModes[pSearch.entindex()]) & PLAYER_NOSOLID > 0)
					{
						if(pSearch.pev.movetype != SOLID_NOT)
							if(!pSearch.GetObserver().IsObserver())
								pSearch.pev.solid = SOLID_NOT;
					}else{
						if(pSearch.pev.movetype != SOLID_BBOX)
							if(!pSearch.GetObserver().IsObserver())
								pSearch.pev.solid = SOLID_BBOX;
					}
					
					if(int(g_playerModes[pSearch.entindex()]) & PLAYER_NOTARGET > 0)
					{
						if(pSearch.pev.flags & FL_NOTARGET == 0)
							pSearch.pev.flags |= FL_NOTARGET;
					}else{
						if(pSearch.pev.flags & FL_NOTARGET > 0)
							pSearch.pev.flags &= ~FL_NOTARGET;
					}
				}
			}
		}else{
			if(int(g_playerModes[pTarget.entindex()]) & PLAYER_FROZEN > 0)
			{
				if(pTarget.pev.flags & FL_FROZEN == 0)
					pTarget.pev.flags |= FL_FROZEN;
			}else{
				if(pTarget.pev.flags & FL_FROZEN > 0)
					pTarget.pev.flags &= ~FL_FROZEN;
			}
			
			if(int(g_playerModes[pTarget.entindex()]) & PLAYER_GOD > 0)
			{
				if(pTarget.pev.flags & FL_GODMODE == 0)
					pTarget.pev.flags |= FL_GODMODE;
			}else{
				if(pTarget.pev.flags & FL_GODMODE > 0)
					pTarget.pev.flags &= ~FL_GODMODE;
			}
			
			if(int(g_playerModes[pTarget.entindex()]) & PLAYER_NOCLIP > 0)
			{
				if(pTarget.pev.movetype != PLAYER_NOCLIP)
					pTarget.pev.movetype = MOVETYPE_NOCLIP;
			}else{
				if(pTarget.pev.movetype != MOVETYPE_WALK)
					pTarget.pev.movetype = MOVETYPE_WALK;
			}
			
			if(int(g_playerModes[pTarget.entindex()]) & PLAYER_NOSOLID > 0)
			{
				if(pTarget.pev.movetype != SOLID_TRIGGER)
					if(!pTarget.GetObserver().IsObserver())
						pTarget.pev.solid = SOLID_TRIGGER;
			}else{
				if(pTarget.pev.movetype != SOLID_BBOX)
					if(!pTarget.GetObserver().IsObserver())
						pTarget.pev.solid = SOLID_BBOX;
			}
			
			if(int(g_playerModes[pTarget.entindex()]) & PLAYER_NOTARGET > 0)
			{
				if(pTarget.pev.flags & FL_NOTARGET == 0)
					pTarget.pev.flags |= FL_NOTARGET;
			}else{
				if(pTarget.pev.flags & FL_NOTARGET > 0)
					pTarget.pev.flags &= ~FL_NOTARGET;
			}
		}
	}
	
	dictionary g_playerModes;

	enum PlayerModes
	{
		PLAYER_NOSOLID = 1,
		PLAYER_NOCLIP = 2,
		PLAYER_FLAMING = 4,
		PLAYER_GOD = 8,
		PLAYER_FROZEN = 16,
		PLAYER_NOTARGET = 32
	}

	void keyvalue(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		string sVal = AFArgs.GetCount() >= 3 ? AFArgs.GetString(2) : "";
		string sValY = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		string sValZ = AFArgs.GetCount() >= 5 ? AFArgs.GetString(4) : "";
		string sValout = "";
		if(sVal != "" && sValY != "" && sValZ != "")
			sValout = sVal+" "+sValY+" "+sValZ;
		else
			sValout = sVal;
			
		bool bHasE = AFBase::CheckAccess(AFArgs.User, ACCESS_E);
		
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(sValout == "")
				{
					string sReturn = AF2LegacyCode::getKeyValue(pTarget, AFArgs.GetString(1));
					if(sReturn != "§§§§N/A")
					{
						af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+sReturn+"\"", AFArgs.User, HUD_PRINTCONSOLE);
					}
					else
					{
						//retarded. but works.
						if(AFArgs.GetString(1).ToLowercase() == "m_ieffectblockweapons")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_iEffectBlockWeapons)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectinvulnerable")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_iEffectInvulnerable)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectinvisible")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_iEffectInvisible)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectnonsolid")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_iEffectNonSolid)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectrespiration")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_flEffectRespiration)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectgravity")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_flEffectGravity)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectfriction")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_flEffectFriction)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectspeed")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_flEffectSpeed)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectdamage")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_flEffectDamage)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else if(AFArgs.GetString(1).ToLowercase() == "m_ideaths")
							af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+string(pTarget.m_iDeaths)+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						else
							af2player.Tell("Unsupported key in get", AFArgs.User, HUD_PRINTCONSOLE);
						
					}
				}else{
					if(AFArgs.GetString(1) == "model" || AFArgs.GetString(1) == "viewmodel" || AFArgs.GetString(1) == "weaponmodel" || AFArgs.GetString(1) == "modelindex")
					{
						if(!bHasE)
						{
							af2player.Tell("Blocked: you require access flag E to do this action (\"highrisk\" key).", AFArgs.User, HUD_PRINTCONSOLE);
							return;
						}
					}
					
					//round two
					if(AFArgs.GetString(1).ToLowercase() == "m_ieffectblockweapons")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_iEffectBlockWeapons = atoi(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectinvulnerable")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_iEffectInvulnerable = atoi(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectinvisible")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_iEffectInvisible = atoi(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_ieffectnonsolid")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_iEffectNonSolid = atoi(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectrespiration")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_flEffectRespiration = atof(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectgravity")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_flEffectGravity = atof(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectfriction")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_flEffectFriction = atof(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectspeed")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_flEffectSpeed = atof(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_fleffectdamage")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_flEffectDamage = atof(sValout);
					}
					else if(AFArgs.GetString(1).ToLowercase() == "m_ideaths")
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						pTarget.m_iDeaths = atoi(sValout);
					}
					else
					{
						af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
						g_EntityFuncs.DispatchKeyValue(pTarget.edict(), AFArgs.GetString(1), sValout);
					}
				}
			}
		}
	}

	void maxspeed(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				pTarget.SetMaxSpeedOverride(int(AFArgs.GetFloat(1)));
				af2player.Tell("Set max speed "+string(AFArgs.GetFloat(1))+" to "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void resurrect(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		bool bNoRespawn = AFArgs.GetCount() >= 2 ? AFArgs.GetBool(1) : false;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				Vector oldPos = pTarget.pev.origin;
				Vector oldAngles = pTarget.pev.angles;
				g_PlayerFuncs.RespawnPlayer(pTarget, true, true);
				if(bNoRespawn)
				{
					pTarget.SetOrigin(oldPos);
					pTarget.pev.fixangle = FAM_FORCEVIEWANGLES;
					pTarget.pev.angles = oldAngles;
				}
				
				af2player.Tell("Resurrected "+pTarget.pev.netname, AFArgs.User, targetHud);
			}
		}
	}

	void position(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Player "+pTarget.pev.netname+" position X: "+pTarget.pev.origin.x+" Y: "+pTarget.pev.origin.y+" Z: "+pTarget.pev.origin.z, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void givemapcfg(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				g_PlayerFuncs.ApplyMapCfgToPlayer(pTarget, false);
				af2player.Tell("Gave map cfg to "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void giveammo(AFBaseArguments@ AFArgs)
	{
		bool bAllWeapons = AFArgs.GetCount() >= 2 ? AFArgs.GetBool(1) : true;
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(!pTarget.HasWeapons())
				{
					af2player.Tell(string(pTarget.pev.netname)+" has no weapons to give ammo to.", AFArgs.User, targetHud);
					continue;
				}
				
				bool wasGivenAmmo = false;
				if(!bAllWeapons)
				{
					CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pTarget.m_hActiveItem.GetEntity());
					if(activeItem.PrimaryAmmoIndex() > -1)
					{
						pTarget.GiveAmmo(activeItem.iMaxAmmo1(), activeItem.pszAmmo1(), activeItem.iMaxAmmo1());
						wasGivenAmmo = true;
					}
					
					if(activeItem.SecondaryAmmoIndex() > -1)
					{
						pTarget.GiveAmmo(activeItem.iMaxAmmo2(), activeItem.pszAmmo2(), activeItem.iMaxAmmo2());
						wasGivenAmmo = true;
					}
					
					if(wasGivenAmmo)
						af2player.Tell("Gave ammo to "+pTarget.pev.netname+" (holding: "+activeItem.pszName()+")", AFArgs.User, targetHud);
					else
						af2player.Tell("Can't give ammo to "+pTarget.pev.netname+", weapon uses no ammo! (holding: "+activeItem.pszName()+")", AFArgs.User, targetHud);
					
					continue;
				}
				
				CBasePlayerItem@ pItem;
				CBasePlayerWeapon@ pWeapon;
				int amt = 0;
				for(uint j = 0; j < MAX_ITEM_TYPES; j++)
				{
					@pItem = pTarget.m_rgpPlayerItems(j);
					while(pItem !is null)
					{
						@pWeapon = pItem.GetWeaponPtr();
						wasGivenAmmo = false;
						if(pWeapon.PrimaryAmmoIndex() > -1)
						{
							pTarget.GiveAmmo(pWeapon.iMaxAmmo1(), pWeapon.pszAmmo1(), pWeapon.iMaxAmmo1());
							wasGivenAmmo = true;
						}
						
						if(pWeapon.SecondaryAmmoIndex() > -1)
						{
							pTarget.GiveAmmo(pWeapon.iMaxAmmo2(), pWeapon.pszAmmo2(), pWeapon.iMaxAmmo2());
							wasGivenAmmo = true;
						}
						
						if(wasGivenAmmo) amt++;
						
						@pItem = cast<CBasePlayerItem@>(pItem.m_hNextItem.GetEntity());
					}
				}
					
				if(amt > 0)
					af2player.Tell("Gave ammo to "+pTarget.pev.netname+" (potential weapons supplied: "+string(amt)+")", AFArgs.User, targetHud);
				else
					af2player.Tell("Didn't give amm to "+pTarget.pev.netname+" (potential weapons supplied: "+string(amt)+"!)", AFArgs.User, targetHud);
			}
		}
	}

	const array<string> player_weaponlist_native = 
	{
		"weapon_357", "weapon_9mmar", "weapon_9mmhandgun", "weapon_crossbow",
		"weapon_crowbar", "weapon_displacer", "weapon_eagle", "weapon_egon",
		"weapon_gauss", "weapon_grapple", "weapon_handgrenade", "weapon_hornetgun",
		"weapon_m16", "weapon_m249", "weapon_medkit", "weapon_minigun",
		"weapon_pipewrench", "weapon_rpg", "weapon_satchel", "weapon_shotgun",
		"weapon_snark", "weapon_sniperrifle", "weapon_sporelauncher", "weapon_tripmine",
		"weapon_uzi"
	};

	const array<string> player_weaponlist_ins2 = 
	{
		"weapon_ins2ak12", "weapon_ins2ak74", "weapon_ins2akm", "weapon_ins2aks74u",
		"weapon_ins2asval", "weapon_ins2m1014", "weapon_ins2beretta", "weapon_ins2knuckles",
		"weapon_ins2c96carb", "weapon_ins2c96", "weapon_ins2coach", "weapon_ins2m1911",
		"weapon_ins2python", "weapon_ins2deagle", "weapon_ins2dragunov", "weapon_ins2fg42",
		"weapon_ins2f2000", "weapon_ins2fnfal", "weapon_ins2m249", "weapon_ins2galil",
		"weapon_ins2g43", "weapon_ins2glock17", "weapon_ins2g3a3", "weapon_ins2mp5k",
		"weapon_ins2mp7", "weapon_ins2ump45", "weapon_ins2usp", "weapon_ins2ithaca",
		"weapon_ins2kabar", "weapon_ins2kukri", "weapon_ins2l85a2", "weapon_ins2enfield",
		"weapon_ins2garand", "weapon_ins2at4", "weapon_ins2m14ebr", "weapon_ins2m16a4",
		"weapon_ins2stick", "weapon_ins2m4a1", "weapon_ins2m60", "weapon_ins2law",
		"weapon_ins2m79", "weapon_ins2makarov", "weapon_ins2mg42", "weapon_ins2mk2",
		"weapon_ins2mosin", "weapon_ins2m590", "weapon_ins2mp18", "weapon_ins2mp40",
		"weapon_ins2pzfaust", "weapon_ins2pzschreck", "weapon_ins2ppsh41", "weapon_ins2rpg7",
		"weapon_ins2rpk", "weapon_ins2saiga12", "weapon_ins2sks", "weapon_ins2m29",
		"weapon_ins2l2a3", "weapon_ins2stg44", "weapon_ins2m1928", "weapon_ins2webley"
	};
	
	const array<string> player_weaponlist_cs16 =
	{
		"weapon_p228", "weapon_dualelites", "weapon_csglock18", "weapon_aug",
		"weapon_c4", "weapon_famas", "weapon_ak47", "weapon_g3sg1",
		"weapon_p90", "weapon_fiveseven", "weapon_csm249", "weapon_hegrenade",
		"weapon_galil", "weapon_mac10", "weapon_usp", "weapon_mp5navy",
		"weapon_ump45", "weapon_csknife", "weapon_sg550", "weapon_sg552",
		"weapon_m3", "weapon_xm1014", "weapon_awp", "weapon_m4a1",
		"weapon_csdeagle", "weapon_tmp", "weapon_scout"
	};
	
	const array<string> player_weaponlist_cof =
	{
		"weapon_cofswitchblade", "weapon_cofnightstick", "weapon_cofbranch", "weapon_cofsledgehammer",
		"weapon_cofaxe", "weapon_cofglock", "weapon_cofvp70", "weapon_cofp345",
		"weapon_cofrevolver", "weapon_cofshotgun", "weapon_cofrifle", "weapon_cofm16",
		"weapon_cofg43", "weapon_coftmp", "weapon_cofmp5", "weapon_coffamas",
		"weapon_cofsyringe", "weapon_coflantern", "weapon_cofbooklaser", "weapon_cofcamera",
		"weapon_cofak74", "weapon_cofberetta", "weapon_cofdeagle", "weapon_cofp228",
		"weapon_cofglock18", "weapon_cofanaconda", "weapon_cofgolden", "weapon_cofuzi",
		"weapon_cofl85", "weapon_cofmp5k", "weapon_cofbenelli", "weapon_cofknife",
		"weapon_cofhammer", "weapon_cofspear", "weapon_cofm76", "v_action"
	};
	
	enum player_weaponlist_available
	{
		WEAPONLIST_INS2 = 1,
		WEAPONLIST_CS16 = 2,
		WEAPONLIST_COF = 4
	}
	
	void giveall(AFBaseArguments@ AFArgs)
	{
		string sTargets = AFArgs.GetCount() > 0 ? AFArgs.GetString(0) : "";
		string sSet = AFArgs.GetCount() > 1 ? AFArgs.GetString(1) : "vanilla";
		int availables = 0;
		if(sTargets == "")
		{
			af2player.Tell("Currently available sets (use \"all\" to get literally everything):", AFArgs.User, HUD_PRINTCONSOLE);
			array<string> plugins = g_PluginManager.GetPluginList();
			af2player.Tell("vanilla", AFArgs.User, HUD_PRINTCONSOLE);
			for(uint i = 0; i < plugins.length(); i++)
			{
				if(plugins[i].ToLowercase() == "insurgency mod")
					af2player.Tell("ins2", AFArgs.User, HUD_PRINTCONSOLE);
				if(plugins[i].ToLowercase() == "counter-strike 1.6 mod")
					af2player.Tell("cs16", AFArgs.User, HUD_PRINTCONSOLE);
				if(plugins[i].ToLowercase() == "cry of fear")
					af2player.Tell("cof", AFArgs.User, HUD_PRINTCONSOLE);
			}
			
			return;
		}
		
		//read out whats available for "all" set... because who knows - someone might be mad enough to run all at once
		array<string> plugins = g_PluginManager.GetPluginList();
		for(uint i = 0; i < plugins.length(); i++)
		{
			if(plugins[i].ToLowercase() == "insurgency mod")
				availables |= WEAPONLIST_INS2;
			if(plugins[i].ToLowercase() == "counter-strike 1.6 mod")
				availables |= WEAPONLIST_CS16;
			if(plugins[i].ToLowercase() == "cry of fear")
				availables |= WEAPONLIST_COF;
		}
		
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, sTargets, TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Gave everything from \""+sSet+"\" set to "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				if(sSet == "vanilla")
				{
					for(uint j = 0; j < player_weaponlist_native.length(); j++)
						pTarget.GiveNamedItem(player_weaponlist_native[j], 0, 9999);
				}
				else if(sSet == "ins2")
				{
					for(uint j = 0; j < player_weaponlist_ins2.length(); j++)
						pTarget.GiveNamedItem(player_weaponlist_ins2[j], 0, 9999);
				}
				else if(sSet == "cs16")
				{
					for(uint j = 0; j < player_weaponlist_cs16.length(); j++)
						pTarget.GiveNamedItem(player_weaponlist_cs16[j], 0, 9999);
				}
				else if(sSet == "cof")
				{
					for(uint j = 0; j < player_weaponlist_cof.length(); j++)
						pTarget.GiveNamedItem(player_weaponlist_cof[j], 0, 9999);
				}
				else if(sSet == "all") // you mad man
				{
					for(uint j = 0; j < player_weaponlist_native.length(); j++)
						pTarget.GiveNamedItem(player_weaponlist_native[j], 0, 9999);
						
					if(availables & WEAPONLIST_INS2 > 0)
						for(uint j = 0; j < player_weaponlist_ins2.length(); j++)
							pTarget.GiveNamedItem(player_weaponlist_ins2[j], 0, 9999);
						
					if(availables & WEAPONLIST_CS16 > 0)
						for(uint j = 0; j < player_weaponlist_cs16.length(); j++)
							pTarget.GiveNamedItem(player_weaponlist_cs16[j], 0, 9999);
						
					if(availables & WEAPONLIST_COF > 0)
						for(uint j = 0; j < player_weaponlist_cof.length(); j++)
							pTarget.GiveNamedItem(player_weaponlist_cof[j], 0, 9999);
				}
			}
		}
	}

	void give(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFArgs.GetString(1) == "weapon_entmover")
		{
			af2player.Tell("Can't give entmover!", AFArgs.User, targetHud);
			return;
		}
		
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(pTarget.HasNamedPlayerItem(AFArgs.GetString(1)) !is null)
				{
					af2player.Tell("Can't give "+AFArgs.GetString(1)+" to "+pTarget.pev.netname+": target already has weapon!", AFArgs.User, targetHud);
					continue;
				}
				
				pTarget.GiveNamedItem(AFArgs.GetString(1), 0, 9999);
				af2player.Tell("Gave "+AFArgs.GetString(1)+" to "+pTarget.pev.netname, AFArgs.User, targetHud);
			}
		}
	}

	void getmodel(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				KeyValueBuffer@ pInfo = g_EngineFuncs.GetInfoKeyBuffer(pTarget.edict());
				af2player.Tell("Player "+pTarget.pev.netname+" model is "+pInfo.GetValue("model"), AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void disarm(AFBaseArguments@ AFArgs)
	{
		string sTargetWeapon = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "";
		if(sTargetWeapon == "weapon_entmover")
		{
			af2player.Tell("Can't disarm entmover!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				if(!pTarget.HasWeapons())
				{
					af2player.Tell("Can't disarm "+pTarget.pev.netname+": player has no weapons!", AFArgs.User, HUD_PRINTCONSOLE);
				}
				
				if(sTargetWeapon == "")
				{
					//special case behavior so we can remove all weapons except entmover
					int amt = 0;
					CBasePlayerItem@ pItem;
					CBasePlayerItem@ pItemHold;
					CBasePlayerWeapon@ pWeapon;
					for(uint j = 0; j < MAX_ITEM_TYPES; j++)
					{
						@pItem = pTarget.m_rgpPlayerItems(j);
						while(pItem !is null)
						{
							@pWeapon = pItem.GetWeaponPtr();
							
							if(pWeapon.GetClassname() != "weapon_entmover")
							{
								@pItemHold = pItem;
								@pItem = cast<CBasePlayerItem@>(pItem.m_hNextItem.GetEntity());
								pTarget.RemovePlayerItem(pItemHold);
								amt++;
								continue;
							}
							
							@pItem = cast<CBasePlayerItem@>(pItem.m_hNextItem.GetEntity());
						}
					}
					
					af2player.Tell("Disarmed "+string(amt)+" weapons from "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				}
				else
				{
					if(AFBase::RemoveSingleItem(pTarget, sTargetWeapon))
						af2player.Tell("Disarmed \""+sTargetWeapon+"\" from "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
					else
						af2player.Tell(string(pTarget.pev.netname)+" has no weapon called \""+sTargetWeapon+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				}
			}
		}
	}

	void teleportpos(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			Vector position = AFArgs.GetVector(1);
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Teleported "+pTarget.pev.netname+" to X: "+position.x+" Y: "+position.y+" Z: "+position.z, AFArgs.User, targetHud);
				pTarget.SetOrigin(position);
				pTarget.pev.velocity = Vector(0,0,0);
				pTarget.pev.flFallVelocity = 0.0f;
			}
		}
	}

	void teleporttome(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Teleported "+pTarget.pev.netname, AFArgs.User, targetHud);
				pTarget.SetOrigin(AFArgs.User.pev.origin);
				pTarget.pev.velocity = Vector(0,0,0);
				pTarget.pev.fixangle = FAM_FORCEVIEWANGLES;
				pTarget.pev.angles = AFArgs.User.pev.angles;
			}
		}
	}

	void teleportmeto(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			af2player.Tell("Teleported to "+AFArgs.GetString(0), AFArgs.User, targetHud);
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				AFArgs.User.SetOrigin(pTarget.pev.origin);
				AFArgs.User.pev.velocity = Vector(0,0,0);
				AFArgs.User.pev.fixangle = FAM_FORCEVIEWANGLES;
				AFArgs.User.pev.angles = pTarget.pev.angles;
				AFArgs.User.pev.flFallVelocity = 0.0f;
			}
		}
	}

	void teleportaim(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOAIM|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			g_EngineFuncs.MakeVectors(AFArgs.User.pev.v_angle);
			Vector vecSrc = AFArgs.User.GetGunPosition();
			Vector vecAiming = g_Engine.v_forward;
			TraceResult tr;
			g_Utility.TraceHull(vecSrc, vecSrc+vecAiming*2048, dont_ignore_monsters, human_hull, AFArgs.User.edict(), tr);
			Vector endResult = tr.vecEndPos;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Teleported "+pTarget.pev.netname, AFArgs.User, targetHud);
				pTarget.SetOrigin(endResult);
				pTarget.pev.velocity = Vector(0,0,0);
				pTarget.pev.flFallVelocity = 0.0f;
			}
		}
	}
	
	void notarget(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		int iMode = AFArgs.GetCount() >= 2 ? AFArgs.GetInt(1) : -1;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				bool bIsOn = int(g_playerModes[pTarget.entindex()]) & PLAYER_NOTARGET > 0 ? true : false;
				if(iMode == -1)
				{
					af2player.Tell("Toggled notarget for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
					int iFlags = int(g_playerModes[pTarget.entindex()]);
					iFlags ^= PLAYER_NOTARGET;
					g_playerModes[pTarget.entindex()] = iFlags;
				}else if(iMode == 1)
				{
					if(!bIsOn)
					{
						af2player.Tell("Set notarget on for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags |= PLAYER_NOTARGET;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is already in notarget!", AFArgs.User, HUD_PRINTCONSOLE);
				}else{
					if(bIsOn)
					{
						af2player.Tell("Set notarget for "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
						int iFlags = int(g_playerModes[pTarget.entindex()]);
						iFlags &= ~PLAYER_NOTARGET;
						g_playerModes[pTarget.entindex()] = iFlags;
					}else
						af2player.Tell("Player "+pTarget.pev.netname+" is not in notarget!", AFArgs.User, HUD_PRINTCONSOLE);
				}
			}
			
			CheckPlayerModes(null);
		}
	}
}