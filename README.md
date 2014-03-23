grive-indicator
===============

A very simple and lightweight indicator applet to synchronize with Google Drive using grive.

Based on the AMD indicator applet here: https://github.com/beidl/amd-indicator

Prerequisites
===============

1. Install "grive", "python-appindicator" and "zenity" (e.g. using using DEB package or "setup-1-grive-indicator" as below), AND
2. Have "grive" authenticated with your chosen Google account by (creating and) changing directory (cd) to "~/Google Drive" and then entering the terminal command "grive -a" in that directory (e.g. using "setup-2-grive" as below)
before beginning to use this indicator applet.

Installation
===============
1. Extract and install the DEB file in the arcive with "gdebi-gtk" application, and then make sure that Prerequisite 2 as above is met, if using this indicator for the first time, OR
2. Make first "setup-1-grive-indicator" and then "setup-2-grive" files executable and run in terminal in that order.

The "grive-indicator" should now be listed among startup applications and ready to start on next login.


Tests
===============
Successfully tested under: Ubuntu 13.10 (Unity), Linux Mint 16 (Cinnamon), Siduction 13.2 (Xfce)

ToDo
===============

1. Use a switch as in UbuntuOne indicator instead of the current info item in the menu.
2. Avoid root password prompt when changing icons.
3. Add a menu item to show a list of recently changed items (e.g. using a command like: inotifywait -r -e modify,attrib,moved_to,moved_from,move_self,create,delete,delete_self "$HOME/Google Drive")
4. Create also a simple GUI for grive initial setup (attempts to include "setup-2-grive" script in DEB package under "postinst" failed).
