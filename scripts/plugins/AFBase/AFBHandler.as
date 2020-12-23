namespace AFBase
{
	funcdef void AFBaseCommandCallback(AFBaseArguments@);
	
	class AFBaseCommand
	{
		private string sName = "";
		private string sENameID = "";
		private string sDescription = "";
		private string sReqArgs = "";
		private int iAccess = 0;
		private AFBaseCommandCallback@ cCallback;
		private CClientCommand@ c_cClientCom;
		private CConCommand@ c_cConCom;
		private int iFlags = 0;
		
		int Flags
		{
			get const
			{
				return iFlags;
			}
			set
			{
				iFlags = value;
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
		
		CConCommand@ ConsoleCommand
		{
			get
			{
				return c_cConCom;
			}
			set
			{
				@c_cConCom = value;
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
	
	class VisualCommand
	{
		int iCmdAccess;
		int iFlags;
		string sENameID;
		string sVisual;
		string sCmd;
		
		VisualCommand(int iAcc, int iFl, string sName, string sVis)
		{
			iCmdAccess = iAcc;
			iFlags = iFl;
			sENameID = sName;
			sVisual = sVis;
			sCmd = sVisual.Split(" ")[0];
		}
		
		int opCmp(VisualCommand@ vCom)
		{
			return sVisual.opCmp(vCom.sVisual);
		}
	}
	
	bool InsertCommand(string sENameID, string sName, string sReqArgs, string sDescription, int iAccess, AFBaseCommandCallback@ callback, int iFlags)
	{
		sName = sName.ToLowercase();
		AFBaseCommand command;
		
		@command.CallBack = callback;
		command.AccessFlags = iAccess;
		command.Description = sDescription;
		command.ReqArguments = sReqArgs;
		command.ExpansionNameID = sENameID;
		command.Name = sName;
		command.Flags = iFlags;

		if(sName.SubString(0, 4) == "say ")
		{
			if(iFlags & CMD_SERVER != 0 || iFlags & CMD_SERVERONLY != 0)
			{
				BaseLog("Can't register command \""+sName+"\": attempting to register say command to server console!");
				return false;
			}
		
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
			VisualCommand visCom(iAccess, 0, sENameID, sName+" "+sDescription);
			//g_afbVisualCommandList.insertLast(string(iAccess)+"§!%§"+sENameID+"§!%§"+sName+" "+sDescription);
			g_afbVisualCommandList.insertLast(visCom);
		}else{
			if(iFlags & CMD_SERVERONLY == 0)
			{
				@command.ClientCommand = CClientCommand(sName, "", @HandleClientConsole);
			}
			if(iFlags & CMD_SERVERONLY != 0 || iFlags & CMD_SERVER != 0)
			{
				@command.ConsoleCommand = CConCommand(g_afServerPrefix+sName, "", @HandleClientConsole);
			}
			array<string> sHold = g_afbConCommandList.getKeys();
			if(sHold.find(sName) > -1)
			{
				BaseLog("Can't register command \""+sName+"\": command already exists!");
				return false;
			}
			
			g_afbConCommandList[sName] = command;
			VisualCommand visCom(iAccess, iFlags, sENameID, sName+" "+sDescription);
			//g_afbVisualCommandList.insertLast(string(iAccess)+"§!%§"+sENameID+"§!%§."+sName+" "+sDescription);
			g_afbVisualCommandList.insertLast(visCom);
		}
		
		
		return true;
	}
	
	bool OldInsertCommand(string sENameID, string sName, string sReqArgs, string sDescription, int iAccess, AFBaseCommandCallback@ callback, bool bPrecacheGuard, bool bSupressChat)
	{
		int flags = 0;
		if(bPrecacheGuard)
			flags |= CMD_PRECACHE;
		if(bSupressChat)
			flags |= CMD_SUPRESS;
		BaseLog("Obsolete RegisterCommand arguments in \""+sENameID+"\"->\""+sName+"\": void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, callback, bool bRequiresPrecache, bool bHideChat)");
		BaseLog("  Consider using: void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, callback, int iFlags)");
		return InsertCommand(sENameID, sName, sReqArgs, sDescription, iAccess, callback, flags);
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
			
		if(parsedCommand[0].SubString(0, 2) == "s_")
			parsedCommand[0] = parsedCommand[0].SubString(2, parsedCommand[0].Length()-2);
		
		CBasePlayer@ pUser = g_ConCommandSystem.GetCurrentPlayer();
		HandleCommandExecution(pUser, parsedCommand, HUD_PRINTCONSOLE, CLIENTSAY_SAY, true);
	}
	
	bool HandleCommandExecution(CBasePlayer@ pUser, array<string> parsedCommand, HUD targetPrint, ClientSayType cSayType, bool bConsole)
	{
		bool bServer = pUser is null ? true : false;
		AFBaseCommand@ command;
		string sLowerCommand = parsedCommand[0];
		sLowerCommand = sLowerCommand.ToLowercase();
		if(bConsole)
			@command = cast<AFBaseCommand@>(g_afbConCommandList[sLowerCommand]);
		else
			@command = cast<AFBaseCommand@>(g_afbChatCommandList[sLowerCommand]);
		if(command is null)
		{
			BaseLog("Command execution failed: callback null!");
			BaseLog("Caller: "+ (bServer?"Server":string(pUser.pev.netname)));
			BaseLog("Contents: ");
			for(uint i = 0; i < parsedCommand.length(); i++)
			{
				BaseLog(string(i)+" -> "+parsedCommand[i]);
			}
			return false;
		}
		
		if(!bServer)
		{
			if(!CheckAccess(pUser, command.AccessFlags))
			{
				BaseTell("You do not have access to this command!", pUser, targetPrint);
				return command.Flags & CMD_SUPRESS != 0 ? true : false;
			}
		}
		
		AFBaseClass@ AFBClass = cast<AFBaseClass@>(g_afbExpansionList[command.ExpansionNameID]);
		if(!AFBClass.Running)
		{
			BaseTell("Expansion stopped: can't execute command.", pUser, targetPrint);
			return command.Flags & CMD_SUPRESS != 0 ? true : false;
		}
		
		if(command.Flags & CMD_PRECACHE != 0 && !g_afbIsSafePlugin)
		{
			BaseTell("Command blocked, requires precaching first! Please wait for a map change.", pUser, targetPrint);
			return command.Flags & CMD_SUPRESS != 0 ? true : false;
		}
		
		AFBaseArguments afbArguments;
		@afbArguments.User = !bServer ? pUser : null;
		afbArguments.SayType = cSayType;
		afbArguments.IsChat = !bConsole;
		afbArguments.IsServer = bServer;
		if(bServer)
			afbArguments.FixedNick = "Server";
		else
			afbArguments.FixedNick = string(pUser.pev.netname);
		
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
				
			return command.Flags & CMD_SUPRESS != 0 ? true : false;
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
		return command.Flags & CMD_SUPRESS != 0 ? true : false;
	}
}