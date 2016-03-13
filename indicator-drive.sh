#!/bin/bash

drive_monitor()
{
while inotifywait -qqr -e modify -e move -e create -e delete "$HOME/Drive/"
do
	"/usr/share/indicator-drive/indicator-drive.sh" drive_push
done
}

drive_push()
{
while ! wget -q -O /dev/null --no-cache http://www.google.com/; do sleep 10; done
notify-send "Drive Indicator" "Updating Drive website..." -i gtk-dialog-info &
if [[ ! -d "$HOME/.config/indicator-drive/" ]]
then
	mkdir "$HOME/.config/indicator-drive/"
fi
if [[ ! -f "$HOME/.config/indicator-drive/remote.log" ]]
then
	touch "$HOME/.config/indicator-drive/remote.log"
fi
if [[ ! -f "$HOME/.config/indicator-drive/history.log" ]]
then
	touch "$HOME/.config/indicator-drive/history.log"
fi
if [[ ! -f "$HOME/.config/indicator-drive/sync-interval" ]]
then
	echo "5m" >	"$HOME/.config/indicator-drive/sync-interval"
fi
interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
pkill -f "sleep $interval"
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
cd "$HOME/Drive"
drive diff -skip-content-check -ignore-name-clashes -ignore-conflict -ignore-checksum &> "$HOME/.config/indicator-drive/remote.log"
ItemsTotal="$(find "$HOME/Drive" -print | wc -l)"
ItemsToDelete="$(grep -c '\( only on remote\|^\- \/\)' "$HOME/.config/indicator-drive/remote.log")"
ItemsToWrite="$(grep -c '\( only on local\|^+ \/\)' "$HOME/.config/indicator-drive/remote.log")"
ItemsToModify="$(grep -c '^File: ' "$HOME/.config/indicator-drive/remote.log")"
ItemsChanged="$(wc -l "$HOME/.config/indicator-drive/remote.log" | awk '{print $1}')"
ItemsDifference="$(expr "$ItemsTotal" / 3 - "$ItemsChanged")"
if [[ "$ItemsDifference" -lt 0 ]]
then
	'/usr/bin/canberra-gtk-play' --id="dialog-warning" &
	zenity --text-info --title="Drive Indicator" --filename="$HOME/.config/indicator-drive/remote.log" --width=600 --height=500 &
	zenity --question --title="Drive Indicator" --text="<b><i>Unusual amount of changes detected\!</i></b>\nItems to be DELETED in Drive website: <b>$ItemsToDelete</b>\nItems to be COPIED to Drive website: <b>$ItemsToWrite</b>\nItems to be MODIFIED in Drive website: <b>$ItemsToModify</b>\n<b>Would you like to abort synchronization\nin order to check Drive folder and website\?</b>" --cancel-label "Continue" --ok-label "Abort" --width=300 --height=150
	if [ $? = 0 ]
	then
		"/usr/share/indicator-drive/indicator-drive.sh" sync_pause
	fi
fi
drive push -no-prompt -ignore-name-clashes -ignore-conflict -ignore-checksum
echo "`date +'%Y-%m-%d %H:%M'` ▼ Change(s) in Drive website" >> "$HOME/.config/indicator-drive/history.log"
echo "—————————————————————" >> "$HOME/.config/indicator-drive/history.log"
cat "$HOME/.config/indicator-drive/remote.log" | sed -e "s/^File: //g" | grep "^/" | sed -e "s/$/ ► OVERWRITTEN on REMOTE/g" -e "s/ only on remote ► OVERWRITTEN on REMOTE/ ► DELETED on REMOTE/g" -e "s/ only on local ► OVERWRITTEN on REMOTE/ ► COPIED to REMOTE/g" -e "s/^\//☑ \//g" >> "$HOME/.config/indicator-drive/history.log"
cat "$HOME/.config/indicator-drive/remote.log" | grep " err: googleapi: " | sed -e "s/ err: googleapi: / ☛ /g" -e "s/^push: /☒ /g" >> "$HOME/.config/indicator-drive/history.log"
echo "════════════════════════════════════════════════════════════════════════════════" >> "$HOME/.config/indicator-drive/history.log"
Lines="$(wc -l "$HOME/.config/indicator-drive/history.log" | awk '{print $1}')"
if [[ "$Lines" -gt 100 ]]
then
	n="$(expr "$Lines" - 100)"
	sed -ie "1,${n}d" "$HOME/.config/indicator-drive/history.log"
fi
"/usr/share/indicator-drive/indicator-drive.sh" drive_pull &
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_push"
}

drive_pull()
{
while true
do
	while ! wget -q -O /dev/null --no-cache http://www.google.com/; do sleep 10; done
	if [[ ! -d "$HOME/.config/indicator-drive/" ]]
	then
		mkdir "$HOME/.config/indicator-drive/"
	fi
	if [[ ! -f "$HOME/.config/indicator-drive/local.log" ]]
	then
		touch "$HOME/.config/indicator-drive/local.log"
	fi
	if [[ ! -f "$HOME/.config/indicator-drive/history.log" ]]
	then
		touch "$HOME/.config/indicator-drive/history.log"
	fi
	if [[ ! -f "$HOME/.config/indicator-drive/sync-interval" ]]
	then
		echo "5m" >	"$HOME/.config/indicator-drive/sync-interval"
	fi
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	pkill -f "sleep $interval"
	iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
	if [ "$iNotify" != 0 ]
	then
		kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	fi
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
	cd "$HOME/Drive"
	drive diff -skip-content-check -ignore-name-clashes -ignore-conflict -ignore-checksum &> "$HOME/.config/indicator-drive/local.log"
	if [ ! -s "$HOME/.config/indicator-drive/local.log" ]
	then
		"/usr/share/indicator-drive/indicator-drive.sh" drive_monitor &
		sleep "$interval"
	else
		ItemsTotal="$(find "$HOME/Drive" -print | wc -l)"
		ItemsToDelete="$(grep -c '\( only on local\|^\- \/\)' "$HOME/.config/indicator-drive/local.log")"
		ItemsToWrite="$(grep -c '\( only on remote\|^+ \/\)' "$HOME/.config/indicator-drive/local.log")"
		ItemsToModify="$(grep -c '^File: ' "$HOME/.config/indicator-drive/local.log")"
		ItemsChanged="$(wc -l "$HOME/.config/indicator-drive/local.log" | awk '{print $1}')"
		ItemsDifference="$(expr "$ItemsTotal" / 3 - "$ItemsChanged")"
		if [[ "$ItemsDifference" -lt 0 ]]
		then
			'/usr/bin/canberra-gtk-play' --id="dialog-warning" &
			zenity --text-info --title="Drive Indicator" --filename="$HOME/.config/indicator-drive/local.log" --width=600 --height=500 &
			zenity --question --title="Drive Indicator" --text="<b><i>Unusual amount of changes detected\!</i></b>\nItems to be DELETED in Drive folder: <b>$ItemsToDelete</b>\nItems to be COPIED to Drive folder: <b>$ItemsToWrite</b>\nItems to be MODIFIED in Drive folder: <b>$ItemsToModify</b>\n<b>Would you like to abort synchronization\nin order to check Drive folder and website\?</b>" --cancel-label "Continue" --ok-label "Abort" --width=300 --height=150
			if [ $? = 0 ]
			then
				"/usr/share/indicator-drive/indicator-drive.sh" sync_pause
			fi
		fi
		drive pull -no-prompt -ignore-name-clashes -ignore-conflict -ignore-checksum
		echo "`date +'%Y-%m-%d %H:%M'` ▼ Change(s) in Drive folder" >> "$HOME/.config/indicator-drive/history.log"
		echo "—————————————————————" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | sed -e "s/^File: //g" | grep "^/" | sed -e "s/$/ ► OVERWRITTEN on LOCAL/g" -e "s/ only on remote ► OVERWRITTEN on LOCAL/ ► COPIED to LOCAL/g" -e "s/ only on local ► OVERWRITTEN on LOCAL/ ► DELETED on LOCAL/g" -e "s/^\//☑ \//g" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | grep "^+ /" | sed -e "s/$/ ► COPIED to LOCAL/g" -e "s/^+ /☑ /g" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | grep "^M /" | sed -e "s/$/ ► OVERWRITTEN on LOCAL/g" -e "s/^M /☑ /g" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | grep "^- /" | sed -e "s/$/ ► DELETED on LOCAL/g" -e "s/^\- /☑ /g" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | grep " err: googleapi: " | sed -e "s/ err: googleapi: / ☛ /g" -e "s/^pull: /☒ /g" >> "$HOME/.config/indicator-drive/history.log"
		echo "════════════════════════════════════════════════════════════════════════════════" >> "$HOME/.config/indicator-drive/history.log"
		Lines="$(wc -l "$HOME/.config/indicator-drive/history.log" | awk '{print $1}')"
		if [[ "$Lines" -gt 100 ]]
		then
			n="$(expr "$Lines" - 100)"
			sed -ie "1,${n}d" "$HOME/.config/indicator-drive/history.log"
		fi
		'/usr/bin/canberra-gtk-play' --id="dialog-information" &
		notify-send "Drive Indicator" "Updated Drive folder!" -i gtk-dialog-info &
		"/usr/share/indicator-drive/indicator-drive.sh" drive_monitor &
		sleep "$interval"
	fi
done
}

sync_pause()
{
interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
pkill -f "sleep $interval"
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
if [ "$iNotify" != 0 ]
then
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
fi
}

sync_status()
{
if [[ ! -d "$HOME/.config/indicator-drive/" ]]
then
	mkdir "$HOME/.config/indicator-drive/"
	echo "5m" >	"$HOME/.config/indicator-drive/sync-interval"
else
	if [[ ! -f "$HOME/.config/indicator-drive/sync-interval" ]]
	then
		echo "5m" >	"$HOME/.config/indicator-drive/sync-interval"
	fi
fi
Sync="$(ps -e -o cmd | grep -c "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull" | egrep -v grep)"
if [ "$Sync" -eq 0 ]
then
	echo "No auto sync"
else
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	echo "Syncs every $interval"
fi
}

set_interval()
{
if [[ ! -d "$HOME/.config/indicator-drive/" ]]
then
	mkdir "$HOME/.config/indicator-drive/"
fi
if [[ ! -f "$HOME/.config/indicator-drive/sync-interval" ]]
then
	echo "5m" >	"$HOME/.config/indicator-drive/sync-interval"
fi
interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
NewInterval="$(zenity --scale --title="Drive Sync Interval" --text="Current sync interval is <b>$interval</b>.\nSet new interval using the scale below:" --min-value="1" --max-value="180" --value="5" --step="1")"
if [[ -z "$NewInterval" ]]
then
	notify-send "Drive Indicator" "Sync interval not changed!" -i gtk-dialog-info &
else
	InterVal="$(cat "$HOME/.config/indicator-drive/sync-interval" | sed -e "s/m//g" -e "s/ //g")"
	if [[ "$NewInterval" == "$InterVal" ]]
	then
		notify-send "Drive Indicator" "Sync interval not changed!" -i gtk-dialog-info &
	else
		if [[ "$NewInterval" == "1" ]]
		then
			notify-send "Drive Indicator" "Sync interval changed to $NewInterval minute" -i gtk-dialog-info &
		else
			notify-send "Drive Indicator" "Sync interval changed to $NewInterval minutes" -i gtk-dialog-info &
		fi
		echo "$NewInterval m" > "$HOME/.config/indicator-drive/sync-interval"
		sed -ie "s/ //g" "$HOME/.config/indicator-drive/sync-interval"
		pkill -f "sleep $interval"
		pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
		iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
		if [ "$iNotify" != 0 ]
		then
			kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
		fi
		pkill -f "python /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
		pkill -f "python /usr/share/indicator-drive/indicator-drive.py"
		"/usr/share/indicator-drive/indicator-drive.py" &
		pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh set_interval"
	fi
fi
}

change_icon()
{
menu()
{
im="zenity --list --radiolist --title=\"Change Icon\" --text=\"<b>Select icon to use:</b>\" --width=270 --height=170"
im=$im" --column=\"☑\" --column \"Options\" --column \"Description\" "
im=$im"FALSE \"Light\" \"Icon for dark panels\" "
im=$im"FALSE \"Dark\" \"Icon for light panels\" "
im=$im"FALSE \"Color\" \"Icon for all panels\" "
}
option()
{
choice=`echo $im | sh -`
if echo $choice | grep "Light" > /dev/null
then
	cp -f "/usr/share/indicator-drive/drive-light.svg" "/usr/share/indicator-drive/drive.svg"
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	pkill -f "sleep $interval"
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
	iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
	if [ "$iNotify" != 0 ]
	then
		kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	fi
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "python /usr/share/indicator-drive/indicator-drive.py"
	"/usr/share/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh change_icon"
fi
if echo $choice | grep "Dark" > /dev/null
then
	cp -f "/usr/share/indicator-drive/drive-dark.svg" "/usr/share/indicator-drive/drive.svg"
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	pkill -f "sleep $interval"
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
	iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
	if [ "$iNotify" != 0 ]
	then
		kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	fi
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "python /usr/share/indicator-drive/indicator-drive.py"
	"/usr/share/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh change_icon"
fi
if echo $choice | grep "Color" > /dev/null
then
	cp -f "/usr/share/indicator-drive/drive-color.svg" "/usr/share/indicator-drive/drive.svg"
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	pkill -f "sleep $interval"
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
	iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
	if [ "$iNotify" != 0 ]
	then
		kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	fi
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "python /usr/share/indicator-drive/indicator-drive.py"
	"/usr/share/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh change_icon"
fi
}
menu
option
}

quit()
{
interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
pkill -f "sleep $interval"
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_pull"
iNotify="$(ps x | egrep -v grep | grep "inotifywait" | grep -c "Drive")"
if [ "$iNotify" != 0 ]
then
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
fi
pkill -f "/bin/bash /usr/share/indicator-drive/indicator-drive.sh drive_monitor"
pkill -f "python /usr/share/indicator-drive/indicator-drive.py"
}

##############

if [ $# -eq 0 ]
then
	echo "You should specify a function as parameter"
	exit 1
else
	for func do
		[ "$(type -t -- "$func")" = function ] && "$func"
	done
fi

exit 0
