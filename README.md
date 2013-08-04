Volume.sh
=====

This script is a PulseAudio Volume Control Script which works
by using the pacmd command. Built for my benefit, feel free to 
adapt to your scenario. In my case is searches for sink #1, but 
that might not be the one which controls your volume (test for
yourself). I offer you the source as is, no guarantees. 

Usage:
volume.sh <return>
--this will print the current volume

volume.sh 10 <return>
--this will set the volume to 10% of max

volume.sh +5 <return>
--this will increase the volume by 5%
--Note: minus works likewise with opposite effect.

volume.sh mute <return>
--this sets the volume to 0.

volume.sh 100 <return>
--the script limits volume to 39% because anything louder than that
--would cause trouble to those living around me, and my hearing!

God Bless!
--dchriste

