class ScrnMutator extends Mutator
    abstract;

// format: MMNNPP, where M - major, N - minor, P - patch
var const int VersionNumber;
var const int MinLibVersion;
var transient KFGameType KF;


static final function int LibVersion()
{
    return 97100;
}

static final function string VersionStr(int v, optional bool bClean)
{
    return class'ScrnF'.static.VersionStr(v, bClean);
}

static final function string GetVersionStr(optional bool bClean)
{
    return VersionStr(default.VersionNumber, bClean);
}

function PostBeginPlay()
{
    KF = KFGameType(Level.Game);
    if (KF == none) {
        warn("ERROR: Wrong GameType ("$Level.Game$") - KFGameType required");
        Destroy();
        return;
    }

    if (LibVersion() < MinLibVersion) {
        warn("ERROR: Deprecated ScrnShared library! " $ self.class @ GetVersionStr()
                $ " requires lib " $ VersionStr(MinLibVersion)
                $ ". Actual lib version: " $ VersionStr(LibVersion(), true)
                $ ". Please upgrade ScrnShared.u");
        Destroy();
        return;
    }
}

function AddMutator(Mutator M)
{
    if ( M != self )
        super.AddMutator(M);
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
    local int i;

    super.GetServerDetails(ServerState);

    i = ServerState.ServerInfo.Length;
    ServerState.ServerInfo.insert(i, 1);

    ServerState.ServerInfo[i].Key = FriendlyName;
    ServerState.ServerInfo[i++].Value = GetVersionStr();
}

function Mutate(string MutateString, PlayerController Sender)
{
    if ( MutateString ~= "VERSION" ) {
        Sender.ClientMessage(default.FriendlyName @ GetVersionStr());
    }

    super.Mutate(MutateString, Sender);
}

function ServerTraveling(string URL, bool bItems)
{
    if (NextMutator != None)
        NextMutator.ServerTraveling(URL,bItems);

    class'ScrnF'.static.ResetDebug();
}

static function ScrnMutator FindScrnMutator(Mutator StartWith)
{
    local ScrnMutator SM;
    local Mutator M;

    for ( M = StartWith; M != none ; M = M.NextMutator ) {
        SM = ScrnMutator(M);
        if ( SM != none )
            return SM;
    }
    return none;
}

static function ScrnMutator FirstScrnMutator(LevelInfo Level)
{
    return FindScrnMutator(Level.Game.BaseMutator);
}

function ScrnMutator NextScrnMutator()
{
    return FindScrnMutator(NextMutator);
}

function bool IsScrnAuthority()
{
    return false;
}

// Usually - returns ScrnBalance mutator
static function ScrnMutator ScrnAuthority(LevelInfo Level)
{
    local ScrnMutator SM;

    for ( SM = FirstScrnMutator(Level); SM != none; SM = SM.NextScrnMutator() ) {
        if ( SM.IsScrnAuthority() ) {
            return SM;
        }
    }
    return none;
}

function RegisterVersion(string ItemName, int Version)
{
    local ScrnMutator Auth;

    Auth = ScrnAuthority(Level);
    if ( Auth == self ) {
        warn("ScrnAuthority must override RegisterVersion()");
        return;
    }
    if ( Auth != none ) {
        Auth.RegisterVersion(ItemName, Version);
    }
}

function RegisterPostMortem()
{
    local ScrnMutator Auth;

    if ( bDeleteMe )
        return;

    Auth = ScrnAuthority(Level);
    if ( Auth != none ) {
        Auth.RegisterVersion(FriendlyName, VersionNumber);
    }
    else {
        warn("ScrnAuthority not found");
    }
    Destroy();
}

// publishes Kay=Value for all ScrnMutators
function final static bool sPublishValue(LevelInfo Level, name Key, int Value, optional ScrnMutator Publisher)
{
    local int count;
    local ScrnMutator SM;

    for ( SM = FirstScrnMutator(Level); SM != none; SM = SM.NextScrnMutator() ) {
        if ( SM != Publisher && SM.SetCustomValue(Key, Value, Publisher) ) {
            ++count;
        }
    }
    return count > 0;
}

function final static bool sPublishFloat(LevelInfo Level, name Key, float Value, optional ScrnMutator Publisher)
{
    local int count;
    local ScrnMutator SM;

    for ( SM = FirstScrnMutator(Level); SM != none; SM = SM.NextScrnMutator() ) {
        if ( SM != Publisher && SM.SetCustomFloat(Key, Value, Publisher) ) {
            ++count;
        }
    }
    return count > 0;
}

function final static bool sPublishStr(LevelInfo Level, name Key, string Value, optional ScrnMutator Publisher)
{
    local int count;
    local ScrnMutator SM;

    for ( SM = FirstScrnMutator(Level); SM != none; SM = SM.NextScrnMutator() ) {
        if ( SM != Publisher && SM.SetCustomStr(Key, Value, Publisher) ) {
            ++count;
        }
    }
    return count > 0;
}

function bool PublishValue(name Key, int Value) { return sPublishValue(Level, Key, value, self); }
function bool PublishFloat(name Key, float Value) { return sPublishFloat(Level, Key, value, self); }
function bool PublishStr(name Key, string Value) { return sPublishStr(Level, Key, value, self); }

function bool SetCustomValue(name Key, int Value, optional ScrnMutator Publisher) { return false; }
function bool SetCustomFloat(name Key, float Value, optional ScrnMutator Publisher) { return false; }
function bool SetCustomStr(name Key, string Value, optional ScrnMutator Publisher) { return false; }


defaultproperties
{
    MinLibVersion=97100
}