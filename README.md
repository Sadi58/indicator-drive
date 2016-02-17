indicator-drive
===============

A very simple and lightweight indicator applet to synchronize with Google Drive using **drive** (https://github.com/odeke-em/drive).

![screenshot](indicator-drive-screenshot.png)

Important Notice
----------------------

This indicator is based on https://github.com/Sadi58/grive-indicator which used the obsolete **grive** client. The new **drive** client is currently under active development but it's not designed as a **synchronization tool** (at least not yet). Therefore this indicator has the same limitations as the "backend" Drive client, and its use for synchronization purposes might have some unforeseen and undesirable effects. For it essentially uses two commands, `drive push` and `drive pull` with options `-no-prompt -ignore-name-clashes -ignore-conflict -ignore-checksum` which end up mirroring the local folder on the remote Drive (push) and vice versa (pull).

Installation
----------------------

1. Install **drive**, **python-appindicator**, **zenity**, **inotifywait** and **indicator_drive** (e.g. using the `install-drive` and then `install-indicator-drive` scripts provided), AND

2. If using the **drive** client for the first time, have it authenticated by creating your local Google Drive directory (e.g. `~/Drive`) and then entering the terminal command `drive init ~/Drive` and following the instructions (i.e. click the url link, choose your Google account, copy and paste the code provided).

The indicator-drive should now be listed among startup applications and ready to start on next login.

Change Log
----------------------

- **0.90b:** Moved from Alpha to Beta stage
