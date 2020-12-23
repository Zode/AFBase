namespace AFBase
{
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
		bool bUnsafe = false;
		if(pUser is null)
		{
			BaseLog("Player SteamID check failed: User entity is null! Returning empty");
			return "";
		}
		
		if(!pUser.IsConnected())
		{
			bUnsafe = true;
			BaseLog("WARNING: Checking against disconnected player!");
		}
		AFBaseUser@ afbUser = GetUser(pUser);
		if(afbUser is null)
		{
			BaseLog("User cache missing. Getting ID from engine..");
			string steamID = g_EngineFuncs.GetPlayerAuthId(pUser.edict());
			if(steamID == "")
				for(int i = 0; i < 8; i++) // lowered search amount
				{
					steamID = g_EngineFuncs.GetPlayerAuthId(pUser.edict());
					if(steamID != "")
						break;
				}
				
			if(bUnsafe && steamID == "")
			{
				BaseLog("Player SteamID check failed: User cache missing & user is not connected, returning empty");
				return "";
			}

			if(steamID == "STEAM_ID_LAN" or steamID == "BOT")
				steamID = pUser.pev.netname;
				
			return steamID;
		}else{
			return afbUser.sSteam;
		}
	}

	float rxytoval(string input)
	{
		string inputb = input;
		if(inputb.SubString(0, 2) == "r#") // rechecking input
			inputb = input.SubString(2, input.Length()-2);
			
		array<string> inputc = inputb.Split("#");
		
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
		}
		else if(sFilterInput == "@admins" && iFlags & TARGETS_NOALL == 0)
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
		}
		else if(sFilterInput == "@noadmins" && iFlags & TARGETS_NOALL == 0)
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
		}
		else if(sFilterInput == "@dead" && iFlags & TARGETS_NODEAD == 0 && iFlags & TARGETS_NOALL == 0)
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
		}
		else if(sFilterInput == "@alive" && iFlags & TARGETS_NOALIVE == 0 && iFlags & TARGETS_NOALL == 0)
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
		}
		else if(sFilterInput == "@aim" && iFlags & TARGETS_NOAIM == 0)
		{
			if(pSelf is null)
			{
				BaseTell("Can't use @aim as server!", pSelf, hudTarget);
				return false;
			}
			
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
		}
		else if(sFilterInput == "@random" && iFlags & TARGETS_NORANDOM == 0)
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
			
			if(pTemporary.length() > 0 && pSelf !is null)
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
		}
		else if(sFilterInput == "@last" && iFlags & TARGETS_NOLAST == 0)
		{
			if(pSelf is null)
			{
				BaseTell("Can't use @last as server!", pSelf, hudTarget);
				return false;
			}
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
		}
		else if(sFilterInput == "@me" && iFlags & TARGETS_NOME == 0)
		{
			if(pSelf is null)
			{
				BaseTell("Can't use @me as server!", pSelf, hudTarget);
				return false;
			}
			
			aCBPHold.insertLast(pSelf);
		
			if(aCBPHold.length() > 0)
			{
				pTargets = aCBPHold;
				return true;
			}
			
			BaseTell("Something went horribly wrong, if you see this message it probably means you dont exist.", pSelf, hudTarget);
			return false;
		}
		else if(sFilterInput.SubString(0,6) == "steam_")
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
			
			if(pHold !is null && pSelf !is null)
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
		}
		else if(iFlags & TARGETS_NONICK == 0)
		{
			CBasePlayer@ pSearch = null;
			CBasePlayer@ pHold = null;
			AFBaseUser afbUser;
			int iMatchMode = 0;
			string sNick = sFilterInput;
			if(sNick.SubString(sNick.Length()-1,1) == "*")
			{
				iMatchMode |= 1;
				sNick = sNick.SubString(0,sNick.Length()-1);
			}
			if(sNick.SubString(0, 1) == "*")
			{
				iMatchMode |= 2;
				sNick = sNick.SubString(1,sNick.Length()-1);
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
						if(iMatchMode == 0)
						{
							if(sNick == string(pSearch.pev.netname).ToLowercase())
							{
								aCBPHold.insertLast(pSearch);
								@pHold = pSearch;
							}
						}else{
							string sHold = string(pSearch.pev.netname).ToLowercase();
							//quick & dirty backsearch
							if(iMatchMode & 2 == 0 && iMatchMode & 1 != 0)
							{
								if(sNick == sHold.SubString(0,sNick.Length()))
								{
									aCBPHold.insertLast(pSearch);
									@pHold = pSearch;
								}
							}
							
							//quick & dirty frontsearch
							if(iMatchMode & 1 == 0 && iMatchMode & 2 != 0)
							{
								if(sNick == sHold.SubString(sHold.Length()-sNick.Length(),sNick.Length()))
								{
									aCBPHold.insertLast(pSearch);
									@pHold = pSearch;
								}
							}
							
							//back/front search
							if(iMatchMode & 1 != 0 && iMatchMode & 2 != 0)
							{
								for(uint j = 0; j < sHold.Length(); j++)
								{
									if(sHold.opIndex(j) == sNick.opIndex(0))
									{
										if(sNick == sHold.SubString(j, sNick.Length()))
										{
											aCBPHold.insertLast(pSearch);
											@pHold = pSearch;
											break;
										}
									}
								}
							}
						}
					}
				}
			}
			
			if(aCBPHold.length() >= 2)
			{
				if(hudTarget == HUD_PRINTCONSOLE)
				{
					BaseTell("Too many hits with wildcard! Found "+string(aCBPHold.length())+" matching players:", pSelf, hudTarget);
					for(uint i = 0; i < aCBPHold.length(); i++)
						BaseTell(string(i)+": "+string(aCBPHold[i].pev.netname), pSelf, hudTarget);
				}else{
					BaseTell("Too many hits with wildcard! Found "+string(aCBPHold.length())+" matching players.", pSelf, hudTarget);
				}
				
				return false;
			}
			
			if(pHold !is null && pSelf !is null)
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

	bool IsNumeric(string sIn)
	{
		bool ret = true;
		for(uint i = 0; i < sIn.Length(); i++)
		{
			if(!isdigit(sIn.opIndex(i)))
			{
				ret = false; break;
			}
		}

		return ret;
	}
	
	bool RemoveSingleItem(CBasePlayer@ pTarget, string targetWeapon)
	{
		//instantly fail if attempting to remove the afb's entmover
		if(targetWeapon == "weapon_entmover") return false;
		
		CBasePlayerItem@ pItem;
		CBasePlayerWeapon@ pWeapon;
		for(uint j = 0; j < MAX_ITEM_TYPES; j++)
		{
			@pItem = pTarget.m_rgpPlayerItems(j);
			while(pItem !is null)
			{
				@pWeapon = pItem.GetWeaponPtr();
				
				if(pWeapon.GetClassname() == targetWeapon)
				{
					pTarget.RemovePlayerItem(pItem);
					return true;
				}
				
				@pItem = cast<CBasePlayerItem@>(pItem.m_hNextItem.GetEntity());
			}
		}
		
		return false;
	}
}