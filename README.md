# nPose-Animesh-Plugin
Animesh objects are made with the same type of skeletal structure as Avatars and thus we can animate them with the same animation files used to animate Avatars.

There are several areas we can animate separately (bento).  These areas are:
    * body
    * hand
    * head
    * tail
    * wings
    
The nPose Animesh Plugin can target each of these areas separately with a single animation, or a list of animations to run either concurrently or in a random order.  This plugin also supports the use of multiple rezzed animesh objects separately, given that each has a unique object name within the build.

For this we must use [PLUGINCOMMAND](https://github.com/nPoseTeam/nPose-V4/wiki/NC-Contents#plugincommand) to enable us to send more data than LINKMSG does.
Always add a line in the .init as follows:    
    `PLUGINCOMMAND|XANI_MESH|-14002`
There are two separate overrides within this system to set up animations.    
The first being to run a single animation:        
    `XANI_MESH|animeshName|areaToAnimate|animationName`
    
The second being to provide a list of animations to run on one of the areas:        
    `XANI_MESH|animeshName|randomMode|timeForEachAnimation|commaSeparatedListOfAnimations`
    
When the nPose Animesh Pluin receives a new body animation request, it will reset any timers which could be running for the list of animations.  It will not stop any current animation automatically.  If you wish to run another list of animations, you'll have to set that up again for this animesh pose.

    
    
There is also an override to allow you to move an animesh.  This is for rezzed animesh, not attached.  The move uses the rezzor's position and rotation as the reference (just like normal props use).
The syntax for this override is as follows:        
    `XANI_MESH|animeshName|areaToAnimate|animationName|<positionVector>|<rotationVector>`
    
    
    
SETUP:

The animation files must be in the same prim as the nPose Animesh Plugin.  Add your animation files in the contents of the animesh prim.  Also add the nPose Animesh Plugin to the contents of that same animesh prim.  Also add the nPose prop plugin to contents.  The animesh prim is now setup and can be rezzed like any other prop.

Rez the animesh just like any other prop.
Rez the dummy as explicit so ANIM lines don't derez the dummy        
    `PROP|Bento_test_dummy_rezzed|<0.00000, 2.63785, 0.508057>|<0.00000, 0.00000, 0.00000>|explicit|quiet`

Set the initial pose for the animesh        
    `XANI_MESH|Bento_test_dummy_rezzed|body|npose-listen right`

The animesh will report any new positions like a prop would except it's in an easy copy format for the animesh lines.  Reporting is turned off by default.        
    `LINKMSG|-14002|report`


You can now set up notecards to animate the animesh areas as well as setup your AV animations just like an normal nPose setup.  Just include the lines to do what's needed with the animesh prop in that same card.  An example might be as follows:        

    `XANIM{1}|1|npose-listen forward|<0.694916, 0.685030, 0.214600>|<0.000000, 0.000000, -135.001892>|`        
    `XANI_MESH|areaToAnimate|Bento_test_dummy_rezzed~body~npose-storyteller|<-0.672264, -0.748333, 0.508057>|<0.000000, 0.000000, 45.000030>`        
    `XANI_MESH|Bento_test_dummy_rezzed|hand~HandLPoint01 P4`        
    `XANI_MESH|Bento_test_dummy_rezzed~hand|HandRPoint01 P4`        
    `XANI_MESH|Bento_test_dummy_rezzed|tail|1|5|Tail-1,Tail-2,Tail-3,Tail-4`        
    

Here we use the SINGLES (XANIM{1}|1|..) line to move and animate the AV.
Set up the body animation to run on the animesh prim named "Bento_test_dummy_rezzed".
Next set up the animation for the left hand.
And setup the animation for the right hand.  (It is possible that some animations would animate both hands, depending on the creator)
And last set up a list of animations to run in a random order running for 5 seconds each for the list.
    
Note that this example does not set any animations for head and wings areas.  Those areas will be fixed in their default position or possibly use a previously set animation.
