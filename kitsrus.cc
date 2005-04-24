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
		size = HexData.max_addr_below(info.rom_size-1);
//		std::cout << __FUNCTION__ << ": size = " << size << std::endl;

		//Send program rom command
		com->write(CMD_WRITE_ROM);
		com->write( (size & 0xFF00) >> 8);	//Send size hi
		com->write(size & 0x00FF);	//Send size low

		while(1)
		{
			switch(com->read())
			{
				case 'P':
					std::cout << "\n";
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
//					std::cout << __FUNCTION__ << ": Got Y\n";
					std::cout << "." << std::flush;
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
//		std::cout << __FUNCTION__ << ": eeprom_start = " << std::hex << j << std::endl;
//		std::cout << __FUNCTION__ << ": eeprom_size = " << std::hex << info.eeprom_size << std::endl;
		size = HexData.size_in_range(j, info.get_eeprom_start() + info.eeprom_size);
//		std::cout << __FUNCTION__ << ": size = " << size << std::endl;

		//Send program rom command
		com->write(CMD_WRITE_EEPROM);
		com->write( (size & 0xFF00) >> 8);	//Send size hi
		com->write(size & 0x00FF);	//Send size low

		while(1)
		{
			switch(com->read())
			{
				case 'P':
					std::cout << "\n";
					return true;
				case 'Y':
					std::cout << "." << std::flush;
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
//		else
//			std::cout << __FUNCTION__ << ": Got ack\n";

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
//		else
//			std::cout << __FUNCTION__ << ": Got Y\n";
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
//					line.replace(line.find('\r'),1,"");	//Ignore DOS newlines
					if(line.length() == 0)	//Records are terminated with a blank line
						return true;
				}
			}
		}
		return false;
	}
}	//namespace pocket
