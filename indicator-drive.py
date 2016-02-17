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

	self.separator1_item = gtk.SeparatorMenuItem()
	self.separator1_item.show()

	self.Local_item = gtk.MenuItem("Open Drive folder")
        self.Local_item.connect("activate", self.openLocal)
        self.Local_item.show()

	self.Remote_item = gtk.MenuItem("Launch Drive website")
        self.Remote_item.connect("activate", self.openRemote)
        self.Remote_item.show()

	self.View_item = gtk.MenuItem("Recently changed files")
        self.View_item.connect("activate", self.doView)
        self.View_item.show()

	self.separator2_item = gtk.SeparatorMenuItem()
	self.separator2_item.show()

	self.Info_item = gtk.MenuItem("Account Info")
        self.Info_item.connect("activate", self.Info)
        self.Info_item.show()

	self.separator3_item = gtk.SeparatorMenuItem()
	self.separator3_item.show()

	self.setInterval_item = gtk.MenuItem("Change sync interval...")
        self.setInterval_item.connect("activate", self.setInterval)
        self.setInterval_item.show()

	self.Icon_item = gtk.MenuItem("Change indicator icon...")
        self.Icon_item.connect("activate", self.setIcon)
        self.Icon_item.show()

	self.separator4_item = gtk.SeparatorMenuItem()
	self.separator4_item.show()

	self.Quit_item = gtk.MenuItem("Quit Drive")
        self.Quit_item.connect("activate", self.Quit)
        self.Quit_item.show()

	self.menu.append(self.infoDrive_item)
	self.menu.append(self.separator1_item)
	self.menu.append(self.Local_item)
	self.menu.append(self.Remote_item)
	self.menu.append(self.View_item)
	self.menu.append(self.separator2_item)
	self.menu.append(self.Info_item)
	self.menu.append(self.separator3_item)
	self.menu.append(self.setInterval_item)
	self.menu.append(self.Icon_item)
	self.menu.append(self.separator4_item)
	self.menu.append(self.Quit_item)

    def infoDrive(self):
	os.system("while ! ping -c 1 -W 1 8.8.8.8; do sleep 1; done && /usr/local/indicator-drive/indicator-drive.sh drive_pull && sleep 1m && /usr/local/indicator-drive/indicator-drive.sh drive_monitor &")
	stat, out = commands.getstatusoutput("/usr/local/indicator-drive/indicator-drive.sh sync_status")
	return out

    def openLocal(self, dude):
	os.system("xdg-open 'Drive' &")

    def openRemote(self, dude):
	os.system("xdg-open 'https://drive.google.com/' &")

    def doView(self, dude):
	os.system("zenity --text-info --title=\"View history\" --filename=\"$HOME/.config/indicator-drive/history.log\" --width 680 --height 580 &")

    def Info(self, dude):
	os.system("zenity --info --title=\"Drive info\" --text=\"`cd $HOME/Drive && drive quota`\" &")

    def setInterval(self, dude):
	os.system("/usr/local/indicator-drive/indicator-drive.sh set_interval &")

    def setIcon(self, dude):
	os.system("/usr/local/indicator-drive/indicator-drive.sh change_icon &")

    def Quit(self, dude):
	os.system("/usr/local/indicator-drive/indicator-drive.sh quit")

    def ignore(*args):
	return gtk.TRUE

    def main(self):
        gtk.main()

if __name__ == "__main__":
    indicator = DriveIndicator()
    indicator.main()
