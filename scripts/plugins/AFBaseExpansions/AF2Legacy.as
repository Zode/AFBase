// direct copypaste from AF2 code - helper.as (modif: 24.12.2016, 03:41)

namespace AF2LegacyCode
{
	//dubbed: superstring

	string sstring(string vin)
	{
		return string(vin);
	}

	string sstring(double vin)
	{
		return string(vin);
	}

	string sstring(int vin)
	{
		return string(vin);
	}

	string sstring(uint vin)
	{
		return string(vin);
	}

	string sstring(bool vin)
	{
		return string(vin);
	}

	string sstring(char vin)
	{
		return string(vin);
	}

	string sstring(Vector vin)
	{
		string sComp = string(vin.x)+" "+string(vin.y)+" "+string(vin.z)+" ";
		return sComp;
	}

	// this was written because there is
	// no way to "get" a keyvalue exactly

	string getKeyValue(CBasePlayer@ pPlayer, string sKey)
	{
		return getKeyValue(cast<CBaseEntity@>(pPlayer), sKey);
	}

	string getKeyValue(CBaseEntity@ pEntity, string sKey)
	{
		if(sKey == "classname")
		{
			return string(pEntity.pev.classname);
		}else if(sKey == "origin")
		{
			Vector vecc = pEntity.pev.origin;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "velocity")
		{
			Vector vecc = pEntity.pev.velocity;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "movedir")
		{
			Vector vecc = pEntity.pev.movedir;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "angles")
		{
			Vector vecc = pEntity.pev.angles;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "avelocity")
		{
			Vector vecc = pEntity.pev.avelocity;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "punchangle")
		{
			Vector vecc = pEntity.pev.punchangle;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "v_angle")
		{
			Vector vecc = pEntity.pev.v_angle;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "endpos")
		{
			Vector vecc = pEntity.pev.endpos;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "startpos")
		{
			Vector vecc = pEntity.pev.startpos;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "modelindex")
		{
			return string(pEntity.pev.modelindex);
		}else if(sKey == "model")
		{
			return string(pEntity.pev.model);
		}else if(sKey == "viewmodel")
		{
			return string(pEntity.pev.viewmodel);
		}else if(sKey == "weaponmodel")
		{
			return string(pEntity.pev.weaponmodel);
		}else if(sKey == "skin")
		{
			return string(pEntity.pev.skin);
		}else if(sKey == "body")
		{
			return string(pEntity.pev.body);
		}else if(sKey == "effects")
		{
			return string(pEntity.pev.effects);
		}else if(sKey == "gravity")
		{
			return string(pEntity.pev.gravity);
		}else if(sKey == "sequence")
		{
			return string(pEntity.pev.sequence);
		}else if(sKey == "scale")
		{
			return string(pEntity.pev.scale);
		}else if(sKey == "rendermode")
		{
			return string(pEntity.pev.rendermode);
		}else if(sKey == "renderamt")
		{
			return string(pEntity.pev.renderamt);
		}else if(sKey == "rendercolor")
		{
			Vector vecc = pEntity.pev.rendercolor;
			return string(vecc.x)+" "+string(vecc.y)+" "+string(vecc.z);
		}else if(sKey == "renderfx")
		{
			return string(pEntity.pev.renderfx);
		}else if(sKey == "health")
		{
			return string(pEntity.pev.health);
		}else if(sKey == "max_health")
		{
			return string(pEntity.pev.max_health);
		}else if(sKey == "armortype")
		{
			return string(pEntity.pev.armortype);
		}else if(sKey == "armorvalue")
		{
			return string(pEntity.pev.armorvalue);
		}else if(sKey == "target")
		{
			return string(pEntity.pev.target);
		}else if(sKey == "targetname")
		{
			return string(pEntity.pev.targetname);
		}else if(sKey == "netname")
		{
			return string(pEntity.pev.netname);
		}else if(sKey == "message")
		{
			return string(pEntity.pev.message);
		}else if(sKey == "speed")
		{
			return string(pEntity.pev.speed);
		}else if(sKey == "maxspeed")
		{
			return string(pEntity.pev.maxspeed);
		}else{
			return "§§§§N/A";
		}
	}

}