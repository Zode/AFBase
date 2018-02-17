#include "AF2Legacy"

AF2Entity af2entity;

void AF2Entity_Call()
{
	af2entity.RegisterExpansion(af2entity);
}

class AF2Entity : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery2 Entity Commands";
		this.ShortName = "AF2E";
	}
	
	void ExpansionInit()
	{
		RegisterCommand("ent_damage", "!fs", "<damage> <targetname> - damage entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2Entity::damage);
		RegisterCommand("ent_keyvalue", "s!sss", "(key) <value> <value> <value> - get/set keyvalue of entity you are aiming at, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2Entity::keyvalue);
		RegisterCommand("ent_keyvaluename", "ss!sss", "(targetname) (key) <value> <value> <value> - get/set keyvalue of entity based on targetname, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2Entity::keyvaluename);
		RegisterCommand("ent_keyvaluerange", "sfs!sss", "(classname) (range) (key) <value> <value><value> - get/set keyvalue of entity based on classname and range, use \"!null!\" to set keyvalue as empty", ACCESS_F, @AF2Entity::keyvaluerange);
		RegisterCommand("ent_kill", "!s", "<targetname> - removes entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2Entity::kill);
		RegisterCommand("ent_trigger", "!s", "<targetname> - trigger entity, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2Entity::trigger);
		RegisterCommand("ent_triggerrange", "sf", "(classname) (range) - trigger entity based on classname and range", ACCESS_F, @AF2Entity::triggerrange);
		RegisterCommand("ent_rotate", "fff!s", "(x) (y) (z) <targetname> - rotate entity, if no targetname given it will attempt to trace forwards. For best results use 15 increments", ACCESS_F, @AF2Entity::rotate);
		RegisterCommand("ent_rotateabsolute", "fff!s", "(x) (y) (z) <targetname> - set entity rotation, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2Entity::rotateabsolute);
		RegisterCommand("ent_create", "s!s", "(classname) <\"key:value:key:value:key:value\" etc> - create entity, default position at your origin", ACCESS_F|ACCESS_E, @AF2Entity::create);
		RegisterCommand("ent_movename", "s", "(targetname) - absolute move, entity is placed to your origin", ACCESS_F, @AF2Entity::moveabsolute);
		RegisterCommand("ent_move", "!b", "- Use without argument to see usage/alias - Grab entity and move it relative to you", ACCESS_F, @AF2Entity::move);
		RegisterCommand("ent_movecopy", "!b", "- Use without argument to see usage/alias - Copy & grab (copied) entity and move it relative to you", ACCESS_F, @AF2Entity::movecopy);
		RegisterCommand("ent_drop", "", "- Drop entity that you are aiming at to ground", ACCESS_F, @AF2Entity::drop);
		RegisterCommand("ent_item", "s", "(weapon_/ammo_/item_ name) - Spawn weapon/ammo/item at your location", ACCESS_F, @AF2Entity::item);
		RegisterCommand("ent_worldcopy", "f!vbbb", "(speed) <angle vector> <0/1 reverse> <0/1 xaxis> <0/1 yaxis> - Create worldcopy", ACCESS_F, @AF2Entity::worldcopy);
		RegisterCommand("ent_worldremove", "", "- Remove all worldcopies", ACCESS_F, @AF2Entity::worldremove);
		RegisterCommand("ent_mover", "!i", "<0/1 mode> - weapon_entmover, don't define mode to toggle", ACCESS_F, @AF2Entity::entmover, true);
		RegisterCommand("ent_dumpinfo", "!bs", "<dirty 0/1> <targetname> - dump entity keyvalues into console, if no targetname given it will attempt to trace forwards", ACCESS_F, @AF2Entity::dumpinfo);
		
		g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @AF2Entity::PlayerPreThink);
		g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @AF2Entity::PlayerSpawn);
		
		AF2Entity::g_entMoving.deleteAll();
		AF2Entity::g_entWeapon.deleteAll();
		if(AF2Entity::g_entThink !is null)
			g_Scheduler.RemoveTimer(AF2Entity::g_entThink);
	
		@AF2Entity::g_entThink = g_Scheduler.SetInterval("entThink", 0.075f+Math.RandomFloat(0.0f, 0.05f));
	}
	
	void MapInit()
	{
		AF2Entity::g_entMoving.deleteAll();
		AF2Entity::g_entWeapon.deleteAll();
		if(AF2Entity::g_entThink !is null)
			g_Scheduler.RemoveTimer(AF2Entity::g_entThink);
	
		@AF2Entity::g_entThink = g_Scheduler.SetInterval("entThink", 0.075f+Math.RandomFloat(0.0f, 0.05f));
		
		g_Game.PrecacheModel("models/zode/v_entmover.mdl");
		g_Game.PrecacheModel("models/zode/p_entmover.mdl");
		g_Game.PrecacheModel("sprites/zbeam4.spr");
		g_Game.PrecacheModel("sprites/zerogxplode.spr");
		g_SoundSystem.PrecacheSound("tfc/items/inv3.wav");
	}
	
	void PlayerDisconnectEvent(CBasePlayer@ pUser)
	{
		if(AF2Entity::g_entMoving.exists(pUser.entindex()))
			AF2Entity::g_entMoving.delete(pUser.entindex());
			
		if(AF2Entity::g_entWeapon.exists(pUser.entindex()))
			AF2Entity::g_entWeapon.delete(pUser.entindex());
	}
	
	void StopEvent()
	{
		// handle stop copy grab
		CBasePlayer@ pSearch = null;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(AF2Entity::g_entMoving.exists(pSearch.entindex()))
				{
					Vector grabIndex = Vector(AF2Entity::g_entMoving[pSearch.entindex()]);
					CBaseEntity@ pEntity = g_EntityFuncs.Instance(int(grabIndex.x));
					if(pEntity !is null)
					{
						AF2Entity::popEntRenderSettings(pEntity);
						CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
						pCustom.SetKeyvalue("$i_afbentgrab", 0);
						if(pEntity.IsPlayer())
						{
							if(pEntity.pev.movetype != MOVETYPE_WALK)
								pEntity.pev.movetype = MOVETYPE_WALK;
							
							if(pEntity.pev.flags & FL_FROZEN > 0)
								pEntity.pev.flags &= ~FL_FROZEN;
						}
					}
				}
				
				if(AF2Entity::g_entWeapon.exists(pSearch.entindex()))
				{
					AF2Entity::weaponmover(pSearch, false, false);
				}
			}
		}
		
		dictionary dData;
		dData["player"] = null;
		SendMessage("AF2P", "RecheckPlayer", dData);
		
		AF2Entity::g_entMoving.deleteAll();
		AF2Entity::g_entWeapon.deleteAll();
		if(AF2Entity::g_entThink !is null)
			g_Scheduler.RemoveTimer(AF2Entity::g_entThink);
	}
	
	void StartEvent()
	{
		if(AF2Entity::g_entThink !is null)
			g_Scheduler.RemoveTimer(AF2Entity::g_entThink);
	
		@AF2Entity::g_entThink = g_Scheduler.SetInterval("entThink", 0.075f+Math.RandomFloat(0.0f, 0.05f));
	}
}

namespace AF2Entity
{
	void dumpinfo(AFBaseArguments@ AFArgs)
	{
		string sTarget = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "";
		bool bDirty = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) : false;
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity is null)
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't dump: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			dictionary stuff = bDirty ? AF2LegacyCode::reverseGetKeyvalue(pEntity) : AF2LegacyCode::prunezero(AF2LegacyCode::reverseGetKeyvalue(pEntity));
			array<string> dkeys = stuff.getKeys();
			af2entity.Tell("Entity keyvalues:", AFArgs.User, HUD_PRINTCONSOLE);
			for(uint i = 0; i < dkeys.length(); i++)
			{
				string sout = string(stuff[dkeys[i]]);
				af2entity.Tell("\""+dkeys[i]+"\" -> \""+sout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			int iC = 0;
			CBaseEntity@ pEntity = null;
			while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, sTarget)) !is null)
			{
				dictionary stuff = AF2LegacyCode::reverseGetKeyvalue(pEntity);
				array<string> dkeys = stuff.getKeys();
				af2entity.Tell("========\nEntity keyvalues:\n========", AFArgs.User, HUD_PRINTCONSOLE);
				for(uint i = 0; i < dkeys.length(); i++)
				{
					string sout = string(stuff[dkeys[i]]);
					af2entity.Tell("\""+dkeys[i]+"\" -> \""+sout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				}
				af2entity.Tell("========", AFArgs.User, HUD_PRINTCONSOLE);
				
				iC++;
			}
			
			if(iC == 0)
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}
	
	dictionary g_entMoving;
	CScheduledFunction@ g_entThink = null;
	dictionary g_entWeapon;
	
	HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
	{
		if(g_entWeapon.exists(pPlayer.entindex()))
			weaponmover(pPlayer, false, true);
		
		return HOOK_CONTINUE;
	}
	
	HookReturnCode PlayerPreThink(CBasePlayer@ pPlayer, uint &out magicnumbers)
	{
		if(af2entity.Running)
		{
			if(g_entWeapon.exists(pPlayer.entindex()))
			{
				bool bUsing = g_entMoving.exists(pPlayer.entindex()) ? true : false;
				EntMoverData@ emd = cast<EntMoverData@>(g_entWeapon[pPlayer.entindex()]);
				
				if(pPlayer.pev.button & IN_ATTACK > 0)
				{
					pPlayer.pev.button &= ~IN_ATTACK;
					
					if(!bUsing && !emd.bHolding)
					{
						emd.bHolding = true;
						emd.vColor = Vector(Math.RandomLong(0, 255),Math.RandomLong(0, 255),Math.RandomLong(0, 255));
						g_entWeapon[pPlayer.entindex()] = emd;
						g_EngineFuncs.MakeVectors(pPlayer.pev.v_angle);
						Vector vecStart = pPlayer.GetGunPosition();
						TraceResult tr;
						g_Utility.TraceLine(vecStart, vecStart+g_Engine.v_forward*4096, dont_ignore_monsters, pPlayer.edict(), tr);
						CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr.pHit);
						if(pEntity is null || pEntity.pev.classname == "worldspawn")
						{
							af2entity.Tell("No entity in front (4096 units)!", pPlayer, HUD_PRINTTALK);
							return HOOK_CONTINUE;
						}
						
						CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
						if(pCustom.GetKeyvalue("$i_afbentgrab").GetInteger() == 1)
						{
							af2entity.Tell("Can't grab: entity already being grabbed!", pPlayer, HUD_PRINTTALK);
							return HOOK_CONTINUE;
						}
						g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_WEAPON, "tfc/items/inv3.wav", 1.0f, 1.0f, SND_FORCE_LOOP, PITCH_NORM);
						
						pushEntRenderSettings(pEntity);
						pCustom.SetKeyvalue("$i_afbentgrab", 1);
						//pEntity.pev.rendermode = 1;
						//pEntity.pev.renderfx = 0;
						//pEntity.pev.rendercolor = Vector(0, 255, 0);
						//pEntity.pev.renderamt = 88;
						Vector vecOffset = tr.vecEndPos;
						float fDist = (vecOffset - vecStart).Length();
						pCustom.SetKeyvalue("$v_afbentofs", vecOffset);
						g_entMoving[pPlayer.entindex()] = Vector(pEntity.entindex(), fDist, 0);
						if(pEntity.IsPlayer())
						{
							if(pEntity.pev.movetype != MOVETYPE_NOCLIP)
								pEntity.pev.movetype = MOVETYPE_NOCLIP;
								
							if(pEntity.pev.flags & FL_FROZEN == 0)
								pEntity.pev.flags |= FL_FROZEN;
						}
					}
				}else{
					if(bUsing && emd.bHolding)
					{
						emd.bHolding = false;
						g_entWeapon[pPlayer.entindex()] = emd;
						g_SoundSystem.StopSound(pPlayer.edict(), CHAN_WEAPON, "tfc/items/inv3.wav", false);
						Vector grabIndex = Vector(g_entMoving[pPlayer.entindex()]);
						CBaseEntity@ pEntity = g_EntityFuncs.Instance(int(grabIndex.x));
						if(pEntity !is null)
						{
							popEntRenderSettings(pEntity);
							CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
							pCustom.SetKeyvalue("$i_afbentgrab", 0);
							if(pEntity.IsPlayer())
							{
								if(pEntity.pev.movetype != MOVETYPE_WALK)
									pEntity.pev.movetype = MOVETYPE_WALK;
								
								if(pEntity.pev.flags & FL_FROZEN > 0)
									pEntity.pev.flags &= ~FL_FROZEN;
								
								dictionary dData;
								EHandle ePlayer = cast<CBasePlayer@>(pEntity);
								dData["player"] = ePlayer;
								af2entity.SendMessage("AF2P", "RecheckPlayer", dData);
							}
						}
						
						g_entMoving.delete(pPlayer.entindex());
					}else if(!bUsing && emd.bHolding)
					{
						emd.bHolding = false;
						g_entWeapon[pPlayer.entindex()] = emd;
					}
				}
				
				if(pPlayer.pev.button & IN_ATTACK2 > 0)
				{
					pPlayer.pev.button &= ~IN_ATTACK2;
					
					if(!emd.bHolding2)
					{
						emd.bHolding2 = true;
						g_entWeapon[pPlayer.entindex()] = emd;
						
						g_EngineFuncs.MakeVectors(pPlayer.pev.v_angle);
						Vector vecStart = pPlayer.GetGunPosition();
						TraceResult tr;
						g_Utility.TraceLine(vecStart, vecStart+g_Engine.v_forward*4096, dont_ignore_monsters, pPlayer.edict(), tr);
						CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr.pHit);
						if(pEntity is null || pEntity.pev.classname == "worldspawn")
						{
							af2entity.Tell("No entity in front (4096 units)!", pPlayer, HUD_PRINTTALK);
							return HOOK_CONTINUE;
						}
						
						if(pEntity.IsPlayer())
						{
							af2entity.Tell("Can't kill: target is player!", pPlayer, HUD_PRINTTALK);
							return HOOK_CONTINUE;
						}
						
						NetworkMessage msg(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
							msg.WriteByte(TE_BEAMPOINTS);
							msg.WriteCoord(vecStart.x);
							msg.WriteCoord(vecStart.y);
							msg.WriteCoord(vecStart.z-8);
							msg.WriteCoord(tr.vecEndPos.x);
							msg.WriteCoord(tr.vecEndPos.y);
							msg.WriteCoord(tr.vecEndPos.z);
							msg.WriteShort(g_EngineFuncs.ModelIndex("sprites/zbeam4.spr"));
							msg.WriteByte(0);
							msg.WriteByte(0);
							msg.WriteByte(4);
							msg.WriteByte(8);
							msg.WriteByte(32);
							msg.WriteByte(255);
							msg.WriteByte(0);
							msg.WriteByte(0);
							msg.WriteByte(255);
							msg.WriteByte(0);
						msg.End();
						
						NetworkMessage msg2(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
							msg2.WriteByte(TE_EXPLOSION);
							msg2.WriteCoord(tr.vecEndPos.x);
							msg2.WriteCoord(tr.vecEndPos.y);
							msg2.WriteCoord(tr.vecEndPos.z);
							msg2.WriteShort(g_EngineFuncs.ModelIndex("sprites/zerogxplode.spr"));
							msg2.WriteByte(10);
							msg2.WriteByte(15);
							msg2.WriteByte(0);
						msg2.End();
						
						g_EntityFuncs.Remove(pEntity);
					}
				}else{
					if(emd.bHolding2)
					{
						emd.bHolding2 = false;
						g_entWeapon[pPlayer.entindex()] = emd;
					}
				}
				
				if(pPlayer.pev.button & IN_ALT1 > 0)
				{
					pPlayer.pev.button &= ~IN_ALT1;
				}
				
				if(pPlayer.pev.button & IN_RELOAD > 0)
				{
					pPlayer.pev.button &= ~IN_RELOAD;
				}
			}
		}
		
		return HOOK_CONTINUE;
	}
	
	class EntMoverData
	{
		string weaponModel = "models/zode/p_entmover.mdl";
		string viewModel = "models/zode/v_entmover.mdl";
		bool bHolding = false;
		bool bHolding2 = false;
		Vector vColor = Vector(0,0,0);
	}
	
	void weaponmover(CBasePlayer@ pPlayer, bool bMode, bool bReset)
	{
		if(bMode)
		{
			EntMoverData emd;
			emd.weaponModel = pPlayer.pev.weaponmodel;
			emd.viewModel = pPlayer.pev.viewmodel;
			pPlayer.pev.weaponmodel = "models/zode/p_entmover.mdl";
			pPlayer.pev.viewmodel = "models/zode/v_entmover.mdl";
			pPlayer.m_iHideHUD = 1;
			pPlayer.m_iEffectBlockWeapons = 1;
			if(pPlayer.pev.flags & FL_NOWEAPONS == 0)
				pPlayer.pev.flags |= FL_NOWEAPONS;
			if(pPlayer.HasWeapons())
			{
				CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
				activeItem.SendWeaponAnim(0,0,0);
				activeItem.m_flNextPrimaryAttack = 43200.0f;
				activeItem.m_flNextSecondaryAttack = 43200.0f;
				activeItem.m_flNextTertiaryAttack = 43200.0f;
				activeItem.m_flTimeWeaponIdle = 43200.0f;
			}
			
			g_entWeapon[pPlayer.entindex()] = emd;
			
		}else{
			EntMoverData@ emd = cast<EntMoverData@>(g_entWeapon[pPlayer.entindex()]);
			if(!bReset)
			{
				pPlayer.pev.weaponmodel = emd.weaponModel;
				pPlayer.pev.viewmodel = emd.viewModel;
			}
			pPlayer.m_iHideHUD = 0;
			pPlayer.m_iEffectBlockWeapons = 0;
			if(pPlayer.pev.flags & FL_NOWEAPONS > 0)
			pPlayer.pev.flags &= ~FL_NOWEAPONS;
			if(pPlayer.HasWeapons())
			{
				CBasePlayerWeapon@ activeItem = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
				activeItem.SendWeaponAnim(0,0,0);
				activeItem.m_flNextPrimaryAttack = 0;
				activeItem.m_flNextSecondaryAttack = 0;
				activeItem.m_flNextTertiaryAttack = 0;
				activeItem.m_flTimeWeaponIdle = 0;
			}
			g_entWeapon.delete(pPlayer.entindex());
		}
	}
	
	void entmover(AFBaseArguments@ AFArgs)
	{
		int iMode = AFArgs.GetCount() >= 1 ? AFArgs.GetInt(0) : -1;
		bool bIsOn = g_entWeapon.exists(AFArgs.User.entindex());
		if(iMode == -1)
		{
			if(bIsOn)
			{
				weaponmover(AFArgs.User, false, false);
			}else{
				weaponmover(AFArgs.User, true, false);
			}
			
			af2entity.Tell("Toggled entmover", AFArgs.User, HUD_PRINTCONSOLE);
		}else if(iMode == 1)
		{
			if(!bIsOn)
			{
				weaponmover(AFArgs.User, true, false);
				af2entity.Tell("Gave entmover", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				af2entity.Tell("Can't give entmover: entmover is already out", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			if(bIsOn)
			{
				weaponmover(AFArgs.User, false, false);
				af2entity.Tell("Removed entmover", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				af2entity.Tell("Can't remove entmover: entmover is not out", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}
	}
	
	void worldcopy(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pWorld = g_EntityFuncs.Create("func_rotating", Vector(0,0,0), AFArgs.GetVector(1), true);
		if(pWorld is null)
		{
			af2entity.Tell("Failed to create worldcopy!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		g_EntityFuncs.DispatchKeyValue(pWorld.edict(), "model", "maps/"+g_Engine.mapname+".bsp");
		g_EntityFuncs.DispatchKeyValue(pWorld.edict(), "speed", AFArgs.GetFloat(0));
		//1 on 64 nosolid 2 reverse 4 xaxis 8 yaxis
		int iFlags = 65; // on nosolid
		if(AFArgs.GetBool(2))
			iFlags += 2; // reverse
			
		if(AFArgs.GetBool(3))
			iFlags += 4; // xaxis
			
		if(AFArgs.GetBool(4))
			iFlags += 8; // yaxis
			
		g_EntityFuncs.DispatchKeyValue(pWorld.edict(), "spawnflags", iFlags);
		g_EntityFuncs.DispatchKeyValue(pWorld.edict(), "effects", 2048);
		g_EntityFuncs.DispatchKeyValue(pWorld.edict(), "targetname", "afb_worldcopy");
		g_EntityFuncs.DispatchSpawn(pWorld.edict());
		af2entity.Tell("Created worldcopy!", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void worldremove(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = null;
		int iC = 0;
		while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, "afb_worldcopy")) !is null)
		{
			g_EntityFuncs.Remove(pEntity);
			iC++;
		}
		
		if(iC > 0)
			af2entity.Tell(string(iC)+" worldcopies deleted", AFArgs.User, HUD_PRINTCONSOLE);
		else
			af2entity.Tell("No worldcopies currently exist!", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void item(AFBaseArguments@ AFArgs)
	{
		string sEnt = AFArgs.GetString(0);
		if(sEnt.SubString(0, 7) != "weapon_" && sEnt.SubString(0, 5) != "item_" && sEnt.SubString(0, 5) != "ammo_")
		{
			af2entity.Tell("Can't spawn \""+AFArgs.GetString(0)+"\": not allowed!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
	
		CBaseEntity@ pEntity = g_EntityFuncs.Create(AFArgs.GetString(0), AFArgs.User.pev.origin, Vector(0, AFArgs.User.pev.angles.y, 0), true);
		if(pEntity !is null)
		{
			g_EntityFuncs.DispatchSpawn(pEntity.edict());
			af2entity.Tell("Spawned \""+AFArgs.GetString(0)+"\"!", AFArgs.User, HUD_PRINTCONSOLE);
		}else
			af2entity.Tell("Failed to spawn \""+AFArgs.GetString(0)+"\"!", AFArgs.User, HUD_PRINTCONSOLE);
	}
	
	void drop(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
		if(pEntity is null)
		{
			af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		if(pEntity.IsPlayer())
		{
			af2entity.Tell("Can't drop: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		g_EngineFuncs.DropToFloor(pEntity.edict());
		af2entity.Tell("Dropped entity!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void movecopy(AFBaseArguments@ AFArgs)
	{
		int iMode = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) ? 2 : 0 : -1;
		if(iMode == -1)
		{
			af2entity.Tell("Aliases: (execute these, perferrably save to autoexec cfg)", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    alias +copy \".ent_movecopy 1\"", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    alias -copy \".ent_movecopy 0\"", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    bind (button) +copy", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		entActualMove(AFArgs, iMode);
	}

	void move(AFBaseArguments@ AFArgs)
	{
		int iMode = AFArgs.GetCount() >= 1 ? AFArgs.GetBool(0) ? 1 : 0 : -1;
		if(iMode == -1)
		{
			af2entity.Tell("Aliases: (execute these, perferrably save to autoexec cfg)", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    alias +grab \".ent_move 1\"", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    alias -grab \".ent_move 0\"", AFArgs.User, HUD_PRINTCONSOLE);
			af2entity.Tell("    bind (button) +grab", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		entActualMove(AFArgs, iMode);
	}
	
	void entThink()
	{
		CBasePlayer@ pSearch = null;
		for(int i = 1; i <= g_Engine.maxClients; i++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pSearch !is null)
			{
				if(g_entMoving.exists(pSearch.entindex()))
				{
					Vector grabIndex = Vector(g_entMoving[pSearch.entindex()]);
					CBaseEntity@ pEntity = g_EntityFuncs.Instance(int(grabIndex.x));
					if(pEntity !is null)
					{
						CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
						Vector vecOffset = pCustom.GetKeyvalue("$v_afbentofs").GetVector();	
						Vector vecOrigin = pSearch.pev.origin;
						g_EngineFuncs.MakeVectors(pSearch.pev.v_angle);
						Vector vecSrc = pSearch.GetGunPosition();
						Vector vecNewEnd = vecSrc+(g_Engine.v_forward*grabIndex.y);
						Vector vecUpdated = pEntity.pev.origin + (vecNewEnd-vecOffset);
						pEntity.pev.oldorigin = vecUpdated;
						pEntity.SetOrigin(vecUpdated);
						g_EntityFuncs.SetOrigin(pEntity, vecUpdated);
						pCustom.SetKeyvalue("$v_afbentofs", vecNewEnd);
						if(pEntity.IsPlayer())
							pEntity.pev.velocity = Vector(0,0,0);
							
						if(g_entWeapon.exists(pSearch.entindex()))
						{
							EntMoverData@ emd = cast<EntMoverData@>(g_entWeapon[pSearch.entindex()]);
							if(emd.bHolding)
							{
								NetworkMessage msg(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
									msg.WriteByte(TE_BEAMPOINTS);
									msg.WriteCoord(vecSrc.x);
									msg.WriteCoord(vecSrc.y);
									msg.WriteCoord(vecSrc.z-8);
									msg.WriteCoord(vecNewEnd.x);
									msg.WriteCoord(vecNewEnd.y);
									msg.WriteCoord(vecNewEnd.z);
									msg.WriteShort(g_EngineFuncs.ModelIndex("sprites/zbeam4.spr"));
									msg.WriteByte(0);
									msg.WriteByte(0);
									msg.WriteByte(2);
									msg.WriteByte(32);
									msg.WriteByte(0);
									msg.WriteByte(int(emd.vColor.x));
									msg.WriteByte(int(emd.vColor.y));
									msg.WriteByte(int(emd.vColor.z));
									msg.WriteByte(255);
									msg.WriteByte(0);
								msg.End();
							}
						}
					}
				}
			}
		}
	}

	void pushEntRenderSettings(CBaseEntity@ pEntity)
	{
		CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
		pCustom.SetKeyvalue("$i_afborendermode", pEntity.pev.rendermode);
		pCustom.SetKeyvalue("$i_afborenderfx", pEntity.pev.renderfx);
		pCustom.SetKeyvalue("$f_afborenderamt", pEntity.pev.renderamt);
		pCustom.SetKeyvalue("$v_afborendercolor", pEntity.pev.rendercolor);
	}
	
	void popEntRenderSettings(CBaseEntity@ pEntity)
	{
		CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
		if(!pCustom.GetKeyvalue("$i_afborendermode").Exists())
			return;
			
		pEntity.pev.rendermode = pCustom.GetKeyvalue("$i_afborendermode").GetInteger();
		pEntity.pev.renderfx = pCustom.GetKeyvalue("$i_afborenderfx").GetInteger();
		pEntity.pev.renderamt = pCustom.GetKeyvalue("$f_afborenderamt").GetFloat();
		pEntity.pev.rendercolor = pCustom.GetKeyvalue("$v_afborendercolor").GetVector();
	}
	
	CBaseEntity@ entCopy(CBaseEntity@ pEntity, CBasePlayer@ pUser)
	{
		if(g_EngineFuncs.NumberOfEntities() >= g_Engine.maxEntities-15*g_Engine.maxClients-100)
		{
			af2entity.Tell("Can't copy: reached maximum limit of entities!", pUser, HUD_PRINTTALK);
			return null;
		}
		
		string sClass = pEntity.pev.classname;
		dictionary dKeyvalues = AF2LegacyCode::cleancopy(AF2LegacyCode::reverseGetKeyvalue(pEntity));
		
		CBaseEntity@ pCopiedEntity = g_EntityFuncs.CreateEntity(sClass, dKeyvalues, false);
		if(pCopiedEntity is null || !g_EntityFuncs.IsValidEntity(pCopiedEntity.edict()))
			return null;
			
		g_EntityFuncs.DispatchSpawn(pCopiedEntity.edict());
		pCopiedEntity.pev.oldorigin = pEntity.pev.origin;
		pCopiedEntity.pev.origin = pEntity.pev.origin;
		pCopiedEntity.pev.angles = pEntity.pev.angles;
		pCopiedEntity.pev.v_angle = pEntity.pev.angles;
		pCopiedEntity.SetOrigin(pEntity.pev.origin);
		g_EntityFuncs.SetOrigin(pCopiedEntity, pEntity.pev.origin);
		return pCopiedEntity;
	}
	
	void entActualMove(AFBaseArguments@ AFArgs, int iMode)
	{
		bool bUsing = g_entMoving.exists(AFArgs.User.entindex()) ? true : false;
		bool bUsing2 = false;
		if(g_entWeapon.exists(AFArgs.User.entindex()))
		{
			EntMoverData@ emd = cast<EntMoverData@>(g_entWeapon[AFArgs.User.entindex()]);
			bUsing2 = emd.bHolding;
		}
		
		if(iMode == 0 && bUsing && !bUsing2)
		{
			Vector grabIndex = Vector(g_entMoving[AFArgs.User.entindex()]);
			CBaseEntity@ pEntity = g_EntityFuncs.Instance(int(grabIndex.x));
			if(pEntity !is null)
			{
				popEntRenderSettings(pEntity);
				CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
				pCustom.SetKeyvalue("$i_afbentgrab", 0);
				if(pEntity.IsPlayer())
				{
					if(pEntity.pev.movetype != MOVETYPE_WALK)
						pEntity.pev.movetype = MOVETYPE_WALK;
					
					if(pEntity.pev.flags & FL_FROZEN > 0)
						pEntity.pev.flags &= ~FL_FROZEN;
					
					dictionary dData;
					EHandle ePlayer = cast<CBasePlayer@>(pEntity);
					dData["player"] = ePlayer;
					af2entity.SendMessage("AF2P", "RecheckPlayer", dData);
				}
			}
			
			g_entMoving.delete(AFArgs.User.entindex());
		}else if(iMode == 1 && !bUsing && !bUsing2)
		{
			g_EngineFuncs.MakeVectors(AFArgs.User.pev.v_angle);
			Vector vecStart = AFArgs.User.GetGunPosition();
			TraceResult tr;
			g_Utility.TraceLine(vecStart, vecStart+g_Engine.v_forward*4096, dont_ignore_monsters, AFArgs.User.edict(), tr);
			CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr.pHit);
			if(pEntity is null || pEntity.pev.classname == "worldspawn")
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
			if(pCustom.GetKeyvalue("$i_afbentgrab").GetInteger() == 1)
			{
				af2entity.Tell("Can't grab: entity already being grabbed!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			pushEntRenderSettings(pEntity);
			pCustom.SetKeyvalue("$i_afbentgrab", 1);
			pEntity.pev.rendermode = 1;
			pEntity.pev.renderfx = 0;
			pEntity.pev.rendercolor = Vector(0, 255, 0);
			pEntity.pev.renderamt = 88;
			Vector vecOffset = tr.vecEndPos;
			float fDist = (vecOffset - vecStart).Length();
			pCustom.SetKeyvalue("$v_afbentofs", vecOffset);
			g_entMoving[AFArgs.User.entindex()] = Vector(pEntity.entindex(), fDist, 0);
			if(pEntity.IsPlayer())
			{
				if(pEntity.pev.movetype != MOVETYPE_NOCLIP)
					pEntity.pev.movetype = MOVETYPE_NOCLIP;
					
				if(pEntity.pev.flags & FL_FROZEN == 0)
					pEntity.pev.flags |= FL_FROZEN;
			}
		}else if(iMode == 2 && !bUsing && !bUsing2)
		{
			g_EngineFuncs.MakeVectors(AFArgs.User.pev.v_angle);
			Vector vecStart = AFArgs.User.GetGunPosition();
			TraceResult tr;
			g_Utility.TraceLine(vecStart, vecStart+g_Engine.v_forward*4096, dont_ignore_monsters, AFArgs.User.edict(), tr);
			CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr.pHit);
			if(pEntity is null || pEntity.pev.classname == "worldspawn")
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			CustomKeyvalues@ pCustom = pEntity.GetCustomKeyvalues();
			if(pCustom.GetKeyvalue("$i_afbentgrab").GetInteger() == 1)
			{
				af2entity.Tell("Can't copy: entity already being grabbed!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't copy: target is player!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			CBaseEntity@ pCopyEntity = entCopy(pEntity, AFArgs.User);
			if(pCopyEntity is null)
			{
				af2entity.Tell("Can't copy: copy result was null!", AFArgs.User, HUD_PRINTTALK);
				return;
			}
			
			CustomKeyvalues@ pCustomCopy = pCopyEntity.GetCustomKeyvalues();
			pushEntRenderSettings(pCopyEntity);
			pCustomCopy.SetKeyvalue("$i_afbentgrab", 1);
			pCopyEntity.pev.rendermode = 1;
			pCopyEntity.pev.renderfx = 0;
			pCopyEntity.pev.rendercolor = Vector(255, 0, 255);
			pCopyEntity.pev.renderamt = 88;
			Vector vecOffset = tr.vecEndPos;
			float fDist = (vecOffset - vecStart).Length();
			pCustomCopy.SetKeyvalue("$v_afbentofs", vecOffset);
			g_entMoving[AFArgs.User.entindex()] = Vector(pCopyEntity.entindex(), fDist, 0);
		}
		
		entThink();
	}

	void moveabsolute(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = null;
		int iC = 0;
		while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, AFArgs.GetString(0))) !is null)
		{
			pEntity.SetOrigin(AFArgs.User.pev.origin);
			g_EntityFuncs.SetOrigin(pEntity, AFArgs.User.pev.origin);
			iC++;
		}
		
		if(iC > 0)
			af2entity.Tell(string(iC)+" entities moved", AFArgs.User, HUD_PRINTCONSOLE);
		else
			af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void create(AFBaseArguments@ AFArgs)
	{
		string sKeyvalues = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "";
		dictionary dKeyvalues;
		bool bOriginDefined = false;
		Vector vecOrigin = AFArgs.User.pev.origin;
		if(sKeyvalues != "")
		{
			array<string> asParse = sKeyvalues.Split(":");
			for(uint i = 0; i < asParse.length(); i=i+2)
			{
				if(i+1 >= asParse.length())
					break;
					
				if(asParse[i] == "origin")
				{
					bOriginDefined = true;
					if(asParse[i+1] == "aim")
					{
						bOriginDefined = false;
						TraceResult tr;
						g_EngineFuncs.MakeVectors(AFArgs.User.pev.v_angle);
						Vector vecStart = AFArgs.User.pev.origin+AFArgs.User.pev.view_ofs;
						g_Utility.TraceLine(vecStart, vecStart+g_Engine.v_forward*4096, dont_ignore_monsters, AFArgs.User.edict(), tr);
						vecOrigin = tr.vecEndPos;
					}
				}
				
				if(asParse[i] == "angles")
				{
					if(asParse[i+1] == "self")
					{
						dKeyvalues[asParse[i]] = string(AFArgs.User.pev.angles.x)+" "+string(AFArgs.User.pev.angles.y)+" "+string(AFArgs.User.pev.angles.z);
					}else if(asParse[i+1] == "self180")
					{
						dKeyvalues[asParse[i]] = string(AFArgs.User.pev.angles.x)+" "+string(AFArgs.User.pev.angles.y+180)+" "+string(AFArgs.User.pev.angles.z);
					}else{
						dKeyvalues[asParse[i]] = string(asParse[i+1]);
					}
				}else{
					dKeyvalues[asParse[i]] = string(asParse[i+1]);
				}
			}
		}
		
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity(AFArgs.GetString(0), dKeyvalues, false);
		if(pEntity is null)
		{
			af2entity.Tell("Can't create: entity was null!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		if(!bOriginDefined)
			g_EntityFuncs.DispatchKeyValue(pEntity.edict(), "origin", string(vecOrigin.x)+" "+string(vecOrigin.y)+" "+string(vecOrigin.z));
		
		g_EntityFuncs.DispatchSpawn(pEntity.edict());
		af2entity.Tell("Entity created!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void rotateabsolute(AFBaseArguments@ AFArgs)
	{
		string sTarget = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		Vector vecRotation = Vector(AFArgs.GetFloat(0), AFArgs.GetFloat(1), AFArgs.GetFloat(2));
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity is null)
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't rotate: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			Vector vecOrigin = pEntity.IsBSPModel() ? getBrushOrigin(pEntity) : pEntity.pev.origin;
			pEntity.pev.angles = vecRotation;
			pEntity.pev.v_angle = vecRotation;
			pEntity.SetOrigin(vecOrigin); // attempt to fix brushes with no originbrush
			g_EntityFuncs.SetOrigin(pEntity, vecOrigin); // is there a difference between these two? docs say other one is just set origin other one is absolute origin
			af2entity.Tell("Set entity rotation (angle x:"+string(vecRotation.x)+" y:"+string(vecRotation.y)+" z:"+string(vecRotation.z)+")!", AFArgs.User, HUD_PRINTCONSOLE);
		}else{
			int iC = 0;
			CBaseEntity@ pEntity = null;
			while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, sTarget)) !is null)
			{
				Vector vecOrigin = pEntity.IsBSPModel() ? getBrushOrigin(pEntity) : pEntity.pev.origin;
				pEntity.pev.angles = vecRotation;
				pEntity.pev.v_angle = vecRotation;
				pEntity.SetOrigin(vecOrigin); // attempt to fix brushes with no originbrush
				g_EntityFuncs.SetOrigin(pEntity, vecOrigin); // is there a difference between these two? docs say other one is just set origin other one is absolute origin
				af2entity.Tell("Set entity rotation (angle x:"+string(vecRotation.x)+" y:"+string(vecRotation.y)+" z:"+string(vecRotation.z)+")!", AFArgs.User, HUD_PRINTCONSOLE);
				iC++;
			}
			
			if(iC > 0)
				af2entity.Tell(string(iC)+" entities rotated", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}

	void rotate(AFBaseArguments@ AFArgs)
	{
		string sTarget = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		Vector vecRotation = Vector(AFArgs.GetFloat(0), AFArgs.GetFloat(1), AFArgs.GetFloat(2));
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity is null)
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't rotate: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			Vector vecOrigin = pEntity.IsBSPModel() ? getBrushOrigin(pEntity) : pEntity.pev.origin;
			Vector vecAngles = pEntity.pev.angles;
			Vector vecOldAngles = pEntity.pev.angles;
			vecAngles = vecAngles+vecRotation;
			pEntity.pev.angles = vecAngles;
			pEntity.pev.v_angle = vecAngles;
			pEntity.SetOrigin(vecOrigin); // attempt to fix brushes with no originbrush
			g_EntityFuncs.SetOrigin(pEntity, vecOrigin); // is there a difference between these two? docs say other one is just set origin other one is absolute origin
			af2entity.Tell("Rotated entity (old angle x:"+string(vecOldAngles.x)+" y:"+string(vecOldAngles.y)+" z:"+string(vecOldAngles.z)+") (new angle x:"+string(vecAngles.x)+" y:"+string(vecAngles.y)+" z:"+string(vecAngles.z)+")!", AFArgs.User, HUD_PRINTCONSOLE);
		}else{
			int iC = 0;
			CBaseEntity@ pEntity = null;
			while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, sTarget)) !is null)
			{
				Vector vecOrigin = pEntity.IsBSPModel() ? getBrushOrigin(pEntity) : pEntity.pev.origin;
				Vector vecAngles = pEntity.pev.angles;
				Vector vecOldAngles = pEntity.pev.angles;
				vecAngles = vecAngles+vecRotation;
				pEntity.pev.angles = vecAngles;
				pEntity.pev.v_angle = vecAngles;
				pEntity.SetOrigin(vecOrigin); // attempt to fix brushes with no originbrush
				g_EntityFuncs.SetOrigin(pEntity, vecOrigin); // is there a difference between these two? docs say other one is just set origin other one is absolute origin
				af2entity.Tell("Rotated entity (old angle x:"+string(vecOldAngles.x)+" y:"+string(vecOldAngles.y)+" z:"+string(vecOldAngles.z)+") (new angle x:"+string(vecAngles.x)+" y:"+string(vecAngles.y)+" z:"+string(vecAngles.z)+")!", AFArgs.User, HUD_PRINTCONSOLE);
				iC++;
			}
			
			if(iC > 0)
				af2entity.Tell(string(iC)+" entities rotated", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}
	
	Vector getBrushOrigin(CBaseEntity@ pEntity)
	{
			Vector vOrigin = pEntity.pev.origin;
			Vector vMins = pEntity.pev.mins;
			Vector vMaxs = pEntity.pev.maxs;
			for(int i = 0; i < 3; i++)
				vOrigin[i] += (vMins[i]+vMaxs[i])*0.5f; //yes multiplication is faster than dividing
			
			return vOrigin;
	}

	void triggerrange(AFBaseArguments@ AFArgs)
	{
		int iC = 0;
		CBaseEntity@ pEntity = null;
		while((@pEntity = g_EntityFuncs.FindEntityInSphere(pEntity, AFArgs.User.pev.origin, AFArgs.GetFloat(1), AFArgs.GetString(0), "classname")) !is null)
		{
			pEntity.Use(AFArgs.User, AFArgs.User, USE_TOGGLE, 0);
			iC++;
		}
		
		if(iC > 0)
			af2entity.Tell(string(iC)+" entities triggered!", AFArgs.User, HUD_PRINTCONSOLE);
		else
			af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void trigger(AFBaseArguments@ AFArgs)
	{
		string sTarget = AFArgs.GetCount() >= 1 ? AFArgs.GetString(0) : "";
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity is null)
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't trigger: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			pEntity.Use(AFArgs.User, AFArgs.User, USE_TOGGLE, 0);
			af2entity.Tell("Triggered entity!", AFArgs.User, HUD_PRINTCONSOLE);
		}else{
			int iC = 0;
			CBaseEntity@ pEntity = null;
			while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, sTarget)) !is null)
			{
				pEntity.Use(AFArgs.User, AFArgs.User, USE_TOGGLE, 0);
				iC++;
			}
			
			if(iC > 0)
				af2entity.Tell(string(iC)+" entities triggered!", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}

	void kill(AFBaseArguments@ AFArgs)
	{
		string sTarget = AFArgs.GetCount() >= 1 ? AFArgs.GetString(0) : "";
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity is null)
			{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't kill: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				return;
			}
			
			g_EntityFuncs.Remove(pEntity);
			af2entity.Tell("Killed entity!", AFArgs.User, HUD_PRINTCONSOLE);
		}else{
			int iC = 0;
			CBaseEntity@ pEntity = null;
			while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, sTarget)) !is null)
			{
				g_EntityFuncs.Remove(pEntity);
				iC++;
			}
			
			if(iC > 0)
				af2entity.Tell(string(iC)+" entities killed", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}

	void keyvaluerange(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = null;
		int iC = 0;
		
		string sVal = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		string sValY = AFArgs.GetCount() >= 5 ? AFArgs.GetString(4) : "";
		string sValZ = AFArgs.GetCount() >= 6 ? AFArgs.GetString(5) : "";
		string sValout = "";
		if(sVal != "" && sValY != "" && sValZ != "")
			sValout = sVal+" "+sValY+" "+sValZ;
		else
			sValout = sVal;
			
		bool bHasE = AFBase::CheckAccess(AFArgs.User, ACCESS_E);
		while((@pEntity = g_EntityFuncs.FindEntityInSphere(pEntity, AFArgs.User.pev.origin, AFArgs.GetFloat(1), AFArgs.GetString(0), "classname")) !is null)
		{
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't set: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				continue;
			}
		
			if(sValout == "")
			{
				string sReturn = AF2LegacyCode::getKeyValue(pEntity, AFArgs.GetString(2));
				if(sReturn != "§§§§N/A")
					af2entity.Tell("Entity key is \""+sReturn+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				else
					af2entity.Tell("Unsupported key in get", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				if(AFArgs.GetString(2) == "model" || AFArgs.GetString(2) == "viewmodel" || AFArgs.GetString(2) == "weaponmodel" || AFArgs.GetString(2) == "modelindex")
				{
					if(!bHasE)
					{
						af2entity.Tell("Blocked: you require access flag E to do this action (\"highrisk\" key).", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
				}
				
				string sValHold = sValout;
				if(sValHold.ToLowercase() == "!null!")
					sValout = "";
				
				af2entity.Tell("Set entity key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				g_EntityFuncs.DispatchKeyValue(pEntity.edict(), AFArgs.GetString(2), sValout);
			}
			iC++;
		}
		
		if(iC > 0)
			af2entity.Tell(string(iC)+" entities found", AFArgs.User, HUD_PRINTCONSOLE);
		else
			af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void keyvaluename(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = null;
		int iC = 0;
		
		string sVal = AFArgs.GetCount() >= 3 ? AFArgs.GetString(2) : "";
		string sValY = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		string sValZ = AFArgs.GetCount() >= 5 ? AFArgs.GetString(4) : "";
		string sValout = "";
		if(sVal != "" && sValY != "" && sValZ != "")
			sValout = sVal+" "+sValY+" "+sValZ;
		else
			sValout = sVal;
			
		bool bHasE = AFBase::CheckAccess(AFArgs.User, ACCESS_E);
		while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, AFArgs.GetString(0))) !is null)
		{
			if(pEntity.IsPlayer())
			{
				af2entity.Tell("Can't set: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
				continue;
			}
		
			if(sValout == "")
			{
				string sReturn = AF2LegacyCode::getKeyValue(pEntity, AFArgs.GetString(1));
				if(sReturn != "§§§§N/A")
					af2entity.Tell("Entity key is \""+sReturn+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				else
					af2entity.Tell("Unsupported key in get", AFArgs.User, HUD_PRINTCONSOLE);
			}else{
				if(AFArgs.GetString(1) == "model" || AFArgs.GetString(1) == "viewmodel" || AFArgs.GetString(1) == "weaponmodel" || AFArgs.GetString(1) == "modelindex")
				{
					if(!bHasE)
					{
						af2entity.Tell("Blocked: you require access flag E to do this action (\"highrisk\" key).", AFArgs.User, HUD_PRINTCONSOLE);
						return;
					}
				}
				
				string sValHold = sValout;
				if(sValHold.ToLowercase() == "!null!")
					sValout = "";
				
				af2entity.Tell("Set entity key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
				g_EntityFuncs.DispatchKeyValue(pEntity.edict(), AFArgs.GetString(1), sValout);
			}
			iC++;
		}
		
		if(iC > 0)
			af2entity.Tell(string(iC)+" entities found", AFArgs.User, HUD_PRINTCONSOLE);
		else
			af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
	}

	void keyvalue(AFBaseArguments@ AFArgs)
	{
		CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
		if(pEntity is null)
		{
			af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		if(pEntity.IsPlayer())
		{
			af2entity.Tell("Can't set: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
			return;
		}
		
		string sVal = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "";
		string sValY = AFArgs.GetCount() >= 3 ? AFArgs.GetString(2) : "";
		string sValZ = AFArgs.GetCount() >= 4 ? AFArgs.GetString(3) : "";
		string sValout = "";
		if(sVal != "" && sValY != "" && sValZ != "")
			sValout = sVal+" "+sValY+" "+sValZ;
		else
			sValout = sVal;
			
		bool bHasE = AFBase::CheckAccess(AFArgs.User, ACCESS_E);
		if(sValout == "")
		{
			string sReturn = AF2LegacyCode::getKeyValue(pEntity, AFArgs.GetString(0));
			if(sReturn != "§§§§N/A")
				af2entity.Tell("Entity key is \""+sReturn+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("Unsupported key in get", AFArgs.User, HUD_PRINTCONSOLE);
		}else{
			if(AFArgs.GetString(0) == "model" || AFArgs.GetString(0) == "viewmodel" || AFArgs.GetString(0) == "weaponmodel" || AFArgs.GetString(0) == "modelindex")
			{
				if(!bHasE)
				{
					af2entity.Tell("Blocked: you require access flag E to do this action (\"highrisk\" key).", AFArgs.User, HUD_PRINTCONSOLE);
					return;
				}
			}
			
			string sValHold = sValout;
			if(sValHold.ToLowercase() == "!null!")
				sValout = "";
			
			af2entity.Tell("Set entity key to \""+sValout+"\"", AFArgs.User, HUD_PRINTCONSOLE);
			g_EntityFuncs.DispatchKeyValue(pEntity.edict(), AFArgs.GetString(0), sValout);
		}
	}

	void damage(AFBaseArguments@ AFArgs)
	{
		float fDamage = AFArgs.GetCount() >= 1 ? AFArgs.GetFloat(0) : 5000.0f;
		string sTarget = AFArgs.GetCount() >= 2 ? AFArgs.GetString(1) : "";
		if(sTarget == "")
		{
			CBaseEntity@ pEntity = g_Utility.FindEntityForward(AFArgs.User, 4096);
			if(pEntity !is null)
			{
				if(pEntity.IsPlayer())
				{
					af2entity.Tell("Can't damage: target is player!", AFArgs.User, HUD_PRINTCONSOLE);
					return;
				}
				pEntity.TakeDamage(AFArgs.User.pev, AFArgs.User.pev, fDamage, DMG_BLAST);
			
			}else{
				af2entity.Tell("No entity in front (4096 units)!", AFArgs.User, HUD_PRINTCONSOLE);
			}
		}else{
			int iC = 0;
			CBaseEntity@ eSearch = null;
			while((@eSearch = g_EntityFuncs.FindEntityByTargetname(eSearch, sTarget)) !is null)
			{
				eSearch.TakeDamage(AFArgs.User.pev, AFArgs.User.pev, fDamage, DMG_BLAST);
				iC++;
			}
			
			if(iC > 0)
				af2entity.Tell("Damaged "+string(iC)+" entities", AFArgs.User, HUD_PRINTCONSOLE);
			else
				af2entity.Tell("No entity with that name!", AFArgs.User, HUD_PRINTCONSOLE);
		}
	}
}