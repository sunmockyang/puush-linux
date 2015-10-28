#!/bin/bash

PUUSH_CONFIG_FILE="$HOME/.puush"
PUUSH_API_KEY=""

# Puush for Ubuntu/linux
# Owner : Sunmock Yang
# www.sunmock.com
# May 2014
#
# Dependencies:
# - gnome-screenshot
# - curl
# - zenity
# - xclip
# - notify-send
#
# Licence : Beerware
#
# Instructions:
# - Configure your puush API key by adding PUUSH_API_KEY to the $HOME/.puush file
#   - You can find your API key at http://puush.me/account/settings
# - Place this file wherever you want (/usr/local/bin)
# - Set up keyboard shortcuts within linux (in Ubuntu it's system settings > keyboard > keyboard shortcuts > custom shortcuts)
#
# 		command			description		(recommended keyboard shortcut)
#		---------------------------------------------------------------
#		puush -c		puush window	(Ctrl + Shift + 2/@)
#		puush -a		puush desktop	(Ctrl + Shift + 3/#)
#		puush -b		area puush		(Ctrl + Shift + 4/$)
#		puush -d		file upload		(Ctrl + Shift + U)
#
#
# Notes:
# - Link(s) will be copied into clipboard and appear in notifications
# - puush curl upload code borrowed from online sources

function createDefaultConfigFile()
{
    echo "# Configure your puush API key here" >> $PUUSH_CONFIG_FILE
    echo "# - You can find your API key at http://puush.me/account/settings" >> $PUUSH_CONFIG_FILE
    echo "PUUSH_API_KEY=\"\"" >> $PUUSH_CONFIG_FILE
    echo >> $PUUSH_CONFIG_FILE
}

# Usage: puushFile [fileName]
function puushFile ()
{
	if [ -z "$1" ]; then
		echo "No file specified"
		exit 1
	elif [ ! -f "$1" ]; then
		echo "Puush cancelled"
		exit 1
	fi

	fileURL=`curl "https://puush.me/api/up" -# -F "k=$PUUSH_API_KEY" -F "z=waifu" -F "f=@$1" | sed -E 's/^.+,(.+),.+,.+$/\1\n/'`

	if [ ! -z "$fileURL" ]; then
		#Copy link to clipboard, show notification
		printf $fileURL | xclip -selection "clipboard"
		notify-send -i "$( cd "$( dirname "$0" )" && pwd )/puush.png" -t 2000 "puush complete!" "$fileURL"
	fi
}

function helpText ()
{
  printf "_____________ puush for linux _____________\n"
  printf "Created by Sunmock Yang using the puush api\n"
  printf "\n"
  printf "Usage:\n"
  printf "  puush [OPTIONS] [PATH]\n"
  printf "\n"
  printf "OPTIONS:\n"
  printf "  -a                 puush entire desktop\n"
  printf "  -b                 select area to puush\n"
  printf "  -c                 puush current window\n"
  printf "  -d                 puush specific file (opens file dialog)\n"
  printf "\n"
  printf "  --help,-h          show this page\n"
  printf "\n"
  printf "PATH:\n"
  printf "  PATH               optional: path of file to puush\n"
}

function generateFileName () { echo "/tmp/puush-linux ($(date +"%Y-%m-%d at %I.%M.%S")).png"; }

if [ -f $PUUSH_CONFIG_FILE ]; then
  source $PUUSH_CONFIG_FILE
else
  echo "Creating default config file in $PUUSH_CONFIG_FILE"
  createDefaultConfigFile
fi

if [ -z "$PUUSH_API_KEY" ]; then
  echo "Set the variable PUUSH_API_KEY in $PUUSH_CONFIG_FILE" >/dev/stderr
  echo "You can find your API key at http://puush.me/account/settings" >/dev/stderr

  notify-send -i "$( cd "$( dirname "$0" )" && pwd )/puush.png" "Set the variable PUUSH_API_KEY in $PUUSH_CONFIG_FILE" "You can find your API key at http://puush.me/account/settings"

  exit 1

elif [ -z "$1" ]; then
	echo "No file entered."
	helpText
  exit 1

fi

#Get file to puush and puush it
case "$1" in
	-a)
		echo "Whole Desktop"
			fileName=$(generateFileName)
			gnome-screenshot -f "$fileName"
			puushFile "$fileName"
		;;

	-b)
		echo "Area"
			fileName=$(generateFileName)
			gnome-screenshot -a -f "$fileName"
			puushFile "$fileName"
		;;

	-c)
		echo "Window"
			fileName=$(generateFileName)
			gnome-screenshot -w -f "$fileName"
			puushFile "$fileName"
		;;

	-d)
		echo "File Upload"
			fileName=`zenity --file-selection`
			puushFile "$fileName"
		;;

	-h|--help)
		helpText
		exit 0
		;;
		
	*)
		echo "Upload $1"
			puushFile "$1"
		;;
		
esac
