/* Filename: intelhex.h
 * Routines for reading/writing Intel INHX8M and INHX32 files

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
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

	
	//The data set that results from parsing a hex file
	struct hex_data
	{
		//Each line of the hex file generates a block of memory at a particular address
		// pair<>.first is the address, pair<>.second is the data
		typedef	uint16_t	element;								//Data element
		typedef	uint32_t	address_t;
		typedef	std::vector<element>	data_container;		//Element container
		typedef	std::pair<address_t, data_container>	dblock;	//Data block container
		typedef	std::list<dblock> lst_dblock;						//List of data blocks

		typedef	lst_dblock::iterator	iterator;
		typedef	lst_dblock::reverse_iterator	reverse_iterator;
		typedef	data_container::size_type	size_type;
	private:		
		char	format;					//Format of the parsed file (necessary?)
		bool	segment_addr_rec;		//Uses/Has a segment address record
		bool	linear_addr_rec;		//Uses/Has a linear address record
	public:
		lst_dblock	blocks;			//List of data blocks
											//I used a list instead of a vector since
											//	the data set gets sorted a few times

	public:
		hex_data() : segment_addr_rec(false), linear_addr_rec(false) {}
		iterator	begin() { return blocks.begin(); }
		iterator	end() { return blocks.end(); }
		void	clear();		//Delete everything
		void	push_back(element);	//Add a word to the end of the set
		size_type	size();
		size_type	size_below_addr(address_t);
		size_type	size_in_range(address_t, address_t);	//number of words in [lo, hi)
		address_t	max_addr_below(address_t);
		
		bool	isset(address_t);
		
		element	&operator[](address_t);	//Array access operator
		element	get(address_t, element);	//FIXME	Nasty kludge
		
		dblock	*new_block();					//Extend the array by one block
		dblock	*add_block(address_t, size_type, element = 0xFFFF);	//Append a new block with address/length
		bool		load(const char *);			//Load a hex file from disk
		bool		load(const std::string &s) {return load(s.c_str());}	//Load a hex file from disk
		void		write(const char *);			//Save hex data to a hex file
		void		write(std::ostream &);			//Write all data to an output stream
		void		truncate(size_type);			//Truncate all of the blocks to a given length
	};

}
#endif
