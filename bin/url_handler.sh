#!/bin/bash
#
# url_handler.sh for SuSE Linux
#
# Copyright (c) 2000  SuSE GmbH  Nuernberg, Germany.
#
# Author: Werner Fink <werner@suse.de>
#

#exec 2>/tmp/url_handler.log

# acrobat reader passes args: -remote openURL(url,new-window)

if [ "$1" = -remote ]; then
    shift
    case "$1" in
        openURL*)
            set "${1#openURL(}"
            set "${1%)}"
            set "${1%,new-window}"
            ;;
    esac
fi

   url="$1"
method="${1%%:*}"

if test "$url" = "$method" ; then
    # no method was specified, try to guess one
    case "${url%%.*}" in
	www|web|w3) method=http		;;
	mail|mailx) method=mailto	;;
	gopher)	    method=gopher	;;
	*)
	    case "${url}" in
		*@*)
                    method=mailto
                    ;;
		*)
                    if [ -e "$url" ]; then
                        method=file
                        url="`abs \"$url\"`"
                    fi
                    ;;
	    esac
        ;;
    esac
    case "$method" in
	mailto|file)	url="${method}:$url"	;;
	*)		url="${method}://$url"	;;
    esac
fi

### an alternative method of handling "news:*" URL's
#
# if test "$method" = "news" ; then
#     url="http://www.deja.com/[ST_rn=if]/topics_if.xp?search=topic&group=${url#news:}"
#     method=http
# fi

shift

case "$method" in
    ftp)
	ftp=ftp
	if type -p ncftp >& /dev/null ; then
	    ftp=ncftp
	else
	    url="${url#ftp://}"
	    echo "=====>  Paste this command by mouse:"
	    echo cd "/${url#*/}"
	    url="${url%%/*}"
	fi
	exec $ftp "$url"
	;;
    file|http|https|gopher)
	if test -n "$DISPLAY"; then
            if type -p firefox >& /dev/null; then
                ff_version="`firefox -version`"
                echo "ff_version $ff_version"
                case "$ff_version" in
                    *1.5.0.8)
                        # tested on FC6
                        firefox -remote "openURL($url,new-tab)" && exit 0 ;;
                    *1.5.0.*)
                        firefox "$url" & exit 0 ;;
                    *2.0*)
                        firefox -new-tab "$url" && exit 0 ;;
                    *)
                        firefox -remote "openURL($url,new-tab)" && exit 0 ;;
                esac                        
            elif type -p mozilla >& /dev/null; then
                # FIXME - which mozilla versions?
                mozilla -remote "openURL($url,new-tab)" && exit 0
            fi
        fi
	type -p links >& /dev/null && links "$url" && exit 0
	type -p w3m   >& /dev/null && w3m   "$url" && exit 0
	type -p lynx  >& /dev/null && lynx  "$url" && exit 0
        echo "No HTTP browser found."
        read -p "Press return to continue: "
        exit 1
	;;
    mailto)
	: ${MAILER:=mutt}
	if type -p ${MAILER} >& /dev/null ; then
	    exec ${MAILER} "${url#mailto:}"
	else
	    echo "No mailer ${MAILER} found in path."
	    echo "Please check your environment variable MAILER."
	    read -p "Press return to continue: "
	    exit 0  # No error return
	fi
	;;
    textedit)
        lilypond-invoke-editor "$url"
        exit 0
        ;;
    *)
	echo "URL type \"$method\" not known"
	read -p "Press return to continue: "
	exit 0  # No error return
	;;
esac
