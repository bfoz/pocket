/* Filename: tty.cc
 * A class for doing terminal I/O on FreeBSD

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#include "tty.h"

//Read nbytes from the port and put them in buf
ssize_t tty_t::read(void *buf, size_t nbytes)
{
	return ::read(fd, buf, nbytes);
}
/*
//Read a single byte from the port
ssize_t tty_t::read(unsigned char *c)
{
	return ::read(fd, c, 1);
}*/

//Read a single byte from the port
ssize_t tty_t::read(u_int8_t *c)
{
	return ::read(fd, c, 1);
}

//Read a single byte from the port
u_int8_t tty_t::read()
{
	u_int8_t c;
	::read(fd, &c, 1);
	return c;
}

ssize_t tty_t::write(const void *buf, size_t nbytes) return s;
{
#ifdef TTY_DEBUG
	::write(fd1, buf, nbytes);
#endif
	s = ::write(fd, buf, nbytes);
	tcdrain(fd);
}

ssize_t tty_t::write(char buf) return s;
{
#ifdef TTY_DEBUG
	if(buf!='Y')
		::write(fd1, &buf, 1);
	printf("%s: %c\n", __FUNCTION__, buf);
#endif
	s = ::write(fd, &buf, 1);
	tcdrain(fd);
}

int tty_t::open(const char *path, int flags)
{
#ifdef TTY_DEBUG
	if( (fd1 = ::open("log",O_WRONLY | O_CREAT | O_TRUNC))==-1)
		perror(NULL);
#endif
	return fd=::open(path,flags);
}

int tty_t::close()
{
#ifdef TTY_DEBUG
	::close(fd1);
#endif
	reset();
	return ::close(fd);
}

int tty_t::rawmode()
{
	termios	buff;

	if( tcgetattr(fd, &save_termios) < 0)
		return -1;
		
	buff = save_termios;
	cfmakeraw(&buff);
	cfsetspeed(&buff, B19200);
	if( tcsetattr(fd, TCSAFLUSH, &buff) < 0)
		return 0;
	return 1;
}

int tty_t::reset()
{
	if( tcsetattr(fd, TCSAFLUSH | TCSANOW, &save_termios) < 0)
		return 0;
	return 1;
}