// The base class for freezing damage dealt by players
class DamTypeBaseFreeze extends KFWeaponDamageType
    abstract;

var float   FreezeRatio; // percent of damage used for freezing effect

// Freeze over Time
var int     FoT_Duration;   // for how long zed will freeze after receiving this damage
var float   FoT_Ratio;      // freeze per second in percent of damage received

var float   ShatteringDamageMult; // damage multiplier to already frozen zeds
