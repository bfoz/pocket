/* Filename: intelhex.cc
 * Routines for reading/writing Intel INHX8M and INHX32 files
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "intelhex.h"

namespace intelhex
{

	hex_data::hex_data()
	{
		format = HEX_FORMAT_INHX8M;
	}

	//Extend the data block array by one element
	//	and return a pointer to the new element
	dblock* hex_data::new_block()
	{
		dblock b;
		blocks.push_back(b);
		return &blocks.back();
	}

	//Extend the data block array by one element
	//	and return a pointer to the new element
	//	Initialize the element with address and length
	dblock* hex_data::add_block(uint16_t address, uint16_t length)
	{
		dblock db;	//A list of pointers would be faster, but this isn't too bad
		blocks.push_back(db);
		blocks.back().first = address;
		blocks.back().second.resize(length);
		return &blocks.back();
	}

	//Array access operator
	//Assumes that the blocks have been sorted by address in ascending order
	uint16_t &hex_data::operator[](uint16_t addr)
	{
		//Start at the end of the list and find the first (last) block with an address
		//	less than addr
		lst_dblock::reverse_iterator i = blocks.rbegin();
		while( (i!=blocks.rend()) && (i->first > addr))
			++i;
		if(i==blocks.rend())	//If a suitable block wasn't found, return something
			return blocks.begin()->second[0];
		return i->second[addr - i->first];
	}

	//	Delete all allocated memory
	void hex_data::cleanup()
	{
		format = HEX_FORMAT_INHX8M;
		blocks.clear();
	}

	//Load a hex file from disk
	//Destroys any data that has already been loaded
	bool	hex_data::load(const char *path)
	{
		FILE	*fp;
		unsigned int	hi, lo, address, count, rtype, i, j;
		dblock	*db;		//Temporary pointer

		if( (fp=fopen(path, "r"))==NULL )
		{
			printf("%s: Can't open %s\n", __FUNCTION__, path);
			return false;
		}

		cleanup();		//First, clean house
		
		//Start parsing the file
		while(!feof(fp))
		{
			if(fgetc(fp)==':')	//First character of every line should be ':'
			{
				fscanf(fp, "%2x", &count);			//Read in byte count
				fscanf(fp, "%4x", &address);		//Read in address
				fscanf(fp, "%2x", &rtype);			//Read type

	/*			printf("Count: %02X\t", count);
				printf("Address: %04X\t", address);
				printf("Type: %02X\n", rtype);
				*/
				count /= 2;								//Convert byte count to word count
				address /= 2;							//Byte address to word address
				
				switch(rtype)	//What type of record?
				{
					case 0: 	//Data block so store it
						db = add_block(address, count);	//Make a data block
						for(i=0; i<count; i++)				//Read all of the data bytes
						{
							fscanf(fp, "%2x", &lo);			//Low byte
							fscanf(fp, "%2x", &hi);			//High byte
							db->second[i] = ((hi<<8)&0xFF00) | (lo&0x00FF);	//Assemble the word
						}
						break;
					case 1:	//EOF
						break;
					case 2:	//Segment address record (INHX32)
						break;
					case 4:	//Linear address record (INHX32)
						break;
				}
				fscanf(fp,"%*[^\n]\n");		//Ignore the checksum and the newline
			}
			else
			{
				printf("%s: Bad line\n", __FUNCTION__);
				fscanf(fp, "%*[^\n]\n");	//Ignore the rest of the line
			}
		}
		fclose(fp);

		blocks.sort();		//Sort the data blocks by address (ascending)
		return true;
	}

	//Write all data to a file
	void	hex_data::write(const char *path)
	{
		ofstream	ofs(path);
		write(ofs);
	}

	//Write all data to an output stream
	void	hex_data::write(ostream &os)
	{
		uint8_t	checksum;

		truncate(8);				//Truncate each record to length=8 (purely asthetic)
		blocks.sort();				//Sort the data blocks by address (ascending)

		os.setf(ios::hex, ios::basefield);	//Set the stream to ouput hex instead of decimal
		os.setf(ios::uppercase);				//Use uppercase hex notation
		os.fill('0');								//Pad with zeroes
		
		for(lst_dblock::iterator i=blocks.begin(); i!=blocks.end(); i++)
		{
			checksum = 0;
			if(i->first < 0x2100)
			{	//Program memory and fuses require special consideration
				os << ':';	//Every line begins with ':'
				os.width(2);
				os << i->second.size()*2;	//Record length
				os.width(4);
				os << static_cast<uint16_t>(i->first*2);	//Address
				os << "00";											//Record type
				for(int j=0; j<i->second.size(); j++)	//Store the data bytes, LSB first, ASCII HEX
				{
					os.width(2);
					os << (i->second[j] & 0x00FF);
					os.width(2);
					os << ((i->second[j]>>8) & 0x00FF);
					checksum += i->second[j];
				}
			}
			else	//EEPROM can just be written out
			{
				os.width(2);
				os << i->second.size();		//Record length
				os.width(4);
				os << i->first << "00";		//Address and record type
				for(int j=0; j<i->second.size(); j++)	//Store the data bytes, LSB first, ASCII HEX
				{
					os.width(2);
					os << (i->second[j] & 0x00FF);
					checksum += i->second[j];
				}
			}
			os.width(2);
			os << static_cast<int>(checksum);	//Bogus checksum byte
			os << endl;
		}
		os << ":00000001FF\n";			//EOF marker
	}

	//Truncate all of the blocks to a given length
	void	hex_data::truncate(uint16_t len)
	{
		for(lst_dblock::iterator i=blocks.begin(); i!=blocks.end(); i++)
			if(i->second.size() > len)
			{
				dblock db;
				blocks.push_back(db);	//Append a new block
				blocks.back().first = i->first + len;	//Give the new block an address
				blocks.back().second.assign(&i->second[len], i->second.end());	//Insert the extra bytes into the new block
				i->second.resize(len);	//Truncate the original block
			}
	}

}