# Weapon classes

## WeaponBase - basic weapon functionality.

Update: actually, all weapon functionality, probably should be renamed to just Weapon.
Update 2: actually, just one base class, and separate inherited scripts for all the weapons

Trigger functions for main and alt. attack:
- Auto
- Semi-auto
- Charge
- Discharge

Special functions for alt. attack:
- Zoom
- Target lock
- Block

Attack types for main and alt. attacks:
- Spawn projectile
- Raycast
- Area



# Ammo types

## 9mm
Max amount: 200.

## .223
Max amount: 400.

## .50
Max amount: 40.

## Flak
Max amount: 80.

## Explosives
Max amount: 50.

## Cells
Max amount: 500.

## Atomic
Max amount: 1.



# Weapons

## 1. Meelee

### Knife
Basic meelee weapon.
Starting weapon.

### Katana
More damage and reach than knife.
Alt. attack blocks enemy meelee attacks.

### Axe
More damage that katana, but slower attack.
Alt. attack throws axe.

### Whip
Longest reach, push back enemies.



## 2. SMG

### Junk SMG
Quite low damage output and quite slow projectile speed.
Alt. attack shoot quick burst of 3 projectiles.
Magazine capacity: 30 9mm.
Starting weapon.

### Standard SMG
A little more damage.
Fast firing speed.
Alt. attack shoot burst of 5 projectiles.
Magazine capacity: 50 9mm.

### Blaster
Higher damage, but lower range.
Alt. attack shoots burst of 4 projectiles.
Magazine capacity: 50 cells.



## 3. Flak

### Flak gun
Primary attack shoot 8 projectiles, like a shotgun.
Alt. attack shoot one single projectile that, when hit something or nearby enemy, shoot bunch of short-distance projectiles in all directions, uses 4 ammo.
Magazine capacity: 8.

### New flak gun
Same thing as flak gun, except shoot 16 projectiles instead of 8.

### 2x barrel flak
Same thing as flak gun, but shoots 32 projectiles instead of 8, and alt. attack shoots 2 projectiles instead of 1.
Magazine capacity: 16.



## 4. Machine gun

### Machine gun
Shoot long-distance projectile with quite a high rate.
Magazine capacity: 200.

### Vulkan
Even more fire rate.
Magazine capacity: 300.

### Rapid laser
Shoots laser beams with quite a high rate.
Alt. attack locks on target.
Magazine capacity: 80.

### Ripper
Fastest of them all.
Magazine capacity: 400.



## 5. Rocket launcher

### Rocket launcher
Shoot rockets.
Alt. attack: target lock.
Magazine capacity: 1.

### 4x barrel rocket launcher
Alt. attack: lock-on.
Magazine capacity: 4.

### New rocket launcher
Automatic.
Alt. attack: lock-on.
Magazine capacity: 6.

### Howitzer
Shoots big rocket with huge explosion.
Alt. attack: zoom in.
Magazine capacity: 1.



## 6. Grenade launcher

### Grenade launcher
Shoot grenades
Magazine capacity: 1.

### New grenade launcher
Magazine capacity: 6.
Alt. fire discharge.

### Napalm launcher
Shoots napalm bombs.
Automatic.
Alt. fire discharge.
Magazine capacity: 10.



## 7. Sniper rifle

### Lever action rifle
Shoot raycast with high damage, alt. attack zooms in and out.
Magazine capacity: 11.

### Sniper rifle
Shoot raycast with even higher damage, alt. attack zooms in and out, more zoom than lever action.
Magazine capacity: 5.

### Railgun
Shoots powerful raycast with most damage, alt. attack zooms in and out.
Magazine capacity: 16.



## 8. Plasmagun

### Plasmagun
Shoot plasma particles with quite a low speed, but high damage.
Alt. attack: shoots 8 plasma at once, uses 4 cells.
Magazine capacity: 50.

### Flamethrower
Shoost flame.
Alt. attack: shoot napalm bomb.
Magazine capacity: 20.

### Freezer
Freezes enemies (just like name suggests :3)
Alt. attack: shoots 6 shards of ice.
Magazine capacity: 30.

### Lightning gun
Shoots lightning.
Alt. attacks shoots chain lightning.
Magazine capacity: 100.



## 9. Big gun

### Big gun
Charged weapon, shoot big projectile with low speed that attack nearby enemies when passed by, and also expodes at certain range or when hit something, shooting a lot of little projectiles in all directions. Also, along with it, shoot a lot of little short-life projectiles in quite a big spread.
Alt. attack: none.
Magazine capacity: 40, attack uses 10.



## 10. Atomic

### Atomic rocket
Shoot atomic rocket, like in Shadow Warrior. HUGE explosion radius and HUGE damage. Bosses, probable, need atomic_resistance value to be implemented, so that boss fights can't be easily cheesed.
Magazine capacity: 1.

### Orbital strike
Player points at location and satellite shoots giant energy beam with huge radius there.
Magazine capacity: 1.