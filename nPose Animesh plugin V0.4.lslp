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

key AV_To_Follow;
integer followFlag;
integer gotoFlag;
string AVstatus;
integer SFlagWalking;
integer SFlagStanding;
integer SFlagSitting;
integer SFlagFlying;
integer SFlagHoveringUp;
integer SFlagHoveringDown;
integer SFlagHovering;
integer SFlagRunning;

string WalkingAnims;
string StandingAnims;
string FlyingAnims;
string SittingAnims;
string HoveringDownAnims;
string HoveringUpAnims;
string HoveringAnims;
string RunningAnims;
string FloatingAnims;

vector objPos;
rotation startRot;
integer FOLLOW_MODE = -14021;
float followDist = 3.0;
float heightOffset;
vector offset = < -2.0, 0, 0>;


integer GETANIMDATA = -14002;  //str=Mode|RunTime|comma delimited list of animations to run
integer moveMe = -14003;
integer ANIMATE_MESH = -14020; //[target group, animation [, target group, animation].. we will have capability to run one animation for each of the target groups

list BodyAnims;                 //List of the last received animations to run from notecard
list HandAnims;                 //List of the last received animations to run from notecard
list TailAnims;                 //List of the last received animations to run from notecard
list HeadAnims;                 //List of the last received animations to run from notecard
list WingsAnims;                 //List of the last received animations to run from notecard

initialize() {
        llSetStatus(STATUS_ROTATE_X|STATUS_ROTATE_Y,FALSE);
        stop_all_animations();
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
    if (followFlag || gotoFlag) {
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSensorRepeat("", AV_To_Follow, AGENT, 30.0, PI, 0.25);
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

rotation getRotToPointAxisAt(vector axis, vector target) {
    return llGetRot() * llRotBetween(axis * llGetRot(), target - llGetPos());
}

processLines(list Anims, string TargetGroup) {
    //from here, we work on the list option of animations
    //set up the list for concurrent or random
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

default {
    state_entry() {
        initialize();
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
                list Anims;
                if (llList2Integer(Parts, 2)) {
                    Anims = llListRandomize(llCSV2List(llList2String(Parts, 4)), 1);
                }
                else {
                    Anims = llCSV2List(llList2String(Parts, 4));
                }
                //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
                TimerList += [
                    llGetTime() + llList2Integer(Parts, 2),
                    llList2Integer(Parts, 2),
                    llList2Integer(Parts, 3),
                    0,
                    TargetGroup
                ];
                processLines(Anims, TargetGroup);
            }
        }
        else if (num == ANIMATE_MESH) {
            //here we are not going to move the animesh cause it is our root prim.  We only want to animate.. so no pos/rot and no mesh name
            list Parts = llParseStringKeepNulls(str, ["|"], []);
//            string MeshName = llList2String(Parts, 0);
            string TargetGroup = llToLower(llList2String(Parts, 0));
            if (TargetGroup == "body") {
                TimerList = []; //clear timer list triggered on body animation change (reset if you will)
                TimerList += [
                    llGetTime() + 10.0,
                    0,
                    10.0,
                    0,
                    "checkMoved"
                ];
            }
            if (llGetListLength(Parts) < 4) { //this will run the single animation in card line option
                //we need the target group and the animation name
                executeAnimChange(TargetGroup, llList2String(Parts, 1));
                return;
            }
            
            list Anims;
            //check if we need to randmoize the animations list or not
            if (llList2Integer(Parts, 1)) {
                Anims = llListRandomize(llCSV2List(llList2String(Parts, 3)), 1);
            }
            else {
                Anims = llCSV2List(llList2String(Parts, 3));
            }
            //TimerList = [remaining time, mode, requested run time, AnimsIndex, target group]
            TimerList += [
                llGetTime() + llList2Integer(Parts, 2),
                llList2Integer(Parts, 1),
                llList2Integer(Parts, 2),
                0,
                TargetGroup
            ];
            processLines(Anims, TargetGroup);
        }
        else if (num == FOLLOW_MODE) {
            AV_To_Follow = id;
            list Follow_ParamsList = llCSV2List(str);
            integer listStop = llGetListLength(Follow_ParamsList);
            integer listIndex;
            for (listIndex = 0; listIndex < listStop; ++listIndex) {
                list optionsItems = llParseString2List(llList2String(Follow_ParamsList, listIndex), ["="], []);
                string optionItem = llToLower(llStringTrim(llList2String(optionsItems, 0), STRING_TRIM));
                string optionString = llList2String(optionsItems, 1);
                string optionSetting = llToLower(llStringTrim(optionString, STRING_TRIM));
                integer optionSettingFlag = optionSetting=="on" || (integer)optionSetting;
                if (optionItem == "follow") {
                    followFlag = optionSettingFlag;
                    SFlagWalking = 0;
                    SFlagStanding = 0;
                    SFlagSitting = 0;
                    SFlagFlying = 0;
                    SFlagHoveringUp = 0;
                    SFlagHoveringDown = 0;
                    SFlagHovering = 0;
                    SFlagRunning = 0;
                }
                else if (optionItem == "goto") {
                    followFlag = 0;
                    gotoFlag = optionSettingFlag;
                    SFlagWalking = 0;
                    SFlagStanding = 0;
                    SFlagSitting = 0;
                    SFlagFlying = 0;
                    SFlagHoveringUp = 0;
                    SFlagHoveringDown = 0;
                    SFlagHovering = 0;
                    SFlagRunning = 0;
                }
                else if (optionItem == "followtodist") {
                    followDist = (float)optionString;
                }
                else if (optionItem == "heightoffset") {
                    heightOffset = (float)optionString;
                }
                else if (optionItem == "standing") {
                    StandingAnims = optionString;
                }
                else if (optionItem == "walking") {
                    WalkingAnims = optionString;
                }
                else if (optionItem == "sitting") {
                    SittingAnims = optionString;
                }
                else if (optionItem == "flying") {
                    FlyingAnims = optionString;
                }
                else if (optionItem == "hoveringup") {
                    HoveringUpAnims = optionString;
                }
                else if (optionItem == "hoveringdown") {
                    HoveringDownAnims = optionString;
                }
                else if (optionItem == "hovering") {
                    HoveringAnims = optionString;
                }
                else if (optionItem == "running") {
                    RunningAnims = optionString;
                }
            }
            if (followFlag || gotoFlag) {
                llSetStatus(STATUS_PHYSICS, TRUE);
                startRot = llGetRot();
                list det = llGetObjectDetails(AV_To_Follow, [OBJECT_POS,OBJECT_ROT]);//this will never fail less owner is not in the same sim
                vector AvPos = llList2Vector(det,0);
                objPos = llGetPos();
                objPos = <objPos.x, objPos.y, AvPos.z + heightOffset>;
                llMoveToTarget(objPos, 0.2);
                llRotLookAt(getRotToPointAxisAt(<1.0,0.0,0.0>, AvPos), 0.4, 0.1);
                stop_all_animations();
                llMessageLinked(LINK_SET, 200, WalkingAnims, "");
            }
        }
    }

    sensor(integer total_number) {
        if (followFlag || gotoFlag) {
            list det = llGetObjectDetails(AV_To_Follow, [OBJECT_POS,OBJECT_ROT]);//this will never fail less owner is not in the same sim
            // Owner detected...
            vector AvPos = llList2Vector(det,0);
            objPos = llGetPos();
            objPos = <objPos.x, objPos.y, AvPos.z + heightOffset>;
            llMoveToTarget(objPos, 0.6);
            llRotLookAt(getRotToPointAxisAt(<1.0,0.0,0.0>, AvPos), 0.4, 0.1);
            // Get position and rotation
            vector pos   = llList2Vector(det,0);
            rotation rot = (rotation)llList2String(det,1);
            vector worldOffset = <offset.x + followDist, offset.y, offset.z + heightOffset>;
            pos += worldOffset;
            if (llVecMag(AvPos-objPos) >= 3) {
                llMoveToTarget(pos, 0.6);
            }
            AVstatus = llGetAnimation(AV_To_Follow);
            if (AVstatus == "Standing" && llVecMag(AvPos-objPos) < 3 && !SFlagStanding) {
                llRotLookAt(getRotToPointAxisAt(<1.0,0.0,0.0>, AvPos), 0.4, 0.1);
                llMessageLinked(LINK_SET, 200, StandingAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 1;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
                if (gotoFlag) {
                    gotoFlag = 0;
                    llSensorRemove();
                    llSetStatus(STATUS_PHYSICS, FALSE);
                }
            }
            if (followFlag && AVstatus == "Walking" && !SFlagWalking) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, WalkingAnims, "");
                SFlagWalking = 1;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Sitting") && !SFlagSitting) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, SittingAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 1;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Flying" || AVstatus == "Flying Up" || AVstatus == "Flying Down") && !SFlagFlying) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, FlyingAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 1;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Hovering Up") && !SFlagHoveringUp) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, HoveringUpAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 1;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Hovering Down") && !SFlagHoveringDown) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, HoveringDownAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 1;
                SFlagHovering = 0;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Hovering") && !SFlagHovering) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, HoveringAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 1;
                SFlagRunning = 0;
            }
            else if (followFlag && (AVstatus == "Running") && !SFlagRunning) {
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llMessageLinked(LINK_SET, 200, RunningAnims, "");
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 1;
            }
        }
        else {
            llSensorRemove();
            llSetStatus(STATUS_PHYSICS, FALSE);
                SFlagWalking = 0;
                SFlagStanding = 0;
                SFlagSitting = 0;
                SFlagFlying = 0;
                SFlagHoveringUp = 0;
                SFlagHoveringDown = 0;
                SFlagHovering = 0;
                SFlagRunning = 0;
        }
    }
    
    on_rez(integer parms) {
        initialize();
    }
    
    timer() {
        checkTimer();
    }

    changed(integer change) {
        if(change & CHANGED_LINK) {
            if (followFlag = 1){
                llSensorRemove();
                llSetStatus(STATUS_PHYSICS, FALSE);
                AV_To_Follow = NULL_KEY;
                followFlag = 0;
            }
        }
    }
}
