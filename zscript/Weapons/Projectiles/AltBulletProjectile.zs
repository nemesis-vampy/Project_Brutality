class PB_ProjectileAlt : PB_Projectile abstract
{
    transient F3DFloor PBBlocking3DCeiling, PBBlocking3DFloor;
    //[inkoalawetrust]: The stock FastProjectile code. We have to basically reimplement the whole think to make it support bouncing projectiles again.
	override void FastProjectileTick()
	{
		ClearInterpolation();
		double oldz = pos.Z;

		if (!bNOTIMEFREEZE && isFrozen())
			return;

		// [RH] Ripping is a little different than it was in Hexen
		FCheckPosition tm;
		tm.DoRipping = bRipper;

		int count = 8;
		if (radius > 0)
		{
			while (abs(Vel.X) >= radius * count || abs(Vel.Y) >= radius * count)
			{
				// we need to take smaller steps.
				count += count;
			}
		}

		if (height > 0)
		{
			while (abs(Vel.Z) >= height * count)
			{
				count += count;
			}
		}

		// Handle movement
		bool ismoved = Vel != (0, 0, 0)
			// Check Z position set during previous tick.
			// It should be strictly equal to the argument of SetZ() function.
			|| (   (pos.Z != floorz           ) /* Did it hit the floor?   */
				&& (pos.Z != ceilingz - Height) /* Did it hit the ceiling? */ );

		if (ismoved)
		{
			// force some lateral movement so that collision detection works as intended.
			if (bMissile && Vel.X == 0 && Vel.Y == 0 && !IsZeroDamage())
			{
				VelFromAngle(MinVel);
			}
			
			distanceTraveled = Level.Vec3Diff( pos, startPos ).Length();

			Vector3 frac = Vel / count;
			int changexy = frac.X != 0 || frac.Y != 0;
			int ripcount = count / 8;
			for (int i = 0; i < count; i++)
			{
				if (changexy)
				{
					if (--ripcount <= 0)
					{
						tm.ClearLastRipped();	// [RH] Do rip damage each step, like Hexen
					}

					if( bRANGED && distanceTraveled > destroyRange )
					{
						self.Destroy();
						return;
					}
					
					if (!TryMove (Pos.XY + frac.XY, true, false, tm))
					{ // Blocked move
						if (!bSkyExplode)
						{
							let l = tm.ceilingline;
							if (l &&
								l.backsector &&
								l.backsector.GetTexture(sector.ceiling) == skyflatnum)
							{
								let posr = PosRelative(l.backsector);
								if (pos.Z >= l.backsector.ceilingplane.ZatPoint(posr.XY))
								{
									// Hack to prevent missiles exploding against the sky.
									// Does not handle sky floors.
									Destroy ();
									return;
								}
							}
							// [RH] Don't explode on horizon lines.
							if (BlockingLine != NULL && BlockingLine.special == Line_Horizon)
							{
								Destroy ();
								return;
							}
							
							// [inkoalawetrust] Bounce off of blocking lines and actors.
							// https://sourcegraph.com/github.com/ZDoom/gzdoom/-/blob/src/playsim/p_mobj.cpp?L2105-2132
							If (BlockingMobj) //Hit actor.
							{
								If (bBounceOnActors)
								{
									If (!BounceActor (BlockingMobj,False))
									{
										ExplodeMissile (Null, BlockingMobj);
										OnExplode (FindExplosionType(BlockingMobj));
									}
									Return;
								}
							}
							Else //Hit wall.
							{
								If (BounceWall())
								{
									PlayBounceSound (False);
									Return;
								}
							}
							
							If (BlockingMobj && ReflectOffActor(BlockingMobj)) //Handle reflection too.
								Return;
						}
						
						//Wall Penetration
						if(BlockingMobj == NULL && BlockingLine != NULL)
						{
							if(PenetrateWall(frac)) return;
						}
							
						ExplodeMissile (BlockingLine, BlockingMobj);
						OnExplode (FindExplosionType(BlockingMobj));
						return;
					}
				}
				AddZ(frac.Z);
				UpdateWaterLevel ();
				oldz = pos.Z;
				if (oldz <= floorz)
				{ // Hit the floor

					if (floorpic == skyflatnum && !bSkyExplode)
					{
						// [RH] Just remove the missile without exploding it
						//		if this is a sky floor.
						Destroy ();
						return;
					}
					
					SetZ(floorz);
					
					// [inkoalawetrust] Floor plane bounce handling.
					// https://sourcegraph.com/github.com/ZDoom/gzdoom@cfe30c1d477e5cc8339226ebbb37f37b5bd2f019/-/blob/src/playsim/p_mobj.cpp?L2442-2463
					CheckFor3DFloorHit(FloorZ,True);
					
					If (bBounceOnFloors)
					{
						BouncePlane (FloorSector.FloorPlane);
						Return;
					}

					double dontcare;
					[dontcare, BlockingFloor, PBBlocking3DFloor] = floorsector.NextLowestFloorAt(pos.x, pos.y, floorz);
					
					HitFloor ();
                    Destructible.ProjectileHitPlane(self, SECPART_Floor);
					
					if(PenetrateWall(frac)) return;
					
					ExplodeMissile (NULL, NULL);
					OnExplode (EType_Geometry);
					return;
				}
				if (pos.Z + height > ceilingz)
				{ // Hit the ceiling

					if (ceilingpic == skyflatnum && !bSkyExplode)
					{
						Destroy ();
						return;
					}
					
					SetZ(ceilingz - Height);
					
					// [inkoalawetrust] Ceiling plane bounce handling.
					// https://sourcegraph.com/github.com/ZDoom/gzdoom@cfe30c1d477e5cc8339226ebbb37f37b5bd2f019/-/blob/src/playsim/p_mobj.cpp?L2553-2572
					CheckFor3DCeilingHit(CeilingZ,True);
					
					If (bBounceOnCeilings)
					{
						BouncePlane (CeilingSector.CeilingPlane);
						Return;
					}
					
					double dontcare;
					[dontcare, BlockingCeiling, PBBlocking3DCeiling] = ceilingsector.NextHighestCeilingAt(pos.x, pos.y, pos.z, ceilingz);
                    Destructible.ProjectileHitPlane(self, SECPART_Ceiling);
					
					if(PenetrateWall(frac)) return;
					
					ExplodeMissile (NULL, NULL);
					OnExplode (EType_Geometry);
					return;
				}
				CheckPortalTransition();
				if (changexy && ripcount <= 0) 
				{
					ripcount = count >> 3;

					// call the 'Effect' method.
					Effect();
				}
			}
		}
		if (!CheckNoDelay())
			return;		// freed itself
		// Advance the state
		if (tics != -1)
		{
			if (tics > 0) tics--;
			while (!tics)
			{
				if (!SetState (CurState.NextState))
				{ // mobj was removed
					return;
				}
			}
		}
	}


}