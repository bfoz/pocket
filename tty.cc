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

//#include "tty.h"

//Read nbytes from the port and put them in buf
inline ssize_t tty_t::read(void *buf, size_t nbytes)
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
inline ssize_t tty_t::read(u_int8_t *c)
{
	return ::read(fd, c, 1);
}

//Read a single byte from the port
inline u_int8_t tty_t::read()
{
	u_int8_t c;
	::read(fd, &c, 1);
	return c;
}

inline ssize_t tty_t::write(const void *buf, size_t nbytes)
{
	ssize_t s;
#ifdef TTY_DEBUG
	::write(fd1, buf, nbytes);
#endif
	s = ::write(fd, buf, nbytes);
	tcdrain(fd);
}

inline ssize_t tty_t::write(char buf)
{
	ssize_t s;
#ifdef TTY_DEBUG
	if(buf!='Y')
		::write(fd1, &buf, 1);
	printf("%s: %X\n", __FUNCTION__, buf);
#endif
	s = ::write(fd, &buf, 1);
	printf("write wrote\n");
	tcdrain(fd);
}

inline int tty_t::open(const char *path, int flags)
{
#ifdef TTY_DEBUG
	if( (fd1 = ::open("log",O_WRONLY | O_CREAT | O_TRUNC))==-1)
		perror(NULL);
#endif
	return fd=::open(path,flags);
}

inline int tty_t::close()
{
#ifdef TTY_DEBUG
	::close(fd1);
#endif
	reset();
	return ::close(fd);
}

inline int tty_t::rawmode()
{
	termios	buff;

	if( tcgetattr(fd, &save_termios) < 0)
		return -1;
		
	buff = save_termios;
	cfmakeraw(&buff);
//	printf("rawmode: buff.c_cflag = %X\n", buff.c_cflag);
	cfsetspeed(&buff, B19200);
//	buff.c_cc[VMIN] = 1;	//Block on read until at least one character is available
//	buff.c_cc[VTIME] = 10;	//Block on read for no more than 1 second
	if( tcsetattr(fd, TCSANOW | TCSAFLUSH, &buff) < 0)
		return 0;
	return 1;
}

inline int tty_t::reset()
{
	if( tcsetattr(fd, TCSAFLUSH | TCSANOW, &save_termios) < 0)
		return 0;
	return 1;
}
