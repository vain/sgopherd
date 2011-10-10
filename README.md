bgopherd
========

bgopherd is a simple gopher server for Unix-like systems. As it's
implemented as a shell script (GNU Bash), there's no standalone daemon
functionality. Thus, it's meant to be called by inetd(8) or xinetd(8).
Despite being tiny, bgopherd supports

* dynamic content using CGI scripts and dynamic menus using DCGI scripts,
* automatic indexing,
* automatic dynamic menu creation using INDEX.dcgi scripts,
* manual menus using plain text INDEX files,
* search queries and
* basic file type detection.

Please have a look at the manpage if you want to learn more about
bgopherd. You can view it without having to install the whole package:

	$ cd ~/git/bgopherd
	$ man -M . bgopherd
