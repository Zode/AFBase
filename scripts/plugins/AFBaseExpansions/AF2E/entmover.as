namespace AF2Entity
{
	enum entmover_e
	{
		MOVER_IDLE = 0,
		MOVER_FIDGET,
		MOVER_ALTFIREON,
		MOVER_ALTFIRE,
		MOVER_ALTFIREOFF,
		MOVER_FIRE1,
		MOVER_FIRE2,
		MOVER_FIRE3,
		MOVER_FIRE4,
		MOVER_DRAW,
		MOVER_HOLSTER
		
	}

	class weapon_entmover : ScriptBasePlayerWeaponEntity
	{
		private CBasePlayer@ m_pPlayer = null;

		void Spawn()
		{
			self.Precache();
			g_EntityFuncs.SetModel(self, self.GetW_Model("models/not_precached.mdl"));
			//self.m_iClip			= -1;
			self.FallInit();
		}
		
		void Precache()
		{
			self.PrecacheCustomModels();
			g_Game.PrecacheModel("models/not_precached.mdl");
			g_Game.PrecacheModel("models/zode/v_entmover.mdl");
			g_Game.PrecacheModel("models/zode/p_entmover.mdl");
			g_Game.PrecacheModel("sprites/zbeam4.spr");
			g_Game.PrecacheModel("sprites/zode/border.spr");
			g_Game.PrecacheModel("sprites/zerogxplode.spr");
			g_SoundSystem.PrecacheSound("tfc/items/inv3.wav");
		}
		
		bool GetItemInfo(ItemInfo& out info)
		{
			info.iMaxAmmo1		= -1;
			info.iMaxAmmo2		= -1;
			info.iMaxClip		= WEAPON_NOCLIP;
			info.iSlot			= 9;
			info.iPosition		= 6;
			info.iFlags 		= ITEM_FLAG_ESSENTIAL|ITEM_FLAG_NOAUTOSWITCHEMPTY|ITEM_FLAG_SELECTONEMPTY;
			info.iWeight		= 666;
			return true;
		}
		
		bool AddToPlayer(CBasePlayer@ pPlayer)
		{
			@m_pPlayer = pPlayer;
			self.m_bExclusiveHold = true;
		
			return BaseClass.AddToPlayer(pPlayer);
		}
		
		bool Deploy()
		{
			return self.DefaultDeploy(self.GetV_Model("models/zode/v_entmover.mdl"), self.GetP_Model("models/zode/p_entmover.mdl"), MOVER_DRAW, "onehanded");
		}
		
		void Holster(int skip = 0)
		{
			BaseClass.Holster(skip);
		}
		
		CBasePlayerItem@ DropItem()
		{
			return null;
		}
		
		void WeaponIdle()
		{
			if(self.m_flTimeWeaponIdle > g_Engine.time) return;
		
			int anim;
			switch(Math.RandomLong(0,1))
			{
				case 0:
					anim = MOVER_IDLE;
					self.m_flTimeWeaponIdle = g_Engine.time+2.03f;
					break;
				case 1:
					anim = MOVER_FIDGET;
					self.m_flTimeWeaponIdle = g_Engine.time+2.7f;
					break;
			}
			
			self.SendWeaponAnim(anim, 0, 0);
		}
		
		void PrimaryAttack()
		{
			if(self.m_flNextPrimaryAttack > g_Engine.time) return;
			self.SendWeaponAnim(MOVER_FIRE1, 0, 0);
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
			self.m_flTimeWeaponIdle = g_Engine.time+0.1;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		}
		
		void SecondaryAttack()
		{
			if(self.m_flNextSecondaryAttack > g_Engine.time) return;
			self.SendWeaponAnim(MOVER_ALTFIREOFF, 0, 0);
			self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
			self.m_flTimeWeaponIdle = g_Engine.time+0.1;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		}
		
		void Reload()
		{
		
		}
	}
}