;
	list P = 16F876
;
	include "p16f876.inc"

 	errorlevel         -(305), -(302), -(306)

;
; ----------------------------------------------
; SET THIS Flag = 1 IF YOUR CODE USES INTERRUPTS
; ELSE, SET THIS FLAG = 0
; ----------------------------------------------
;
INTERRUPTS = 0
;
; --------------------
; USER RAM DEFINITIONS
; --------------------
;
	CBLOCK 0x20

DelayH			; delay counter H
DelayL			; delay counter L
Flag1			; flag register 1
Flag2			; flag register 2
Flag3			; flag register 3
Flag4			; flag register 4
Flag5			; flag register 5
MenuItem			; currently selected root menu item
LoopDelay			; key repeat delay counter
Temp1			; temp register 1
Temp2			; temp register 2
Temp3			; temp register 3
Temp4			; temp register 4
Temp5			; temp register 5
KeyValue			; keypress value
SelChip			; currently selected chip
TSelChip			; temp storage for selected chip
FNindex			; selected File Number index
KeyTemp			; temp storage for keypress value
Repeat			; key repeat counter
MessPt			; message character pointer
DutyH			; PWM duty H
DutyL			; PWM duty L
CurPos			; dissassembly cursor position
ACount			; GP loop count register
BCount			; GP loop count register
CCount			; GP loop count register
ICount			; GP loop count register
EEdata			; I2C eeprom data
RxHold			; RS232 received data hold register
EEaddH			; storage for I2C eeprom data start address H
EEaddL			; storage for I2C eeprom data start address L
HiROMAdd			; highest ROM address for selected chip
EEsizeH			; highest EEPROM address for selected chip H
EEsizeL			; highest EEPROM address for selected chip L
VPPtype			; VPP type 1 or 2
NibA			; LCD data register
NibB			; LCD data register
Byte64			; 64 byte I2C storage counter
CodeAddH			; I2C address H
CodeAddL			; I2C address L
_SaveH			; temp storage H
_SaveL			; temp storage L
_FSR			; temp storgae for FSR
ProgAddH			; current program address H
ProgAddL			; current program address L
ROMTmpH			; current program data H
ROMTmpL			; current program data L
BlockCnt			; current chip I2C block storage count
ChipAddH			; address of current dissassemble data H
ChipAddL			; address of current dissassemble data L
Data1H			; * DO NOT CHANGE ORDER OF THESE 4 LOCATIONS
Data1L			; * USED IN ID ROUTINES IN THIS ORDER
Data2H			; *
Data2L			; *
Vvalue			; current verify voltage
ProCycs			; programming cycle counter
BMenuItem			; current boot menu item
Bchip			; detected boot chip
EEPdata			; eeprom data for dissassembly
IndexS			; temp storage of currently selected file
InstrH			; dissassembly instruction H
InstrL			; dissassembly instruction L
InsDataH			; dissassembly register H
InsDataL			; dissassembly register L
RAMpage			; current dissassemble RAM page
RAMpageMax		; max RAM pages for selected device
RAMadd			; dissaembled RAM address
TRAMadd			; temp storage for RAMadd
OptIndex			; current fuse option index
FuseH			; fuse value H
FuseL			; fuse value L
FuseItem			; current fuse item index
IDCurMax			; maximum cursor movement
CurFuse			; current fuse number 1 - 4
TBLPTRU			; 18Cxxx program counter U
TBLPTRH			; 18Cxxx program counter H
TBLPTRL			; 18Cxxx program counter L
EEPaddH			; storage of eeprom start addre4ss during load/read H
EEPaddL			; storage of eeprom start addre4ss during load/read L
PICpins			; pic pin count
RmSizeH			; pocketpro data
RmSizeL			; pocketpro data
Temp6			; temp register 6

	ENDC

	CBLOCK 0xA0

ChipBuff: 10h		; text storage space for chip name
Buffer: 10h		; PocketPro Buffer

	ENDC


	CBLOCK 0x110

;
; ***************************
; do not change order of these registers
;
IDloc1H			; ID and Fuse data storage
IDloc1L
IDloc2H
IDloc2L
Fuse1H
Fuse1L
Fuse2H
Fuse2L
Fuse3H
Fuse3L
Fuse4H
Fuse4L

TIDloc1H			; temp ID and Fuse data storage
TIDloc1L			; used for comparing fuse and ID data
TIDloc2H
TIDloc2L
TFuse1H
TFuse1L
TFuse2H
TFuse2L
TFuse3H
TFuse3L
TFuse4H
TFuse4L

Fuse1ANDH			; Fuse AND/OR mask values
Fuse1ANDL
Fuse1ORH
Fuse1ORL
Fuse2ANDH
Fuse2ANDL
Fuse2ORH
Fuse2ORL
Fuse3ANDH
Fuse3ANDL
Fuse3ORH
Fuse3ORL
Fuse4ANDH
Fuse4ANDL
Fuse4ORH
Fuse4ORL

;
; *************************
;

	ENDC


	CBLOCK 0x190

EepBuff			; storage buffer for chip data

	ENDC
;
; --------------------
; SERIAL EEPROM ACCESS
; --------------------
;
Aread	equ b'10100001'	; #0 internal data
Awrite	equ b'10100000'
Bread	equ b'10100011'	; #1 program data
Bwrite	equ b'10100010'
Cwrite	equ b'10100100'	; #2 program data
Cread	equ b'10100101'
;
; --------------------
; INTERNAL EEPROM DATA
; --------------------
;
CalAddr	equ d'0'		; calibration Flag
V5calH	equ d'25'		; 5V cal data H EEPROM address
VHAddress	equ d'35'		; multy V voltage info address H
VLAddress	equ d'36'		; multy V voltage info address L
VFAddress	equ d'37'		; multy V on off
EEChipAdd	equ d'38'		; current chip address
ProMode	equ d'39'		; internal/ICSP mode
EEvalid	equ d'40'		; text data valid
CurProg	equ d'41'		; current program number
CurFile	equ 0x3F		; current filename index
;
; EEPROM BLOCK USAGE BYTES
; 40h - 5Fh
; 64K of EEPROM memory = 256 x 128 word blocks
; 256 / 8 = 32 bytes -> 1 bit per block
; Bit = 1 = unused, Bit = 0 = used
; 
BlockBits	equ 0x40
UpperBits	equ 0x60
;
; EEPROM PROGRAM STORAGE START ADDRESSES
; 32 PROGRAMS MAX = 32 BYTES
; 60h - 7Fh
; High byte used only - Low byte always = 00h
;
StartAdd	equ 0x60
UpperAdd	equ 0x80
FilesMax	equ d'32'
;
; NEW I2C EEPROM PROGRAM DATA STORAGE FORMAT
; 256 BYTE BLOCKS
; 1ST BLOCK
; BYTES 0 - 11    = FILENAME 12 bytes
; BYTES 12 - 13   = ID LOCS (1) H L 2 bytes - 12/16 ID 2001/0 - 2003/2  (18 ID 200007 6 5 4)
; BYTES 14 - 15   = ID LOCS (2) H L 2 bytes - (18 ID 200003 2 1 0)
; BYTES 16 - 17   = FUSE (1) H L 2 bytes - 12/16 fuse 18 fuse 300001 300000
; BYTES 18 - 19   = FUSE (2) H L 2 bytes - 18 fuse 300003 300002
; BYTES 20 - 21   = FUSE (3) H L 2 bytes - 18 fuse 300005 300004
; BYTES 22 - 23   = FUSE (4) H L 2 bytes - 18 fuse 300007 300006
; BYTES 24 - 25   = EEPROM DATA START ADDRESS H L
; BYTES 26        = ROM DATA SIZE H (L = 0)
; BYTES 27 - 28   = EEPROM DATA SIZE H L
; BYTES 29        = FILE TYPE INHX8M OR INHX32


; BYTES 32 - 254  = DATA
; BYTE  255       = ADDRESS OF NEXT DATA BLOCK - H L format
;
BlockLink	equ 0xFF	; block link address of each I2C data block
;
; EEPROM ADDRESS CONSTANTS
;
E_FileName equ 0h
E_NameSize equ d'12'
E_ID1	 equ d'12'
E_ID2	 equ d'14'
E_Fuse1	 equ d'16'
E_Fuse2	 equ d'18'
E_Fuse3	 equ d'20'
E_Fuse4	 equ d'22'
E_EepStart equ d'24'
E_RomSize	 equ d'26'
E_EepSize	 equ d'27'
E_FileType equ d'29'


E_ROMStart equ d'32'	; File ROM start address (L)
;
; SUBSEQUENT BLOCKS
; BYTES 0 - 253   = DATA
; BYTES 255       = ADDRESS OF NEXT DATA BLOCK - HIGH BYTE, LOW BYTE = 0
;
; ----------------
; PORT ASSIGNMENTS
; ----------------
;
KEY	equ 0h		; RA0 = Key switches - Analog
FB	equ 1h		; RA1 = Feedback voltage - Analog
lcdRS	equ 2h		; RA2 = LCD RS pin

SDA	equ 4h		; RA4 = SDA EEPROM - open collector
lcdE	equ 5h		; RA5 = LCD E pin

LCDd7	equ 0h		; RB0 = lcd data bit 7
LCDd6	equ 1h		; RB1 = lcd data bit 6
LCDd5	equ 2h		; RB2 = lcd data bit 5
LCDd4	equ 3h		; RB3 = lcd data bit 4
DataR	equ 4h		; RB4 = programming data bit READ IN
ActLed	equ 5h		; RB5 = Active LED
Clk	equ 6h		; RB6 = Clock
Dat	equ 7h		; RB7 = Data

SCL	equ 0h		; RC0 = SCL EEPROM
HiZ	equ 1h		; RC1 = ICSP data out control - LOW = HiZ
PWM	equ 2h		; RC2 = PWM output
VccOn	equ 3h		; RC3 = VccP
SVP2	equ 4h		; RC4 = VPP2
SVP1	equ 5h		; RC5 = VPP1
Tx232	equ 6h		; RC6 = RS232 TX
Rx232	equ 7h		; RC7 = RS232 RX
;
; FLAG1 BITS
;
LCDmd	equ 0h		; 4 or 8 bit LCD mode
Ms2Ps	equ 1h		; LCD line 2 message control
line	equ 2h		; display message on line 1 or 2
Mnem	equ 3h		; message data control
n_ack	equ 4h		; ACK control to I2C
MVee	equ 5h		; multy V on off
TxtFile	equ 6h		; clear EEPROM on comms timeout
C_Name	equ 7h		; chip name display control
;
; FLAG 2 BITS
;
BootYN	equ 0h		; boot programmer allow
f8M32	equ 1h		; file/chip type 14 or 16 bit
TimeLS	equ 2h		; eeprom type chip program time
FuseYN	equ 3h		; code protect warning flag
FLayer	equ 4h		; selected message line option
OK	equ 5h		; general routine OK result flag
MVdo	equ 6h		; 1st or 2nd Multy V pass
Blank	equ 7h		; verify code is blank testing
;
; FLAG 3 BITS
;
NoVolt	equ 0h		; display verify voltage control
PrBlnk	equ 1h		; blank test before programming
Etype	equ 2h		; eeprom chip type Y or N
Pverf	equ 3h		; verify after programming flag
Mods	equ 4h		; ROM/Fuse data was modified while dissassembling
AddInc	equ 5h		; boot program do progress flag
Up_Dn	equ 6h		; move dissassembling address up or down
AddData	equ 7h		; dissassemble disply control
;
; FLAG 4 BITS
;
cur	equ 0h		; cursor move direction
d_err	equ 1h		; dissassembly code error
nofw	equ 2h		; display F or W control
end_fz	equ 3h		; end of fuse definitions data
IdC	equ 4h		; ID word count 1 or 2
FzC	equ 5h		; Fuse word count 1 or 4
Wdel	equ 6h		; 18Cxxx programming delay flag
;
; FLAG 5 BITS
;
NAInc	equ 0h
;
; ---------------------------------------------------- 
; RAM REGISTERS NEEDED FOR BOOT AND BREAK ROUTINES. DO
; NOT CHANGE OR USE THE LAST 4 RAM REGISTERS IN ANY RAM
; PAGE IF YOU ARE USING BREAK POINTS IN YOUR CODE.
; -----------------------------------------------------
;
	CBLOCK 0x7C
;
W_Hold		; storage for W
S_Hold		; storage for STATUS
dataH		; data H
dataL		; data L
;
	ENDC

SCL_Hi	MACRO
	bsf PORTC,SCL
	ENDM
SCL_Lo	MACRO
	bcf PORTC,SCL
	ENDM
SDA_Hi	MACRO
	bsf STATUS,RP0
	bsf TRISA,SDA
	bcf STATUS,RP0
	ENDM
SDA_Lo	MACRO
	bcf PORTA,SDA
	bsf STATUS,RP0
	bcf TRISA,SDA
	bcf STATUS,RP0
	ENDM
SDA_In	MACRO
	bsf STATUS,RP0
	bsf TRISA,SDA
	bcf STATUS,RP0
	ENDM
SDA_Out	MACRO
	bcf PORTA,SDA
	bsf STATUS,RP0
	bcf TRISA,SDA
	bcf STATUS,RP0
	ENDM

ThisPage	MACRO
	movlw High($)
	movwf PCLATH
	ENDM
;
; ---------------------------------------------------
; THIS IS A MACRO TO USE WHEN YOU NEED TO SET A BREAK
; POINT IN YOUR CODE.
;
; IF ANY INTERRUPTS ARE ENABLED, THEN THEY SHOULD BE
; DISABLED BY USING BCF INSTRUCTIONS SO THE STATUS
; REGISTER CONTENTS ARE NOT DISTURBED.
;
; IF INTERRUPTS WERE DISABLED, THEN THEY SHOULD BE
; RE-ENABLED BY USING A BSF INSTRUCTION SO THE STATUS
; REGISTER CONTENTS ARE NOT DISTURBED.
; ---------------------------------------------------
;
BreakCode	Macro BreakNumber
;
	IF BreakNumber > 0xFF	; test if > FF
	ERROR "Break number exceeds 0xFF"
	ENDIF
;
	IF INTERRUPTS == 1
CInt	bcf INTCON,GIE		; disable interrupts
	btfsc INTCON,GIE		; make sure
	goto CInt
	ENDIF
;
	movwf W_Hold		; save W
	swapf PCLATH,W		; save PCLATH
	movwf Data1L
	movlw High(MonCode)		; set for last ROM page
	movwf PCLATH
	movlw BreakNumber		; user break code value
	call MonCode		; jump to break code start
;
	IF INTERRUPTS == 1
	bsf INTCON,GIE		; re-enable interrupts
	ENDIF
;
	ENDM
;
; ---------------------
; YOUR CODE BEGINS HERE
; ---------------------
;
	org 0x0003
;
UCode	goto Start
;
; ------------------
; ERROR MESSAGE DATA
; ------------------
;
errMessDt	clrf PCLATH
	movf MessPt,W
	addwf PCL
	DT "EEPROM ERROR"
;
; -----------------------
; CONVERT NIBBLE TO ASCII
; -----------------------
;
ToASCII	clrf PCLATH
	andlw 0Fh
	addwf PCL
	retlw '0'
	retlw '1'
	retlw '2'
	retlw '3'
	retlw '4'
	retlw '5'
	retlw '6'
	retlw '7'
	retlw '8'
	retlw '9'
	retlw 'A'
	retlw 'B'
	retlw 'C'
	retlw 'D'
	retlw 'E'
	retlw 'F'
;
; GET I2C EEPROM TEXT OFFSET FOR MENU LABELS - BIT 7 = 1, ADD CHIP NAME AS WELL
;
GetDvalue	clrf PCLATH
	movf MenuItem,W		; select function
	addwf PCL
	retlw 4h			; file manager
	retlw 3h			; chip
	retlw 7h			; dissassemble
	retlw 8h			; examine fuse data
	retlw 80H + 09h		; program + chip
	retlw 80h + 0Ah		; read + chip
	retlw 80h + 0Bh		; verify + chip
	retlw 80h + 0Ch		; blank + chip
	retlw 57h			; bootloader
	retlw 0Dh			; program mode
;
; ------------------------
; LCD INITIALIZATION CODES
; ------------------------
;
_lcd	clrf PCLATH
	addwf PCL
	retlw 30h           	; (128) display initialisation
          retlw 30h			; initialize page 45 of the data sheet
          retlw 30h           	; initialize
	retlw 20h			; 4 bit initialise

	retlw 28h			; 4 bit display two line font 0
	retlw 08h			; display off
          retlw 01h           	; clear display
          retlw 06h           	; increment display
          retlw 0Ch           	; display = on, cursor = off
;
; ---------------------------
; MANUAL EEPROM LOAD MESSAGES
; ---------------------------
;
eepMessDt	clrf PCLATH
	movf MessPt,W
	addwf PCL
	DT "RUN POCKET.EXE"
	DT "PRESS ANY KEY"
	DT "IMPORTING DATA"
;
; -----------------------------------------
; Convert an 8 bit value to a 2 digit ASCII
; -----------------------------------------
;
HexASCII	movwf Temp3
	swapf Temp3,W
	call ToASCII
	movwf INDF
	incf FSR
	movf Temp3,W
	call ToASCII
	movwf INDF
	incf FSR
	return
;
; CODE START
;	
Start	movlw High(_Init)
	movwf PCLATH
	call _Init
	clrf PCLATH
;
; TEST FOR TEXT & CALIBRATION
;
CalTest	movlw 2h
	movwf LoopDelay
	movlw EEvalid
	call IEread
	xorlw 0xAA
	btfss STATUS,Z
	goto NoEEPdat		; no text file loaded - load it

	movlw CalAddr
	call IEread
	xorlw 0xAA
	btfss STATUS,Z
	goto Calibrate		; not calibrated - calibrate it

	clrf Flag1
	clrf Flag2
	clrf Flag3
	ThisPage
	call KeyPress
	addwf PCL
	goto GotEEPdat		; none pressed
	goto Pockpro		; PocketPro Mode
	goto Calibrate		; Calibrate VPP
	goto ClearAll		; Clear all EEPROM data
	goto NoEEPdat		; Get Text file
;
; EXECUTE POCKETPRO CODE
;
Pockpro	movlw High(LWaitCom)
	movwf PCLATH
	goto LWaitCom

GotEEPdat	clrf Flag1
	clrf Flag2
	clrf Flag3
	clrf Flag4

	clrw
	call MessProc1
	movlw 1h
	call MessProc2

	movlw d'20'
	movwf Temp1

DispShow	btfss INTCON,T0IF
	goto DispShow
	bcf INTCON,T0IF
	decfsz Temp1
	goto DispShow
	
	clrf KeyValue

	movlw EEChipAdd
	call IEread
	movwf SelChip
	movwf TSelChip

	movlw CurFile
	call IEread
	movwf FNindex
	clrf MenuItem	

	call ChipData		; initialise chip data

TopMenu	call MenuDisp

MnLoop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto MnLoop
	goto Key1
	goto Key2
	goto Key3
	goto Key4
;
; Key #1
;
Key1	incf MenuItem		; shift menu items
	movlw 0Ah
	xorwf MenuItem,W
	btfsc STATUS,Z
	clrf MenuItem

MenuOK	call MenuDisp
	goto MnLoop

Key2	nop			; used for code testing purposes
	nop			; if needed
	goto MnLoop
;
; Key #3
;
Key3	call KeyReles
	movf MenuItem,W		; select function
	addwf PCL
tt	goto _FILEMAN		; file manager
	goto _CHIP		; chip
	goto _Dsemble		; dissassemble
	goto _FUSE		; examine fuse data
	goto _Program		; program
	goto _Read		; read
	goto _Verf		; verify
	goto _Blank		; blank
	goto _Boot		; boot loader
	movlw High(ICSPMode)
	movwf PCLATH
	goto ICSPMode		; set program mode
;
; Key #4
;
Key4	decf MenuItem		; shift menu items
	btfss MenuItem,7
	goto MenuOK

	movlw 09h
	movwf MenuItem
	goto MenuOK
;
; ---------------------
; DISSASSEMBLE THE CODE
; ---------------------
;
_Dsemble	call AreFiles		; any files available ?
	btfss Flag2,OK
	goto TopMenu		; no files

	movlw High(Dissassem)
	movwf PCLATH
	goto Dissassem
;
; ---------
; FUSE DATA
; ---------
;
_FUSE	call AreFiles		; any files available ?
	btfss Flag2,OK
	goto TopMenu		; no files

	movlw High(FuseMode)
	movwf PCLATH
	goto FuseMode
;
; --------------
; PROGRAM A CHIP
; --------------
;
_Program	call AreFiles		; any files available ?
	btfss Flag2,OK
	goto TopMenu		; no files

	movlw High(ProgMode)
	movwf PCLATH
	goto ProgMode
;
; ----------------
; READ FROM A CHIP
; ----------------
;
_Read	movlw High(ReadMode)
	movwf PCLATH
	goto ReadMode
;
; ------------------
; VERIFY FROM A CHIP
; ------------------
;
_Verf	call AreFiles		; any files available ? OK = 1 = Yes
	btfss Flag2,OK
	goto TopMenu		; no files

	movlw High(VerfMode)
	movwf PCLATH
	goto VerfMode
;
; -----------------
; BLANK TEST A CHIP
; -----------------
;
_Blank	movlw High(BlankMode)
	movwf PCLATH
	goto BlankMode
;
; -----------
; BOOT LOADER
; -----------
;
_Boot	btfss Flag2,BootYN
	goto DFNA			; boot not allowed

	movlw High(BootLoad)
	movwf PCLATH
	goto BootLoad
;
; -----------------------------
; WAIT FOR KEYPRESS WITH REPEAT
; -----------------------------
;
KeyRepeat	btfss INTCON,T0IF		; about 200mS delay
	goto KeyRepeat

	bcf INTCON,T0IF
	decfsz LoopDelay
	goto KeyRepeat

	movlw 2h
	movwf LoopDelay

	call KeyPress
	movwf KeyTemp

	xorwf KeyValue,W
	btfss STATUS,Z
	goto ExRepeat		; key value changed - process keypress/release
;
; KEY REPEATS
;
	movf KeyTemp,W
	btfsc STATUS,Z
	goto KeyRepeat		; no key pressed = no repeats

	decfsz Repeat
	goto KeyRepeat		; wait until repeat delay is over

	movlw d'2'		; re-repeat delay
	goto Frepeat

ExRepeat	movlw 5h			; initial repeat delay
Frepeat	movwf Repeat
	movf KeyTemp,W
	movwf KeyValue
	return
;
; ----------------
; KEYPRESS ROUTINE
; ----------------
; NONE  = 2.5v   = 0
; KEY 1 =	3.75v  = 1
; KEY 2 = 1.20v  = 2
; KEY 3 = 4.90v  = 3
; KEY 4 = 0.10v  = 4
;
KeyPress	bcf ADCON0,CHS0     	; (3) read channel 0
	call Delay6ms
	bsf ADCON0,GO_DONE   	; (2) start conversion
WaitA2D   nop
          btfsc ADCON0,GO_DONE 	; (2)
          goto WaitA2D

	movlw 0x0F
	subwf ADRESH,W
	btfss STATUS,C
	retlw 4h			; key 4

	movlw 0x47
	subwf ADRESH,W
	btfss STATUS,C
	retlw 3h			; key 3

	movlw 0x8C
	subwf ADRESH,W
	btfss STATUS,C
	retlw 0h			; none

	movlw 0xCA
	subwf ADRESH,W
	btfss STATUS,C
	retlw 1h			; key 1
	retlw 2h			; key 2
;
; --------------------
; WAIT FOR KEY RELEASE
; --------------------
;
KeyReles	call Delay6ms
	call KeyPress
	xorlw 0h
	btfss STATUS,Z
	goto KeyReles
	call Delay6ms
	return
;
; ----------------------
; WAIT FOR ANY KEY PRESS
; ----------------------
;
AnyKey	call KeyReles
InAnyKey	call Delay6ms
	call KeyPress
	movwf KeyTemp
	xorlw 0h
	btfsc STATUS,Z
	goto InAnyKey

	call KeyReles
	bcf Flag2,OK
	movf KeyTemp,W
	xorlw 1h
	btfsc STATUS,Z
	bsf Flag2,OK		; set = 1 is anykey result = key 1
	movf KeyTemp,W	
	return
;
; ----------------
; 6mS DELAY @ 4MHz
; ----------------
;
Delay6ms	clrf DelayL
	movlw 10h			; about 12mS delay @ 4MHz
	movwf DelayH
ctlp3     decfsz DelayL
          goto ctlp3
	decfsz DelayH
	goto ctlp3
	return
;
; --------------------
; INTERNAL EEPROM READ
; --------------------
;
IEread	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bsf STATUS,RP0		; RAM Page 3
	bcf EECON1,EEPGD		; internal reads
	bsf EECON1,RD
	bcf STATUS,RP0		; RAM Page 2
	movf EEDATA,W
	bcf STATUS,RP1		; RAM page 0
	return
;
; ---------------------
; INTERNAL EEPROM WRITE
; ---------------------
;
IEwrite	bsf STATUS,RP1		; RAM Page 2
	movwf EEDATA

	bsf STATUS,RP0		; RAM Page 3
	bcf EECON1,EEPGD		; internal writes
	bsf EECON1,WREN
	movlw 55h
	movwf EECON2
	movlw 0xAA
	movwf EECON2
	bsf EECON1,WR

WtEep	btfsc EECON1,WR
	goto WtEep

	bcf EECON1,WREN
	bcf STATUS,RP0		; RAM Page 2
	incf EEADR
	bcf STATUS,RP1		; RAM page 0
	return
;
; ------------------
; DISPLAY MENU ITEMS
; ------------------
;
MenuDisp	movlw 2h			; function:
          call MessProc1

	call GetDvalue		; get display message index
	movwf Temp1
	andlw b'10000000'		; if bit 7 = 1, then display CHIP name
	btfss STATUS,Z
	goto ChipNM

	movf Temp1,W
	call MessProc2
	return

ChipNM	movf Temp1,W
	andlw b'01111111'
	call MessProc2

	movlw 0xC8
ChipName	call LCDins
	movlw ChipBuff
	movwf FSR
	
ChipNam	movf INDF,W
	movwf Temp4		; chip name string length
	incf FSR

CNloop	movf INDF,W
	call LCDout
	incf FSR
	decfsz Temp4
	goto CNloop
	return
;
; -----------------
; CLEAR THE DISPLAY
; -----------------
;
ClearDisp	movlw 1h            	; clear display
          call LCDins		; send the instruction
	return
;
; -----------------------------
; CLOCKING DELAY - 200uS @ 4MHz
; -----------------------------
;
Clock	movlw 40h
	movwf DelayL
kdloop    decfsz DelayL
          goto kdloop
          return
;
; -----------------
; MESSAGE PROCESSOR
; -----------------
; >00,PICPOCKET   by^
;
MessProc1	bcf Flag1,line		; Line # 1
	goto InProc
MessProc3	bsf Flag1,Mnem		; just get message data
	bsf Flag1,line
	goto InProc2

MessProc2	bsf Flag1,line		; Line # 2
InProc	bcf Flag1,Mnem		; get and display message data
InProc2	movwf Temp1		; message number
	call EERdStA0		; read starting from address 0
	call EEread_A		; EEPROM read with ACK
	movwf EEaddH		; address pointer to message data address list H
	call EEread_N		; EEPROM read with ACK
	movwf EEaddL		; address pointer to message data address list L

	clrf Temp2
	bcf STATUS,C
	rlf Temp1
	rlf Temp2			; message number X 2 = 2 chars per address	
	movf Temp1,W
	addwf EEaddL
	btfsc STATUS,C
	incf EEaddH
	movf Temp2,W
	addwf EEaddH		; add in message data start address
	call EEreadStA		; start reading eeprom A to get message address

	call EEread_A		; EEPROM read with ACK
	movwf EEaddH		; pointer H
	call EEread_N		; EEPROM read with ACK
	movwf EEaddL		; pointer L

	call EEreadStA		; start reading eeprom A at message start address
;
; GET TEXT DATA INTO BUFFER UPTO '^'
;
	movlw Low(EepBuff)
	movwf FSR

GtMessEE	call EEread_A		; EEPROM read with ACK
	bsf STATUS,IRP
	movwf INDF
	bcf STATUS,IRP
	xorlw '^'
	btfsc STATUS,Z
	goto GotMat

	incf FSR
	movlw Low(EepBuff) + 40h	
	xorwf FSR,W
	btfsc STATUS,Z
	goto MSerror 
	goto GtMessEE

GotMat	call EEread_N		; EEPROM read & stop without ACK
	btfsc Flag1,Mnem
	goto clrfg		; just get data
;
; PUT TEXT INTO DISPLAY
;
	movlw Low(EepBuff)
	movwf FSR
	btfss Flag1,line
	goto MenText1

MenText2	movlw 0xC0		; message to start of line 2
	btfsc Flag1,Ms2Ps
	movlw 0xCB		; message to start in line 2	
	goto InMtext

MenText1	call ClearDisp
	movlw 80h           	; message to start of line 1
InMtext	call LCDins
	bcf Flag1,Ms2Ps

MenLp	bsf STATUS,IRP
	movf INDF,W
	bcf STATUS,IRP
	xorlw '^'
	btfsc STATUS,Z
	goto clrfg		; message finished

	xorlw '^'
          call LCDout         	; output to display
	incf FSR
          goto MenLp

clrfg	bcf Flag1,Mnem
	return
;
; -----------------------------------
; SET CODEADDH FOR CODE START ADDRESS
; -----------------------------------
;
SetCdAddH	movwf CodeAddL
	movf FNindex,W
	addlw StartAdd
	call IEread
	movwf CodeAddH
	return
;
; ----------------------------
; CALIBRATE THE VOLTAGE VALUES
; ----------------------------
; 2V - 6V in 0.25V steps = 17
; DATA STORED IN INTERNAL EEPROM
; ADDRESS d0 = 00 = NO CALIBRATE / AA = CALIBRATED
; ADDRESSES d1 - d34 = calibrate duty cycle data
; Dx = DutyH, Dx + 1 = DutyL
; ADDRESS d35 = VERIFY VOLTS L
; ADDRESS d36 = VERIFY VOLTS H
; ADDRESS d37 = VERIFY MODE on/off, 0 = off
;
Calibrate	call ClearCal		; clear cal eeprom regs
	movlw 39h			; calibrate vccp
	call MessProc1
	movlw 12h			; press any key
	call MessProc2

	call AnyKey		; OK flag = 1 if Key 1 pressed

	clrf ACount
	bsf STATUS,RP1		; RAM Page 2
	movlw 1h
	movwf EEADR		; 1st cal data
	bcf STATUS,RP1		; RAM page 0

	clrf DutyH
	movlw 40h
	movwf DutyL

	bsf PORTB,ActLed
	bsf PORTC,VccOn
CalChg	call SetDuty
	bsf T2CON,TMR2ON		; TMR2 = on

CalVLP	movlw 3Ah			; Cal 1U 2X 3A 4D
	call MessProc1
	movf ACount,W
	addlw 66h
	call MessProc2

CalLoop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto CalLoop
	goto CLKey1
	goto CalError
	goto GotCal
	goto CLKey4

CLKey1	btfsc DutyH,1
	goto CalLoop

	incf DutyL
	btfsc STATUS,Z
	incf DutyH
	goto CalChg

CLKey4	btfsc DutyH,7
	goto CalLoop

	decf DutyL
	movlw 0xFF
	xorwf DutyL,W
	btfsc STATUS,Z
	decf DutyH
	goto CalChg
;
; SAVE CALIBRATION DATA
;
GotCal	movf DutyH,W
	call IEwrite
	movf DutyL,W
	call IEwrite
	incf ACount
	movlw d'17'
	xorwf ACount,W
	btfss STATUS,Z
	goto CalVLP
;
; CALIBRATION FINISHED
;	
	bsf STATUS,RP1		; RAM Page 2
	clrf EEADR		; 1st cal data
	movlw 0xAA		; cal data IS valid
	call IEwrite
	
	movlw 3Bh			; calibrated OK
	movwf Temp1
	goto DunCal
;
; CALIBRATION ERROR
;
CalError	call ClearCal		; clear cal eeprom regs
	movlw 3Ch			; calibrate fail
	movwf Temp1

DunCal	movlw High(VccPoff)
	movwf PCLATH
	call VccPoff
	clrf PCLATH
	bcf PORTB,ActLed	
	movf Temp1,W
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto CalTest		; start from scratch
;
; --------------
; SET DUTY CYCLE
; --------------
;
SetDuty	movlw b'00001100'		; enable PWM mode
	movwf Temp1
	btfsc DutyL,0		; prepare CCP1CON <5:4>
	bsf Temp1,4
	btfsc DutyL,1
	bsf Temp1,5
	movf Temp1,W
	movwf CCP1CON
	movf DutyL,W
	movwf Data2L
	movf DutyH,W
	movwf Data2H
	bcf STATUS,C
	rrf Data2H			; prepare CCPR1L data
	rrf Data2L
	bcf STATUS,C
	rrf Data2H
	rrf Data2L
	movf Data2L,W
	movwf CCPR1L
	return
;
; -----------------------------
; CLEAR ALL DATA IN ALL EEPROMS
; -----------------------------
;
ClearAll	movlw 38h			; clear all data
	call MessProc1
	movlw 4Bh			; sure? k1 = yes
	call MessProc2

	call AnyKey		; OK flag = 1 if Key 1 pressed
	btfss Flag2,OK
	goto ExitClr

	movlw 37h			; erasing...
	call MessProc1
	clrw
	call ClrFileA

ExitClr	call KeyReles
	goto CalTest		; restart
;
; -------------------------------
; CLEAR ALL FILE DATA FROM EEPROM
; -------------------------------
;
ClearFile	movlw CurFile
ClrFileA	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
DelALoop	movlw 0xFF
	call IEwrite		; save it

	bsf STATUS,RP1		; RAM Page 2
	movf EEADR,W	
	btfss STATUS,Z
	goto DelALoop

	bcf STATUS,RP1		; RAM Page 0	
	movlw 0xFF
	movwf FNindex		; no files available
	return
;
; -----------------------------------------
; OUTPUT 1 INSTRUCTION BYTE IN W TO DISPLAY
; -----------------------------------------
;
LCDins    call SwapNibs		; -> W
	movwf NibA
	movf PORTB,W
	andlw 0xF0
	movwf NibB
	swapf NibA,W
	andlw 0x0F
	iorwf NibB,W
	movwf PORTB
	bcf PORTA,lcdRS		; (2)
          call Clock
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)
          call Clock

	btfsc Flag1,LCDmd
	goto bits8

	movf NibA,W
	andlw b'00001111'
	iorwf NibB,W
	movwf PORTB
          call Clock
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)

bits8	call Delay6ms
          return
;
; ----------------------------------
; OUTPUT 1 DATA BYTE IN W TO DISPLAY
; ----------------------------------
;
LCDout    call SwapNibs		; -> W
	movwf NibA
	movf PORTB,W
	andlw B'11110000'
	movwf NibB
	swapf NibA,W
	andlw b'00001111'
	iorwf NibB,W
	movwf PORTB
          bsf PORTA,lcdRS     	; (2) Write data to display
          call Clock
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)
          call Clock

	movf NibA,W
	andlw b'00001111'
	iorwf NibB,W
	movwf PORTB
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)
          call Clock
          return
;
; --------------------------------
; LCD data exchange to match PORTB
; --------------------------------
; swap data bits 7 = 4, 6 = 5, 5 = 6, 4 = 7
; swap data bits 3 = 0, 2 = 1, 1 = 2, 0 = 3
;
SwapNibs	movwf NibA
	movlw 8h
	movwf NibB
SwapLoop	rrf NibA
	rlf Temp1
	decfsz NibB
	goto SwapLoop

	swapf Temp1,W
	return
;
; ---------------------
; 12mS Delay and Longer
; ---------------------
;
Del12mSL	movlw 0xA0
	goto InDel
Del12mS   movlw 11h
InDel	movwf DelayH
	clrf DelayL
Del1a     decfsz DelayL
          goto Del1a
          decfsz DelayH
          goto Del1a
          return
;
; -------------------------
; SETUP FOR EEPROM (A) READ
; -------------------------
;
EERdStA0	clrf EEaddH		; set up eeprom A for reading at 0h
	clrf EEaddL
EEreadStA	call EEstart		; start condition

	movlw Awrite		; control byte 'write' EEPROM (A)
	call EEwrite

	movf EEaddH,W
	call EEwrite		; message pointer/address Hi

	movf EEaddL,W
ExRead0	call EEwrite		; message pointer/address Lo	

	call EEstart		; do another start condition

	movlw Aread		; control byte 'read' EEPROM (A)
	call EEwrite
	return
;
; ------------
; EEPROM START
; ------------
; SCL = ? SDA = ?
;
EEstart	call EEclock
	SCL_Lo			; make sure SCL = Lo
	call EEclock
	SDA_Hi			; make sure SDA = hi while SCL = Lo
	call EEclock2
	SCL_Hi			; SCL = Hi
	call EEclock2
	SDA_Lo			; SDA = Lo = start condition
	call EEclock2
	SCL_Lo			; SCL = Lo for first clock pulse
	return
;
; -------------------
; EEPROM BYTE - WRITE
; -------------------
;
EEwrite	movwf EEdata
	movlw 8h
	movwf BCount

EEsenLP	call EEclock
	rlf EEdata
	btfsc STATUS,C
	goto senHI

	SDA_Lo		; Lo bit
	goto senTM

senHI	SDA_Hi		; Hi bit

senTM	call EEclock

	SCL_Hi		; clock = Hi
	call EEclock2
	SCL_Lo		; clock = Lo
	decfsz BCount
	goto EEsenLP
;
; GET ACK FROM SLAVE
; SCL = Lo SDA = ?
;
	SDA_In		; Data pin = input
	call EEclock2	; low clock time

	SCL_Hi		; clock = Hi
	call EEclock

	btfsc PORTA,SDA	; 1 = no ack, 0 = ack
	goto MSerror

	call EEclock
	SCL_Lo		; clock = Lo
	return
;
; ----------------
; EEPROM READ BYTE
; ----------------
; SCL = Lo SDA = ?
; _N = no ACK after read - finished
; _A = do ACK after read - continue
;
EEread_N	bcf Flag1,n_ack
	goto inRead
EEread_A	bsf Flag1,n_ack
inRead	SDA_In		; SDA = input

	movlw 8h
	movwf BCount

EEredLP	call EEclock2	; low clock count

	SCL_Hi		; clock = Hi
	call EEclock

	bcf STATUS,C
	btfsc PORTA,SDA	; test SDA
	bsf STATUS,C
	rlf EEdata
	call EEclock

	SCL_Lo		; clock = Lo

	decfsz BCount
	goto EEredLP	; get 8 bits
;
; READ ACK
;
	btfss Flag1,n_ack
	goto NoRDack

	SDA_Out		; SDA = output (LO)

NoRDack	call EEclock2	; low clock count
	SCL_Hi		; clock = Hi
	call EEclock2
	SCL_Lo		; clock = Lo

	SDA_In		; make sure SDA = In

	btfss Flag1,n_ack
	call EEstop	; finish eeprom access

	movf EEdata,W
	return
;
; -----------
; EEPROM STOP
; -----------
; SCL = Lo SDA = ?
;
EEstop	call EEclock
	SCL_Lo		; make sure SCL = Lo
	call EEclock
	SDA_Lo		; make sure SDA Lo while SCL = Lo
	call EEclock2
	SCL_Hi		; SCL = Hi
	call EEclock2
	SDA_Hi		; SDA Hi = stop condition
	call Delay6ms
	return
;
; --------------------------
; SERIAL EEPROM CLOCK DELAYS
; --------------------------
; 20uS and 10uS & 4MHz
;
EEclock2	goto $ + 1
	goto $ + 1
	goto $ + 1
EEclock	goto $ + 1
	goto $ + 1
	goto $ + 1
	return
;
; ----------------------
; CLEAR CALIBRATION DATA
; ----------------------
; ADDRESS d0 = 00 = NO CALIBRATE / AA = CALIBRATED
; ADDRESS d35 = VERIFY VOLTS H, 0 = none
; ADDRESS d36 = VERIFY VOLTS L, 0 = none
; ADDRESS d37 = VERIFY MODE on/off, 0 = off
;
ClearCal	bsf STATUS,RP1		; RAM Page 2
	clrf EEADR		; 1st cal data
	movlw CalAddr
	call IEwrite		; flag data NOT valid
	bsf STATUS,RP1		; RAM Page 2
	movlw VHAddress
	movwf EEADR		; 1st cal data
	clrw
	call IEwrite		; no verify high data
	clrw
	call IEwrite		; no verify low data
	clrw
	call IEwrite		; multy verify = off
	return
;
; MESSAGE RETRIEVE ERROR
;
MSerror	call EEstop
	call ClearDisp
	movlw High(VoltsOFF)
	movwf PCLATH
	call VoltsOFF
	clrf PCLATH

TestMess	clrf MessPt
MerrLP	call errMessDt

	call LCDout
	incf MessPt
	movlw d'12'
	xorwf MessPt,W
	btfss STATUS,Z
	goto MerrLP

	movlw 0ch			; cursor = off
	call LCDins

	clrf MenuItem

	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto CalTest
;
; ------------------
; MANUAL EEPROM DATA
; ------------------
;
NoEEPdat	call ClearDisp
	clrf MessPt
	movlw d'14'
	call ManEDat		; PICPOC MESSAGE

	movlw 0xC0
	call LCDins

	movlw d'27'		; PRESS ANY KEY MESSAGE
	call ManEDat

	call AnyKey		; OK flag = 1 if Key 1 pressed

	movlw 'T'			; ask for text data
	movwf TXREG
	movwf TXREG

	call Receive		; wait 1 sec

	call ClearDisp
	movlw d'27'
	movwf MessPt
	bsf Flag1,TxtFile		; clears EEPROM if timeout error

	movlw d'41'		; IMPORTING TEXT MESSAGE
	call ManEDat

	bsf STATUS,RP1		; RAM Page 2
	movlw EEChipAdd
	movwf EEADR
	clrw			; reset current selected chip = 0
	call IEwrite

	bsf STATUS,RP1		; RAM Page 2
	movlw EEvalid
	movwf EEADR
	clrw			; reset eeprom text valid
	call IEwrite

	clrf EEaddH
	clrf EEaddL
;
; GET 16 BYTES OF DATA
;
ExpMore	movlw 'R'			; send request to save ROM to PC
	movwf TXREG

	call Receive		; wait 1 second for response - PC sends 'Y'
	
	movf RxHold,W
	xorlw 'Y'
	btfss STATUS,Z
	goto FinEEPA
;
; RECEIVE 16 BYTES FROM PC
;
	movlw d'16'
	movwf BCount

	movlw Low(EepBuff)
	movwf FSR
	bsf STATUS,IRP

Gtfrmad	call Receive		; get data into buffer
	movwf INDF
	incf FSR

	decfsz BCount
	goto Gtfrmad
;
; NOW WRITE THE DATA TO EEPROM
;
	movlw Low(EepBuff)		; send data to EEPROM
	movwf FSR

	movlw d'16'
	movwf CCount

	call EEstart		; start condition

	movlw Awrite		; control byte 'write' EEPROM (A)
	call EEwrite

	movf EEaddH,W
	call EEwrite		; address Hi

	movf EEaddL,W
	call EEwrite		; address Lo	

DoDat	movf INDF,W		; send data to EEPROM
	call EEwrite

	incf EEaddL		; current EEPROM address
	btfsc STATUS,Z
	incf EEaddH

	incf FSR
	decfsz CCount
	goto DoDat

	call EEstop		; writes data to eeprom
	bcf STATUS,IRP
	goto ExpMore
;
; SET EEPROM TEXT DATA VALID
;
FinEEPA	bsf STATUS,RP1		; RAM Page 2
	movlw EEvalid
	movwf EEADR
	movlw 0xAA		; set eeprom text valid
	call IEwrite
	bcf Flag1,TxtFile

	movlw 14h			; import complete
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto CalTest		; initialise again
;
; ----------------------------------------
; RECEIVE FROM SERIAL PORT - WAIT 1 SECOND
; ----------------------------------------
;
Receive	clrf TMR0
	bcf INTCON,T0IF
	movlw d'20'
	movwf Temp1

RecA	btfsc PIR1,RCIF		; (5) check for received data
	goto GotRec

	btfss INTCON,T0IF
	goto RecA

	bcf INTCON,T0IF
	decfsz Temp1
	goto RecA
;
; PC TIMEOUT ERROR
;
	call EEread_N		; EEPROM read & stop without ACK - ignore data

	btfsc Flag1,TxtFile		; only delete data if receiving 'text' file
	call ClearFile
	bcf Flag1,TxtFile
	bcf STATUS,IRP

	movlw 17h			; error: timeout
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto CalTest		; initialise again

GotRec	movf RCREG,W
	movwf RxHold
	return
;
; ----------------------------
; OUTPUT MANUAL MESSAGE TO LCD
; ----------------------------
;
ManEDat	movwf CCount
datEepLP	call eepMessDt
	call LCDout
	incf MessPt
	movf CCount,W
	xorwf MessPt,W
	btfss STATUS,Z
	goto datEepLP
	return
;
; -----------------------------
; GET THE SELECTED CHIP DETAILS
; -----------------------------
; NAME - ROM SIZE - EEPROM SIZE - ETC
;
ChipData	clrf MessPt
	movlw ChipBuff
	movwf FSR
	clrf INDF			; no string

	movlw 6h
	movwf EEaddL
	clrf EEaddH
	call EEreadStA		; chip names start address

ChdatLp	call EEread_A		; EEPROM read with ACK
	xorlw '['
	btfss STATUS,Z
	goto ChdatLp		; chip name starts with '['

	movf MessPt,W
	xorwf TSelChip,W
	btfsc STATUS,Z
	goto ChnamLp

	incf MessPt
	goto ChdatLp		; no

ChnamLp	call EEread_A		; EEPROM read with ACK
	movwf INDF
	incf FSR

	xorlw ']'
	btfss STATUS,Z
	goto ChnamLp		; chip name ends with ']'
;
; DISPLAY CHIP NAME ONLY, IF USER IS SELECTING CHIP
;
	btfss Flag1,C_Name
	goto NoCname

	call EEread_N		; finished reading
	movlw 0xC0
	call ChipName
	bcf Flag1,C_Name		; reset the flag
	return
;
; GET I2C EEPROM ADDRESS OF CHIP DATA - 2 HEX DIGITS
;	
NoCname	call EEread_A		; EEPROM read with ACK
	movwf ChipAddH		; save address H
	call EEread_N		; EEPROM read with No ACK
	movwf ChipAddL		; save address L
	call JumpChip		; jump to chip data address on EEPROM
;
; GET TOTAL EEPROM BLOCK SIZE FOR CHIP
;
	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_A		; EEPROM read with ACK
	movwf Data2L
	call HEX_dec		; ASCII Data2H/L = decimal
	movwf BlockCnt
;
; GET ROM SIZE
;
	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_A		; EEPROM read with ACK
	movwf Data2L
	call HEX_dec		; ASCII Data2H/L = decimal
	movwf HiROMAdd
;
; GET EEPROM SIZE
;
	bcf Flag3,Etype		; preset not eeprom type chip
	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_A		; EEPROM read with ACK
	movwf Data2L
	call HEX_dec		; ASCII Data2H/L = decimal
	movwf EEsizeH
	xorlw 0h
	btfss STATUS,Z
	bsf Flag3,Etype		; is eeprom type chip
	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_A		; EEPROM read with ACK
	movwf Data2L
	call HEX_dec		; ASCII Data2H/L = decimal
	movwf EEsizeL
	xorlw 0h
	btfss STATUS,Z
	bsf Flag3,Etype		; is eeprom type chip
;
; GET RAM PAGES
;
	call EEread_A		; EEPROM read with ACK
	movwf RAMpageMax

	movlw d'48'
	subwf RAMpageMax		; convert ASCII bit value to decimal
;
; GET VPP
; 1 or 2
	call EEread_A		; EEPROM read with ACK
	movwf VPPtype
;
; GET EEPROM PIC PROGRAMMING DELAY
; L = 20mS S = 5mS
;
	bcf Flag2,TimeLS		; short programming time
	call EEread_A		; EEPROM read with ACK
	xorlw 'S'
	btfss STATUS,Z
	bsf Flag2,TimeLS		; long programming time
;
; GET PIC PINS
; 0 = 8 1 = 18 2 = 28 3 = 40
;
	call EEread_A		; EEPROM read with ACK
	movwf PICpins
;
; GET CODE PROTECT WARNING FLAG
; N or Y
;
	bcf Flag2,FuseYN
	call EEread_A		; EEPROM read with ACK
	xorlw 'N'
	btfss STATUS,Z
	bsf Flag2,FuseYN
;
; GET CHIP AND FILE TYPE
;
	bcf Flag2,f8M32		; INHX8M - 16Cxxx series
	call EEread_A		; EEPROM read with ACK
	xorlw 'M'			; 'M' or '2'
	btfss STATUS,Z
	bsf Flag2,f8M32		; INHX32 - 18Cxxx series
;
; GET BOOT ALLOW STATUS
;
	bcf Flag2,BootYN
	call EEread_A		; EEPROM read with ACK
	xorlw 'Y'
	btfsc STATUS,Z
	bsf Flag2,BootYN		; boot programmer allowed
;
; GET ID WORD COUNT
; 1 or 2
;
	bcf Flag4,IdC		; 1 ID loc
	call EEread_A		; EEPROM read with ACK
	xorlw '1'
	btfss STATUS,Z
	bsf Flag4,IdC		; 2 ID locs
;
; GET FUSE WORD COUNT
; 1 or 4
;
	bcf Flag4,FzC		; 1 Fuse loc
	call EEread_A		; EEPROM read with ACK
	xorlw '1'
	btfss STATUS,Z
	bsf Flag4,FzC		; 4 Fuse locs
;
; GET FUSE 'AND' and 'OR' VALUES
;
	movlw d'16'		; get 16 fuse bytes in 2 char ASCII format
	movwf Temp2
	movlw Low(Fuse1ANDH)
	movwf FSR
	bsf STATUS,IRP		; FSR accesses RAM pages 2 and 3

GetAOlp	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_A		; EEPROM read with ACK
	movwf Data2L
	call HEX_dec		; ASCII Data2H/L = decimal
	movwf INDF
	incf FSR
	decfsz Temp2
	goto GetAOlp

	bcf STATUS,IRP		; FSR accesses RAM pages 0 and 1
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	clrf CurFuse		; view fuse #1
	return
;
; -----------------------------
; MOVE TO CHIP DATA ON EEPROM A
; -----------------------------
;
JumpChip	call EEstart		; start condition
	movlw Awrite		; control byte 'write' EEPROM (A)
	call EEwrite

	movf ChipAddH,W
	movwf EEaddH
	call EEwrite		; address Hi

	movf ChipAddL,W
	movwf EEaddL
	call EEwrite		; address Lo	

	call EEstart		; do another start condition
	movlw Aread		; control byte 'read' EEPROM (A)
	call EEwrite
	return
;
; ------------------------------------
; CONVERT ASCII VAL 00 - FF TO DECIMAL
; ------------------------------------
;
HEX_dec	movlw d'65'
	subwf Data2H,W
	btfss STATUS,C
	addlw d'7'
	addlw d'10'
	movwf Temp1
	swapf Temp1

	movlw d'65'
	subwf Data2L,W
	btfss STATUS,C
	addlw d'7'
	addlw d'10'
	addwf Temp1,W
	return
;
; --------------
; CHIP SELECTION
; --------------
;
_CHIP	movf SelChip,W
	movwf TSelChip		; save original chip

	movlw 1Ah			; selecting chip
	call MessProc1
;
; FIND OUT MAX CHIPS
;
	clrf EEaddH
	movlw 4h
	movwf EEaddL
	call EEreadStA		; chip count data address
	call EEread_A		; EEPROM read with ACK
	movwf Data2H
	call EEread_N		; EEPROM read & stop without ACK
	movwf Data2L

	call HEX_dec		; ASCII Data2H/L = decimal
	movwf Temp3

	bsf Flag1,C_Name
	call ChipData		; display current chip name

ChipLoop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto ChipLoop
	goto CKey1		; selection up
	goto CKey2		; exit - no change
	goto CKey3		; select chip
	goto CKey4		; selection down

CKey1	incf TSelChip
	movf Temp3,W
	xorwf TSelChip,W
	btfsc STATUS,Z
	clrf TSelChip
	goto ChipSet

CKey2	goto TopMenu

CKey3	call ChipData		; get new chip name and data
	bsf STATUS,RP1		; RAM Page 2
	movlw EEChipAdd
	movwf EEADR		; eeprom address for upper or lower
	bcf STATUS,RP1		; RAM Page 0
	movf TSelChip,W
	movwf SelChip
	call IEwrite		; save selected chip into EEPROM
	goto TopMenu

CKey4	decf TSelChip
	incfsz TSelChip,W
	goto ChipSet

	movlw 1h
	subwf Temp3,W
	movwf TSelChip
ChipSet	movlw 1Ah			; selecting chip
	call MessProc1
	bsf Flag1,C_Name		; display new chip name
	call ChipData
	goto ChipLoop
;
; ---------------------
; FILE MANAGER ROUTINES
; ---------------------
;
_FILEMAN	movlw 54h			; file action
	call MessProc1
	movlw 55h			; information
	call MessProc2

	call HighLiteA		; put '<' on screen

OIloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto OIloop
	goto OIKey1
	goto OIKey2
	goto OIKey3
	goto OIKey2
;
; OP IN KEY 1
;
OIKey1	call HighLight
	goto OIloop
;
; OP IN KEY 2
;
OIKey2	goto TopMenu
;
; OP IN KEY 3
;
OIKey3	btfss Flag2,FLayer
	goto ChgDel
;
; ------------------------
; DISPLAY FILE INFORMATION
; ------------------------
;
FileInfo	movlw 64h			; file info
	call MessProc1
	movlw 65h			; usage
	call MessProc2

	call HighLiteA		; put '<' on screen

FUloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FUloop
	goto FUKey1
	goto _FILEMAN
	goto FUKey3
	goto TopMenu
;
; FILES USAGE KEY 1
;
FUKey1	call HighLight
	goto FUloop
;
; FILES USAGE KEY 3
;
FUKey3	btfss Flag2,FLayer
	goto DsFiles		; display the files
;
; VIEW EEPROM BLOCK USAGE
;
	call StartPP		; start pocket.exe message

	movlw 'B'			; block usage request
	movwf TXREG
	movwf TXREG
	call Receive		; wait one second
	call ByteSd32		; send the byte data

	movlw 53h			; waiting for PC
	call MessProc1

	call ReceiveP		; wait for PC
	goto FileInfo
;
; display files
;
DsFiles	call AreFiles		; any files available ? OK = 1 = Yes
	btfss Flag2,OK
	goto _FILEMAN		; no files

	movf FNindex,W
	movwf Data1L
	goto FilesInfo

FINloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FINloop
	goto FINKey1
	goto RstrFN
	goto FINloop
	goto TopMenu

RstrFN	movf Data1L,W
	movwf FNindex
	goto _FILEMAN
;
; File Info KEY 1
;
FINKey1	incf FNindex
	movlw FilesMax
	xorwf FNindex,W
	btfsc STATUS,Z
	clrf FNindex

FilesInfo	call ClearDisp
	call FindFile		; setup file start (FNindex used)
	call DispFileA		; display current filename - line1
;
; display file type
;
	movlw 9Ch			; blocks    INHX
	call MessProc2

	movlw 0xC7
	call LCDins

	call BlockCwt		; -> Temp4

	movf Temp4,W
	call Bin2BCD		; Temp3 = tens, Temp4 = units
	movf Temp3,W
	btfss STATUS,Z
	goto ASdig

	movlw ' '
	goto SNdig		; leading 0 = space

ASdig	call ToASCII
SNdig	call LCDout		; tens digit
	movf Temp4,W
	call ToASCII
	call LCDout		; units digit

	movlw 0xCE
	call LCDins

	movlw E_FileType
	call SetCdAddH		; set CodeAddH/L for code start address

	call BCstartR
	call EEread_N		; FileType '8' or '3'
	movwf Temp5
	call LCDout
	movlw '8'
	xorwf Temp5,W
	movlw 'M'
	btfss STATUS,Z
	movlw '2'
	call LCDout
	goto FINloop

FilesAvl	call ListFiles
	btfss Flag2,OK
	goto ChgDel		; aborted

	movlw 4Bh			; sure? k1 = yes
	call MessProc1

	call AnyKey		; OK flag = 1 if Key 1 pressed
	btfsc Flag2,OK
	call DeletFile
	goto DelAfile
;
; -------------------------------
; DELETE FILES - IMPORT OR EXPORT
; -------------------------------
;
ChgDel	movlw 4Dh			; transfer file
	call MessProc1
	movlw 4Eh			; delete file
	call MessProc2

	call HighLiteA		; put '<' on screen

FMloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FMloop
	goto FMKey1
	goto _FILEMAN
	goto FMKey3
	goto OIKey2
;
; FileManager KEY 1
;
FMKey1	call HighLight
	goto FMloop
;
; FileManager KEY 3
;
FMKey3	btfsc Flag2,FLayer
	goto DelFile
;
; IMPORT OR EXPORT
;
ImpExp	movlw 6h			; import
	call MessProc1
	movlw 5h			; export
	call MessProc2

	call HighLiteA		; put '<' on screen

CFloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto CFloop
	goto CFKey1
	goto ChgDel
	goto CFKey3
	goto OIKey2
;
; change file KEY 1
;
CFKey1	call HighLight
	goto CFloop
;
; change file KEY 3
;
CFKey3	call KeyReles		; wait for key release
	btfss Flag2,FLayer
	goto _IMPORT
	goto _EXPORT
;
; DELETE FILE(S)
;
DelFile	movlw 4Fh			; single
	call MessProc1
	movlw 50h			; all
	call MessProc2

	call HighLiteA		; put '<' on screen

SAloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto SAloop
	goto SAKey1
	goto _FILEMAN
	goto SAKey3
	goto OIKey2
;
; Single/All KEY 1
;
SAKey1	call HighLight
	goto SAloop
;
; Single/All KEY 3
;
SAKey3	btfsc Flag2,FLayer
	goto DelALL
;
; DELETE A SINGLE FILE FROM MEMORY
;
DelAfile	call KeyReles
	movf FNindex,W
	xorlw 0xFF
	btfss STATUS,Z
	goto FilesAvl		; files available for deletion
;
; NO FILES AVAILABLE TO DELETE
;
	movlw 52h			; no files
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto ChgDel
;
; ------------------------
; LIST FILENAMES AVAILABLE
; ------------------------
;
ListFiles	bsf Flag2,OK
	movf FNindex,W
	movwf IndexS		; temp save index data
	movlw 51h			; select file
	call MessProc1
	call FindFile		; find filename (FNindex used)
	call DispFile		; display current filename

LFloop	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto LFloop
	goto LFKey1
	goto NoChan
	return			; accept
	goto LFloop

NoChan	movf IndexS,W
	movwf FNindex
	bcf Flag2,OK		; abort
	return
;
; List Files KEY 1
;
LFKey1	incf FNindex
	movlw FilesMax
	xorwf FNindex,W
	btfsc STATUS,Z
	clrf FNindex

	call FindFile		; find filename (FNindex used)
	call DispFile		; display current filename
	goto LFloop	
;
; --------------------------------
; EXPORT A HEX FILE FROM PIC TO PC
; --------------------------------
; data that is sent...
; rom words in 16 byte blocks
; then eeprom words in 16 bytes blocks
; then fuse data in a word
;
; exit if no files to export
;
_EXPORT	call AreFiles		; any files available ? OK = 1 = Yes
	btfss Flag2,OK
	goto ImpExp		; no files

ExpFilAvl	call ListFiles
	btfss Flag2,OK
	goto ImpExp

	call StartPP		; start pocket.exe message

	movlw 11h			; exporting
	call MessProc1

	movlw 'E'			; send export data command to PC
	movwf TXREG
	movwf TXREG

	call Receive		; get 'Y' ack from PC

	call SendSize		; send ROM and EEP size
;
; Set data start address from FNindex, and send all file data
;
	clrw
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
;
; EXPORTING
;
EXPMore	call Receive		; wait for ACK from PC
	xorlw 'M'
	btfss STATUS,Z
	goto NoMoreEX		; no more data requested by PC

	movlw d'16'
	movwf ICount
;
; SEND 16 BYTES TO PC
;
EXloop	call EEreadBC
	movwf TXREG
	call TransWt
	decfsz ICount
	goto EXloop
	goto EXPMore

NoMoreEX	call EEread_N		; stop reading
	movlw 53h			; waiting for PC to save file
	call MessProc1
	movlw 'M'			; ask for new filename
	movwf TXREG
;
; 'N' - DATA ERROR
; 'Y' - RECEIVE NEW FILENAME
;
	call ReceiveP		; wait forever
	xorlw 'Y'
	btfss STATUS,Z
	goto NoNewNM		; PC error saving data

	movlw Low(EepBuff)		; receive PC saved filename if 'Y' send back
	movwf FSR
	bsf STATUS,IRP
	movlw E_NameSize
	movwf Data1L

FileRLP	call Receive
	movwf INDF
	incf FSR
	decfsz Data1L
	goto FileRLP

	movlw StartAdd
	addwf FNindex,W
	call IEread
	movwf CodeAddH
	clrf CodeAddL
	movlw E_NameSize
	movwf Data1L
	movlw Low(EepBuff)		; get PC saved filename
	movwf FSR
	call BCstartW

PCfile	movf INDF,W
	call EEwriteBC
	incf FSR
	decfsz Data1L
	goto PCfile

	call EEstop
	bcf STATUS,IRP

NoNewNM	movlw 13h			; export complete
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto ImpExp
;
; --------------------------------
; IMPORT A HEX FILE FROM PC TO PIC
; --------------------------------
;
_IMPORT	call BlocksOK		; see if enough blocks, OK = 1 = OK, OK = 0 = full
	btfss Flag2,OK
	goto MemFull		; full

	call StartAdr		; program address storage available? OK = 1 = OK
	btfss Flag2,OK
	goto MemFull		; full

	call StartPP		; start pocket.exe message

	movlw 'I'			; send IMPORT data command to PC
	movwf TXREG
	movwf TXREG

	movlw 53h			; waiting for PC
	call MessProc1

	call ReceiveP		; while file is loaded
	xorlw 'Y'
	btfss STATUS,Z
	goto NilTrans		; file load request terminated by PC

	call SendSize		; send ROM and EEP size
	movlw Low(Fuse1ANDH)	; send fuse mask values
	movwf FSR			; PC will modify fuse values before sending
	bsf STATUS,IRP
	movlw 8h			; 8 words to send
	movwf Temp1

SdFzMask	call TransWt
	movf INDF,W
	movwf TXREG
	incf FSR
	movf INDF,W
	movwf TXREG
	incf FSR
	decfsz Temp1
	goto SdFzMask

	bcf STATUS,IRP
	call ReceiveP		; wait for PC ack
	xorlw 'Y'
	btfss STATUS,Z
	goto NilTrans		; terminated by PC - found error

	call FindBlock		; finds next free block and flag it used, sets CodeAddH/L
	movf CodeAddH,W
	movwf _SaveH		; save start address until after all data imported
;
; --------------------
; START IMPORTING DATA
; --------------------
;
	movlw 10h			; importing
	call MessProc1
	movlw 0xC0
	call LCDins

	movlw 'F'			; get file header
	movwf TXREG
;
; GET FILE HEADER DATA
; FileName, ID chars, Fuse data, etc (32 bytes total)
; Then ROM data
;
	movlw E_ROMStart
	movwf ICount
	movlw Low(EepBuff)
	movwf FSR
	bsf STATUS,IRP

GetFhead	call Receive		; receive the file header info
	movwf INDF	

	incf FSR
	decfsz ICount
	goto GetFhead
;
; GOT HEADER INFO, START WRITING FILENAME TO I2C EEPROM AND DISPLAY
;
	call BCstartW		; start writing to EEPROMs B and C

	clrf ICount
	movlw Low(EepBuff)
	movwf FSR

INDatx	movf INDF,W		; write to B or C EEPROM
	call EEwriteBC
	movf INDF,W		; send data to LCD display
	call LCDout

	incf FSR
	incf ICount
	movlw E_NameSize
	xorwf ICount,W
	btfss STATUS,Z
	goto INDatx
;
; NOW WRITE REST OF HEADER INFO TO EEPROM ONLY
;
ImpIDF	movf INDF,W		; write ID/FUSE data
	call EEwriteBC
	incf ICount
	incf FSR
	movlw E_ROMStart
	xorwf ICount,W
	btfss STATUS,Z
	goto ImpIDF

	clrf ROMTmpH		; initialise ROM address counter
	clrf ROMTmpL
;
; GET 16 BYTES OF DATA
;
IMPMore	movlw 'M'			; send request to receive data from PC
	movwf TXREG

	call Receive		; wait 1 second for response - PC sends 00h or FFh
	btfsc RxHold,7
	goto ImpEnd		; bit 7 set = end of data

	movlw d'16'
	movwf ICount
	movlw Low(EepBuff)
	movwf FSR

RecData	call Receive		; receive data into buffer
	movwf INDF

	incf FSR
	decfsz ICount
	goto RecData

	movlw d'16'
	movwf ICount
	movlw Low(EepBuff)		; send data to EEPROM
	movwf FSR

INDat	movf INDF,W		; send data to EEPROM
	call EEwriteBC

	incf FSR
	decfsz ICount
	goto INDat

	movlw 8h			; add 8 ROM addresses to count
	addwf ROMTmpL
	btfsc STATUS,C
	incf ROMTmpH

	movf HiROMAdd,W		; if ROM address = ROM count for this chip
	xorwf ROMTmpH,W		; then save this I2C address which is the
	btfss STATUS,Z		; start of the EEPROM data
	goto IMPMore

	movf ROMTmpL,W
	btfss STATUS,Z
	goto IMPMore
;
; START OF EEPROM DATA
;
	movf CodeAddH,W		; save eeprom start address
	movwf EEPaddH
	movf CodeAddL,W
	movwf EEPaddL
	goto IMPMore
;
; IMPORT COMPLETED, SEND BACK USAGE DATA
;
ImpEnd	bcf STATUS,IRP
	movlw 'F'
	movwf TXREG		; send block usage data back to PC
	call EEstop
	call FinishIR		; write file address info to int EEPROM
	call ByteSd32		; send block usage to PC
;
; WRITE EEPROM START ADDRESS TO I2C
;
	movlw E_EepStart
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartW
	movf EEPaddH,W
	call EEwriteBC
	movf EEPaddL,W
	call EEwriteBC
	call EEstop

	movlw 14h			; import complete
	call MessProc1
	movlw 53h			; waiting for PC
	call MessProc2
	call ReceiveP		; wait for ack char from PC
	goto ImpExp		; back to menu
;
; OTHER RESPONSES TO IMPORT REQUEST
;
NilTrans	movlw 15h			; nil data to transfer
	goto EndImport

MemFull	movlw 4Ch			; memory full

EndImport	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto ImpExp		; back to menu
;
; ------------------
; FINISH IMPORT/READ
; ------------------
; writes start block and FNindex to int eeprom and 00h to last link
;
FinishIR	movf FNindex,W		; store start address index
	addlw StartAdd
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	movf _SaveH,W		; save new file start address (High), 
	call IEwrite		; low always = 0

	movlw CurFile		; save current program to eeprom
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM page 0
	movf FNindex,W
	call IEwrite		; save it
;
; WRITE 00h TO LAST BLOCK AT ADDRESS 0xFF - SIGNIFIES LAST USED BLOCK
;
	movlw 0xFF
	movwf CodeAddL		; CodeAddH already set
	call BCstartW
	clrw
	call EEwrite
	call EEstop		; writes data to eeprom
	return
;
; ---------------------------
; SEND ROM AND EEP SIZE TO PC
; ---------------------------
;
SendSize	movf HiROMAdd,W
	movwf TXREG		; amount of ROM words needed X 256
	movf EEsizeH,W
	movwf TXREG
	call TransWt
	movf EEsizeL,W
	movwf TXREG		; and amount of EEPROM bytes
	return
;
; -----------------------------------------------------------
; SEE IF ENOUGH DATA BLOCKS ARE AVAILABLE FOR PROGRAM STORAGE
; -----------------------------------------------------------
; RETURNS W = 0 = OK, W = 255 = FULL
; BLOCK = Free, bit = 1, Block = Used, bit = 0
;
BlocksOK	movf BlockCnt,W		; get I2C block storage count for selected chip
	movwf Temp1		; block count in W
	movlw BlockBits		; start address for block bits in internal EEPROM
	movwf Temp3
NextBkBy	movlw b'10000000'
	movwf BCount		; bit counter
;
; scan through block available bits
;
	movf Temp3,W
	call IEread		; get bit info
	movwf Temp2

BlockAv	movf BCount,W
	andwf Temp2,W
	btfsc STATUS,Z
	goto NoFreeBit		; bit = 0, block is not available

	decfsz Temp1		; bit = 1, block is available
	goto NoFreeBit

	bsf Flag2,OK		; blocks available
	return
;
; shift to next bit
;
NoFreeBit	bcf STATUS,C		; this block not available
	rrf BCount		; shift bit for next test
	btfss STATUS,C
	goto BlockAv		; test for next free bit

	incf Temp3		; move to next block byte
	movlw UpperBits		; test if at end
	xorwf Temp3,W
	btfss STATUS,Z
	goto NextBkBy		; test next byte

	bcf Flag2,OK		; not enough blocks available
	return
;
; ------------------------------------------------------
; STORE THE NEW PROGRAM START ADDRESS IN INTERNAL EEPROM
; ------------------------------------------------------
; search through addresses in internal EEPROM for first 0xFF
; FNindex is a pointer for the data for this program code
;
StartAdr	bsf Flag2,OK		; preset to OK
	movlw StartAdd
	movwf Temp4
	movf FNindex,W
	movwf Temp3
	clrf FNindex

TestFF	movf Temp4,W
	call IEread		; get address info
	xorlw 0xFF
	btfsc STATUS,Z
	return

	incf FNindex		; new file index value
	incf Temp4
	movlw UpperAdd
	xorwf Temp4,W
	btfss STATUS,Z
	goto TestFF

	movf Temp3,W		; restore original index value
	movwf FNindex
	bcf Flag2,OK
	return			; out of storage space
;
; ---------------------------
; FIND NEXT FREE EEPROM BLOCK
; ---------------------------
; Block Address H result in CodeAddH, CodeAddL = 0
; Block is flagged used if a free one is found
; Blocks were previously tested as available
;
FindBlock	clrf Byte64
	movlw BlockBits		; start address for block bits
	movwf Temp3
	clrf CodeAddH
	clrf CodeAddL	
NextItBy	movlw b'10000000'
	movwf BCount		; bit counter
;
; scan through block available bits
;
	movf Temp3,W
	call IEread		; get bit info
	movwf Temp2

BlockIt	movf BCount,W
	andwf Temp2,W
	btfss STATUS,Z		; 0 bits = used
	goto FoundBK		; 1 bits = unused
;
; This block not available, shift to next bit
;
	incf CodeAddH		; increment Block address H
	bcf STATUS,C
	rrf BCount		; shift bit for next test
	btfss STATUS,C
	goto BlockIt		; test for next free bit

	incf Temp3
	goto NextItBy		; test next byte
;
; Found a free block, flag it now used
;
FoundBK	movf Temp3,W
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	movlw 0xFF
	xorwf BCount,W		; set block bit = 0
	andwf Temp2,W
	call IEwrite
	return
;
; -------------------------------
; START WRITING TO B OR C EEPROMS
; -------------------------------
;
BCstartW	call EEstart		; start condition

	movlw Bwrite		; control byte 'write' EEPROM (B)
	btfsc CodeAddH,7
	movlw Cwrite		; control byte 'write' EEPROM (C)
	call EEwrite

	movf CodeAddH,W
	call EEwrite		; address Hi
	movf CodeAddL,W
	call EEwrite		; address Lo

	return
;
; -----------------------------
; WRITE A BYTE TO EEPROM B OR C
; -----------------------------
; if CodeAddL = 255 before data write then find next free block and flag it used
; and write it's start address H to 255. L byte always = 0. Do EEstop.
; Do BCstart and write the data byte.
;
EEwriteBC	movwf Temp4
	movf CodeAddL,W
	xorlw BlockLink
	btfss STATUS,Z
	goto OldBlock

	call FindBlock		; finds next free block and flags it used, sets CodeAddH/L
	movf CodeAddH,W		; set in FindBlock
	call EEwrite
	call EEstop		; writes data to eeprom

	call BCstartW

OldBlock	movf Temp4,W
	call EEwrite

	incf CodeAddL		; current EEPROM address
	btfsc STATUS,Z
	incf CodeAddH

	incf Byte64
	movlw d'64'
	xorwf Byte64,W
	btfss STATUS,Z
	return

	call EEstop		; writes data to eeprom in 64 byte blocks
	clrf Byte64
	call BCstartW
	return
;
; -------------------------------
; FIND THE NEXT FILE FROM FNindex
; -------------------------------
; returns index value if file found, sets it into FNindex
; Sets CodeAddH = start address of file
; files are available for this routine
;
FindFile	movf FNindex,W
	movwf Temp4		; save FNindex start value
	addlw StartAdd
	movwf MessPt

seeFF	movf MessPt,W
	call IEread		; get program start address H
	movwf Temp1

	xorlw 0xFF		; FF in EEPROM means no file
	btfss STATUS,Z
	goto GotAFile

	incf FNindex		; move to next file
	incf MessPt
	movlw UpperAdd
	xorwf MessPt,W
	btfss STATUS,Z
	goto TestEnd

	clrf FNindex		; go back to start of data
	movlw StartAdd
	movwf MessPt

TestEnd	movf Temp4,W		; test if scanned through all files once
	xorwf FNindex,W
	btfss STATUS,Z
	goto seeFF		; not yet
	return

GotAFile	movf Temp1,W		; got a file start address
	movwf CodeAddH
	clrf CodeAddL		; always = 0 for file starts
	return
;
; ------------------------
; DISPLAY CURRENT FILENAME
; ------------------------
; file start address in CodeAddH/L
;
DispFileA	movlw 0x80
	goto InDispF

DispFile	movlw 0xC0
InDispF	call LCDins
	call BCstartR		; read from eprom A or C
	movlw E_NameSize
	movwf Temp4

FileNloop	call EEread_A		; EEPROM read with ACK
	call LCDout	
	decfsz Temp4
	goto FileNloop

	call EEread_N		; EEPROM read & stop without ACK - ignore data
	return
;
; DELETE A FILE
; File to delete is pointed to by FNindex
; free all block bits ascociated with this file
; clear file start byte
; clear EEPROM data address
; find next available file - set FNindex.
; if no files - FNindex = FF
; write FNindex to eeprom[curfile]
;
DeletFile	clrf PCLATH
	movlw 37h			; erasing...
	call MessProc1
	movlw StartAdd
	addwf FNindex,W
	movwf Temp2		; temp save offset address
	call IEread
	movwf CodeAddH		; save start address data
	movwf Temp1		; and again
;
; Clear the start address byte = 0xFF
;
	movf Temp2,W		; get saved address
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	movlw 0xFF
	call IEwrite
;
; clear block used bit
; address H = bit number to clear in block bit used registers
;
NextLink	movf Temp1,W
	andlw b'00000111'		; MOD 8 value of address = bit 0 - 7
	movwf Temp2

	rrf Temp1
	rrf Temp1
	rrf Temp1,W
	andlw b'00011111'		; DIV 8 value of address = byte number
	addlw BlockBits		; = byte offset
	movwf Temp3		; save address
	call IEread		; get block bit info
	movwf Temp1		; save it
;
; Find the block bit in the byte
;
	movlw b'10000000'
	movwf Temp4
FindBit	movf Temp2,W
	btfsc STATUS,Z
	goto GotMask

	decf Temp2
	bcf STATUS,C
	rrf Temp4
	goto FindBit

GotMask	movf Temp3,W		; get saved address	
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	movf Temp1,W		; get saved block info
	iorwf Temp4,W		; clear the block bit -> = 1
	call IEwrite		; write back new value
;
; read block link address - if = 00h then end of file
;
	movlw BlockLink
	movwf CodeAddL		; CodeAddH already set
	call BCstartR		; read from eprom A or C
	call EEread_N		; EEPROM read without ACK
	movwf Temp3		; save value

	movf Temp3,W
	btfsc STATUS,Z
	goto FileEND		; link = 00h

	movwf CodeAddH		; save block start address data
	movwf Temp1		; and again
	goto NextLink
;
; find first available file - set FNindex.
; if no files - FNindex = FF
; write FNindex to eeprom[curfile]
;
FileEND	clrf FNindex
	movlw StartAdd
	movwf Temp3

TestNxt	movf Temp3,W
	call IEread		; get address info
	movwf Temp1

	movlw 0xFF
	xorwf Temp1,W
	btfss STATUS,Z
	goto GotNFile		; got file

FileEnd	incf FNindex
	incf Temp3
	movlw UpperAdd
	xorwf Temp3,W
	btfss STATUS,Z
	goto TestNxt

	movlw 0xFF		; no other files available
	movwf FNindex
	goto FinDelF

GotNFile	clrf FNindex		; search from start
	call FindFile		; find filename (FNindex used)
;
; save new FNindex
;
FinDelF	movlw CurFile
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	movf FNindex,W
	call IEwrite
	return
;
; ------------------------------
; HIGHLIGHT THE CURRENT LINE '<'
; ------------------------------
;
HighLiteA	bcf Flag2,FLayer
	goto Line1

HighLight	movlw B'00010000'
	xorwf Flag2		; alternate FLayer bit

HighLiteB	btfsc Flag2,FLayer
	goto Line2

Line1	movlw 0xCF		; de-highlight bottom line
	call LCDins
	movlw ' '
	call LCDout
	movlw 0x8F		; highlight top line
	call LCDins
	movlw '<'
	call LCDout
	return

Line2	movlw 0x8F		; de-highlight top line
	call LCDins
	movlw ' '
	call LCDout
	movlw 0xCF		; highlight bottom line
	call LCDins
	movlw '<'
	call LCDout
	return
;
; ---------------------------------
; START READING FROM B OR C EEPROMS
; ---------------------------------
;
BCstartR	call EEstart		; start condition

	movlw Bwrite		; control byte 'write' EEPROM (B)
	btfsc CodeAddH,7
	movlw Cwrite		; control byte 'write' EEPROM (C)
	call EEwrite

	movf CodeAddH,W
	call EEwrite		; address Hi

	movf CodeAddL,W
	call EEwrite		; address Lo	

	call EEstart		; do another start condition

	movlw Bread		; control byte 'read' EEPROM (B)
	btfsc CodeAddH,7
	movlw Cread		; control byte 'read' EEPROM (C)
	call EEwrite
	return
;
; ------------------------------
; READ A BYTE FROM EEPROM B OR C
; ------------------------------
; if CodeAddL = 254 before data read then find next free block
; do EEread_N then BCstartR
; read byte
;
EEreadBC	movf CodeAddL,W
	xorlw BlockLink
	btfss STATUS,Z
	goto OldBlockR

	call EEread_N		; = link address H
	movwf CodeAddH
	clrf CodeAddL
	call BCstartR

OldBlockR	call EEread_A
	incf CodeAddL
	btfsc STATUS,Z
	incf CodeAddH
	return
;
; ------------------------------------
; WAIT UNTIL RS232 IS FINISHED SENDING
; ------------------------------------
;
TransWt	bsf STATUS,RP0
WtHere	btfss TXSTA,TRMT		; (1) transmission is complete if hi
	goto WtHere

	bcf STATUS,RP0		; RAM Page 0
	return
;
; ----------------------------------------
; RECEIVE CHARACTER FROM RS232 OR INTERNAL
; ----------------------------------------
; This routine does not return until a character is received.

ReceiveP	nop
          btfss PIR1,RCIF		; (5) check for received data
          goto ReceiveP

          movf RCREG,W
          movwf RxHold		; tempstore data
          return
;
; ---------------------------
; TEST IF FILES ARE AVAILABLE
; ---------------------------
;
AreFiles	bsf Flag2,OK		; preset are files
	movf FNindex,W
	xorlw 0xFF
	btfss STATUS,Z
	return			; yes

	movlw 52h			; no files
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	bcf Flag2,OK
	return			; no files
;
; --------------------------------------
; SEND 32 EEPROM BLOCK USAGE BYTES TO PC
; --------------------------------------
;
ByteSd32	clrf ICount		; send 32 usage bytes to PC
UBloop	movlw BlockBits
	addwf ICount,W
	call IEread
	movwf TXREG
	call Delay6ms		; delay between bytes
	incf ICount
	movlw d'32'
	xorwf ICount,W
	btfss STATUS,Z
	goto UBloop
	return
;
; ------------------------
; START POCKET.EXE MESSAGE
; ------------------------
;
StartPP	bcf RCSTA,CREN		; clear any errors
	movlw 3Dh			; start pocket.exe
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	bsf RCSTA,CREN		; restart receive mode
	call AnyKey		; OK flag = 1 if Key 1 pressed
	movf RCREG,W
	movf RCREG,W
	movf RCREG,W
	return
;
; --------------------
; CLEAR THE LCD SCREEN
; --------------------
;
ClearScr	movlw 01h
	call LCDins
	return
;
; -----------------------
; BINARY TO BCD CONVERTER
; -----------------------
; suits numbers < 100 only
;
Bin2BCD	movwf Temp4
	clrf Temp3
BinLP10	movlw d'10'
	subwf Temp4
	btfss STATUS,C
	goto Under10

	incf Temp3	; increment digit tens storage
	goto BinLP10

Under10	movlw d'10'	; restore last 10 value subtracted
	addwf Temp4	; result = units
	return
;
; ---------------------------------------------
; GENERATE A HEADER AND FILENAME AFTER READMODE
; ---------------------------------------------
; 'P' + Filename max = 8 chars + '_' + Rand(XX) + balance ' ' (if any) 
;
; BYTES 0 - 11    = FILENAME 12 bytes
; BYTES 12 - 13   = ID LOCS (1) H L 2 bytes
; BYTES 14 - 15   = ID LOCS (2) H L 2 bytes
; BYTES 16 - 17   = FUSE (1) H L 2 bytes - 12 bit/16 bit fuse 16 bit fuse 300000 300001
; BYTES 18 - 19   = FUSE (2) H L 2 bytes - 16 bit fuse 300002 300003
; BYTES 20 - 21   = FUSE (3) H L 2 bytes - 16 bit fuse 300004 300005
; BYTES 22 - 23   = FUSE (4) H L 2 bytes - 16 bit fuse 300006 300007
; BYTES 24 - 25   = EEPROM DATA START ADDRESS H L
; BYTES 26        = ROM DATA SIZE H (L = 0)
; BYTES 27 - 28   = EEPROM DATA SIZE H L
; BYTES 29        = FILE TYPE INHX8M OR INHX32
; BYTES 30 - 31   = SERIAL DATA START ADDRESS H L
;
DoHeader	clrw
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartW		; at header I2C start address

	movlw 'P'
	call EEwriteBC

	movlw ChipBuff		; get chip name length
	movwf FSR			; 8 chars max
	movf INDF,W
	movwf NibA
	incf FSR			; point to chip name 1st char

	sublw d'8'		; P + (chipname) + _xx
	movwf NibB		; save (8 - chipname length) value

FGloop	movf INDF,W		; total filename = 12 chars
	call EEwriteBC

	incf FSR
	decfsz NibA
	goto FGloop

	movlw '_'
	call EEwriteBC

	movf TMR0,W		; sort of random number
	movwf NibA		; for file number
	swapf NibA,W
	call ToASCII
	call EEwriteBC
	movf NibA,W
	call ToASCII
	call EEwriteBC

CmpSpc	movf NibB,W		; pad with spaces until = 12 chars
	btfsc STATUS,Z
	goto StREad

	movlw ' '
	call EEwriteBC
	decf NibB
	goto CmpSpc

; SAVE ID LOC - FUSE

StREad	movlw Low(IDloc1H)
	movwf FSR
	bsf STATUS,IRP
	movlw 6h			; 6 words
	movwf NibB

IDFloop	movf INDF,W
	call EEwriteBC		; hi byte
	incf FSR
	movf INDF,W
	call EEwriteBC		; low byte
	incf FSR
	decfsz NibB
	goto IDFloop

	bcf STATUS,IRP
;
; SAVE EEPROM START ADDRESS
;
	movf EEPaddH,W
	call EEwriteBC
	movf EEPaddL,W
	call EEwriteBC

; SAVE ROM SIZE

	movf HiROMAdd,W
	call EEwriteBC

; SAVE EEPROM SIZE

	movf EEsizeH,W
	call EEwriteBC
	movf EEsizeL,W
	call EEwriteBC

; SAVE FILE TYPE

	movlw '8'
	btfsc Flag2,f8M32
	movlw '3'
	call EEwriteBC
	movlw 'M'
	btfsc Flag2,f8M32
	movlw '2'
	call EEwriteBC

	call EEstop
	return
;
; ------------------------------------------------------
; DISSASSEMBLE OR BOOT FUNCTION NOT AVAILABLE FOR 18Cxxx
; ------------------------------------------------------
;
DFNA	movlw 9Bh			; not available
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto TopMenu
;
; --------------------------------
; COUNT THE BLOCKS USED FOR A FILE
; --------------------------------
;
BlockCwt	movlw 1h
	movwf Temp4
	movlw BlockLink
	call SetCdAddH		; set CodeAddH for code start address

BlkLoop	movlw BlockLink
	movwf CodeAddL

	call BCstartR
	call EEread_N
	movwf Temp3
	
	movf Temp3,W		; address link or 0
	btfsc STATUS,Z
	return			; 0 = end of file

	incf Temp4		; add 1 to block count
	movwf CodeAddH
	goto BlkLoop
;
; DELETE ALL FILES FROM MEMORY
; free all block bits
; clear all file start bytes
; clear all fuse and eeprom bytes
;
DelALL	movlw 4Bh			; sure? k1 = yes
	call MessProc1

	call AnyKey		; OK flag = 1 if Key 1 pressed
	btfss Flag2,OK
	goto ChgDel		; aborted

	movlw 37h			; erasing...
	call MessProc1
	call ClearFile
	goto ChgDel

; ***********************

	Org 0800h

; ***********************
;
; ---------------------------
; INITIALISE THE READ PROCESS
; ---------------------------
;
ReadMode	call SetPins		; pins display
	btfsc Flag2,OK
	goto OKtoRead

	clrf PCLATH
	goto TopMenu		; key 1 = aborted
;
; CHECK IF ENOUGH DATA BLOCKS AVAILABLE IN EEPROMS FOR NEW PROGRAM
;
OKtoRead	clrf PCLATH
	call BlocksOK		; see if enough blocks, OK = 1 = enough, OK = 0 = full
	ThisPage
	btfss Flag2,OK
	goto MemFullR		; full

	clrf PCLATH
	call StartAdr		; program address storage available? OK = 0 = no
	ThisPage
	btfsc Flag2,OK
	goto SttRead

MemFullR	movlw 4Ch			; memory full
	goto ExitMode
;
; set start ROM address and byte count
;
SttRead	clrf PCLATH

	movlw 23h
	call MessProc1		; Read ROM

	call FindBlock		; finds next free block and flag it used, sets CodeAddH/L
	movf CodeAddH,W
	movwf _SaveH		; save start address for FinishIR subroutine
	movlw d'32'
	movwf CodeAddL
	movwf Byte64
	call BCstartW
;
; READ ROM PROCEDURE
;
	ThisPage
	call VoltsON5		; turn on VCCP and VPPx

	clrf ProgAddH
	clrf ProgAddL
;
; DO 18CXXX IF SELECTED
;
	btfss Flag2,f8M32
	goto RdROM

	call Rd18ROM
	goto Rd18CDn		; finish read routine
;
; READ THE ROM DATA TO EEPROM (B or C)
;
RdROM	call ReadROM		; Read the ROM data -> ROMTmpH/L

	clrf PCLATH
	movf ROMTmpH,W		; send data to EEPROM (A)
	call EEwriteBC
	movf ROMTmpL,W		; send data to EEPROM (A)
	call EEwriteBC
	ThisPage

	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	call IncAddr

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto RdROM
;
; FINISHED READING ROM
;
	call VoltsOFF
;
; SET EEPROM START ADDRESS
;
	movf CodeAddL,W
	movwf EEPaddL
	movwf TXREG
	movf CodeAddH,W
	movwf EEPaddH
	movwf TXREG
;
; READ EEPROM IF IS EEPROM TYPE
;
	btfss Flag3,Etype		; = 1 if eeprom type chip
	goto DoRdFuse		; no eeprom data

RdEep	clrf PCLATH
	call EEstop		; stop writing for message
	movlw 24h
	call MessProc1		; Reading EEPROM

	call BCstartW

	ThisPage
	call VoltsON5		; turn on VCCP and VPPx

	clrf ProgAddL
	clrf ProgAddH
;
; READ THE EEPROM DATA
;
RdgEEP	call ReadEE		; -> W
	clrf PCLATH
	call EEwriteBC		; write to B or C EEPROM
	ThisPage

	incf ProgAddL		; current PIC EEPROM address -> DisProg routine
	btfsc STATUS,Z
	incf ProgAddH

	call IncAddr

	movf EEsizeL,W
	andlw b'00001111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf EEsizeL,W		; see if all completed
	xorwf ProgAddL,W
	btfss STATUS,Z
	goto RdgEEP

	movf EEsizeH,W		; see if all completed
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto RdgEEP		; no

	call VoltsOFF
;
; READ THE ID AND FUSE
;
DoRdFuse	clrf PCLATH
	call EEstop		; writes last read data bytes to eeprom
	call ClearScr
	
	ThisPage
	call VoltsON5		; turn on VCCP and VPPx
	call ReadFuse		; stores in ID and fuse registers
Rd18CDn	call VoltsOFF
;
; ALL COMPLETED OK - WRITE START BLOCK ADDRESS AND FNindex TO INT EEPROM
;
	clrf PCLATH
	call FinishIR
	call DoHeader		; write header details

	ThisPage
	movlw 25h			; read complete
	goto ExitMode
;
; ---------------------------
; FINISH OF READ/WRITE/VERIFY
; ---------------------------
;
Vcomplete	movlw 28h			; verify ok
ExitProc	movwf Temp3
	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data

	movf Temp3,W
ExitMode	clrf PCLATH
	call MessProc1
	movlw 12h
	call MessProc2		; Press any key
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto TopMenu
;
; -------------------
; READ A ROM LOCATION
; -------------------
; ROM data is put in ROMTmpH(L)
;
ReadROM   movlw b'00000100'		; Read Data command
	goto InRead
;
; ---------------------------------
; READ DATA FROM EEPROM DATA MEMORY
; ---------------------------------
; EEPROM data is in W
;
ReadEE    movlw b'00000101'		; Read EEPROM Data Command
InRead	call Command		; send it

	bcf PORTB,Dat		; make sure data line = low
	call ClkDelay

	bcf PORTC,HiZ		; data out pin = HiZ
	call ClkDelay

          movlw d'16'		; 16 EEPROM data bits to read
          movwf BCount

ReadEp    bsf PORTB,Clk		; (6) PIC clock = Logic 1 gets data from PIC
          call ClkDelay

          bcf PORTB,Clk		; (6) Clock bit = Logic 0
          call ClkDelay

          bcf STATUS,C		; set carry bit = incoming data bit
          btfss PORTB,DataR		; (4) read data bit = inverted
          bsf STATUS,C

          rrf ROMTmpH		; shift carry into data regs
          rrf ROMTmpL

          decfsz BCount		; do until all bits are sent
          goto ReadEp

          bcf STATUS,C		; shift 14 bit data across to compensate for
          rrf ROMTmpH		; the start bit that was read from the PIC
          rrf ROMTmpL

	bsf PORTC,HiZ		; data out pin = out
	call ClkDelay

          movlw b'00111111'		; mask upper 2 bits
          andwf ROMTmpH

          movf ROMTmpL,W
          return
;
; ------------------
; READ THE FUSE DATA
; ------------------
; Data into FuseH/L
;
ReadFuse	call ReadID		; -> IDlocH/L PIC address = 2007 on return
	call ReadROM        	; read fuse
	movf ROMTmpH,W		; store it to fuse registers
	bsf STATUS,RP1		; RAM Page 2
	movwf Fuse1H
	bcf STATUS,RP1		; RAM Page 0
	movf ROMTmpL,W
	bsf STATUS,RP1		; RAM Page 2
	movwf Fuse1L
	bcf STATUS,RP1		; RAM Page 0
	return	
;
; -------------------------------
; READ ID LOCATIONS - 14 BIT CORE
; -------------------------------
; Sets IDlocH - IDlocL
; PIC address = 2007 on return
;
ReadID	call LoadCfig		; Load Configuration Command

	call ReadROM		; 2000 ID Loc
	swapf ROMTmpL,W
	andlw 0xF0
	movwf Data2H
          call IncAddr

	call ReadROM		; 2001 ID Loc
	movf ROMTmpL,W
	andlw 0x0F
	iorwf Data2H
	call IncAddr
	
	call ReadROM		; 2002 ID Loc
	swapf ROMTmpL,W
	andlw 0xF0
	movwf Data2L
          call IncAddr

	call ReadROM		; 2003 ID Loc
	movf ROMTmpL,W
	andlw 0x0F
	iorwf Data2L

	call IncAddr		; 2004
          call IncAddr		; 2005
          call IncAddr		; 2006
          call IncAddr		; 2007

	movf Data2H,W
	bsf STATUS,RP1		; RAM Page 2
	movwf IDloc1H
	bcf STATUS,RP1		; RAM Page 0
	movf Data2L,W
	bsf STATUS,RP1		; RAM Page 2
	movwf IDloc1L
	bcf STATUS,RP1		; RAM Page 0
	return
;
; -------------------------
; INCREMENT ADDRESS COMMAND
; -------------------------
;
IncAddr   movlw b'00000110'		; Increment Address command = 000110
          call Command		; send it
	return
;
; --------------------------
; LOAD CONFIGURATION COMMAND
; --------------------------
;
LoadCfig	movlw b'00000000'		; Load Configuration Command
          call Command		; send it

; Send 16 bits of data. This data is not used by the chip

	clrf Data1H
	clrf Data1L
	call Send16		; send 16 data bits to PIC
	return
;
; ---------------------
; "INSERT CHIP" MESSAGE
; ---------------------
;
SetPins	clrf PCLATH
	movlw ProMode
	call IEread
	movwf Temp1
	ThisPage
	movf Temp1,W
	xorlw 0xAA
	btfss STATUS,Z
	goto Intern
	
	clrf PCLATH
	movlw 4Ah			; ICSP
	call MessProc1		
	movlw 22h
	call MessProc2		; k1 = start
	ThisPage
	goto WKey

Intern	clrf PCLATH
	movlw 21h			; insert chip 1-
	call MessProc1		
	movlw 22h
	call MessProc2		; k1 = start
	movlw 8Eh
	call LCDins		; display to pin number staring at line 1 pos 15
	ThisPage

	movf PICpins,W
	xorlw '0'
	btfss STATUS,Z
	goto pins18

	clrf PCLATH
	movlw '1'			; 8 pins insert at pin 11
	call LCDout
	ThisPage

	movlw '1'
	goto pinsDone

pins18	movf PICpins,W
	xorlw '1'
	btfss STATUS,Z
	goto pins2840

	movlw '2'			; 18 pins insert at pin 2
	goto pinsDone

pins2840	movlw '1'			; 28 - 40 pins insert at pin 1
pinsDone	clrf PCLATH
	call LCDout
;
; WAIT FOR KEYPRESS
;
WKey	bcf Flag2,OK		; aborted
	clrf PCLATH
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	return			; key value in W
;
; ----------------------------------
; TURN OFF THE VPP AND VCCP VOLTAGES
; ----------------------------------
; Calling code must reset PCLATH after calling this routine
;
VoltsOFF	movlw b'11001101'		; VPP's off data pin = HiZ
	andwf PORTC
	call Dl12Pg1		; <<<< follows through to VccPoff >>>>
;
; -----------------
; TURN PWM VCCP OFF
; -----------------
;
VccPoff	clrf PORTB		; RB6/7 lo
	bcf PORTC,VccOn		; VccP = off
	bcf T2CON,TMR2ON		; TMR2 = off
	clrf CCP1CON		; PWM off
	bcf PORTC,PWM		; make sure PWM output is low
	call Del12Pg1
	return
;
; ---------------------------------
; TURN ON THE VPP AND VCCP VOLTAGES
; ---------------------------------
;
VoltsON5	movlw V5calH		; 5V volt cal value
	movwf Vvalue
VoltsON	clrf PORTB		; make sure RB6/7 = lo
	call Dl12Pg1		; delay

	clrf PCLATH
	movf Vvalue,W		; Turn PWM VccP on
	call IEread		; X volt cal PWM data H
	movwf DutyH
	incf Vvalue,W		; X volt cal PWM data L
	call IEread
	movwf DutyL
	call SetDuty
	ThisPage
	bsf PORTB,ActLed
	movlw b'00001100'		; PWM mode = on
	iorwf CCP1CON
	bsf T2CON,TMR2ON		; TMR2 = on
	call Del12Pg1		; voltage stabilize delay
	bsf PORTC,VccOn		; VccP = on
	call Del12Pg1		; voltage stabilize delay

	bsf PORTC,HiZ		; data pin = out lo
;
; IF ICSP MODE (OxAA) THEN ONLY USE VPP1
;
	clrf PCLATH
	bsf STATUS,RP1		; RAM Page 2
	movlw ProMode
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	call IEread
	movwf Temp1
	ThisPage

	movf Temp1,W
	xorlw 0xAA
	btfsc STATUS,Z
	goto DoVPP1

	movf VPPtype,W
	xorlw '1'			; 1 = VPP1, 2 = VPP2
	btfss STATUS,Z
	goto DoVpp2

DoVPP1	bsf PORTC,SVP1    		; (5) turn on VPP1
          goto FVpp

DoVpp2	bsf PORTC,SVP2    		; (4) turn on VPP2

FVpp	call Del12Pg1		; long delay
	return
;
; ------------------------------
; TURN ON VCC AT CORRECT VOLTAGE
; ------------------------------
;
VccVolts	btfsc Flag2,Blank		; normal 5V for blank
	goto Vequal5

	btfss Flag1,MVee		; is multy V mode?
	goto Vequal5		; no - use 5V

	call SetMulVee		; set the correct upper/lower multyV
	return

Vequal5	call VoltsON5
	return
;
; -------------------
; SET MULTY V VOLTAGE
; -------------------
;
SetMulVee	clrf PCLATH
	movlw VLAddress		; lower
	btfsc Flag2,MVdo
	movlw VHAddress		; upper
	call IEread		; get Verify voltage
	movwf Data1L		; store voltage index value
	ThisPage

	btfsc Flag3,NoVolt
	goto SetVval

	clrf PCLATH
	bsf Flag1,Ms2Ps
	movlw 66h			; voltage values
	addwf Data1L,W
	call MessProc2
	movlw 'V'
	call LCDout
	ThisPage

SetVval	bcf STATUS,C
	rlf Data1L,W		; address X 2
	addlw 1h			; + 1
	movwf Vvalue
	call VoltsON		; turn on VCCP and VPPx
	return
;
; --------------------------------
; 12mS Delay and Longer ROM Page 1
; --------------------------------
;
Del12Pg1	movlw 0xA0
	goto InDel1
Dl12Pg1   movlw 11h
InDel1	movwf DelayH
	clrf DelayL
Del1a1    decfsz DelayL
          goto Del1a1
          decfsz DelayH
          goto Del1a1
          return
;
; -----------------------------------
; SEE IF CHIP AND FILE SIZES ARE SAME
; -----------------------------------
; OK flag 1 = ok, 0 = not ok
;
CheckSize	bsf Flag2,OK		; preset = OK
	clrf PCLATH
	movlw E_RomSize
	call SetCdAddH		; set CodeAddH for code start address	
	call BCstartR
	call EEreadBC
	movwf Temp4		; rom size H
	call EEreadBC
	movwf Data1H		; eep size H
	call EEreadBC
	movwf Data1L		; eep size L
	call EEread_N

	ThisPage
	movf HiROMAdd,W
	xorwf Temp4,W
	btfss STATUS,Z
	goto ROMszerr		; rom no match

	movf EEsizeH,W
	xorwf Data1H,W
	btfss STATUS,Z
	goto ROMszerr		; eep no match

	movf EEsizeL,W
	xorwf Data1L,W
	btfsc STATUS,Z
	return			; OK

ROMszerr	clrf PCLATH
	movlw 16h			; file missmatch
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	bcf Flag2,OK
	return			; error
;
; ------------------------------------
; DISPLAY PROGRAMMING/READING PROGRESS
; ------------------------------------
; Calling code must reset PCLATH after calling this routine
; 
DispProg	movlw Low(EepBuff)
	movwf FSR
	bsf STATUS,IRP
	clrf PCLATH
	movf ProgAddH,W
	call HexASCII
	movf ProgAddL,W
	call HexASCII

	movlw 0xC0
	call LCDins
	movlw Low(EepBuff)
	movwf FSR

	movf INDF,W
	call LCDout
	incf FSR
	movf INDF,W
	call LCDout
	incf FSR
	movf INDF,W
	call LCDout
	incf FSR
	movf INDF,W
	call LCDout
	movlw 'h'
	call LCDout
	bcf STATUS,IRP
	ThisPage
	return
;
; ---------------------
; SEND A COMMAND TO PIC
; ---------------------
; Command is in W Reg
; Command is sent LSB first
; Clock pin is at Logic 0 to start with
; Data pin is Logic 0 to start with

Command   movwf Temp4
          movlw 6h			; 6 bits to send
          movwf BCount

SendBit   rrf Temp4			; shift bit into carry
          bsf PORTB,Clk		; (6) clock pin = high
          btfsc STATUS,C		; data bit = carry bit
          goto SBitHa

          bcf PORTB,Dat		; (7) data bit = Logic 0
          goto SBDelb

SBitHa    bsf PORTB,Dat		; (7) data bit = 1
SBDelb    call ClkDelay

          bcf PORTB,Clk		; (6) PIC accepts data as clock pin goes low
	call ClkDelay
	  
          decfsz BCount		; continue for 6 bits
          goto SendBit

          return
;
; --------------------------------
; TRANSFER ID AND FUSE DATA TO RAM
; --------------------------------
; Into Temp ID and Fuse registers
;
IDFuseRAM	movlw Low(TIDloc1H)
	movwf FSR
	bsf STATUS,IRP

	clrf PCLATH
	movlw E_ID1		; ID1 location in I2C memory
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
	movlw d'12'		; 12 bytes to transfer
	movwf Temp4

FidLp	clrf PCLATH
	call EEread_A
	movwf INDF
	incf FSR
	ThisPage
	decfsz Temp4
	goto FidLp

	clrf PCLATH
	call EEread_N
	ThisPage
	bcf STATUS,IRP
	return
;
; --------------------------------------
; SMALL DELAY FOR CLOCKING DATA INTO PIC
; --------------------------------------
;
ClkDelay  goto $ + 1
          return
;
; -----------
; 100uS Delay
; -----------
;
Delay100  movlw 20h
InDelu	movwf DelayL
Del4      decfsz DelayL
          goto Del4
          return
;
; ------------------------
; SET EEPROM START ADDRESS
; ------------------------
;
SetEEPAdd	clrf PCLATH
	movlw E_EepStart
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR

	call EEread_A		; address of eeprom start H
	movwf CodeAddH
	call EEread_N		; address of eeprom start L
	movwf CodeAddL

	call BCstartR
	ThisPage
	return
;
; -------------------
; SEND 16 BITS TO PIC
; -------------------
;
Send16	bcf STATUS,C		; insert start and stop bits
          rlf Data1L,W
          movwf ROMTmpL
          rlf Data1H,W
          movwf ROMTmpH
          movlw d'16'		; 16 data bits to send
          movwf BCount

ClockROMI	rrf ROMTmpH		; shift bit into carry
          rrf ROMTmpL
          bsf PORTB,Clk		; (6) PIC clock = Logic 1
	call ClkDelay
	bcf PORTB,Dat		; (7) data bit = Logic 0
          btfsc STATUS,C		; data bit = carry bit
	bsf PORTB,Dat		; (7) data bit = 1
	call ClkDelay
          bcf PORTB,Clk		; (6) Clock bit in

          decfsz BCount		; do until all bits are sent
          goto ClockROMI
          bcf PORTB,Dat		; (7) Set Data bit = Logic 0
	return
;
; ----------------------------------------
; COMPARE CHIP ID/FUSE WITH STORED ID/FUSE
; ----------------------------------------
; Values in IDloc/Fuse and TIdLoc/TFuse
;
IDFcomp	bcf Flag2,OK		; preset = not equal
	movf INDF,W		; read chip ID/FUSE
	movwf Temp4
	movlw d'12'		; point to temp stored ID/FUSE
	addwf FSR
	movf INDF,W		; read temp ID/FUSE
	xorwf Temp4,W		; compare the two values
	btfsc STATUS,Z
	bsf Flag2,OK		; are equal
	movlw d'11'		; point to chip ID/FUSE + 1
	subwf FSR
	clrf PCLATH
	ThisPage
	return
;
; -----------------------------
; VERIFY or SETUP MULTYV VERFIY
; -----------------------------
;
VerfMode	clrf PCLATH
	movlw 3Eh			; Verify mode
	call MessProc1
	movlw 3Fh			; Verify setup
	call MessProc2
	call HighLiteA		; put '<' on screen

VFloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto VFloop
	goto VFKey1
	goto VFKey2
	goto VFKey3
	goto VFloop
;
; VERFIY KEY 1
;
VFKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto VFloop
;
; VERIFY KEY 2
;
VFKey2	clrf PCLATH		; exit verify
	goto TopMenu
;
; VERIFY KEY 3
;
VFKey3	btfss Flag2,FLayer
	goto IVerfMode

IVF3Key	clrf PCLATH
	movlw 40h			; Multy V On Off
	call MessProc1
	movlw 41h			; Multy V Volts
	call MessProc2
	call HighLiteA		; put '<' on screen

MVloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto MVloop
	goto MVKey1
	goto MVKey2
	goto MVKey3
	goto VFKey2
;
; VERFIY VOLTAGE KEY 1
;
MVKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto MVloop
;
; VERIFY VOLTAGE KEY 2
;
MVKey2	goto VerfMode
;
; VERIFY VOLTAGE KEY 3
;
MVKey3	btfss Flag2,FLayer
	goto MultyVerf
;
; SELECT MULTY VERIFY UPPER AND LOWER VOLTAGES
;
InK3	clrf PCLATH
	movlw 44h			; Set Verify Upper
	call MessProc1
	movlw 45h			; Set Verify Lower
	call MessProc2
	call HighLiteA		; put '<' on screen

VUloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto VUloop
	goto VUKey1
	goto VUKey2
	goto VUKey3
	goto VFKey2
;
; UPPER/LOWER VERFIY KEY 1
;
VUKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto VUloop
;
; UPPER/LOWER VERIFY KEY 2
;
VUKey2	goto IVF3Key
;
; UPPER/LOWER VERIFY KEY 3
;
VUKey3	btfsc Flag2,FLayer
	goto SetLowr

	clrf PCLATH
	movlw 44h			; Set Verify Upper
	call MessProc1
	ThisPage
	movlw VHAddress
	goto inV

SetLowr	clrf PCLATH
	movlw 45h			; Set Verify Lower
	call MessProc1
	movlw VLAddress
inV	movwf Data1H		; store eeprom address
	clrf PCLATH
	call IEread
	movwf Data1L		; store voltage index value
	addlw 66h			; voltage values
	call MessProc2
;
; CHANGE CURRENT SETTING
;
CSloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto CSloop
	goto CSKey1
	goto InK3
	goto CSKey3
	goto CSKey4
;
; CHANGE UPPER/LOWER VERFIY KEY 1
;
CSKey1	incf Data1L
	movlw d'17'
	xorwf Data1L,W
	btfsc STATUS,Z
	clrf Data1L
	goto NotUn
;
; CHANGE UPPER/LOWER VERIFY KEY 3
;
CSKey3	clrf PCLATH
	movf Data1H,W
	bsf STATUS,RP1		; RAM Page 2
	movwf EEADR		; eeprom address for upper or lower
	bcf STATUS,RP1		; RAM Page 0
	movf Data1L,W		; voltage index
	call IEwrite		; set new voltage index value
	ThisPage
	goto InK3
;
; CHANGE UPPER/LOWER VERFIY KEY 4
;
CSKey4	decf Data1L
	btfss Data1L,7
	goto NotUn

	movlw d'16'
	movwf Data1L
NotUn	movlw 66h			; voltage values
	addwf Data1L,W
	clrf PCLATH
	call MessProc2
	ThisPage
	goto CSloop
;
; SELECT IF MULTY VERIFY MODE IS ON OR OFF
;
MultyVerf	clrf PCLATH
	movlw 42h			; Multy V = OFF
	call MessProc1
	movlw 43h			; Multy V = ON
	call MessProc2
	movlw VFAddress
	call IEread
	bcf Flag2,FLayer
	xorlw 0xAA
	btfsc STATUS,Z
	bsf Flag2,FLayer
	call HighLiteB		; put '<' on screen

VOloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto VOloop
	goto VOKey1
	goto VOKey2
	goto VOKey3
	goto VFKey2
;
; MULTY VERIFY KEY 1
;
VOKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto VOloop
;
; MULTY VERIFY KEY 2
;
VOKey2	goto IVF3Key
;
; MULTY VERIFY KEY 3
;
VOKey3	clrf PCLATH
	bsf STATUS,RP1		; RAM Page 2
	movlw VFAddress
	movwf EEADR		; 1st cal data
	bcf STATUS,RP1		; RAM Page 0
	clrw			; multy verify = off
	btfsc Flag2,FLayer
	movlw 0xAA		; multy verify = on
	call IEwrite		; no verify high data
	ThisPage
	goto IVF3Key
;
; ------------------------
; START THE VERIFY PROCESS
; ------------------------
;
IVerfMode	clrf PCLATH
	call ListFiles
	ThisPage

	btfss Flag2,OK
	goto VerfMode
;
; check rom/eep size against chip and file
;
	call CheckSize
	btfss Flag2,OK
	goto VerfMode
;
; PINs message
;
	call SetPins
	btfss Flag2,OK
	goto VerfMode		; aborted

	call IDFuseRAM		; transfer ID and Fuse data to RAM
	
Pverify	bcf Flag1,MVee		; no multy V mode
	clrf PCLATH
	movlw VFAddress
	call IEread		; get multy V flag
	xorlw 0h
	btfss STATUS,Z
	bsf Flag1,MVee		; is multy V mode
	bcf Flag2,MVdo		; doing 1st verify loop

CommencV	clrf PCLATH
	movlw 26h			; Verifying ROM
	call MessProc1
	ThisPage

	call VerfROM
	movlw 29h			; ROM error
	btfss Flag2,OK
	goto ExitProc
;
; VERIFY EEPROM IF IS EEPROM TYPE
;
	btfss Flag3,Etype		; = 1 if eeprom type chip
	goto DoVrfID		; no eeprom data

IsEdat	clrf PCLATH
	movlw 27h			; Verifying EEPROM
	call MessProc1
	ThisPage

	call VerfEEP
	movlw 19h			; eeprom error
	btfss Flag2,OK
	goto ExitProc

DoVrfID	btfsc Flag3,Pverf		; exit if verifying after programming
	goto BackProg

	bsf Flag3,NoVolt		; don't display verify voltage values
	call VerfFuses
	bcf Flag3,NoVolt	
	btfss Flag2,OK
	goto ExitProc

	btfss Flag1,MVee		; verified ok
	goto Vcomplete		; no multy V

	btfsc Flag2,MVdo		; 1st/2nd loop
	goto Vcomplete

	bsf Flag2,MVdo
	goto CommencV		; do upper V verify now
;
; ----------
; VERIFY ROM
; ----------
;
VerfROM	bcf Flag2,OK		; flag verify error
	clrf ProgAddH
	clrf ProgAddL
	call VccVolts		; turn on Vcc at correct voltage

VerfStrt	btfsc Flag2,Blank		; no need for I2C access if blank testing
	goto VerfMoreR

	clrf PCLATH
	movlw E_ROMStart		; data start address
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
	ThisPage

VerfMoreR	btfss Flag2,f8M32
	goto NotVf18C
;
; READ FROM 18CXXX ROUTINE
;
	movlw b'00001001'		; TBLRD *+ post increment - Even Address - Low Byte
	call C18Rbyte		; -> W
	movwf ROMTmpL
	movlw b'00001001'		; TBLRD *+ post increment - Odd Address - High Byte
	call C18Rbyte		; -> W
	movwf ROMTmpH
	goto Verfd18

NotVf18C	call ReadROM		; -> ROMTmpH/L
Verfd18	call Delay100

	btfsc Flag2,Blank		; blank test = 1
	goto TstBRval

	clrf PCLATH
	call EEreadBC
	movwf Data1H
	call EEreadBC
	movwf Data1L
	ThisPage

TstBRval	movf Data1H,W
	xorwf ROMTmpH,W
	btfss STATUS,Z
	goto VFYexit

	movf Data1L,W
	xorwf ROMTmpL,W
	btfss STATUS,Z
	goto VFYexit

	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	btfss Flag2,f8M32
	call IncAddr		; not for 18Cxxx types

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display verifying progress

	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto VerfMoreR

	bsf Flag2,OK		; ROM verified
	goto VFYexit
;
; -------------
; VERIFY EEPROM
; -------------
; EEPROM address map is 4000h - 40FFh = 256 bytes
;
VerfEEP	bcf Flag2,OK		; flag verify error
	clrf ProgAddH
	clrf ProgAddL
	call VccVolts		; turn on Vcc at correct voltage
	btfss Flag2,Blank		; no need to read I2C for blank test
	call SetEEPAdd		; get the eeprom data start address
;
; VERIFY EEPROM PROCEDURE
;
VerfMEER	call ReadEE		; -> W
	call Delay100

	btfsc Flag2,Blank		; value = FF for blank test
	goto CmpBEval

	clrf PCLATH
	call EEreadBC
	movwf Data1L
	ThisPage

CmpBEval	movf ROMTmpL,W
	xorwf Data1L,W
	btfss STATUS,Z
	goto VFYexit

	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	call IncAddr

	movf EEsizeL,W
	andlw b'00001111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf EEsizeH,W		; test if end of eeprom data
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto VerfMEER

	movf EEsizeL,W
	xorwf ProgAddL,W
	btfss STATUS,Z
	goto VerfMEER

	bsf Flag2,OK		; EEPROM verified
VFYexit	call VoltsOFF
	clrf PCLATH
	call ClearScr
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	ThisPage
	return
;
; ------------------
; VERIFY THE ID/FUSE
; ------------------
;
VerfFuses	btfss Flag2,f8M32
	goto Not18Fz

	call Verf18F		; OK flag set and error code in W	
	return

Not18Fz	call VccVolts		; turn on Vcc at correct voltage
	call ReadFuse		; stores ID and Fuse data in fuse registers
	call VoltsOFF
;
; VERIFY ID LOCS
;
VerfFZBk	movlw Low(IDloc1H)
	movwf FSR
	bsf STATUS,IRP
	call IDFcomp		; compare ID byte value H
	btfss Flag2,OK
	goto IdERR

	call IDFcomp		; compare ID byte value L
	btfsc Flag2,OK
	goto VfzLcs
;
; ID verify error
;
IdERR	movlw 61h			; ID error
	btfsc Flag2,Blank
	movlw 60h			; ID not blank
	goto ExVFz
;
; VERIFY FUSE LOCS
;
VfzLcs	incf FSR			; skip past IDLOC2 H L
	incf FSR

	call IDFcomp		; compare Fuse byte value H
	btfsc Flag2,OK
	call IDFcomp		; compare Fuse byte value L

	movlw 20h			; fuse error
	btfsc Flag2,Blank
	movlw 2Eh			; fuse not blank

ExVFz	bcf STATUS,IRP
	return			; verify error
;
; --------------------------
; BLANK TEST OR ERASE A CHIP
; --------------------------
;
BlankMode	btfsc Flag3,Etype		; = 1 if eeprom type chip
	goto EraseCh		; yes, blank test or bulk erase it
;
; DO BLANK TEST
;
BlankTst	call SetPins

	btfsc Flag2,OK
	goto InBlank

	clrf PCLATH
	goto TopMenu		; blank test aborted

InBlank	clrf PCLATH
	movlw 9Fh			; blank testing
	call MessProc1
	ThisPage
;
; DO 18CXXX IF SELECTED
;
	btfss Flag2,f8M32
	goto NotBk18C

	call C18Blank		; message result in Temp5
	movf Temp5,W
	goto ExorDis
;
; BLANK TEST VALUES
;
NotBk18C	bsf Flag2,Blank		; verifying with blank values
	movlw 0x3F
	movwf Data1H
	movlw 0xFF
	movwf Data1L

	call VerfROM
	movlw 2Ch			; ROM not blank
	btfss Flag2,OK
	goto ExitBProc
;
; BLANK TEST EEPROM IF IS EEPROM TYPE
;
	btfss Flag3,Etype		; = 1 if eeprom type chip
	goto DoBlkFuse		; no eeprom data

	clrf PCLATH
	movlw 9Fh			; blank testing
	call MessProc1
	ThisPage

	call VerfEEP
	movlw 2Dh			; eeprom not blank
	btfss Flag2,OK
	goto ExitBProc
;
; BLANK TEST ID AND FUSES
;
DoBlkFuse	movlw Low(TIDloc1H)		; temp data storage - fill with blank value
	movwf FSR
	bsf STATUS,IRP
;
; FILL ALL TEST FUSE DATA WITH 0xFF
;
	movlw d'12'		; 6 words
	movwf Temp4
BnkDat	movlw 0xFF		; IDs and Fuse blank = FFFF FFFF
	movwf INDF
	incf FSR
	decfsz Temp4
	goto BnkDat
	bcf STATUS,IRP
;
; USE MASK FUSE VALUES
;
	bsf STATUS,RP1		; RAMP Page 2
	movf Fuse1ANDH,W
	movwf TFuse1H
	movf Fuse1ANDL,W
	movwf TFuse1L
	bcf STATUS,RP1		; RAMP Page 0

	call VerfFuses

	btfsc Flag2,OK
	movlw 2Fh			; blank verify ok

ExitBProc	movwf Temp4
	bcf Flag2,Blank
	
	movf Temp4,W		; error message number
ExorDis	btfsc Flag3,PrBlnk		; blank testing before programming if = 1
	return			; return to programming mode
	
Rslt18Bk	clrf PCLATH
	call MessProc1		; routine message result - data in Temp4
	movlw 12h
	call MessProc2		; Press any key
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto TopMenu
;
; --------------------
; BULK ERASE CHIP MENU
; --------------------
;
EraseCh	clrf PCLATH
	movlw 0Bh			; verify
	call MessProc1
	movlw 46h			; Erase chip
	call MessProc2
	call HighLiteA		; put '<' on screen

BMloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto BMloop
	goto BMKey1
	goto BMKey2
	goto BMKey3
	goto BMKey2
;
; BLANK KEY 1
;
BMKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto BMloop
;
; BLANK KEY 2
;
BMKey2	clrf PCLATH		; exit blank
	goto TopMenu
;
; VERIFY KEY 3
;
BMKey3	btfss Flag2,FLayer
	goto BlankTst

	call SetPins

	btfsc Flag2,OK
	goto StrtbKTT

	clrf PCLATH
	goto TopMenu		; aborted

StrtbKTT	call BulkErase		; bulk erase eeprom type chip
	clrf PCLATH
	movlw 47h			; erase complete
	call MessProc1
	movlw 12h
	call MessProc2		; Press any key
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto TopMenu
;
; ----------------------
; BULK ERASE EEPROM CHIP
; ----------------------
;
BulkErase	clrf PCLATH
	movlw 37h
	call MessProc1		; erasing
	ThisPage			; >>> follow on to BulkECode - returns from there
;
; ---------------
; BULK ERASE CODE
; ---------------
;
BulkECode	movlw 5h			; do bulk erase 5 times
          movwf NibA		; to make sure all is erased

EallLoop  call VoltsON5

	movlw b'00000000'		; Load Configuration Command
          call Command		; send it
	movlw 0x3F
	movwf Data1H
	movlw 0xFF
	movwf Data1L
	call Send16		; send 16 bits to PIC

; Increment Address 7 times so that PC points to Configuration word

          movlw 7h
          movwf Temp1

FAddEx    call IncAddr
          decfsz Temp1
          goto FAddEx

; EXECUTE CODE PROTECT ERASE PROCEDURE

          movlw b'00000001'
          call Command
          call Delay100

          movlw b'00000111'
          call Command
          call Delay100

          movlw b'00001000'
          call Command

          call Dl12Pg1
          call Dl12Pg1

          movlw b'00000001'
          call Command
          call Delay100

          movlw b'00000111'
          call Command
          call Dl12Pg1

	call VoltsOFF

          decfsz NibA		; do routine 5 times
          goto EallLoop

; ERASE DATA EEPROM

	call VoltsON5

          clrf ProgAddH
          clrf ProgAddL

ereepm    movlw 0xFF
          movwf Data1L
          call ErEeprom		; write the data
          call IncAddr		; increment the PIC address

	incf ProgAddL
	btfsc STATUS,Z
	incf ProgAddH

          movf ProgAddH,W
          xorwf EEsizeH,W
          btfss STATUS,Z
          goto ereepm		; not all done yet

          movf ProgAddL,W
          xorwf EEsizeL,W
          btfss STATUS,Z
          goto ereepm		; not all done yet

          call VoltsOFF
	return
;
; ---------------------------------------
; SUBROUTINE TO WRITE DATA TO DATA EEPROM
; ---------------------------------------
;
WrEeprom  bcf Flag2,OK
	movf Data1L,W
          xorlw 0xFF
          btfsc STATUS,Z
          return			; don't program FF

ErEeprom	movlw 0x3F
          movwf Data1H
          movlw b'00000011'		; Load Data for Data Memory Command
          call Command		; send it

	call Send16		; send 16 bits to PIC

; Data is clocked into PIC, so begin programming pulse.

          movlw b'00001000'		; Begin Programming command
          call Command		; send it

          call Dl12Pg1		; wait 12mS
	bsf Flag2,OK		; wasn't blank
          return
;
; --------------
; PROGRAM A CHIP
; --------------
;
ProgMode	clrf PCLATH
	call ListFiles
	ThisPage
	btfss Flag2,OK
	goto ExitPchp		; aborted
;
; CHECK ROM/EEP SIZE AGAINST FILE DATA
;
	call CheckSize
	btfss Flag2,OK
	goto ExitPchp

	btfss Flag2,FuseYN
	goto NoWarn

	clrf PCLATH
	movlw 35h
	call MessProc1		; CODE PROTECT WARNING
	movlw 36h
	call MessProc2		; continue? 

	call AnyKey		; OK flag = 1 if Key 1 pressed
	btfss Flag2,OK
	goto TopMenu		; aborted

	ThisPage
NoWarn	call SetPins		; socket pins message
	btfsc Flag2,OK
	goto StrtProg

ExitPchp	clrf PCLATH
	goto TopMenu		; aborted
;
; BULK ERASE EEPROM TYPE CHIP OR DO A BLANK TEST FOR NON EEPROM TYPES
;
StrtProg	btfss Flag3,Etype
	goto ROMtype

	call BulkErase		; bulk erase eeprom type chip
	goto ContProg

ROMtype	bsf Flag3,PrBlnk		; causes blank test code to return here
	call InBlank		; check for blank chip
	bcf Flag3,PrBlnk

	btfsc Flag2,OK		; 0 = not blank, 1 = blank
	goto ContProg
;
; CHIP IS NOT BLANK - BLANK ERROR MESSAGE NUMBER IN W REG
;
NonBlank	clrf PCLATH
	call MessProc1
	movlw 36h
	call MessProc2		; K1 = continue
	call AnyKey		; OK flag = 1 if Key 1 pressed
	btfss Flag2,OK
	goto TopMenu		; aborted
;
; BEGIN THE PROGRAMMING
;
ContProg	clrf PCLATH
	movlw 31h
	call MessProc1		; Program ROM	

	movlw E_ROMStart		; data start address
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
	ThisPage

	clrf ProgAddH
	clrf ProgAddL
;
; PROGRAM ROM PROCEDURE
;
	call VoltsON5		; turn on VCCP and VPPx
;
; JUMP TO 16cXXX TYPE OR 18cXXX TYPE ????
;
	btfsc Flag2,f8M32
	goto ProgMr18

ProgMoreR	clrf PCLATH
	call EEreadBC
	movwf Data1H
	call EEreadBC
	movwf Data1L
	ThisPage

	call IProgNLoc		; program the location
	btfss Flag2,OK		; OK = 0 = error
	goto ProgError

	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	call IncAddr

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto ProgMoreR

	call VoltsOFF
	call ClearScr
	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	ThisPage
;
; PROGRAM EEPROM IF IS EEPROM TYPE
;
	btfss Flag3,Etype		; EEPROM type of chip = 1
	goto VerifPrg		; verify just programmed ROM

	clrf PCLATH
	movlw 32h
	call MessProc1		; Program EEPROM
	ThisPage

	clrf ProgAddH
	clrf ProgAddL

	call SetEEPAdd		; get the eeprom data start address
;
; PROGRAM EEPROM PROCEDURE
;
	call VoltsON5		; turn on VCCP and VPPx

pEEPMoreR	clrf PCLATH
	call EEreadBC
	movwf Data1L
	ThisPage

	call WrEeprom		; write the data
	btfss Flag2,OK		; wasn't blank
	goto IzBlnkEE

	call ReadEE		; read it back -> W
	xorwf Data1L,W
	btfsc STATUS,Z
	goto IzBlnkEE

	movlw 19h			; eeprom error
	goto ProgError		; verify error

IzBlnkEE	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	call IncAddr

	movf EEsizeL,W
	andlw b'00001111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf EEsizeH,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto pEEPMoreR

	movf EEsizeL,W
	xorwf ProgAddL,W
	btfss STATUS,Z
	goto pEEPMoreR

	call VoltsOFF
	clrf PCLATH
	call ClearScr
	call EEread_N		; EEPROM read & stop without ACK - ignore data
;
; IF MULTY V - VERIFY ROM BEFORE PROGRAMMING FUSE
; IF ERROR IS FOUND, IT EXITS BACK TO MAIN LOOP AFTER ERROR MESSAGE
;
VerifPrg	clrf PCLATH
	movlw VFAddress
	call IEread		; get multy V flag
	movwf Temp1
	ThisPage
	movf Temp1,W
	btfss STATUS,Z
	goto Pverify		; is multy V mode - multiV verify ROM
;
; IF CODE/EEP VERIFIES OK, IT RETURNS HERE - NOW PROGRAM ID
;
BackProg	call IDFuseRAM		; transfer ID and Fuse data to RAM
	call Dl12Pg1
	call VoltsON5		; turn on VCCP and VPPx

	btfsc Flag2,f8M32
	goto P18ID		; 18Cxxx ID and Fuses

	call LoadCfig		; Load Configuration Command
	call ProgID
	btfss Flag2,OK
	goto ProgError
;
; NOW PROGRAM FUSE
;
	call IncAddr		; increment to 2007h
	call IncAddr
	call IncAddr

	bsf STATUS,RP1		; RAM Page 2
	movf TFuse1H,W
	bcf STATUS,RP1		; RAM Page 0
	movwf Data1H
	bsf STATUS,RP1		; RAM Page 2
	movf TFuse1L,W
	bcf STATUS,RP1		; RAM Page 0
	movwf Data1L

	movlw 1h
	btfss Flag3,Etype    	; (7) test if ROM or EEPROM type
          movlw d'100'
          movwf Temp1

FuseProgI	call ProgLoc
          decfsz Temp1
          goto FuseProgI
;
; VERIFY ID/FUSE DATA
;
	call ReadROM

	call VoltsOFF

	movf ROMTmpH,W
	xorwf Data1H,W
	btfss STATUS,Z
	goto FZerror

	movf ROMTmpH,W
	xorwf Data1H,W
	btfsc STATUS,Z
	goto FZMVtst

FZerror	movlw 20h			; fuse error
	goto ProgError

FZMVtst	bcf Flag2,MVdo		; 1st loop
	btfss Flag1,MVee		; done if no multy v
	goto ProgFins

	movlw 18h			; small delay for fuse display
	movwf Temp1
delfzlp	call Dl12Pg1
	decfsz Temp1
	goto delfzlp
;
; MULTY V VERIFY FUSE
;
	bsf Flag3,NoVolt		; stops voltage from being displayed

MVfuse	call VerfFuses	
	btfss Flag2,OK
	goto ProgError

	btfsc Flag2,MVdo		; 1st/2nd loop
	goto ProgFins

	bsf Flag2,MVdo
	goto MVfuse		; do upper V verify now

ProgFins	movlw 33h			; program complete
ProgError movwf Temp4
	bcf STATUS,IRP
	call VoltsOFF
	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	movf Temp4,W
	call MessProc1
	movlw 12h
	call MessProc2		; Press any key
	bcf Flag3,NoVolt
	call AnyKey		; OK flag = 1 if Key 1 pressed
	goto TopMenu
;
; ---------------
; PROGRAM ID LOCS
; ---------------
; Address is at 2000 - 1st ID loc (16cXXX)
;
ProgID	bsf STATUS,RP1		; RAM Page 2
	movf TIDloc1H,W
	bcf STATUS,RP1		; RAM Page 0
	movwf Data2H
	bsf STATUS,RP1		; RAM Page 2
	movf TIDloc1L,W
	bcf STATUS,RP1		; RAM Page 0
	movwf Data2L
MprogID	clrf Data1H		; Hi Word always = 0

	swapf Data2H,W
	call doID			; 2000
	btfss Flag2,OK
	retlw 61h			; ID error

	movf Data2H,W
	call doID			; 2001
	btfss Flag2,OK
	retlw 61h			; ID error

	swapf Data2L,W
	call doID			; 2002
	btfss Flag2,OK
	retlw 61h			; ID error

	movf Data2L,W
	call doID			; 2003
	btfss Flag2,OK
	retlw 61h			; ID error
	return
;
; PROGRAM THE ID LOC
;
doID	andlw 0Fh			; mask upper nibble
	movwf Data1L
	call IProgNLoc
	call IncAddr
	return
;
; -------------------------
; INTERNAL PROGRAMMING CODE
; -------------------------
; on return W = 0 = OK, W = 1 = Fail
;
; PROGRAM ROM DATA if not blank data (3FFF)
;
IProgNLoc	clrf ProCycs		; reset programming cycles counter
	bsf Flag2,OK		; preset programmed ok
	movf Data1H,W
          xorlw 3Fh
          btfss STATUS,Z
          goto DoProgI

	movf Data1L,W
          xorlw 0xFF
          btfsc STATUS,Z
	return

DoProgI	call ProgLoc		; program new data
          incf ProCycs		; increment programming count
;
; NOW VERIFY IT
;          
          call ReadROM		; read back data

          movf ROMTmpH,W		; set during ReadROM
          xorwf Data1H,W
          btfss STATUS,Z     
          goto NoVerifyI

          movf ROMTmpL,W		; set during ReadROM          
          xorwf Data1L,W
          btfsc STATUS,Z
          goto IsVerifyI

NoVerifyI	btfsc Flag3,Etype		; (7) test if ROM or EEPROM type
	goto NotProg

          movlw d'25'
          xorwf ProCycs,W
          btfss STATUS,Z
          goto DoProgI		; program location again

NotProg	bcf Flag2,OK		; program error
	return
;
; DO 3 TIMES OVER PROGRAMMING
;
IsVerifyI	btfsc Flag3,Etype		; (7) test if ROM or EEPROM type
          return			; EEPROM - done
                              
          movf ProCycs,W
          bcf STATUS,C
          rlf ProCycs
          addwf ProCycs

ProgVerfI	call ProgLoc		; program new data
          decfsz ProCycs
          goto ProgVerfI		; continue
	return
;
; ----------------------
; PROGRAM A ROM LOCATION
; ----------------------
; Command for Load Data                 = 000010
; Command for Begin Programming         = 001000
; Command for End Programming           = 001110
;
ProgLoc	movlw b'00000010'		; Load Data command
          call Command		; send it
	call Send16		; send 16 bits to PIC

; Data is clocked into PIC, so begin programming pulse.

          movlw b'00001000'		; Begin Programming command
          call Command		; send it

	btfsc Flag3,Etype		; (7) test if ROM or EEPROM type
          goto isEEPROMI		; EEPROM

	call Delay100		; Wait 100uS to program location

          movlw b'00001110'		; End Programming command
          call Command		; send it
          return			; Done

; PROGRAMMING EEPROM - Wait 5 or 12mS

isEEPROMI	movlw 8h			; short EEPROM programming delay
	btfsc Flag2,TimeLS
	movlw 0Fh			; long EEPROM programming delay
	movwf DelayH
	clrf DelayL
DelEaI    decfsz DelayL
          goto DelEaI
          decfsz DelayH
          goto DelEaI
          return
;
; ---------------------
; INTERNAL OR ICSP MODE
; ---------------------
;
ICSPMode	clrf PCLATH
	movlw 49h			; Internal
	call MessProc1
	movlw 4Ah			; ICSP
	call MessProc2

	bcf Flag2,FLayer
	clrf PCLATH
	movlw ProMode
	call IEread
	xorlw 0xAA
	btfsc STATUS,Z
	bsf Flag2,FLayer
	call HighLiteB		; put '<' on screen

ICloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto ICloop
	goto ICKey1
	goto ExitPrMd
	goto ICKey3
	goto ExitPrMd
;
; ICSP KEY 1
;
ICKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto ICloop
;
; ICSP KEY 3
;
ICKey3	bsf STATUS,RP1		; RAM Page 2
	movlw ProMode
	movwf EEADR
	bcf STATUS,RP1		; RAM Page 0
	clrf PCLATH
	clrw			; ICSP = Internal
	btfsc Flag2,FLayer
	movlw 0xAA		; ICSP = External
	call IEwrite

ExitPrMd	clrf PCLATH
	call KeyReles
	goto TopMenu
;
; -----------------
; PIC18Cxxx PROGRAM
; -----------------
;
; GET THE DATA FOR PROGRAMMING
;
ProgMr18	clrf PCLATH
	call EEreadBC
	movwf Data1H
	call EEreadBC
	movwf Data1L
	ThisPage
	call Do18CProg		; program the current location

	btfss Flag2,OK
	goto Prog18ER		; 18Cxxx PROGRAM ERROR
;
; GET NEXT DATA
;
	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto ProgMr18
;
; FINISH LAST WRITE CYCLE
;
	bsf Flag1,Wdel		; wait 100uS on last clock pulse H
	movlw b'00001000'		; TBLRD * Dummy read
	call C18Rbyte		; -> W

	clrf PCLATH
	call ClearScr
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	ThisPage
	call VoltsOFF
;
; DO MULTIV VERIFY IF SET
;
	bcf Flag1,MVee		; no multy V mode
	clrf PCLATH
	movlw VFAddress
	call IEread		; get multy V flag
	movwf Temp5
	ThisPage
	movf Temp5,W
	xorlw 0h
	btfsc STATUS,Z
	goto P18ID

	bcf Flag2,MVdo		; doing 1st verify loop
	bsf Flag1,MVee		; is multy V mode

MV18romv	clrf PCLATH
	movlw 26h			; Verifying ROM
	call MessProc1

	ThisPage
	call VerfROM

	btfss Flag2,OK
	goto Prog18ER		; verify error

	btfsc Flag2,MVdo		; 1st/2nd loop
	goto P18ID		; 2nd

	bsf Flag2,MVdo
	goto MV18romv		; do upper V verify now
;
; -----------------
; PROGRAM 18CXXX ID
; -----------------
;
P18ID	call IDFuseRAM		; transfer ID and Fuse data to RAM
	call Dl12Pg1
	call VoltsON5		; turn on VCCP and VPPx
	call SetIDadd		; TBLPTR = 200000h

	movlw Low(TIDloc2L)
	movwf FSR
	bsf STATUS,IRP

	movlw 4h
	movwf CCount		; 4 words

NextID2	movf INDF,W		; ID data L byte
	iorlw 0xF0		; make sure upper nibble = 1111
	movwf Data1L

	swapf INDF,W		; ID data H Byte
	iorlw 0xF0		; make sure upper nibble = 1111
	movwf Data1H
	decf FSR

	call Do18CProg		; program the current location
	btfss Flag2,OK
	goto IDerr18

	decfsz CCount
	goto NextID2
;
; -------------------
; PROGRAM 18CXXX FUSE
; -------------------
;
	call SetFZadd		; TBLPTR = 300000h
	movlw Low(TFuse1H)
	movwf FSR
	movlw 4h
	movwf CCount		; 4 fuse words

DoC18Fz	movlw d'99'
	movwf ProCycs
;
; GET NEXT FUSE DATA
;
	movf INDF,W		; Fuse data H byte
	movwf Data1H
	incf FSR
	movf INDF,W		; Fuse data L Byte
	movwf Data1L
	incf FSR

ExtraFuse	movlw b'00001100'		; TBLWT *
	call BitOut4
	movf Data1L,W		; low byte
	call BitOut8
	movf Data1H,W		; high byte
	call BitOut8
	bsf Flag4,Wdel		; wait 100uS on last clock pulse H

	decfsz ProCycs		; program count - 1
	goto ExtraFuse

	movlw b'00001001'		; TBLRD *+   Read L address
	call C18Rbyte		; -> W
	xorwf Data1L,W
	btfss STATUS,Z
	goto FuseBad		; did not verify

	movlw b'00001001'		; TBLRD *+   Read H address
	call C18Rbyte		; -> W
	xorwf Data1H,W
	btfss STATUS,Z
	goto FuseBad		; did not verify

TFZ	decfsz CCount
	goto DoC18Fz		; do next config
;
; MULTIV VERIFY ID AND FUSE IF SET
;
	call VoltsOFF
	clrf PCLATH
	call ClearScr
	ThisPage
	btfss Flag1,MVee		; is multy V mode ?
	goto ProgFins		; no

	bcf Flag2,MVdo

MV18fuse	call Verf18F		; OK flag set and error code in W
	btfss Flag2,OK
	goto ProgError		; verify error

	btfsc Flag2,MVdo		; 1st/2nd loop
	goto ProgFins		; 2nd

	bsf Flag2,MVdo
	goto MV18fuse		; do upper V verify now
;
; FUSE ERROR
;
FuseBad	movlw 20h			; fuse error
	goto ProgError
;
; ID ERROR
;
IDerr18	movlw 61h			; ID error
	goto ProgError
;
; ROM OR MULTIV ROM ERROR
;
Prog18ER	movlw 29h			; ROM error
	goto ProgError
;
; ----------------------------------
; 18Cxxx PROGRAM THE CURRENT ADDRESS
; ----------------------------------
;
Do18CProg	clrf ProCycs
	bsf Flag2,OK		; preset programmed ok

ExtraProg	movlw b'00001111'		; TBLWT +*
	call BitOut4
	movf Data1L,W		; low byte
	call BitOut8
	movf Data1H,W		; high byte
	call BitOut8
	incf ProCycs		; programed count + 1

	bsf Flag4,Wdel		; wait 100uS on last clock pulse H
	movlw b'00001010'		; TBLRD *-   Read H address
	call C18Rbyte		; -> W
	movwf Temp5
	movlw b'00001000'		; TBLRD *    Read L address
	call C18Rbyte		; -> W
	xorwf Data1L,W
	btfss STATUS,Z
	goto MoreProg		; did not verify

	movf Temp5,W
	xorwf Data1H,W
	btfss STATUS,Z
	goto MoreProg		; did not verify
	
	bcf STATUS,C		; 3 X overprogramming
	rlf ProCycs,W
	addwf ProCycs
	decf ProCycs		; last cycle does TBLWT *+

	movlw b'00001101'		; TBLWT *+
	goto InOver
;
; Do OverProgramming pulses - 1
;
OverPg	bsf Flag4,Wdel		; wait 100uS on last clock pulse H
	movlw b'00001100'		; TBLWT *
InOver	call BitOut4
	movf Data1L,W
	call BitOut8
	movf Data1H,W
	call BitOut8	
	decfsz ProCycs
	goto OverPg
;
; Do Last OverProgramming Pulse
;
	bsf Flag4,Wdel		; wait 100uS on last clock pulse H
	movlw b'00001101'		; TBLWT *+
	call BitOut4		; last overprogramming pulse
	movf Data1L,W
	call BitOut8
	movf Data1H,W
	call BitOut8	

	bsf Flag4,Wdel		; wait 100uS on last clock pulse H (next instruction)
	return

MoreProg	movlw d'25'
	xorwf ProCycs,W
	btfss STATUS,Z
	goto ExtraProg		; program again

	bcf Flag2,OK		; programming error
	return
;
; -----------------------------
; PIC18CXXX VERIFY ID AND FUSES
; -----------------------------
;
Verf18F	call VccVolts		; turn on Vcc at correct voltage
	call C18IDrd		; read ID -> ID regs
	call C18FZrd		; read Fuses -> fuse regs
	call VoltsOFF
;
; DATA IS ALREADY IN TEMP ID AND FUSE REGS - COMPARE THEM
;
	movlw Low(IDloc1H)
	movwf FSR
	bsf STATUS,IRP

	call IDFcomp		; compare ID1 byte value H
	btfss Flag2,OK
	goto ID18Err

	call IDFcomp		; compare ID1 byte value L
	btfss Flag2,OK
	goto ID18Err

	call IDFcomp		; compare ID2 byte value H
	btfss Flag2,OK
	goto ID18Err

	call IDFcomp		; compare ID2 byte value L
	btfss Flag2,OK
	goto ID18Err
;
; FUSES
;	
	call IDFcomp		; compare Fuse1 byte value H
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse1 byte value L
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse2 byte value H
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse2 byte value L
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse3 byte value H
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse3 byte value L
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse4 byte value H
	btfss Flag2,OK
	goto FZ18Err

	call IDFcomp		; compare Fuse4 byte value L
	btfss Flag2,OK
	goto FZ18Err

	bcf STATUS,IRP
	bsf Flag2,OK		; Verified
	return		

ID18Err	bcf STATUS,IRP
	bcf Flag2,OK
	retlw 61h			; ID error

FZ18Err	bcf STATUS,IRP
	bcf Flag2,OK
	retlw 20h			; fuse error
;
; --------------
; PIC18Cxxx READ
; --------------
;
; READ THE ROM DATA TO EEPROM (B or C)
;
Rd18ROM	movlw b'00001001'		; TBLRD *+ post increment - Even Address - Low Byte
	call C18Rbyte		; -> W
	movwf ROMTmpL		; low byte
	movlw b'00001001'		; TBLRD *+ post increment - Odd Address - High Byte
	call C18Rbyte		; -> W
	clrf PCLATH
	call EEwriteBC		; save Hi
	movf ROMTmpL,W
	call EEwriteBC		; save Lo
	ThisPage

	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto Rd18ROM
;
; SET EEPROM START ADDRESS
;
	movf CodeAddL,W
	movwf EEPaddL
	movf CodeAddH,W
	movwf EEPaddH

	clrf PCLATH
	call EEstop
	ThisPage

	call C18IDrd		; read ID
	call C18FZrd		; read Fuses
	return
;
; -----------------
; PIC18Cxxx ID READ
; -----------------
;
C18IDrd	call SetIDadd		; TBLPTR = 200000h

	movlw Low(IDloc2L)
	movwf FSR
	movlw 4h
	movwf ICount
	bsf STATUS,IRP

I2C18IR	movlw b'00001001'		; TBLRD *+ post increment 20000x x = even
	call C18Rbyte		; -> W
	andlw 0Fh
	movwf INDF
	movlw b'00001001'		; TBLRD *+ post increment 20000x x = odd
	call C18Rbyte		; -> W
	movwf Temp5
	swapf Temp5,W
	andlw 0xF0
	iorwf INDF
	decf FSR
	decfsz ICount
	goto I2C18IR

	bcf STATUS,IRP
	return
;
; -----------------
; PIC18Cxxx FUSE READ
; -----------------
;
C18FZrd	call SetFZadd		; TBLPTR = 300000h
	movlw 4h			; 4 words
	movwf ICount
	movlw Low(Fuse1L)
	movwf FSR
	bsf STATUS,IRP

InC18FR	movlw b'00001001'		; TBLRD *+ post increment - Even Address - L Byte
	call C18Rbyte		; -> W
	movwf INDF
	decf FSR

	movlw b'00001001'		; TBLRD *+ post increment - Odd Address - H Byte
	call C18Rbyte		; -> W
	movwf INDF
	movlw 3h
	addwf FSR

	decfsz ICount
	goto InC18FR

	bcf STATUS,IRP
	return
;
; ---------------
; PIC18Cxxx BLANK
; ---------------
; OK flag = 1 if blank, = 0 if non blank
; Message number returned in Temp5
;
C18Blank	bsf Flag2,OK		; preset is blank result
	clrf ProgAddH
	clrf ProgAddL
	call VoltsON5		; turn on VCCP and VPPx

BlLoop	movlw b'00001001'		; TBLRD *+ post increment - Even Address - Low Byte
	call C18Rbyte		; -> W
	xorlw 0xFF
	btfss STATUS,Z
	goto C18RmNtB		; ROM not blank

	movlw b'00001001'		; TBLRD *+ post increment - Odd Address - High Byte
	call C18Rbyte		; -> W
	xorlw 0xFF
	btfss STATUS,Z
	goto C18RmNtB		; ROM not blank

	incf ProgAddL
	btfsc STATUS,Z
	incf ProgAddH

	movf ProgAddL,W
	andlw b'00011111'
	btfsc STATUS,Z
	call DispProg		; display programming progress

NoDUdt	movf ProgAddH,W
	xorwf HiROMAdd,W
	btfss STATUS,Z
	goto BlLoop
;
; BLANK TEST ID
;
	call SetIDadd		; TBLPTR = 200000h

	movlw 8h			; 8 ID bytes to check
	movwf ICount

BKC18id	movlw b'00001001'		; TBLRD *+ post increment
	call C18Rbyte		; -> W
	xorlw 0xFF
	btfss STATUS,Z
	goto C18IdNtB
	
	decfsz ICount
	goto BKC18id
;
; BLANK TEST FUSES
;
	call SetFZadd		; TBLPTR = 300000h
	movlw 4h			; 4 words to test
	movwf ICount
	movlw Low(Fuse1ANDL)
	movwf FSR
	bsf STATUS,IRP		; FSR accesses RAM pages 2 and 3

C18FzBk	movlw b'00001001'		; TBLRD *+ post increment 300000 - 300007
	call C18Rbyte		; -> W
	xorwf INDF,W
	btfss STATUS,Z
	goto C18FzNtB		; fuse data L not blank

	decf FSR
	movlw b'00001001'		; TBLRD *+ post increment 300000 - 300007
	call C18Rbyte		; -> W
	xorwf INDF,W
	btfss STATUS,Z
	goto C18FzNtB		; fuse data H not blank

	movlw 5h			; skip Fuse OR data
	addwf FSR			; point to next fuse AND L value
	decfsz ICount
	goto C18FzBk

	movlw 2Fh			; blank verify ok
	goto NVolts

C18RmNtB	movlw 2Ch			; ROM not blank
          goto C18NoBk

C18IdNtB	movlw 60h			; ID not blank
          goto C18NoBk

C18FzNtB	movlw 2Eh			; fuse not blank
C18NoBk	bcf Flag2,OK		; not blank
NVolts	movwf Temp5		; save non blank message number
	call VoltsOFF
	bcf STATUS,IRP
	return
;
; ------------------------
; OUTPUT 4 BIT INSTRUCTION
; ------------------------
;
BitOut4	movwf EEdata
          bsf PORTB,Clk		; (6) release 18Cxxx pin (could have been reading)
	call ClkDelay
	bcf PORTB,Dat
	call ClkDelay
	bsf PORTC,HiZ		; data out pin = out
	movlw 4h
	movwf BCount

morbts	bcf PORTB,Dat
	rrf EEdata          	; rotate bit into carry
	btfsc STATUS,C
	bsf PORTB,Dat		; (7)
	call ClkDelay

          bsf PORTB,Clk		; (6)
	call ClkDelay2

	btfss Flag4,Wdel		; executing program command
	goto NoProgT		; no

	decfsz BCount,W		; yes, so if = last clock, hold high
	goto NoProgT		; for programming period

	call Delay100		; programming time
	bcf Flag4,Wdel

NoProgT	bcf PORTB,Clk		; (6) clock bit in
	call ClkDelay

	decfsz BCount
	goto morbts         	; continue until 4 bits sent

	bcf PORTB,Dat		; (7)
          call ClkDelay
	return              	; finished
;
; -----------------
; OUTPUT 8 BIT DATA
; -----------------
;
BitOut8	movwf EEdata
	movlw 8h
	movwf BCount

morbt8	bcf PORTB,Dat
	rrf EEdata          	; rotate bit into carry
	btfsc STATUS,C
	bsf PORTB,Dat		; (7)
	call ClkDelay

          bsf PORTB,Clk		; (6)
	call ClkDelay2

	bcf PORTB,Clk		; (6) clock bit in
	call ClkDelay

	decfsz BCount
	goto morbt8         	; continue until 8 bits sent

	bcf PORTB,Dat
          call ClkDelay
	return              	; finished
;
; -------------------------
; READ A BYTE FROM C18 CHIP
; -------------------------
;
C18Rbyte	call BitOut4
	movlw 0h			; Execute Cycle 1 & 2 TBLRD
	call BitOut8

	bcf PORTC,HiZ		; data out pin = HiZ
	movlw 8h			; read the data
	movwf BCount
RbyteLP	bsf PORTB,Clk
	call ClkDelay2
	bcf PORTB,Clk
	call ClkDelay2

          bcf STATUS,C		; set carry bit = incoming data bit
          btfss PORTB,DataR		; (4) read data bit = inverted
          bsf STATUS,C
	rrf EEdata

	decfsz BCount
	goto RbyteLP

	movf EEdata,W
	return
;
; -------------------------
; SET TBLPTR AT CONFIG LOCS
; -------------------------
;
SetFZadd	movlw 30h			; set for fuses
	goto InADDs
SetIDadd	movlw 20h			; set for IDs
InADDs	movwf TBLPTRU
	clrf TBLPTRH
	clrf TBLPTRL
	call SetADD
	return
;
; ------------------------------
; RESET TBLPTR ADDRESS = 000000h
; ------------------------------
;
ResetAdd	movlw 0h
	movwf TBLPTRL
	movwf TBLPTRH
	movwf TBLPTRU
	call SetADD
	return
;
; -----------------------------
; SET AN ADDRESS INTO PIC18CXXX
; -----------------------------
; nop
; movlw xxh
; nop
; movwf TBLPTRL
; nop
; movlw xxh
; nop
; movwf TBLPTRH
; nop
; movlw xxh
; nop
; movwf TBLPTRU
;
; Dummy read
;
SetADD	movlw b'00000000'		; NOP - execute previous if any
	call BitOut4
	movf TBLPTRL,W
	call BitOut8
	movlw b'00001110'		; MOVLW
	call BitOut8

	movlw b'00000000'		; NOP - execute previous
	call BitOut4
	movlw 0xF6		; TBLPTRL = 0xF6
	call BitOut8
	movlw b'01101110'		; MOVWF a = 0, access banking
	call BitOut8

	movlw b'00000000'		; NOP - execute previous if any
	call BitOut4
	movf TBLPTRH,W
	call BitOut8
	movlw b'00001110'		; MOVLW
	call BitOut8

	movlw b'00000000'		; NOP - execute previous
	call BitOut4
	movlw 0xF7		; TBLPTRH = 0xF7
	call BitOut8
	movlw b'01101110'		; MOVWF a = 0, access banking
	call BitOut8

	movlw b'00000000'		; NOP - execute previous if any
	call BitOut4
	movf TBLPTRU,W
	call BitOut8
	movlw b'00001110'		; MOVLW
	call BitOut8

	movlw b'00000000'		; NOP - execute previous
	call BitOut4
	movlw 0xF8		; TBLPTRU = 0xF8
	call BitOut8
	movlw b'01101110'		; MOVWF a = 0, access banking
	call BitOut8
;
; DUMMY READ TO EXECUTE LAST MOVWF INSTRUCTION
;
	movlw b'00001000'		; TBLRD * no increment
	call C18Rbyte		; -> W
	return
;
; --------------------------------------
; SMALL DELAY FOR CLOCKING DATA INTO PIC
; --------------------------------------
;
ClkDelay2	goto $ + 1
	goto $ + 1
	goto $ + 1
          return

TXr	movwf TXREG
	clrf PCLATH
	call TransWt
	ThisPage
	return

; **********************************

	ORG 1000H

; **********************************

;
; ROM AND EEPROM SIZES FOR 16FXXX FLASH CHIPS
;
BtROMsize	movwf Temp2
	ThisPage
	movf Temp2,W
	addwf PCL
	retlw 8h			; 870 2K = 0800h
	retlw 8h			; 871 2K = 0800h
	retlw 8h			; 872 2K = 0800h
	retlw 10h			; 873 4K = 1000h
	retlw 10h			; 874 4K = 1000h
	retlw 20h			; 876 8K = 2000h
	retlw 20h			; 877 8K = 2000h

BtEEPsize	movwf Temp2
	ThisPage
	movf Temp2,W
	addwf PCL
	retlw 0h			; 870
	retlw 40h			;     64 bytes
	retlw 0h			; 871
	retlw 40h			;     64 bytes
	retlw 0h			; 872
	retlw 40h			;     64 bytes
	retlw 0h			; 873
	retlw 80h			;     128 bytes
	retlw 0h			; 874
	retlw 80h			;     128 bytes
	retlw 1h			; 876
	retlw 0h			;     256 bytes
	retlw 1h			; 877
	retlw 0h			;     256 bytes

BtChip	movwf Temp2
	ThisPage
	movf Temp2,W
	addwf PCL
	retlw '0'			; 870
	retlw '1'			; 871
	retlw '2'			; 872
	retlw '3'			; 873
	retlw '4'			; 874
	retlw '6'			; 876
	retlw '7'			; 877
;
; -----------------------------------------
; GET MESSAGE NUMBER FOR THESE INSTRUCTIONS
; -----------------------------------------
;
InsDec	movwf Temp1
	ThisPage
	movlw 2h
	subwf Temp1,W
	addwf PCL
	retlw 86h			; subwf
	retlw 7Ch			; decf
	retlw 80h			; iorwf
	retlw 78h			; andwf
	retlw 88h			; xorwf
	retlw 77h			; andwf
	retlw 81h			; movf
	retlw 7Bh			; comf
	retlw 7Eh			; incf
	retlw 7Dh			; decfsz
	retlw 85h			; rrf
	retlw 84h			; rlf
	retlw 87h			; swapf
	retlw 7Fh			; incfsz
;
; ----------------
; BOOT LOADER MODE
; ----------------
;
BootLoad	movf RCREG,W		; flush receive buffer
	movf RCREG,W
	movf RCREG,W
;
; Ping ROMzap PCB to see if there
;
	clrf PCLATH
	movlw 5Ch			; pinging
	call MessProc1
	ThisPage

	movlw '2'			; inc address (send dummy command)
	movwf TXREG

	call WaitP5S		; wait 1/2 sec

	btfsc PIR1,RCIF
	goto PingOK

	clrf PCLATH
	movlw 57h			; bootloader
	call MessProc1
	movlw 5Ah			; idle
	call MessProc2
	ThisPage

BootLP	btfsc PIR1,RCIF		; (5) check for received data
	goto GotBL

	clrf PCLATH
	call KeyPress
	xorlw 0h
	btfss STATUS,Z
	goto TopMenu		; exit if a key pressed while waiting

	ThisPage
	goto BootLP

GotBL	movf RCREG,W
	xorlw 'B'
	btfss STATUS,Z
	goto BootLP

	clrf PCLATH
	call Receive
	ThisPage

	movf RxHold,W
	xorlw 'L'
	btfss STATUS,Z
	goto BootLP
;
; Boot Loader is online
;
Oline	movwf TXREG		; ACK any char back
PingOK	movf RCREG,W
;
; Send Change address command and FFFF to get back chip type and UART mode
; High nibble
; E = UART, F = Bit Bang
; Low nibble
; 0 = 870, 1 = 871, 2 = 872, 3 = 873, 4 = 874, 5 = 876, 6 = 877
;
	movlw 1h
	movwf TXREG
	clrf PCLATH
	call TransWt
	movlw 0xFF
	movwf TXREG
	call Delay6ms
	movlw 0xFF
	movwf TXREG
	call Receive
	andlw 0Fh			; mask off UART data
	movwf Bchip

	movlw 58h			; online
	call MessProc1
	movlw 5Bh			; display boot chip name
	call MessProc2		; 16f87

	ThisPage
	movf Bchip,W		; 0 - 6
	call BtChip
	clrf PCLATH
	call LCDout
	ThisPage

	movf Bchip,W
	call BtROMsize		; set rom size
	movwf HiROMAdd

	bcf STATUS,C		; set eep size
	rlf Bchip,W
	movwf Temp1
	call BtEEPsize
	movwf EEsizeH
	incf Temp1,W
	call BtEEPsize
	movwf EEsizeL
	call Wait1sec
	
	clrf BMenuItem	
;
; -------------------------------------
; MAIN BOOTLOADER LOOP - NO KEY REPEATS
; -------------------------------------
;
BootTop	call BTDisp
	movlw 2h
	movwf LoopDelay

BTLoop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto BTLoop
	goto BTKey1
	goto BTKey2
	goto BTKey3
	goto BTKey4
;
; Boot Key #1
;
BTKey1	incf BMenuItem		; shift menu items
	movlw 2h
	xorwf BMenuItem,W
	btfsc STATUS,Z
	clrf BMenuItem
	goto BootTop
;
; Boot Key #2
;
BTKey2	clrf PCLATH
	call ChipData		; restore chip info
	goto TopMenu		; exit boot loader
;
; Boot Key #3
;
BTKey3	ThisPage
	movf BMenuItem,W		; select function
	addwf PCL
	goto _ProgROM		; program ROM
	goto _StartU		; start user code
;
; Boot Key #4
;
BTKey4	decf BMenuItem		; shift menu items
	btfss BMenuItem,7
	goto BootTop

	movlw 1h
	movwf BMenuItem
	goto BootTop
;
; -----------------------
; BOOT DISPLAY MENU ITEMS
; -----------------------
;
BTDisp	clrf PCLATH
	movlw 5Dh			; boot function:
          call MessProc1

	movf BMenuItem,W
	xorlw 0h
	movlw 9h			; program
	btfss STATUS,Z
	movlw 5Eh			; run user code
	call MessProc2
	ThisPage
	return
;
; ----------------
; BOOT PROGRAM ROM
; ----------------
;
_ProgROM	clrf PCLATH
	call AreFiles		; any files available ?
	ThisPage
	btfss Flag2,OK
	goto BootTop		; no files

	clrf PCLATH
	call ListFiles
	ThisPage
	btfss Flag2,OK
	goto BootTop		; aborted
;
; -----------------------------------
; SEE IF CHIP AND FILE SIZES ARE SAME
; -----------------------------------
;
	movlw High(CheckSize)
	movwf PCLATH
	call CheckSize
	ThisPage
	btfss Flag2,OK
	goto BootTop
;
; Program/Eep Size = OK
;
BTSZok	clrf PCLATH
	movlw 31h			; programming ROM
	call MessProc1
	movlw E_ROMStart		; data start address
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR

	clrf ProgAddH
	clrf ProgAddL
	bcf Flag3,AddInc
;
; DO THE PROGRAMMING
;
ProgBTR	clrf PCLATH
	call EEreadBC
	andlw 3Fh
	movwf Data1H
	call EEreadBC
	movwf Data1L
	ThisPage

	movf Data1H,W
	xorlw 0x3F
	btfss STATUS,Z
	goto NonBN		; not blank

	movf Data1L,W
	xorlw 0xFF
	btfss STATUS,Z
	goto NonBN		; not blank

	bsf Flag3,AddInc		; flag update address on next non blank data
	goto UppADs

NonBN	btfss Flag3,AddInc
	goto NoAddCH

	bcf Flag3,AddInc		; change address
	movlw 1h			; then continue programming
	movwf TXREG
	call TransWt2
	movf ProgAddH,W
	movwf TXREG
	movf ProgAddL,W
	movwf TXREG

	call BTRecv		; get address change ack
	btfss Flag2,OK		; OK = 0 = timeout error
	goto BootLoad

NoAddCH	clrw			; send 0 = program ROM command
	movwf TXREG
	call TransWt2
	movf Data1H,W
	movwf TXREG		; program H
	movf Data1L,W
	movwf TXREG		; program L

	call BTRecv		; wait 1 second for 'A' ack
	btfss Flag2,OK		; OK = 0 = timeout error
	goto BootLoad

UppADs	incf ProgAddL		; ROM address
	btfsc STATUS,Z
	incf ProgAddH

	movf ProgAddL,W
	andlw b'00011111'
	btfss STATUS,Z
	goto NonDs

	movlw High(DispProg)
	movwf PCLATH
	call DispProg		; display progress
	ThisPage

NonDs	movf HiROMAdd,W
	xorwf ProgAddH,W
	btfss STATUS,Z
	goto ProgBTR

	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
;
; PROGRAM EEPROM
;
	movlw 32h			; program eeprom
	call MessProc1

	movlw High(SetEEPAdd)	; set EEPROM I2C address
	movwf PCLATH
	call SetEEPAdd
	ThisPage

	clrf Temp3
	clrf Temp4

BootMoreE	movlw d'16'		; 16 bytes to do
	movwf CCount
;
; READ THE EEPROM DATA FROM EEPROM (A or C)
;
BTREEP	clrf PCLATH
	call EEreadBC
	movwf Temp1
	ThisPage

	movlw 4h			; write RAM/EEP
	movwf TXREG
	clrw			; address 0 = write EEP
	movwf TXREG
	call TransWt2

	movf Temp1,W		; eeprom data
	movwf TXREG
	movf EEaddL,W		; eeprom address
	movwf TXREG
	call TransWt2

	incf Temp3		; increment address
	btfsc STATUS,Z
	incf Temp4

	call BTRecv		; wait 1 second for 'A' ack
	btfss Flag2,OK		; OK = 0 = timeout error
	goto BootLoad

	decfsz CCount
	goto BTREEP

	movf Temp4,W
	xorwf EEsizeH,W
	btfss STATUS,Z
	goto BootMoreE

	movf Temp3,W
	xorwf EEsizeL,W
	btfss STATUS,Z
	goto BootMoreE
;
; BOOT PROGRAMMING COMPLETE
;
	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data

	movlw 33h			; program complete
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	goto BootTop
;
; ---------------------------------------------
; BOOT RECEIVE FROM SERIAL PORT - WAIT 1 SECOND
; ---------------------------------------------
;
BTRecv	clrf TMR0
	bcf INTCON,T0IF
	movlw d'20'
	movwf Temp1

RecBT	btfsc PIR1,RCIF		; (5) check for received data
	goto GotRecBT

	btfss INTCON,T0IF
	goto RecBT

	bcf INTCON,T0IF
	decfsz Temp1
	goto RecBT
;
; PC TIMEOUT ERROR
;
	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data

	movlw 17h			; error: timeout
	call MessProc1
	movlw 12h			; press any key
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	bcf Flag2,OK
	return			; error

GotRecBT	movf RCREG,W
	movwf RxHold
	bsf Flag2,OK
	return			; OK
;
; wait for 1/2 or 1 second
;
WaitP5S	movlw 10h
	goto InWTs
Wait1sec	movlw d'20'
InWTs	movwf Temp3

BTShow	btfss INTCON,T0IF
	goto BTShow
	bcf INTCON,T0IF
	decfsz Temp3
	goto BTShow
	return
;
; -----------------------
; BOOT START USER PROGRAM
; -----------------------
;
_StartU	clrf PCLATH
	call KeyReles
	movlw 5Fh			; rom programmed?
	call MessProc1
	movlw 22h			; K1 = start
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	btfss Flag2,OK
	goto BootTop

	movlw 5h			; run user code
	movwf TXREG
	goto BTKey2		; exit to main menu
;
; -------------------------------------------------
; WAIT UNTIL RS232 IS FINISHED SENDING - ROM PAGE 2
; -------------------------------------------------
;
TransWt2	bsf STATUS,RP0
WtHere2	btfss TXSTA,TRMT		; (1) transmission is complete if hi
	goto WtHere2

	bcf STATUS,RP0		; RAM Page 0
	return
;
; ----------------
; DISASSEMBLE CODE
; ----------------
;
Dissassem	clrf PCLATH
	btfsc Flag2,f8M32		; 18cxxx no disassemble
	goto DFNA

	call ListFiles
	btfss Flag2,OK
	goto TopMenu
;
; check rom/eep size against chip and file
;
	movlw High(CheckSize)
	movwf PCLATH
	call CheckSize
	clrf PCLATH
	btfss Flag2,OK
	goto TopMenu

	ThisPage
	bcf Flag3,Mods		; clear data modified flag

	btfss Flag3,Etype
	goto DissROM		; no eeprom in selected chip

	clrf PCLATH
	movlw 1Bh			; key #1 = VIEW ROM
          call MessProc1
	movlw 1Ch			; key #4 = VIEW EEPROM
          call MessProc2

	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	btfss Flag2,OK
	goto DisEEP		; display eeprom data

DissROM	clrf PCLATH		; get program start address
	movlw StartAdd
	addwf FNindex,W
	call IEread
	movwf CodeAddH
	movlw E_ROMStart		; data start address
	movwf CodeAddL
	clrf ProgAddH		; keeps track of display address
	clrf ProgAddL
	clrf RAMpage

	call BCstartR		; get 1st instruction
	call EEread_A
	movwf InstrH
	call EEread_N
	movwf InstrL

	ThisPage
	movlw 0Eh           	; display = on, cursor = on
	call LCDins2
	movlw 3h
	movwf CurPos		; = code address units digit
	bcf Flag3,AddData		; cursor at hex address
	call F_Cursor		; set cursor position

DDdisp	call Decode	
	call DDisplay

DDLoop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto DDLoop
	goto DDKey1
	goto DDKey2
	goto DDKey3
	goto DDKey4
;
; Key #1
;
DDKey1	movf CurPos,W
	xorlw d'9'		; 9 = RAM page select UP
	btfss STATUS,Z
	goto ExmnCK

	call RAMpgChgU
	goto DDLoop

ExmnCK	movf CurPos,W		; 10 = exit to main
	xorlw d'10'
	btfss STATUS,Z
	goto IzLcr
;
; EXIT TO MAIN MENU
;
	clrf PCLATH
	goto TopMenu		; exit to top menu

IzLcr	bsf Flag3,Up_Dn		; 0123 = flag dissassemble upwards	
	btfss Flag3,AddData
	goto FinDs

chgHEXu	call DataFdU		; 5678 = data field change up
	goto DDdisp
;
; Key #2
;
DDKey2	bcf Flag4,cur
	call DM_Cursor		; shift cursor left
	goto DissDisp		; adjust dissassemble display information
;
; Key #3
;
DDKey3	bsf Flag4,cur	
	call DM_Cursor		; shift cursor right
	goto DissDisp		; adjust dissassemble display information
;
; Key #4
;
DDKey4	movf CurPos,W
	xorlw d'9'		; 9 = RAM page select DOWN
	btfss STATUS,Z
	goto DMcrCK

	call RAMpgChgD
	goto DDLoop	

DMcrCK	movf CurPos,W		; 10 = save data field change
	xorlw d'10'
	btfss STATUS,Z
	goto Izadtr

	btfss Flag3,Mods		; check data modified flag
	goto DDLoop		; no changes were made

	clrf PCLATH
	movlw 0Eh			; save rom?
	call MessProc1
	movlw 0xA0		; k1 = yes
	call MessProc2
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	btfss Flag2,OK
	goto NoRSave		; not key 1
;
; SAVE ROM DATA
;
	clrf PCLATH
	call BCstartW
	movf CodeAddH,W		; save values
	movwf _SaveH		; don't want them to increment
	movf CodeAddL,W		; because of EEwriteBC code
	movwf _SaveL
	movf InstrH,W
	call EEwriteBC
	movf InstrL,W
	call EEwriteBC
	call EEstop

	movf _SaveH,W
	movwf CodeAddH
	movf _SaveL,W
	movwf CodeAddL
	bcf Flag3,Mods

NoRSave	clrf PCLATH
	movlw 0Fh			; k1 = main menu
	call MessProc1
	ThisPage
	btfss Flag3,Mods		; check data modified flag
	goto DDLoop

	clrf PCLATH
	movlw 2Ah			; k4 = save change
	call MessProc2
	ThisPage
	goto DDLoop

Izadtr	bcf Flag3,Up_Dn		; 0123 = flag dissassemble downwards
	btfss Flag3,AddData
	goto FinDs

chgHEXd	call DataFdD		; 5678 = data field change down
	goto DDdisp

FinDs	call ChangAddR		; next rom address
	goto DDdisp
;
; ----------------------------------------------
; SHIFT THE CURSOR POSITION IN DISSASSEMBLE MODE
; ----------------------------------------------
;
DM_Cursor btfsc Flag4,cur
	goto CurRight

	decf CurPos
	btfss CurPos,7
	goto NotFarLf

	movlw d'10'		; place cursor at far right
	movwf Temp4
	movwf CurPos

RightCr	movlw B'00010100'		; cursor = 1 pos to right
	call LCDins2
	decfsz Temp4
	goto RightCr

	movlw 0ch			; cursor = off
	call LCDins2
	goto SetHDfg

NotFarLf	movlw 8h
	xorwf CurPos,W
	btfss STATUS,Z
	goto NoCrOnY

	movlw 0eh			; cursor = on
	call LCDins2
	goto DecCr1

NoCrOnY	movlw 4h
	xorwf CurPos,W
	btfss STATUS,Z
	goto DecCr1

	decf CurPos		; cursor in data field position
	movlw B'00010000'		; cursor = 1 pos to left
	call LCDins2
DecCr1	movlw B'00010000'		; cursor = 1 pos to left
	call LCDins2
	goto SetHDfg

CurRight	incf CurPos
	movlw 9h
	xorwf CurPos,W
	btfss STATUS,Z
	goto NoCrOffY

	movlw 0ch			; cursor = off
	call LCDins2
	goto shf1

NoCrOffY	movlw 4h
	xorwf CurPos,W
	btfss STATUS,Z
	goto Chk11

	incf CurPos		; cursor in data field position
	movlw B'00010100'		; cursor = 1 pos to right
	call LCDins2

shf1	movlw B'00010100'		; cursor = 1 pos to right
	call LCDins2
SetHDfg	bcf Flag3,AddData		; cursor not in hex address
	movlw 5h			; hex code curpos = 5 - 8
	subwf CurPos,W
	btfss STATUS,C
	return			; cursor not in hex code

	bsf Flag3,AddData		; cursor in hex code
	movlw 9h
	subwf CurPos,W
	btfsc STATUS,C
	bcf Flag3,AddData		; cursor not in hex code
	return

Chk11	movlw d'11'
	xorwf CurPos,W
	btfss STATUS,Z
	goto shf1

	clrf CurPos
	movlw B'00000010'		; home display
	call LCDins2
	movlw 0eh           	; cursor = on
	call LCDins2
	bcf Flag3,AddData		; cursor not in hex address
	return	
;
; ------------------------------
; INCREMENT/DECREMENT DATA FIELD
; ------------------------------
; Cr 5 = Hxxx, 6 = xHxx, 7 = xxHx, 8 = xxxH
;
DataFdU	bsf Flag3,Up_Dn		; flag alter code upwards
	goto InFd

DataFdD	bcf Flag3,Up_Dn		; flag alter code downwards
InFd	bsf Flag3,Mods		; set data modified flag
	movlw 5h
	subwf CurPos,W
	movwf Temp1

	movlw 1h
	btfss Temp1,0
	movlw 10h
	btfss Temp1,1
	goto DatHi

	btfsc Flag3,Up_Dn
	goto DatUp

	subwf InstrL
	btfss STATUS,C
	decf InstrH
	goto AddDatL
	
DatUp	addwf InstrL
	btfsc STATUS,C
	incf InstrH
	goto AddDatL

DatHi	btfsc Flag3,Up_Dn
	goto DatUpH

	subwf InstrH
	goto AddDatL
	
DatUpH	addwf InstrH
AddDatL	movlw 3Fh
	andwf InstrH
	return
;
; --------------------------------------------------
; RESET THE CURSOR BACK TO IT'S DISASSEMBLE POSITION
; --------------------------------------------------
;
F_Cursor	movlw 2h			; home cursor
	call LCDins2

	movf CurPos,W		; set it back to it's position
	movwf Temp4
Cloop	movf Temp4,W
	btfsc STATUS,Z
	return

	movlw B'00010100'		; cursor = 1 pos to right
	call LCDins2

	decf Temp4
	goto Cloop
;
; --------------------------------------
; SEND DISSASSEMBLED DATA TO THE DISPLAY
; --------------------------------------
;
DDisplay	clrf PCLATH
	call ClearDisp
	movlw 80h           	; message to start of line 1
	call LCDins

	movlw Low(EepBuff)		; point to eeprom data buffer
	movwf FSR
	bsf STATUS,IRP
;
; SEND ROM ADDRESS DATA
;
	movf ProgAddH,W
	movwf Temp4

	swapf Temp4,W
	call ToASCII
	call LCDout

	movf Temp4,W
	call ToASCII
	call LCDout

	movf ProgAddL,W
	movwf Temp4

	swapf Temp4,W
	call ToASCII
	call LCDout

	movf Temp4,W
	call ToASCII
	call LCDout

	movlw ' '
	call LCDout
;
; SEND HEX CODE
;
	swapf InstrH,W
	call ToASCII
	call LCDout

	movf InstrH,W
	call ToASCII
	call LCDout

	swapf InstrL,W
	call ToASCII
	call LCDout

	movf InstrL,W
	call ToASCII
	call LCDout

	movlw ' '
	call LCDout
;
; SEND DISSASSEBLED INSTRUCTION MNEMONIC
;
condisp   ThisPage
	movf INDF,W
	xorlw 0xFF
	btfsc STATUS,Z
	goto CurFix

	movf INDF,W
	xorlw ' '
	btfsc STATUS,Z
	goto NewLn

	clrf PCLATH
	movf INDF,W
	call LCDout        	 	; output to display
	ThisPage

          incf FSR
          goto condisp
;
; SEND DISSASSEMBLED DATA 
;
NewLn	incf FSR
	movlw 0xC0          	; message to start of line 2
	call LCDins2

condispN	movf INDF,W
	xorlw 0xFF
	btfsc STATUS,Z
	goto CurFix

	clrf PCLATH
	movf INDF,W
	call LCDout         	; output to display
	ThisPage

          incf FSR
          goto condispN

CurFix	call F_Cursor
	bcf STATUS,IRP
	return
;
; ---------------------------
; DECODE THE INSTRUCTION DATA
; ---------------------------
; Returns with a number for the instruction in W
; If no instruction exists for the supplied data then MessPt = FFh
; Instruction data is extracted to InsDataH, InsDataL
;
Decode	bcf Flag4,d_err		; (0) clear flag error
	ThisPage
	swapf InstrH,W
	andlw b'00000011'		; mask upper 6 bits
	addwf PCL
	goto Sub_A
	goto Sub_B
	goto Sub_C
	goto Sub_D
;
; (0xxx)
; THIS BLOCK HAS THE FOLLOWING INSTRUCTIONS...
; ADDWF, ANDWF, CLRF, CLRW, COMF, DECF, DECFSZ, INCF, INCFSZ, IORWF
; MOVF, MOVWF, NOP, RLF, RRF, SUBWF, SWAPF, XORWF, CLRWDT, RETFIE
; RETURN, SLEEP
;
Sub_A	bsf Flag4,nofw		; use ,F ,W extensions
	movf InstrH,W
	btfsc STATUS,Z
	goto Sub_Aa

	xorlw 1h
	btfsc STATUS,Z
	goto Sub_Ag

	xorlw 1h
	call InsDec
	goto Insa
;
; CLRF, CLRW
;
Sub_Ag	movf InstrL,W
	andlw b'10000000'
	btfsc STATUS,Z
	goto Sub_Ah

	movlw 79h			; clrf
	goto Insx
;
; CLRW
;
Sub_Ah	movlw 7Ah			; clrw
	goto insb
;
; MOVWF, NOP, CLRWDT, RETFIE, RETURN, SLEEP
;
Sub_Aa	btfss InstrL,7
	goto Sub_Ab

	movlw 82h			; movwf
Insx	bcf Flag4,nofw		; don't use ,F ,W extensions
Insa	clrf PCLATH
	call MessProc3		; puts data into buffer
	ThisPage

	bsf STATUS,IRP
	call _Space		; insert a space after text

	movf InstrL,W		; add RAM address
	andlw b'01111111'
	call RamNames

	btfss Flag4,nofw
	goto NoFWext

	movlw ','			; add a comma
	movwf INDF
	incf FSR

	movlw 'W'
	btfsc InstrL,7		; d bit = bit 7
	movlw 'F'
	movwf INDF
	incf FSR

NoFWext	movlw 0xFF
	movwf INDF
	bcf STATUS,IRP
	return
;
; NOP, CLRWDT, RETFIE, RETURN, SLEEP
;
Sub_Ab	movf InstrL,W
	andlw b'11110000'
	btfss STATUS,Z
	goto Sub_Ac
;
; NOP, RETFIE, RETURN
;
	movf InstrL,W
	andlw b'00001111'
	btfss STATUS,Z
	goto Sub_Ad

Iz_nop	movlw 83h			; nop
	goto insb
;
; RETFIE, RETURN
;
Sub_Ad	movf InstrL,W
	xorlw b'00001001'
	btfss STATUS,Z
	goto Sub_Ae

	movlw 94h			; retfie
	goto insb
;
; RETURN
;
Sub_Ae	movf InstrL,W
	xorlw b'00001000'
	btfss STATUS,Z
	goto Sub_EE		; data error

	movlw 96h			; return
	goto insb
;
; NOP, CLRWDT, SLEEP
;
Sub_Ac	movf InstrL,W
	andlw b'10011111'
	btfsc STATUS,Z
	goto Iz_nop

	movf InstrL,W
	xorlw b'01100100'
	btfss STATUS,Z
	goto Sub_Af

	movlw 90h			; clrwdt
	goto insb
;
; SLEEP
;
Sub_Af	movf InstrL,W
	xorlw b'01100011'
	btfss STATUS,Z
	goto Sub_EE		; data error

	movlw 97h			; sleep
	goto insb
;
; ----------
; DATA ERROR
; ----------
;
Sub_EE	bsf Flag4,d_err		; (0) flag error
	movlw 9Ah			; ?????
insb	clrf PCLATH
	call MessProc3		; puts data into buffer
	ThisPage

	bsf STATUS,IRP
	movlw 0xFF
	movwf INDF
	return
;
; (1xxx)
; THIS BLOCK HAS THE FOLOWING INSTRUCTIONS...
; BCF, BSF, BTFSC, BTFSS
; InsDataH = 7 bit 'address data'
; InsdataL = 3 bit 'bit data'
;
Sub_B	movf InstrH,W		; get instruction
	andlw b'00001100'		; mask all but instruction data
	movwf Temp1
	ThisPage
	rrf Temp1,W		; move bits into lowest position X 2
	andlw b'00000110'		; mask unwanted	
	addwf PCL
	movlw 89h			; bcf
	goto Insc
	movlw 8Ah			; bsf
	goto Insc
	movlw 8Bh			; btfsc
	goto Insc
	movlw 8Ch			; btfss
Insc	clrf PCLATH
	call MessProc3		; puts data into buffer
	ThisPage

	bsf STATUS,IRP
	call _Space		; insert a space after text

	movf InstrL,W		; add RAM address
	andlw b'01111111'
	movwf TRAMadd		; save the ram address
	call RamNames

	movlw ','			; add a comma
	movwf INDF
	incf FSR

	movf InstrH,W		; get bit info xxxx xxbb bxxx xxxx
	andlw b'00000011'		; bits 1 and 2
	movwf Temp1
	rlf InstrL,W		; get bit 0 (bit 7) -> carry
	rlf Temp1,W		; shift into data
	clrf PCLATH
	call ToASCII
	movwf INDF
	ThisPage

	call BitNames		; get a bit name if it exists
	incf FSR
	bsf STATUS,IRP
	movlw 0xFF		; end char
	movwf INDF
	return	
;
; (2xxx)
; THIS BLOCK HAS THE FOLLOWING INSTRUCTIONS...
; CALL, GOTO
; InsDataH = 11 bit 'address data H - upper 3 bits'
; InsDataL = 11 bit 'address data L - lower 8 bits'
;
Sub_C	movf InstrH,W
	andlw b'00000111'		; upper 3 bits of address
	movwf InsDataH
	movf InstrL,W		; lower 8 bits
	movwf InsDataL
	movlw 8Fh			; call
	btfsc InstrH,3		; goto/call deciding bit xx10baaa aaaaaaaa
	movlw 91h			; goto
	clrf PCLATH
	call MessProc3		; puts data into buffer
	ThisPage

	bsf STATUS,IRP
	call _Space		; insert a space after text

	movf InsDataH,W		; upper 3 bits of address data
	clrf PCLATH
	call ToASCII
	movwf INDF
	incf FSR

	movf InsDataL,W		; lower 8 bits of address data
	call HexASCII
	ThisPage

	call _H			; add 'H'
	
	movlw 0xFF		; end char
	movwf INDF
	return	
;
; (3xxx)
; THIS BLOCK HAS THE FOLLOWING INSTRUCTIONS...
; ADDLW, ANDLW, IORLW, MOVLW, RETLW, SUBLW, XORLW
; InsdataH = NA
; InsdataL = 8 bit Literal data
;
Sub_D	movf InstrL,W		; get Literal data
	movwf InsDataL
	btfss InstrH,3
	goto Sub_Da
;
; ADDLW, ANDLW, IORLW, SUBLW, XORLW
;
	btfsc InstrH,2
	goto Sub_Db
;
; ANDLW, IORLW, XORLW
;
	movlw 99h			; xorlw
	btfsc InstrH,1
	goto _Lits
;
; ANDLW, IORLW
;
	movlw 92h			; iorlw
	btfsc InstrH,0
	movlw 8Eh			; andlw
	goto _Lits	
;
; ADDLW, SUBLW
;
Sub_Db	movlw 98h			; sublw
	btfsc InstrH,1
	movlw 8Dh			; addlw
	goto _Lits
;
; MOVLW RETLW
;
Sub_Da	movlw 93h			; movlw
	btfsc InstrH,2
	movlw 95h			; retlw

_Lits	clrf PCLATH
	call MessProc3		; puts data into buffer
	ThisPage

	bsf STATUS,IRP
	call _Space		; insert a space after text

	clrf PCLATH
	movf InsDataL,W		; 8 bits of literal data
	call HexASCII
	ThisPage

	call _H

	call Printable		; add it's printable character

	movlw 0xFF		; end char
	movwf INDF	
	return
;
; -----------------------------------------------
; IF DATA IS PRINTABLE - ADD ITS ASCII EQUIVALENT
; 20h - 7Fh is printable.
; -----------------------------------------------
;
Printable btfsc InsDataL,7
	return			; > 7F

	movlw 20h
	subwf InsDataL,W
	btfss STATUS,C
	return			; < 20h

	call _Space

	movlw 27h			; (')
	movwf INDF
	incf FSR

	movf InsDataL,W		; char
	movwf INDF
	incf FSR

	movlw 27h			; (')
	movwf INDF
	incf FSR
	return
;
; -----------------------------------------------------------
; DISSASSEMBLE DISPLAY - UPDATE INFORMATION AFTER CURSOR MOVE
; -----------------------------------------------------------
;
DissDisp	btfsc Flag4,cur		; test the direction that cursor moved
	goto curmvRT

	movf CurPos,W		; if just moved to posn 8
	xorlw d'8'		; display dissassemble data
	btfsc STATUS,Z
	goto DDdisp

ChNM9	movf CurPos,W		; if just moved to posn 9
	xorlw d'9'		; display RAM Page message
	btfss STATUS,Z
	goto ChNM10

	call SetRAMPg
	goto DDLoop

ChNM10	movf CurPos,W		; if just moved to posn 10
	xorlw d'10'		; display save message
	btfss STATUS,Z
	goto DDLoop

	clrf PCLATH
	movlw 0Fh			; k1 = main menu
	call MessProc1
	ThisPage
	btfss Flag3,Mods		; check data modified flag
	goto DDLoop

	clrf PCLATH
	movlw 2Ah			; k4 = save change
	call MessProc2
	ThisPage
	goto DDLoop

curmvRT	movf CurPos,W		; if just moved to Posn 0 then
	btfsc STATUS,Z		; display dissassemble data
	goto DDdisp
	goto ChNM9		; check positions 9
;
; -----------------------------------------
; INSERT THE RAM PAGE NUMBER ON THE DISPLAY
; -----------------------------------------
;
SetRAMPg	clrf PCLATH
	movlw 1Dh			; RAM PAGE
	call MessProc1
	movf RAMpage,W
	call ToASCII
	call LCDout
	ThisPage
	return
;
; -------------------
; DISPLAY EEPROM DATA
; -------------------
; HH: xx A
;
DisEEP	movlw High(SetEEPAdd)	; get eeprom start address
	movwf PCLATH
	call SetEEPAdd
	clrf PCLATH
	call EEread_N		; no need to read from I2C yet
	movlw 0Eh           	; display = on, cursor = on
	call LCDins
	ThisPage

	clrf ProgAddL
	clrf CurPos	

	call EEPscreen		; display 1st eeprom data

EELoop	clrf PCLATH
	call KeyRepeat		; get a keypress
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto EELoop
	goto EEKey1
	goto EEKey2
	goto EEKey3
	goto EEKey4
;
; KEY #1
; value up or exit to main
;
EEKey1	movf CurPos,W
	xorlw d'6'
	btfss STATUS,Z
	goto EEPup

	clrf PCLATH
	goto TopMenu		; exit to top menu
;
; KEY #2
; cursor left
;
EEKey2	decf CurPos
	btfss CurPos,7
	goto NOunder
;
; DISPLAY SAVE/EXIT
;
	movlw 6h
	movwf CurPos
	goto Chgdatex

NOunder	movf CurPos,W
	xorlw 5h
	btfss STATUS,Z
	goto cr3ck
;
; DISPLAY EEPROM DATA
;
DeepSC	call EEPscreen
	movlw 0Eh           	; display = on, cursor = on
	call LCDins2
	goto PosCurN

cr3ck	movf CurPos,W
	xorlw 3h
	btfss STATUS,Z
	goto PosCurN

	movlw 1h
	movwf CurPos
PosCurN	call F_Cursor
	goto EELoop
;
; KEY #3
; cursor right
;
EEKey3	incf CurPos
	movlw d'7'
	xorwf CurPos,W
	btfss STATUS,Z
	goto MB6ix

	clrf CurPos
	goto DeepSC		; display eeprom data

MB6ix	movlw d'6'
	xorwf CurPos,W
	btfss STATUS,Z
	goto Un6ix
;
; DISPLAY SAVE/EXIT
;
Chgdatex	clrf PCLATH
	movlw 0Ch           	; cursor = off
	call LCDins
	movlw 0Fh			; k1 = main menu
	call MessProc1
	ThisPage
	btfss Flag3,Mods		; check data modified flag
	goto EELoop

	clrf PCLATH
	movlw 2Ah			; k4 = save change
	call MessProc2
	ThisPage
	goto EELoop

Un6ix	movlw 2h
	xorwf CurPos,W
	btfss STATUS,Z
	goto PosCurN

	movlw 4h
	movwf CurPos
	goto PosCurN
;
; KEY #4
; value down or save data
;
EEKey4	movf CurPos,W
	xorlw d'6'
	btfss STATUS,Z
	goto EEPdn

	btfss Flag3,Mods		; check data modified flag
	goto Chgdatex		; no changes were made

	clrf PCLATH
	call KeyReles
	movlw 1Fh			; save eeprom?
	call MessProc1
	movlw 0xA0		; k1 = yes
	call MessProc2
;
; key1 = Yes, any other = No
;
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	btfss Flag2,OK
	goto Chgdatex
;
; SAVE EEPROM DATA
;
	clrf PCLATH
	call BCstartW
	movf EEPdata,W
	call EEwrite
	call EEstop
	ThisPage
	bcf Flag3,Mods
	goto Chgdatex
;
; CHANGING EEPROM DATA - UP KEY
;
EEPup	bsf Flag3,Up_Dn
	goto EEupdn
;
; CHANGING EEPROM DATA - DOWN KEY
;
EEPdn	bcf Flag3,Up_Dn
EEupdn	bsf Flag3,Mods		; set data modified flag
	ThisPage
	movf CurPos,W
	addwf PCL
	goto AH			;  0 address H
	goto AL			;  1 address L
	nop			;  2 :  (not used)
	nop			;  3 -  (not used)
	goto D1H			;  4 data1H
	goto D1L			;  5 data1L
;
; -------------------
; DISPLAY EEPROM DATA
; -------------------
;
EEPscreen	clrf PCLATH
	call BCstartR
	call EEread_N
	movwf EEPdata

InScreen	clrf PCLATH
	call ClearDisp
	movlw 80h           	; message to start of line 1
	call LCDins
;
; DISPLAY ADDRESS
;
	swapf ProgAddL,W		; display eeprom address
	call ToASCII
	call LCDout

	movf ProgAddL,W
	call ToASCII
	call LCDout
	movlw ':'
	call LCDout

	movlw ' '
	call LCDout
;
; DISPLAY DATA BYTE
;
	swapf EEPdata,W	
	call ToASCII
	call LCDout

	movf EEPdata,W
	call ToASCII
	call LCDout

	movlw ' '
	call LCDout

	ThisPage
;
; SEE IF DATA IS PRINTABLE
;
	btfsc EEPdata,7
	goto ExEEd		; > 7F

	movlw 20h
	subwf EEPdata,W
	btfss STATUS,C
	goto ExEEd		; < 20h

	clrf PCLATH
	movlw 27h			; (')
	call LCDout
	
	movf EEPdata,W		; char
	call LCDout

	movlw 27h			; (')
	call LCDout
	ThisPage

ExEEd	call F_Cursor		; reset cursor to it's position
	return
;
; -------------------
; EEPROM DATA CHANGES
; -------------------
; ADDRESS BYTE
;
AH	btfsc Flag3,Up_Dn
	goto HiUP

	movlw 10h			; SUB Upper nibble address
	subwf ProgAddL
	goto ChopIt

HiUP	movlw 10h			; ADD Upper nibble address
	addwf ProgAddL
	goto ChopIt

AL	btfsc Flag3,Up_Dn
	goto LoUp

	decf ProgAddL
	goto ChopIt	

LoUp	incf ProgAddL
ChopIt	decf EEsizeL,W		; chop off data above limit
	andwf ProgAddL
	call ChangAddE
	call EEPscreen		; update screen
	bcf Flag3,Mods
	goto EELoop
;
; CHANGE DATA BYTE
;
D1H	btfsc Flag3,Up_Dn
	goto DHiUP

	movlw 10h
	subwf EEPdata
	goto FiDat

DHiUP	movlw 10h
	addwf EEPdata
	goto FiDat

D1L	btfsc Flag3,Up_Dn
	goto DLoUP

	decf EEPdata
	goto FiDat

DLoUP	incf EEPdata
FiDat	call InScreen		; update screen
	goto EELoop
;
; ---------------
; RAM PAGE CHANGE
; ---------------
; 1 = 0, 2 = 0,1 - 3 = 0,1,2 - 4 = 0,1,2,3
;
RAMpgChgU	incf RAMpage
	movf RAMpageMax,W
	xorwf RAMpage,W
	btfsc STATUS,Z
	clrf RAMpage
	goto SetRAMPg
	
RAMpgChgD	decf RAMpage
	movlw 0xFF
	xorwf RAMpage,W
	btfss STATUS,Z
	goto SetRAMPg

	decf RAMpageMax,W
	movwf RAMpage
;
; ------------------
; CHANGE ROM ADDRESS
; ------------------
;
ChangAddR	bcf Flag3,Mods		; flag not modified anymore
	movlw 1h
	btfss CurPos,0
	movlw 10h
	btfss CurPos,1
	goto ModHi

	btfsc Flag3,Up_Dn
	goto DissUp

	subwf ProgAddL
	btfss STATUS,C
	decf ProgAddH
	goto AddChkL
	
DissUp	addwf ProgAddL
	btfsc STATUS,C
	incf ProgAddH
	goto AddChkH

ModHi	btfsc Flag3,Up_Dn
	goto DissUpH

	subwf ProgAddH
AddChkL	movf HiROMAdd,W	
	subwf ProgAddH,W		; if >= upper ROM address then = upper
	btfss STATUS,C
	goto AdjCodeA

	decf HiROMAdd,W
	movwf ProgAddH
	goto AdjCodeA
	
DissUpH	addwf ProgAddH
AddChkH	movf HiROMAdd,W	
	subwf ProgAddH,W		; if >= upper ROM address then = 0
	btfss STATUS,C
	goto AdjCodeA

	clrf ProgAddH
;
; LINK THROUGH EEPROM(S) TO MATCH ROM ADDRESS
;
AdjCodeA	clrf PCLATH
	movlw 0xFF
	call SetCdAddH		; set CodeAddH for code start address
	ThisPage

	bcf STATUS,C		; 2 bytes per ROM word
	rlf ProgAddL,W		; byte count for ROM address
	movwf Data2L		; used to create an offset into final block
	rlf ProgAddH,W
	movwf Data2H

	movlw d'255' - E_ROMStart	; bytes for 1st block
	movwf Data1L
	clrf Data1H
	movlw E_ROMStart		; data start address for 1st block
	movwf Temp5

AdjLoop	movf Data1L,W		; is current byte count >= this block count
	subwf Data2L,W
	movf Data1H,W
	btfss STATUS,C
	addlw 1h
	subwf Data2H,W
	btfss STATUS,C
	goto IsaMat		; No, data is in within this block
;
; subtract block byte count from total
;
	movf Data1L,W
	subwf Data2L
	btfss STATUS,C
	decf Data2H

	movlw d'255'		; 255 bytes in other blocks
	movwf Data1L
	clrf Temp5		; no offsets for all other blocks
;
; link to next block
;
	clrf PCLATH
	call BCstartR		; CodeAddH/L already set
	call EEread_N
	movwf CodeAddH
	ThisPage
	goto AdjLoop
;
; get code word from eeprom
;
IsaMat	movf Data2L,W		; offset into block
	addwf Temp5,W		; plus 0 or 16 byte offset
	movwf CodeAddL		; code addH already set
	clrf PCLATH
	call BCstartR
	call EEread_A
	movwf InstrH
	call EEread_N
	movwf InstrL
	ThisPage
	return
;
; ---------------------
; CHANGE EEPROM ADDRESS
; ---------------------
;
ChangAddE	movlw High(SetEEPAdd)	; get eeprom start address
	movwf PCLATH
	call SetEEPAdd
	clrf PCLATH
	call EEread_N		; no need to read from I2C yet
	ThisPage

	clrf Temp5		; address match data

AdjLoopE	movf ProgAddL,W
	xorwf Temp5,W
	btfsc STATUS,Z
	goto IsaMatE
;
; no address match
;
NoAMatE	incf Temp5
	incf CodeAddL		; 1 byte per eeprom location
	
	movlw 0xFF
	xorwf CodeAddL,W
	btfss STATUS,Z
	goto AdjLoopE
;
; link to next block
;
	clrf PCLATH
	call BCstartR
	call EEread_N
	movwf CodeAddH
	clrf CodeAddL
	ThisPage
	goto AdjLoopE
;
; get eeprom byte from eeprom
;
IsaMatE	clrf PCLATH
	call BCstartR
	call EEread_N
	movwf EEdata
	ThisPage
	return
;
; -------------------------
; EXTRACT RAM MNEMONIC NAME
; -------------------------
; try to find RAM name in EEPROM
; if not just use HEX data
;
RamNames	movwf RAMadd		; RAM address
	clrf PCLATH
	call ToASCII
	movwf Data2L
	swapf RAMadd,W
	call ToASCII
	movwf Data2H
	movf FSR,W
	movwf _FSR		; save FSR value
	call JumpChip		; jump to chip data address on EEPROM
	ThisPage

RnamLP	clrf PCLATH
	call EEread_A		; EEPROM read with ACK
	ThisPage

	movf EEdata,W
	xorlw '['			; test for '['
	btfsc STATUS,Z
	goto NoName		; yes, start of next chip data

	movf EEdata,W		; test for '!'
	xorlw '!'
	btfsc STATUS,Z
	goto NoName		; yes, end of chip data

	movf EEdata,W		; test for '#'
	xorlw '#'
	btfss STATUS,Z
	goto RnamLP		; no, RAM addresses start with #

	clrf PCLATH
	call EEread_A		; EEPROM read with ACK
	ThisPage
	movlw d'48'
	subwf EEdata,W		; convert ASCII bit value to decimal
	xorwf RAMpage,W
	btfss STATUS,Z
	goto RnamLP		; not selected RAM page page

	clrf PCLATH
	call EEread_A		; EEPROM read with ACK - skip ','
;
; GET RAM NAME TEXT
;
RstMessR	movf _FSR,W		; restore buffer pointer
	movwf FSR
GtMessRN	bsf STATUS,IRP
	clrf PCLATH
	call EEread_A		; EEPROM read with ACK
	movwf INDF
	ThisPage
	movf INDF,W
	xorlw ';'
	btfsc STATUS,Z
	goto GotRName		; got RAM name

	movlw ','			; comma between ram data
	xorwf INDF,W
	btfsc STATUS,Z
	goto GtMessRN		; skip comma between RAM data

	movlw '^'			; end of line
	xorwf INDF,W
	btfsc STATUS,Z
	goto NoName		; no match

	incf FSR
	goto GtMessRN		; not end of RAM name text
;
; NEXT NUMBER IS THE RAM ADDRESS VALUE
;
GotRName	clrf PCLATH
	call EEread_A		; EEPROM read with ACK
	movwf Data1H
	call EEread_A		; EEPROM read with ACK
	movwf Data1L
	ThisPage
	call CompNum		; compares Data1H/L and Data2H/L
	btfsc STATUS,Z
	goto OffEEP		; match
	goto RstMessR		; no match - try another
;
; RAM ADDRESS DID NOT MATCH
;
NoName	movf _FSR,W
	movwf FSR
	clrf PCLATH
	movf RAMadd,W
	call HexASCII
	ThisPage
	call _H			; add 'h'

OffEEP	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	ThisPage
	return
;
; -----------------
; GET RAM BIT NAMES
; -----------------
; ASCII value of BIT number is in INDF address
; text example of ram bits
; %003,C,DC,Z,PD,TO,RP0,RP1,IRP^
;
BitNames	movf TRAMadd,W		; saved RAM address
	clrf PCLATH		; ROM page 0
	call ToASCII
	movwf Data2L
	swapf TRAMadd,W
	call ToASCII
	movwf Data2H

	movf FSR,W
	movwf _FSR		; save FSR value
	movf INDF,W		; save ASCII bit value
	movwf TRAMadd

	call JumpChip		; jump to RAM bits address on EEPROM

RbitLP	clrf PCLATH		; ROM page 0
	call EEread_A		; EEPROM read with ACK
	ThisPage

	movf EEdata,W
	xorlw '@'
	btfsc STATUS,Z
	goto NoBName		; end of ram addresses

	movf EEdata,W
	xorlw '%'
	btfss STATUS,Z
	goto RbitLP		; RAM bits start with %
;
; NEXT 3 DIGITS ARE RAM ADDRESS - 1st is RAM PAGE
;
	clrf PCLATH		; ROM page 0
	call EEread_A		; EEPROM read with ACK
	movwf Temp1
	ThisPage

	movlw d'48'		; convert to decimal
	subwf Temp1,W
	xorwf RAMpage,W
	btfss STATUS,Z
	goto RbitLP		; not selected ram page

	clrf PCLATH
	call EEread_A		; EEPROM read with ACK
	movwf Data1H
	call EEread_A		; EEPROM read with ACK
	movwf Data1L
	ThisPage
	call CompNum		; compares Data1H/L and Data2H/L
	btfss STATUS,Z
	goto RbitLP		; get another RAM address
;
; RAM ADDRESS MATCHED - GET BIT INFO
;
	movlw d'48'
	subwf TRAMadd,W		; convert ASCII bit value to decimal
	movwf Data1L

; %003,C,DC,Z,PD,TO,RP0,RP1,IRP^

	clrf PCLATH		; ROM page 0
	call EEread_A		; EEPROM read with ACK - skip 1st ','

TextFld	bsf STATUS,IRP
	clrf PCLATH
	call EEread_A		; EEPROM read with ACK	
	movwf INDF		; text data
	ThisPage

	movf EEdata,W
	xorlw '^'			; end of line
	btfsc STATUS,Z
	goto OFFbit		; must be bit 7 text

	movf EEdata,W
	xorlw ','			; end of text field
	btfsc STATUS,Z
	goto ChkFld

	incf FSR
	goto TextFld		; get next bit text

ChkFld	movf Data1L,W		; if = 0 then bit text is retrieved
	btfsc STATUS,Z
	goto OFFbit		; got text

	decf Data1L
	movf _FSR,W		; restore FSR
	movwf FSR
	goto TextFld
;
; NO BIT MATCH
;
NoBName	movf _FSR,W
	movwf FSR
	bsf STATUS,IRP
	movf TRAMadd,W
	movwf INDF
	goto RestPL

OFFbit	decf FSR			; ignore last comma that was put in buffer
	movf FSR,W
	movwf Temp1
	movf _FSR,W
	movwf FSR
	movf INDF,W
	xorlw '?'			; ? in 1st char = no bit defined
	btfsc STATUS,Z
	goto NoBName

	movf Temp1,W
	movwf FSR	

RestPL	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
	ThisPage
	return
;
; ---------------------------------------
; COMPARE THE NUMERS IN Data2H/L AND Data1H/L
; ---------------------------------------
;
CompNum	movf Data1H,W
	xorwf Data2H,W
	btfss STATUS,Z
	return			; no match Z = clear

	movf Data1L,W
	xorwf Data2L,W
	return			; z = set for a match, clear if not
;
; -----------------------------------------
; OUTPUT 1 INSTRUCTION BYTE IN W TO DISPLAY
; -----------------------------------------
; 4 bit mode only
;
LCDins2   clrf PCLATH
	call SwapNibs		; -> W
	movwf NibA
	movf PORTB,W
	andlw 0xF0
	movwf NibB
	swapf NibA,W
	andlw 0x0F
	iorwf NibB,W
	movwf PORTB
	bcf PORTA,lcdRS		; (2)
          call Clock
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)
          call Clock

	movf NibA,W
	andlw b'00001111'
	iorwf NibB,W
	movwf PORTB
          call Clock
          bsf PORTA,lcdE      	; (5) enable instruction
          call Clock
          bcf PORTA,lcdE      	; (5)

	call Delay6ms
	ThisPage
          return
;
; -----------------------------
; INSERT A SPACE IN TEXT BUFFER
; -----------------------------
;
_Space	movlw ' '			; space after text
	goto in_H
;
; -------------------------
; INSERT 'H' IN TEXT BUFFER
; -------------------------
;
_H	movlw 'h'			; 'h' after text
in_H	movwf INDF
	incf FSR
	return
; **********************************

	ORG 1800H

; **********************************
;
; ------------------------------------
; INCREMENT ID DATA AT CURSOR POSITION
; ------------------------------------
;
IDup	bsf Flag3,Up_Dn
	goto InIDUD
IDdn	bcf Flag3,Up_Dn
InIDUD	bsf Flag3,Mods
	ThisPage
	bcf STATUS,C
	rlf CurPos,W
	addwf PCL
	movlw Data1H
	goto UpDn10
	movlw Data1H
	goto UpDn1
	movlw Data1L
	goto UpDn10
	movlw Data1L
	goto UpDn1
	nop			; not used
	nop			; not used
	movlw Data2H
	goto UpDn10
	movlw Data2H
	goto UpDn1
	movlw Data2L
	goto UpDn10
	movlw Data2L
UpDn1	movwf FSR			; increment low nibble
	movf INDF,W
	andlw 0xF0
	movwf Temp5
	btfss Flag3,Up_Dn
	goto SubID1

	incf INDF,W
	goto Did1

SubID1	decf INDF,W
Did1	andlw 0Fh
	iorwf Temp5,W
	movwf INDF
	return

UpDn10	movwf FSR			; increment Hi nibble
	movlw 10h
	btfss Flag3,Up_Dn
	goto SubID10

	addwf INDF
	return

SubID10	subwf INDF
	return
;
; -------------------------
; SELECT FUSE OR ID DISPLAY
; -------------------------
;
FuseMode	clrf PCLATH

	call ListFiles
	btfss Flag2,OK
	goto TopMenu
;
; check rom/eep size against chip and file
;
	movlw High(CheckSize)
	movwf PCLATH
	call CheckSize
	clrf PCLATH
	btfss Flag2,OK
	goto TopMenu

InCnID	clrf PCLATH
	movlw 62h			; config
	call MessProc1
	movlw 63h			; ID
	call MessProc2
	call KeyReles		; wait for key release
	call HighLiteA		; put '<' on screen
;
; FUSE ID KEYPRESS
;
FIloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FIloop
	goto FIKey1
	goto FuseMode
	goto FIKey3
	goto FIKey4
;
; FUSE ID KEY 1
;
FIKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto FIloop
;
; FUSE ID KEY 3
;
FIKey3	btfss Flag2,FLayer
	goto FuseDisp		; display fuse data
;
; VIEW/CHANGE THE ID VALUE
;
	goto IDshow
;
; FUSE ID KEY 4
;
FIKey4	clrf PCLATH
	goto TopMenu
;
; --------------------------
; DISPLAY - MODIFY FUSE DATA
; --------------------------
; FUSE FORMAT
; @0OSC,0003+0000LP+0001XT+0002HS+0003RC^
; @ = fuse bit
; OSC = name
; 0003 = bit mask
; + = start of bit definitions
; 0000 = fuse bit option value (4 digits)
; LP = fuse bit option name
; ^ = end of fuse bit definition line
;
FuseDisp	btfss Flag4,FzC
	goto ModFuse

	clrf PCLATH
	movlw 9Dh			; fuse number
	call MessProc1
	call KeyReles		; wait for key release
ShowFzNm	clrf PCLATH
	movlw 0xC0
	call LCDins
	movf CurFuse,W
	call ToASCII
	call LCDout		; display current fuse to display
;
; FUSE NUMBER KEYPRESS
;
FzNloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FzNloop
	goto FzNKey1
	goto InCnID
	goto ModFuse
	goto FIKey4		; main menu
;
; FUSE NUMBER KEY 1
;
FzNKey1	incf CurFuse		; increment current fuse#
	btfsc CurFuse,2		; if = 4 = 0
	clrf CurFuse
	goto ShowFzNm
;
; ------------------------
; MODIFY THE SELECTED FUSE
; ------------------------
;
ModFuse	clrf PCLATH
	bcf STATUS,C
	rlf CurFuse,W
	addlw E_Fuse1		; Fuse x location
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
	call EEread_A
	movwf FuseH
	call EEread_N
	movwf FuseL
	ThisPage

	clrf FuseItem
	call NewFuse		; get fuse data
	clrf PCLATH
	call HighLiteA		; put '<' on screen
	ThisPage
;
; FUSE MODIFY KEYPRESS
;
FZloop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto FZloop
	goto FZKey1
	goto InCnID
	goto FZKey3
	goto FZKey4
;
; FUSE KEY 1
;
FZKey1	clrf PCLATH
	call HighLight
	ThisPage
	goto FZloop
;
; FUSE KEY 3
;
FZKey3	btfss Flag2,FLayer
	goto UpItems
;
; CHANGE THE FUSE OPTION NAME
;
	call NextItem		; display the next fuse option name
	goto FZloop
;
; CHANGE THE FUSE ITEM NAME
;
UpItems	incf FuseItem
	btfsc Flag4,end_fz
	clrf FuseItem
	call NewFuse
	clrf PCLATH
	call HighLiteA		; put '<' on screen
	ThisPage
	goto FZloop	
;
; FUSE KEY 4 - SAVE FUSE DATA
;
FZKey4	clrf PCLATH
	movlw 1Eh			; save fuse
	call MessProc1
	movlw 0xA0		; k1 = yes
	call MessProc2
;
; key1 = Yes, any other = No
;
	call AnyKey		; OK flag = 1 if Key 1 pressed
	ThisPage
	btfss Flag2,OK
	goto FIKey4		; no save - MAIN MENU
;
; SAVE FUSE DATA
;
	clrf PCLATH
	bcf STATUS,C
	rlf CurFuse,W
	addlw E_Fuse1		; Fuse x location
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartW
	movf FuseH,W
	call EEwriteBC 		; save H
	movf FuseL,W
	call EEwriteBC 		; save L
	call EEstop
	goto TopMenu
;
; --------------------------------
; GET FUSE DEFINITIONS INTO BUFFER
; --------------------------------
;
NewFuse	bcf Flag4,end_fz
	clrf PCLATH
	call JumpChip		; jump to chip data address on EEPROM
	ThisPage
	clrf Temp5

FindNext@	clrf PCLATH
	call EEread_A		; try to find '@' or '/' char
	ThisPage

	movf EEdata,W		; @ = fuse data line
	xorlw '@'
	btfsc STATUS,Z
	goto Ex@

	movf EEdata,W
	xorlw '!'
	btfsc STATUS,Z
	goto NoFuse		; end of data

	movf EEdata,W
	xorlw '['			; test for '['
	btfsc STATUS,Z
	goto NoFuse		; start of next chip data

	movf EEdata,W		; / = last text line of fuse data
	xorlw '/'
	btfss STATUS,Z
	goto FindNext@

	call FuzNumMch		; test if this fuse number matches selected fuse number
	btfss Flag2,OK
	goto FindNext@

	bsf Flag4,end_fz
	goto Got@

Ex@	call FuzNumMch		; test if this fuse number matches selected fuse number
	btfss Flag2,OK
	goto FindNext@

	movf Temp5,W		; do until item is found
	xorwf FuseItem,W
	btfsc STATUS,Z
	goto Got@

	incf Temp5
	goto FindNext@

Got@	movlw Low(EepBuff)
	movwf FSR
	bsf STATUS,IRP
;
; PUT FUSE DATA FOR THIS ITEM INTO BUFFER
;
In@	clrf PCLATH
	call EEread_A		; fuse data
	movwf INDF
	incf FSR
	ThisPage

	movf EEdata,W		; end of line
	xorlw '^'
	btfss STATUS,Z
	goto In@

	clrf PCLATH
	call EEread_N		; EEPROM read & stop without ACK - ignore data
;
; DISPLAY FUSE NAME
; OSC,0003+0000LP+0001XT+0002HS+0003RC^
;
	call ClearDisp
	movlw 80h
	call LCDins		; LCD start of first line

	movlw Low(EepBuff)
	movwf FSR
	ThisPage

FuseNM	movf INDF,W
	xorlw ','			; end of fuse name
	btfsc STATUS,Z
	goto DoMask

	clrf PCLATH
	movf INDF,W
	call LCDout

	incf FSR
	ThisPage
	goto FuseNM
;
; GET MASKED FUSE VALUE
;
DoMask	incf FSR
	call WordToHex		; mask value -> Data1H/L
	movf FuseH,W
	andwf Data1H,W
	movwf Temp3
	movf FuseL,W
	andwf Data1L,W
	movwf Temp4
;
; FIND THE FUSE OPTION THAT MATCHES MASKED FUSE
;
	incf FSR			; points to 1st '+'

FindPlus	movf INDF,W
	xorlw '+'
	btfsc STATUS,Z
	goto GotPlus

	movf INDF,W
	xorlw '^'
	btfsc STATUS,Z
	goto FuseError		; can't match the data

	incf FSR
	goto FindPlus

GotPlus	movf FSR,W		; save char index of this item
	movwf OptIndex

	incf FSR
	call WordToHex		; fuse option value -> Data1H/L

	movf Temp3,W
	xorwf Data1H,W
	btfss STATUS,Z
	goto FindPlus		; no match

	movf Temp4,W
	xorwf Data1L,W
	btfss STATUS,Z
	goto FindPlus		; no match

	incf FSR			; points to option name
	call OptName		; display the option name

	call DispFuse		; display fuse value
	bcf STATUS,IRP
	return			; done
;
; ---------------------------------------------------------
; SEE IF MATCH BETWEEN FUSE NUMBER AND SELECTED FUSE NUMBER
; ---------------------------------------------------------
;
FuzNumMch	bcf Flag2,OK
	clrf PCLATH
	call EEread_A
	movlw 30h
	subwf EEdata,W		; convert ASCII to decimal		
	xorwf CurFuse,W
	btfsc STATUS,Z
	bsf Flag2,OK		; is a match
	ThisPage
	return
;
; ---------------------------
; CANT MATCH FUSE WITH OPTION
; ---------------------------
;
NoFuse	bsf Flag2,OK
	goto InFE
FuseError	bcf Flag2,OK
InFE	clrf PCLATH
	bcf STATUS,IRP
	call EEread_N
	movlw 9Eh			; fuse data error
	btfsc Flag2,OK
	movlw 9Bh			; not available
	call MessProc1
	movlw 12h			; press any key
	call MessProc2

	call AnyKey		; OK flag = 1 if Key 1 pressed
	call KeyReles
	goto TopMenu
;
; --------------------------------------------
; MOVE TO NEXT FUSE OPTION - ADJUST FUSE VALUE
; --------------------------------------------
; OSC,0003+0000LP+0001XT+0002HS+0003RC^
;
NextItem	incf OptIndex,W		; 1 past start of current option (+)
	movwf FSR
	bsf STATUS,IRP

FusecFZ	movf INDF,W
	xorlw '+'			; go until end of curent item
	btfsc STATUS,Z
	goto GotFN

	movf INDF,W
	xorlw '^'			; or end of fuse options
	btfsc STATUS,Z
	goto GotEFN

	incf FSR
	goto FusecFZ

GotEFN	movlw Low(EepBuff)		; start back at first item
	movwf FSR

FirstPL	movf INDF,W
	xorlw '+'			; move to 1st '+' char
	btfsc STATUS,Z
	goto GotFN

	incf FSR
	goto FirstPL

GotFN	movf FSR,W		; points to start of new item
	movwf OptIndex

	incf FSR
	call WordToHex		; Option value
	movf Data1H,W
	movwf InstrH
	movf Data1L,W
	movwf InstrL
;
; DISPLAY THE NAME
;
	incf FSR
	call OptName
;
; SKIP FUSE NAME
;
	movlw Low(EepBuff)
	movwf FSR

Fusma	movf INDF,W
	xorlw ','			; end of fuse name
	btfsc STATUS,Z
	goto GotMsk

	incf FSR
	goto Fusma
;
; GET MASK VALUE
;
GotMsk	incf FSR
	call WordToHex		; Mask value

	movlw 0xFF		; negate mask
	xorwf Data1H,W
	andwf FuseH,W		; zero the affected fuse bits H
	iorwf InstrH,W		; change new bits to 1 if new valueH sets them
	movwf FuseH

	movlw 0xFF
	xorwf Data1L,W
	andwf FuseL,W		; zero the affected fuse bits L
	iorwf InstrL,W		; change new bits to 1 if new valueL sets them
	movwf FuseL

	call DispFuse		; display fuse value
	bcf STATUS,IRP
	return
;
; -------------------
; DISPLAY OPTION NAME
; -------------------
; OSC,0003+0000LP+0001XT+0002HS+0003RC^
;
OptName	clrf PCLATH
	movlw 0xC0
	call LCDins		; LCD start of 2nd line
	ThisPage

	clrf MessPt
;
; FSR POINTS TO 1ST OPTION NAME CHAR - eg. L in LP
;
DisName	movf INDF,W
	xorlw '+'
	btfsc STATUS,Z
	goto Optspc
	
	movf INDF,W
	xorlw '^'
	btfsc STATUS,Z
	goto Optspc

	clrf PCLATH
	movf INDF,W
	call LCDout
	ThisPage
	incf FSR
	incf MessPt
	goto DisName
;
; WRITE SOME SPACES TO COVER ANY TEXT PAST NAME
;
Optspc	clrf PCLATH
	movlw ' '
	call LCDout
	incf MessPt
	ThisPage
	movlw d'14'
	xorwf MessPt,W
	btfss STATUS,Z
	goto Optspc
	return
;
; -----------------------------
; CONVERT HEX ASCII DATA TO HEX
; -----------------------------
;
WordToHex	movf INDF,W
	movwf Data2H
	incf FSR
	movf INDF,W
	movwf Data2L
	clrf PCLATH
	call HEX_dec
	movwf Data1H

	incf FSR
	movf INDF,W
	movwf Data2H
	incf FSR
	movf INDF,W
	movwf Data2L
	call HEX_dec
	movwf Data1L
	ThisPage
	return	
;
; ----------------------
; DISPLAY FUSE HEX VALUE
; ----------------------
;
DispFuse	clrf PCLATH
	movlw 0xCA
	call LCDins
	swapf FuseH,W
	call ToASCII
	call LCDout

	movf FuseH,W
	call ToASCII
	call LCDout

	swapf FuseL,W
	call ToASCII
	call LCDout

	movf FuseL,W
	call ToASCII
	call LCDout

	ThisPage
	return
;
; ---------------------------------
; DISPLAY AND MODIFY ID INFORMATION
; ---------------------------------
;
IDshow	clrf PCLATH		; get ID data from I2C EEPROM
	movlw E_ID1
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartR
	call EEreadBC
	movwf Data1H
	call EEreadBC
	movwf Data1L
	call EEreadBC
	movwf Data2H
	call EEreadBC
	movwf Data2L
	call EEread_N
	ThisPage

	call DispIDV
	call IDmodify
;
; SAVE ID DATA ?
;
	btfss Flag3,Mods		; check data modified flag
	goto FuseMode

	movf KeyTemp,W		; yes check if last keypress was = 4
	xorlw 4h
	btfss STATUS,Z
	goto FuseMode		; no
	
	clrf PCLATH
	movlw E_ID1
	call SetCdAddH		; set CodeAddH for code start address
	call BCstartW
	movf Data1H,W		; ID 1 H
	call EEwriteBC
	movf Data1L,W		; ID 1 L	
	call EEwriteBC
	movf Data2H,W		; ID 2 H
	call EEwriteBC
	movf Data2L,W		; ID 2 L	
	call EEwriteBC
	call EEstop
	ThisPage
	goto FuseMode
;
; ------------------
; MODIFY AN ID VALUE
; ------------------
;
IDmodify	movlw 4h			; 1 ID location
	btfsc Flag4,IdC
	movlw 9h			; 2 ID locations
	movwf IDCurMax		; max cursor movement

	clrf CurPos
	bcf Flag3,Mods

IDDLoop	clrf PCLATH
	call KeyRepeat
	ThisPage
	movf KeyTemp,W
	addwf PCL
	goto IDDLoop
	goto IDDKey1
	goto IDDKey2
	goto IDDKey3
	goto IDDKey4
;
; Key #1
;
IDDKey1	movf CurPos,W
	xorwf IDCurMax,W
	btfsc STATUS,Z
	return

	call IDup			; ID data field change up
	goto NewID
;
; Key #2
;
IDDKey2	bcf Flag3,Up_Dn
	decf CurPos		; shift cursor left
	btfss CurPos,7
	goto SetCRP

	movf IDCurMax,W
	movwf CurPos
	goto SetCRP
;
; Key #3
;
IDDKey3	bsf Flag3,Up_Dn
	incf CurPos		; shift cursor right
	movf IDCurMax,W
	addlw 1h
	xorwf CurPos,W
	btfsc STATUS,Z
	clrf CurPos
SetCRP	call DoIDCR
	goto IDDLoop
;
; Key #4
;
IDDKey4	movf CurPos,W
	xorwf IDCurMax,W
	btfsc STATUS,Z
	return

	call IDdn			; ID data field change down
NewID	call DispID
	goto IDDLoop
;
; --------------------
; ID MODE SHIFT CURSOR
; --------------------
;
DoIDCR	clrf PCLATH
	movlw 0Ch           	; cursor = off
	call LCDins
	ThisPage

	btfss Flag4,IdC
	goto No2ID

	movf CurPos,W		; if 2 ID locs and if CurPos = 4 then move it
	xorlw 4h			; to skip space in between
	btfss STATUS,Z
	goto No2ID

	movlw 0xFF		; shift extra 1 left
	btfsc Flag3,Up_Dn
	movlw 1h			; shift extra 1 right
	addwf CurPos
	goto DispID

No2ID	movf CurPos,W
	xorwf IDCurMax,W
	btfss STATUS,Z
	goto DispID

	clrf PCLATH		; save data or exit ID mode
	call LCDins
	movlw 0Fh			; k1 = main menu
	call MessProc1
	ThisPage
	btfss Flag3,Mods		; check data modified flag
	goto ExIDst

	clrf PCLATH
	movlw 2Ah			; k4 = save change
	call MessProc2

ExIDst	ThisPage
	return			; keypress in KeyTemp
;
; RE-DISPLAY ID DATA
;
DispID	call DispIDV
;
; SET CURSOR POSITION
;
	movf CurPos,W
	addlw 0xC0
	clrf PCLATH
	call LCDins
	movlw 0Eh           	; display = on, cursor = on
	call LCDins
	ThisPage
	return
;
; --------------------
; DISPLAY THE ID VALUE
; --------------------
; values in Data1H/L Data2H/L
;
DispIDV	clrf PCLATH
	movlw 63h			; ID
	call MessProc1
	movlw 0xC0
	call LCDins
	movlw Data1H
	movwf FSR

DIdLP	clrf PCLATH
	swapf INDF,W
	call ToASCII
	call LCDout
	movf INDF,W
	call ToASCII
	call LCDout
	ThisPage

	incf FSR
	movlw Data2H
	xorwf FSR,W
	btfss STATUS,Z
	goto IDlast

	btfss Flag4,IdC		; 1 or 2 ID locs
	goto EndID

	clrf PCLATH
	movlw ' '
	call LCDout
	ThisPage
	goto DIdLP

IDlast	movlw Data2L + 1
	xorwf FSR,W
	btfss STATUS,Z
	goto DIdLP

EndID	clrf PCLATH
	movlw 0xC0		; reset cursor to 1st line 2nd char
	call LCDins
	movlw 0Eh           	; cursor = on
	call LCDins
	ThisPage
	return
;
; ----------
; INITIALIZE
; ----------
;
_Init	movlw 20h			; 25mS powerup delay @ 4MHz
	movwf DelayH		; data sheet says 15mS
	clrf DelayL
PUPD	decfsz DelayL
	goto PUPD
	decfsz DelayH
	goto PUPD
;
; -----------------
; SEND CONTROL DATA
; -----------------
;
	clrf MessPt
	bsf Flag1,LCDmd		; do 8 bit mode to start

iLoop	clrf PCLATH
	movf MessPt,W
	call _lcd
	movwf Data2H	
	xorlw 28h
	btfsc STATUS,Z
	bcf Flag1,LCDmd		; do 4 bit mode from now on

	movf Data2H,W
          call LCDins         	; output to display

	ThisPage
	incf MessPt
	movf Data2H,W
	xorlw 0Ch
	btfss STATUS,Z
          goto iLoop
;
; ENABLE A2D
;
	movlw b'01000001'   	; A2D = 0n, Ch0, FOsc/8
	movwf ADCON0

	clrf PCLATH
	call EEstop		; make sure EEPROMs are initialized
;
; START TIMER 0
;
	bsf STATUS,RP0		; RAM page 1
	movlw 87h
	movwf OPTION_REG
;
; SET UP PWM
;
	movlw d'55'
	movwf PR2			; 4464 Hz PWM
	bcf STATUS,RP0		; RAM page 0
	movlw b'00000001'		; PreScale = 4, TMR2 = off
	movwf T2CON

	movf RCREG,W		; flush receive
	movf RCREG,W
	movf RCREG,W
	return
;
; ---------------------------------------------------
; PROGRAMMER MODE - WAITING FOR A COMMAND FROM THE PC
; ---------------------------------------------------
;
LWaitCom	
	clrf PCLATH	
	movlw 56h			; run PocketPro
	call MessProc1
	movlw 12h
	call MessProc2		; Press any key
	call AnyKey

PINGmp	
	movlw 'P'			; announce PocketPro
	movwf TXREG
	movwf TXREG

	clrf PCLATH	
	call Receive		; wait for ack - 1 second

	movlw 30h			; Pocket Pro mode
	call MessProc1
	ThisPage

LWaitCm	
	call ReceiveM		;Wait for the PC to send a byte
	xorlw 0h				
	btfsc STATUS,Z
	goto PgmrMode		;	0: goto PgmrMode	(programmer mode)
							;	1: goto PINGmp	(reannounce pocketpro)		
	movf RxHold,W		;	default:	wait for another byte
	xorlw 1h	
	btfss STATUS,Z
	goto LWaitCm		; wait for another byte
	goto PINGmp			; reannounce pocketpro 

PgmrMode  
	bcf Flag2,TimeLS	; now = short delay
	call ReceiveM		; get prog speed for 16F87x devices.
	xorlw '0'
	btfss STATUS,Z
	bsf Flag2,TimeLS	; now = long delay	

	movlw 'P'			; confirm Programmer command
	movwf TXREG
	clrf Flag5			; initialise Flag registers
	clrf Flag3
	clrf PORTB			; make sure RB6/7 = lo

PWaitCom	
	call ReceiveM		; wait and read from RS232
	ThisPage
	movf RxHold,W
	andlw 0Fh
	addwf PCL
	goto PWaitCom		; 0 = PgmCommand = ignore it
	goto DoQuitX		; 1 = VppOnOff = error
	goto SetVVolt		; 2 = VccOnOff
	goto ProgVer		; 3 = ProgROM
	goto ProgVerE		; 4 = ProgEROM
	goto ReadcROM		; 5 = ReadROM
	goto DoFuse			; 6 = ProgFuse
	goto DoFuseE		; 7 = ProgEFuse
	goto RdFuse			; 8 = ReadFuse
	goto ReadEEm		; 9 = ReadEMem
	goto Ewrite			; 10 = WriteEMem
	goto ErCheck		; 11 = IsErased
 	goto EraseAll		; 12 = EraseAll
  	goto QuitU			; 13 = QuitNoRes
  	goto DoQuit			; 14 = QuitProg
; error 15
;
; ----------------------------
; PC IS CLOSING COMMUNICATIONS
; ----------------------------
;
DoQuitX   
	movlw 'X'			; send back serial character error
	goto sendQD
DoQuit
	movlw 'Q'			; send back quit comms
sendQD
	movwf TXREG
QuitU     
	movlw High(VoltsOFF)
	movwf PCLATH
	call VoltsOFF
	call Dl12Pg1
	ThisPage
	movf RCREG,W		; flush receive buffer
	movf RCREG,W
	movf RCREG,W
	goto LWaitCm		; wait for initial command
;
; ---------------
; TURN OFF/ON VCC
; ---------------
;
SetVVolt	
	call ReceiveM
	movwf VPPtype
	movlw High(VoltsON5)
	movwf PCLATH
	call VoltsON5
	ThisPage

FinVcc    movlw 'Y'			; send back programming confirmation
          movwf TXREG
          goto PWaitCom		; wait for next command
;
; --------------------------------------------------
; PROGRAM AND VERIFY THE ROM SECTION OF A 14 BIT PIC
; --------------------------------------------------
; This routine receives 16 bytes of data from the host PC to program into
; the PIC.
;
; 'M' sent     = request more data
; 'Y' returned = more data follows
; 'N' returned = no data follows
; 'F' sent     = programming failure followed by current address
;
ProgVerE  bsf Flag3,Etype      ; (7) EEprom style of chip
          goto InProgV
ProgVer   bcf Flag3,Etype     ; (7) ROM style of chip
InProgV   clrf ProgAddH       ; initialise current program address
          clrf ProgAddL

	movlw 'M'           ; request 16 bytes of data
          movwf TXREG
;
; GET 2 BYTES OF DATA
; IF = DataH = FFh then end of data
;
ProgMore	
	clrf PCLATH
	call Receive	; data H
	movwf Data1H
	call Receive	; data L
	movwf Data1L
	movlw High($)
	movwf PCLATH

	movf Data1H,W
	xorlw 0xFF
	btfsc STATUS,Z
	goto QuitU          ; no more data

	movlw 'M'		; request more data
	movwf TXREG

	call ProgNLoc
	xorlw 0h
	btfsc STATUS,Z
	goto PrFail

	movlw High(Command)
	movwf PCLATH
	movlw b'00000110'   ; Increment Address command = 000110
	call Command        ; send it 
	ThisPage

	incf ProgAddL
	btfsc STATUS,Z
	incf ProgAddH
	goto ProgMore       ; prog next location
;
; PROGRAMMING FAILED
; Send back programming failed response with current address
;
PrFail    movlw 'F'           ; inform PC of program failure
          movwf TXREG
          call TransWt4       ; wait until 'F' is sent

          movf ProgAddH,w     ; now send current address
          movwf TXREG
          movf ProgAddL,w
          movwf TXREG
          goto QuitU
;
; -----------------------------------------
; PROGRAM ROM DATA if not blank data (3FFF)
; -----------------------------------------
;
ProgNLoc  movf Data1H,w
          xorlw 3Fh
          btfss STATUS,Z
          goto DoProg

          movf Data1L,w
          xorlw 0xFF
          btfsc STATUS,Z
          retlw 0xFF	; data = 3FFF - ignore - OK

DoProg    
	clrf ProCycs        ; reset programming cycles counter
ProgLoop	
	movlw High(ProgLoc)
	movwf PCLATH
	call ProgLoc        ; program new data
	incf ProCycs        ; increment programming count
;
; NOW VERIFY IT
;          
	call ReadROM        ; read back data
	ThisPage

	movf ROMTmpH,w      ; set during ReadROM
	xorwf Data1H,w
	btfss STATUS,Z     
	goto NoVerify

	movf ROMTmpL,w      ; set during ReadROM
	xorwf Data1L,w
	btfsc STATUS,Z
	goto IsVerify

NoVerify  btfsc Flag3,Etype    ; (7) test if ROM or EEPROM type
          retlw 0h		; error

          movlw d'25'
          xorwf ProCycs,w
          btfss STATUS,Z
          goto ProgLoop       ; program location again
	retlw 0h		; error
;
; DO 3 TIMES OVER PROGRAMMING
;
IsVerify  btfsc Flag3,Etype    ; (7) test if ROM or EEPROM type
          retlw 0xFF	; OK
                              
          movf ProCycs,w
          bcf STATUS,C
          rlf ProCycs
          addwf ProCycs

ProgVerf	movlw High(ProgLoc)
	movwf PCLATH
	call ProgLoc        ; program new data
	ThisPage
          decfsz ProCycs
          goto ProgVerf       ; continue
	retlw 0xFF	; OK
;
; -----------------------------
; READ THE ROM SECTION OF A PIC
; -----------------------------
; Send back 8 ROM words to PC
;
ReadcROM  movlw 8h
          movwf ICount

ContRd    movlw High(ReadROM)
	movwf PCLATH
	call ReadROM
	ThisPage

          movf ROMTmpH,W
          movwf TXREG
          movf ROMTmpL,W
          movwf TXREG

          call IncAddrR		; increment address

          call TransWt4		; wait for data to be sent

          decfsz ICount
          goto ContRd

          goto PWaitCom		; wait for new PC command
;
; ---------------------
; INCREMENT PIC ADDRESS
; ---------------------
;
IncAddrR  movlw High(Command)
	movwf PCLATH
	movlw b'00000110'		; Increment Address command = 000110
          call Command		; send it
	ThisPage
          incf ProgAddL
          btfsc STATUS,Z
          incf ProgAddH
          return
;
; ---------------
; ROM ERASE CHECK
; ---------------
;
ErCheck   
	clrf ProgAddH		; clear address counters
	clrf ProgAddL

	call ReceiveM		; get ROM count
	movwf RmSizeH
	call ReceiveM
	movwf RmSizeL

compLP    
	movlw High(ReadROM)
	movwf PCLATH
	call ReadROM
	ThisPage

	movf ROMTmpH,W		; if = 3FFF then blank
	xorlw 3fh
	btfss STATUS,Z
	goto NotBlnkR		; ROM not blank

	movf ROMTmpL,W
          xorlw 0xFF
          btfss STATUS,Z
          goto NotBlnkR		; ROM not blank

          call IncAddrR		; increment the PIC address

          movf ProgAddH,W
          xorwf RmSizeH,W
          btfss STATUS,Z
          goto compLP		; not all done yet

          movf ProgAddL,W
          xorwf RmSizeL,W
          btfss STATUS,Z
          goto compLP

	call RdFuse		; sets Data2H/L and ROMTmpH/L

          movf Data2H,W		; if = 3FFF then ID blank
          xorlw 0xFF
          btfss STATUS,Z
          goto NotBlnkI		; ID not blank

          movf Data2L,W
          xorlw 0xFF
          btfss STATUS,Z
          goto NotBlnkI		; ID not blank

          movf ROMTmpH,W		; if = 3FFF then fuse blank
          xorlw 3Fh
          btfss STATUS,Z
          goto NotBlnkF		; Fuse not blank

          movf ROMTmpL,W
          xorlw 0xFF
          btfss STATUS,Z
          goto NotBlnkF		; Fuse not blank

IzBlnk    movlw 'Y'			; blank test successful
          goto VoltOff

NotBlnkR  movlw 'R'			; ROM not blank
          goto VoltOff

NotBlnkI  movlw 'I'			; ID not blank
          goto VoltOff

NotBlnkF  movlw 'F'			; FUSE not blank

VoltOff   movwf TXREG
	movlw High(VoltsOFF)
	movwf PCLATH
	call VoltsOFF
	ThisPage
	goto PWaitCom		; finished
;
; ---------
; READ FUSE
; ---------
;
RdFuse    movlw High(ReadID)
	movwf PCLATH
	call ReadID		; -> Data2H/L PIC address = 2007 on return
	call ReadROM        	; read fuse
	ThisPage

	movf Data2H,W		; ID
	movwf TXREG
	movf Data2L,W
	movwf TXREG

	call TransWt4		; wait for data to be sent

	movf ROMTmpH,W		; FUSE
	movwf TXREG
	movf ROMTmpL,W
	movwf TXREG
	goto PWaitCom
;
; --------------------
; PROGRAM FUSE COMMAND
; --------------------
;
DoFuseE   bsf Flag3,Etype		; (7) programming EEPROM type fuse
          goto InFus
DoFuse    bcf Flag3,Etype		; (7) ROM style of chip
InFus     call ReceiveM		; get unformatted fuse data
          movwf InsDataH
          call ReceiveM
          movwf InsDataL
	call ReceiveM		; get ID data
	movwf Data2H
	call ReceiveM
	movwf Data2L

	movlw High(LoadCfig)
	movwf PCLATH
	call LoadCfig		; Load Configuration Command
	call MprogID		; program the ID locations
	ThisPage
	btfss Flag2,OK
	goto NotBlnkI
;
; NOW PROGRAM FUSE
;
	call IncAddrR		; increment to 2007h
	call IncAddrR
	call IncAddrR

	movlw 1h
	btfss Flag3,Etype		; (7) test if ROM or EEPROM type
          movlw d'100'
          movwf Temp1

; program ROM type Fuse with data 100 times

FuseProg	movf InsDataH,W
	movwf Data1H
	movf InsDataL,W
	movwf Data1L
	movlw High(ProgLoc)
	movwf PCLATH
	call ProgLoc
	ThisPage
          decfsz Temp1
          goto FuseProg

; Read Fuse data to verify it

VerFuz    movlw High(ReadROM)		; verify the data just programmed into ROM
	movwf PCLATH
	call ReadROM
	ThisPage

          movf ROMTmpH,W		; set during ReadROM

          xorwf InsDataH,W
          btfss STATUS,Z     
          goto NotBlnkF

          movf ROMTmpL,W		; set during ReadROM
          xorwf InsDataL,W
          btfss STATUS,Z
          goto NotBlnkF
	goto IzBlnk
;
; ----------------------------------
; ERASE ALL FOR EEPROM BASED DEVICES
; ----------------------------------
;
EraseAll  call ReceiveM		; get VPP value
          movwf VPPtype

          call ReceiveM		; eeprom size
          movwf EEsizeH

          call ReceiveM
          movwf EEsizeL

	movlw High(BulkECode)
	movwf PCLATH
	call BulkECode
	ThisPage

          clrf ProgAddH		; reset address counters
          clrf ProgAddL

          movlw 'Y'
          movwf TXREG
          goto PWaitCom
;
; ---------------------------
; WRITE TO EEPROM DATA MEMORY
; ---------------------------
;
Ewrite    clrf Temp6
          bsf Flag5,NAInc		; (6) no address increment on read
InEwrt    movlw 'M'			; ask for data
          movwf TXREG

          call ReceiveM
          xorlw 'Y'
          btfss STATUS,Z
          goto QuitU

          movlw 8h
          movwf CCount
          movlw Buffer
          movwf FSR

getEEdt   call ReceiveM		; get eeprom byte
          movwf INDF
          incf FSR
          decfsz CCount
          goto getEEdt

          movlw Buffer
          movwf FSR
          movlw 8h
          movwf CCount

; SEND DATA TO PIC

Doawrt    movf INDF,W
	movwf Data1L
	movlw High(WrEeprom)
	movwf PCLATH
	call WrEeprom		; write the data to data eeprom
	ThisPage

; VERIFY PROGRAMMED DATA
          
          call ReadEEm		; -> W
          xorwf INDF,W
          btfss STATUS,Z
          goto VerEr

          incf FSR
          incf Temp6
          call IncAddrR		; increment the PIC address
          decfsz CCount
          goto Doawrt
          goto InEwrt		; get more data

VerEr     movlw 'N'
          movwf TXREG
          movf Temp6,W		; send current eeprom address
          movwf TXREG
          goto PWaitCom
;
; ---------------------------------
; READ DATA FROM EEPROM DATA MEMORY
; ---------------------------------
;
ReadEEm   
	movlw 8h
	movwf ACount

ContEe
	movlw High(Command)
	movwf PCLATH
	movlw b'00000101'		; Read EEPROM Data Command
	call Command		; send it
	ThisPage

	bcf PORTC,HiZ		; data out pin = HiZ
	call ClkDelayM

	movlw d'16'			; 16 EEPROM data bits to read
	movwf ICount

ReadEpm
	bsf PORTB,Clk		; (6) PIC clock = Logic 1 gets data from PIC
	call ClkDelayM

	bcf PORTB,Clk		; (6) Clock bit = Logic 0
	call ClkDelayM

	bcf STATUS,C		; set carry bit = incoming data bit
	btfss PORTB,DataR		; (4) read data bit = inverted
	bsf STATUS,C

	rrf ROMTmpH		; shift carry into data regs
	rrf ROMTmpL

	decfsz ICount		; do until all bits are sent
	goto ReadEpm

	bcf STATUS,C		; shift 14 bit data across to compensate for
	rrf ROMTmpH		; the start bit that was read from the PIC
	rrf ROMTmpL

	bsf PORTC,HiZ		; data out pin = out
	call ClkDelayM

	movf ROMTmpL,W
	btfsc Flag5,NAInc		; (6) no increment if = 1
	return

	movwf TXREG
	call IncAddrR		; increment address
	call TransWt4		; wait for data to be sent

	decfsz ACount
	goto ContEe
	goto PWaitCom		; wait for new PC command
;
; --------------------------------------
; SMALL DELAY FOR CLOCKING DATA INTO PIC
; --------------------------------------
;
ClkDelayM nop
	nop
	nop
          return
;
; ----------------------------------------
; RECEIVE CHARACTER FROM RS232 OR INTERNAL
; ----------------------------------------
; This routine does not return until a character is received.

ReceiveM	nop
          btfss PIR1,RCIF		; (5) check for received data
          goto ReceiveM

          movf RCREG,W
          movwf RxHold		; tempstore data
          return
;
; ------------------------------------
; WAIT UNTIL RS232 IS FINISHED SENDING
; ------------------------------------
;
TransWt4	bsf STATUS,RP0
WtHere4	btfss TXSTA,TRMT		; (1) transmission is complete if hi
	goto WtHere4

	clrf STATUS		; RAM Page 0
	return
;
; -----------------------
; BOOT CODE START ADDRESS
; -----------------------
; DO NOT PLACE ANY CODE PAST THIS POINT
;
	org 0x1F00

MonCode

	org 0x1FFF

EnterBoot
;
;
	end
