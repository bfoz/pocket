/* Filename: tty.cc
 * A class for doing terminal I/O on FreeBSD
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

#include "tty.h"

ssize_t tty_t::read(void *buf, size_t nbytes)
{
	return ::read(fd, buf, nbytes);
}

ssize_t tty_t::read(char *c)
{
	return ::read(fd, c, 1);
}

ssize_t tty_t::write(const void *buf, size_t nbytes)
{
#ifdef TTY_DEBUG
	::write(fd1, buf, nbytes);
#endif
	return ::write(fd, buf, nbytes);
}

ssize_t tty_t::write(char buf)
{
#ifdef TTY_DEBUG
	if(buf!='Y')
		::write(fd1, &buf, 1);
	printf("%s: %c\n", __FUNCTION__, buf);
#endif
	return ::write(fd, &buf, 1);
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
	if( tcsetattr(fd, TCSAFLUSH, &save_termios) < 0)
		return 0;
	return 1;
}