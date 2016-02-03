#!/usr/bin/env python
import gtk
import appindicator
import os
import commands
import gtk
import sys

class DriveIndicator:
    def __init__(self):
	self.ind = appindicator.Indicator("Drive Indicator",
                                           "indicator-messages",
                                           appindicator.CATEGORY_APPLICATION_STATUS)
	self.ind.set_status(appindicator.STATUS_ACTIVE)
	self.ind.set_attention_icon("indicator-messages-new")
	self.ind.set_icon_theme_path("/usr/local/indicator-drive/")
	self.ind.set_icon('drive')
        self.menu_setup()
        self.ind.set_menu(self.menu)
    def menu_setup(self):
        self.menu = gtk.Menu()

	self.infoDrive_item = gtk.MenuItem(self.infoDrive())
	self.infoDrive_item.set_sensitive(False)
	self.infoDrive_item.show()

	self.Restart_item = gtk.MenuItem("Sync now / restart")
        self.Restart_item.connect("activate", self.doRestart)
        self.Restart_item.show()

	self.setInterval_item = gtk.MenuItem("Change sync interval")
        self.setInterval_item.connect("activate", self.setInterval)
        self.setInterval_item.show()

	self.seperator1_item = gtk.SeparatorMenuItem()
	self.seperator1_item.show()

	self.Remote_item = gtk.MenuItem("Open remote Drive")
        self.Remote_item.connect("activate", self.openRemote)
        self.Remote_item.show()

	self.Local_item = gtk.MenuItem("Open local Drive")
        self.Local_item.connect("activate", self.openLocal)
        self.Local_item.show()

	self.seperator2_item = gtk.SeparatorMenuItem()
	self.seperator2_item.show()

	self.DarkTheme_item = gtk.MenuItem("Use dark theme icon")
        self.DarkTheme_item.connect("activate", self.setDarkTheme)
        self.DarkTheme_item.show()

	self.LightTheme_item = gtk.MenuItem("Use light theme icon")
        self.LightTheme_item.connect("activate", self.setLightTheme)
        self.LightTheme_item.show()

	self.seperator3_item = gtk.SeparatorMenuItem()
	self.seperator3_item.show()

	self.Quit_item = gtk.MenuItem("Quit")
        self.Quit_item.connect("activate", self.Quit)
        self.Quit_item.show()

	self.menu.append(self.infoDrive_item)
	self.menu.append(self.Restart_item)
	self.menu.append(self.setInterval_item)
	self.menu.append(self.seperator1_item)
	self.menu.append(self.Remote_item)
	self.menu.append(self.Local_item)
	self.menu.append(self.seperator2_item)
	self.menu.append(self.DarkTheme_item)
	self.menu.append(self.LightTheme_item)
	self.menu.append(self.seperator3_item)
	self.menu.append(self.Quit_item)

    def infoDrive(self):
	os.system("/usr/local/indicator-drive/indicator-drive.sh drive-restart")
	stat, out = commands.getstatusoutput("/usr/local/indicator-drive/indicator-drive.sh status")
	out = out.replace("drive", "Drive")
	return out

    def doRestart(self, dude):
	os.system("/usr/local/indicator-drive/indicator-drive.sh indicator-restart")

    def setInterval(self, dude):
	os.system("sudo /usr/local/indicator-drive/indicator-drive.sh set-interval && /usr/local/indicator-drive/indicator-drive.sh indicator-restart")

    def openRemote(self, dude):
	os.system("xdg-open 'https://drive.google.com/'")

    def openLocal(self, dude):
	os.system("xdg-open 'Drive'")

    def setDarkTheme(self, dude):
	os.system("cp -f '/usr/local/indicator-drive/drive-dark.png' '/usr/local/indicator-drive/drive.png' && '/usr/local/indicator-drive/indicator-drive.sh indicator-restart'")

    def setLightTheme(self, dude):
	os.system("cp -f '/usr/local/indicator-drive/drive-light.png' '/usr/local/indicator-drive/drive.png' && '/usr/local/indicator-drive/indicator-drive.sh indicator-restart'")

    def Quit(self, dude):
	os.system("/usr/local/indicator-drive/indicator-drive.sh quit")

    def ignore(*args):
	return gtk.TRUE

    def main(self):
        gtk.main()

if __name__ == "__main__":
    indicator = DriveIndicator()
    indicator.main()
