sgopherd
========

sgopherd is a simple gopher server for Unix-like systems, preferably
GNU. As it's implemented as a shell script (GNU Bash), there's no
standalone daemon functionality. Thus, it's meant to be called by
inetd(8) or xinetd(8). Despite being tiny, sgopherd supports

* dynamic content using CGI scripts and dynamic menus using DCGI scripts,
* automatic indexing,
* automatic dynamic menu creation using INDEX.dcgi scripts,
* manual menus using plain text INDEX files,
* custom headers in auto-generated menus using .HEADER files,
* manual annotation of single files in auto-generated menus using .ANN files,
* ignore sets of files in auto-generated menus using .IGNORE files,
* search queries,
* logging to syslog and
* basic file type detection.

Internally, sgopherd uses GNU sed(1).

Please have a look at the manpage if you want to learn more about
sgopherd. You can view it without having to install the whole package:

	$ cd ~/git/sgopherd
	$ man -M . sgopherd
