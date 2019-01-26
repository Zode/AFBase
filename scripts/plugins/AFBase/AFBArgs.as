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