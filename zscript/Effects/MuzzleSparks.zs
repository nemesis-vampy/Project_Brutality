class PB_MuzzleSpark : PB_LightActor
{
    Default {
        Scale 0.1;
        Gravity 0.3;
        Renderstyle "AddShaded";
        +NOTELEPORT;
        +NOBLOCKMAP;
        +BLOODLESSIMPACT;
        +FORCEXYBILLBOARD;
        +NOTIMEFREEZE;
    }

    override void PostBeginPlay()
    {
        scale *= frandom(0.9, 1.0);
        Super.PostBeginPlay(); // does this matter? i believe PostBeginPlay is empty by default
    }

    States
    {
        Spawn:
            SPKO SSS 1 BRIGHT NoDelay {
                A_FaceMovementDirection();

                vel.z -= gravity;
            }
            TNT1 A 0 A_Jump(8, "FlyAround");
            Stop;
        FlyAround:
            SPKO S 1 BRIGHT NoDelay {
                scale *= 0.99;
                A_FadeOut(0.1);
                A_FaceMovementDirection();

                vel.z -= gravity;
            }
            Loop;
    }
}