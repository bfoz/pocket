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

static	tty_t tty;
static	pocket_t	pocket;
static	char	devpath[256] = "/dev/cuaa0";
static	char	msgpath[256] = "pocket.msg";
static	char	datpath[256] = "chipdat.txt";

//This is paranoia, files *should* get closed after a ^C, but just in case...
//	It doesn't handle the msg and chipinfo files, but they're not open very long
void catch_ctrl_c(int signo)
{
	printf("\nCaught ^C\n");
	tty.close();
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
	int	n;
	
	sact.sa_handler = catch_ctrl_c;		//Setup for the signal handler
	sigemptyset(&sact.sa_mask);
	sact.sa_flags = 0;

	if(sigaction(SIGINT, &sact, NULL) < 0) //Be paranoid and catch the ^C
		printf("Couldn't register signal handler, continuing anyway\n");
	
	if((fp=fopen(msgpath,"r"))==NULL)		//Open the messages file
	{
		printf("Couldn't open %s\n", msgpath);
		exit(1);
	}
	read_messages(fp);					//Read in the messages
	fclose(fp);
	
	if((fp=fopen(datpath,"r"))==NULL)				//Open the chip data file
	{
		printf("Couldn't open %s\n", datpath);
		exit(1);
	}
	if(read_chipdat(fp)==-1)							//Read and parse chip data
		printf("Error reading %s\n", datpath);
	fclose(fp);


	//Open the serial port and set the baud rate
	if((tty.open(devpath,O_RDWR))==-1)
	{
		printf("Couldn't open %s", devpath);
		exit(1);
	}
	pocket.fd = tty.fd;		//**** Temporary kludge to use both pocket_t and tty_t
	tty.rawmode();		//Set the terminal to raw mode
	
	while(tty.read(&s, 2)==2)		//Wait for data
	{
		//Handle state changes due to input
		switch(s[0])
		{
			case POC_REQICHIP:	
				if(s[1]==POC_REQICHIP)
				{
					printf("Pocket is requesting chip data\n");
					//Send messages and chip data
					tty.write(POC_ANYCHAR);
					tty.read(&c, 1);
					if(c=='R')
						send_msgdat(tty);
					done = true;
				}
				break;
			case POC_REQICOMM:
				if(s[1]==POC_REQICOMM)
				{
					printf("Pocket wants a file\n");
					printf("Enter path or <enter> to abort.\n");
					n = 0;
					scanf("%[^\n]%n", path, &n);
					if(n>0)
						handle_export(tty, path);
					else		//Abort the transfer
					{
						tty.write('N');
						done = true;
					}
				}
				break;
			case POC_REQECOMM:
				if(s[1]==POC_REQECOMM)
				{
					printf("Pocket is hailing\n");
				}
				break;
			case POC_POCKETPRO:
				if(s[1]==POC_POCKETPRO)
				{
					printf("The Pocket says it's in PocketPro mode\n");
					tty.write(POC_ANYCHAR);	//Acknowledge with a single byte
					//Send programming speed
					tty.read(&c, 1);			//Wait for Pocket to acknowledge
				}
			default: printf("%x%x\n", s[0], s[1]);		//Ignore garbage
		}
		if(done)
			break;
		//Act on the current state
	}

	tty.close();
	
	return 0;
}
