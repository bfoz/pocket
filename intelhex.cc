/* Filename: intelhex.cc
 * Routines for reading/writing Intel INHX8M and INHX32 files
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "intelhex.h"

hex_data::hex_data()
{
	format = HEX_FORMAT_INHX8M;
	blocks = NULL;
	num_blocks = 0;
}

//Extend the data block array by one element
//	and return a pointer to the new element
dblock* hex_data::new_block()
{
	num_blocks++;
	blocks = (dblock *)realloc(blocks, sizeof(dblock)*num_blocks);
	return &(blocks[num_blocks-1]);
}

//Extend the data block array by one element
//	and return a pointer to the new element
//	Initialize the element with address and length
dblock* hex_data::add_block(u_int16_t address, u_int16_t length)
{
	dblock *db;
	db = new_block();
	db->address = address;
	db->data = new u_int16_t[length];
	db->length = length;
	return db;
}

//Array access operator
u_int16_t &hex_data::operator[](u_int16_t addr)
{
	unsigned i;

	i=0;
	while((i<num_blocks) && (blocks[i].address < addr))
		i++;
	if(i==num_blocks)	//Check for a valid block number
		return blocks[0].data[0];
	if(blocks[i].address > addr)	//One block too far? 
		i--;										//	go back one
	return blocks[i].data[addr - blocks[i].address];
}

//	Delete all allocated memory
void hex_data::cleanup()
{
	int i;
	for(i=0;i<num_blocks;i++)
		delete blocks[i].data;
	delete blocks;
	format = HEX_FORMAT_INHX8M;
	blocks = NULL;
	num_blocks = 0;
}

//Swap two elements of an array of dblocks
void swap(dblock *db, unsigned a, unsigned b)
{
	dblock	temp;

	temp.address = db[a].address;
	temp.data = db[a].data;
	temp.length = db[a].length;

	db[a].address = db[b].address;
	db[a].data = db[b].data;
	db[a].length = db[b].length;

	db[b].address = temp.address;
	db[b].data = temp.data;
	db[b].length = temp.length;
}

//Quicksort an array of dblocks based on the address field
void quicksort(dblock *db, int lo0, int hi0)
{
	int lo = lo0;
	int hi = hi0;
	u_int16_t mid;

	if( hi0 > lo0)
	{
		//Arbitrarily establish a partition element as the midpoint of the array
		mid = db[(lo0+hi0)/2].address;
		//Loop through the array until the indices cross
		while(lo <= hi)
		{
			//Find the first element that is >= the partition element
			//	starting from the left
			while( (lo<hi0) && (db[lo].address<mid) )
				lo++;

			//Find an element that is <= the partition element
			//	starting from the right
			while( (hi>lo0) && (db[hi].address>mid))
				hi--;

			//If the indices have not crossed, swap the elements
			if( lo <= hi )
			{
				swap(db, lo, hi);
				lo++;
				hi--;
			}
		}
	}
	if( lo0 < hi )
		quicksort(db, lo0, hi);
	if( lo < hi0 )
		quicksort(db, lo, hi0);
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
						db->data[i] = ((hi<<8)&0xFF00) | (lo&0x00FF);	//Assemble the word
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
	
	quicksort(blocks,0,num_blocks-1);	//Sort the data blocks
	return true;
}

//Write all data to a file
void	hex_data::write(const char *path)
{
	FILE	*fp;
	int i, j;
	u_int8_t	checksum;

	if( (fp=fopen(path, "w"))==NULL )
	{
		printf("%s: Can't open %s\n", __FUNCTION__, path);
		return;
	}

	truncate(8);								//Truncate each record to length=8
	quicksort(blocks,0,num_blocks-1);	//Sort the data blocks by address

	for(i=0; i<num_blocks; i++)
	{
		checksum = 0;
		if(blocks[i].address < 0x2100)
		{	//Program memory and fuses require special consideration
			fprintf(fp, ":%02X%04X00", blocks[i].length*2, blocks[i].address*2);	//Record length and address
			for(j=0; j<blocks[i].length; j++)	//Store the data bytes, LSB first, ASCII HEX
			{
				fprintf(fp, "%02X%02X", blocks[i].data[j] & 0x00FF, (blocks[i].data[j]>>8) & 0x00FF);
				checksum += blocks[i].data[j];
			}
		}
		else	//EEPROM can just be written out
		{
			fprintf(fp, ":%02X%04X00", blocks[i].length, blocks[i].address);	//Record length and address
			for(j=0; j<blocks[i].length; j++)	//Store the data bytes, LSB first, ASCII HEX
			{
				fprintf(fp, "%02X", blocks[i].data[j] & 0x00FF);
				checksum += blocks[i].data[j];
			}
		}
		fprintf(fp, "00\n");	//Bogus checksum and a newline
	}
	fprintf(fp, ":00000001FF\n");	//EOF marker
	fclose(fp);
}

//Truncate all of the blocks to a given length
void	hex_data::truncate(u_int16_t len)
{
	dblock	*db;
	u_int16_t i;
	
	for(i=0; i<num_blocks; i++)
	{
		if(blocks[i].length > len)
		{
			db = add_block(blocks[i].address+len, blocks[i].length-len);		//Create a new block
			memcpy(db->data, &(blocks[i].data[len]), sizeof(u_int16_t)*(blocks[i].length-len));	//Copy the overrun data to it
			blocks[i].data = (u_int16_t *)realloc(blocks[i].data, sizeof(u_int16_t)*len);	//Shorten the original block
			blocks[i].length = len;
		}
	}
}