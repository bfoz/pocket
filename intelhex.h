/* Filename: intelhex.h
 * Routines for reading/writing Intel INHX8M and INHX32 files
 * Copyright Brandon Fosdick 2001-2002

	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#ifndef INTELHEXH
#define INTELHEXH

#include <fstream>
#include <vector>
#include <list>

#include <unistd.h>

namespace intelhex
{

	#define	HEX_FORMAT_INHX8M	0x01
	#define	HEX_FORMAT_INHX32	0x02

	//Each line of the hex file generates a block of memory at a particular address
	// pair<>.first is the address, pair<>.second is the data
	typedef pair<uint16_t, vector<uint16_t> >	dblock;
	typedef list<dblock> lst_dblock;
		 
	//The data set that results from parsing a hex file
	struct hex_data
	{
		char			format;						//Format of the parsed file (necessary?)

		lst_dblock	blocks;						//List of data blocks
														//I used a list instead of a vector since
														//	the data set gets sorted a few times
		
					hex_data();						//Constructor
		void		cleanup();						//Cleanup
		dblock	*new_block();					//Extend the array by one block
		dblock	*add_block(uint16_t, uint16_t);	//Append a new block with address/length
		uint16_t	&operator[](uint16_t);	//Array access operator
		bool		load(const char *);			//Load a hex file from disk
		void		write(const char *);			//Save hex data to a hex file
		void		write(ostream &);			//Write all data to an output stream
		void		truncate(uint16_t);			//Truncate all of the blocks to a given length
	};

}
#endif