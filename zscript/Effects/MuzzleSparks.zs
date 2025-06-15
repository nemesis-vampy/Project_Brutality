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

    States
    {
        Spawn:
            SPKO SSS 1 BRIGHT NoDelay {
                A_FadeOut(0.1);
                A_FaceMovementDirection();

                vel.z -= gravity;
            }
            Stop;
    }
}