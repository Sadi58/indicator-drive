grive-indicator
===============

A very simple and lightweight indicator applet to synchronize with Google Drive.

Based on the AMD indicator here: https://github.com/beidl/amd-indicator

Prerequisites
===============

You need "grive", python module "appindicator" and "zenity" installed, and also to have "grive" authenticated with your Google account by (creating and) changing directory (cd) to "~/Google Drive" and then entering the terminal command "grive -a" in that directory.

Installation
===============

Make the setup file executable and run it.

ToDo
===============

1. Use a switch as in UbuntuOne indicator instead of the current info item in the menu.
2. Prevent zenity cancel button from deleting the interval value.
3. Avoid root password prompt when changing icons.
4. Add a menu item to show a list of recently changed items, using this command: inotifywait -r -e modify,attrib,moved_to,moved_from,move_self,create,delete,delete_self "$HOME/Google Drive"
5. Incorporate grive setup (google account authentication) and local folder creation?
