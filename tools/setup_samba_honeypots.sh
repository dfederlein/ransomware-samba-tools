#!/bin/bash
# Setup samba honeypots to detect ransomware activity
# Kuko Armas <kuko@canarytek.com>

# Bait files dir. You can put your own files here
bait_files_dir="/usr/local/share/bait-files"
# Detection string
# **NOTE:** Make sure you add this files in the honeypot_re in the fail2ban samba-filter file
bait_string="ShahZeZ6"
# This should be a name that windows finds first
honey_folder="____Secret_Data____"

if [ "x$1" == "x" ]; then
	# No directory givem, get shares path from samba config
	shares=`testparm -s 2>/dev/null | grep path | awk '{ print $3}'`
else
	# Setup honeypot on given directory
	shares="$1"
fi


for share in $shares; do
	echo "Setting honeypot in $share"
	mkdir -p "/$share/$honey_folder"
	# Copy files
	for fullfile in $bait_files_dir/*; do
		filename=$(basename "$fullfile")
		extension="${filename##*.}"
		filename="${filename%.*}"
		cp $fullfile /$share/$honey_folder/$filename-$bait_string.$extension
	done
	# Everyone needs write permissions here...
	chmod -R 777 "/$share/$honey_folder"
done
