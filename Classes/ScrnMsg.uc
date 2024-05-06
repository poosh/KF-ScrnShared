// Generic localized messages
class ScrnMsg extends LocalMessage
    abstract;

var const int msgSrvDisabled;
var const int msgNotAvaliableATM;
var const int msgRestartRequired;
var const int msgAdminRequired;

var const localized string strSrvDisabled;
var const localized string strNotAvaliableATM;
var const localized string strRestartRequired;
var const localized string strAdminRequired;

static function string GetString(
        optional int msgID,
        optional PlayerReplicationInfo RelatedPRI_1,
        optional PlayerReplicationInfo RelatedPRI_2,
        optional Object OptionalObject
    )
{
    local string s;

    switch (msgID) {
        case default.msgSrvDisabled: s = default.strSrvDisabled; break;
        case default.msgNotAvaliableATM: s = default.strNotAvaliableATM; break;
        case default.msgRestartRequired: s = default.strRestartRequired; break;
        case default.msgAdminRequired: s = default.strAdminRequired; break;
    }
    return class'ScrnF'.static.ParseColorTags(s);
}

defaultproperties
{
    bIsSpecial=false
    bIsConsoleMessage=true

    msgSrvDisabled=0
    msgNotAvaliableATM=1
    msgRestartRequired=2
    msgAdminRequired=3

    strSrvDisabled="Disabled on this server"
    strNotAvaliableATM="Not avaliable at this moment"
    strRestartRequired="Map restart required"
    strAdminRequired="Requires ADMIN priviledges"
}
