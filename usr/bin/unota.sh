#!/bin/bash

iscmdmissing () {
CLITOOL=$( which $1 )
if [[ $CLITOOL = "" ]]; then
    return 0
else
	return 1
fi
}

gainroot () {
ROOTSTATE=$( sudo -n true )
	if [[ $ROOTSTATE == *"a password is required"* ]]; then
		echo "[•] Please, enter administrator password and hit enter."
		sudo echo "" > /dev/null
	else
		echo "[•] This is already an administrator session."
	fi
}

if [ \( "$1" = "" \) -o \( "$2" = "" \) ]; then
	echo "Usage: unota.sh [payload_file] [output_directory]"
	exit
	else

		if [ -f "$1" ]; then
			PAYLOAD=$1
		else
	echo "ERROR: file '$1' does not exist."
	exit
		fi

		if [ -d "$2" ]; then
			OUTDIR=$2
		else
	echo "ERROR: directory '$2' does not exist."
	exit
		fi
fi

if iscmdmissing otaa; then
	echo "[•] Downloading otaa..."
	cd /tmp
	gainroot
	curl -s -download https://raw.githubusercontent.com/BlackGeekTutorial/iOSOTAPayloadExtractor/master/dependencies/src/otaa.c > otaa.c
	sudo cc otaa.c -o /usr/bin/otaa
	sudo chmod +x /usr/bin/otaa
fi

if iscmdmissing pbzx; then
	echo "[•] Downloading pbzx..."
	cd /tmp
	gainroot
	curl -s -download https://raw.githubusercontent.com/BlackGeekTutorial/iOSOTAPayloadExtractor/master/dependencies/src/pbzx.c > pbzx.c
	sudo cc pbzx.c -o /usr/bin/pbzx
	sudo chmod +x /usr/bin/pbzx
fi

rm -rf "/tmp/unpack" && mkdir "/tmp/unpack" && cd "/tmp/unpack"
echo "[•] Getting Payload's Data flow..."
pbzx < $PAYLOAD > p.xz
echo "[•] Uncompressing Data flow..."
xz --decompress p.xz > /dev/null 2>&1
cd $OUTDIR
echo "[•] Extracting..."
otaa -e '*' "/tmp/unpack/p" > /dev/null 2>&1
rm -rf "/tmp/unpack"
echo "[•] DONE!"