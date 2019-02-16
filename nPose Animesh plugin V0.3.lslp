rotation ParentRot;
vector ParentPos;
rotation MyRot;
vector MyPos;
key Parent = NULL_KEY;
list TimerList;
string curBodyAnim;
string curHandAnim;
string curTailAnim;
string curHeadAnim;
string curWingsAnim;
integer reporting;
integer SYNC = 206;

integer GETANIMDATA = -14002;  //str=Mode|RunTime|comma delimited list of animations to run
integer moveMe = -14003;

list BodyAnims;                 //List of the last received animations to run from notecard
list HandAnims;                 //List of the last received animations to run from notecard
list TailAnims;                 //List of the last received animations to run from notecard
list HeadAnims;                 //List of the last received animations to run from notecard
list WingsAnims;                 //List of the last received animations to run from notecard

executeAnimChange(string group, string str) {
    if(group == "body") {
        if (curBodyAnim != "") {
            llStopObjectAnimation(curBodyAnim);
        }
        llStartObjectAnimation(str);
        curBodyAnim = str;
    }
    else if(group == "hand"){
        if (curHandAnim != "") {
            llStopObjectAnimation(curHandAnim);
        }
        llStartObjectAnimation(str);
        curHandAnim = str;
    }
    else if(group == "tail"){
        if (curTailAnim != "") {
            llStopObjectAnimation(curTailAnim);
        }
        llStartObjectAnimation(str);
        curTailAnim = str;
    }
    else if(group == "head"){
        if (curHeadAnim != "") {
            llStopObjectAnimation(curHeadAnim);
        }
        llStartObjectAnimation(str);
        curHeadAnim = str;
    }
    else if(group == "wings"){
        if (curWingsAnim != "") {
            llStopObjectAnimation(curWingsAnim);
        }
        llStartObjectAnimation(str);
        curWingsAnim = str;
    }
}

checkTimer() {
    llSetTimerEvent(0.0);
    float timerTime;
    float timeNow=llGetTime();
    while(timerTime<=0.01 && llGetListLength(TimerList)) {
        timerTime=llList2Float(TimerList, 0) - timeNow;
        if(timerTime<=0.01) {
            //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
            TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);    //reset timer for next sequence
            TimerList = llListReplaceList(TimerList, [llList2Integer(TimerList, 3)+1], 3, 3);
            string TargetGroup = llList2String(TimerList, 4);
            if (TargetGroup == "body") {
                if (llList2Integer(TimerList, 3) > llGetListLength(BodyAnims)-1) {        //check if we exceed last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(BodyAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "hand") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HandAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(HandAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "tail") {
                if (llList2Integer(TimerList, 3) > llGetListLength(TailAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(TailAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "head") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HeadAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(HeadAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "wings") {
                if (llList2Integer(TimerList, 3) > llGetListLength(WingsAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(WingsAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "checkMoved") {
                //report new position/rotation
                //reset checkMoved timer
                if(Parent!=NULL_KEY) {
                    if (MyPos != llGetPos() || MyRot != llGetRot()) { //someone moved me so report
                        vector reportingPos = (llGetPos() - ParentPos) / ParentRot;
                        vector reportingRot = llRot2Euler(llGetRot() / ParentRot) * RAD_TO_DEG;
                        list parts = [llGetObjectName(), reportingPos, reportingRot];
                        if (reporting) {
                            llRegionSayTo(llGetOwner(), 0, "LINKMSG|-14003|" + llDumpList2String(parts, "~"));
                        }
                        MyPos = llGetPos();
                        MyRot = llGetRot();
                    }
                    TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);
                }
            }
        }
    }
    if(llGetListLength(TimerList)>5) {
        TimerList=llListSort(TimerList, 5, TRUE);
    }
    if(llGetListLength(TimerList)) {
        llSetTimerEvent(timerTime);
    }
}

stop_all_animations() {
    list curr_anims = llGetObjectAnimationNames();
    integer i;
    integer stop = llGetListLength(curr_anims);
    for (i=0; i<stop; ++i) {
        llStopObjectAnimation(llList2Key(curr_anims, i));
    }
}

default
{
    state_entry()
    {
        stop_all_animations();
    }

    link_message(integer sender_num, integer num, string str, key id) {
        if (num == -14007) {
            list Parts = llParseStringKeepNulls(str, ["~"], []);
            string MeshName = llList2String(Parts, 0);
            if (llGetObjectName() == MeshName) {
                stop_all_animations();
            }
        }
        else if (num == SYNC) {
            llStopObjectAnimation(curBodyAnim);
            llSleep(0.1);
//            llStartObjectAnimation("[RNP] nPose Default");
//            llStopObjectAnimation("[RNP] nPose Default");
            llStartObjectAnimation(curBodyAnim);
        }
        else if (num == moveMe) {
            list moveParams = llParseStringKeepNulls(str, ["~"], []);
            if (llGetObjectName() == llList2String(moveParams, 0)) {
                vector vDelta = (vector)llList2String(moveParams, 1);
                vector position = ParentPos + (vDelta * ParentRot);
                rotation rotate = llEuler2Rot((vector)llList2String(moveParams, 2) * DEG_TO_RAD) * ParentRot;
                llSetLinkPrimitiveParamsFast(1,
                    [
                        PRIM_POSITION, position, 
                        PRIM_ROTATION, rotate
rotation ParentRot;
vector ParentPos;
rotation MyRot;
vector MyPos;
key Parent = NULL_KEY;
list TimerList;
string curBodyAnim;
string curHandAnim;
string curTailAnim;
string curHeadAnim;
string curWingsAnim;
integer reporting;
integer SYNC = 206;

integer GETANIMDATA = -14002;  //str=Mode|RunTime|comma delimited list of animations to run
integer moveMe = -14003;

list BodyAnims;                 //List of the last received animations to run from notecard
list HandAnims;                 //List of the last received animations to run from notecard
list TailAnims;                 //List of the last received animations to run from notecard
list HeadAnims;                 //List of the last received animations to run from notecard
list WingsAnims;                 //List of the last received animations to run from notecard

executeAnimChange(string group, string str) {
    if(group == "body") {
        if (curBodyAnim != "") {
            llStopObjectAnimation(curBodyAnim);
        }
        llStartObjectAnimation(str);
        curBodyAnim = str;
    }
    else if(group == "hand"){
        if (curHandAnim != "") {
            llStopObjectAnimation(curHandAnim);
        }
        llStartObjectAnimation(str);
        curHandAnim = str;
    }
    else if(group == "tail"){
        if (curTailAnim != "") {
            llStopObjectAnimation(curTailAnim);
        }
        llStartObjectAnimation(str);
        curTailAnim = str;
    }
    else if(group == "head"){
        if (curHeadAnim != "") {
            llStopObjectAnimation(curHeadAnim);
        }
        llStartObjectAnimation(str);
        curHeadAnim = str;
    }
    else if(group == "wings"){
        if (curWingsAnim != "") {
            llStopObjectAnimation(curWingsAnim);
        }
        llStartObjectAnimation(str);
        curWingsAnim = str;
    }
}

checkTimer() {
    llSetTimerEvent(0.0);
    float timerTime;
    float timeNow=llGetTime();
    while(timerTime<=0.01 && llGetListLength(TimerList)) {
        timerTime=llList2Float(TimerList, 0) - timeNow;
        if(timerTime<=0.01) {
            //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
            TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);    //reset timer for next sequence
            TimerList = llListReplaceList(TimerList, [llList2Integer(TimerList, 3)+1], 3, 3);
            string TargetGroup = llList2String(TimerList, 4);
            if (TargetGroup == "body") {
                if (llList2Integer(TimerList, 3) > llGetListLength(BodyAnims)-1) {        //check if we exceed last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(BodyAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "hand") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HandAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(HandAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "tail") {
                if (llList2Integer(TimerList, 3) > llGetListLength(TailAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(TailAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "head") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HeadAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(HeadAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "wings") {
                if (llList2Integer(TimerList, 3) > llGetListLength(WingsAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                executeAnimChange(TargetGroup, llList2String(WingsAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "checkMoved") {
                //report new position/rotation
                //reset checkMoved timer
                if(Parent!=NULL_KEY) {
                    if (MyPos != llGetPos() || MyRot != llGetRot()) { //someone moved me so report
                        vector reportingPos = (llGetPos() - ParentPos) / ParentRot;
                        vector reportingRot = llRot2Euler(llGetRot() / ParentRot) * RAD_TO_DEG;
                        list parts = [llGetObjectName(), "body", curBodyAnim, reportingPos, reportingRot];
                        if (reporting) {
                            llRegionSayTo(llGetOwner(), 0, "LINKMSG|-14003|" + llDumpList2String(parts, "|"));
                        }
                        MyPos = llGetPos();
                        MyRot = llGetRot();
                    }
                    TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);
                }
            }
        }
    }
    if(llGetListLength(TimerList)>5) {
        TimerList=llListSort(TimerList, 5, TRUE);
    }
    if(llGetListLength(TimerList)) {
        llSetTimerEvent(timerTime);
    }
}

stop_all_animations() {
    list curr_anims = llGetObjectAnimationNames();
    integer i;
    integer stop = llGetListLength(curr_anims);
    for (i=0; i<stop; ++i) {
        llStopObjectAnimation(llList2Key(curr_anims, i));
    }
}

move(string ObjName, vector newPos, vector NewRot) {
    if (llGetObjectName() == ObjName) {
        vector position = ParentPos + (newPos * ParentRot);
        rotation rotate = llEuler2Rot(NewRot * DEG_TO_RAD) * ParentRot;
        llSetLinkPrimitiveParamsFast(1,
            [
                PRIM_POSITION, position, 
                PRIM_ROTATION, rotate
            ]);
        MyPos = llGetPos();
        MyRot = llGetRot();
    }
}

default
{
    state_entry()
    {
        stop_all_animations();
    }

    link_message(integer sender_num, integer num, string str, key id) {
        if (num == -14007) {
            list Parts = llParseStringKeepNulls(str, ["~"], []);
rotation ParentRot;
vector ParentPos;
rotation MyRot;
vector MyPos;
key Parent = NULL_KEY;
list TimerList;
string curBodyAnim;
string curHandAnim;
string curTailAnim;
string curHeadAnim;
string curWingsAnim;
integer reporting;
integer SYNC = 206;

integer GETANIMDATA = -14002;  //str=Mode|RunTime|comma delimited list of animations to run
integer moveMe = -14003;

list BodyAnims;                 //List of the last received animations to run from notecard
list HandAnims;                 //List of the last received animations to run from notecard
list TailAnims;                 //List of the last received animations to run from notecard
list HeadAnims;                 //List of the last received animations to run from notecard
list WingsAnims;                 //List of the last received animations to run from notecard

executeAnimChange(string group, string str) {
    if (str != ""){
        if(group == "body") {
            if (curBodyAnim != "") {
                llStopObjectAnimation(curBodyAnim);
            }
            llStartObjectAnimation(str);
            curBodyAnim = str;
        }
        else if(group == "hand"){
            if (curHandAnim != "") {
                llStopObjectAnimation(curHandAnim);
            }
            llStartObjectAnimation(str);
            curHandAnim = str;
        }
        else if(group == "tail"){
            if (curTailAnim != "") {
                llStopObjectAnimation(curTailAnim);
            }
            llStartObjectAnimation(str);
            curTailAnim = str;
        }
        else if(group == "head"){
            if (curHeadAnim != "") {
                llStopObjectAnimation(curHeadAnim);
            }
            llStartObjectAnimation(str);
            curHeadAnim = str;
        }
        else if(group == "wings"){
            if (curWingsAnim != "") {
                llStopObjectAnimation(curWingsAnim);
            }
            llStartObjectAnimation(str);
            curWingsAnim = str;
        }
    }
}

checkTimer() {
    llSetTimerEvent(0.0);
    float timerTime;
    float timeNow=llGetTime();
    while(timerTime<=0.01 && llGetListLength(TimerList)) {
        timerTime=llList2Float(TimerList, 0) - timeNow;
        if(timerTime<=0.01) {
            //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
            TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);    //reset timer for next sequence
            TimerList = llListReplaceList(TimerList, [llList2Integer(TimerList, 3)+1], 3, 3);
            string TargetGroup = llList2String(TimerList, 4);
            if (TargetGroup == "body") {
                if (llList2Integer(TimerList, 3) > llGetListLength(BodyAnims)-1) {        //check if we exceed last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                if (llList2String(BodyAnims, llList2Integer(TimerList, 3)) != "") 
                    executeAnimChange(TargetGroup, llList2String(BodyAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "hand") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HandAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                if (llList2String(HandAnims, llList2Integer(TimerList, 3)) != "") 
                    executeAnimChange(TargetGroup, llList2String(HandAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "tail") {
                if (llList2Integer(TimerList, 3) > llGetListLength(TailAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                if (llList2String(TailAnims, llList2Integer(TimerList, 3)) != "") 
                    executeAnimChange(TargetGroup, llList2String(TailAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "head") {
                if (llList2Integer(TimerList, 3) > llGetListLength(HeadAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                if (llList2String(HeadAnims, llList2Integer(TimerList, 3)) != "") 
                    executeAnimChange(TargetGroup, llList2String(HeadAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "wings") {
                if (llList2Integer(TimerList, 3) > llGetListLength(WingsAnims)-1) {        //check if we less than last anim in list
                    TimerList = llListReplaceList(TimerList, [0],3,3);     //update anim and curIndex in timer list
                }
                if (llList2String(WingsAnims, llList2Integer(TimerList, 3)) != "") 
                    executeAnimChange(TargetGroup, llList2String(WingsAnims, llList2Integer(TimerList, 3)));
            }
            else if (TargetGroup == "checkMoved") {
                //report new position/rotation
                //reset checkMoved timer
                if(Parent!=NULL_KEY) {
                    if (MyPos != llGetPos() || MyRot != llGetRot()) { //someone moved me so report
                        vector reportingPos = (llGetPos() - ParentPos) / ParentRot;
                        vector reportingRot = llRot2Euler(llGetRot() / ParentRot) * RAD_TO_DEG;
                        list parts = [llGetObjectName(), "body", curBodyAnim, reportingPos, reportingRot];
                        if (reporting) {
                            llRegionSayTo(llGetOwner(), 0, "LINKMSG|-14003|" + llDumpList2String(parts, "|"));
                        }
                        MyPos = llGetPos();
                        MyRot = llGetRot();
                    }
                    TimerList = llListReplaceList(TimerList, [timeNow + llList2Float(TimerList, 2)], 0, 0);
                }
            }
        }
    }
    if(llGetListLength(TimerList)>5) {
        TimerList=llListSort(TimerList, 5, TRUE);
    }
    if(llGetListLength(TimerList)) {
        llSetTimerEvent(timerTime);
    }
}

stop_all_animations() {
    list curr_anims = llGetObjectAnimationNames();
    integer i;
    integer stop = llGetListLength(curr_anims);
    for (i=0; i<stop; ++i) {
        llStopObjectAnimation(llList2Key(curr_anims, i));
    }
}

move(string ObjName, vector newPos, vector NewRot) {
    if (llGetObjectName() == ObjName) {
        vector position = ParentPos + (newPos * ParentRot);
        rotation rotate = llEuler2Rot(NewRot * DEG_TO_RAD) * ParentRot;
        llSetLinkPrimitiveParamsFast(1,
            [
                PRIM_POSITION, position, 
                PRIM_ROTATION, rotate
            ]);
        MyPos = llGetPos();
        MyRot = llGetRot();
    }
}

default
{
    state_entry()
    {
        stop_all_animations();
    }

    link_message(integer sender_num, integer num, string str, key id) {
        if (num == -14007) {
            list Parts = llParseStringKeepNulls(str, ["~"], []);
            string MeshName = llList2String(Parts, 0);
            if (llGetObjectName() == MeshName) {
                stop_all_animations();
            }
        }
        else if (num == SYNC) {
            llStopObjectAnimation(curBodyAnim);
            llSleep(0.1);
            llStartObjectAnimation(curBodyAnim);
        }
        else if (num == moveMe) {
            list moveParams = llParseStringKeepNulls(str, ["~"], []);
            move(llList2String(moveParams, 0), (vector)llList2String(moveParams, 1), (vector)llList2String(moveParams, 2));
        }
        else if(num == GETANIMDATA) {
            list Parts = llParseStringKeepNulls(str, ["|"], []);
            string MeshName = llList2String(Parts, 0);
            string TargetGroup = llToLower(llList2String(Parts, 1));
            if (str == "report") {
                reporting = 1;
                return;
            }
            if (llGetObjectName() == MeshName) {
                if (TargetGroup == "body") {
                    TimerList = []; //clear timer list triggered on body animation change (reset if you will)
                    TimerList += [
                        llGetTime() + 10.0,
                        0,
                        10.0,
                        0,
                        "checkMoved"
                    ];
                    //Strip off the position and rotation from the parts and move the animesh
                    //Use them to do the move
                    integer listLength = llGetListLength(Parts);
                    vector newPos = (vector)llList2String(Parts, listLength - 2);
                    vector newRot = (vector)llList2String(Parts, listLength - 1);
                    move(MeshName, newPos, newRot);
                    Parts = llDeleteSubList(Parts, listLength - 2, listLength - 1);
                }
                
                if (llGetListLength(Parts) < 4 && llList2String(Parts, 2) != "") { //this will run the single animation in card line option
                    //we need the target group and the animation name
                    executeAnimChange(TargetGroup, llList2String(Parts, 2));
//                    llSetTimerEvent(0);
                    return;
                }
                //from here, we work on the list option of animations
                //set up the list for concurrent or random
                list Anims;
                if (llList2Integer(Parts, 2)) {
                    Anims = llListRandomize(llCSV2List(llList2String(Parts, 4)), 1);
                }
                else {
                    Anims = llCSV2List(llList2String(Parts, 4));
                }
                //add the animations to the proper list
                if (TargetGroup == "body") {
                    BodyAnims = Anims;
                }
                else if (TargetGroup == "hand") {
                    HandAnims = Anims;
                }
                else if (TargetGroup == "tail") {
                    TailAnims = Anims;
                }
                else if (TargetGroup == "head") {
                    HeadAnims = Anims;
                }
                else if (TargetGroup == "wings") {
                    WingsAnims = Anims;
                }
                //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
                TimerList += [
                    llGetTime() + llList2Integer(Parts, 2),
                    llList2Integer(Parts, 2),
                    llList2Integer(Parts, 3),
                    0,
                    TargetGroup
                ];
                //here we set the initial animation for the group
                //send the target group and the animation name
                if (TargetGroup == "body" && llList2String(BodyAnims, llList2Integer(TimerList, 3)) != "") {
                    executeAnimChange(TargetGroup, llList2String(BodyAnims, llList2Integer(TimerList, 3)));
                }
                else if (TargetGroup == "hand" && llList2String(HandAnims, llList2Integer(TimerList, 3)) != "") {
                    executeAnimChange(TargetGroup, llList2String(HandAnims, llList2Integer(TimerList, 3)));
                }
                else if (TargetGroup == "tail" && llList2String(TailAnims, llList2Integer(TimerList, 3)) != "") {
                    executeAnimChange(TargetGroup, llList2String(TailAnims, llList2Integer(TimerList, 3)));
                }
                else if (TargetGroup == "head" && llList2String(HeadAnims, llList2Integer(TimerList, 3)) != "") {
                    executeAnimChange(TargetGroup, llList2String(HeadAnims, llList2Integer(TimerList, 3)));
                }
                else if (TargetGroup == "wings" && llList2String(WingsAnims, llList2Integer(TimerList, 3)) != "") {
                    executeAnimChange(TargetGroup, llList2String(WingsAnims, llList2Integer(TimerList, 3)));
                }
                if(llGetListLength(TimerList)>5) {
                    TimerList=llListSort(TimerList, 5, TRUE);
                }
                checkTimer();
            }
        }
    }

    on_rez(integer parms) {
        Parent = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]), 0);
        list parentParams = llGetObjectDetails(Parent , [OBJECT_POS, OBJECT_ROT]);
        ParentPos = llList2Vector(parentParams, 0);
        ParentRot = llList2Rot(parentParams, 1);
        MyPos = llGetPos();
        MyRot = llGetRot();
        //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
        TimerList += [
            llGetTime() + 10.0,
            0,
            10.0,
            0,
            "checkMoved"
        ];
        checkTimer();
    }
    
    timer() {
        checkTimer();
    }
}
