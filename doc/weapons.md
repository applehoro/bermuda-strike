# Weapon classes

## WeaponBase - basic weapon functionality.

Update: actually, all weapon functionality, probably should be renamed to just Weapon.
Update 2: actually, just one base class, and separate inherited scripts for all the weapons

Trigger functions for main and alt. attack:
- Auto
- Semi-auto
- Burst
- Charge
- Hold

Special functions for alt. attack:
- Zoom
- Target lock

Attack types for main and alt. attacks:
- Spawn projectile
- Raycast
- Area
- Block
- Custom

# Weapons

## 1. Katana

Basic meelee weapon.
About 3 different attack animations, alt. attack blocks enemy meelee attacks.

Attack: auto, area.
Alt. attack: hold, block.
Starting weapon.

## 2. SMG

Basic projectile weapon.
Quite low damage output and quite slow projectile speed.
Alt. attack shoot quick burst of 3 projectiles.

Attack: auto, projectile (bullet).
Alt. attack: burst (3), projectile (bullet).
Magazine capacity: 30.
Max ammo: 200.
Starting weapon.

## 3. Flak gun

Primary attack shoot a bunch or projectiles, like a shotgun. Secondary attack shoot one single projectile that, when hit something or nearby enemy, shoot bunch of short-distance projectiles in all directions.

Attack: semi-auto, projectile (8 pellets).
Alt. attack: semi-auto, projectile (flak), uses 4 ammo.
Magazine capacity: 8.
Max ammo: 80.

## 4. Machine gun

Shoot long-distance projectile with quite a high rate.

Attack: auto, projectile (bullet).
Alt. attack: none.
Magazine capacity: 200.
Max ammo: 400.

## 5. Rocket launcher

Shoot rockets.

Attack: semi-auto, projectile (rocket).
Alt. attack: target lock.
Magazine capacity: 1.
Max ammo: 30.

## 6. Grenade launcher

Shoot grenades

Attack: semi-auto, projectile (grenade).
Alt. attack: none.
Magazine capacity: 1.
Max ammo: 50.

## 7. Sniper rifle

Shoot raycast with high damage, alt. attack zooms in and out.

Attack: semi-auto, raycast.
Alt. attack: zoom.
Magazine capacity: 5.
Max ammo: 50.

## 8. Plasmagun

Shoot plasma particles with quite a low speed, but high damage.

Attack: auto, projectile (plasma).
Alt. attack: semi-auto, (8 plasma).
Magazine capacity: 50.
Max ammo: 300.

## 9. BFG-35F "Island Defender"

Charged weapon, shoot big projectile with low speed that attack nearby enemies when passed by, and also expodes at certain range or when hit something, shooting a lot of little projectiles in all directions. Also, along with it, shoot a lot of little short-life projectiles in quite a big spread.

Attack: charge, projectile (bfg_ball (spawns a lot of little projectiles when spawned) .
Alt. attack: none.
Magazine capacity: 4.
Max ammo: 20.

## 10. Atomic option

Shoot atomic rocket, like in Shadow Warrior. HUGE explosion radius and HUGE damage. Bosses, probable, need atomic_resistance value to be implemented, so that boss fights can't be easily cheesed.

Attack: semi-auto, projectile (atomic_rocket).
Alt. attack: target lock.
Magazine capacity: 1.
Max ammo: 1.