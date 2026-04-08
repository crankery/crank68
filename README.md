# C68

One day I thought to myself I want to build a computer with the simplest 8 bit CPU I can think of". That CPU is the Motorola M6800 and this is the computer.

It's going to be pretty useless but it's fun to play around with all of this.

## Hardware

So, this isn't intended to be historically accurate or anything. It's a 1970s CPU but I'll use modern components where it makes things simpler. So, for whatever reason I thought it'd be nice to use things like the MC6850, MC6821 and other components that would have been available when the M6800 was being used in the industry. But really, I'm just trying to avoid using microcontrollers that would render the actual CPU hopelessly redundant.

One place I used a microcontroller is on the terminal board. It's just being used to produce DVI video and render text. Oh, it also does the keyboard matrix scan. It has its one job and that's to replace a glass terminal. So, since it's busy doing dumb terminal stuff it doesn't really matter that it's anacronistic... right?

The computer is split up across a bunch of 100x100mm boards. This is an attempt to reduce the cost of production as that's the maxiumum size the Chinese fabs will produce at bargain pricing. The one exception (thus far) is the actual keyboard; its dimensions are dictated by the keyboard layout.

I'm currently using some SPLDs as there were analogs of these back in the day. I am using them for decode logic for the most part but I'm trying to replace them with simple 74 series logic slowly.

### Boards

As previously mentioned, the computer is built upon a set of cards. These cards are generally single function so there's a lot of them. 

#### Backplane

The backplane is a simple board with a bunch of slots on it. Each board will plug into this board. The boards are setup to be chained together. The slots are 13.5mm apart giving about 12mm of component height for each board. If a board grows taller than this or has multiple layers, it will block the next slot. This is tall enough to allow for most common components though.

The left side of each board is allowed to host connectors. This allows for connecting I/O devices to individual boards such as parallel ports, serial ports, video output or sound output.

Status: C68BP.01 sent to production

#### Processor

This board hosts the Motorola M6800 CPU and the MC6875 clock generator along with an oscillator running at 4MHz. This will result in a 1MHz system clock.

Status: C68CPU.01 sent to production

#### Memory

Lower 48KB of RAM (in FRAM), 8KB ROM (EEPROM)

Status: C68MEM.01 sent to production

#### Banked Memory

1 MB of batery backed SRAM presented in two four KB windows in the main address space.

Status: Finalized design

#### Math

AMD AM9511 FPU

Status: design in progress

#### Sound

This is a sound board. I'm still trying to decide which chip(s) to use. The YM2149 OPL2, Philips SAA1099, GI AY-3-8910 SGM

Status: spitballing

#### IO

2xACIA MC6850, 2xPIA MC6821

Status: design completed

#### Time

A DS12885 RTC and a MC6850 PTC.

Status: design completed

#### Front Panel

blinkenlights and switches and buttons.

Status: in progress

#### Terminal

Using a Raspberry PI Pico with PicoDVI to generate the terminal's video and to perform keyboard scans. Uses an on-board MC6850 for communication to the host system.

Status: sent to production

## Software

The software for this project includes some old stuff and some new stuff. The old stuff is being "translated" into a VASM 6800 standard syntax while the new stuff is being written that way.

### Emulator

emu is a very basic M6800 emulator and is being used to verify software development. It isn't complete yet and will halt when it encounters an unimplemented instruction.

It is designed to match the actual computer's IO and memory access and will do the minimum to make things appear as they will in reality. So, the ACIA status and control registers set the flags appropriately while the actual rate of transfer isn't worried about.

### New Stuff

#### C68 BIOS

### Old Stuff

#### MIKBUG2

#### Micro Basic

## Tools

Everything is being done using open source tools. This includes, but is not limited to:

- kicad
- vasm
- vlink
- galasm
- minipro
- GCC




