*---------------------------------------------------------------------
*
*  LINK.CMD
*     Place the track, sector of the specified file (typically the
*     FLEX system file (e.g., DOS.SYS) into bytes 5 and 6 of the 
*     boot loader present on the first sector of track 0
*
*     Mike Douglas, November 2022
*
*---------------------------------------------------------------------
BOOTSEC	equ	1		;boot sector number to patch

* FLEX equates

SYSFCB	equ	$A840		;FLEX system FCB
FMS	equ	$B406		;entry point for FMS calls
FMSCLS	equ	$B403		;close all files
WARMS	equ	$AD03		;FLEX re-entry address
PSTRNG	equ	$AD1E		;display string on console
GETFIL	equ	$AD2D		;build FCB from command line parameter
SETEXT	equ	$AD33		;set default extension
RPTERR	equ	$AD3F		;report error from the FCB
EOT	equ	$04		;end of string for PSTRNG

* FMS equates

OPENRD	equ	$01		;open for read
OPENWRT	equ	$02		;open for write
READSEC	equ	$09		;read a sector
WRTSEC	equ	$0A		;write a sector

* Offsets into the FMS file control block (FCB)

fcbCMD	equ	0		;FMS command
fcbERR	equ	1		;error status
fcbSTRK	equ	17		;start track of file
fcbSSEC	equ	18		;start sector of file
fcbCTRK	equ	30		;track of current file position
fcbCSEC	equ	31		;sector of current file position
fcbSBUF	equ	64		;start of sector buffer in FCB

	org	$A100

entry	bra	start
	fcb	1		;version number

start	ldx	#SYSFCB		;get file name from command line
	jsr	GETFIL
	bcs	badFile		;invalid file name format

	ldx	#SYSFCB		;set a default .SYS extension
	ldaa	#4
	jsr	SETEXT

	ldx	#SYSFCB		;open the file for read
	ldaa	#OPENRD
	staa	fcbCMD,x
	jsr	FMS
	bne	openErr		;file open error

	clr	fcbCTRK,x	;read BOOTSEC from track 0
	ldaa	#BOOTSEC
	staa	fcbCSEC,x
	ldaa	#READSEC
	staa	fcbCMD,x
	jsr	FMS
	bne	sysErr		;report a disk error

	ldaa	fcbSTRK,x	;A=track num of specified FLEX file
	ldab	fcbSSEC,x	;B=sector num of specified FLEX file
	staa	fcbSBUF+5,x	;set track in the boot loader
	stab	fcbSBUF+6,x	;set sector in the boot loader

	ldaa	#WRTSEC		;update the loader on disk
	staa	fcbCMD,x
	jsr	FMS
	beq	pgmExit		;close files and exit

*----------------------------------------------------------------
*  File/disk error processing
*----------------------------------------------------------------
openErr	ldaa	fcbERR,x	;A=error code
	cmpa	#$04		;file not found?
	beq	notFnd

	cmpa	#$40		;write protect error?
	bne	sysErr		;no, report some other error

	ldx	#mWrtPrt	;disk write protected?
	bra	dspExit		;display message and exit

notFnd	ldx	#mNotFnd	;file not found
	bra	dspExit

badFile	ldx	#mBadFil	;invalid file name

dspExit	jsr	PSTRNG		;display error message
	bra	pgmExit

sysErr	jsr	RPTERR		;let system report the error

* pgmExit - Close open FCB and warm start FLEX

pgmExit	jsr	FMSCLS
	jmp	WARMS

*----------------------------------------------------------------
*  Message constants
*----------------------------------------------------------------
mNotFnd	fcc	"NO SUCH FILE"
	fcb	EOT

mBadFil	fcc	"ILLEGAL FILE NAME"
	fcb	EOT

mWrtPrt	fcc	"DISK IS PROTECTED"
	fcb	EOT
	
	end	entry