/* Filename: intelhex.h
 * Routines for reading/writing Intel INHX8M and INHX32 files
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#ifndef INTELHEXH
#define INTELHEXH

#define	HEX_FORMAT_INHX8M	0x01
#define	HEX_FORMAT_INHX32	0x02

//Each line of the hex file generates a block of memory at a particular address
//This structure holds a single block
struct dblock
{
	u_int16_t	address;		//The MCU address where this block starts
	u_int16_t	*data;		//The data
	u_int16_t	length;		//The number of elements in the data array (64k limit)
};

//The data set that results from parsing a hex file
struct hex_data
{
	char			format;						//Format of the parsed file (necessary?)
	dblock		*blocks;						//Pointer to an array of data blocks
	unsigned		num_blocks;					//Number of dblocks in the array

				hex_data();						//Constructor
	void		cleanup();						//Cleanup
	dblock	*new_block();					//Extend the array by one block
	dblock	*add_block(u_int16_t, u_int16_t);	//Append a new block with address/length
	u_int16_t	&operator[](u_int16_t);	//Array access operator
	bool		load(const char *);			//Load a hex file from disk
	void		write(const char *);			//Save hex data to a hex file
	void		truncate(u_int16_t);			//Truncate all of the blocks to a given length
};

#endif