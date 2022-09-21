# Function:

## Keyboard shortcuts:

Set up keyboard shortcuts to open/focus specified apps or folders, or launch specified files.<br>
If a shortcut is triggered while the desired app or directory is already open and focused, the app will be hidden, or the directory window will be closed.

## Multiple clipboards:

- Select text, and copy to a clipboard tied to one the digits between 0 - 9 with Ctrl + Option + <number_to_copy_to>
- Paste from that clipboard with Option + <number_copied_to>
- Show the contents of each of the 10 clipboards with Ctrl + Option + W. Hide the display by pressing Ctrl + Option + W again.
- For permanent clipboards that are referred to regularly, open any of the Clipgroup txt files, and enter whatever is desired into each of the sections, 1 - 10. Load the group you want by using Ctrl + Option \`, and selecting the desired group (when the GUI appears, you can either click the desired number, or press the desired number on your keyboard). Whenever the script is launched, ClipGroup1.txt is loaded by default.
- To open the Clipgroup text file that is currently loaded, press Ctrl + Option + -. If you save any changes, remember to reload the group with Ctrl + Option + `.
- Something I added when I was writing daily reports: Option + -, will paste the current date in M/D/YYYY format.

# Initial Setup:

1. Install Hammerspoon: https://github.com/Hammerspoon/hammerspoon/releases/
   (Currently this script is known to work on .9.90)
2. In Settings > Security & Privacy, navigate to the Privacy tab, select Accessibility, click the Lock icon in the lower left, enter your system credentials, check the box next to Hammerspoon.app in the list to the right, and click the Lock again.
3. From the hammer icon in the upper right, select Preferences.
4. Check the "Launch Hammerspoon at login" box, and close the window.
5. From the same hammer icon, select Open Config. This will open init.lua.
6. Paste the contents of the included Lua into init.lua and find the variables selectorPath and clipboardPath.
7. Update those paths to point at where you set the folder. In my case, they would look something like:<br>
   `selectorPath = '/Users/lucmarion/Hammerspoon/shortcuts-and-clipboards/selector.html'`<br>
   `clipboardPath = '/Users/lucmarion/Hammerspoon/shortcuts-and-clipboards/ClipGroup'`<br>
   (You may notice that the clipboardPath variable, ending in "ClipGroup", is not actually pointing to a specific file in the directory. This is intentional. The script will tag the number and extension to the end when needed.)
8. Save the file.

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
8. In some unusual cases, the name of the app is different when it isn't launched. Visual Studio Code, for example, is known to the system as "Visual Studio Code" when not launched, and "Code" when launched. This means that a line set up as shown above, will not launch the app, but will activate and hide it if it has already been launched.
   In these cases, you can add a third parameter to the activate() function, listing its unlaunched name, in order for it to launch as well.
   So the line to Visual Studio Code might look like this:<br>
   `hs.hotkey.bind({'cmd', 'ctrl'}, 'v', function() activate('app', 'Code', Visual Studio Code) end)`
9. Duplicate this line, changing the shortcut keys and activation target, for as many shortcuts as you'd like.

That's it!
