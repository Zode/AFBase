AF2Menu af2menu;

void AF2Menu_Call()
{
	af2menu.RegisterExpansion(af2menu);
}

class AF2Menu : AFBaseClass
{
	void ExpansionInfo()
	{
		this.AuthorName = "Zode";
		this.ExpansionName = "AdminFuckery2 Menu System";
		this.ShortName = "AF2MS";
	}
	
	void ExpansionInit()
	{
		RegisterCommand("afb_menu", "", "- pop open a simple command menu", ACCESS_H, @AF2Menu::popmenu, true);
		AF2Menu::initializeMenus();
	}
	
	void MapInit()
	{
		AF2Menu::initializeMenus();
	}
	
	void ClientConnectEvent(CBasePlayer@ pPlayer)
	{
		AF2Menu::menuremove(pPlayer.entindex());
	}
	
	void ClientDisconnectEvent(CBasePlayer@ pPlayer)
	{
		AF2Menu::menuremove(pPlayer.entindex());
	}
	
	void ReceiveMessageEvent(string sSender, string sIdentifier, dictionary dData)
	{
		if(sIdentifier == "RegisterMenuCommand")
		{
			array<string> keys = dData.getKeys();
			for(uint i = 0; i < keys.length(); i++)
			{
				if(AF2Menu::g_commands.exists(keys[i]))
				{
					af2menu.Log("skipping menu command register for \""+keys[i]+"\": already exists!");
					continue;
				}
				
				AF2Menu::g_commands[keys[i]] = dData[keys[i]];
			}
		}
	}
}

namespace AF2Menu
{
	class PlayerMenu
	{
		CTextMenu@ cMenu;
		int iState;
		string sTarget;
	}
	
	dictionary g_playerMenus;
	dictionary g_commands;
	const int iMenuTime = 10;
	
	void menuCallback(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem)
	{
		if(mItem !is null && pPlayer !is null)
		{
			PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[pPlayer.entindex()]);
			if(plrMenu.iState == 1)
			{
				string temp = "";
				if(!mItem.m_pUserData.retrieve(temp))
				{
					af2menu.Tell("Failed to retrieve menu data!", pPlayer, HUD_PRINTTALK);
					return;
				}
				
				plrMenu.sTarget = temp;
				
				g_Scheduler.SetTimeout("delayedCallback", 0.1f, EHandle(pPlayer));
				return;
			}else if(plrMenu.iState == 2)
			{
				plrMenu.iState = 3;
				executemenucommand(mItem, pPlayer);
				g_Scheduler.SetTimeout("menuremove", 0.1f, pPlayer.entindex());
				return;
			}
			
			af2menu.Tell("Unknown menu state!", pPlayer, HUD_PRINTTALK);
		}
	}
	
	void delayedCallback(EHandle ePlayer)
	{
		CBaseEntity@ pEnt = ePlayer;
		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEnt);
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[pPlayer.entindex()]);
		if(plrMenu.iState == 1)
		{
			menupartialremove(pPlayer.entindex());
			makeCommandMenu(pPlayer.entindex());
			plrMenu.cMenu.Open(iMenuTime,0,pPlayer);
		}
	}
	
	void executemenucommand(const CTextMenuItem@ mItem, CBasePlayer@ pPlayer)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[pPlayer.entindex()]);
		if(plrMenu.sTarget != "nonexistantuser")
		{
			
			string sMenuCom = "";
			if(!mItem.m_pUserData.retrieve(sMenuCom))
			{
				af2menu.Tell("Failed to retrieve menu data!", pPlayer, HUD_PRINTTALK);
				return;
			}
			
			executeconsole(pPlayer, sMenuCom, plrMenu.sTarget);
			//af2menu.Tell("Executing \""+sMenuCom+"\" against \""+plrMenu.sTarget+"\"", pPlayer, HUD_PRINTTALK);
			
			return;
		}
		
		af2menu.Tell("Illegal target!", pPlayer, HUD_PRINTTALK);
	}
	
	void executeconsole(CBasePlayer@ pPlayer, string sCommand, string sTarget)
	{
		NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::NetworkMessageType(9), pPlayer.edict());
			message.WriteString(sCommand+" \""+sTarget+"\"");
		message.End();
	}
	
	void makeCommandMenu(int i)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[i]);
		@plrMenu.cMenu = CTextMenu(AF2Menu::menuCallback);
		plrMenu.cMenu.SetTitle("\\r[AFB]\\w Select command:");
		//plrMenu.cMenu.AddItem("give ammo", any(".player_giveammo"));
		array<string> keys = g_commands.getKeys();
		AFBase::VisualCommand@ visCom;
		AFBase::AFBaseUser@ afbUser = AFBase::GetUser(cast<CBasePlayer@>(g_EntityFuncs.Instance(g_EntityFuncs.IndexEnt(i))));
		for(uint k = 0; k < AFBase::g_afbVisualCommandList.length(); k++)
		{
			@visCom = cast<AFBase::VisualCommand@>(AFBase::g_afbVisualCommandList[k]);
			for(uint j = 0; j < keys.length(); j++)
			{
				if(keys[j] == "."+visCom.sCmd)
					if(afbUser.iAccess & visCom.iCmdAccess == visCom.iCmdAccess)
						plrMenu.cMenu.AddItem(string(g_commands[keys[j]]), any(keys[j]));
			}
		}
		plrMenu.cMenu.Register();
		plrMenu.iState = 2;
	}
	
	void makePlayerMenu(int i)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[i]);
		@plrMenu.cMenu = CTextMenu(AF2Menu::menuCallback);
		plrMenu.cMenu.SetTitle("\\r[AFB]\\w Select target: \\w");
		plrMenu.cMenu.AddItem("\\r@all\\w", any("@all"));
		plrMenu.cMenu.AddItem("\\r@me\\w", any("@me"));
		plrMenu.cMenu.AddItem("\\r@last\\w", any("@last"));
		CBasePlayer@ pSearch = null;
		for(int j = 1; j <= g_Engine.maxClients; j++)
		{
			@pSearch = g_PlayerFuncs.FindPlayerByIndex(j);
			if(pSearch !is null)
				plrMenu.cMenu.AddItem(pSearch.pev.netname, any(AFBase::FormatSafe(AFBase::GetFixedSteamID(pSearch))));
		}
		plrMenu.cMenu.Register();
		plrMenu.iState = 1;
	}
	
	void initializeMenus()
	{
		g_commands.deleteAll();
		if(g_playerMenus.getSize() <= 0)
		{
			PlayerMenu plrMenu;
			@plrMenu.cMenu = null;
			plrMenu.iState = 0;
			plrMenu.sTarget = "nonexistantuser";
			for(int i = 1; i <= g_Engine.maxClients; i++)
				g_playerMenus[i] = plrMenu;
		}else{
			for(int i = 1; i <= g_Engine.maxClients; i++)
				menuremove(i);
		}
	}
	
	void menupartialremove(int i)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[i]);
		if(@plrMenu.cMenu !is null)
			plrMenu.cMenu.Unregister();

		@plrMenu.cMenu = null;
	}
	
	void menuremove(int i)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[i]);
		if(@plrMenu.cMenu !is null)
			plrMenu.cMenu.Unregister();

		@plrMenu.cMenu = null;
		plrMenu.iState = 0;
		plrMenu.sTarget = "nonexistantuser";
	}
	
	void popmenu(AFBaseArguments@ AFArgs)
	{
		PlayerMenu@ plrMenu = cast<PlayerMenu@>(g_playerMenus[AFArgs.User.entindex()]);
		if(plrMenu.iState != 3)
		{
			menuremove(AFArgs.User.entindex());
			makePlayerMenu(AFArgs.User.entindex());	
			plrMenu.cMenu.Open(iMenuTime,0,AFArgs.User);
		}
	}
}