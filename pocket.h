/* Filename: pocket.h
 *	Interface to Tony Nixon's Pocket Programmer
 * Copyright Brandon Fosdick 2001-2002

	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#ifndef POCKET_H
#define POCKET_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "tty.h"
#include "intelhex.h"

namespace pocket
{

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

	//PocketPro Commands
	#define	PP_SET_VPP				0x02
	#define	PP_PROGVER				0x03
	#define	PP_PROGVERE				0x04
	#define	PP_READ_8_WORDS		0x05
	#define	PP_WRITE_FUSE			0x06
	#define	PP_WRITE_EFUSE			0x07
	#define	PP_READ_FUSE			0x08
	#define	PP_READ_8_EEPROM		0x09
	#define	PP_WRITE_EEPROM		0x0A
	#define	PP_BLANK_CHECK			0x0B
	#define	PP_ERASE					0x0C
	#define	PP_QUIT					0x0E

	//Higher level PocketPro commands
	//These are issued by the user
	#define	PP_PROGRAM		0x01		//Program a hex file
	#define	PP_BLANK			0x02		//Blank the chip
	#define	PP_VERIFY		0x03		//Verify the contents of the chip against a file
	#define	PP_READ			0x04		//Dump the chip to a file
	#define	PP_BLANKCHECK	0x05		//See if the chip is blank
	#define	PP_FUSES			0x06		//Write the fuse and id words
	#define	PP_EEPROM		0x07		//Write the EEPROM data

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
		char	menu_num;			//Which ppro menu is the Pocket in?
		u_int8_t	prog_speed;		//Programming speed to ppro mode '0'=fast, '1'=slow
		
		pocket_t();
		bool	write16(const void *, size_t);	//Write to pocket while handling 16 byte boundaries
		bool	write16(u_int8_t);
		bool	write16a(const void *, size_t);	//Silly export routine uses different protocol
		bool	write16a(u_int8_t);
		void		exportfile(const char *);
		void		importfile(const char *);
		bool		enter_ppro();									//Enter PocketPro mode (goto menu 2)
		u_int8_t	leave_ppro();									//Leave PocketPro mode (goto menu 1)
		void		ppro(char, const char *);					//Handle PocketPro mode
		u_int8_t	pp_setvpp(char);								//Set Vpp pins
		void		pp_writeprogram(intelhex::hex_data *,unsigned);	//Write program locations
		void		pp_readprogram(intelhex::hex_data *, unsigned);
		void		pp_read8words(intelhex::dblock *);					//Read 8 program words from the pic
		void		pp_readeeprom(intelhex::hex_data *, unsigned);
		void		pp_read8eeprom(intelhex::dblock *);
		void		pp_readfuse(u_int16_t *, u_int16_t *);	//Read fuse and id words
		u_int8_t	pp_blankcheck(u_int16_t);
		u_int8_t	pp_bulkerase(u_int8_t, u_int16_t);
	};

	//Constants for the Pocket comm protocol
	#define	POC_REQICHIP	'T'
	#define	POC_REQICOMM	'I'
	#define	POC_REQECOMM	'E'
	#define	POC_POCKETPRO	'P'
	#define	POC_ANYCHAR		'Y'

	extern int read_messages(FILE *);
	extern int read_chipdat(FILE *);
	extern int send_msgdat(pocket_t);
	extern void handle_export(pocket_t, const char *);
}	//namespace pocket
#endif
