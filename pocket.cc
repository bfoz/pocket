/* Filename: pocket.cc
 *	Interface to Tony Nixon's Pocket Programmer
 * Copyright Brandon Fosdick 2001
 * This software and all of its components are available under the BSD License
 * For a copy of the BSD License see http://www.freebsd.org
 * */

#include "pocket.h"

char *MessageString[NUM_MESSAGES];
int	nummsg=0;
int	numchips=0;					//Array of chipinfo structures
chipinfo	*chips=NULL;

pocket_t::pocket_t()
{
	messages = NULL;
	nummsg = 0;
	chips = NULL;
	numchips = 0;
}

bool pocket_t::write16(u_int8_t buf)
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
				//printf("Waiting for R\n");
				read(&in, 1);				//If at the end of a packet...
				if(in=='R')						//...wait for the pocket to respond
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

//This is function only exists because the export protocol uses different constants
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
				//printf("Waiting for R\n");
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
	char buff[256];
	int	len;
	unsigned int index;
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
			case '%':
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

bool pocket_write(tty_t tty, const void *buf, size_t nbytes)
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
					tty.write('Y');			//Start a new packet
				tty.write(((char *)buf)[i]);			//Send the next byte
				bytes++;							//Record that the byte was sent
			}
			else
			{
				//printf("Waiting for R\n");
				tty.read(&in, 1);				//If at the end of a packet...
				if(in=='R')						//...wait for the pocket to respond
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
				tty.write(0);
			tty.read(&in, 1);
			if(in=='R')						//Wait for a response from the pocket
				tty.write('N');			//and then tell it to go away
			else
				return false;
		}
	}
	return true;
}

bool pocket_write(tty_t tty, u_int8_t buf)
{
	return pocket_write(tty, &buf, 1);
}

//This is function only exists because the export protocol uses different constants
//	than the info/msg protocol. Hopefully I'll beable to get Tony to change that so
//	this function can go away.
bool pocket_write2(tty_t tty, const void *buf, size_t nbytes)
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
					tty.write(0x00);			//Start a new packet
				tty.write(((char *)buf)[i]);			//Send the next byte
				bytes++;							//Record that the byte was sent
			}
			else
			{
				//printf("Waiting for R\n");
				tty.read(&in, 1);				//If at the end of a packet...
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
				tty.write(0);
			tty.read(&in, 1);
			if(in=='M')						//Wait for a response from the pocket
				tty.write(0xFF);			//and then tell it to go away
			else
				return false;
		}
	}
	return true;
}

bool pocket_write2(tty_t tty, u_int8_t buf)
{
	return pocket_write(tty, &buf, 1);
}

u_int16_t size(chipinfo chip) return s;
{
	int i;
	s = 49 + strlen(chip.name);
	for(i=0;i<chip.num_textlines;i++)
		s += strlen(chip.textline[i]) + 1;
}

#define	HIBYTE(a)	(u_int8_t)(a>>8)
#define	LOBYTE(a)	(u_int8_t)(a&0x00FF)

int send_msgdat(tty_t tty)
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
	
	pocket_write(tty, HIBYTE(mai));				//Send message address index (2 bytes)
	pocket_write(tty, LOBYTE(mai));
	pocket_write(tty, 0x0);							//Pad the addres w/ 2 bytes
	pocket_write(tty, 0x0);
	sprintf(S,"%02X\n", numchips);				//Send the number of chips in the dataset
	pocket_write(tty, S, 2);

	for(i=0;i<numchips;i++)							//Send the chip names
	{
		pocket_write(tty, '[');
		pocket_write(tty, strlen(chips[i].name));	//Name length
		pocket_write(tty, chips[i].name, strlen(chips[i].name));		//Name
		pocket_write(tty, ']');
		//Info location
		pocket_write(tty, HIBYTE(ci+2+strlen(chips[i].name)));
		pocket_write(tty, LOBYTE(ci+2+strlen(chips[i].name)));
		ci += size(chips[i]);		//Start of next chipinfo
	}

	for(i=0;i<nummsg;i++)							//Send message addresses
	{
		hi = HIBYTE(mi);	lo = LOBYTE(mi);			//Make hi/lo bytes
		pocket_write(tty, &hi, 1);						//Send MSB first
		pocket_write(tty, &lo, 1);
		mi += strlen(MessageString[i])+1;			//Start of next string
	}

	for(i=0;i<nummsg;i++)							//Send the messages
	{
		pocket_write(tty, MessageString[i], strlen(MessageString[i]));
		pocket_write(tty, '^');
	}

	for(i=0;i<numchips;i++)									//Write out the chip info
	{
		pocket_write(tty, '[');
		pocket_write(tty, chips[i].name, strlen(chips[i].name));
		pocket_write(tty, ']');
		sprintf(S, "%2X", chips[i].rompages);				//ROM pages
		pocket_write(tty, &S[1], 1);	pocket_write(tty, &S[0], 1);
		sprintf(S, "%4X", chips[i].eeprom_size);			//EEPROM pages
		pocket_write(tty, &S[3], 1);	pocket_write(tty, &S[2], 1);
		pocket_write(tty, &S[1], 1);	pocket_write(tty, &S[0], 1);
		pocket_write(tty, chips[i].vpp_select+48);		//VPP pin select
		switch(chips[i].eeprom_prog_delay)					//Programming delay
		{
			case	EEPROM_DELAY_SHORT:	pocket_write(tty, 'S');	break;
			case	EEPROM_DELAY_LONG:	pocket_write(tty, 'L');	break;
		}
		pocket_write(tty, chips[i].pin_count+48);				//Pin count
		pocket_write(tty, chips[i].cp_warn ? '1' : '0');	//CP warning?
		switch(chips[i].codetype)
		{
			case	CODE_INHX8M: pocket_write(tty, 'M');
			case	CODE_INHX32: pocket_write(tty, '2');
		}
		pocket_write(tty, chips[i].internal_prog ? '1' : '0');
		c = chips[i].idwords+48; pocket_write(tty, &c, 1);
		c = chips[i].fusewords+48; pocket_write(tty, &c, 1);
		for(j=0;j<4;j++)													//Fuse masks
		{
			sprintf(S, "%4X", chips[i].fuse_and[j]);
			pocket_write(tty, &S[3], 1);	pocket_write(tty, &S[2], 1);
			pocket_write(tty, &S[1], 1);	pocket_write(tty, &S[0], 1);
			sprintf(S, "%4X", chips[i].fuse_or[j]);
			pocket_write(tty, &S[3], 1);	pocket_write(tty, &S[2], 1);
			pocket_write(tty, &S[1], 1);	pocket_write(tty, &S[0], 1);
		}
		/*
		for(j=0;j<chips[i].rampages;j++)
		{
			c = '#'; pocket_write(tty, &c, 1);			//Start of line
			c =j+48; pocket_write(tty, &c, 1);		//ram page
			for(k=0;k<chips[i].num_aliases[j];k++)
			{
				sprintf(S, ",%s;", chips[i].aliases[j][k].alias);
				pocket_write(tty, S, strlen(S));
				sprintf(S, "%2X", chips[i].aliases[j][k].address);
				pocket_write(tty, &S[1], 1);
				pocket_write(tty, &S[0], 1);
			}
			c = '^'; pocket_write(tty, &c, 1);			//End line
		}*/
		for(j=0;j<chips[i].num_textlines;j++)
		{
			//printf("%s: %s\n", 
			pocket_write(tty, chips[i].textline[j], strlen(chips[i].textline[j]));
			c = '^'; pocket_write(tty, &c, 1);
		}
	}
	sprintf(S, "!!!end^");
	pocket_write(tty, S, strlen(S));
	pocket_write(tty, NULL, 0);		//Close out the packet stream
}

struct	memdata
{
	u_int8_t	rom;
	u_int16_t	eeprom;
	u_int8_t	fuse[2][4];
};

struct file_header
{
	char	name[12];
	u_int8_t	id[4];
	u_int8_t	fuse[8];
	u_int8_t	rom;
	u_int16_t	eeprom;
	char	type;
};

void handle_export(tty_t tty, const char *path)
{
	int i, n = 0;
	char c;
	memdata	memdat;
	char	buff[100];
	file_header fh;
	
	//Open the file
	//Fill out file header
	strcpy(fh.name, "file.hex");
	
	
	tty.write('Y');			//Tell the Pocket all is good
	tty.read(buff, 19);		//Get the ROM/EEPROM/Fuse data
	memdat.rom = buff[0];
	memdat.eeprom = ((u_int16_t)buff[1])<<8 + (0x00FF & (u_int16_t)buff[2]);

	for(i=0;i<4;i++)
	{
		memdat.fuse[0][i] = ((u_int16_t)(buff[i*4+3]))<<8 + (0x00FF & (u_int16_t)(buff[i*4+4]));
		memdat.fuse[1][i] = ((u_int16_t)(buff[i*4+5]))<<8 + (0x00FF & (u_int16_t)(buff[i*4+6]));
	}
	
	tty.write('Y');
	tty.read(&c, 1);
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
		pocket_write2(tty, ,);
		tty.read(&c, 1);
		if(c=='F')
		{
			tty.read(buff, 32);			//Get useage info
			tty.write(POC_ANYCHAR);		//Send 1 byte
		}
	}
		
}
