// [AV]anim - Converts Black Tulip AVsitter2 Hands plugin to [AV]anim plugin format
// By Typhaine Artez
//
// Version 1.0 - March 2021
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// This script uses the following ossl functions so they must be enabled for the owner of the object
// containing the script:
//  osGetNotecard(), osMakeNotecard()

string BTCONFIG = "[Black Tulip] Hand Poses - AVsitter Plugin ~CFG~";
string NC = "AVanim";

default {
    state_entry() {
        list AVanim;
        if (INVENTORY_NOTECARD == llGetInventoryType(BTCONFIG)) {
            if (INVENTORY_NOTECARD == llGetInventoryType(NC)) {
                llRemoveInventory(NC);
                llSleep(0.3);
            }
            list lines = llParseString2List(osGetNotecard(BTCONFIG), ["\n"], []);
            integer i;
            string str;
            string anim;
            integer sitter;
            integer c = llGetListLength(lines);
            for (i = 0; i < c; ++i) {
                str = llList2String(lines, i);
                if (llSubStringIndex(str, "#") && "" != str && !llSubStringIndex(str, "Animation = ")) {
                    list l = llParseString2List(llGetSubString(str, 12, -1), ["|"], []);
                    str = llStringTrim(llList2String(l, 0), STRING_TRIM);
                    sitter = (integer)llStringTrim(llList2String(l, 1), STRING_TRIM);
                    anim = llStringTrim(llList2String(l, 2), STRING_TRIM);
                    AVanim += [ sitter, str, anim ];
                }
            }
            // build by sitter#
            sitter = 0;
            lines = ["SITTER 0"];
            while ([] != AVanim) {
                i = llListFindList(AVanim, [sitter]);
                if (~i) {
                    lines += llList2String(AVanim, i+1) + "|" + llList2String(AVanim, i+2);
                    AVanim = llDeleteSubList(AVanim, i, i+2);
                }
                else {
                    // next seat
                    ++sitter;
                    lines += ["", "SITTER "+(string)sitter];
                }
            }

            osMakeNotecard(NC, lines);
            llOwnerSay("AVanim generation complete... deleting the conversion script");
            llRemoveInventory(llGetScriptName());
       }
    }
}
