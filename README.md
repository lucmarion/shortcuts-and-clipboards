# Function:

##  Keyboard shortcuts:

Set up keyboard shortcuts to open/focus specified apps or folders, or launch specified files.<br>
If a shortcut is triggered while the desired app or directory is already open and focused, the app will be hidden, or the directory window will be closed.

##  Multiple clipboards:

*    Select text, and copy to a clipboard tied to the digits 0 - 9 with Ctrl + Option + <number_between_0_and_9>
*    Paste from that clipboard with Option + <number_between_0_and_9>
*    Show the contents of each of the 10 clipboards with Ctrl + Option + W. Hide the display by pressing Ctrl + Option + W again.
*    For permanent clipboards that are referred to regularly, open any of the Clipgroup txt files, and enter whatever is desired into each of the sections, 1 - 10. Load the group you want by using Ctrl + Option `, and selecting the desired group (when the GUI appears, you can either click the desired number, or press the desired number on your keyboard). Whenever the script is launched, ClipGroup1.txt is loaded by default.

# Initial Setup:

1. Install Hammerspoon: https://github.com/Hammerspoon/hammerspoon/releases/
(Currently this script is known to work on .9.90)
2. In Settings > Security & Privacy, navigate to the Privacy tab, select Accessibility, click the Lock icon in the lower left, enter your system credentials, check the box next to Hammerspoon.app in the list to the right, and click the Lock again.
3. From the hammer icon in the upper right, select Open Config. This will open init.lua.
4. Paste the contents of the included Lua into init.lua and Save.

# Window Title Setup:

In order for the toggle function to properly close an active directory window, it needs to know the path of the currently open window. The way it does this is by checking the window's title. By default, the window's title does not display its file path. To do this, do the following:

1. Open a Terminal window, and enter the following command:<br>
    `defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES;`
2. Hold down the Option key, right click the Finder icon in your Dock, and select Relaunch.
Opening any directory should show its filepath in its title now.

Should you ever want to revert the above change, you can enter the following command in a Terminal window:<br>
    `defaults write com.apple.finder _FXShowPosixPathInTitle -bool NO;`

# Keyboard Shortcut Setup:

1. Select the hammer icon in the upper right, and select Open Config.
2. Search for "--Shortcuts". Below the activate function, you will see a commented out line that follow this format:<br>
    `-- hs.hotkey.bind({'', ''}, '', function() activate('', '') end)`
3. First, uncomment the line (remove the preceding "--") to make it active.
4. Within the curly braces, there are two empty strings. These are the keyboard modifiers your shortcut will require. You can put however many or few you like (I would recommend at least one, or you will lose access to the default functionality of the final key you choose).
5. The parameter that follows the curly braces is the final key that will fire the shortcut.
So if I want my shortcut to fire with Command + Control + F, the first part of the line would look like this:<br>
    `hs.hotkey.bind({'cmd', 'ctrl'}, 'f'`
6. For the first empty parameter in the activate function, enter `'app'` if you would like this shortcut to toggle an app, or `'path'` if you would like it to toggle a directory or launch a file.
7. For the second parameter, enter the system name of the app you would like it to toggle, or the path of the directory or file you would like it to toggle/launch.
If you do not know the system name of the app you would like to toggle (they don't always match with what you'd think), you can manually open the desired app, and as long as this script is active, press Option + E to display the app's system name.
So if I wanted this shortcut to open Firefox, the full line would read as follows:<br>
    `hs.hotkey.bind({'cmd', 'ctrl'}, 'f', function() activate('app', 'Firefox') end)`
8. Duplicate this line, changing the shortcut keys and activation target, for as many shortcuts as you'd like.

That's it!