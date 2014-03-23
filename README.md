grive-indicator
===============

A very simple and lightweight Ubuntu indicator applet to synchronize with Google Drive using grive.

Based on the AMD indicator applet here: https://github.com/beidl/amd-indicator

Prerequisites
===============

You need (1) to install "grive", "python-appindicator" and "zenity", and also (2) to have "grive" authenticated with your chosen Google account by (creating and) changing directory (cd) to "~/Google Drive" and then entering the terminal command "grive -a" in that directory before beginning to use this indicator applet.

Installation
===============
1. Open the DEB file with gdebi-gtk application.
2. Make the setup file executable and run it in terminal.

ToDo
===============

1. Use a switch as in UbuntuOne indicator instead of the current info item in the menu.
2. Avoid root password prompt when changing icons.
3. Add a menu item to show a list of recently changed items (e.g. using a command like: inotifywait -r -e modify,attrib,moved_to,moved_from,move_self,create,delete,delete_self "$HOME/Google Drive")
4. Create also a simple GUI for grive initial setup.