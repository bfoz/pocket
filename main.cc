/* Filename: main.cc
 * CLI interface program for Tony Nixon's Pocket Programmer 
 * For more info on the Pocket Programmer see http://bubblesoftonline.com/pocket/pocket.html
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#define	USE_OLD_TTY

#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include "pocket.h"
#include "tty.h"
#include "intelhex.h"

static	pocket::pocket_t	Pocket;
static	char	devpath[256] = "/dev/cuaa0";
static	char	msgpath[256] = "pocket.msg";
static	char	datpath[256] = "chipdat.txt";

//Argument style is similar to tar(1)
//	p	program using pocketpro mode
// v	verify using pocketpro mode
// r 	dump the pic to file specified by f
// e 	bulk erase the pic
// b 	blank check
// f:	write fuse and id
// E: write EEPROM
// m:	path to message file
// c:	path to chip data file
#define	OPTIONS	"p:evr:bf:E:m:c:"

//This is paranoia, files *should* get closed after a ^C, but just in case...
//	It doesn't handle the msg and chipinfo files, but they're not open very long
void catch_ctrl_c(int signo)
{
	printf("\nCaught ^C\n");
	Pocket.close();
	printf("Goodbye!\n");
	exit(0);											//Abandon ship
}

int main(int argc, char *argv[])
{
	FILE *fp;
	char c;
	char s[2];
	bool	done = false;
	struct sigaction	sact;
	char	path[256];							//Path
	int	ch, n;
	char	command;
	
	sact.sa_handler = catch_ctrl_c;		//Setup for the signal handler
	sigemptyset(&sact.sa_mask);
	sact.sa_flags = 0;

	if(sigaction(SIGINT, &sact, NULL) < 0) //Be paranoid and catch the ^C
		printf("Couldn't register signal handler, continuing anyway\n");

	while((ch = getopt(argc, argv, OPTIONS)) != -1)
		switch(ch)
		{
			case	'p': 	//Issue PocketPro programming command
				command = PP_PROGRAM;
				strcpy(path, optarg);	//optarg is the filename
				break;
			case	'e':	//Erase the chip
				command = PP_BLANK;
				break;
			case	'b':	//Blank check
				command = PP_BLANKCHECK;
				break;
			case	'v': //Issue PocketPro verify command
				command = PP_VERIFY;
				break;
			case	'r':	//Issue PocketPro read command
				command = PP_READ;
				strcpy(path, optarg);	//optarg is the filename
				break;
			case	'f':		//Write fuse and id
				command = PP_FUSES;
				strcpy(path, optarg);	//optarg is the filename
				break;
			case	'E':
				command = PP_EEPROM;
				strcpy(path, optarg);
				break;
			case	'm':		//Path to message file
				strcpy(msgpath, optarg);
				break;
			case	'c':		//Path to chip data file
				strcpy(datpath, optarg);
				break;
			case	'?':	//Display useage information
			default:	
				break;
		}
	argc -= optind;
	argv += optind;
	
/*
	hex_data	hex;
	hex.load("test.hex");
	hex.write("test2.hex");
	exit(0);
	*/
	//Open the serial port and set the baud rate
	if((Pocket.open(devpath,O_RDWR))==-1)
	{
		printf("Couldn't open %s", devpath);
		exit(1);
	}
	Pocket.rawmode();		//Set the terminal to raw mode

	//Try to detect PocketPro mode
	//Send a 1 to the port. If the pocket is listening it should respond
	Pocket.write(0x01);
	while(!done)		//Wait for data
	{
		//Handle state changes due to input
		switch(c=Pocket.read())
		{
			case POC_REQICHIP:	
				if(Pocket.read()==POC_REQICHIP)
				{
					printf("Pocket is requesting chip data\n");
					if((fp=fopen(msgpath,"r"))==NULL)		//Open the messages file
					{
						printf("Couldn't open message file: %s\n", msgpath);
						exit(1);
					}
					pocket::read_messages(fp);					//Read in the messages
					fclose(fp);										//Close msgpath
					
					if((fp=fopen(datpath,"r"))==NULL)		//Open the chip data file
					{
						printf("Couldn't open chip data file: %s\n", datpath);
						exit(1);
					}
					if(pocket::read_chipdat(fp)==-1)					//Read and parse chip data
						printf("Error reading chip data file: %s\n", datpath);
					fclose(fp);										//Close datpath
					
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
					printf("PocketPro detected\n");
					Pocket.write(POC_ANYCHAR);	//Acknowledge with a single byte
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
			default: printf("%x\n", c); break;		//Ignore garbage
		}
	}

	Pocket.close();
	
	return 0;
}
