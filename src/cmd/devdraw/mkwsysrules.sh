#!/bin/sh

[ -f $PLAN9/config ] && . $PLAN9/config

if [ "x$X11" = "x" ]; then 
	if [ -d /usr/X11R6 ]; then
		X11=/usr/X11R6
	elif [ -d /usr/local/X11R6 ]; then
		X11=/usr/local/X11R6
	elif [ -d /usr/X ]; then
		X11=/usr/X
	elif [ -d /usr/openwin ]; then	# for Sun
		X11=/usr/openwin
	elif [ -d /usr/include/X11 ]; then
		X11=/usr
	elif [ -d /usr/local/include/X11 ]; then
		X11=/usr/local
	else
		X11=noX11dir
	fi
fi

if [ "x$WSYSTYPE" = "x" ]; then
	if [ "x`uname`" = "xDarwin" ]; then
		if sw_vers | grep 'ProductVersion:	10\.[0-5]\.' >/dev/null; then
			echo 1>&2 'OS X 10.5 and older are not supported'
			exit 1
		else
			#echo 1>&2 'WARNING: OS X Lion is not working.  Copy binaries from a Snow Leopard system.'
			WSYSTYPE=osx-cocoa
		fi
	elif [ -d "$X11" ]; then
		WSYSTYPE=x11
	else
		WSYSTYPE=nowsys
	fi
fi

if [ "x$WSYSTYPE" = "xx11" -a "x$X11H" = "x" ]; then
	if [ -d "$X11/include" ]; then
		X11H="-I$X11/include"
	else
		X11H=""
	fi
fi
	
echo 'WSYSTYPE='$WSYSTYPE
echo 'X11='$X11
echo 'X11H='$X11H

if [ $WSYSTYPE = x11 ]; then
	echo 'CFLAGS=$CFLAGS '$X11H
	echo 'HFILES=$HFILES $XHFILES'
	XO=`ls x11-*.c 2>/dev/null | sed 's/\.c$/.o/'`
	echo 'WSYSOFILES=$WSYSOFILES '$XO
elif [ $WSYSTYPE = osx-cocoa ]; then
	if sw_vers|awk '/ProductVersion/{split($2,a,".");exit(a[2]<14)}' >/dev/null; then	# 0 is true in sh.
		echo 'OBJCFLAGS=$OBJCFLAGS -fobjc-arc'
		echo 'WSYSOFILES=$WSYSOFILES osx-draw.o cocoa-screen-metal-objc.o cocoa-srv.o cocoa-thread.o'
	else
		echo 'WSYSOFILES=$WSYSOFILES osx-draw.o cocoa-screen-objc.o cocoa-srv.o cocoa-thread.o'
	fi
	echo 'MACARGV=macargv-objc.o'
elif [ $WSYSTYPE = nowsys ]; then
	echo 'WSYSOFILES=nowsys.o'
fi
