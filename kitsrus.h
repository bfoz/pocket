/* Filename: kitsrus.h
	Interface to Tony Nixon's PIC Programmers via the Kitsrus protocol
	This works for Kits 128, 149A, 149B, 150, 182

	Copyright (c) 2005, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#ifndef KITSRUS_H
#define KITSRUS_H

#include <fstream>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "chipinfo.h"
#include "tty.h"
#include "intelhex.h"


namespace kitsrus
{

	class kitsrus_t
	{
		//Kitsrus Commands
		#define	CMD_NULL					0x00
		#define	CMD_RESET				0x01
		#define	CMD_ECHO					0x02
		#define	CMD_INITVAR				0x03
		#define	CMD_VPP_ON				0x04
		#define	CMD_VPP_OFF				0x05
		#define	CMD_VPP_CYCLE			0x06
		#define	CMD_WRITE_ROM			0x07
		#define	CMD_WRITE_EEPROM		0x08
		#define	CMD_WRITE_CONFIG		0x09
		#define	CMD_WRITE_CAL			0x0A
		#define	CMD_READ_ROM			0x0B
		#define	CMD_READ_EEPROM		0x0C
		#define	CMD_READ_CONFIG		0x0D
		#define	CMD_ERASE				0x0E
		#define	CMD_CHECK_ROM			0x0F
		#define	CMD_CHECK_EEPROM		0x10
		#define	CMD_WRITE_FUSE			0x11
		#define	CMD_IN_SOCKET			0x12
		#define	CMD_NOT_IN_SOCKET		0x13
		#define	CMD_GET_VERSION		0x14
		#define	CMD_GET_PROTOCOL		0x15
		#define	CMD_WR_DEBUG_VECTOR	0x16
		#define	CMD_RD_DEBUG_VECTOR	0x17
		#define	CMD_WR_CAL_10F			0x18

		//Kitsrus Firmware Types
		#define	KIT_128					0x00
		#define	KIT_149A					0x01
		#define	KIT_149B					0x02
		#define	KIT_150					0x03
		#define	KIT_170					0x04
		#define	KIT_182					0x05
		#define	KIT_185					0x44

		tty_t	*com;		//Pointer the tty to be used for communicating
		chipinfo::chipinfo	info;
		
		int	firmware;	//The firmware type of the programmer

	public:
		typedef	chipinfo::chipinfo::rom_size_type	rom_size_type;
		typedef	chipinfo::chipinfo::eeprom_size_type	eeprom_size_type;

		kitsrus_t() : com(NULL), firmware(-1) {}
		void	set_tty(tty_t *t) {com = t;}
		bool	command_mode();
		bool	soft_reset();
		bool	hard_reset();

		bool	init_program_vars();
		bool	chip_power_on();
		bool	chip_power_off();
		bool	chip_power_cycle();
		bool	write_rom(intelhex::hex_data &);
		bool	write_eeprom(intelhex::hex_data &);
		void	write_config(intelhex::hex_data &);
		void	write_calibration();
		void	read_rom(intelhex::hex_data &);
		void	read_eeprom(intelhex::hex_data &);
		void	read_config(intelhex::hex_data &);
		void	erase_chip();
		void	blank_check_rom();
		void	blank_check_eeprom();
		void	write_18F_fuse();
		bool	detect_chip();
		int	get_version();
/*
	#define	CMD_NOT_IN_SOCKET		0x13
	#define	CMD_WR_DEBUG_VECTOR	0x16
	#define	CMD_RD_DEBUG_VECTOR	0x17
	#define	CMD_WR_CAL_10F			0x18
*/
		std::string	get_protocol();
		std::string kit_name();
		bool	get_chip_info(std::basic_ifstream<char>&, std::string);
		bool	get_chip_info(ext_attrs_t &, std::string);
		rom_size_type	get_rom_size() {return info.rom_size; }
		eeprom_size_type	get_eeprom_size() {return info.eeprom_size; }
		uint32_t	get_eeprom_start() {return info.get_eeprom_start(); }
		void	set_149();	//Ugly kludge to work around the K149 reset logic
	};

}	//namespace kitsrus
#endif
