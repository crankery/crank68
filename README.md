# C68

One day I thought to myself I want to build a computer with the simplest 8 bit CPU I can think of". That CPU is the Motorola M6800 and this is the computer.

It's going to be pretty useless but it's fun to play around with all of this.

## Hardware

This isn't intended to be historically accurate. It's a 1970s CPU, but I'll use modern components where they make things simpler. I like using parts such as the MC6850 and MC6821 that were available when the M6800 was in use, while avoiding microcontrollers that would render the CPU redundant.

The computer is split up across a bunch of 100x100mm boards. This is an attempt to reduce the cost of production as that's the maxiumum size the Chinese fabs will produce at bargain pricing. The one exception (thus far) is the actual keyboard; its dimensions are dictated by the keyboard layout.

I'm currently using some SPLDs as there were analogs of these back in the day. I am using them for decode logic for the most part but I'm trying to replace them with simple 74 series logic slowly.

### Boards

The computer uses mostly single-function cards. The backplanes can be chained together, with slots 13.5 mm apart and about 12 mm of component clearance per card. Connectors can go on the left edge for devices such as serial ports, video and sound.

Progress is tracked as **initial development → PCB created → PCB built → complete**. The revision number is shown from PCB created onward. A created PCB has not necessarily been built.

| Project | Purpose | Status |
| --- | --- | --- |
| [Beep (76489)](hw/76489/) | SN76489 sound board | PCB created (rev 01) |
| [Backplane](hw/Backplane/) | Chainable card slots | PCB created (rev 01) |
| [Banked Memory](hw/BankedMemory/) | 1 MB battery-backed SRAM in two 4 KB windows | PCB created (rev 01) |
| [Height](hw/Height/) | Max RAM / banked ROM experiment; plans still undecided | PCB created (rev 01) |
| [IO](hw/IO/) | Two MC6850 ACIAs and two MC6821 PIAs | PCB created (rev 01) |
| [Keyboard](hw/Keyboard/) | Keyboard board | PCB created (rev 01) |
| [Memory](hw/Memory/) | 48 KB FRAM and 8 KB EEPROM | PCB created (rev 01) |
| [Processor](hw/Processor/) | M6800 CPU and MC6875 clock generator | PCB created (rev 01) |
| [RTC](hw/RTC/) | Real-time clock | Initial development |
| [Instore](hw/Instore/) | Keyboard and microSD add-on | Initial development |
| [Math](hw/Math/) | AMD AM9511 FPU | Initial development |
| [Video](hw/Video/) | Video board | Initial development |

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




