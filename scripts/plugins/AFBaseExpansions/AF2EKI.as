ElevatorInfo elevatorinfo;

void ElevatorInfo_Call()
{
	elevatorinfo.RegisterExpansion(elevatorinfo);
}

class ElevatorInfo : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery2 Elevator Kill Info";
		this.ShortName = "AF2EKI";
	}
	
	void ExpansionInit()
	{
		g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @ElevatorInfo::ClientKilled);
	}
}

namespace ElevatorInfo
{ // c+p from AF2
	HookReturnCode ClientKilled(CBasePlayer@ pPlayer, CBaseEntity@ pThing, int iNum)
	{
		if(!elevatorinfo.Running)
			return HOOK_CONTINUE; // skip if plugin "paused"
	
		Vector vecPos = pPlayer.pev.origin+Vector(0,2,0);
		g_EngineFuncs.MakeVectors(Vector(0,0,0));
		Vector vecAimUp = g_Engine.v_up;
		TraceResult tr;
		g_Utility.TraceLine(vecPos, vecPos-vecAimUp*256, ignore_monsters, pPlayer.edict(), tr);
		CBaseEntity@ pHitEnt = g_EntityFuncs.Instance(tr.pHit);
		if(pHitEnt !is null)
		{
			if(pHitEnt.pev.classname == "func_door" || pHitEnt.pev.classname == "func_plat" || pHitEnt.pev.classname == "func_train" || pHitEnt.pev.classname == "func_tracktrain")
			{
				TraceResult tr2;
				g_Utility.TraceLine(vecPos, vecPos+vecAimUp*256, dont_ignore_monsters, pPlayer.edict(), tr2);
				CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr2.pHit);
				if(pEntity !is null)
				{
					if(pEntity.IsPlayer())
					{
						CBasePlayer@ pSearchVictim;
						for(int i = 1; i <= g_Engine.maxClients; i++)
						{
							@pSearchVictim = g_PlayerFuncs.FindPlayerByIndex(i);
							if(pSearchVictim !is null)
								if(AFBase::CheckAccess(pSearchVictim, ACCESS_G))
									elevatorinfo.Tell("[Trace+Trace] Detected player \""+pEntity.pev.netname+"\" gibbing player \""+pPlayer.pev.netname+"\" on an elevator of some sort!", pSearchVictim, HUD_PRINTTALK);
						}
						return HOOK_CONTINUE;
					}
				}
				
				g_Utility.TraceHull(vecPos, vecPos+vecAimUp*256, dont_ignore_monsters, human_hull, pPlayer.edict(), tr2);
				@pEntity = g_EntityFuncs.Instance(tr2.pHit);
				if(pEntity !is null)
				{
					if(pEntity.IsPlayer())
					{
						CBasePlayer@ pSearchVictim;
						for(int i = 1; i <= g_Engine.maxClients; i++)
						{
							@pSearchVictim = g_PlayerFuncs.FindPlayerByIndex(i);
							if(pSearchVictim !is null)
								if(AFBase::CheckAccess(pSearchVictim, ACCESS_G))
									elevatorinfo.Tell("[Trace+Hull] Detected player \""+pEntity.pev.netname+"\" gibbing player \""+pPlayer.pev.netname+"\" on an elevator of some sort!", pSearchVictim, HUD_PRINTTALK);
						}
						return HOOK_CONTINUE;
					}
				}
			}
		}
		
		g_Utility.TraceHull(vecPos, vecPos-vecAimUp*256, ignore_monsters, human_hull, pPlayer.edict(), tr);
		@pHitEnt = g_EntityFuncs.Instance(tr.pHit);
		if(pHitEnt !is null)
		{
			if(pHitEnt.pev.classname == "func_door" || pHitEnt.pev.classname == "func_plat" || pHitEnt.pev.classname == "func_train" || pHitEnt.pev.classname == "func_tracktrain")
			{
				TraceResult tr2;
				g_Utility.TraceLine(vecPos, vecPos+vecAimUp*256, dont_ignore_monsters, pPlayer.edict(), tr2);
				CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr2.pHit);
				if(pEntity !is null)
				{
					if(pEntity.IsPlayer())
					{
						CBasePlayer@ pSearchVictim;
						for(int i = 1; i <= g_Engine.maxClients; i++)
						{
							@pSearchVictim = g_PlayerFuncs.FindPlayerByIndex(i);
							if(pSearchVictim !is null)
								if(AFBase::CheckAccess(pSearchVictim, ACCESS_G))
									elevatorinfo.Tell("[Hull+Trace] Detected player \""+pEntity.pev.netname+"\" gibbing player \""+pPlayer.pev.netname+"\" on an elevator of some sort!", pSearchVictim, HUD_PRINTTALK);
						}
						return HOOK_CONTINUE;
					}
				}
				
				g_Utility.TraceHull(vecPos, vecPos+vecAimUp*256, dont_ignore_monsters, human_hull, pPlayer.edict(), tr2);
				@pEntity = g_EntityFuncs.Instance(tr2.pHit);
				if(pEntity !is null)
				{
					if(pEntity.IsPlayer())
					{
						CBasePlayer@ pSearchVictim;
						for(int i = 1; i <= g_Engine.maxClients; i++)
						{
							@pSearchVictim = g_PlayerFuncs.FindPlayerByIndex(i);
							if(pSearchVictim !is null)
								if(AFBase::CheckAccess(pSearchVictim, ACCESS_G))
									elevatorinfo.Tell("[Hull+Hull] Detected player \""+pEntity.pev.netname+"\" gibbing player \""+pPlayer.pev.netname+"\" on an elevator of some sort!", pSearchVictim, HUD_PRINTTALK);
						}
						return HOOK_CONTINUE;
					}
				}
			}
		}
		
		return HOOK_CONTINUE;
	}
}