class ScrnF extends Object
abstract;

var const private string pad;

// Left-pads string to a given length with "with" or spaces.
// Makes use of native functions as much as possible for better perfomance (unless TWI screwed up C++ code too)
// Max padding is limited to 80 characters (len(pad))
static function string LPad(coerce string src, int to_len, optional string with)
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

static function string RPad(coerce string src, int to_len, optional string with)
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

static function bool StartsWith(string str, string part)
{
    return left(str, len(part)) ~= part;
}

static function bool EndsWith(string str, string part)
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

// returns a % b.
// The native operator % is defined only for float (wtf?), which doesn't ensure precission.
// Use mod(a, b) only if the precission is a must-have. Otherwise, use the native operator, which performs faster.
static function int Mod(int a, int b)
{
    return a - a / b * b;
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
static function bool TestHitboxSphere(vector HitLoc, vector Ray, vector SphereLoc, float SphereRadius)
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

defaultproperties
{
    pad="                                                                                "
}
