/* Filename: main.cc
 * CLI interface program for Tony Nixon's Pocket Programmer 
 * For more info on the Pocket Programmer see http://bubblesoftonline.com/pocket/pocket.html

	Copyright (c) 2002, Terran Development Corporation
	All rights reserved.
	This code is made available to the public under a BSD-like license, a copy of which
	should have been provided with this code in the file LICENSE. For a copy of the BSD 
	license template please visit http://www.opensource.org/licenses/bsd-license.php

 * */

#define	USE_OLD_TTY

#include <fstream>

#include <iostream>
#include <sstream>

#include <getopt.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/errno.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include	"extattr.h"
#include "kitsrus.h"

#include "pocket.h"
#include "tty.h"
#include "intelhex.h"

static	pocket::pocket_t	Pocket;
static	tty_t com;	//Device interface object

#if defined(__APPLE__) && defined(__MACH__)
//	#define	TTY_OPEN_FLAGS	(O_RDWR | O_NONBLOCK)
	#define	TTY_OPEN_FLAGS	(O_RDWR | O_NOCTTY)
#else
	#define	TTY_OPEN_FLAGS	(O_RDWR | O_NOCTTY | O_NONBLOCK)
#endif

//Commands
#define	CMD_ERASE_CHIP	PP_BLANK
#define	CMD_PROGRAM_ALL	0x08
#define	CMD_PROGRAM_ROM	PP_PROGRAM
#define	CMD_PROGRAM_EEPROM	PP_EEPROM
#define	CMD_PROGRAM_CONFIG	PP_FUSES
//#define	CMD_READ_ROM	0xFF
#define	CMD_READ_ALL	PP_READ
#define	CMD_UPDATE_INFO	0x09
#define	CMD_CLEAR_INFO		0x0A

static	char	msgpath[256] = "pocket.msg";
static	std::string	ChipInfoPath = "chipinfo.cid";
static	std::string	DevicePath;
static	std::string	HexPath;
static	std::string	PartName;
static	std::string	UpdatePath;
static	std::string	UpdateURL = "http://bfoz.net/projects/pocket/PartsDB/export.php?format=extattr&noslashes=true";

//Argument style is similar to tar(1)
//	k	Use Kitsrus protocol P018 (16 Aug 2004)
// v	verify using pocketpro mode
//	P	Program the ROM, config and EEPROM (in that order)
//	R	program the ROM
// r 	dump the pic to file specified by f
// B 	bulk erase the pic
// b 	blank check
// f:	hex file
// F	write fuse and id
// E write EEPROM
// m:	path to message file
// c:	path to chip data file
//	d:	path to programmer device
//	p:	The part to program (ex. 16F877)
#define	OPTIONS	"bc:d:ef:km:p:qrvBEFPR"

#define	OPT_VAL_UPDATE			1
#define	OPT_VAL_UPDATE_FILE	2
#define	OPT_VAL_UPDATE_URL	3
#define	OPT_VAL_CLEAR_INFO	4
#define	OPT_VAL_NO_UPDATE		5
#define	OPT_VAL_KIT149			6

static int option_val;
static struct option longopts[] = {
	{"kitsrus",	no_argument,			NULL, 'k'},
	{"file",		required_argument,	NULL, 'f'},
	{"chipinfofile",		required_argument,	NULL, 'c'},
	{"quiet",	no_argument,			NULL, 'q'},
	{"device",	required_argument,	NULL, 'd'},
	{"part",		required_argument,	NULL, 'p'},
	{"kit149",	no_argument,			&option_val, OPT_VAL_KIT149},
	{"program",	no_argument,			NULL, 'P'},
	{"writerom",no_argument,			NULL, 'R'},
	{"read",		no_argument,			NULL,	'r'},
	{"erase",	no_argument,			NULL, 'B'},
	{"blankcheck",	no_argument,		NULL, 'b'},
	{"writeconfig",	no_argument,	NULL, 'F'},
	{"writeeeprom",	no_argument,	NULL, 'E'},
	{"verify",			no_argument,	NULL, 'v'},
	{"update",		no_argument,		&option_val, OPT_VAL_UPDATE},
	{"update_file",required_argument,	&option_val, OPT_VAL_UPDATE_FILE},
	{"update_url",	required_argument,	&option_val, OPT_VAL_UPDATE_URL},
	{"clear_info",	no_argument,	&option_val, OPT_VAL_CLEAR_INFO},
	{"no_update",	no_argument,	&option_val, OPT_VAL_NO_UPDATE},
	{ NULL, 0, NULL, 0}
};

void display_usage()
{
	std::cout << "\n./pocket [args] [command]\n";
	std::cout << "\nArguments:\n";
	std::cout << "   -k        --kitsrus     Use Kitsrus protocol (>= P018)\n";
	std::cout << "   -q        --quiet       Be quiet. Useful when piping the output.\n";
	std::cout << "   -f PATH   --file PATH   File path needed by some commands. Use '-' for stdout\n";
	std::cout << "   -d PATH   --device PATH Programmer device node (ex. /dev/tty.usbserial-1B1)\n";
	std::cout << "   -p NAME   --part NAME   Name of the part to be programmed (ex. 16F877)\n";
	std::cout << "             --kit149      Enable Kit149 compatibility (if autodetect fails)\n";
	std::cout << "\nCommands:\n";
	std::cout << "NOTE: It can only do one command at a time\n";
	std::cout << "   -P   --program     Program the ROM, config and EEPROM (in that order)\n";
	std::cout << "   -R   --writerom    Program the ROM\n";
	std::cout << "   -r   --read        Read the PIC into a file\n";
	std::cout << "   -B   --erase       Bulk erase the pic (can be used with -P,--program)\n";
	std::cout << "   -b   --blankcheck  Blank check\n";
	std::cout << "   -F   --writeconfig Write config bits\n";
	std::cout << "   -E   --writeeeprom Write EEPROM\n";
	std::cout << "   -v   --verify      Verify against a hex file\n";
	std::cout << "\nUpdate Chipinfo Commands:\n";
	std::cout << "NOTE: These commands operate on the info for all parts unless a part is \n";
	std::cout << "      specified using -p or --part.\n";
	std::cout << "   --update           Update chip info for all parts\n";
	std::cout << "   --update_file PATH Update chipinfo from the specified file\n";
	std::cout << "   --update_url URL   Update chipinfo from the specified URL\n";
	std::cout << "   --clear_info       Clear all stored chipinfo\n";
	std::cout << "   --no_update        Disable automatic retrieval of needed chipinfo\n";
	std::cout << "\nCopyright 2001-2005 Brandon Fosdick (BSD License)\n\n";
}

//This is paranoia, files *should* get closed after a ^C, but just in case...
//	It doesn't handle the msg and chipinfo files, but they're not open very long
void catch_ctrl_c(int signo)
{
	printf("\nCaught ^C\n");
	exit(0);											//Abandon ship
}

//On exit, reset the programmer and close the device
void handle_exit()
{
	//Reset the kitsrus programmer
	if(DevicePath.length() != 0)
	{
		com.set_dtr();
		for(int i=0; i<10000; ++i) {};	//Delay
		com.clear_dtr();
		com.close();
		Pocket.close();
//		std::cout << "Closed device " << DevicePath << "\r\n";
	}
	std::cout << "Goodbye!\r\n";
}

void do_eeprom_write(kitsrus::kitsrus_t &programmer, intelhex::hex_data &HexData)
{
	const intelhex::hex_data::size_type num_eeprom_bytes = HexData.size_in_range(programmer.get_eeprom_start(), programmer.get_eeprom_start() + programmer.get_eeprom_size());

	if(num_eeprom_bytes > 0)
	{
		programmer.chip_power_on();		//Activate programming voltages
		std::cout << "Programming " << num_eeprom_bytes << " EEPROM bytes for " << PartName << std::endl;
		programmer.write_eeprom(HexData);
		programmer.chip_power_off();		//Turn the chip off
	}
	else
		std::cout << "No EEPROM bytes in file\n";
}

//See if a file already exists
bool	file_exists(const std::string &fn)
{
	struct stat sb;

	if(stat(fn.c_str(),&sb)==0)
		return true;
	else
		return false;
}

#if defined(__APPLE__) && defined(__MACH__)
std::string FetchPrefix = "curl ";
#endif
#if defined(__FreeBSD__)
std::string FetchPrefix = "fetch -q -o - ";
#endif

int main(int argc, char *argv[])
{
	FILE *fp;
	char c;
	char s[2];
	bool	done = false;
	bool	kitsrus = false;	//true if kitsrus protocol mode
	bool	erase_first = false;
	bool	no_update = false;			//true if automatic update has been disabled
	struct sigaction	sact;
	char	path[256];							//Path
	int	ch, n;
	char	command;
	intelhex::hex_data	HexData;
	std::string PathToSelf = argv[0];
	std::string XAFile = PathToSelf;
	
	//getopt() is retarded
	if(argc == 1)
	{
		display_usage();
		exit(0);
	}

	sact.sa_handler = catch_ctrl_c;		//Setup for the signal handler
	sigemptyset(&sact.sa_mask);
	sact.sa_flags = 0;

	if(sigaction(SIGINT, &sact, NULL) < 0) //Be paranoid and catch the ^C
		std::cerr << "Couldn't register signal handler, continuing anyway\n";

	//More paranoia
	if( atexit(handle_exit) == -1 )
	{
		std::cerr << "Couldn't register exit handler. Bailing out.\n";
		exit(1);
	}
	
	//Process command line
	while((ch = getopt_long(argc, argv, OPTIONS, longopts, NULL)) != -1)
		switch(ch)
		{
			case	'k':	//Use Kitsrus protocol
				kitsrus = true;
				break;
			case	'B':	//Bulk erase the chip
				command = CMD_ERASE_CHIP;
				erase_first = true;
				break;
			case	'b':	//Blank check
				command = PP_BLANKCHECK;
				break;
			case	'v': //Verify
				command = PP_VERIFY;
				break;
			case	'P':	//Program ROM, config and EEPROM
				command = CMD_PROGRAM_ALL;
				break;
			case	'R':	//Program the ROM
				command = CMD_PROGRAM_ROM;
				break;
			case	'r':	//Dump the chip to a file given by the -f argument
				command = CMD_READ_ALL;
				break;
			case	'f':		//Hex file
				strcpy(path, optarg);	//optarg is the filename
				HexPath = optarg;
				break;
			case	'F':		//Write Config
				command = CMD_PROGRAM_CONFIG;
				break;
			case	'E':		//Write EEPROM
				command = CMD_PROGRAM_EEPROM;
				break;
			case	'm':		//Path to message file (Pocket pro only)
				strcpy(msgpath, optarg);
				break;
			case	'c':		//Path to chip data file
				ChipInfoPath = optarg;
				break;
			case	'd':		//Path to serial device
				DevicePath = optarg;
				break;
			case	'p':		//The name of the device to program (ex. 16F877)
				PartName = optarg;
				break;
			case 0:	//Handle long opts with no shortcut
				switch(option_val)
				{
					case OPT_VAL_UPDATE:
						command = CMD_UPDATE_INFO;
						break;
					case OPT_VAL_UPDATE_FILE:
						UpdatePath = optarg;
						break;
					case OPT_VAL_UPDATE_URL:
						UpdateURL = optarg;
						break;
					case OPT_VAL_CLEAR_INFO:
						command = CMD_CLEAR_INFO;
						break;
					case OPT_VAL_NO_UPDATE:
						no_update = true;
						break;
					case OPT_VAL_KIT149:
						break;
				}
				break;
			default:	//Display usage information
				display_usage();
				exit(0);
				break;
		}
	argc -= optind;
	argv += optind;

	//Find out if the XAs can be stored with the executable or 
	//	if they need to be stored with a dotfile
	if( setxattr(XAFile, "net.bfoz:test", "test", 0) == -1)	//Set a test XA
	{
		//If the underlying filesystem doesn't support XA, then try to store
		//	them in a dot file in the user's home directory
		if(errno == ENOTSUP)
		{
			XAFile = std::string(getenv("HOME")) + std::string("/.pocket");
			std::cout << "Using " <<  XAFile << " for chip info\n";
			//	If the dot file doesn't exist, try to create it
			if( !file_exists(XAFile) )
			{
				system((std::string("touch ")+XAFile).c_str());
			}
		}
	}
	removexattr(XAFile, "net.bfoz:test");	//Remove the test XA
	
	//Handle Chipinfo related commands
	std::string Response;
	std::string Key, Value;
	std::istringstream ResponseStream;
	char S[512];
	switch(command)
	{
		case CMD_UPDATE_INFO:
			if(UpdatePath.length() != 0)
				fp = popen(("cat " + UpdatePath).c_str(), "r");
			else
			{
//				std::cout << "Updating from " << (FetchPrefix + "\"" + UpdateURL + "\"") << std::endl;
				fp = popen((FetchPrefix + "\"" + UpdateURL + "\"").c_str(), "r");
			}

			//Store the returned data in a string
			//	This seemed easier than futzing with fgets to figure out if it 
			//		returned a full line. So dump it all to a string, turn it into a stream,
			//		and then use std::getline to pull out whole lines as strings.
			while(!feof(fp))
			{
				if( fgets(S, 512, fp) != NULL )
					Response += S;
			}
			pclose(fp);

			//Turn the string into a stream so we can do something useful with it
			ResponseStream.str(Response);
			
			//Seperate the stream into strings (one per line)
			while(ResponseStream)
			{
				getline(ResponseStream, Key);	//First line is the key
				getline(ResponseStream, Value);	//Second line is the value

				//Getline screwiness
				if( (Key.length() == 0) || (Value.length()==0) )
					continue;

//				std::cout << Key << " => " << Value << "\n";
				//Set the attribute
				if( setxattr(XAFile, Key, Value, 0) == -1)
				{
					std::cerr << "Bad setxattr ( [" << Key << "] => [" << Value << "] ): " << strerror(errno) << "\n";
					exit(1);
				}
			}
			exit(0);
			break;
		case CMD_CLEAR_INFO:
			if( file_exists(XAFile) )
				remove_xattr(XAFile, "net.bfoz:projects:pocket:PartsDB");

			std::cout << "Chipinfo cleared\n";

			exit(0);
			break;
	}
	
	//Bail out if a device path isn't available
	if(DevicePath.length() == 0)
	{
		std::cerr << "A device path must be specified\n";
		exit(1);
	}
	
	//The bulk erase command is the only one that doesn't need a part type specified
	if((command != CMD_ERASE_CHIP) && (PartName.length() == 0) )
	{
		std::cerr << "The name of the part to program must be specified\n";
		exit(1);
	}

	switch(command)
	{
	//If ROM, EEPROM or Fuses are being programmed load in the hex file
		case CMD_PROGRAM_ALL:
		case CMD_PROGRAM_ROM:
		case CMD_PROGRAM_EEPROM:
		case CMD_PROGRAM_CONFIG:
			if(!HexData.load(HexPath))
			{
				std::cerr << "Couldn't load hex file " << HexPath << std::endl;
				exit(1);
			}
			break;
	//If ROM, EEPROM or Fuses are being read ensure a file name was provided
		case CMD_READ_ALL:
			if(HexPath.length() == 0)
			{
				std::cerr << "Need a file to store the data in\n";
				exit(1);
			}		
	}
	
	if(kitsrus)
	{
		//The Kitsrus DIY programmers require a chipinfo file since they don't store the info internally
		//Get the attributes for this chip
		const std::string prefix("net.bfoz:projects:pocket:PartsDB:" + PartName + ":");
		ext_attrs_t	attrs = getxattrs(XAFile, prefix);
		if( attrs.size() == 0 )
		{
			std::cerr << "Couldn't find the chip info for the specified part ( " << PartName << " )\n";
			exit(1);
		}

		//Trim the prefix from the attributes
		for(ext_attrs_t::iterator i = attrs.begin(); i != attrs.end(); ++i)
		{
			i->first.erase(i->first.begin(), i->first.begin() + prefix.length());
		}
		
		kitsrus::kitsrus_t programmer;
		if(!programmer.get_chip_info(attrs, PartName))	//Get the info for the specified part
		{
			std::cerr << "Had trouble getting the chip info for part " << PartName << std::endl;
			exit(1);
		}
		
		if( (com.open(DevicePath.c_str(), TTY_OPEN_FLAGS))==-1 )
		{
			std::cerr << "Couldn't open " << DevicePath << std::endl;
			exit(1);
		}

		//	Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
		//	See fcntl(2) ("man 2 fcntl") for details.
/*		if(fcntl(com.fd, F_SETFL, 0) == -1)
		{
			std::cerr << "Error clearing O_NONBLOCK " << DevicePath << " - " << strerror(errno) << "(" << errno << ").\n";
			com.close();
			exit(1);
		}
*/	
//		std::cout << "Opened device " << DevicePath << std::endl;
		com.rawmode();		//Set the terminal to raw mode
		if(!com.flush())		//Just to make sure
		{
			std::cerr << "Couldn't flush " << DevicePath << std::endl;
			exit(1);
		}
		

		//Turn the TTY over to a handler for this programmer
		programmer.set_tty(&com);
		
		//Try a soft reset
		if(!programmer.soft_reset())
		{
//			std::cout << "Soft reset failed\nTrying a hard reset\n";
			
			if(!programmer.hard_reset())
			{
				std::cout << "Hard reset failed. Trying a K149 reset...\n";
				//Try assuming that the programmer is a Kit149
				programmer.set_149();
				if(!programmer.hard_reset())
				{
					std::cerr << "Couldn't reset the device\n";
					exit(EXIT_FAILURE);
				}
			}
		}
		//Enter command mode
		if(!programmer.command_mode())
		{
			std::cerr << "Couldn't enter Command Mode\n";
			exit(1);
		}
//		std::cout << "Entered Command Mode\n";
		
		//Check the protocol version
		std::string protocol = programmer.get_protocol();
		if( protocol != "P018" )
		{
			std::cerr << "Wrong protocol version ( " << protocol << " )\n";
			exit(1);
		}
		std::cout << "Using Kitsrus protocol " << protocol << std::endl;

		//Now read the programmer type
		int firmware = programmer.get_version();
		std::cout << "Detected " << programmer.kit_name() << std::endl;

		//The bulk erase command is the only one that doesn't need the programming
		// variables initialized first
		if(command != CMD_ERASE_CHIP)
				programmer.init_program_vars();	//Initialize programming variables

		switch(command)
		{
			case	CMD_PROGRAM_ALL:
				if(erase_first)
				{
					programmer.chip_power_on();		//Activate programming voltages
					programmer.erase_chip();
					programmer.chip_power_off();		//Turn the chip off
					std::cout << "Erased " << PartName << std::endl;
				}
				programmer.chip_power_on();		//Activate programming voltages
				std::cout << "Programming " << HexData.size_below_addr(programmer.get_rom_size()) << " ROM words for " << PartName << std::endl;
				if( !programmer.write_rom(HexData) )
				{
					std::cerr << "Error programming ROM\n";
					programmer.hard_reset();		//Do a hard reset
					exit(1);								// and then bail out
				}
				programmer.chip_power_off();		//Turn the chip off
				
				programmer.chip_power_on();		//Activate programming voltages
				std::cout << "Programming Config for " << PartName << std::endl;
				programmer.write_config(HexData);
				programmer.chip_power_off();		//Turn the chip off

				do_eeprom_write(programmer, HexData);
				break;
			case CMD_PROGRAM_ROM:
				programmer.chip_power_on();		//Activate programming voltages
				std::cout << "Programming " << HexData.size_below_addr(programmer.get_rom_size()) << " ROM words for " << PartName << std::endl;
				if( !programmer.write_rom(HexData) )
				{
					std::cerr << "Error programming ROM\n";
					programmer.hard_reset();		//Do a hard reset
					exit(1);								// and then bail out
				}
				programmer.chip_power_off();		//Turn the chip off
				break;
			case CMD_PROGRAM_EEPROM:
				do_eeprom_write(programmer, HexData);
				break;
			case CMD_PROGRAM_CONFIG:
				programmer.chip_power_on();		//Activate programming voltages
				std::cout << "Programming Config for " << PartName << std::endl;
				programmer.write_config(HexData);
				programmer.chip_power_off();		//Turn the chip off
				break;
//			case CMD_READ_ROM:
//				break;
			case CMD_READ_ALL:
				std::cout << "Reading " << programmer.get_rom_size() << " ROM words\n";
				programmer.chip_power_on();		//Activate programming voltages
				programmer.read_rom(HexData);	//Read ROM
				programmer.chip_power_off();		//Turn the chip off
				std::cout << "Reading CONFIG\n";
				programmer.chip_power_on();		//Activate programming voltages
				programmer.read_config(HexData);	//Read Config
				programmer.chip_power_off();		//Turn the chip off
				std::cout << "Reading " << programmer.get_eeprom_size() << " EEPROM bytes\n";
				programmer.chip_power_on();		//Activate programming voltages
				programmer.read_eeprom(HexData);	//Read EEPROM
				programmer.chip_power_off();		//Turn the chip off
				std::cout << "Read " << HexData.size() << " words from " << PartName << " into " << HexPath << std::endl;
				if(HexPath == "-")
					HexData.write(std::cout);	//Write to stdout
				else
					HexData.write(HexPath.c_str());	//Write it all out to a file
				break;
			case CMD_ERASE_CHIP:
				programmer.chip_power_on();		//Activate programming voltages
				programmer.erase_chip();
				programmer.chip_power_off();		//Turn the chip off
				std::cout << "Erased " << PartName << std::endl;
				break;
			default:
				std::cerr << "Unrecognized command\n";
				break;
		}
		exit(0);	//Done
	}
	else
	{	
		//Open the serial port and set the baud rate
		if((Pocket.open(DevicePath.c_str(), TTY_OPEN_FLAGS))==-1)
		{
			std::cerr << "Couldn't open " << DevicePath << std::endl;
			exit(1);
		}
	}

	//	FIXME	A dirty hack to get this working on OSX 
	//	FIXME	Need to move this to tty_t::open()
#if defined(__APPLE__) && defined(__MACH__)
	//	Note that open() follows POSIX semantics: multiple open() calls to 
	//	the same file will succeed unless the TIOCEXCL ioctl is issued.
	//	This will prevent additional opens except by root-owned processes.
	//	See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
/*	if(ioctl(Pocket.fd, TIOCEXCL) == -1)
	{
		std::cerr << "Error setting TIOCEXCL on " << DevicePath << " - " << strerror(errno) << "(" << errno << ").\n";
		Pocket.close();
		exit(1);
    }
*/	//	Now that the device is open, clear the O_NONBLOCK flag so 
	//	subsequent I/O will block.
	//	See fcntl(2) ("man 2 fcntl") for details.
	if(fcntl(Pocket.fd, F_SETFL, 0) == -1)
	{
		std::cerr << "Error clearing O_NONBLOCK " << DevicePath << " - " << strerror(errno) << "(" << errno << ").\n";
		exit(1);
	}	

#endif

	std::cout << "Opened device " << DevicePath << std::endl;
	Pocket.rawmode();		//Set the terminal to raw mode
//	Pocket.close();
//	exit(0);

	//Try to detect PocketPro mode
	//Send a 1 to the port. If the pocket is listening it should respond
	Pocket.write(0x01);
//	std::cout << "done write\n";
	while(!done)		//Wait for data
	{
//		std::cout << Pocket.read() << std::endl << "read something\n";

		//Handle state changes due to input
		switch(c=Pocket.read())
		{
			case POC_REQICHIP:	
				if(Pocket.read()==POC_REQICHIP)
				{
					std::cout << "Pocket is requesting chip data\n";
					if((fp=fopen(msgpath,"r"))==NULL)		//Open the messages file
					{
						printf("Couldn't open message file: %s\n", msgpath);
						exit(1);
					}
					pocket::read_messages(fp);					//Read in the messages
					fclose(fp);										//Close msgpath
					
					if((fp=fopen(ChipInfoPath.c_str(),"r"))==NULL)		//Open the chip data file
					{
						printf("Couldn't open chip data file: %s\n", ChipInfoPath.c_str());
						exit(1);
					}
					if(pocket::read_chipdat(fp)==-1)					//Read and parse chip data
						printf("Error reading chip data file: %s\n", ChipInfoPath.c_str());
					fclose(fp);										//Close ChipInfoPath
					
					//Send messages and chip data
					printf("Exporting message and chip info\n");
					Pocket.write(POC_ANYCHAR);
					Pocket.read(&c, 1);
					if(c=='R')
						send_msgdat(Pocket);
					done = true;
					printf("Finished exporting\n");
				}
				break;
			case POC_REQICOMM:	//Export a hex file to the pocket
				if(Pocket.read()==POC_REQICOMM)
				{
					if(path[0]!=0x00)
					{
						printf("Pocket wants a file\n");
						printf("Enter path or <enter> to abort.\n");
						n = 0;
						scanf("%[^\n]%n", path, &n);
					}
					if(n>0)
					{
						printf("Exporting %s to the Pocket\n", path);
						//handle_export(pocket, path);
					}
					else		//Abort the transfer
					{
						Pocket.write('N');
						done = true;
					}
				}
				break;
			case POC_REQECOMM:
				if(Pocket.read()==POC_REQECOMM)
				{
					printf("Pocket is sending a file\n");
					Pocket.importfile(NULL);
					done=true;
				}
				break;
			case POC_POCKETPRO:		//The Pocket was either just turned on, or it was waiting in menu 1
				if(Pocket.read()==POC_POCKETPRO)
				{
					std::cout << "PocketPro detected\n";
					Pocket.write(POC_ANYCHAR);	//Acknowledge with a single byte
					std::cout << "wrote\n";
					Pocket.ppro(command, path);					//Handle menu 1
					done = true;
				}
				break;
			case 'X':
				//It was in the second menu, and now its in the first menu
				//So reset it and let everything be handled normally
				printf("Found it, it was in menu 2\n");
				Pocket.write(0x01);	//Reset it again
				break;
			default: printf("unrecognized character: %x\n", c); break;		//Ignore garbage
		}
	}

//	Pocket.close();
//	std::cout << "Closed device " << DevicePath << std::endl;

	return 0;
}
