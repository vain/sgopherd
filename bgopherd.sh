#!/bin/bash

# ------------------------------------------------------------------
# "THE PIZZA-WARE LICENSE" (Revision 42):
# Peter Hofmann <pcode@uninformativ.de> wrote this file. As long as you
# retain this notice you can do whatever you want with this stuff. If
# we meet some day, and you think this stuff is worth it, you can buy
# me a pizza in return.
# ------------------------------------------------------------------


# Find and load config.
config=/etc/bgopherd.conf

while getopts c: name; do
	case $name in
		c) config="$OPTARG" ;;
	esac
done

. "$config" || { echo "Unable to load config file." >&2; exit 1; }

# Library functions.
rel2abs()
{
	[[ -d "$1" ]] && { (cd -- "$1"; echo "$PWD"); return; }
	[[ -f "$1" ]] && { (cd -- "${1%/*}"; echo "$PWD/${1##*/}"); return; }
}

dirEmpty()
{
	set -- "$1"/*
	[[ ! -e "$1" ]]
}

parseIndex()
{
	rel=$1
	shift

	sed \
		-e '/^\[/! { s/.*/i&\t-\t-\t0/ }' \
		-e '/^\[/ { s/\$MYHOST/'"$servername"'/g }' \
		-e '/^\[/ { s/\$MYPORT/'"$serverport"'/g }' \
		-e '/^\[/ { s,^\(...[^|]\+|\)\([^/]\),\1'"$rel"'/\2, }' \
		-e '/^\[/ { s/\[//; s/^\(.\)|/\1/; s/\]//; s/|/\t/g }' \
		-e 's/$/\r/' \
		"$@"
}

isCGI()
{
	[[ -x "$1" ]] && [[ "${1##*.}" == "cgi" ]]
}

isDCGI()
{
	[[ -x "$1" ]] && [[ "${1##*.}" == "dcgi" ]]
}

sendListing()
{
	dirEmpty "$1" && return

	for i in "$1"/*; do
		[[ -d "$i" ]] && itype=1 || itype=0
		isDCGI "$i" && itype=1

		ext=${i##*.}
		if [[ -n "$ext" ]]; then
			case "${ext,,}" in
				html|htm|xhtm|xhtml) itype=h ;;
				jpeg|jpg|png|tif|tiff|bmp|svg) itype=I ;;
				exe|bin|iso|img|gz|xz|tar|tgz) itype=9 ;;
				gif) itype=g ;;
			esac
		fi

		printf "%s%s\t%s\t%s\t%d\r\n" \
			$itype \
			"${i##*/}" \
			"${i:${#docroot}}" \
			"$servername" \
			"$serverport"
	done
}

run()
(
	cd -- "${1%/*}"
	"$1"
)

# Process a request.
read -r request
request=${request//$'\r'/}
selector=${request%$'\t'*}
search=${request#*$'\t'}
absreq=$(rel2abs "$docroot$selector")
if [[ "${absreq:0:${#docroot}}" == "$docroot" ]]; then
	if [[ -d "$absreq" ]]; then
		if [[ -f "$absreq"/INDEX ]]; then
			parseIndex "${absreq:${#docroot}}" "$absreq"/INDEX
		elif isDCGI "$absreq"/INDEX.dcgi; then
			run "$absreq"/INDEX.dcgi | parseIndex "${absreq:${#docroot}}"
		else
			sendListing "$absreq"
		fi
	elif isCGI "$absreq"; then
		run "$absreq" "$search"
	elif isDCGI "$absreq"; then
		rel="${absreq:${#docroot}}"
		rel="${rel%/*}"
		run "$absreq" "$search" | parseIndex "$rel"
	else
		cat "$absreq"
	fi
else
	printf "%d%s\t%s\t%s\t%d\r\n" \
		3 "\`$request' invalid." "Error" "Error" 0
fi
