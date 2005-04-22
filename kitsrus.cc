/* Filename: kitsrus.cc
	Interface to Tony Nixon's PIC Programmers via the Kitsrus protocol
	This works for Kits 128, 149A, 149B, 150, 182

	Copyright (c) 2005, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */
#include <fcntl.h>
#include <iostream>

#include "kitsrus.h"
#include "intelhex.h"

namespace kitsrus
{

	#define	HIBYTE(a)	(u_int8_t)(a>>8)
	#define	LOBYTE(a)	(u_int8_t)(a&0x00FF)

	//Switch from power-on mode to command mode
	bool kitsrus_t::command_mode()
	{
		com->write('P');
		if( com->read() == 'P' )
			return true;
		else
			return false;
	}

	//Do a soft reset of the device
	//Send a 1 to the device. If it is in the command table it will reset. Either way it should return 'Q'
	bool kitsrus_t::soft_reset()
	{
		//Send a 1 to the device.
		// If it is in the command table it will reset. Either way it should return 'Q'
		com->write(CMD_RESET);
		if((com->read()) == 'Q')
			return true;
		else
			return false;
	}

	//Do a hard reset of the device
	//FIXME This won't work for Kit149 (A or B)
	bool kitsrus_t::hard_reset()
	{
		com->set_dtr();
		for(int i=0; i<10000; ++i) {};	//Delay
		com->clear_dtr();
		if( com->read()=='B' )
		{
			com->read();
			return true;
		}
		else
			return false;
	}

	bool kitsrus_t::init_program_vars()
	{
		com->write(CMD_INITVAR);
		com->write(HIBYTE(info.rom_size));
		com->write(LOBYTE(info.rom_size));
		com->write(HIBYTE(info.eeprom_size));
		com->write(LOBYTE(info.eeprom_size));
		com->write(info.core_type);	//FIXME	CoreType
		uint8_t i = (info.cal_word)?0x01:0x00;
		i != (info.band_gap)?0x02:0x00;
		i != (info.single_panel)?0x04:0x00;
		i != (info.fast_power)?0x08:0x00;
		com->write(i);		//Program flags
		com->write(info.program_delay);
		com->write(info.power_sequence);
		com->write(info.erase_mode);
		com->write(info.program_tries);
		com->write(info.over_program);
		if(com->read() == 'I')
			return true;
		return false;
	}
	

	bool kitsrus_t::chip_power_on()
	{
		com->write(CMD_VPP_ON);
		if( com->read() == 'V' )
			return true;
		else
			return false;
	}
	
	bool kitsrus_t::chip_power_off()
	{
		com->write(CMD_VPP_OFF);
		if( com->read() == 'v' )
			return true;
		else
			return false;
	}
	
	bool kitsrus_t::chip_power_cycle()
	{
		com->write(CMD_VPP_CYCLE);
		if( com->read() == 'V' )
			return true;
		else
			return false;
	}

	bool kitsrus_t::write_rom(intelhex::hex_data &HexData)
	{
		uint8_t	c;
		uint8_t i;
		intelhex::hex_data::address_t	j(0);
		uint16_t k;
		intelhex::hex_data::size_type size;
		
		//Figure out how many ROM words need to be written
		size = HexData.size_below_addr(info.rom_size);
		std::cout << __FUNCTION__ << ": size = " << size << std::endl;

		//Send program rom command
		com->write(CMD_WRITE_ROM);
		com->write( (size & 0xFF00) >> 8);	//Send size hi
		com->write(size & 0x00FF);	//Send size low

		while(1)
		{
			switch(com->read())
			{
				case 'P':
					return true;
				case 'N':
					std::cerr << __FUNCTION__ << ": Got N at address ";
					k = com->read();
					k = k << 8;
					k |= (0x00FF & com->read());
					std::cerr << std::hex << k;
					std::cerr << " with word ";
					k = com->read();
					k = k << 8;
					k |= (0x00FF & com->read());
					std::cerr << std::hex << k;
					std::cerr << std::endl;
					return false;
				case 'Y':
					std::cout << __FUNCTION__ << ": Got Y\n";
					for(i=0; i<(32/2); ++i)
					{
						com->write( (HexData[j] & 0xFF00) >> 8);
						com->write( HexData[j] & 0x00FF);
						++j;
					}
					break;
				default:
					std::cerr << __FUNCTION__ << ": Got unexpected character\n";
					return false;
			}
		}
	}

	bool kitsrus_t::write_eeprom(intelhex::hex_data &HexData)
	{
		uint8_t	c;
		uint8_t i;
		intelhex::hex_data::address_t	j(info.get_eeprom_start());
		uint16_t k;
		intelhex::hex_data::size_type size;
		
		//Ideally we would figure out how many ROM words are going to be written
		//	and then write only that. But, to make things simpler we'll just write
		//	to all of the ROM.
		std::cout << __FUNCTION__ << ": eeprom_start = " << std::hex << j << std::endl;
		std::cout << __FUNCTION__ << ": eeprom_size = " << std::hex << info.eeprom_size << std::endl;
		size = HexData.size_in_range(j, info.get_eeprom_start() + info.eeprom_size);
		std::cout << __FUNCTION__ << ": size = " << size << std::endl;

		//Send program rom command
		com->write(CMD_WRITE_EEPROM);
		com->write( (size & 0xFF00) >> 8);	//Send size hi
		com->write(size & 0x00FF);	//Send size low

		while(1)
		{
			switch(com->read())
			{
				case 'P':
					return true;
				case 'Y':
					std::cout << __FUNCTION__ << ": Got Y\n";
					com->write( HexData[j] & 0x00FF);
//					std::cout << __FUNCTION__ << ": wrote " << std::hex << HexData[j] << "\n";
					++j;
					com->write( HexData[j] & 0x00FF);
//					std::cout << __FUNCTION__ << ": wrote " << std::hex << HexData[j] << "\n";
					++j;
					break;
				default:
					std::cerr << __FUNCTION__ << ": Got unexpected character\n";
					return false;
			}
		}
	}

	void kitsrus_t::write_config(intelhex::hex_data &HexData)
	{
		std::vector<uint8_t> tmp_config(22, 0xFF);
		intelhex::hex_data::address_t	i;
		if( info.is14bit() )
		{
			//If the ID bits were specified use them
			//	otherwise use blanks
			i = info.get_id_start();
			if( HexData.isset(i) )
			{
				tmp_config[0] = HexData[i++];
				tmp_config[1] = HexData[i++];
				tmp_config[2] = HexData[i++];
				tmp_config[3] = HexData[i];
			}
			tmp_config[4] = 'F';
			tmp_config[5] = 'F';
			tmp_config[6] = 'F';
			tmp_config[7] = 'F';
			i = info.get_config_start();
			if( HexData.isset(i) )
			{
				tmp_config[8] = HexData[i] & 0x00FF;
				tmp_config[9] = (HexData[i] & 0xFF00) >> 8;
			}
			else
			{
				std::cerr << __FUNCTION__ << ": no config bits\n";
				return;		//FIXME
			}
		}
		com->write(CMD_WRITE_CONFIG);
		com->write('0');
		com->write('0');
		for( i=0; i<22; ++i)
		{
			com->write(tmp_config[i]);
		}
		com->read();	//Throw away the ack
	}

	void kitsrus_t::write_calibration()
	{}

	//Read from a PIC into a hex_data structure
	void kitsrus_t::read_rom(intelhex::hex_data &HexData)
	{
		intelhex::hex_data::element a;
		
		com->write(CMD_READ_ROM);
//		std::cout << "About to read " << info.rom_size << " words\n";
		for(unsigned i=0; i<info.rom_size; ++i)
		{
//			std::cout << "\r" << i;
			a = (com->read() << 8) & 0xFF00;
			a |= com->read() & 0x00FF;
			HexData[i] = a;
		}
//		std::cout << "\r";
//		std::cout << "\nRead " << info.rom_size << " words\n";
	}

	void kitsrus_t::read_eeprom(intelhex::hex_data &HexData)
	{
		intelhex::hex_data::address_t i(info.get_eeprom_start());
		const intelhex::hex_data::address_t stop(i + info.eeprom_size);

		intelhex::hex_data::element a;
		intelhex::hex_data::address_t j(0);

//		std::cout << __FUNCTION__ << ": eeprom_start = " << std::hex << i << std::endl;
//		std::cout << __FUNCTION__ << ": eeprom_stop = " << std::hex << stop << std::endl;
//		std::cout << __FUNCTION__ << ": eeprom_size = " << std::hex << info.eeprom_size << std::endl;

		com->write(CMD_READ_EEPROM);
		for(; i<stop; ++i)
		{
			HexData[i] = com->read();
//			std::cout << __FUNCTION__ << ": HexData[" << std::hex << i << "] = " << std::hex << HexData[i] << std::endl;
//			a = com->read();
//			std::cout << __FUNCTION__ << ": j = " << std::hex << (j++) << "\t" << std::hex << a << "\n";
		}
	}

	void kitsrus_t::read_config(intelhex::hex_data &HexData)
	{
		intelhex::hex_data::element	a[26];
		com->write(CMD_READ_CONFIG);
		
		uint8_t b = com->read();	//Throw away the ack
		if(b != 'C')
			std::cerr << __FUNCTION__ << ": Bad config ack\n\tExpected C got " << b << std::endl;
		else
			std::cout << __FUNCTION__ << ": Got ack\n";

		for(unsigned i=0; i<26; ++i)
		{
			a[i] = com->read();
//			std::cout << __FUNCTION__ << ": read " << std::hex << a[i] << "\n";
		}
		
		if(info.is14bit())
		{
			HexData[0x2000] = a[2];
			HexData[0x2001] = a[3];
			HexData[0x2002] = a[4];
			HexData[0x2003] = a[5];

			HexData[0x2007] = (a[0x0B] << 8) | a[0x0A];
		}
	}

	void kitsrus_t::erase_chip()
	{
		com->write(CMD_ERASE);
		uint8_t a = com->read();
		if( a != 'Y')
			std::cerr << __FUNCTION__ << ": Bad erase\n\tExpected Y got: " << a << std::endl;
		else
			std::cout << __FUNCTION__ << ": Got Y\n";
	}

	bool kitsrus_t::detect_chip()
	{
		com->write(CMD_IN_SOCKET);
		if( com->read() == 'A' )
		{
			com->read();
			return true;
		}
		else
			return false;
	}

	int kitsrus_t::get_version()
	{
		if(firmware < 0)
		{
			com->write(CMD_GET_VERSION);
			firmware = com->read();
		}
		return firmware;
	}

	std::string kitsrus_t::get_protocol()
	{
		std::string s;
		com->write(CMD_GET_PROTOCOL);
		s.push_back(com->read());
		s.push_back(com->read());
		s.push_back(com->read());
		s.push_back(com->read());
		return s;
	}

	std::string kitsrus_t::kit_name()
	{
		switch(firmware)
		{
			case KIT_128:
				return "Kit 128";
			case KIT_149A:
				return "Kit 149A";
			case KIT_149B:
				return "Kit 149B";
			case KIT_150:
				return "Kit 150";
			case KIT_170:
				return "Kit 170";
			case KIT_182:
				return "Kit 182";
			case KIT_185:
				return "Kit 185";
			default:
				return "Unknown";
		}
	}

	bool kitsrus_t::get_chip_info(std::basic_ifstream<char> &in, std::string PartName)
	{
		std::string line;

		//Read each line and search it for the part name
		while(in)
		{
			line.clear();
			std::getline(in, line);
			if(line.find(PartName) != std::string::npos)
			{
				//Found the correct line, now read out the record
				while(in)	//Get each line until a blank line
				{
					//Check each line for a space
					//If it doesn't have a space its a key=value pair
					if( line.find(' ') == std::string::npos )
					{
						//Split the line at the '='
						int j = line.find('=');
//						std::string key = line.substr(0, j);
//						std::string value = line.substr(j+1);
						info.set(line.substr(0, j), line.substr(j+1));
					}
					line.clear();				//Discard the used line
					std::getline(in, line);	//Get the next line in the record
					line.replace(line.find('\r'),1,"");	//Ignore DOS newlines
					if(line.length() == 0)	//Records are terminated with a blank line
						return true;
				}
			}
		}
		return false;
	}

/*
	bool pocket_t::write16(uint8_t buf)
	{
		return write16(&buf, 1);
	}

	bool pocket_t::write16(const void *buf, size_t nbytes)
	{
		static	int bytes = 0;		//Byte counter
		int i;
		u_int8_t	in;

		if(buf!=NULL)
		{
			for(i=0; i<nbytes; i++)
			{
				if(bytes<16)
				{
					if(bytes==0)					//If we're at a packet boundary
						write('Y');			//Start a new packet
					write(((char *)buf)[i]);			//Send the next byte
					bytes++;							//Record that the byte was sent
				}
				else
				{
					read(&in, 1);				//If at the end of a packet...
					if(in=='R')						//...wait for the pocket to respond
					{
						bytes=0;							//and reset the byte counter
						i--;	//BAD BAD BAD Well...I haven't thought of a better/cleaner way
								//This is so it doesn't skip a character at packet boundaries
					}
					else
						return false;
				}
			}
		}
		else
		{
			//If a NULL has been sent and nbytes==0 then assume the NULL was intentional
			//	which means the packet transfer needs to be terminated. so...
			if(nbytes==0)
			{
				for(;bytes<16;bytes++)		//Pad the last packet
					write(0);
				read(&in, 1);
				if(in=='R')						//Wait for a response from the pocket
					write('N');			//and then tell it to go away
				else
					return false;
			}
		}
		return true;
	}

	bool pocket_t::write16a(u_int8_t buf)
	{
		return write16a(&buf, 1);
	}

	//This function exists because the export protocol uses different constants
	//	than the info/msg protocol. Hopefully I'll be able to get Tony to change that so
	//	this function can go away.
	bool pocket_t::write16a(const void *buf, size_t nbytes)
	{
		static	int bytes = 0;		//Byte counter
		int i;
		u_int8_t	in;

		if(buf!=NULL)
		{
			for(i=0; i<nbytes; i++)
			{
				if(bytes<16)
				{
					if(bytes==0)					//If we're at a packet boundary
						write(0x00);			//Start a new packet
					write(((char *)buf)[i]);			//Send the next byte
					bytes++;							//Record that the byte was sent
				}
				else
				{
					read(&in, 1);				//If at the end of a packet...
					if(in=='M')						//...wait for the pocket to respond
					{
						bytes=0;							//and reset the byte counter
						i--;	//BAD BAD BAD Well...I haven't thought of a better/clean way
								//This is so it doesn't skip a character at packet boundaries
					}
					else
						return false;
				}
			}
		}
		else
		{
			//If a NULL has been sent and nbytes==0 then assume the NULL was intentional
			//	which means the packet transfer needs to be terminated. so...
			if(nbytes==0)
			{
				for(;bytes<16;bytes++)		//Pad the last packet
					write(0);
				read(&in, 1);
				if(in=='M')						//Wait for a response from the pocket
					write(0xFF);			//and then tell it to go away
				else
					return false;
			}
		}
		return true;
	}

	int	read_messages(FILE *fp)
	{
		char buff[32];		//Temporary buffer
		int	len;			//number of bytes in the buffer
		int index;
		char	s1[] = " THE POCKET by";
		char	s2[] = "BUBBLE  SOFTWARE";
		nummsg=0;
		while(fscanf(fp,"%x,",&index)==1)		//Read the index number and check for EOF
		{
			if(index>=LO_MESSAGE_INDEX && index<=HI_MESSAGE_INDEX)		//Make sure index is in bounds
			{
				//Use fscanf instead of fgets because fgets has issues with DOS CR/LF
				fscanf(fp, "%[^\n]%n",buff, &len);			//Get the message string
				buff[len] = 0x0;									//Add terminating NULL
				MessageString[index] = new char[len+1];	//Allocate space for the string
				strcpy(MessageString[index],buff);			//Copy it
				nummsg++;
			}
		}
		MessageString[0] = new char[strlen(s1)+1];
		strcpy(MessageString[0], s1);
		MessageString[1] = new char[strlen(s2)+1];
		strcpy(MessageString[1],s2);
		nummsg+=2;
		return 1;
	}

	int read_chipdat(FILE *fp)
	{
		char buff[500];
		char name[256];
		int d, i, j, k, page;
		char c;
		
		while(!feof(fp))
		{
			c=fgetc(fp);
			switch(c)
			{
				case '[':				//Start of new chip definition
					//Allocate a new chipinfo structure
					chips = (chipinfo *)realloc(chips,sizeof(chipinfo)*(numchips+1));
					numchips++;
					
					fscanf(fp,"%[^]]\n%n",buff, &d);						//Read the chip name
					chips[numchips-1].name = new char[d+1];			//Allocate space for the string
					strncpy(chips[numchips-1].name,buff,d);			//Copy the string
					chips[numchips-1].name[d] = 0x0;						//Append a NULL
					//Scan the next line for ROM pages, EEPROM pages, RAM pages,
					//	Programming pin select and EEPROM programming delay
					fscanf(fp,"%x %x %x %d %c", &chips[numchips-1].rompages, &chips[numchips-1].eeprom_size, &chips[numchips-1].rampages, &d, &c);
					if(d==1) chips[numchips-1].vpp_select = VPP_PIN1;
					if(d==2) chips[numchips-1].vpp_select = VPP_PINS514;
					if(c=='S') chips[numchips-1].eeprom_prog_delay = EEPROM_DELAY_SHORT;
					if(c=='L') chips[numchips-1].eeprom_prog_delay = EEPROM_DELAY_LONG;

					//Read the part pin count and code protect warning flag
					fscanf(fp,"%d %c", &d, &c);
					switch(d)
					{
						case 0: chips[numchips-1].pin_count = PIC_8PINS; break;
						case 1: chips[numchips-1].pin_count = PIC_18PINS; break;
						case 2: chips[numchips-1].pin_count = PIC_28PINS; break;
						case 3: chips[numchips-1].pin_count = PIC_40PINS; break;
					}
					if(c=='Y') chips[numchips-1].cp_warn = true;
					if(c=='N') chips[numchips-1].cp_warn = false;

					//Read the binary code format
					fscanf(fp," %c", &c);
					if(c=='M') chips[numchips-1].codetype = CODE_INHX8M;
					if(c=='2') chips[numchips-1].codetype= CODE_INHX32;

					//Internally programmable flag, Id words, Fuse words, 
					fscanf(fp," %c %d %d", &c, &chips[numchips-1].idwords, &chips[numchips-1].fusewords);
					if(c=='Y') chips[numchips-1].internal_prog = true;
					if(c=='N') chips[numchips-1].internal_prog = false;
					for(i=0;i<4;i++)						//Read in the fuse masks
						fscanf(fp,"%x %x", &chips[numchips-1].fuse_and[i], &chips[numchips-1].fuse_or[i]);
					fscanf(fp,"\n");						//Take the newline off the stream
					break;
					
				case '#':			//Register aliases
				/*
					fscanf(fp,"%d", &page);			//Get the page number
					fgets(buff,500,fp);				//Get the rest of the line
					chips[numchips-1].num_aliases[page]=0;		//Count the aliases on the line
					for(i=0;i<strlen(buff);i++)	//	by counting the comma's
						if(buff[i]==',') chips[numchips-1].num_aliases[page]+=1;
					chips[numchips-1].aliases[page] = new ram_alias[chips[numchips-1].num_aliases[page]];//Allocate space for the aliases

					//Scan buff and extract the aliases
					i=0; j=0;
					while(i<strlen(buff))
					{
						if(buff[i]==',')		//Find commas
						{
							i++;
							k=0;
							while(buff[i]!=';')	//Read until a semicolon
							{
								name[k] = buff[i];	//Store the character
								k++;						//Inc the counter
								i++;
							}
							i++;
							name[k] = 0x0;
							//Finish storing the alias
							chips[numchips-1].aliases[page][j].alias = new char[strlen(name)];
							strcpy(chips[numchips-1].aliases[page][j].alias,name);
							sscanf(&buff[i],"%x",&chips[numchips-1].aliases[page][j].address);	//Read address
							j++;		//Increment the alias counter
						}
						i++;
					}
					break;
				*/
/*				case '%':
				case '/':
				case '@':
					ungetc(c, fp);		//Put the char back so it can be stored with the line
					//Lenghten the array of pointers
					chips[numchips-1].textline = (char **)realloc(chips[numchips-1].textline, (chips[numchips-1].num_textlines+1)*sizeof(char*));
					if(chips[numchips-1].textline!=NULL)
					{
						chips[numchips-1].textline[chips[numchips-1].num_textlines] = new char[500];		//Allocate a new string
						fgets(chips[numchips-1].textline[chips[numchips-1].num_textlines],500,fp);			//Store the text
						chips[numchips-1].textline[chips[numchips-1].num_textlines][strlen(chips[numchips-1].textline[chips[numchips-1].num_textlines])-1] = 0x0;	//Strip the newline character
						chips[numchips-1].num_textlines++;												//Inc the line counter
					}
					else
						printf("%s: No memory\n", __FUNCTION__);
					break;
				default:
					fgets(buff,500,fp);		//Discard unrecognized lines
			}
		}
		return 1;
	}

	u_int16_t size(chipinfo chip)
	{
		int i;
		u_int16_t s;
		
		s = 49 + strlen(chip.name);
		for(i=0;i<chip.num_textlines;i++)
			s += strlen(chip.textline[i]) + 1;
	}

	int send_msgdat(pocket_t pocket)
	{
		char	S[100];					//a string
		int i, j, k;					//loop counters
		u_int16_t	mai, mi, ci;	//index pointers
		u_int8_t	c, in, hi, lo;		//miscellaneous variables
		bool	abort=false;			//not used
		
		//Calculate the address of the chip address section
		mai = 6 + 5*numchips;	//4 address bytes + 2 for numchips and then all the delimeters
		for(i=0;i<numchips;i++)							//Add up the string lengths
			mai += strlen(chips[i].name);	
		mi = mai + nummsg*2;								//Start of Message string section
		ci = mi;												//Start of chipinfo section 
		for(i=0;i<nummsg;i++)								//Add string lengths
			ci += strlen(MessageString[i])+1;
		
		pocket.write16(HIBYTE(mai));				//Send message address index (2 bytes)
		pocket.write16(LOBYTE(mai));
		pocket.write16(0x0);							//Pad the addres w/ 2 bytes
		pocket.write16(0x0);
		sprintf(S,"%02X\n", numchips);				//Send the number of chips in the dataset
		pocket.write16(S, 2);

		for(i=0;i<numchips;i++)							//Send the chip names
		{
			pocket.write16('[');
			pocket.write16(strlen(chips[i].name));	//Name length
			pocket.write16(chips[i].name, strlen(chips[i].name));		//Name
			pocket.write16(']');
			//Info location
			pocket.write16(HIBYTE(ci+2+strlen(chips[i].name)));
			pocket.write16(LOBYTE(ci+2+strlen(chips[i].name)));
			ci += size(chips[i]);		//Start of next chipinfo
		}

		for(i=0;i<nummsg;i++)							//Send message addresses
		{
			pocket.write16(HIBYTE(mi));						//Send MSB first
			pocket.write16(LOBYTE(mi));
			mi += strlen(MessageString[i])+1;			//Start of next string
		}

		for(i=0;i<nummsg;i++)							//Send the messages
		{
			pocket.write16(MessageString[i], strlen(MessageString[i]));
			pocket.write16('^');
		}

		for(i=0;i<numchips;i++)									//Write out the chip info
		{
			pocket.write16('[');
			pocket.write16(chips[i].name, strlen(chips[i].name));
			pocket.write16(']');
			sprintf(S, "%2X", chips[i].rompages);				//ROM pages
			pocket.write16(S[1]);	pocket.write16(S[0]);
			sprintf(S, "%4X", chips[i].eeprom_size);			//EEPROM pages
			for(j=3;j>=0;j--)
				pocket.write16(S[k]);
			pocket.write16(chips[i].vpp_select+48);		//VPP pin select
			switch(chips[i].eeprom_prog_delay)					//Programming delay
			{
				case	EEPROM_DELAY_SHORT:	pocket.write16('S');	break;
				case	EEPROM_DELAY_LONG:	pocket.write16('L');	break;
			}
			pocket.write16(chips[i].pin_count+48);				//Pin count
			pocket.write16(chips[i].cp_warn ? '1' : '0');	//CP warning?
			switch(chips[i].codetype)
			{
				case	CODE_INHX8M: pocket.write16('M');
				case	CODE_INHX32: pocket.write16('2');
			}
			pocket.write16(chips[i].internal_prog ? '1' : '0');
			pocket.write16(chips[i].idwords+48);
			pocket.write16(chips[i].fusewords+48);
			for(j=0;j<4;j++)													//Fuse masks
			{
				sprintf(S, "%4X", chips[i].fuse_and[j]);
				for(k=3;k>=0;k--)
					pocket.write16(S[k]);
				sprintf(S, "%4X", chips[i].fuse_or[j]);
				for(k=3;k>=0;k--)
					pocket.write16(S[k]);
			}
			for(j=0;j<chips[i].num_textlines;j++)	//Raw text
			{
				pocket.write16(chips[i].textline[j], strlen(chips[i].textline[j]));
				pocket.write16('^');
			}
		}
		sprintf(S, "!!!end^");
		pocket.write16(S, strlen(S));	//Signal EOF to Pocket
		pocket.write16(NULL, 0);		//Close out the packet stream
	}

	struct	memdata
	{
		u_int8_t	rom;
		u_int16_t	eeprom;
		u_int8_t	fuse[2][4];
	};


	u_int16_t swap16(u_int16_t in)
	{
		return ((in & 0x00FF)<<8) | ((in & 0xFF00)>>8);
	}

	//Swaps lo and hi such that lo becomes the new MSB and hi becomes the new LSB
	u_int16_t swap8s(u_int8_t lo, u_int8_t hi)
	{
		return (((u_int16_t)lo)&0x00FF)<<8 | (((u_int16_t)hi) & 0x00FF);
	}

	struct file_header
	{
		char			name[13];
		u_int8_t		id[4];
		u_int16_t	fuse[4];
		u_int8_t		rom;
		u_int16_t	eeprom;
		char			format;
	};

	//Import a hex file from the Pocket and save it to path
	void pocket_t::importfile(const char *path)
	{
		u_int8_t	rompages;
		int	romsize;
		u_int16_t eepromsize;
		u_int8_t	*data;
		u_int8_t	a, b;
		int total, r, n;
		file_header	hdr;
		char	file[256];
		
		write(POC_ANYCHAR);			//Send Ack
		read(&rompages);				//Get ROM pages (1 page = 256 words)
		romsize = 256*rompages;		//Convert to ROM words
		read(&a);						//High byte of EEPROM size
		read(&b);						//Low byte of EEPROM size
		eepromsize = (a<<8) | b;	//Put it all together
		total = 32 + 2*romsize + eepromsize;
		data = new u_int8_t[total];
*/	/*	
		printf("%s: ROM pages: %d\n", __FUNCTION__, rompages);
		printf("%s: ROM size: %d words\n", __FUNCTION__, romsize);
		printf("%s: EEPROM size: %d\n", __FUNCTION__, eepromsize);
		printf("%s: total size: %d\n", __FUNCTION__, total);
	*/
/*		n=0;
		r=0;
		write('M');				//Initial data request
		while(r<total)
		{
			if(n>=16)
			{
				write('M');		//Request more data
				n=0;
			}
			n+=read(&(data[r]),16-n);		//Read 16 bytes and store them
			r+=n;
		}
		write('N');						//No more data
		read(&a);						//Pocket wants the filename
		write('N');						//Tell Pocket to bugger off

		printf("%s: Received %d bytes\n", __FUNCTION__, r);
		
		//Time to decipher what was sent and save it

		//The data starts with the file header
		memcpy(hdr.name, data, 12);	//Filename
		hdr.name[12] = 0x00;				//Ensure that its terminated
		hdr.id[0] = data[13];			//ID locations
		hdr.id[1] = data[12];
		hdr.id[2] = data[15];
		hdr.id[3] = data[14];
		hdr.fuse[0] = (data[16]<<8) | data[17];	//Configuration fuses
		hdr.fuse[1] = (data[18]<<8) | data[19];
		hdr.fuse[2] = (data[20]<<8) | data[21];
		hdr.fuse[3] = (data[22]<<8) | data[23];

		hdr.rom = data[26];				//ROM pages
		hdr.eeprom = (data[27]<<8) | data[28];			//EEPROM size in bytes
		//hdr.format = (data[29]=='M') ? HEX_FORMAT_INHX8M : HEX_FORMAT_INHX32;
		if(data[29]=='M')
		{
			hdr.format = HEX_FORMAT_INHX8M;
			printf("INHX8M\n");
		}
		else if(data[29]=='2')
		{
			hdr.format = HEX_FORMAT_INHX32;
			printf("INHX32\n");
		}
		else
			hdr.format = data[29];

		printf("Filename: %s\n", hdr.name);
		printf("ID: 0x%X 0x%X 0x%X 0x%X\n", hdr.id[0], hdr.id[1], hdr.id[2], hdr.id[3]);
		printf("Fuse: 0x%X 0x%X 0x%X 0x%X\n", hdr.fuse[0], hdr.fuse[1], hdr.fuse[2], hdr.fuse[3]);
		printf("ROM pages: %d\n", hdr.rom);
		printf("EEPROM size: %d\n", hdr.eeprom);
		printf("Format: %d\n", hdr.format);
		
		if(path==NULL)
		{
			//Ask the user for a path/filename
			printf("Filename (./%s): ", hdr.name);
			n=0;
			scanf("%[^\n]%n", file, &n);
			if(n==0)
				strcpy(file, hdr.name);
			//write a hex file
			printf("Saved ./%s\n", hdr.name);

		}
		
	}

	void pocket_t::exportfile(const char *path)
	{
*/	/*	int i, n = 0;
		char c;
		memdata	memdat;
		char	buff[100];
		file_header fh;
		
		//Open the file
		//Fill out file header
		strcpy(fh.name, "file.hex");
		
		
		write('Y');			//Tell the Pocket all is good
		read(buff, 19);		//Get the ROM/EEPROM/Fuse data
		memdat.rom = buff[0];
		memdat.eeprom = ((u_int16_t)buff[1])<<8 + (0x00FF & (u_int16_t)buff[2]);	//Swap bytes
		for(i=0;i<4;i++)
		{
			memdat.fuse[0][i] = ((u_int16_t)(buff[i*4+3]))<<8 + (0x00FF & (u_int16_t)(buff[i*4+4]));	//Swap bytes
			memdat.fuse[1][i] = ((u_int16_t)(buff[i*4+5]))<<8 + (0x00FF & (u_int16_t)(buff[i*4+6]));	//Swap bytes
		}
		
		write('Y');
		read(&c);
		if(c=='F')
		{
			//Send file header
			tty.write(fh.name, 12);		//File name

			tty.write(fh.id[0]);	tty.write(fh.id[1]);	//Id bytes
			tty.write(fh.id[2]);	tty.write(fh.id[3]);

			tty.write(fh.fuse[0]);	tty.write(fh.fuse[1]);
			tty.write(fh.fuse[2]);	tty.write(fh.fuse[3]);
			tty.write(fh.fuse[4]);	tty.write(fh.fuse[5]);
			tty.write(fh.fuse[6]);	tty.write(fh.fuse[7]);

			tty.write(0x0); tty.write(0x0);

			tty.write(fh.rom);
			tty.write(HIBYTE(fh.eeprom));
			tty.write(LOBYTE(fh.eeprom));
			tty.write(fh.type ? 'M' : '2');
			
			//send_file(tty, path);	//Send file
			//pocket_write2(tty, ,);
			tty.read(&c, 1);
			if(c=='F')
			{
				tty.read(buff, 32);			//Get useage info
				tty.write(POC_ANYCHAR);		//Send 1 byte
			}
		}
	*/		
/*	}

	//Starting at menu 1, go to menu 2
	bool	pocket_t::enter_ppro()
	{
		write(0x00);			//Enter programmer mode (go to menu 2)
		write(prog_speed);	//Send programming speed (fast)
		if(read()=='P')		//Make sure it ack'd properly
		{
			//printf("Got P\n");
			menu_num = 2;			//Record state (PWaitCom)
			return true;
		}
		else
			return false;
		
	}

	u_int8_t	pocket_t::leave_ppro()
	{
		write(PP_QUIT);			//Always leave the programmer in menu 1
		menu_num = 1;
		return read();				//Pocket should reply with 'Q'
	}

	//Handle PocketPro mode starting from the first menu
	//	***FIXME***	Hardcoded for 16F877
	//	***FIXME***	Hardcoded for Vpp1
	void	pocket_t::ppro(char command, const char *path)
	{
		u_int8_t c, c1, FuseHi, FuseLo;
		u_int16_t id, fuse, rom;
		unsigned int ch;
		intelhex::dblock	*db;
		intelhex::hex_data	hexd;
		
		//printf("%s\n", __FUNCTION__);
		if(enter_ppro())
		{
			pp_setvpp(1);		//Set Vpp to Vpp1

			switch(command)
			{
				case PP_PROGRAM: 
					if(!hexd.load(path))	//Load the hex file
					{
						printf("Couldn't load %s\n", path);
						return;
					}
					
					printf("Programming..."); 
					fflush(stdout);
					pp_writeprogram(&hexd, 0x2000);
					
	//				printf("Waiting for pocket...\n");
	//				fflush(stdout);
					sleep(1);		//wait 1 sec for the pocket to reset itself
	//				printf("awake\n");
					write(0x01);
					c = read();		//Should be a P
					c = read();		//Should be a P
					write(POC_ANYCHAR);
					enter_ppro();

					//Program EEPROM
					printf("Done\n");
					break;
				case PP_FUSES:
					if(!hexd.load(path))	//Load the hex file
					{
						printf("Couldn't load %s\n", path);
						return;
					}
					
	 				//Program fuses
	 				printf("Programming Fuses and ID's...\n");
	 				fflush(stdout);
					write(PP_WRITE_EFUSE);
					//Find the dblock with fuse info in it
					for(intelhex::lst_dblock::iterator i=hexd.blocks.begin(); i!=hexd.blocks.end();++i)
					{
						if(i->first >= 0x2007)
						{
							if(i->first > 0x2007)	//One block too far?
								--i;										//	Step back
	//						printf("Fuse @ %d\n", i);
							if(i->first <= 0x2007)	//Fuse is in the middle of the block?
							{
								FuseHi = HIBYTE(i->second[0x2007 - i->first]);
								FuseLo = LOBYTE(i->second[0x2007 - i->first]);
								printf("Fuse: %02X%02X\n", FuseHi, FuseLo);
							}
							break;		//Jump out of the FOR loop
						}
					}
					write(FuseHi);	//Send hibyte of fuse word
					write(FuseLo);	//Send lobyte of fuse word
					write(0xF1);	//Send bogus ID bytes
					write(0xF2);
					c = read();
					if(c!='Y');
						printf("%c\n", c);
				
					break;
				case PP_EEPROM:
				{
					if(!hexd.load(path))	//Load the hex file
					{
						printf("Couldn't load %s\n", path);
						return;
					}
					//Find the last block that starts before the EEPROM address
					//*** FIXME *** Hard coded for 16F877
					intelhex::lst_dblock::reverse_iterator ri = hexd.blocks.rbegin();
					while((ri!=hexd.blocks.rend()) && (ri->first > 0x2100) )
						ri++;
					if(ri==hexd.blocks.rend())	//Check for a valid block number
					{
						std::cerr << "No EEPROM data (EOF)\n";
						break;
					}
					//Make sure the block actually includes the EEPROM address
					//*** FIXME *** Hard coded for 16F877
					if( (ri->first + ri->second.size()) < 0x2100 )
					{
						std::cerr << "No EEPROM data\n";
						break;
					}

					std::cout << "Programming EEPROM...\n" << std::flush;
					write(PP_WRITE_EEPROM);
					unsigned j;
					//Initialize di to point to the first byte of EEPROM data
					//	***	FIXME	*** hardcoded for 16F877
					intelhex::data_container::iterator di = ri->second.begin()+ (ri->first - 0x2100);
					for(j=0;j<256; j++)
					{
						unsigned k = j%8;
						if(k==0)	//Check for 8-byte packet boundaries
						{
							if(read()=='M')
								write('Y');		//Tell Pocket there's more data
							else
							{
								ch = read();	//Get the failure address
								std::cout << "Error at " << std::hex <<  ch << std::endl;
								break;	//This should really be an exception throw
							}
						}
						//If the end of a block has been reached, go to the next block
						if(di == ri->second.end())	
						{
							ri--;		//Go forward by decrementing since ri is a reverse iterator
							di = ri->second.begin();	//Set di to point to the beggining of the next block
						}
						if(ri==hexd.blocks.rend())	//If no more blocks...
						{
							for(;k<8;k++)	//Finish the packet
								write(0xFF);
							j=500;	//Force the j loop to terminate
							break;	//break out of the k loop
						}
						write(static_cast<uint8_t>(*di));		//Write out a data byte
						++di;		//Go to the next data byte
					}
					if(j>=256)
						write('N');		//No more data
					std::cout << "Finished EEPROM\n";
					return;
					break;
				}
				case PP_BLANK: 
					printf("Erasing...");
					fflush(stdout);
					ch = pp_bulkerase('1', 0x2000);			//Erase the chip
					printf("%c\n", ch);						//Display the result ('Y')
					break;
				case PP_VERIFY: 
					printf("Verify\n"); 
					//Read the pic
					//Compare it against path
					//Display the results
					break;
				case PP_READ:
					printf("Saving %s\n", path);
					pp_readprogram(&hexd, 0x2000);			//Read the program memory
					pp_readfuse(&id, &fuse);				//Read the configuration word
					db = hexd.add_block(0x2000, 1);		//Add it to the hex file
					db->second[0] = id;
					db = hexd.add_block(0x2007, 1);		//Add it to the hex file
					db->second[0] = fuse;
					pp_readeeprom(&hexd, 256);				//Read the EEPROM and add it to the hex file
					hexd.write(path);							//Save the file to disk
					break;
				case PP_BLANKCHECK: 
					printf("Blank Checking..."); 
					fflush(stdout);
					switch(ch=pp_blankcheck(0x2000))
					{
						case	'R': 
							printf("Program Memory isn't blank\n");
							break;
						case	'I':
							printf("ID location isn't blank\n");
							break;
						case	'F':
							printf("Configuration word isn't blank\n");
							break;
						default:
							printf("%d\n", ch);
							break;
					}
					break;
			}
			//printf("%c\n", leave_ppro());
			leave_ppro();
		}	
		else
			printf("No P\n");
	}

	void pocket_t::pp_writeprogram(intelhex::hex_data *hexd, unsigned numwords)
	{
		unsigned int i, j;
		unsigned char c;
		
		write(PP_PROGVERE);		//Program command
		//Program the program memory
		for(intelhex::lst_dblock::iterator i=hexd->blocks.begin(); i!=hexd->blocks.end();++i)
		{
			if(i->first < numwords)
			{
				//	** This if() could easily be merged with the interior if(), but that would
				//	require short-circuit logic to keep i from being decremented each time
				if( i!= hexd->blocks.begin() )
				{
					intelhex::lst_dblock::const_iterator prev = (--i)++;	//Get an iterator to the previous element w/o changing i
					//Check for gaps between blocks and fill them with NOP's
					if(i->first != (prev->first + prev->second.size()) )
						//Fill the gap with NOP's
						for(j=0; j< (i->first - (prev->first + prev->second.size())); j++)
							if(read()=='M')
							{
								write(0x3F);
								write(0xFF);
							}
				}
				for(j=0; j<i->second.size(); j++)
				{
					switch(c=read())
					{
						case 'M':
							//printf("Got M\n");
							write((i->second[j] & 0xFF00)>>8);	//Send high byte
							write(i->second[j] & 0x00FF);		//Send low byte
							//printf("Sent: 0x%04X\n", hex->blocks[i].data[j]);
							break;
						case 'F':
							printf("Programming Failure @ 0x");
							fflush(stdout);
							printf("%02X", read());
							printf("%02X\n", read());
							return;
							break;
					}
				}
			}
		}
		if(read()=='M')
		{
			write(0xFF);
			write(0x00);
		}
	}

	void pocket_t::pp_readprogram(intelhex::hex_data *hexd, unsigned numwords)
	{
		unsigned	numblocks;
		u_int16_t i, j;
		intelhex::dblock *db;
		numblocks = numwords/8;				//Find required number of data blocks
		while(numwords > numblocks*8)		//Check for incomplete blocks
			numblocks++;						//	inc number of block if necessary
		//printf("Numwords %d Numblocks %d\n", numwords, numblocks);

		for(i=0; i<numblocks; i++)			//For each block
			pp_read8words(hexd->add_block(i*8, 8));	//Read 8 words and store them
	}

	//Set Vpp pins
	//	1: Vpp1
	//	2: Vpp2
	u_int8_t	pocket_t::pp_setvpp(char vpp)
	{
		write(PP_SET_VPP);
		switch(vpp)
		{
			case 1: write('1'); break;
			case 2: write('2'); break;
		}
		return read();		//Pocket should return 'Y'
	}

	void	pocket_t::pp_read8words(intelhex::dblock *db)
	{
		if(db->second.size() < 8)
			db->second.resize(8);
		
		write(PP_READ_8_WORDS);		//Send read command
		
		for(int i=0; i<8; i++)
			db->second[i] = (read()<<8) | read();
	}

	void pocket_t::pp_readeeprom(intelhex::hex_data *hexd, unsigned numbytes)
	{
		unsigned numblocks = numbytes/8;			//Find required number of data blocks
		while(numbytes > (numblocks*8))			//Check for incomplete blocks
			numblocks++;								//	inc number of blocks if necessary

		for(unsigned i=0; i<numblocks; i++)		//For each block
			pp_read8words(hexd->add_block(i*8 + 0x2100, 8));	//Read 8 words and store them
	}

	void	pocket_t::pp_read8eeprom(intelhex::dblock *db)
	{
		if(db->second.size() < 8)	//Make sure the vector is big enough
			db->second.resize(8);
		
		write(PP_READ_8_EEPROM);		//Send read command
		
		for(int i=0; i<8; i++)			//Read the data
			db->second[i] = read();
	}

	//Read the Fuse and ID words when in PocketPro mode
	//	Assumes menu 2 (i.e. at PWaitCom)
	//	Leaves Pocket at menu 2
	void	pocket_t::pp_readfuse(u_int16_t *id, u_int16_t *fuse)
	{
*/	/*	if(menu_num!=2)		//If not already in menu 2
			if(enter_ppro())		//Reenter ppro mode
			{
				write(PP_READ_FUSE);					//Send read id/fuse command
				*id = (read()<<8) | read();		//ID word (MSB first)
				*fuse = (read()<<8) | read();		//Fuse word (MSB first)
			}
		else						//Else, continue
		{*/
/*			write(PP_READ_FUSE);					//Send read id/fuse command
			*id = (read()<<8) | read();		//ID word (MSB first)
			*fuse = (read()<<8) | read();		//Fuse word (MSB first)
		//}
	}

	//Blank check the PIC
	//	Assumes menu 2 (i.e. at PWaitCom)
	//	Leaves Pocket at menu 2
	u_int8_t	pocket_t::pp_blankcheck(u_int16_t romsize)
	{
		write(PP_BLANK_CHECK);							//Send blank check command
		write((u_int8_t)((romsize & 0xFF00)>>8));	//MSB of ROM size
		write((u_int8_t)(romsize & 0x00FF));		//LSB of ROM size
		return read();
	}

	//Blank the PIC
	//	Assumes menu 2 (i.e. at PWaitCom)
	//	Leaves Pocket at menu 2
	u_int8_t	pocket_t::pp_bulkerase(u_int8_t vpp, u_int16_t romsize)
	{
		write(PP_ERASE);									//Send erase command
		write(vpp);											//Select Vpp pins
		write((u_int8_t)((romsize && 0xF0)>>8));	//MSB of ROM size
		write((u_int8_t)(romsize && 0x0F));			//LSB of ROM size
		return read();
	}
*/
}	//namespace pocket
