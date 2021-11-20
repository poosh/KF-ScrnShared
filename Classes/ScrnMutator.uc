class ScrnMutator extends Mutator
    abstract;

// format: MMNNPP, where M - major, N - minor, P - patch
var const int VersionNumber;
var transient KFGameType KF;


static final function int LibVersion()
{
    return 96801;
}

static final function string VersionStr(int v, optional bool bClean)
{
    return class'ScrnF'.static.VersionStr(v, bClean);
}

static final function string GetVersionStr(optional bool bClean)
{
    return VersionStr(default.VersionNumber, bClean);
}

// returns true of the mutator has the same version as the given version, patch excluding
final function bool SameVersionAs(int v)
{
    return VersionNumber / 100 == v / 100;
}

function bool CheckVersion()
{
    return SameVersionAs(LibVersion());
}

function PostBeginPlay()
{
    KF = KFGameType(Level.Game);
    if (KF == none) {
        warn("ERROR: Wrong GameType ("$Level.Game$") - KFGameType required");
        Destroy();
        return;
    }

    if (!CheckVersion()) {
        warn("ScrN Version Mismatch: " $ self.class @ GetVersionStr() $ " <> lib " $ VersionStr(LibVersion()));
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
