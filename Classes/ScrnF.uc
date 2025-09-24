class ScrnF extends Object
abstract;

var const private string pad;
var private int DebugCounter;

struct SColorTag
{
    var string T;
    var byte R, G, B;
};
var array<SColorTag> ColorTags;


// ============================================================================
// STRINGS
// ============================================================================

//  Performs binary search on sorted array.
//  @param arr : array of sorted items (in ascending order). Array will not be modified.
//               out modifier is used just for performance purpose (pass by reference).
//  @param val : value to search
//  @return array index or -1, if value not found.
static final function int BinarySearch(out array<int> arr, int val)
{
    local int start, end, i;

    start = 0;
    end = arr.length;
    while ( start < end )
    {
        i = start + ((end - start)>>1);
        if ( arr[i] == val )
            return i;
        else if ( val < arr[i] )
            end = i;
        else
            start = i + 1;
    }
    return -1;
}

static final function int BinarySearchStr(out array<string> arr, string val)
{
    local int start, end, i;

    start = 0;
    end = arr.length;
    while ( start < end )
    {
        i = start + ((end - start)>>1);
        if ( arr[i] == val )
            return i;
        else if ( val < arr[i] )
            end = i;
        else
            start = i + 1;
    }
    return -1;
}

static final function int SearchStr(out array<string> arr, string val)
{
    local int i;

    if (val == "" || arr.length == 0)
        return -1;

    for (i = 0; i < arr.length; ++i) {
        if (arr[i] == val)
            return i;
    }
    return -1;
}

static final function int SearchStrIgnoreCase(out array<string> arr, string val)
{
    local int i;

    if (val == "" || arr.length == 0)
        return -1;

    for (i = 0; i < arr.length; ++i) {
        if (arr[i] ~= val)
            return i;
    }
    return -1;
}

static final function int SearchName(out array<name> arr, name val)
{
    local int i;

    if (val == '' || arr.length == 0)
        return -1;

    for (i = 0; i < arr.length; ++i) {
        if (arr[i] == val)
            return i;
    }
    return -1;
}

// fancy time formatting
static final function String FormatTime(int Seconds)
{
    local int Minutes, Hours;
    local String Time;

    if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        Time = Hours$":";
    }
    Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 || Hours == 0 )
        Time = Time $ Minutes $ ":";
    else
        Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
    else
        Time = Time $ "0" $ Seconds;

    return Time;
}

// Left-pads string to a given length with "with" or spaces.
// Makes use of native functions as much as possible for better perfomance (unless TWI screwed up C++ code too)
// Max padding is limited to 80 characters (len(pad))
static final function string LPad(coerce string src, int to_len, optional string with)
{
    local string custom_pad;
    local int pad_len;

    pad_len = to_len - len(src);
    if ( pad_len <= 0 )
        return src; // source string already has enough characters

    if ( with != "" && with != " " ) {
        custom_pad = Repl(default.pad, " ", with, true);
        return left(custom_pad, pad_len) $ src;
    }
    return left(default.pad, pad_len) $ src;
}

static final function string RPad(coerce string src, int to_len, optional string with)
{
    local string custom_pad;
    local int pad_len;

    pad_len = to_len - len(src);
    if ( pad_len <= 0 )
        return src; // source string already has enough characters

    if ( with != "" && with != " " ) {
        custom_pad = Repl(default.pad, " ", with, true);
        return src $ left(custom_pad, pad_len);
    }
    return src $ left(default.pad, pad_len);
}

static final function bool StartsWith(string str, string part)
{
    return left(str, len(part)) ~= part;
}

static final function bool EndsWith(string str, string part)
{
    return right(str, len(part)) ~= part;
}

// Converts version number in user-friendly string, e.g. 1.23 or 1.23.45
static final function string VersionStr(int v, optional bool bClean) {
    local string s;
    local int major, minor, patch;

    // for some reason, UnrealScript has operator % declared only for float not for int.
    // So we can't use % here due to precision
    if (v >= 10000) {
        major = v / 10000;  v -= major * 10000;
        minor = v / 100;    v -= minor * 100;
        patch = v;
    }
    else {
        major = v / 100;    v -= major * 100;
        minor = v;
    }

    if ( !bClean ) {
        s $= "v";
    }
    s $= major $ ".";
    if ( minor < 10 )
        s $= "0";
    s $= minor;
    if ( patch > 0) {
        s $= ".";
        if ( patch < 10 )
            s $= "0";
        s $= patch;
    }
    return s;
}

/**
  * @return true if TestStr contains all Keywords
  * @pre Keywords must not be empty
  */
static final function bool MatchKeywords(string TestStr, out array<string> Keywords) {
    local int k;

    for (k = 0; k < Keywords.Length; ++k) {
        if (InStr(TestStr, Keywords[k]) == -1) {
            return false;
        }
    }
    return true;
}

static final function bool SearchKeywords(out array<string> Items, out array<string> Keywords, out array<int> MatchIndexes) {
    local int i;

    MatchIndexes.Length = 0;
    if (Items.Length == 0 || Keywords.Length == 0)
        return false;

    for (i = 0; i < Items.Length; ++i) {
        if (MatchKeywords(items[i], Keywords)) {
            MatchIndexes[MatchIndexes.Length] = i;
        }
    }
    return MatchIndexes.Length > 0;
}

static final function bool SearchKeywordsStr(out array<string> Items, string KeywordStr, out array<int> MatchIndexes) {
    local array<string> Keywords;

    Split(KeywordStr, " ", Keywords);
    return SearchKeywords(Items, Keywords, MatchIndexes);
}

static function int WordCount(String str) {
    if (str == "") return 0;

    return Len(str) - Len(Repl(Repl(str, " ", "", true), "|", "", true)) + 1;
}

static function float TextReadTime(String str) {
    local int wc;

    wc = WordCount(str);
    if (wc == 0)
        return 0.0;

    return wc * 0.5 * fmax(1.0, float(Len(str)) / (4 * wc));
}


// ============================================================================
// ARRAYS
// ============================================================================

// Adds class to array. Doesn't add none or classes which already are stored in array.
static final function bool ClassAddToArrayUnique(out array<class> AArray, class AClass)
{
    if (AClass == none || ClassIsInArray(AArray, AClass))
        return false;

    AArray[AArray.length] = AClass;
    return true;
}

// returns true if an array contains a given class
static final function bool ClassIsInArray(out array<class> AArray, class AClass)
{
    local int i;

    if (AClass == none)
        return false;

    for (i = 0; i < AArray.length; ++i) {
        if (AArray[i] == AClass)
            return true;
    }
    return false;
}

//returns true if class or its parent is in a given array
static final function bool ClassChildIsInArray(out array<class> AArray, class AClass)
{
    local int i;

    if (AClass == none)
        return false;

    for (i = 0; i < AArray.length; ++i) {
        if (ClassIsChildOf(AClass, AArray[i]))
            return true;
    }
    return false;
}

//output array to the log - for debugging
static final function LogArray(out array <class> AArray)
{
    local int i;

    if (AArray.length == 0)
        Log("Array is empty!");
    else {
        Log("Array elements:");
        for (i = 0; i < AArray.length; ++i) {
            Log(String(AArray[i]));
        }
        Log("End of array");
    }
}

static final function int SearchObj(out array<Object> arr, Object val)
{
    local int i;

    if (val == none || arr.length == 0)
        return -1;

    for (i = 0; i < arr.length; ++i) {
        if (arr[i] == val)
            return i;
    }
    return -1;
}

static final function bool ObjAddUnique(out array<Object> arr, Object val)
{
    if (val == none)
        return false;

    if (SearchObj(arr, val) != -1)
        return false;

    arr[arr.length] = val;
    return true;
}

// ============================================================================
// MATH
// ============================================================================

// returns a % b.
// The native operator % is defined only for float (wtf?), which doesn't ensure precission.
// Use mod(a, b) only if the precission is a must-have. Otherwise, use the native operator, which performs faster.
static final function int Mod(int a, int b)
{
    return a - a / b * b;
}

// Returns true if float is not a real number (NaN, -INF, or +INF)
static final function bool IsNaN(float f)
{
    return !(f < 0 || f >= 0);
}

/**
 * Tests if the tracing Ray that hit the target at HitLoc hits also the given target's sphere-shaped hitbox.
 * @param HitLoc location where the tracing ray hit the target's collision cylinder
 * @param Ray normalized direction of the trace line
 * @param SphereLoc the center of the sphere (e.g., Head bone's location for headshot detection)
 * @param SphereRadius the radius of the sphere
 * @pre The function assumes that the sphere is inside the target's collision cylinder
 * @return true if the ray hits the sphere
 */
static final function bool TestHitboxSphere(vector HitLoc, vector Ray, vector SphereLoc, float SphereRadius)
{
    local vector HitToSphere;  // vector from HitLoc to SphereLoc
    local vector P;

    SphereRadius *= SphereRadius; // square it to avoid doing sqrt()

    HitToSphere = SphereLoc - HitLoc;
    if ( VSizeSquared(HitToSphere) < SphereRadius ) {
        // HitLoc is already inside the sphere - no projection needed
        return true;
    }

    // Let's project SphereLoc to Ray to get the projection point P.
    //               SphereLoc
    //              /|
    //            /  |
    //          /    |
    // HitLoc /_ _ _ |  _ _ _ _ _ _ > Ray
    //              P^
    //
    // If VSize(P - SphereLoc) < SphereRadius, the Ray hits the sphere.
    // VSize(P - SphereLoc) = sin(A) * vsize(SpereLoc - HitLoc)
    // A = acos(normal(SphereLoc - HitLoc) dot Ray)
    // The above solution is simle to understand. However, it is CPU-heavy since it uses 2 trigonometric function calls.
    // The below algorithm does the same but avoids trigonometry

    // HitToSphere dot Ray = cos(A) * VSize(HitToSphere) = VSize(P - HitLoc)
    P = HitLoc + Ray * (HitToSphere dot Ray);

    return VSizeSquared(P - SphereLoc) < SphereRadius;
}

/**
 * @brief Applies a Low-Pass Filter to the input samples, adding inertia to the system.
 * @param y [in] previous/initial result of the function
 *          [out] new result
 * @param x new sample value
 * @oaram dt time between the previous and the new sample
 * @param rc time constant - the reference measurement time.
 *  The higher rc, the more inertia (less impact of a single x on y)
 */
static function lpf(out float y, float x, float dt, float rc)
{
    local float a;

    a = dt / (rc + dt);
    y = a * x + (1 - a) * y;
}

/** Calculates the multiplier to act at real-time speed during a Zed Time.
 *  @return the action speed multiplier.
 */
static function float RealTimeFactor(LevelInfo Level)
{
    return fmax(1.1 / Level.TimeDilation, 1.0);
}


// ============================================================================
// PLAYERS & ADMINS
// ============================================================================

/**
 * @brief Checks if the player is admin rights. Solo players and listen server owners always have admin rights.
 *
 * @param Sender the player to check
 * @return true if the Sender has admin rights
 * @see CheckAdmin
 */
static final function bool IsAdmin(PlayerController Sender)
{
    return (Sender.PlayerReplicationInfo != none && Sender.PlayerReplicationInfo.bAdmin)
            || Sender.Level.NetMode == NM_Standalone
            || (Sender.Level.NetMode == NM_ListenServer && NetConnection(Sender.Player) == none);
}

/**
 * @brief Warns the player if they do no have the admin rigts.
 *
 * @param Sender the player to check
 * @return true if the player has admin rights
 * @see IsAdmin
 */
static final function bool CheckAdmin(PlayerController Sender)
{
    if (IsAdmin(Sender))
        return true;


    Sender.ReceiveLocalizedMessage(class'ScrnMsg', class'ScrnMsg'.default.msgAdminRequired);
    return false;
}

/**
 * @brief Finds the player's pawn by their PRI.
 * The function is fast on the server side or for the local player. It is relatively slow on a client side when
 * looking for other players. Moreover, not all player pawns may be replicated
 *
 * @param PRI replication info of the player to search pawn
 * @return Player pawn or none.
 */
// The function is fast on the server side or for the local player.
// It is relatively slow on a client side when looking for other players.
static final function Pawn FindPawnByPRI(PlayerReplicationInfo PRI)
{
    local Pawn P;

    if ( PRI == none )
        return none;

    // Owner is set only on server-side or bNetOwner
    if ( Controller(PRI.Owner) != none )
        return Controller(PRI.Owner).Pawn;

    foreach PRI.DynamicActors(class'Pawn', P) {
        if ( P.PlayerReplicationInfo == PRI )
            return P;
    }

    return none;
}

/**
 * @brief Fills the player controller array with alive players.
 *
 * @pre Server-side only. Never called it on the client.
 * @param Game Pass the Level property of any actor.
 * @param Players (out) Player controller list of the alive players.
 * @return Alive player count.
 * @see GetAlivePlayerCount if you need only the number.
 */
static final function int GetAlivePlayers(GameInfo Game, out array<PlayerController> Players) {
    local Controller C;
    local int i;

    // The below lines produces a NULL access warning if called client-side to indicate that
    // the function must be called server-side only.
    Players.length = Game.NumPlayers;
    for (C = Game.Level.ControllerList; C != none; C = C.nextController) {
        if (C.bIsPlayer && C.Pawn != none && C.Pawn.Health > 0) {
            Players[i] = PlayerController(C);
            if (Players[i] != none) {
                ++i;
            }
        }
    }
    Players.length = i;
    return i;
}

static final function int GetAlivePlayerCount(GameInfo Game) {
    local Controller C;
    local int i;

    for (C = Game.Level.ControllerList; C != none; C = C.nextController) {
        if (C.bIsPlayer && C.Pawn != none && C.Pawn.Health > 0 && PlayerController(C) != none) {
            ++i;
        }
    }
    return i;
}

/**
 * @brief Splits long message on short ones before sending it to client.
 *
 * @param   Sender     Player, who receives the message(-s).
 * @param   S          String to send.
 * @param   MaxLen     Max length of one string. Default: 80. If S is longer than this value,
 *                     then it will be splitted on serveral messages.
 * @param  Divider     Character to be used as divider. Default: Space. String is split
 *                     at last divder's position before MaxLen is reached.
 */
static final function LongMessage(PlayerController Sender, string S, optional int MaxLen, optional string Divider)
{
    local int pos;
    local string part;

    if ( Sender == none )
        return;
    if ( MaxLen == 0 )
        MaxLen = 80;
    if ( Divider == "" )
        Divider = " ";

    while ( len(part) + len(S) > MaxLen ) {
        pos = InStr(S, Divider);
        if ( pos == -1 )
            break; // no more dividers

        if ( part != "" && len(part) + pos + 1 > MaxLen) {
            Sender.ClientMessage(part);
            part = "";
        }
        part $= Left(S, pos + 1);
        S = Mid(S, pos+1);
    }

    part $= S;
    if ( part != "" )
        Sender.ClientMessage(part);
}

static function string PlainPlayerName(PlayerReplicationInfo PRI)
{
    if ( PRI == none )
        return "";

    return StripColorTags(PRI.PlayerName);
}

static function string ColoredPlayerName(PlayerReplicationInfo PRI)
{
    if ( PRI == none )
        return "";

    return ParseColorTags(PRI.PlayerName, PRI);
}

// ==============================================================
//                           COLORS
// ==============================================================

// parse tags and color strings
// PRI is left for backward-compatibility with ScrN Balance. It is not used in the base version.
static function string ParseColorTags(string ColoredText, optional PlayerReplicationInfo _unused_PRI)
{
    local int i;
    local string s;

    s = ColoredText;
    for (i = 0; i < default.ColorTags.Length; ++i) {
        s = Repl(s, default.ColorTags[i].T, ColorString("",
                default.ColorTags[i].R, default.ColorTags[i].G, default.ColorTags[i].B), true);
    }
    // Remove unportable legacy player color tags.
    s = Repl(s, "^p", "", true);
    s = Repl(s, "^t", "", true);
    return s;
}

// remove color tags from string
static function string StripColorTags(string ColoredText)
{
    local int i;
    local string s;

    s = ColoredText;
    for (i = 0; i < default.ColorTags.Length; ++i) {
        s = Repl(s, default.ColorTags[i].T, "", true);
    }
    s = Repl(s, "^p", "", true);
    s = Repl(s, "^t", "", true);
    return s;
}

static final function string ColorString(string s, byte R, byte G, byte B)
{
    return chr(27)$chr(max(R,1))$chr(max(G,1))$chr(max(B,1))$s;
}

static final function string ColorStringC(string s, color c)
{
    return chr(27)$chr(max(c.R,1))$chr(max(c.G,1))$chr(max(c.B,1))$s;
}

// remove color characters from string
static final function string StripColor(string s)
{
    local int p;

    p = InStr(s,chr(27));
    while ( p>=0 )
    {
        s = left(s,p)$mid(S,p+4);
        p = InStr(s,Chr(27));
    }
    return s;
}

// returns first i amount of characters excluding escape color codes
static final function string LeftCol(string ColoredString, int i)
{
    local string s;
    local int p, c;

    if ( Len(ColoredString) <= i )
        return ColoredString;

    c = i;
    s = ColoredString;
    p = InStr(s,chr(27));
    while ( p >=0 && p < i ) {
        c+=4; // add 4 more characters due to color code
        s = left(s, p) $ mid(s, p+4);
        p = InStr(s,Chr(27));
    }

    return Left(ColoredString, c);
}


// ============================================================================
// I/O
// ============================================================================
static final function byte GetNumKeyIndex(byte Key) {
    if (Key >= 0x60 && Key <= 0x69) {
        // convert IK_NumPadX to IK_X
        Key -= 0x30;
    }
    if (Key >= 0x30 && Key <= 0x39) {
        // IK_0 .. IK_9
        if (Key == 0x30)
            return 9;
        return Key - 0x31;
    }
    return 255;
}

// ============================================================================
// DEBUG
// ============================================================================
static function PlayerController GetDebugPlayerController(Actor DebugObj)
{
    local Controller C;
    local PlayerController PC;
    local Pawn P;

    if (DebugObj == none)
        return none;

    if (DebugObj.Level.NetMode != NM_DedicatedServer) {
        return DebugObj.Level.GetLocalPlayerController();
    }

    if (DebugObj.Level.Game.NumPlayers == 1) {
        for (C = DebugObj.Level.ControllerList; C != none; C = C.nextController) {
            if (C.bIsPlayer) {
                PC = PlayerController(C);
                if (PC != none) {
                    return PC;
                }
            }
        }
    }

    PC = PlayerController(DebugObj);
    if (PC != none)
        return PC;

    P = Pawn(DebugObj);
    if (P != none) {
        PC = PlayerController(P.Controller);
        if (PC != none)
            return PC;
        return none;
    }

    // when debugging weapons, projectiles, etc.
    if (DebugObj.Instigator != none) {
        PC = PlayerController(DebugObj.Instigator.Controller);
        if (PC != none)
            return PC;
    }
}

static function dbg(Actor DebugObj, coerce string S)
{
    local PlayerController PC;

    if (!IsDebugEnabled())
        return;

    PC = GetDebugPlayerController(DebugObj);
    if (DebugObj.Level.NetMode == NM_DedicatedServer || PC == none) {
        // log on server side
        log(S);
    }
    if (PC != none) {
        // display and log on client side
        PC.ClientMessage(S, 'log');
    }
}

static function EnableDebug()
{
    default.DebugCounter++;
}

static function DisableDebug()
{
    default.DebugCounter--;
}

static function bool IsDebugEnabled()
{
    return default.DebugCounter > 0;
}

static function ResetDebug()
{
    default.DebugCounter = 0;
}


defaultproperties
{
    pad="                                                                                "

    ColorTags(00)=(T="^0",R=1,G=1,B=1)
    ColorTags(01)=(T="^1",R=200,G=1,B=1)
    ColorTags(02)=(T="^2",R=1,G=200,B=1)
    ColorTags(03)=(T="^3",R=200,G=200,B=1)
    ColorTags(04)=(T="^4",R=1,G=1,B=255)
    ColorTags(05)=(T="^5",R=1,G=255,B=255)
    ColorTags(06)=(T="^6",R=200,G=1,B=200)
    ColorTags(07)=(T="^7",R=200,G=200,B=200)
    ColorTags(08)=(T="^8",R=255,G=127,B=0)
    ColorTags(09)=(T="^9",R=128,G=128,B=128)

    ColorTags(10)=(T="^w$",R=255,G=255,B=255)
    ColorTags(11)=(T="^r$",R=255,G=1,B=1)
    ColorTags(12)=(T="^g$",R=1,G=255,B=1)
    ColorTags(13)=(T="^b$",R=1,G=1,B=255)
    ColorTags(14)=(T="^y$",R=255,G=255,B=1)
    ColorTags(15)=(T="^c$",R=1,G=255,B=255)
    ColorTags(16)=(T="^o$",R=255,G=140,B=1)
    ColorTags(17)=(T="^u$",R=255,G=20,B=147)
    ColorTags(18)=(T="^s$",R=1,G=192,B=255)
    ColorTags(19)=(T="^n$",R=139,G=69,B=19)

    ColorTags(20)=(T="^W$",R=112,G=138,B=144)
    ColorTags(21)=(T="^R$",R=132,G=1,B=1)
    ColorTags(22)=(T="^G$",R=1,G=132,B=1)
    ColorTags(23)=(T="^B$",R=1,G=1,B=132)
    ColorTags(24)=(T="^Y$",R=192,G=192,B=1)
    ColorTags(25)=(T="^C$",R=1,G=160,B=192)
    ColorTags(26)=(T="^O$",R=255,G=69,B=1)
    ColorTags(27)=(T="^U$",R=160,G=32,B=240)
    ColorTags(28)=(T="^S$",R=65,G=105,B=225)
    ColorTags(29)=(T="^N$",R=80,G=40,B=20)
}
