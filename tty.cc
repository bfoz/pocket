/* Filename: tty.cc
 * A class for doing terminal I/O on FreeBSD

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#include <stdio.h>
#include <sys/ioctl.h>
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
inline uint8_t tty_t::read()
{
	uint8_t c;
#ifdef TTY_DEBUG_1
	printf("%s: About to read\n", __FUNCTION__);
#endif
	::read(fd, &c, 1);
#ifdef TTY_DEBUG
	printf("%s: '%c' (0x%02X)\n", __FUNCTION__, c, c);
#endif
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

inline ssize_t tty_t::write(const unsigned char buf)
{
	ssize_t s;
#ifdef TTY_DEBUG
	if(buf!='Y')
		::write(fd1, &buf, 1);
	printf("%s: '%c' (0x%02X)\n", __FUNCTION__, buf, buf);
#endif
	s = ::write(fd, &buf, 1);
//	printf("write wrote\n");
	tcdrain(fd);
}

inline int tty_t::open(const char *path, int flags)
{
#ifdef TTY_DEBUG
	if( (fd1 = ::open("log",O_WRONLY | O_CREAT | O_TRUNC))==-1)
		perror(NULL);
#endif
	return fd=::open(path,flags);
//	return fd=::open(path,flags | O_NDELAY);
}

inline int tty_t::close()
{
#ifdef TTY_DEBUG
	::close(fd1);
#endif
	reset();
	return ::close(fd);
}

inline void display_termios(termios buff)
{
	printf("c_cflag = %X", buff.c_cflag);
	if(buff.c_cflag & CIGNORE)
		printf(" CIGNORE");
	switch( buff.c_cflag & CSIZE)
	{
		case CS5: printf(" CS5"); break;
		case CS6: printf(" CS6"); break;
		case CS7: printf(" CS7"); break;
		case CS8: printf(" CS8"); break;
	}		
	if(buff.c_cflag & CSTOPB)
		printf(" CSTOPB");
	if(buff.c_cflag & CREAD)
		printf(" CREAD");
	if(buff.c_cflag & PARENB)      // parity enable
		printf(" PARENB");
	if(buff.c_cflag & PARODD)      // odd parity, else even
		printf(" PARODD");
	if(buff.c_cflag & HUPCL)      // hang up on last close
		printf(" HUPCL");
	if(buff.c_cflag & CLOCAL)      // ignore modem status lines
		printf(" CLOCAL");
	printf("\n");
	printf("c_iflag = %X", buff.c_iflag);
	printf("\n");
	printf("c_lflag = %X", buff.c_lflag);
	printf("\n");
	printf("c_oflag = %X", buff.c_oflag);
	printf("\n");
}

inline int tty_t::rawmode()
{
	termios	buff;

	if( tcgetattr(fd, &save_termios) < 0)
		return -1;
		
	buff = save_termios;
	cfmakeraw(&buff);
//	display_termios(buff);
	cfsetspeed(&buff, B19200);
#if defined(__FreeBSD__)
	buff.c_iflag = 1;
	buff.c_lflag = 0;
	buff.c_oflag = 0;
#endif
	buff.c_cflag |= CLOCAL;	//Ignore modem status lines
	buff.c_cc[VMIN] = 1;	//Block on read until at least one character is available
	buff.c_cc[VTIME] = 5;	//Block on read for no more than 1 second
//	display_termios(buff);

	if(tcflush(fd, TCIOFLUSH) == -1)
		return 0;
	if(tcsetattr(fd, TCSANOW | TCSAFLUSH, &buff) < 0)
		return 0;
	return 1;
}

inline int tty_t::reset()
{
	if( tcsetattr(fd, TCSAFLUSH | TCSANOW, &save_termios) < 0)
		return 0;
	return 1;
}

inline bool tty_t::flush()
{
	if(tcflush(fd, TCIOFLUSH) == -1)
		return false;
	return true;
}

inline void tty_t::set_dtr()
{
	ioctl(fd, TIOCSDTR);
}

inline void tty_t::clear_dtr()
{
	ioctl(fd, TIOCCDTR);
}


