// The base class for electric damage dealth by Zeds
class DamTypeBaseZombieElectric extends DamTypeZombieAttack
    abstract;

defaultproperties
{
    bCheckForHeadShots=False
    DeathString="%o accepts %k's shaft."
    FemaleSuicide="%o rode the lighting."
    MaleSuicide="%o rode the lighting."
    bLocationalHit=False
}
