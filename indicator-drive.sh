#!/bin/bash

drive-sync()
{
cd "$HOME/Drive"
while true
do
drive pull -no-prompt
drive push -no-prompt
sleep 5m
done
}

drive-restart()
{
killall "/usr/local/indicator-grive/indicator-grive.sh drive-sync"
"/usr/local/indicator-grive/indicator-grive.sh drive-sync" &
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

indicator-restart()
{
killall "/usr/local/indicator-drive/indicator-drive.sh drive-sync"
pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
"/usr/local/indicator-drive/indicator-drive.py"
}

quit()
{
pkill -f "python /usr/local/indicator-drive/indicator-drive.py"
killall "/usr/local/indicator-drive/indicator-drive.sh drive-sync"
}
