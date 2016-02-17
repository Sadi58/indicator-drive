#!/bin/bash

drive_monitor()
{
while inotifywait -qqr -e modify -e move -e create -e delete "$HOME/Drive/"
do
	notify-send "Drive Indicator" "Updating Drive website..." -i gtk-dialog-info &
	"/usr/local/indicator-drive/indicator-drive.sh" drive_push
done
}

drive_push()
{
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
pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
cd "$HOME/Drive"
drive diff -ignore-name-clashes -ignore-conflict -ignore-checksum &> "$HOME/.config/indicator-drive/remote.log"
drive push -no-prompt -ignore-name-clashes -ignore-conflict -ignore-checksum
echo "`date +'%Y-%m-%d %H:%M'` ▼ Change(s) in Drive website" >> "$HOME/.config/indicator-drive/history.log"
echo "—————————————————————" >> "$HOME/.config/indicator-drive/history.log"
cat "$HOME/.config/indicator-drive/remote.log" | sed -e "s/^File: //g" | grep "^/" | sed -e "s/$/ ► OVERWRITTEN on REMOTE/g" -e "s/ only on remote ► OVERWRITTEN on REMOTE/ ► DELETED on REMOTE/g" -e "s/ only on local ► OVERWRITTEN on REMOTE/ ► COPIED to REMOTE/g" -e "s/^\//☑ /g" >> "$HOME/.config/indicator-drive/history.log"
echo "════════════════════════════════════════════════════════════════════════════════" >> "$HOME/.config/indicator-drive/history.log"
sed -i -n '
1h
1!H
$ {
        g
        s/^[0-9].*\s▼ Change.*\sin\sDrive\s.*\n—*\n═*//g
        p
}
' "$HOME/.config/indicator-drive/history.log"
Lines="$(wc -l "$HOME/.config/indicator-drive/history.log" | awk '{print $1}')"
if [[ "$Lines" -gt 100 ]]
then
	n="$(expr "$Lines" - 100)"
	sed -ie "1,${n}d" "$HOME/.config/indicator-drive/history.log"
fi
interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
sleep "$interval"
"/usr/local/indicator-drive/indicator-drive.sh" drive_pull &
}

drive_pull()
{
while true
do
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
	cd "$HOME/Drive"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_push"
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	drive diff -ignore-name-clashes -ignore-conflict -ignore-checksum &> "$HOME/.config/indicator-drive/local.log"
	drive pull -no-prompt -ignore-name-clashes -ignore-conflict -ignore-checksum &>> "$HOME/.config/indicator-drive/local.log"
	Changes="$(grep "Everything is up\-to\-date" "$HOME/.config/indicator-drive/local.log")"
	if [[ -z "$Changes" ]]
	then
		notify-send "Drive Indicator" "Change(s) made in Drive folder!" -i gtk-dialog-info &
		echo "`date +'%Y-%m-%d %H:%M'` ▼ Change(s) in Drive folder" >> "$HOME/.config/indicator-drive/history.log"
		echo "—————————————————————" >> "$HOME/.config/indicator-drive/history.log"
		cat "$HOME/.config/indicator-drive/local.log" | sed -e "s/^File: //g" | grep "^/" | sed -e "s/$/ ► OVERWRITTEN on LOCAL/g" -e "s/ only on remote ► OVERWRITTEN on LOCAL/ ► COPIED to LOCAL/g" -e "s/ only on local ► OVERWRITTEN on LOCAL/ ► DELETED on LOCAL/g" -e "s/^\//☑ /g" >> "$HOME/.config/indicator-drive/history.log"
		echo "════════════════════════════════════════════════════════════════════════════════" >> "$HOME/.config/indicator-drive/history.log"
		sed -i -n '
1h
1!H
$ {
        g
        s/^[0-9].*\s▼ Change.*\sin\sDrive\s.*\n—*\n═*//g
        p
}
' "$HOME/.config/indicator-drive/history.log"
		Lines="$(wc -l "$HOME/.config/indicator-drive/history.log" | awk '{print $1}')"
		if [[ "$Lines" -gt 100 ]]
		then
			n="$(expr "$Lines" - 100)"
			sed -ie "1,${n}d" "$HOME/.config/indicator-drive/history.log"
		fi
	fi
	"/usr/local/indicator-drive/indicator-drive.sh" drive_monitor &
	interval="$(cat "$HOME/.config/indicator-drive/sync-interval")"
	sleep "$interval"
done
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
Sync="$(ps -e -o cmd | grep -c "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull" | egrep -v grep)"
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
		pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
		pkill -f "python /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
		pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
		kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
		"/usr/local/indicator-drive/indicator-drive.py" &
		pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh set_interval"
	fi
fi
}

change_icon()
{
menu()
{
im="zenity --list --radiolist --title=\"Change Icon\" --text=\"<b>Select icon to use:</b>\" --width 270 --height 170"
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
	cp -f "/usr/local/indicator-drive/drive-light.svg" "/usr/local/indicator-drive/drive.svg"
	pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	"/usr/local/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh change_icon"
fi
if echo $choice | grep "Dark" > /dev/null
then
	cp -f "/usr/local/indicator-drive/drive-dark.svg" "/usr/local/indicator-drive/drive.svg"
	pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	"/usr/local/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh change_icon"
fi
if echo $choice | grep "Color" > /dev/null
then
	cp -f "/usr/local/indicator-drive/drive-color.svg" "/usr/local/indicator-drive/drive.svg"
	pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
	kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
	"/usr/local/indicator-drive/indicator-drive.py" &
	pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh change_icon"
fi
}
menu
option
}

quit()
{
InterVal="$(cat "$HOME/.config/indicator-drive/sync-interval" | sed -e "s/m//g" -e "s/ //g")"
pkill -f "sleep $InterVal"
pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_pull"
pkill -f "/bin/bash /usr/local/indicator-drive/indicator-drive.sh drive_monitor"
kill -9 `ps -e -o pid,cmd | egrep -v grep | grep "inotifywait" | grep "Drive" | awk '{print$1}'`
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
