/* Filename: pocket.h
 *	Interface to Tony Nixon's Pocket Programmer
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#ifndef POCKET_H
#define POCKET_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "tty.h"

//Constants for the chipinfo structure
#define	VPP_PIN1					0
#define	VPP_PINS514				1
#define	EEPROM_DELAY_SHORT	0
#define	EEPROM_DELAY_LONG		1
#define	PIC_8PINS				0
#define	PIC_18PINS				1
#define	PIC_28PINS				2
#define	PIC_40PINS				3
#define	CODE_INHX8M				0
#define	CODE_INHX32				1

//Constants for the messages array
#define	LO_MESSAGE_INDEX	0x02
#define	HI_MESSAGE_INDEX	0xFF
#define	NUM_MESSAGES	(HI_MESSAGE_INDEX - LO_MESSAGE_INDEX)

//Data structures for handling the chip and message data

struct ram_alias
{
	unsigned int	address;		//RAM address
	char	*alias;					//char* to alias text
};

struct ram_bitalias
{
	u_int8_t	address;				//Address
	char	*alias[8];
};

struct chipinfo
{
	char	*name;						//Chip name
	u_int16_t	rompages;			//Number of ROM pages
	u_int16_t	eeprom_size;		//EEPROM size in bytes
	u_int16_t	rampages;			//Number of RAM pages
	u_int8_t		vpp_select;			//Vpp pin select VPP_PIN1:Pin1, VPP_PINS514:Pins 5,14
	u_int8_t		eeprom_prog_delay;//EEPROM Chips Only: Long or Short programming delay
	u_int8_t		pin_count;			//Chip pin count 0:8 pins, 1:18 pins, 2:28, 3:40
	bool			cp_warn;				//Code Protect warning needed? 0:No, 1:Yes
	u_int8_t		codetype;			//Chip/File format 0:14 bit INHX8M, 1:16 bit INHX32
	bool			internal_prog;		//Internally programmable?	0:No, 1:Yes
	u_int16_t	idwords;				//Number of ID words
	u_int16_t	fusewords;			//Number of fuse words
	u_int16_t	fuse_and[4];		//AND masks for fuses
	u_int16_t	fuse_or[4];			//OR masks for fuses
	int			num_aliases[4];	//Number of aliases for each of up to 4 ram pages
	ram_alias	*aliases[4];		//An array of pointers to arrays of ram_alias's
	//Bit aliases aren't parsed yet
	//int			num_bitalias[4];	//Number of bit aliases in each of up to 4 pages
	//ram_bitalias	*bitalias[4];	//An array of pointers to arrays of ram_bitalias's
	//This is a temporary kludge since I don't *really* need to parse chipdat.txt
	//	since the pocket does most of the parsing.
	int	num_textlines;				//Number of lines of raw text stored
	char	**textline;					//Pointer to array of pointers to strings
};

struct pocket_t : public tty_t
{
	char	**messages;
	int	nummsg;
	chipinfo	*chips;
	int	numchips;

	pocket_t();
	bool write16(const void *, size_t);
	bool write16(u_int8_t);
	bool write16a(const void *, size_t);	//Silly export routine uses different protocol
	bool write16a(u_int8_t);
};

//Constants for the Pocket comm protocol
#define	POC_REQICHIP	'T'
#define	POC_REQICOMM	'I'
#define	POC_REQECOMM	'E'
#define	POC_POCKETPRO	'P'
#define	POC_ANYCHAR		'Y'

extern int read_messages(FILE *);
extern int read_chipdat(FILE *);
extern int send_msgdat(tty_t);
extern void handle_export(tty_t, const char *);
#endif
