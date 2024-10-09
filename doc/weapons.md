# Weapon classes

WeaponBase - basic weapon functionality.
WeaponRanged - ranged weapon, either projectile or raycast.
WeaponRangedBurst - subclass of ranged weapon, alt. attack shoot quick burst.
WeaponRangedCharge - subclass of ranged weapon, uses charge mechanic for trigger logic.
WeaponRangedSniper - subclass of ranged weapon, alt. fire allows to zoom in and out.
WeaponMeelee - meelee weapon.

# Weapons

## 1. Katana

Basic meelee weapon.
About 3 different attack animations, alt. attack blocks enemy meelee attacks.

Class: WeaponMeelee.
Starting weapon.

## 2. SMG

Basic projectile weapon.
Quite low damage output and quite slow projectile speed.
Alt. attack shoot quick burst of 3 projectiles.

Class: WeaponRangedBurst.
Trigger type: Auto.
Magazine capacity: 30.
Max ammo: 200.
Starting weapon.

## 3. Flak gun

Primary attack shoot a bunch or projectiles, like a shotgun. Secondary attack shoot one single projectile that, when hit something or nearby enemy, shoot bunch of short-distance projectiles in all directions.

Class: WeaponRanged.
Trigger type: Semi-auto.
Magazine capacity: 8.
Max ammo: 80.

## 4. Machine gun

Shoot long-distance projectile with quite a high rate.

Class: WeaponRanged.
Trigger type: Auto.
Magazine capacity: 200.
Max ammo: 400.

## 5. Rocket launcher

Shoot rockets.

Class: WeaponRanged.
Trigger type: Semi-auto.
Magazine capacity: 1.
Max ammo: 30.

## 6. Grenade launcher

Shoot grenades

Class: WeaponRanged.
Trigger type: Semi-auto.
Magazine capacity: 1.
Max ammo: 50.

## 7. Sniper rifle

Shoot raycast with high damage, alt. attack zooms in and out.

Class: WeaponRangedSniper.
Trigger type: Semi-auto.
Magazine capacity: 5.
Max ammo: 50.

## 8. Plasmagun

Shoot plasma particles with quite a low speed, but high damage.

Class: WeaponRanged.
Trigger type: Auto.
Magazine capacity: 50.
Max ammo: 300.

## 9. BFG-35F "Island Defender"

Charged weapon, shoot big projectile with low speed that attack nearby enemies when passed by, and also expodes at certain range or when hit something, shooting a lot of little projectiles in all directions. Also, along with it, shoot a lot of little short-life projectiles in quite a big spread.

Class: WeaponRangedCharge.
Trigger type: Charge.
Magazine capacity: 4.
Max ammo: 20.

## 10. Atomic option

Shoot atomic rocket, like in Shadow Warrior. HUGE explosion radius and HUGE damage. Bosses, probable, need atomic_resistance value to be implemented, so that boss fights can't be easily cheesed.

Class: WeaponRanged.
Trigger type: Semi-auto.
Magazine capacity: 1.
Max ammo: 1.