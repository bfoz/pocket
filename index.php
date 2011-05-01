<?php
	include_once '/home/bfoz/public_html/include/common.php';
?>
<html>
<head>
	<title>Pocket Programmer</title>
	<link rel="stylesheet" href="<?php echo $HOME_URL ?>/style.css" type="text/css" />
</head>

<body>
<h1>Pocket Programmer</a></h1>

<h2>Overview</h2>
<p>Originally I wrote this utility to interface with the <a href="http://www.piclist.com/techref/microchip/pocketprog.htm">Pocket</a> programmer sold by Tony Nixon because he only provided Windows software. It was a good programmer that came with lousy software that wouldn't run on FreeBSD, so I set about to scratch an itch. Since then, <a href="http://kitsrus.com">Kitsrus</a> has started selling a line of programmers based on Tony's work. I've added support to pocket for the new programmers because they come with the same Windows-only software. The app is still called 'pocket', but now it supports the Kitsrus programmers as well.</p>

<p>The primary development platforms are OS X and FreeBSD. I'll gladly take patches for other OS's.</p>

<h3>Supported Programmers</h3>
<ul>
	<li><a href="http://www.piclist.com/techref/microchip/pocketprog.htm">Pocket</a> (not maintained)</li>
	<li>All of the Kitsrus programmers that use the <a href="http://bfoz.net/projects/pocket/diy_protocol_p018.html">P018</a> protocol are supported, except the K149 because it uses an inverted DTR.</li>
</ul>

<h3>Download</h3>
<p>
<a href="files/pocket-0.4.tgz">pocket-0.4 source</a><br>
<a href="files/pocket-0.3.tgz">pocket-0.3 source</a><br>
<a href="files/pocket-0.2.tgz">pocket-0.2 source</a><br>
<a href="files/pocket-0.1.tbz">pocket-0.1 source</a><br>
<a href="files/pocket.tar.gz">Original source code (for the nastalgic)</a><br>
<!-- <a href="pocket.tar">FreeBSD/i386 Binary</a></p> -->
<a href="files/pocket.zip">Original Bubblesoft Online Windows software.</a> Extract pocket.zip to an empty directory and you're ready to go.<br>

<h3>June 21, 2005</h3> <!-- @ 20:32:00 Pacific -->
<p><strong>New Version: pocket-0.4</strong><p>
<p>I've been on a database craze lately so I put all of the chip info into a <a href="http://bfoz.net/projects/pocket/PartsDB/">database</a>. Actually, I did that back in May, but I just now got around to updating pocket to take advantage of it. Which is the long way of saying that those of us using OS X Tiger can now live free of the tyranny of the chip info file. woohoo!</p>
<p>Now pocket can retrieve its chip info using the --update option (BTW, long options are supported now too), which then stores the chipinfo as extended attributes attached to the executable. But that only works if you have write privs on the executable. If you don't, pocket will automatically create $HOME/.pocket and attach the attributes to it. Either way, extended attributes don't work on files that are mounted over the network. Also, FreeBSD seems to have a limit on the number of attributes a file can have and naturally the limit is smaller than I need. So for now pocket is effectively restricted to OS X. I've only tested it on Tiger since I don't have a Panther box. </p>

<h3>April 23, 2005</h3> <!-- @ 20:18:00 Pacific -->
<p>This is mostly a bug-fix release to take care of some serious bugs in the handling of sparse hex files. A few other things were prettied up too, but the code is still very messy. There are some things I'd still like to change but haven't yet because it would break the Pocket specific code. I'm still not sure if I should just dump the old code or try to update it. I don't have a working Pocket handy for testing and I'm reluctant to fiddle with code that I can't test.</p>

<h3>April 21, 2005</h3> <!-- @ 22:27:57 Pacific -->
<p>I've added support for the <a href="http://kitsrus.com">Kitsrus</a> programmers that use the P018 protocol. The original protocol document needed some help so I made a <a href="http://bfoz.net/projects/pocket/diy_protocol_p018.html">new version</a>. There's something wrong with the serial code on FreeBSD. It works fine on a real UART but seems to have problems with both the Prolific and FTDI based USB-232 converters. I haven't bothered to track it down since I mostly use my Powerbook now for this sort of thing. Consequently it works great on OS X (Panther, until I upgrade to Tiger). Compilation and installation are still straightforward. Use make to compile the binary and then copy it and the chipinfo.cid file to someplace useful (or change your $PATH). Usage info is obtained in usual way. Let me know if there are any problems.
</p>

<h3>May 31, 2003</h3>
<p>Since the loss of Bubblesoft and the apparent disappearance of Tony Nixon I've had a few requests for the original set of software distributed with the pocket. Unfortunately I seem to be the last bastion of support for the Pocket Programmer. Fortunately there are still a few people using this great tool so it lives on. I don't use Windows much so I've long since lost my copy of the original distro. <a href="http://brumley.dynip.com/">Alan Brunley</a> still has his and has kindly made it available. I've added pocket.zip to the downloads section on this page, hopefully Tony (wherever he is) won't mind me posting it.</p>

<h3>September 5, 2002</h3>
<p><strong>New Version: pocket-0.0.0.1</strong> Its been a long time since I looked at any of this code. I got it to the point were it does everything that I need and stopped messing with it; too afraid to break something I guess. About a week or so ago somebody wrote asking about Linux support and even volunteered to handle the porting. Then I remembered that I wrote the original code while working on my thesis. My brain was mostly fried during those days so I figured I'd better take a look at the code that I was allowing the rest of the world to see. Talk about embarassing. To prove that the previously posted code isn't indicitive of my programming abilities I've started cleaning things up a bit, or a lot. This may turn into a complete rewrite by the time I'm done with it.</p>
<p>For starters I'm making extensive use of STL containers. For this program any related performance considerations aren't important and the STL version of the code will be much easier to maintain and port. It looks better too. I have no idea why I didn't use containers to start with, I must have been really brain dead. I'm almost afraid to go back and read my thesis now.</p>
<p>I've also started converting I/O routines to use C++ streams instead of read/write calls. Hopefully this will make the code easier to port. The intelhex module now uses streams for output, I'm still tinkering with input. The last part to get converted will be the tty module since thats hardest to test.</p>
<p>BTW, I fixed Makefile so that it no longer requires bhf.post.mk.</p>
<p>One more thing...I updated each file's header to be more explicit about the copyright info. The license is still BSD, same as always, but now each header references the file LICENSE which is included in the new distribution.</p>
<p>One more thing...Since the FreeBSD project has switched to bzip2 for packages I've followed suit and compressed the new source code distro with bzip2.</p>

<h3>August 6, 2001</h3>
<p><strong>Added EEPROM support in PocketPro mode.</strong> The project I'm working on finally needed to program EEPROM so I added that ability in the software. It's hard-coded for 16F87X since thats all I need right now. It still display more text than it needs to, if anybody complains I'll fix it.</p>
<h3>July 27, 2001</h3>
<p><strong>Updated source.</strong>The chipinfo downloading code has a bug somewhere in it that I haven't found yet. I don't need it right now so I haven't bothered to fix it. The new code just adds PocketPro support. I think there are a few PocketPro functions that I haven't implemented yet, cause I haven't needed them. It also has a few quirks that need to be fixed. I think I just don't understand the protocol properly, but I haven't talked to Tony lately since he expanded his family a few weeks ago.</p>
<h3>May 31, 2001</h3>
<p><strong>Code!!!</strong> Yes, thats right folks I have real working code now. For the moment it only supports downloading message text and chip info, but don't worry more is coming. I just wanted to get something posted so others could play with it. The code is messy, I plan to fix that at some point. I had some fun with arrays of pointers to arrays. :) Thats what I get for staying up too late. </p>
<p>I'm making both the source code and a binary available. The code is under a BSD license and the binary is only for FreeBSD/i386 cause that's what I use. If you want something else, make it yourself (or submit patches). If there's enough interest I'll make a FBSD port/package for it (somebody else will have to do rpm's and deb's)</p>
<h4>Notes</h4>
<ul>
	<li>I provided Unixified copies of chipdat.txt and pocket.msg since Tony's version has CRLF pairs and I'm not sure if my program can handle them in all cases. It works for me, but as always, YMMV.</li>
</ul>
<h4>Compiling</h4>
<p>The code is written in C++, not because it uses any fancy C++ stuff, I just like C++ better. I think I used a few GCC'isms too so that might get in the way if you don't use gcc (who doesn't?). Otherwise, untar the source into a directory and type make. To install just copy the file somewhere useful (along with chipdat.txt and pocket.msg).</p>
<h4>Installing</h4>
<p>I haven't make any install scripts or packages yet so you have to do it by hand. Don't worry, its real simple. Just put pocket (the executable) in a directory with chipdat.txt and pocket.msg (You don't need these two files if you're not going to be updating the chips or message info).</p>
</body>
</html>
