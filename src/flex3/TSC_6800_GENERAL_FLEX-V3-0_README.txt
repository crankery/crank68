This archive contains disk images and documentation for 6800 GENERAL FLEX V3.0
The manuals are PDFs of the paper documents supplied with the distribution disks.

GENERAL FLEX does not include console or disk drivers which must be user supplied.
The disk images therefore only have a FLEX.COR file. There is only one source
disk, the IMD file is in Dave Dunfield's format and with a suitable PC a near
exact copy of the original disk can be produced. The DSK file is normal FUFU
format. The images are "distribution format" single sided, single density,
10 sectors per track and 35 tracks.

This package came from TSC and not SWTPC, therefore it uses conventional sector
numbering and as far as I know has no SWTPC "quirks". The first sector on track
zero is sector one. LINK will be updating track 0 sector 1, NEWDISK will write
the boot sector to track 0 sector 1 as will PUTLDR. If you want to use this with
SWTBUG, you will have to alter at least these programs (or perhaps substitute
SWTPC versions).

I have original TSC 6809 GENERAL FLEX V3.01 disks, but I don't have a copy of
the original 6800 V3.0 disks. The attached disk image is my best guess of the
original based on the contents of the 6809 version. One thing I copied from the
6809 disk is the 1st sector of track 0 which is filled with bytes from 00 to FF
rather than a boot loader. This was intended as known data to prove a sector
read was successful. FLEX.COR starts track 1 sector 1 like the 6809 disk.

Due to the similarities between the GENERAL FLEX V3.01 6809 and this 6800
version I wonder if 6809 changes were back ported. For both of them if you use
the MAP command on FLEX.COR there are sections that overlay each other in memory
where there is a copyright message. I'm not sure what that achieves (causes
problems with some disassemblers?). The user written console drivers must
include an input no echo entry and a terminal status entry. $AD4E is the FLEX
console status entry like $CD4E in 6809 FLEX.

Files in this package:

1) TSC_6800_FLEX_Advanced_Programmers_Manual.pdf (which states that it applies
to all versions of 6800 FLEX, so console status is not documented.)

2) TSC_6800_FLEX-V3-0_Adaptation_Guide.pdf

3) TSC_6800_FLEX-V3-0_Adaptation_Guide_Source_Code.zip (which includes example
console and disk driver routines.)

4) flex-g00.dsk - FUFU DSK format disk image.

5) FLEX-G00.IMD - Dave Dunfield format disk image.

6) TSC_6800_GENERAL_FLEX-V3-0_README.txt - this README file.


Notes on the TSC_6800_FLEX-V3-0_Adaptation_Guide.pdf

1) Assembled listings have not been OCR'd but have been assembled from
   source using the TSC assembler on my FLEX system so they do not contain
   OCR errors like "O" instead of "0".
   
2) Note that since the listing for the MF68 NEWDISK in the manual contains
   only selected sections, to obtain assembly at the correct address for the
   sections that are published required the addition of an ORG statement.
   This means that some of the code is overlaid and is therefore not useable.
   This is why the words "with-KLUDGE" appear in the title for the source
   code file. Don't use it to build your own NEWDISK!

Ian May September 2021.

