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
4. Incorporate grive setup (google account authentication) and local folder creation?
