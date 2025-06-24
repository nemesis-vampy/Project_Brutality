#include "zscript/Effects/BulletImpacts.zs"

// [gng] partially based on beautiful doom's smoke
// https://github.com/jekyllgrim/Beautiful-Doom/blob/96fcd0cec039eca762a8b206e522e8111a62ad95/Z_BDoom/bd_main.zc#L932
class PB_GunFireSmoke: PB_LightActor
{
    Default {
        Alpha 0.198;
        YScale 0.22;
        XScale 0.264;
        +NOBLOCKMAP;
        +NOTELEPORT;
        +DONTSPLASH;
        //+MISSILE;
        +FORCEXYBILLBOARD;
        //+CLIENTSIDEONLY;
        +NOINTERACTION;
        +NOGRAVITY;
        +THRUACTORS;
        +ROLLSPRITE;
        +ROLLCENTER;
        +NOCLIP;
        +NOTIMEFREEZE;
        FloatBobPhase 0;
        -RANDOMIZE;
    }

    double dissipateRotation;
    vector3 posOfs;

    double blowSpeed, fadeSpeed;

    override void BeginPlay()
    {
        ChangeStatNum(STAT_PB_SMOKE);
        Super.BeginPlay();

        blowSpeed = 1.02;
        fadeSpeed = 1.0;
	    /*alpha *= CVar.GetCVar("pb_smokeopacity", players[consoleplayer]).GetFloat();
        alpha = clamp(alpha, 0, 1);*/
    }

    override void PostBeginPlay()
    {
        dissipateRotation = frandom[muzzlesmoke](0.7, 1.4) * randompick[muzzlesmoke](-1, 1);
        bXFLIP = randompick[muzzlesmoke](0, 1);
        bYFLIP = randompick[muzzlesmoke](0, 1);
		scale *= 0.25;

		fadeSpeed *= 0.66;
    }
    
    virtual void SmokeTick()
    {    	
        int age = GetAge();
        if(age < 5 && age > 1) 
        {
            A_Fadeout(0.05 * fadeSpeed, FTF_CLAMP|FTF_REMOVE);
            scale *= blowSpeed;
            vel *= 0.85;
            roll += dissipateRotation;
            dissipateRotation *= 0.96;
            
            if(CeilingPic == SkyFlatNum) {
                vel.y += 0.03; // wind
                vel.x -= 0.02;
            }
        }
        else
        {
            scale *= 1.01;
            vel *= 0.7;
            roll += dissipateRotation;
            dissipateRotation *= 0.95;
            
            if(CeilingPic == SkyFlatNum) {
                vel.y += 0.04;
                vel.x -= 0.025;
            }
            
            vel.z += 0.07;

            /*if (alpha < 0.1)
               	A_FadeOut(alpha * (0.05 * fadeSpeed), FTF_CLAMP|FTF_REMOVE);
            else*/
                A_Fadeout(alpha * (0.1 * fadeSpeed), FTF_CLAMP|FTF_REMOVE);
        }
    }

	override void Tick()
	{
		Super.Tick();
		SmokeTick();
	}

    States 
    {
        Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Jump(256, random[muzzlesmoke](0, 5));
            XS18 JKLMNOPQRSTUVWXYZ 2;
			XS28 ABCDEFGHIJKLMNOPQRSTUVWXYZ 2;
			XS38 ABCD 2;
            Stop;
    }
}

class PB_GunFireSmoke_Var1 : PB_GunFireSmoke
{
	States 
    {
        Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Jump(256, random[muzzlesmoke](0, 7));
            XS13 ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
			XS23 ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
            Stop;
    }
}

class PB_GunFireSmoke_Var2 : PB_GunFireSmoke
{
	States 
    {
        Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Jump(256, random[muzzlesmoke](0, 3));
            XS16 CDEFGHIJKLMNO 2;
            Stop;
    }
}

class PB_GunFireSmoke_FastCloud : PB_GunFireSmoke 
{
	Default {
		Alpha 0.6;
	}

	override void PostBeginPlay()
    {
        dissipateRotation = frandom[muzzlesmoke](0.7, 1.4) * randompick[muzzlesmoke](-1, 1);
        bXFLIP = randompick[muzzlesmoke](0, 1);
		scale *= 0.25;
    }
	
	States 
    {
        Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Jump(256, random[muzzlesmoke](0, 3));
            XS15 ABCDEFGH 1;
            Stop;
    }
}

class PB_CasingEjectionSmoke : PB_GunFireSmoke
{    
    Default
    {
        XScale 0.10;
        YScale 0.10;

        -ROLLCENTER;
    }

    override void PostBeginPlay()
    {
        if(!master) 
			Destroy();

        //roll = pitch * ceil(deltaangle(angle, master.angle) / 180);
		bXFLIP = randompick[muzzlesmoke](0, 1);
		roll = pitch;

		// vel *= 0.3;
    }

	override void SmokeTick()
    {    	
		int age = GetAge();
        if(age < 5 && age > 1) 
        {
            A_Fadeout(0.05 * fadeSpeed, FTF_CLAMP|FTF_REMOVE);
            scale *= blowSpeed; 
        }
        else
        {
			vel *= 0.85;
            scale *= 1.01;
            A_Fadeout(alpha * (0.04 * fadeSpeed), FTF_CLAMP|FTF_REMOVE);
        }
	}

    States 
    {
        Spawn:
			TNT1 A 0;
			TNT1 A 0 A_Jump(256, random[muzzlesmoke](0, 5));
            XS16 ABCDEFGHIJKLNO 1;
            Stop;
    }
}

class PB_BarrelHeatSmoke: PB_GunFireSmoke
{   
	Default {
		Alpha 1.0;
        YScale 0.25;
        XScale 0.3;
	}
	
    override void SmokeTick()
    {    	
		vel.xy *= 0.9;
        int age = GetAge();
		
		vel.z += 0.04;
		
		A_Fadeout(alpha * (0.5 * fadeSpeed), FTF_CLAMP|FTF_REMOVE);
		
        if(age < 5 && age > 1) 
        {
            scale *= blowSpeed;
            roll += dissipateRotation;
            
            if(CeilingPic == SkyFlatNum) {
                vel.y += 0.2; // wind
                vel.x -= 0.1;
            }
        }
        else
        {
            scale *= 1.01;
            roll += dissipateRotation;
            
            if(CeilingPic == SkyFlatNum) {
                vel.y += 0.1; // wind
                vel.x -= 0.05;
            }
        }
    }
	
	States 
    {
        Spawn:
            XS23 ABCDEFGHIJKLMNOPQRSTUVWXYZ 1;
			XS24 ABCDEF 1;
            Loop;
    }
}

class MarineMuzzle1 : PB_LightActor
{
	Default
	{
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOCLIP;
		+FORCEXYBILLBOARD;
		+NOINTERACTION;
		RenderStyle "Add";
	}

	void SpawnSmokeActor(vector3 ofs, vector3 vofs, string SActor = "PB_GunFireSmoke", double scalemul = 1.0, double alphamul = 1.0, double blowspeed = 1.02, double fadeSpeed = 1.0, bool rollSprite = true)
	{
		PB_GunFireSmoke Smoke = PB_GunFireSmoke(Spawn(SActor, pos + RotateVector((ofs.y, ofs.x), angle)));
		
		If(Smoke)
		{
			Smoke.master = target;
			Smoke.Vel = vofs;
			Smoke.A_SetRoll(random[muzzlesmoke](0, 359));
			Smoke.scale *= scalemul;
			Smoke.alpha *= alphamul;
			Smoke.blowSpeed = blowspeed;
			Smoke.fadeSpeed = fadeSpeed;
		}
	}

	void SpawnPuffSpark()
	{
        int sparkcount = random[muzzlesmoke](3,5);
        for(int i = 0; i < sparkcount; i++)
        {
            FSpawnParticleParams PUFSPRK;
            PUFSPRK.Texture = TexMan.CheckForTexture("SPKOA0");
            PUFSPRK.Color1 = 0xFF9D2E;
            PUFSPRK.Style = STYLE_AddShaded;
            PUFSPRK.Flags = SPF_ROLL|SPF_FULLBRIGHT;
            PUFSPRK.Vel = (RotateVector((frandom[muzzlesmoke](7, 19), frandom[muzzlesmoke](-5, 5)), angle), frandom[muzzlesmoke](-5, 5));
            PUFSPRK.accel = (frandom[muzzlesmoke](-1, 1), frandom[muzzlesmoke](-1, 1), frandom[muzzlesmoke](-1, 1));
            PUFSPRK.Startroll = random[muzzlesmoke](0,359);
            PUFSPRK.RollVel = 0;
            PUFSPRK.StartAlpha = 1.0;
            PUFSPRK.FadeStep = 0.1;
            PUFSPRK.Size = random[muzzlesmoke](6,8);
            PUFSPRK.SizeStep = -0.5;
            PUFSPRK.Lifetime = 3; 
            PUFSPRK.Pos = pos;
            Level.SpawnParticle(PUFSPRK);
        }
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if(target) Angle = target.Angle;
		Scale *= frandompick[muzzlesmoke](0.5, 1.0);
	}

	States
	{
		Spawn:
			PLMZ A 2 BRIGHT NoDelay {
				SpawnPuffSpark();

				SpawnSmokeActor(
					(0, 0, 0), // offsets
					(0, 0, 0), 	  // velocites
					"PB_GunFireSmoke_Var1",		// actor
					2.2,		  // scale multiplier
					0.6,		  // alpha multiplier
					1.03		  // blow speed
				);
		
				SpawnSmokeActor(
					(0, 0, 0),
					(0, 0, 0),
					"PB_GunFireSmoke",
					0.7,
					1.0,
					1.02,
					1.2
				);
		
				SpawnSmokeActor(
					(0, 20.1, 0),
					(0, 0, 0),
					"PB_GunFireSmoke",
					1.7,
					1.0,
					1.02,
					1.2
				);
		
				SpawnSmokeActor(
					(0, 43.2, 0),
					(0, 0, 0),
					"PB_GunFireSmoke",
					2.7,
					1.0,
					1.02,
					1.2
				);
				NashGoreStatics.QueueSmoke();
			}
			Stop;
	}
}

class MarineMuzzle2 : MarineMuzzle1 { }