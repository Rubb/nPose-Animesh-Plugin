# nPose-Animesh-Plugin (Release Candidate)
This is going to be geared up to use with nPose V3.10+ 

Animesh objects are made with the same type of skeletal structure as Avatars and thus we can animate them with the same animation files used to animate Avatars.

There are several areas we can animate separately (bento).  These areas are:
```
body
hand
head
tail
wings
```

## For usage as a PROP

    
The nPose Animesh Plugin can target each of these areas separately with a single animation, or a list of animations to run either concurrently or in a random order.  This plugin also supports the use of multiple rezzed animesh objects separately, given that each has a unique object name within the build.

**PLEASE NOTE: Animesh commands will not work while written as a LINKMSG or SATMSG line.  We must set up `PLUGINCOMMAND` lines in the .init card to use the link message channels listed below.  Use these lines:**
```
PLUGINCOMMAND|ANI_MESH|-14002
PLUGINCOMMAND|MOVE_MESH|-14003
PLUGINCOMMAND|MESH_ANIMATE|-14020
PLUGINCOMMAND|MESH_OVERRIDE|-14021
```

There are two separate overrides within this system to set up animations.  
The first being to run a single animation:        
    `ANI_MESH|animeshName|areaToAnimate|animationName|position vector|rotation vector`
    
The second being to provide a list of animations to run on one of the areas:        
    `ANI_MESH|animeshName|randomMode|timeForEachAnimation|commaSeparatedListOfAnimations|position vector|rotation vector`
    
When the nPose Animesh Pluin receives a new body animation request, it will reset any timers which could be running for the list of animations.  It will not stop any current animation automatically.  If you wish to run another list of animations, you'll have to set that up again for this animesh pose.

    
    
There is also an overload to allow you to move an animesh.  This is for rezzed animesh, not attached.  The move uses the rezzor's position and rotation as the reference (just like normal props use).
The syntax for this override is as follows:        
    `MOVE_MESH|animeshName|<positionVector>|<rotationVector>`
    
    
    
### SETUP:

The animation files must be in the same prim as the nPose Animesh Plugin.  Add your animation files in the contents of the animesh prim.  Also add the nPose Animesh Plugin to the contents of that same animesh prim.  Also add the nPose prop plugin to contents.  The animesh prim is now setup and can be rezzed like any other prop.

Rez the animesh just like any other prop.
Rez the dummy as explicit so ANIM lines don't derez the dummy        
    `PROP|Bento_test_dummy_rezzed|<0.00000, 2.63785, 0.508057>|<0.00000, 0.00000, 0.00000>|explicit|quiet`

Set the initial pose for the animesh        
    `ANI_MESH|Bento_test_dummy_rezzed|body|npose-listen right|<0.00000, 2.63785, 0.508057>|<0.00000, 0.00000, 0.00000>`

The animesh will report any new positions like a prop would except it's in an easy copy format for the animesh lines.  Reporting is turned off by default.        
    `ANI_MESH|report`


You can now set up notecards to animate the animesh areas as well as setup your AV animations just like an normal nPose setup.  Just include the lines to do what's needed with the animesh prop in that same card.  An example might be as follows:        

    `SCHMO|1|npose-listen forward|<0.694916, 0.685030, 0.214600>|<0.000000, 0.000000, -135.001892>|`        
    `ANI_MESH|Bento_test_dummy_rezzed|body|npose-storyteller|<-0.672264, -0.748333, 0.508057>|<0.000000, 0.000000, 45.000030>`        
    `ANI_MESH|Bento_test_dummy_rezzed|hand|HandLPoint01 P4`        
    `ANI_MESH|Bento_test_dummy_rezzed|hand|HandRPoint01 P4`        
    `ANI_MESH|Bento_test_dummy_rezzed|tail|1|5|Tail-1,Tail-2,Tail-3,Tail-4`        
    

Here we use the SCHMO line to move and animate the AV.
Set up the body animation to run on the animesh prim named "Bento_test_dummy_rezzed".
Set up the position of the animesh prim.
Next set up the animation for the left hand.
And setup the animation for the right hand.  (It is possible that some animations would animate both hands, depending on the creator)
And last set up a list of animations to run in a random order running for 5 seconds each for the list.
    
Note that this example does not set any animations for head and wings areas.  Those areas will be fixed in their default position or possibly use a previously set animation.

## For Usage where the Animesh is the base of nPose (meaning sit the animesh)

### OverRide Commands
| command               | Version | parameters                                                                     | description |
| --------------------- | ------- | ------------------------------------------------------------------------------ | ----------- |
| `Follow`              | 1.00    | Follow=on or Follow=off                                              | Animesh will follow the menu user or stop following |
| `GoTo`              | 1.00    | GoTo=on                                              | Animesh will go to the menu user |
| `FollowToDist`              | 1.00    | FollowToDist=0.0                                         | An offset to the default follow distance of 3.0 meters |
| `HeightOffset`        | 1.00    | HeightOffset=0.1                                            | An offset to the default center of menu user |
| `MaxDistance`         | 1.00     |MaxDistance=10.0                                           | Used in the Animesh Return home Plugin (sets roaming range |
| `Walking`              | 1.00    | Walking=`cardName`                                        | Card to use for the Walking Animesh override |
| `Running`              | 1.00    | Running=`cardName`                                         | Card to use for the Running Animesh override |
| `Standing`              | 1.00    | Standing=`cardName`                                       | Card to use for the Standing Animesh override |
| `Sitting`              | 1.00    | Sitting=`cardName`                                         | Card to use for the Sitting Animesh override |
| `Flying`              | 1.00    | Flying=`cardName`                                           | Card to use for the Flying Animesh override |
| `HoveringUp`              | 1.00    | HoveringUp=`cardName`                                   | Card to use for the HoveringUp Animesh override |
| `HoveringDown`              | 1.00    | HoveringDown=`cardName`                               | Card to use for the HoveringDown Animesh override |
| `Hovering`              | 1.00    | Hovering=`cardName`                                      | Card to use for the Hovering Animesh override |

While using animesh as the base prim set for nPose, we cannot move the animesh as we would a PROP since it has no point of reference, thus this new overload of MESH_ANIMATE is needed without position/rotation.  Also we will only be working with the animesh as the base, thus this new overload doesn't need the animesh name to decide who we are working with.

Each of the `cardName`'s in the list will hold the animation commands to animate the animesh while in Follow or GoTo modes.  Also each of these commands which call the `cardNames` are using the state that the menu user is currently using, if menu user is Sitting the animesh will use the Sitting override and if the menu user is Walking the animesh will use the Walking override, etc.  Each of these cards named for overrides can contain commands to animate each of the areas listed above using single animations or multiple animations.

**PLEASE NOTE: Animesh commands will not work while written as a LINKMSG or SATMSG line.  We must set up `PLUGINCOMMAND` lines in the .init card to use the link message channels listed below.  Use these lines:**
```
PLUGINCOMMAND|ANI_MESH|-14002
PLUGINCOMMAND|MOVE_MESH|-14003
PLUGINCOMMAND|MESH_ANIMATE|-14020
PLUGINCOMMAND|MESH_OVERRIDE|-14021
```

### SETUP:

Single animation syntax:

    `MESH_ANIMATE|area|animationName`
    
Multiple animation syntax:

    `MESH_ANIMATE|area|randomMode|timeForEachAnimation|commaSeparatedListOfAnimations`
    
Where randomMode 0 and animations will run in the order the notecard lists them..
Where randomMode 1 and animations will be sorted randomly before they start running them..
Where timeForEachAnimation is a global time used for each animation before changing to the next in the list.
    
The areas we can animate separately:
```
body
hand
head
tail
wings
```

**Note: Use a separate line for each of the areas to be animated.**

A typical DEFAULTCARD would include the following line to set up the override notecard names:
   `MESH_OVERRIDE|Walking=.walking,Running=.running,Standing=.standing,Sitting=.sitting,Flying=.flying,HoveringUp=.hoveringup,HoveringDown=.hoveringdown,Hovering=.hovering`
   
**Note:  There could be cases where one or more of these override card would be replaced in some other submenu or something.  This is possible to do.  Otherwise there would not be another reason to duplicate the above line in any other card.**
   
A typical DEFAULT card might include ANIM lines to allow Avatar sitters such as follows:
```
ANIM|AO-Stand8-Female|<1.631423, -2.241961, -0.245679>|<-0.000217, 0.102807, -1.929819>||
ANIM|AO-Stand8-Female|<-2.174795, 2.787950, -0.240076>|<-0.000217, 0.102807, -1.929819>||
ANIM|AO-Stand8-Female|<2.360891, 1.318915, -0.240789>|<-0.000217, 0.102807, -1.929819>||
ANIM|AO-Stand8-Female|<-3.209779, -1.212217, -0.245628>|<-0.000217, 0.102807, -1.929819>||
```

And of course the card would animate the animesh and might use something like the following lines:
```
MESH_ANIMATE|body|0|15|stand507,stand11,stand10,Stand4,Stand1
MESH_ANIMATE|wings|Wing_Sit_Stand
MESH_ANIMATE|hand|HandLRelaxed01 P4
MESH_ANIMATE|hand|HandRRelaxed01 P4
MESH_ANIMATE|tail|1
```

Follow mode setup where the Animesh will follow you wherever you go, whether walking, running, or flying, and even sitting.
Somewhere in your menu set up a notecard to turn on the follow mode.  Name is something like SET:Follow ON{!seated}.  Trust me you do not want to turn on Follow mode while you're sitting this animesh...It's a fun ride!  Inside that card add a line something like:

`MESH_OVERRIDE|Follow=on`

It is also possible to set some of the offsets here, such as `HeightOffset` to adjust the height of the animesh.  In this case the line would look like this:

`MESH_OVERRIDE|Follow=on,HeightOffset=0.2`

It's always nice to be able to turn off follow mode so create another notecard with a name something like SET:Follow OFF.  Inside that card add the following line:

`MESH_OVERRIDE|Follow=off`

To have the animesh walk to and greet the menu toucher, make a card named SET:Greet Me{!seated}.  Inside that card add the following line:

`MESH_OVERRIDE|GoTo=on`

and maybe another line to do the greeting:

`TIMER|T1|5.0|LINKMSG|5000|Hello %DISPLAYNAME%.  How are you today?`

**NOTE: The sat/notsat handler must be included to use the timers.**

