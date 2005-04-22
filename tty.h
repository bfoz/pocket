/* Filename: tty.h
 * A class for doing terminal I/O on FreeBSD

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#ifndef MYTTY_H
#define MYTTY_H

#include <termios.h>

//#define	TTY_DEBUG

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
	bool flush();
	void set_dtr();
	void clear_dtr();

	ssize_t read(void *, size_t);
	//ssize_t read(unsigned char *);
	uint8_t read();
	ssize_t read(u_int8_t *);
	ssize_t write(const void *, size_t);
	ssize_t write(const unsigned char);
};

//Allow for inlining
#include "tty.cc"

#endif
