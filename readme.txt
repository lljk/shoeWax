Hello and thanks for trying out shoeWax...

  shoeWax 0.11.12 is a *wicked* alpha release, intended for testing - please, play with it, try to break it, and get back to me with any questions or comments.


  REQUIREMENTS / INSTALLATION

  shoeWax requires Gstreamer.  If you're running Windows, take a look here: https://github.com/lljk/rubyWax/wiki/rubyWax-and-Windows ... sections III and IV explain how to install Gstreamer and the Gstreamer gem.

  Unfortunately, shoeWax won't run under standard Shoes builds - you'll need to run it under my shoes_gst build, found here: https://github.com/lljk/shoes_gst/downloads .  Download the zip, extract it somewhere you want it to live, rename the directory something easy ('shoes_gst', for example,) enter the directory, and run 'rake.'

  Once shoes_gst is built, you should be able to fire the thing up... enter the shoeWax directory, open a terminal and run 'path/to/shoes_gst/dist/shoes shoeWax.rb' ...  Did it work?  Sure hope so!


  LOADING TRACKS

  The first thing you'll want to do is load up some tracks to play.  Click on either the playlist button or the directory browser button - the playlist button is on the bottom of the table all the way to the left, and the directory browser button is just next to it.  If you opened the playlist, click the 'add tracks' button, and the directory browser will come up - if you opened the directory browser, well, you're already there!

  The directory browser uses the first image file it finds in a given directory to represent it, so if you want things to look snazzy you should put images in your music directories...

  Navigate to the tracks you want to play by clicking on the directory images on the right side of the browser to enter them.  On the left hand side you'll see an image for the directory you're in, and on the right a listing of subdirectories and music files.  Once you're in a directory with tracks you'd like to play there are a couple of options for adding them to the playlist.  You can add the entire directory (and all its subdirectories) by clicking either the 'list << dir' or 'dir >> list' buttons on the right.  'list << dir' appends the directory to the playlist, and 'dir >> list' prepends it.  You can also select individual tracks by clicking them, and then add them to the playlist using the 'list << tracks' or 'tracks >> list' buttons on the right side (these buttons only appear if there are music tracks inside the directory.)


  PLAYING TRACKS

  So, now that you've got some tracks loaded up, it's time to play them...  The transport buttons located on the bottom right of the table should be fairly obvious.  The small button above the transport buttons is the shuffle toggle button.  Above and to the right of the transport buttons is the volume slider.

  The tone arm moves with the track's progress, and you can seek within the track by clicking within the range of the arm's movement.

  The 'i' button at the top left toggles the info window.


  PLAYLISTS

  Tracks in the playlist can be selected by clicking on them, moved with the up and down arrow keys, and deleted with the 'remove tracks' button.  Playlists can be saved and loaded with, you guessed it, the 'save list' and 'load list' buttons.


  SETTINGS

  The settings manager can be opened with the small button next to the info window button at the top left of the table.  Once opened, you can set a default music directory for the browser, the scale of the player, background and text colors, text font and size, and the tag fields to be shown in the info window.

  Tag fields are marked with a leading and trailing pound sign (#field#) - anything else will be shown as is...  for example if you are listening to the 7th track of Electric Ladyland, tags are available, and you have set the title format to be "Track number #track-number# from the record #album# by #artist# is called #title#" - you will see "Track number 7 from the record Electric Ladyland by Jimi Hendrix is called Come On (Let The Good Times Roll)" displayed in the info window.  If tags are not available, the filename will be displayed instead.

  Hovering the mouse over the text in the info window will scroll it.


  ROCK AND ROLL, BUDDY
 
  So that's really about all there is to it.
  
