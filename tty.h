/* Filename: tty.h
 * A class for doing terminal I/O on FreeBSD
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#ifndef MYTTY_H
#define MYTTY_H

#include <termios.h>

struct tty_t
{
	int fd;
#ifdef TTY_DEBUG
	int fd1;
#endif
	termios	save_termios;

	int open(const char *, int);
	int close();
	int rawmode();
	int reset();
	ssize_t read(void *, size_t);
	//ssize_t read(unsigned char *);
	u_int8_t read();
	ssize_t read(u_int8_t *);
	ssize_t write(const void *, size_t);
	ssize_t write(char);
};


#endif