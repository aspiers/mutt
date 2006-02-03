#!/bin/bash
#
# url_handler.sh for SuSE Linux
#
# Copyright (c) 2000  SuSE GmbH  Nuernberg, Germany.
#
# Author: Werner Fink <werner@suse.de>
#
   url="$1"
method="${1%%:*}"

if test "$url" = "$method" ; then
    case "${url%%.*}" in
	www|web|w3) method=http		;;
	mail|mailx) method=mailto	;;
	gopher)	    method=gopher	;;
	*)
	    case "${url}" in
		*/*.htm|*/*.html) method=http	;;
		*/*.htmls)	  method=https	;;
		*@*)		  method=mailto ;;
		/*) if test -r "${url}" ; then
				  method=file
		    fi				;;
		*)				;;
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
            type -p firefox >& /dev/null && \
                firefox -remote "openURL($url,new-tab)" && exit 0
            type -p mozilla >& /dev/null && \
                mozilla -remote "openURL($url,new-tab)" && exit 0
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
    *)
	echo "URL type \"$method\" not know"
	read -p "Press return to continue: "
	exit 0  # No error return
	;;
esac