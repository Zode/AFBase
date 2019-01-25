namespace AFBase
{
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
}