class PB_MuzzleSpark : PB_LightActor
{
    Default {
        Scale 0.05;
        //Gravity 0.3;
        Renderstyle "AddShaded";
        +NOTELEPORT;
        +NOBLOCKMAP;
        +BLOODLESSIMPACT;
        +FORCEXYBILLBOARD;
    }

    States
    {
        Spawn:
            SPKO S 2 BRIGHT NoDelay {
                A_FadeOut(0.25);
                A_FaceMovementDirection();
            }
            Stop;
    }
}