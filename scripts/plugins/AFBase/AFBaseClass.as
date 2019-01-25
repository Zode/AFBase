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
	
	void MapActivate() {} // user define
	
	void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, AFBase::AFBaseCommandCallback@ callback, bool bPrecacheGuard, bool bSupressChat = false) final
	{
		bool bInserted = AFBase::OldInsertCommand(this.ShortName, sCommand, sReqArgs, sDescription, iAccess, callback, bPrecacheGuard, bSupressChat);
		if(!bInserted)
		{
			this.Running = false;
			this.Log("Stopped: command register failed!");
		}
	}
	
	void RegisterCommand(string sCommand, string sReqArgs, string sDescription, int iAccess, AFBase::AFBaseCommandCallback@ callback, int iFlags = 0) final
	{
		bool bInserted = AFBase::InsertCommand(this.ShortName, sCommand, sReqArgs, sDescription, iAccess, callback, iFlags);
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
			
		MessageData msgData(this.ShortName, sReceiver, sIdentifier, dData);
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
		if(pUser is null)
		{
			TellServer(sMsg);
			return;
		}
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrint(pUser, hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
	}
	
	void TellServer(string sMsg)
	{
		g_EngineFuncs.ServerPrint("["+this.ShortName+"] "+sMsg+"\n");
	}
	
	void TellAll(string sMsg, HUD hudTarget) final
	{
		TellServer(sMsg);
		if(hudTarget == HUD_PRINTTALK)
			g_PlayerFuncs.ClientPrintAll(hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
		else
			g_PlayerFuncs.ClientPrintAll(hudTarget, "["+this.ShortName+"] "+sMsg+"\n");
	}
	
	void TellLong(string sMsg, CBasePlayer@ pUser, HUD targetHud)
	{
		if(pUser is null)
		{
			TellLongServer(sMsg);
			return;
		}
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
	
	void TellLongServer(string sMsg)
	{
		string sHoldIn = "["+this.ShortName+"] "+sMsg+"\n";
		
		while(sHoldIn.Length() > 128)
		{
			g_EngineFuncs.ServerPrint(sHoldIn.SubString(0, 128));
			sHoldIn = sHoldIn.SubString(127, sHoldIn.Length()-127);
		}
		
		if(sHoldIn.Length() > 0)
			g_EngineFuncs.ServerPrint(sHoldIn);
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
	private bool c_bServer;
	private string c_sFixedNick;
	
	string FixedNick
	{
		get const
		{
			return c_sFixedNick;
		}
		set
		{
			c_sFixedNick = c_bLock ? c_sFixedNick : value;
		}
	}
	
	bool IsServer
	{
		get const
		{
			return c_bServer;
		}
		set
		{
			c_bServer = c_bLock ? c_bServer : value;
		}
	}
	
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
	
	MessageData(string sSend, string sRec, string sIdent, dictionary dDat)
	{
		sSender = sSend;
		sReceiver = sRec;
		sIdentifier = sIdent;
		dData = dDat;
	}
}

namespace AFBase
{
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