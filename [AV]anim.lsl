// [AV]anim - Play extra animations on poses for AVsitter2
// By Typhaine Artez
//
// Version 1.2 - March 2021
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/

// stride list of animations per sitter and pose
// format: {sitter#},{pose name},{animations list - separated with a ;}
list anims;

// stride list of animations played by default on each seat
// format: {sitter#},{animation list - separated with a ;}
list defaults;

// stride list of animation played on each seat
// format: {sitter#},{animation list - separated with a ;}
list playing;

// notecard handling
string NC = "AVanim";
integer ncline;
key ncquery;
integer ncsitter;

readNotecard(key id, string data) {
    if (NULL_KEY != id && ncquery != id) return;
    if (NULL_KEY == id) {
        // first call
        anims = [];
        ncquery = NULL_KEY;
        ncline = 0;
        ncsitter = 0;
    }
    else {
        integer i;
        if (EOF == data) {
            // inform all is loaded
            integer count = llGetListLength(anims);
            llOwnerSay(llGetScriptName()+" "+(string)(count/3)+" Poses for extra animations loaded");
            // update ncquery with the notecard key for future changes
            ncquery = llGetInventoryKey("AVanim");
            ncline = 0;
            return;
        }
        if (llSubStringIndex(data, "#") && "" != data) {
            if (!llSubStringIndex(data, "SITTER ")) {
                // SITTER #
                ncsitter = (integer)llGetSubString(data, 7, -1);
            }
            else if (!llSubStringIndex(data, "DEFAULT ")) {
                // DEFAULT #|anims;list;semicolon;separated
                integer sitter = (integer)llGetSubString(data, 8, -1);
                i = llSubStringIndex(data, "|");
                if (~i) defaults += [ sitter, llGetSubString(data, i+1, -1) ];
            }
            else {
                // assume pose: {pose name}|anims;list;semicolon;separated
                i = llSubStringIndex(data, "|");
                if (~i) anims += [ ncsitter, llGetSubString(data, 0, i-1), llGetSubString(data, i+1, -1) ];
            }
        }            
    }
    ncquery = llGetNotecardLine(NC, ncline++);
}

list animsForSeat(integer sitter, string pose) {
    list lst;
    integer i;

    if ("" == pose) {
        // check default animations
        i = llListFindList(defaults, [sitter]);
        if (~i) lst = llParseString2List(llList2String(defaults, i+1), [";"], []);
    }
    else if (EOF == pose) {
        // check played animations
        i = llListFindList(playing, [sitter]);
        if (~i) lst = llParseString2List(llList2String(playing, i+1), [";"], []);
    }
    else {
        i = llListFindList(anims, [sitter, pose]);
        if (~i) lst = llParseString2List(llList2String(anims, i+2), [";"], []);
    }
    return lst;
}

stopAnimations(integer sitter) {
    integer i = llListFindList(playing, [sitter]);
    if (~i) {
        list played = llParseString2List(llList2String(playing, i+1), [";"], []);
        integer c = llGetListLength(played);
        while (~(--c)) llStopAnimation(llList2String(played, c));
        playing = llDeleteSubList(playing, i, i+1);
    }
}

startAnimations(integer sitter, list lst) {
    integer i = llGetListLength(lst);
    while (~(--i)) llStartAnimation(llList2String(lst, i));
    playing += [sitter, llDumpList2String(lst, ";")];
}

default {
    state_entry() {
        // read the AVanim notecard
        if (INVENTORY_NOTECARD == llGetInventoryType(NC)) {
            readNotecard(NULL_KEY, "");
        }
    }
    changed(integer c) {
        if (CHANGED_OWNER & c) llResetScript();
        if (CHANGED_INVENTORY & c) {
            // if not already loading the notecard, read it
            if (!ncline && ncquery != llGetInventoryKey(NC)) readNotecard(NULL_KEY, "");
        }
    }
    dataserver(key id, string data) {
        if (ncquery == id) readNotecard(id, data);
    }
    link_message(integer sender, integer num, string str, key id) {
        if (90060 == num) {
            // avatar sits: id=agent UUID, str=SITTER #
            llRequestPermissions(id, PERMISSION_TRIGGER_ANIMATION);
        }
        else if (90065 == num) {
            // avatar stands: id=agent UUID, str=SITTER #
            stopAnimations((integer)str);
        }
        else if (90045 == num) {
            // pose is played: id=agent UUID, str=SITTER #|pose name|...
            list data = llParseStringKeepNulls(str, ["|"], []);
            integer sitter = (integer)llList2String(data, 0);
            string pose = llList2String(data, 1);

            data = animsForSeat(sitter, pose);
            if ([] == data) {
                // try default animations
                data = animsForSeat(sitter, "");
            }
            if (llDumpList2String(data, "") != llDumpList2String(animsForSeat(sitter, EOF), "")) {
                // first stop currently played animations
                stopAnimations(sitter);
            }
            if ([] != data) {
                // found specific animations for this pose
                startAnimations(sitter, data);
            }
        }
    }
}
