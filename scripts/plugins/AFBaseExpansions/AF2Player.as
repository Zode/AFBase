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
		RegisterCommand("say !tpaim", "s", "(targets) - teleport target(s) to where you are aiming at", ACCESS_G, @AF2Player::teleportaim, false, true);
		RegisterCommand("player_teleportmeto", "s", "(target) - teleport you to target", ACCESS_G, @AF2Player::teleportmeto);
		RegisterCommand("say !tpmeto", "s", "(target) - teleport you to target", ACCESS_G, @AF2Player::teleportmeto, false, true);
		RegisterCommand("player_teleporttome", "s", "(targets) - teleport target(s) to you", ACCESS_G, @AF2Player::teleporttome);
		RegisterCommand("say !tptome", "s", "(targets) - teleport target(s) to you", ACCESS_G, @AF2Player::teleporttome, false, true);
		RegisterCommand("player_teleportpos", "sv", "(targets) (vector) - teleport target(s) to position", ACCESS_G, @AF2Player::teleportpos);
		RegisterCommand("player_disarm", "s", "(targets) - disarm target(s)", ACCESS_G, @AF2Player::disarm);
		RegisterCommand("player_getmodel", "s", "(targets) - return target(s) playermodel", ACCESS_G, @AF2Player::getmodel);
		RegisterCommand("player_give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2Player::give);
		RegisterCommand("say !give", "ss", "(targets) (weapon/ammo/item) - give target(s) stuff", ACCESS_G, @AF2Player::give, false, true);
		RegisterCommand("player_giveall", "s", "(targets) - give target(s) all stock weapons", ACCESS_G, @AF2Player::giveall);
		RegisterCommand("player_giveammo", "s", "(targets) - give target(s) ammo", ACCESS_G, @AF2Player::giveammo);
		RegisterCommand("say !giveammo", "s", "(targets) - give target(s) ammo", ACCESS_G, @AF2Player::giveammo, false, true);
		RegisterCommand("player_givemapcfg", "s", "(targets) - apply map cfg to target(s)", ACCESS_G, @AF2Player::givemapcfg);
		RegisterCommand("player_position", "s", "(target) - returns target position,", ACCESS_G, @AF2Player::position);
		RegisterCommand("player_resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2Player::resurrect);
		RegisterCommand("say !resurrect", "s!b", "(targets) <0/1 no respawn> - resurrect target(s)", ACCESS_G, @AF2Player::resurrect, false, true);
		RegisterCommand("player_setmaxspeed", "sf", "(targets) (speed) - set target(s) max speed", ACCESS_G, @AF2Player::maxspeed);
		RegisterCommand("player_keyvalue", "ss!sss", "(targets) (key) <value> <value> <value> - get/set target(s) keyvalue", ACCESS_G, @AF2Player::keyvalue);
		RegisterCommand("player_nosolid", "s!b", "(targets) <0/1 mode> - set target(s) solidity, don't define mode to toggle", ACCESS_G, @AF2Player::nosolid);
		RegisterCommand("say !nosolid", "s!i", "(targets) <0/1 mode> - set target(s) nosolid mode, don't define mode to toggle", ACCESS_G, @AF2Player::nosolid, false, true);
		RegisterCommand("player_noclip", "s!i", "(targets) <0/1 mode> - set target(s) noclip mode, don't define mode to toggle", ACCESS_G, @AF2Player::noclip);
		RegisterCommand("player_god", "s!i", "(targets) <0/1 mode> - set target(s) godmode, don't define mode to toggle", ACCESS_G, @AF2Player::god);
		RegisterCommand("player_freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2Player::freeze);
		RegisterCommand("say !freeze", "s!i", "(targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle", ACCESS_G, @AF2Player::freeze, false, true);
		RegisterCommand("player_ignite", "s", "(targets) - ignite target(s)", ACCESS_G, @AF2Player::ignite, true);
		RegisterCommand("player_viewmode", "sb", "(targets) (0/1 firstperson/thirdperson) - set target(s) viewmode", ACCESS_G, @AF2Player::viewmode);
	
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
		recheckPlayers();
		g_SoundSystem.PrecacheSound("ambience/flameburst1.wav");
		g_Game.PrecacheModel("sprites/flame2.spr");
		if(AF2Player::g_playerThink !is null)
			g_Scheduler.RemoveTimer(AF2Player::g_playerThink);
	
		@AF2Player::g_playerThink = g_Scheduler.SetInterval("playerThink", 0.25f);
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
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pPlayer)
	{
		if(AF2Player::g_playerModes.exists(pPlayer.entindex()))
			AF2Player::g_playerModes.delete(pPlayer.entindex());
	}
}

namespace AF2Player
{
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
						af2player.Tell("Player "+pTarget.pev.netname+" is not forzen!", AFArgs.User, targetHud);
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
						if(pSearch.pev.movetype != PLAYER_NOCLIP)
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
		}
	}
	
	dictionary g_playerModes;

	enum PlayerModes
	{
		PLAYER_NOSOLID = 1,
		PLAYER_NOCLIP = 2,
		PLAYER_FLAMING = 4,
		PLAYER_GOD = 8,
		PLAYER_FROZEN = 16
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
						af2player.Tell("Player \""+pTarget.pev.netname+"\" key is \""+sReturn+"\"", AFArgs.User, HUD_PRINTCONSOLE);
					else
						af2player.Tell("Unsupported key in get", AFArgs.User, HUD_PRINTCONSOLE);
				}else{
					if(AFArgs.GetString(1) == "model" || AFArgs.GetString(1) == "viewmodel" || AFArgs.GetString(1) == "weaponmodel" || AFArgs.GetString(1) == "modelindex")
					{
						if(!bHasE)
						{
							af2player.Tell("Blocked: you require access flag E to do this action (\"highrisk\" key).", AFArgs.User, HUD_PRINTCONSOLE);
							return;
						}
					}
					
					af2player.Tell("Set player \""+pTarget.pev.netname+"\" key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
					g_EntityFuncs.DispatchKeyValue(pTarget.edict(), AFArgs.GetString(1), sValout);
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
				g_EngineFuncs.SetClientMaxspeed(pTarget.edict(), AFArgs.GetFloat(1));
				af2player.Tell("Set max speed "+string(AFArgs.GetFloat(1))+" to "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}

	void resurrect(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		bool bNoRespawn = AFArgs.GetCount() >= 2 ? AFArgs.GetBool(1) : false;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOIMMUNITYCHECK, pTargets))
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
					pTarget.pev.origin = oldPos;
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
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NOALL|TARGETS_NOIMMUNITYCHECK, pTargets))
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
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
		if(AFBase::GetTargetPlayers(AFArgs.User, targetHud, AFArgs.GetString(0), TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pTarget.m_hActiveItem.GetEntity());
				//CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pTarget.m_pActiveItem);
				if(activeItem.PrimaryAmmoIndex() > -1)
					pTarget.GiveAmmo(activeItem.iMaxAmmo1(), activeItem.pszAmmo1(), activeItem.iMaxAmmo1());
					
				if(activeItem.SecondaryAmmoIndex() > -1)
					pTarget.GiveAmmo(activeItem.iMaxAmmo2(), activeItem.pszAmmo2(), activeItem.iMaxAmmo2());
					
				af2player.Tell("Gave ammo to "+pTarget.pev.netname, AFArgs.User, targetHud);
			}
		}
	}

	const array<string> player_weaponlist = 
	{
		"weapon_357",
		"weapon_9mmar",
		"weapon_9mmhandgun",
		"weapon_crossbow",
		"weapon_crowbar",
		"weapon_displacer",
		"weapon_eagle",
		"weapon_egon",
		"weapon_gauss",
		"weapon_grapple",
		"weapon_handgrenade",
		"weapon_hornetgun",
		"weapon_m16",
		"weapon_m249",
		"weapon_medkit",
		"weapon_minigun",
		"weapon_pipewrench",
		"weapon_rpg",
		"weapon_satchel",
		"weapon_shotgun",
		"weapon_snark",
		"weapon_sniperrifle",
		"weapon_sporelauncher",
		"weapon_tripmine",
		"weapon_uzi"
	};

	void giveall(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), TARGETS_NODEAD|TARGETS_NOIMMUNITYCHECK, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Gave everything to "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				for(uint j = 0; j < player_weaponlist.length(); j++)
				{
					pTarget.GiveNamedItem(player_weaponlist[j], 0, 9999);
				}
			}
		}
	}

	void give(AFBaseArguments@ AFArgs)
	{
		array<CBasePlayer@> pTargets;
		HUD targetHud = AFArgs.IsChat ? HUD_PRINTTALK : HUD_PRINTCONSOLE;
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
		array<CBasePlayer@> pTargets;
		if(AFBase::GetTargetPlayers(AFArgs.User, HUD_PRINTCONSOLE, AFArgs.GetString(0), 0, pTargets))
		{
			CBasePlayer@ pTarget = null;
			for(uint i = 0; i < pTargets.length(); i++)
			{
				@pTarget = pTargets[i];
				af2player.Tell("Disarmed "+pTarget.pev.netname, AFArgs.User, HUD_PRINTCONSOLE);
				pTarget.RemoveAllItems(false);
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
				pTarget.pev.origin = position;
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
				pTarget.pev.origin = AFArgs.User.pev.origin;
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
				AFArgs.User.pev.origin = pTarget.pev.origin;
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
				pTarget.pev.origin = endResult;
				pTarget.pev.velocity = Vector(0,0,0);
				pTarget.pev.flFallVelocity = 0.0f;
			}
		}
	}
}