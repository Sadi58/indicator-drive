#!/bin/bash

drive_sync()
{
cd "$HOME/Drive"
while true
do
drive pull -no-prompt
drive push -no-prompt
sleep 5m
done
}

indicator_restart()
{
killall "drive"
killall "/usr/local/indicator-grive/indicator-grive.sh drive-sync"
sleep 5
/usr/local/indicator-grive/indicator-grive.sh grive-sync &
exit 0
}

status()
{
CurrentInterval="$(grep "sleep" "/usr/local/indicator-drive/indicator-drive.sh" | sed -e 's/sleep //g')"
sleep 5 && ps -U root -u root -N | grep "drive-sync" | sed -e "s/  / /g" | awk -F" " '{print $4}' | sed -e "s/-sync/ is syncing every $CurrentInterval/g"
}

set-interval()
{
OLD=$(grep "sleep" "/usr/local/indicator-grive/grive-sync" | sed -e 's/sleep //g' | sed -e 's/m//g')
zenity --scale --title="Drive sync interval" --text="                    Current interval is<b> $OLD </b>minute(s).\n                    Set new interval using the scale." --min-value=1 --max-value=180 --value=1 --step=1 > "/tmp/drive-sync-interval"
NEW=$(cat /tmp/grive-sync-interval)
if [ "$NEW" != "" ]
then
	sed -i "s/$OLD/$NEW/g" "/usr/local/indicator-drive/indicator-drive.sh"
fi
}

icon4darktheme()
{
cp -f "/usr/local/indicator-drive/drive-dark.png" "/usr/local/indicator-drive/drive.png"
}

icon4lighttheme()
{
cp -f "/usr/local/indicator-drive/drive-light.png" "/usr/local/indicator-drive/drive.png"
}

restart()
{
notify-send "Drive indicator is restarting..." -i gtk-dialog-info -t 3000 -u normal &
pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
killall "drive"
killall "/usr/local/indicator-drive/indicator-drive.sh drive-sync"
"/usr/local/indicator-drive/indicator-drive.py"
}

quit()
{
pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
killall "/usr/local/indicator-drive/indicator-drive.sh drive-sync"
}
