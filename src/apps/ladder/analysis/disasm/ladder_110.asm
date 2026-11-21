; z80dasm 1.2.0
; command line: z80dasm -a -l -t -c -S analysis/disasm/ladder_110.sym -b analysis/disasm/ladder_110.blocks -g 0x100 -o analysis/disasm/ladder_110.asm cpm/LADDER.COM

	org 00100h
; CP/M BDOS entry
BDOS:	equ 0x0005
level_word:	equ 0x0f69

; CP/M COM entry
cpm_entry:
	jp startup		;0100	c3 fa 0f	. . .

; BLOCK 'header' (start 0x0103 end 0x0137)
header_start:
	defb 000h		;0103	00		.
	defb 000h		;0104	00		.
	defb 000h		;0105	00		.
	defb 000h		;0106	00		.
l0107h:
	defb 000h		;0107	00		.
	defb 000h		;0108	00		.
	defb 000h		;0109	00		.
l010ah:
	defb 000h		;010a	00		.
	defb 000h		;010b	00		.
	defb 000h		;010c	00		.
	defb 000h		;010d	00		.
	defb 000h		;010e	00		.
	defb 000h		;010f	00		.
	defb 000h		;0110	00		.
	defb 000h		;0111	00		.
	defb 000h		;0112	00		.
	defb 000h		;0113	00		.
	defb 000h		;0114	00		.
	defb 000h		;0115	00		.
	defb 000h		;0116	00		.
	defb 000h		;0117	00		.
	defb 000h		;0118	00		.
	defb 000h		;0119	00		.
	defb 000h		;011a	00		.
	defb 000h		;011b	00		.
	defb 000h		;011c	00		.
	defb 000h		;011d	00		.
	defb 000h		;011e	00		.
	defb 000h		;011f	00		.
	defb 000h		;0120	00		.
	defb 000h		;0121	00		.
	defb 000h		;0122	00		.
	defb 000h		;0123	00		.
	defb 000h		;0124	00		.
	defb 000h		;0125	00		.
	defb 000h		;0126	00		.
	defb 000h		;0127	00		.
	defb 000h		;0128	00		.
	defb 000h		;0129	00		.
	defb 000h		;012a	00		.
	defb 000h		;012b	00		.
	defb 000h		;012c	00		.
	defb 000h		;012d	00		.
	defb 000h		;012e	00		.
	defb 000h		;012f	00		.
sub_0130h:
	defb 000h		;0130	00		.
	defb 000h		;0131	00		.
	defb 000h		;0132	00		.
	defb 005h		;0133	05		.
	defb 000h		;0134	00		.
	defb 0c3h		;0135	c3		.
	defb 012h		;0136	12		.
	inc h			;0137	24		$
	ld a,(de)		;0138	1a		.
	and a			;0139	a7		.
	jp nz,0240dh		;013a	c2 0d 24	. . $
	ld e,l			;013d	5d		]
	ld d,h			;013e	54		T
	inc de			;013f	13		.
	ld a,b			;0140	78		x
	push hl			;0141	e5		.
	ld bc,l0107h		;0142	01 07 01	. . .
	push af			;0145	f5		.
	ld a,(de)		;0146	1a		.
	ld (0241dh),a		;0147	32 1d 24	2 . $
	pop af			;014a	f1		.
	call 02812h		;014b	cd 12 28	. . (
	inc hl			;014e	23		#
	ld (hl),004h		;014f	36 04		6 .
	ld a,(hl)		;0151	7e		~
	dec hl			;0152	2b		+
	and a			;0153	a7		.
	ret			;0154	c9		.
	ld de,00005h		;0155	11 05 00	. . .
	ex de,hl		;0158	eb		.
	add hl,de		;0159	19		.
	ex de,hl		;015a	eb		.
l015bh:
	ld a,(de)		;015b	1a		.
	or a			;015c	b7		.
	inc de			;015d	13		.
	jp z,l2518h		;015e	ca 18 25	. . %
	ld de,l14eah		;0161	11 ea 14	. . .
	call 04835h		;0164	cd 35 48	. 5 H
	jp nz,l2440h+1		;0167	c2 41 24	. A $
	push hl			;016a	e5		.
	call sub_2e08h		;016b	cd 08 2e	. . .
	pop hl			;016e	e1		.
	cp 0e1h			;016f	fe e1		. .
	jp nz,l2512h		;0171	c2 12 25	. . %
	call sub_2e61h		;0174	cd 61 2e	. a .
	pop hl			;0177	e1		.
	ret c			;0178	d8		.
	push hl			;0179	e5		.
	call sub_22e4h		;017a	cd e4 22	. . "
	jp c,l2fceh		;017d	da ce 2f	. . /
	inc hl			;0180	23		#
	ex de,hl		;0181	eb		.
	pop hl			;0182	e1		.
	push hl			;0183	e5		.
	ld hl,00000h		;0184	21 00 00	! . .
	add hl,sp		;0187	39		9
	ld (l24c0h),hl		;0188	22 c0 24	" . $
	pop hl			;018b	e1		.
	push hl			;018c	e5		.
	ld bc,00006h		;018d	01 06 00	. . .
	add hl,bc		;0190	09		.
	ex de,hl		;0191	eb		.
	ld a,(de)		;0192	1a		.
	and a			;0193	a7		.
l0194h:
	jp p,02476h		;0194	f2 76 24	. v $
	xor 080h		;0197	ee 80		. .
	cp (hl)			;0199	be		.
	jp z,02476h		;019a	ca 76 24	. v $
	pop bc			;019d	c1		.
	ex de,hl		;019e	eb		.
	dec hl			;019f	2b		+
	ld a,(hl)		;01a0	7e		~
	inc hl			;01a1	23		#
	call 047efh		;01a2	cd ef 47	. . G
	inc hl			;01a5	23		#
	jp 02450h		;01a6	c3 50 24	. P $
	dec hl			;01a9	2b		+
l01aah:
	push hl			;01aa	e5		.
	dec de			;01ab	1b		.
l01ach:
	ld a,(de)		;01ac	1a		.
	ld b,a			;01ad	47		G
	add a,a			;01ae	87		.
	add a,007h		;01af	c6 07		. .
	ld c,a			;01b1	4f		O
	ld a,023h		;01b2	3e 23		> #
	call sub_26b3h		;01b4	cd b3 26	. . &
	pop bc			;01b7	c1		.
	push hl			;01b8	e5		.
	push hl			;01b9	e5		.
	ld h,b			;01ba	60		`
	ld l,c			;01bb	69		i
	ld a,(de)		;01bc	1a		.
	inc de			;01bd	13		.
	ld b,a			;01be	47		G
	jp 024adh		;01bf	c3 ad 24	. . $
	push hl			;01c2	e5		.
	ld hl,(l24c0h)		;01c3	2a c0 24	* . $
	push hl			;01c6	e5		.
	ld a,(de)		;01c7	1a		.
	and 020h		;01c8	e6 20		.  
	jp z,024a2h		;01ca	ca a2 24	. . $
	call sub_2e08h		;01cd	cd 08 2e	. . .
	cp 0e5h			;01d0	fe e5		. .
	call z,026cdh		;01d2	cc cd 26	. . &
	call sub_22e4h		;01d5	cd e4 22	. . "
	ex (sp),hl		;01d8	e3		.
	ld (l24c0h),hl		;01d9	22 c0 24	" . $
	pop hl			;01dc	e1		.
	jp c,l2fcch		;01dd	da cc 2f	. . /
	ld a,(de)		;01e0	1a		.
	and 040h		;01e1	e6 40		. @
	jp z,l24c6h		;01e3	ca c6 24	. . $
l01e6h:
	inc hl			;01e6	23		#
l01e7h:
	ld a,(hl)		;01e7	7e		~
	dec hl			;01e8	2b		+
	cp 007h			;01e9	fe 07		. .
	jp nz,l24c6h		;01eb	c2 c6 24	. . $
	push hl			;01ee	e5		.
	ld hl,l1415h		;01ef	21 15 14	! . .
	ld (0dbf1h),hl		;01f2	22 f1 db	" . .
	pop hl			;01f5	e1		.
	ld de,l141bh+1		;01f6	11 1c 14	. . .
	ld a,(de)		;01f9	1a		.
	inc de			;01fa	13		.
	and 01fh		;01fb	e6 1f		. .
	call l2b6ah+1		;01fd	cd 6b 2b	. k +
	ex de,hl		;0200	eb		.
	ex (sp),hl		;0201	e3		.
	ld (hl),e		;0202	73		s
	inc hl			;0203	23		#
	ld (hl),d		;0204	72		r
	inc hl			;0205	23		#
	pop de			;0206	d1		.
	push hl			;0207	e5		.
	call 026cdh		;0208	cd cd 26	. . &
l020bh:
	pop hl			;020b	e1		.
	cp 0e2h			;020c	fe e2		. .
	jp z,l24f5h		;020e	ca f5 24	. . $
	cp 0e7h			;0211	fe e7		. .
	jp z,l24eah		;0213	ca ea 24	. . $
	call sub_1fefh		;0216	cd ef 1f	. . .
	ld bc,0cdc3h		;0219	01 c3 cd	. . .
	cpl			;021c	2f		/
	dec b			;021d	05		.
	jp nz,0248fh		;021e	c2 8f 24	. . $
	call sub_1fefh		;0221	cd ef 1f	. . .
	ld bc,0cdc3h		;0224	01 c3 cd	. . .
	cpl			;0227	2f		/
	dec b			;0228	05		.
	jp z,l2522h		;0229	ca 22 25	. " %
	push de			;022c	d5		.
	push hl			;022d	e5		.
l022eh:
	call sub_2a9ch		;022e	cd 9c 2a	. . *
	ex de,hl		;0231	eb		.
	pop hl			;0232	e1		.
	ld (hl),e		;0233	73		s
	inc hl			;0234	23		#
	ld (hl),d		;0235	72		r
	inc hl			;0236	23		#
	pop de			;0237	d1		.
	ld a,(de)		;0238	1a		.
	inc de			;0239	13		.
	and a			;023a	a7		.
	jp m,l2522h		;023b	fa 22 25	. " %
l023eh:
	call sub_1fefh		;023e	cd ef 1f	. . .
	ld bc,0cdc3h		;0241	01 c3 cd	. . .
	cpl			;0244	2f		/
	ld hl,0165dh		;0245	21 5d 16	! ] .
	ld de,014f1h		;0248	11 f1 14	. . .
	push hl			;024b	e5		.
	ld bc,00007h		;024c	01 07 00	. . .
	ld a,023h		;024f	3e 23		> #
	call sub_26b3h		;0251	cd b3 26	. . &
	push hl			;0254	e5		.
	ld a,(de)		;0255	1a		.
	pop de			;0256	d1		.
	pop bc			;0257	c1		.
	inc bc			;0258	03		.
	inc bc			;0259	03		.
	inc bc			;025a	03		.
	ld (hl),c		;025b	71		q
	inc hl			;025c	23		#
	ld (hl),b		;025d	70		p
	ld hl,0fffch		;025e	21 fc ff	! . .
	add hl,de		;0261	19		.
	ld (hl),a		;0262	77		w
	dec hl			;0263	2b		+
	and a			;0264	a7		.
	ret			;0265	c9		.
	push hl			;0266	e5		.
	ld de,00005h		;0267	11 05 00	. . .
	add hl,de		;026a	19		.
	ld a,(hl)		;026b	7e		~
	and a			;026c	a7		.
	jp z,l2546h		;026d	ca 46 25	. F %
	push hl			;0270	e5		.
	call sub_2e61h		;0271	cd 61 2e	. a .
	pop hl			;0274	e1		.
	pop hl			;0275	e1		.
	jp c,l2fceh		;0276	da ce 2f	. . /
	ld a,(hl)		;0279	7e		~
	add a,a			;027a	87		.
	ld b,a			;027b	47		G
	add a,a			;027c	87		.
	add a,007h		;027d	c6 07		. .
	ld c,a			;027f	4f		O
	inc hl			;0280	23		#
	ld e,(hl)		;0281	5e		^
	inc hl			;0282	23		#
	ld d,(hl)		;0283	56		V
	ld a,d			;0284	7a		z
	or e			;0285	b3		.
	ld a,00eh		;0286	3e 0e		> .
	pop hl			;0288	e1		.
	jp z,l1f60h+1		;0289	ca 61 1f	. a .
	push hl			;028c	e5		.
	ld a,030h		;028d	3e 30		> 0
	call sub_26b3h		;028f	cd b3 26	. . &
	ld a,b			;0292	78		x
	rra			;0293	1f		.
	pop bc			;0294	c1		.
	push hl			;0295	e5		.
	push bc			;0296	c5		.
	push de			;0297	d5		.
	ld b,a			;0298	47		G
	ld a,b			;0299	78		x
	and a			;029a	a7		.
	jp z,l25ach		;029b	ca ac 25	. . %
	ex (sp),hl		;029e	e3		.
	ld e,(hl)		;029f	5e		^
	inc hl			;02a0	23		#
	ld d,(hl)		;02a1	56		V
	inc hl			;02a2	23		#
	ex (sp),hl		;02a3	e3		.
	push de			;02a4	d5		.
	inc de			;02a5	13		.
	ld a,(de)		;02a6	1a		.
	ld c,a			;02a7	4f		O
	ex de,hl		;02a8	eb		.
	call sub_22e4h		;02a9	cd e4 22	. . "
	jp c,l2fcbh		;02ac	da cb 2f	. . /
	ld a,c			;02af	79		y
	call l2b6ah+1		;02b0	cd 6b 2b	. k +
	ex (sp),hl		;02b3	e3		.
	call sub_2846h		;02b4	cd 46 28	. F (
	ld (hl),001h		;02b7	36 01		6 .
	ex de,hl		;02b9	eb		.
	ld (hl),e		;02ba	73		s
	inc hl			;02bb	23		#
	ld (hl),d		;02bc	72		r
	inc hl			;02bd	23		#
	pop de			;02be	d1		.
	ld (hl),e		;02bf	73		s
	inc hl			;02c0	23		#
	ld (hl),d		;02c1	72		r
	inc hl			;02c2	23		#
	push hl			;02c3	e5		.
	call 026cdh		;02c4	cd cd 26	. . &
	pop hl			;02c7	e1		.
	cp 0e7h			;02c8	fe e7		. .
	jp nz,l25a0h+1		;02ca	c2 a1 25	. . %
	dec b			;02cd	05		.
	jp nz,0256bh		;02ce	c2 6b 25	. k %
	jp l25bch		;02d1	c3 bc 25	. . %
	cp 0e2h			;02d4	fe e2		. .
	ld a,001h		;02d6	3e 01		> .
	jp nz,l25beh		;02d8	c2 be 25	. . %
	dec b			;02db	05		.
	jp nz,l25bch		;02dc	c2 bc 25	. . %
	pop de			;02df	d1		.
	pop de			;02e0	d1		.
	ld (hl),e		;02e1	73		s
	inc hl			;02e2	23		#
	ld (hl),d		;02e3	72		r
	pop hl			;02e4	e1		.
	inc de			;02e5	13		.
	ld a,(de)		;02e6	1a		.
	ld de,0fffch		;02e7	11 fc ff	. . .
	add hl,de		;02ea	19		.
	ld (hl),a		;02eb	77		w
	dec hl			;02ec	2b		+
	and a			;02ed	a7		.
	ret			;02ee	c9		.
	ld a,001h		;02ef	3e 01		> .
	call l1f60h+1		;02f1	cd 61 1f	. a .
	jp l2fcch		;02f4	c3 cc 2f	. . /
	call sub_2e61h		;02f7	cd 61 2e	. a .
	pop hl			;02fa	e1		.
	ret c			;02fb	d8		.
	call sub_2e08h		;02fc	cd 08 2e	. . .
	cp 0e5h			;02ff	fe e5		. .
	jp z,l25f2h		;0301	ca f2 25	. . %
	call 02e32h		;0304	cd 32 2e	. 2 .
	ret c			;0307	d8		.
	inc hl			;0308	23		#
	ld (hl),004h		;0309	36 04		6 .
	dec hl			;030b	2b		+
	ex de,hl		;030c	eb		.
	ld bc,l0107h		;030d	01 07 01	. . .
	ld a,031h		;0310	3e 31		> 1
	call sub_26b3h		;0312	cd b3 26	. . &
	ld (hl),e		;0315	73		s
	inc hl			;0316	23		#
	ld (hl),d		;0317	72		r
	ld de,0fffbh		;0318	11 fb ff	. . .
	add hl,de		;031b	19		.
	ld a,004h		;031c	3e 04		> .
	ld (hl),a		;031e	77		w
	dec hl			;031f	2b		+
	call sub_2e61h		;0320	cd 61 2e	. a .
	jp po,0cdc9h		;0323	e2 c9 cd	. . .
	jp pe,0d829h		;0326	ea 29 d8	. ) .
	call sub_2e61h		;0329	cd 61 2e	. a .
	jp po,03ed8h		;032c	e2 d8 3e	. . >
	inc hl			;032f	23		#
	push af			;0330	f5		.
	ld de,l1656h		;0331	11 56 16	. V .
	push de			;0334	d5		.
	push hl			;0335	e5		.
	ld a,004h		;0336	3e 04		> .
	ld b,001h		;0338	06 01		. .
	jp 02886h		;033a	c3 86 28	. . (
	call 026cdh		;033d	cd cd 26	. . &
	cp 0ebh			;0340	fe eb		. .
	jp z,sub_2846h		;0342	ca 46 28	. F (
	cp 0ech			;0345	fe ec		. .
	jp z,sub_2846h		;0347	ca 46 28	. F (
	cp 0edh			;034a	fe ed		. .
	jp z,027c8h		;034c	ca c8 27	. . '
	cp 0e1h			;034f	fe e1		. .
	jp z,l264fh		;0351	ca 4f 26	. O &
	cp 0eeh			;0354	fe ee		. .
	jp z,l2533h		;0356	ca 33 25	. 3 %
	cp 019h			;0359	fe 19		. .
	ld bc,l0619h		;035b	01 19 06	. . .
	jp z,l2660h		;035e	ca 60 26	. ` &
	cp 00fh			;0361	fe 0f		. .
	ld bc,l0d09h		;0363	01 09 0d	. . .
	jp z,l2660h		;0366	ca 60 26	. ` &
	cp 00eh			;0369	fe 0e		. .
	jp z,l260ah		;036b	ca 0a 26	. . &
	cp 096h			;036e	fe 96		. .
	jp z,l25c4h		;0370	ca c4 25	. . %
	cp 0e1h			;0373	fe e1		. .
	ccf			;0375	3f		?
	ret c			;0376	d8		.
	cp 0a1h			;0377	fe a1		. .
	ret c			;0379	d8		.
	cp 0b8h			;037a	fe b8		. .
	jp c,02341h		;037c	da 41 23	. A #
	jp l2422h		;037f	c3 22 24	. " $
	call sub_22e4h		;0382	cd e4 22	. . "
	ret c			;0385	d8		.
	push af			;0386	f5		.
	call sub_2e61h		;0387	cd 61 2e	. a .
	jp po,l5ddah		;038a	e2 da 5d	. . ]
	ld h,0f1h		;038d	26 f1		& .
	ret			;038f	c9		.
	pop af			;0390	f1		.
	scf			;0391	37		7
	ret			;0392	c9		.
	call sub_230fh		;0393	cd 0f 23	. . #
	ld a,c			;0396	79		y
	call l2abeh+1		;0397	cd bf 2a	. . *
	jp l2e1ah		;039a	c3 1a 2e	. . .
	call 026cdh		;039d	cd cd 26	. . &
	cp 058h			;03a0	fe 58		. X
	ret z			;03a2	c8		.
	cp 082h			;03a3	fe 82		. .
	jp nz,0267bh		;03a5	c2 7b 26	. { &
	call 026cdh		;03a8	cd cd 26	. . &
	cp 098h			;03ab	fe 98		. .
	ret z			;03ad	c8		.
	ld a,001h		;03ae	3e 01		> .
	jp l1f60h+1		;03b0	c3 61 1f	. a .
	ld hl,(l12cdh)		;03b3	2a cd 12	* . .
	ld (hl),080h		;03b6	36 80		6 .
	inc hl			;03b8	23		#
	ld a,(hl)		;03b9	7e		~
	and a			;03ba	a7		.
	jp nz,0269eh		;03bb	c2 9e 26	. . &
	push bc			;03be	c5		.
	push de			;03bf	d5		.
	ex de,hl		;03c0	eb		.
	ld bc,00033h		;03c1	01 33 00	. 3 .
	call l26d9h+1		;03c4	cd da 26	. . &
	ex de,hl		;03c7	eb		.
	ld (hl),e		;03c8	73		s
	inc hl			;03c9	23		#
	ld (hl),d		;03ca	72		r
	ex de,hl		;03cb	eb		.
	pop de			;03cc	d1		.
	pop bc			;03cd	c1		.
	ld a,010h		;03ce	3e 10		> .
	inc hl			;03d0	23		#
	dec hl			;03d1	2b		+
	push hl			;03d2	e5		.
	ld (hl),000h		;03d3	36 00		6 .
	inc hl			;03d5	23		#
	ld (hl),000h		;03d6	36 00		6 .
	inc hl			;03d8	23		#
	ld (hl),000h		;03d9	36 00		6 .
	inc hl			;03db	23		#
	ld (hl),040h		;03dc	36 40		6 @
	dec a			;03de	3d		=
	ld (l12cdh),hl		;03df	22 cd 12	" . .
	inc hl			;03e2	23		#
	ld (hl),a		;03e3	77		w
	pop hl			;03e4	e1		.
	ret			;03e5	c9		.
	and a			;03e6	a7		.
	jp sub_26b7h+1		;03e7	c3 b8 26	. . &
	scf			;03ea	37		7
	push af			;03eb	f5		.
	push bc			;03ec	c5		.
	ld b,000h		;03ed	06 00		. .
	call sub_273fh		;03ef	cd 3f 27	. ? '
	pop bc			;03f2	c1		.
	pop af			;03f3	f1		.
	ld (hl),a		;03f4	77		w
	inc hl			;03f5	23		#
	inc hl			;03f6	23		#
	jp nc,l26c8h		;03f7	d2 c8 26	. . &
	inc (hl)		;03fa	34		4
	inc hl			;03fb	23		#
	inc hl			;03fc	23		#
	ld (hl),b		;03fd	70		p
	inc hl			;03fe	23		#
	ret			;03ff	c9		.
	call sub_2e08h		;0400	cd 08 2e	. . .
	cp 09fh			;0403	fe 9f		. .
	ret z			;0405	c8		.
	push af			;0406	f5		.
	xor a			;0407	af		.
	ld (l2061h+1),a		;0408	32 62 20	2 b  
	pop af			;040b	f1		.
	ret			;040c	c9		.
	push de			;040d	d5		.
	ld hl,(l16bah)		;040e	2a ba 16	* . .
	ex de,hl		;0411	eb		.
l0412h:
	ld hl,(l16b6h)		;0412	2a b6 16	* . .
	push hl			;0415	e5		.
	add hl,bc		;0416	09		.
	ld (l16b6h),hl		;0417	22 b6 16	" . .
	ld a,h			;041a	7c		|
	sub d			;041b	92		.
	jp c,l26f3h+1		;041c	da f4 26	. . &
	jp nz,l201eh		;041f	c2 1e 20	. .  
	ld a,l			;0422	7d		}
	sub e			;0423	93		.
	jp nc,l201eh		;0424	d2 1e 20	. .  
	pop hl			;0427	e1		.
	pop de			;0428	d1		.
	ret			;0429	c9		.
	dec hl			;042a	2b		+
	dec hl			;042b	2b		+
	dec hl			;042c	2b		+
	ld de,0fffbh		;042d	11 fb ff	. . .
	add hl,de		;0430	19		.
	ld a,(l16a6h+1)		;0431	3a a7 16	: . .
	and a			;0434	a7		.
	ret nz			;0435	c0		.
	push hl			;0436	e5		.
	ld a,(hl)		;0437	7e		~
	cp 03fh			;0438	fe 3f		. ?
	jp z,l271ch		;043a	ca 1c 27	. . '
	cp 034h			;043d	fe 34		. 4
	jp z,l271ch		;043f	ca 1c 27	. . '
	cp 060h			;0442	fe 60		. `
	jp z,l271ch		;0444	ca 1c 27	. . '
	ld a,(l122ch)		;0447	3a 2c 12	: , .
	cp 058h			;044a	fe 58		. X
	jp z,l2fceh		;044c	ca ce 2f	. . /
	ld a,(hl)		;044f	7e		~
	ld (l122ch),a		;0450	32 2c 12	2 , .
	ld bc,00004h		;0453	01 04 00	. . .
	call sub_273fh		;0456	cd 3f 27	. ? '
	ex de,hl		;0459	eb		.
	ld hl,(l122ah)		;045a	2a 2a 12	* * .
	ld (hl),e		;045d	73		s
	inc hl			;045e	23		#
	ld (hl),d		;045f	72		r
	ex de,hl		;0460	eb		.
	ld (l122ah),hl		;0461	22 2a 12	" * .
	inc hl			;0464	23		#
	inc hl			;0465	23		#
	pop de			;0466	d1		.
	ld (hl),e		;0467	73		s
	inc hl			;0468	23		#
	ld (hl),d		;0469	72		r
	ld a,(l16a8h)		;046a	3a a8 16	: . .
	and a			;046d	a7		.
	ret z			;046e	c8		.
	jp l2fd2h		;046f	c3 d2 2f	. . /
	push bc			;0472	c5		.
	push de			;0473	d5		.
	ld hl,(l16bah)		;0474	2a ba 16	* . .
	ld a,l			;0477	7d		}
	sub c			;0478	91		.
	ld l,a			;0479	6f		o
	ld a,h			;047a	7c		|
	sbc a,b			;047b	98		.
	ld h,a			;047c	67		g
	ld (l16bah),hl		;047d	22 ba 16	" . .
	ex de,hl		;0480	eb		.
	ld hl,(l16b6h)		;0481	2a b6 16	* . .
	ld a,028h		;0484	3e 28		> (
	call 047efh		;0486	cd ef 47	. . G
	ld a,l			;0489	7d		}
	sub e			;048a	93		.
	ld a,h			;048b	7c		|
	sbc a,d			;048c	9a		.
	jp c,l2776h		;048d	da 76 27	. v '
	ld hl,00000h		;0490	21 00 00	! . .
	ld (l1228h),hl		;0493	22 28 12	" ( .
	ld hl,l1228h		;0496	21 28 12	! ( .
	ld (l122ah),hl		;0499	22 2a 12	" * .
	call sub_1fefh		;049c	cd ef 1f	. . .
	dec b			;049f	05		.
	ld hl,(l16b8h)		;04a0	2a b8 16	* . .
	ld (l16bah),hl		;04a3	22 ba 16	" . .
	pop de			;04a6	d1		.
	pop bc			;04a7	c1		.
	ret			;04a8	c9		.
	ld hl,(l16bch)		;04a9	2a bc 16	* . .
	ld a,l			;04ac	7d		}
	sub e			;04ad	93		.
	ld a,h			;04ae	7c		|
	sbc a,d			;04af	9a		.
	ex de,hl		;04b0	eb		.
	jp c,l2784h		;04b1	da 84 27	. . '
	ld (l16bch),hl		;04b4	22 bc 16	" . .
	push hl			;04b7	e5		.
	ld (hl),000h		;04b8	36 00		6 .
	inc hl			;04ba	23		#
	dec bc			;04bb	0b		.
	ld a,b			;04bc	78		x
	or c			;04bd	b1		.
	jp nz,l2785h		;04be	c2 85 27	. . '
	pop hl			;04c1	e1		.
	pop de			;04c2	d1		.
	pop bc			;04c3	c1		.
	ret			;04c4	c9		.
	ld hl,(l16ach)		;04c5	2a ac 16	* . .
	push hl			;04c8	e5		.
	add hl,bc		;04c9	09		.
	ld (l16ach),hl		;04ca	22 ac 16	" . .
	pop hl			;04cd	e1		.
	ld a,002h		;04ce	3e 02		> .
	jp c,l1f60h+1		;04d0	da 61 1f	. a .
	ld a,(l16b0h)		;04d3	3a b0 16	: . .
	and 010h		;04d6	e6 10		. .
	ret z			;04d8	c8		.
	push hl			;04d9	e5		.
	push de			;04da	d5		.
	push bc			;04db	c5		.
	ex de,hl		;04dc	eb		.
	call sub_7908h		;04dd	cd 08 79	. . y
	pop hl			;04e0	e1		.
	push hl			;04e1	e5		.
	ld a,h			;04e2	7c		|
	or l			;04e3	b5		.
	jp z,l27bdh		;04e4	ca bd 27	. . '
	ld b,000h		;04e7	06 00		. .
	call 07ad0h		;04e9	cd d0 7a	. . z
	dec hl			;04ec	2b		+
	jp l27afh		;04ed	c3 af 27	. . '
	ld hl,(l16aeh)		;04f0	2a ae 16	* . .
	ex de,hl		;04f3	eb		.
	call 0790eh		;04f4	cd 0e 79	. . y
	pop bc			;04f7	c1		.
	pop de			;04f8	d1		.
	pop hl			;04f9	e1		.
	ret			;04fa	c9		.
	call sub_2c72h		;04fb	cd 72 2c	. r ,
	ret c			;04fe	d8		.
	push hl			;04ff	e5		.
	inc hl			;0500	23		#
	inc hl			;0501	23		#
	ld a,(hl)		;0502	7e		~
	rra			;0503	1f		.
l0504h:
	ld a,001h		;0504	3e 01		> .
	jp nc,l27d8h		;0506	d2 d8 27	. . '
	ld a,002h		;0509	3e 02		> .
	ld bc,00009h		;050b	01 09 00	. . .
	call sub_26b3h		;050e	cd b3 26	. . &
	pop de			;0511	d1		.
	ld (hl),e		;0512	73		s
	inc hl			;0513	23		#
	ld (hl),d		;0514	72		r
	ld bc,0fffbh		;0515	01 fb ff	. . .
	add hl,bc		;0518	09		.
	inc de			;0519	13		.
	ld a,(de)		;051a	1a		.
	push af			;051b	f5		.
	ld (hl),a		;051c	77		w
	dec hl			;051d	2b		+
	push hl			;051e	e5		.
	call l2e1ah		;051f	cd 1a 2e	. . .
	push hl			;0522	e5		.
	ld a,032h		;0523	3e 32		> 2
	ld bc,00209h		;0525	01 09 02	. . .
	call 02812h		;0528	cd 12 28	. . (
	pop af			;052b	f1		.
	inc hl			;052c	23		#
	ld (hl),a		;052d	77		w
l052eh:
	dec hl			;052e	2b		+
	push af			;052f	f5		.
	ex de,hl		;0530	eb		.
	ld bc,l0107h		;0531	01 07 01	. . .
	ld a,033h		;0534	3e 33		> 3
	call sub_26b3h		;0536	cd b3 26	. . &
	ld (hl),e		;0539	73		s
	inc hl			;053a	23		#
	ld (hl),d		;053b	72		r
	ld de,0fffbh		;053c	11 fb ff	. . .
	add hl,de		;053f	19		.
	pop af			;0540	f1		.
	ld (hl),a		;0541	77		w
	dec hl			;0542	2b		+
	and a			;0543	a7		.
	ret			;0544	c9		.
	call sub_26b3h		;0545	cd b3 26	. . &
	ld a,b			;0548	78		x
	ld b,h			;0549	44		D
	ld c,l			;054a	4d		M
	ex (sp),hl		;054b	e3		.
	ld (l282fh),hl		;054c	22 2f 28	" / (
	pop hl			;054f	e1		.
	sub 001h		;0550	d6 01		. .
	jp c,l2829h+1		;0552	da 2a 28	. * (
	pop de			;0555	d1		.
	ld (hl),e		;0556	73		s
	inc hl			;0557	23		#
	ld (hl),d		;0558	72		r
	inc hl			;0559	23		#
	jp l281dh		;055a	c3 1d 28	. . (
	ld hl,0fffbh		;055d	21 fb ff	! . .
	add hl,bc		;0560	09		.
	jp 02843h		;0561	c3 43 28	. C (
	ld a,001h		;0564	3e 01		> .
	ld (l16a8h),a		;0566	32 a8 16	2 . .
	ret			;0569	c9		.
	call sub_26b7h		;056a	cd b7 26	. . &
	jp l2840h		;056d	c3 40 28	. @ (
	call sub_26b3h		;0570	cd b3 26	. . &
	call sub_2815h		;0573	cd 15 28	. . (
	jp l26fdh+1		;0576	c3 fe 26	. . &
	push bc			;0579	c5		.
	push de			;057a	d5		.
	ld b,001h		;057b	06 01		. .
	ld a,(hl)		;057d	7e		~
	inc hl			;057e	23		#
	cp 0ebh			;057f	fe eb		. .
	jp z,0285ah		;0581	ca 5a 28	. Z (
	inc b			;0584	04		.
	inc hl			;0585	23		#
	ld a,(hl)		;0586	7e		~
	dec hl			;0587	2b		+
	rra			;0588	1f		.
	jp nc,0285ah		;0589	d2 5a 28	. Z (
	inc b			;058c	04		.
	ld a,(hl)		;058d	7e		~
	push af			;058e	f5		.
	dec hl			;058f	2b		+
	ex de,hl		;0590	eb		.
	ld a,b			;0591	78		x
	ld bc,00009h		;0592	01 09 00	. . .
	call sub_26b3h		;0595	cd b3 26	. . &
	ld (hl),e		;0598	73		s
	inc hl			;0599	23		#
	ld (hl),d		;059a	72		r
	ld de,0fffbh		;059b	11 fb ff	. . .
	add hl,de		;059e	19		.
	pop af			;059f	f1		.
	ld (hl),a		;05a0	77		w
	dec hl			;05a1	2b		+
	and a			;05a2	a7		.
	pop de			;05a3	d1		.
	pop bc			;05a4	c1		.
	ret			;05a5	c9		.
	xor a			;05a6	af		.
	ld (028b5h),a		;05a7	32 b5 28	2 . (
	ld a,b			;05aa	78		x
	add a,a			;05ab	87		.
	ld e,a			;05ac	5f		_
	ld d,000h		;05ad	16 00		. .
	add a,007h		;05af	c6 07		. .
	ld c,a			;05b1	4f		O
	call sub_26b7h		;05b2	cd b7 26	. . &
	jp 02894h		;05b5	c3 94 28	. . (
	xor a			;05b8	af		.
	ld (028b5h),a		;05b9	32 b5 28	2 . (
	ld a,b			;05bc	78		x
	add a,a			;05bd	87		.
	ld e,a			;05be	5f		_
	ld d,000h		;05bf	16 00		. .
	add a,007h		;05c1	c6 07		. .
	ld c,a			;05c3	4f		O
	call sub_26b3h		;05c4	cd b3 26	. . &
	add hl,de		;05c7	19		.
	ex de,hl		;05c8	eb		.
	add hl,sp		;05c9	39		9
	ex de,hl		;05ca	eb		.
	ld a,(de)		;05cb	1a		.
	ld (hl),a		;05cc	77		w
	inc de			;05cd	13		.
	inc hl			;05ce	23		#
	ld a,(de)		;05cf	1a		.
	ld (hl),a		;05d0	77		w
	dec hl			;05d1	2b		+
	ld a,b			;05d2	78		x
	and a			;05d3	a7		.
	jp z,028adh		;05d4	ca ad 28	. . (
	pop de			;05d7	d1		.
	dec hl			;05d8	2b		+
	ld (hl),d		;05d9	72		r
	dec hl			;05da	2b		+
	ld (hl),e		;05db	73		s
	dec a			;05dc	3d		=
	jp nz,l28a3h+1		;05dd	c2 a4 28	. . (
	pop bc			;05e0	c1		.
	ld de,0fffbh		;05e1	11 fb ff	. . .
	add hl,de		;05e4	19		.
	pop af			;05e5	f1		.
	ld (hl),a		;05e6	77		w
	ld a,000h		;05e7	3e 00		> .
	inc hl			;05e9	23		#
	ld (hl),a		;05ea	77		w
	dec hl			;05eb	2b		+
	and a			;05ec	a7		.
	ret nz			;05ed	c0		.
	jp l26fdh+1		;05ee	c3 fe 26	. . &
	ld a,(hl)		;05f1	7e		~
	cp 001h			;05f2	fe 01		. .
	scf			;05f4	37		7
	ret nz			;05f5	c0		.
	push de			;05f6	d5		.
	push hl			;05f7	e5		.
	ld de,00005h		;05f8	11 05 00	. . .
	add hl,de		;05fb	19		.
	ld e,(hl)		;05fc	5e		^
	inc hl			;05fd	23		#
	ld d,(hl)		;05fe	56		V
	ld a,(de)		;05ff	1a		.
	cp 0ebh			;0600	fe eb		. .
	jp nz,l28e2h		;0602	c2 e2 28	. . (
	inc de			;0605	13		.
	ld a,(de)		;0606	1a		.
	cp 007h			;0607	fe 07		. .
	jp z,l28e2h		;0609	ca e2 28	. . (
	ld hl,00004h		;060c	21 04 00	! . .
	add hl,de		;060f	19		.
	ld a,(hl)		;0610	7e		~
	pop hl			;0611	e1		.
	pop de			;0612	d1		.
	and a			;0613	a7		.
	ret			;0614	c9		.
	pop hl			;0615	e1		.
	pop de			;0616	d1		.
	scf			;0617	37		7
l0618h:
	ret			;0618	c9		.
l0619h:
	call sub_2e08h		;0619	cd 08 2e	. . .
	sub 0e7h		;061c	d6 e7		. .
l061eh:
	and a			;061e	a7		.
	ret nz			;061f	c0		.
	call 026cdh		;0620	cd cd 26	. . &
	xor a			;0623	af		.
	ret			;0624	c9		.
	call sub_2e08h		;0625	cd 08 2e	. . .
	cp 09fh			;0628	fe 9f		. .
	ret z			;062a	c8		.
	cp 09dh			;062b	fe 9d		. .
	ret			;062d	c9		.
l062eh:
	ld a,(hl)		;062e	7e		~
	cp 001h			;062f	fe 01		. .
	scf			;0631	37		7
	ret nz			;0632	c0		.
	push de			;0633	d5		.
	ex de,hl		;0634	eb		.
	ld hl,00005h		;0635	21 05 00	! . .
	add hl,de		;0638	19		.
	ld a,(hl)		;0639	7e		~
	inc hl			;063a	23		#
	ld h,(hl)		;063b	66		f
	ld l,a			;063c	6f		o
	ld a,(hl)		;063d	7e		~
	cp 0edh			;063e	fe ed		. .
	jp z,l291eh		;0640	ca 1e 29	. . )
	cp 0ebh			;0643	fe eb		. .
	scf			;0645	37		7
	jp nz,l291eh		;0646	c2 1e 29	. . )
	inc hl			;0649	23		#
	ld a,(hl)		;064a	7e		~
	dec hl			;064b	2b		+
	xor 007h		;064c	ee 07		. .
	sub 001h		;064e	d6 01		. .
	ld a,(hl)		;0650	7e		~
	ex de,hl		;0651	eb		.
	pop de			;0652	d1		.
	ret			;0653	c9		.
	ld a,(de)		;0654	1a		.
	ld (hl),a		;0655	77		w
	ld a,l			;0656	7d		}
	ld (de),a		;0657	12		.
	ld b,h			;0658	44		D
	inc de			;0659	13		.
	inc hl			;065a	23		#
	ld a,(de)		;065b	1a		.
	ld (hl),a		;065c	77		w
	ld a,b			;065d	78		x
	ld (de),a		;065e	12		.
	inc hl			;065f	23		#
	ret			;0660	c9		.
	call sub_2e61h		;0661	cd 61 2e	. a .
	rst 20h			;0664	e7		.
	ret			;0665	c9		.
	push af			;0666	f5		.
	ex de,hl		;0667	eb		.
	call l26d9h+1		;0668	cd da 26	. . &
	pop af			;066b	f1		.
	call 047efh		;066c	cd ef 47	. . G
	jp l2920h+1		;066f	c3 21 29	. ! )
	push hl			;0672	e5		.
	push de			;0673	d5		.
	ld hl,0ffd8h		;0674	21 d8 ff	! . .
	add hl,sp		;0677	39		9
	ex de,hl		;0678	eb		.
	ld hl,(l16b2h)		;0679	2a b2 16	* . .
	add hl,de		;067c	19		.
	ccf			;067d	3f		?
	pop de			;067e	d1		.
	pop hl			;067f	e1		.
	ret nc			;0680	d0		.
	ld a,005h		;0681	3e 05		> .
	jp l1f60h+1		;0683	c3 61 1f	. a .
	ld a,(l12b8h)		;0686	3a b8 12	: . .
	sub 001h		;0689	d6 01		. .
	jp nz,02963h		;068b	c2 63 29	. c )
	ld (l12aah),a		;068e	32 aa 12	2 . .
	ld a,002h		;0691	3e 02		> .
	ld (l12b8h),a		;0693	32 b8 12	2 . .
	ld a,(l12b8h)		;0696	3a b8 12	: . .
	ld b,000h		;0699	06 00		. .
	cp 002h			;069b	fe 02		. .
	jp z,l296eh+1		;069d	ca 6f 29	. o )
	ld b,020h		;06a0	06 20		.  
	push bc			;06a2	c5		.
	call l4c06h+1		;06a3	cd 07 4c	. . L
	jp z,029e7h		;06a6	ca e7 29	. . )
	jp p,l2980h		;06a9	f2 80 29	. . )
	pop af			;06ac	f1		.
	or 080h			;06ad	f6 80		. .
	push af			;06af	f5		.
	call 04bech		;06b0	cd ec 4b	. . K
	ld a,(l12b8h)		;06b3	3a b8 12	: . .
	cp 002h			;06b6	fe 02		. .
	jp z,029c9h		;06b8	ca c9 29	. . )
	push af			;06bb	f5		.
	ld hl,l12afh		;06bc	21 af 12	! . .
	call sub_4c75h		;06bf	cd 75 4c	. u L
	call sub_1efdh		;06c2	cd fd 1e	. . .
	jp nc,02998h		;06c5	d2 98 29	. . )
	call sub_4d91h		;06c8	cd 91 4d	. . M
	ld hl,l29a4h		;06cb	21 a4 29	! . )
	push hl			;06ce	e5		.
	call sub_4d62h		;06cf	cd 62 4d	. b M
	pop hl			;06d2	e1		.
	pop bc			;06d3	c1		.
	jp 029e5h		;06d4	c3 e5 29	. . )
	pop bc			;06d7	c1		.
	ld hl,(l12a9h)		;06d8	2a a9 12	* . .
	push hl			;06db	e5		.
	ld a,b			;06dc	78		x
	cp 004h			;06dd	fe 04		. .
	jp z,l29b8h		;06df	ca b8 29	. . )
	call 04db3h		;06e2	cd b3 4d	. . M
	call 04cf4h		;06e5	cd f4 4c	. . L
	jp l29c4h		;06e8	c3 c4 29	. . )
	call sub_4d87h		;06eb	cd 87 4d	. . M
	ld hl,l12afh		;06ee	21 af 12	! . .
	call l4c37h+1		;06f1	cd 38 4c	. 8 L
	call sub_4c87h		;06f4	cd 87 4c	. . L
	pop hl			;06f7	e1		.
	and a			;06f8	a7		.
	jp nz,029e5h		;06f9	c2 e5 29	. . )
	pop af			;06fc	f1		.
	or 040h			;06fd	f6 40		. @
	push af			;06ff	f5		.
l0700h:
	ld e,l			;0700	5d		]
	ld d,h			;0701	54		T
	dec de			;0702	1b		.
	ld a,l			;0703	7d		}
	and e			;0704	a3		.
	ld e,a			;0705	5f		_
	ld a,h			;0706	7c		|
	and d			;0707	a2		.
	or e			;0708	b3		.
	jp nz,029e5h		;0709	c2 e5 29	. . )
	ld b,010h		;070c	06 10		. .
	dec b			;070e	05		.
	add hl,hl		;070f	29		)
	jp nc,029dbh		;0710	d2 db 29	. . )
	pop af			;0713	f1		.
	or b			;0714	b0		.
	or 010h			;0715	f6 10		. .
	push af			;0717	f5		.
	pop af			;0718	f1		.
	ret			;0719	c9		.
	pop af			;071a	f1		.
	xor a			;071b	af		.
	ret			;071c	c9		.
	call sub_2e08h		;071d	cd 08 2e	. . .
	cp 0e5h			;0720	fe e5		. .
	call z,026cdh		;0722	cc cd 26	. . &
	jp l22cbh		;0725	c3 cb 22	. . "
	ld a,034h		;0728	3e 34		> 4
	call l2a56h+1		;072a	cd 57 2a	. W *
	jp l2fd2h		;072d	c3 d2 2f	. . /
	ld de,l1216h		;0730	11 16 12	. . .
	ld a,c			;0733	79		y
	push de			;0734	d5		.
	dec a			;0735	3d		=
	jp nz,02a01h		;0736	c2 01 2a	. . *
	call sub_1fefh		;0739	cd ef 1f	. . .
	inc d			;073c	14		.
	call l2f05h+1		;073d	cd 06 2f	. . /
	ret			;0740	c9		.
	inc hl			;0741	23		#
	ld a,(hl)		;0742	7e		~
	dec hl			;0743	2b		+
	cp 007h			;0744	fe 07		. .
	jp nz,l2a29h		;0746	c2 29 2a	. ) *
	ld a,b			;0749	78		x
	add a,a			;074a	87		.
	jp p,l2a20h		;074b	f2 20 2a	.   *
	ld a,b			;074e	78		x
	or 008h			;074f	f6 08		. .
	ld b,a			;0751	47		G
	ret			;0752	c9		.
	call sub_1fefh		;0753	cd ef 1f	. . .
	inc b			;0756	04		.
	ld a,005h		;0757	3e 05		> .
	call l2b6ah+1		;0759	cd 6b 2b	. k +
	ld a,b			;075c	78		x
	and 008h		;075d	e6 08		. .
	jp z,l2a38h		;075f	ca 38 2a	. 8 *
	call sub_1fefh		;0762	cd ef 1f	. . .
	inc b			;0765	04		.
	ld a,007h		;0766	3e 07		> .
	jp l2b6ah+1		;0768	c3 6b 2b	. k +
	ld a,b			;076b	78		x
	and 0bfh		;076c	e6 bf		. .
	ld b,a			;076e	47		G
	and 020h		;076f	e6 20		.  
	jp z,l2a46h		;0771	ca 46 2a	. F *
	ld a,004h		;0774	3e 04		> .
	jp l2b6ah+1		;0776	c3 6b 2b	. k +
	ld a,b			;0779	78		x
	and 004h		;077a	e6 04		. .
	ret z			;077c	c8		.
	inc hl			;077d	23		#
	ld a,(hl)		;077e	7e		~
	dec hl			;077f	2b		+
	cp 004h			;0780	fe 04		. .
	ret nz			;0782	c0		.
	ld a,005h		;0783	3e 05		> .
	jp l2b6ah+1		;0785	c3 6b 2b	. k +
	ld a,058h		;0788	3e 58		> X
	ld bc,00007h		;078a	01 07 00	. . .
	call sub_26b3h		;078d	cd b3 26	. . &
	ld (hl),e		;0790	73		s
	inc hl			;0791	23		#
	ld (hl),d		;0792	72		r
	dec hl			;0793	2b		+
	jp 026fah		;0794	c3 fa 26	. . &
	push de			;0797	d5		.
	ld d,a			;0798	57		W
	add a,a			;0799	87		.
	add a,d			;079a	82		.
	ld hl,l2a78h		;079b	21 78 2a	! x *
	call 047efh		;079e	cd ef 47	. . G
	ld e,(hl)		;07a1	5e		^
	inc hl			;07a2	23		#
	ld d,(hl)		;07a3	56		V
	inc hl			;07a4	23		#
	ld a,(hl)		;07a5	7e		~
	ex de,hl		;07a6	eb		.
	pop de			;07a7	d1		.
	jp l2aach		;07a8	c3 ac 2a	. . *
	inc sp			;07ab	33		3
	ld (de),a		;07ac	12		.
	add hl,bc		;07ad	09		.
	inc a			;07ae	3c		<
	ld (de),a		;07af	12		.
	add hl,bc		;07b0	09		.
	ld b,l			;07b1	45		E
	ld (de),a		;07b2	12		.
	add hl,bc		;07b3	09		.
	ld c,(hl)		;07b4	4e		N
	ld (de),a		;07b5	12		.
	add hl,bc		;07b6	09		.
	ld hl,01233h		;07b7	21 33 12	! 3 .
	ld a,009h		;07ba	3e 09		> .
	jp l2aach		;07bc	c3 ac 2a	. . *
	ld hl,l123ch		;07bf	21 3c 12	! < .
	ld a,009h		;07c2	3e 09		> .
	jp l2aach		;07c4	c3 ac 2a	. . *
	ld hl,l1256h+1		;07c7	21 57 12	! W .
	ld a,009h		;07ca	3e 09		> .
	jp l2aach		;07cc	c3 ac 2a	. . *
	ld hl,l1260h		;07cf	21 60 12	! ` .
	ld a,009h		;07d2	3e 09		> .
	jp l2aach		;07d4	c3 ac 2a	. . *
	ld hl,01269h		;07d7	21 69 12	! i .
	ld a,009h		;07da	3e 09		> .
	jp l2aach		;07dc	c3 ac 2a	. . *
	push bc			;07df	c5		.
	push de			;07e0	d5		.
	ex de,hl		;07e1	eb		.
	ld c,a			;07e2	4f		O
	ld b,000h		;07e3	06 00		. .
	call sub_273fh		;07e5	cd 3f 27	. ? '
	push hl			;07e8	e5		.
	ld a,c			;07e9	79		y
	call 047f4h		;07ea	cd f4 47	. . G
	pop hl			;07ed	e1		.
	pop de			;07ee	d1		.
	pop bc			;07ef	c1		.
	xor a			;07f0	af		.
	ret			;07f1	c9		.
	push bc			;07f2	c5		.
	push de			;07f3	d5		.
	push hl			;07f4	e5		.
	push af			;07f5	f5		.
	sub 009h		;07f6	d6 09		. .
	ld hl,02b54h		;07f8	21 54 2b	! T +
	call 047efh		;07fb	cd ef 47	. . G
	ld b,(hl)		;07fe	46		F
	call l2e1ah		;07ff	cd 1a 2e	. . .
	call sub_2a0eh		;0802	cd 0e 2a	. . *
	ld a,b			;0805	78		x
	ld (l2b6ah),a		;0806	32 6a 2b	2 j +
	and a			;0809	a7		.
	jp p,02ae5h		;080a	f2 e5 2a	. . *
	pop af			;080d	f1		.
	ld bc,l0107h		;080e	01 07 01	. . .
	push hl			;0811	e5		.
	call 02812h		;0812	cd 12 28	. . (
	jp l2b14h		;0815	c3 14 2b	. . +
	inc hl			;0818	23		#
	ld c,(hl)		;0819	4e		N
	dec hl			;081a	2b		+
	push hl			;081b	e5		.
	call l2e1ah		;081c	cd 1a 2e	. . .
	call sub_2a0eh		;081f	cd 0e 2a	. . *
	jp c,l2b4dh+1		;0822	da 4e 2b	. N +
	ld a,b			;0825	78		x
	and 008h		;0826	e6 08		. .
	jp nz,l2b0bh		;0828	c2 0b 2b	. . +
	inc hl			;082b	23		#
	ld a,(hl)		;082c	7e		~
	dec hl			;082d	2b		+
	cp c			;082e	b9		.
	jp c,02b07h		;082f	da 07 2b	. . +
	ex (sp),hl		;0832	e3		.
	call l2b6ah+1		;0833	cd 6b 2b	. k +
	ex (sp),hl		;0836	e3		.
	jp l2b0bh		;0837	c3 0b 2b	. . +
	ld a,c			;083a	79		y
	call l2b6ah+1		;083b	cd 6b 2b	. k +
	push hl			;083e	e5		.
	ld bc,00209h		;083f	01 09 02	. . .
	call 02812h		;0842	cd 12 28	. . (
	pop af			;0845	f1		.
	ld (hl),a		;0846	77		w
	ex de,hl		;0847	eb		.
	ld hl,00005h		;0848	21 05 00	! . .
	add hl,de		;084b	19		.
	ld a,(hl)		;084c	7e		~
	inc hl			;084d	23		#
	ld h,(hl)		;084e	66		f
	ld l,a			;084f	6f		o
	inc hl			;0850	23		#
	ld a,(hl)		;0851	7e		~
	ex de,hl		;0852	eb		.
	inc hl			;0853	23		#
	ld (hl),a		;0854	77		w
	ld a,(l2b6ah)		;0855	3a 6a 2b	: j +
	and 010h		;0858	e6 10		. .
	jp z,l2b2ch		;085a	ca 2c 2b	. , +
	ld (hl),004h		;085d	36 04		6 .
	ld a,(hl)		;085f	7e		~
	dec hl			;0860	2b		+
	cp 004h			;0861	fe 04		. .
	jp nz,l2b3ah+1		;0863	c2 3b 2b	. ; +
	ld a,(hl)		;0866	7e		~
	cp 00ah			;0867	fe 0a		. .
	jp nz,l2b3ah+1		;0869	c2 3b 2b	. ; +
	ld (hl),00ch		;086c	36 0c		6 .
	cp 007h			;086e	fe 07		. .
	jp nz,l2b48h		;0870	c2 48 2b	. H +
	ld a,(hl)		;0873	7e		~
	cp 00eh			;0874	fe 0e		. .
	jp nz,l2b48h		;0876	c2 48 2b	. H +
	ld (hl),01eh		;0879	36 1e		6 .
	call sub_2fa4h		;087b	cd a4 2f	. . /
	jp 02b50h		;087e	c3 50 2b	. P +
	pop hl			;0881	e1		.
	pop hl			;0882	e1		.
	pop hl			;0883	e1		.
	pop de			;0884	d1		.
	pop bc			;0885	c1		.
	ret			;0886	c9		.
	add a,b			;0887	80		.
	nop			;0888	00		.
	inc b			;0889	04		.
	jr nz,l08ach		;088a	20 20		   
	ld b,b			;088c	40		@
	nop			;088d	00		.
	jr nz,l08e0h		;088e	20 50		  P
	ld d,b			;0890	50		P
	ld d,b			;0891	50		P
	ld d,b			;0892	50		P
	ld d,b			;0893	50		P
	ld d,b			;0894	50		P
	inc b			;0895	04		.
	jr nz,$-94		;0896	20 a0		  .
	jr nz,l08bah		;0898	20 20		   
	jr nz,l08bch		;089a	20 20		   
	ex af,af'		;089c	08		.
	ld e,b			;089d	58		X
	inc hl			;089e	23		#
	cp (hl)			;089f	be		.
	jp z,l2b8ch		;08a0	ca 8c 2b	. . +
	cp 007h			;08a3	fe 07		. .
	call z,sub_2b8fh	;08a5	cc 8f 2b	. . +
	push de			;08a8	d5		.
	push bc			;08a9	c5		.
	push af			;08aa	f5		.
	ld a,(hl)		;08ab	7e		~
l08ach:
	cp 007h			;08ac	fe 07		. .
	call z,sub_2b8fh	;08ae	cc 8f 2b	. . +
	dec hl			;08b1	2b		+
	push hl			;08b2	e5		.
	ld bc,l0107h		;08b3	01 07 01	. . .
	call 02812h		;08b6	cd 12 28	. . (
	pop af			;08b9	f1		.
l08bah:
	pop bc			;08ba	c1		.
	pop de			;08bb	d1		.
l08bch:
	ld (hl),a		;08bc	77		w
	inc hl			;08bd	23		#
	ld (hl),a		;08be	77		w
	dec hl			;08bf	2b		+
	and a			;08c0	a7		.
	ret			;08c1	c9		.
	call sub_1fefh		;08c2	cd ef 1f	. . .
	inc b			;08c5	04		.
	ret			;08c6	c9		.
	ld hl,(01352h)		;08c7	2a 52 13	* R .
	inc hl			;08ca	23		#
	ld a,(hl)		;08cb	7e		~
	ld (hl),000h		;08cc	36 00		6 .
	dec hl			;08ce	2b		+
	and a			;08cf	a7		.
	jp nz,l2bb4h		;08d0	c2 b4 2b	. . +
	push de			;08d3	d5		.
	push hl			;08d4	e5		.
	ld bc,0009bh		;08d5	01 9b 00	. . .
	call l26d9h+1		;08d8	cd da 26	. . &
	ex de,hl		;08db	eb		.
	pop hl			;08dc	e1		.
	ld (hl),080h		;08dd	36 80		6 .
	inc hl			;08df	23		#
l08e0h:
	ld (hl),e		;08e0	73		s
	inc hl			;08e1	23		#
	ld (hl),d		;08e2	72		r
	ex de,hl		;08e3	eb		.
	pop de			;08e4	d1		.
	ld a,01eh		;08e5	3e 1e		> .
	ld (hl),002h		;08e7	36 02		6 .
	inc hl			;08e9	23		#
	inc hl			;08ea	23		#
	inc hl			;08eb	23		#
	ld (hl),e		;08ec	73		s
	inc hl			;08ed	23		#
	ld (hl),d		;08ee	72		r
	inc hl			;08ef	23		#
	ld (hl),040h		;08f0	36 40		6 @
	ld (01352h),hl		;08f2	22 52 13	" R .
	dec a			;08f5	3d		=
	inc hl			;08f6	23		#
	ld (hl),a		;08f7	77		w
	ld de,0fffah		;08f8	11 fa ff	. . .
	add hl,de		;08fb	19		.
	xor a			;08fc	af		.
	ret			;08fd	c9		.
	push bc			;08fe	c5		.
	push de			;08ff	d5		.
	ld a,(l12b8h)		;0900	3a b8 12	: . .
	ld b,a			;0903	47		G
	ld de,l12a9h		;0904	11 a9 12	. . .
	cp 008h			;0907	fe 08		. .
	jp nz,l2bdch		;0909	c2 dc 2b	. . +
	ld de,l12a5h		;090c	11 a5 12	. . .
	ld hl,l2c3ch		;090f	21 3c 2c	! < ,
	inc hl			;0912	23		#
	inc hl			;0913	23		#
	inc hl			;0914	23		#
	inc hl			;0915	23		#
	ld a,(hl)		;0916	7e		~
	inc hl			;0917	23		#
	cp b			;0918	b8		.
	jp nz,l2bdeh+1		;0919	c2 df 2b	. . +
	ld b,(hl)		;091c	46		F
	inc hl			;091d	23		#
	ld c,(hl)		;091e	4e		N
	inc hl			;091f	23		#
	ld a,(hl)		;0920	7e		~
	inc hl			;0921	23		#
	ld h,(hl)		;0922	66		f
	ld l,a			;0923	6f		o
	push hl			;0924	e5		.
	ld a,(hl)		;0925	7e		~
	inc hl			;0926	23		#
	ld h,(hl)		;0927	66		f
	ld l,a			;0928	6f		o
	or h			;0929	b4		.
	jp z,l2c14h+1		;092a	ca 15 2c	. . ,
	push hl			;092d	e5		.
l092eh:
	push de			;092e	d5		.
	ld de,00008h		;092f	11 08 00	. . .
	add hl,de		;0932	19		.
	pop de			;0933	d1		.
	push bc			;0934	c5		.
	push de			;0935	d5		.
	ld b,000h		;0936	06 00		. .
	call 04843h		;0938	cd 43 48	. C H
	pop de			;093b	d1		.
	pop bc			;093c	c1		.
	pop hl			;093d	e1		.
	jp nz,l2bf2h		;093e	c2 f2 2b	. . +
	inc hl			;0941	23		#
	inc hl			;0942	23		#
	pop de			;0943	d1		.
	pop de			;0944	d1		.
	pop bc			;0945	c1		.
	ld a,(hl)		;0946	7e		~
	ret			;0947	c9		.
	pop hl			;0948	e1		.
	push bc			;0949	c5		.
	push de			;094a	d5		.
	ld b,000h		;094b	06 00		. .
	ld a,008h		;094d	3e 08		> .
	add a,c			;094f	81		.
	ld c,a			;0950	4f		O
	xor a			;0951	af		.
	call l2932h+1		;0952	cd 33 29	. 3 )
	pop de			;0955	d1		.
	pop bc			;0956	c1		.
	push hl			;0957	e5		.
	ld (hl),0ebh		;0958	36 eb		6 .
	inc hl			;095a	23		#
	ld (hl),b		;095b	70		p
	inc hl			;095c	23		#
	ld (hl),020h		;095d	36 20		6  
	inc hl			;095f	23		#
	inc hl			;0960	23		#
	inc hl			;0961	23		#
	inc hl			;0962	23		#
	push hl			;0963	e5		.
	ld a,c			;0964	79		y
	call 047f4h		;0965	cd f4 47	. . G
	call l2952h+1		;0968	cd 53 29	. S )
	pop hl			;096b	e1		.
	dec hl			;096c	2b		+
	ld (hl),a		;096d	77		w
	pop hl			;096e	e1		.
	pop de			;096f	d1		.
	pop bc			;0970	c1		.
	ld a,(hl)		;0971	7e		~
	ret			;0972	c9		.
	ld (bc),a		;0973	02		.
	inc b			;0974	04		.
	ld (bc),a		;0975	02		.
	sub h			;0976	94		.
	ld de,l0504h		;0977	11 04 05	. . .
	inc b			;097a	04		.
	sbc a,d			;097b	9a		.
	ld de,00608h		;097c	11 08 06	. . .
	ex af,af'		;097f	08		.
	sbc a,h			;0980	9c		.
	ld de,00801h		;0981	11 01 08	. . .
	ld bc,l1196h		;0984	01 96 11	. . .
	nop			;0987	00		.
	push hl			;0988	e5		.
	ld hl,l2c5eh+1		;0989	21 5f 2c	! _ ,
	call 04802h		;098c	cd 02 48	. . H
	ld a,(hl)		;098f	7e		~
	pop hl			;0990	e1		.
	ret			;0991	c9		.
	dec b			;0992	05		.
	inc b			;0993	04		.
	inc b			;0994	04		.
	ld (bc),a		;0995	02		.
	rlca			;0996	07		.
	inc bc			;0997	03		.
	ld b,008h		;0998	06 08		. .
	nop			;099a	00		.
	call 02e9eh		;099b	cd 9e 2e	. . .
	ret c			;099e	d8		.
	ret z			;099f	c8		.
	ld a,001h		;09a0	3e 01		> .
	jp l1f60h+1		;09a2	c3 61 1f	. a .
	push hl			;09a5	e5		.
	ld bc,00000h		;09a6	01 00 00	. . .
	push bc			;09a9	c5		.
	call sub_22c2h		;09aa	cd c2 22	. . "
	pop bc			;09ad	c1		.
	jp c,l2d6eh		;09ae	da 6e 2d	. n -
	inc bc			;09b1	03		.
	ld a,(l16aah)		;09b2	3a aa 16	: . .
	and a			;09b5	a7		.
	jp z,l2c97h		;09b6	ca 97 2c	. . ,
	call sub_2fa4h		;09b9	cd a4 2f	. . /
	call sub_2a94h		;09bc	cd 94 2a	. . *
	call sub_2fa4h		;09bf	cd a4 2f	. . /
	ld a,00eh		;09c2	3e 0e		> .
	call l2abeh+1		;09c4	cd bf 2a	. . *
	call l2e1ah		;09c7	cd 1a 2e	. . .
	push hl			;09ca	e5		.
	call 026cdh		;09cb	cd cd 26	. . &
	cp 0e7h			;09ce	fe e7		. .
	jp z,l2c76h		;09d0	ca 76 2c	. v ,
	cp 0e4h			;09d3	fe e4		. .
	jp z,l2caah		;09d5	ca aa 2c	. . ,
	cp 0e2h			;09d8	fe e2		. .
	jp nz,l2d75h+2		;09da	c2 77 2d	. w -
	ld h,b			;09dd	60		`
	ld l,c			;09de	69		i
	add hl,hl		;09df	29		)
	add hl,sp		;09e0	39		9
	ld e,(hl)		;09e1	5e		^
	inc hl			;09e2	23		#
	ld d,(hl)		;09e3	56		V
	ld hl,00005h		;09e4	21 05 00	! . .
	add hl,de		;09e7	19		.
	ld a,(hl)		;09e8	7e		~
	and a			;09e9	a7		.
	call z,l29fch+1		;09ea	cc fd 29	. . )
	ld a,c			;09ed	79		y
	cp (hl)			;09ee	be		.
	jp nz,l2d7eh		;09ef	c2 7e 2d	. ~ -
	inc hl			;09f2	23		#
	ld a,(hl)		;09f3	7e		~
	inc hl			;09f4	23		#
	ld h,(hl)		;09f5	66		f
	ld l,a			;09f6	6f		o
	inc hl			;09f7	23		#
	inc hl			;09f8	23		#
	ld b,c			;09f9	41		A
	ld a,(l16b0h)		;09fa	3a b0 16	: . .
	rra			;09fd	1f		.
	jp c,l2d15h		;09fe	da 15 2d	. . -
	ex (sp),hl		;0a01	e3		.
	call sub_2fa4h		;0a02	cd a4 2f	. . /
	ld a,b			;0a05	78		x
	cp c			;0a06	b9		.
	ld a,00eh		;0a07	3e 0e		> .
	call nz,l2abeh+1	;0a09	c4 bf 2a	. . *
	pop hl			;0a0c	e1		.
l0a0dh:
	dec c			;0a0d	0d		.
	jp z,02cf2h		;0a0e	ca f2 2c	. . ,
	ld e,(hl)		;0a11	5e		^
	inc hl			;0a12	23		#
	ld d,(hl)		;0a13	56		V
	inc hl			;0a14	23		#
	ex de,hl		;0a15	eb		.
	call sub_2846h		;0a16	cd 46 28	. F (
	call sub_2fa4h		;0a19	cd a4 2f	. . /
	ld a,00ch		;0a1c	3e 0c		> .
	call l2abeh+1		;0a1e	cd bf 2a	. . *
	ex de,hl		;0a21	eb		.
	jp l2cceh		;0a22	c3 ce 2c	. . ,
	pop hl			;0a25	e1		.
	push hl			;0a26	e5		.
	inc hl			;0a27	23		#
	ld a,(hl)		;0a28	7e		~
	call 02c55h		;0a29	cd 55 2c	. U ,
	ld l,a			;0a2c	6f		o
	ld h,000h		;0a2d	26 00		& .
	ld (l12a9h),hl		;0a2f	22 a9 12	" . .
	ld a,002h		;0a32	3e 02		> .
	ld (l12b8h),a		;0a34	32 b8 12	2 . .
	call 02bcbh		;0a37	cd cb 2b	. . +
	call sub_2846h		;0a3a	cd 46 28	. F (
	call sub_2fa4h		;0a3d	cd a4 2f	. . /
	ld a,00ch		;0a40	3e 0c		> .
	call l2abeh+1		;0a42	cd bf 2a	. . *
	pop hl			;0a45	e1		.
	and a			;0a46	a7		.
	ret			;0a47	c9		.
	ld (l2d33h),hl		;0a48	22 33 2d	" 3 -
	ld a,b			;0a4b	78		x
	add a,a			;0a4c	87		.
	ld b,a			;0a4d	47		G
	add a,a			;0a4e	87		.
	add a,006h		;0a4f	c6 06		. .
	ld c,a			;0a51	4f		O
	ld a,024h		;0a52	3e 24		> $
	call sub_26b3h		;0a54	cd b3 26	. . &
	ld c,b			;0a57	48		H
	ld (02d85h),hl		;0a58	22 85 2d	" . -
	pop de			;0a5b	d1		.
	ld (hl),e		;0a5c	73		s
	inc hl			;0a5d	23		#
	ld (hl),d		;0a5e	72		r
	inc hl			;0a5f	23		#
	dec c			;0a60	0d		.
	dec c			;0a61	0d		.
	jp nz,l2d28h		;0a62	c2 28 2d	. ( -
	ld de,00000h		;0a65	11 00 00	. . .
	dec de			;0a68	1b		.
	dec de			;0a69	1b		.
	ld c,b			;0a6a	48		H
	ld b,000h		;0a6b	06 00		. .
	ex de,hl		;0a6d	eb		.
	add hl,bc		;0a6e	09		.
	ex de,hl		;0a6f	eb		.
	push hl			;0a70	e5		.
	ex de,hl		;0a71	eb		.
	dec hl			;0a72	2b		+
	ld d,(hl)		;0a73	56		V
	dec hl			;0a74	2b		+
	ld e,(hl)		;0a75	5e		^
	ex de,hl		;0a76	eb		.
	call sub_2846h		;0a77	cd 46 28	. F (
	ex de,hl		;0a7a	eb		.
	ex (sp),hl		;0a7b	e3		.
	ld (hl),e		;0a7c	73		s
	inc hl			;0a7d	23		#
	ld (hl),d		;0a7e	72		r
	inc hl			;0a7f	23		#
	pop de			;0a80	d1		.
	dec c			;0a81	0d		.
	dec c			;0a82	0d		.
	jp nz,l2d3dh		;0a83	c2 3d 2d	. = -
	pop de			;0a86	d1		.
	push de			;0a87	d5		.
	inc de			;0a88	13		.
	ld a,(de)		;0a89	1a		.
	call 02c55h		;0a8a	cd 55 2c	. U ,
	ld (hl),a		;0a8d	77		w
	ld hl,(02d85h)		;0a8e	2a 85 2d	* . -
	ld de,0fffch		;0a91	11 fc ff	. . .
	add hl,de		;0a94	19		.
	pop de			;0a95	d1		.
	inc de			;0a96	13		.
	ld a,(de)		;0a97	1a		.
	ld (hl),a		;0a98	77		w
	dec de			;0a99	1b		.
	dec hl			;0a9a	2b		+
	call sub_2fa4h		;0a9b	cd a4 2f	. . /
	ex de,hl		;0a9e	eb		.
	and a			;0a9f	a7		.
	ret			;0aa0	c9		.
	pop hl			;0aa1	e1		.
	ld a,c			;0aa2	79		y
	sub 001h		;0aa3	d6 01		. .
	ld c,a			;0aa5	4f		O
	ret c			;0aa6	d8		.
	jp l2d6eh		;0aa7	c3 6e 2d	. n -
	call sub_1fefh		;0aaa	cd ef 1f	. . .
	ld bc,06ec3h		;0aad	01 c3 6e	. . n
	dec l			;0ab0	2d		-
	call sub_1fefh		;0ab1	cd ef 1f	. . .
	ld b,0c3h		;0ab4	06 c3		. .
	ld l,(hl)		;0ab6	6e		n
	dec l			;0ab7	2d		-
	nop			;0ab8	00		.
	nop			;0ab9	00		.
	ld hl,(l16b6h)		;0aba	2a b6 16	* . .
	ex de,hl		;0abd	eb		.
	ld hl,(l16bch)		;0abe	2a bc 16	* . .
	ld a,l			;0ac1	7d		}
	sub e			;0ac2	93		.
	ld e,a			;0ac3	5f		_
	ld a,h			;0ac4	7c		|
	sbc a,d			;0ac5	9a		.
	ld d,a			;0ac6	57		W
	jp nc,l2d9ah		;0ac7	d2 9a 2d	. . -
	ld de,00000h		;0aca	11 00 00	. . .
	call 0485ch		;0acd	cd 5c 48	. \ H
	call 04937h		;0ad0	cd 37 49	. 7 I
	jr nz,l0b17h		;0ad3	20 42		  B
	ld a,c			;0ad5	79		y
	ld (hl),h		;0ad6	74		t
	ld h,l			;0ad7	65		e
	ld (hl),e		;0ad8	73		s
	jr nz,l0b21h		;0ad9	20 46		  F
	ld (hl),d		;0adb	72		r
	ld h,l			;0adc	65		e
	ld h,l			;0add	65		e
	dec c			;0ade	0d		.
	adc a,d			;0adf	8a		.
	ret			;0ae0	c9		.
	call 02e9eh		;0ae1	cd 9e 2e	. . .
	ret c			;0ae4	d8		.
	jp z,l2dcbh		;0ae5	ca cb 2d	. . -
	ld a,(l16b0h+1)		;0ae8	3a b1 16	: . .
	and 080h		;0aeb	e6 80		. .
	ret nz			;0aed	c0		.
	ld a,(02067h)		;0aee	3a 67 20	: g  
	and a			;0af1	a7		.
	ret nz			;0af2	c0		.
	call sub_2e08h		;0af3	cd 08 2e	. . .
	cp 09fh			;0af6	fe 9f		. .
	ret z			;0af8	c8		.
	ld a,001h		;0af9	3e 01		> .
	jp l1f60h+1		;0afb	c3 61 1f	. a .
	ld a,(hl)		;0afe	7e		~
	rra			;0aff	1f		.
	ld a,003h		;0b00	3e 03		> .
	call c,l1f60h+1		;0b02	dc 61 1f	. a .
	ld a,(l16b0h+1)		;0b05	3a b1 16	: . .
	and 080h		;0b08	e6 80		. .
	jp nz,l2dfdh+1		;0b0a	c2 fe 2d	. . -
	inc hl			;0b0d	23		#
	inc hl			;0b0e	23		#
	inc hl			;0b0f	23		#
	ld e,(hl)		;0b10	5e		^
	inc hl			;0b11	23		#
	ld d,(hl)		;0b12	56		V
	push hl			;0b13	e5		.
	ld hl,(l13efh)		;0b14	2a ef 13	* . .
l0b17h:
	ld a,e			;0b17	7b		{
	sub l			;0b18	95		.
	ld a,d			;0b19	7a		z
	sbc a,h			;0b1a	9c		.
	jp nc,l2defh+1		;0b1b	d2 f0 2d	. . -
	call sub_1fefh		;0b1e	cd ef 1f	. . .
l0b21h:
	inc bc			;0b21	03		.
	ex de,hl		;0b22	eb		.
	ex de,hl		;0b23	eb		.
	ld (l13efh),hl		;0b24	22 ef 13	" . .
	pop de			;0b27	d1		.
	dec de			;0b28	1b		.
	dec de			;0b29	1b		.
	dec de			;0b2a	1b		.
	dec de			;0b2b	1b		.
	ld a,03fh		;0b2c	3e 3f		> ?
	jp l2a56h+1		;0b2e	c3 57 2a	. W *
	push hl			;0b31	e5		.
	call l2fd2h		;0b32	cd d2 2f	. . /
	pop de			;0b35	d1		.
	ld a,03fh		;0b36	3e 3f		> ?
	jp l2a56h+1		;0b38	c3 57 2a	. W *
	ld a,(l2061h+1)		;0b3b	3a 62 20	: b  
l0b3eh:
	and a			;0b3e	a7		.
	ld hl,(l2063h)		;0b3f	2a 63 20	* c  
	ret nz			;0b42	c0		.
	call sub_16beh		;0b43	cd be 16	. . .
	ld (l2061h+1),a		;0b46	32 62 20	2 b  
	ld (l2063h),hl		;0b49	22 63 20	" c  
	ret			;0b4c	c9		.
	push de			;0b4d	d5		.
	ld hl,(l129ah)		;0b4e	2a 9a 12	* . .
	ex de,hl		;0b51	eb		.
	ld hl,(l129ch)		;0b52	2a 9c 12	* . .
	call 04835h		;0b55	cd 35 48	. 5 H
	call z,sub_2005h	;0b58	cc 05 20	. .  
	dec hl			;0b5b	2b		+
	ld d,(hl)		;0b5c	56		V
	dec hl			;0b5d	2b		+
	ld e,(hl)		;0b5e	5e		^
	ld (l129ch),hl		;0b5f	22 9c 12	" . .
	ex de,hl		;0b62	eb		.
	pop de			;0b63	d1		.
	ret			;0b64	c9		.
	call 026cdh		;0b65	cd cd 26	. . &
	cp 0ech			;0b68	fe ec		. .
	jp z,l2e44h		;0b6a	ca 44 2e	. D .
	cp 0edh			;0b6d	fe ed		. .
	jp z,l2e4ah		;0b6f	ca 4a 2e	. J .
	call sub_1fefh		;0b72	cd ef 1f	. . .
	ld bc,0cdc9h		;0b75	01 c9 cd	. . .
	ld b,(hl)		;0b78	46		F
	jr z,l0b3eh		;0b79	28 c3		( .
	ld c,(hl)		;0b7b	4e		N
	ld l,0cdh		;0b7c	2e cd		. .
	ret z			;0b7e	c8		.
	daa			;0b7f	27		'
	ret c			;0b80	d8		.
	push af			;0b81	f5		.
	ld a,(hl)		;0b82	7e		~
	dec a			;0b83	3d		=
	ld (hl),a		;0b84	77		w
	cp 032h			;0b85	fe 32		. 2
	jp nz,l2e5fh		;0b87	c2 5f 2e	. _ .
	ld de,00005h		;0b8a	11 05 00	. . .
	add hl,de		;0b8d	19		.
	ld a,(hl)		;0b8e	7e		~
	inc hl			;0b8f	23		#
	ld h,(hl)		;0b90	66		f
	ld l,a			;0b91	6f		o
	pop af			;0b92	f1		.
	ret			;0b93	c9		.
	ex (sp),hl		;0b94	e3		.
	push hl			;0b95	e5		.
	call 026cdh		;0b96	cd cd 26	. . &
	pop hl			;0b99	e1		.
	cp (hl)			;0b9a	be		.
	ld a,(hl)		;0b9b	7e		~
	inc hl			;0b9c	23		#
	ex (sp),hl		;0b9d	e3		.
	ret z			;0b9e	c8		.
	push hl			;0b9f	e5		.
	ld hl,l2e79h		;0ba0	21 79 2e	! y .
	call 04802h		;0ba3	cd 02 48	. . H
	ld a,(hl)		;0ba6	7e		~
	call l1f60h+1		;0ba7	cd 61 1f	. a .
	pop hl			;0baa	e1		.
	ret			;0bab	c9		.
	pop hl			;0bac	e1		.
	ld bc,l01e6h		;0bad	01 e6 01	. . .
	rrca			;0bb0	0f		.
	ld bc,l0194h		;0bb1	01 94 01	. . .
	ld e,b			;0bb4	58		X
	ld bc,l015bh		;0bb5	01 5b 01	. [ .
l0bb8h:
	ld de,0e201h		;0bb8	11 01 e2	. . .
	ld bc,l01e7h		;0bbb	01 e7 01	. . .
	sbc a,b			;0bbe	98		.
	ld bc,0019bh		;0bbf	01 9b 01	. . .
	sub l			;0bc2	95		.
	ld bc,0cd00h		;0bc3	01 00 cd	. . .
	call 0fe26h		;0bc6	cd 26 fe	. & .
	ex de,hl		;0bc9	eb		.
	ret nz			;0bca	c0		.
	inc hl			;0bcb	23		#
	ld a,(hl)		;0bcc	7e		~
	dec hl			;0bcd	2b		+
	cp 004h			;0bce	fe 04		. .
	ret			;0bd0	c9		.
	ld a,0afh		;0bd1	3e af		> .
	push af			;0bd3	f5		.
	ld a,001h		;0bd4	3e 01		> .
	ld (02065h),a		;0bd6	32 65 20	2 e  
	call sub_2e08h		;0bd9	cd 08 2e	. . .
	sub 0f0h		;0bdc	d6 f0		. .
	and a			;0bde	a7		.
	ld a,000h		;0bdf	3e 00		> .
	ld (02065h),a		;0be1	32 65 20	2 e  
l0be4h:
	pop bc			;0be4	c1		.
	ret nz			;0be5	c0		.
	call 026cdh		;0be6	cd cd 26	. . &
	ld a,h			;0be9	7c		|
	or l			;0bea	b5		.
	jp nz,l2ebdh		;0beb	c2 bd 2e	. . .
	cp b			;0bee	b8		.
	ret z			;0bef	c8		.
	ex de,hl		;0bf0	eb		.
	ld hl,01354h		;0bf1	21 54 13	! T .
	ld a,(hl)		;0bf4	7e		~
	inc hl			;0bf5	23		#
	add a,a			;0bf6	87		.
	jp nc,l2ecch+2		;0bf7	d2 ce 2e	. . .
	ld a,(hl)		;0bfa	7e		~
	inc hl			;0bfb	23		#
	ld h,(hl)		;0bfc	66		f
	ld l,a			;0bfd	6f		o
	jp l2ec1h		;0bfe	c3 c1 2e	. . .
	jp m,l2ee5h		;0c01	fa e5 2e	. . .
	inc hl			;0c04	23		#
	inc hl			;0c05	23		#
	ld a,(hl)		;0c06	7e		~
	cp e			;0c07	bb		.
	inc hl			;0c08	23		#
	ld a,(hl)		;0c09	7e		~
	inc hl			;0c0a	23		#
	jp nz,l2ec1h		;0c0b	c2 c1 2e	. . .
	cp d			;0c0e	ba		.
	jp nz,l2ec1h		;0c0f	c2 c1 2e	. . .
	ld de,0fffbh		;0c12	11 fb ff	. . .
	add hl,de		;0c15	19		.
	xor a			;0c16	af		.
	ret			;0c17	c9		.
	jp l2b94h		;0c18	c3 94 2b	. . +
	call sub_2e08h		;0c1b	cd 08 2e	. . .
	cp 0e7h			;0c1e	fe e7		. .
	jp nz,02a84h		;0c20	c2 84 2a	. . *
	call 026cdh		;0c23	cd cd 26	. . &
	call sub_22c2h		;0c26	cd c2 22	. . "
	ret c			;0c29	d8		.
	or 001h			;0c2a	f6 01		. .
	ret			;0c2c	c9		.
	call sub_22e4h		;0c2d	cd e4 22	. . "
	ret c			;0c30	d8		.
	cp 007h			;0c31	fe 07		. .
	ret z			;0c33	c8		.
	call sub_1fefh		;0c34	cd ef 1f	. . .
	inc b			;0c37	04		.
	ret			;0c38	c9		.
	ld b,000h		;0c39	06 00		. .
	ld a,00bh		;0c3b	3e 0b		> .
	ld (l16aah+1),a		;0c3d	32 ab 16	2 . .
	ld (hl),c		;0c40	71		q
	ex (sp),hl		;0c41	e3		.
	ld (l2f93h),hl		;0c42	22 93 2f	" . /
	ld a,c			;0c45	79		y
	ld (l2fa2h),a		;0c46	32 a2 2f	2 . /
	ld (l2fa2h+1),a		;0c49	32 a3 2f	2 . /
	add a,a			;0c4c	87		.
	ld c,a			;0c4d	4f		O
	call l26d9h+1		;0c4e	cd da 26	. . &
	ex de,hl		;0c51	eb		.
	pop hl			;0c52	e1		.
	inc hl			;0c53	23		#
	ld (hl),e		;0c54	73		s
	inc hl			;0c55	23		#
	ld (hl),d		;0c56	72		r
	dec hl			;0c57	2b		+
	dec hl			;0c58	2b		+
	push hl			;0c59	e5		.
	dec hl			;0c5a	2b		+
	dec hl			;0c5b	2b		+
	dec hl			;0c5c	2b		+
	ld bc,00001h		;0c5d	01 01 00	. . .
	ld a,(hl)		;0c60	7e		~
	and 0c0h		;0c61	e6 c0		. .
	pop hl			;0c63	e1		.
	jp z,l2f35h		;0c64	ca 35 2f	. 5 /
	dec bc			;0c67	0b		.
	ex (sp),hl		;0c68	e3		.
	ld a,l			;0c69	7d		}
	ld (de),a		;0c6a	12		.
	inc de			;0c6b	13		.
	ld a,h			;0c6c	7c		|
	ld (de),a		;0c6d	12		.
	inc de			;0c6e	13		.
	ex de,hl		;0c6f	eb		.
	push hl			;0c70	e5		.
	ld a,b			;0c71	78		x
	or c			;0c72	b1		.
	jp z,02f5dh		;0c73	ca 5d 2f	. ] /
	ld hl,00006h		;0c76	21 06 00	! . .
	add hl,de		;0c79	19		.
	ld e,(hl)		;0c7a	5e		^
	inc hl			;0c7b	23		#
	ld d,(hl)		;0c7c	56		V
	ld a,d			;0c7d	7a		z
	and e			;0c7e	a3		.
	inc a			;0c7f	3c		<
	call z,sub_2f95h	;0c80	cc 95 2f	. . /
	ld a,d			;0c83	7a		z
	or e			;0c84	b3		.
	call z,sub_2f9dh	;0c85	cc 9d 2f	. . /
	call sub_489ah		;0c88	cd 9a 48	. . H
	call nz,sub_2f95h	;0c8b	c4 95 2f	. . /
	ld b,h			;0c8e	44		D
	ld c,l			;0c8f	4d		M
	pop de			;0c90	d1		.
	ld hl,l2fa2h		;0c91	21 a2 2f	! . /
	dec (hl)		;0c94	35		5
	pop hl			;0c95	e1		.
	jp nz,l2f35h		;0c96	c2 35 2f	. 5 /
	ld a,b			;0c99	78		x
	or c			;0c9a	b1		.
	jp z,02f8ch		;0c9b	ca 8c 2f	. . /
	push hl			;0c9e	e5		.
	ld de,0fffch		;0c9f	11 fc ff	. . .
	add hl,de		;0ca2	19		.
	ld a,(hl)		;0ca3	7e		~
	call 02c55h		;0ca4	cd 55 2c	. U ,
	ld hl,00000h		;0ca7	21 00 00	! . .
	add hl,bc		;0caa	09		.
	call c,sub_2f95h	;0cab	dc 95 2f	. . /
	dec a			;0cae	3d		=
	jp nz,l2f77h		;0caf	c2 77 2f	. w /
	ld b,h			;0cb2	44		D
	ld c,l			;0cb3	4d		M
	call sub_2792h		;0cb4	cd 92 27	. . '
	ex de,hl		;0cb7	eb		.
	pop hl			;0cb8	e1		.
	push hl			;0cb9	e5		.
	dec hl			;0cba	2b		+
	ld (hl),d		;0cbb	72		r
	dec hl			;0cbc	2b		+
	ld (hl),e		;0cbd	73		s
	pop hl			;0cbe	e1		.
	ld a,(l2fa2h+1)		;0cbf	3a a3 2f	: . /
	ld c,a			;0cc2	4f		O
	ld b,000h		;0cc3	06 00		. .
	jp 00695h		;0cc5	c3 95 06	. . .
	call sub_1fefh		;0cc8	cd ef 1f	. . .
	ld (bc),a		;0ccb	02		.
	ld hl,00000h		;0ccc	21 00 00	! . .
	ret			;0ccf	c9		.
	call sub_1fefh		;0cd0	cd ef 1f	. . .
	ld b,0c9h		;0cd3	06 c9		. .
	nop			;0cd5	00		.
	ld bc,0ebd5h		;0cd6	01 d5 eb	. . .
	ld hl,(l129ch)		;0cd9	2a 9c 12	* . .
	ld (hl),e		;0cdc	73		s
	inc hl			;0cdd	23		#
	ld (hl),d		;0cde	72		r
	inc hl			;0cdf	23		#
	push de			;0ce0	d5		.
	ld (l129ch),hl		;0ce1	22 9c 12	" . .
	ld de,0dab5h		;0ce4	11 b5 da	. . .
	add hl,de		;0ce7	19		.
	pop hl			;0ce8	e1		.
	pop de			;0ce9	d1		.
	inc hl			;0cea	23		#
	ld a,(hl)		;0ceb	7e		~
	dec hl			;0cec	2b		+
	ret nc			;0ced	d0		.
	call sub_1fefh		;0cee	cd ef 1f	. . .
	dec b			;0cf1	05		.
	push hl			;0cf2	e5		.
	ld hl,(l129ch)		;0cf3	2a 9c 12	* . .
	dec hl			;0cf6	2b		+
	dec hl			;0cf7	2b		+
	ld (l129ch),hl		;0cf8	22 9c 12	" . .
	pop hl			;0cfb	e1		.
	ret			;0cfc	c9		.
	pop hl			;0cfd	e1		.
	pop hl			;0cfe	e1		.
	pop hl			;0cff	e1		.
	pop hl			;0d00	e1		.
	pop hl			;0d01	e1		.
	ret			;0d02	c9		.
	pop de			;0d03	d1		.
	ret			;0d04	c9		.
	ld hl,00000h		;0d05	21 00 00	! . .
	add hl,sp		;0d08	39		9
l0d09h:
	ld (l2fe5h+1),hl	;0d09	22 e6 2f	" . /
	ld hl,l2fe5h		;0d0c	21 e5 2f	! . /
	ld (l2068h),hl		;0d0f	22 68 20	" h  
	call 03005h		;0d12	cd 05 30	. . 0
	call sub_57f2h		;0d15	cd f2 57	. . W
	ld sp,0dc03h		;0d18	31 03 dc	1 . .
	ld hl,(l16b8h)		;0d1b	2a b8 16	* . .
	ld (l16bah),hl		;0d1e	22 ba 16	" . .
	ld hl,00000h		;0d21	21 00 00	! . .
	ld (l1228h),hl		;0d24	22 28 12	" ( .
	ld (l16a6h+1),hl	;0d27	22 a7 16	" . .
	ld (l2068h),hl		;0d2a	22 68 20	" h  
	ld hl,l1228h		;0d2d	21 28 12	! ( .
	ld (l122ah),hl		;0d30	22 2a 12	" * .
	xor a			;0d33	af		.
	ld (l122ch),a		;0d34	32 2c 12	2 , .
	ret			;0d37	c9		.
	ld bc,0001ah		;0d38	01 1a 00	. . .
	call sub_273fh		;0d3b	cd 3f 27	. ? '
	ld (0122fh),hl		;0d3e	22 2f 12	" / .
	ld hl,l1228h		;0d41	21 28 12	! ( .
	ld a,(hl)		;0d44	7e		~
	inc hl			;0d45	23		#
	ld h,(hl)		;0d46	66		f
	ld l,a			;0d47	6f		o
	or h			;0d48	b4		.
	jp z,l305fh		;0d49	ca 5f 30	. _ 0
	ld (039feh),hl		;0d4c	22 fe 39	" . 9
	inc hl			;0d4f	23		#
	inc hl			;0d50	23		#
	push hl			;0d51	e5		.
	ld a,(hl)		;0d52	7e		~
	inc hl			;0d53	23		#
	ld h,(hl)		;0d54	66		f
	ld l,a			;0d55	6f		o
	push hl			;0d56	e5		.
	call sub_39e5h		;0d57	cd e5 39	. . 9
	call sub_39f1h		;0d5a	cd f1 39	. . 9
	jp z,l3039h		;0d5d	ca 39 30	. 9 0
	call sub_310ah		;0d60	cd 0a 31	. . 1
	call 0310fh		;0d63	cd 0f 31	. . 1
	call 03114h		;0d66	cd 14 31	. . 1
	jp l3027h		;0d69	c3 27 30	. ' 0
	pop hl			;0d6c	e1		.
	ld a,(hl)		;0d6d	7e		~
	sub 059h		;0d6e	d6 59		. Y
	jp z,l3041h		;0d70	ca 41 30	. A 0
	dec a			;0d73	3d		=
	call z,l3065h+1		;0d74	cc 66 30	. f 0
	call sub_380dh		;0d77	cd 0d 38	. . 8
	ex de,hl		;0d7a	eb		.
	ld a,(l16b0h)		;0d7b	3a b0 16	: . .
	and 020h		;0d7e	e6 20		.  
	ld a,01ah		;0d80	3e 1a		> .
	ld hl,(0122fh)		;0d82	2a 2f 12	* / .
	call nz,sub_4987h	;0d85	c4 87 49	. . I
	pop hl			;0d88	e1		.
	inc hl			;0d89	23		#
	ld (hl),d		;0d8a	72		r
	dec hl			;0d8b	2b		+
	ld (hl),e		;0d8c	73		s
	dec hl			;0d8d	2b		+
	dec hl			;0d8e	2b		+
	jp l3011h		;0d8f	c3 11 30	. . 0
	ld hl,(0122fh)		;0d92	2a 2f 12	* / .
	ld a,01ah		;0d95	3e 1a		> .
	ret			;0d97	c9		.
	nop			;0d98	00		.
	ex de,hl		;0d99	eb		.
	push de			;0d9a	d5		.
	call 030a6h		;0d9b	cd a6 30	. . 0
	pop de			;0d9e	d1		.
	ld hl,00005h		;0d9f	21 05 00	! . .
	add hl,de		;0da2	19		.
	ld a,(hl)		;0da3	7e		~
	inc hl			;0da4	23		#
	ld h,(hl)		;0da5	66		f
	ld l,a			;0da6	6f		o
	ld a,(hl)		;0da7	7e		~
	ex de,hl		;0da8	eb		.
	cp 011h			;0da9	fe 11		. .
	ret c			;0dab	d8		.
	cp 017h			;0dac	fe 17		. .
	ret nc			;0dae	d0		.
	ld a,(hl)		;0daf	7e		~
	cp 05ah			;0db0	fe 5a		. Z
	ld a,(de)		;0db2	1a		.
	call z,sub_39abh	;0db3	cc ab 39	. . 9
	ld bc,00007h		;0db6	01 07 00	. . .
	add hl,bc		;0db9	09		.
	push hl			;0dba	e5		.
	add a,027h		;0dbb	c6 27		. '
	ld bc,l020bh		;0dbd	01 0b 02	. . .
	call sub_26b3h		;0dc0	cd b3 26	. . &
	ld bc,00005h		;0dc3	01 05 00	. . .
	ex de,hl		;0dc6	eb		.
	add hl,bc		;0dc7	09		.
	ex de,hl		;0dc8	eb		.
	ld a,004h		;0dc9	3e 04		> .
	call 047f4h		;0dcb	cd f4 47	. . G
	pop de			;0dce	d1		.
	ld a,002h		;0dcf	3e 02		> .
	call 047f4h		;0dd1	cd f4 47	. . G
	ld de,0fff5h		;0dd4	11 f5 ff	. . .
	add hl,de		;0dd7	19		.
	ret			;0dd8	c9		.
	ld hl,00007h		;0dd9	21 07 00	! . .
	add hl,de		;0ddc	19		.
	ld c,(hl)		;0ddd	4e		N
	inc hl			;0dde	23		#
	ld b,(hl)		;0ddf	46		F
	ld hl,(039feh)		;0de0	2a fe 39	* . 9
	ld a,(hl)		;0de3	7e		~
	inc hl			;0de4	23		#
	ld h,(hl)		;0de5	66		f
	ld l,a			;0de6	6f		o
	or h			;0de7	b4		.
	ret z			;0de8	c8		.
	inc hl			;0de9	23		#
	inc hl			;0dea	23		#
	ld e,(hl)		;0deb	5e		^
	inc hl			;0dec	23		#
	ld d,(hl)		;0ded	56		V
	ld a,(de)		;0dee	1a		.
	cp 058h			;0def	fe 58		. X
	ret nz			;0df1	c0		.
	push hl			;0df2	e5		.
	ld hl,00005h		;0df3	21 05 00	! . .
	add hl,de		;0df6	19		.
	ld a,(hl)		;0df7	7e		~
	inc hl			;0df8	23		#
	ld h,(hl)		;0df9	66		f
	ld l,a			;0dfa	6f		o
	ld (l3104h),hl		;0dfb	22 04 31	" . 1
	pop hl			;0dfe	e1		.
	dec hl			;0dff	2b		+
	dec hl			;0e00	2b		+
	ld a,(hl)		;0e01	7e		~
	dec hl			;0e02	2b		+
	ld l,(hl)		;0e03	6e		n
	ld h,a			;0e04	67		g
	or l			;0e05	b5		.
	ret z			;0e06	c8		.
	inc hl			;0e07	23		#
	inc hl			;0e08	23		#
	ld e,(hl)		;0e09	5e		^
	inc hl			;0e0a	23		#
	ld d,(hl)		;0e0b	56		V
	ex de,hl		;0e0c	eb		.
	ld a,(hl)		;0e0d	7e		~
	cp 034h			;0e0e	fe 34		. 4
	ret nz			;0e10	c0		.
	inc hl			;0e11	23		#
	inc hl			;0e12	23		#
	inc hl			;0e13	23		#
	inc hl			;0e14	23		#
	inc hl			;0e15	23		#
	ld a,(hl)		;0e16	7e		~
	cp c			;0e17	b9		.
	ret nz			;0e18	c0		.
	inc hl			;0e19	23		#
	ld a,(hl)		;0e1a	7e		~
	cp b			;0e1b	b8		.
	ret nz			;0e1c	c0		.
	ld hl,(039feh)		;0e1d	2a fe 39	* . 9
	dec de			;0e20	1b		.
	dec de			;0e21	1b		.
	dec de			;0e22	1b		.
	ld a,(de)		;0e23	1a		.
	ld (hl),a		;0e24	77		w
	inc de			;0e25	13		.
	inc hl			;0e26	23		#
	ld a,(de)		;0e27	1a		.
	ld (hl),a		;0e28	77		w
	inc hl			;0e29	23		#
	ld a,(hl)		;0e2a	7e		~
	inc hl			;0e2b	23		#
	ld h,(hl)		;0e2c	66		f
	ld l,a			;0e2d	6f		o
l0e2eh:
	ld a,0b3h		;0e2e	3e b3		> .
	sub (hl)		;0e30	96		.
	ld (hl),a		;0e31	77		w
	ld de,00007h		;0e32	11 07 00	. . .
	add hl,de		;0e35	19		.
	ld bc,0a4a2h		;0e36	01 a2 a4	. . .
	ld (hl),c		;0e39	71		q
	inc hl			;0e3a	23		#
	ld (hl),b		;0e3b	70		p
	ret			;0e3c	c9		.
	ld a,000h		;0e3d	3e 00		> .
	jp 03116h		;0e3f	c3 16 31	. . 1
	ld a,001h		;0e42	3e 01		> .
	jp 03116h		;0e44	c3 16 31	. . 1
	ld a,002h		;0e47	3e 02		> .
	push hl			;0e49	e5		.
	ld hl,(l3063h+1)	;0e4a	2a 64 30	* d 0
	ld (l3065h),a		;0e4d	32 65 30	2 e 0
	ex (sp),hl		;0e50	e3		.
	call sub_3126h		;0e51	cd 26 31	. & 1
l0e54h:
	pop af			;0e54	f1		.
	ld (l3065h),a		;0e55	32 65 30	2 e 0
l0e58h:
	ret			;0e58	c9		.
	ld a,(hl)		;0e59	7e		~
l0e5ah:
	cp 004h			;0e5a	fe 04		. .
l0e5ch:
	jp c,l3171h		;0e5c	da 71 31	. q 1
	push bc			;0e5f	c5		.
l0e60h:
	push de			;0e60	d5		.
	push hl			;0e61	e5		.
l0e62h:
	call sub_39e5h		;0e62	cd e5 39	. . 9
	call sub_39f1h		;0e65	cd f1 39	. . 9
l0e68h:
	jp z,0313eh		;0e68	ca 3e 31	. > 1
	call sub_3126h		;0e6b	cd 26 31	. & 1
	jp l3132h		;0e6e	c3 32 31	. 2 1
	pop hl			;0e71	e1		.
	ld b,000h		;0e72	06 00		. .
	call sub_314ch		;0e74	cd 4c 31	. L 1
	ld a,b			;0e77	78		x
	and a			;0e78	a7		.
	jp nz,l313fh		;0e79	c2 3f 31	. ? 1
	pop de			;0e7c	d1		.
	pop bc			;0e7d	c1		.
l0e7eh:
	ret			;0e7e	c9		.
	ld a,(l3065h)		;0e7f	3a 65 30	: e 0
	dec a			;0e82	3d		=
	jp z,l3165h		;0e83	ca 65 31	. e 1
	jp p,l3167h+1		;0e86	f2 68 31	. h 1
	call l3171h		;0e89	cd 71 31	. q 1
	call 034fdh		;0e8c	cd fd 34	. . 4
	call sub_31c7h		;0e8f	cd c7 31	. . 1
	call sub_3280h		;0e92	cd 80 32	. . 2
	jp l32f6h		;0e95	c3 f6 32	. . 2
	jp l324dh+1		;0e98	c3 4e 32	. N 2
	call l3171h		;0e9b	cd 71 31	. q 1
	call 034fdh		;0e9e	cd fd 34	. . 4
	jp l32f6h		;0ea1	c3 f6 32	. . 2
	push de			;0ea4	d5		.
	push hl			;0ea5	e5		.
	ld a,(hl)		;0ea6	7e		~
	cp 004h			;0ea7	fe 04		. .
	jp nc,l3193h+1		;0ea9	d2 94 31	. . 1
	add a,001h		;0eac	c6 01		. .
	cp 002h			;0eae	fe 02		. .
	jp nz,l31bdh+1		;0eb0	c2 be 31	. . 1
	ld de,00005h		;0eb3	11 05 00	. . .
	add hl,de		;0eb6	19		.
	ld e,(hl)		;0eb7	5e		^
	inc hl			;0eb8	23		#
	ld d,(hl)		;0eb9	56		V
	ld a,(de)		;0eba	1a		.
	cp 0ebh			;0ebb	fe eb		. .
	ld a,001h		;0ebd	3e 01		> .
	jp z,l31bdh+1		;0ebf	ca be 31	. . 1
	ld a,002h		;0ec2	3e 02		> .
	jp l31bdh+1		;0ec4	c3 be 31	. . 1
	call 039d8h		;0ec7	cd d8 39	. . 9
	add a,a			;0eca	87		.
	jp c,031a0h		;0ecb	da a0 31	. . 1
	ld a,005h		;0ece	3e 05		> .
	jp l31bdh+1		;0ed0	c3 be 31	. . 1
	inc hl			;0ed3	23		#
	ld a,(hl)		;0ed4	7e		~
	cp 005h			;0ed5	fe 05		. .
	jp z,l319bh		;0ed7	ca 9b 31	. . 1
	cp 006h			;0eda	fe 06		. .
	jp z,l319bh		;0edc	ca 9b 31	. . 1
	inc hl			;0edf	23		#
	inc hl			;0ee0	23		#
	inc hl			;0ee1	23		#
	inc hl			;0ee2	23		#
	ld e,(hl)		;0ee3	5e		^
	inc hl			;0ee4	23		#
	ld d,(hl)		;0ee5	56		V
	inc de			;0ee6	13		.
	inc de			;0ee7	13		.
l0ee8h:
	inc de			;0ee8	13		.
	ld a,(de)		;0ee9	1a		.
l0eeah:
	cp 003h			;0eea	fe 03		. .
	jp nc,l31bdh+1		;0eec	d2 be 31	. . 1
	ld a,003h		;0eef	3e 03		> .
	pop hl			;0ef1	e1		.
	pop de			;0ef2	d1		.
	push hl			;0ef3	e5		.
l0ef4h:
	inc hl			;0ef4	23		#
	inc hl			;0ef5	23		#
l0ef6h:
	inc hl			;0ef6	23		#
	ld (hl),a		;0ef7	77		w
l0ef8h:
	pop hl			;0ef8	e1		.
	ret			;0ef9	c9		.
	ld a,(hl)		;0efa	7e		~
l0efbh:
	cp 004h			;0efb	fe 04		. .
l0efdh:
	ret c			;0efd	d8		.
	cp 032h			;0efe	fe 32		. 2
	jp z,l3990h		;0f00	ca 90 39	. . 9
l0f03h:
	push bc			;0f03	c5		.
	push hl			;0f04	e5		.
; HUD state words (runtime memory)
score_word:
	call 039d8h		;0f05	cd d8 39	. . 9
	ld b,a			;0f08	47		G
l0f09h:
	rra			;0f09	1f		.
	jp c,l3242h		;0f0a	da 42 32	. B 2
	ld de,00004h		;0f0d	11 04 00	. . .
	add hl,de		;0f10	19		.
l0f11h:
	ld c,(hl)		;0f11	4e		N
	inc hl			;0f12	23		#
	ld e,(hl)		;0f13	5e		^
l0f14h:
	inc hl			;0f14	23		#
	ld d,(hl)		;0f15	56		V
	inc hl			;0f16	23		#
l0f17h:
	ld a,(hl)		;0f17	7e		~
	inc hl			;0f18	23		#
	ld h,(hl)		;0f19	66		f
l0f1ah:
	ld l,a			;0f1a	6f		o
	dec c			;0f1b	0d		.
l0f1ch:
	call nz,l28fah+1	;0f1c	c4 fb 28	. . (
l0f1fh:
	jp c,l3242h		;0f1f	da 42 32	. B 2
	ex de,hl		;0f22	eb		.
l0f23h:
	call l28fah+1		;0f23	cd fb 28	. . (
l0f26h:
	jp c,031feh		;0f26	da fe 31	. . 1
	pop hl			;0f29	e1		.
	pop bc			;0f2a	c1		.
l0f2bh:
	ld b,(hl)		;0f2b	46		F
	call 0361bh		;0f2c	cd 1b 36	. . 6
	ld b,(hl)		;0f2f	46		F
	ret			;0f30	c9		.
l0f31h:
	ld a,b			;0f31	78		x
	and 020h		;0f32	e6 20		.  
l0f34h:
	jp z,l3242h		;0f34	ca 42 32	. B 2
l0f37h:
	ex (sp),hl		;0f37	e3		.
	ld a,(hl)		;0f38	7e		~
	ex (sp),hl		;0f39	e3		.
l0f3ah:
	cp (hl)			;0f3a	be		.
	jp nz,l3242h		;0f3b	c2 42 32	. B 2
	ld c,a			;0f3e	4f		O
	push de			;0f3f	d5		.
l0f40h:
	ex de,hl		;0f40	eb		.
	ld hl,00007h		;0f41	21 07 00	! . .
l0f44h:
	add hl,de		;0f44	19		.
	ld a,(hl)		;0f45	7e		~
l0f46h:
	inc hl			;0f46	23		#
	ld h,(hl)		;0f47	66		f
	ld l,a			;0f48	6f		o
l0f49h:
	call l28fah+1		;0f49	cd fb 28	. . (
l0f4ch:
	jp c,l3240h+1		;0f4c	da 41 32	. A 2
	ld (l3249h+1),hl	;0f4f	22 4a 32	" J 2
l0f52h:
	pop hl			;0f52	e1		.
	ld (0324ch),hl		;0f53	22 4c 32	" L 2
l0f56h:
	ex de,hl		;0f56	eb		.
	pop de			;0f57	d1		.
	ld a,(hl)		;0f58	7e		~
l0f59h:
	push hl			;0f59	e5		.
	inc hl			;0f5a	23		#
l0f5bh:
	ld b,(hl)		;0f5b	46		F
	ld hl,l3245h		;0f5c	21 45 32	! E 2
l0f5fh:
	ld (hl),a		;0f5f	77		w
	inc hl			;0f60	23		#
l0f61h:
	ld (hl),b		;0f61	70		p
	dec hl			;0f62	2b		+
	call 0361bh		;0f63	cd 1b 36	. . 6
	pop bc			;0f66	c1		.
lads_word:
	ex de,hl		;0f67	eb		.
	ld hl,00007h		;0f68	21 07 00	! . .
l0f6bh:
	add hl,bc		;0f6b	09		.
	ld (hl),e		;0f6c	73		s
l0f6dh:
	inc hl			;0f6d	23		#
	ld (hl),d		;0f6e	72		r
l0f6fh:
	ld h,b			;0f6f	60		`
	ld l,c			;0f70	69		i
l0f71h:
	pop bc			;0f71	c1		.
	ld b,(hl)		;0f72	46		F
l0f73h:
	ret			;0f73	c9		.
	pop hl			;0f74	e1		.
l0f75h:
	pop hl			;0f75	e1		.
	pop bc			;0f76	c1		.
bonus_word:
	ret			;0f77	c9		.
	ld c,004h		;0f78	0e 04		. .
	nop			;0f7a	00		.
l0f7bh:
	nop			;0f7b	00		.
	ld (bc),a		;0f7c	02		.
l0f7dh:
	ret pe			;0f7d	e8		.
	exx			;0f7e	d9		.
l0f7fh:
	call nz,sub_7ed9h	;0f7f	c4 d9 7e	. . ~
	cp 00bh			;0f82	fe 0b		. .
	ret nz			;0f84	c0		.
l0f85h:
	ex de,hl		;0f85	eb		.
	ld hl,00005h		;0f86	21 05 00	! . .
l0f89h:
	add hl,de		;0f89	19		.
	ld c,(hl)		;0f8a	4e		N
l0f8bh:
	inc hl			;0f8b	23		#
	ld b,(hl)		;0f8c	46		F
l0f8dh:
	inc hl			;0f8d	23		#
	ld a,(bc)		;0f8e	0a		.
l0f8fh:
	ex de,hl		;0f8f	eb		.
	cp (hl)			;0f90	be		.
l0f91h:
	jp nz,l327dh		;0f91	c2 7d 32	. } 2
	dec (hl)		;0f94	35		5
l0f95h:
	ld hl,00008h		;0f95	21 08 00	! . .
	add hl,bc		;0f98	09		.
l0f99h:
	ld b,(hl)		;0f99	46		F
	dec hl			;0f9a	2b		+
l0f9bh:
	ld c,(hl)		;0f9b	4e		N
	ex de,hl		;0f9c	eb		.
l0f9dh:
	dec hl			;0f9d	2b		+
	ld (hl),b		;0f9e	70		p
l0f9fh:
	dec hl			;0f9f	2b		+
	ld (hl),c		;0fa0	71		q
l0fa1h:
	ld bc,0fffbh		;0fa1	01 fb ff	. . .
	add hl,bc		;0fa4	09		.
l0fa5h:
	call sub_310ah		;0fa5	cd 0a 31	. . 1
	ex de,hl		;0fa8	eb		.
l0fa9h:
	ld (hl),e		;0fa9	73		s
	inc hl			;0faa	23		#
l0fabh:
	ld (hl),d		;0fab	72		r
	ld bc,0fff8h		;0fac	01 f8 ff	. . .
l0fafh:
	add hl,bc		;0faf	09		.
	ld b,000h		;0fb0	06 00		. .
actor_index_word:
	ret			;0fb2	c9		.
	ld a,(hl)		;0fb3	7e		~
l0fb4h:
	cp 00ah			;0fb4	fe 0a		. .
l0fb6h:
	jp z,l3289h		;0fb6	ca 89 32	. . 2
	cp 00ch			;0fb9	fe 0c		. .
	ret nz			;0fbb	c0		.
l0fbch:
	ld (l32edh),a		;0fbc	32 ed 32	2 . 2
	push bc			;0fbf	c5		.
l0fc0h:
	push hl			;0fc0	e5		.
	ld de,00005h		;0fc1	11 05 00	. . .
l0fc4h:
	add hl,de		;0fc4	19		.
	ld e,(hl)		;0fc5	5e		^
l0fc6h:
	inc hl			;0fc6	23		#
	ld d,(hl)		;0fc7	56		V
l0fc8h:
	inc hl			;0fc8	23		#
	ld a,(hl)		;0fc9	7e		~
l0fcah:
	inc hl			;0fca	23		#
	ld h,(hl)		;0fcb	66		f
l0fcch:
	ld l,a			;0fcc	6f		o
	ld a,(de)		;0fcd	1a		.
l0fceh:
	cp 00eh			;0fce	fe 0e		. .
l0fd0h:
	scf			;0fd0	37		7
	call z,l28fah+1		;0fd1	cc fb 28	. . (
l0fd4h:
	jp c,032eah		;0fd4	da ea 32	. . 2
	ld (l32f2h),hl		;0fd7	22 f2 32	" . 2
l0fdah:
	ld hl,00005h		;0fda	21 05 00	! . .
	add hl,de		;0fdd	19		.
l0fdeh:
	ld c,(hl)		;0fde	4e		N
	inc hl			;0fdf	23		#
l0fe0h:
	ld b,(hl)		;0fe0	46		F
	inc hl			;0fe1	23		#
l0fe2h:
	ld a,(hl)		;0fe2	7e		~
	inc hl			;0fe3	23		#
	ld h,(hl)		;0fe4	66		f
	ld l,a			;0fe5	6f		o
	call l28fah+1		;0fe6	cd fb 28	. . (
	jp c,032eah		;0fe9	da ea 32	. . 2
	ld (l32f4h),hl		;0fec	22 f4 32	" . 2
	ex de,hl		;0fef	eb		.
	ex (sp),hl		;0ff0	e3		.
	ex de,hl		;0ff1	eb		.
	ld hl,00005h		;0ff2	21 05 00	! . .
	add hl,de		;0ff5	19		.
l0ff6h:
	ld (hl),c		;0ff6	71		q
	inc hl			;0ff7	23		#
	ld (hl),b		;0ff8	70		p
	push de			;0ff9	d5		.
; BASCOM startup transfers control through $66B0
startup:
	ld hl,main_code		;0ffa	21 0e 10	! . .
	jp l66b0h		;0ffd	c3 b0 66	. . f

; BLOCK 'startup_record' (start 0x1000 end 0x100e)
startup_record_start:
	defb 065h		;1000	65		e
	defb 061h		;1001	61		a
l1002h:
	defb 0cbh		;1002	cb		.
	defb 010h		;1003	10		.
	defb 067h		;1004	67		g
	defb 061h		;1005	61		a
l1006h:
	defb 003h		;1006	03		.
	defb 001h		;1007	01		.
	defb 0e4h		;1008	e4		.
	defb 00fh		;1009	0f		.
l100ah:
	defb 000h		;100a	00		.
	defb 000h		;100b	00		.
l100ch:
	defb 0fah		;100c	fa		.
	defb 00fh		;100d	0f		.
; Compiled game main code
main_code:
	ld hl,000ffh		;100e	21 ff 00	! . .
	call width_setting	;1011	cd 5e 70	. ^ p
	ld hl,00000h		;1014	21 00 00	! . .
	ld (l0ef4h),hl		;1017	22 f4 0e	" . .
	ld hl,(l0ef4h)		;101a	2a f4 0e	* . .
	ld a,h			;101d	7c		|
	cpl			;101e	2f		/
	ld h,a			;101f	67		g
	ld a,l			;1020	7d		}
	cpl			;1021	2f		/
	ld l,a			;1022	6f		o
	ld (l0ef6h),hl		;1023	22 f6 0e	" . .
	ld de,l0ef8h		;1026	11 f8 0e	. . .
	ld hl,s_version_number	;1029	21 37 61	! 7 a
	call string_assign	;102c	cd db 74	. . t
	ld hl,00014h		;102f	21 14 00	! . .
	ld (l0efbh),hl		;1032	22 fb 0e	" . .
	ld hl,00015h		;1035	21 15 00	! . .
	ld (l0efdh),hl		;1038	22 fd 0e	" . .
	ld hl,00017h		;103b	21 17 00	! . .
	ld (00effh),hl		;103e	22 ff 0e	" . .
	ld hl,00019h		;1041	21 19 00	! . .
	ld (00f01h),hl		;1044	22 01 0f	" . .
	ld hl,l0bb8h		;1047	21 b8 0b	! . .
	ld (l0f03h),hl		;104a	22 03 0f	" . .
	ld hl,00000h		;104d	21 00 00	! . .
	ld (score_word),hl	;1050	22 05 0f	" . .
	ld hl,00001h		;1053	21 01 00	! . .
	ld (score_word+2),hl	;1056	22 07 0f	" . .
	ld hl,00005h		;1059	21 05 00	! . .
	ld (l0f09h),hl		;105c	22 09 0f	" . .
	ld de,00f0bh		;105f	11 0b 0f	. . .
	ld hl,s_space		;1062	21 33 61	! 3 a
	call string_assign	;1065	cd db 74	. . t
	ld de,00f0eh		;1068	11 0e 0f	. . .
	ld hl,s_actor_glyphs_alt	;106b	21 25 61	! % a
	call string_assign	;106e	cd db 74	. . t
	ld de,l0f11h		;1071	11 11 0f	. . .
	ld hl,s_actor_glyphs	;1074	21 17 61	! . a
	call string_assign	;1077	cd db 74	. . t
	ld de,l0f14h		;107a	11 14 0f	. . .
	ld hl,s_default_key_subset	;107d	21 0f 61	! . a
	call string_assign	;1080	cd db 74	. . t
	ld de,l0f17h		;1083	11 17 0f	. . .
	ld hl,s_default_key_map	;1086	21 ff 60	! . `
	call string_assign	;1089	cd db 74	. . t
	ld hl,00000h		;108c	21 00 00	! . .
	ld (l0e54h),hl		;108f	22 54 0e	" T .
	ld hl,0ffffh		;1092	21 ff ff	! . .
	ld (00e56h),hl		;1095	22 56 0e	" V .
	ld hl,00001h		;1098	21 01 00	! . .
	ld (l0e58h),hl		;109b	22 58 0e	" X .
	ld hl,0ffffh		;109e	21 ff ff	! . .
	ld (l0e5ah),hl		;10a1	22 5a 0e	" Z .
	ld hl,00001h		;10a4	21 01 00	! . .
	ld (l0e5ch),hl		;10a7	22 5c 0e	" \ .
	ld hl,00000h		;10aa	21 00 00	! . .
	ld (l0e5ch+2),hl	;10ad	22 5e 0e	" ^ .
	ld hl,00002h		;10b0	21 02 00	! . .
	ld (l0e60h),hl		;10b3	22 60 0e	" ` .
	ld hl,00001h		;10b6	21 01 00	! . .
	ld (l0e62h),hl		;10b9	22 62 0e	" b .
	ld hl,00004h		;10bc	21 04 00	! . .
	ld (l0e62h+2),hl	;10bf	22 64 0e	" d .
	ld hl,00003h		;10c2	21 03 00	! . .
	ld (00e66h),hl		;10c5	22 66 0e	" f .
	jp l10d1h		;10c8	c3 d1 10	. . .
	sub 010h		;10cb	d6 10		. .
	jr nz,$+53		;10cd	20 33		  3
	dec (hl)		;10cf	35		5
	nop			;10d0	00		.
l10d1h:
	jp l10deh		;10d1	c3 de 10	. . .
	ex (sp),hl		;10d4	e3		.
	djnz l10f7h		;10d5	10 20		.  
	ld sp,l3030h		;10d7	31 30 30	1 0 0
	jr nc,$+46		;10da	30 2c		0 ,
	dec (hl)		;10dc	35		5
	nop			;10dd	00		.
l10deh:
	jp l111fh+2		;10de	c3 21 11	. ! .
	ld h,011h		;10e1	26 11		& .
	jr nz,l1107h		;10e3	20 22		  "
	jr nz,l1107h		;10e5	20 20		   
	jr nz,l1109h		;10e7	20 20		   
	jr nz,l110bh		;10e9	20 20		   
	jr nz,l110dh		;10eb	20 20		   
	jr nz,l110fh		;10ed	20 20		   
	jr nz,l1111h		;10ef	20 20		   
	jr nz,l1113h		;10f1	20 20		   
	jr nz,l1115h		;10f3	20 20		   
	jr nz,l1117h		;10f5	20 20		   
l10f7h:
	jr nz,l1119h		;10f7	20 20		   
	jr nz,l111bh		;10f9	20 20		   
	jr nz,l111dh		;10fb	20 20		   
	jr nz,l111fh		;10fd	20 20		   
	jr nz,$+34		;10ff	20 20		   
	jr nz,l1123h		;1101	20 20		   
	jr nz,$+34		;1103	20 20		   
	jr nz,$+34		;1105	20 20		   
l1107h:
	jr nz,$+34		;1107	20 20		   
l1109h:
	jr nz,$+34		;1109	20 20		   
l110bh:
	jr nz,$+88		;110b	20 56		  V
l110dh:
	jr nz,$+34		;110d	20 20		   
l110fh:
	jr nz,$+34		;110f	20 20		   
l1111h:
	jr nz,$+34		;1111	20 20		   
l1113h:
	jr nz,$+34		;1113	20 20		   
l1115h:
	jr nz,$+34		;1115	20 20		   
l1117h:
	jr nz,$+34		;1117	20 20		   
l1119h:
	jr nz,$+34		;1119	20 20		   
l111bh:
	jr nz,$+34		;111b	20 20		   
l111dh:
	jr nz,$+38		;111d	20 24		  $
l111fh:
	ld (0c300h),hl		;111f	22 00 c3	" . .
	ld h,h			;1122	64		d
l1123h:
	ld de,l1169h		;1123	11 69 11	. i .
	jr nz,l114ah		;1126	20 22		  "
	jr nz,l114ah		;1128	20 20		   
	jr nz,l114ch		;112a	20 20		   
	jr nz,l114eh		;112c	20 20		   
	jr nz,l1150h		;112e	20 20		   
	jr nz,l1152h		;1130	20 20		   
	jr nz,l1154h		;1132	20 20		   
	jr nz,l1156h		;1134	20 20		   
	jr nz,l1158h		;1136	20 20		   
	jr nz,l115ah		;1138	20 20		   
	jr nz,l115ch		;113a	20 20		   
	jr nz,l115eh		;113c	20 20		   
	jr nz,l1160h		;113e	20 20		   
	jr nz,l1162h		;1140	20 20		   
	jr nz,$+34		;1142	20 20		   
	jr nz,l1166h		;1144	20 20		   
	jr nz,$+34		;1146	20 20		   
	jr nz,$+34		;1148	20 20		   
l114ah:
	jr nz,$+34		;114a	20 20		   
l114ch:
	jr nz,$+34		;114c	20 20		   
l114eh:
	jr nz,$+34		;114e	20 20		   
l1150h:
	jr nz,$+34		;1150	20 20		   
l1152h:
	jr nz,$+34		;1152	20 20		   
l1154h:
	jr nz,$+34		;1154	20 20		   
l1156h:
	jr nz,$+34		;1156	20 20		   
l1158h:
	jr nz,$+34		;1158	20 20		   
l115ah:
	jr nz,l117ch		;115a	20 20		   
l115ch:
	jr nz,l117eh		;115c	20 20		   
l115eh:
	jr nz,l1180h		;115e	20 20		   
l1160h:
	jr nz,$+74		;1160	20 48		  H
l1162h:
	ld (0c300h),hl		;1162	22 00 c3	" . .
	and a			;1165	a7		.
l1166h:
	ld de,l11ach		;1166	11 ac 11	. . .
l1169h:
	jr nz,$+36		;1169	20 22		  "
	jr nz,$+34		;116b	20 20		   
	jr nz,$+34		;116d	20 20		   
	jr nz,$+34		;116f	20 20		   
	jr nz,$+34		;1171	20 20		   
	jr nz,$+34		;1173	20 20		   
	jr nz,$+34		;1175	20 20		   
	jr nz,$+34		;1177	20 20		   
	jr nz,$+34		;1179	20 20		   
	ld c,b			;117b	48		H
l117ch:
	jr nz,l119eh		;117c	20 20		   
l117eh:
	jr nz,l11a0h		;117e	20 20		   
l1180h:
	jr nz,l11a2h		;1180	20 20		   
	jr nz,l11a4h		;1182	20 20		   
	jr nz,$+34		;1184	20 20		   
	jr nz,l11a8h		;1186	20 20		   
	jr nz,$+34		;1188	20 20		   
	jr nz,l11ach		;118a	20 20		   
	jr nz,l11aeh		;118c	20 20		   
	jr nz,l11b0h		;118e	20 20		   
	jr nz,l11b2h		;1190	20 20		   
	jr nz,l11b4h		;1192	20 20		   
	jr nz,l11b6h		;1194	20 20		   
l1196h:
	jr nz,l11b8h		;1196	20 20		   
	jr nz,l11bah		;1198	20 20		   
	jr nz,l11bch		;119a	20 20		   
	jr nz,l11beh		;119c	20 20		   
l119eh:
	jr nz,l11c0h		;119e	20 20		   
l11a0h:
	jr nz,l11c2h		;11a0	20 20		   
l11a2h:
	jr nz,l11c4h		;11a2	20 20		   
l11a4h:
	ld c,b			;11a4	48		H
	ld (0c300h),hl		;11a5	22 00 c3	" . .
l11a8h:
	di			;11a8	f3		.
	ld de,l11f8h		;11a9	11 f8 11	. . .
l11ach:
	jr nz,l11d0h		;11ac	20 22		  "
l11aeh:
	jr nz,l11d0h		;11ae	20 20		   
l11b0h:
	jr nz,l11d2h		;11b0	20 20		   
l11b2h:
	jr nz,l11d4h		;11b2	20 20		   
l11b4h:
	jr nz,$+63		;11b4	20 3d		  =
l11b6h:
	dec a			;11b6	3d		=
	dec a			;11b7	3d		=
l11b8h:
	dec a			;11b8	3d		=
	dec a			;11b9	3d		=
l11bah:
	dec a			;11ba	3d		=
	dec a			;11bb	3d		=
l11bch:
	dec a			;11bc	3d		=
	dec a			;11bd	3d		=
l11beh:
	ld c,b			;11be	48		H
	dec a			;11bf	3d		=
l11c0h:
	dec a			;11c0	3d		=
	dec a			;11c1	3d		=
l11c2h:
	dec a			;11c2	3d		=
	dec a			;11c3	3d		=
l11c4h:
	dec a			;11c4	3d		=
	dec a			;11c5	3d		=
	dec a			;11c6	3d		=
	dec a			;11c7	3d		=
	dec a			;11c8	3d		=
	dec a			;11c9	3d		=
	dec a			;11ca	3d		=
	dec a			;11cb	3d		=
	dec a			;11cc	3d		=
	dec a			;11cd	3d		=
	dec a			;11ce	3d		=
	dec a			;11cf	3d		=
l11d0h:
	dec a			;11d0	3d		=
	dec a			;11d1	3d		=
l11d2h:
	dec a			;11d2	3d		=
	dec a			;11d3	3d		=
l11d4h:
	dec a			;11d4	3d		=
	dec a			;11d5	3d		=
	dec a			;11d6	3d		=
	dec a			;11d7	3d		=
	dec a			;11d8	3d		=
	dec a			;11d9	3d		=
	dec a			;11da	3d		=
	dec a			;11db	3d		=
	dec a			;11dc	3d		=
	dec a			;11dd	3d		=
	dec a			;11de	3d		=
	dec a			;11df	3d		=
	dec a			;11e0	3d		=
	dec a			;11e1	3d		=
	dec a			;11e2	3d		=
	dec a			;11e3	3d		=
	dec a			;11e4	3d		=
	dec a			;11e5	3d		=
	dec a			;11e6	3d		=
	dec a			;11e7	3d		=
	dec a			;11e8	3d		=
	dec a			;11e9	3d		=
	dec a			;11ea	3d		=
	dec a			;11eb	3d		=
	dec a			;11ec	3d		=
	dec a			;11ed	3d		=
	dec a			;11ee	3d		=
	dec a			;11ef	3d		=
	dec a			;11f0	3d		=
	ld (0c300h),hl		;11f1	22 00 c3	" . .
	dec c			;11f4	0d		.
	ld (de),a		;11f5	12		.
	ld (de),a		;11f6	12		.
	ld (de),a		;11f7	12		.
l11f8h:
	jr nz,l121ch		;11f8	20 22		  "
	jr nz,l121ch		;11fa	20 20		   
	jr nz,l121eh		;11fc	20 20		   
	jr nz,l1220h		;11fe	20 20		   
	jr nz,l1222h		;1200	20 20		   
	jr nz,l1224h		;1202	20 20		   
	jr nz,$+34		;1204	20 20		   
	jr nz,l1228h		;1206	20 20		   
	jr nz,l122ah		;1208	20 20		   
	ld c,b			;120a	48		H
	ld (0c300h),hl		;120b	22 00 c3	" . .
	daa			;120e	27		'
	ld (de),a		;120f	12		.
	inc l			;1210	2c		,
	ld (de),a		;1211	12		.
	jr nz,l1236h		;1212	20 22		  "
	jr nz,l1236h		;1214	20 20		   
l1216h:
	jr nz,l1238h		;1216	20 20		   
	jr nz,l123ah		;1218	20 20		   
	jr nz,l123ch		;121a	20 20		   
l121ch:
	jr nz,l123eh		;121c	20 20		   
l121eh:
	jr nz,$+34		;121e	20 20		   
l1220h:
	jr nz,$+34		;1220	20 20		   
l1222h:
	jr nz,$+34		;1222	20 20		   
l1224h:
	ld c,b			;1224	48		H
	ld (0c300h),hl		;1225	22 00 c3	" . .
l1228h:
	ld l,d			;1228	6a		j
	ld (de),a		;1229	12		.
l122ah:
	ld l,a			;122a	6f		o
	ld (de),a		;122b	12		.
l122ch:
	jr nz,l1250h		;122c	20 22		  "
	jr nz,l1250h		;122e	20 20		   
	jr nz,l1252h		;1230	20 20		   
	jr nz,l1254h		;1232	20 20		   
	jr nz,l1256h		;1234	20 20		   
l1236h:
	jr nz,l1258h		;1236	20 20		   
l1238h:
	jr nz,l125ah		;1238	20 20		   
l123ah:
	jr nz,l125ch		;123a	20 20		   
l123ch:
	jr nz,l125eh		;123c	20 20		   
l123eh:
	ld c,b			;123e	48		H
	jr nz,$+34		;123f	20 20		   
	jr nz,$+34		;1241	20 20		   
	jr nz,$+34		;1243	20 20		   
	jr nz,$+34		;1245	20 20		   
	jr nz,$+34		;1247	20 20		   
	ld c,b			;1249	48		H
	jr nz,$+34		;124a	20 20		   
	jr nz,l126eh		;124c	20 20		   
	jr nz,$+34		;124e	20 20		   
l1250h:
	jr nz,l1272h		;1250	20 20		   
l1252h:
	jr nz,l1274h		;1252	20 20		   
l1254h:
	jr nz,l1276h		;1254	20 20		   
l1256h:
	jr nz,l1278h		;1256	20 20		   
l1258h:
	jr nz,l127ah		;1258	20 20		   
l125ah:
	jr nz,l127ch		;125a	20 20		   
l125ch:
	jr nz,l127eh		;125c	20 20		   
l125eh:
	jr nz,l1280h		;125e	20 20		   
l1260h:
	jr nz,l1282h		;1260	20 20		   
	jr nz,l1284h		;1262	20 20		   
	jr nz,l1286h		;1264	20 20		   
	jr nz,l12b0h		;1266	20 48		  H
	ld (0c300h),hl		;1268	22 00 c3	" . .
	jp nz,0c712h		;126b	c2 12 c7	. . .
l126eh:
	ld (de),a		;126e	12		.
	jr nz,l1293h		;126f	20 22		  "
	dec a			;1271	3d		=
l1272h:
	dec a			;1272	3d		=
	dec a			;1273	3d		=
l1274h:
	dec a			;1274	3d		=
	dec a			;1275	3d		=
l1276h:
	dec a			;1276	3d		=
	dec a			;1277	3d		=
l1278h:
	dec a			;1278	3d		=
	dec a			;1279	3d		=
l127ah:
	dec a			;127a	3d		=
	dec a			;127b	3d		=
l127ch:
	dec a			;127c	3d		=
	dec a			;127d	3d		=
l127eh:
	dec a			;127e	3d		=
	dec a			;127f	3d		=
l1280h:
	dec a			;1280	3d		=
	ld c,b			;1281	48		H
l1282h:
	dec a			;1282	3d		=
	dec a			;1283	3d		=
l1284h:
	dec a			;1284	3d		=
	dec a			;1285	3d		=
l1286h:
	dec a			;1286	3d		=
	dec a			;1287	3d		=
	dec a			;1288	3d		=
	dec a			;1289	3d		=
	dec a			;128a	3d		=
	dec a			;128b	3d		=
	ld c,b			;128c	48		H
	dec a			;128d	3d		=
	dec a			;128e	3d		=
	dec a			;128f	3d		=
	dec a			;1290	3d		=
	dec a			;1291	3d		=
	dec a			;1292	3d		=
l1293h:
	dec a			;1293	3d		=
	dec a			;1294	3d		=
	dec a			;1295	3d		=
	dec a			;1296	3d		=
	dec a			;1297	3d		=
	dec a			;1298	3d		=
	dec a			;1299	3d		=
l129ah:
	dec a			;129a	3d		=
	dec a			;129b	3d		=
l129ch:
	dec a			;129c	3d		=
	dec a			;129d	3d		=
	dec a			;129e	3d		=
	jr nz,$+34		;129f	20 20		   
	jr nz,$+63		;12a1	20 3d		  =
	dec a			;12a3	3d		=
	dec a			;12a4	3d		=
l12a5h:
	dec a			;12a5	3d		=
	dec a			;12a6	3d		=
	dec a			;12a7	3d		=
	dec a			;12a8	3d		=
l12a9h:
	dec a			;12a9	3d		=
l12aah:
	ld c,b			;12aa	48		H
	dec a			;12ab	3d		=
	dec a			;12ac	3d		=
	dec a			;12ad	3d		=
	dec a			;12ae	3d		=
l12afh:
	dec a			;12af	3d		=
l12b0h:
	dec a			;12b0	3d		=
	dec a			;12b1	3d		=
	dec a			;12b2	3d		=
	dec a			;12b3	3d		=
	dec a			;12b4	3d		=
	dec a			;12b5	3d		=
	dec a			;12b6	3d		=
	dec a			;12b7	3d		=
l12b8h:
	dec a			;12b8	3d		=
	dec a			;12b9	3d		=
	dec a			;12ba	3d		=
	dec a			;12bb	3d		=
	dec a			;12bc	3d		=
	dec a			;12bd	3d		=
	dec a			;12be	3d		=
	dec a			;12bf	3d		=
	ld (0c300h),hl		;12c0	22 00 c3	" . .
	dec b			;12c3	05		.
	inc de			;12c4	13		.
	ld a,(bc)		;12c5	0a		.
	inc de			;12c6	13		.
	jr nz,l12ebh		;12c7	20 22		  "
	jr nz,l12ebh		;12c9	20 20		   
	jr nz,l12edh		;12cb	20 20		   
l12cdh:
	jr nz,l12efh		;12cd	20 20		   
	jr nz,l12f1h		;12cf	20 20		   
	jr nz,l12f3h		;12d1	20 20		   
	jr nz,l12f5h		;12d3	20 20		   
	jr nz,l12f7h		;12d5	20 20		   
	jr nz,l12f9h		;12d7	20 20		   
	ld h,020h		;12d9	26 20		&  
	jr nz,l12fdh		;12db	20 20		   
	jr nz,l12ffh		;12dd	20 20		   
	jr nz,l1301h		;12df	20 20		   
	jr nz,l1303h		;12e1	20 20		   
	jr nz,$+74		;12e3	20 48		  H
	jr nz,l1307h		;12e5	20 20		   
	jr nz,l1309h		;12e7	20 20		   
	jr nz,$+34		;12e9	20 20		   
l12ebh:
	jr nz,$+34		;12eb	20 20		   
l12edh:
	jr nz,$+34		;12ed	20 20		   
l12efh:
	jr nz,$+34		;12ef	20 20		   
l12f1h:
	jr nz,$+34		;12f1	20 20		   
l12f3h:
	jr nz,$+34		;12f3	20 20		   
l12f5h:
	jr nz,$+34		;12f5	20 20		   
l12f7h:
	jr nz,$+34		;12f7	20 20		   
l12f9h:
	jr nz,$+34		;12f9	20 20		   
	jr nz,$+34		;12fb	20 20		   
l12fdh:
	jr nz,$+34		;12fd	20 20		   
l12ffh:
	jr nz,$+34		;12ff	20 20		   
l1301h:
	jr nz,l134bh		;1301	20 48		  H
l1303h:
	ld (0c300h),hl		;1303	22 00 c3	" . .
	ld c,b			;1306	48		H
l1307h:
	inc de			;1307	13		.
	ld c,l			;1308	4d		M
l1309h:
	inc de			;1309	13		.
	jr nz,l132eh		;130a	20 22		  "
	jr nz,l132eh		;130c	20 20		   
	jr nz,l1330h		;130e	20 20		   
	jr nz,l1332h		;1310	20 20		   
	jr nz,l1334h		;1312	20 20		   
	jr nz,l1336h		;1314	20 20		   
	jr nz,l1338h		;1316	20 20		   
	jr nz,l133ah		;1318	20 20		   
	jr nz,l133ch		;131a	20 20		   
	jr nz,l133eh		;131c	20 20		   
	jr nz,l1340h		;131e	20 20		   
	jr nz,l1342h		;1320	20 20		   
	jr nz,l1344h		;1322	20 20		   
	jr nz,l1346h		;1324	20 20		   
	jr nz,$+34		;1326	20 20		   
	jr nz,l134ah		;1328	20 20		   
	jr nz,l134ch		;132a	20 20		   
	jr nz,$+34		;132c	20 20		   
l132eh:
	jr nz,$+34		;132e	20 20		   
l1330h:
	jr nz,$+34		;1330	20 20		   
l1332h:
	jr nz,$+34		;1332	20 20		   
l1334h:
	jr nz,$+34		;1334	20 20		   
l1336h:
	jr nz,$+34		;1336	20 20		   
l1338h:
	jr nz,$+34		;1338	20 20		   
l133ah:
	jr nz,$+34		;133a	20 20		   
l133ch:
	jr nz,$+34		;133c	20 20		   
l133eh:
	jr nz,l1360h		;133e	20 20		   
l1340h:
	jr nz,l1362h		;1340	20 20		   
l1342h:
	jr nz,l1364h		;1342	20 20		   
l1344h:
	jr nz,$+74		;1344	20 48		  H
l1346h:
	ld (0c300h),hl		;1346	22 00 c3	" . .
	adc a,e			;1349	8b		.
l134ah:
	inc de			;134a	13		.
l134bh:
	sub b			;134b	90		.
l134ch:
	inc de			;134c	13		.
	jr nz,$+36		;134d	20 22		  "
	jr nz,$+34		;134f	20 20		   
	jr nz,$+34		;1351	20 20		   
	jr nz,$+34		;1353	20 20		   
	jr nz,$+34		;1355	20 20		   
	jr nz,$+34		;1357	20 20		   
	jr nz,$+34		;1359	20 20		   
	jr nz,$+34		;135b	20 20		   
	jr nz,$+34		;135d	20 20		   
	ld c,b			;135f	48		H
l1360h:
	jr nz,l1382h		;1360	20 20		   
l1362h:
	jr nz,l1384h		;1362	20 20		   
l1364h:
	jr nz,l1386h		;1364	20 20		   
	jr nz,l1388h		;1366	20 20		   
	jr nz,$+34		;1368	20 20		   
	jr nz,l138ch		;136a	20 20		   
	jr nz,$+34		;136c	20 20		   
	jr nz,l1390h		;136e	20 20		   
	jr nz,l1392h		;1370	20 20		   
	jr nz,l1394h		;1372	20 20		   
	jr nz,l1396h		;1374	20 20		   
	jr nz,l1398h		;1376	20 20		   
	jr nz,l139ah		;1378	20 20		   
	jr nz,l139ch		;137a	20 20		   
	jr nz,l139eh		;137c	20 20		   
	jr nz,l13a0h		;137e	20 20		   
	jr nz,l13a2h		;1380	20 20		   
l1382h:
	jr nz,l13a4h		;1382	20 20		   
l1384h:
	jr nz,l13a6h		;1384	20 20		   
l1386h:
	jr nz,l13a8h		;1386	20 20		   
l1388h:
	ld c,b			;1388	48		H
	ld (0c300h),hl		;1389	22 00 c3	" . .
l138ch:
	jp nc,0d713h		;138c	d2 13 d7	. . .
	inc de			;138f	13		.
l1390h:
	jr nz,l13b4h		;1390	20 22		  "
l1392h:
	jr nz,l13b4h		;1392	20 20		   
l1394h:
	jr nz,l13b6h		;1394	20 20		   
l1396h:
	jr nz,$+34		;1396	20 20		   
l1398h:
	jr nz,l13d7h		;1398	20 3d		  =
l139ah:
	dec a			;139a	3d		=
	dec a			;139b	3d		=
l139ch:
	dec a			;139c	3d		=
	dec a			;139d	3d		=
l139eh:
	dec a			;139e	3d		=
	dec a			;139f	3d		=
l13a0h:
	dec a			;13a0	3d		=
	dec a			;13a1	3d		=
l13a2h:
	ld c,b			;13a2	48		H
	dec a			;13a3	3d		=
l13a4h:
	dec a			;13a4	3d		=
	dec a			;13a5	3d		=
l13a6h:
	dec a			;13a6	3d		=
	dec a			;13a7	3d		=
l13a8h:
	dec a			;13a8	3d		=
	dec a			;13a9	3d		=
	dec a			;13aa	3d		=
	dec a			;13ab	3d		=
	dec a			;13ac	3d		=
	ld c,b			;13ad	48		H
	dec a			;13ae	3d		=
	dec a			;13af	3d		=
	dec a			;13b0	3d		=
	dec a			;13b1	3d		=
	dec a			;13b2	3d		=
	dec a			;13b3	3d		=
l13b4h:
	dec a			;13b4	3d		=
	dec a			;13b5	3d		=
l13b6h:
	dec a			;13b6	3d		=
	jr nz,l13d9h		;13b7	20 20		   
	dec a			;13b9	3d		=
	dec a			;13ba	3d		=
	dec a			;13bb	3d		=
	dec a			;13bc	3d		=
	dec a			;13bd	3d		=
	dec a			;13be	3d		=
	dec a			;13bf	3d		=
	dec a			;13c0	3d		=
	dec a			;13c1	3d		=
	dec a			;13c2	3d		=
	dec a			;13c3	3d		=
	dec a			;13c4	3d		=
	dec a			;13c5	3d		=
	dec a			;13c6	3d		=
	dec a			;13c7	3d		=
	dec a			;13c8	3d		=
	dec a			;13c9	3d		=
	dec a			;13ca	3d		=
	dec a			;13cb	3d		=
	dec a			;13cc	3d		=
	dec a			;13cd	3d		=
	dec a			;13ce	3d		=
	dec a			;13cf	3d		=
	ld (0c300h),hl		;13d0	22 00 c3	" . .
	call pe,0f113h		;13d3	ec 13 f1	. . .
	inc de			;13d6	13		.
l13d7h:
	jr nz,l13fbh		;13d7	20 22		  "
l13d9h:
	jr nz,l13fbh		;13d9	20 20		   
	jr nz,l13fdh		;13db	20 20		   
	jr nz,l13ffh		;13dd	20 20		   
	jr nz,l1401h		;13df	20 20		   
	jr nz,l1403h		;13e1	20 20		   
	jr nz,$+34		;13e3	20 20		   
	jr nz,l1407h		;13e5	20 20		   
	jr nz,l1409h		;13e7	20 20		   
	ld c,b			;13e9	48		H
	ld (0c300h),hl		;13ea	22 00 c3	" . .
	ld b,014h		;13ed	06 14		. .
l13efh:
	dec bc			;13ef	0b		.
	inc d			;13f0	14		.
	jr nz,l1415h		;13f1	20 22		  "
	jr nz,l1415h		;13f3	20 20		   
	jr nz,l1417h		;13f5	20 20		   
	jr nz,l1419h		;13f7	20 20		   
	jr nz,l141bh		;13f9	20 20		   
l13fbh:
	jr nz,l141dh		;13fb	20 20		   
l13fdh:
	jr nz,$+34		;13fd	20 20		   
l13ffh:
	jr nz,$+34		;13ff	20 20		   
l1401h:
	jr nz,$+34		;1401	20 20		   
l1403h:
	ld c,b			;1403	48		H
	ld (0c300h),hl		;1404	22 00 c3	" . .
l1407h:
	ld c,c			;1407	49		I
	inc d			;1408	14		.
l1409h:
	ld c,(hl)		;1409	4e		N
	inc d			;140a	14		.
	jr nz,$+36		;140b	20 22		  "
	jr nz,$+34		;140d	20 20		   
	jr nz,$+34		;140f	20 20		   
	jr nz,$+34		;1411	20 20		   
	jr nz,$+34		;1413	20 20		   
l1415h:
	jr nz,$+34		;1415	20 20		   
l1417h:
	jr nz,$+34		;1417	20 20		   
l1419h:
	jr nz,$+34		;1419	20 20		   
l141bh:
	jr nz,$+34		;141b	20 20		   
l141dh:
	ld c,b			;141d	48		H
	jr nz,l1440h		;141e	20 20		   
	jr nz,l1442h		;1420	20 20		   
	jr nz,l1444h		;1422	20 20		   
	jr nz,l1446h		;1424	20 20		   
	jr nz,$+34		;1426	20 20		   
	jr nz,l144ah		;1428	20 20		   
	jr nz,l144ch		;142a	20 20		   
	jr nz,l144eh		;142c	20 20		   
l142eh:
	jr nz,l1450h		;142e	20 20		   
	jr nz,l1452h		;1430	20 20		   
	jr nz,l1454h		;1432	20 20		   
	jr nz,l1456h		;1434	20 20		   
	jr nz,l1458h		;1436	20 20		   
	jr nz,l145ah		;1438	20 20		   
	jr nz,l145ch		;143a	20 20		   
	jr nz,l145eh		;143c	20 20		   
	jr nz,l1460h		;143e	20 20		   
l1440h:
	jr nz,l1462h		;1440	20 20		   
l1442h:
	jr nz,l1464h		;1442	20 20		   
l1444h:
	jr nz,l1466h		;1444	20 20		   
l1446h:
	ld c,b			;1446	48		H
	ld (0c300h),hl		;1447	22 00 c3	" . .
l144ah:
	sbc a,d			;144a	9a		.
	inc d			;144b	14		.
l144ch:
	sbc a,a			;144c	9f		.
	inc d			;144d	14		.
l144eh:
	jr nz,l1472h		;144e	20 22		  "
l1450h:
	dec a			;1450	3d		=
	dec a			;1451	3d		=
l1452h:
	dec a			;1452	3d		=
	dec a			;1453	3d		=
l1454h:
	dec a			;1454	3d		=
	dec a			;1455	3d		=
l1456h:
	dec a			;1456	3d		=
	dec a			;1457	3d		=
l1458h:
	dec a			;1458	3d		=
	dec a			;1459	3d		=
l145ah:
	dec a			;145a	3d		=
	dec a			;145b	3d		=
l145ch:
	dec a			;145c	3d		=
	dec a			;145d	3d		=
l145eh:
	dec a			;145e	3d		=
	dec a			;145f	3d		=
l1460h:
	dec a			;1460	3d		=
	dec a			;1461	3d		=
l1462h:
	dec a			;1462	3d		=
	dec a			;1463	3d		=
l1464h:
	dec a			;1464	3d		=
	dec a			;1465	3d		=
l1466h:
	dec a			;1466	3d		=
	dec a			;1467	3d		=
	jr nz,l14a7h		;1468	20 3d		  =
	dec a			;146a	3d		=
	dec a			;146b	3d		=
	dec a			;146c	3d		=
	dec a			;146d	3d		=
	dec a			;146e	3d		=
	dec a			;146f	3d		=
	dec a			;1470	3d		=
	dec a			;1471	3d		=
l1472h:
	dec a			;1472	3d		=
	dec a			;1473	3d		=
	dec a			;1474	3d		=
	dec a			;1475	3d		=
	dec a			;1476	3d		=
	dec a			;1477	3d		=
	dec a			;1478	3d		=
	dec a			;1479	3d		=
	dec a			;147a	3d		=
	dec a			;147b	3d		=
	dec a			;147c	3d		=
	dec a			;147d	3d		=
	dec a			;147e	3d		=
	jr nz,$+63		;147f	20 3d		  =
	dec a			;1481	3d		=
	dec a			;1482	3d		=
	dec a			;1483	3d		=
	dec a			;1484	3d		=
	dec a			;1485	3d		=
	dec a			;1486	3d		=
	dec a			;1487	3d		=
	dec a			;1488	3d		=
	ld c,b			;1489	48		H
	dec a			;148a	3d		=
	dec a			;148b	3d		=
	dec a			;148c	3d		=
	dec a			;148d	3d		=
	dec a			;148e	3d		=
	dec a			;148f	3d		=
	dec a			;1490	3d		=
	dec a			;1491	3d		=
	dec a			;1492	3d		=
	dec a			;1493	3d		=
	dec a			;1494	3d		=
	dec a			;1495	3d		=
	dec a			;1496	3d		=
	dec a			;1497	3d		=
	ld (0c300h),hl		;1498	22 00 c3	" . .
	defb 0ddh,014h,0e2h ;illegal sequence	;149b	dd 14 e2	. . .
	inc d			;149e	14		.
	jr nz,l14c3h		;149f	20 22		  "
	jr nz,l14c3h		;14a1	20 20		   
	jr nz,l14c5h		;14a3	20 20		   
	jr nz,l14c7h		;14a5	20 20		   
l14a7h:
	jr nz,l14c9h		;14a7	20 20		   
	jr nz,l14cbh		;14a9	20 20		   
	jr nz,l14cdh		;14ab	20 20		   
	jr nz,l14cfh		;14ad	20 20		   
	jr nz,l14d1h		;14af	20 20		   
	jr nz,l14d3h		;14b1	20 20		   
	jr nz,l14d5h		;14b3	20 20		   
	jr nz,l14d7h		;14b5	20 20		   
	jr nz,l14d9h		;14b7	20 20		   
	jr nz,l14dbh		;14b9	20 20		   
	jr nz,$+34		;14bb	20 20		   
	jr nz,$+34		;14bd	20 20		   
	jr nz,l14e1h		;14bf	20 20		   
	jr nz,$+34		;14c1	20 20		   
l14c3h:
	jr nz,$+34		;14c3	20 20		   
l14c5h:
	jr nz,$+34		;14c5	20 20		   
l14c7h:
	jr nz,$+34		;14c7	20 20		   
l14c9h:
	jr nz,$+34		;14c9	20 20		   
l14cbh:
	jr nz,$+34		;14cb	20 20		   
l14cdh:
	jr nz,$+34		;14cd	20 20		   
l14cfh:
	jr nz,$+34		;14cf	20 20		   
l14d1h:
	jr nz,$+34		;14d1	20 20		   
l14d3h:
	jr nz,$+34		;14d3	20 20		   
l14d5h:
	jr nz,$+34		;14d5	20 20		   
l14d7h:
	jr nz,$+34		;14d7	20 20		   
l14d9h:
	jr nz,l1523h		;14d9	20 48		  H
l14dbh:
	ld (0c300h),hl		;14db	22 00 c3	" . .
	jr nz,$+23		;14de	20 15		  .
	dec h			;14e0	25		%
l14e1h:
	dec d			;14e1	15		.
	jr nz,l1506h		;14e2	20 22		  "
	jr nz,l1506h		;14e4	20 20		   
	jr nz,l1508h		;14e6	20 20		   
	jr nz,l150ah		;14e8	20 20		   
l14eah:
	jr nz,l150ch		;14ea	20 20		   
	jr nz,l150eh		;14ec	20 20		   
	jr nz,l1510h		;14ee	20 20		   
	jr nz,l1512h		;14f0	20 20		   
	jr nz,l1514h		;14f2	20 20		   
	jr nz,l1516h		;14f4	20 20		   
	jr nz,l1518h		;14f6	20 20		   
	jr nz,l151ah		;14f8	20 20		   
	jr nz,l151ch		;14fa	20 20		   
	jr nz,l151eh		;14fc	20 20		   
	jr nz,$+34		;14fe	20 20		   
	jr nz,l1522h		;1500	20 20		   
	jr nz,l1524h		;1502	20 20		   
	jr nz,$+34		;1504	20 20		   
l1506h:
	jr nz,$+34		;1506	20 20		   
l1508h:
	jr nz,l152ah		;1508	20 20		   
l150ah:
	jr nz,l152ch		;150a	20 20		   
l150ch:
	jr nz,$+34		;150c	20 20		   
l150eh:
	jr nz,$+34		;150e	20 20		   
l1510h:
	jr nz,$+34		;1510	20 20		   
l1512h:
	jr nz,$+34		;1512	20 20		   
l1514h:
	jr nz,$+34		;1514	20 20		   
l1516h:
	jr nz,$+34		;1516	20 20		   
l1518h:
	jr nz,$+34		;1518	20 20		   
l151ah:
	jr nz,$+34		;151a	20 20		   
l151ch:
	jr nz,$+74		;151c	20 48		  H
l151eh:
	ld (0c300h),hl		;151e	22 00 c3	" . .
	ld a,b			;1521	78		x
l1522h:
	dec d			;1522	15		.
l1523h:
	ld a,l			;1523	7d		}
l1524h:
	dec d			;1524	15		.
	jr nz,l1549h		;1525	20 22		  "
	ld hl,(l2020h)		;1527	2a 20 20	*    
l152ah:
	jr nz,$+34		;152a	20 20		   
l152ch:
	ld h,a			;152c	67		g
	jr nz,l154fh		;152d	20 20		   
	jr nz,l1551h		;152f	20 20		   
	jr nz,l1553h		;1531	20 20		   
	jr nz,l1555h		;1533	20 20		   
	jr nz,l1557h		;1535	20 20		   
	jr nz,l1559h		;1537	20 20		   
	jr nz,l155bh		;1539	20 20		   
	jr nz,l155dh		;153b	20 20		   
	jr nz,l155fh		;153d	20 20		   
	jr nz,l1561h		;153f	20 20		   
	jr nz,l1563h		;1541	20 20		   
	jr nz,l1565h		;1543	20 20		   
	jr nz,l1567h		;1545	20 20		   
	jr nz,l1569h		;1547	20 20		   
l1549h:
	jr nz,l156bh		;1549	20 20		   
	jr nz,l156dh		;154b	20 20		   
	jr nz,l156fh		;154d	20 20		   
l154fh:
	jr nz,l1571h		;154f	20 20		   
l1551h:
	jr nz,l1573h		;1551	20 20		   
l1553h:
	jr nz,l1575h		;1553	20 20		   
l1555h:
	jr nz,$+34		;1555	20 20		   
l1557h:
	jr nz,$+34		;1557	20 20		   
l1559h:
	jr nz,l157bh		;1559	20 20		   
l155bh:
	jr nz,l157dh		;155b	20 20		   
l155dh:
	jr nz,l157fh		;155d	20 20		   
l155fh:
	jr nz,l15a9h		;155f	20 48		  H
l1561h:
	jr nz,l1583h		;1561	20 20		   
l1563h:
	jr nz,l1585h		;1563	20 20		   
l1565h:
	jr nz,l1587h		;1565	20 20		   
l1567h:
	jr nz,l1589h		;1567	20 20		   
l1569h:
	jr nz,l158bh		;1569	20 20		   
l156bh:
	jr nz,l158dh		;156b	20 20		   
l156dh:
	jr nz,l158fh		;156d	20 20		   
l156fh:
	jr nz,l1591h		;156f	20 20		   
l1571h:
	jr nz,l1593h		;1571	20 20		   
l1573h:
	jr nz,l1595h		;1573	20 20		   
l1575h:
	ld hl,(00022h)		;1575	2a 22 00	* " .
	jp 015d0h		;1578	c3 d0 15	. . .
l157bh:
	push de			;157b	d5		.
	dec d			;157c	15		.
l157dh:
	jr nz,l15a1h		;157d	20 22		  "
l157fh:
	dec a			;157f	3d		=
	dec a			;1580	3d		=
	dec a			;1581	3d		=
	dec a			;1582	3d		=
l1583h:
	dec a			;1583	3d		=
	dec a			;1584	3d		=
l1585h:
	dec a			;1585	3d		=
	dec a			;1586	3d		=
l1587h:
	dec a			;1587	3d		=
	dec a			;1588	3d		=
l1589h:
	dec a			;1589	3d		=
	dec a			;158a	3d		=
l158bh:
	dec a			;158b	3d		=
	dec a			;158c	3d		=
l158dh:
	dec a			;158d	3d		=
	dec a			;158e	3d		=
l158fh:
	dec a			;158f	3d		=
	dec a			;1590	3d		=
l1591h:
	dec a			;1591	3d		=
	dec a			;1592	3d		=
l1593h:
	dec a			;1593	3d		=
	dec a			;1594	3d		=
l1595h:
	dec a			;1595	3d		=
	dec a			;1596	3d		=
	dec a			;1597	3d		=
	dec a			;1598	3d		=
	dec a			;1599	3d		=
	dec a			;159a	3d		=
	dec a			;159b	3d		=
	dec a			;159c	3d		=
	dec a			;159d	3d		=
	dec a			;159e	3d		=
	dec a			;159f	3d		=
	dec a			;15a0	3d		=
l15a1h:
	dec a			;15a1	3d		=
	dec a			;15a2	3d		=
	dec a			;15a3	3d		=
	dec a			;15a4	3d		=
	dec a			;15a5	3d		=
	dec a			;15a6	3d		=
	dec a			;15a7	3d		=
	dec a			;15a8	3d		=
l15a9h:
	dec a			;15a9	3d		=
	dec a			;15aa	3d		=
	dec a			;15ab	3d		=
	dec a			;15ac	3d		=
	dec a			;15ad	3d		=
	dec a			;15ae	3d		=
	dec a			;15af	3d		=
	dec a			;15b0	3d		=
	dec a			;15b1	3d		=
	dec a			;15b2	3d		=
	dec a			;15b3	3d		=
	dec a			;15b4	3d		=
	dec a			;15b5	3d		=
	dec a			;15b6	3d		=
	dec a			;15b7	3d		=
	dec a			;15b8	3d		=
	dec a			;15b9	3d		=
	dec a			;15ba	3d		=
	dec a			;15bb	3d		=
	dec a			;15bc	3d		=
	dec a			;15bd	3d		=
	dec a			;15be	3d		=
	dec a			;15bf	3d		=
	dec a			;15c0	3d		=
	dec a			;15c1	3d		=
	dec a			;15c2	3d		=
	dec a			;15c3	3d		=
	dec a			;15c4	3d		=
	dec a			;15c5	3d		=
	dec a			;15c6	3d		=
	dec a			;15c7	3d		=
	dec a			;15c8	3d		=
	dec a			;15c9	3d		=
	dec a			;15ca	3d		=
	dec a			;15cb	3d		=
	dec a			;15cc	3d		=
	dec a			;15cd	3d		=
	ld (0c300h),hl		;15ce	22 00 c3	" . .
	exx			;15d1	d9		.
	dec d			;15d2	15		.
	sbc a,015h		;15d3	de 15		. .
	jr nz,$+54		;15d5	20 34		  4
	dec (hl)		;15d7	35		5
	nop			;15d8	00		.
	jp l15e5h		;15d9	c3 e5 15	. . .
	jp pe,l2015h		;15dc	ea 15 20	. .  
	scf			;15df	37		7
	dec (hl)		;15e0	35		5
	jr nc,$+46		;15e1	30 2c		0 ,
	jr c,l15e5h		;15e3	38 00		8 .
l15e5h:
	jp 01639h		;15e5	c3 39 16	. 9 .
	ld a,016h		;15e8	3e 16		> .
	jr nz,l160eh		;15ea	20 22		  "
	jr nz,l160eh		;15ec	20 20		   
	jr nz,l1610h		;15ee	20 20		   
	jr nz,l1612h		;15f0	20 20		   
	jr nz,l1614h		;15f2	20 20		   
	jr nz,l1616h		;15f4	20 20		   
	jr nz,l1618h		;15f6	20 20		   
	jr nz,l161ah		;15f8	20 20		   
	jr nz,l161ch		;15fa	20 20		   
	jr nz,l161eh		;15fc	20 20		   
	jr nz,l1620h		;15fe	20 20		   
	jr nz,l1622h		;1600	20 20		   
	jr nz,l1624h		;1602	20 20		   
	jr nz,l1626h		;1604	20 20		   
	jr nz,l1628h		;1606	20 20		   
	jr nz,l162ah		;1608	20 20		   
	jr nz,l162ch		;160a	20 20		   
	jr nz,l162eh		;160c	20 20		   
l160eh:
	jr nz,l1630h		;160e	20 20		   
l1610h:
	jr nz,l1632h		;1610	20 20		   
l1612h:
	jr nz,l1634h		;1612	20 20		   
l1614h:
	jr nz,l1636h		;1614	20 20		   
l1616h:
	jr nz,$+34		;1616	20 20		   
l1618h:
	jr nz,l163ah		;1618	20 20		   
l161ah:
	jr nz,$+34		;161a	20 20		   
l161ch:
	jr nz,$+34		;161c	20 20		   
l161eh:
	jr nz,$+34		;161e	20 20		   
l1620h:
	jr nz,l1642h		;1620	20 20		   
l1622h:
	jr nz,l1644h		;1622	20 20		   
l1624h:
	jr nz,l1646h		;1624	20 20		   
l1626h:
	jr nz,l1648h		;1626	20 20		   
l1628h:
	jr nz,l164ah		;1628	20 20		   
l162ah:
	jr nz,l164ch		;162a	20 20		   
l162ch:
	jr nz,l164eh		;162c	20 20		   
l162eh:
	jr nz,l1650h		;162e	20 20		   
l1630h:
	jr nz,l1652h		;1630	20 20		   
l1632h:
	jr nz,l1654h		;1632	20 20		   
l1634h:
	jr nz,l1656h		;1634	20 20		   
l1636h:
	inc h			;1636	24		$
	ld (0c300h),hl		;1637	22 00 c3	" . .
l163ah:
	adc a,l			;163a	8d		.
	ld d,092h		;163b	16 92		. .
	ld d,020h		;163d	16 20		.  
	ld (l2020h),hl		;163f	22 20 20	"    
l1642h:
	jr nz,l1664h		;1642	20 20		   
l1644h:
	jr nz,l1666h		;1644	20 20		   
l1646h:
	jr nz,l1668h		;1646	20 20		   
l1648h:
	jr nz,l166ah		;1648	20 20		   
l164ah:
	jr nz,l166ch		;164a	20 20		   
l164ch:
	jr nz,l166eh		;164c	20 20		   
l164eh:
	jr nz,l1670h		;164e	20 20		   
l1650h:
	jr nz,l1672h		;1650	20 20		   
l1652h:
	jr nz,l1674h		;1652	20 20		   
l1654h:
	jr nz,l1676h		;1654	20 20		   
l1656h:
	jr nz,l1678h		;1656	20 20		   
	jr nz,l167ah		;1658	20 20		   
	jr nz,l167ch		;165a	20 20		   
	jr nz,l167eh		;165c	20 20		   
	jr nz,l1680h		;165e	20 20		   
	jr nz,l1682h		;1660	20 20		   
	jr nz,l1684h		;1662	20 20		   
l1664h:
	jr nz,l1686h		;1664	20 20		   
l1666h:
	jr nz,l1688h		;1666	20 20		   
l1668h:
	jr nz,l168ah		;1668	20 20		   
l166ah:
	jr nz,$+34		;166a	20 20		   
l166ch:
	jr nz,l168eh		;166c	20 20		   
l166eh:
	jr nz,$+34		;166e	20 20		   
l1670h:
	jr nz,$+34		;1670	20 20		   
l1672h:
	jr nz,$+34		;1672	20 20		   
l1674h:
	jr nz,l1696h		;1674	20 20		   
l1676h:
	jr nz,l1698h		;1676	20 20		   
l1678h:
	jr nz,$+34		;1678	20 20		   
l167ah:
	jr nz,$+34		;167a	20 20		   
l167ch:
	jr nz,$+34		;167c	20 20		   
l167eh:
	jr nz,$+34		;167e	20 20		   
l1680h:
	jr nz,l16a2h		;1680	20 20		   
l1682h:
	jr nz,l16aah		;1682	20 26		  &
l1684h:
	jr nz,l16a6h		;1684	20 20		   
l1686h:
	jr nz,l16a8h		;1686	20 20		   
l1688h:
	jr nz,l16aah		;1688	20 20		   
l168ah:
	ld c,b			;168a	48		H
	ld (0c300h),hl		;168b	22 00 c3	" . .
l168eh:
	pop hl			;168e	e1		.
	ld d,0e6h		;168f	16 e6		. .
	ld d,020h		;1691	16 20		.  
	ld (l2020h),hl		;1693	22 20 20	"    
l1696h:
	jr nz,l16b8h		;1696	20 20		   
l1698h:
	ld c,b			;1698	48		H
	jr nz,$+34		;1699	20 20		   
	jr nz,$+34		;169b	20 20		   
	jr nz,$+34		;169d	20 20		   
	jr nz,l171dh		;169f	20 7c		  |
	ld d,(hl)		;16a1	56		V
l16a2h:
	jr nz,l16c4h		;16a2	20 20		   
	jr nz,l16c6h		;16a4	20 20		   
l16a6h:
	jr nz,l16c8h		;16a6	20 20		   
l16a8h:
	jr nz,l16cah		;16a8	20 20		   
l16aah:
	jr nz,l16cch		;16aa	20 20		   
l16ach:
	jr nz,l16ceh		;16ac	20 20		   
l16aeh:
	jr nz,l16d0h		;16ae	20 20		   
l16b0h:
	jr nz,l16d2h		;16b0	20 20		   
l16b2h:
	jr nz,l16d4h		;16b2	20 20		   
	jr nz,l16d6h		;16b4	20 20		   
l16b6h:
	jr nz,l16d8h		;16b6	20 20		   
l16b8h:
	jr nz,$+34		;16b8	20 20		   
l16bah:
	jr nz,$+34		;16ba	20 20		   
l16bch:
	jr nz,$+34		;16bc	20 20		   
sub_16beh:
	jr nz,$+34		;16be	20 20		   
	jr nz,l16e2h		;16c0	20 20		   
	jr nz,l16e4h		;16c2	20 20		   
l16c4h:
	jr nz,l16e6h		;16c4	20 20		   
l16c6h:
	jr nz,l16e8h		;16c6	20 20		   
l16c8h:
	jr nz,l16eah		;16c8	20 20		   
l16cah:
	jr nz,l16ech		;16ca	20 20		   
l16cch:
	jr nz,l16eeh		;16cc	20 20		   
l16ceh:
	jr nz,l16f0h		;16ce	20 20		   
l16d0h:
	jr nz,l16f2h		;16d0	20 20		   
l16d2h:
	jr nz,l16f4h		;16d2	20 20		   
l16d4h:
	jr nz,l16f6h		;16d4	20 20		   
l16d6h:
	jr nz,l172eh		;16d6	20 56		  V
l16d8h:
	ld a,h			;16d8	7c		|
	jr nz,l16fbh		;16d9	20 20		   
	jr nz,l16fdh		;16db	20 20		   
	jr nz,l1727h		;16dd	20 48		  H
	ld (0c300h),hl		;16df	22 00 c3	" . .
l16e2h:
	add hl,sp		;16e2	39		9
	rla			;16e3	17		.
l16e4h:
	ld a,017h		;16e4	3e 17		> .
l16e6h:
	jr nz,l170ah		;16e6	20 22		  "
l16e8h:
	dec a			;16e8	3d		=
	dec a			;16e9	3d		=
l16eah:
	dec a			;16ea	3d		=
	dec a			;16eb	3d		=
l16ech:
	ld c,b			;16ec	48		H
	dec a			;16ed	3d		=
l16eeh:
	dec a			;16ee	3d		=
	dec a			;16ef	3d		=
l16f0h:
	dec a			;16f0	3d		=
	dec a			;16f1	3d		=
l16f2h:
	dec a			;16f2	3d		=
	dec a			;16f3	3d		=
l16f4h:
	dec a			;16f4	3d		=
	dec a			;16f5	3d		=
l16f6h:
	dec a			;16f6	3d		=
	dec a			;16f7	3d		=
	dec a			;16f8	3d		=
	dec a			;16f9	3d		=
	dec a			;16fa	3d		=
l16fbh:
	dec a			;16fb	3d		=
	dec a			;16fc	3d		=
l16fdh:
	dec a			;16fd	3d		=
	dec a			;16fe	3d		=
	dec a			;16ff	3d		=
	dec a			;1700	3d		=
	dec a			;1701	3d		=
	dec a			;1702	3d		=
	dec a			;1703	3d		=
	jr nz,$+63		;1704	20 3d		  =
	dec a			;1706	3d		=
	dec a			;1707	3d		=
	dec a			;1708	3d		=
	dec a			;1709	3d		=
l170ah:
	dec a			;170a	3d		=
	dec a			;170b	3d		=
	dec a			;170c	3d		=
	dec a			;170d	3d		=
	dec a			;170e	3d		=
	dec a			;170f	3d		=
	dec a			;1710	3d		=
	dec a			;1711	3d		=
	dec a			;1712	3d		=
	dec a			;1713	3d		=
	dec a			;1714	3d		=
	dec a			;1715	3d		=
	dec a			;1716	3d		=
	dec a			;1717	3d		=
	dec a			;1718	3d		=
	dec a			;1719	3d		=
	dec a			;171a	3d		=
	dec a			;171b	3d		=
	dec a			;171c	3d		=
l171dh:
	dec a			;171d	3d		=
	jr nz,$+63		;171e	20 3d		  =
	dec a			;1720	3d		=
	dec a			;1721	3d		=
	dec a			;1722	3d		=
	dec a			;1723	3d		=
	dec a			;1724	3d		=
	dec a			;1725	3d		=
	dec a			;1726	3d		=
l1727h:
	dec a			;1727	3d		=
	dec a			;1728	3d		=
	dec a			;1729	3d		=
	dec a			;172a	3d		=
	dec a			;172b	3d		=
	dec a			;172c	3d		=
	dec a			;172d	3d		=
l172eh:
	dec a			;172e	3d		=
	dec a			;172f	3d		=
	dec a			;1730	3d		=
	dec a			;1731	3d		=
	dec a			;1732	3d		=
	dec a			;1733	3d		=
	dec a			;1734	3d		=
	dec a			;1735	3d		=
	dec a			;1736	3d		=
	ld (0c300h),hl		;1737	22 00 c3	" . .
	ld b,a			;173a	47		G
	rla			;173b	17		.
	ld c,h			;173c	4c		L
	rla			;173d	17		.
	jr nz,$+36		;173e	20 22		  "
	jr nz,$+34		;1740	20 20		   
	jr nz,$+34		;1742	20 20		   
	ld c,b			;1744	48		H
	ld (0c300h),hl		;1745	22 00 c3	" . .
	ld d,l			;1748	55		U
	rla			;1749	17		.
	ld e,d			;174a	5a		Z
	rla			;174b	17		.
	jr nz,$+36		;174c	20 22		  "
	jr nz,$+34		;174e	20 20		   
	jr nz,$+34		;1750	20 20		   
	ld c,b			;1752	48		H
	ld (0c300h),hl		;1753	22 00 c3	" . .
	xor c			;1756	a9		.
	rla			;1757	17		.
	xor (hl)		;1758	ae		.
	rla			;1759	17		.
	jr nz,l177eh		;175a	20 22		  "
	jr nz,l177eh		;175c	20 20		   
	jr nz,l1780h		;175e	20 20		   
	ld c,b			;1760	48		H
	jr nz,$+34		;1761	20 20		   
	jr nz,$+34		;1763	20 20		   
	jr nz,$+34		;1765	20 20		   
	jr nz,$+34		;1767	20 20		   
	jr nz,$+34		;1769	20 20		   
	jr nz,$+34		;176b	20 20		   
	jr nz,$+34		;176d	20 20		   
	jr nz,$+34		;176f	20 20		   
	jr nz,$+34		;1771	20 20		   
	jr nz,$+34		;1773	20 20		   
	ld h,020h		;1775	26 20		&  
	ld a,h			;1777	7c		|
	jr nz,l179ah		;1778	20 20		   
	jr nz,l179ch		;177a	20 20		   
	jr nz,l179eh		;177c	20 20		   
l177eh:
	jr nz,l17a0h		;177e	20 20		   
l1780h:
	jr nz,l17a2h		;1780	20 20		   
	jr nz,l17a4h		;1782	20 20		   
	jr nz,l17a6h		;1784	20 20		   
	jr nz,$+34		;1786	20 20		   
	jr nz,l17aah		;1788	20 20		   
	jr nz,$+34		;178a	20 20		   
	jr nz,$+34		;178c	20 20		   
	jr nz,$+34		;178e	20 20		   
	jr nz,l17c0h		;1790	20 2e		  .
	jr nz,l17c2h		;1792	20 2e		  .
	jr nz,l17b6h		;1794	20 20		   
	jr nz,l17b8h		;1796	20 20		   
	jr nz,l17bah		;1798	20 20		   
l179ah:
	jr nz,l17bch		;179a	20 20		   
l179ch:
	jr nz,l17beh		;179c	20 20		   
l179eh:
	jr nz,l17c0h		;179e	20 20		   
l17a0h:
	jr nz,l17c2h		;17a0	20 20		   
l17a2h:
	jr nz,l17c4h		;17a2	20 20		   
l17a4h:
	jr nz,l17c6h		;17a4	20 20		   
l17a6h:
	ld c,b			;17a6	48		H
	ld (0c300h),hl		;17a7	22 00 c3	" . .
l17aah:
	ld bc,l0618h		;17aa	01 18 06	. . .
	jr l17cfh		;17ad	18 20		.  
	ld (l3d3dh),hl		;17af	22 3d 3d	" = =
	dec a			;17b2	3d		=
	dec a			;17b3	3d		=
	dec a			;17b4	3d		=
	dec a			;17b5	3d		=
l17b6h:
	dec a			;17b6	3d		=
	dec a			;17b7	3d		=
l17b8h:
	dec a			;17b8	3d		=
	dec a			;17b9	3d		=
l17bah:
	dec a			;17ba	3d		=
	dec a			;17bb	3d		=
l17bch:
	dec a			;17bc	3d		=
	dec a			;17bd	3d		=
l17beh:
	dec a			;17be	3d		=
	dec a			;17bf	3d		=
l17c0h:
	dec a			;17c0	3d		=
	dec a			;17c1	3d		=
l17c2h:
	dec a			;17c2	3d		=
	dec a			;17c3	3d		=
l17c4h:
	dec a			;17c4	3d		=
	dec a			;17c5	3d		=
l17c6h:
	dec a			;17c6	3d		=
	dec a			;17c7	3d		=
	dec a			;17c8	3d		=
	dec a			;17c9	3d		=
	jr nz,$+63		;17ca	20 3d		  =
	dec a			;17cc	3d		=
	dec a			;17cd	3d		=
	dec a			;17ce	3d		=
l17cfh:
	dec a			;17cf	3d		=
	dec a			;17d0	3d		=
	jr nz,l1810h		;17d1	20 3d		  =
	dec a			;17d3	3d		=
	dec a			;17d4	3d		=
	dec a			;17d5	3d		=
	dec a			;17d6	3d		=
	dec a			;17d7	3d		=
	dec a			;17d8	3d		=
	dec a			;17d9	3d		=
	dec a			;17da	3d		=
	dec a			;17db	3d		=
	dec a			;17dc	3d		=
	dec a			;17dd	3d		=
	dec a			;17de	3d		=
	dec a			;17df	3d		=
	dec a			;17e0	3d		=
	dec a			;17e1	3d		=
	dec a			;17e2	3d		=
	dec a			;17e3	3d		=
	dec a			;17e4	3d		=
	dec a			;17e5	3d		=
	jr nz,$+63		;17e6	20 3d		  =
	dec a			;17e8	3d		=
	dec a			;17e9	3d		=
	dec a			;17ea	3d		=
	dec a			;17eb	3d		=
	dec a			;17ec	3d		=
	dec a			;17ed	3d		=
	dec a			;17ee	3d		=
	dec a			;17ef	3d		=
	dec a			;17f0	3d		=
	dec a			;17f1	3d		=
	dec a			;17f2	3d		=
	dec a			;17f3	3d		=
	dec a			;17f4	3d		=
	dec a			;17f5	3d		=
	dec a			;17f6	3d		=
	dec a			;17f7	3d		=
	dec a			;17f8	3d		=
	dec a			;17f9	3d		=
	ld c,b			;17fa	48		H
	dec a			;17fb	3d		=
	dec a			;17fc	3d		=
	dec a			;17fd	3d		=
	dec a			;17fe	3d		=
	ld (0c300h),hl		;17ff	22 00 c3	" . .
	ld d,l			;1802	55		U
	jr $+92			;1803	18 5a		. Z
	jr $+34			;1805	18 20		.  
l1807h:
	ld (l2020h),hl		;1807	22 20 20	"    
	jr nz,l182ch		;180a	20 20		   
	jr nz,l182eh		;180c	20 20		   
	jr nz,l1830h		;180e	20 20		   
l1810h:
	jr nz,l1832h		;1810	20 20		   
	jr nz,l1834h		;1812	20 20		   
	jr nz,l1836h		;1814	20 20		   
	jr nz,l1838h		;1816	20 20		   
	jr nz,l183ah		;1818	20 20		   
	jr nz,l183ch		;181a	20 20		   
	jr nz,l183eh		;181c	20 20		   
	jr nz,l1840h		;181e	20 20		   
	jr nz,l1842h		;1820	20 20		   
	jr nz,l1844h		;1822	20 20		   
	jr nz,l1846h		;1824	20 20		   
	jr nz,l1848h		;1826	20 20		   
	jr nz,l184ah		;1828	20 20		   
	jr nz,l184ch		;182a	20 20		   
l182ch:
	jr nz,l184eh		;182c	20 20		   
l182eh:
	jr nz,l1850h		;182e	20 20		   
l1830h:
	jr nz,l1852h		;1830	20 20		   
l1832h:
	jr nz,$+34		;1832	20 20		   
l1834h:
	jr nz,l1856h		;1834	20 20		   
l1836h:
	jr nz,$+34		;1836	20 20		   
l1838h:
	jr nz,$+34		;1838	20 20		   
l183ah:
	jr nz,$+34		;183a	20 20		   
l183ch:
	jr nz,l185eh		;183c	20 20		   
l183eh:
	jr nz,l1860h		;183e	20 20		   
l1840h:
	jr nz,l1862h		;1840	20 20		   
l1842h:
	jr nz,l1864h		;1842	20 20		   
l1844h:
	jr nz,l1866h		;1844	20 20		   
l1846h:
	jr nz,l1868h		;1846	20 20		   
l1848h:
	jr nz,l186ah		;1848	20 20		   
l184ah:
	jr nz,l186ch		;184a	20 20		   
l184ch:
	jr nz,l186eh		;184c	20 20		   
l184eh:
	jr nz,l1870h		;184e	20 20		   
l1850h:
	jr nz,l1872h		;1850	20 20		   
l1852h:
	ld c,b			;1852	48		H
	ld (0c300h),hl		;1853	22 00 c3	" . .
l1856h:
	xor c			;1856	a9		.
	jr l1807h		;1857	18 ae		. .
	jr $+34			;1859	18 20		.  
	ld (l2020h),hl		;185b	22 20 20	"    
l185eh:
	jr nz,l1880h		;185e	20 20		   
l1860h:
	jr nz,l1882h		;1860	20 20		   
l1862h:
	jr nz,l1884h		;1862	20 20		   
l1864h:
	jr nz,l1886h		;1864	20 20		   
l1866h:
	jr nz,l1888h		;1866	20 20		   
l1868h:
	jr nz,l188ah		;1868	20 20		   
l186ah:
	jr nz,l188ch		;186a	20 20		   
l186ch:
	jr nz,l188eh		;186c	20 20		   
l186eh:
	jr nz,l1890h		;186e	20 20		   
l1870h:
	jr nz,l1892h		;1870	20 20		   
l1872h:
	jr nz,l1894h		;1872	20 20		   
	jr nz,l1896h		;1874	20 20		   
	jr nz,l1898h		;1876	20 20		   
	jr nz,l189ah		;1878	20 20		   
	jr nz,l189ch		;187a	20 20		   
	jr nz,l189eh		;187c	20 20		   
	jr nz,l18a0h		;187e	20 20		   
l1880h:
	jr nz,l18a2h		;1880	20 20		   
l1882h:
	jr nz,l18a4h		;1882	20 20		   
l1884h:
	jr nz,l18a6h		;1884	20 20		   
l1886h:
	jr nz,$+34		;1886	20 20		   
l1888h:
	jr nz,l18aah		;1888	20 20		   
l188ah:
	jr nz,$+34		;188a	20 20		   
l188ch:
	jr nz,l18aeh		;188c	20 20		   
l188eh:
	jr nz,l18b0h		;188e	20 20		   
l1890h:
	jr nz,l18b2h		;1890	20 20		   
l1892h:
	jr nz,l18b4h		;1892	20 20		   
l1894h:
	jr nz,$+34		;1894	20 20		   
l1896h:
	jr nz,$+34		;1896	20 20		   
l1898h:
	jr nz,$+34		;1898	20 20		   
l189ah:
	jr nz,$+34		;189a	20 20		   
l189ch:
	jr nz,$+34		;189c	20 20		   
l189eh:
	jr nz,$+34		;189e	20 20		   
l18a0h:
	jr nz,$+34		;18a0	20 20		   
l18a2h:
	jr nz,$+34		;18a2	20 20		   
l18a4h:
	jr nz,$+34		;18a4	20 20		   
l18a6h:
	ld c,b			;18a6	48		H
	ld (0c300h),hl		;18a7	22 00 c3	" . .
l18aah:
	defb 0fdh,018h,002h ;illegal sequence	;18aa	fd 18 02	. . .
	add hl,de		;18ad	19		.
l18aeh:
	jr nz,$+36		;18ae	20 22		  "
l18b0h:
	jr nz,$+34		;18b0	20 20		   
l18b2h:
	jr nz,$+34		;18b2	20 20		   
l18b4h:
	ld c,b			;18b4	48		H
	jr nz,l18d7h		;18b5	20 20		   
	jr nz,l18d9h		;18b7	20 20		   
	jr nz,l18dbh		;18b9	20 20		   
	jr nz,l18ddh		;18bb	20 20		   
	jr nz,l18dfh		;18bd	20 20		   
	jr nz,l18e1h		;18bf	20 20		   
	jr nz,l18e3h		;18c1	20 20		   
	jr nz,l18e5h		;18c3	20 20		   
	jr nz,l18e7h		;18c5	20 20		   
	jr nz,l18e9h		;18c7	20 20		   
	jr nz,l18ebh		;18c9	20 20		   
	jr nz,l18edh		;18cb	20 20		   
	jr nz,l18efh		;18cd	20 20		   
	jr nz,l18f1h		;18cf	20 20		   
	jr nz,l194fh		;18d1	20 7c		  |
	jr nz,l18f5h		;18d3	20 20		   
	jr nz,l18f7h		;18d5	20 20		   
l18d7h:
	jr nz,l18f9h		;18d7	20 20		   
l18d9h:
	jr nz,l18fbh		;18d9	20 20		   
l18dbh:
	jr nz,$+34		;18db	20 20		   
l18ddh:
	jr nz,l18ffh		;18dd	20 20		   
l18dfh:
	jr nz,l1901h		;18df	20 20		   
l18e1h:
	jr nz,$+34		;18e1	20 20		   
l18e3h:
	jr nz,l1913h		;18e3	20 2e		  .
l18e5h:
	jr nz,l1907h		;18e5	20 20		   
l18e7h:
	ld l,020h		;18e7	2e 20		.  
l18e9h:
	jr nz,l190bh		;18e9	20 20		   
l18ebh:
	jr nz,l190dh		;18eb	20 20		   
l18edh:
	jr nz,l190fh		;18ed	20 20		   
l18efh:
	jr nz,l1911h		;18ef	20 20		   
l18f1h:
	jr nz,l1913h		;18f1	20 20		   
	jr nz,l1915h		;18f3	20 20		   
l18f5h:
	jr nz,l1917h		;18f5	20 20		   
l18f7h:
	jr nz,l1919h		;18f7	20 20		   
l18f9h:
	jr nz,l1943h		;18f9	20 48		  H
l18fbh:
	ld (0c300h),hl		;18fb	22 00 c3	" . .
	ld d,l			;18fe	55		U
l18ffh:
	add hl,de		;18ff	19		.
	ld e,d			;1900	5a		Z
l1901h:
	add hl,de		;1901	19		.
	jr nz,l1926h		;1902	20 22		  "
	dec a			;1904	3d		=
	dec a			;1905	3d		=
	dec a			;1906	3d		=
l1907h:
	dec a			;1907	3d		=
	ld c,b			;1908	48		H
	dec a			;1909	3d		=
	dec a			;190a	3d		=
l190bh:
	dec a			;190b	3d		=
	dec a			;190c	3d		=
l190dh:
	dec a			;190d	3d		=
	dec a			;190e	3d		=
l190fh:
	dec a			;190f	3d		=
	dec a			;1910	3d		=
l1911h:
	dec a			;1911	3d		=
	dec a			;1912	3d		=
l1913h:
	dec a			;1913	3d		=
	dec a			;1914	3d		=
l1915h:
	dec a			;1915	3d		=
	dec a			;1916	3d		=
l1917h:
	dec a			;1917	3d		=
	dec a			;1918	3d		=
l1919h:
	dec a			;1919	3d		=
	dec a			;191a	3d		=
	dec a			;191b	3d		=
	dec a			;191c	3d		=
	dec a			;191d	3d		=
	jr nz,l1940h		;191e	20 20		   
	jr nz,$+63		;1920	20 3d		  =
	dec a			;1922	3d		=
	dec a			;1923	3d		=
	dec a			;1924	3d		=
	dec a			;1925	3d		=
l1926h:
	dec a			;1926	3d		=
	jr nz,l1949h		;1927	20 20		   
	dec a			;1929	3d		=
	dec a			;192a	3d		=
	dec a			;192b	3d		=
	dec a			;192c	3d		=
	dec a			;192d	3d		=
	dec a			;192e	3d		=
	dec a			;192f	3d		=
	dec a			;1930	3d		=
	dec a			;1931	3d		=
	dec a			;1932	3d		=
	dec a			;1933	3d		=
	dec a			;1934	3d		=
	dec a			;1935	3d		=
	dec a			;1936	3d		=
	dec a			;1937	3d		=
	dec a			;1938	3d		=
	jr nz,$+34		;1939	20 20		   
	dec a			;193b	3d		=
	dec a			;193c	3d		=
	dec a			;193d	3d		=
	dec a			;193e	3d		=
	dec a			;193f	3d		=
l1940h:
	dec a			;1940	3d		=
	dec a			;1941	3d		=
	dec a			;1942	3d		=
l1943h:
	dec a			;1943	3d		=
	dec a			;1944	3d		=
	dec a			;1945	3d		=
	dec a			;1946	3d		=
	dec a			;1947	3d		=
	dec a			;1948	3d		=
l1949h:
	dec a			;1949	3d		=
	dec a			;194a	3d		=
	dec a			;194b	3d		=
	dec a			;194c	3d		=
	dec a			;194d	3d		=
	dec a			;194e	3d		=
l194fh:
	dec a			;194f	3d		=
	dec a			;1950	3d		=
	dec a			;1951	3d		=
	dec a			;1952	3d		=
	ld (0c300h),hl		;1953	22 00 c3	" . .
	ld h,e			;1956	63		c
	add hl,de		;1957	19		.
	ld l,b			;1958	68		h
	add hl,de		;1959	19		.
	jr nz,$+36		;195a	20 22		  "
	jr nz,$+34		;195c	20 20		   
	jr nz,$+34		;195e	20 20		   
	ld c,b			;1960	48		H
	ld (0c300h),hl		;1961	22 00 c3	" . .
	ld (hl),c		;1964	71		q
	add hl,de		;1965	19		.
	halt			;1966	76		v
	add hl,de		;1967	19		.
	jr nz,$+36		;1968	20 22		  "
	jr nz,$+34		;196a	20 20		   
	jr nz,$+34		;196c	20 20		   
	ld c,b			;196e	48		H
	ld (0c300h),hl		;196f	22 00 c3	" . .
	push bc			;1972	c5		.
	add hl,de		;1973	19		.
	jp z,l2019h		;1974	ca 19 20	. .  
	ld (l2020h),hl		;1977	22 20 20	"    
	jr nz,l199ch		;197a	20 20		   
	ld c,b			;197c	48		H
	jr nz,$+34		;197d	20 20		   
	jr nz,$+34		;197f	20 20		   
	jr nz,$+34		;1981	20 20		   
	jr nz,$+34		;1983	20 20		   
	jr nz,$+34		;1985	20 20		   
	jr nz,$+34		;1987	20 20		   
	jr nz,$+34		;1989	20 20		   
	jr nz,$+34		;198b	20 20		   
	jr nz,$+34		;198d	20 20		   
	jr nz,$+34		;198f	20 20		   
	jr nz,$+34		;1991	20 20		   
	ld a,h			;1993	7c		|
	jr nz,l19b6h		;1994	20 20		   
	jr nz,l19b8h		;1996	20 20		   
	jr nz,l19bah		;1998	20 20		   
	jr nz,l19bch		;199a	20 20		   
l199ch:
	jr nz,l19beh		;199c	20 20		   
	jr nz,l19c0h		;199e	20 20		   
	jr nz,l19c2h		;19a0	20 20		   
	jr nz,$+34		;19a2	20 20		   
	jr nz,l19c6h		;19a4	20 20		   
	jr nz,l19c8h		;19a6	20 20		   
	jr nz,$+34		;19a8	20 20		   
	jr nz,$+34		;19aa	20 20		   
	ld l,020h		;19ac	2e 20		.  
	jr nz,l19d0h		;19ae	20 20		   
	ld l,020h		;19b0	2e 20		.  
	jr nz,l19d4h		;19b2	20 20		   
	jr nz,l19d6h		;19b4	20 20		   
l19b6h:
	jr nz,l19d8h		;19b6	20 20		   
l19b8h:
	jr nz,l19dah		;19b8	20 20		   
l19bah:
	jr nz,l19dch		;19ba	20 20		   
l19bch:
	jr nz,l19deh		;19bc	20 20		   
l19beh:
	jr nz,l19e0h		;19be	20 20		   
l19c0h:
	jr nz,l19e2h		;19c0	20 20		   
l19c2h:
	ld c,b			;19c2	48		H
	ld (0c300h),hl		;19c3	22 00 c3	" . .
l19c6h:
	dec e			;19c6	1d		.
	ld a,(de)		;19c7	1a		.
l19c8h:
	ld (l201ah),hl		;19c8	22 1a 20	" .  
	ld (l3d3dh),hl		;19cb	22 3d 3d	" = =
	dec a			;19ce	3d		=
	dec a			;19cf	3d		=
l19d0h:
	dec a			;19d0	3d		=
	dec a			;19d1	3d		=
	dec a			;19d2	3d		=
	dec a			;19d3	3d		=
l19d4h:
	dec a			;19d4	3d		=
	dec a			;19d5	3d		=
l19d6h:
	dec a			;19d6	3d		=
	dec a			;19d7	3d		=
l19d8h:
	dec a			;19d8	3d		=
	dec a			;19d9	3d		=
l19dah:
	dec a			;19da	3d		=
	dec a			;19db	3d		=
l19dch:
	dec a			;19dc	3d		=
	dec a			;19dd	3d		=
l19deh:
	dec a			;19de	3d		=
	dec a			;19df	3d		=
l19e0h:
	dec a			;19e0	3d		=
	dec a			;19e1	3d		=
l19e2h:
	dec a			;19e2	3d		=
	dec a			;19e3	3d		=
	jr nz,l1a06h		;19e4	20 20		   
	jr nz,$+63		;19e6	20 3d		  =
	dec a			;19e8	3d		=
	dec a			;19e9	3d		=
	dec a			;19ea	3d		=
	dec a			;19eb	3d		=
	dec a			;19ec	3d		=
	dec a			;19ed	3d		=
	dec a			;19ee	3d		=
	jr nz,l1a11h		;19ef	20 20		   
	jr nz,l1a13h		;19f1	20 20		   
	dec a			;19f3	3d		=
	dec a			;19f4	3d		=
	dec a			;19f5	3d		=
	dec a			;19f6	3d		=
	dec a			;19f7	3d		=
	dec a			;19f8	3d		=
	dec a			;19f9	3d		=
	dec a			;19fa	3d		=
	dec a			;19fb	3d		=
	dec a			;19fc	3d		=
	dec a			;19fd	3d		=
	dec a			;19fe	3d		=
	dec a			;19ff	3d		=
	dec a			;1a00	3d		=
	jr nz,$+34		;1a01	20 20		   
	jr nz,l1a42h		;1a03	20 3d		  =
	dec a			;1a05	3d		=
l1a06h:
	dec a			;1a06	3d		=
	dec a			;1a07	3d		=
	dec a			;1a08	3d		=
	dec a			;1a09	3d		=
	dec a			;1a0a	3d		=
	dec a			;1a0b	3d		=
	dec a			;1a0c	3d		=
	dec a			;1a0d	3d		=
	dec a			;1a0e	3d		=
	dec a			;1a0f	3d		=
	dec a			;1a10	3d		=
l1a11h:
	dec a			;1a11	3d		=
	dec a			;1a12	3d		=
l1a13h:
	dec a			;1a13	3d		=
	dec a			;1a14	3d		=
	dec a			;1a15	3d		=
	ld c,b			;1a16	48		H
	dec a			;1a17	3d		=
	dec a			;1a18	3d		=
	dec a			;1a19	3d		=
	dec a			;1a1a	3d		=
	ld (0c300h),hl		;1a1b	22 00 c3	" . .
	ld (hl),c		;1a1e	71		q
	ld a,(de)		;1a1f	1a		.
	halt			;1a20	76		v
	ld a,(de)		;1a21	1a		.
	jr nz,l1a46h		;1a22	20 22		  "
	jr nz,l1a46h		;1a24	20 20		   
	jr nz,l1a48h		;1a26	20 20		   
	jr nz,l1a4ah		;1a28	20 20		   
	jr nz,l1a4ch		;1a2a	20 20		   
	jr nz,l1a4eh		;1a2c	20 20		   
	jr nz,l1a50h		;1a2e	20 20		   
	jr nz,l1a52h		;1a30	20 20		   
	jr nz,l1a54h		;1a32	20 20		   
	jr nz,l1a56h		;1a34	20 20		   
	jr nz,l1a58h		;1a36	20 20		   
	jr nz,l1a5ah		;1a38	20 20		   
	jr nz,l1a5ch		;1a3a	20 20		   
	jr nz,l1a5eh		;1a3c	20 20		   
	jr nz,l1a60h		;1a3e	20 20		   
	jr nz,l1a62h		;1a40	20 20		   
l1a42h:
	jr nz,l1a64h		;1a42	20 20		   
	jr nz,l1a66h		;1a44	20 20		   
l1a46h:
	jr nz,l1a68h		;1a46	20 20		   
l1a48h:
	jr nz,l1a6ah		;1a48	20 20		   
l1a4ah:
	jr nz,l1a6ch		;1a4a	20 20		   
l1a4ch:
	jr nz,l1a6eh		;1a4c	20 20		   
l1a4eh:
	jr nz,$+34		;1a4e	20 20		   
l1a50h:
	jr nz,l1a72h		;1a50	20 20		   
l1a52h:
	jr nz,l1a74h		;1a52	20 20		   
l1a54h:
	jr nz,$+34		;1a54	20 20		   
l1a56h:
	jr nz,$+34		;1a56	20 20		   
l1a58h:
	jr nz,l1a7ah		;1a58	20 20		   
l1a5ah:
	jr nz,l1a7ch		;1a5a	20 20		   
l1a5ch:
	jr nz,l1a7eh		;1a5c	20 20		   
l1a5eh:
	jr nz,l1a80h		;1a5e	20 20		   
l1a60h:
	jr nz,l1a82h		;1a60	20 20		   
l1a62h:
	jr nz,l1a84h		;1a62	20 20		   
l1a64h:
	jr nz,l1a86h		;1a64	20 20		   
l1a66h:
	jr nz,l1a88h		;1a66	20 20		   
l1a68h:
	jr nz,l1a8ah		;1a68	20 20		   
l1a6ah:
	jr nz,l1a8ch		;1a6a	20 20		   
l1a6ch:
	jr nz,l1a8eh		;1a6c	20 20		   
l1a6eh:
	ld c,b			;1a6e	48		H
	ld (0c300h),hl		;1a6f	22 00 c3	" . .
l1a72h:
	push bc			;1a72	c5		.
	ld a,(de)		;1a73	1a		.
l1a74h:
	jp z,l201ah		;1a74	ca 1a 20	. .  
	ld (l2020h),hl		;1a77	22 20 20	"    
l1a7ah:
	jr nz,l1a9ch		;1a7a	20 20		   
l1a7ch:
	jr nz,l1a9eh		;1a7c	20 20		   
l1a7eh:
	jr nz,l1aa0h		;1a7e	20 20		   
l1a80h:
	jr nz,l1aa2h		;1a80	20 20		   
l1a82h:
	jr nz,l1aa4h		;1a82	20 20		   
l1a84h:
	jr nz,l1aa6h		;1a84	20 20		   
l1a86h:
	jr nz,l1aa8h		;1a86	20 20		   
l1a88h:
	jr nz,l1aaah		;1a88	20 20		   
l1a8ah:
	jr nz,l1aach		;1a8a	20 20		   
l1a8ch:
	jr nz,l1aaeh		;1a8c	20 20		   
l1a8eh:
	jr nz,l1ab0h		;1a8e	20 20		   
	jr nz,l1ab2h		;1a90	20 20		   
	jr nz,l1ab4h		;1a92	20 20		   
	jr nz,l1ab6h		;1a94	20 20		   
	jr nz,l1ab8h		;1a96	20 20		   
	jr nz,l1abah		;1a98	20 20		   
	jr nz,l1abch		;1a9a	20 20		   
l1a9ch:
	jr nz,l1abeh		;1a9c	20 20		   
l1a9eh:
	jr nz,l1ac0h		;1a9e	20 20		   
l1aa0h:
	jr nz,l1ac2h		;1aa0	20 20		   
l1aa2h:
	jr nz,$+34		;1aa2	20 20		   
l1aa4h:
	jr nz,l1ac6h		;1aa4	20 20		   
l1aa6h:
	jr nz,l1ac8h		;1aa6	20 20		   
l1aa8h:
	jr nz,l1acah		;1aa8	20 20		   
l1aaah:
	jr nz,l1acch		;1aaa	20 20		   
l1aach:
	jr nz,l1aceh		;1aac	20 20		   
l1aaeh:
	jr nz,l1ad0h		;1aae	20 20		   
l1ab0h:
	jr nz,l1ad2h		;1ab0	20 20		   
l1ab2h:
	jr nz,$+34		;1ab2	20 20		   
l1ab4h:
	jr nz,$+34		;1ab4	20 20		   
l1ab6h:
	jr nz,$+34		;1ab6	20 20		   
l1ab8h:
	jr nz,$+34		;1ab8	20 20		   
l1abah:
	jr nz,$+34		;1aba	20 20		   
l1abch:
	jr nz,$+34		;1abc	20 20		   
l1abeh:
	jr nz,$+34		;1abe	20 20		   
l1ac0h:
	jr nz,$+34		;1ac0	20 20		   
l1ac2h:
	ld c,b			;1ac2	48		H
	ld (0c300h),hl		;1ac3	22 00 c3	" . .
l1ac6h:
	add hl,de		;1ac6	19		.
	dec de			;1ac7	1b		.
l1ac8h:
	ld e,01bh		;1ac8	1e 1b		. .
l1acah:
	jr nz,l1aeeh		;1aca	20 22		  "
l1acch:
	jr nz,l1aeeh		;1acc	20 20		   
l1aceh:
	jr nz,l1af0h		;1ace	20 20		   
l1ad0h:
	jr nz,$+34		;1ad0	20 20		   
l1ad2h:
	ld h,a			;1ad2	67		g
	jr nz,l1af5h		;1ad3	20 20		   
	jr nz,l1af7h		;1ad5	20 20		   
	jr nz,l1af9h		;1ad7	20 20		   
	jr nz,l1afbh		;1ad9	20 20		   
	jr nz,l1afdh		;1adb	20 20		   
	jr nz,l1affh		;1add	20 20		   
	jr nz,l1b01h		;1adf	20 20		   
	jr nz,l1b03h		;1ae1	20 20		   
	jr nz,l1b05h		;1ae3	20 20		   
	jr nz,l1b07h		;1ae5	20 20		   
	ld hl,(l2020h)		;1ae7	2a 20 20	*    
	jr nz,$+34		;1aea	20 20		   
	jr nz,$+34		;1aec	20 20		   
l1aeeh:
	jr nz,$+34		;1aee	20 20		   
l1af0h:
	ld a,h			;1af0	7c		|
	jr nz,l1b13h		;1af1	20 20		   
	jr nz,l1b15h		;1af3	20 20		   
l1af5h:
	jr nz,l1b17h		;1af5	20 20		   
l1af7h:
	jr nz,$+34		;1af7	20 20		   
l1af9h:
	jr nz,l1b1bh		;1af9	20 20		   
l1afbh:
	jr nz,l1b1dh		;1afb	20 20		   
l1afdh:
	jr nz,$+34		;1afd	20 20		   
l1affh:
	jr nz,l1b21h		;1aff	20 20		   
l1b01h:
	jr nz,l1b2dh		;1b01	20 2a		  *
l1b03h:
	jr nz,l1b25h		;1b03	20 20		   
l1b05h:
	jr nz,l1b27h		;1b05	20 20		   
l1b07h:
	jr nz,l1b29h		;1b07	20 20		   
	jr nz,l1b2bh		;1b09	20 20		   
	jr nz,l1b2dh		;1b0b	20 20		   
	jr nz,l1b2fh		;1b0d	20 20		   
	jr nz,l1b31h		;1b0f	20 20		   
	jr nz,l1b33h		;1b11	20 20		   
l1b13h:
	jr nz,l1b35h		;1b13	20 20		   
l1b15h:
	jr nz,l1b5fh		;1b15	20 48		  H
l1b17h:
	ld (0c300h),hl		;1b17	22 00 c3	" . .
	ld (hl),c		;1b1a	71		q
l1b1bh:
	dec de			;1b1b	1b		.
	halt			;1b1c	76		v
l1b1dh:
	dec de			;1b1d	1b		.
	jr nz,l1b42h		;1b1e	20 22		  "
	dec a			;1b20	3d		=
l1b21h:
	dec a			;1b21	3d		=
	dec a			;1b22	3d		=
	dec a			;1b23	3d		=
	dec a			;1b24	3d		=
l1b25h:
	dec a			;1b25	3d		=
	dec a			;1b26	3d		=
l1b27h:
	dec a			;1b27	3d		=
	dec a			;1b28	3d		=
l1b29h:
	dec a			;1b29	3d		=
	dec a			;1b2a	3d		=
l1b2bh:
	dec a			;1b2b	3d		=
	dec a			;1b2c	3d		=
l1b2dh:
	dec a			;1b2d	3d		=
	dec a			;1b2e	3d		=
l1b2fh:
	dec a			;1b2f	3d		=
	dec a			;1b30	3d		=
l1b31h:
	dec a			;1b31	3d		=
	dec a			;1b32	3d		=
l1b33h:
	dec a			;1b33	3d		=
	dec a			;1b34	3d		=
l1b35h:
	dec a			;1b35	3d		=
	dec a			;1b36	3d		=
	dec a			;1b37	3d		=
	dec a			;1b38	3d		=
	dec a			;1b39	3d		=
	dec a			;1b3a	3d		=
	dec a			;1b3b	3d		=
	dec a			;1b3c	3d		=
	dec a			;1b3d	3d		=
	dec a			;1b3e	3d		=
	dec a			;1b3f	3d		=
	dec a			;1b40	3d		=
	dec a			;1b41	3d		=
l1b42h:
	dec a			;1b42	3d		=
	dec a			;1b43	3d		=
	dec a			;1b44	3d		=
	dec a			;1b45	3d		=
	dec a			;1b46	3d		=
	dec a			;1b47	3d		=
	dec a			;1b48	3d		=
	dec a			;1b49	3d		=
	dec a			;1b4a	3d		=
	dec a			;1b4b	3d		=
	dec a			;1b4c	3d		=
	dec a			;1b4d	3d		=
	dec a			;1b4e	3d		=
	dec a			;1b4f	3d		=
	dec a			;1b50	3d		=
	dec a			;1b51	3d		=
	dec a			;1b52	3d		=
	dec a			;1b53	3d		=
	dec a			;1b54	3d		=
	dec a			;1b55	3d		=
	dec a			;1b56	3d		=
	dec a			;1b57	3d		=
	dec a			;1b58	3d		=
	dec a			;1b59	3d		=
	dec a			;1b5a	3d		=
	dec a			;1b5b	3d		=
	dec a			;1b5c	3d		=
	dec a			;1b5d	3d		=
	dec a			;1b5e	3d		=
l1b5fh:
	dec a			;1b5f	3d		=
	dec a			;1b60	3d		=
	dec a			;1b61	3d		=
	dec a			;1b62	3d		=
	dec a			;1b63	3d		=
	dec a			;1b64	3d		=
	dec a			;1b65	3d		=
	dec a			;1b66	3d		=
	dec a			;1b67	3d		=
	dec a			;1b68	3d		=
	dec a			;1b69	3d		=
	dec a			;1b6a	3d		=
	dec a			;1b6b	3d		=
	dec a			;1b6c	3d		=
	dec a			;1b6d	3d		=
	dec a			;1b6e	3d		=
	ld (0c300h),hl		;1b6f	22 00 c3	" . .
	ld a,d			;1b72	7a		z
	dec de			;1b73	1b		.
	ld a,a			;1b74	7f		.
	dec de			;1b75	1b		.
	jr nz,$+53		;1b76	20 33		  3
	dec (hl)		;1b78	35		5
	nop			;1b79	00		.
	jp l1b86h		;1b7a	c3 86 1b	. . .
	adc a,e			;1b7d	8b		.
	dec de			;1b7e	1b		.
	jr nz,l1bbah		;1b7f	20 39		  9
	jr nc,$+50		;1b81	30 30		0 0
	inc l			;1b83	2c		,
	dec (hl)		;1b84	35		5
	nop			;1b85	00		.
l1b86h:
	jp l1bd6h+2		;1b86	c3 d8 1b	. . .
	defb 0ddh,01bh,020h ;illegal sequence	;1b89	dd 1b 20	. .  
	ld (l2020h),hl		;1b8c	22 20 20	"    
	jr nz,$+34		;1b8f	20 20		   
	jr nz,$+34		;1b91	20 20		   
	jr nz,$+34		;1b93	20 20		   
	jr nz,$+34		;1b95	20 20		   
	jr nz,$+34		;1b97	20 20		   
	jr nz,$+34		;1b99	20 20		   
	jr nz,$+34		;1b9b	20 20		   
	jr nz,$+34		;1b9d	20 20		   
	jr nz,$+34		;1b9f	20 20		   
	jr nz,$+34		;1ba1	20 20		   
	jr nz,$+34		;1ba3	20 20		   
	jr nz,$+34		;1ba5	20 20		   
	jr nz,$+34		;1ba7	20 20		   
	ld d,(hl)		;1ba9	56		V
	jr nz,l1bcch		;1baa	20 20		   
	jr nz,l1bceh		;1bac	20 20		   
	jr nz,l1bd0h		;1bae	20 20		   
	jr nz,l1bd2h		;1bb0	20 20		   
	jr nz,l1bd4h		;1bb2	20 20		   
	jr nz,l1bd6h		;1bb4	20 20		   
	jr nz,$+34		;1bb6	20 20		   
	jr nz,$+88		;1bb8	20 56		  V
l1bbah:
	jr nz,$+34		;1bba	20 20		   
	jr nz,$+34		;1bbc	20 20		   
	jr nz,$+34		;1bbe	20 20		   
	jr nz,$+34		;1bc0	20 20		   
	jr nz,$+34		;1bc2	20 20		   
	jr nz,$+88		;1bc4	20 56		  V
	jr nz,$+34		;1bc6	20 20		   
	jr nz,$+34		;1bc8	20 20		   
l1bcah:
	jr nz,$+34		;1bca	20 20		   
l1bcch:
	jr nz,$+34		;1bcc	20 20		   
l1bceh:
	jr nz,$+34		;1bce	20 20		   
l1bd0h:
	jr nz,$+34		;1bd0	20 20		   
l1bd2h:
	jr nz,$+34		;1bd2	20 20		   
l1bd4h:
	jr nz,$+38		;1bd4	20 24		  $
l1bd6h:
	ld (0c300h),hl		;1bd6	22 00 c3	" . .
	dec hl			;1bd9	2b		+
	inc e			;1bda	1c		.
	jr nc,l1bf9h		;1bdb	30 1c		0 .
	jr nz,l1c01h		;1bdd	20 22		  "
	jr nz,l1c01h		;1bdf	20 20		   
	jr nz,l1c03h		;1be1	20 20		   
	jr nz,l1c05h		;1be3	20 20		   
	jr nz,l1c07h		;1be5	20 20		   
	jr nz,l1c09h		;1be7	20 20		   
	jr nz,l1c0bh		;1be9	20 20		   
	jr nz,l1c0dh		;1beb	20 20		   
	jr nz,l1c0fh		;1bed	20 20		   
	jr nz,l1c11h		;1bef	20 20		   
	jr nz,l1c13h		;1bf1	20 20		   
	jr nz,l1c15h		;1bf3	20 20		   
	jr nz,l1c17h		;1bf5	20 20		   
	jr nz,l1c19h		;1bf7	20 20		   
l1bf9h:
	jr nz,l1c1bh		;1bf9	20 20		   
	jr nz,l1c1dh		;1bfb	20 20		   
	jr nz,l1c1fh		;1bfd	20 20		   
	jr nz,l1c21h		;1bff	20 20		   
l1c01h:
	jr nz,l1c23h		;1c01	20 20		   
l1c03h:
	jr nz,l1c25h		;1c03	20 20		   
l1c05h:
	jr nz,l1c27h		;1c05	20 20		   
l1c07h:
	jr nz,l1c29h		;1c07	20 20		   
l1c09h:
	jr nz,$+34		;1c09	20 20		   
l1c0bh:
	jr nz,l1c2dh		;1c0b	20 20		   
l1c0dh:
	jr nz,l1c2fh		;1c0d	20 20		   
l1c0fh:
	jr nz,$+34		;1c0f	20 20		   
l1c11h:
	jr nz,$+34		;1c11	20 20		   
l1c13h:
	jr nz,$+34		;1c13	20 20		   
l1c15h:
	jr nz,$+34		;1c15	20 20		   
l1c17h:
	jr nz,$+34		;1c17	20 20		   
l1c19h:
	jr nz,$+34		;1c19	20 20		   
l1c1bh:
	jr nz,l1c3dh		;1c1b	20 20		   
l1c1dh:
	jr nz,l1c3fh		;1c1d	20 20		   
l1c1fh:
	jr nz,l1c41h		;1c1f	20 20		   
l1c21h:
	jr nz,l1c43h		;1c21	20 20		   
l1c23h:
	jr nz,l1c45h		;1c23	20 20		   
l1c25h:
	jr nz,l1c4bh		;1c25	20 24		  $
l1c27h:
	inc h			;1c27	24		$
	inc h			;1c28	24		$
l1c29h:
	ld (0c300h),hl		;1c29	22 00 c3	" . .
	add a,e			;1c2c	83		.
l1c2dh:
	inc e			;1c2d	1c		.
	adc a,b			;1c2e	88		.
l1c2fh:
	inc e			;1c2f	1c		.
	jr nz,$+36		;1c30	20 22		  "
	jr nz,$+34		;1c32	20 20		   
	jr nz,$+34		;1c34	20 20		   
	jr nz,$+105		;1c36	20 67		  g
	jr nz,$+34		;1c38	20 20		   
	jr nz,$+34		;1c3a	20 20		   
	ld c,b			;1c3c	48		H
l1c3dh:
	jr nz,l1c5fh		;1c3d	20 20		   
l1c3fh:
	jr nz,l1c61h		;1c3f	20 20		   
l1c41h:
	jr nz,l1c63h		;1c41	20 20		   
l1c43h:
	jr nz,l1c65h		;1c43	20 20		   
l1c45h:
	jr nz,l1c67h		;1c45	20 20		   
	jr nz,l1c69h		;1c47	20 20		   
	jr nz,l1c6bh		;1c49	20 20		   
l1c4bh:
	jr nz,l1c6dh		;1c4b	20 20		   
	jr nz,l1c6fh		;1c4d	20 20		   
	jr nz,l1c71h		;1c4f	20 20		   
	jr nz,$+34		;1c51	20 20		   
	jr nz,$+34		;1c53	20 20		   
	jr nz,$+34		;1c55	20 20		   
	jr nz,l1c79h		;1c57	20 20		   
	jr nz,l1c7bh		;1c59	20 20		   
	jr nz,l1c7dh		;1c5b	20 20		   
	jr nz,l1c7fh		;1c5d	20 20		   
l1c5fh:
	jr nz,l1c81h		;1c5f	20 20		   
l1c61h:
	jr nz,$+34		;1c61	20 20		   
l1c63h:
	jr nz,$+34		;1c63	20 20		   
l1c65h:
	jr nz,l1c87h		;1c65	20 20		   
l1c67h:
	jr nz,$+34		;1c67	20 20		   
l1c69h:
	jr nz,l1c8bh		;1c69	20 20		   
l1c6bh:
	jr nz,l1c8dh		;1c6b	20 20		   
l1c6dh:
	jr nz,l1c8fh		;1c6d	20 20		   
l1c6fh:
	jr nz,l1c91h		;1c6f	20 20		   
l1c71h:
	ld c,b			;1c71	48		H
	jr nz,l1c94h		;1c72	20 20		   
	jr nz,l1c96h		;1c74	20 20		   
	jr nz,l1c98h		;1c76	20 20		   
	inc h			;1c78	24		$
l1c79h:
	inc h			;1c79	24		$
	inc h			;1c7a	24		$
l1c7bh:
	inc h			;1c7b	24		$
	inc h			;1c7c	24		$
l1c7dh:
	jr nz,$+34		;1c7d	20 20		   
l1c7fh:
	jr nz,l1cc9h		;1c7f	20 48		  H
l1c81h:
	ld (0c300h),hl		;1c81	22 00 c3	" . .
	in a,(01ch)		;1c84	db 1c		. .
	ret po			;1c86	e0		.
l1c87h:
	inc e			;1c87	1c		.
	jr nz,l1cach		;1c88	20 22		  "
	dec a			;1c8a	3d		=
l1c8bh:
	dec a			;1c8b	3d		=
	dec a			;1c8c	3d		=
l1c8dh:
	dec a			;1c8d	3d		=
	dec a			;1c8e	3d		=
l1c8fh:
	dec a			;1c8f	3d		=
	dec a			;1c90	3d		=
l1c91h:
	dec a			;1c91	3d		=
	dec a			;1c92	3d		=
	dec a			;1c93	3d		=
l1c94h:
	ld c,b			;1c94	48		H
	dec a			;1c95	3d		=
l1c96h:
	dec a			;1c96	3d		=
	dec a			;1c97	3d		=
l1c98h:
	jr nz,l1cbah		;1c98	20 20		   
	jr nz,l1cbch		;1c9a	20 20		   
	jr nz,l1cbeh		;1c9c	20 20		   
	jr nz,l1cc0h		;1c9e	20 20		   
	jr nz,l1cc2h		;1ca0	20 20		   
	jr nz,l1cc4h		;1ca2	20 20		   
	jr nz,l1cc6h		;1ca4	20 20		   
	jr nz,l1cc8h		;1ca6	20 20		   
	jr nz,l1ccah		;1ca8	20 20		   
	jr nz,l1ccch		;1caa	20 20		   
l1cach:
	jr nz,l1cceh		;1cac	20 20		   
	jr nz,l1cd0h		;1cae	20 20		   
	jr nz,l1cd2h		;1cb0	20 20		   
	jr nz,l1cd4h		;1cb2	20 20		   
	jr nz,l1cd6h		;1cb4	20 20		   
	jr nz,l1cd8h		;1cb6	20 20		   
	jr nz,$+34		;1cb8	20 20		   
l1cbah:
	jr nz,l1cdch		;1cba	20 20		   
l1cbch:
	jr nz,l1cdeh		;1cbc	20 20		   
l1cbeh:
	jr nz,l1ce0h		;1cbe	20 20		   
l1cc0h:
	jr nz,l1ce2h		;1cc0	20 20		   
l1cc2h:
	jr nz,l1ce4h		;1cc2	20 20		   
l1cc4h:
	jr nz,l1ce6h		;1cc4	20 20		   
l1cc6h:
	jr nz,l1ce8h		;1cc6	20 20		   
l1cc8h:
	dec a			;1cc8	3d		=
l1cc9h:
	ld c,b			;1cc9	48		H
l1ccah:
	dec a			;1cca	3d		=
	dec a			;1ccb	3d		=
l1ccch:
	dec a			;1ccc	3d		=
	dec a			;1ccd	3d		=
l1cceh:
	dec a			;1cce	3d		=
	dec a			;1ccf	3d		=
l1cd0h:
	dec a			;1cd0	3d		=
	dec a			;1cd1	3d		=
l1cd2h:
	dec a			;1cd2	3d		=
	dec a			;1cd3	3d		=
l1cd4h:
	dec a			;1cd4	3d		=
	dec a			;1cd5	3d		=
l1cd6h:
	dec a			;1cd6	3d		=
	dec a			;1cd7	3d		=
l1cd8h:
	ld c,b			;1cd8	48		H
	ld (0c300h),hl		;1cd9	22 00 c3	" . .
l1cdch:
	inc sp			;1cdc	33		3
	dec e			;1cdd	1d		.
l1cdeh:
	jr c,l1cfdh		;1cde	38 1d		8 .
l1ce0h:
	jr nz,$+36		;1ce0	20 22		  "
l1ce2h:
	jr nz,$+34		;1ce2	20 20		   
l1ce4h:
	jr nz,$+34		;1ce4	20 20		   
l1ce6h:
	jr nz,$+34		;1ce6	20 20		   
l1ce8h:
	jr nz,$+34		;1ce8	20 20		   
	jr nz,$+34		;1cea	20 20		   
	ld c,b			;1cec	48		H
	jr nz,l1d0fh		;1ced	20 20		   
	jr nz,l1d11h		;1cef	20 20		   
	jr nz,l1d13h		;1cf1	20 20		   
	jr nz,l1d15h		;1cf3	20 20		   
	jr nz,l1d17h		;1cf5	20 20		   
	jr nz,l1d19h		;1cf7	20 20		   
	jr nz,l1d1bh		;1cf9	20 20		   
	jr nz,l1d1dh		;1cfb	20 20		   
l1cfdh:
	jr nz,l1d1fh		;1cfd	20 20		   
	jr nz,l1d21h		;1cff	20 20		   
	jr nz,$+34		;1d01	20 20		   
	jr nz,$+34		;1d03	20 20		   
	jr nz,$+34		;1d05	20 20		   
	jr nz,$+34		;1d07	20 20		   
	jr nz,$+34		;1d09	20 20		   
	jr nz,$+34		;1d0b	20 20		   
	jr nz,$+34		;1d0d	20 20		   
l1d0fh:
	jr nz,l1d31h		;1d0f	20 20		   
l1d11h:
	jr nz,$+34		;1d11	20 20		   
l1d13h:
	jr nz,l1d35h		;1d13	20 20		   
l1d15h:
	jr nz,l1d37h		;1d15	20 20		   
l1d17h:
	jr nz,$+34		;1d17	20 20		   
l1d19h:
	jr nz,$+34		;1d19	20 20		   
l1d1bh:
	jr nz,$+34		;1d1b	20 20		   
l1d1dh:
	jr nz,$+34		;1d1d	20 20		   
l1d1fh:
	jr nz,$+34		;1d1f	20 20		   
l1d21h:
	ld c,b			;1d21	48		H
	jr nz,l1d44h		;1d22	20 20		   
	jr nz,$+34		;1d24	20 20		   
	jr nz,$+34		;1d26	20 20		   
	jr nz,$+34		;1d28	20 20		   
	jr nz,$+34		;1d2a	20 20		   
	jr nz,$+34		;1d2c	20 20		   
	jr nz,$+34		;1d2e	20 20		   
	ld c,b			;1d30	48		H
l1d31h:
	ld (0c300h),hl		;1d31	22 00 c3	" . .
	adc a,e			;1d34	8b		.
l1d35h:
	dec e			;1d35	1d		.
	sub b			;1d36	90		.
l1d37h:
	dec e			;1d37	1d		.
	jr nz,$+36		;1d38	20 22		  "
	jr nz,$+34		;1d3a	20 20		   
	jr nz,$+34		;1d3c	20 20		   
	jr nz,$+34		;1d3e	20 20		   
	jr nz,$+34		;1d40	20 20		   
	jr nz,$+34		;1d42	20 20		   
l1d44h:
	ld c,b			;1d44	48		H
	jr nz,l1d67h		;1d45	20 20		   
	jr nz,l1d69h		;1d47	20 20		   
	jr nz,l1d6bh		;1d49	20 20		   
	jr nz,l1d6dh		;1d4b	20 20		   
	jr nz,l1d6fh		;1d4d	20 20		   
	jr nz,l1d71h		;1d4f	20 20		   
	jr nz,l1d73h		;1d51	20 20		   
	jr nz,l1d75h		;1d53	20 20		   
	jr nz,l1d77h		;1d55	20 20		   
	jr nz,l1d79h		;1d57	20 20		   
	jr nz,$+34		;1d59	20 20		   
	jr nz,$+34		;1d5b	20 20		   
	jr nz,$+34		;1d5d	20 20		   
	jr nz,$+34		;1d5f	20 20		   
	jr nz,$+34		;1d61	20 20		   
	ld h,020h		;1d63	26 20		&  
	jr nz,$+34		;1d65	20 20		   
l1d67h:
	jr nz,l1d89h		;1d67	20 20		   
l1d69h:
	jr nz,$+34		;1d69	20 20		   
l1d6bh:
	jr nz,l1d8dh		;1d6b	20 20		   
l1d6dh:
	jr nz,l1d8fh		;1d6d	20 20		   
l1d6fh:
	jr nz,$+34		;1d6f	20 20		   
l1d71h:
	jr nz,$+34		;1d71	20 20		   
l1d73h:
	jr nz,$+34		;1d73	20 20		   
l1d75h:
	jr nz,$+34		;1d75	20 20		   
l1d77h:
	jr nz,l1d99h		;1d77	20 20		   
l1d79h:
	ld c,b			;1d79	48		H
	jr nz,l1d9ch		;1d7a	20 20		   
	jr nz,l1d9eh		;1d7c	20 20		   
	jr nz,l1da0h		;1d7e	20 20		   
	jr nz,l1da2h		;1d80	20 20		   
	jr nz,l1da4h		;1d82	20 20		   
	jr nz,$+34		;1d84	20 20		   
	jr nz,$+34		;1d86	20 20		   
	ld c,b			;1d88	48		H
l1d89h:
	ld (0c300h),hl		;1d89	22 00 c3	" . .
	ex (sp),hl		;1d8c	e3		.
l1d8dh:
	dec e			;1d8d	1d		.
	ret pe			;1d8e	e8		.
l1d8fh:
	dec e			;1d8f	1d		.
	jr nz,l1db4h		;1d90	20 22		  "
	jr nz,l1db4h		;1d92	20 20		   
	jr nz,l1db6h		;1d94	20 20		   
	jr nz,l1dd5h		;1d96	20 3d		  =
	dec a			;1d98	3d		=
l1d99h:
	dec a			;1d99	3d		=
	dec a			;1d9a	3d		=
	dec a			;1d9b	3d		=
l1d9ch:
	dec a			;1d9c	3d		=
	dec a			;1d9d	3d		=
l1d9eh:
	dec a			;1d9e	3d		=
	dec a			;1d9f	3d		=
l1da0h:
	dec a			;1da0	3d		=
	dec a			;1da1	3d		=
l1da2h:
	dec a			;1da2	3d		=
	dec a			;1da3	3d		=
l1da4h:
	dec a			;1da4	3d		=
	jr nz,l1dc7h		;1da5	20 20		   
	jr nz,$+63		;1da7	20 3d		  =
	dec a			;1da9	3d		=
	dec a			;1daa	3d		=
	dec a			;1dab	3d		=
	jr nz,l1dceh		;1dac	20 20		   
	jr nz,l1dd0h		;1dae	20 20		   
	jr nz,$+63		;1db0	20 3d		  =
	jr nz,l1dd4h		;1db2	20 20		   
l1db4h:
	jr nz,l1dd6h		;1db4	20 20		   
l1db6h:
	dec a			;1db6	3d		=
	dec a			;1db7	3d		=
	dec a			;1db8	3d		=
	dec a			;1db9	3d		=
	dec a			;1dba	3d		=
	dec a			;1dbb	3d		=
	jr nz,$+34		;1dbc	20 20		   
	jr nz,$+34		;1dbe	20 20		   
	dec a			;1dc0	3d		=
	jr nz,$+34		;1dc1	20 20		   
	jr nz,l1e02h		;1dc3	20 3d		  =
	dec a			;1dc5	3d		=
	dec a			;1dc6	3d		=
l1dc7h:
	dec a			;1dc7	3d		=
	jr nz,$+34		;1dc8	20 20		   
	jr nz,l1dech		;1dca	20 20		   
	dec a			;1dcc	3d		=
	dec a			;1dcd	3d		=
l1dceh:
	dec a			;1dce	3d		=
	dec a			;1dcf	3d		=
l1dd0h:
	dec a			;1dd0	3d		=
	ld c,b			;1dd1	48		H
	dec a			;1dd2	3d		=
	dec a			;1dd3	3d		=
l1dd4h:
	dec a			;1dd4	3d		=
l1dd5h:
	dec a			;1dd5	3d		=
l1dd6h:
	dec a			;1dd6	3d		=
	jr nz,$+34		;1dd7	20 20		   
	jr nz,$+34		;1dd9	20 20		   
	jr nz,$+34		;1ddb	20 20		   
	jr nz,l1dffh		;1ddd	20 20		   
	jr nz,l1e29h		;1ddf	20 48		  H
	ld (0c300h),hl		;1de1	22 00 c3	" . .
	dec sp			;1de4	3b		;
	ld e,040h		;1de5	1e 40		. @
	ld e,020h		;1de7	1e 20		.  
	ld (l2020h),hl		;1de9	22 20 20	"    
l1dech:
	jr nz,l1e0eh		;1dec	20 20		   
	jr nz,l1e10h		;1dee	20 20		   
	jr nz,l1e12h		;1df0	20 20		   
	jr nz,l1e14h		;1df2	20 20		   
	jr nz,l1e16h		;1df4	20 20		   
	jr nz,l1e18h		;1df6	20 20		   
	jr nz,l1e1ah		;1df8	20 20		   
	jr nz,l1e1ch		;1dfa	20 20		   
	jr nz,l1e5ch		;1dfc	20 5e		  ^
	ld e,(hl)		;1dfe	5e		^
l1dffh:
	ld e,(hl)		;1dff	5e		^
	jr nz,l1e22h		;1e00	20 20		   
l1e02h:
	jr nz,$+34		;1e02	20 20		   
	ld e,(hl)		;1e04	5e		^
	ld e,(hl)		;1e05	5e		^
	ld e,(hl)		;1e06	5e		^
	ld e,(hl)		;1e07	5e		^
	ld e,(hl)		;1e08	5e		^
	jr nz,$+96		;1e09	20 5e		  ^
	ld e,(hl)		;1e0b	5e		^
	ld e,(hl)		;1e0c	5e		^
	ld e,(hl)		;1e0d	5e		^
l1e0eh:
	jr nz,$+34		;1e0e	20 20		   
l1e10h:
	jr nz,$+34		;1e10	20 20		   
l1e12h:
	jr nz,$+34		;1e12	20 20		   
l1e14h:
	ld e,(hl)		;1e14	5e		^
	ld e,(hl)		;1e15	5e		^
l1e16h:
	ld e,(hl)		;1e16	5e		^
	ld e,(hl)		;1e17	5e		^
l1e18h:
	jr nz,l1e78h		;1e18	20 5e		  ^
l1e1ah:
	ld e,(hl)		;1e1a	5e		^
	ld e,(hl)		;1e1b	5e		^
l1e1ch:
	jr nz,$+34		;1e1c	20 20		   
	jr nz,$+34		;1e1e	20 20		   
	ld e,(hl)		;1e20	5e		^
	ld e,(hl)		;1e21	5e		^
l1e22h:
	ld e,(hl)		;1e22	5e		^
	jr nz,$+34		;1e23	20 20		   
	jr nz,$+34		;1e25	20 20		   
	jr nz,$+34		;1e27	20 20		   
l1e29h:
	jr nz,$+34		;1e29	20 20		   
	jr nz,$+34		;1e2b	20 20		   
	jr nz,$+34		;1e2d	20 20		   
	jr nz,$+34		;1e2f	20 20		   
	jr nz,$+34		;1e31	20 20		   
	jr nz,$+34		;1e33	20 20		   
	jr nz,$+34		;1e35	20 20		   
	jr nz,$+38		;1e37	20 24		  $
	ld (0c300h),hl		;1e39	22 00 c3	" . .
	adc a,e			;1e3c	8b		.
	ld e,090h		;1e3d	1e 90		. .
	ld e,020h		;1e3f	1e 20		.  
	ld (l2020h),hl		;1e41	22 20 20	"    
	jr nz,l1e66h		;1e44	20 20		   
	jr nz,l1e68h		;1e46	20 20		   
	jr nz,l1e6ah		;1e48	20 20		   
	jr nz,l1e6ch		;1e4a	20 20		   
	jr nz,l1e6eh		;1e4c	20 20		   
	jr nz,l1e70h		;1e4e	20 20		   
	jr nz,l1e72h		;1e50	20 20		   
	jr nz,l1e74h		;1e52	20 20		   
	jr nz,l1e76h		;1e54	20 20		   
	jr nz,l1e78h		;1e56	20 20		   
	jr nz,l1e7ah		;1e58	20 20		   
	jr nz,l1e7ch		;1e5a	20 20		   
l1e5ch:
	jr nz,l1e7eh		;1e5c	20 20		   
	jr nz,l1e80h		;1e5e	20 20		   
	jr nz,l1e82h		;1e60	20 20		   
	jr nz,l1e84h		;1e62	20 20		   
	jr nz,l1e86h		;1e64	20 20		   
l1e66h:
	jr nz,l1e88h		;1e66	20 20		   
l1e68h:
	jr nz,$+34		;1e68	20 20		   
l1e6ah:
	jr nz,l1e8ch		;1e6a	20 20		   
l1e6ch:
	jr nz,l1e8eh		;1e6c	20 20		   
l1e6eh:
	jr nz,$+34		;1e6e	20 20		   
l1e70h:
	jr nz,$+34		;1e70	20 20		   
l1e72h:
	jr nz,l1e94h		;1e72	20 20		   
l1e74h:
	jr nz,l1e96h		;1e74	20 20		   
l1e76h:
	jr nz,l1e98h		;1e76	20 20		   
l1e78h:
	jr nz,l1e9ah		;1e78	20 20		   
l1e7ah:
	jr nz,l1e9ch		;1e7a	20 20		   
l1e7ch:
	jr nz,$+34		;1e7c	20 20		   
l1e7eh:
	jr nz,$+34		;1e7e	20 20		   
l1e80h:
	jr nz,$+34		;1e80	20 20		   
l1e82h:
	jr nz,$+34		;1e82	20 20		   
l1e84h:
	jr nz,$+34		;1e84	20 20		   
l1e86h:
	jr nz,$+34		;1e86	20 20		   
l1e88h:
	ld a,h			;1e88	7c		|
	ld (0c300h),hl		;1e89	22 00 c3	" . .
l1e8ch:
	in a,(01eh)		;1e8c	db 1e		. .
l1e8eh:
	ret po			;1e8e	e0		.
	ld e,020h		;1e8f	1e 20		.  
	ld (l2020h),hl		;1e91	22 20 20	"    
l1e94h:
	jr nz,$+34		;1e94	20 20		   
l1e96h:
	jr nz,$+34		;1e96	20 20		   
l1e98h:
	jr nz,$+34		;1e98	20 20		   
l1e9ah:
	jr nz,$+34		;1e9a	20 20		   
l1e9ch:
	ld a,h			;1e9c	7c		|
	jr nz,l1ebfh		;1e9d	20 20		   
	jr nz,l1ec1h		;1e9f	20 20		   
	jr nz,l1ec3h		;1ea1	20 20		   
	jr nz,l1ec5h		;1ea3	20 20		   
	jr nz,l1ec7h		;1ea5	20 20		   
	jr nz,l1ec9h		;1ea7	20 20		   
	jr nz,l1ecbh		;1ea9	20 20		   
	jr nz,l1ecdh		;1eab	20 20		   
	jr nz,l1ecfh		;1ead	20 20		   
	jr nz,l1ed1h		;1eaf	20 20		   
	jr nz,l1efbh		;1eb1	20 48		  H
	jr nz,l1ed5h		;1eb3	20 20		   
	jr nz,l1ed7h		;1eb5	20 20		   
	jr nz,l1ed9h		;1eb7	20 20		   
	jr nz,$+34		;1eb9	20 20		   
	jr nz,l1eddh		;1ebb	20 20		   
	jr nz,l1edfh		;1ebd	20 20		   
l1ebfh:
	jr nz,$+34		;1ebf	20 20		   
l1ec1h:
	jr nz,$+34		;1ec1	20 20		   
l1ec3h:
	jr nz,$+34		;1ec3	20 20		   
l1ec5h:
	jr nz,$+34		;1ec5	20 20		   
l1ec7h:
	jr nz,$+34		;1ec7	20 20		   
l1ec9h:
	jr nz,$+34		;1ec9	20 20		   
l1ecbh:
	jr nz,l1eedh		;1ecb	20 20		   
l1ecdh:
	jr nz,l1eefh		;1ecd	20 20		   
l1ecfh:
	jr nz,l1ef7h		;1ecf	20 26		  &
l1ed1h:
	jr nz,l1ef3h		;1ed1	20 20		   
	jr nz,l1ef5h		;1ed3	20 20		   
l1ed5h:
	jr nz,l1ef7h		;1ed5	20 20		   
l1ed7h:
	jr nz,$+126		;1ed7	20 7c		  |
l1ed9h:
	ld (0c300h),hl		;1ed9	22 00 c3	" . .
	cpl			;1edc	2f		/
l1eddh:
	rra			;1edd	1f		.
	inc (hl)		;1ede	34		4
l1edfh:
	rra			;1edf	1f		.
	jr nz,l1f04h		;1ee0	20 22		  "
	jr nz,l1f04h		;1ee2	20 20		   
	jr nz,l1f06h		;1ee4	20 20		   
	jr nz,l1f08h		;1ee6	20 20		   
	jr nz,l1f0ah		;1ee8	20 20		   
	jr nz,l1f0ch		;1eea	20 20		   
	dec a			;1eec	3d		=
l1eedh:
	dec a			;1eed	3d		=
	dec a			;1eee	3d		=
l1eefh:
	dec a			;1eef	3d		=
	dec a			;1ef0	3d		=
	dec a			;1ef1	3d		=
	dec a			;1ef2	3d		=
l1ef3h:
	dec a			;1ef3	3d		=
	dec a			;1ef4	3d		=
l1ef5h:
	dec a			;1ef5	3d		=
	dec a			;1ef6	3d		=
l1ef7h:
	dec a			;1ef7	3d		=
	dec a			;1ef8	3d		=
	dec a			;1ef9	3d		=
	dec a			;1efa	3d		=
l1efbh:
	dec a			;1efb	3d		=
	dec a			;1efc	3d		=
sub_1efdh:
	dec a			;1efd	3d		=
	dec a			;1efe	3d		=
	dec a			;1eff	3d		=
	dec a			;1f00	3d		=
	dec a			;1f01	3d		=
	ld c,b			;1f02	48		H
	dec a			;1f03	3d		=
l1f04h:
	dec a			;1f04	3d		=
	dec a			;1f05	3d		=
l1f06h:
	dec a			;1f06	3d		=
	dec a			;1f07	3d		=
l1f08h:
	dec a			;1f08	3d		=
	dec a			;1f09	3d		=
l1f0ah:
	dec a			;1f0a	3d		=
	dec a			;1f0b	3d		=
l1f0ch:
	dec a			;1f0c	3d		=
	dec a			;1f0d	3d		=
	dec a			;1f0e	3d		=
	dec a			;1f0f	3d		=
	dec a			;1f10	3d		=
	dec a			;1f11	3d		=
	dec a			;1f12	3d		=
	dec a			;1f13	3d		=
	dec a			;1f14	3d		=
	dec a			;1f15	3d		=
	dec a			;1f16	3d		=
	dec a			;1f17	3d		=
	dec a			;1f18	3d		=
	dec a			;1f19	3d		=
	dec a			;1f1a	3d		=
	dec a			;1f1b	3d		=
	dec a			;1f1c	3d		=
	dec a			;1f1d	3d		=
	dec a			;1f1e	3d		=
	dec a			;1f1f	3d		=
	dec a			;1f20	3d		=
	jr nz,l1f60h		;1f21	20 3d		  =
	dec a			;1f23	3d		=
	dec a			;1f24	3d		=
	dec a			;1f25	3d		=
	dec a			;1f26	3d		=
	dec a			;1f27	3d		=
	dec a			;1f28	3d		=
	dec a			;1f29	3d		=
	dec a			;1f2a	3d		=
	dec a			;1f2b	3d		=
	dec a			;1f2c	3d		=
	ld (0c300h),hl		;1f2d	22 00 c3	" . .
	ld e,c			;1f30	59		Y
	rra			;1f31	1f		.
	ld e,(hl)		;1f32	5e		^
	rra			;1f33	1f		.
	jr nz,$+36		;1f34	20 22		  "
	jr nz,$+34		;1f36	20 20		   
	jr nz,l1f5ah		;1f38	20 20		   
	jr nz,l1f5ch		;1f3a	20 20		   
	jr nz,l1f5eh		;1f3c	20 20		   
	jr nz,l1f60h		;1f3e	20 20		   
	jr nz,l1f62h		;1f40	20 20		   
	jr nz,l1f6ah		;1f42	20 26		  &
	jr nz,l1f66h		;1f44	20 20		   
	jr nz,l1f68h		;1f46	20 20		   
	jr nz,l1f6ah		;1f48	20 20		   
	jr nz,l1f6ch		;1f4a	20 20		   
	jr nz,l1f6eh		;1f4c	20 20		   
	jr nz,l1f70h		;1f4e	20 20		   
	jr nz,l1f72h		;1f50	20 20		   
	jr nz,l1f74h		;1f52	20 20		   
	jr nz,l1f76h		;1f54	20 20		   
	ld c,b			;1f56	48		H
	ld (0c300h),hl		;1f57	22 00 c3	" . .
l1f5ah:
	add a,e			;1f5a	83		.
	rra			;1f5b	1f		.
l1f5ch:
	adc a,b			;1f5c	88		.
	rra			;1f5d	1f		.
l1f5eh:
	jr nz,$+36		;1f5e	20 22		  "
l1f60h:
	jr nz,$+34		;1f60	20 20		   
l1f62h:
	jr nz,l1f84h		;1f62	20 20		   
	jr nz,l1f86h		;1f64	20 20		   
l1f66h:
	jr nz,l1f88h		;1f66	20 20		   
l1f68h:
	jr nz,l1f8ah		;1f68	20 20		   
l1f6ah:
	jr nz,l1f8ch		;1f6a	20 20		   
l1f6ch:
	jr nz,l1f8eh		;1f6c	20 20		   
l1f6eh:
	jr nz,l1f90h		;1f6e	20 20		   
l1f70h:
	jr nz,l1f92h		;1f70	20 20		   
l1f72h:
	jr nz,l1f94h		;1f72	20 20		   
l1f74h:
	jr nz,l1f96h		;1f74	20 20		   
l1f76h:
	jr nz,l1f98h		;1f76	20 20		   
	jr nz,$+34		;1f78	20 20		   
	jr nz,$+34		;1f7a	20 20		   
	jr nz,$+34		;1f7c	20 20		   
	jr nz,$+34		;1f7e	20 20		   
	ld c,b			;1f80	48		H
	ld (0c300h),hl		;1f81	22 00 c3	" . .
l1f84h:
	out (01fh),a		;1f84	d3 1f		. .
l1f86h:
	ret c			;1f86	d8		.
	rra			;1f87	1f		.
l1f88h:
	jr nz,$+36		;1f88	20 22		  "
l1f8ah:
	jr nz,$+34		;1f8a	20 20		   
l1f8ch:
	jr nz,$+34		;1f8c	20 20		   
l1f8eh:
	jr nz,$+34		;1f8e	20 20		   
l1f90h:
	jr nz,$+34		;1f90	20 20		   
l1f92h:
	jr nz,$+34		;1f92	20 20		   
l1f94h:
	jr nz,$+34		;1f94	20 20		   
l1f96h:
	jr nz,$+34		;1f96	20 20		   
l1f98h:
	ld a,h			;1f98	7c		|
	jr nz,l1fbbh		;1f99	20 20		   
	jr nz,l1fbdh		;1f9b	20 20		   
	jr nz,l1fbfh		;1f9d	20 20		   
	jr nz,l1fc1h		;1f9f	20 20		   
	jr nz,l1fc3h		;1fa1	20 20		   
	jr nz,l1fc5h		;1fa3	20 20		   
	jr nz,l1fc7h		;1fa5	20 20		   
	jr nz,l1fc9h		;1fa7	20 20		   
	jr nz,l1ff3h		;1fa9	20 48		  H
	jr nz,l1fcdh		;1fab	20 20		   
	jr nz,l1fcfh		;1fad	20 20		   
	jr nz,l1fd1h		;1faf	20 20		   
	jr nz,$+34		;1fb1	20 20		   
	jr nz,$+34		;1fb3	20 20		   
	jr nz,l1fd7h		;1fb5	20 20		   
	jr nz,l1fd9h		;1fb7	20 20		   
	jr nz,$+34		;1fb9	20 20		   
l1fbbh:
	jr nz,sub_2005h		;1fbb	20 48		  H
l1fbdh:
	jr nz,$+34		;1fbd	20 20		   
l1fbfh:
	jr nz,$+34		;1fbf	20 20		   
l1fc1h:
	jr nz,$+34		;1fc1	20 20		   
l1fc3h:
	jr nz,$+34		;1fc3	20 20		   
l1fc5h:
	jr nz,$+34		;1fc5	20 20		   
l1fc7h:
	jr nz,l1fe9h		;1fc7	20 20		   
l1fc9h:
	jr nz,l1febh		;1fc9	20 20		   
	jr nz,l1fedh		;1fcb	20 20		   
l1fcdh:
	jr nz,sub_1fefh		;1fcd	20 20		   
l1fcfh:
	jr nz,l2019h		;1fcf	20 48		  H
l1fd1h:
	ld (0c300h),hl		;1fd1	22 00 c3	" . .
	ld hl,(l2f20h)		;1fd4	2a 20 2f	*   /
l1fd7h:
	jr nz,l1ff9h		;1fd7	20 20		   
l1fd9h:
	ld (l2020h),hl		;1fd9	22 20 20	"    
	jr nz,l1ffeh		;1fdc	20 20		   
	jr nz,l2000h		;1fde	20 20		   
	jr nz,l2002h		;1fe0	20 20		   
	jr nz,l2004h		;1fe2	20 20		   
	jr nz,l2006h		;1fe4	20 20		   
	jr nz,l2008h		;1fe6	20 20		   
	dec a			;1fe8	3d		=
l1fe9h:
	dec a			;1fe9	3d		=
	dec a			;1fea	3d		=
l1febh:
	dec a			;1feb	3d		=
	dec a			;1fec	3d		=
l1fedh:
	dec a			;1fed	3d		=
	dec a			;1fee	3d		=
sub_1fefh:
	dec a			;1fef	3d		=
	dec a			;1ff0	3d		=
	dec a			;1ff1	3d		=
	dec a			;1ff2	3d		=
l1ff3h:
	dec a			;1ff3	3d		=
	dec a			;1ff4	3d		=
	dec a			;1ff5	3d		=
	dec a			;1ff6	3d		=
	dec a			;1ff7	3d		=
	dec a			;1ff8	3d		=
l1ff9h:
	dec a			;1ff9	3d		=
	ld c,b			;1ffa	48		H
	dec a			;1ffb	3d		=
	dec a			;1ffc	3d		=
	dec a			;1ffd	3d		=
l1ffeh:
	dec a			;1ffe	3d		=
	dec a			;1fff	3d		=
l2000h:
	dec a			;2000	3d		=
	dec a			;2001	3d		=
l2002h:
	dec a			;2002	3d		=
	dec a			;2003	3d		=
l2004h:
	dec a			;2004	3d		=
sub_2005h:
	dec a			;2005	3d		=
l2006h:
	dec a			;2006	3d		=
	dec a			;2007	3d		=
l2008h:
	dec a			;2008	3d		=
	dec a			;2009	3d		=
	dec a			;200a	3d		=
	dec a			;200b	3d		=
	ld c,b			;200c	48		H
	dec a			;200d	3d		=
	dec a			;200e	3d		=
	dec a			;200f	3d		=
	dec a			;2010	3d		=
	dec a			;2011	3d		=
	dec a			;2012	3d		=
	dec a			;2013	3d		=
	dec a			;2014	3d		=
l2015h:
	dec a			;2015	3d		=
	dec a			;2016	3d		=
	dec a			;2017	3d		=
	dec a			;2018	3d		=
l2019h:
	dec a			;2019	3d		=
l201ah:
	dec a			;201a	3d		=
	dec a			;201b	3d		=
	dec a			;201c	3d		=
	dec a			;201d	3d		=
l201eh:
	dec a			;201e	3d		=
	dec a			;201f	3d		=
l2020h:
	ld c,b			;2020	48		H
sub_2021h:
	dec a			;2021	3d		=
l2022h:
	dec a			;2022	3d		=
	dec a			;2023	3d		=
	dec a			;2024	3d		=
	dec a			;2025	3d		=
	dec a			;2026	3d		=
sub_2027h:
	dec a			;2027	3d		=
	ld (0c300h),hl		;2028	22 00 c3	" . .
	ld a,d			;202b	7a		z
	jr nz,l20adh		;202c	20 7f		  .
	jr nz,$+34		;202e	20 20		   
	ld (l2020h),hl		;2030	22 20 20	"    
	jr nz,l2055h		;2033	20 20		   
	jr nz,l2057h		;2035	20 20		   
	jr nz,l2059h		;2037	20 20		   
	jr nz,l205bh		;2039	20 20		   
	jr nz,l205dh		;203b	20 20		   
	jr nz,l205fh		;203d	20 20		   
	jr nz,l2061h		;203f	20 20		   
	jr nz,l2063h		;2041	20 20		   
	jr nz,$+34		;2043	20 20		   
	jr nz,$+34		;2045	20 20		   
	jr nz,$+34		;2047	20 20		   
	jr nz,$+34		;2049	20 20		   
	jr nz,$+34		;204b	20 20		   
	jr nz,$+34		;204d	20 20		   
	jr nz,$+34		;204f	20 20		   
	jr nz,$+34		;2051	20 20		   
	jr nz,$+34		;2053	20 20		   
l2055h:
	jr nz,$+34		;2055	20 20		   
l2057h:
	jr nz,$+34		;2057	20 20		   
l2059h:
	jr nz,l207bh		;2059	20 20		   
l205bh:
	jr nz,$+34		;205b	20 20		   
l205dh:
	jr nz,$+34		;205d	20 20		   
l205fh:
	jr nz,$+34		;205f	20 20		   
l2061h:
	jr nz,l2083h		;2061	20 20		   
l2063h:
	ld c,b			;2063	48		H
	jr nz,$+34		;2064	20 20		   
	jr nz,$+34		;2066	20 20		   
l2068h:
	jr nz,$+34		;2068	20 20		   
	jr nz,$+34		;206a	20 20		   
	jr nz,$+34		;206c	20 20		   
	jr nz,$+34		;206e	20 20		   
	jr nz,$+34		;2070	20 20		   
	jr nz,$+34		;2072	20 20		   
	jr nz,$+34		;2074	20 20		   
	jr nz,$+74		;2076	20 48		  H
	ld (0c300h),hl		;2078	22 00 c3	" . .
l207bh:
	jp z,0cf20h		;207b	ca 20 cf	.   .
	jr nz,$+34		;207e	20 20		   
	ld (l2020h),hl		;2080	22 20 20	"    
l2083h:
	jr nz,l20a5h		;2083	20 20		   
	jr nz,l20a7h		;2085	20 20		   
	jr nz,l20a9h		;2087	20 20		   
	jr nz,l20abh		;2089	20 20		   
	jr nz,l20adh		;208b	20 20		   
	jr nz,l20afh		;208d	20 20		   
	jr nz,l20b1h		;208f	20 20		   
	jr nz,l20b3h		;2091	20 20		   
	jr nz,l20b5h		;2093	20 20		   
	jr nz,l20b7h		;2095	20 20		   
	jr nz,l20b9h		;2097	20 20		   
	jr nz,l20bbh		;2099	20 20		   
	jr nz,l20bdh		;209b	20 20		   
	jr nz,l20bfh		;209d	20 20		   
	jr nz,l20c1h		;209f	20 20		   
	jr nz,l20c3h		;20a1	20 20		   
	jr nz,l20c5h		;20a3	20 20		   
l20a5h:
	jr nz,l20c7h		;20a5	20 20		   
l20a7h:
	jr nz,$+34		;20a7	20 20		   
l20a9h:
	jr nz,l20cbh		;20a9	20 20		   
l20abh:
	jr nz,$+34		;20ab	20 20		   
l20adh:
	jr nz,l20cfh		;20ad	20 20		   
l20afh:
	jr nz,l20d1h		;20af	20 20		   
l20b1h:
	jr nz,l20d3h		;20b1	20 20		   
l20b3h:
	jr nz,l20d5h		;20b3	20 20		   
l20b5h:
	jr nz,l20d7h		;20b5	20 20		   
l20b7h:
	jr nz,l20d9h		;20b7	20 20		   
l20b9h:
	jr nz,l20dbh		;20b9	20 20		   
l20bbh:
	jr nz,l20ddh		;20bb	20 20		   
l20bdh:
	jr nz,l20dfh		;20bd	20 20		   
l20bfh:
	jr nz,l20e1h		;20bf	20 20		   
l20c1h:
	jr nz,l20e3h		;20c1	20 20		   
l20c3h:
	jr nz,l20e5h		;20c3	20 20		   
l20c5h:
	jr nz,l20e7h		;20c5	20 20		   
l20c7h:
	ld c,b			;20c7	48		H
	ld (0c300h),hl		;20c8	22 00 c3	" . .
l20cbh:
	ld a,(de)		;20cb	1a		.
	ld hl,l211fh		;20cc	21 1f 21	! . !
l20cfh:
	jr nz,l20f3h		;20cf	20 22		  "
l20d1h:
	jr nz,l20f3h		;20d1	20 20		   
l20d3h:
	jr nz,l20f5h		;20d3	20 20		   
l20d5h:
	jr nz,l20f7h		;20d5	20 20		   
l20d7h:
	jr nz,l20f9h		;20d7	20 20		   
l20d9h:
	jr nz,l20fbh		;20d9	20 20		   
l20dbh:
	jr nz,l20fdh		;20db	20 20		   
l20ddh:
	jr nz,l20ffh		;20dd	20 20		   
l20dfh:
	jr nz,l2101h		;20df	20 20		   
l20e1h:
	jr nz,l2103h		;20e1	20 20		   
l20e3h:
	jr nz,l2105h		;20e3	20 20		   
l20e5h:
	jr nz,l2107h		;20e5	20 20		   
l20e7h:
	jr nz,l2109h		;20e7	20 20		   
	jr nz,l210bh		;20e9	20 20		   
	jr nz,l210dh		;20eb	20 20		   
	jr nz,l210fh		;20ed	20 20		   
	jr nz,l2111h		;20ef	20 20		   
	jr nz,l2113h		;20f1	20 20		   
l20f3h:
	jr nz,l2115h		;20f3	20 20		   
l20f5h:
	jr nz,l2117h		;20f5	20 20		   
l20f7h:
	jr nz,$+34		;20f7	20 20		   
l20f9h:
	jr nz,l211bh		;20f9	20 20		   
l20fbh:
	jr nz,$+34		;20fb	20 20		   
l20fdh:
	jr nz,l211fh		;20fd	20 20		   
l20ffh:
	jr nz,l2121h		;20ff	20 20		   
l2101h:
	jr nz,$+34		;2101	20 20		   
l2103h:
	jr nz,$+34		;2103	20 20		   
l2105h:
	jr nz,$+34		;2105	20 20		   
l2107h:
	jr nz,$+34		;2107	20 20		   
l2109h:
	jr nz,$+34		;2109	20 20		   
l210bh:
	jr nz,$+34		;210b	20 20		   
l210dh:
	jr nz,$+34		;210d	20 20		   
l210fh:
	jr nz,$+34		;210f	20 20		   
l2111h:
	jr nz,$+34		;2111	20 20		   
l2113h:
	jr nz,$+34		;2113	20 20		   
l2115h:
	jr nz,$+34		;2115	20 20		   
l2117h:
	ld c,b			;2117	48		H
	ld (0c300h),hl		;2118	22 00 c3	" . .
l211bh:
	ld (hl),d		;211b	72		r
	ld hl,l2176h+1		;211c	21 77 21	! w !
l211fh:
	jr nz,$+36		;211f	20 22		  "
l2121h:
	ld hl,(l2020h)		;2121	2a 20 20	*    
	jr nz,l2146h		;2124	20 20		   
	jr nz,l2148h		;2126	20 20		   
	jr nz,l214ah		;2128	20 20		   
	jr nz,l214ch		;212a	20 20		   
	jr nz,l214eh		;212c	20 20		   
	jr nz,l2150h		;212e	20 20		   
	jr nz,l2152h		;2130	20 20		   
	jr nz,l2154h		;2132	20 20		   
	jr nz,l2156h		;2134	20 20		   
	jr nz,l2158h		;2136	20 20		   
	jr nz,l215ah		;2138	20 20		   
	jr nz,l215ch		;213a	20 20		   
	jr nz,l215eh		;213c	20 20		   
	jr nz,l2160h		;213e	20 20		   
	jr nz,l2162h		;2140	20 20		   
	jr nz,l2164h		;2142	20 20		   
	jr nz,l2166h		;2144	20 20		   
l2146h:
	jr nz,l2168h		;2146	20 20		   
l2148h:
	jr nz,l216ah		;2148	20 20		   
l214ah:
	jr nz,l216ch		;214a	20 20		   
l214ch:
	jr nz,l216eh		;214c	20 20		   
l214eh:
	jr nz,l2170h		;214e	20 20		   
l2150h:
	jr nz,$+34		;2150	20 20		   
l2152h:
	jr nz,$+34		;2152	20 20		   
l2154h:
	jr nz,l2176h		;2154	20 20		   
l2156h:
	jr nz,$+34		;2156	20 20		   
l2158h:
	jr nz,l217ah		;2158	20 20		   
l215ah:
	jr nz,l217ch		;215a	20 20		   
l215ch:
	jr nz,l217eh		;215c	20 20		   
l215eh:
	jr nz,l2180h		;215e	20 20		   
l2160h:
	jr nz,l2182h		;2160	20 20		   
l2162h:
	jr nz,l2184h		;2162	20 20		   
l2164h:
	jr nz,l2186h		;2164	20 20		   
l2166h:
	jr nz,l21b0h		;2166	20 48		  H
l2168h:
	jr nz,l218ah		;2168	20 20		   
l216ah:
	jr nz,l218ch		;216a	20 20		   
l216ch:
	jr nz,l218eh		;216c	20 20		   
l216eh:
	jr nz,l219ah		;216e	20 2a		  *
l2170h:
	ld (0c300h),hl		;2170	22 00 c3	" . .
	jp z,0cf21h		;2173	ca 21 cf	. ! .
l2176h:
	ld hl,02220h		;2176	21 20 22	!   "
	dec a			;2179	3d		=
l217ah:
	dec a			;217a	3d		=
	dec a			;217b	3d		=
l217ch:
	dec a			;217c	3d		=
	dec a			;217d	3d		=
l217eh:
	dec a			;217e	3d		=
	dec a			;217f	3d		=
l2180h:
	dec a			;2180	3d		=
	dec a			;2181	3d		=
l2182h:
	dec a			;2182	3d		=
	dec a			;2183	3d		=
l2184h:
	dec a			;2184	3d		=
	dec a			;2185	3d		=
l2186h:
	dec a			;2186	3d		=
	dec a			;2187	3d		=
	dec a			;2188	3d		=
	dec a			;2189	3d		=
l218ah:
	dec a			;218a	3d		=
	dec a			;218b	3d		=
l218ch:
	dec a			;218c	3d		=
	dec a			;218d	3d		=
l218eh:
	dec a			;218e	3d		=
	dec a			;218f	3d		=
	dec a			;2190	3d		=
	dec a			;2191	3d		=
	dec a			;2192	3d		=
	dec a			;2193	3d		=
	dec a			;2194	3d		=
	dec a			;2195	3d		=
	dec a			;2196	3d		=
	dec a			;2197	3d		=
	dec a			;2198	3d		=
	dec a			;2199	3d		=
l219ah:
	dec a			;219a	3d		=
	dec a			;219b	3d		=
	dec a			;219c	3d		=
	dec a			;219d	3d		=
	dec a			;219e	3d		=
	dec a			;219f	3d		=
	dec a			;21a0	3d		=
	dec a			;21a1	3d		=
	dec a			;21a2	3d		=
	dec a			;21a3	3d		=
	dec a			;21a4	3d		=
	dec a			;21a5	3d		=
	dec a			;21a6	3d		=
	dec a			;21a7	3d		=
	dec a			;21a8	3d		=
	dec a			;21a9	3d		=
	dec a			;21aa	3d		=
	dec a			;21ab	3d		=
	dec a			;21ac	3d		=
	dec a			;21ad	3d		=
	dec a			;21ae	3d		=
	dec a			;21af	3d		=
l21b0h:
	dec a			;21b0	3d		=
	dec a			;21b1	3d		=
	dec a			;21b2	3d		=
	dec a			;21b3	3d		=
	dec a			;21b4	3d		=
	dec a			;21b5	3d		=
	dec a			;21b6	3d		=
	dec a			;21b7	3d		=
	dec a			;21b8	3d		=
	dec a			;21b9	3d		=
	dec a			;21ba	3d		=
	dec a			;21bb	3d		=
	dec a			;21bc	3d		=
	dec a			;21bd	3d		=
	dec a			;21be	3d		=
	dec a			;21bf	3d		=
	dec a			;21c0	3d		=
	dec a			;21c1	3d		=
	dec a			;21c2	3d		=
	dec a			;21c3	3d		=
	dec a			;21c4	3d		=
	dec a			;21c5	3d		=
	dec a			;21c6	3d		=
	dec a			;21c7	3d		=
	ld (0c300h),hl		;21c8	22 00 c3	" . .
	out (021h),a		;21cb	d3 21		. !
	ret c			;21cd	d8		.
	ld hl,03320h		;21ce	21 20 33	!   3
	ld (hl),000h		;21d1	36 00		6 .
	jp l21dfh		;21d3	c3 df 21	. . !
	call po,sub_2021h	;21d6	e4 21 20	. !  
	jr c,$+50		;21d9	38 30		8 0
	jr nc,$+46		;21db	30 2c		0 ,
	dec (hl)		;21dd	35		5
	nop			;21de	00		.
l21dfh:
	jp 0222dh		;21df	c3 2d 22	. - "
	ld (l2022h),a		;21e2	32 22 20	2 "  
	ld (l2020h),hl		;21e5	22 20 20	"    
	jr nz,l220ah		;21e8	20 20		   
	jr nz,l220ch		;21ea	20 20		   
	jr nz,l220eh		;21ec	20 20		   
	jr nz,l2210h		;21ee	20 20		   
	jr nz,l2212h		;21f0	20 20		   
	jr nz,$+34		;21f2	20 20		   
	jr nz,$+34		;21f4	20 20		   
	jr nz,$+34		;21f6	20 20		   
	jr nz,$+34		;21f8	20 20		   
	jr nz,$+34		;21fa	20 20		   
	jr nz,$+34		;21fc	20 20		   
	jr nz,$+34		;21fe	20 20		   
	jr nz,$+34		;2200	20 20		   
	jr nz,$+34		;2202	20 20		   
	jr nz,$+34		;2204	20 20		   
	jr nz,$+34		;2206	20 20		   
	jr nz,$+34		;2208	20 20		   
l220ah:
	jr nz,$+34		;220a	20 20		   
l220ch:
	jr nz,l222eh		;220c	20 20		   
l220eh:
	jr nz,l2230h		;220e	20 20		   
l2210h:
	jr nz,$+34		;2210	20 20		   
l2212h:
	ld d,(hl)		;2212	56		V
	jr nz,$+34		;2213	20 20		   
	jr nz,l2237h		;2215	20 20		   
	jr nz,$+34		;2217	20 20		   
	jr nz,l223bh		;2219	20 20		   
	jr nz,l223dh		;221b	20 20		   
	jr nz,l223fh		;221d	20 20		   
	jr nz,l2241h		;221f	20 20		   
l2221h:
	jr nz,l2243h		;2221	20 20		   
	jr nz,l2245h		;2223	20 20		   
	jr nz,l2247h		;2225	20 20		   
	jr nz,l2249h		;2227	20 20		   
	jr nz,$+88		;2229	20 56		  V
	ld (0c300h),hl		;222b	22 00 c3	" . .
l222eh:
	ld (hl),022h		;222e	36 22		6 "
l2230h:
	dec sp			;2230	3b		;
	ld (02220h),hl		;2231	22 20 22	"   "
	ld (0c300h),hl		;2234	22 00 c3	" . .
l2237h:
	ld a,(hl)		;2237	7e		~
	ld (l2283h),hl		;2238	22 83 22	" . "
l223bh:
	jr nz,l225fh		;223b	20 22		  "
l223dh:
	jr nz,l225fh		;223d	20 20		   
l223fh:
	jr nz,l2261h		;223f	20 20		   
l2241h:
	jr nz,l228bh		;2241	20 48		  H
l2243h:
	jr nz,l2265h		;2243	20 20		   
l2245h:
	jr nz,l2267h		;2245	20 20		   
l2247h:
	jr nz,l2269h		;2247	20 20		   
l2249h:
	jr nz,l226bh		;2249	20 20		   
	jr nz,l226dh		;224b	20 20		   
	jr nz,l226fh		;224d	20 20		   
	jr nz,l2299h		;224f	20 48		  H
	jr nz,l2273h		;2251	20 20		   
	jr nz,l2275h		;2253	20 20		   
	jr nz,l2277h		;2255	20 20		   
	jr nz,l2279h		;2257	20 20		   
	jr nz,l227bh		;2259	20 20		   
	jr nz,$+34		;225b	20 20		   
	jr nz,l227fh		;225d	20 20		   
l225fh:
	jr nz,$+34		;225f	20 20		   
l2261h:
	jr nz,l2283h		;2261	20 20		   
	jr nz,l2285h		;2263	20 20		   
l2265h:
	jr nz,l2287h		;2265	20 20		   
l2267h:
	jr nz,l2289h		;2267	20 20		   
l2269h:
	jr nz,$+126		;2269	20 7c		  |
l226bh:
	jr nz,l228dh		;226b	20 20		   
l226dh:
	jr nz,l228fh		;226d	20 20		   
l226fh:
	jr nz,l2291h		;226f	20 20		   
	jr nz,l2293h		;2271	20 20		   
l2273h:
	jr nz,l2295h		;2273	20 20		   
l2275h:
	jr nz,l2297h		;2275	20 20		   
l2277h:
	jr nz,l2299h		;2277	20 20		   
l2279h:
	jr nz,l229bh		;2279	20 20		   
l227bh:
	ld c,b			;227b	48		H
	ld (0c300h),hl		;227c	22 00 c3	" . .
l227fh:
	pop de			;227f	d1		.
	ld (l22d6h),hl		;2280	22 d6 22	" . "
l2283h:
	jr nz,l22a7h		;2283	20 22		  "
l2285h:
	dec a			;2285	3d		=
	dec a			;2286	3d		=
l2287h:
	dec a			;2287	3d		=
	dec a			;2288	3d		=
l2289h:
	dec a			;2289	3d		=
	ld c,b			;228a	48		H
l228bh:
	dec a			;228b	3d		=
	dec a			;228c	3d		=
l228dh:
	dec a			;228d	3d		=
	dec a			;228e	3d		=
l228fh:
	dec a			;228f	3d		=
	dec l			;2290	2d		-
l2291h:
	dec l			;2291	2d		-
	dec a			;2292	3d		=
l2293h:
	dec a			;2293	3d		=
	dec a			;2294	3d		=
l2295h:
	dec a			;2295	3d		=
	dec a			;2296	3d		=
l2297h:
	dec a			;2297	3d		=
	ld c,b			;2298	48		H
l2299h:
	dec a			;2299	3d		=
	dec a			;229a	3d		=
l229bh:
	dec a			;229b	3d		=
	dec a			;229c	3d		=
	dec a			;229d	3d		=
	dec a			;229e	3d		=
	dec a			;229f	3d		=
	dec a			;22a0	3d		=
	dec a			;22a1	3d		=
	dec a			;22a2	3d		=
	dec a			;22a3	3d		=
	dec a			;22a4	3d		=
	dec a			;22a5	3d		=
	dec a			;22a6	3d		=
l22a7h:
	dec a			;22a7	3d		=
	dec a			;22a8	3d		=
	dec a			;22a9	3d		=
	dec a			;22aa	3d		=
	dec a			;22ab	3d		=
	dec a			;22ac	3d		=
	dec a			;22ad	3d		=
	dec a			;22ae	3d		=
	dec a			;22af	3d		=
	dec a			;22b0	3d		=
	dec a			;22b1	3d		=
	dec a			;22b2	3d		=
	jr nz,$+34		;22b3	20 20		   
	jr nz,$+34		;22b5	20 20		   
	jr nz,l22f6h		;22b7	20 3d		  =
	dec a			;22b9	3d		=
	dec a			;22ba	3d		=
	dec l			;22bb	2d		-
	dec l			;22bc	2d		-
	dec l			;22bd	2d		-
	dec l			;22be	2d		-
	dec a			;22bf	3d		=
	dec a			;22c0	3d		=
	dec a			;22c1	3d		=
sub_22c2h:
	dec a			;22c2	3d		=
	ld c,b			;22c3	48		H
	dec a			;22c4	3d		=
	dec a			;22c5	3d		=
	dec a			;22c6	3d		=
	dec a			;22c7	3d		=
	dec a			;22c8	3d		=
	dec a			;22c9	3d		=
	dec a			;22ca	3d		=
l22cbh:
	dec a			;22cb	3d		=
	dec a			;22cc	3d		=
	dec a			;22cd	3d		=
	dec a			;22ce	3d		=
	ld (0c300h),hl		;22cf	22 00 c3	" . .
	add hl,de		;22d2	19		.
	inc hl			;22d3	23		#
	ld e,023h		;22d4	1e 23		. #
l22d6h:
	jr nz,l22fah		;22d6	20 22		  "
	jr nz,l22fah		;22d8	20 20		   
	jr nz,l22fch		;22da	20 20		   
	jr nz,l2326h		;22dc	20 48		  H
	jr nz,$+34		;22de	20 20		   
	jr nz,$+34		;22e0	20 20		   
	jr nz,$+34		;22e2	20 20		   
sub_22e4h:
	jr nz,$+34		;22e4	20 20		   
	jr nz,$+34		;22e6	20 20		   
	jr nz,$+34		;22e8	20 20		   
	jr nz,l2334h		;22ea	20 48		  H
	jr nz,$+34		;22ec	20 20		   
	jr nz,$+34		;22ee	20 20		   
	jr nz,$+34		;22f0	20 20		   
	jr nz,$+34		;22f2	20 20		   
	jr nz,$+34		;22f4	20 20		   
l22f6h:
	jr nz,$+34		;22f6	20 20		   
	jr nz,l231ah		;22f8	20 20		   
l22fah:
	jr nz,l231ch		;22fa	20 20		   
l22fch:
	ld a,h			;22fc	7c		|
	ld h,026h		;22fd	26 26		& &
	jr nz,$+34		;22ff	20 20		   
	jr nz,$+34		;2301	20 20		   
	jr nz,$+34		;2303	20 20		   
	jr nz,$+34		;2305	20 20		   
	jr nz,$+34		;2307	20 20		   
	jr nz,$+34		;2309	20 20		   
	jr nz,$+34		;230b	20 20		   
	jr nz,$+34		;230d	20 20		   
sub_230fh:
	jr nz,$+34		;230f	20 20		   
	jr nz,$+34		;2311	20 20		   
	jr nz,$+34		;2313	20 20		   
	jr nz,l235fh		;2315	20 48		  H
	ld (0c300h),hl		;2317	22 00 c3	" . .
l231ah:
	ld h,c			;231a	61		a
	inc hl			;231b	23		#
l231ch:
	ld h,(hl)		;231c	66		f
	inc hl			;231d	23		#
	jr nz,l2342h		;231e	20 22		  "
	jr nz,l2342h		;2320	20 20		   
	jr nz,l2344h		;2322	20 20		   
	jr nz,l236eh		;2324	20 48		  H
l2326h:
	jr nz,l2348h		;2326	20 20		   
	jr nz,l234ah		;2328	20 20		   
	jr nz,l234ch		;232a	20 20		   
	jr nz,l234eh		;232c	20 20		   
	jr nz,l2350h		;232e	20 20		   
	jr nz,l2352h		;2330	20 20		   
	jr nz,l237ch		;2332	20 48		  H
l2334h:
	jr nz,l2356h		;2334	20 20		   
	jr nz,l2358h		;2336	20 20		   
	jr nz,l235ah		;2338	20 20		   
	jr nz,l235ch		;233a	20 20		   
	jr nz,l235eh		;233c	20 20		   
	jr nz,$+34		;233e	20 20		   
	jr nz,l2362h		;2340	20 20		   
l2342h:
	jr nz,l2364h		;2342	20 20		   
l2344h:
	dec a			;2344	3d		=
	dec a			;2345	3d		=
	dec a			;2346	3d		=
	dec a			;2347	3d		=
l2348h:
	dec a			;2348	3d		=
	dec a			;2349	3d		=
l234ah:
	dec a			;234a	3d		=
	dec a			;234b	3d		=
l234ch:
	dec a			;234c	3d		=
	dec a			;234d	3d		=
l234eh:
	dec a			;234e	3d		=
	dec a			;234f	3d		=
l2350h:
	dec a			;2350	3d		=
	dec a			;2351	3d		=
l2352h:
	dec a			;2352	3d		=
	dec a			;2353	3d		=
	dec a			;2354	3d		=
	dec a			;2355	3d		=
l2356h:
	jr nz,l2378h		;2356	20 20		   
l2358h:
	jr nz,l237ah		;2358	20 20		   
l235ah:
	jr nz,l237ch		;235a	20 20		   
l235ch:
	jr nz,l237eh		;235c	20 20		   
l235eh:
	ld c,b			;235e	48		H
l235fh:
	ld (0c300h),hl		;235f	22 00 c3	" . .
l2362h:
	xor c			;2362	a9		.
	inc hl			;2363	23		#
l2364h:
	xor (hl)		;2364	ae		.
	inc hl			;2365	23		#
	jr nz,l238ah		;2366	20 22		  "
	jr nz,l238ah		;2368	20 20		   
	jr nz,l238ch		;236a	20 20		   
	jr nz,l23b6h		;236c	20 48		  H
l236eh:
	jr nz,l2390h		;236e	20 20		   
	jr nz,l2392h		;2370	20 20		   
	jr nz,l2394h		;2372	20 20		   
	jr nz,l2396h		;2374	20 20		   
	jr nz,l2398h		;2376	20 20		   
l2378h:
	jr nz,l239ah		;2378	20 20		   
l237ah:
	jr nz,l23c4h		;237a	20 48		  H
l237ch:
	jr nz,l239eh		;237c	20 20		   
l237eh:
	jr nz,l23a0h		;237e	20 20		   
	jr nz,l23a2h		;2380	20 20		   
	jr nz,l23a4h		;2382	20 20		   
	jr nz,l23a6h		;2384	20 20		   
	jr nz,$+34		;2386	20 20		   
	jr nz,l23aah		;2388	20 20		   
l238ah:
	jr nz,l23ach		;238a	20 20		   
l238ch:
	jr nz,l23aeh		;238c	20 20		   
	jr nz,l23b0h		;238e	20 20		   
l2390h:
	jr nz,l23b2h		;2390	20 20		   
l2392h:
	jr nz,l23b4h		;2392	20 20		   
l2394h:
	jr nz,l23b6h		;2394	20 20		   
l2396h:
	jr nz,l23b8h		;2396	20 20		   
l2398h:
	jr nz,l23bah		;2398	20 20		   
l239ah:
	jr nz,l23e4h		;239a	20 48		  H
	jr nz,l23beh		;239c	20 20		   
l239eh:
	jr nz,l23c0h		;239e	20 20		   
l23a0h:
	jr nz,l23c2h		;23a0	20 20		   
l23a2h:
	jr nz,l23c4h		;23a2	20 20		   
l23a4h:
	jr nz,l23c6h		;23a4	20 20		   
l23a6h:
	ld c,b			;23a6	48		H
	ld (0c300h),hl		;23a7	22 00 c3	" . .
l23aah:
	inc iy			;23aa	fd 23		. #
l23ach:
	ld (bc),a		;23ac	02		.
	inc h			;23ad	24		$
l23aeh:
	jr nz,l23d2h		;23ae	20 22		  "
l23b0h:
	jr nz,l23d2h		;23b0	20 20		   
l23b2h:
	jr nz,l23d4h		;23b2	20 20		   
l23b4h:
	jr nz,l23feh		;23b4	20 48		  H
l23b6h:
	jr nz,l23d8h		;23b6	20 20		   
l23b8h:
	jr nz,l23dah		;23b8	20 20		   
l23bah:
	jr nz,l23dch		;23ba	20 20		   
	jr nz,l23deh		;23bc	20 20		   
l23beh:
	jr nz,l23e0h		;23be	20 20		   
l23c0h:
	jr nz,l23ffh		;23c0	20 3d		  =
l23c2h:
	dec a			;23c2	3d		=
	dec a			;23c3	3d		=
l23c4h:
	dec a			;23c4	3d		=
	dec a			;23c5	3d		=
l23c6h:
	dec a			;23c6	3d		=
	dec a			;23c7	3d		=
	dec l			;23c8	2d		-
sub_23c9h:
	dec l			;23c9	2d		-
	dec l			;23ca	2d		-
	dec a			;23cb	3d		=
	dec a			;23cc	3d		=
	dec a			;23cd	3d		=
	dec l			;23ce	2d		-
	dec l			;23cf	2d		-
	dec l			;23d0	2d		-
	dec l			;23d1	2d		-
l23d2h:
	dec a			;23d2	3d		=
	dec a			;23d3	3d		=
l23d4h:
	dec a			;23d4	3d		=
	dec a			;23d5	3d		=
	dec a			;23d6	3d		=
	dec a			;23d7	3d		=
l23d8h:
	dec a			;23d8	3d		=
	dec a			;23d9	3d		=
l23dah:
	dec a			;23da	3d		=
	dec a			;23db	3d		=
l23dch:
	dec a			;23dc	3d		=
	dec a			;23dd	3d		=
l23deh:
	dec a			;23de	3d		=
	dec a			;23df	3d		=
l23e0h:
	dec a			;23e0	3d		=
	dec a			;23e1	3d		=
	dec a			;23e2	3d		=
	ld c,b			;23e3	48		H
l23e4h:
	dec a			;23e4	3d		=
	jr nz,$+34		;23e5	20 20		   
	jr nz,$+34		;23e7	20 20		   
	jr nz,$+34		;23e9	20 20		   
	jr nz,$+34		;23eb	20 20		   
	jr nz,$+74		;23ed	20 48		  H
	jr nz,$+34		;23ef	20 20		   
	jr nz,$+34		;23f1	20 20		   
	jr nz,$+34		;23f3	20 20		   
	jr nz,$+34		;23f5	20 20		   
	jr nz,$+34		;23f7	20 20		   
	jr nz,l2443h		;23f9	20 48		  H
	ld (0c300h),hl		;23fb	22 00 c3	" . .
l23feh:
	ld d,c			;23fe	51		Q
l23ffh:
	inc h			;23ff	24		$
l2400h:
	ld d,(hl)		;2400	56		V
	inc h			;2401	24		$
	jr nz,l2426h		;2402	20 22		  "
	jr nz,l2426h		;2404	20 20		   
	jr nz,l2428h		;2406	20 20		   
	jr nz,l2452h		;2408	20 48		  H
	jr nz,l242ch		;240a	20 20		   
	jr nz,l242eh		;240c	20 20		   
	jr nz,l2430h		;240e	20 20		   
	jr nz,l2432h		;2410	20 20		   
	jr nz,l2490h		;2412	20 7c		  |
	jr nz,l2436h		;2414	20 20		   
	jr nz,l2438h		;2416	20 20		   
	jr nz,l243ah		;2418	20 20		   
	jr nz,l243ch		;241a	20 20		   
	jr nz,l243eh		;241c	20 20		   
	jr nz,l2440h		;241e	20 20		   
	jr nz,l2442h		;2420	20 20		   
l2422h:
	jr nz,$+34		;2422	20 20		   
	jr nz,$+34		;2424	20 20		   
l2426h:
	jr nz,$+34		;2426	20 20		   
l2428h:
	jr nz,$+34		;2428	20 20		   
	jr nz,$+34		;242a	20 20		   
l242ch:
	jr nz,$+34		;242c	20 20		   
l242eh:
	jr nz,$+34		;242e	20 20		   
l2430h:
	jr nz,l2452h		;2430	20 20		   
l2432h:
	jr nz,l2454h		;2432	20 20		   
	jr nz,l2456h		;2434	20 20		   
l2436h:
	jr nz,l2480h		;2436	20 48		  H
l2438h:
	jr nz,l245ah		;2438	20 20		   
l243ah:
	jr nz,l245ch		;243a	20 20		   
l243ch:
	jr nz,l245eh		;243c	20 20		   
l243eh:
	jr nz,l2460h		;243e	20 20		   
l2440h:
	jr nz,l2462h		;2440	20 20		   
l2442h:
	ld c,b			;2442	48		H
l2443h:
	jr nz,$+34		;2443	20 20		   
	jr nz,$+34		;2445	20 20		   
	jr nz,l2469h		;2447	20 20		   
	jr nz,l246bh		;2449	20 20		   
	jr nz,l246dh		;244b	20 20		   
	jr nz,l2497h		;244d	20 48		  H
	ld (0c300h),hl		;244f	22 00 c3	" . .
l2452h:
	and l			;2452	a5		.
	inc h			;2453	24		$
l2454h:
	xor d			;2454	aa		.
	inc h			;2455	24		$
l2456h:
	jr nz,$+36		;2456	20 22		  "
	jr nz,$+34		;2458	20 20		   
l245ah:
	jr nz,l247ch		;245a	20 20		   
l245ch:
	jr nz,l24a6h		;245c	20 48		  H
l245eh:
	jr nz,l2480h		;245e	20 20		   
l2460h:
	jr nz,l2482h		;2460	20 20		   
l2462h:
	jr nz,l2484h		;2462	20 20		   
	jr nz,l2486h		;2464	20 20		   
	jr nz,$+63		;2466	20 3d		  =
	dec a			;2468	3d		=
l2469h:
	dec a			;2469	3d		=
	dec a			;246a	3d		=
l246bh:
	dec a			;246b	3d		=
	dec a			;246c	3d		=
l246dh:
	dec a			;246d	3d		=
	dec a			;246e	3d		=
	dec a			;246f	3d		=
	dec l			;2470	2d		-
	dec l			;2471	2d		-
	dec l			;2472	2d		-
	ld h,020h		;2473	26 20		&  
	jr nz,l2497h		;2475	20 20		   
	jr nz,l2499h		;2477	20 20		   
	jr nz,l24a8h		;2479	20 2d		  -
	dec l			;247b	2d		-
l247ch:
	dec l			;247c	2d		-
	dec l			;247d	2d		-
	dec l			;247e	2d		-
	dec a			;247f	3d		=
l2480h:
	dec a			;2480	3d		=
	dec a			;2481	3d		=
l2482h:
	dec a			;2482	3d		=
	dec a			;2483	3d		=
l2484h:
	dec a			;2484	3d		=
	dec a			;2485	3d		=
l2486h:
	dec a			;2486	3d		=
	dec a			;2487	3d		=
	dec a			;2488	3d		=
	dec a			;2489	3d		=
	dec a			;248a	3d		=
	ld c,b			;248b	48		H
	jr nz,l24aeh		;248c	20 20		   
	jr nz,l24b0h		;248e	20 20		   
l2490h:
	jr nz,l24b2h		;2490	20 20		   
	jr nz,l24b4h		;2492	20 20		   
	jr nz,l24b6h		;2494	20 20		   
	ld c,b			;2496	48		H
l2497h:
	jr nz,$+34		;2497	20 20		   
l2499h:
	jr nz,$+34		;2499	20 20		   
	jr nz,$+34		;249b	20 20		   
	jr nz,$+34		;249d	20 20		   
	jr nz,$+34		;249f	20 20		   
	jr nz,l24ebh		;24a1	20 48		  H
	ld (0c300h),hl		;24a3	22 00 c3	" . .
l24a6h:
	ld sp,hl		;24a6	f9		.
	inc h			;24a7	24		$
l24a8h:
	cp 024h			;24a8	fe 24		. $
	jr nz,l24ceh		;24aa	20 22		  "
	jr nz,l24ceh		;24ac	20 20		   
l24aeh:
	jr nz,l24d0h		;24ae	20 20		   
l24b0h:
	jr nz,l24fah		;24b0	20 48		  H
l24b2h:
	jr nz,l24d4h		;24b2	20 20		   
l24b4h:
	jr nz,l24d6h		;24b4	20 20		   
l24b6h:
	jr nz,l24d8h		;24b6	20 20		   
	jr nz,l24dah		;24b8	20 20		   
	jr nz,l24dch		;24ba	20 20		   
	jr nz,l2506h		;24bc	20 48		  H
	jr nz,l24e0h		;24be	20 20		   
l24c0h:
	jr nz,l24e2h		;24c0	20 20		   
	jr nz,l24e4h		;24c2	20 20		   
	jr nz,l24e6h		;24c4	20 20		   
l24c6h:
	jr nz,l24e8h		;24c6	20 20		   
	jr nz,l24eah		;24c8	20 20		   
	jr nz,$+34		;24ca	20 20		   
	jr nz,$+34		;24cc	20 20		   
l24ceh:
	jr nz,$+34		;24ce	20 20		   
l24d0h:
	jr nz,$+34		;24d0	20 20		   
	jr nz,$+34		;24d2	20 20		   
l24d4h:
	jr nz,$+34		;24d4	20 20		   
l24d6h:
	jr nz,$+34		;24d6	20 20		   
l24d8h:
	jr nz,l24fah		;24d8	20 20		   
l24dah:
	jr nz,l24fch		;24da	20 20		   
l24dch:
	jr nz,l24feh		;24dc	20 20		   
	jr nz,l2528h		;24de	20 48		  H
l24e0h:
	jr nz,l255eh		;24e0	20 7c		  |
l24e2h:
	jr nz,l2504h		;24e2	20 20		   
l24e4h:
	jr nz,l2506h		;24e4	20 20		   
l24e6h:
	jr nz,l2508h		;24e6	20 20		   
l24e8h:
	jr nz,l250ah		;24e8	20 20		   
l24eah:
	ld c,b			;24ea	48		H
l24ebh:
	jr nz,$+34		;24eb	20 20		   
	jr nz,$+34		;24ed	20 20		   
	jr nz,$+34		;24ef	20 20		   
	jr nz,l2513h		;24f1	20 20		   
	jr nz,l2515h		;24f3	20 20		   
l24f5h:
	jr nz,l253fh		;24f5	20 48		  H
	ld (0c300h),hl		;24f7	22 00 c3	" . .
l24fah:
	ld d,c			;24fa	51		Q
	dec h			;24fb	25		%
l24fch:
	ld d,(hl)		;24fc	56		V
	dec h			;24fd	25		%
l24feh:
	jr nz,l2522h		;24fe	20 22		  "
	jr nz,l2522h		;2500	20 20		   
	jr nz,l2524h		;2502	20 20		   
l2504h:
	jr nz,l254eh		;2504	20 48		  H
l2506h:
	jr nz,l2528h		;2506	20 20		   
l2508h:
	jr nz,l252ah		;2508	20 20		   
l250ah:
	jr nz,l252ch		;250a	20 20		   
	jr nz,l252eh		;250c	20 20		   
	jr nz,l2530h		;250e	20 20		   
	jr nz,l255ah		;2510	20 48		  H
l2512h:
	dec a			;2512	3d		=
l2513h:
	dec a			;2513	3d		=
	dec a			;2514	3d		=
l2515h:
	dec a			;2515	3d		=
	dec a			;2516	3d		=
	dec a			;2517	3d		=
l2518h:
	dec a			;2518	3d		=
	dec a			;2519	3d		=
	dec a			;251a	3d		=
	dec l			;251b	2d		-
	dec l			;251c	2d		-
	dec l			;251d	2d		-
	dec l			;251e	2d		-
	dec a			;251f	3d		=
	dec a			;2520	3d		=
	dec a			;2521	3d		=
l2522h:
	dec l			;2522	2d		-
	dec l			;2523	2d		-
l2524h:
	dec l			;2524	2d		-
	dec l			;2525	2d		-
	dec a			;2526	3d		=
	dec a			;2527	3d		=
l2528h:
	dec a			;2528	3d		=
	dec a			;2529	3d		=
l252ah:
	dec a			;252a	3d		=
	dec a			;252b	3d		=
l252ch:
	dec a			;252c	3d		=
	dec a			;252d	3d		=
l252eh:
	dec a			;252e	3d		=
	dec a			;252f	3d		=
l2530h:
	dec a			;2530	3d		=
	dec a			;2531	3d		=
	dec a			;2532	3d		=
l2533h:
	dec a			;2533	3d		=
	dec a			;2534	3d		=
	dec a			;2535	3d		=
	jr nz,l2558h		;2536	20 20		   
	jr nz,l255ah		;2538	20 20		   
	jr nz,l255ch		;253a	20 20		   
	jr nz,l255eh		;253c	20 20		   
	ld c,b			;253e	48		H
l253fh:
	jr nz,$+34		;253f	20 20		   
	dec a			;2541	3d		=
	dec a			;2542	3d		=
	dec a			;2543	3d		=
	dec a			;2544	3d		=
	dec a			;2545	3d		=
l2546h:
	dec a			;2546	3d		=
	dec a			;2547	3d		=
	dec a			;2548	3d		=
	dec a			;2549	3d		=
	dec a			;254a	3d		=
	dec a			;254b	3d		=
	dec a			;254c	3d		=
	dec a			;254d	3d		=
l254eh:
	dec a			;254e	3d		=
	ld (0c300h),hl		;254f	22 00 c3	" . .
	sbc a,c			;2552	99		.
	dec h			;2553	25		%
	sbc a,(hl)		;2554	9e		.
	dec h			;2555	25		%
	jr nz,l257ah		;2556	20 22		  "
l2558h:
	jr nz,l257ah		;2558	20 20		   
l255ah:
	jr nz,l257ch		;255a	20 20		   
l255ch:
	jr nz,l257eh		;255c	20 20		   
l255eh:
	jr nz,l2580h		;255e	20 20		   
	jr nz,l2582h		;2560	20 20		   
	jr nz,l2584h		;2562	20 20		   
	jr nz,l2586h		;2564	20 20		   
	jr nz,l2588h		;2566	20 20		   
	jr nz,l25b2h		;2568	20 48		  H
	jr nz,l258ch		;256a	20 20		   
	jr nz,l258eh		;256c	20 20		   
	jr nz,l2590h		;256e	20 20		   
	jr nz,l2592h		;2570	20 20		   
	jr nz,l2594h		;2572	20 20		   
	jr nz,l2596h		;2574	20 20		   
	jr nz,$+34		;2576	20 20		   
	jr nz,l259ah		;2578	20 20		   
l257ah:
	jr nz,l259ch		;257a	20 20		   
l257ch:
	jr nz,l259eh		;257c	20 20		   
l257eh:
	jr nz,l25a0h		;257e	20 20		   
l2580h:
	jr nz,l25a2h		;2580	20 20		   
l2582h:
	jr nz,l25a4h		;2582	20 20		   
l2584h:
	jr nz,l25a6h		;2584	20 20		   
l2586h:
	jr nz,l25a8h		;2586	20 20		   
l2588h:
	jr nz,l25aah		;2588	20 20		   
	jr nz,l25ach		;258a	20 20		   
l258ch:
	jr nz,l25aeh		;258c	20 20		   
l258eh:
	jr nz,l25b0h		;258e	20 20		   
l2590h:
	jr nz,l25b2h		;2590	20 20		   
l2592h:
	ld h,020h		;2592	26 20		&  
l2594h:
	jr nz,l25b6h		;2594	20 20		   
l2596h:
	ld c,b			;2596	48		H
	ld (0c300h),hl		;2597	22 00 c3	" . .
l259ah:
	pop hl			;259a	e1		.
	dec h			;259b	25		%
l259ch:
	and 025h		;259c	e6 25		. %
l259eh:
	jr nz,l25c2h		;259e	20 22		  "
l25a0h:
	jr nz,l25c2h		;25a0	20 20		   
l25a2h:
	jr nz,l25c4h		;25a2	20 20		   
l25a4h:
	jr nz,l25c6h		;25a4	20 20		   
l25a6h:
	jr nz,l25c8h		;25a6	20 20		   
l25a8h:
	jr nz,l25cah		;25a8	20 20		   
l25aah:
	jr nz,l25cch		;25aa	20 20		   
l25ach:
	jr nz,l25ceh		;25ac	20 20		   
l25aeh:
	jr nz,l25d0h		;25ae	20 20		   
l25b0h:
	jr nz,l25fah		;25b0	20 48		  H
l25b2h:
	jr nz,l25d4h		;25b2	20 20		   
	jr nz,l25d6h		;25b4	20 20		   
l25b6h:
	jr nz,l25d8h		;25b6	20 20		   
	jr nz,l25dah		;25b8	20 20		   
	jr nz,$+34		;25ba	20 20		   
l25bch:
	jr nz,$+34		;25bc	20 20		   
l25beh:
	jr nz,$+34		;25be	20 20		   
	jr nz,l25e2h		;25c0	20 20		   
l25c2h:
	jr nz,$+34		;25c2	20 20		   
l25c4h:
	jr nz,$+34		;25c4	20 20		   
l25c6h:
	jr nz,$+34		;25c6	20 20		   
l25c8h:
	jr nz,l25eah		;25c8	20 20		   
l25cah:
	jr nz,l25ech		;25ca	20 20		   
l25cch:
	jr nz,l25eeh		;25cc	20 20		   
l25ceh:
	jr nz,l25f0h		;25ce	20 20		   
l25d0h:
	jr nz,l25f2h		;25d0	20 20		   
	jr nz,$+34		;25d2	20 20		   
l25d4h:
	jr nz,$+34		;25d4	20 20		   
l25d6h:
	jr nz,$+34		;25d6	20 20		   
l25d8h:
	jr nz,l25fah		;25d8	20 20		   
l25dah:
	ld a,h			;25da	7c		|
	jr nz,$+34		;25db	20 20		   
	jr nz,l2627h		;25dd	20 48		  H
	ld (0c300h),hl		;25df	22 00 c3	" . .
l25e2h:
	add hl,hl		;25e2	29		)
	ld h,02eh		;25e3	26 2e		& .
	ld h,020h		;25e5	26 20		&  
	ld (l3d3dh),hl		;25e7	22 3d 3d	" = =
l25eah:
	dec a			;25ea	3d		=
	dec a			;25eb	3d		=
l25ech:
	dec l			;25ec	2d		-
	dec l			;25ed	2d		-
l25eeh:
	dec l			;25ee	2d		-
	dec a			;25ef	3d		=
l25f0h:
	dec a			;25f0	3d		=
	dec a			;25f1	3d		=
l25f2h:
	dec a			;25f2	3d		=
	jr nz,$+34		;25f3	20 20		   
	jr nz,$+34		;25f5	20 20		   
	jr nz,$+34		;25f7	20 20		   
	ld c,b			;25f9	48		H
l25fah:
	jr nz,l261ch		;25fa	20 20		   
	jr nz,l261eh		;25fc	20 20		   
	jr nz,l2620h		;25fe	20 20		   
	jr nz,l2622h		;2600	20 20		   
	jr nz,$+34		;2602	20 20		   
	jr nz,$+34		;2604	20 20		   
	jr nz,$+34		;2606	20 20		   
	jr nz,l262ah		;2608	20 20		   
l260ah:
	jr nz,$+34		;260a	20 20		   
	jr nz,$+34		;260c	20 20		   
	jr nz,$+34		;260e	20 20		   
	jr nz,l2632h		;2610	20 20		   
	jr nz,l2634h		;2612	20 20		   
	jr nz,l2636h		;2614	20 20		   
	jr nz,l2638h		;2616	20 20		   
	jr nz,l263ah		;2618	20 20		   
	jr nz,$+34		;261a	20 20		   
l261ch:
	jr nz,$+34		;261c	20 20		   
l261eh:
	jr nz,l2640h		;261e	20 20		   
l2620h:
	jr nz,l2642h		;2620	20 20		   
l2622h:
	ld a,h			;2622	7c		|
	jr nz,l2645h		;2623	20 20		   
	jr nz,l266fh		;2625	20 48		  H
l2627h:
	ld (0c300h),hl		;2627	22 00 c3	" . .
l262ah:
	ld (hl),c		;262a	71		q
	ld h,076h		;262b	26 76		& v
	ld h,020h		;262d	26 20		&  
	ld (l207bh+1),hl	;262f	22 7c 20	" |  
l2632h:
	jr nz,l2654h		;2632	20 20		   
l2634h:
	jr nz,l2656h		;2634	20 20		   
l2636h:
	jr nz,l2658h		;2636	20 20		   
l2638h:
	jr nz,l265ah		;2638	20 20		   
l263ah:
	ld a,h			;263a	7c		|
	jr nz,l265dh		;263b	20 20		   
	jr nz,l265fh		;263d	20 20		   
	dec a			;263f	3d		=
l2640h:
	dec a			;2640	3d		=
	dec a			;2641	3d		=
l2642h:
	dec a			;2642	3d		=
	dec a			;2643	3d		=
	dec a			;2644	3d		=
l2645h:
	dec a			;2645	3d		=
	dec a			;2646	3d		=
	dec a			;2647	3d		=
	dec a			;2648	3d		=
	dec a			;2649	3d		=
	dec a			;264a	3d		=
	dec a			;264b	3d		=
	dec a			;264c	3d		=
	dec a			;264d	3d		=
	dec a			;264e	3d		=
l264fh:
	dec l			;264f	2d		-
	dec l			;2650	2d		-
	dec l			;2651	2d		-
	dec a			;2652	3d		=
	dec a			;2653	3d		=
l2654h:
	dec a			;2654	3d		=
	dec l			;2655	2d		-
l2656h:
	dec l			;2656	2d		-
	dec l			;2657	2d		-
l2658h:
	dec a			;2658	3d		=
	dec a			;2659	3d		=
l265ah:
	dec a			;265a	3d		=
	dec a			;265b	3d		=
	dec a			;265c	3d		=
l265dh:
	dec a			;265d	3d		=
	dec a			;265e	3d		=
l265fh:
	dec a			;265f	3d		=
l2660h:
	dec a			;2660	3d		=
	dec a			;2661	3d		=
	dec a			;2662	3d		=
	dec a			;2663	3d		=
	dec a			;2664	3d		=
	dec a			;2665	3d		=
	dec a			;2666	3d		=
	dec a			;2667	3d		=
	dec a			;2668	3d		=
	dec a			;2669	3d		=
	dec a			;266a	3d		=
	jr nz,l268dh		;266b	20 20		   
	jr nz,sub_26b7h		;266d	20 48		  H
l266fh:
	ld (0c300h),hl		;266f	22 00 c3	" . .
	rst 0			;2672	c7		.
	ld h,0cch		;2673	26 cc		& .
	ld h,020h		;2675	26 20		&  
	ld (l207bh+1),hl	;2677	22 7c 20	" |  
	jr nz,$+34		;267a	20 20		   
	dec a			;267c	3d		=
	dec a			;267d	3d		=
	dec a			;267e	3d		=
	jr nz,l26a1h		;267f	20 20		   
	jr nz,l26ffh		;2681	20 7c		  |
	jr nz,l26a5h		;2683	20 20		   
	jr nz,l26a7h		;2685	20 20		   
	jr nz,l26a9h		;2687	20 20		   
	jr nz,l26abh		;2689	20 20		   
	jr nz,l26adh		;268b	20 20		   
l268dh:
	jr nz,l26afh		;268d	20 20		   
	jr nz,l26b1h		;268f	20 20		   
	jr nz,sub_26b3h		;2691	20 20		   
	jr nz,l26b5h		;2693	20 20		   
	jr nz,sub_26b7h		;2695	20 20		   
	jr nz,l26b9h		;2697	20 20		   
	jr nz,l26bbh		;2699	20 20		   
	jr nz,l26bdh		;269b	20 20		   
	jr nz,l26bfh		;269d	20 20		   
	jr nz,$+34		;269f	20 20		   
l26a1h:
	jr nz,$+34		;26a1	20 20		   
	jr nz,l26c5h		;26a3	20 20		   
l26a5h:
	jr nz,$+34		;26a5	20 20		   
l26a7h:
	jr nz,l26c9h		;26a7	20 20		   
l26a9h:
	jr nz,l26cbh		;26a9	20 20		   
l26abh:
	jr nz,$+34		;26ab	20 20		   
l26adh:
	jr nz,l26cfh		;26ad	20 20		   
l26afh:
	jr nz,l26d1h		;26af	20 20		   
l26b1h:
	jr nz,l26d3h		;26b1	20 20		   
sub_26b3h:
	jr nz,$+34		;26b3	20 20		   
l26b5h:
	jr nz,l26ffh		;26b5	20 48		  H
sub_26b7h:
	jr nz,l26d9h		;26b7	20 20		   
l26b9h:
	jr nz,l26dbh		;26b9	20 20		   
l26bbh:
	jr nz,l26ddh		;26bb	20 20		   
l26bdh:
	jr nz,l26dfh		;26bd	20 20		   
l26bfh:
	ld c,b			;26bf	48		H
	jr nz,$+34		;26c0	20 20		   
	jr nz,$+34		;26c2	20 20		   
	ld h,a			;26c4	67		g
l26c5h:
	ld (0c300h),hl		;26c5	22 00 c3	" . .
l26c8h:
	rra			;26c8	1f		.
l26c9h:
	daa			;26c9	27		'
	inc h			;26ca	24		$
l26cbh:
	daa			;26cb	27		'
	jr nz,$+36		;26cc	20 22		  "
	ld a,h			;26ce	7c		|
l26cfh:
	jr nz,l26f1h		;26cf	20 20		   
l26d1h:
	jr nz,l26f3h		;26d1	20 20		   
l26d3h:
	inc h			;26d3	24		$
	jr nz,$+34		;26d4	20 20		   
	jr nz,$+34		;26d6	20 20		   
	ld a,h			;26d8	7c		|
l26d9h:
	jr nz,l26fbh		;26d9	20 20		   
l26dbh:
	jr nz,l26fdh		;26db	20 20		   
l26ddh:
	jr nz,l26ffh		;26dd	20 20		   
l26dfh:
	jr nz,l2701h		;26df	20 20		   
	jr nz,l2703h		;26e1	20 20		   
	jr nz,l2705h		;26e3	20 20		   
	jr nz,l2707h		;26e5	20 20		   
	jr nz,l2709h		;26e7	20 20		   
	jr nz,l270bh		;26e9	20 20		   
	jr nz,l270dh		;26eb	20 20		   
	jr nz,l270fh		;26ed	20 20		   
	jr nz,l2711h		;26ef	20 20		   
l26f1h:
	jr nz,l2713h		;26f1	20 20		   
l26f3h:
	jr nz,l2715h		;26f3	20 20		   
	jr nz,l2717h		;26f5	20 20		   
	jr nz,l2719h		;26f7	20 20		   
	jr nz,l271bh		;26f9	20 20		   
l26fbh:
	jr nz,l271dh		;26fb	20 20		   
l26fdh:
	jr nz,$+34		;26fd	20 20		   
l26ffh:
	jr nz,l2721h		;26ff	20 20		   
l2701h:
	jr nz,l2723h		;2701	20 20		   
l2703h:
	jr nz,$+34		;2703	20 20		   
l2705h:
	jr nz,l2727h		;2705	20 20		   
l2707h:
	jr nz,$+34		;2707	20 20		   
l2709h:
	jr nz,l272bh		;2709	20 20		   
l270bh:
	jr nz,$+74		;270b	20 48		  H
l270dh:
	jr nz,l272fh		;270d	20 20		   
l270fh:
	jr nz,$+34		;270f	20 20		   
l2711h:
	jr nz,l2750h		;2711	20 3d		  =
l2713h:
	dec a			;2713	3d		=
	dec a			;2714	3d		=
l2715h:
	ld c,b			;2715	48		H
	dec a			;2716	3d		=
l2717h:
	dec a			;2717	3d		=
	dec a			;2718	3d		=
l2719h:
	dec a			;2719	3d		=
	dec a			;271a	3d		=
l271bh:
	dec a			;271b	3d		=
l271ch:
	dec a			;271c	3d		=
l271dh:
	ld (0c300h),hl		;271d	22 00 c3	" . .
	ld (hl),b		;2720	70		p
l2721h:
	daa			;2721	27		'
	ld (hl),l		;2722	75		u
l2723h:
	daa			;2723	27		'
	jr nz,l2748h		;2724	20 22		  "
	ld a,h			;2726	7c		|
l2727h:
	ld hl,(l2020h)		;2727	2a 20 20	*    
	inc h			;272a	24		$
l272bh:
	inc h			;272b	24		$
	inc h			;272c	24		$
	jr nz,$+34		;272d	20 20		   
l272fh:
	ld hl,(l207bh+1)	;272f	2a 7c 20	* |  
	jr nz,l2754h		;2732	20 20		   
	ld hl,(l2020h)		;2734	2a 20 20	*    
	jr nz,$+34		;2737	20 20		   
	jr nz,$+34		;2739	20 20		   
	jr nz,$+34		;273b	20 20		   
	jr nz,$+34		;273d	20 20		   
sub_273fh:
	jr nz,$+34		;273f	20 20		   
	jr nz,$+34		;2741	20 20		   
	jr nz,l2765h		;2743	20 20		   
	ld hl,(l2020h)		;2745	2a 20 20	*    
l2748h:
	jr nz,$+34		;2748	20 20		   
	jr nz,$+34		;274a	20 20		   
	jr nz,$+44		;274c	20 2a		  *
	jr nz,$+34		;274e	20 20		   
l2750h:
	jr nz,l2772h		;2750	20 20		   
	jr nz,$+34		;2752	20 20		   
l2754h:
	jr nz,l2776h		;2754	20 20		   
	jr nz,$+34		;2756	20 20		   
	jr nz,l277ah		;2758	20 20		   
	jr nz,l277ch		;275a	20 20		   
	jr nz,l277eh		;275c	20 20		   
	jr nz,l2780h		;275e	20 20		   
	jr nz,l2782h		;2760	20 20		   
	jr nz,l278eh		;2762	20 2a		  *
	ld c,b			;2764	48		H
l2765h:
	jr nz,l2787h		;2765	20 20		   
	jr nz,l2789h		;2767	20 20		   
	jr nz,l278bh		;2769	20 20		   
	jr nz,l2797h		;276b	20 2a		  *
	ld c,b			;276d	48		H
	ld (0c300h),hl		;276e	22 00 c3	" . .
	ret z			;2771	c8		.
l2772h:
	daa			;2772	27		'
	call sub_2027h		;2773	cd 27 20	. '  
l2776h:
	ld (l3d3dh),hl		;2776	22 3d 3d	" = =
	dec a			;2779	3d		=
l277ah:
	dec a			;277a	3d		=
	dec a			;277b	3d		=
l277ch:
	dec a			;277c	3d		=
	dec a			;277d	3d		=
l277eh:
	dec a			;277e	3d		=
	dec a			;277f	3d		=
l2780h:
	dec a			;2780	3d		=
	dec a			;2781	3d		=
l2782h:
	dec a			;2782	3d		=
	dec a			;2783	3d		=
l2784h:
	dec a			;2784	3d		=
l2785h:
	dec a			;2785	3d		=
	dec a			;2786	3d		=
l2787h:
	dec a			;2787	3d		=
	dec a			;2788	3d		=
l2789h:
	dec a			;2789	3d		=
	dec a			;278a	3d		=
l278bh:
	dec a			;278b	3d		=
	dec a			;278c	3d		=
	dec a			;278d	3d		=
l278eh:
	dec a			;278e	3d		=
	dec a			;278f	3d		=
	dec a			;2790	3d		=
	dec a			;2791	3d		=
sub_2792h:
	dec a			;2792	3d		=
	dec a			;2793	3d		=
	dec a			;2794	3d		=
	dec a			;2795	3d		=
	dec a			;2796	3d		=
l2797h:
	dec a			;2797	3d		=
	dec a			;2798	3d		=
	dec a			;2799	3d		=
	dec a			;279a	3d		=
	dec a			;279b	3d		=
	dec a			;279c	3d		=
	dec a			;279d	3d		=
	dec a			;279e	3d		=
	dec a			;279f	3d		=
	dec a			;27a0	3d		=
	dec a			;27a1	3d		=
	dec a			;27a2	3d		=
	dec a			;27a3	3d		=
	dec a			;27a4	3d		=
	dec a			;27a5	3d		=
	dec a			;27a6	3d		=
	dec a			;27a7	3d		=
	dec a			;27a8	3d		=
	dec a			;27a9	3d		=
	dec a			;27aa	3d		=
	dec a			;27ab	3d		=
	dec a			;27ac	3d		=
	dec a			;27ad	3d		=
	dec a			;27ae	3d		=
l27afh:
	dec a			;27af	3d		=
	dec a			;27b0	3d		=
	dec a			;27b1	3d		=
	dec a			;27b2	3d		=
	dec a			;27b3	3d		=
	dec a			;27b4	3d		=
	dec a			;27b5	3d		=
	dec a			;27b6	3d		=
	dec a			;27b7	3d		=
	dec a			;27b8	3d		=
	dec a			;27b9	3d		=
	dec a			;27ba	3d		=
	dec a			;27bb	3d		=
	dec a			;27bc	3d		=
l27bdh:
	dec a			;27bd	3d		=
	dec a			;27be	3d		=
	dec a			;27bf	3d		=
	dec a			;27c0	3d		=
	dec a			;27c1	3d		=
	dec a			;27c2	3d		=
	dec a			;27c3	3d		=
	dec a			;27c4	3d		=
	dec a			;27c5	3d		=
	ld (0c300h),hl		;27c6	22 00 c3	" . .
	pop de			;27c9	d1		.
	daa			;27ca	27		'
	sub 027h		;27cb	d6 27		. '
	jr nz,$+53		;27cd	20 33		  3
	dec (hl)		;27cf	35		5
	nop			;27d0	00		.
	jp l27ddh		;27d1	c3 dd 27	. . '
	jp po,sub_2027h		;27d4	e2 27 20	. '  
	scf			;27d7	37		7
l27d8h:
	dec (hl)		;27d8	35		5
	jr nc,l2807h		;27d9	30 2c		0 ,
	scf			;27db	37		7
	nop			;27dc	00		.
l27ddh:
	jp 027f0h		;27dd	c3 f0 27	. . '
	push af			;27e0	f5		.
	daa			;27e1	27		'
	jr nz,$+36		;27e2	20 22		  "
	jr nz,$+34		;27e4	20 20		   
	jr nz,$+34		;27e6	20 20		   
	jr nz,$+34		;27e8	20 20		   
	jr nz,$+34		;27ea	20 20		   
	jr nz,$+38		;27ec	20 24		  $
	ld (0c300h),hl		;27ee	22 00 c3	" . .
	scf			;27f1	37		7
	jr z,$+62		;27f2	28 3c		( <
	jr z,$+34		;27f4	28 20		(  
	ld (l2020h),hl		;27f6	22 20 20	"    
	jr nz,l281bh		;27f9	20 20		   
	jr nz,l281dh		;27fb	20 20		   
	jr nz,l281fh		;27fd	20 20		   
	jr nz,$+74		;27ff	20 48		  H
	jr nz,l2823h		;2801	20 20		   
	jr nz,l2825h		;2803	20 20		   
	jr nz,l2827h		;2805	20 20		   
l2807h:
	jr nz,l2829h		;2807	20 20		   
	jr nz,l282bh		;2809	20 20		   
	jr nz,l282dh		;280b	20 20		   
	jr nz,l282fh		;280d	20 20		   
	jr nz,l2831h		;280f	20 20		   
	jr nz,l2833h		;2811	20 20		   
	jr nz,l2835h		;2813	20 20		   
sub_2815h:
	jr nz,$+34		;2815	20 20		   
	jr nz,l2839h		;2817	20 20		   
	jr nz,l283bh		;2819	20 20		   
l281bh:
	jr nz,l283dh		;281b	20 20		   
l281dh:
	jr nz,$+34		;281d	20 20		   
l281fh:
	jr nz,$+34		;281f	20 20		   
	jr nz,$+34		;2821	20 20		   
l2823h:
	jr nz,$+34		;2823	20 20		   
l2825h:
	jr nz,$+34		;2825	20 20		   
l2827h:
	jr nz,$+34		;2827	20 20		   
l2829h:
	jr nz,l284bh		;2829	20 20		   
l282bh:
	jr nz,$+34		;282b	20 20		   
l282dh:
	jr nz,$+34		;282d	20 20		   
l282fh:
	jr nz,$+34		;282f	20 20		   
l2831h:
	jr nz,l2853h		;2831	20 20		   
l2833h:
	jr nz,l288bh		;2833	20 56		  V
l2835h:
	ld (0c300h),hl		;2835	22 00 c3	" . .
	ld c,d			;2838	4a		J
l2839h:
	jr z,$+81		;2839	28 4f		( O
l283bh:
	jr z,l285dh		;283b	28 20		(  
l283dh:
	ld (l2020h),hl		;283d	22 20 20	"    
l2840h:
	jr nz,l2862h		;2840	20 20		   
	jr nz,l2864h		;2842	20 20		   
	jr nz,l2866h		;2844	20 20		   
sub_2846h:
	jr nz,$+74		;2846	20 48		  H
	ld (0c300h),hl		;2848	22 00 c3	" . .
l284bh:
	sbc a,l			;284b	9d		.
	jr z,$-92		;284c	28 a2		( .
	jr z,l2870h		;284e	28 20		(  
	ld (l2020h),hl		;2850	22 20 20	"    
l2853h:
	jr nz,l2875h		;2853	20 20		   
	jr nz,l2877h		;2855	20 20		   
	jr nz,l2879h		;2857	20 20		   
	jr nz,l28a3h		;2859	20 48		  H
	ld c,b			;285b	48		H
	ld c,b			;285c	48		H
l285dh:
	ld c,b			;285d	48		H
	ld c,b			;285e	48		H
	ld c,b			;285f	48		H
	ld c,b			;2860	48		H
	ld c,b			;2861	48		H
l2862h:
	ld c,b			;2862	48		H
	ld c,b			;2863	48		H
l2864h:
	ld c,b			;2864	48		H
	ld c,b			;2865	48		H
l2866h:
	ld c,b			;2866	48		H
	jr nz,l2889h		;2867	20 20		   
	jr nz,l288bh		;2869	20 20		   
	jr nz,l289bh		;286b	20 2e		  .
	ld c,b			;286d	48		H
	ld c,b			;286e	48		H
	ld c,b			;286f	48		H
l2870h:
	ld c,b			;2870	48		H
	ld c,b			;2871	48		H
	ld c,b			;2872	48		H
	ld c,b			;2873	48		H
	ld c,b			;2874	48		H
l2875h:
	ld c,b			;2875	48		H
	ld c,b			;2876	48		H
l2877h:
	ld c,b			;2877	48		H
	ld c,b			;2878	48		H
l2879h:
	ld c,b			;2879	48		H
	ld c,b			;287a	48		H
	jr nz,$+34		;287b	20 20		   
	jr nz,l289fh		;287d	20 20		   
	jr nz,l28a1h		;287f	20 20		   
	jr nz,l28a3h		;2881	20 20		   
	jr nz,$+34		;2883	20 20		   
	jr nz,$+34		;2885	20 20		   
	jr nz,$+34		;2887	20 20		   
l2889h:
	jr nz,$+34		;2889	20 20		   
l288bh:
	jr nz,$+34		;288b	20 20		   
	jr nz,$+34		;288d	20 20		   
	jr nz,$+34		;288f	20 20		   
	jr nz,$+34		;2891	20 20		   
	jr nz,$+34		;2893	20 20		   
	ld c,b			;2895	48		H
	jr nz,l28b8h		;2896	20 20		   
	jr nz,l28bah		;2898	20 20		   
	ld h,a			;289a	67		g
l289bh:
	ld (0c300h),hl		;289b	22 00 c3	" . .
	push af			;289e	f5		.
l289fh:
	jr z,l289bh		;289f	28 fa		( .
l28a1h:
	jr z,$+34		;28a1	28 20		(  
l28a3h:
	ld (l2020h),hl		;28a3	22 20 20	"    
	jr nz,l28c8h		;28a6	20 20		   
	jr nz,l28cah		;28a8	20 20		   
	jr nz,l28cch		;28aa	20 20		   
	jr nz,l28d4h		;28ac	20 26		  &
	jr nz,l28d0h		;28ae	20 20		   
	jr nz,l28d2h		;28b0	20 20		   
	jr nz,l28d4h		;28b2	20 20		   
	jr nz,l28d6h		;28b4	20 20		   
	jr nz,l28d8h		;28b6	20 20		   
l28b8h:
	jr nz,l28dah		;28b8	20 20		   
l28bah:
	jr nz,l28dch		;28ba	20 20		   
	jr nz,l28deh		;28bc	20 20		   
	jr nz,l28e0h		;28be	20 20		   
	jr nz,l2918h		;28c0	20 56		  V
	jr nz,l28e4h		;28c2	20 20		   
	jr nz,l28e6h		;28c4	20 20		   
	jr nz,l28e8h		;28c6	20 20		   
l28c8h:
	jr nz,l28eah		;28c8	20 20		   
l28cah:
	jr nz,l28ech		;28ca	20 20		   
l28cch:
	jr nz,l2916h		;28cc	20 48		  H
	jr nz,l28f0h		;28ce	20 20		   
l28d0h:
	jr nz,l28f2h		;28d0	20 20		   
l28d2h:
	jr nz,$+34		;28d2	20 20		   
l28d4h:
	jr nz,l28f6h		;28d4	20 20		   
l28d6h:
	jr nz,l28f8h		;28d6	20 20		   
l28d8h:
	jr nz,l28fah		;28d8	20 20		   
l28dah:
	jr nz,l28fch		;28da	20 20		   
l28dch:
	jr nz,l28feh		;28dc	20 20		   
l28deh:
	jr nz,l2900h		;28de	20 20		   
l28e0h:
	jr nz,l2902h		;28e0	20 20		   
l28e2h:
	jr nz,l2904h		;28e2	20 20		   
l28e4h:
	jr nz,l2906h		;28e4	20 20		   
l28e6h:
	dec a			;28e6	3d		=
	dec a			;28e7	3d		=
l28e8h:
	ld c,b			;28e8	48		H
	dec a			;28e9	3d		=
l28eah:
	dec a			;28ea	3d		=
	dec a			;28eb	3d		=
l28ech:
	dec a			;28ec	3d		=
	dec a			;28ed	3d		=
	dec a			;28ee	3d		=
	dec a			;28ef	3d		=
l28f0h:
	dec a			;28f0	3d		=
	dec a			;28f1	3d		=
l28f2h:
	dec a			;28f2	3d		=
	ld (0c300h),hl		;28f3	22 00 c3	" . .
l28f6h:
	ld b,e			;28f6	43		C
	add hl,hl		;28f7	29		)
l28f8h:
	ld c,b			;28f8	48		H
	add hl,hl		;28f9	29		)
l28fah:
	jr nz,l291eh		;28fa	20 22		  "
l28fch:
	jr nz,l291eh		;28fc	20 20		   
l28feh:
	jr nz,l2920h		;28fe	20 20		   
l2900h:
	jr nz,l2922h		;2900	20 20		   
l2902h:
	jr nz,l2924h		;2902	20 20		   
l2904h:
	jr nz,l2926h		;2904	20 20		   
l2906h:
	jr nz,l2928h		;2906	20 20		   
	jr nz,l292ah		;2908	20 20		   
	jr nz,l292ch		;290a	20 20		   
	jr nz,l292eh		;290c	20 20		   
	jr nz,l2930h		;290e	20 20		   
	jr nz,l2932h		;2910	20 20		   
	jr nz,l2934h		;2912	20 20		   
	jr nz,l2936h		;2914	20 20		   
l2916h:
	jr nz,l2938h		;2916	20 20		   
l2918h:
	jr nz,l293ah		;2918	20 20		   
	jr nz,l293ch		;291a	20 20		   
	jr nz,l293eh		;291c	20 20		   
l291eh:
	jr nz,l2940h		;291e	20 20		   
l2920h:
	jr nz,$+34		;2920	20 20		   
l2922h:
	jr nz,l2944h		;2922	20 20		   
l2924h:
	jr nz,l296eh		;2924	20 48		  H
l2926h:
	jr nz,l2948h		;2926	20 20		   
l2928h:
	jr nz,l294ah		;2928	20 20		   
l292ah:
	jr nz,l294ch		;292a	20 20		   
l292ch:
	jr nz,l294eh		;292c	20 20		   
l292eh:
	jr nz,l2950h		;292e	20 20		   
l2930h:
	jr nz,l2952h		;2930	20 20		   
l2932h:
	jr nz,l2954h		;2932	20 20		   
l2934h:
	jr nz,l2956h		;2934	20 20		   
l2936h:
	jr nz,l2958h		;2936	20 20		   
l2938h:
	jr nz,l295ah		;2938	20 20		   
l293ah:
	jr nz,l295ch		;293a	20 20		   
l293ch:
	jr nz,l295eh		;293c	20 20		   
l293eh:
	jr nz,l2960h		;293e	20 20		   
l2940h:
	ld c,b			;2940	48		H
	ld (0c300h),hl		;2941	22 00 c3	" . .
l2944h:
	sub c			;2944	91		.
	add hl,hl		;2945	29		)
	sub (hl)		;2946	96		.
	add hl,hl		;2947	29		)
l2948h:
	jr nz,l296ch		;2948	20 22		  "
l294ah:
	jr nz,l296ch		;294a	20 20		   
l294ch:
	jr nz,$+74		;294c	20 48		  H
l294eh:
	jr nz,l2970h		;294e	20 20		   
l2950h:
	jr nz,l2972h		;2950	20 20		   
l2952h:
	jr nz,l2974h		;2952	20 20		   
l2954h:
	jr nz,l2976h		;2954	20 20		   
l2956h:
	jr nz,l2978h		;2956	20 20		   
l2958h:
	jr nz,l297ah		;2958	20 20		   
l295ah:
	jr nz,l297ch		;295a	20 20		   
l295ch:
	jr nz,l297eh		;295c	20 20		   
l295eh:
	jr nz,l2980h		;295e	20 20		   
l2960h:
	jr nz,l2982h		;2960	20 20		   
	jr nz,l2984h		;2962	20 20		   
	jr nz,l2986h		;2964	20 20		   
	jr nz,l2988h		;2966	20 20		   
	jr nz,l298ah		;2968	20 20		   
	jr nz,l298ch		;296a	20 20		   
l296ch:
	jr nz,l298eh		;296c	20 20		   
l296eh:
	jr nz,$+34		;296e	20 20		   
l2970h:
	jr nz,l2992h		;2970	20 20		   
l2972h:
	jr nz,l29bch		;2972	20 48		  H
l2974h:
	jr nz,$+34		;2974	20 20		   
l2976h:
	jr nz,$+34		;2976	20 20		   
l2978h:
	jr nz,l299ah		;2978	20 20		   
l297ah:
	jr nz,l299ch		;297a	20 20		   
l297ch:
	ld l,020h		;297c	2e 20		.  
l297eh:
	jr nz,l29a0h		;297e	20 20		   
l2980h:
	jr nz,l29a2h		;2980	20 20		   
l2982h:
	jr nz,l29a4h		;2982	20 20		   
l2984h:
	jr nz,l29a6h		;2984	20 20		   
l2986h:
	jr nz,l29a8h		;2986	20 20		   
l2988h:
	jr nz,l29aah		;2988	20 20		   
l298ah:
	jr nz,l29ach		;298a	20 20		   
l298ch:
	jr nz,l29aeh		;298c	20 20		   
l298eh:
	ld c,b			;298e	48		H
	ld (0c300h),hl		;298f	22 00 c3	" . .
l2992h:
	rst 18h			;2992	df		.
	add hl,hl		;2993	29		)
	call po,02029h		;2994	e4 29 20	. )  
	ld (l3d3dh),hl		;2997	22 3d 3d	" = =
l299ah:
	dec a			;299a	3d		=
	ld c,b			;299b	48		H
l299ch:
	dec a			;299c	3d		=
	dec a			;299d	3d		=
	dec a			;299e	3d		=
	dec a			;299f	3d		=
l29a0h:
	dec a			;29a0	3d		=
	dec a			;29a1	3d		=
l29a2h:
	dec a			;29a2	3d		=
	dec a			;29a3	3d		=
l29a4h:
	dec a			;29a4	3d		=
	dec a			;29a5	3d		=
l29a6h:
	dec a			;29a6	3d		=
	dec a			;29a7	3d		=
l29a8h:
	dec a			;29a8	3d		=
	dec a			;29a9	3d		=
l29aah:
	dec l			;29aa	2d		-
	dec l			;29ab	2d		-
l29ach:
	dec l			;29ac	2d		-
	dec l			;29ad	2d		-
l29aeh:
	dec l			;29ae	2d		-
	dec l			;29af	2d		-
	dec l			;29b0	2d		-
	dec l			;29b1	2d		-
	dec l			;29b2	2d		-
	dec l			;29b3	2d		-
	dec l			;29b4	2d		-
	dec a			;29b5	3d		=
	dec a			;29b6	3d		=
	dec a			;29b7	3d		=
l29b8h:
	dec a			;29b8	3d		=
	dec a			;29b9	3d		=
	dec a			;29ba	3d		=
	dec a			;29bb	3d		=
l29bch:
	dec a			;29bc	3d		=
	dec a			;29bd	3d		=
	dec a			;29be	3d		=
	dec a			;29bf	3d		=
	dec a			;29c0	3d		=
	ld c,b			;29c1	48		H
	dec a			;29c2	3d		=
	dec a			;29c3	3d		=
l29c4h:
	dec a			;29c4	3d		=
	dec a			;29c5	3d		=
	jr nz,l29e8h		;29c6	20 20		   
	jr nz,l29eah		;29c8	20 20		   
	jr nz,l29ech		;29ca	20 20		   
	jr nz,l29eeh		;29cc	20 20		   
	jr nz,l29f0h		;29ce	20 20		   
	jr nz,l29f2h		;29d0	20 20		   
	jr nz,l29f4h		;29d2	20 20		   
	jr nz,l29f6h		;29d4	20 20		   
	jr nz,l29f8h		;29d6	20 20		   
	jr nz,l29fah		;29d8	20 20		   
	jr nz,l29fch		;29da	20 20		   
	ld c,b			;29dc	48		H
	ld (0c300h),hl		;29dd	22 00 c3	" . .
	dec l			;29e0	2d		-
	ld hl,(l2a32h)		;29e1	2a 32 2a	* 2 *
	jr nz,l2a08h		;29e4	20 22		  "
	jr nz,l2a08h		;29e6	20 20		   
l29e8h:
	jr nz,l2a32h		;29e8	20 48		  H
l29eah:
	jr nz,l2a0ch		;29ea	20 20		   
l29ech:
	jr nz,sub_2a0eh		;29ec	20 20		   
l29eeh:
	jr nz,l2a10h		;29ee	20 20		   
l29f0h:
	jr nz,l2a12h		;29f0	20 20		   
l29f2h:
	jr nz,l2a14h		;29f2	20 20		   
l29f4h:
	jr nz,l2a16h		;29f4	20 20		   
l29f6h:
	jr nz,l2a18h		;29f6	20 20		   
l29f8h:
	jr nz,l2a1ah		;29f8	20 20		   
l29fah:
	jr nz,l2a1ch		;29fa	20 20		   
l29fch:
	jr nz,l2a1eh		;29fc	20 20		   
	jr nz,l2a20h		;29fe	20 20		   
	jr nz,$+34		;2a00	20 20		   
	jr nz,$+34		;2a02	20 20		   
	jr nz,$+34		;2a04	20 20		   
	jr nz,$+34		;2a06	20 20		   
l2a08h:
	jr nz,$+34		;2a08	20 20		   
	jr nz,$+34		;2a0a	20 20		   
l2a0ch:
	jr nz,l2a2eh		;2a0c	20 20		   
sub_2a0eh:
	jr nz,$+34		;2a0e	20 20		   
l2a10h:
	jr nz,l2a32h		;2a10	20 20		   
l2a12h:
	jr nz,l2a34h		;2a12	20 20		   
l2a14h:
	jr nz,l2a36h		;2a14	20 20		   
l2a16h:
	jr nz,l2a38h		;2a16	20 20		   
l2a18h:
	jr nz,l2a3ah		;2a18	20 20		   
l2a1ah:
	jr nz,l2a3ch		;2a1a	20 20		   
l2a1ch:
	jr nz,l2a3eh		;2a1c	20 20		   
l2a1eh:
	jr nz,l2a40h		;2a1e	20 20		   
l2a20h:
	ld c,b			;2a20	48		H
	jr nz,$+34		;2a21	20 20		   
	jr nz,$+34		;2a23	20 20		   
	jr nz,$+34		;2a25	20 20		   
	jr nz,$+34		;2a27	20 20		   
l2a29h:
	jr nz,l2a73h		;2a29	20 48		  H
	ld (0c300h),hl		;2a2b	22 00 c3	" . .
l2a2eh:
	ld a,a			;2a2e	7f		.
	ld hl,(02a84h)		;2a2f	2a 84 2a	* . *
l2a32h:
	jr nz,l2a56h		;2a32	20 22		  "
l2a34h:
	jr nz,l2a56h		;2a34	20 20		   
l2a36h:
	jr nz,l2a80h		;2a36	20 48		  H
l2a38h:
	jr nz,l2a5ah		;2a38	20 20		   
l2a3ah:
	jr nz,l2a5ch		;2a3a	20 20		   
l2a3ch:
	jr nz,l2a5eh		;2a3c	20 20		   
l2a3eh:
	jr nz,l2a60h		;2a3e	20 20		   
l2a40h:
	jr nz,l2a62h		;2a40	20 20		   
	jr nz,l2a64h		;2a42	20 20		   
	jr nz,l2a66h		;2a44	20 20		   
l2a46h:
	jr nz,l2a68h		;2a46	20 20		   
	jr nz,l2a6ah		;2a48	20 20		   
	jr nz,l2a6ch		;2a4a	20 20		   
	jr nz,l2a6eh		;2a4c	20 20		   
	jr nz,l2a70h		;2a4e	20 20		   
	jr nz,l2a72h		;2a50	20 20		   
	jr nz,l2a74h		;2a52	20 20		   
	jr nz,l2a76h		;2a54	20 20		   
l2a56h:
	jr nz,l2a78h		;2a56	20 20		   
	jr nz,l2a7ah		;2a58	20 20		   
l2a5ah:
	jr nz,l2a7ch		;2a5a	20 20		   
l2a5ch:
	jr nz,$+34		;2a5c	20 20		   
l2a5eh:
	jr nz,l2a80h		;2a5e	20 20		   
l2a60h:
	jr nz,$+34		;2a60	20 20		   
l2a62h:
	jr nz,$+34		;2a62	20 20		   
l2a64h:
	jr nz,l2a86h		;2a64	20 20		   
l2a66h:
	jr nz,l2a88h		;2a66	20 20		   
l2a68h:
	jr nz,$+63		;2a68	20 3d		  =
l2a6ah:
	dec a			;2a6a	3d		=
	dec a			;2a6b	3d		=
l2a6ch:
	dec a			;2a6c	3d		=
	dec a			;2a6d	3d		=
l2a6eh:
	ld c,b			;2a6e	48		H
	dec a			;2a6f	3d		=
l2a70h:
	dec a			;2a70	3d		=
	dec a			;2a71	3d		=
l2a72h:
	dec a			;2a72	3d		=
l2a73h:
	dec a			;2a73	3d		=
l2a74h:
	dec a			;2a74	3d		=
	dec a			;2a75	3d		=
l2a76h:
	dec a			;2a76	3d		=
	dec a			;2a77	3d		=
l2a78h:
	dec a			;2a78	3d		=
	dec a			;2a79	3d		=
l2a7ah:
	dec a			;2a7a	3d		=
	dec a			;2a7b	3d		=
l2a7ch:
	dec a			;2a7c	3d		=
	ld (0c300h),hl		;2a7d	22 00 c3	" . .
l2a80h:
	jp 0c82ah		;2a80	c3 2a c8	. * .
	ld hl,(02220h)		;2a83	2a 20 22	*   "
l2a86h:
	jr nz,l2aa8h		;2a86	20 20		   
l2a88h:
	jr nz,l2ad2h		;2a88	20 48		  H
	jr nz,l2aach		;2a8a	20 20		   
	jr nz,l2aaeh		;2a8c	20 20		   
	jr nz,l2ab0h		;2a8e	20 20		   
	jr nz,l2ab2h		;2a90	20 20		   
	jr nz,l2ab4h		;2a92	20 20		   
sub_2a94h:
	jr nz,l2ab6h		;2a94	20 20		   
	jr nz,l2ab8h		;2a96	20 20		   
	jr nz,l2abah		;2a98	20 20		   
	jr nz,l2abch		;2a9a	20 20		   
sub_2a9ch:
	jr nz,l2abeh		;2a9c	20 20		   
	jr nz,l2ac0h		;2a9e	20 20		   
	jr nz,$+34		;2aa0	20 20		   
	jr nz,l2ac4h		;2aa2	20 20		   
	jr nz,l2ac6h		;2aa4	20 20		   
	jr nz,l2ac8h		;2aa6	20 20		   
l2aa8h:
	jr nz,l2acah		;2aa8	20 20		   
	jr nz,l2acch		;2aaa	20 20		   
l2aach:
	jr nz,l2aceh		;2aac	20 20		   
l2aaeh:
	jr nz,l2af8h		;2aae	20 48		  H
l2ab0h:
	jr nz,l2ad2h		;2ab0	20 20		   
l2ab2h:
	jr nz,l2ad4h		;2ab2	20 20		   
l2ab4h:
	jr nz,l2ad6h		;2ab4	20 20		   
l2ab6h:
	jr nz,l2ad8h		;2ab6	20 20		   
l2ab8h:
	jr nz,l2adah		;2ab8	20 20		   
l2abah:
	jr nz,l2adch		;2aba	20 20		   
l2abch:
	jr nz,l2adeh		;2abc	20 20		   
l2abeh:
	jr nz,l2ae0h		;2abe	20 20		   
l2ac0h:
	ld c,b			;2ac0	48		H
	ld (0c300h),hl		;2ac1	22 00 c3	" . .
l2ac4h:
	rlca			;2ac4	07		.
	dec hl			;2ac5	2b		+
l2ac6h:
	inc c			;2ac6	0c		.
	dec hl			;2ac7	2b		+
l2ac8h:
	jr nz,$+36		;2ac8	20 22		  "
l2acah:
	jr nz,$+34		;2aca	20 20		   
l2acch:
	jr nz,l2b16h		;2acc	20 48		  H
l2aceh:
	jr nz,l2af0h		;2ace	20 20		   
	jr nz,l2af2h		;2ad0	20 20		   
l2ad2h:
	jr nz,l2af4h		;2ad2	20 20		   
l2ad4h:
	jr nz,l2af6h		;2ad4	20 20		   
l2ad6h:
	jr nz,l2af8h		;2ad6	20 20		   
l2ad8h:
	jr nz,l2afah		;2ad8	20 20		   
l2adah:
	jr nz,l2afch		;2ada	20 20		   
l2adch:
	ld h,02eh		;2adc	26 2e		& .
l2adeh:
	ld l,05eh		;2ade	2e 5e		. ^
l2ae0h:
	ld e,(hl)		;2ae0	5e		^
	ld e,(hl)		;2ae1	5e		^
	ld l,02eh		;2ae2	2e 2e		. .
	ld l,02eh		;2ae4	2e 2e		. .
	ld l,05eh		;2ae6	2e 5e		. ^
	ld l,02eh		;2ae8	2e 2e		. .
	ld e,(hl)		;2aea	5e		^
	jr nz,$+48		;2aeb	20 2e		  .
	jr nz,l2b4dh		;2aed	20 5e		  ^
	ld e,(hl)		;2aef	5e		^
l2af0h:
	jr nz,l2b12h		;2af0	20 20		   
l2af2h:
	jr nz,l2b3ch		;2af2	20 48		  H
l2af4h:
	dec a			;2af4	3d		=
	dec a			;2af5	3d		=
l2af6h:
	dec l			;2af6	2d		-
	dec l			;2af7	2d		-
l2af8h:
	dec l			;2af8	2d		-
	dec l			;2af9	2d		-
l2afah:
	dec l			;2afa	2d		-
	dec l			;2afb	2d		-
l2afch:
	dec l			;2afc	2d		-
	dec l			;2afd	2d		-
	dec l			;2afe	2d		-
	jr nz,l2b21h		;2aff	20 20		   
	jr nz,l2b23h		;2b01	20 20		   
	jr nz,l2b4dh		;2b03	20 48		  H
	ld (0c300h),hl		;2b05	22 00 c3	" . .
	ld e,c			;2b08	59		Y
	dec hl			;2b09	2b		+
	ld e,(hl)		;2b0a	5e		^
l2b0bh:
	dec hl			;2b0b	2b		+
	jr nz,l2b30h		;2b0c	20 22		  "
	jr nz,l2b30h		;2b0e	20 20		   
	jr nz,l2b5ah		;2b10	20 48		  H
l2b12h:
	jr nz,l2b34h		;2b12	20 20		   
l2b14h:
	jr nz,l2b36h		;2b14	20 20		   
l2b16h:
	jr nz,l2b38h		;2b16	20 20		   
	jr nz,l2b3ah		;2b18	20 20		   
	jr nz,$+63		;2b1a	20 3d		  =
	dec a			;2b1c	3d		=
	dec a			;2b1d	3d		=
	dec a			;2b1e	3d		=
	dec a			;2b1f	3d		=
	dec a			;2b20	3d		=
l2b21h:
	dec a			;2b21	3d		=
	dec a			;2b22	3d		=
l2b23h:
	dec a			;2b23	3d		=
	dec a			;2b24	3d		=
	dec a			;2b25	3d		=
	dec a			;2b26	3d		=
	dec a			;2b27	3d		=
	dec a			;2b28	3d		=
	dec a			;2b29	3d		=
	dec a			;2b2a	3d		=
	dec a			;2b2b	3d		=
l2b2ch:
	dec a			;2b2c	3d		=
	dec a			;2b2d	3d		=
	dec a			;2b2e	3d		=
	dec a			;2b2f	3d		=
l2b30h:
	dec a			;2b30	3d		=
	dec a			;2b31	3d		=
	dec a			;2b32	3d		=
	dec a			;2b33	3d		=
l2b34h:
	dec a			;2b34	3d		=
	dec a			;2b35	3d		=
l2b36h:
	dec a			;2b36	3d		=
	ld c,b			;2b37	48		H
l2b38h:
	jr nz,l2b5ah		;2b38	20 20		   
l2b3ah:
	jr nz,l2b5ch		;2b3a	20 20		   
l2b3ch:
	ld h,020h		;2b3c	26 20		&  
	jr nz,l2b60h		;2b3e	20 20		   
	jr nz,l2b62h		;2b40	20 20		   
	jr nz,l2b64h		;2b42	20 20		   
	jr nz,l2b66h		;2b44	20 20		   
	jr nz,l2b68h		;2b46	20 20		   
l2b48h:
	ld c,b			;2b48	48		H
	jr nz,$+34		;2b49	20 20		   
	jr nz,$+34		;2b4b	20 20		   
l2b4dh:
	jr nz,l2b6fh		;2b4d	20 20		   
	jr nz,$+34		;2b4f	20 20		   
	jr nz,$+34		;2b51	20 20		   
	jr nz,$+34		;2b53	20 20		   
	jr nz,l2b9fh		;2b55	20 48		  H
	ld (0c300h),hl		;2b57	22 00 c3	" . .
l2b5ah:
	or c			;2b5a	b1		.
	dec hl			;2b5b	2b		+
l2b5ch:
	or (hl)			;2b5c	b6		.
	dec hl			;2b5d	2b		+
	jr nz,l2b82h		;2b5e	20 22		  "
l2b60h:
	jr nz,l2b82h		;2b60	20 20		   
l2b62h:
	jr nz,l2bach		;2b62	20 48		  H
l2b64h:
	jr nz,l2b86h		;2b64	20 20		   
l2b66h:
	jr nz,l2b88h		;2b66	20 20		   
l2b68h:
	jr nz,l2b8ah		;2b68	20 20		   
l2b6ah:
	jr nz,l2b8ch		;2b6a	20 20		   
	jr nz,l2babh		;2b6c	20 3d		  =
	dec a			;2b6e	3d		=
l2b6fh:
	dec a			;2b6f	3d		=
	jr nz,l2b92h		;2b70	20 20		   
	jr nz,l2b94h		;2b72	20 20		   
	jr nz,l2b96h		;2b74	20 20		   
	dec a			;2b76	3d		=
	dec a			;2b77	3d		=
	dec a			;2b78	3d		=
	jr nz,l2b9bh		;2b79	20 20		   
	jr nz,l2b9dh		;2b7b	20 20		   
	jr nz,l2b9fh		;2b7d	20 20		   
	dec a			;2b7f	3d		=
	dec a			;2b80	3d		=
	dec a			;2b81	3d		=
l2b82h:
	jr nz,l2ba4h		;2b82	20 20		   
	jr nz,l2ba6h		;2b84	20 20		   
l2b86h:
	jr nz,l2ba8h		;2b86	20 20		   
l2b88h:
	jr nz,l2bd2h		;2b88	20 48		  H
l2b8ah:
	jr nz,l2bach		;2b8a	20 20		   
l2b8ch:
	jr nz,l2baeh		;2b8c	20 20		   
	dec l			;2b8e	2d		-
sub_2b8fh:
	dec l			;2b8f	2d		-
	dec l			;2b90	2d		-
	dec l			;2b91	2d		-
l2b92h:
	dec l			;2b92	2d		-
	dec l			;2b93	2d		-
l2b94h:
	dec l			;2b94	2d		-
	dec l			;2b95	2d		-
l2b96h:
	dec l			;2b96	2d		-
	dec a			;2b97	3d		=
	dec a			;2b98	3d		=
	dec a			;2b99	3d		=
	dec a			;2b9a	3d		=
l2b9bh:
	dec a			;2b9b	3d		=
	dec a			;2b9c	3d		=
l2b9dh:
	dec a			;2b9d	3d		=
	dec a			;2b9e	3d		=
l2b9fh:
	dec a			;2b9f	3d		=
	dec a			;2ba0	3d		=
	dec a			;2ba1	3d		=
	dec a			;2ba2	3d		=
	dec a			;2ba3	3d		=
l2ba4h:
	dec a			;2ba4	3d		=
	dec a			;2ba5	3d		=
l2ba6h:
	dec a			;2ba6	3d		=
	dec a			;2ba7	3d		=
l2ba8h:
	ld c,b			;2ba8	48		H
	dec a			;2ba9	3d		=
	dec a			;2baa	3d		=
l2babh:
	dec a			;2bab	3d		=
l2bach:
	dec a			;2bac	3d		=
	dec a			;2bad	3d		=
l2baeh:
	dec a			;2bae	3d		=
	ld (0c300h),hl		;2baf	22 00 c3	" . .
	inc bc			;2bb2	03		.
	inc l			;2bb3	2c		,
l2bb4h:
	ex af,af'		;2bb4	08		.
	inc l			;2bb5	2c		,
	jr nz,l2bdah		;2bb6	20 22		  "
	jr nz,l2bdah		;2bb8	20 20		   
	jr nz,l2c04h		;2bba	20 48		  H
	jr nz,l2bdeh		;2bbc	20 20		   
	jr nz,l2be0h		;2bbe	20 20		   
	jr nz,l2be2h		;2bc0	20 20		   
	jr nz,l2be4h		;2bc2	20 20		   
	jr nz,l2be6h		;2bc4	20 20		   
	jr nz,l2be8h		;2bc6	20 20		   
	jr nz,l2beah		;2bc8	20 20		   
	jr nz,l2bech		;2bca	20 20		   
	jr nz,l2beeh		;2bcc	20 20		   
	jr nz,l2bf0h		;2bce	20 20		   
	jr nz,l2bf2h		;2bd0	20 20		   
l2bd2h:
	jr nz,l2bf4h		;2bd2	20 20		   
	jr nz,l2bf6h		;2bd4	20 20		   
	jr nz,l2bf8h		;2bd6	20 20		   
	jr nz,l2bfah		;2bd8	20 20		   
l2bdah:
	jr nz,l2bfch		;2bda	20 20		   
l2bdch:
	jr nz,l2bfeh		;2bdc	20 20		   
l2bdeh:
	jr nz,l2c00h		;2bde	20 20		   
l2be0h:
	jr nz,l2c2ah		;2be0	20 48		  H
l2be2h:
	jr nz,l2c04h		;2be2	20 20		   
l2be4h:
	jr nz,l2c06h		;2be4	20 20		   
l2be6h:
	jr nz,l2c08h		;2be6	20 20		   
l2be8h:
	jr nz,l2c0ah		;2be8	20 20		   
l2beah:
	jr nz,l2c0ch		;2bea	20 20		   
l2bech:
	jr nz,l2c0eh		;2bec	20 20		   
l2beeh:
	jr nz,l2c10h		;2bee	20 20		   
l2bf0h:
	jr nz,l2c12h		;2bf0	20 20		   
l2bf2h:
	jr nz,l2c14h		;2bf2	20 20		   
l2bf4h:
	jr nz,l2c16h		;2bf4	20 20		   
l2bf6h:
	jr nz,l2c18h		;2bf6	20 20		   
l2bf8h:
	jr nz,l2c1ah		;2bf8	20 20		   
l2bfah:
	jr nz,l2c1ch		;2bfa	20 20		   
l2bfch:
	jr nz,l2c1eh		;2bfc	20 20		   
l2bfeh:
	jr nz,l2c20h		;2bfe	20 20		   
l2c00h:
	ld c,b			;2c00	48		H
	ld (0c300h),hl		;2c01	22 00 c3	" . .
l2c04h:
	ld d,l			;2c04	55		U
	inc l			;2c05	2c		,
l2c06h:
	ld e,d			;2c06	5a		Z
	inc l			;2c07	2c		,
l2c08h:
	jr nz,l2c2ch		;2c08	20 22		  "
l2c0ah:
	jr nz,l2c2ch		;2c0a	20 20		   
l2c0ch:
	jr nz,l2c56h		;2c0c	20 48		  H
l2c0eh:
	jr nz,l2c30h		;2c0e	20 20		   
l2c10h:
	jr nz,l2c32h		;2c10	20 20		   
l2c12h:
	jr nz,l2c34h		;2c12	20 20		   
l2c14h:
	jr nz,l2c36h		;2c14	20 20		   
l2c16h:
	jr nz,l2c38h		;2c16	20 20		   
l2c18h:
	jr nz,l2c3ah		;2c18	20 20		   
l2c1ah:
	jr nz,l2c3ch		;2c1a	20 20		   
l2c1ch:
	jr nz,l2c3eh		;2c1c	20 20		   
l2c1eh:
	jr nz,l2c40h		;2c1e	20 20		   
l2c20h:
	jr nz,l2c42h		;2c20	20 20		   
	jr nz,l2c44h		;2c22	20 20		   
	jr nz,l2c46h		;2c24	20 20		   
	jr nz,l2c48h		;2c26	20 20		   
	ld h,020h		;2c28	26 20		&  
l2c2ah:
	jr nz,l2c4ch		;2c2a	20 20		   
l2c2ch:
	jr nz,l2c4eh		;2c2c	20 20		   
	jr nz,l2c50h		;2c2e	20 20		   
l2c30h:
	jr nz,l2c52h		;2c30	20 20		   
l2c32h:
	jr nz,l2c7ch		;2c32	20 48		  H
l2c34h:
	jr nz,l2c56h		;2c34	20 20		   
l2c36h:
	jr nz,l2c58h		;2c36	20 20		   
l2c38h:
	jr nz,l2c5ah		;2c38	20 20		   
l2c3ah:
	jr nz,l2c5ch		;2c3a	20 20		   
l2c3ch:
	jr nz,l2c5eh		;2c3c	20 20		   
l2c3eh:
	ld h,020h		;2c3e	26 20		&  
l2c40h:
	jr nz,l2c62h		;2c40	20 20		   
l2c42h:
	jr nz,l2c64h		;2c42	20 20		   
l2c44h:
	jr nz,l2c66h		;2c44	20 20		   
l2c46h:
	jr nz,l2c68h		;2c46	20 20		   
l2c48h:
	jr nz,l2c6ah		;2c48	20 20		   
	jr nz,l2c6ch		;2c4a	20 20		   
l2c4ch:
	jr nz,l2c6eh		;2c4c	20 20		   
l2c4eh:
	jr nz,l2c70h		;2c4e	20 20		   
l2c50h:
	jr nz,sub_2c72h		;2c50	20 20		   
l2c52h:
	ld c,b			;2c52	48		H
	ld (0c300h),hl		;2c53	22 00 c3	" . .
l2c56h:
	and a			;2c56	a7		.
	inc l			;2c57	2c		,
l2c58h:
	xor h			;2c58	ac		.
	inc l			;2c59	2c		,
l2c5ah:
	jr nz,l2c7eh		;2c5a	20 22		  "
l2c5ch:
	jr nz,l2c7eh		;2c5c	20 20		   
l2c5eh:
	jr nz,l2c9dh		;2c5e	20 3d		  =
	dec a			;2c60	3d		=
	dec a			;2c61	3d		=
l2c62h:
	dec a			;2c62	3d		=
	dec a			;2c63	3d		=
l2c64h:
	dec a			;2c64	3d		=
	dec a			;2c65	3d		=
l2c66h:
	dec a			;2c66	3d		=
	dec a			;2c67	3d		=
l2c68h:
	dec a			;2c68	3d		=
	dec l			;2c69	2d		-
l2c6ah:
	dec l			;2c6a	2d		-
	dec l			;2c6b	2d		-
l2c6ch:
	dec l			;2c6c	2d		-
	dec l			;2c6d	2d		-
l2c6eh:
	dec l			;2c6e	2d		-
	dec l			;2c6f	2d		-
l2c70h:
	dec l			;2c70	2d		-
	dec l			;2c71	2d		-
sub_2c72h:
	dec l			;2c72	2d		-
	dec l			;2c73	2d		-
	dec l			;2c74	2d		-
	dec l			;2c75	2d		-
l2c76h:
	dec l			;2c76	2d		-
	dec l			;2c77	2d		-
	dec l			;2c78	2d		-
	dec l			;2c79	2d		-
	dec l			;2c7a	2d		-
	dec l			;2c7b	2d		-
l2c7ch:
	dec l			;2c7c	2d		-
	dec l			;2c7d	2d		-
l2c7eh:
	dec l			;2c7e	2d		-
	dec l			;2c7f	2d		-
	dec l			;2c80	2d		-
	dec l			;2c81	2d		-
	dec a			;2c82	3d		=
	dec a			;2c83	3d		=
	dec a			;2c84	3d		=
	dec a			;2c85	3d		=
	dec a			;2c86	3d		=
	dec a			;2c87	3d		=
	dec a			;2c88	3d		=
	dec l			;2c89	2d		-
	dec l			;2c8a	2d		-
	dec l			;2c8b	2d		-
	dec l			;2c8c	2d		-
	dec l			;2c8d	2d		-
	dec l			;2c8e	2d		-
	dec l			;2c8f	2d		-
	dec l			;2c90	2d		-
	dec l			;2c91	2d		-
	dec l			;2c92	2d		-
	dec a			;2c93	3d		=
	dec a			;2c94	3d		=
	dec a			;2c95	3d		=
	dec a			;2c96	3d		=
l2c97h:
	dec a			;2c97	3d		=
	dec a			;2c98	3d		=
	dec a			;2c99	3d		=
	dec a			;2c9a	3d		=
	dec a			;2c9b	3d		=
	dec a			;2c9c	3d		=
l2c9dh:
	dec a			;2c9d	3d		=
	dec a			;2c9e	3d		=
	dec a			;2c9f	3d		=
	dec a			;2ca0	3d		=
	dec a			;2ca1	3d		=
	dec a			;2ca2	3d		=
	dec a			;2ca3	3d		=
	dec a			;2ca4	3d		=
	ld (0c300h),hl		;2ca5	22 00 c3	" . .
	or b			;2ca8	b0		.
	inc l			;2ca9	2c		,
l2caah:
	or l			;2caa	b5		.
	inc l			;2cab	2c		,
	jr nz,l2cd0h		;2cac	20 22		  "
	ld (0c300h),hl		;2cae	22 00 c3	" . .
	ex af,af'		;2cb1	08		.
	dec l			;2cb2	2d		-
	dec c			;2cb3	0d		.
	dec l			;2cb4	2d		-
	jr nz,l2cd9h		;2cb5	20 22		  "
	ld e,(hl)		;2cb7	5e		^
	ld e,(hl)		;2cb8	5e		^
	ld e,(hl)		;2cb9	5e		^
	ld hl,(l2020h)		;2cba	2a 20 20	*    
	jr nz,$+34		;2cbd	20 20		   
	jr nz,$+34		;2cbf	20 20		   
	jr nz,$+34		;2cc1	20 20		   
	jr nz,l2d23h		;2cc3	20 5e		  ^
	ld e,(hl)		;2cc5	5e		^
	ld e,(hl)		;2cc6	5e		^
	ld e,(hl)		;2cc7	5e		^
	ld e,(hl)		;2cc8	5e		^
	ld e,(hl)		;2cc9	5e		^
	ld e,(hl)		;2cca	5e		^
	ld e,(hl)		;2ccb	5e		^
	ld e,(hl)		;2ccc	5e		^
	ld e,(hl)		;2ccd	5e		^
l2cceh:
	ld e,(hl)		;2cce	5e		^
	ld e,(hl)		;2ccf	5e		^
l2cd0h:
	ld e,(hl)		;2cd0	5e		^
	ld e,(hl)		;2cd1	5e		^
	ld e,(hl)		;2cd2	5e		^
	ld e,(hl)		;2cd3	5e		^
	ld e,(hl)		;2cd4	5e		^
	ld e,(hl)		;2cd5	5e		^
	ld e,(hl)		;2cd6	5e		^
	ld e,(hl)		;2cd7	5e		^
	ld e,(hl)		;2cd8	5e		^
l2cd9h:
	ld e,(hl)		;2cd9	5e		^
	ld e,(hl)		;2cda	5e		^
	ld e,(hl)		;2cdb	5e		^
	ld e,(hl)		;2cdc	5e		^
	ld hl,(l2020h)		;2cdd	2a 20 20	*    
	jr nz,l2d02h		;2ce0	20 20		   
	jr nz,$+44		;2ce2	20 2a		  *
	ld e,(hl)		;2ce4	5e		^
	ld e,(hl)		;2ce5	5e		^
	ld e,(hl)		;2ce6	5e		^
	ld e,(hl)		;2ce7	5e		^
	ld e,(hl)		;2ce8	5e		^
	ld e,(hl)		;2ce9	5e		^
	ld e,(hl)		;2cea	5e		^
	ld e,(hl)		;2ceb	5e		^
	ld e,(hl)		;2cec	5e		^
	ld e,(hl)		;2ced	5e		^
	ld hl,(l2020h)		;2cee	2a 20 20	*    
	jr nz,l2d13h		;2cf1	20 20		   
	jr nz,l2d15h		;2cf3	20 20		   
	jr nz,l2d17h		;2cf5	20 20		   
	jr nz,l2d19h		;2cf7	20 20		   
	jr nz,l2d1bh		;2cf9	20 20		   
	jr nz,l2d1dh		;2cfb	20 20		   
	jr nz,l2d1fh		;2cfd	20 20		   
	ld hl,(l5e5eh)		;2cff	2a 5e 5e	* ^ ^
l2d02h:
	ld e,(hl)		;2d02	5e		^
	ld e,(hl)		;2d03	5e		^
	ld e,(hl)		;2d04	5e		^
	ld e,(hl)		;2d05	5e		^
	ld (0c300h),hl		;2d06	22 00 c3	" . .
	ld h,b			;2d09	60		`
	dec l			;2d0a	2d		-
	ld h,l			;2d0b	65		e
	dec l			;2d0c	2d		-
	jr nz,l2d31h		;2d0d	20 22		  "
	dec a			;2d0f	3d		=
	dec a			;2d10	3d		=
	dec a			;2d11	3d		=
	dec a			;2d12	3d		=
l2d13h:
	dec a			;2d13	3d		=
	dec a			;2d14	3d		=
l2d15h:
	dec a			;2d15	3d		=
	dec a			;2d16	3d		=
l2d17h:
	dec a			;2d17	3d		=
	dec a			;2d18	3d		=
l2d19h:
	dec a			;2d19	3d		=
	dec a			;2d1a	3d		=
l2d1bh:
	dec a			;2d1b	3d		=
	dec a			;2d1c	3d		=
l2d1dh:
	dec a			;2d1d	3d		=
	dec a			;2d1e	3d		=
l2d1fh:
	dec a			;2d1f	3d		=
	dec a			;2d20	3d		=
	dec a			;2d21	3d		=
	dec a			;2d22	3d		=
l2d23h:
	dec a			;2d23	3d		=
	dec a			;2d24	3d		=
	dec a			;2d25	3d		=
	dec a			;2d26	3d		=
	dec a			;2d27	3d		=
l2d28h:
	dec a			;2d28	3d		=
	dec a			;2d29	3d		=
	dec a			;2d2a	3d		=
	dec a			;2d2b	3d		=
	dec a			;2d2c	3d		=
	dec a			;2d2d	3d		=
	dec a			;2d2e	3d		=
	dec a			;2d2f	3d		=
	dec a			;2d30	3d		=
l2d31h:
	dec a			;2d31	3d		=
	dec a			;2d32	3d		=
l2d33h:
	dec a			;2d33	3d		=
	dec a			;2d34	3d		=
	dec a			;2d35	3d		=
	dec a			;2d36	3d		=
	dec a			;2d37	3d		=
	dec a			;2d38	3d		=
	dec a			;2d39	3d		=
	dec a			;2d3a	3d		=
	dec a			;2d3b	3d		=
	dec a			;2d3c	3d		=
l2d3dh:
	dec a			;2d3d	3d		=
	dec a			;2d3e	3d		=
	dec a			;2d3f	3d		=
	dec a			;2d40	3d		=
	dec a			;2d41	3d		=
	dec a			;2d42	3d		=
	dec a			;2d43	3d		=
	dec a			;2d44	3d		=
	dec a			;2d45	3d		=
	dec a			;2d46	3d		=
	dec a			;2d47	3d		=
	dec a			;2d48	3d		=
	dec a			;2d49	3d		=
	dec a			;2d4a	3d		=
	dec a			;2d4b	3d		=
	dec a			;2d4c	3d		=
	dec a			;2d4d	3d		=
	dec a			;2d4e	3d		=
	dec a			;2d4f	3d		=
	dec a			;2d50	3d		=
	dec a			;2d51	3d		=
	dec a			;2d52	3d		=
	dec a			;2d53	3d		=
	dec a			;2d54	3d		=
	dec a			;2d55	3d		=
	dec a			;2d56	3d		=
	dec a			;2d57	3d		=
	dec a			;2d58	3d		=
	dec a			;2d59	3d		=
	dec a			;2d5a	3d		=
	dec a			;2d5b	3d		=
	dec a			;2d5c	3d		=
	dec a			;2d5d	3d		=
	ld (0c300h),hl		;2d5e	22 00 c3	" . .
	ld l,c			;2d61	69		i
	dec l			;2d62	2d		-
	ld l,(hl)		;2d63	6e		n
	dec l			;2d64	2d		-
	jr nz,l2d9ah		;2d65	20 33		  3
	scf			;2d67	37		7
	nop			;2d68	00		.
	jp l2d75h		;2d69	c3 75 2d	. u -
	ld a,d			;2d6c	7a		z
	dec l			;2d6d	2d		-
l2d6eh:
	jr nz,l2da7h		;2d6e	20 37		  7
	jr nc,$+50		;2d70	30 30		0 0
	inc l			;2d72	2c		,
	ld (hl),000h		;2d73	36 00		6 .
l2d75h:
	jp 02dbeh		;2d75	c3 be 2d	. . -
	jp 0202dh		;2d78	c3 2d 20	. -  
	ld (l2020h),hl		;2d7b	22 20 20	"    
l2d7eh:
	jr nz,l2da0h		;2d7e	20 20		   
	jr nz,$+34		;2d80	20 20		   
	jr nz,$+34		;2d82	20 20		   
	jr nz,$+34		;2d84	20 20		   
	jr nz,$+34		;2d86	20 20		   
	jr nz,$+34		;2d88	20 20		   
	jr nz,$+34		;2d8a	20 20		   
	jr nz,$+34		;2d8c	20 20		   
	jr nz,$+34		;2d8e	20 20		   
	jr nz,$+34		;2d90	20 20		   
	jr nz,$+34		;2d92	20 20		   
	jr nz,$+34		;2d94	20 20		   
	jr nz,$+34		;2d96	20 20		   
	jr nz,l2de2h		;2d98	20 48		  H
l2d9ah:
	ld c,b			;2d9a	48		H
	ld c,b			;2d9b	48		H
	ld c,b			;2d9c	48		H
	ld c,b			;2d9d	48		H
	ld c,b			;2d9e	48		H
	ld c,b			;2d9f	48		H
l2da0h:
	ld c,b			;2da0	48		H
	jr nz,l2dc3h		;2da1	20 20		   
	jr nz,l2dc5h		;2da3	20 20		   
	jr nz,l2dc7h		;2da5	20 20		   
l2da7h:
	jr nz,l2dc9h		;2da7	20 20		   
	jr nz,l2dcbh		;2da9	20 20		   
	jr nz,l2dcdh		;2dab	20 20		   
	jr nz,l2dcfh		;2dad	20 20		   
	jr nz,l2dd1h		;2daf	20 20		   
	jr nz,l2dd3h		;2db1	20 20		   
	jr nz,l2dd5h		;2db3	20 20		   
	jr nz,l2dd7h		;2db5	20 20		   
	jr nz,l2dd9h		;2db7	20 20		   
	jr nz,l2ddbh		;2db9	20 20		   
	ld d,(hl)		;2dbb	56		V
	ld (0c300h),hl		;2dbc	22 00 c3	" . .
	xor 02dh		;2dbf	ee 2d		. -
	di			;2dc1	f3		.
	dec l			;2dc2	2d		-
l2dc3h:
	jr nz,l2de7h		;2dc3	20 22		  "
l2dc5h:
	jr nz,l2de7h		;2dc5	20 20		   
l2dc7h:
	jr nz,l2de9h		;2dc7	20 20		   
l2dc9h:
	jr nz,l2debh		;2dc9	20 20		   
l2dcbh:
	jr nz,$+34		;2dcb	20 20		   
l2dcdh:
	jr nz,l2defh		;2dcd	20 20		   
l2dcfh:
	jr nz,l2df1h		;2dcf	20 20		   
l2dd1h:
	jr nz,$+34		;2dd1	20 20		   
l2dd3h:
	jr nz,$+34		;2dd3	20 20		   
l2dd5h:
	jr nz,l2df7h		;2dd5	20 20		   
l2dd7h:
	jr nz,l2df9h		;2dd7	20 20		   
l2dd9h:
	jr nz,l2dfbh		;2dd9	20 20		   
l2ddbh:
	jr nz,l2dfdh		;2ddb	20 20		   
	jr nz,l2dffh		;2ddd	20 20		   
	jr nz,l2e29h		;2ddf	20 48		  H
	ld c,b			;2de1	48		H
l2de2h:
	ld c,b			;2de2	48		H
	jr nz,l2e05h		;2de3	20 20		   
	jr nz,l2e07h		;2de5	20 20		   
l2de7h:
	jr nz,$+34		;2de7	20 20		   
l2de9h:
	ld c,b			;2de9	48		H
	ld c,b			;2dea	48		H
l2debh:
	ld c,b			;2deb	48		H
	ld (0c300h),hl		;2dec	22 00 c3	" . .
l2defh:
	jr z,$+48		;2def	28 2e		( .
l2df1h:
	dec l			;2df1	2d		-
	ld l,020h		;2df2	2e 20		.  
	ld (l2020h),hl		;2df4	22 20 20	"    
l2df7h:
	jr nz,l2e41h		;2df7	20 48		  H
l2df9h:
	jr nz,$+34		;2df9	20 20		   
l2dfbh:
	jr nz,$+34		;2dfb	20 20		   
l2dfdh:
	jr nz,$+34		;2dfd	20 20		   
l2dffh:
	jr nz,$+34		;2dff	20 20		   
	jr nz,$+34		;2e01	20 20		   
	jr nz,l2e25h		;2e03	20 20		   
l2e05h:
	jr nz,$+42		;2e05	20 28		  (
l2e07h:
	add hl,hl		;2e07	29		)
sub_2e08h:
	jr nz,l2e2ah		;2e08	20 20		   
	jr nz,l2e2ch		;2e0a	20 20		   
	jr nz,l2e2eh		;2e0c	20 20		   
	jr nz,$+34		;2e0e	20 20		   
	jr nz,$+34		;2e10	20 20		   
	jr nz,l2e34h		;2e12	20 20		   
	jr nz,l2e36h		;2e14	20 20		   
	jr nz,l2e38h		;2e16	20 20		   
	jr nz,l2e3ah		;2e18	20 20		   
l2e1ah:
	jr nz,l2e3ch		;2e1a	20 20		   
	jr nz,l2e3eh		;2e1c	20 20		   
	jr nz,l2e40h		;2e1e	20 20		   
	jr nz,l2e42h		;2e20	20 20		   
	jr nz,l2e44h		;2e22	20 20		   
	ld e,e			;2e24	5b		[
l2e25h:
	ld e,l			;2e25	5d		]
	ld (0c300h),hl		;2e26	22 00 c3	" . .
l2e29h:
	halt			;2e29	76		v
l2e2ah:
	ld l,07bh		;2e2a	2e 7b		. {
l2e2ch:
	ld l,020h		;2e2c	2e 20		.  
l2e2eh:
	ld (l2020h),hl		;2e2e	22 20 20	"    
	jr nz,l2e7bh		;2e31	20 48		  H
	dec a			;2e33	3d		=
l2e34h:
	dec a			;2e34	3d		=
	dec a			;2e35	3d		=
l2e36h:
	dec a			;2e36	3d		=
	dec a			;2e37	3d		=
l2e38h:
	dec a			;2e38	3d		=
	dec a			;2e39	3d		=
l2e3ah:
	dec a			;2e3a	3d		=
	dec a			;2e3b	3d		=
l2e3ch:
	dec a			;2e3c	3d		=
	dec a			;2e3d	3d		=
l2e3eh:
	dec a			;2e3e	3d		=
	dec a			;2e3f	3d		=
l2e40h:
	dec a			;2e40	3d		=
l2e41h:
	dec a			;2e41	3d		=
l2e42h:
	jr nz,l2e64h		;2e42	20 20		   
l2e44h:
	jr nz,l2e66h		;2e44	20 20		   
	jr nz,l2e68h		;2e46	20 20		   
	jr nz,$+34		;2e48	20 20		   
l2e4ah:
	jr nz,$+34		;2e4a	20 20		   
	jr nz,$+34		;2e4c	20 20		   
	jr nz,$+34		;2e4e	20 20		   
	jr nz,$+34		;2e50	20 20		   
	jr nz,l2e74h		;2e52	20 20		   
	jr nz,l2e93h		;2e54	20 3d		  =
	dec a			;2e56	3d		=
	dec a			;2e57	3d		=
	dec a			;2e58	3d		=
	dec a			;2e59	3d		=
	dec a			;2e5a	3d		=
	dec a			;2e5b	3d		=
	dec a			;2e5c	3d		=
	dec a			;2e5d	3d		=
	dec a			;2e5e	3d		=
l2e5fh:
	dec a			;2e5f	3d		=
	dec a			;2e60	3d		=
sub_2e61h:
	dec a			;2e61	3d		=
	dec a			;2e62	3d		=
	dec a			;2e63	3d		=
l2e64h:
	dec a			;2e64	3d		=
	dec a			;2e65	3d		=
l2e66h:
	dec a			;2e66	3d		=
	dec a			;2e67	3d		=
l2e68h:
	dec a			;2e68	3d		=
	jr nz,l2e8bh		;2e69	20 20		   
	jr nz,l2e8dh		;2e6b	20 20		   
	jr nz,l2e8fh		;2e6d	20 20		   
	jr nz,l2e91h		;2e6f	20 20		   
	jr nz,l2e93h		;2e71	20 20		   
	ld c,b			;2e73	48		H
l2e74h:
	ld (0c300h),hl		;2e74	22 00 c3	" . .
	adc a,02eh		;2e77	ce 2e		. .
l2e79h:
	out (02eh),a		;2e79	d3 2e		. .
l2e7bh:
	jr nz,l2e9fh		;2e7b	20 22		  "
	jr nz,l2e9fh		;2e7d	20 20		   
	jr nz,l2ec9h		;2e7f	20 48		  H
	jr nz,$+34		;2e81	20 20		   
	jr nz,$+34		;2e83	20 20		   
	jr nz,$+34		;2e85	20 20		   
	jr nz,$+34		;2e87	20 20		   
	jr nz,$+34		;2e89	20 20		   
l2e8bh:
	jr nz,$+34		;2e8b	20 20		   
l2e8dh:
	jr nz,$+34		;2e8d	20 20		   
l2e8fh:
	ld a,h			;2e8f	7c		|
	dec a			;2e90	3d		=
l2e91h:
	dec a			;2e91	3d		=
	dec a			;2e92	3d		=
l2e93h:
	dec a			;2e93	3d		=
	dec a			;2e94	3d		=
	jr nz,$+34		;2e95	20 20		   
	jr nz,$+34		;2e97	20 20		   
	jr nz,$+34		;2e99	20 20		   
	jr nz,l2ef9h		;2e9b	20 5c		  \
	jr nz,l2ebfh		;2e9d	20 20		   
l2e9fh:
	cpl			;2e9f	2f		/
	jr nz,l2ec2h		;2ea0	20 20		   
	jr nz,l2ec4h		;2ea2	20 20		   
	jr nz,l2ec6h		;2ea4	20 20		   
	jr nz,l2ec8h		;2ea6	20 20		   
	jr nz,$+88		;2ea8	20 56		  V
	jr nz,l2ecch		;2eaa	20 20		   
	jr nz,$+34		;2eac	20 20		   
	jr nz,l2ed0h		;2eae	20 20		   
	jr nz,$+34		;2eb0	20 20		   
	jr nz,l2ed4h		;2eb2	20 20		   
	jr nz,$+34		;2eb4	20 20		   
	jr nz,$+34		;2eb6	20 20		   
	jr nz,$+34		;2eb8	20 20		   
	jr nz,$+34		;2eba	20 20		   
	dec a			;2ebc	3d		=
l2ebdh:
	dec a			;2ebd	3d		=
	dec a			;2ebe	3d		=
l2ebfh:
	dec a			;2ebf	3d		=
	dec a			;2ec0	3d		=
l2ec1h:
	ld c,b			;2ec1	48		H
l2ec2h:
	dec a			;2ec2	3d		=
	dec a			;2ec3	3d		=
l2ec4h:
	dec a			;2ec4	3d		=
	dec a			;2ec5	3d		=
l2ec6h:
	dec a			;2ec6	3d		=
	dec a			;2ec7	3d		=
l2ec8h:
	dec a			;2ec8	3d		=
l2ec9h:
	dec a			;2ec9	3d		=
	dec a			;2eca	3d		=
	dec a			;2ecb	3d		=
l2ecch:
	ld (0c300h),hl		;2ecc	22 00 c3	" . .
	inc e			;2ecf	1c		.
l2ed0h:
	cpl			;2ed0	2f		/
	ld hl,0202fh		;2ed1	21 2f 20	! /  
l2ed4h:
	ld (l2020h),hl		;2ed4	22 20 20	"    
	jr nz,l2f21h		;2ed7	20 48		  H
	jr nz,l2efbh		;2ed9	20 20		   
	jr nz,l2efdh		;2edb	20 20		   
	jr nz,l2effh		;2edd	20 20		   
	jr nz,l2f01h		;2edf	20 20		   
	jr nz,l2f03h		;2ee1	20 20		   
	jr nz,l2f05h		;2ee3	20 20		   
l2ee5h:
	jr nz,l2f07h		;2ee5	20 20		   
	jr nz,l2f09h		;2ee7	20 20		   
	jr nz,l2f0bh		;2ee9	20 20		   
	jr nz,l2f0dh		;2eeb	20 20		   
	jr nz,l2f0fh		;2eed	20 20		   
	jr nz,l2f11h		;2eef	20 20		   
	jr nz,l2f13h		;2ef1	20 20		   
	jr nz,l2f15h		;2ef3	20 20		   
	ld e,h			;2ef5	5c		\
	cpl			;2ef6	2f		/
	jr nz,l2f19h		;2ef7	20 20		   
l2ef9h:
	jr nz,$+34		;2ef9	20 20		   
l2efbh:
	jr nz,l2f1dh		;2efb	20 20		   
l2efdh:
	jr nz,l2f1fh		;2efd	20 20		   
l2effh:
	jr nz,l2f21h		;2eff	20 20		   
l2f01h:
	jr nz,l2f23h		;2f01	20 20		   
l2f03h:
	jr nz,l2f25h		;2f03	20 20		   
l2f05h:
	jr nz,l2f27h		;2f05	20 20		   
l2f07h:
	jr nz,l2f29h		;2f07	20 20		   
l2f09h:
	jr nz,l2f2bh		;2f09	20 20		   
l2f0bh:
	jr nz,l2f2dh		;2f0b	20 20		   
l2f0dh:
	jr nz,l2f2fh		;2f0d	20 20		   
l2f0fh:
	jr nz,l2f31h		;2f0f	20 20		   
l2f11h:
	jr nz,l2f33h		;2f11	20 20		   
l2f13h:
	jr nz,l2f35h		;2f13	20 20		   
l2f15h:
	jr nz,l2f37h		;2f15	20 20		   
	jr nz,l2f39h		;2f17	20 20		   
l2f19h:
	ld c,b			;2f19	48		H
	ld (0c300h),hl		;2f1a	22 00 c3	" . .
l2f1dh:
	ld l,d			;2f1d	6a		j
	cpl			;2f1e	2f		/
l2f1fh:
	ld l,a			;2f1f	6f		o
l2f20h:
	cpl			;2f20	2f		/
l2f21h:
	jr nz,l2f45h		;2f21	20 22		  "
l2f23h:
	jr nz,l2f45h		;2f23	20 20		   
l2f25h:
	jr nz,l2f6fh		;2f25	20 48		  H
l2f27h:
	jr nz,l2f49h		;2f27	20 20		   
l2f29h:
	jr nz,l2f4bh		;2f29	20 20		   
l2f2bh:
	jr nz,l2f4dh		;2f2b	20 20		   
l2f2dh:
	jr nz,l2f4fh		;2f2d	20 20		   
l2f2fh:
	jr nz,$+34		;2f2f	20 20		   
l2f31h:
	jr nz,$+34		;2f31	20 20		   
l2f33h:
	jr nz,$+34		;2f33	20 20		   
l2f35h:
	jr nz,$+34		;2f35	20 20		   
l2f37h:
	jr nz,$+34		;2f37	20 20		   
l2f39h:
	jr nz,$+34		;2f39	20 20		   
	jr nz,$+34		;2f3b	20 20		   
	jr nz,$+34		;2f3d	20 20		   
	jr nz,$+34		;2f3f	20 20		   
	jr nz,$+34		;2f41	20 20		   
	jr nz,$+34		;2f43	20 20		   
l2f45h:
	jr nz,$+34		;2f45	20 20		   
	jr nz,$+34		;2f47	20 20		   
l2f49h:
	jr nz,l2f6bh		;2f49	20 20		   
l2f4bh:
	jr nz,l2f6dh		;2f4b	20 20		   
l2f4dh:
	jr nz,l2f6fh		;2f4d	20 20		   
l2f4fh:
	ld a,h			;2f4f	7c		|
	jr nz,$+38		;2f50	20 24		  $
	jr nz,$+34		;2f52	20 20		   
	jr nz,$+34		;2f54	20 20		   
	jr nz,$+34		;2f56	20 20		   
	jr nz,$+34		;2f58	20 20		   
	jr nz,$+34		;2f5a	20 20		   
	jr nz,$+34		;2f5c	20 20		   
	jr nz,$+34		;2f5e	20 20		   
	jr nz,$+34		;2f60	20 20		   
	jr nz,$+34		;2f62	20 20		   
	jr nz,$+34		;2f64	20 20		   
	jr nz,l2fb0h		;2f66	20 48		  H
	ld (0c300h),hl		;2f68	22 00 c3	" . .
l2f6bh:
	cp b			;2f6b	b8		.
	cpl			;2f6c	2f		/
l2f6dh:
	cp l			;2f6d	bd		.
	cpl			;2f6e	2f		/
l2f6fh:
	jr nz,l2f93h		;2f6f	20 22		  "
	jr nz,l2f93h		;2f71	20 20		   
	jr nz,$+74		;2f73	20 48		  H
	jr nz,l2f97h		;2f75	20 20		   
l2f77h:
	jr nz,l2f99h		;2f77	20 20		   
	jr nz,l2f9bh		;2f79	20 20		   
	jr nz,sub_2f9dh		;2f7b	20 20		   
	jr nz,$+34		;2f7d	20 20		   
	jr nz,l2fc9h		;2f7f	20 48		  H
	jr nz,$+34		;2f81	20 20		   
	jr nz,$+34		;2f83	20 20		   
	jr nz,$+34		;2f85	20 20		   
	jr nz,$+34		;2f87	20 20		   
	jr nz,$+34		;2f89	20 20		   
	jr nz,$+34		;2f8b	20 20		   
	jr nz,$+34		;2f8d	20 20		   
	jr nz,$+34		;2f8f	20 20		   
	jr nz,$+34		;2f91	20 20		   
l2f93h:
	jr nz,$+34		;2f93	20 20		   
sub_2f95h:
	jr nz,$+34		;2f95	20 20		   
l2f97h:
	jr nz,l2fb9h		;2f97	20 20		   
l2f99h:
	jr nz,l2fbbh		;2f99	20 20		   
l2f9bh:
	jr nz,$+34		;2f9b	20 20		   
sub_2f9dh:
	ld a,h			;2f9d	7c		|
	jr nz,$+74		;2f9e	20 48		  H
	jr nz,$+34		;2fa0	20 20		   
l2fa2h:
	jr nz,$+34		;2fa2	20 20		   
sub_2fa4h:
	jr nz,$+34		;2fa4	20 20		   
	jr nz,$+34		;2fa6	20 20		   
	jr nz,$+34		;2fa8	20 20		   
	jr nz,l2fcch		;2faa	20 20		   
	jr nz,l2fceh		;2fac	20 20		   
	jr nz,l2fd0h		;2fae	20 20		   
l2fb0h:
	jr nz,l2fd2h		;2fb0	20 20		   
	jr nz,l2fd4h		;2fb2	20 20		   
	jr nz,$+74		;2fb4	20 48		  H
	ld (0c300h),hl		;2fb6	22 00 c3	" . .
l2fb9h:
	ld b,030h		;2fb9	06 30		. 0
l2fbbh:
	dec bc			;2fbb	0b		.
	jr nc,$+34		;2fbc	30 20		0  
	ld (l2020h),hl		;2fbe	22 20 20	"    
	jr nz,$+74		;2fc1	20 48		  H
	jr nz,l2fe5h		;2fc3	20 20		   
	jr nz,l2fe7h		;2fc5	20 20		   
	jr nz,l2fe9h		;2fc7	20 20		   
l2fc9h:
	jr nz,l3008h		;2fc9	20 3d		  =
l2fcbh:
	dec a			;2fcb	3d		=
l2fcch:
	dec a			;2fcc	3d		=
	dec a			;2fcd	3d		=
l2fceh:
	ld c,b			;2fce	48		H
	dec a			;2fcf	3d		=
l2fd0h:
	dec a			;2fd0	3d		=
	dec a			;2fd1	3d		=
l2fd2h:
	dec a			;2fd2	3d		=
	dec a			;2fd3	3d		=
l2fd4h:
	dec a			;2fd4	3d		=
	dec a			;2fd5	3d		=
	dec a			;2fd6	3d		=
	jr nz,l2ff9h		;2fd7	20 20		   
	jr nz,l2ffbh		;2fd9	20 20		   
	jr nz,l2ffdh		;2fdb	20 20		   
	jr nz,l2fffh		;2fdd	20 20		   
	jr nz,$+105		;2fdf	20 67		  g
	jr nz,l3003h		;2fe1	20 20		   
	jr nz,$+34		;2fe3	20 20		   
l2fe5h:
	jr nz,l3007h		;2fe5	20 20		   
l2fe7h:
	jr nz,$+34		;2fe7	20 20		   
l2fe9h:
	jr nz,$+34		;2fe9	20 20		   
	ld a,h			;2feb	7c		|
	ld h,048h		;2fec	26 48		& H
	jr nz,$+34		;2fee	20 20		   
	jr nz,$+34		;2ff0	20 20		   
	ld c,b			;2ff2	48		H
	jr nz,l3015h		;2ff3	20 20		   
	jr nz,l3017h		;2ff5	20 20		   
	jr nz,l3019h		;2ff7	20 20		   
l2ff9h:
	jr nz,l301bh		;2ff9	20 20		   
l2ffbh:
	jr nz,l301dh		;2ffb	20 20		   
l2ffdh:
	jr nz,l301fh		;2ffd	20 20		   
l2fffh:
	jr nz,l3021h		;2fff	20 20		   
	jr nz,l3023h		;3001	20 20		   
l3003h:
	ld c,b			;3003	48		H
	ld (0c300h),hl		;3004	22 00 c3	" . .
l3007h:
	ld d,h			;3007	54		T
l3008h:
	jr nc,l3063h		;3008	30 59		0 Y
	jr nc,l302ch		;300a	30 20		0  
	ld (l2020h),hl		;300c	22 20 20	"    
	jr nz,$+74		;300f	20 48		  H
l3011h:
	jr nz,l3033h		;3011	20 20		   
	jr nz,l3035h		;3013	20 20		   
l3015h:
	jr nz,l3037h		;3015	20 20		   
l3017h:
	jr nz,l3039h		;3017	20 20		   
l3019h:
	jr nz,l303bh		;3019	20 20		   
l301bh:
	jr nz,l3065h		;301b	20 48		  H
l301dh:
	jr nz,l303fh		;301d	20 20		   
l301fh:
	jr nz,l3041h		;301f	20 20		   
l3021h:
	jr nz,l3043h		;3021	20 20		   
l3023h:
	jr nz,l3045h		;3023	20 20		   
	jr nz,l3047h		;3025	20 20		   
l3027h:
	jr nz,l3049h		;3027	20 20		   
	jr nz,$+63		;3029	20 3d		  =
	dec a			;302b	3d		=
l302ch:
	dec a			;302c	3d		=
	dec a			;302d	3d		=
	dec a			;302e	3d		=
	dec a			;302f	3d		=
l3030h:
	dec a			;3030	3d		=
	dec a			;3031	3d		=
	dec a			;3032	3d		=
l3033h:
	dec a			;3033	3d		=
	dec a			;3034	3d		=
l3035h:
	dec a			;3035	3d		=
	dec a			;3036	3d		=
l3037h:
	dec a			;3037	3d		=
	dec a			;3038	3d		=
l3039h:
	dec a			;3039	3d		=
	dec a			;303a	3d		=
l303bh:
	dec a			;303b	3d		=
	dec a			;303c	3d		=
	dec a			;303d	3d		=
	dec a			;303e	3d		=
l303fh:
	dec a			;303f	3d		=
	ld c,b			;3040	48		H
l3041h:
	jr nz,l3063h		;3041	20 20		   
l3043h:
	jr nz,l3065h		;3043	20 20		   
l3045h:
	jr nz,l3067h		;3045	20 20		   
l3047h:
	jr nz,l3069h		;3047	20 20		   
l3049h:
	jr nz,l306bh		;3049	20 20		   
	jr nz,$+63		;304b	20 3d		  =
	dec a			;304d	3d		=
	dec a			;304e	3d		=
	dec a			;304f	3d		=
	dec a			;3050	3d		=
	dec a			;3051	3d		=
	ld (0c300h),hl		;3052	22 00 c3	" . .
	and (hl)		;3055	a6		.
	jr nc,l3003h		;3056	30 ab		0 .
	jr nc,$+34		;3058	30 20		0  
	ld (l2020h),hl		;305a	22 20 20	"    
	jr nz,l30a7h		;305d	20 48		  H
l305fh:
	jr nz,l3081h		;305f	20 20		   
	jr nz,l3083h		;3061	20 20		   
l3063h:
	jr nz,l3085h		;3063	20 20		   
l3065h:
	jr nz,l3087h		;3065	20 20		   
l3067h:
	jr nz,l3089h		;3067	20 20		   
l3069h:
	jr nz,l30b3h		;3069	20 48		  H
l306bh:
	jr nz,l308dh		;306b	20 20		   
	jr nz,l308fh		;306d	20 20		   
	jr nz,l3091h		;306f	20 20		   
	ld h,07ch		;3071	26 7c		& |
	jr nz,l3095h		;3073	20 20		   
	jr nz,l3097h		;3075	20 20		   
	jr nz,l3099h		;3077	20 20		   
	jr nz,l309bh		;3079	20 20		   
	jr nz,l309dh		;307b	20 20		   
	jr nz,l309fh		;307d	20 20		   
	jr nz,l30a1h		;307f	20 20		   
l3081h:
	jr nz,l30a3h		;3081	20 20		   
l3083h:
	jr nz,$+34		;3083	20 20		   
l3085h:
	jr nz,l30a7h		;3085	20 20		   
l3087h:
	jr nz,$+34		;3087	20 20		   
l3089h:
	jr nz,$+34		;3089	20 20		   
	jr nz,l30adh		;308b	20 20		   
l308dh:
	jr nz,l30d7h		;308d	20 48		  H
l308fh:
	jr nz,l30b1h		;308f	20 20		   
l3091h:
	jr nz,l30b3h		;3091	20 20		   
	jr nz,l30b5h		;3093	20 20		   
l3095h:
	jr nz,l30b7h		;3095	20 20		   
l3097h:
	jr nz,l30b9h		;3097	20 20		   
l3099h:
	jr nz,l30bbh		;3099	20 20		   
l309bh:
	jr nz,l30bdh		;309b	20 20		   
l309dh:
	jr nz,l30bfh		;309d	20 20		   
l309fh:
	jr nz,l30c1h		;309f	20 20		   
l30a1h:
	jr nz,l30c3h		;30a1	20 20		   
l30a3h:
	ld c,b			;30a3	48		H
	ld (0c300h),hl		;30a4	22 00 c3	" . .
l30a7h:
	call m,sub_0130h	;30a7	fc 30 01	. 0 .
	ld sp,02220h		;30aa	31 20 22	1   "
l30adh:
	jr nz,l30cfh		;30ad	20 20		   
	jr nz,l30f9h		;30af	20 48		  H
l30b1h:
	jr nz,l30d3h		;30b1	20 20		   
l30b3h:
	jr nz,l30d5h		;30b3	20 20		   
l30b5h:
	jr nz,l30d7h		;30b5	20 20		   
l30b7h:
	jr nz,l30d9h		;30b7	20 20		   
l30b9h:
	jr nz,$+34		;30b9	20 20		   
l30bbh:
	jr nz,l3105h		;30bb	20 48		  H
l30bdh:
	jr nz,$+34		;30bd	20 20		   
l30bfh:
	jr nz,l30e1h		;30bf	20 20		   
l30c1h:
	jr nz,l30e3h		;30c1	20 20		   
l30c3h:
	ld h,07ch		;30c3	26 7c		& |
	jr nz,l30e7h		;30c5	20 20		   
	jr nz,l30e9h		;30c7	20 20		   
	jr nz,l30ebh		;30c9	20 20		   
	jr nz,l30edh		;30cb	20 20		   
	jr nz,l30efh		;30cd	20 20		   
l30cfh:
	jr nz,l30f1h		;30cf	20 20		   
	jr nz,l30f3h		;30d1	20 20		   
l30d3h:
	jr nz,l30f5h		;30d3	20 20		   
l30d5h:
	jr nz,l30f7h		;30d5	20 20		   
l30d7h:
	jr nz,l30f9h		;30d7	20 20		   
l30d9h:
	ld c,b			;30d9	48		H
	jr nz,$+34		;30da	20 20		   
	jr nz,l30feh		;30dc	20 20		   
	jr nz,$+34		;30de	20 20		   
	ld c,b			;30e0	48		H
l30e1h:
	jr nz,l3103h		;30e1	20 20		   
l30e3h:
	jr nz,l3105h		;30e3	20 20		   
	jr nz,l3107h		;30e5	20 20		   
l30e7h:
	jr nz,l3109h		;30e7	20 20		   
l30e9h:
	jr nz,$+34		;30e9	20 20		   
l30ebh:
	jr nz,$+34		;30eb	20 20		   
l30edh:
	jr nz,$+34		;30ed	20 20		   
l30efh:
	jr nz,l312eh		;30ef	20 3d		  =
l30f1h:
	dec a			;30f1	3d		=
	dec a			;30f2	3d		=
l30f3h:
	dec a			;30f3	3d		=
	dec a			;30f4	3d		=
l30f5h:
	ld c,b			;30f5	48		H
	dec a			;30f6	3d		=
l30f7h:
	dec a			;30f7	3d		=
	dec a			;30f8	3d		=
l30f9h:
	dec a			;30f9	3d		=
	ld (0c300h),hl		;30fa	22 00 c3	" . .
	ld c,(hl)		;30fd	4e		N
l30feh:
	ld sp,l3153h		;30fe	31 53 31	1 S 1
	jr nz,l3125h		;3101	20 22		  "
l3103h:
	dec a			;3103	3d		=
l3104h:
	dec a			;3104	3d		=
l3105h:
	dec a			;3105	3d		=
	ld c,b			;3106	48		H
l3107h:
	dec a			;3107	3d		=
	dec a			;3108	3d		=
l3109h:
	dec a			;3109	3d		=
sub_310ah:
	ld h,020h		;310a	26 20		&  
	jr nz,l312eh		;310c	20 20		   
	jr nz,l3130h		;310e	20 20		   
	jr nz,l3132h		;3110	20 20		   
	ld c,b			;3112	48		H
	jr nz,$+34		;3113	20 20		   
	jr nz,l3137h		;3115	20 20		   
	jr nz,l3139h		;3117	20 20		   
	jr nz,$+63		;3119	20 3d		  =
	dec a			;311b	3d		=
	dec a			;311c	3d		=
	dec a			;311d	3d		=
	dec a			;311e	3d		=
	dec a			;311f	3d		=
	dec a			;3120	3d		=
	dec a			;3121	3d		=
	dec a			;3122	3d		=
	dec a			;3123	3d		=
	dec a			;3124	3d		=
l3125h:
	dec a			;3125	3d		=
sub_3126h:
	dec a			;3126	3d		=
	dec a			;3127	3d		=
	dec a			;3128	3d		=
	dec a			;3129	3d		=
	dec a			;312a	3d		=
	dec a			;312b	3d		=
	dec a			;312c	3d		=
	dec a			;312d	3d		=
l312eh:
	dec a			;312e	3d		=
	ld c,b			;312f	48		H
l3130h:
	jr nz,$+34		;3130	20 20		   
l3132h:
	jr nz,$+34		;3132	20 20		   
	jr nz,$+34		;3134	20 20		   
	ld c,b			;3136	48		H
l3137h:
	jr nz,l3159h		;3137	20 20		   
l3139h:
	jr nz,l315bh		;3139	20 20		   
	jr nz,l315dh		;313b	20 20		   
	jr nz,l315fh		;313d	20 20		   
l313fh:
	jr nz,l3161h		;313f	20 20		   
	jr nz,l3163h		;3141	20 20		   
	jr nz,l3165h		;3143	20 20		   
	jr nz,l3167h		;3145	20 20		   
	jr nz,l3169h		;3147	20 20		   
	jr nz,l316bh		;3149	20 20		   
	ld c,b			;314b	48		H
sub_314ch:
	ld (0c300h),hl		;314c	22 00 c3	" . .
	and b			;314f	a0		.
	ld sp,l31a4h+1		;3150	31 a5 31	1 . 1
l3153h:
	jr nz,l3177h		;3153	20 22		  "
	jr nz,l3177h		;3155	20 20		   
	jr nz,l3179h		;3157	20 20		   
l3159h:
	jr nz,l317bh		;3159	20 20		   
l315bh:
	jr nz,l317dh		;315b	20 20		   
l315dh:
	jr nz,l317fh		;315d	20 20		   
l315fh:
	jr nz,l3181h		;315f	20 20		   
l3161h:
	jr nz,$+34		;3161	20 20		   
l3163h:
	jr nz,l31adh		;3163	20 48		  H
l3165h:
	jr nz,$+34		;3165	20 20		   
l3167h:
	jr nz,l3189h		;3167	20 20		   
l3169h:
	jr nz,l318bh		;3169	20 20		   
l316bh:
	jr nz,l318dh		;316b	20 20		   
	jr nz,l318fh		;316d	20 20		   
	jr nz,l3191h		;316f	20 20		   
l3171h:
	jr nz,l3193h		;3171	20 20		   
	jr nz,l3195h		;3173	20 20		   
	jr nz,l3197h		;3175	20 20		   
l3177h:
	jr nz,l3199h		;3177	20 20		   
l3179h:
	jr nz,l319bh		;3179	20 20		   
l317bh:
	jr nz,l319dh		;317b	20 20		   
l317dh:
	jr nz,$+34		;317d	20 20		   
l317fh:
	jr nz,l31a1h		;317f	20 20		   
l3181h:
	ld c,b			;3181	48		H
	jr nz,l31a4h		;3182	20 20		   
	jr nz,$+34		;3184	20 20		   
	jr nz,$+34		;3186	20 20		   
	ld c,b			;3188	48		H
l3189h:
	jr nz,l31abh		;3189	20 20		   
l318bh:
	jr nz,l31adh		;318b	20 20		   
l318dh:
	jr nz,l31afh		;318d	20 20		   
l318fh:
	jr nz,l31b1h		;318f	20 20		   
l3191h:
	jr nz,l31b3h		;3191	20 20		   
l3193h:
	jr nz,l31b5h		;3193	20 20		   
l3195h:
	jr nz,l31b7h		;3195	20 20		   
l3197h:
	jr nz,l31b9h		;3197	20 20		   
l3199h:
	jr nz,l31bbh		;3199	20 20		   
l319bh:
	jr nz,l31bdh		;319b	20 20		   
l319dh:
	ld c,b			;319d	48		H
	ld (0c300h),hl		;319e	22 00 c3	" . .
l31a1h:
	jp p,0f731h		;31a1	f2 31 f7	. 1 .
l31a4h:
	ld sp,02220h		;31a4	31 20 22	1   "
	jr nz,l31c9h		;31a7	20 20		   
	jr nz,l31cbh		;31a9	20 20		   
l31abh:
	jr nz,l31cdh		;31ab	20 20		   
l31adh:
	jr nz,l31cfh		;31ad	20 20		   
l31afh:
	jr nz,l31d1h		;31af	20 20		   
l31b1h:
	jr nz,l31d3h		;31b1	20 20		   
l31b3h:
	jr nz,$+34		;31b3	20 20		   
l31b5h:
	jr nz,l31ffh		;31b5	20 48		  H
l31b7h:
	jr nz,$+34		;31b7	20 20		   
l31b9h:
	jr nz,$+34		;31b9	20 20		   
l31bbh:
	jr nz,$+34		;31bb	20 20		   
l31bdh:
	jr nz,$+34		;31bd	20 20		   
	jr nz,$+34		;31bf	20 20		   
	jr nz,$+34		;31c1	20 20		   
	jr nz,$+34		;31c3	20 20		   
	jr nz,$+34		;31c5	20 20		   
sub_31c7h:
	jr nz,$+34		;31c7	20 20		   
l31c9h:
	jr nz,$+34		;31c9	20 20		   
l31cbh:
	jr nz,$+34		;31cb	20 20		   
l31cdh:
	jr nz,$+34		;31cd	20 20		   
l31cfh:
	jr nz,$+34		;31cf	20 20		   
l31d1h:
	jr nz,l31f3h		;31d1	20 20		   
l31d3h:
	ld c,b			;31d3	48		H
	jr nz,$+34		;31d4	20 20		   
	jr nz,$+34		;31d6	20 20		   
	jr nz,$+34		;31d8	20 20		   
	ld h,020h		;31da	26 20		&  
	jr nz,$+34		;31dc	20 20		   
	jr nz,$+34		;31de	20 20		   
	jr nz,$+34		;31e0	20 20		   
	jr nz,l3204h		;31e2	20 20		   
	jr nz,l3206h		;31e4	20 20		   
	jr nz,l3208h		;31e6	20 20		   
	jr nz,l320ah		;31e8	20 20		   
	jr nz,l320ch		;31ea	20 20		   
	jr nz,l320eh		;31ec	20 20		   
	jr nz,l3238h		;31ee	20 48		  H
	ld (0c300h),hl		;31f0	22 00 c3	" . .
l31f3h:
	ld b,h			;31f3	44		D
	ld (l3249h),a		;31f4	32 49 32	2 I 2
	jr nz,l321bh		;31f7	20 22		  "
	jr nz,l321bh		;31f9	20 20		   
	jr nz,l321dh		;31fb	20 20		   
	jr nz,l321fh		;31fd	20 20		   
l31ffh:
	jr nz,$+34		;31ff	20 20		   
	jr nz,l3240h		;3201	20 3d		  =
	dec a			;3203	3d		=
l3204h:
	dec a			;3204	3d		=
	dec a			;3205	3d		=
l3206h:
	dec a			;3206	3d		=
	dec a			;3207	3d		=
l3208h:
	ld c,b			;3208	48		H
	dec a			;3209	3d		=
l320ah:
	dec a			;320a	3d		=
	dec a			;320b	3d		=
l320ch:
	jr nz,l322eh		;320c	20 20		   
l320eh:
	jr nz,l324dh		;320e	20 3d		  =
	dec a			;3210	3d		=
	dec a			;3211	3d		=
	dec a			;3212	3d		=
	dec a			;3213	3d		=
	dec a			;3214	3d		=
	dec a			;3215	3d		=
	jr nz,l3238h		;3216	20 20		   
	jr nz,l323ah		;3218	20 20		   
	ld c,b			;321a	48		H
l321bh:
	jr nz,$+34		;321b	20 20		   
l321dh:
	jr nz,$+34		;321d	20 20		   
l321fh:
	inc a			;321f	3c		<
	ld a,020h		;3220	3e 20		>  
	jr nz,$+34		;3222	20 20		   
	jr nz,$+40		;3224	20 26		  &
	jr nz,$+34		;3226	20 20		   
	jr nz,$+34		;3228	20 20		   
	jr nz,$+34		;322a	20 20		   
	jr nz,$+34		;322c	20 20		   
l322eh:
	jr nz,$+34		;322e	20 20		   
	jr nz,$+34		;3230	20 20		   
	jr nz,$+34		;3232	20 20		   
	jr nz,$+34		;3234	20 20		   
	jr nz,$+34		;3236	20 20		   
l3238h:
	jr nz,$+34		;3238	20 20		   
l323ah:
	jr nz,$+34		;323a	20 20		   
	jr nz,$+34		;323c	20 20		   
l323eh:
	jr nz,$+34		;323e	20 20		   
l3240h:
	jr nz,$+74		;3240	20 48		  H
l3242h:
	ld (0c300h),hl		;3242	22 00 c3	" . .
l3245h:
	sbc a,h			;3245	9c		.
	ld (l32a1h),a		;3246	32 a1 32	2 . 2
l3249h:
	jr nz,l326dh		;3249	20 22		  "
	jr nz,l326dh		;324b	20 20		   
l324dh:
	jr nz,l326fh		;324d	20 20		   
	jr nz,l3271h		;324f	20 20		   
	jr nz,l3273h		;3251	20 20		   
	jr nz,l3275h		;3253	20 20		   
	jr nz,l3277h		;3255	20 20		   
	jr nz,l3279h		;3257	20 20		   
	jr nz,l327bh		;3259	20 20		   
	jr nz,l327dh		;325b	20 20		   
	jr nz,l327fh		;325d	20 20		   
	jr nz,l3281h		;325f	20 20		   
	jr nz,l3283h		;3261	20 20		   
	jr nz,l3285h		;3263	20 20		   
	jr nz,l3287h		;3265	20 20		   
	jr nz,l3289h		;3267	20 20		   
	jr nz,l328bh		;3269	20 20		   
	jr nz,l32b5h		;326b	20 48		  H
l326dh:
	dec a			;326d	3d		=
	dec a			;326e	3d		=
l326fh:
	dec a			;326f	3d		=
	dec a			;3270	3d		=
l3271h:
	dec a			;3271	3d		=
	dec a			;3272	3d		=
l3273h:
	dec a			;3273	3d		=
	dec a			;3274	3d		=
l3275h:
	dec a			;3275	3d		=
	dec a			;3276	3d		=
l3277h:
	jr nz,l3299h		;3277	20 20		   
l3279h:
	jr nz,$+34		;3279	20 20		   
l327bh:
	jr nz,l329dh		;327b	20 20		   
l327dh:
	jr nz,$+63		;327d	20 3d		  =
l327fh:
	dec a			;327f	3d		=
sub_3280h:
	dec a			;3280	3d		=
l3281h:
	dec a			;3281	3d		=
	dec a			;3282	3d		=
l3283h:
	jr nz,l32a5h		;3283	20 20		   
l3285h:
	jr nz,l32a7h		;3285	20 20		   
l3287h:
	jr nz,$+63		;3287	20 3d		  =
l3289h:
	jr nz,l32abh		;3289	20 20		   
l328bh:
	jr nz,l32adh		;328b	20 20		   
	jr nz,l32cch		;328d	20 3d		  =
	dec a			;328f	3d		=
	dec a			;3290	3d		=
	dec a			;3291	3d		=
	dec a			;3292	3d		=
	dec a			;3293	3d		=
	dec a			;3294	3d		=
	dec a			;3295	3d		=
	dec a			;3296	3d		=
	dec a			;3297	3d		=
	dec a			;3298	3d		=
l3299h:
	dec a			;3299	3d		=
	ld (0c300h),hl		;329a	22 00 c3	" . .
l329dh:
	rst 0			;329d	c7		.
	ld (l32cch),a		;329e	32 cc 32	2 . 2
l32a1h:
	jr nz,l32c5h		;32a1	20 22		  "
	jr nz,l32c5h		;32a3	20 20		   
l32a5h:
	jr nz,$+34		;32a5	20 20		   
l32a7h:
	jr nz,l32c9h		;32a7	20 20		   
	jr nz,l32cbh		;32a9	20 20		   
l32abh:
	jr nz,$+34		;32ab	20 20		   
l32adh:
	jr nz,$+34		;32ad	20 20		   
	jr nz,l32d1h		;32af	20 20		   
	jr nz,l32d3h		;32b1	20 20		   
	jr nz,l32d5h		;32b3	20 20		   
l32b5h:
	jr nz,l32d7h		;32b5	20 20		   
	jr nz,l32d9h		;32b7	20 20		   
	jr nz,l32dbh		;32b9	20 20		   
	jr nz,l32ddh		;32bb	20 20		   
	jr nz,l32dfh		;32bd	20 20		   
	jr nz,l32e1h		;32bf	20 20		   
	jr nz,l32e3h		;32c1	20 20		   
	jr nz,$+74		;32c3	20 48		  H
l32c5h:
	ld (0c300h),hl		;32c5	22 00 c3	" . .
	rra			;32c8	1f		.
l32c9h:
	inc sp			;32c9	33		3
	inc h			;32ca	24		$
l32cbh:
	inc sp			;32cb	33		3
l32cch:
	jr nz,l32f0h		;32cc	20 22		  "
	ld hl,(l2020h)		;32ce	2a 20 20	*    
l32d1h:
	jr nz,$+34		;32d1	20 20		   
l32d3h:
	jr nz,$+34		;32d3	20 20		   
l32d5h:
	jr nz,$+34		;32d5	20 20		   
l32d7h:
	jr nz,$+34		;32d7	20 20		   
l32d9h:
	jr nz,$+34		;32d9	20 20		   
l32dbh:
	jr nz,$+34		;32db	20 20		   
l32ddh:
	jr nz,$+34		;32dd	20 20		   
l32dfh:
	jr nz,$+34		;32df	20 20		   
l32e1h:
	jr nz,$+34		;32e1	20 20		   
l32e3h:
	jr nz,$+34		;32e3	20 20		   
	jr nz,$+34		;32e5	20 20		   
	jr nz,$+34		;32e7	20 20		   
	jr nz,$+34		;32e9	20 20		   
	jr nz,$+34		;32eb	20 20		   
l32edh:
	jr nz,$+34		;32ed	20 20		   
	ld c,b			;32ef	48		H
l32f0h:
	jr nz,l3312h		;32f0	20 20		   
l32f2h:
	jr nz,l3314h		;32f2	20 20		   
l32f4h:
	jr nz,l3316h		;32f4	20 20		   
l32f6h:
	jr nz,l3318h		;32f6	20 20		   
	jr nz,l331ah		;32f8	20 20		   
	jr nz,l331ch		;32fa	20 20		   
	jr nz,$+34		;32fc	20 20		   
	jr nz,$+34		;32fe	20 20		   
	jr nz,l3322h		;3300	20 20		   
	jr nz,l3324h		;3302	20 20		   
	jr nz,l3326h		;3304	20 20		   
	jr nz,l3328h		;3306	20 20		   
	jr nz,l332ah		;3308	20 20		   
	jr nz,l332ch		;330a	20 20		   
	jr nz,l332eh		;330c	20 20		   
	jr nz,l3330h		;330e	20 20		   
	jr nz,l3332h		;3310	20 20		   
l3312h:
	jr nz,l3334h		;3312	20 20		   
l3314h:
	jr nz,l3336h		;3314	20 20		   
l3316h:
	jr nz,l3338h		;3316	20 20		   
l3318h:
	jr nz,l333ah		;3318	20 20		   
l331ah:
	jr nz,l333ch		;331a	20 20		   
l331ch:
	ld hl,(00022h)		;331c	2a 22 00	* " .
	jp 03377h		;331f	c3 77 33	. w 3
l3322h:
	ld a,h			;3322	7c		|
	inc sp			;3323	33		3
l3324h:
	jr nz,l3348h		;3324	20 22		  "
l3326h:
	dec a			;3326	3d		=
	dec a			;3327	3d		=
l3328h:
	dec a			;3328	3d		=
	dec a			;3329	3d		=
l332ah:
	dec a			;332a	3d		=
	dec a			;332b	3d		=
l332ch:
	dec a			;332c	3d		=
	dec a			;332d	3d		=
l332eh:
	dec a			;332e	3d		=
	dec a			;332f	3d		=
l3330h:
	dec a			;3330	3d		=
	dec a			;3331	3d		=
l3332h:
	dec a			;3332	3d		=
	dec a			;3333	3d		=
l3334h:
	dec a			;3334	3d		=
	dec a			;3335	3d		=
l3336h:
	dec a			;3336	3d		=
	dec a			;3337	3d		=
l3338h:
	dec a			;3338	3d		=
	dec a			;3339	3d		=
l333ah:
	dec a			;333a	3d		=
	dec a			;333b	3d		=
l333ch:
	dec a			;333c	3d		=
	dec a			;333d	3d		=
l333eh:
	dec a			;333e	3d		=
	dec a			;333f	3d		=
	dec a			;3340	3d		=
	dec a			;3341	3d		=
	dec a			;3342	3d		=
	dec a			;3343	3d		=
	dec a			;3344	3d		=
	dec a			;3345	3d		=
	dec a			;3346	3d		=
	dec a			;3347	3d		=
l3348h:
	dec a			;3348	3d		=
	dec a			;3349	3d		=
	dec a			;334a	3d		=
	dec a			;334b	3d		=
	dec a			;334c	3d		=
	dec a			;334d	3d		=
	dec a			;334e	3d		=
	dec a			;334f	3d		=
	dec a			;3350	3d		=
	dec a			;3351	3d		=
	dec a			;3352	3d		=
	dec a			;3353	3d		=
	dec a			;3354	3d		=
	dec a			;3355	3d		=
	dec a			;3356	3d		=
	dec a			;3357	3d		=
	dec a			;3358	3d		=
	dec a			;3359	3d		=
	dec a			;335a	3d		=
	dec a			;335b	3d		=
	dec a			;335c	3d		=
	dec a			;335d	3d		=
	dec a			;335e	3d		=
	dec a			;335f	3d		=
	dec a			;3360	3d		=
	dec a			;3361	3d		=
	dec a			;3362	3d		=
	dec a			;3363	3d		=
	dec a			;3364	3d		=
	dec a			;3365	3d		=
	dec a			;3366	3d		=
	dec a			;3367	3d		=
	dec a			;3368	3d		=
	dec a			;3369	3d		=
	dec a			;336a	3d		=
	dec a			;336b	3d		=
	dec a			;336c	3d		=
	dec a			;336d	3d		=
	dec a			;336e	3d		=
	dec a			;336f	3d		=
	dec a			;3370	3d		=
	dec a			;3371	3d		=
	dec a			;3372	3d		=
	dec a			;3373	3d		=
	dec a			;3374	3d		=
	ld (0c300h),hl		;3375	22 00 c3	" . .
	add a,b			;3378	80		.
	inc sp			;3379	33		3
	add a,l			;337a	85		.
	inc sp			;337b	33		3
	jr nz,$+53		;337c	20 33		  3
	ld (0c300h),a		;337e	32 00 c3	2 . .
	adc a,d			;3381	8a		.
	inc sp			;3382	33		3
	adc a,a			;3383	8f		.
	inc sp			;3384	33		3
	jr nz,$+50		;3385	20 30		  0
	inc l			;3387	2c		,
	ld (hl),000h		;3388	36 00		6 .
	jp l33d8h+2		;338a	c3 da 33	. . 3
	rst 18h			;338d	df		.
	inc sp			;338e	33		3
	jr nz,$+36		;338f	20 22		  "
	jr nz,$+34		;3391	20 20		   
	jr nz,$+34		;3393	20 20		   
	jr nz,$+34		;3395	20 20		   
	jr nz,$+34		;3397	20 20		   
	jr nz,$+34		;3399	20 20		   
	jr nz,$+34		;339b	20 20		   
	jr nz,$+34		;339d	20 20		   
	jr nz,$+34		;339f	20 20		   
	jr nz,$+34		;33a1	20 20		   
	jr nz,$+34		;33a3	20 20		   
	dec a			;33a5	3d		=
	dec a			;33a6	3d		=
	dec a			;33a7	3d		=
	dec a			;33a8	3d		=
	dec a			;33a9	3d		=
	dec a			;33aa	3d		=
	dec a			;33ab	3d		=
	dec a			;33ac	3d		=
	dec a			;33ad	3d		=
	dec a			;33ae	3d		=
	dec a			;33af	3d		=
	jr nz,l33d2h		;33b0	20 20		   
	jr nz,l33d4h		;33b2	20 20		   
	jr nz,l33d6h		;33b4	20 20		   
	jr nz,l33d8h		;33b6	20 20		   
	jr nz,$+34		;33b8	20 20		   
	jr nz,$+34		;33ba	20 20		   
	jr nz,l33deh		;33bc	20 20		   
	jr nz,$+34		;33be	20 20		   
	jr nz,$+34		;33c0	20 20		   
	jr nz,$+34		;33c2	20 20		   
	jr nz,$+34		;33c4	20 20		   
	jr nz,$+34		;33c6	20 20		   
	jr nz,$+34		;33c8	20 20		   
	jr nz,$+34		;33ca	20 20		   
	jr nz,$+88		;33cc	20 56		  V
	jr nz,$+34		;33ce	20 20		   
	jr nz,$+34		;33d0	20 20		   
l33d2h:
	jr nz,$+34		;33d2	20 20		   
l33d4h:
	jr nz,l33f6h		;33d4	20 20		   
l33d6h:
	jr nz,$+48		;33d6	20 2e		  .
l33d8h:
	ld (0c300h),hl		;33d8	22 00 c3	" . .
	ld hl,(l2f33h+1)	;33db	2a 34 2f	* 4 /
l33deh:
	inc (hl)		;33de	34		4
	jr nz,l3403h		;33df	20 22		  "
	jr nz,l3403h		;33e1	20 20		   
	jr nz,l3405h		;33e3	20 20		   
	jr nz,l3407h		;33e5	20 20		   
	jr nz,l3409h		;33e7	20 20		   
	jr nz,l340bh		;33e9	20 20		   
	jr nz,l340dh		;33eb	20 20		   
	jr nz,l340fh		;33ed	20 20		   
	jr nz,l3411h		;33ef	20 20		   
	jr nz,l3413h		;33f1	20 20		   
	jr nz,$+63		;33f3	20 3d		  =
	dec a			;33f5	3d		=
l33f6h:
	jr nz,$+34		;33f6	20 20		   
	jr nz,$+34		;33f8	20 20		   
	jr nz,$+34		;33fa	20 20		   
	ld e,a			;33fc	5f		_
	jr nz,l341fh		;33fd	20 20		   
	dec a			;33ff	3d		=
	dec a			;3400	3d		=
	jr nz,l3423h		;3401	20 20		   
l3403h:
	jr nz,l3425h		;3403	20 20		   
l3405h:
	jr nz,l3427h		;3405	20 20		   
l3407h:
	jr nz,l3429h		;3407	20 20		   
l3409h:
	jr nz,$+34		;3409	20 20		   
l340bh:
	jr nz,l342dh		;340b	20 20		   
l340dh:
	jr nz,l342fh		;340d	20 20		   
l340fh:
	jr nz,l3431h		;340f	20 20		   
l3411h:
	jr nz,l3433h		;3411	20 20		   
l3413h:
	jr nz,l3435h		;3413	20 20		   
	jr nz,l3437h		;3415	20 20		   
	jr nz,$+34		;3417	20 20		   
	jr nz,$+34		;3419	20 20		   
	jr nz,l343dh		;341b	20 20		   
	jr nz,l343fh		;341d	20 20		   
l341fh:
	jr nz,l3441h		;341f	20 20		   
	jr nz,l3443h		;3421	20 20		   
l3423h:
	jr nz,l3445h		;3423	20 20		   
l3425h:
	jr nz,$+34		;3425	20 20		   
l3427h:
	ld l,022h		;3427	2e 22		. "
l3429h:
	nop			;3429	00		.
	jp 0347dh		;342a	c3 7d 34	. } 4
l342dh:
	add a,d			;342d	82		.
	inc (hl)		;342e	34		4
l342fh:
	jr nz,$+36		;342f	20 22		  "
l3431h:
	jr nz,$+34		;3431	20 20		   
l3433h:
	jr nz,$+34		;3433	20 20		   
l3435h:
	jr nz,$+34		;3435	20 20		   
l3437h:
	ld h,a			;3437	67		g
	jr nz,l345ah		;3438	20 20		   
	jr nz,l345ch		;343a	20 20		   
	ld c,b			;343c	48		H
l343dh:
	jr nz,$+34		;343d	20 20		   
l343fh:
	jr nz,$+34		;343f	20 20		   
l3441h:
	jr nz,$+34		;3441	20 20		   
l3443h:
	jr nz,$+34		;3443	20 20		   
l3445h:
	ld a,h			;3445	7c		|
	jr nz,l3468h		;3446	20 20		   
	ld e,e			;3448	5b		[
	ld e,l			;3449	5d		]
	jr nz,l34c8h		;344a	20 7c		  |
	ld e,a			;344c	5f		_
	ld a,h			;344d	7c		|
	jr nz,l34cch		;344e	20 7c		  |
	jr nz,l3472h		;3450	20 20		   
	jr nz,l3474h		;3452	20 20		   
	jr nz,l3476h		;3454	20 20		   
	jr nz,l3478h		;3456	20 20		   
	jr nz,l347ah		;3458	20 20		   
l345ah:
	jr nz,$+34		;345a	20 20		   
l345ch:
	jr nz,l347eh		;345c	20 20		   
	jr nz,l3480h		;345e	20 20		   
	jr nz,l3482h		;3460	20 20		   
	ld h,020h		;3462	26 20		&  
	jr nz,l3486h		;3464	20 20		   
	jr nz,l3488h		;3466	20 20		   
l3468h:
	jr nz,l348ah		;3468	20 20		   
	jr nz,l348ch		;346a	20 20		   
	jr nz,l348eh		;346c	20 20		   
	jr nz,l3490h		;346e	20 20		   
	jr nz,l3492h		;3470	20 20		   
l3472h:
	jr nz,l3494h		;3472	20 20		   
l3474h:
	jr nz,l3496h		;3474	20 20		   
l3476h:
	jr nz,$+48		;3476	20 2e		  .
l3478h:
	jr nz,$+34		;3478	20 20		   
l347ah:
	ld c,b			;347a	48		H
	ld (0c300h),hl		;347b	22 00 c3	" . .
l347eh:
	ret nc			;347e	d0		.
	inc (hl)		;347f	34		4
l3480h:
	push de			;3480	d5		.
	inc (hl)		;3481	34		4
l3482h:
	jr nz,$+36		;3482	20 22		  "
	dec a			;3484	3d		=
	dec a			;3485	3d		=
l3486h:
	dec a			;3486	3d		=
	dec a			;3487	3d		=
l3488h:
	dec a			;3488	3d		=
	dec a			;3489	3d		=
l348ah:
	dec a			;348a	3d		=
	dec a			;348b	3d		=
l348ch:
	dec a			;348c	3d		=
	dec a			;348d	3d		=
l348eh:
	dec a			;348e	3d		=
	ld c,b			;348f	48		H
l3490h:
	jr nz,$+34		;3490	20 20		   
l3492h:
	jr nz,$+34		;3492	20 20		   
l3494h:
	jr nz,l34b6h		;3494	20 20		   
l3496h:
	jr nz,$+34		;3496	20 20		   
	ld a,h			;3498	7c		|
	jr nz,l34bbh		;3499	20 20		   
	jr nz,l34bdh		;349b	20 20		   
	jr nz,$+126		;349d	20 7c		  |
	ld e,a			;349f	5f		_
	ld a,h			;34a0	7c		|
	jr nz,$+126		;34a1	20 7c		  |
	jr nz,l34c5h		;34a3	20 20		   
	jr nz,l34c7h		;34a5	20 20		   
	jr nz,l34c9h		;34a7	20 20		   
	jr nz,l34f3h		;34a9	20 48		  H
	jr nz,l34cdh		;34ab	20 20		   
	jr nz,$+34		;34ad	20 20		   
	jr nz,l34d1h		;34af	20 20		   
	jr nz,l34d3h		;34b1	20 20		   
	jr nz,l34f2h		;34b3	20 3d		  =
	dec a			;34b5	3d		=
l34b6h:
	dec a			;34b6	3d		=
	jr nz,l34d9h		;34b7	20 20		   
	jr nz,l34f8h		;34b9	20 3d		  =
l34bbh:
	dec a			;34bb	3d		=
	dec a			;34bc	3d		=
l34bdh:
	dec a			;34bd	3d		=
	dec a			;34be	3d		=
	dec a			;34bf	3d		=
	dec a			;34c0	3d		=
	dec a			;34c1	3d		=
	dec a			;34c2	3d		=
	dec a			;34c3	3d		=
	dec a			;34c4	3d		=
l34c5h:
	dec a			;34c5	3d		=
	dec a			;34c6	3d		=
l34c7h:
	dec a			;34c7	3d		=
l34c8h:
	dec a			;34c8	3d		=
l34c9h:
	dec a			;34c9	3d		=
	dec a			;34ca	3d		=
	dec a			;34cb	3d		=
l34cch:
	dec a			;34cc	3d		=
l34cdh:
	ld c,b			;34cd	48		H
	ld (0c300h),hl		;34ce	22 00 c3	" . .
l34d1h:
	inc hl			;34d1	23		#
	dec (hl)		;34d2	35		5
l34d3h:
	jr z,l350ah		;34d3	28 35		( 5
	jr nz,$+36		;34d5	20 22		  "
	jr nz,$+34		;34d7	20 20		   
l34d9h:
	jr nz,$+34		;34d9	20 20		   
	jr nz,$+34		;34db	20 20		   
	ld d,(hl)		;34dd	56		V
	jr nz,l3500h		;34de	20 20		   
	jr nz,l3502h		;34e0	20 20		   
	ld c,b			;34e2	48		H
	jr nz,$+34		;34e3	20 20		   
	jr nz,$+34		;34e5	20 20		   
	jr nz,$+34		;34e7	20 20		   
	jr nz,$+34		;34e9	20 20		   
	dec a			;34eb	3d		=
	dec a			;34ec	3d		=
	dec a			;34ed	3d		=
	dec a			;34ee	3d		=
	dec a			;34ef	3d		=
	dec a			;34f0	3d		=
	dec a			;34f1	3d		=
l34f2h:
	dec a			;34f2	3d		=
l34f3h:
	dec a			;34f3	3d		=
	dec a			;34f4	3d		=
	dec a			;34f5	3d		=
	dec a			;34f6	3d		=
	dec a			;34f7	3d		=
l34f8h:
	jr nz,l351ah		;34f8	20 20		   
	jr nz,l351ch		;34fa	20 20		   
	jr nz,l3546h		;34fc	20 48		  H
	dec a			;34fe	3d		=
	dec a			;34ff	3d		=
l3500h:
	dec a			;3500	3d		=
	dec a			;3501	3d		=
l3502h:
	dec a			;3502	3d		=
	dec a			;3503	3d		=
	jr nz,l3526h		;3504	20 20		   
	jr nz,l3528h		;3506	20 20		   
	jr nz,l352ah		;3508	20 20		   
l350ah:
	jr nz,l352ch		;350a	20 20		   
	jr nz,l352eh		;350c	20 20		   
	jr nz,l3530h		;350e	20 20		   
	jr nz,l3532h		;3510	20 20		   
	jr nz,l3534h		;3512	20 20		   
	jr nz,l3536h		;3514	20 20		   
	jr nz,l3538h		;3516	20 20		   
	jr nz,l353ah		;3518	20 20		   
l351ah:
	jr nz,l353ch		;351a	20 20		   
l351ch:
	jr nz,l353eh		;351c	20 20		   
	jr nz,l3540h		;351e	20 20		   
	ld c,b			;3520	48		H
	ld (0c300h),hl		;3521	22 00 c3	" . .
	halt			;3524	76		v
	dec (hl)		;3525	35		5
l3526h:
	ld a,e			;3526	7b		{
	dec (hl)		;3527	35		5
l3528h:
	jr nz,l354ch		;3528	20 22		  "
l352ah:
	jr nz,l354ch		;352a	20 20		   
l352ch:
	jr nz,l354eh		;352c	20 20		   
l352eh:
	jr nz,l3550h		;352e	20 20		   
l3530h:
	jr nz,$+34		;3530	20 20		   
l3532h:
	jr nz,$+34		;3532	20 20		   
l3534h:
	jr nz,$+74		;3534	20 48		  H
l3536h:
	jr nz,$+34		;3536	20 20		   
l3538h:
	jr nz,$+34		;3538	20 20		   
l353ah:
	jr nz,$+34		;353a	20 20		   
l353ch:
	jr nz,$+34		;353c	20 20		   
l353eh:
	jr nz,$+34		;353e	20 20		   
l3540h:
	jr nz,$+34		;3540	20 20		   
	jr nz,$+34		;3542	20 20		   
	jr nz,$+34		;3544	20 20		   
l3546h:
	jr nz,$+34		;3546	20 20		   
	jr nz,$+34		;3548	20 20		   
	jr nz,$+34		;354a	20 20		   
l354ch:
	jr nz,$+34		;354c	20 20		   
l354eh:
	jr nz,$+34		;354e	20 20		   
l3550h:
	ld c,b			;3550	48		H
	jr nz,l3573h		;3551	20 20		   
	jr nz,$+34		;3553	20 20		   
	jr nz,l3577h		;3555	20 20		   
	jr nz,l3579h		;3557	20 20		   
	jr nz,l357bh		;3559	20 20		   
	jr nz,l357dh		;355b	20 20		   
	jr nz,l357fh		;355d	20 20		   
	jr nz,l3581h		;355f	20 20		   
	jr nz,l3583h		;3561	20 20		   
	jr nz,l3585h		;3563	20 20		   
	jr nz,l358dh		;3565	20 26		  &
	jr nz,l3589h		;3567	20 20		   
	jr nz,l358bh		;3569	20 20		   
	jr nz,l358dh		;356b	20 20		   
	jr nz,l358fh		;356d	20 20		   
	jr nz,l3591h		;356f	20 20		   
	jr nz,l3593h		;3571	20 20		   
l3573h:
	ld c,b			;3573	48		H
	ld (0c300h),hl		;3574	22 00 c3	" . .
l3577h:
	ret			;3577	c9		.
	dec (hl)		;3578	35		5
l3579h:
	adc a,035h		;3579	ce 35		. 5
l357bh:
	jr nz,l359fh		;357b	20 22		  "
l357dh:
	jr nz,l359fh		;357d	20 20		   
l357fh:
	jr nz,l35a1h		;357f	20 20		   
l3581h:
	jr nz,l35a3h		;3581	20 20		   
l3583h:
	jr nz,$+34		;3583	20 20		   
l3585h:
	jr nz,$+34		;3585	20 20		   
	jr nz,$+74		;3587	20 48		  H
l3589h:
	jr nz,$+34		;3589	20 20		   
l358bh:
	jr nz,$+34		;358b	20 20		   
l358dh:
	jr nz,$+34		;358d	20 20		   
l358fh:
	jr nz,$+34		;358f	20 20		   
l3591h:
	jr nz,$+34		;3591	20 20		   
l3593h:
	jr nz,l35b5h		;3593	20 20		   
	jr nz,l35b7h		;3595	20 20		   
	jr nz,l35b9h		;3597	20 20		   
	jr nz,$+34		;3599	20 20		   
	jr nz,$+34		;359b	20 20		   
	jr nz,$+34		;359d	20 20		   
l359fh:
	jr nz,$+34		;359f	20 20		   
l35a1h:
	jr nz,$+34		;35a1	20 20		   
l35a3h:
	ld c,b			;35a3	48		H
	jr nz,l35c6h		;35a4	20 20		   
	jr nz,$+34		;35a6	20 20		   
	jr nz,l35cah		;35a8	20 20		   
	jr nz,$+34		;35aa	20 20		   
	jr nz,$+34		;35ac	20 20		   
	jr nz,$+34		;35ae	20 20		   
	jr nz,l35d2h		;35b0	20 20		   
	jr nz,l35d4h		;35b2	20 20		   
	ld a,h			;35b4	7c		|
l35b5h:
	jr nz,l35d7h		;35b5	20 20		   
l35b7h:
	jr nz,l35d9h		;35b7	20 20		   
l35b9h:
	ld a,h			;35b9	7c		|
	jr nz,l35dch		;35ba	20 20		   
	jr nz,l35deh		;35bc	20 20		   
	jr nz,l35e0h		;35be	20 20		   
	jr nz,l35e2h		;35c0	20 20		   
	jr nz,l35e4h		;35c2	20 20		   
	jr nz,l35e6h		;35c4	20 20		   
l35c6h:
	ld c,b			;35c6	48		H
	ld (0c300h),hl		;35c7	22 00 c3	" . .
l35cah:
	inc e			;35ca	1c		.
	ld (hl),021h		;35cb	36 21		6 !
	ld (hl),020h		;35cd	36 20		6  
	ld (l2020h),hl		;35cf	22 20 20	"    
l35d2h:
	jr nz,l35f4h		;35d2	20 20		   
l35d4h:
	ld c,b			;35d4	48		H
	jr nz,l35f7h		;35d5	20 20		   
l35d7h:
	jr nz,l35f9h		;35d7	20 20		   
l35d9h:
	jr nz,l35fbh		;35d9	20 20		   
	ld c,b			;35db	48		H
l35dch:
	jr nz,$+34		;35dc	20 20		   
l35deh:
	jr nz,$+34		;35de	20 20		   
l35e0h:
	jr nz,$+34		;35e0	20 20		   
l35e2h:
	jr nz,$+34		;35e2	20 20		   
l35e4h:
	ld e,(hl)		;35e4	5e		^
	ld e,(hl)		;35e5	5e		^
l35e6h:
	ld e,(hl)		;35e6	5e		^
	ld h,026h		;35e7	26 26		& &
	ld e,(hl)		;35e9	5e		^
	ld e,(hl)		;35ea	5e		^
	ld e,(hl)		;35eb	5e		^
	jr nz,l3614h		;35ec	20 26		  &
	jr nz,l364eh		;35ee	20 5e		  ^
	jr nz,l3612h		;35f0	20 20		   
	ld e,(hl)		;35f2	5e		^
	ld e,(hl)		;35f3	5e		^
l35f4h:
	ld e,(hl)		;35f4	5e		^
	jr nz,l363fh		;35f5	20 48		  H
l35f7h:
	jr nz,l3619h		;35f7	20 20		   
l35f9h:
	jr nz,$+34		;35f9	20 20		   
l35fbh:
	jr nz,l361dh		;35fb	20 20		   
	jr nz,$+34		;35fd	20 20		   
	jr nz,$+34		;35ff	20 20		   
	jr nz,l364bh		;3601	20 48		  H
	jr nz,l3625h		;3603	20 20		   
	jr nz,l3627h		;3605	20 20		   
	ld a,h			;3607	7c		|
	jr nz,l362ah		;3608	20 20		   
	jr nz,l362ch		;360a	20 20		   
	dec a			;360c	3d		=
	dec a			;360d	3d		=
	dec a			;360e	3d		=
	dec a			;360f	3d		=
	dec a			;3610	3d		=
	dec a			;3611	3d		=
l3612h:
	dec a			;3612	3d		=
	dec a			;3613	3d		=
l3614h:
	dec a			;3614	3d		=
	dec a			;3615	3d		=
	dec a			;3616	3d		=
	dec a			;3617	3d		=
	dec a			;3618	3d		=
l3619h:
	ld c,b			;3619	48		H
	ld (0c300h),hl		;361a	22 00 c3	" . .
l361dh:
	ld l,a			;361d	6f		o
	ld (hl),074h		;361e	36 74		6 t
	ld (hl),020h		;3620	36 20		6  
	ld (l2020h),hl		;3622	22 20 20	"    
l3625h:
	jr nz,l3647h		;3625	20 20		   
l3627h:
	ld c,b			;3627	48		H
	dec a			;3628	3d		=
	dec a			;3629	3d		=
l362ah:
	dec a			;362a	3d		=
	dec a			;362b	3d		=
l362ch:
	dec a			;362c	3d		=
	dec a			;362d	3d		=
	ld c,b			;362e	48		H
	jr nz,l3651h		;362f	20 20		   
	jr nz,l3670h		;3631	20 3d		  =
	dec a			;3633	3d		=
	dec a			;3634	3d		=
	dec a			;3635	3d		=
	dec a			;3636	3d		=
	dec a			;3637	3d		=
	dec a			;3638	3d		=
	dec a			;3639	3d		=
	dec a			;363a	3d		=
	dec a			;363b	3d		=
	dec a			;363c	3d		=
	dec a			;363d	3d		=
	dec a			;363e	3d		=
l363fh:
	dec a			;363f	3d		=
	dec a			;3640	3d		=
	dec a			;3641	3d		=
	dec a			;3642	3d		=
	dec a			;3643	3d		=
	dec a			;3644	3d		=
	dec a			;3645	3d		=
	dec a			;3646	3d		=
l3647h:
	dec a			;3647	3d		=
	dec a			;3648	3d		=
	ld c,b			;3649	48		H
	dec a			;364a	3d		=
l364bh:
	dec a			;364b	3d		=
	dec a			;364c	3d		=
	dec a			;364d	3d		=
l364eh:
	dec a			;364e	3d		=
	dec a			;364f	3d		=
	dec a			;3650	3d		=
l3651h:
	dec a			;3651	3d		=
	dec a			;3652	3d		=
	dec a			;3653	3d		=
	dec a			;3654	3d		=
	ld c,b			;3655	48		H
	dec a			;3656	3d		=
	dec a			;3657	3d		=
	dec a			;3658	3d		=
	dec a			;3659	3d		=
	dec a			;365a	3d		=
	jr nz,l367dh		;365b	20 20		   
	jr nz,l367fh		;365d	20 20		   
	jr nz,l3681h		;365f	20 20		   
	jr nz,l3683h		;3661	20 20		   
	jr nz,l3685h		;3663	20 20		   
	jr nz,l3687h		;3665	20 20		   
	jr nz,l3689h		;3667	20 20		   
	jr nz,l368bh		;3669	20 20		   
	jr nz,$+74		;366b	20 48		  H
	ld (0c300h),hl		;366d	22 00 c3	" . .
l3670h:
	jp nz,0c736h		;3670	c2 36 c7	. 6 .
	ld (hl),020h		;3673	36 20		6  
	ld (l2020h),hl		;3675	22 20 20	"    
	jr nz,$+34		;3678	20 20		   
	ld c,b			;367a	48		H
	jr nz,l369dh		;367b	20 20		   
l367dh:
	jr nz,l369fh		;367d	20 20		   
l367fh:
	jr nz,l36a1h		;367f	20 20		   
l3681h:
	jr nz,l36a3h		;3681	20 20		   
l3683h:
	jr nz,l36a5h		;3683	20 20		   
l3685h:
	jr nz,l36a7h		;3685	20 20		   
l3687h:
	jr nz,l36a9h		;3687	20 20		   
l3689h:
	jr nz,l36abh		;3689	20 20		   
l368bh:
	jr nz,l36adh		;368b	20 20		   
	jr nz,$+34		;368d	20 20		   
	jr nz,$+34		;368f	20 20		   
	jr nz,$+34		;3691	20 20		   
	jr nz,$+34		;3693	20 20		   
	jr nz,$+34		;3695	20 20		   
	jr nz,$+34		;3697	20 20		   
	jr nz,$+34		;3699	20 20		   
	jr nz,$+74		;369b	20 48		  H
l369dh:
	jr nz,$+34		;369d	20 20		   
l369fh:
	jr nz,$+34		;369f	20 20		   
l36a1h:
	jr nz,l36c3h		;36a1	20 20		   
l36a3h:
	jr nz,l36c5h		;36a3	20 20		   
l36a5h:
	jr nz,l36c7h		;36a5	20 20		   
l36a7h:
	jr nz,$+74		;36a7	20 48		  H
l36a9h:
	jr nz,l36cbh		;36a9	20 20		   
l36abh:
	jr nz,l36cdh		;36ab	20 20		   
l36adh:
	ld a,h			;36ad	7c		|
	jr nz,l36d0h		;36ae	20 20		   
	jr nz,l36d2h		;36b0	20 20		   
	jr nz,l36d4h		;36b2	20 20		   
	jr nz,l36d6h		;36b4	20 20		   
	jr nz,l36d8h		;36b6	20 20		   
	jr nz,l36dah		;36b8	20 20		   
	jr nz,l36dch		;36ba	20 20		   
	jr nz,l36deh		;36bc	20 20		   
	jr nz,$+74		;36be	20 48		  H
	ld (0c300h),hl		;36c0	22 00 c3	" . .
l36c3h:
	dec d			;36c3	15		.
	scf			;36c4	37		7
l36c5h:
	ld a,(de)		;36c5	1a		.
	scf			;36c6	37		7
l36c7h:
	jr nz,$+36		;36c7	20 22		  "
	jr nz,$+34		;36c9	20 20		   
l36cbh:
	jr nz,$+34		;36cb	20 20		   
l36cdh:
	ld c,b			;36cd	48		H
	jr nz,l36f0h		;36ce	20 20		   
l36d0h:
	jr nz,l36f2h		;36d0	20 20		   
l36d2h:
	jr nz,l36f4h		;36d2	20 20		   
l36d4h:
	jr nz,l36f6h		;36d4	20 20		   
l36d6h:
	jr nz,l36f8h		;36d6	20 20		   
l36d8h:
	jr nz,l36fah		;36d8	20 20		   
l36dah:
	jr nz,l36fch		;36da	20 20		   
l36dch:
	jr nz,l36feh		;36dc	20 20		   
l36deh:
	jr nz,l3700h		;36de	20 20		   
	jr nz,$+34		;36e0	20 20		   
	jr nz,$+34		;36e2	20 20		   
	jr nz,$+34		;36e4	20 20		   
	jr nz,$+34		;36e6	20 20		   
	jr nz,$+34		;36e8	20 20		   
	jr nz,$+34		;36ea	20 20		   
	jr nz,$+34		;36ec	20 20		   
	jr nz,$+74		;36ee	20 48		  H
l36f0h:
	jr nz,$+34		;36f0	20 20		   
l36f2h:
	jr nz,$+34		;36f2	20 20		   
l36f4h:
	jr nz,l3716h		;36f4	20 20		   
l36f6h:
	jr nz,l3718h		;36f6	20 20		   
l36f8h:
	jr nz,l371ah		;36f8	20 20		   
l36fah:
	jr nz,$+74		;36fa	20 48		  H
l36fch:
	jr nz,l371eh		;36fc	20 20		   
l36feh:
	jr nz,l3720h		;36fe	20 20		   
l3700h:
	ld a,h			;3700	7c		|
	jr nz,l3723h		;3701	20 20		   
	jr nz,l3725h		;3703	20 20		   
	jr nz,l3727h		;3705	20 20		   
	jr nz,l3729h		;3707	20 20		   
	jr nz,l372bh		;3709	20 20		   
	jr nz,l372dh		;370b	20 20		   
	jr nz,l372fh		;370d	20 20		   
	jr nz,l3731h		;370f	20 20		   
	jr nz,l375bh		;3711	20 48		  H
	ld (0c300h),hl		;3713	22 00 c3	" . .
l3716h:
	ld l,b			;3716	68		h
	scf			;3717	37		7
l3718h:
	ld l,l			;3718	6d		m
	scf			;3719	37		7
l371ah:
	jr nz,$+36		;371a	20 22		  "
	jr nz,$+34		;371c	20 20		   
l371eh:
	jr nz,$+34		;371e	20 20		   
l3720h:
	ld c,b			;3720	48		H
	jr nz,l3743h		;3721	20 20		   
l3723h:
	jr nz,l3745h		;3723	20 20		   
l3725h:
	jr nz,l3747h		;3725	20 20		   
l3727h:
	jr nz,l3749h		;3727	20 20		   
l3729h:
	jr nz,l374bh		;3729	20 20		   
l372bh:
	jr nz,l374dh		;372b	20 20		   
l372dh:
	jr nz,l374fh		;372d	20 20		   
l372fh:
	jr nz,l3751h		;372f	20 20		   
l3731h:
	jr nz,l3753h		;3731	20 20		   
	jr nz,$+34		;3733	20 20		   
	jr nz,$+34		;3735	20 20		   
	jr nz,l3759h		;3737	20 20		   
	jr nz,l375bh		;3739	20 20		   
	jr nz,l375dh		;373b	20 20		   
	jr nz,l375fh		;373d	20 20		   
	jr nz,l3761h		;373f	20 20		   
	jr nz,l378bh		;3741	20 48		  H
l3743h:
	jr nz,l3765h		;3743	20 20		   
l3745h:
	jr nz,$+34		;3745	20 20		   
l3747h:
	jr nz,l3769h		;3747	20 20		   
l3749h:
	jr nz,l376bh		;3749	20 20		   
l374bh:
	jr nz,l376dh		;374b	20 20		   
l374dh:
	jr nz,l3797h		;374d	20 48		  H
l374fh:
	jr nz,l3771h		;374f	20 20		   
l3751h:
	jr nz,l3773h		;3751	20 20		   
l3753h:
	ld a,h			;3753	7c		|
	jr nz,$+34		;3754	20 20		   
	jr nz,$+34		;3756	20 20		   
	dec a			;3758	3d		=
l3759h:
	dec a			;3759	3d		=
	dec a			;375a	3d		=
l375bh:
	dec a			;375b	3d		=
	dec a			;375c	3d		=
l375dh:
	dec a			;375d	3d		=
	dec a			;375e	3d		=
l375fh:
	dec a			;375f	3d		=
	dec a			;3760	3d		=
l3761h:
	dec a			;3761	3d		=
	dec a			;3762	3d		=
	dec a			;3763	3d		=
	dec a			;3764	3d		=
l3765h:
	ld c,b			;3765	48		H
	ld (0c300h),hl		;3766	22 00 c3	" . .
l3769h:
	or a			;3769	b7		.
	scf			;376a	37		7
l376bh:
	cp h			;376b	bc		.
	scf			;376c	37		7
l376dh:
	jr nz,l3791h		;376d	20 22		  "
	jr nz,l3791h		;376f	20 20		   
l3771h:
	jr nz,l3793h		;3771	20 20		   
l3773h:
	jr nz,l3795h		;3773	20 20		   
	jr nz,l3797h		;3775	20 20		   
	jr nz,l3799h		;3777	20 20		   
	jr nz,l379bh		;3779	20 20		   
	jr nz,l379dh		;377b	20 20		   
	dec a			;377d	3d		=
	dec a			;377e	3d		=
	dec a			;377f	3d		=
	dec a			;3780	3d		=
	dec a			;3781	3d		=
	dec l			;3782	2d		-
	dec l			;3783	2d		-
	dec l			;3784	2d		-
	dec l			;3785	2d		-
	dec l			;3786	2d		-
	dec l			;3787	2d		-
	dec a			;3788	3d		=
	dec a			;3789	3d		=
	dec a			;378a	3d		=
l378bh:
	dec a			;378b	3d		=
	dec a			;378c	3d		=
	dec a			;378d	3d		=
	dec a			;378e	3d		=
	dec a			;378f	3d		=
	dec a			;3790	3d		=
l3791h:
	dec a			;3791	3d		=
	dec a			;3792	3d		=
l3793h:
	dec a			;3793	3d		=
	dec a			;3794	3d		=
l3795h:
	dec a			;3795	3d		=
	dec a			;3796	3d		=
l3797h:
	dec a			;3797	3d		=
	dec a			;3798	3d		=
l3799h:
	jr nz,l37bbh		;3799	20 20		   
l379bh:
	jr nz,l37bdh		;379b	20 20		   
l379dh:
	jr nz,$+34		;379d	20 20		   
	jr nz,$+34		;379f	20 20		   
	ld c,b			;37a1	48		H
	jr nz,l37c4h		;37a2	20 20		   
	jr nz,l37c6h		;37a4	20 20		   
	ld a,h			;37a6	7c		|
	jr nz,$+34		;37a7	20 20		   
	jr nz,$+34		;37a9	20 20		   
	jr nz,$+34		;37ab	20 20		   
	jr nz,$+38		;37ad	20 24		  $
	jr nz,$+34		;37af	20 20		   
	jr nz,$+34		;37b1	20 20		   
	jr nz,$+38		;37b3	20 24		  $
	ld (0c300h),hl		;37b5	22 00 c3	" . .
	rlca			;37b8	07		.
	jr c,$+14		;37b9	38 0c		8 .
l37bbh:
	jr c,$+34		;37bb	38 20		8  
l37bdh:
	ld (l2020h),hl		;37bd	22 20 20	"    
	jr nz,l37e2h		;37c0	20 20		   
	jr nz,l37e4h		;37c2	20 20		   
l37c4h:
	jr nz,l37e6h		;37c4	20 20		   
l37c6h:
	jr nz,l37e8h		;37c6	20 20		   
	jr nz,l37eah		;37c8	20 20		   
	jr nz,l37ech		;37ca	20 20		   
	jr nz,l37eeh		;37cc	20 20		   
	jr nz,l37f0h		;37ce	20 20		   
	jr nz,$+34		;37d0	20 20		   
	jr nz,$+34		;37d2	20 20		   
	jr nz,l37f6h		;37d4	20 20		   
	jr nz,l37f8h		;37d6	20 20		   
	jr nz,l37fah		;37d8	20 20		   
	jr nz,l37fch		;37da	20 20		   
	jr nz,l37feh		;37dc	20 20		   
	jr nz,$+34		;37de	20 20		   
	jr nz,$+34		;37e0	20 20		   
l37e2h:
	jr nz,l3804h		;37e2	20 20		   
l37e4h:
	jr nz,$+34		;37e4	20 20		   
l37e6h:
	jr nz,$+126		;37e6	20 7c		  |
l37e8h:
	jr nz,$+34		;37e8	20 20		   
l37eah:
	jr nz,$+34		;37ea	20 20		   
l37ech:
	jr nz,$+34		;37ec	20 20		   
l37eeh:
	jr nz,l3810h		;37ee	20 20		   
l37f0h:
	ld c,b			;37f0	48		H
	jr nz,l3813h		;37f1	20 20		   
	jr nz,l3815h		;37f3	20 20		   
	ld a,h			;37f5	7c		|
l37f6h:
	jr nz,l3818h		;37f6	20 20		   
l37f8h:
	jr nz,l381ah		;37f8	20 20		   
l37fah:
	jr nz,$+34		;37fa	20 20		   
l37fch:
	inc h			;37fc	24		$
	inc h			;37fd	24		$
l37feh:
	inc h			;37fe	24		$
	jr nz,l3821h		;37ff	20 20		   
	jr nz,l3827h		;3801	20 24		  $
	inc h			;3803	24		$
l3804h:
	inc h			;3804	24		$
	ld (0c300h),hl		;3805	22 00 c3	" . .
	ld e,b			;3808	58		X
	jr c,$+95		;3809	38 5d		8 ]
	jr c,l382dh		;380b	38 20		8  
sub_380dh:
	ld (l3d3dh),hl		;380d	22 3d 3d	" = =
l3810h:
	dec a			;3810	3d		=
	dec a			;3811	3d		=
	dec l			;3812	2d		-
l3813h:
	dec l			;3813	2d		-
	dec l			;3814	2d		-
l3815h:
	dec l			;3815	2d		-
	dec l			;3816	2d		-
	dec l			;3817	2d		-
l3818h:
	dec a			;3818	3d		=
	dec a			;3819	3d		=
l381ah:
	dec a			;381a	3d		=
	jr nz,$+34		;381b	20 20		   
	jr nz,$+34		;381d	20 20		   
	jr nz,l3841h		;381f	20 20		   
l3821h:
	jr nz,l3843h		;3821	20 20		   
	jr nz,l3845h		;3823	20 20		   
	jr nz,$+34		;3825	20 20		   
l3827h:
	jr nz,$+34		;3827	20 20		   
	jr nz,$+34		;3829	20 20		   
	jr nz,l384dh		;382b	20 20		   
l382dh:
	jr nz,l384fh		;382d	20 20		   
	jr nz,$+34		;382f	20 20		   
	jr nz,l3853h		;3831	20 20		   
	jr nz,l3855h		;3833	20 20		   
	jr nz,$+34		;3835	20 20		   
	ld a,h			;3837	7c		|
	jr nz,l385ah		;3838	20 20		   
	jr nz,l385ch		;383a	20 20		   
	jr nz,l385eh		;383c	20 20		   
	jr nz,$+34		;383e	20 20		   
	ld c,b			;3840	48		H
l3841h:
	jr nz,l3863h		;3841	20 20		   
l3843h:
	jr nz,l3865h		;3843	20 20		   
l3845h:
	ld a,h			;3845	7c		|
	jr nz,$+34		;3846	20 20		   
	jr nz,$+34		;3848	20 20		   
	jr nz,l3870h		;384a	20 24		  $
	inc h			;384c	24		$
l384dh:
	inc h			;384d	24		$
	inc h			;384e	24		$
l384fh:
	inc h			;384f	24		$
	jr nz,l3876h		;3850	20 24		  $
	inc h			;3852	24		$
l3853h:
	inc h			;3853	24		$
	inc h			;3854	24		$
l3855h:
	inc h			;3855	24		$
	ld (0c300h),hl		;3856	22 00 c3	" . .
	xor c			;3859	a9		.
l385ah:
	jr c,$-80		;385a	38 ae		8 .
l385ch:
	jr c,l387eh		;385c	38 20		8  
l385eh:
	ld (l2020h),hl		;385e	22 20 20	"    
	jr nz,$+34		;3861	20 20		   
l3863h:
	jr nz,$+34		;3863	20 20		   
l3865h:
	jr nz,$+34		;3865	20 20		   
	jr nz,l3889h		;3867	20 20		   
	jr nz,l388bh		;3869	20 20		   
	ld a,h			;386b	7c		|
	jr nz,l388eh		;386c	20 20		   
	jr nz,l3890h		;386e	20 20		   
l3870h:
	jr nz,l3892h		;3870	20 20		   
	jr nz,$+63		;3872	20 3d		  =
	jr nz,l3896h		;3874	20 20		   
l3876h:
	jr nz,$+34		;3876	20 20		   
	jr nz,$+34		;3878	20 20		   
	jr nz,l389ch		;387a	20 20		   
	jr nz,l389eh		;387c	20 20		   
l387eh:
	jr nz,l38a0h		;387e	20 20		   
	jr nz,l38a2h		;3880	20 20		   
	jr nz,l38a4h		;3882	20 20		   
	jr nz,l38a6h		;3884	20 20		   
	jr nz,$+34		;3886	20 20		   
	ld a,h			;3888	7c		|
l3889h:
	jr nz,$+63		;3889	20 3d		  =
l388bh:
	dec a			;388b	3d		=
	dec a			;388c	3d		=
	dec a			;388d	3d		=
l388eh:
	dec a			;388e	3d		=
	dec a			;388f	3d		=
l3890h:
	dec a			;3890	3d		=
	dec a			;3891	3d		=
l3892h:
	dec a			;3892	3d		=
	dec a			;3893	3d		=
	dec a			;3894	3d		=
	dec a			;3895	3d		=
l3896h:
	dec a			;3896	3d		=
	jr nz,$+34		;3897	20 20		   
	jr nz,$+34		;3899	20 20		   
	dec a			;389b	3d		=
l389ch:
	dec a			;389c	3d		=
	dec a			;389d	3d		=
l389eh:
	dec a			;389e	3d		=
	dec a			;389f	3d		=
l38a0h:
	dec a			;38a0	3d		=
	dec a			;38a1	3d		=
l38a2h:
	dec a			;38a2	3d		=
	dec a			;38a3	3d		=
l38a4h:
	dec a			;38a4	3d		=
	dec a			;38a5	3d		=
l38a6h:
	dec a			;38a6	3d		=
	ld (0c300h),hl		;38a7	22 00 c3	" . .
	ret pe			;38aa	e8		.
	jr c,$-17		;38ab	38 ed		8 .
	jr c,l38cfh		;38ad	38 20		8  
	ld (l2020h),hl		;38af	22 20 20	"    
	jr nz,$+34		;38b2	20 20		   
	jr nz,$+34		;38b4	20 20		   
	jr nz,$+34		;38b6	20 20		   
	jr nz,$+34		;38b8	20 20		   
	jr nz,$+34		;38ba	20 20		   
	ld a,h			;38bc	7c		|
	jr nz,l38dfh		;38bd	20 20		   
	jr nz,l38e1h		;38bf	20 20		   
	jr nz,l38e3h		;38c1	20 20		   
	jr nz,$+38		;38c3	20 24		  $
	jr nz,l38e7h		;38c5	20 20		   
	jr nz,$+34		;38c7	20 20		   
	jr nz,l38ebh		;38c9	20 20		   
	jr nz,l38edh		;38cb	20 20		   
	jr nz,l38efh		;38cd	20 20		   
l38cfh:
	jr nz,l38f1h		;38cf	20 20		   
	jr nz,l38f3h		;38d1	20 20		   
	jr nz,l38f5h		;38d3	20 20		   
	jr nz,l38f7h		;38d5	20 20		   
	jr nz,l38f9h		;38d7	20 20		   
	jr nz,l3939h		;38d9	20 5e		  ^
	jr nz,l38fdh		;38db	20 20		   
	jr nz,l38ffh		;38dd	20 20		   
l38dfh:
	jr nz,l3901h		;38df	20 20		   
l38e1h:
	jr nz,l3903h		;38e1	20 20		   
l38e3h:
	jr nz,l3905h		;38e3	20 20		   
	ld h,022h		;38e5	26 22		& "
l38e7h:
	nop			;38e7	00		.
	jp 03929h		;38e8	c3 29 39	. ) 9
l38ebh:
	ld l,039h		;38eb	2e 39		. 9
l38edh:
	jr nz,l3911h		;38ed	20 22		  "
l38efh:
	jr nz,l3911h		;38ef	20 20		   
l38f1h:
	jr nz,l3913h		;38f1	20 20		   
l38f3h:
	jr nz,l3915h		;38f3	20 20		   
l38f5h:
	jr nz,l3917h		;38f5	20 20		   
l38f7h:
	jr nz,l3919h		;38f7	20 20		   
l38f9h:
	jr nz,l391bh		;38f9	20 20		   
	ld a,h			;38fb	7c		|
	ld e,(hl)		;38fc	5e		^
l38fdh:
	ld e,(hl)		;38fd	5e		^
	ld e,(hl)		;38fe	5e		^
l38ffh:
	ld e,(hl)		;38ff	5e		^
	ld e,(hl)		;3900	5e		^
l3901h:
	ld e,(hl)		;3901	5e		^
	ld e,(hl)		;3902	5e		^
l3903h:
	ld e,(hl)		;3903	5e		^
	ld e,(hl)		;3904	5e		^
l3905h:
	ld e,(hl)		;3905	5e		^
	ld e,(hl)		;3906	5e		^
	ld e,(hl)		;3907	5e		^
	ld e,(hl)		;3908	5e		^
	ld e,(hl)		;3909	5e		^
	jr nz,l392ch		;390a	20 20		   
	jr nz,l392eh		;390c	20 20		   
	jr nz,l3930h		;390e	20 20		   
	inc h			;3910	24		$
l3911h:
	jr nz,$+96		;3911	20 5e		  ^
l3913h:
	jr nz,l3935h		;3913	20 20		   
l3915h:
	jr nz,l3937h		;3915	20 20		   
l3917h:
	jr nz,l3939h		;3917	20 20		   
l3919h:
	jr nz,l393bh		;3919	20 20		   
l391bh:
	jr nz,l393dh		;391b	20 20		   
	jr nz,l393fh		;391d	20 20		   
	jr nz,l3941h		;391f	20 20		   
	dec a			;3921	3d		=
	dec a			;3922	3d		=
	dec a			;3923	3d		=
	dec a			;3924	3d		=
	dec a			;3925	3d		=
	dec a			;3926	3d		=
	ld (0c300h),hl		;3927	22 00 c3	" . .
	add a,c			;392a	81		.
	add hl,sp		;392b	39		9
l392ch:
	add a,(hl)		;392c	86		.
	add hl,sp		;392d	39		9
l392eh:
	jr nz,l3952h		;392e	20 22		  "
l3930h:
	ld hl,(l2020h)		;3930	2a 20 20	*    
	jr nz,l3955h		;3933	20 20		   
l3935h:
	jr nz,l3957h		;3935	20 20		   
l3937h:
	jr nz,l3959h		;3937	20 20		   
l3939h:
	jr nz,l395bh		;3939	20 20		   
l393bh:
	jr nz,l395dh		;393b	20 20		   
l393dh:
	jr nz,l395fh		;393d	20 20		   
l393fh:
	jr nz,l3961h		;393f	20 20		   
l3941h:
	jr nz,l3963h		;3941	20 20		   
	jr nz,$+48		;3943	20 2e		  .
	jr nz,l3967h		;3945	20 20		   
	jr nz,l3969h		;3947	20 20		   
	jr nz,l396bh		;3949	20 20		   
	ld h,020h		;394b	26 20		&  
	jr nz,$+34		;394d	20 20		   
	ld e,(hl)		;394f	5e		^
	jr nz,l399ah		;3950	20 48		  H
l3952h:
	ld hl,(l205dh+1)	;3952	2a 5e 20	* ^  
l3955h:
	jr nz,l3977h		;3955	20 20		   
l3957h:
	jr nz,l3979h		;3957	20 20		   
l3959h:
	jr nz,l397bh		;3959	20 20		   
l395bh:
	jr nz,l397dh		;395b	20 20		   
l395dh:
	jr nz,l397fh		;395d	20 20		   
l395fh:
	jr nz,$+34		;395f	20 20		   
l3961h:
	jr nz,l3983h		;3961	20 20		   
l3963h:
	jr nz,$+34		;3963	20 20		   
	jr nz,$+34		;3965	20 20		   
l3967h:
	jr nz,l39c7h		;3967	20 5e		  ^
l3969h:
	jr nz,l398bh		;3969	20 20		   
l396bh:
	ld e,(hl)		;396b	5e		^
	jr nz,l398eh		;396c	20 20		   
	jr nz,l3990h		;396e	20 20		   
	jr nz,l3992h		;3970	20 20		   
	jr nz,l39d2h		;3972	20 5e		  ^
	ld e,(hl)		;3974	5e		^
	ld e,(hl)		;3975	5e		^
	ld e,(hl)		;3976	5e		^
l3977h:
	ld e,(hl)		;3977	5e		^
	ld e,(hl)		;3978	5e		^
l3979h:
	ld e,(hl)		;3979	5e		^
	ld e,(hl)		;397a	5e		^
l397bh:
	ld e,(hl)		;397b	5e		^
	ld e,(hl)		;397c	5e		^
l397dh:
	ld e,(hl)		;397d	5e		^
	ld e,(hl)		;397e	5e		^
l397fh:
	ld (0c300h),hl		;397f	22 00 c3	" . .
	exx			;3982	d9		.
l3983h:
	add hl,sp		;3983	39		9
	sbc a,039h		;3984	de 39		. 9
	jr nz,l39aah		;3986	20 22		  "
	dec a			;3988	3d		=
	dec a			;3989	3d		=
	dec a			;398a	3d		=
l398bh:
	dec a			;398b	3d		=
	dec a			;398c	3d		=
	dec a			;398d	3d		=
l398eh:
	dec a			;398e	3d		=
	dec a			;398f	3d		=
l3990h:
	dec a			;3990	3d		=
	dec a			;3991	3d		=
l3992h:
	dec a			;3992	3d		=
	dec a			;3993	3d		=
	dec a			;3994	3d		=
	dec a			;3995	3d		=
	dec a			;3996	3d		=
	dec a			;3997	3d		=
	dec a			;3998	3d		=
	dec a			;3999	3d		=
l399ah:
	dec a			;399a	3d		=
	dec a			;399b	3d		=
	dec a			;399c	3d		=
	dec a			;399d	3d		=
	dec a			;399e	3d		=
	dec a			;399f	3d		=
	dec a			;39a0	3d		=
	dec a			;39a1	3d		=
	dec a			;39a2	3d		=
	dec a			;39a3	3d		=
	dec a			;39a4	3d		=
	dec a			;39a5	3d		=
	dec a			;39a6	3d		=
	dec a			;39a7	3d		=
	dec a			;39a8	3d		=
	dec a			;39a9	3d		=
l39aah:
	dec a			;39aa	3d		=
sub_39abh:
	dec a			;39ab	3d		=
	dec a			;39ac	3d		=
	dec a			;39ad	3d		=
	dec a			;39ae	3d		=
	dec a			;39af	3d		=
	dec a			;39b0	3d		=
	dec a			;39b1	3d		=
	dec a			;39b2	3d		=
	dec a			;39b3	3d		=
	dec a			;39b4	3d		=
	dec a			;39b5	3d		=
	dec a			;39b6	3d		=
	dec a			;39b7	3d		=
	dec a			;39b8	3d		=
	dec a			;39b9	3d		=
	dec a			;39ba	3d		=
	dec a			;39bb	3d		=
	dec a			;39bc	3d		=
	dec a			;39bd	3d		=
	dec a			;39be	3d		=
	dec a			;39bf	3d		=
	dec a			;39c0	3d		=
	dec a			;39c1	3d		=
	dec a			;39c2	3d		=
	dec a			;39c3	3d		=
	dec a			;39c4	3d		=
	dec a			;39c5	3d		=
	dec a			;39c6	3d		=
l39c7h:
	dec a			;39c7	3d		=
	dec a			;39c8	3d		=
	dec a			;39c9	3d		=
	dec a			;39ca	3d		=
	dec a			;39cb	3d		=
	dec a			;39cc	3d		=
	dec a			;39cd	3d		=
	dec a			;39ce	3d		=
	dec a			;39cf	3d		=
	dec a			;39d0	3d		=
	dec a			;39d1	3d		=
l39d2h:
	dec a			;39d2	3d		=
	dec a			;39d3	3d		=
	dec a			;39d4	3d		=
	dec a			;39d5	3d		=
	dec a			;39d6	3d		=
	ld (0c300h),hl		;39d7	22 00 c3	" . .
	jp po,l6439h		;39da	e2 39 64	. 9 d
	ld h,c			;39dd	61		a
	jr nz,l3a0dh		;39de	20 2d		  -
	ld sp,l3a00h		;39e0	31 00 3a	1 . :
	add a,b			;39e3	80		.
	nop			;39e4	00		.
sub_39e5h:
	ld l,a			;39e5	6f		o
	ld h,000h		;39e6	26 00		& .
	ld (l0f1ah),hl		;39e8	22 1a 0f	" . .
	ld de,l0f1ch		;39eb	11 1c 0f	. . .
	ld hl,l60fch		;39ee	21 fc 60	! . `
sub_39f1h:
	call string_assign	;39f1	cd db 74	. . t
	ld hl,(l0f1ah)		;39f4	2a 1a 0f	* . .
	ld (l0f1fh),hl		;39f7	22 1f 0f	" . .
	ld hl,00001h		;39fa	21 01 00	! . .
	jp l3a1dh		;39fd	c3 1d 3a	. . :
l3a00h:
	ld de,00080h		;3a00	11 80 00	. . .
	ld hl,(l0f1fh+2)	;3a03	2a 21 0f	* ! .
	add hl,de		;3a06	19		.
	ld l,(hl)		;3a07	6e		n
	ld h,000h		;3a08	26 00		& .
	call character_string	;3a0a	cd b5 75	. . u
l3a0dh:
	ld de,l0f1ch		;3a0d	11 1c 0f	. . .
	call sub_706eh		;3a10	cd 6e 70	. n p
	ld de,l0f1ch		;3a13	11 1c 0f	. . .
	call string_assign	;3a16	cd db 74	. . t
	ld hl,(l0f1fh+2)	;3a19	2a 21 0f	* ! .
	inc hl			;3a1c	23		#
l3a1dh:
	ld (l0f1fh+2),hl	;3a1d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;3a20	2a 21 0f	* ! .
	ex de,hl		;3a23	eb		.
	ld hl,(l0f1fh)		;3a24	2a 1f 0f	* . .
	ld a,d			;3a27	7a		z
	xor h			;3a28	ac		.
	ld a,h			;3a29	7c		|
	jp m,l3a31h		;3a2a	fa 31 3a	. 1 :
	ld a,l			;3a2d	7d		}
	sub e			;3a2e	93		.
	ld a,h			;3a2f	7c		|
	sbc a,d			;3a30	9a		.
l3a31h:
	rla			;3a31	17		.
	jp nc,l3a00h		;3a32	d2 00 3a	. . :
	call sub_8993h		;3a35	cd 93 89	. . .
	ld hl,s_key_r_upper	;3a38	21 f8 60	! . `
	call sub_8ab4h		;3a3b	cd b4 8a	. . .
l3a3eh:
	ld bc,00001h		;3a3e	01 01 00	. . .
	ld de,s_data_filename	;3a41	11 eb 60	. . `
	ld hl,00020h		;3a44	21 20 00	!   .
	call sub_8adch		;3a47	cd dc 8a	. . .
	ld hl,00001h		;3a4a	21 01 00	! . .
	call l6dd5h+2		;3a4d	cd d7 6d	. . m
	ld de,l0f23h		;3a50	11 23 0f	. # .
	ld hl,00020h		;3a53	21 20 00	!   .
	call sub_6dffh		;3a56	cd ff 6d	. . m
	ld de,00001h		;3a59	11 01 00	. . .
	ld hl,00001h		;3a5c	21 01 00	! . .
	call sub_8b2dh		;3a5f	cd 2d 8b	. - .
	ld hl,00001h		;3a62	21 01 00	! . .
	call sub_8574h		;3a65	cd 74 85	. t .
	ld a,h			;3a68	7c		|
	cpl			;3a69	2f		/
	ld h,a			;3a6a	67		g
	ld a,l			;3a6b	7d		}
	cpl			;3a6c	2f		/
	ld l,a			;3a6d	6f		o
	ld a,h			;3a6e	7c		|
	or l			;3a6f	b5		.
	jp nz,l3b2fh		;3a70	c2 2f 3b	. / ;
	ld hl,00001h		;3a73	21 01 00	! . .
	call sub_85f4h		;3a76	cd f4 85	. . .
	ld hl,s_data_filename	;3a79	21 eb 60	! . `
	call sub_89afh		;3a7c	cd af 89	. . .
	call print_setup	;3a7f	cd ea 6f	. . o
	ld hl,l613eh		;3a82	21 3e 61	! > a
	call print_string_line	;3a85	cd 92 6e	. . n
	call print_setup	;3a88	cd ea 6f	. . o
	ld hl,l613eh		;3a8b	21 3e 61	! > a
	call print_string_line	;3a8e	cd 92 6e	. . n
	call print_setup	;3a91	cd ea 6f	. . o
	ld hl,s_not_configured	;3a94	21 d3 60	! . `
	call print_string_line	;3a97	cd 92 6e	. . n
l3a9ah:
	ld hl,s_key_r_upper	;3a9a	21 f8 60	! . `
	call sub_8ab4h		;3a9d	cd b4 8a	. . .
	ld bc,00001h		;3aa0	01 01 00	. . .
	ld de,s_ladconf_filename	;3aa3	11 c5 60	. . `
	ld hl,00020h		;3aa6	21 20 00	!   .
	call sub_8adch		;3aa9	cd dc 8a	. . .
	ld hl,00001h		;3aac	21 01 00	! . .
	call l6dd5h+2		;3aaf	cd d7 6d	. . m
	ld de,l0f23h		;3ab2	11 23 0f	. # .
	ld hl,00020h		;3ab5	21 20 00	!   .
	call sub_6dffh		;3ab8	cd ff 6d	. . m
	ld de,00001h		;3abb	11 01 00	. . .
	ld hl,00001h		;3abe	21 01 00	! . .
	call sub_8b2dh		;3ac1	cd 2d 8b	. - .
	ld hl,00001h		;3ac4	21 01 00	! . .
	call sub_8574h		;3ac7	cd 74 85	. t .
	ld a,h			;3aca	7c		|
	cpl			;3acb	2f		/
	ld h,a			;3acc	67		g
	ld a,l			;3acd	7d		}
	cpl			;3ace	2f		/
	ld l,a			;3acf	6f		o
	ld a,h			;3ad0	7c		|
	or l			;3ad1	b5		.
	jp nz,l3b08h		;3ad2	c2 08 3b	. . ;
	ld hl,00001h		;3ad5	21 01 00	! . .
	call sub_85f4h		;3ad8	cd f4 85	. . .
	ld hl,s_ladconf_filename	;3adb	21 c5 60	! . `
	call sub_89afh		;3ade	cd af 89	. . .
	call print_setup	;3ae1	cd ea 6f	. . o
	ld hl,l613eh		;3ae4	21 3e 61	! > a
	call print_string_line	;3ae7	cd 92 6e	. . n
	call print_setup	;3aea	cd ea 6f	. . o
	ld hl,l613eh		;3aed	21 3e 61	! > a
	call print_string_line	;3af0	cd 92 6e	. . n
	call print_setup	;3af3	cd ea 6f	. . o
	ld hl,s_config_link_error	;3af6	21 a5 60	! . `
	call print_string_line	;3af9	cd 92 6e	. . n
	call print_setup	;3afc	cd ea 6f	. . o
	ld hl,s_config_missing	;3aff	21 7e 60	! ~ `
	call print_string_line	;3b02	cd 92 6e	. . n
	call program_end	;3b05	cd bb 68	. . h
l3b08h:
	ld hl,00001h		;3b08	21 01 00	! . .
	call sub_85f4h		;3b0b	cd f4 85	. . .
	call print_setup	;3b0e	cd ea 6f	. . o
	ld hl,l613eh		;3b11	21 3e 61	! > a
	call print_string_line	;3b14	cd 92 6e	. . n
	call print_setup	;3b17	cd ea 6f	. . o
	ld hl,l613eh		;3b1a	21 3e 61	! > a
	call print_string_line	;3b1d	cd 92 6e	. . n
	call print_setup	;3b20	cd ea 6f	. . o
	ld hl,s_linking_config	;3b23	21 58 60	! X `
	call print_string_line	;3b26	cd 92 6e	. . n
	ld hl,s_ladconf_name	;3b29	21 4e 60	! N `
	call sub_6754h		;3b2c	cd 54 67	. T g
l3b2fh:
	ld de,l0f23h		;3b2f	11 23 0f	. # .
	ld hl,00001h		;3b32	21 01 00	! . .
	call sub_744dh		;3b35	cd 4d 74	. M t
	call sub_71dfh		;3b38	cd df 71	. . q
	ld (l0f26h),hl		;3b3b	22 26 0f	" & .
	ld bc,l0f23h		;3b3e	01 23 0f	. # .
	ld de,00002h		;3b41	11 02 00	. . .
	ld hl,(l0f26h)		;3b44	2a 26 0f	* & .
	call sub_747fh		;3b47	cd 7f 74	. . t
	ld de,l0f26h+2		;3b4a	11 28 0f	. ( .
	call string_assign	;3b4d	cd db 74	. . t
	ld de,00001h		;3b50	11 01 00	. . .
	ld hl,00002h		;3b53	21 02 00	! . .
	call sub_8b2dh		;3b56	cd 2d 8b	. - .
	ld de,l0f23h		;3b59	11 23 0f	. # .
	ld hl,00001h		;3b5c	21 01 00	! . .
	call sub_744dh		;3b5f	cd 4d 74	. M t
	call sub_71dfh		;3b62	cd df 71	. . q
	ld (l0f26h),hl		;3b65	22 26 0f	" & .
	ld bc,l0f23h		;3b68	01 23 0f	. # .
	ld de,00002h		;3b6b	11 02 00	. . .
	ld hl,(l0f26h)		;3b6e	2a 26 0f	* & .
	call sub_747fh		;3b71	cd 7f 74	. . t
	ld de,l0f2bh		;3b74	11 2b 0f	. + .
	call string_assign	;3b77	cd db 74	. . t
	ld de,00001h		;3b7a	11 01 00	. . .
	ld hl,00003h		;3b7d	21 03 00	! . .
	call sub_8b2dh		;3b80	cd 2d 8b	. - .
	ld de,l0f23h		;3b83	11 23 0f	. # .
	ld hl,00001h		;3b86	21 01 00	! . .
	call sub_744dh		;3b89	cd 4d 74	. M t
	call sub_71dfh		;3b8c	cd df 71	. . q
	ld (l0f26h),hl		;3b8f	22 26 0f	" & .
	ld bc,l0f23h		;3b92	01 23 0f	. # .
	ld de,00002h		;3b95	11 02 00	. . .
	ld hl,(l0f26h)		;3b98	2a 26 0f	* & .
	call sub_747fh		;3b9b	cd 7f 74	. . t
	ld de,00f2eh		;3b9e	11 2e 0f	. . .
	call string_assign	;3ba1	cd db 74	. . t
	ld de,00001h		;3ba4	11 01 00	. . .
	ld hl,00004h		;3ba7	21 04 00	! . .
	call sub_8b2dh		;3baa	cd 2d 8b	. - .
	ld de,l0f23h		;3bad	11 23 0f	. # .
	ld hl,00001h		;3bb0	21 01 00	! . .
	call sub_744dh		;3bb3	cd 4d 74	. M t
	call sub_71dfh		;3bb6	cd df 71	. . q
	ld (l0f26h),hl		;3bb9	22 26 0f	" & .
	ld bc,l0f23h		;3bbc	01 23 0f	. # .
	ld de,00002h		;3bbf	11 02 00	. . .
	ld hl,(l0f26h)		;3bc2	2a 26 0f	* & .
	call sub_747fh		;3bc5	cd 7f 74	. . t
	ld de,l0f31h		;3bc8	11 31 0f	. 1 .
	call string_assign	;3bcb	cd db 74	. . t
	ld de,00001h		;3bce	11 01 00	. . .
	ld hl,00005h		;3bd1	21 05 00	! . .
	call sub_8b2dh		;3bd4	cd 2d 8b	. - .
	ld de,l0f23h		;3bd7	11 23 0f	. # .
	ld hl,00001h		;3bda	21 01 00	! . .
	call sub_744dh		;3bdd	cd 4d 74	. M t
	call sub_71dfh		;3be0	cd df 71	. . q
	ld (l0f26h),hl		;3be3	22 26 0f	" & .
	ld bc,l0f23h		;3be6	01 23 0f	. # .
	ld de,00002h		;3be9	11 02 00	. . .
	ld hl,(l0f26h)		;3bec	2a 26 0f	* & .
	call sub_747fh		;3bef	cd 7f 74	. . t
	ld de,l0f34h		;3bf2	11 34 0f	. 4 .
	call string_assign	;3bf5	cd db 74	. . t
	ld de,00001h		;3bf8	11 01 00	. . .
	ld hl,00006h		;3bfb	21 06 00	! . .
	call sub_8b2dh		;3bfe	cd 2d 8b	. - .
	ld de,l0f23h		;3c01	11 23 0f	. # .
	ld hl,00001h		;3c04	21 01 00	! . .
	call sub_744dh		;3c07	cd 4d 74	. M t
	call sub_71dfh		;3c0a	cd df 71	. . q
	ld (l0f26h),hl		;3c0d	22 26 0f	" & .
	ld bc,l0f23h		;3c10	01 23 0f	. # .
	ld de,00002h		;3c13	11 02 00	. . .
	ld hl,(l0f26h)		;3c16	2a 26 0f	* & .
	call sub_747fh		;3c19	cd 7f 74	. . t
	ld de,l0f37h		;3c1c	11 37 0f	. 7 .
	call string_assign	;3c1f	cd db 74	. . t
	ld de,00001h		;3c22	11 01 00	. . .
	ld hl,00007h		;3c25	21 07 00	! . .
	call sub_8b2dh		;3c28	cd 2d 8b	. - .
	ld de,l0f23h		;3c2b	11 23 0f	. # .
	ld hl,00001h		;3c2e	21 01 00	! . .
	call sub_744dh		;3c31	cd 4d 74	. M t
	ld de,l0f3ah		;3c34	11 3a 0f	. : .
	call string_assign	;3c37	cd db 74	. . t
	ld bc,l0f23h		;3c3a	01 23 0f	. # .
	ld de,00002h		;3c3d	11 02 00	. . .
	ld hl,00001h		;3c40	21 01 00	! . .
	call sub_747fh		;3c43	cd 7f 74	. . t
	ld de,00f3dh		;3c46	11 3d 0f	. = .
	call string_assign	;3c49	cd db 74	. . t
	ld bc,l0f23h		;3c4c	01 23 0f	. # .
	ld de,00003h		;3c4f	11 03 00	. . .
	ld hl,00002h		;3c52	21 02 00	! . .
	call sub_747fh		;3c55	cd 7f 74	. . t
	call sub_70f1h		;3c58	cd f1 70	. . p
	ld (l0f40h),hl		;3c5b	22 40 0f	" @ .
	ld bc,l0f23h		;3c5e	01 23 0f	. # .
	ld de,00005h		;3c61	11 05 00	. . .
	ld hl,00002h		;3c64	21 02 00	! . .
	call sub_747fh		;3c67	cd 7f 74	. . t
	call sub_70f1h		;3c6a	cd f1 70	. . p
	ld (00f42h),hl		;3c6d	22 42 0f	" B .
	ld bc,l0f23h		;3c70	01 23 0f	. # .
	ld de,00007h		;3c73	11 07 00	. . .
	ld hl,00001h		;3c76	21 01 00	! . .
	call sub_747fh		;3c79	cd 7f 74	. . t
	call sub_71dfh		;3c7c	cd df 71	. . q
	ld (l0f44h),hl		;3c7f	22 44 0f	" D .
	ld de,00001h		;3c82	11 01 00	. . .
	ld hl,00008h		;3c85	21 08 00	! . .
	call sub_8b2dh		;3c88	cd 2d 8b	. - .
	ld de,l0f23h		;3c8b	11 23 0f	. # .
	ld hl,00004h		;3c8e	21 04 00	! . .
	call sub_744dh		;3c91	cd 4d 74	. M t
	ld de,l0f46h		;3c94	11 46 0f	. F .
	call string_assign	;3c97	cd db 74	. . t
	ld de,l0f46h		;3c9a	11 46 0f	. F .
	ld hl,00001h		;3c9d	21 01 00	! . .
	call sub_7462h		;3ca0	cd 62 74	. b t
	ld de,l0f46h		;3ca3	11 46 0f	. F .
	push hl			;3ca6	e5		.
	ld hl,00003h		;3ca7	21 03 00	! . .
	call sub_744dh		;3caa	cd 4d 74	. M t
	pop de			;3cad	d1		.
	call sub_706eh		;3cae	cd 6e 70	. n p
	ld de,l0f46h		;3cb1	11 46 0f	. F .
	call string_assign	;3cb4	cd db 74	. . t
	ld hl,00001h		;3cb7	21 01 00	! . .
	jp l3d41h		;3cba	c3 41 3d	. A =
l3cbdh:
	ld de,00008h		;3cbd	11 08 00	. . .
	ld hl,(l0f1fh+2)	;3cc0	2a 21 0f	* ! .
	add hl,de		;3cc3	19		.
	ld de,00001h		;3cc4	11 01 00	. . .
	call sub_8b2dh		;3cc7	cd 2d 8b	. - .
	ld de,l0f23h		;3cca	11 23 0f	. # .
	ld hl,00001h		;3ccd	21 01 00	! . .
	call sub_744dh		;3cd0	cd 4d 74	. M t
	call sub_71dfh		;3cd3	cd df 71	. . q
	ld (l0f26h),hl		;3cd6	22 26 0f	" & .
	ld hl,(l0f26h)		;3cd9	2a 26 0f	* & .
	ld a,h			;3cdc	7c		|
	or l			;3cdd	b5		.
	jp nz,l3d04h		;3cde	c2 04 3d	. . =
	ld hl,(l0f1fh+2)	;3ce1	2a 21 0f	* ! .
	add hl,hl		;3ce4	29		)
	ld de,l0ee8h		;3ce5	11 e8 0e	. . .
	add hl,de		;3ce8	19		.
	ld de,0ffffh		;3ce9	11 ff ff	. . .
	ld (hl),e		;3cec	73		s
	inc hl			;3ced	23		#
	ld (hl),d		;3cee	72		r
	ld hl,(l0f1fh+2)	;3cef	2a 21 0f	* ! .
	call integer_mul_inline	;3cf2	cd 8e 76	. . v
	defw 00003h		;3cf5	03 00		. .
	ld de,00ed6h		;3cf7	11 d6 0e	. . .
	add hl,de		;3cfa	19		.
	ld de,l604bh		;3cfb	11 4b 60	. K `
	call sub_750eh		;3cfe	cd 0e 75	. . u
	jp l3d3dh		;3d01	c3 3d 3d	. = =
l3d04h:
	ld bc,l0f23h		;3d04	01 23 0f	. # .
	ld de,00002h		;3d07	11 02 00	. . .
	ld h,d			;3d0a	62		b
	ld l,e			;3d0b	6b		k
	call sub_747fh		;3d0c	cd 7f 74	. . t
	call sub_70f1h		;3d0f	cd f1 70	. . p
	push hl			;3d12	e5		.
	ld hl,(l0f1fh+2)	;3d13	2a 21 0f	* ! .
	add hl,hl		;3d16	29		)
	ld de,l0ee8h		;3d17	11 e8 0e	. . .
	add hl,de		;3d1a	19		.
	pop de			;3d1b	d1		.
	ld (hl),e		;3d1c	73		s
	inc hl			;3d1d	23		#
	ld (hl),d		;3d1e	72		r
	ld hl,(l0f1fh+2)	;3d1f	2a 21 0f	* ! .
	call integer_mul_inline	;3d22	cd 8e 76	. . v
	defw 00003h		;3d25	03 00		. .
	ld de,00ed6h		;3d27	11 d6 0e	. . .
	add hl,de		;3d2a	19		.
	ld bc,l0f23h		;3d2b	01 23 0f	. # .
	ld de,00004h		;3d2e	11 04 00	. . .
	push hl			;3d31	e5		.
	ld hl,(l0f26h)		;3d32	2a 26 0f	* & .
	call sub_747fh		;3d35	cd 7f 74	. . t
	ex de,hl		;3d38	eb		.
	pop hl			;3d39	e1		.
	call sub_750eh		;3d3a	cd 0e 75	. . u
l3d3dh:
	ld hl,(l0f1fh+2)	;3d3d	2a 21 0f	* ! .
	inc hl			;3d40	23		#
l3d41h:
	ld (l0f1fh+2),hl	;3d41	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;3d44	2a 21 0f	* ! .
	ld de,0fffah		;3d47	11 fa ff	. . .
	ld a,h			;3d4a	7c		|
	rla			;3d4b	17		.
	jp c,l3d51h		;3d4c	da 51 3d	. Q =
	add hl,de		;3d4f	19		.
	add hl,hl		;3d50	29		)
l3d51h:
	jp c,l3cbdh		;3d51	da bd 3c	. . <
	ld hl,00001h		;3d54	21 01 00	! . .
	call sub_85f4h		;3d57	cd f4 85	. . .
	call print_setup	;3d5a	cd ea 6f	. . o
	ld hl,l0f34h		;3d5d	21 34 0f	! 4 .
	call print_string	;3d60	cd 6e 6e	. n n
	ld de,00f2eh		;3d63	11 2e 0f	. . .
	ld hl,l0f2bh		;3d66	21 2b 0f	! + .
	call 06216h		;3d69	cd 16 62	. . b
	ld hl,l0f31h		;3d6c	21 31 0f	! 1 .
	call sub_6247h		;3d6f	cd 47 62	. G b
	ld bc,00f42h		;3d72	01 42 0f	. B .
	ld de,l0f40h		;3d75	11 40 0f	. @ .
	ld hl,l0f44h		;3d78	21 44 0f	! D .
	call sub_625eh		;3d7b	cd 5e 62	. ^ b
	ld de,l0f3ah		;3d7e	11 3a 0f	. : .
	ld hl,s_yes		;3d81	21 47 60	! G `
	call branch_if_strings_unequal	;3d84	cd b8 73	. . s
	sbc a,b			;3d87	98		.
	dec a			;3d88	3d		=
	ld hl,00007h		;3d89	21 07 00	! . .
	call character_string	;3d8c	cd b5 75	. . u
	ld de,l0f49h		;3d8f	11 49 0f	. I .
	call string_assign	;3d92	cd db 74	. . t
	jp l3da1h		;3d95	c3 a1 3d	. . =
	ld de,l0f49h		;3d98	11 49 0f	. I .
	ld hl,l6044h		;3d9b	21 44 60	! D `
	call string_assign	;3d9e	cd db 74	. . t
l3da1h:
	ld de,00f3dh		;3da1	11 3d 0f	. = .
	ld hl,s_yes		;3da4	21 47 60	! G `
	call branch_if_strings_unequal	;3da7	cd b8 73	. . s
	or l			;3daa	b5		.
	dec a			;3dab	3d		=
	ld hl,(l0ef6h)		;3dac	2a f6 0e	* . .
	ld (l0f4ch),hl		;3daf	22 4c 0f	" L .
	jp l3dbbh		;3db2	c3 bb 3d	. . =
	ld hl,(l0ef4h)		;3db5	2a f4 0e	* . .
	ld (l0f4ch),hl		;3db8	22 4c 0f	" L .
l3dbbh:
	ld de,l0f1ch		;3dbb	11 1c 0f	. . .
	ld hl,s_terminal_pro_level	;3dbe	21 38 60	! 8 `
	call l7155h+1		;3dc1	cd 56 71	. V q
	ld (l0f1fh+2),hl	;3dc4	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;3dc7	2a 21 0f	* ! .
	ld a,h			;3dca	7c		|
	add a,a			;3dcb	87		.
	jp c,l3dd2h		;3dcc	da d2 3d	. . =
	or l			;3dcf	b5		.
	sub 001h		;3dd0	d6 01		. .
l3dd2h:
	ccf			;3dd2	3f		?
	sbc a,a			;3dd3	9f		.
	ld h,a			;3dd4	67		g
	ld l,a			;3dd5	6f		o
	ld (l0f4ch+2),hl	;3dd6	22 4e 0f	" N .
	ld hl,(l0f1fh+2)	;3dd9	2a 21 0f	* ! .
	ld a,h			;3ddc	7c		|
	or l			;3ddd	b5		.
	jp nz,l3deah		;3dde	c2 ea 3d	. . =
	ld hl,00002h		;3de1	21 02 00	! . .
	ld (00f50h),hl		;3de4	22 50 0f	" P .
	jp l3e04h		;3de7	c3 04 3e	. . >
l3deah:
	ld de,00009h		;3dea	11 09 00	. . .
	ld hl,(l0f1fh+2)	;3ded	2a 21 0f	* ! .
	add hl,de		;3df0	19		.
	ex de,hl		;3df1	eb		.
	ld bc,l0f1ch		;3df2	01 1c 0f	. . .
	ld hl,000ffh		;3df5	21 ff 00	! . .
	call sub_747fh		;3df8	cd 7f 74	. . t
	call sub_7324h		;3dfb	cd 24 73	. $ s
	call sub_7623h		;3dfe	cd 23 76	. # v
	ld (00f50h),hl		;3e01	22 50 0f	" P .
l3e04h:
	ld de,l0f1ch		;3e04	11 1c 0f	. . .
	ld hl,s_terminal_pro_men	;3e07	21 2e 60	! . `
	call l7155h+1		;3e0a	cd 56 71	. V q
	ld (l0f1fh+2),hl	;3e0d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;3e10	2a 21 0f	* ! .
	ld a,h			;3e13	7c		|
	add a,a			;3e14	87		.
	jp c,l3e1bh		;3e15	da 1b 3e	. . >
	or l			;3e18	b5		.
	sub 001h		;3e19	d6 01		. .
l3e1bh:
	ccf			;3e1b	3f		?
	sbc a,a			;3e1c	9f		.
	ld h,a			;3e1d	67		g
	ld l,a			;3e1e	6f		o
	ex de,hl		;3e1f	eb		.
	ld hl,(l0f4ch+2)	;3e20	2a 4e 0f	* N .
	ld a,h			;3e23	7c		|
	or d			;3e24	b2		.
	ld h,a			;3e25	67		g
	ld a,l			;3e26	7d		}
	or e			;3e27	b3		.
	ld l,a			;3e28	6f		o
	ld (l0f4ch+2),hl	;3e29	22 4e 0f	" N .
	ld hl,(l0f1fh+2)	;3e2c	2a 21 0f	* ! .
	ld a,h			;3e2f	7c		|
	or l			;3e30	b5		.
	jp nz,l3e3dh		;3e31	c2 3d 3e	. = >
	ld hl,(l0f09h)		;3e34	2a 09 0f	* . .
	ld (l0f52h),hl		;3e37	22 52 0f	" R .
	jp l3e57h		;3e3a	c3 57 3e	. W >
l3e3dh:
	ld de,00007h		;3e3d	11 07 00	. . .
	ld hl,(l0f1fh+2)	;3e40	2a 21 0f	* ! .
	add hl,de		;3e43	19		.
	ex de,hl		;3e44	eb		.
	ld bc,l0f1ch		;3e45	01 1c 0f	. . .
	ld hl,000ffh		;3e48	21 ff 00	! . .
	call sub_747fh		;3e4b	cd 7f 74	. . t
	call sub_7324h		;3e4e	cd 24 73	. $ s
	call sub_7623h		;3e51	cd 23 76	. # v
	ld (l0f52h),hl		;3e54	22 52 0f	" R .
l3e57h:
	ld de,l0f1ch		;3e57	11 1c 0f	. . .
	ld hl,s_terminal_pro_score	;3e5a	21 22 60	! " `
	call l7155h+1		;3e5d	cd 56 71	. V q
	ld (l0f1fh+2),hl	;3e60	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;3e63	2a 21 0f	* ! .
	ld a,h			;3e66	7c		|
	add a,a			;3e67	87		.
	jp c,l3e6eh		;3e68	da 6e 3e	. n >
	or l			;3e6b	b5		.
	sub 001h		;3e6c	d6 01		. .
l3e6eh:
	ccf			;3e6e	3f		?
	sbc a,a			;3e6f	9f		.
	ld h,a			;3e70	67		g
	ld l,a			;3e71	6f		o
	ex de,hl		;3e72	eb		.
	ld hl,(l0f4ch+2)	;3e73	2a 4e 0f	* N .
	ld a,h			;3e76	7c		|
	or d			;3e77	b2		.
	ld h,a			;3e78	67		g
	ld a,l			;3e79	7d		}
	or e			;3e7a	b3		.
	ld l,a			;3e7b	6f		o
	ld (l0f4ch+2),hl	;3e7c	22 4e 0f	" N .
	ld hl,(l0f1fh+2)	;3e7f	2a 21 0f	* ! .
	ld a,h			;3e82	7c		|
	or l			;3e83	b5		.
	jp nz,l3e90h		;3e84	c2 90 3e	. . >
	ld hl,00000h		;3e87	21 00 00	! . .
	ld (00f54h),hl		;3e8a	22 54 0f	" T .
	jp l3eafh		;3e8d	c3 af 3e	. . >
l3e90h:
	ld de,00009h		;3e90	11 09 00	. . .
	ld hl,(l0f1fh+2)	;3e93	2a 21 0f	* ! .
	add hl,de		;3e96	19		.
	ex de,hl		;3e97	eb		.
	ld bc,l0f1ch		;3e98	01 1c 0f	. . .
	ld hl,000ffh		;3e9b	21 ff 00	! . .
	call sub_747fh		;3e9e	cd 7f 74	. . t
	call sub_7324h		;3ea1	cd 24 73	. $ s
	call sub_743bh		;3ea4	cd 3b 74	. ; t
	ld e,c			;3ea7	59		Y
	ld h,c			;3ea8	61		a
	call sub_7623h		;3ea9	cd 23 76	. # v
	ld (00f54h),hl		;3eac	22 54 0f	" T .
l3eafh:
	call print_setup	;3eaf	cd ea 6f	. . o
	ld hl,l0f37h		;3eb2	21 37 0f	! 7 .
	call print_string_line	;3eb5	cd 92 6e	. . n
	ld hl,0000fh		;3eb8	21 0f 00	! . .
	call sub_7570h		;3ebb	cd 70 75	. p u
	ld de,l0f56h		;3ebe	11 56 0f	. V .
	call string_assign	;3ec1	cd db 74	. . t
	call print_setup	;3ec4	cd ea 6f	. . o
	ld hl,l0f56h		;3ec7	21 56 0f	! V .
	call print_string	;3eca	cd 6e 6e	. n n
	call print_setup	;3ecd	cd ea 6f	. . o
	ld hl,s_menu_logo_row_1	;3ed0	21 fd 5f	! . _
	call print_string_line	;3ed3	cd 92 6e	. . n
	call print_setup	;3ed6	cd ea 6f	. . o
	ld hl,l0f56h		;3ed9	21 56 0f	! V .
	call print_string	;3edc	cd 6e 6e	. n n
	call print_setup	;3edf	cd ea 6f	. . o
	ld hl,s_menu_logo_row_1	;3ee2	21 fd 5f	! . _
	call print_string_line	;3ee5	cd 92 6e	. . n
	call print_setup	;3ee8	cd ea 6f	. . o
	ld hl,l0f56h		;3eeb	21 56 0f	! V .
	call print_string	;3eee	cd 6e 6e	. n n
	call print_setup	;3ef1	cd ea 6f	. . o
	ld hl,s_menu_logo_row_2	;3ef4	21 c6 5f	! . _
	call print_string_line	;3ef7	cd 92 6e	. . n
	call print_setup	;3efa	cd ea 6f	. . o
	ld hl,l0f56h		;3efd	21 56 0f	! V .
	call print_string	;3f00	cd 6e 6e	. n n
	call print_setup	;3f03	cd ea 6f	. . o
	ld hl,s_menu_logo_row_3	;3f06	21 8e 5f	! . _
	call print_string_line	;3f09	cd 92 6e	. . n
	call print_setup	;3f0c	cd ea 6f	. . o
	ld hl,l0f56h		;3f0f	21 56 0f	! V .
	call print_string	;3f12	cd 6e 6e	. n n
	call print_setup	;3f15	cd ea 6f	. . o
	ld hl,s_menu_logo_row_4	;3f18	21 5c 5f	! \ _
	call print_string_line	;3f1b	cd 92 6e	. . n
	call print_setup	;3f1e	cd ea 6f	. . o
	ld hl,l0f56h		;3f21	21 56 0f	! V .
	call print_string	;3f24	cd 6e 6e	. n n
	call print_setup	;3f27	cd ea 6f	. . o
	ld hl,s_menu_logo_row_5	;3f2a	21 2a 5f	! * _
	call print_string_line	;3f2d	cd 92 6e	. . n
	call print_setup	;3f30	cd ea 6f	. . o
	ld hl,l0f56h		;3f33	21 56 0f	! V .
	call print_string	;3f36	cd 6e 6e	. n n
	call print_setup	;3f39	cd ea 6f	. . o
	ld hl,s_menu_logo_row_6	;3f3c	21 f8 5e	! . ^
	call print_string_line	;3f3f	cd 92 6e	. . n
	call print_setup	;3f42	cd ea 6f	. . o
	ld hl,l613eh		;3f45	21 3e 61	! > a
	call print_string_line	;3f48	cd 92 6e	. . n
	call print_setup	;3f4b	cd ea 6f	. . o
	ld hl,s_copyright	;3f4e	21 de 5e	! . ^
	call print_string_line	;3f51	cd 92 6e	. . n
	call print_setup	;3f54	cd ea 6f	. . o
	ld hl,s_version_heading	;3f57	21 d1 5e	! . ^
	call print_string	;3f5a	cd 6e 6e	. n n
	ld hl,l0ef8h		;3f5d	21 f8 0e	! . .
	call print_string_line	;3f60	cd 92 6e	. . n
	call print_setup	;3f63	cd ea 6f	. . o
	ld hl,s_terminal_heading	;3f66	21 c4 5e	! . ^
	call print_string	;3f69	cd 6e 6e	. n n
	ld hl,l0f26h+2		;3f6c	21 28 0f	! ( .
	call print_string_line	;3f6f	cd 92 6e	. . n
	call print_setup	;3f72	cd ea 6f	. . o
	ld hl,l613eh		;3f75	21 3e 61	! > a
	call print_string_line	;3f78	cd 92 6e	. . n
	call print_setup	;3f7b	cd ea 6f	. . o
	ld hl,s_menu_play_option	;3f7e	21 b4 5e	! . ^
	call print_string_line	;3f81	cd 92 6e	. . n
	call print_setup	;3f84	cd ea 6f	. . o
	ld hl,s_menu_difficulty_option	;3f87	21 93 5e	! . ^
	call print_string_line	;3f8a	cd 92 6e	. . n
	call print_setup	;3f8d	cd ea 6f	. . o
	ld hl,s_menu_configure_option	;3f90	21 7c 5e	! | ^
	call print_string_line	;3f93	cd 92 6e	. . n
	call print_setup	;3f96	cd ea 6f	. . o
	ld hl,s_menu_instructions_option	;3f99	21 69 5e	! i ^
	call print_string_line	;3f9c	cd 92 6e	. . n
	call print_setup	;3f9f	cd ea 6f	. . o
	ld hl,s_menu_exit_option	;3fa2	21 57 5e	! W ^
	call print_string_line	;3fa5	cd 92 6e	. . n
	ld hl,00028h		;3fa8	21 28 00	! ( .
	ld (l0f59h),hl		;3fab	22 59 0f	" Y .
	ld hl,0000bh		;3fae	21 0b 00	! . .
	ld (l0f5bh),hl		;3fb1	22 5b 0f	" [ .
	ld de,l0f5bh		;3fb4	11 5b 0f	. [ .
	ld hl,l0f59h		;3fb7	21 59 0f	! Y .
	call sub_626bh		;3fba	cd 6b 62	. k b
	call print_setup	;3fbd	cd ea 6f	. . o
	ld hl,s_up_key_hint	;3fc0	21 4f 5e	! O ^
	call print_string	;3fc3	cd 6e 6e	. n n
	ld de,l0f46h		;3fc6	11 46 0f	. F .
	ld hl,00001h		;3fc9	21 01 00	! . .
	call sub_744dh		;3fcc	cd 4d 74	. M t
	call print_string	;3fcf	cd 6e 6e	. n n
	ld hl,s_down_key_hint	;3fd2	21 43 5e	! C ^
	call print_string	;3fd5	cd 6e 6e	. n n
	ld bc,l0f46h		;3fd8	01 46 0f	. F .
	ld de,00002h		;3fdb	11 02 00	. . .
	ld hl,00001h		;3fde	21 01 00	! . .
	call sub_747fh		;3fe1	cd 7f 74	. . t
	call print_string	;3fe4	cd 6e 6e	. n n
	call print_setup	;3fe7	cd ea 6f	. . o
	ld hl,s_left_key_hint	;3fea	21 37 5e	! 7 ^
	call print_string	;3fed	cd 6e 6e	. n n
	ld bc,l0f46h		;3ff0	01 46 0f	. F .
	ld de,00003h		;3ff3	11 03 00	. . .
	ld hl,00001h		;3ff6	21 01 00	! . .
	call sub_747fh		;3ff9	cd 7f 74	. . t
	call print_string	;3ffc	cd 6e 6e	. n n
	ld hl,s_right_key_hint	;3fff	21 2a 5e	! * ^
	call print_string	;4002	cd 6e 6e	. n n
	ld bc,l0f46h		;4005	01 46 0f	. F .
	ld de,00004h		;4008	11 04 00	. . .
	ld hl,00001h		;400b	21 01 00	! . .
	call sub_747fh		;400e	cd 7f 74	. . t
	call print_string	;4011	cd 6e 6e	. n n
	ld hl,0000ch		;4014	21 0c 00	! . .
	ld (l0f5bh),hl		;4017	22 5b 0f	" [ .
	ld de,l0f5bh		;401a	11 5b 0f	. [ .
	ld hl,l0f59h		;401d	21 59 0f	! Y .
	call sub_626bh		;4020	cd 6b 62	. k b
	call print_setup	;4023	cd ea 6f	. . o
	ld hl,s_jump_key_hint	;4026	21 1b 5e	! . ^
	call print_string	;4029	cd 6e 6e	. n n
	ld hl,00028h		;402c	21 28 00	! ( .
	ld (l0f59h),hl		;402f	22 59 0f	" Y .
	ld hl,0000eh		;4032	21 0e 00	! . .
	ld (l0f5bh),hl		;4035	22 5b 0f	" [ .
	ld de,l0f5bh		;4038	11 5b 0f	. [ .
	ld hl,l0f59h		;403b	21 59 0f	! Y .
l403eh:
	call sub_626bh		;403e	cd 6b 62	. k b
	call print_setup	;4041	cd ea 6f	. . o
	ld hl,s_high_scores_heading	;4044	21 0d 5e	! . ^
	call print_string	;4047	cd 6e 6e	. n n
	ld hl,00001h		;404a	21 01 00	! . .
	jp l40b0h		;404d	c3 b0 40	. . @
l4050h:
	ld hl,(l0f5bh)		;4050	2a 5b 0f	* [ .
	inc hl			;4053	23		#
	ld (l0f5bh),hl		;4054	22 5b 0f	" [ .
	ld de,l0f5bh		;4057	11 5b 0f	. [ .
	ld hl,l0f59h		;405a	21 59 0f	! Y .
	call sub_626bh		;405d	cd 6b 62	. k b
	call print_setup	;4060	cd ea 6f	. . o
	ld de,00030h		;4063	11 30 00	. 0 .
	ld hl,(l0f1fh+2)	;4066	2a 21 0f	* ! .
	add hl,de		;4069	19		.
	call character_string	;406a	cd b5 75	. . u
	call print_string	;406d	cd 6e 6e	. n n
	ld hl,s_score_rank_suffix	;4070	21 08 5e	! . ^
	call print_string	;4073	cd 6e 6e	. n n
	ld hl,(l0f1fh+2)	;4076	2a 21 0f	* ! .
	add hl,hl		;4079	29		)
	ld de,l0ee8h		;407a	11 e8 0e	. . .
	add hl,de		;407d	19		.
	ld e,(hl)		;407e	5e		^
	inc hl			;407f	23		#
	ld d,(hl)		;4080	56		V
	push de			;4081	d5		.
	pop hl			;4082	e1		.
	add hl,hl		;4083	29		)
	jp c,l40ach		;4084	da ac 40	. . @
	ld hl,(l0f1fh+2)	;4087	2a 21 0f	* ! .
	add hl,hl		;408a	29		)
	ld de,l0ee8h		;408b	11 e8 0e	. . .
	add hl,de		;408e	19		.
	push hl			;408f	e5		.
	pop hl			;4090	e1		.
	call sub_61a8h		;4091	cd a8 61	. . a
	call print_setup	;4094	cd ea 6f	. . o
	ld hl,s_zero_hundreds_padded	;4097	21 01 5e	! . ^
	call print_string	;409a	cd 6e 6e	. n n
	ld hl,(l0f1fh+2)	;409d	2a 21 0f	* ! .
	call integer_mul_inline	;40a0	cd 8e 76	. . v
	defw 00003h		;40a3	03 00		. .
	ld de,00ed6h		;40a5	11 d6 0e	. . .
	add hl,de		;40a8	19		.
	call print_string	;40a9	cd 6e 6e	. n n
l40ach:
	ld hl,(l0f1fh+2)	;40ac	2a 21 0f	* ! .
	inc hl			;40af	23		#
l40b0h:
	ld (l0f1fh+2),hl	;40b0	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;40b3	2a 21 0f	* ! .
	ld de,0fffah		;40b6	11 fa ff	. . .
	ld a,h			;40b9	7c		|
	rla			;40ba	17		.
	jp c,l40c0h		;40bb	da c0 40	. . @
	add hl,de		;40be	19		.
	add hl,hl		;40bf	29		)
l40c0h:
	jp c,l4050h		;40c0	da 50 40	. P @
	ld hl,(score_word)	;40c3	2a 05 0f	* . .
	ld a,h			;40c6	7c		|
	add a,a			;40c7	87		.
	jp c,l40f8h		;40c8	da f8 40	. . @
	or l			;40cb	b5		.
	jp z,l40f8h		;40cc	ca f8 40	. . @
	ld hl,(l0f5bh)		;40cf	2a 5b 0f	* [ .
	inc hl			;40d2	23		#
	inc hl			;40d3	23		#
	ld (l0f5bh),hl		;40d4	22 5b 0f	" [ .
	ld de,l0f5bh		;40d7	11 5b 0f	. [ .
	ld hl,l0f59h		;40da	21 59 0f	! Y .
	call sub_626bh		;40dd	cd 6b 62	. k b
	call print_setup	;40e0	cd ea 6f	. . o
	ld hl,s_last_score	;40e3	21 f2 5d	! . ]
	call print_string	;40e6	cd 6e 6e	. n n
	ld hl,score_word	;40e9	21 05 0f	! . .
	call sub_61a8h		;40ec	cd a8 61	. . a
	call print_setup	;40ef	cd ea 6f	. . o
	ld hl,s_zero_hundreds	;40f2	21 ed 5d	! . ]
	call print_string	;40f5	cd 6e 6e	. n n
l40f8h:
	ld hl,00028h		;40f8	21 28 00	! ( .
	ld (l0f59h),hl		;40fb	22 59 0f	" Y .
	ld hl,0000ah		;40fe	21 0a 00	! . .
	ld (l0f5bh),hl		;4101	22 5b 0f	" [ .
	ld de,l0f5bh		;4104	11 5b 0f	. [ .
	ld hl,l0f59h		;4107	21 59 0f	! Y .
	call sub_626bh		;410a	cd 6b 62	. k b
	call print_setup	;410d	cd ea 6f	. . o
	ld hl,s_play_speed	;4110	21 de 5d	! . ]
	call print_string	;4113	cd 6e 6e	. n n
	ld de,00030h		;4116	11 30 00	. 0 .
	ld hl,(score_word+2)	;4119	2a 07 0f	* . .
	add hl,de		;411c	19		.
	call character_string	;411d	cd b5 75	. . u
	call print_string	;4120	cd 6e 6e	. n n
l4123h:
	ld hl,00005h		;4123	21 05 00	! . .
	call random_float	;4126	cd 31 6c	. 1 l
	call sub_7412h		;4129	cd 12 74	. . t
	ld d,c			;412c	51		Q
	ld h,c			;412d	61		a
	ld hl,l9285h		;412e	21 85 92	! . .
	call sub_71c8h		;4131	cd c8 71	. . q
	call sub_73e9h		;4134	cd e9 73	. . s
	ld c,l			;4137	4d		M
	ld h,c			;4138	61		a
	call sub_7618h		;4139	cd 18 76	. . v
	ld (00f5dh),hl		;413c	22 5d 0f	" ] .
	call sub_57d1h		;413f	cd d1 57	. . W
l4142h:
	ld hl,00015h		;4142	21 15 00	! . .
	ld (l0f5bh),hl		;4145	22 5b 0f	" [ .
	ld hl,00001h		;4148	21 01 00	! . .
	ld (l0f59h),hl		;414b	22 59 0f	" Y .
	ld de,l0f5bh		;414e	11 5b 0f	. [ .
	ld hl,l0f59h		;4151	21 59 0f	! Y .
	call sub_626bh		;4154	cd 6b 62	. k b
	call print_setup	;4157	cd ea 6f	. . o
	ld hl,s_menu_prompt	;415a	21 c3 5d	! . ]
	call print_string	;415d	cd 6e 6e	. n n
; Start screen: poll until a key arrives, then dispatch the menu choice
start_key_scan:
	ld hl,l0f5fh		;4160	21 5f 0f	! _ .
	call keyboard_poll	;4163	cd 7d 61	. } a
	ld hl,(l0f5fh)		;4166	2a 5f 0f	* _ .
	ld a,h			;4169	7c		|
	or l			;416a	b5		.
	jp nz,start_key_dispatch	;416b	c2 c3 41	. . A
	ld hl,(00f5dh)		;416e	2a 5d 0f	* ] .
	dec hl			;4171	2b		+
	ld (00f5dh),hl		;4172	22 5d 0f	" ] .
	ld hl,(00f5dh)		;4175	2a 5d 0f	* ] .
	ld a,h			;4178	7c		|
	add a,a			;4179	87		.
	jp c,l4181h		;417a	da 81 41	. . A
	or l			;417d	b5		.
	jp nz,start_key_scan	;417e	c2 60 41	. ` A
l4181h:
	ld hl,00005h		;4181	21 05 00	! . .
	call random_float	;4184	cd 31 6c	. 1 l
	call sub_735dh		;4187	cd 5d 73	. ] s
	ld c,c			;418a	49		I
	ld h,c			;418b	61		a
	sbc a,d			;418c	9a		.
	ld b,c			;418d	41		A
	ld de,l0f61h		;418e	11 61 0f	. a .
	ld hl,s_insult_hurry	;4191	21 a1 5d	! . ]
	call string_assign	;4194	cd db 74	. . t
	jp l41a3h		;4197	c3 a3 41	. . A
	ld de,l0f61h		;419a	11 61 0f	. a .
	ld hl,s_insult_quiche	;419d	21 8f 5d	! . ]
	call string_assign	;41a0	cd db 74	. . t
l41a3h:
	call sub_57e3h		;41a3	cd e3 57	. . W
	ld hl,(l0f5fh)		;41a6	2a 5f 0f	* _ .
	ld a,h			;41a9	7c		|
	or l			;41aa	b5		.
	jp z,l4123h		;41ab	ca 23 41	. # A
	ld hl,00015h		;41ae	21 15 00	! . .
	ld (l0f5bh),hl		;41b1	22 5b 0f	" [ .
	ld hl,00019h		;41b4	21 19 00	! . .
	ld (l0f59h),hl		;41b7	22 59 0f	" Y .
	ld de,l0f5bh		;41ba	11 5b 0f	. [ .
	ld hl,l0f59h		;41bd	21 59 0f	! Y .
	call sub_626bh		;41c0	cd 6b 62	. k b
start_key_dispatch:
	ld hl,(l0f5fh)		;41c3	2a 5f 0f	* _ .
	call character_string	;41c6	cd b5 75	. . u
	ld de,00f64h		;41c9	11 64 0f	. d .
	call string_assign	;41cc	cd db 74	. . t
	ld de,00f64h		;41cf	11 64 0f	. d .
	ld hl,s_key_e_upper	;41d2	21 8b 5d	! . ]
	call string_equal	;41d5	cd 99 73	. . s
	ld de,00f64h		;41d8	11 64 0f	. d .
	push hl			;41db	e5		.
	ld hl,s_key_e_lower	;41dc	21 87 5d	! . ]
	call string_equal	;41df	cd 99 73	. . s
	pop de			;41e2	d1		.
	ld a,h			;41e3	7c		|
	or d			;41e4	b2		.
	ld h,a			;41e5	67		g
	ld a,l			;41e6	7d		}
	or e			;41e7	b3		.
	ld l,a			;41e8	6f		o
	ld a,h			;41e9	7c		|
	or l			;41ea	b5		.
	jp z,l41fah		;41eb	ca fa 41	. . A
	call print_setup	;41ee	cd ea 6f	. . o
	ld hl,s_exiting		;41f1	21 7a 5d	! z ]
	call print_string_line	;41f4	cd 92 6e	. . n
	call program_end	;41f7	cd bb 68	. . h
l41fah:
	ld de,00f64h		;41fa	11 64 0f	. d .
	ld hl,s_key_p_upper	;41fd	21 76 5d	! v ]
	call string_equal	;4200	cd 99 73	. . s
	ld de,00f64h		;4203	11 64 0f	. d .
	push hl			;4206	e5		.
	ld hl,s_key_p_lower	;4207	21 72 5d	! r ]
	call string_equal	;420a	cd 99 73	. . s
	pop de			;420d	d1		.
	ld a,h			;420e	7c		|
	or d			;420f	b2		.
	ld h,a			;4210	67		g
	ld a,l			;4211	7d		}
	or e			;4212	b3		.
	ld l,a			;4213	6f		o
	ld a,h			;4214	7c		|
	or l			;4215	b5		.
	jp nz,menu_play		;4216	c2 6f 43	. o C
	ld de,00f64h		;4219	11 64 0f	. d .
	ld hl,s_key_c_upper	;421c	21 6e 5d	! n ]
	call string_equal	;421f	cd 99 73	. . s
	ld de,00f64h		;4222	11 64 0f	. d .
	push hl			;4225	e5		.
	ld hl,s_key_c_lower	;4226	21 6a 5d	! j ]
	call string_equal	;4229	cd 99 73	. . s
	pop de			;422c	d1		.
	ld a,h			;422d	7c		|
	or d			;422e	b2		.
	ld h,a			;422f	67		g
	ld a,l			;4230	7d		}
	or e			;4231	b3		.
	ld l,a			;4232	6f		o
	ld a,h			;4233	7c		|
l4234h:
	or l			;4234	b5		.
	jp nz,l3a9ah		;4235	c2 9a 3a	. . :
	ld de,00f64h		;4238	11 64 0f	. d .
	ld hl,s_key_i_upper	;423b	21 66 5d	! f ]
	call string_equal	;423e	cd 99 73	. . s
	ld de,00f64h		;4241	11 64 0f	. d .
	push hl			;4244	e5		.
	ld hl,s_key_i_lower	;4245	21 62 5d	! b ]
	call string_equal	;4248	cd 99 73	. . s
	pop de			;424b	d1		.
	ld a,h			;424c	7c		|
	or d			;424d	b2		.
	ld h,a			;424e	67		g
	ld a,l			;424f	7d		}
	or e			;4250	b3		.
	ld l,a			;4251	6f		o
	ld a,h			;4252	7c		|
	or l			;4253	b5		.
	jp nz,menu_instructions	;4254	c2 79 42	. y B
	ld de,00f64h		;4257	11 64 0f	. d .
	ld hl,s_key_l_upper	;425a	21 5e 5d	! ^ ]
	call string_equal	;425d	cd 99 73	. . s
	ld de,00f64h		;4260	11 64 0f	. d .
	push hl			;4263	e5		.
	ld hl,s_key_l_lower	;4264	21 5a 5d	! Z ]
	call string_equal	;4267	cd 99 73	. . s
	pop de			;426a	d1		.
	ld a,h			;426b	7c		|
	or d			;426c	b2		.
	ld h,a			;426d	67		g
	ld a,l			;426e	7d		}
	or e			;426f	b3		.
	ld l,a			;4270	6f		o
	ld a,h			;4271	7c		|
	or l			;4272	b5		.
	jp nz,menu_change_speed	;4273	c2 60 43	. ` C
	jp l4142h		;4276	c3 42 41	. B A
menu_instructions:
	call print_setup	;4279	cd ea 6f	. . o
	ld hl,l0f37h		;427c	21 37 0f	! 7 .
	call print_string_line	;427f	cd 92 6e	. . n
	call print_setup	;4282	cd ea 6f	. . o
	ld hl,l613eh		;4285	21 3e 61	! > a
	call print_string_line	;4288	cd 92 6e	. . n
	call print_setup	;428b	cd ea 6f	. . o
	ld hl,s_instructions_intro	;428e	21 1a 5d	! . ]
	call print_string_line	;4291	cd 92 6e	. . n
	call print_setup	;4294	cd ea 6f	. . o
	ld hl,s_instructions_corridors	;4297	21 d9 5c	! . \
	call print_string_line	;429a	cd 92 6e	. . n
	call print_setup	;429d	cd ea 6f	. . o
	ld hl,s_instructions_riches	;42a0	21 c1 5c	! . \
	call print_string_line	;42a3	cd 92 6e	. . n
	call print_setup	;42a6	cd ea 6f	. . o
	ld hl,l613eh		;42a9	21 3e 61	! > a
	call print_string_line	;42ac	cd 92 6e	. . n
	call print_setup	;42af	cd ea 6f	. . o
	ld hl,s_instructions_controls	;42b2	21 80 5c	! . \
	call print_string_line	;42b5	cd 92 6e	. . n
	call print_setup	;42b8	cd ea 6f	. . o
	ld hl,s_instructions_jump_and_rocks	;42bb	21 3d 5c	! = \
	call print_string_line	;42be	cd 92 6e	. . n
	call print_setup	;42c1	cd ea 6f	. . o
	ld hl,s_instructions_treasure	;42c4	21 fe 5b	! . [
	call print_string_line	;42c7	cd 92 6e	. . n
	call print_setup	;42ca	cd ea 6f	. . o
	ld hl,s_instructions_bonus_expires	;42cd	21 e7 5b	! . [
	call print_string_line	;42d0	cd 92 6e	. . n
	call print_setup	;42d3	cd ea 6f	. . o
	ld hl,l613eh		;42d6	21 3e 61	! > a
	call print_string_line	;42d9	cd 92 6e	. . n
	call print_setup	;42dc	cd ea 6f	. . o
	ld hl,s_instructions_extra_lad	;42df	21 b2 5b	! . [
	call print_string_line	;42e2	cd 92 6e	. . n
	call print_setup	;42e5	cd ea 6f	. . o
	ld hl,s_instructions_gold	;42e8	21 81 5b	! . [
	call print_string_line	;42eb	cd 92 6e	. . n
	call print_setup	;42ee	cd ea 6f	. . o
	ld hl,s_instructions_statues	;42f1	21 41 5b	! A [
	call print_string_line	;42f4	cd 92 6e	. . n
	call print_setup	;42f7	cd ea 6f	. . o
	ld hl,s_instructions_bonus_remainder	;42fa	21 0f 5b	! . [
	call print_string_line	;42fd	cd 92 6e	. . n
	call print_setup	;4300	cd ea 6f	. . o
	ld hl,s_pause_hint	;4303	21 eb 5a	! . Z
	call print_string_line	;4306	cd 92 6e	. . n
	call print_setup	;4309	cd ea 6f	. . o
	ld hl,l613eh		;430c	21 3e 61	! > a
	call print_string_line	;430f	cd 92 6e	. . n
	call print_setup	;4312	cd ea 6f	. . o
	ld hl,s_good_luck	;4315	21 da 5a	! . Z
	call print_string_line	;4318	cd 92 6e	. . n
	call print_setup	;431b	cd ea 6f	. . o
	ld hl,l613eh		;431e	21 3e 61	! > a
	call print_string_line	;4321	cd 92 6e	. . n
	call print_setup	;4324	cd ea 6f	. . o
	ld hl,l613eh		;4327	21 3e 61	! > a
	call print_string_line	;432a	cd 92 6e	. . n
	call print_setup	;432d	cd ea 6f	. . o
	ld hl,l613eh		;4330	21 3e 61	! > a
	call print_string_line	;4333	cd 92 6e	. . n
	call print_setup	;4336	cd ea 6f	. . o
	ld hl,s_type_return_for_menu	;4339	21 b3 5a	! . Z
	call print_string	;433c	cd 6e 6e	. n n
	ld de,00001h		;433f	11 01 00	. . .
	ld hl,000ffh		;4342	21 ff 00	! . .
	call input_string	;4345	cd 38 8e	. 8 .
	ld de,00f64h		;4348	11 64 0f	. d .
	call string_assign	;434b	cd db 74	. . t
	ld hl,0000dh		;434e	21 0d 00	! . .
	call character_string	;4351	cd b5 75	. . u
	ex de,hl		;4354	eb		.
	ld hl,00f64h		;4355	21 64 0f	! d .
	call branch_if_strings_unequal	;4358	cd b8 73	. . s
	defw 0433fh		;435b	3f 43		? C
	jp l3eafh		;435d	c3 af 3e	. . >
menu_change_speed:
	ld hl,(score_word+2)	;4360	2a 07 0f	* . .
	call integer_mod_inline	;4363	cd 46 76	. F v
	defw 00005h		;4366	05 00		. .
	inc hl			;4368	23		#
	ld (score_word+2),hl	;4369	22 07 0f	" . .
	jp l40f8h		;436c	c3 f8 40	. . @
menu_play:
	ld hl,(l0f52h)		;436f	2a 52 0f	* R .
	ld (lads_word),hl	;4372	22 67 0f	" g .
	ld hl,00001h		;4375	21 01 00	! . .
	ld (level_word),hl	;4378	22 69 0f	" i .
	ld hl,(00f54h)		;437b	2a 54 0f	* T .
	ld (score_word),hl	;437e	22 05 0f	" . .
	ld hl,00001h		;4381	21 01 00	! . .
	ld (l0f6bh),hl		;4384	22 6b 0f	" k .
	ld hl,00064h		;4387	21 64 00	! d .
	ld (l0f6dh),hl		;438a	22 6d 0f	" m .
	ld hl,(00f50h)		;438d	2a 50 0f	* P .
	ld (l0f6fh),hl		;4390	22 6f 0f	" o .
	ld hl,(score_word+2)	;4393	2a 07 0f	* . .
	ld (l0f71h),hl		;4396	22 71 0f	" q .
	ld hl,00000h		;4399	21 00 00	! . .
	ld (l0f73h),hl		;439c	22 73 0f	" s .
l439fh:
	call sub_7299h		;439f	cd 99 72	. . r
	ld hl,00000h		;43a2	21 00 00	! . .
	ld (l0f75h),hl		;43a5	22 75 0f	" u .
l43a8h:
	ld hl,bonus_word	;43a8	21 77 0f	! w .
	call sub_723eh		;43ab	cd 3e 72	. > r
	ld hl,(bonus_word)	;43ae	2a 77 0f	* w .
	ld de,00001h		;43b1	11 01 00	. . .
	add hl,de		;43b4	19		.
	ld a,h			;43b5	7c		|
	or l			;43b6	b5		.
	jp nz,l43e1h		;43b7	c2 e1 43	. . C
	ld hl,00002h		;43ba	21 02 00	! . .
	ld (l0f6fh),hl		;43bd	22 6f 0f	" o .
	ld hl,(l0f71h)		;43c0	2a 71 0f	* q .
	inc hl			;43c3	23		#
	inc hl			;43c4	23		#
	ld (l0f71h),hl		;43c5	22 71 0f	" q .
	ld hl,(l0f71h)		;43c8	2a 71 0f	* q .
	ld de,0fffah		;43cb	11 fa ff	. . .
	ld a,h			;43ce	7c		|
	rla			;43cf	17		.
	jp c,l43d5h		;43d0	da d5 43	. . C
	add hl,de		;43d3	19		.
	add hl,hl		;43d4	29		)
l43d5h:
	jp c,l43deh		;43d5	da de 43	. . C
	ld hl,00005h		;43d8	21 05 00	! . .
	ld (l0f71h),hl		;43db	22 71 0f	" q .
l43deh:
	jp l439fh		;43de	c3 9f 43	. . C
l43e1h:
	ld hl,(l0f75h)		;43e1	2a 75 0f	* u .
	ex de,hl		;43e4	eb		.
	ld hl,(l0f6fh)		;43e5	2a 6f 0f	* o .
	ld a,d			;43e8	7a		z
	xor h			;43e9	ac		.
	ld a,d			;43ea	7a		z
	jp m,l43f2h		;43eb	fa f2 43	. . C
	ld a,e			;43ee	7b		{
	sub l			;43ef	95		.
	ld a,d			;43f0	7a		z
	sbc a,h			;43f1	9c		.
l43f2h:
	rla			;43f2	17		.
	jp c,l4408h		;43f3	da 08 44	. . D
	ld hl,(l0f6fh)		;43f6	2a 6f 0f	* o .
	inc hl			;43f9	23		#
	ld (l0f6fh),hl		;43fa	22 6f 0f	" o .
	ld hl,(l0f73h)		;43fd	2a 73 0f	* s .
	inc hl			;4400	23		#
	inc hl			;4401	23		#
	ld (l0f73h),hl		;4402	22 73 0f	" s .
	jp l439fh		;4405	c3 9f 43	. . C
l4408h:
	ld hl,(l0f73h)		;4408	2a 73 0f	* s .
	ex de,hl		;440b	eb		.
	ld hl,(bonus_word)	;440c	2a 77 0f	* w .
	ld a,l			;440f	7d		}
	sub e			;4410	93		.
	ld l,a			;4411	6f		o
	ld a,h			;4412	7c		|
	sbc a,d			;4413	9a		.
	ld h,a			;4414	67		g
	ld (bonus_word),hl	;4415	22 77 0f	" w .
	ld hl,(bonus_word)	;4418	2a 77 0f	* w .
	ld (00f79h),hl		;441b	22 79 0f	" y .
	ld hl,l0f7bh		;441e	21 7b 0f	! { .
	call sub_723eh		;4421	cd 3e 72	. > r
	ld hl,l0f7dh		;4424	21 7d 0f	! } .
	call sub_723eh		;4427	cd 3e 72	. > r
	ld hl,(l0f71h)		;442a	2a 71 0f	* q .
	call sub_7524h		;442d	cd 24 75	. $ u
	dec b			;4430	05		.
	ld a,h			;4431	7c		|
	ld b,h			;4432	44		D
	dec sp			;4433	3b		;
	ld b,h			;4434	44		D
	ld d,h			;4435	54		T
	ld b,h			;4436	44		D
	ld h,d			;4437	62		b
	ld b,h			;4438	44		D
	halt			;4439	76		v
	ld b,h			;443a	44		D
	ld hl,(l0f7bh)		;443b	2a 7b 0f	* { .
	call integer_mul_inline	;443e	cd 8e 76	. . v
	defw 00003h		;4441	03 00		. .
	call sub_760eh		;4443	cd 0e 76	. . v
	call sub_7412h		;4446	cd 12 74	. . t
	ld b,l			;4449	45		E
	ld h,c			;444a	61		a
	call sub_7618h		;444b	cd 18 76	. . v
	ld (l0f7bh),hl		;444e	22 7b 0f	" { .
	jp l447ch		;4451	c3 7c 44	. | D
	ld hl,(l0f7bh)		;4454	2a 7b 0f	* { .
	call sub_75c9h		;4457	cd c9 75	. . u
	ld (bc),a		;445a	02		.
	nop			;445b	00		.
	ld (l0f7bh),hl		;445c	22 7b 0f	" { .
	jp l447ch		;445f	c3 7c 44	. | D
	ld hl,(l0f7bh)		;4462	2a 7b 0f	* { .
	call sub_760eh		;4465	cd 0e 76	. . v
	call sub_7412h		;4468	cd 12 74	. . t
	ld b,l			;446b	45		E
	ld h,c			;446c	61		a
	call sub_7618h		;446d	cd 18 76	. . v
	ld (l0f7bh),hl		;4470	22 7b 0f	" { .
	jp l447ch		;4473	c3 7c 44	. | D
	ld hl,00000h		;4476	21 00 00	! . .
	ld (l0f7bh),hl		;4479	22 7b 0f	" { .
l447ch:
	ld hl,00000h		;447c	21 00 00	! . .
	ld (l0f7fh),hl		;447f	22 7f 0f	" . .
	call print_setup	;4482	cd ea 6f	. . o
	ld hl,l0f37h		;4485	21 37 0f	! 7 .
	call print_string	;4488	cd 6e 6e	. n n
	ld hl,(l0efbh)		;448b	2a fb 0e	* . .
	ld (l0f7fh+2),hl	;448e	22 81 0f	" . .
	ld hl,00001h		;4491	21 01 00	! . .
	jp l4595h		;4494	c3 95 45	. . E
l4497h:
	ld hl,l0f23h		;4497	21 23 0f	! # .
	call sub_7258h		;449a	cd 58 72	. X r
	call print_setup	;449d	cd ea 6f	. . o
	ld hl,l0f23h		;44a0	21 23 0f	! # .
	call print_string_line	;44a3	cd 92 6e	. . n
	ld hl,00001h		;44a6	21 01 00	! . .
	jp l44c8h		;44a9	c3 c8 44	. . D
l44ach:
	ld hl,(l0f1fh+2)	;44ac	2a 21 0f	* ! .
	call integer_mul_inline	;44af	cd 8e 76	. . v
	defw 00051h		;44b2	51 00		Q .
	ex de,hl		;44b4	eb		.
	ld hl,(00f83h)		;44b5	2a 83 0f	* . .
	add hl,de		;44b8	19		.
	add hl,hl		;44b9	29		)
	ld de,l010ah		;44ba	11 0a 01	. . .
	add hl,de		;44bd	19		.
	ld de,00000h		;44be	11 00 00	. . .
	ld (hl),e		;44c1	73		s
	inc hl			;44c2	23		#
	ld (hl),d		;44c3	72		r
	ld hl,(00f83h)		;44c4	2a 83 0f	* . .
	inc hl			;44c7	23		#
l44c8h:
	ld (00f83h),hl		;44c8	22 83 0f	" . .
	ld hl,(00f83h)		;44cb	2a 83 0f	* . .
	ld de,0ffafh		;44ce	11 af ff	. . .
	ld a,h			;44d1	7c		|
	rla			;44d2	17		.
	jp c,l44d8h		;44d3	da d8 44	. . D
	add hl,de		;44d6	19		.
	add hl,hl		;44d7	29		)
l44d8h:
	jp c,l44ach		;44d8	da ac 44	. . D
	ld hl,l0f23h		;44db	21 23 0f	! # .
	call sub_71d5h		;44de	cd d5 71	. . q
	ld (l0f85h),hl		;44e1	22 85 0f	" . .
	ld hl,00001h		;44e4	21 01 00	! . .
	jp l4579h		;44e7	c3 79 45	. y E
l44eah:
	ld bc,l0f23h		;44ea	01 23 0f	. # .
	ld hl,(00f83h)		;44ed	2a 83 0f	* . .
	ex de,hl		;44f0	eb		.
	ld hl,00001h		;44f1	21 01 00	! . .
	call sub_747fh		;44f4	cd 7f 74	. . t
	ld de,00f0eh		;44f7	11 0e 0f	. . .
	call l7155h+1		;44fa	cd 56 71	. V q
	dec hl			;44fd	2b		+
	ld (00f87h),hl		;44fe	22 87 0f	" . .
	ld hl,(00f87h)		;4501	2a 87 0f	* . .
	ld a,h			;4504	7c		|
	or l			;4505	b5		.
	jp nz,l4515h		;4506	c2 15 45	. . E
	ld hl,(00f83h)		;4509	2a 83 0f	* . .
	ld (l0f89h),hl		;450c	22 89 0f	" . .
	ld hl,(l0f1fh+2)	;450f	2a 21 0f	* ! .
	ld (l0f8bh),hl		;4512	22 8b 0f	" . .
l4515h:
	ld hl,(00f87h)		;4515	2a 87 0f	* . .
	ld de,00001h		;4518	11 01 00	. . .
	add hl,de		;451b	19		.
	ld a,h			;451c	7c		|
	or l			;451d	b5		.
	jp nz,l4527h		;451e	c2 27 45	. ' E
	ld hl,00000h		;4521	21 00 00	! . .
	ld (00f87h),hl		;4524	22 87 0f	" . .
l4527h:
	ld hl,(l0f1fh+2)	;4527	2a 21 0f	* ! .
	call integer_mul_inline	;452a	cd 8e 76	. . v
	defw 00051h		;452d	51 00		Q .
	ex de,hl		;452f	eb		.
	ld hl,(00f83h)		;4530	2a 83 0f	* . .
	add hl,de		;4533	19		.
	add hl,hl		;4534	29		)
	ld de,l010ah		;4535	11 0a 01	. . .
	add hl,de		;4538	19		.
	push hl			;4539	e5		.
	ld hl,(00f87h)		;453a	2a 87 0f	* . .
	ex de,hl		;453d	eb		.
	pop hl			;453e	e1		.
	ld (hl),e		;453f	73		s
	inc hl			;4540	23		#
	ld (hl),d		;4541	72		r
	ld hl,(00f87h)		;4542	2a 87 0f	* . .
	ld de,0fffbh		;4545	11 fb ff	. . .
	add hl,de		;4548	19		.
	ld a,h			;4549	7c		|
	or l			;454a	b5		.
	jp nz,l4575h		;454b	c2 75 45	. u E
	ld hl,(l0f7fh)		;454e	2a 7f 0f	* . .
	inc hl			;4551	23		#
	ld (l0f7fh),hl		;4552	22 7f 0f	" . .
	ld hl,(l0f7fh)		;4555	2a 7f 0f	* . .
	add hl,hl		;4558	29		)
	push hl			;4559	e5		.
	ld de,00eaah		;455a	11 aa 0e	. . .
	add hl,de		;455d	19		.
	push hl			;455e	e5		.
	ld hl,(00f83h)		;455f	2a 83 0f	* . .
	ex de,hl		;4562	eb		.
	pop hl			;4563	e1		.
	ld (hl),e		;4564	73		s
	inc hl			;4565	23		#
	ld (hl),d		;4566	72		r
	pop hl			;4567	e1		.
	ld de,00ec0h		;4568	11 c0 0e	. . .
	add hl,de		;456b	19		.
	push hl			;456c	e5		.
	ld hl,(l0f1fh+2)	;456d	2a 21 0f	* ! .
	ex de,hl		;4570	eb		.
	pop hl			;4571	e1		.
	ld (hl),e		;4572	73		s
	inc hl			;4573	23		#
	ld (hl),d		;4574	72		r
l4575h:
	ld hl,(00f83h)		;4575	2a 83 0f	* . .
	inc hl			;4578	23		#
l4579h:
	ld (00f83h),hl		;4579	22 83 0f	" . .
	ld hl,(00f83h)		;457c	2a 83 0f	* . .
	ex de,hl		;457f	eb		.
	ld hl,(l0f85h)		;4580	2a 85 0f	* . .
	ld a,d			;4583	7a		z
	xor h			;4584	ac		.
	ld a,h			;4585	7c		|
	jp m,l458dh		;4586	fa 8d 45	. . E
	ld a,l			;4589	7d		}
	sub e			;458a	93		.
	ld a,h			;458b	7c		|
	sbc a,d			;458c	9a		.
l458dh:
	rla			;458d	17		.
	jp nc,l44eah		;458e	d2 ea 44	. . D
	ld hl,(l0f1fh+2)	;4591	2a 21 0f	* ! .
	inc hl			;4594	23		#
l4595h:
	ld (l0f1fh+2),hl	;4595	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;4598	2a 21 0f	* ! .
	ex de,hl		;459b	eb		.
	ld hl,(l0f7fh+2)	;459c	2a 81 0f	* . .
	ld a,d			;459f	7a		z
	xor h			;45a0	ac		.
	ld a,h			;45a1	7c		|
	jp m,l45a9h		;45a2	fa a9 45	. . E
	ld a,l			;45a5	7d		}
	sub e			;45a6	93		.
	ld a,h			;45a7	7c		|
	sbc a,d			;45a8	9a		.
l45a9h:
	rla			;45a9	17		.
	jp nc,l4497h		;45aa	d2 97 44	. . D
	ld hl,(l0f75h)		;45ad	2a 75 0f	* u .
	inc hl			;45b0	23		#
	ld (l0f75h),hl		;45b1	22 75 0f	" u .
	ld hl,00000h		;45b4	21 00 00	! . .
	jp l45cch		;45b7	c3 cc 45	. . E
l45bah:
	ld hl,(l0f1fh+2)	;45ba	2a 21 0f	* ! .
	add hl,hl		;45bd	29		)
	ld de,l010ah		;45be	11 0a 01	. . .
	add hl,de		;45c1	19		.
	ld de,00002h		;45c2	11 02 00	. . .
	ld (hl),e		;45c5	73		s
	inc hl			;45c6	23		#
	ld (hl),d		;45c7	72		r
	ld hl,(l0f1fh+2)	;45c8	2a 21 0f	* ! .
	inc hl			;45cb	23		#
l45cch:
	ld (l0f1fh+2),hl	;45cc	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;45cf	2a 21 0f	* ! .
	ld de,0ffafh		;45d2	11 af ff	. . .
	ld a,h			;45d5	7c		|
	rla			;45d6	17		.
	jp c,l45dch		;45d7	da dc 45	. . E
	add hl,de		;45da	19		.
	add hl,hl		;45db	29		)
l45dch:
	jp c,l45bah		;45dc	da ba 45	. . E
	ld hl,(l0efbh)		;45df	2a fb 0e	* . .
	ld (l0f8dh),hl		;45e2	22 8d 0f	" . .
	ld hl,00000h		;45e5	21 00 00	! . .
	jp l460dh		;45e8	c3 0d 46	. . F
l45ebh:
	ld hl,(l0f1fh+2)	;45eb	2a 21 0f	* ! .
	call integer_mul_inline	;45ee	cd 8e 76	. . v
	defw 000a2h		;45f1	a2 00		. .
	push hl			;45f3	e5		.
	ld de,l010ah		;45f4	11 0a 01	. . .
	add hl,de		;45f7	19		.
	ld de,00004h		;45f8	11 04 00	. . .
	ld (hl),e		;45fb	73		s
	inc hl			;45fc	23		#
	ld (hl),d		;45fd	72		r
	pop hl			;45fe	e1		.
	ld de,l01aah		;45ff	11 aa 01	. . .
	add hl,de		;4602	19		.
	ld de,00004h		;4603	11 04 00	. . .
	ld (hl),e		;4606	73		s
	inc hl			;4607	23		#
	ld (hl),d		;4608	72		r
	ld hl,(l0f1fh+2)	;4609	2a 21 0f	* ! .
	inc hl			;460c	23		#
l460dh:
	ld (l0f1fh+2),hl	;460d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;4610	2a 21 0f	* ! .
	ex de,hl		;4613	eb		.
	ld hl,(l0f8dh)		;4614	2a 8d 0f	* . .
	ld a,d			;4617	7a		z
	xor h			;4618	ac		.
	ld a,h			;4619	7c		|
	jp m,l4621h		;461a	fa 21 46	. ! F
	ld a,l			;461d	7d		}
	sub e			;461e	93		.
	ld a,h			;461f	7c		|
	sbc a,d			;4620	9a		.
l4621h:
	rla			;4621	17		.
	jp nc,l45ebh		;4622	d2 eb 45	. . E
	ld hl,(l0f89h)		;4625	2a 89 0f	* . .
	ld (l0f8fh),hl		;4628	22 8f 0f	" . .
	ld hl,(l0f8bh)		;462b	2a 8b 0f	* . .
	ld (l0f91h),hl		;462e	22 91 0f	" . .
l4631h:
	ld hl,(l0f8fh)		;4631	2a 8f 0f	* . .
	ld (l0f89h),hl		;4634	22 89 0f	" . .
	ld hl,(l0f91h)		;4637	2a 91 0f	* . .
l463ah:
	ld (l0f8bh),hl		;463a	22 8b 0f	" . .
	ld hl,(l0ef4h)		;463d	2a f4 0e	* . .
	ld (l0f91h+2),hl	;4640	22 93 0f	" . .
	ld (l0f95h),hl		;4643	22 95 0f	" . .
	ld hl,00000h		;4646	21 00 00	! . .
	ld (l0f95h+2),hl	;4649	22 97 0f	" . .
	ld hl,00000h		;464c	21 00 00	! . .
	ld (l0f99h),hl		;464f	22 99 0f	" . .
	ld hl,(l0f7dh)		;4652	2a 7d 0f	* } .
	ld (l0f9bh),hl		;4655	22 9b 0f	" . .
	ld hl,00001h		;4658	21 01 00	! . .
	jp l4670h		;465b	c3 70 46	. p F
l465eh:
	ld hl,(l0f1fh+2)	;465e	2a 21 0f	* ! .
	add hl,hl		;4661	29		)
	ld de,00e94h		;4662	11 94 0e	. . .
	add hl,de		;4665	19		.
	ld de,0ffffh		;4666	11 ff ff	. . .
	ld (hl),e		;4669	73		s
	inc hl			;466a	23		#
	ld (hl),d		;466b	72		r
	ld hl,(l0f1fh+2)	;466c	2a 21 0f	* ! .
	inc hl			;466f	23		#
l4670h:
	ld (l0f1fh+2),hl	;4670	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;4673	2a 21 0f	* ! .
	ex de,hl		;4676	eb		.
	ld hl,(l0f9bh)		;4677	2a 9b 0f	* . .
	ld a,d			;467a	7a		z
	xor h			;467b	ac		.
	ld a,h			;467c	7c		|
	jp m,l4684h		;467d	fa 84 46	. . F
	ld a,l			;4680	7d		}
	sub e			;4681	93		.
	ld a,h			;4682	7c		|
	sbc a,d			;4683	9a		.
l4684h:
	rla			;4684	17		.
	jp nc,l465eh		;4685	d2 5e 46	. ^ F
	ld hl,00000h		;4688	21 00 00	! . .
	ld (l0f9dh),hl		;468b	22 9d 0f	" . .
	ld (l0f9fh),hl		;468e	22 9f 0f	" . .
	ld hl,(00f01h)		;4691	2a 01 0f	* . .
	ld (l0fa1h),hl		;4694	22 a1 0f	" . .
	ld hl,(00f79h)		;4697	2a 79 0f	* y .
	ld (bonus_word),hl	;469a	22 77 0f	" w .
	ld hl,00001h		;469d	21 01 00	! . .
	ld (l0fa1h+2),hl	;46a0	22 a3 0f	" . .
	ld de,l0efdh		;46a3	11 fd 0e	. . .
	ld hl,l0fa1h+2		;46a6	21 a3 0f	! . .
	call sub_626bh		;46a9	cd 6b 62	. k b
	call print_setup	;46ac	cd ea 6f	. . o
	ld hl,s_lads		;46af	21 ac 5a	! . Z
	call print_string	;46b2	cd 6e 6e	. n n
	ld hl,lads_word		;46b5	21 67 0f	! g .
	call sub_61a8h		;46b8	cd a8 61	. . a
	call print_setup	;46bb	cd ea 6f	. . o
	ld hl,s_level		;46be	21 9f 5a	! . Z
	call print_string	;46c1	cd 6e 6e	. n n
	ld hl,level_word	;46c4	21 69 0f	! i .
	call sub_61a8h		;46c7	cd a8 61	. . a
	call print_setup	;46ca	cd ea 6f	. . o
	ld hl,s_score		;46cd	21 91 5a	! . Z
	call print_string	;46d0	cd 6e 6e	. n n
	ld hl,score_word	;46d3	21 05 0f	! . .
	call sub_61a8h		;46d6	cd a8 61	. . a
	call print_setup	;46d9	cd ea 6f	. . o
	ld hl,s_zero_hundreds	;46dc	21 ed 5d	! . ]
	call print_string	;46df	cd 6e 6e	. n n
	ld hl,0003ch		;46e2	21 3c 00	! < .
	ld (l0fa1h+2),hl	;46e5	22 a3 0f	" . .
	ld de,l0efdh		;46e8	11 fd 0e	. . .
	ld hl,l0fa1h+2		;46eb	21 a3 0f	! . .
	call sub_626bh		;46ee	cd 6b 62	. k b
	call print_setup	;46f1	cd ea 6f	. . o
	ld hl,s_bonus_time	;46f4	21 83 5a	! . Z
	call print_string	;46f7	cd 6e 6e	. n n
	ld hl,bonus_word	;46fa	21 77 0f	! w .
	call sub_61a8h		;46fd	cd a8 61	. . a
	call print_setup	;4700	cd ea 6f	. . o
	ld hl,s_zero_hundreds	;4703	21 ed 5d	! . ]
	call print_string	;4706	cd 6e 6e	. n n
	call sub_57d1h		;4709	cd d1 57	. . W
	ld de,l0f61h		;470c	11 61 0f	. a .
	ld hl,s_get_ready	;470f	21 76 5a	! v Z
	call string_assign	;4712	cd db 74	. . t
	call sub_57e3h		;4715	cd e3 57	. . W
l4718h:
	ld hl,(l0f99h)		;4718	2a 99 0f	* . .
	ex de,hl		;471b	eb		.
	ld hl,(l0f7dh)		;471c	2a 7d 0f	* } .
	ld a,d			;471f	7a		z
	xor h			;4720	ac		.
	ld a,d			;4721	7a		z
	jp m,l4729h		;4722	fa 29 47	. ) G
	ld a,e			;4725	7b		{
	sub l			;4726	95		.
	ld a,d			;4727	7a		z
	sbc a,h			;4728	9c		.
l4729h:
	rla			;4729	17		.
	jp nc,l47d8h		;472a	d2 d8 47	. . G
	ld hl,00005h		;472d	21 05 00	! . .
	call random_float	;4730	cd 31 6c	. 1 l
	call sub_75fch		;4733	cd fc 75	. . u
	add a,c			;4736	81		.
	ld hl,(l0f7fh)		;4737	2a 7f 0f	* . .
	call sub_760eh		;473a	cd 0e 76	. . v
	call sub_7418h		;473d	cd 18 74	. . t
	add a,c			;4740	81		.
	ld hl,l9285h		;4741	21 85 92	! . .
	call sub_71c8h		;4744	cd c8 71	. . q
	call sub_73e9h		;4747	cd e9 73	. . s
	ld d,l			;474a	55		U
	ld h,c			;474b	61		a
	call sub_7618h		;474c	cd 18 76	. . v
	ld (l0fa5h),hl		;474f	22 a5 0f	" . .
	ld hl,(l0f7dh)		;4752	2a 7d 0f	* } .
	ld (l0fa5h+2),hl	;4755	22 a7 0f	" . .
	ld hl,00001h		;4758	21 01 00	! . .
	jp l4778h		;475b	c3 78 47	. x G
l475eh:
	ld hl,(l0f1fh+2)	;475e	2a 21 0f	* ! .
	add hl,hl		;4761	29		)
	ld de,00e94h		;4762	11 94 0e	. . .
	add hl,de		;4765	19		.
	ld e,(hl)		;4766	5e		^
	inc hl			;4767	23		#
	ld d,(hl)		;4768	56		V
	push de			;4769	d5		.
	pop hl			;476a	e1		.
	ld de,00001h		;476b	11 01 00	. . .
	add hl,de		;476e	19		.
	ld a,h			;476f	7c		|
	or l			;4770	b5		.
	jp z,l4793h		;4771	ca 93 47	. . G
	ld hl,(l0f1fh+2)	;4774	2a 21 0f	* ! .
	inc hl			;4777	23		#
l4778h:
	ld (l0f1fh+2),hl	;4778	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;477b	2a 21 0f	* ! .
	ex de,hl		;477e	eb		.
	ld hl,(l0fa5h+2)	;477f	2a a7 0f	* . .
	ld a,d			;4782	7a		z
	xor h			;4783	ac		.
	ld a,h			;4784	7c		|
	jp m,l478ch		;4785	fa 8c 47	. . G
	ld a,l			;4788	7d		}
	sub e			;4789	93		.
	ld a,h			;478a	7c		|
	sbc a,d			;478b	9a		.
l478ch:
	rla			;478c	17		.
	jp nc,l475eh		;478d	d2 5e 47	. ^ G
	jp l47d8h		;4790	c3 d8 47	. . G
l4793h:
	ld hl,(l0fa5h)		;4793	2a a5 0f	* . .
	add hl,hl		;4796	29		)
	push hl			;4797	e5		.
	ld de,00eaah		;4798	11 aa 0e	. . .
	add hl,de		;479b	19		.
	ld e,(hl)		;479c	5e		^
	inc hl			;479d	23		#
	ld d,(hl)		;479e	56		V
	push de			;479f	d5		.
	ld hl,(l0f1fh+2)	;47a0	2a 21 0f	* ! .
	add hl,hl		;47a3	29		)
	ld (00ff4h),hl		;47a4	22 f4 0f	" . .
	ld de,l0e68h		;47a7	11 68 0e	. h .
	add hl,de		;47aa	19		.
	pop de			;47ab	d1		.
	ld (hl),e		;47ac	73		s
	inc hl			;47ad	23		#
	ld (hl),d		;47ae	72		r
	pop hl			;47af	e1		.
	ld de,00ec0h		;47b0	11 c0 0e	. . .
	add hl,de		;47b3	19		.
	ld e,(hl)		;47b4	5e		^
	inc hl			;47b5	23		#
	ld d,(hl)		;47b6	56		V
	push de			;47b7	d5		.
	ld hl,(00ff4h)		;47b8	2a f4 0f	* . .
	ld de,l0e7eh		;47bb	11 7e 0e	. ~ .
	add hl,de		;47be	19		.
	pop de			;47bf	d1		.
	ld (hl),e		;47c0	73		s
	inc hl			;47c1	23		#
	ld (hl),d		;47c2	72		r
	ld hl,(l0f99h)		;47c3	2a 99 0f	* . .
	inc hl			;47c6	23		#
	ld (l0f99h),hl		;47c7	22 99 0f	" . .
	ld hl,(l0f1fh+2)	;47ca	2a 21 0f	* ! .
	add hl,hl		;47cd	29		)
	ld de,00e94h		;47ce	11 94 0e	. . .
	add hl,de		;47d1	19		.
	ld de,00002h		;47d2	11 02 00	. . .
	ld (hl),e		;47d5	73		s
	inc hl			;47d6	23		#
	ld (hl),d		;47d7	72		r
l47d8h:
	ld hl,(l0ef4h)		;47d8	2a f4 0e	* . .
	ld (l0fa9h),hl		;47db	22 a9 0f	" . .
	ld hl,(l0f7dh)		;47de	2a 7d 0f	* } .
	ld (l0fabh),hl		;47e1	22 ab 0f	" . .
	ld hl,00001h		;47e4	21 01 00	! . .
	jp next_actor		;47e7	c3 cf 4b	. . K
; Gameplay: poll input for each actor, update it, then advance the index
game_actor_loop:
	ld hl,00fadh		;47ea	21 ad 0f	! . .
	call keyboard_poll	;47ed	cd 7d 61	. } a
	ld hl,(00fadh)		;47f0	2a ad 0f	* . .
	call character_string	;47f3	cd b5 75	. . u
	ld de,l0fafh		;47f6	11 af 0f	. . .
	call string_assign	;47f9	cd db 74	. . t
	ld hl,(00fadh)		;47fc	2a ad 0f	* . .
	ld a,h			;47ff	7c		|
	or l			;4800	b5		.
	jp z,actor_update	;4801	ca b0 48	. . H
	ld hl,(00fadh)		;4804	2a ad 0f	* . .
	ld de,0ffe5h		;4807	11 e5 ff	. . .
	add hl,de		;480a	19		.
	ld a,h			;480b	7c		|
	or l			;480c	b5		.
	jp nz,l4816h		;480d	c2 16 48	. . H
	call sub_586fh		;4810	cd 6f 58	. o X
	jp actor_update		;4813	c3 b0 48	. . H
l4816h:
	ld hl,(00fadh)		;4816	2a ad 0f	* . .
	ld de,0fffdh		;4819	11 fd ff	. . .
	add hl,de		;481c	19		.
	ld a,h			;481d	7c		|
	or l			;481e	b5		.
	jp z,l3eafh		;481f	ca af 3e	. . >
	ld de,l0fafh		;4822	11 af 0f	. . .
	ld hl,00f0bh		;4825	21 0b 0f	! . .
	call sub_73bdh		;4828	cd bd 73	. . s
	inc a			;482b	3c		<
	ld c,b			;482c	48		H
	ld de,l0f46h		;482d	11 46 0f	. F .
	ld hl,l0fafh		;4830	21 af 0f	! . .
	call l7155h+1		;4833	cd 56 71	. V q
	ld (l0f9dh),hl		;4836	22 9d 0f	" . .
	jp actor_update		;4839	c3 b0 48	. . H
	ld hl,(l0f91h+2)	;483c	2a 93 0f	* . .
	ld a,h			;483f	7c		|
	or l			;4840	b5		.
	jp z,l484dh		;4841	ca 4d 48	. M H
	ld hl,(l0ef6h)		;4844	2a f6 0e	* . .
	ld (l0f95h),hl		;4847	22 95 0f	" . .
	jp actor_update		;484a	c3 b0 48	. . H
l484dh:
	ld hl,(l0f8bh)		;484d	2a 8b 0f	* . .
	call integer_mul_inline	;4850	cd 8e 76	. . v
	defw 00051h		;4853	51 00		Q .
	ex de,hl		;4855	eb		.
	ld hl,(l0f89h)		;4856	2a 89 0f	* . .
	add hl,de		;4859	19		.
	add hl,hl		;485a	29		)
	ld de,l01ach		;485b	11 ac 01	. . .
	add hl,de		;485e	19		.
	ld e,(hl)		;485f	5e		^
	inc hl			;4860	23		#
	ld d,(hl)		;4861	56		V
	ex de,hl		;4862	eb		.
	push hl			;4863	e5		.
	ld a,h			;4864	7c		|
	or l			;4865	b5		.
	sub 001h		;4866	d6 01		. .
	sbc a,a			;4868	9f		.
	ld h,a			;4869	67		g
	ld l,a			;486a	6f		o
	ld (00ff4h),hl		;486b	22 f4 0f	" . .
	pop hl			;486e	e1		.
	ld de,0fff9h		;486f	11 f9 ff	. . .
	ld a,h			;4872	7c		|
	rla			;4873	17		.
	jp c,l4879h		;4874	da 79 48	. y H
	add hl,de		;4877	19		.
	add hl,hl		;4878	29		)
l4879h:
	ccf			;4879	3f		?
	sbc a,a			;487a	9f		.
	ld h,a			;487b	67		g
	ld l,a			;487c	6f		o
	push hl			;487d	e5		.
	ld hl,(00ff4h)		;487e	2a f4 0f	* . .
	ex de,hl		;4881	eb		.
	pop hl			;4882	e1		.
	ld a,h			;4883	7c		|
	or d			;4884	b2		.
	ld h,a			;4885	67		g
	ld a,l			;4886	7d		}
	or e			;4887	b3		.
	ld l,a			;4888	6f		o
	ld a,h			;4889	7c		|
	or l			;488a	b5		.
	jp nz,actor_update	;488b	c2 b0 48	. . H
	ld hl,(l0ef6h)		;488e	2a f6 0e	* . .
	ld (l0f91h+2),hl	;4891	22 93 0f	" . .
	ld hl,00006h		;4894	21 06 00	! . .
	ld (l0f95h+2),hl	;4897	22 97 0f	" . .
sub_489ah:
	ld hl,(l0f9fh)		;489a	2a 9f 0f	* . .
	ld de,0fffdh		;489d	11 fd ff	. . .
	ld a,h			;48a0	7c		|
	rla			;48a1	17		.
	jp c,l48a7h		;48a2	da a7 48	. . H
	add hl,de		;48a5	19		.
	add hl,hl		;48a6	29		)
l48a7h:
	jp nc,actor_update	;48a7	d2 b0 48	. . H
	ld hl,00000h		;48aa	21 00 00	! . .
	ld (l0f9fh),hl		;48ad	22 9f 0f	" . .
actor_update:
	ld hl,(actor_index_word)	;48b0	2a b2 0f	* . .
	add hl,hl		;48b3	29		)
	ld de,00e94h		;48b4	11 94 0e	. . .
	add hl,de		;48b7	19		.
	ld e,(hl)		;48b8	5e		^
	inc hl			;48b9	23		#
	ld d,(hl)		;48ba	56		V
	push de			;48bb	d5		.
	pop hl			;48bc	e1		.
	ld de,00001h		;48bd	11 01 00	. . .
	add hl,de		;48c0	19		.
	ld a,h			;48c1	7c		|
	or l			;48c2	b5		.
	jp z,l4bcbh		;48c3	ca cb 4b	. . K
	ld hl,(actor_index_word)	;48c6	2a b2 0f	* . .
	add hl,hl		;48c9	29		)
	push hl			;48ca	e5		.
	ld de,l0e68h		;48cb	11 68 0e	. h .
	add hl,de		;48ce	19		.
	ld e,(hl)		;48cf	5e		^
	inc hl			;48d0	23		#
	ld d,(hl)		;48d1	56		V
	ex de,hl		;48d2	eb		.
	ld (l0fb4h),hl		;48d3	22 b4 0f	" . .
	pop hl			;48d6	e1		.
	ld de,l0e7eh		;48d7	11 7e 0e	. ~ .
	add hl,de		;48da	19		.
	ld e,(hl)		;48db	5e		^
	inc hl			;48dc	23		#
	ld d,(hl)		;48dd	56		V
	ex de,hl		;48de	eb		.
	ld (l0fb6h),hl		;48df	22 b6 0f	" . .
	ld hl,(l0fb4h)		;48e2	2a b4 0f	* . .
	ld (l0fb6h+2),hl	;48e5	22 b8 0f	" . .
	ld hl,(l0fb6h)		;48e8	2a b6 0f	* . .
	ld (00fbah),hl		;48eb	22 ba 0f	" . .
	ld hl,(l0fb6h)		;48ee	2a b6 0f	* . .
	call integer_mul_inline	;48f1	cd 8e 76	. . v
	defw 00051h		;48f4	51 00		Q .
	ex de,hl		;48f6	eb		.
	ld hl,(l0fb4h)		;48f7	2a b4 0f	* . .
	add hl,de		;48fa	19		.
	add hl,hl		;48fb	29		)
	ld de,l010ah		;48fc	11 0a 01	. . .
	add hl,de		;48ff	19		.
	ld e,(hl)		;4900	5e		^
	inc hl			;4901	23		#
	ld d,(hl)		;4902	56		V
	push de			;4903	d5		.
	pop hl			;4904	e1		.
	ld de,0fff9h		;4905	11 f9 ff	. . .
	add hl,de		;4908	19		.
	ld a,h			;4909	7c		|
	or l			;490a	b5		.
	jp nz,l4938h		;490b	c2 38 49	. 8 I
	ld hl,(actor_index_word)	;490e	2a b2 0f	* . .
	add hl,hl		;4911	29		)
	ld de,00e94h		;4912	11 94 0e	. . .
	add hl,de		;4915	19		.
	ld de,0ffffh		;4916	11 ff ff	. . .
	ld (hl),e		;4919	73		s
	inc hl			;491a	23		#
	ld (hl),d		;491b	72		r
	ld hl,(l0f99h)		;491c	2a 99 0f	* . .
	dec hl			;491f	2b		+
	ld (l0f99h),hl		;4920	22 99 0f	" . .
	ld de,l0fb6h		;4923	11 b6 0f	. . .
	ld hl,l0fb4h		;4926	21 b4 0f	! . .
	call sub_626bh		;4929	cd 6b 62	. k b
	call print_setup	;492c	cd ea 6f	. . o
	ld hl,s_actor_asterisk	;492f	21 72 5a	! r Z
	call print_string	;4932	cd 6e 6e	. n n
	jp l4bcbh		;4935	c3 cb 4b	. . K
l4938h:
	ld hl,(l0fb6h)		;4938	2a b6 0f	* . .
	call integer_mul_inline	;493b	cd 8e 76	. . v
sub_493eh:
	defw 00051h		;493e	51 00		Q .
	ex de,hl		;4940	eb		.
	ld hl,(l0fb4h)		;4941	2a b4 0f	* . .
	add hl,de		;4944	19		.
	add hl,hl		;4945	29		)
	ld de,l010ah		;4946	11 0a 01	. . .
	add hl,de		;4949	19		.
	ld e,(hl)		;494a	5e		^
	inc hl			;494b	23		#
	ld d,(hl)		;494c	56		V
	push de			;494d	d5		.
	pop hl			;494e	e1		.
	ld de,0fffah		;494f	11 fa ff	. . .
	add hl,de		;4952	19		.
	ld a,h			;4953	7c		|
	or l			;4954	b5		.
	jp nz,l49aah		;4955	c2 aa 49	. . I
	ld hl,00005h		;4958	21 05 00	! . .
	call random_float	;495b	cd 31 6c	. 1 l
	call sub_7412h		;495e	cd 12 74	. . t
	ld b,c			;4961	41		A
	ld h,c			;4962	61		a
	ld hl,l9285h		;4963	21 85 92	! . .
	call sub_71c8h		;4966	cd c8 71	. . q
	call sub_7618h		;4969	cd 18 76	. . v
	ld (l0fbch),hl		;496c	22 bc 0f	" . .
	ld hl,(l0fbch)		;496f	2a bc 0f	* . .
	inc hl			;4972	23		#
	call sub_7524h		;4973	cd 24 75	. $ u
	inc bc			;4976	03		.
	ld a,l			;4977	7d		}
	ld c,c			;4978	49		I
	sbc a,c			;4979	99		.
	ld c,c			;497a	49		I
	ex de,hl		;497b	eb		.
	ld c,c			;497c	49		I
	ld hl,(actor_index_word)	;497d	2a b2 0f	* . .
	add hl,hl		;4980	29		)
	ld de,00e94h		;4981	11 94 0e	. . .
	add hl,de		;4984	19		.
	push hl			;4985	e5		.
	ld e,(hl)		;4986	5e		^
sub_4987h:
	inc hl			;4987	23		#
	ld d,(hl)		;4988	56		V
	ex de,hl		;4989	eb		.
	add hl,hl		;498a	29		)
	ld de,l0e5ch+2		;498b	11 5e 0e	. ^ .
	add hl,de		;498e	19		.
	ld e,(hl)		;498f	5e		^
	inc hl			;4990	23		#
	ld d,(hl)		;4991	56		V
	pop hl			;4992	e1		.
	ld (hl),e		;4993	73		s
	inc hl			;4994	23		#
	ld (hl),d		;4995	72		r
	jp l49ebh		;4996	c3 eb 49	. . I
l4999h:
	ld hl,(actor_index_word)	;4999	2a b2 0f	* . .
	add hl,hl		;499c	29		)
	ld de,00e94h		;499d	11 94 0e	. . .
	add hl,de		;49a0	19		.
	ld de,00002h		;49a1	11 02 00	. . .
	ld (hl),e		;49a4	73		s
	inc hl			;49a5	23		#
	ld (hl),d		;49a6	72		r
	jp l49ebh		;49a7	c3 eb 49	. . I
l49aah:
	ld hl,(l0fb6h)		;49aa	2a b6 0f	* . .
	call integer_mul_inline	;49ad	cd 8e 76	. . v
	defw 00051h		;49b0	51 00		Q .
	ex de,hl		;49b2	eb		.
	ld hl,(l0fb4h)		;49b3	2a b4 0f	* . .
	add hl,de		;49b6	19		.
	add hl,hl		;49b7	29		)
	ld de,l01ach		;49b8	11 ac 01	. . .
	add hl,de		;49bb	19		.
	ld e,(hl)		;49bc	5e		^
	inc hl			;49bd	23		#
	ld d,(hl)		;49be	56		V
	ex de,hl		;49bf	eb		.
	push hl			;49c0	e5		.
	ld a,h			;49c1	7c		|
	or l			;49c2	b5		.
	sub 001h		;49c3	d6 01		. .
	sbc a,a			;49c5	9f		.
	ld h,a			;49c6	67		g
	ld l,a			;49c7	6f		o
	ld (00ff4h),hl		;49c8	22 f4 0f	" . .
	pop hl			;49cb	e1		.
	ld de,0fffah		;49cc	11 fa ff	. . .
	ld a,h			;49cf	7c		|
	rla			;49d0	17		.
	jp c,l49d6h		;49d1	da d6 49	. . I
	add hl,de		;49d4	19		.
	add hl,hl		;49d5	29		)
l49d6h:
	ccf			;49d6	3f		?
	sbc a,a			;49d7	9f		.
	ld h,a			;49d8	67		g
	ld l,a			;49d9	6f		o
	push hl			;49da	e5		.
	ld hl,(00ff4h)		;49db	2a f4 0f	* . .
	ex de,hl		;49de	eb		.
	pop hl			;49df	e1		.
	ld a,h			;49e0	7c		|
	or d			;49e1	b2		.
	ld h,a			;49e2	67		g
	ld a,l			;49e3	7d		}
	or e			;49e4	b3		.
	ld l,a			;49e5	6f		o
	ld a,h			;49e6	7c		|
	or l			;49e7	b5		.
	jp nz,l4999h		;49e8	c2 99 49	. . I
l49ebh:
	ld hl,(actor_index_word)	;49eb	2a b2 0f	* . .
	add hl,hl		;49ee	29		)
	ld de,00e94h		;49ef	11 94 0e	. . .
	add hl,de		;49f2	19		.
	ld e,(hl)		;49f3	5e		^
	inc hl			;49f4	23		#
	ld d,(hl)		;49f5	56		V
	ex de,hl		;49f6	eb		.
	call sub_7524h		;49f7	cd 24 75	. $ u
	inc b			;49fa	04		.
	inc bc			;49fb	03		.
	ld c,d			;49fc	4a		J
	inc bc			;49fd	03		.
	ld c,d			;49fe	4a		J
	ld (hl),e		;49ff	73		s
	ld c,d			;4a00	4a		J
	ld (hl),e		;4a01	73		s
	ld c,d			;4a02	4a		J
	ld hl,(l0fb6h)		;4a03	2a b6 0f	* . .
	inc hl			;4a06	23		#
	ld (l0fb6h),hl		;4a07	22 b6 0f	" . .
	ld hl,(l0fb6h)		;4a0a	2a b6 0f	* . .
	call integer_mul_inline	;4a0d	cd 8e 76	. . v
	defw 00051h		;4a10	51 00		Q .
	ex de,hl		;4a12	eb		.
	ld hl,(l0fb4h)		;4a13	2a b4 0f	* . .
	add hl,de		;4a16	19		.
	add hl,hl		;4a17	29		)
	ld de,l010ah		;4a18	11 0a 01	. . .
	add hl,de		;4a1b	19		.
	ld e,(hl)		;4a1c	5e		^
	inc hl			;4a1d	23		#
	ld d,(hl)		;4a1e	56		V
	ex de,hl		;4a1f	eb		.
	push hl			;4a20	e5		.
	ld a,h			;4a21	7c		|
	or l			;4a22	b5		.
	sub 001h		;4a23	d6 01		. .
	sbc a,a			;4a25	9f		.
	ld h,a			;4a26	67		g
	ld l,a			;4a27	6f		o
	ld (00ff4h),hl		;4a28	22 f4 0f	" . .
	pop hl			;4a2b	e1		.
	ld de,0fffah		;4a2c	11 fa ff	. . .
	ld a,h			;4a2f	7c		|
	rla			;4a30	17		.
	jp c,l4a36h		;4a31	da 36 4a	. 6 J
	add hl,de		;4a34	19		.
	add hl,hl		;4a35	29		)
l4a36h:
	ccf			;4a36	3f		?
	sbc a,a			;4a37	9f		.
	ld h,a			;4a38	67		g
	ld l,a			;4a39	6f		o
	push hl			;4a3a	e5		.
	ld hl,(00ff4h)		;4a3b	2a f4 0f	* . .
	ex de,hl		;4a3e	eb		.
	pop hl			;4a3f	e1		.
	ld a,h			;4a40	7c		|
	or d			;4a41	b2		.
	ld h,a			;4a42	67		g
	ld a,l			;4a43	7d		}
	or e			;4a44	b3		.
	ld l,a			;4a45	6f		o
	ld a,h			;4a46	7c		|
	or l			;4a47	b5		.
	jp nz,l4af4h		;4a48	c2 f4 4a	. . J
	ld hl,00005h		;4a4b	21 05 00	! . .
	call random_float	;4a4e	cd 31 6c	. 1 l
	call sub_74c9h		;4a51	cd c9 74	. . t
	ld bc,l8521h		;4a54	01 21 85	. ! .
	sub d			;4a57	92		.
	call sub_71c8h		;4a58	cd c8 71	. . q
	call sub_73e9h		;4a5b	cd e9 73	. . s
	ld b,c			;4a5e	41		A
	ld h,c			;4a5f	61		a
	call sub_7618h		;4a60	cd 18 76	. . v
	push hl			;4a63	e5		.
	ld hl,(actor_index_word)	;4a64	2a b2 0f	* . .
	add hl,hl		;4a67	29		)
	ld de,00e94h		;4a68	11 94 0e	. . .
	add hl,de		;4a6b	19		.
	pop de			;4a6c	d1		.
	ld (hl),e		;4a6d	73		s
	inc hl			;4a6e	23		#
	ld (hl),d		;4a6f	72		r
	jp l4ae8h		;4a70	c3 e8 4a	. . J
	ld hl,(actor_index_word)	;4a73	2a b2 0f	* . .
	add hl,hl		;4a76	29		)
	ld de,00e94h		;4a77	11 94 0e	. . .
	add hl,de		;4a7a	19		.
	ld e,(hl)		;4a7b	5e		^
	inc hl			;4a7c	23		#
	ld d,(hl)		;4a7d	56		V
	ex de,hl		;4a7e	eb		.
	add hl,hl		;4a7f	29		)
	ld de,l0e54h		;4a80	11 54 0e	. T .
	add hl,de		;4a83	19		.
	ld e,(hl)		;4a84	5e		^
	inc hl			;4a85	23		#
	ld d,(hl)		;4a86	56		V
	ld hl,(l0fb4h)		;4a87	2a b4 0f	* . .
	add hl,de		;4a8a	19		.
	ld (l0fb4h),hl		;4a8b	22 b4 0f	" . .
	ld hl,(l0fb6h)		;4a8e	2a b6 0f	* . .
	call integer_mul_inline	;4a91	cd 8e 76	. . v
	defw 00051h		;4a94	51 00		Q .
	ex de,hl		;4a96	eb		.
	ld hl,(l0fb4h)		;4a97	2a b4 0f	* . .
	add hl,de		;4a9a	19		.
	add hl,hl		;4a9b	29		)
	ld de,l010ah		;4a9c	11 0a 01	. . .
	add hl,de		;4a9f	19		.
	ld e,(hl)		;4aa0	5e		^
	inc hl			;4aa1	23		#
	ld d,(hl)		;4aa2	56		V
	ex de,hl		;4aa3	eb		.
	push hl			;4aa4	e5		.
	ld a,h			;4aa5	7c		|
	or l			;4aa6	b5		.
	sub 001h		;4aa7	d6 01		. .
	sbc a,a			;4aa9	9f		.
	ld h,a			;4aaa	67		g
	ld l,a			;4aab	6f		o
	ld (00ff4h),hl		;4aac	22 f4 0f	" . .
	pop hl			;4aaf	e1		.
	ld de,0fffah		;4ab0	11 fa ff	. . .
	ld a,h			;4ab3	7c		|
	rla			;4ab4	17		.
	jp c,l4abah		;4ab5	da ba 4a	. . J
	add hl,de		;4ab8	19		.
	add hl,hl		;4ab9	29		)
l4abah:
	ccf			;4aba	3f		?
	sbc a,a			;4abb	9f		.
	ld h,a			;4abc	67		g
	ld l,a			;4abd	6f		o
	push hl			;4abe	e5		.
	ld hl,(00ff4h)		;4abf	2a f4 0f	* . .
	ex de,hl		;4ac2	eb		.
	pop hl			;4ac3	e1		.
	ld a,h			;4ac4	7c		|
	or d			;4ac5	b2		.
	ld h,a			;4ac6	67		g
	ld a,l			;4ac7	7d		}
	or e			;4ac8	b3		.
	ld l,a			;4ac9	6f		o
	ld a,h			;4aca	7c		|
	or l			;4acb	b5		.
	jp nz,l4af4h		;4acc	c2 f4 4a	. . J
	ld hl,(actor_index_word)	;4acf	2a b2 0f	* . .
	add hl,hl		;4ad2	29		)
	ld de,00e94h		;4ad3	11 94 0e	. . .
	add hl,de		;4ad6	19		.
	push hl			;4ad7	e5		.
	ld e,(hl)		;4ad8	5e		^
	inc hl			;4ad9	23		#
	ld d,(hl)		;4ada	56		V
	ex de,hl		;4adb	eb		.
	add hl,hl		;4adc	29		)
	ld de,l0e5ch+2		;4add	11 5e 0e	. ^ .
	add hl,de		;4ae0	19		.
	ld e,(hl)		;4ae1	5e		^
	inc hl			;4ae2	23		#
	ld d,(hl)		;4ae3	56		V
	pop hl			;4ae4	e1		.
	ld (hl),e		;4ae5	73		s
	inc hl			;4ae6	23		#
	ld (hl),d		;4ae7	72		r
l4ae8h:
	ld hl,(l0fb6h+2)	;4ae8	2a b8 0f	* . .
	ld (l0fb4h),hl		;4aeb	22 b4 0f	" . .
	ld hl,(00fbah)		;4aee	2a ba 0f	* . .
	ld (l0fb6h),hl		;4af1	22 b6 0f	" . .
l4af4h:
	ld de,00fbah		;4af4	11 ba 0f	. . .
	ld hl,l0fb6h+2		;4af7	21 b8 0f	! . .
	call sub_626bh		;4afa	cd 6b 62	. k b
	call print_setup	;4afd	cd ea 6f	. . o
	ld hl,(00fbah)		;4b00	2a ba 0f	* . .
	call integer_mul_inline	;4b03	cd 8e 76	. . v
	defw 00051h		;4b06	51 00		Q .
	ex de,hl		;4b08	eb		.
	ld hl,(l0fb6h+2)	;4b09	2a b8 0f	* . .
	add hl,de		;4b0c	19		.
	add hl,hl		;4b0d	29		)
	ld de,l010ah		;4b0e	11 0a 01	. . .
	add hl,de		;4b11	19		.
	ld e,(hl)		;4b12	5e		^
	inc hl			;4b13	23		#
	ld d,(hl)		;4b14	56		V
	ex de,hl		;4b15	eb		.
	inc hl			;4b16	23		#
	ex de,hl		;4b17	eb		.
	ld bc,l0f11h		;4b18	01 11 0f	. . .
	ld hl,00001h		;4b1b	21 01 00	! . .
	call sub_747fh		;4b1e	cd 7f 74	. . t
	call print_string	;4b21	cd 6e 6e	. n n
	ld de,l0fb6h		;4b24	11 b6 0f	. . .
	ld hl,l0fb4h		;4b27	21 b4 0f	! . .
	call sub_626bh		;4b2a	cd 6b 62	. k b
	call print_setup	;4b2d	cd ea 6f	. . o
	ld hl,s_actor_o		;4b30	21 6e 5a	! n Z
	call print_string	;4b33	cd 6e 6e	. n n
	ld hl,(actor_index_word)	;4b36	2a b2 0f	* . .
	add hl,hl		;4b39	29		)
	push hl			;4b3a	e5		.
	ld de,l0e68h		;4b3b	11 68 0e	. h .
	add hl,de		;4b3e	19		.
	push hl			;4b3f	e5		.
	ld hl,(l0fb4h)		;4b40	2a b4 0f	* . .
	ex de,hl		;4b43	eb		.
	pop hl			;4b44	e1		.
	ld (hl),e		;4b45	73		s
	inc hl			;4b46	23		#
	ld (hl),d		;4b47	72		r
	pop hl			;4b48	e1		.
	ld de,l0e7eh		;4b49	11 7e 0e	. ~ .
	add hl,de		;4b4c	19		.
	push hl			;4b4d	e5		.
	ld hl,(l0fb6h)		;4b4e	2a b6 0f	* . .
	ex de,hl		;4b51	eb		.
	pop hl			;4b52	e1		.
	ld (hl),e		;4b53	73		s
	inc hl			;4b54	23		#
	ld (hl),d		;4b55	72		r
	ld hl,(l0fb4h)		;4b56	2a b4 0f	* . .
	ex de,hl		;4b59	eb		.
	ld hl,(l0f89h)		;4b5a	2a 89 0f	* . .
	ld a,l			;4b5d	7d		}
	xor e			;4b5e	ab		.
	ld l,a			;4b5f	6f		o
	ld a,h			;4b60	7c		|
	xor d			;4b61	aa		.
	or l			;4b62	b5		.
	sub 001h		;4b63	d6 01		. .
	sbc a,a			;4b65	9f		.
	ld h,a			;4b66	67		g
	ld l,a			;4b67	6f		o
	push hl			;4b68	e5		.
	ld hl,(l0fb6h)		;4b69	2a b6 0f	* . .
	ex de,hl		;4b6c	eb		.
	ld hl,(l0f8bh)		;4b6d	2a 8b 0f	* . .
	ld a,l			;4b70	7d		}
	xor e			;4b71	ab		.
	ld l,a			;4b72	6f		o
	ld a,h			;4b73	7c		|
	xor d			;4b74	aa		.
	or l			;4b75	b5		.
	sub 001h		;4b76	d6 01		. .
	sbc a,a			;4b78	9f		.
	ld h,a			;4b79	67		g
	ld l,a			;4b7a	6f		o
	pop de			;4b7b	d1		.
	ld a,h			;4b7c	7c		|
	and d			;4b7d	a2		.
	ld h,a			;4b7e	67		g
	ld a,l			;4b7f	7d		}
	and e			;4b80	a3		.
	ld l,a			;4b81	6f		o
	ld a,h			;4b82	7c		|
	or l			;4b83	b5		.
	jp nz,l5216h		;4b84	c2 16 52	. . R
	ld hl,(l0f91h+2)	;4b87	2a 93 0f	* . .
	ld a,h			;4b8a	7c		|
	cpl			;4b8b	2f		/
	ld h,a			;4b8c	67		g
	ld a,l			;4b8d	7d		}
	cpl			;4b8e	2f		/
	ld l,a			;4b8f	6f		o
	ld a,h			;4b90	7c		|
	or l			;4b91	b5		.
	jp nz,l4bcbh		;4b92	c2 cb 4b	. . K
	ld hl,(l0fb6h)		;4b95	2a b6 0f	* . .
	dec hl			;4b98	2b		+
	ld (l0fbch+2),hl	;4b99	22 be 0f	" . .
	call sub_56d5h		;4b9c	cd d5 56	. . V
	ld hl,(l0fbch+2)	;4b9f	2a be 0f	* . .
	call integer_mul_inline	;4ba2	cd 8e 76	. . v
	defw 00051h		;4ba5	51 00		Q .
	ex de,hl		;4ba7	eb		.
	ld hl,(l0fb4h)		;4ba8	2a b4 0f	* . .
	add hl,de		;4bab	19		.
	add hl,hl		;4bac	29		)
	ld de,l010ah		;4bad	11 0a 01	. . .
	add hl,de		;4bb0	19		.
	ld e,(hl)		;4bb1	5e		^
	inc hl			;4bb2	23		#
	ld d,(hl)		;4bb3	56		V
	ex de,hl		;4bb4	eb		.
	ld a,h			;4bb5	7c		|
	or l			;4bb6	b5		.
	jp nz,l4bcbh		;4bb7	c2 cb 4b	. . K
	ld hl,(l0fbch+2)	;4bba	2a be 0f	* . .
	dec hl			;4bbd	2b		+
	ld (l0fbch+2),hl	;4bbe	22 be 0f	" . .
	ld hl,(l0fbch+2)	;4bc1	2a be 0f	* . .
	add hl,hl		;4bc4	29		)
	jp c,l4bcbh		;4bc5	da cb 4b	. . K
	call sub_56d5h		;4bc8	cd d5 56	. . V
l4bcbh:
	ld hl,(actor_index_word)	;4bcb	2a b2 0f	* . .
	inc hl			;4bce	23		#
next_actor:
	ld (actor_index_word),hl	;4bcf	22 b2 0f	" . .
	ld hl,(actor_index_word)	;4bd2	2a b2 0f	* . .
	ex de,hl		;4bd5	eb		.
	ld hl,(l0fabh)		;4bd6	2a ab 0f	* . .
	ld a,d			;4bd9	7a		z
	xor h			;4bda	ac		.
	ld a,h			;4bdb	7c		|
	jp m,l4be3h		;4bdc	fa e3 4b	. . K
	ld a,l			;4bdf	7d		}
	sub e			;4be0	93		.
	ld a,h			;4be1	7c		|
	sbc a,d			;4be2	9a		.
l4be3h:
	rla			;4be3	17		.
	jp nc,game_actor_loop	;4be4	d2 ea 47	. . G
	call sub_577fh		;4be7	cd 7f 57	. . W
	call sub_7138h		;4bea	cd 38 71	. 8 q
	call sub_7618h		;4bed	cd 18 76	. . v
	ld (l0f1fh+2),hl	;4bf0	22 21 0f	" ! .
	ld hl,(l0fa1h)		;4bf3	2a a1 0f	* . .
	dec hl			;4bf6	2b		+
	ld (l0fa1h),hl		;4bf7	22 a1 0f	" . .
	ld hl,(l0fa1h)		;4bfa	2a a1 0f	* . .
	ld a,h			;4bfd	7c		|
	add a,a			;4bfe	87		.
	jp c,l4c06h		;4bff	da 06 4c	. . L
	or l			;4c02	b5		.
	jp nz,l4c37h		;4c03	c2 37 4c	. 7 L
l4c06h:
	ld hl,(bonus_word)	;4c06	2a 77 0f	* w .
	dec hl			;4c09	2b		+
	ld (bonus_word),hl	;4c0a	22 77 0f	" w .
	call sub_5769h		;4c0d	cd 69 57	. i W
	ld hl,(bonus_word)	;4c10	2a 77 0f	* w .
	ld a,h			;4c13	7c		|
	or l			;4c14	b5		.
	jp z,l5216h		;4c15	ca 16 52	. . R
	ld hl,(bonus_word)	;4c18	2a 77 0f	* w .
	ld de,0fff5h		;4c1b	11 f5 ff	. . .
	ld a,h			;4c1e	7c		|
	rla			;4c1f	17		.
	jp c,l4c25h		;4c20	da 25 4c	. % L
	add hl,de		;4c23	19		.
	add hl,hl		;4c24	29		)
l4c25h:
	jp nc,l4c31h		;4c25	d2 31 4c	. 1 L
	call print_setup	;4c28	cd ea 6f	. . o
	ld hl,l0f49h		;4c2b	21 49 0f	! I .
	call print_string	;4c2e	cd 6e 6e	. n n
l4c31h:
	ld hl,(00f01h)		;4c31	2a 01 0f	* . .
	ld (l0fa1h),hl		;4c34	22 a1 0f	" . .
l4c37h:
	ld hl,(l0f89h)		;4c37	2a 89 0f	* . .
	ld (l0fb4h),hl		;4c3a	22 b4 0f	" . .
	ld hl,(l0f8bh)		;4c3d	2a 8b 0f	* . .
	ld (l0fb6h),hl		;4c40	22 b6 0f	" . .
	ld hl,(l0f91h+2)	;4c43	2a 93 0f	* . .
	ld a,h			;4c46	7c		|
	or l			;4c47	b5		.
	jp nz,l4e50h		;4c48	c2 50 4e	. P N
	ld hl,(l0f9fh)		;4c4b	2a 9f 0f	* . .
	ld (l0fc0h),hl		;4c4e	22 c0 0f	" . .
	ld hl,(l0f9dh)		;4c51	2a 9d 0f	* . .
	ld (l0f9fh),hl		;4c54	22 9f 0f	" . .
	ld hl,(l0fb6h)		;4c57	2a b6 0f	* . .
	call integer_mul_inline	;4c5a	cd 8e 76	. . v
	defw 00051h		;4c5d	51 00		Q .
	ex de,hl		;4c5f	eb		.
	ld hl,(l0fb4h)		;4c60	2a b4 0f	* . .
	add hl,de		;4c63	19		.
	add hl,hl		;4c64	29		)
	ld de,l010ah		;4c65	11 0a 01	. . .
	add hl,de		;4c68	19		.
	ld e,(hl)		;4c69	5e		^
	inc hl			;4c6a	23		#
	ld d,(hl)		;4c6b	56		V
	ex de,hl		;4c6c	eb		.
	ld a,h			;4c6d	7c		|
	or l			;4c6e	b5		.
	jp nz,l4cbch		;4c6f	c2 bc 4c	. . L
	ld hl,(l0fb6h)		;4c72	2a b6 0f	* . .
sub_4c75h:
	call integer_mul_inline	;4c75	cd 8e 76	. . v
	defw 00051h		;4c78	51 00		Q .
	ex de,hl		;4c7a	eb		.
	ld hl,(l0fb4h)		;4c7b	2a b4 0f	* . .
	add hl,de		;4c7e	19		.
	add hl,hl		;4c7f	29		)
	ld de,l01ach		;4c80	11 ac 01	. . .
	add hl,de		;4c83	19		.
	ld e,(hl)		;4c84	5e		^
	inc hl			;4c85	23		#
	ld d,(hl)		;4c86	56		V
sub_4c87h:
	ex de,hl		;4c87	eb		.
	push hl			;4c88	e5		.
	ld a,h			;4c89	7c		|
	or l			;4c8a	b5		.
	sub 001h		;4c8b	d6 01		. .
	sbc a,a			;4c8d	9f		.
	ld h,a			;4c8e	67		g
	ld l,a			;4c8f	6f		o
	ld (00ff4h),hl		;4c90	22 f4 0f	" . .
	pop hl			;4c93	e1		.
	ld de,0fffah		;4c94	11 fa ff	. . .
	ld a,h			;4c97	7c		|
	rla			;4c98	17		.
	jp c,l4c9eh		;4c99	da 9e 4c	. . L
	add hl,de		;4c9c	19		.
	add hl,hl		;4c9d	29		)
l4c9eh:
	ccf			;4c9e	3f		?
	sbc a,a			;4c9f	9f		.
	ld h,a			;4ca0	67		g
	ld l,a			;4ca1	6f		o
	push hl			;4ca2	e5		.
	ld hl,(00ff4h)		;4ca3	2a f4 0f	* . .
	ex de,hl		;4ca6	eb		.
	pop hl			;4ca7	e1		.
	ld a,h			;4ca8	7c		|
	or d			;4ca9	b2		.
	ld h,a			;4caa	67		g
	ld a,l			;4cab	7d		}
	or e			;4cac	b3		.
	ld l,a			;4cad	6f		o
	ld a,h			;4cae	7c		|
	or l			;4caf	b5		.
	jp z,l4cbch		;4cb0	ca bc 4c	. . L
	ld hl,00002h		;4cb3	21 02 00	! . .
	ld (l0f9fh),hl		;4cb6	22 9f 0f	" . .
	jp l4d3ah		;4cb9	c3 3a 4d	. : M
l4cbch:
	ld hl,(l0f9fh)		;4cbc	2a 9f 0f	* . .
	inc hl			;4cbf	23		#
	call sub_7524h		;4cc0	cd 24 75	. $ u
	dec b			;4cc3	05		.
	rst 30h			;4cc4	f7		.
	ld c,a			;4cc5	4f		O
	adc a,04ch		;4cc6	ce 4c		. L
	ld a,(0a14dh)		;4cc8	3a 4d a1	: M .
	ld c,l			;4ccb	4d		M
	and c			;4ccc	a1		.
	ld c,l			;4ccd	4d		M
	ld hl,(l0fb6h)		;4cce	2a b6 0f	* . .
	dec hl			;4cd1	2b		+
	ld (l0fb6h),hl		;4cd2	22 b6 0f	" . .
	ld hl,(l0fb6h)		;4cd5	2a b6 0f	* . .
	call integer_mul_inline	;4cd8	cd 8e 76	. . v
	defw 00051h		;4cdb	51 00		Q .
	ex de,hl		;4cdd	eb		.
	ld hl,(l0fb4h)		;4cde	2a b4 0f	* . .
	add hl,de		;4ce1	19		.
	add hl,hl		;4ce2	29		)
	ld de,l010ah		;4ce3	11 0a 01	. . .
	add hl,de		;4ce6	19		.
	ld e,(hl)		;4ce7	5e		^
	inc hl			;4ce8	23		#
	ld d,(hl)		;4ce9	56		V
	push de			;4cea	d5		.
	pop hl			;4ceb	e1		.
	push hl			;4cec	e5		.
	ld de,0fffah		;4ced	11 fa ff	. . .
	ld a,h			;4cf0	7c		|
	rla			;4cf1	17		.
	jp c,l4cf7h		;4cf2	da f7 4c	. . L
	add hl,de		;4cf5	19		.
	add hl,hl		;4cf6	29		)
l4cf7h:
	ccf			;4cf7	3f		?
	sbc a,a			;4cf8	9f		.
	ld h,a			;4cf9	67		g
	ld l,a			;4cfa	6f		o
	ld (00ff4h),hl		;4cfb	22 f4 0f	" . .
	pop hl			;4cfe	e1		.
	ld de,0fffdh		;4cff	11 fd ff	. . .
	add hl,de		;4d02	19		.
	ld a,h			;4d03	7c		|
	or l			;4d04	b5		.
	sub 001h		;4d05	d6 01		. .
	sbc a,a			;4d07	9f		.
	ld h,a			;4d08	67		g
	ld l,a			;4d09	6f		o
	push hl			;4d0a	e5		.
	ld hl,(00ff4h)		;4d0b	2a f4 0f	* . .
	ex de,hl		;4d0e	eb		.
	pop hl			;4d0f	e1		.
	ld a,h			;4d10	7c		|
	or d			;4d11	b2		.
	ld h,a			;4d12	67		g
	ld a,l			;4d13	7d		}
	or e			;4d14	b3		.
	ld l,a			;4d15	6f		o
	ld a,h			;4d16	7c		|
	or l			;4d17	b5		.
	jp nz,l4ff7h		;4d18	c2 f7 4f	. . O
l4d1bh:
	ld hl,(l0f8bh)		;4d1b	2a 8b 0f	* . .
	ld (l0fb6h),hl		;4d1e	22 b6 0f	" . .
	ld hl,(l0f9fh)		;4d21	2a 9f 0f	* . .
	ex de,hl		;4d24	eb		.
	ld hl,(l0fc0h)		;4d25	2a c0 0f	* . .
	ld a,l			;4d28	7d		}
	xor e			;4d29	ab		.
	ld l,a			;4d2a	6f		o
	ld a,h			;4d2b	7c		|
	xor d			;4d2c	aa		.
	or l			;4d2d	b5		.
	jp z,l4ff7h		;4d2e	ca f7 4f	. . O
	ld hl,(l0fc0h)		;4d31	2a c0 0f	* . .
	ld (l0f9fh),hl		;4d34	22 9f 0f	" . .
	jp l4cbch		;4d37	c3 bc 4c	. . L
l4d3ah:
	ld hl,(l0fb6h)		;4d3a	2a b6 0f	* . .
	inc hl			;4d3d	23		#
	ld (l0fb6h),hl		;4d3e	22 b6 0f	" . .
	ld hl,(l0fb6h)		;4d41	2a b6 0f	* . .
	call integer_mul_inline	;4d44	cd 8e 76	. . v
	defw 00051h		;4d47	51 00		Q .
	ex de,hl		;4d49	eb		.
	ld hl,(l0fb4h)		;4d4a	2a b4 0f	* . .
	add hl,de		;4d4d	19		.
	add hl,hl		;4d4e	29		)
	ld de,l010ah		;4d4f	11 0a 01	. . .
	add hl,de		;4d52	19		.
	ld e,(hl)		;4d53	5e		^
	inc hl			;4d54	23		#
	ld d,(hl)		;4d55	56		V
	ex de,hl		;4d56	eb		.
	push hl			;4d57	e5		.
	ld a,h			;4d58	7c		|
	or l			;4d59	b5		.
	sub 001h		;4d5a	d6 01		. .
	sbc a,a			;4d5c	9f		.
	ld h,a			;4d5d	67		g
	ld l,a			;4d5e	6f		o
	ld (00ff4h),hl		;4d5f	22 f4 0f	" . .
sub_4d62h:
	pop hl			;4d62	e1		.
	push hl			;4d63	e5		.
	ld de,0fffdh		;4d64	11 fd ff	. . .
	add hl,de		;4d67	19		.
	ld a,h			;4d68	7c		|
	or l			;4d69	b5		.
	sub 001h		;4d6a	d6 01		. .
	sbc a,a			;4d6c	9f		.
	ld h,a			;4d6d	67		g
	ld l,a			;4d6e	6f		o
	push hl			;4d6f	e5		.
	ld hl,(00ff4h)		;4d70	2a f4 0f	* . .
	ex de,hl		;4d73	eb		.
	pop hl			;4d74	e1		.
	ld a,h			;4d75	7c		|
	or d			;4d76	b2		.
	ld h,a			;4d77	67		g
	ld a,l			;4d78	7d		}
	or e			;4d79	b3		.
	ld l,a			;4d7a	6f		o
	ld (l0ff6h),hl		;4d7b	22 f6 0f	" . .
	pop hl			;4d7e	e1		.
	ld de,0fffah		;4d7f	11 fa ff	. . .
	ld a,h			;4d82	7c		|
	rla			;4d83	17		.
	jp c,l4d89h		;4d84	da 89 4d	. . M
sub_4d87h:
	add hl,de		;4d87	19		.
	add hl,hl		;4d88	29		)
l4d89h:
	ccf			;4d89	3f		?
	sbc a,a			;4d8a	9f		.
	ld h,a			;4d8b	67		g
	ld l,a			;4d8c	6f		o
	push hl			;4d8d	e5		.
	ld hl,(l0ff6h)		;4d8e	2a f6 0f	* . .
sub_4d91h:
	ex de,hl		;4d91	eb		.
	pop hl			;4d92	e1		.
	ld a,h			;4d93	7c		|
	or d			;4d94	b2		.
	ld h,a			;4d95	67		g
	ld a,l			;4d96	7d		}
	or e			;4d97	b3		.
	ld l,a			;4d98	6f		o
	ld a,h			;4d99	7c		|
	or l			;4d9a	b5		.
	jp nz,l4ff7h		;4d9b	c2 f7 4f	. . O
	jp l4d1bh		;4d9e	c3 1b 4d	. . M
	ld hl,(l0fb6h)		;4da1	2a b6 0f	* . .
	inc hl			;4da4	23		#
	ld (00fc2h),hl		;4da5	22 c2 0f	" . .
	ld hl,(00fc2h)		;4da8	2a c2 0f	* . .
	call integer_mul_inline	;4dab	cd 8e 76	. . v
	defw 00051h		;4dae	51 00		Q .
	ex de,hl		;4db0	eb		.
	ld hl,(l0fb4h)		;4db1	2a b4 0f	* . .
	add hl,de		;4db4	19		.
	add hl,hl		;4db5	29		)
	ld de,l010ah		;4db6	11 0a 01	. . .
	add hl,de		;4db9	19		.
	ld e,(hl)		;4dba	5e		^
	inc hl			;4dbb	23		#
	ld d,(hl)		;4dbc	56		V
	push de			;4dbd	d5		.
	pop hl			;4dbe	e1		.
	ld de,0ffffh		;4dbf	11 ff ff	. . .
	add hl,de		;4dc2	19		.
	ld a,h			;4dc3	7c		|
	or l			;4dc4	b5		.
	jp nz,l4df2h		;4dc5	c2 f2 4d	. . M
	ld hl,(00fc2h)		;4dc8	2a c2 0f	* . .
	call integer_mul_inline	;4dcb	cd 8e 76	. . v
	defw 00051h		;4dce	51 00		Q .
	ex de,hl		;4dd0	eb		.
	ld hl,(l0fb4h)		;4dd1	2a b4 0f	* . .
	add hl,de		;4dd4	19		.
	add hl,hl		;4dd5	29		)
	ld de,l010ah		;4dd6	11 0a 01	. . .
	add hl,de		;4dd9	19		.
	ld de,00000h		;4dda	11 00 00	. . .
	ld (hl),e		;4ddd	73		s
	inc hl			;4dde	23		#
	ld (hl),d		;4ddf	72		r
	ld de,00fc2h		;4de0	11 c2 0f	. . .
	ld hl,l0fb4h		;4de3	21 b4 0f	! . .
	call sub_626bh		;4de6	cd 6b 62	. k b
	call print_setup	;4de9	cd ea 6f	. . o
	ld hl,s_space		;4dec	21 33 61	! 3 a
	call print_string	;4def	cd 6e 6e	. n n
l4df2h:
	ld hl,(l0f9fh)		;4df2	2a 9f 0f	* . .
	add hl,hl		;4df5	29		)
	ld de,l0e54h		;4df6	11 54 0e	. T .
	add hl,de		;4df9	19		.
	ld e,(hl)		;4dfa	5e		^
	inc hl			;4dfb	23		#
	ld d,(hl)		;4dfc	56		V
	ld hl,(l0fb4h)		;4dfd	2a b4 0f	* . .
	add hl,de		;4e00	19		.
	ld (l0fb4h),hl		;4e01	22 b4 0f	" . .
	ld hl,(l0fb6h)		;4e04	2a b6 0f	* . .
	call integer_mul_inline	;4e07	cd 8e 76	. . v
	defw 00051h		;4e0a	51 00		Q .
	ex de,hl		;4e0c	eb		.
	ld hl,(l0fb4h)		;4e0d	2a b4 0f	* . .
	add hl,de		;4e10	19		.
	add hl,hl		;4e11	29		)
	ld de,l010ah		;4e12	11 0a 01	. . .
	add hl,de		;4e15	19		.
	ld e,(hl)		;4e16	5e		^
	inc hl			;4e17	23		#
	ld d,(hl)		;4e18	56		V
	push de			;4e19	d5		.
	pop hl			;4e1a	e1		.
	push hl			;4e1b	e5		.
	ld de,0fffch		;4e1c	11 fc ff	. . .
	add hl,de		;4e1f	19		.
	ld a,h			;4e20	7c		|
	or l			;4e21	b5		.
	add a,0ffh		;4e22	c6 ff		. .
	sbc a,a			;4e24	9f		.
	ld h,a			;4e25	67		g
	ld l,a			;4e26	6f		o
	ld (00ff4h),hl		;4e27	22 f4 0f	" . .
	pop hl			;4e2a	e1		.
	ld de,0fffeh		;4e2b	11 fe ff	. . .
	add hl,de		;4e2e	19		.
	ld a,h			;4e2f	7c		|
	or l			;4e30	b5		.
	add a,0ffh		;4e31	c6 ff		. .
	sbc a,a			;4e33	9f		.
	ld h,a			;4e34	67		g
	ld l,a			;4e35	6f		o
	push hl			;4e36	e5		.
	ld hl,(00ff4h)		;4e37	2a f4 0f	* . .
	ex de,hl		;4e3a	eb		.
	pop hl			;4e3b	e1		.
	ld a,h			;4e3c	7c		|
	and d			;4e3d	a2		.
	ld h,a			;4e3e	67		g
	ld a,l			;4e3f	7d		}
	and e			;4e40	a3		.
	ld l,a			;4e41	6f		o
	ld a,h			;4e42	7c		|
	or l			;4e43	b5		.
	jp nz,l4ff7h		;4e44	c2 f7 4f	. . O
	ld hl,(l0f89h)		;4e47	2a 89 0f	* . .
	ld (l0fb4h),hl		;4e4a	22 b4 0f	" . .
	jp l4ff7h		;4e4d	c3 f7 4f	. . O
l4e50h:
	ld hl,(l0f9dh)		;4e50	2a 9d 0f	* . .
	ld (l0f9fh),hl		;4e53	22 9f 0f	" . .
	ld hl,(l0f9fh)		;4e56	2a 9f 0f	* . .
	ld de,0fffdh		;4e59	11 fd ff	. . .
	ld a,h			;4e5c	7c		|
	rla			;4e5d	17		.
	jp c,l4e63h		;4e5e	da 63 4e	. c N
	add hl,de		;4e61	19		.
	add hl,hl		;4e62	29		)
l4e63h:
	jp nc,l4e6ch		;4e63	d2 6c 4e	. l N
	ld hl,00000h		;4e66	21 00 00	! . .
	ld (l0f9fh),hl		;4e69	22 9f 0f	" . .
l4e6ch:
	ld hl,(l0f9fh)		;4e6c	2a 9f 0f	* . .
	add hl,hl		;4e6f	29		)
	ld de,l0e54h		;4e70	11 54 0e	. T .
	add hl,de		;4e73	19		.
	ld e,(hl)		;4e74	5e		^
	inc hl			;4e75	23		#
	ld d,(hl)		;4e76	56		V
	ld hl,(l0fb4h)		;4e77	2a b4 0f	* . .
	add hl,de		;4e7a	19		.
	ld (l0fb4h),hl		;4e7b	22 b4 0f	" . .
	ld hl,(l0fb6h)		;4e7e	2a b6 0f	* . .
	inc hl			;4e81	23		#
	ld (l0fbch+2),hl	;4e82	22 be 0f	" . .
	call sub_5670h		;4e85	cd 70 56	. p V
	ld hl,(l0fbch+2)	;4e88	2a be 0f	* . .
	call integer_mul_inline	;4e8b	cd 8e 76	. . v
	defw 00051h		;4e8e	51 00		Q .
	ex de,hl		;4e90	eb		.
	ld hl,(l0fb4h)		;4e91	2a b4 0f	* . .
	add hl,de		;4e94	19		.
	add hl,hl		;4e95	29		)
	ld de,l010ah		;4e96	11 0a 01	. . .
	add hl,de		;4e99	19		.
	ld e,(hl)		;4e9a	5e		^
	inc hl			;4e9b	23		#
	ld d,(hl)		;4e9c	56		V
	ex de,hl		;4e9d	eb		.
	ld a,h			;4e9e	7c		|
	or l			;4e9f	b5		.
	jp nz,l4ec2h		;4ea0	c2 c2 4e	. . N
	ld hl,(l0fbch+2)	;4ea3	2a be 0f	* . .
	inc hl			;4ea6	23		#
	ld (l0fbch+2),hl	;4ea7	22 be 0f	" . .
	ld hl,(l0fbch+2)	;4eaa	2a be 0f	* . .
	ex de,hl		;4ead	eb		.
	ld hl,(l0efbh)		;4eae	2a fb 0e	* . .
	ld a,d			;4eb1	7a		z
	xor h			;4eb2	ac		.
	ld a,h			;4eb3	7c		|
	jp m,l4ebbh		;4eb4	fa bb 4e	. . N
	ld a,l			;4eb7	7d		}
	sub e			;4eb8	93		.
	ld a,h			;4eb9	7c		|
	sbc a,d			;4eba	9a		.
l4ebbh:
	rla			;4ebb	17		.
	jp c,l4ec2h		;4ebc	da c2 4e	. . N
	call sub_5670h		;4ebf	cd 70 56	. p V
l4ec2h:
	ld hl,(l0fa9h)		;4ec2	2a a9 0f	* . .
	ld a,h			;4ec5	7c		|
	or l			;4ec6	b5		.
	jp z,l4ecdh		;4ec7	ca cd 4e	. . N
	call sub_5706h		;4eca	cd 06 57	. . W
l4ecdh:
	ld hl,(l0f95h+2)	;4ecd	2a 97 0f	* . .
	call sub_7524h		;4ed0	cd 24 75	. $ u
	ld b,0eah		;4ed3	06 ea		. .
	ld c,(hl)		;4ed5	4e		N
	jp pe,0f14eh		;4ed6	ea 4e f1	. N .
	ld c,(hl)		;4ed9	4e		N
	pop af			;4eda	f1		.
	ld c,(hl)		;4edb	4e		N
	ret po			;4edc	e0		.
	ld c,(hl)		;4edd	4e		N
	ret po			;4ede	e0		.
	ld c,(hl)		;4edf	4e		N
	ld hl,(l0fb6h)		;4ee0	2a b6 0f	* . .
	dec hl			;4ee3	2b		+
	ld (l0fb6h),hl		;4ee4	22 b6 0f	" . .
	jp l4ef1h		;4ee7	c3 f1 4e	. . N
	ld hl,(l0fb6h)		;4eea	2a b6 0f	* . .
	inc hl			;4eed	23		#
	ld (l0fb6h),hl		;4eee	22 b6 0f	" . .
l4ef1h:
	ld hl,(l0fb6h)		;4ef1	2a b6 0f	* . .
	call integer_mul_inline	;4ef4	cd 8e 76	. . v
	defw 00051h		;4ef7	51 00		Q .
	ex de,hl		;4ef9	eb		.
	ld hl,(l0fb4h)		;4efa	2a b4 0f	* . .
	add hl,de		;4efd	19		.
	add hl,hl		;4efe	29		)
	ld de,l010ah		;4eff	11 0a 01	. . .
	add hl,de		;4f02	19		.
	ld e,(hl)		;4f03	5e		^
	inc hl			;4f04	23		#
	ld d,(hl)		;4f05	56		V
sub_4f06h:
	ex de,hl		;4f06	eb		.
	inc hl			;4f07	23		#
	call sub_7524h		;4f08	cd 24 75	. $ u
	rlca			;4f0b	07		.
	ld a,b			;4f0c	78		x
	ld c,a			;4f0d	4f		O
	ld a,b			;4f0e	78		x
	ld c,a			;4f0f	4f		O
	ld b,l			;4f10	45		E
	ld c,a			;4f11	4f		O
	ld a,b			;4f12	78		x
	ld c,a			;4f13	4f		O
	ld d,h			;4f14	54		T
	ld c,a			;4f15	4f		O
	ld a,b			;4f16	78		x
	ld c,a			;4f17	4f		O
	dec e			;4f18	1d		.
	ld c,a			;4f19	4f		O
	jp l4f78h		;4f1a	c3 78 4f	. x O
	ld hl,(l0ef4h)		;4f1d	2a f4 0e	* . .
	ld (l0f91h+2),hl	;4f20	22 93 0f	" . .
	ld (l0f95h),hl		;4f23	22 95 0f	" . .
	ld hl,00000h		;4f26	21 00 00	! . .
	ld (l0f9fh),hl		;4f29	22 9f 0f	" . .
	ld hl,(l0f9dh)		;4f2c	2a 9d 0f	* . .
	ld de,0fffdh		;4f2f	11 fd ff	. . .
	ld a,h			;4f32	7c		|
	rla			;4f33	17		.
	jp c,l4f39h		;4f34	da 39 4f	. 9 O
	add hl,de		;4f37	19		.
	add hl,hl		;4f38	29		)
l4f39h:
	jp c,l4f42h		;4f39	da 42 4f	. B O
	ld hl,00000h		;4f3c	21 00 00	! . .
	ld (l0f9dh),hl		;4f3f	22 9d 0f	" . .
l4f42h:
	jp l4ff7h		;4f42	c3 f7 4f	. . O
	ld hl,(l0f89h)		;4f45	2a 89 0f	* . .
	ld (l0fb4h),hl		;4f48	22 b4 0f	" . .
	ld hl,(l0f8bh)		;4f4b	2a 8b 0f	* . .
	ld (l0fb6h),hl		;4f4e	22 b6 0f	" . .
	jp l4f8bh		;4f51	c3 8b 4f	. . O
	ld hl,(l0f9fh)		;4f54	2a 9f 0f	* . .
	add hl,hl		;4f57	29		)
	ld de,l0e5ch+2		;4f58	11 5e 0e	. ^ .
	add hl,de		;4f5b	19		.
	ld e,(hl)		;4f5c	5e		^
	inc hl			;4f5d	23		#
	ld d,(hl)		;4f5e	56		V
	ex de,hl		;4f5f	eb		.
	ld (l0f9fh),hl		;4f60	22 9f 0f	" . .
	ld hl,(l0f9fh)		;4f63	2a 9f 0f	* . .
	ld (l0f9dh),hl		;4f66	22 9d 0f	" . .
	ld hl,(l0f89h)		;4f69	2a 89 0f	* . .
	ld (l0fb4h),hl		;4f6c	22 b4 0f	" . .
	ld hl,(l0f8bh)		;4f6f	2a 8b 0f	* . .
	ld (l0fb6h),hl		;4f72	22 b6 0f	" . .
	jp l4ff7h		;4f75	c3 f7 4f	. . O
l4f78h:
	ld hl,(l0f95h+2)	;4f78	2a 97 0f	* . .
	dec hl			;4f7b	2b		+
	ld (l0f95h+2),hl	;4f7c	22 97 0f	" . .
	ld hl,(l0f95h+2)	;4f7f	2a 97 0f	* . .
	ld a,h			;4f82	7c		|
	add a,a			;4f83	87		.
	jp c,l4f8bh		;4f84	da 8b 4f	. . O
	or l			;4f87	b5		.
	jp nz,l4ff7h		;4f88	c2 f7 4f	. . O
l4f8bh:
	ld hl,(l0f95h)		;4f8b	2a 95 0f	* . .
	ld a,h			;4f8e	7c		|
	cpl			;4f8f	2f		/
	ld h,a			;4f90	67		g
	ld a,l			;4f91	7d		}
	cpl			;4f92	2f		/
	ld l,a			;4f93	6f		o
	ld a,h			;4f94	7c		|
	or l			;4f95	b5		.
	jp nz,l4feeh		;4f96	c2 ee 4f	. . O
	ld hl,(l0fb6h)		;4f99	2a b6 0f	* . .
	call integer_mul_inline	;4f9c	cd 8e 76	. . v
	defw 00051h		;4f9f	51 00		Q .
	ex de,hl		;4fa1	eb		.
	ld hl,(l0fb4h)		;4fa2	2a b4 0f	* . .
	add hl,de		;4fa5	19		.
	add hl,hl		;4fa6	29		)
	ld de,l01ach		;4fa7	11 ac 01	. . .
	add hl,de		;4faa	19		.
	ld e,(hl)		;4fab	5e		^
	inc hl			;4fac	23		#
	ld d,(hl)		;4fad	56		V
	push de			;4fae	d5		.
	pop hl			;4faf	e1		.
	push hl			;4fb0	e5		.
	ld de,0fffeh		;4fb1	11 fe ff	. . .
	add hl,de		;4fb4	19		.
	ld a,h			;4fb5	7c		|
	or l			;4fb6	b5		.
	sub 001h		;4fb7	d6 01		. .
	sbc a,a			;4fb9	9f		.
	ld h,a			;4fba	67		g
	ld l,a			;4fbb	6f		o
	ld (00ff4h),hl		;4fbc	22 f4 0f	" . .
	pop hl			;4fbf	e1		.
	ld de,0ffffh		;4fc0	11 ff ff	. . .
	add hl,de		;4fc3	19		.
	ld a,h			;4fc4	7c		|
	or l			;4fc5	b5		.
	sub 001h		;4fc6	d6 01		. .
	sbc a,a			;4fc8	9f		.
	ld h,a			;4fc9	67		g
	ld l,a			;4fca	6f		o
	push hl			;4fcb	e5		.
	ld hl,(00ff4h)		;4fcc	2a f4 0f	* . .
	ex de,hl		;4fcf	eb		.
	pop hl			;4fd0	e1		.
	ld a,h			;4fd1	7c		|
	or d			;4fd2	b2		.
	ld h,a			;4fd3	67		g
	ld a,l			;4fd4	7d		}
	or e			;4fd5	b3		.
	ld l,a			;4fd6	6f		o
	ld a,h			;4fd7	7c		|
	or l			;4fd8	b5		.
	jp nz,l4fdfh		;4fd9	c2 df 4f	. . O
	jp l4feeh		;4fdc	c3 ee 4f	. . O
l4fdfh:
	ld hl,00006h		;4fdf	21 06 00	! . .
	ld (l0f95h+2),hl	;4fe2	22 97 0f	" . .
	ld hl,(l0ef4h)		;4fe5	2a f4 0e	* . .
	ld (l0f95h),hl		;4fe8	22 95 0f	" . .
	jp l4ff7h		;4feb	c3 f7 4f	. . O
l4feeh:
	ld hl,(l0ef4h)		;4fee	2a f4 0e	* . .
	ld (l0f91h+2),hl	;4ff1	22 93 0f	" . .
	ld (l0f95h),hl		;4ff4	22 95 0f	" . .
l4ff7h:
	ld de,l0f8bh		;4ff7	11 8b 0f	. . .
	ld hl,l0f89h		;4ffa	21 89 0f	! . .
	call sub_626bh		;4ffd	cd 6b 62	. k b
	call print_setup	;5000	cd ea 6f	. . o
	ld hl,(l0f8bh)		;5003	2a 8b 0f	* . .
	call integer_mul_inline	;5006	cd 8e 76	. . v
	defw 00051h		;5009	51 00		Q .
	ex de,hl		;500b	eb		.
	ld hl,(l0f89h)		;500c	2a 89 0f	* . .
	add hl,de		;500f	19		.
	add hl,hl		;5010	29		)
	ld de,l010ah		;5011	11 0a 01	. . .
	add hl,de		;5014	19		.
	ld e,(hl)		;5015	5e		^
	inc hl			;5016	23		#
	ld d,(hl)		;5017	56		V
	ex de,hl		;5018	eb		.
	inc hl			;5019	23		#
	ex de,hl		;501a	eb		.
	ld bc,l0f11h		;501b	01 11 0f	. . .
	ld hl,00001h		;501e	21 01 00	! . .
	call sub_747fh		;5021	cd 7f 74	. . t
	call print_string	;5024	cd 6e 6e	. n n
	ld de,l0fb6h		;5027	11 b6 0f	. . .
	ld hl,l0fb4h		;502a	21 b4 0f	! . .
	call sub_626bh		;502d	cd 6b 62	. k b
	call print_setup	;5030	cd ea 6f	. . o
	ld hl,(l0f9fh)		;5033	2a 9f 0f	* . .
	inc hl			;5036	23		#
	ex de,hl		;5037	eb		.
	ld bc,l0f14h		;5038	01 14 0f	. . .
	ld hl,00001h		;503b	21 01 00	! . .
	call sub_747fh		;503e	cd 7f 74	. . t
	call print_string	;5041	cd 6e 6e	. n n
	ld hl,(l0fb4h)		;5044	2a b4 0f	* . .
	ld (l0f89h),hl		;5047	22 89 0f	" . .
	ld hl,(l0fb6h)		;504a	2a b6 0f	* . .
	ld (l0f8bh),hl		;504d	22 8b 0f	" . .
	ld hl,(l0fb6h)		;5050	2a b6 0f	* . .
	call integer_mul_inline	;5053	cd 8e 76	. . v
	defw 00051h		;5056	51 00		Q .
	ex de,hl		;5058	eb		.
	ld hl,(l0fb4h)		;5059	2a b4 0f	* . .
	add hl,de		;505c	19		.
	add hl,hl		;505d	29		)
	ld de,l010ah		;505e	11 0a 01	. . .
	add hl,de		;5061	19		.
	ld e,(hl)		;5062	5e		^
	inc hl			;5063	23		#
	ld d,(hl)		;5064	56		V
	ex de,hl		;5065	eb		.
	ld (l0fc4h),hl		;5066	22 c4 0f	" . .
	ld hl,(l0fc4h)		;5069	2a c4 0f	* . .
	ld de,0fff6h		;506c	11 f6 ff	. . .
	add hl,de		;506f	19		.
	ld a,h			;5070	7c		|
	or l			;5071	b5		.
	jp nz,l509eh		;5072	c2 9e 50	. . P
	ld hl,(score_word)	;5075	2a 05 0f	* . .
	ex de,hl		;5078	eb		.
	ld hl,(bonus_word)	;5079	2a 77 0f	* w .
	add hl,de		;507c	19		.
	ld (score_word),hl	;507d	22 05 0f	" . .
	call sub_5706h		;5080	cd 06 57	. . W
	ld hl,(l0fb6h)		;5083	2a b6 0f	* . .
	call integer_mul_inline	;5086	cd 8e 76	. . v
	defw 00051h		;5089	51 00		Q .
	ex de,hl		;508b	eb		.
	ld hl,(l0fb4h)		;508c	2a b4 0f	* . .
	add hl,de		;508f	19		.
	add hl,hl		;5090	29		)
	ld de,l010ah		;5091	11 0a 01	. . .
	add hl,de		;5094	19		.
	ld de,00000h		;5095	11 00 00	. . .
	ld (hl),e		;5098	73		s
	inc hl			;5099	23		#
	ld (hl),d		;509a	72		r
	jp l5105h		;509b	c3 05 51	. . Q
l509eh:
	ld hl,(l0fc4h)		;509e	2a c4 0f	* . .
	ld de,0fffdh		;50a1	11 fd ff	. . .
	add hl,de		;50a4	19		.
	ld a,h			;50a5	7c		|
	or l			;50a6	b5		.
	jp z,l518ah		;50a7	ca 8a 51	. . Q
	ld hl,(l0fc4h)		;50aa	2a c4 0f	* . .
	ld de,0fff8h		;50ad	11 f8 ff	. . .
	add hl,de		;50b0	19		.
	ld a,h			;50b1	7c		|
	or l			;50b2	b5		.
	jp z,l5216h		;50b3	ca 16 52	. . R
	ld hl,(l0fc4h)		;50b6	2a c4 0f	* . .
	ld de,0fff7h		;50b9	11 f7 ff	. . .
	add hl,de		;50bc	19		.
	ld a,h			;50bd	7c		|
	or l			;50be	b5		.
	jp nz,l5105h		;50bf	c2 05 51	. . Q
	ld hl,00005h		;50c2	21 05 00	! . .
	call random_float	;50c5	cd 31 6c	. 1 l
	call sub_7412h		;50c8	cd 12 74	. . t
	ld b,c			;50cb	41		A
	ld h,c			;50cc	61		a
	ld hl,l9285h		;50cd	21 85 92	! . .
	call sub_71c8h		;50d0	cd c8 71	. . q
	call sub_7618h		;50d3	cd 18 76	. . v
	ld (l0fc6h),hl		;50d6	22 c6 0f	" . .
	ld hl,(l0fc6h)		;50d9	2a c6 0f	* . .
	inc hl			;50dc	23		#
	call sub_7524h		;50dd	cd 24 75	. $ u
	inc bc			;50e0	03		.
	dec b			;50e1	05		.
	ld d,c			;50e2	51		Q
	rst 20h			;50e3	e7		.
	ld d,b			;50e4	50		P
	ld sp,hl		;50e5	f9		.
	ld d,b			;50e6	50		P
	ld hl,(l0f9dh)		;50e7	2a 9d 0f	* . .
	add hl,hl		;50ea	29		)
	ld de,l0e5ch+2		;50eb	11 5e 0e	. ^ .
	add hl,de		;50ee	19		.
	ld e,(hl)		;50ef	5e		^
	inc hl			;50f0	23		#
	ld d,(hl)		;50f1	56		V
	ex de,hl		;50f2	eb		.
	ld (l0f9dh),hl		;50f3	22 9d 0f	" . .
	jp l5105h		;50f6	c3 05 51	. . Q
	ld hl,(l0ef6h)		;50f9	2a f6 0e	* . .
	ld (l0f91h+2),hl	;50fc	22 93 0f	" . .
	ld hl,00006h		;50ff	21 06 00	! . .
	ld (l0f95h+2),hl	;5102	22 97 0f	" . .
l5105h:
	ld hl,(l0f7dh)		;5105	2a 7d 0f	* } .
	ld (l0fc8h),hl		;5108	22 c8 0f	" . .
	ld hl,00001h		;510b	21 01 00	! . .
	jp l516fh		;510e	c3 6f 51	. o Q
l5111h:
	ld hl,(l0f1fh+2)	;5111	2a 21 0f	* ! .
	add hl,hl		;5114	29		)
	ld de,00e94h		;5115	11 94 0e	. . .
	add hl,de		;5118	19		.
	ld e,(hl)		;5119	5e		^
	inc hl			;511a	23		#
	ld d,(hl)		;511b	56		V
	push de			;511c	d5		.
	pop hl			;511d	e1		.
	ld de,00001h		;511e	11 01 00	. . .
	add hl,de		;5121	19		.
	ld a,h			;5122	7c		|
	or l			;5123	b5		.
	jp z,l516bh		;5124	ca 6b 51	. k Q
	ld hl,(l0f1fh+2)	;5127	2a 21 0f	* ! .
	add hl,hl		;512a	29		)
	push hl			;512b	e5		.
	ld de,l0e68h		;512c	11 68 0e	. h .
	add hl,de		;512f	19		.
	ld e,(hl)		;5130	5e		^
	inc hl			;5131	23		#
	ld d,(hl)		;5132	56		V
	ld hl,(l0f89h)		;5133	2a 89 0f	* . .
	ld a,l			;5136	7d		}
	xor e			;5137	ab		.
	ld l,a			;5138	6f		o
	ld a,h			;5139	7c		|
	xor d			;513a	aa		.
	or l			;513b	b5		.
	sub 001h		;513c	d6 01		. .
	sbc a,a			;513e	9f		.
	ld h,a			;513f	67		g
	ld l,a			;5140	6f		o
	ld (00ff4h),hl		;5141	22 f4 0f	" . .
	pop hl			;5144	e1		.
	ld de,l0e7eh		;5145	11 7e 0e	. ~ .
	add hl,de		;5148	19		.
	ld e,(hl)		;5149	5e		^
	inc hl			;514a	23		#
	ld d,(hl)		;514b	56		V
	ld hl,(l0f8bh)		;514c	2a 8b 0f	* . .
	ld a,l			;514f	7d		}
	xor e			;5150	ab		.
	ld l,a			;5151	6f		o
	ld a,h			;5152	7c		|
	xor d			;5153	aa		.
	or l			;5154	b5		.
	sub 001h		;5155	d6 01		. .
	sbc a,a			;5157	9f		.
	ld h,a			;5158	67		g
	ld l,a			;5159	6f		o
	push hl			;515a	e5		.
	ld hl,(00ff4h)		;515b	2a f4 0f	* . .
	ex de,hl		;515e	eb		.
	pop hl			;515f	e1		.
	ld a,h			;5160	7c		|
	and d			;5161	a2		.
	ld h,a			;5162	67		g
	ld a,l			;5163	7d		}
	and e			;5164	a3		.
	ld l,a			;5165	6f		o
	ld a,h			;5166	7c		|
	or l			;5167	b5		.
	jp nz,l5216h		;5168	c2 16 52	. . R
l516bh:
	ld hl,(l0f1fh+2)	;516b	2a 21 0f	* ! .
	inc hl			;516e	23		#
l516fh:
	ld (l0f1fh+2),hl	;516f	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;5172	2a 21 0f	* ! .
	ex de,hl		;5175	eb		.
	ld hl,(l0fc8h)		;5176	2a c8 0f	* . .
	ld a,d			;5179	7a		z
	xor h			;517a	ac		.
	ld a,h			;517b	7c		|
	jp m,l5183h		;517c	fa 83 51	. . Q
	ld a,l			;517f	7d		}
	sub e			;5180	93		.
	ld a,h			;5181	7c		|
	sbc a,d			;5182	9a		.
l5183h:
	rla			;5183	17		.
	jp nc,l5111h		;5184	d2 11 51	. . Q
	jp l4718h		;5187	c3 18 47	. . G
l518ah:
	call print_setup	;518a	cd ea 6f	. . o
	ld hl,l0f49h		;518d	21 49 0f	! I .
	call print_string	;5190	cd 6e 6e	. n n
	ld hl,(bonus_word)	;5193	2a 77 0f	* w .
	ld a,h			;5196	7c		|
	add a,a			;5197	87		.
	jp c,l520ch		;5198	da 0c 52	. . R
	or l			;519b	b5		.
	jp z,l520ch		;519c	ca 0c 52	. . R
	ld hl,(bonus_word)	;519f	2a 77 0f	* w .
	ld (l0fcah),hl		;51a2	22 ca 0f	" . .
	ld hl,00001h		;51a5	21 01 00	! . .
	jp l51f4h		;51a8	c3 f4 51	. . Q
l51abh:
	ld hl,(bonus_word)	;51ab	2a 77 0f	* w .
	dec hl			;51ae	2b		+
	ld (bonus_word),hl	;51af	22 77 0f	" w .
	ld hl,(score_word)	;51b2	2a 05 0f	* . .
	inc hl			;51b5	23		#
	ld (score_word),hl	;51b6	22 05 0f	" . .
	call sub_5706h		;51b9	cd 06 57	. . W
	call sub_5769h		;51bc	cd 69 57	. i W
	ld hl,00001h		;51bf	21 01 00	! . .
	ld (l0fa1h+2),hl	;51c2	22 a3 0f	" . .
	ld de,00effh		;51c5	11 ff 0e	. . .
	ld hl,l0fa1h+2		;51c8	21 a3 0f	! . .
	call sub_626bh		;51cb	cd 6b 62	. k b
	ld hl,(l0f1fh+2)	;51ce	2a 21 0f	* ! .
	ld a,l			;51d1	7d		}
	and 001h		;51d2	e6 01		. .
	ld l,a			;51d4	6f		o
	ld a,h			;51d5	7c		|
	and 000h		;51d6	e6 00		. .
	ld h,a			;51d8	67		g
	ld a,h			;51d9	7c		|
	or l			;51da	b5		.
	jp nz,l51e4h		;51db	c2 e4 51	. . Q
	call sub_57a8h		;51de	cd a8 57	. . W
	jp l51f0h		;51e1	c3 f0 51	. . Q
l51e4h:
	ld de,l0f61h		;51e4	11 61 0f	. a .
	ld hl,s_hooka		;51e7	21 65 5a	! e Z
	call string_assign	;51ea	cd db 74	. . t
	call sub_57ech		;51ed	cd ec 57	. . W
l51f0h:
	ld hl,(l0f1fh+2)	;51f0	2a 21 0f	* ! .
	inc hl			;51f3	23		#
l51f4h:
	ld (l0f1fh+2),hl	;51f4	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;51f7	2a 21 0f	* ! .
	ex de,hl		;51fa	eb		.
	ld hl,(l0fcah)		;51fb	2a ca 0f	* . .
	ld a,d			;51fe	7a		z
	xor h			;51ff	ac		.
	ld a,h			;5200	7c		|
	jp m,l5208h		;5201	fa 08 52	. . R
	ld a,l			;5204	7d		}
	sub e			;5205	93		.
	ld a,h			;5206	7c		|
	sbc a,d			;5207	9a		.
l5208h:
	rla			;5208	17		.
	jp nc,l51abh		;5209	d2 ab 51	. . Q
l520ch:
	ld hl,(level_word)	;520c	2a 69 0f	* i .
	inc hl			;520f	23		#
	ld (level_word),hl	;5210	22 69 0f	" i .
	jp l43a8h		;5213	c3 a8 43	. . C
l5216h:
	call print_setup	;5216	cd ea 6f	. . o
	ld hl,l0f49h		;5219	21 49 0f	! I .
	call print_string	;521c	cd 6e 6e	. n n
	ld hl,l0f17h		;521f	21 17 0f	! . .
	call sub_71d5h		;5222	cd d5 71	. . q
	ld (l0fcch),hl		;5225	22 cc 0f	" . .
	ld hl,00001h		;5228	21 01 00	! . .
	jp l5251h		;522b	c3 51 52	. Q R
l522eh:
	ld de,l0f8bh		;522e	11 8b 0f	. . .
	ld hl,l0f89h		;5231	21 89 0f	! . .
	call sub_626bh		;5234	cd 6b 62	. k b
	call print_setup	;5237	cd ea 6f	. . o
	ld bc,l0f17h		;523a	01 17 0f	. . .
	ld hl,(l0f1fh+2)	;523d	2a 21 0f	* ! .
	ex de,hl		;5240	eb		.
	ld hl,00001h		;5241	21 01 00	! . .
	call sub_747fh		;5244	cd 7f 74	. . t
	call print_string	;5247	cd 6e 6e	. n n
	call sub_57a8h		;524a	cd a8 57	. . W
	ld hl,(l0f1fh+2)	;524d	2a 21 0f	* ! .
	inc hl			;5250	23		#
l5251h:
	ld (l0f1fh+2),hl	;5251	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;5254	2a 21 0f	* ! .
	ex de,hl		;5257	eb		.
	ld hl,(l0fcch)		;5258	2a cc 0f	* . .
	ld a,d			;525b	7a		z
	xor h			;525c	ac		.
	ld a,h			;525d	7c		|
	jp m,l5265h		;525e	fa 65 52	. e R
	ld a,l			;5261	7d		}
	sub e			;5262	93		.
	ld a,h			;5263	7c		|
	sbc a,d			;5264	9a		.
l5265h:
	rla			;5265	17		.
	jp nc,l522eh		;5266	d2 2e 52	. . R
	ld de,l0f8bh		;5269	11 8b 0f	. . .
	ld hl,l0f89h		;526c	21 89 0f	! . .
	call sub_626bh		;526f	cd 6b 62	. k b
	call print_setup	;5272	cd ea 6f	. . o
	ld hl,l0f49h		;5275	21 49 0f	! I .
	call print_string	;5278	cd 6e 6e	. n n
	ld hl,(l0f8bh)		;527b	2a 8b 0f	* . .
	call integer_mul_inline	;527e	cd 8e 76	. . v
	defw 00051h		;5281	51 00		Q .
	ex de,hl		;5283	eb		.
	ld hl,(l0f89h)		;5284	2a 89 0f	* . .
	add hl,de		;5287	19		.
	add hl,hl		;5288	29		)
	ld de,l010ah		;5289	11 0a 01	. . .
	add hl,de		;528c	19		.
	ld e,(hl)		;528d	5e		^
	inc hl			;528e	23		#
	ld d,(hl)		;528f	56		V
	ex de,hl		;5290	eb		.
	inc hl			;5291	23		#
	ex de,hl		;5292	eb		.
	ld bc,l0f11h		;5293	01 11 0f	. . .
	ld hl,00001h		;5296	21 01 00	! . .
	call sub_747fh		;5299	cd 7f 74	. . t
	call print_string	;529c	cd 6e 6e	. n n
	ld hl,(l0f7dh)		;529f	2a 7d 0f	* } .
	ld (l0fceh),hl		;52a2	22 ce 0f	" . .
	ld hl,00001h		;52a5	21 01 00	! . .
	jp l531ah		;52a8	c3 1a 53	. . S
l52abh:
	ld hl,(l0f1fh+2)	;52ab	2a 21 0f	* ! .
	add hl,hl		;52ae	29		)
	ld de,00e94h		;52af	11 94 0e	. . .
	add hl,de		;52b2	19		.
	ld e,(hl)		;52b3	5e		^
	inc hl			;52b4	23		#
	ld d,(hl)		;52b5	56		V
	push de			;52b6	d5		.
	pop hl			;52b7	e1		.
	ld de,00001h		;52b8	11 01 00	. . .
	add hl,de		;52bb	19		.
	ld a,h			;52bc	7c		|
	or l			;52bd	b5		.
	jp z,l5316h		;52be	ca 16 53	. . S
	ld hl,(l0f1fh+2)	;52c1	2a 21 0f	* ! .
	add hl,hl		;52c4	29		)
	push hl			;52c5	e5		.
	ld de,l0e7eh		;52c6	11 7e 0e	. ~ .
	add hl,de		;52c9	19		.
	ld (00ff4h),hl		;52ca	22 f4 0f	" . .
	pop hl			;52cd	e1		.
	ld de,l0e68h		;52ce	11 68 0e	. h .
	add hl,de		;52d1	19		.
	push hl			;52d2	e5		.
	ld hl,(00ff4h)		;52d3	2a f4 0f	* . .
	ex de,hl		;52d6	eb		.
	pop hl			;52d7	e1		.
	call sub_626bh		;52d8	cd 6b 62	. k b
	call print_setup	;52db	cd ea 6f	. . o
	ld hl,(l0f1fh+2)	;52de	2a 21 0f	* ! .
	add hl,hl		;52e1	29		)
	push hl			;52e2	e5		.
	ld de,l0e7eh		;52e3	11 7e 0e	. ~ .
	add hl,de		;52e6	19		.
	ld e,(hl)		;52e7	5e		^
	inc hl			;52e8	23		#
	ld d,(hl)		;52e9	56		V
	ex de,hl		;52ea	eb		.
	call integer_mul_inline	;52eb	cd 8e 76	. . v
	defw 00051h		;52ee	51 00		Q .
	ld (00ff4h),hl		;52f0	22 f4 0f	" . .
	pop hl			;52f3	e1		.
	ld de,l0e68h		;52f4	11 68 0e	. h .
	add hl,de		;52f7	19		.
	ld e,(hl)		;52f8	5e		^
	inc hl			;52f9	23		#
	ld d,(hl)		;52fa	56		V
	ld hl,(00ff4h)		;52fb	2a f4 0f	* . .
	add hl,de		;52fe	19		.
	add hl,hl		;52ff	29		)
	ld de,l010ah		;5300	11 0a 01	. . .
	add hl,de		;5303	19		.
	ld e,(hl)		;5304	5e		^
	inc hl			;5305	23		#
	ld d,(hl)		;5306	56		V
	ex de,hl		;5307	eb		.
	inc hl			;5308	23		#
	ex de,hl		;5309	eb		.
	ld bc,l0f11h		;530a	01 11 0f	. . .
	ld hl,00001h		;530d	21 01 00	! . .
	call sub_747fh		;5310	cd 7f 74	. . t
	call print_string	;5313	cd 6e 6e	. n n
l5316h:
	ld hl,(l0f1fh+2)	;5316	2a 21 0f	* ! .
	inc hl			;5319	23		#
l531ah:
	ld (l0f1fh+2),hl	;531a	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;531d	2a 21 0f	* ! .
	ex de,hl		;5320	eb		.
	ld hl,(l0fceh)		;5321	2a ce 0f	* . .
	ld a,d			;5324	7a		z
	xor h			;5325	ac		.
	ld a,h			;5326	7c		|
	jp m,l532eh		;5327	fa 2e 53	. . S
	ld a,l			;532a	7d		}
	sub e			;532b	93		.
	ld a,h			;532c	7c		|
	sbc a,d			;532d	9a		.
l532eh:
	rla			;532e	17		.
	jp nc,l52abh		;532f	d2 ab 52	. . R
	ld hl,(lads_word)	;5332	2a 67 0f	* g .
	dec hl			;5335	2b		+
	ld (lads_word),hl	;5336	22 67 0f	" g .
	ld hl,(lads_word)	;5339	2a 67 0f	* g .
	ld a,h			;533c	7c		|
	add a,a			;533d	87		.
	jp c,l5345h		;533e	da 45 53	. E S
	or l			;5341	b5		.
	jp nz,l4631h		;5342	c2 31 46	. 1 F
l5345h:
	ld hl,(l0ef4h)		;5345	2a f4 0e	* . .
	ld (l0fa9h),hl		;5348	22 a9 0f	" . .
	ld hl,00001h		;534b	21 01 00	! . .
	jp l5557h		;534e	c3 57 55	. W U
l5351h:
	ld hl,(00f83h)		;5351	2a 83 0f	* . .
	add hl,hl		;5354	29		)
	ld de,l0ee8h		;5355	11 e8 0e	. . .
	add hl,de		;5358	19		.
	ld e,(hl)		;5359	5e		^
	inc hl			;535a	23		#
	ld d,(hl)		;535b	56		V
	ld hl,(score_word)	;535c	2a 05 0f	* . .
	ld a,d			;535f	7a		z
	xor h			;5360	ac		.
	ld a,h			;5361	7c		|
	jp m,l5369h		;5362	fa 69 53	. i S
	ld a,l			;5365	7d		}
	sub e			;5366	93		.
	ld a,h			;5367	7c		|
	sbc a,d			;5368	9a		.
l5369h:
	rla			;5369	17		.
	jp c,l5553h		;536a	da 53 55	. S U
	ld hl,(l0f4ch+2)	;536d	2a 4e 0f	* N .
	ld a,h			;5370	7c		|
	cpl			;5371	2f		/
	ld h,a			;5372	67		g
	ld a,l			;5373	7d		}
	cpl			;5374	2f		/
	ld l,a			;5375	6f		o
	ld a,h			;5376	7c		|
	or l			;5377	b5		.
	jp nz,l538ah		;5378	c2 8a 53	. . S
	ld de,l0f61h		;537b	11 61 0f	. a .
	ld hl,s_high_score_cheated	;537e	21 43 5a	! C Z
	call string_assign	;5381	cd db 74	. . t
	call sub_57e3h		;5384	cd e3 57	. . W
	jp l556ah		;5387	c3 6a 55	. j U
l538ah:
	ld hl,(l0ef6h)		;538a	2a f6 0e	* . .
	ld (l0fa9h),hl		;538d	22 a9 0f	" . .
	call print_setup	;5390	cd ea 6f	. . o
	ld hl,l0f37h		;5393	21 37 0f	! 7 .
	call print_string_line	;5396	cd 92 6e	. . n
	call print_setup	;5399	cd ea 6f	. . o
	ld hl,l613eh		;539c	21 3e 61	! > a
	call print_string_line	;539f	cd 92 6e	. . n
	call print_setup	;53a2	cd ea 6f	. . o
	ld hl,l613eh		;53a5	21 3e 61	! > a
	call print_string_line	;53a8	cd 92 6e	. . n
	call print_setup	;53ab	cd ea 6f	. . o
	ld hl,l613eh		;53ae	21 3e 61	! > a
	call print_string_line	;53b1	cd 92 6e	. . n
	call print_setup	;53b4	cd ea 6f	. . o
	ld hl,l613eh		;53b7	21 3e 61	! > a
	call print_string_line	;53ba	cd 92 6e	. . n
	call print_setup	;53bd	cd ea 6f	. . o
	ld hl,l613eh		;53c0	21 3e 61	! > a
	call print_string_line	;53c3	cd 92 6e	. . n
	call print_setup	;53c6	cd ea 6f	. . o
	ld hl,s_high_score_yahoo	;53c9	21 06 5a	! . Z
	call print_string_line	;53cc	cd 92 6e	. . n
	call print_setup	;53cf	cd ea 6f	. . o
	ld hl,l613eh		;53d2	21 3e 61	! > a
	call print_string_line	;53d5	cd 92 6e	. . n
	ld hl,(score_word)	;53d8	2a 05 0f	* . .
	ld de,0d8efh		;53db	11 ef d8	. . .
	ld a,h			;53de	7c		|
	rla			;53df	17		.
	jp c,l53e5h		;53e0	da e5 53	. . S
	add hl,de		;53e3	19		.
	add hl,hl		;53e4	29		)
l53e5h:
	jp c,l53f4h		;53e5	da f4 53	. . S
	call print_setup	;53e8	cd ea 6f	. . o
	ld hl,s_high_score_lad_master	;53eb	21 e7 59	! . Y
	call print_string_line	;53ee	cd 92 6e	. . n
	jp l5489h		;53f1	c3 89 54	. . T
l53f4h:
	ld hl,(score_word)	;53f4	2a 05 0f	* . .
	ld de,0ec77h		;53f7	11 77 ec	. w .
	ld a,h			;53fa	7c		|
	rla			;53fb	17		.
	jp c,l5401h		;53fc	da 01 54	. . T
	add hl,de		;53ff	19		.
	add hl,hl		;5400	29		)
l5401h:
	jp c,l5410h		;5401	da 10 54	. . T
	call print_setup	;5404	cd ea 6f	. . o
	ld hl,s_high_score_lad_guru	;5407	21 c8 59	! . Y
	call print_string_line	;540a	cd 92 6e	. . n
l540dh:
	jp l5489h		;540d	c3 89 54	. . T
l5410h:
	ld hl,(score_word)	;5410	2a 05 0f	* . .
	ld de,0f63bh		;5413	11 3b f6	. ; .
	ld a,h			;5416	7c		|
	rla			;5417	17		.
	jp c,l541dh		;5418	da 1d 54	. . T
	add hl,de		;541b	19		.
	add hl,hl		;541c	29		)
l541dh:
	jp c,l542ch		;541d	da 2c 54	. , T
	call print_setup	;5420	cd ea 6f	. . o
	ld hl,s_high_score_lad_wiz	;5423	21 aa 59	! . Y
	call print_string_line	;5426	cd 92 6e	. . n
	jp l5489h		;5429	c3 89 54	. . T
l542ch:
	ld hl,(score_word)	;542c	2a 05 0f	* . .
	ld de,0fc17h		;542f	11 17 fc	. . .
	ld a,h			;5432	7c		|
	rla			;5433	17		.
	jp c,l5439h		;5434	da 39 54	. 9 T
	add hl,de		;5437	19		.
	add hl,hl		;5438	29		)
l5439h:
	jp c,l5448h		;5439	da 48 54	. H T
	call print_setup	;543c	cd ea 6f	. . o
	ld hl,s_high_score_ladder	;543f	21 86 59	! . Y
	call print_string_line	;5442	cd 92 6e	. . n
	jp l5489h		;5445	c3 89 54	. . T
l5448h:
	ld hl,(score_word)	;5448	2a 05 0f	* . .
	ld de,0fe0bh		;544b	11 0b fe	. . .
	ld a,h			;544e	7c		|
	rla			;544f	17		.
	jp c,l5455h		;5450	da 55 54	. U T
	add hl,de		;5453	19		.
	add hl,hl		;5454	29		)
l5455h:
	jp c,l5464h		;5455	da 64 54	. d T
	call print_setup	;5458	cd ea 6f	. . o
	ld hl,s_high_score_amazing	;545b	21 70 59	! p Y
	call print_string_line	;545e	cd 92 6e	. . n
	jp l5489h		;5461	c3 89 54	. . T
l5464h:
	ld hl,(score_word)	;5464	2a 05 0f	* . .
	ld de,0ff05h		;5467	11 05 ff	. . .
	ld a,h			;546a	7c		|
	rla			;546b	17		.
	jp c,l5471h		;546c	da 71 54	. q T
	add hl,de		;546f	19		.
	add hl,hl		;5470	29		)
l5471h:
	jp c,l5480h		;5471	da 80 54	. . T
	call print_setup	;5474	cd ea 6f	. . o
	ld hl,s_high_score_not_bad	;5477	21 56 59	! V Y
	call print_string_line	;547a	cd 92 6e	. . n
	jp l5489h		;547d	c3 89 54	. . T
l5480h:
	call print_setup	;5480	cd ea 6f	. . o
	ld hl,s_high_score_undeserved	;5483	21 2f 59	! / Y
	call print_string_line	;5486	cd 92 6e	. . n
l5489h:
	call print_setup	;5489	cd ea 6f	. . o
	ld hl,l613eh		;548c	21 3e 61	! > a
	call print_string_line	;548f	cd 92 6e	. . n
	call print_setup	;5492	cd ea 6f	. . o
	ld hl,s_enter_your_name	;5495	21 1b 59	! . Y
	call print_string	;5498	cd 6e 6e	. n n
	call sub_57d1h		;549b	cd d1 57	. . W
	ld hl,l613eh		;549e	21 3e 61	! > a
	call sub_6c8bh		;54a1	cd 8b 6c	. . l
	ld (bc),a		;54a4	02		.
	ld hl,00f64h		;54a5	21 64 0f	! d .
	call sub_6caeh		;54a8	cd ae 6c	. . l
	ld hl,00f64h		;54ab	21 64 0f	! d .
	call sub_71d5h		;54ae	cd d5 71	. . q
	ld a,h			;54b1	7c		|
	or l			;54b2	b5		.
	jp nz,l54bfh		;54b3	c2 bf 54	. . T
	ld hl,(l0ef4h)		;54b6	2a f4 0e	* . .
	ld (l0fa9h),hl		;54b9	22 a9 0f	" . .
	jp l556ah		;54bc	c3 6a 55	. j U
l54bfh:
	ld hl,(00f83h)		;54bf	2a 83 0f	* . .
	ld de,0fffbh		;54c2	11 fb ff	. . .
	add hl,de		;54c5	19		.
	ld a,h			;54c6	7c		|
	or l			;54c7	b5		.
	jp z,l552dh		;54c8	ca 2d 55	. - U
	ld hl,(00f83h)		;54cb	2a 83 0f	* . .
	ld (l0fd0h),hl		;54ce	22 d0 0f	" . .
	ld hl,00004h		;54d1	21 04 00	! . .
	jp l5515h		;54d4	c3 15 55	. . U
l54d7h:
	ld hl,(00fd2h)		;54d7	2a d2 0f	* . .
	add hl,hl		;54da	29		)
	push hl			;54db	e5		.
	ld de,l0ee8h		;54dc	11 e8 0e	. . .
	add hl,de		;54df	19		.
	ld e,(hl)		;54e0	5e		^
	inc hl			;54e1	23		#
	ld d,(hl)		;54e2	56		V
	ex de,hl		;54e3	eb		.
	ld (00ff4h),hl		;54e4	22 f4 0f	" . .
	pop hl			;54e7	e1		.
	ld de,l0eeah		;54e8	11 ea 0e	. . .
	add hl,de		;54eb	19		.
	push hl			;54ec	e5		.
	ld hl,(00ff4h)		;54ed	2a f4 0f	* . .
	ex de,hl		;54f0	eb		.
	pop hl			;54f1	e1		.
	ld (hl),e		;54f2	73		s
	inc hl			;54f3	23		#
	ld (hl),d		;54f4	72		r
	ld hl,(00fd2h)		;54f5	2a d2 0f	* . .
	call integer_mul_inline	;54f8	cd 8e 76	. . v
	defw 00003h		;54fb	03 00		. .
	push hl			;54fd	e5		.
	ld de,00ed9h		;54fe	11 d9 0e	. . .
	add hl,de		;5501	19		.
	ld (00ff4h),hl		;5502	22 f4 0f	" . .
	pop hl			;5505	e1		.
	ld de,00ed6h		;5506	11 d6 0e	. . .
	add hl,de		;5509	19		.
	ex de,hl		;550a	eb		.
	ld hl,(00ff4h)		;550b	2a f4 0f	* . .
	call sub_750eh		;550e	cd 0e 75	. . u
	ld hl,(00fd2h)		;5511	2a d2 0f	* . .
	dec hl			;5514	2b		+
l5515h:
	ld (00fd2h),hl		;5515	22 d2 0f	" . .
	ld hl,(00fd2h)		;5518	2a d2 0f	* . .
	ex de,hl		;551b	eb		.
	ld hl,(l0fd0h)		;551c	2a d0 0f	* . .
	ld a,d			;551f	7a		z
	xor h			;5520	ac		.
	ld a,d			;5521	7a		z
	jp m,l5529h		;5522	fa 29 55	. ) U
	ld a,e			;5525	7b		{
	sub l			;5526	95		.
	ld a,d			;5527	7a		z
	sbc a,h			;5528	9c		.
l5529h:
	rla			;5529	17		.
	jp nc,l54d7h		;552a	d2 d7 54	. . T
l552dh:
	ld hl,(00f83h)		;552d	2a 83 0f	* . .
	add hl,hl		;5530	29		)
	ld de,l0ee8h		;5531	11 e8 0e	. . .
	add hl,de		;5534	19		.
	push hl			;5535	e5		.
	ld hl,(score_word)	;5536	2a 05 0f	* . .
	ex de,hl		;5539	eb		.
	pop hl			;553a	e1		.
	ld (hl),e		;553b	73		s
	inc hl			;553c	23		#
	ld (hl),d		;553d	72		r
	ld hl,(00f83h)		;553e	2a 83 0f	* . .
	call integer_mul_inline	;5541	cd 8e 76	. . v
	defw 00003h		;5544	03 00		. .
	ld de,00ed6h		;5546	11 d6 0e	. . .
	add hl,de		;5549	19		.
	ld de,00f64h		;554a	11 64 0f	. d .
	call sub_750eh		;554d	cd 0e 75	. . u
	jp l556ah		;5550	c3 6a 55	. j U
l5553h:
	ld hl,(00f83h)		;5553	2a 83 0f	* . .
	inc hl			;5556	23		#
l5557h:
	ld (00f83h),hl		;5557	22 83 0f	" . .
	ld hl,(00f83h)		;555a	2a 83 0f	* . .
	ld de,0fffah		;555d	11 fa ff	. . .
	ld a,h			;5560	7c		|
	rla			;5561	17		.
	jp c,l5567h		;5562	da 67 55	. g U
	add hl,de		;5565	19		.
	add hl,hl		;5566	29		)
l5567h:
	jp c,l5351h		;5567	da 51 53	. Q S
l556ah:
	ld hl,(l0fa9h)		;556a	2a a9 0f	* . .
	ld a,h			;556d	7c		|
	cpl			;556e	2f		/
	ld h,a			;556f	67		g
	ld a,l			;5570	7d		}
	cpl			;5571	2f		/
	ld l,a			;5572	6f		o
	ld a,h			;5573	7c		|
	or l			;5574	b5		.
	jp nz,l3eafh		;5575	c2 af 3e	. . >
	call print_setup	;5578	cd ea 6f	. . o
	ld hl,l613eh		;557b	21 3e 61	! > a
	call print_string_line	;557e	cd 92 6e	. . n
	call print_setup	;5581	cd ea 6f	. . o
	ld hl,l613eh		;5584	21 3e 61	! > a
	call print_string_line	;5587	cd 92 6e	. . n
	call print_setup	;558a	cd ea 6f	. . o
	ld hl,l613eh		;558d	21 3e 61	! > a
	call print_string_line	;5590	cd 92 6e	. . n
	call print_setup	;5593	cd ea 6f	. . o
	ld hl,l613eh		;5596	21 3e 61	! > a
	call print_string_line	;5599	cd 92 6e	. . n
	call print_setup	;559c	cd ea 6f	. . o
	ld hl,l613eh		;559f	21 3e 61	! > a
	call print_string_line	;55a2	cd 92 6e	. . n
	call print_setup	;55a5	cd ea 6f	. . o
	ld hl,s_updating_high_scores	;55a8	21 01 59	! . Y
	call print_string_line	;55ab	cd 92 6e	. . n
	ld hl,s_key_r_upper	;55ae	21 f8 60	! . `
	call sub_8ab4h		;55b1	cd b4 8a	. . .
	ld bc,00001h		;55b4	01 01 00	. . .
	ld de,s_data_filename	;55b7	11 eb 60	. . `
	ld hl,00020h		;55ba	21 20 00	!   .
	call sub_8adch		;55bd	cd dc 8a	. . .
	ld hl,00001h		;55c0	21 01 00	! . .
	call l6dd5h+2		;55c3	cd d7 6d	. . m
	ld de,l0f23h		;55c6	11 23 0f	. # .
	ld hl,00020h		;55c9	21 20 00	!   .
	call sub_6dffh		;55cc	cd ff 6d	. . m
	ld hl,00001h		;55cf	21 01 00	! . .
	jp l562dh		;55d2	c3 2d 56	. - V
l55d5h:
	ld hl,(l0f1fh+2)	;55d5	2a 21 0f	* ! .
	call integer_mul_inline	;55d8	cd 8e 76	. . v
	defw 00003h		;55db	03 00		. .
	push hl			;55dd	e5		.
	ld de,00ed6h		;55de	11 d6 0e	. . .
	add hl,de		;55e1	19		.
	call sub_71d5h		;55e2	cd d5 71	. . q
	call character_string	;55e5	cd b5 75	. . u
	push hl			;55e8	e5		.
	ld hl,(l0f1fh+2)	;55e9	2a 21 0f	* ! .
	add hl,hl		;55ec	29		)
	ld de,l0ee8h		;55ed	11 e8 0e	. . .
	add hl,de		;55f0	19		.
	ld e,(hl)		;55f1	5e		^
	inc hl			;55f2	23		#
	ld d,(hl)		;55f3	56		V
	ex de,hl		;55f4	eb		.
	call 071f8h		;55f5	cd f8 71	. . q
	pop de			;55f8	d1		.
	call sub_706eh		;55f9	cd 6e 70	. n p
	ld (00ff4h),hl		;55fc	22 f4 0f	" . .
	pop hl			;55ff	e1		.
	ld de,00ed6h		;5600	11 d6 0e	. . .
	add hl,de		;5603	19		.
	push hl			;5604	e5		.
	ld hl,(00ff4h)		;5605	2a f4 0f	* . .
	ex de,hl		;5608	eb		.
	pop hl			;5609	e1		.
	call sub_706eh		;560a	cd 6e 70	. n p
	ld de,00f64h		;560d	11 64 0f	. d .
	call string_assign	;5610	cd db 74	. . t
	ld de,l0f23h		;5613	11 23 0f	. # .
	ld hl,00f64h		;5616	21 64 0f	! d .
	call sub_70c1h		;5619	cd c1 70	. . p
	ld de,00008h		;561c	11 08 00	. . .
	ld hl,(l0f1fh+2)	;561f	2a 21 0f	* ! .
	add hl,de		;5622	19		.
	ld de,00001h		;5623	11 01 00	. . .
	call sub_8b11h		;5626	cd 11 8b	. . .
	ld hl,(l0f1fh+2)	;5629	2a 21 0f	* ! .
	inc hl			;562c	23		#
l562dh:
	ld (l0f1fh+2),hl	;562d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;5630	2a 21 0f	* ! .
	ld de,0fffah		;5633	11 fa ff	. . .
	ld a,h			;5636	7c		|
	rla			;5637	17		.
	jp c,l563dh		;5638	da 3d 56	. = V
	add hl,de		;563b	19		.
	add hl,hl		;563c	29		)
l563dh:
	jp c,l55d5h		;563d	da d5 55	. . U
	ld hl,00001h		;5640	21 01 00	! . .
	call sub_85f4h		;5643	cd f4 85	. . .
	ld hl,s_key_r_upper	;5646	21 f8 60	! . `
	call sub_8ab4h		;5649	cd b4 8a	. . .
	ld bc,00001h		;564c	01 01 00	. . .
	ld de,s_data_filename	;564f	11 eb 60	. . `
	ld hl,00020h		;5652	21 20 00	!   .
	call sub_8adch		;5655	cd dc 8a	. . .
	ld hl,00001h		;5658	21 01 00	! . .
	call l6dd5h+2		;565b	cd d7 6d	. . m
	ld de,l0f23h		;565e	11 23 0f	. # .
	ld hl,00020h		;5661	21 20 00	!   .
	call sub_6dffh		;5664	cd ff 6d	. . m
	ld hl,00001h		;5667	21 01 00	! . .
	call sub_85f4h		;566a	cd f4 85	. . .
	jp l3eafh		;566d	c3 af 3e	. . >
sub_5670h:
	ld hl,(l0f7dh)		;5670	2a 7d 0f	* } .
	ld (l0fd4h),hl		;5673	22 d4 0f	" . .
	ld hl,00001h		;5676	21 01 00	! . .
	jp l56bch		;5679	c3 bc 56	. . V
l567ch:
	ld hl,(00f87h)		;567c	2a 87 0f	* . .
	add hl,hl		;567f	29		)
	ld de,l0e68h		;5680	11 68 0e	. h .
	add hl,de		;5683	19		.
	ld e,(hl)		;5684	5e		^
	inc hl			;5685	23		#
	ld d,(hl)		;5686	56		V
	ld hl,(l0fb4h)		;5687	2a b4 0f	* . .
	ld a,l			;568a	7d		}
	xor e			;568b	ab		.
	ld l,a			;568c	6f		o
	ld a,h			;568d	7c		|
	xor d			;568e	aa		.
	or l			;568f	b5		.
	jp nz,l56b8h		;5690	c2 b8 56	. . V
	ld hl,(00f87h)		;5693	2a 87 0f	* . .
	add hl,hl		;5696	29		)
	ld de,l0e7eh		;5697	11 7e 0e	. ~ .
	add hl,de		;569a	19		.
	ld e,(hl)		;569b	5e		^
	inc hl			;569c	23		#
	ld d,(hl)		;569d	56		V
	ld hl,(l0fbch+2)	;569e	2a be 0f	* . .
	ld a,l			;56a1	7d		}
	xor e			;56a2	ab		.
	ld l,a			;56a3	6f		o
	ld a,h			;56a4	7c		|
	xor d			;56a5	aa		.
	or l			;56a6	b5		.
	jp nz,l56b8h		;56a7	c2 b8 56	. . V
	ld hl,(score_word)	;56aa	2a 05 0f	* . .
	inc hl			;56ad	23		#
	inc hl			;56ae	23		#
	ld (score_word),hl	;56af	22 05 0f	" . .
	ld hl,(l0ef6h)		;56b2	2a f6 0e	* . .
	ld (l0fa9h),hl		;56b5	22 a9 0f	" . .
l56b8h:
	ld hl,(00f87h)		;56b8	2a 87 0f	* . .
	inc hl			;56bb	23		#
l56bch:
	ld (00f87h),hl		;56bc	22 87 0f	" . .
	ld hl,(00f87h)		;56bf	2a 87 0f	* . .
	ex de,hl		;56c2	eb		.
	ld hl,(l0fd4h)		;56c3	2a d4 0f	* . .
	ld a,d			;56c6	7a		z
	xor h			;56c7	ac		.
	ld a,h			;56c8	7c		|
	jp m,l56d0h		;56c9	fa d0 56	. . V
	ld a,l			;56cc	7d		}
	sub e			;56cd	93		.
	ld a,h			;56ce	7c		|
	sbc a,d			;56cf	9a		.
l56d0h:
	rla			;56d0	17		.
	jp nc,l567ch		;56d1	d2 7c 56	. | V
	ret			;56d4	c9		.
sub_56d5h:
	ld hl,(l0fb4h)		;56d5	2a b4 0f	* . .
	ex de,hl		;56d8	eb		.
	ld hl,(l0f89h)		;56d9	2a 89 0f	* . .
	ld a,l			;56dc	7d		}
	xor e			;56dd	ab		.
	ld l,a			;56de	6f		o
	ld a,h			;56df	7c		|
	xor d			;56e0	aa		.
	or l			;56e1	b5		.
	jp z,l56e6h		;56e2	ca e6 56	. . V
	ret			;56e5	c9		.
l56e6h:
	ld hl,(l0fbch+2)	;56e6	2a be 0f	* . .
	ex de,hl		;56e9	eb		.
	ld hl,(l0f8bh)		;56ea	2a 8b 0f	* . .
	ld a,l			;56ed	7d		}
	xor e			;56ee	ab		.
	ld l,a			;56ef	6f		o
	ld a,h			;56f0	7c		|
	xor d			;56f1	aa		.
	or l			;56f2	b5		.
	jp z,l56f7h		;56f3	ca f7 56	. . V
	ret			;56f6	c9		.
l56f7h:
	ld hl,(score_word)	;56f7	2a 05 0f	* . .
	inc hl			;56fa	23		#
	inc hl			;56fb	23		#
	ld (score_word),hl	;56fc	22 05 0f	" . .
	ld hl,(l0ef6h)		;56ff	2a f6 0e	* . .
	ld (l0fa9h),hl		;5702	22 a9 0f	" . .
	ret			;5705	c9		.
sub_5706h:
	ld hl,00024h		;5706	21 24 00	! $ .
	ld (l0fa1h+2),hl	;5709	22 a3 0f	" . .
	ld de,l0efdh		;570c	11 fd 0e	. . .
	ld hl,l0fa1h+2		;570f	21 a3 0f	! . .
	call sub_626bh		;5712	cd 6b 62	. k b
	ld hl,score_word	;5715	21 05 0f	! . .
	call sub_61a8h		;5718	cd a8 61	. . a
	call print_setup	;571b	cd ea 6f	. . o
	ld hl,l0f49h		;571e	21 49 0f	! I .
	call print_string	;5721	cd 6e 6e	. n n
	ld hl,(score_word)	;5724	2a 05 0f	* . .
	ex de,hl		;5727	eb		.
	ld hl,(l0f6dh)		;5728	2a 6d 0f	* m .
	ld a,d			;572b	7a		z
	xor h			;572c	ac		.
	ld a,d			;572d	7a		z
	jp m,l5735h		;572e	fa 35 57	. 5 W
	ld a,e			;5731	7b		{
	sub l			;5732	95		.
	ld a,d			;5733	7a		z
	sbc a,h			;5734	9c		.
l5735h:
	rla			;5735	17		.
	jp nc,l573ah		;5736	d2 3a 57	. : W
	ret			;5739	c9		.
l573ah:
	ld hl,(l0f6bh)		;573a	2a 6b 0f	* k .
	inc hl			;573d	23		#
	ld (l0f6bh),hl		;573e	22 6b 0f	" k .
	ld hl,(l0f6bh)		;5741	2a 6b 0f	* k .
	call integer_mul_inline	;5744	cd 8e 76	. . v
	defw 00064h		;5747	64 00		d .
	ld (l0f6dh),hl		;5749	22 6d 0f	" m .
	ld hl,(lads_word)	;574c	2a 67 0f	* g .
	inc hl			;574f	23		#
	ld (lads_word),hl	;5750	22 67 0f	" g .
	ld hl,00005h		;5753	21 05 00	! . .
	ld (l0fa1h+2),hl	;5756	22 a3 0f	" . .
	ld de,l0efdh		;5759	11 fd 0e	. . .
	ld hl,l0fa1h+2		;575c	21 a3 0f	! . .
	call sub_626bh		;575f	cd 6b 62	. k b
	ld hl,lads_word		;5762	21 67 0f	! g .
	call sub_61a8h		;5765	cd a8 61	. . a
	ret			;5768	c9		.
sub_5769h:
	ld hl,00047h		;5769	21 47 00	! G .
	ld (l0fa1h+2),hl	;576c	22 a3 0f	" . .
	ld de,l0efdh		;576f	11 fd 0e	. . .
	ld hl,l0fa1h+2		;5772	21 a3 0f	! . .
	call sub_626bh		;5775	cd 6b 62	. k b
	ld hl,bonus_word	;5778	21 77 0f	! w .
	call sub_61a8h		;577b	cd a8 61	. . a
	ret			;577e	c9		.
sub_577fh:
	ld hl,(l0f7bh)		;577f	2a 7b 0f	* { .
	ld (l0fd4h+2),hl	;5782	22 d6 0f	" . .
	ld hl,00000h		;5785	21 00 00	! . .
	jp l578fh		;5788	c3 8f 57	. . W
l578bh:
	ld hl,(00fd8h)		;578b	2a d8 0f	* . .
	inc hl			;578e	23		#
l578fh:
	ld (00fd8h),hl		;578f	22 d8 0f	" . .
	ld hl,(00fd8h)		;5792	2a d8 0f	* . .
	ex de,hl		;5795	eb		.
	ld hl,(l0fd4h+2)	;5796	2a d6 0f	* . .
	ld a,d			;5799	7a		z
	xor h			;579a	ac		.
	ld a,h			;579b	7c		|
	jp m,l57a3h		;579c	fa a3 57	. . W
	ld a,l			;579f	7d		}
	sub e			;57a0	93		.
	ld a,h			;57a1	7c		|
	sbc a,d			;57a2	9a		.
l57a3h:
	rla			;57a3	17		.
	jp nc,l578bh		;57a4	d2 8b 57	. . W
	ret			;57a7	c9		.
sub_57a8h:
	ld hl,(l0f03h)		;57a8	2a 03 0f	* . .
	ld (l0fdah),hl		;57ab	22 da 0f	" . .
	ld hl,00000h		;57ae	21 00 00	! . .
	jp l57b8h		;57b1	c3 b8 57	. . W
l57b4h:
	ld hl,(00fd8h)		;57b4	2a d8 0f	* . .
	inc hl			;57b7	23		#
l57b8h:
	ld (00fd8h),hl		;57b8	22 d8 0f	" . .
	ld hl,(00fd8h)		;57bb	2a d8 0f	* . .
	ex de,hl		;57be	eb		.
	ld hl,(l0fdah)		;57bf	2a da 0f	* . .
	ld a,d			;57c2	7a		z
	xor h			;57c3	ac		.
	ld a,h			;57c4	7c		|
	jp m,l57cch		;57c5	fa cc 57	. . W
	ld a,l			;57c8	7d		}
	sub e			;57c9	93		.
	ld a,h			;57ca	7c		|
	sbc a,d			;57cb	9a		.
l57cch:
	rla			;57cc	17		.
	jp nc,l57b4h		;57cd	d2 b4 57	. . W
	ret			;57d0	c9		.
sub_57d1h:
	ld hl,l0fdah+2		;57d1	21 dc 0f	! . .
	call keyboard_poll	;57d4	cd 7d 61	. } a
	ld hl,(l0fdah+2)	;57d7	2a dc 0f	* . .
	ld a,h			;57da	7c		|
	or l			;57db	b5		.
	jp nz,l57e0h		;57dc	c2 e0 57	. . W
	ret			;57df	c9		.
l57e0h:
	jp sub_57d1h		;57e0	c3 d1 57	. . W
sub_57e3h:
	ld hl,00008h		;57e3	21 08 00	! . .
	ld (l0fdeh),hl		;57e6	22 de 0f	" . .
	jp sub_57f2h		;57e9	c3 f2 57	. . W
sub_57ech:
	ld hl,00001h		;57ec	21 01 00	! . .
	ld (l0fdeh),hl		;57ef	22 de 0f	" . .
sub_57f2h:
	call sub_5847h		;57f2	cd 47 58	. G X
	ld hl,(l0fdeh)		;57f5	2a de 0f	* . .
	ld (l0fe0h),hl		;57f8	22 e0 0f	" . .
	ld hl,00001h		;57fb	21 01 00	! . .
	jp l5816h		;57fe	c3 16 58	. . X
l5801h:
	ld hl,l0f5fh		;5801	21 5f 0f	! _ .
	call keyboard_poll	;5804	cd 7d 61	. } a
	ld hl,(l0f5fh)		;5807	2a 5f 0f	* _ .
	ld a,h			;580a	7c		|
	or l			;580b	b5		.
	jp nz,l582eh		;580c	c2 2e 58	. . X
	call sub_57a8h		;580f	cd a8 57	. . W
	ld hl,(l0fe2h)		;5812	2a e2 0f	* . .
	inc hl			;5815	23		#
l5816h:
	ld (l0fe2h),hl		;5816	22 e2 0f	" . .
	ld hl,(l0fe2h)		;5819	2a e2 0f	* . .
	ex de,hl		;581c	eb		.
	ld hl,(l0fe0h)		;581d	2a e0 0f	* . .
	ld a,d			;5820	7a		z
	xor h			;5821	ac		.
	ld a,h			;5822	7c		|
	jp m,l582ah		;5823	fa 2a 58	. * X
	ld a,l			;5826	7d		}
	sub e			;5827	93		.
	ld a,h			;5828	7c		|
	sbc a,d			;5829	9a		.
l582ah:
	rla			;582a	17		.
	jp nc,l5801h		;582b	d2 01 58	. . X
l582eh:
	ld de,00effh		;582e	11 ff 0e	. . .
	ld hl,l0fa1h+2		;5831	21 a3 0f	! . .
	call sub_626bh		;5834	cd 6b 62	. k b
	call print_setup	;5837	cd ea 6f	. . o
	ld hl,l0f61h		;583a	21 61 0f	! a .
	call sub_71d5h		;583d	cd d5 71	. . q
	call sub_7570h		;5840	cd 70 75	. p u
	call print_string	;5843	cd 6e 6e	. n n
	ret			;5846	c9		.
sub_5847h:
	ld hl,(l0f4ch)		;5847	2a 4c 0f	* L .
	ld a,h			;584a	7c		|
	cpl			;584b	2f		/
	ld h,a			;584c	67		g
	ld a,l			;584d	7d		}
	cpl			;584e	2f		/
	ld l,a			;584f	6f		o
	ld a,h			;5850	7c		|
	or l			;5851	b5		.
	jp z,l5856h		;5852	ca 56 58	. V X
	ret			;5855	c9		.
l5856h:
	ld hl,00001h		;5856	21 01 00	! . .
	ld (l0fa1h+2),hl	;5859	22 a3 0f	" . .
	ld de,00effh		;585c	11 ff 0e	. . .
	ld hl,l0fa1h+2		;585f	21 a3 0f	! . .
	call sub_626bh		;5862	cd 6b 62	. k b
	call print_setup	;5865	cd ea 6f	. . o
	ld hl,l0f61h		;5868	21 61 0f	! a .
	call print_string	;586b	cd 6e 6e	. n n
	ret			;586e	c9		.
sub_586fh:
	ld de,l0fafh		;586f	11 af 0f	. . .
	ld hl,l58feh		;5872	21 fe 58	! . X
	call string_assign	;5875	cd db 74	. . t
	ld hl,00001h		;5878	21 01 00	! . .
	ld (l0fa1h+2),hl	;587b	22 a3 0f	" . .
	ld de,00effh		;587e	11 ff 0e	. . .
	ld hl,l0fa1h+2		;5881	21 a3 0f	! . .
	call sub_626bh		;5884	cd 6b 62	. k b
	ld de,l0f61h		;5887	11 61 0f	. a .
	ld hl,s_type_return_to_continue	;588a	21 e2 58	! . X
	call string_assign	;588d	cd db 74	. . t
	call print_setup	;5890	cd ea 6f	. . o
	ld hl,l0f61h		;5893	21 61 0f	! a .
	call print_string	;5896	cd 6e 6e	. n n
	ld de,00001h		;5899	11 01 00	. . .
	ld hl,000ffh		;589c	21 ff 00	! . .
	call input_string	;589f	cd 38 8e	. 8 .
	ld de,00f64h		;58a2	11 64 0f	. d .
	call string_assign	;58a5	cd db 74	. . t
	ld hl,00003h		;58a8	21 03 00	! . .
	call character_string	;58ab	cd b5 75	. . u
	ex de,hl		;58ae	eb		.
	ld hl,00f64h		;58af	21 64 0f	! d .
	call sub_73bdh		;58b2	cd bd 73	. . s
	xor a			;58b5	af		.
	ld a,021h		;58b6	3e 21		> !
	dec c			;58b8	0d		.
	nop			;58b9	00		.
	call character_string	;58ba	cd b5 75	. . u
	ex de,hl		;58bd	eb		.
	ld hl,00f64h		;58be	21 64 0f	! d .
	call branch_if_strings_unequal	;58c1	cd b8 73	. . s
	sbc a,c			;58c4	99		.
	ld e,b			;58c5	58		X
	ld de,00effh		;58c6	11 ff 0e	. . .
	ld hl,l0fa1h+2		;58c9	21 a3 0f	! . .
	call sub_626bh		;58cc	cd 6b 62	. k b
	call print_setup	;58cf	cd ea 6f	. . o
	ld hl,l0f61h		;58d2	21 61 0f	! a .
	call sub_71d5h		;58d5	cd d5 71	. . q
	call sub_7570h		;58d8	cd 70 75	. p u
	call print_string	;58db	cd 6e 6e	. n n
	ret			;58de	c9		.

; BLOCK 'game_data' (start 0x58df end 0x617d)
game_data_start:
	defb 0cdh		;58df	cd		.
	defb 0bbh		;58e0	bb		.
	defb 068h		;58e1	68		h
; Game string descriptors (length byte, little-endian text pointer)
s_type_return_to_continue:
	defb 019h		;58e2	19		|.|
	defw 058e5h		;58e3	e5 58		|.X|
	defm "Type RETURN to continue: "		;58e5	54 79 70 65 20 52 45 54 55 52 4e 20 74 6f 20 63 6f 6e 74 69 6e 75 65 3a 20		|Type RETURN to continue: |
l58feh:
	defb 000h		;58fe	00		.
	defb 001h		;58ff	01		.
	defb 059h		;5900	59		Y
s_updating_high_scores:
	defb 017h		;5901	17		|.|
	defw 05904h		;5902	04 59		|.Y|
	defm "Updating high scores..."		;5904	55 70 64 61 74 69 6e 67 20 68 69 67 68 20 73 63 6f 72 65 73 2e 2e 2e		|Updating high scores...|
s_enter_your_name:
	defb 011h		;591b	11		|.|
	defw 0591eh		;591c	1e 59		|.Y|
	defm "Enter your name: "		;591e	45 6e 74 65 72 20 79 6f 75 72 20 6e 61 6d 65 3a 20		|Enter your name: |
s_high_score_undeserved:
	defb 024h		;592f	24		|$|
	defw 05932h		;5930	32 59		|2Y|
	defm "You really don't deserve this but..."		;5932	59 6f 75 20 72 65 61 6c 6c 79 20 64 6f 6e 27 74 20 64 65 73 65 72 76 65 20 74 68 69 73 20 62 75 74 2e 2e 2e		|You really don't deserve this but...|
s_high_score_not_bad:
	defb 017h		;5956	17		|.|
	defw 05959h		;5957	59 59		|YY|
	defm "Not bad for a young Lad"		;5959	4e 6f 74 20 62 61 64 20 66 6f 72 20 61 20 79 6f 75 6e 67 20 4c 61 64		|Not bad for a young Lad|
s_high_score_amazing:
	defb 013h		;5970	13		|.|
	defw 05973h		;5971	73 59		|sY|
	defm "Amazing!  You rate!"		;5973	41 6d 61 7a 69 6e 67 21 20 20 59 6f 75 20 72 61 74 65 21		|Amazing!  You rate!|
s_high_score_ladder:
	defb 021h		;5986	21		|!|
	defw 05989h		;5987	89 59		|.Y|
	defm "Looks like we have a Lad-Der here"		;5989	4c 6f 6f 6b 73 20 6c 69 6b 65 20 77 65 20 68 61 76 65 20 61 20 4c 61 64 2d 44 65 72 20 68 65 72 65		|Looks like we have a Lad-Der here|
s_high_score_lad_wiz:
	defb 01bh		;59aa	1b		|.|
	defw 059adh		;59ab	ad 59		|.Y|
	defm "Yeh! Now you are a Lad-Wiz!"		;59ad	59 65 68 21 20 4e 6f 77 20 79 6f 75 20 61 72 65 20 61 20 4c 61 64 2d 57 69 7a 21		|Yeh! Now you are a Lad-Wiz!|
s_high_score_lad_guru:
	defb 01ch		;59c8	1c		|.|
	defw 059cbh		;59c9	cb 59		|.Y|
	defm "Wow! You are now a Lad-Guru!"		;59cb	57 6f 77 21 20 59 6f 75 20 61 72 65 20 6e 6f 77 20 61 20 4c 61 64 2d 47 75 72 75 21		|Wow! You are now a Lad-Guru!|
s_high_score_lad_master:
	defb 01ch		;59e7	1c		|.|
	defw 059eah		;59e8	ea 59		|.Y|
	defm "You are a true Lad-Master!!!"		;59ea	59 6f 75 20 61 72 65 20 61 20 74 72 75 65 20 4c 61 64 2d 4d 61 73 74 65 72 21 21 21		|You are a true Lad-Master!!!|
s_high_score_yahoo:
	defb 03ah		;5a06	3a		|:|
	defw 05a09h		;5a07	09 5a		|.Z|
	defm "          YAHOO! YAHOO! YAHOO! YAHOO! YAHOO! "		;5a09	20 20 20 20 20 20 20 20 20 20 59 41 48 4f 4f 21 20 59 41 48 4f 4f 21 20 59 41 48 4f 4f 21 20 59 41 48 4f 4f 21 20 59 41 48 4f 4f 21 20		|          YAHOO! YAHOO! YAHOO! YAHOO! YAHOO! |
	defm "YAHOO! YAHOO!"		;5a36	59 41 48 4f 4f 21 20 59 41 48 4f 4f 21		|YAHOO! YAHOO!|
s_high_score_cheated:
	defb 01fh		;5a43	1f		|.|
	defw 05a46h		;5a44	46 5a		|FZ|
	defm "YOU CHEATED!!!  You don't rate."		;5a46	59 4f 55 20 43 48 45 41 54 45 44 21 21 21 20 20 59 6f 75 20 64 6f 6e 27 74 20 72 61 74 65 2e		|YOU CHEATED!!!  You don't rate.|
s_hooka:
	defb 006h		;5a65	06		|.|
	defw 05a68h		;5a66	68 5a		|hZ|
	defm "Hooka!"		;5a68	48 6f 6f 6b 61 21		|Hooka!|
s_actor_o:
	defb 001h		;5a6e	01		|.|
	defw 05a71h		;5a6f	71 5a		|qZ|
	defm "o"		;5a71	6f		|o|
s_actor_asterisk:
	defb 001h		;5a72	01		|.|
	defw 05a75h		;5a73	75 5a		|uZ|
	defm "*"		;5a75	2a		|*|
s_get_ready:
	defb 00ah		;5a76	0a		|.|
	defw 05a79h		;5a77	79 5a		|yZ|
	defm "Get ready!"		;5a79	47 65 74 20 72 65 61 64 79 21		|Get ready!|
s_bonus_time:
	defb 00bh		;5a83	0b		|.|
	defw 05a86h		;5a84	86 5a		|.Z|
	defm "Bonus time "		;5a86	42 6f 6e 75 73 20 74 69 6d 65 20		|Bonus time |
s_score:
	defb 00bh		;5a91	0b		|.|
	defw 05a94h		;5a92	94 5a		|.Z|
	defm "     Score "		;5a94	20 20 20 20 20 53 63 6f 72 65 20		|     Score |
s_level:
	defb 00ah		;5a9f	0a		|.|
	defw 05aa2h		;5aa0	a2 5a		|.Z|
	defm "     Level"		;5aa2	20 20 20 20 20 4c 65 76 65 6c		|     Level|
s_lads:
	defb 004h		;5aac	04		|.|
	defw 05aafh		;5aad	af 5a		|.Z|
	defm "Lads"		;5aaf	4c 61 64 73		|Lads|
s_type_return_for_menu:
	defb 024h		;5ab3	24		|$|
	defw 05ab6h		;5ab4	b6 5a		|.Z|
	defm "Type RETURN to return to main menu: "		;5ab6	54 79 70 65 20 52 45 54 55 52 4e 20 74 6f 20 72 65 74 75 72 6e 20 74 6f 20 6d 61 69 6e 20 6d 65 6e 75 3a 20		|Type RETURN to return to main menu: |
s_good_luck:
	defb 00eh		;5ada	0e		|.|
	defw 05addh		;5adb	dd 5a		|.Z|
	defm "Good luck Lad."		;5add	47 6f 6f 64 20 6c 75 63 6b 20 4c 61 64 2e		|Good luck Lad.|
s_pause_hint:
	defb 021h		;5aeb	21		|!|
	defw 05aeeh		;5aec	ee 5a		|.Z|
	defm "Type an ESCape to pause the game."		;5aee	54 79 70 65 20 61 6e 20 45 53 43 61 70 65 20 74 6f 20 70 61 75 73 65 20 74 68 65 20 67 61 6d 65 2e		|Type an ESCape to pause the game.|
s_instructions_bonus_remainder:
	defb 02fh		;5b0f	2f		|/|
	defw 05b12h		;5b10	12 5b		|.[|
	defm "that are left when you have finished the level."		;5b12	74 68 61 74 20 61 72 65 20 6c 65 66 74 20 77 68 65 6e 20 79 6f 75 20 68 61 76 65 20 66 69 6e 69 73 68 65 64 20 74 68 65 20 6c 65 76 65 6c 2e		|that are left when you have finished the level.|
s_instructions_statues:
	defb 03dh		;5b41	3d		|=|
	defw 05b44h		;5b42	44 5b		|D[|
	defm "statues (shown as &).  You will receive the "		;5b44	73 74 61 74 75 65 73 20 28 73 68 6f 77 6e 20 61 73 20 26 29 2e 20 20 59 6f 75 20 77 69 6c 6c 20 72 65 63 65 69 76 65 20 74 68 65 20		|statues (shown as &).  You will receive the |
	defm "bonus time points"		;5b70	62 6f 6e 75 73 20 74 69 6d 65 20 70 6f 69 6e 74 73		|bonus time points|
s_instructions_gold:
	defb 02eh		;5b81	2e		|.|
	defw 05b84h		;5b82	84 5b		|.[|
	defm "Extra points are awarded for touching the gold"		;5b84	45 78 74 72 61 20 70 6f 69 6e 74 73 20 61 72 65 20 61 77 61 72 64 65 64 20 66 6f 72 20 74 6f 75 63 68 69 6e 67 20 74 68 65 20 67 6f 6c 64		|Extra points are awarded for touching the gold|
s_instructions_extra_lad:
	defb 032h		;5bb2	32		|2|
	defw 05bb5h		;5bb3	b5 5b		|.[|
	defm "A new Lad will be awarded for every 10,000 "		;5bb5	41 20 6e 65 77 20 4c 61 64 20 77 69 6c 6c 20 62 65 20 61 77 61 72 64 65 64 20 66 6f 72 20 65 76 65 72 79 20 31 30 2c 30 30 30 20		|A new Lad will be awarded for every 10,000 |
	defm "points."		;5be0	70 6f 69 6e 74 73 2e		|points.|
s_instructions_bonus_expires:
	defb 014h		;5be7	14		|.|
	defw 05beah		;5be8	ea 5b		|.[|
	defm "bonus time runs out."		;5bea	62 6f 6e 75 73 20 74 69 6d 65 20 72 75 6e 73 20 6f 75 74 2e		|bonus time runs out.|
s_instructions_treasure:
	defb 03ch		;5bfe	3c		|<|
	defw 05c01h		;5bff	01 5c		|.\|
	defm "You must find and grasp the treasure (shown as "		;5c01	59 6f 75 20 6d 75 73 74 20 66 69 6e 64 20 61 6e 64 20 67 72 61 73 70 20 74 68 65 20 74 72 65 61 73 75 72 65 20 28 73 68 6f 77 6e 20 61 73 20		|You must find and grasp the treasure (shown as |
	defm "$) BEFORE the"		;5c30	24 29 20 42 45 46 4f 52 45 20 74 68 65		|$) BEFORE the|
s_instructions_jump_and_rocks:
	defb 040h		;5c3d	40		|@|
	defw 05c40h		;5c3e	40 5c		|@\|
	defm "typing SPACE.  But beware of the falling rocks "		;5c40	74 79 70 69 6e 67 20 53 50 41 43 45 2e 20 20 42 75 74 20 62 65 77 61 72 65 20 6f 66 20 74 68 65 20 66 61 6c 6c 69 6e 67 20 72 6f 63 6b 73 20		|typing SPACE.  But beware of the falling rocks |
	defm "called Der rocks."		;5c6f	63 61 6c 6c 65 64 20 44 65 72 20 72 6f 63 6b 73 2e		|called Der rocks.|
s_instructions_controls:
	defb 03eh		;5c80	3e		|>|
	defw 05c83h		;5c81	83 5c		|.\|
	defm "You control Lad by typing the direction buttons "		;5c83	59 6f 75 20 63 6f 6e 74 72 6f 6c 20 4c 61 64 20 62 79 20 74 79 70 69 6e 67 20 74 68 65 20 64 69 72 65 63 74 69 6f 6e 20 62 75 74 74 6f 6e 73 20		|You control Lad by typing the direction buttons |
	defm "and jumping by"		;5cb3	61 6e 64 20 6a 75 6d 70 69 6e 67 20 62 79		|and jumping by|
s_instructions_riches:
	defb 015h		;5cc1	15		|.|
	defw 05cc4h		;5cc2	c4 5c		|.\|
	defm "treasures and riches."		;5cc4	74 72 65 61 73 75 72 65 73 20 61 6e 64 20 72 69 63 68 65 73 2e		|treasures and riches.|
s_instructions_corridors:
	defb 03eh		;5cd9	3e		|>|
	defw 05cdch		;5cda	dc 5c		|.\|
	defm "dark corridors never before seen by human eyes "		;5cdc	64 61 72 6b 20 63 6f 72 72 69 64 6f 72 73 20 6e 65 76 65 72 20 62 65 66 6f 72 65 20 73 65 65 6e 20 62 79 20 68 75 6d 61 6e 20 65 79 65 73 20		|dark corridors never before seen by human eyes |
	defm "and find hidden"		;5d0b	61 6e 64 20 66 69 6e 64 20 68 69 64 64 65 6e		|and find hidden|
s_instructions_intro:
	defb 03dh		;5d1a	3d		|=|
	defw 05d1dh		;5d1b	1d 5d		|.]|
	defm "You are a Lad trapped in a maze.  Your mission "		;5d1d	59 6f 75 20 61 72 65 20 61 20 4c 61 64 20 74 72 61 70 70 65 64 20 69 6e 20 61 20 6d 61 7a 65 2e 20 20 59 6f 75 72 20 6d 69 73 73 69 6f 6e 20		|You are a Lad trapped in a maze.  Your mission |
	defm "is explore the"		;5d4c	69 73 20 65 78 70 6c 6f 72 65 20 74 68 65		|is explore the|
s_key_l_lower:
	defb 001h		;5d5a	01		|.|
	defw 05d5dh		;5d5b	5d 5d		|]]|
	defm "l"		;5d5d	6c		|l|
s_key_l_upper:
	defb 001h		;5d5e	01		|.|
	defw 05d61h		;5d5f	61 5d		|a]|
	defm "L"		;5d61	4c		|L|
s_key_i_lower:
	defb 001h		;5d62	01		|.|
	defw 05d65h		;5d63	65 5d		|e]|
	defm "i"		;5d65	69		|i|
s_key_i_upper:
	defb 001h		;5d66	01		|.|
	defw 05d69h		;5d67	69 5d		|i]|
	defm "I"		;5d69	49		|I|
s_key_c_lower:
	defb 001h		;5d6a	01		|.|
	defw 05d6dh		;5d6b	6d 5d		|m]|
	defm "c"		;5d6d	63		|c|
s_key_c_upper:
	defb 001h		;5d6e	01		|.|
	defw 05d71h		;5d6f	71 5d		|q]|
	defm "C"		;5d71	43		|C|
s_key_p_lower:
	defb 001h		;5d72	01		|.|
	defw 05d75h		;5d73	75 5d		|u]|
	defm "p"		;5d75	70		|p|
s_key_p_upper:
	defb 001h		;5d76	01		|.|
	defw 05d79h		;5d77	79 5d		|y]|
	defm "P"		;5d79	50		|P|
s_exiting:
	defb 00ah		;5d7a	0a		|.|
	defw 05d7dh		;5d7b	7d 5d		|}]|
	defm "Exiting..."		;5d7d	45 78 69 74 69 6e 67 2e 2e 2e		|Exiting...|
s_key_e_lower:
	defb 001h		;5d87	01		|.|
	defw 05d8ah		;5d88	8a 5d		|.]|
	defm "e"		;5d8a	65		|e|
s_key_e_upper:
	defb 001h		;5d8b	01		|.|
	defw 05d8eh		;5d8c	8e 5d		|.]|
	defm "E"		;5d8e	45		|E|
s_insult_quiche:
	defb 00fh		;5d8f	0f		|.|
	defw 05d92h		;5d90	92 5d		|.]|
	defm "You eat quiche!"		;5d92	59 6f 75 20 65 61 74 20 71 75 69 63 68 65 21		|You eat quiche!|
s_insult_hurry:
	defb 01fh		;5da1	1f		|.|
	defw 05da4h		;5da2	a4 5d		|.]|
	defm "Come on, we don't have all day!"		;5da4	43 6f 6d 65 20 6f 6e 2c 20 77 65 20 64 6f 6e 27 74 20 68 61 76 65 20 61 6c 6c 20 64 61 79 21		|Come on, we don't have all day!|
s_menu_prompt:
	defb 018h		;5dc3	18		|.|
	defw 05dc6h		;5dc4	c6 5d		|.]|
	defm "Enter one of the abo"		;5dc6	45 6e 74 65 72 20 6f 6e 65 20 6f 66 20 74 68 65 20 61 62 6f		|Enter one of the abo|
l5ddah:
	defm "ve: "		;5dda	76 65 3a 20		|ve: |
s_play_speed:
	defb 00ch		;5dde	0c		|.|
	defw 05de1h		;5ddf	e1 5d		|.]|
	defm "Play speed: "		;5de1	50 6c 61 79 20 73 70 65 65 64 3a 20		|Play speed: |
s_zero_hundreds:
	defb 002h		;5ded	02		|.|
	defw 05df0h		;5dee	f0 5d		|.]|
	defm "00"		;5df0	30 30		|00|
s_last_score:
	defb 00ch		;5df2	0c		|.|
	defw 05df5h		;5df3	f5 5d		|.]|
	defm "Last Score: "		;5df5	4c 61 73 74 20 53 63 6f 72 65 3a 20		|Last Score: |
s_zero_hundreds_padded:
	defb 004h		;5e01	04		|.|
	defw 05e04h		;5e02	04 5e		|.^|
	defm "00  "		;5e04	30 30 20 20		|00  |
s_score_rank_suffix:
	defb 002h		;5e08	02		|.|
	defw 05e0bh		;5e09	0b 5e		|.^|
	defm ") "		;5e0b	29 20		|) |
s_high_scores_heading:
	defb 00bh		;5e0d	0b		|.|
	defw 05e10h		;5e0e	10 5e		|.^|
	defm "High Scor"		;5e10	48 69 67 68 20 53 63 6f 72		|High Scor|
l5e19h:
	defm "es"		;5e19	65 73		|es|
s_jump_key_hint:
	defb 00ch		;5e1b	0c		|.|
	defw 05e1eh		;5e1c	1e 5e		|.^|
	defm "Jump = Space"		;5e1e	4a 75 6d 70 20 3d 20 53 70 61 63 65		|Jump = Space|
s_right_key_hint:
	defb 00ah		;5e2a	0a		|.|
	defw 05e2dh		;5e2b	2d 5e		|-^|
	defm "  Right = "		;5e2d	20 20 52 69 67 68 74 20 3d 20		|  Right = |
s_left_key_hint:
	defb 009h		;5e37	09		|.|
	defw 05e3ah		;5e38	3a 5e		|:^|
	defm "  Left = "		;5e3a	20 20 4c 65 66 74 20 3d 20		|  Left = |
s_down_key_hint:
	defb 009h		;5e43	09		|.|
	defw 05e46h		;5e44	46 5e		|F^|
	defm "  Down = "		;5e46	20 20 44 6f 77 6e 20 3d 20		|  Down = |
s_up_key_hint:
	defb 005h		;5e4f	05		|.|
	defw 05e52h		;5e50	52 5e		|R^|
	defm "Up = "		;5e52	55 70 20 3d 20		|Up = |
s_menu_exit_option:
	defb 00fh		;5e57	0f		|.|
	defw 05e5ah		;5e58	5a 5e		|Z^|
	defm "E = "		;5e5a	45 20 3d 20		|E = |
l5e5eh:
	defm "Exit Ladder"		;5e5e	45 78 69 74 20 4c 61 64 64 65 72		|Exit Ladder|
s_menu_instructions_option:
	defb 010h		;5e69	10		|.|
	defw 05e6ch		;5e6a	6c 5e		|l^|
	defm "I = Instructions"		;5e6c	49 20 3d 20 49 6e 73 74 72 75 63 74 69 6f 6e 73		|I = Instructions|
s_menu_configure_option:
	defb 014h		;5e7c	14		|.|
	defw 05e7fh		;5e7d	7f 5e		|.^|
	defm "C = Configure Ladder"		;5e7f	43 20 3d 20 43 6f 6e 66 69 67 75 72 65 20 4c 61 64 64 65 72		|C = Configure Ladder|
s_menu_difficulty_option:
	defb 01eh		;5e93	1e		|.|
	defw 05e96h		;5e94	96 5e		|.^|
	defm "L = Change level of difficulty"		;5e96	4c 20 3d 20 43 68 61 6e 67 65 20 6c 65 76 65 6c 20 6f 66 20 64 69 66 66 69 63 75 6c 74 79		|L = Change level of difficulty|
s_menu_play_option:
	defb 00dh		;5eb4	0d		|.|
	defw 05eb7h		;5eb5	b7 5e		|.^|
	defm "P = Play game"		;5eb7	50 20 3d 20 50 6c 61 79 20 67 61 6d 65		|P = Play game|
s_terminal_heading:
	defb 00ah		;5ec4	0a		|.|
	defw 05ec7h		;5ec5	c7 5e		|.^|
	defm "Terminal: "		;5ec7	54 65 72 6d 69 6e 61 6c 3a 20		|Terminal: |
s_version_heading:
	defb 00ah		;5ed1	0a		|.|
	defw 05ed4h		;5ed2	d4 5e		|.^|
	defm "Version : "		;5ed4	56 65 72 73 69 6f 6e 20 3a 20		|Version : |
s_copyright:
	defb 017h		;5ede	17		|.|
	defw 05ee1h		;5edf	e1 5e		|.^|
	defm "(c) 1982 Yahoo Software"		;5ee1	28 63 29 20 31 39 38 32 20 59 61 68 6f 6f 20 53 6f 66 74 77 61 72 65		|(c) 1982 Yahoo Software|
s_menu_logo_row_6:
	defb 02fh		;5ef8	2f		|/|
	defw 05efbh		;5ef9	fb 5e		|.^|
	defm "LLLLLLLL   aaa aa   ddd dd   ddd dd   eeee   rr"		;5efb	4c 4c 4c 4c 4c 4c 4c 4c 20 20 20 61 61 61 20 61 61 20 20 20 64 64 64 20 64 64 20 20 20 64 64 64 20 64 64 20 20 20 65 65 65 65 20 20 20 72 72		|LLLLLLLL   aaa aa   ddd dd   ddd dd   eeee   rr|
s_menu_logo_row_5:
	defb 02fh		;5f2a	2f		|/|
	defw 05f2dh		;5f2b	2d 5f		|-_|
	defm "LL        aa  aa   dd  dd   dd  dd   ee      rr"		;5f2d	4c 4c 20 20 20 20 20 20 20 20 61 61 20 20 61 61 20 20 20 64 64 20 20 64 64 20 20 20 64 64 20 20 64 64 20 20 20 65 65 20 20 20 20 20 20 72 72		|LL        aa  aa   dd  dd   dd  dd   ee      rr|
s_menu_logo_row_4:
	defb 02fh		;5f5c	2f		|/|
	defw 05f5fh		;5f5d	5f 5f		|__|
	defm "LL        aa  aa   dd  dd   dd  dd   eeeeee  rr"		;5f5f	4c 4c 20 20 20 20 20 20 20 20 61 61 20 20 61 61 20 20 20 64 64 20 20 64 64 20 20 20 64 64 20 20 64 64 20 20 20 65 65 65 65 65 65 20 20 72 72		|LL        aa  aa   dd  dd   dd  dd   eeeeee  rr|
s_menu_logo_row_3:
	defb 035h		;5f8e	35		|5|
	defw 05f91h		;5f8f	91 5f		|._|
	defm "LL        aa  aa   dd  d"		;5f91	4c 4c 20 20 20 20 20 20 20 20 61 61 20 20 61 61 20 20 20 64 64 20 20 64		|LL        aa  aa   dd  d|
l5fa9h:
	defm "d   dd  dd   ee  ee  rr    rr"		;5fa9	64 20 20 20 64 64 20 20 64 64 20 20 20 65 65 20 20 65 65 20 20 72 72 20 20 20 20 72 72		|d   dd  dd   ee  ee  rr    rr|
s_menu_logo_row_2:
	defb 034h		;5fc6	34		|4|
	defw 05fc9h		;5fc7	c9 5f		|._|
	defm "LL         aaaa     ddddd    ddddd    eeee   "		;5fc9	4c 4c 20 20 20 20 20 20 20 20 20 61 61 61 61 20 20 20 20 20 64 64 64 64 64 20 20 20 20 64 64 64 64 64 20 20 20 20 65 65 65 65 20 20 20		|LL         aaaa     ddddd    ddddd    eeee   |
	defm "rrrrrrr"		;5ff6	72 72 72 72 72 72 72		|rrrrrrr|
s_menu_logo_row_1:
	defb 022h		;5ffd	22		|"|
	defw 06000h		;5ffe	00 60		|.`|
	defm "LL                     dd       dd"		;6000	4c 4c 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 64 64 20 20 20 20 20 20 20 64 64		|LL                     dd       dd|
s_terminal_pro_score:
	defb 009h		;6022	09		|.|
	defw 06025h		;6023	25 60		|%`|
	defm "PRO SCORE"		;6025	50 52 4f 20 53 43 4f 52 45		|PRO SCORE|
s_terminal_pro_men:
	defb 007h		;602e	07		|.|
	defw 06031h		;602f	31 60		|1`|
	defm "PRO MEN"		;6031	50 52 4f 20 4d 45 4e		|PRO MEN|
s_terminal_pro_level:
	defb 009h		;6038	09		|.|
	defw 0603bh		;6039	3b 60		|;`|
	defm "PRO LEVEL"		;603b	50 52 4f 20 4c 45 56 45 4c		|PRO LEVEL|
l6044h:
	defb 000h		;6044	00		.
	defb 047h		;6045	47		G
	defb 060h		;6046	60		`
s_yes:
	defb 001h		;6047	01		|.|
	defw 0604ah		;6048	4a 60		|J`|
	defm "Y"		;604a	59		|Y|
l604bh:
	defb 000h		;604b	00		.
	defb 04eh		;604c	4e		N
	defb 060h		;604d	60		`
s_ladconf_name:
	defb 007h		;604e	07		|.|
	defw 06051h		;604f	51 60		|Q`|
	defm "LADCONF"		;6051	4c 41 44 43 4f 4e 46		|LADCONF|
s_linking_config:
	defb 023h		;6058	23		|#|
	defw 0605bh		;6059	5b 60		|[`|
	defm "Linking to configuration program..."		;605b	4c 69 6e 6b 69 6e 67 20 74 6f 20 63 6f 6e 66 69 67 75 72 61 74 69 6f 6e 20 70 72 6f 67 72 61 6d 2e 2e 2e		|Linking to configuration program...|
s_config_missing:
	defb 024h		;607e	24		|$|
	defw 06081h		;607f	81 60		|.`|
	defm "Ladder configuration program missing"		;6081	4c 61 64 64 65 72 20 63 6f 6e 66 69 67 75 72 61 74 69 6f 6e 20 70 72 6f 67 72 61 6d 20 6d 69 73 73 69 6e 67		|Ladder configuration program missing|
s_config_link_error:
	defb 01dh		;60a5	1d		|.|
	defw 060a8h		;60a6	a8 60		|.`|
	defm "Unable to link to LADCONF.COM"		;60a8	55 6e 61 62 6c 65 20 74 6f 20 6c 69 6e 6b 20 74 6f 20 4c 41 44 43 4f 4e 46 2e 43 4f 4d		|Unable to link to LADCONF.COM|
s_ladconf_filename:
	defb 00bh		;60c5	0b		|.|
	defw 060c8h		;60c6	c8 60		|.`|
	defm "LADCONF.COM"		;60c8	4c 41 44 43 4f 4e 46 2e 43 4f 4d		|LADCONF.COM|
s_not_configured:
	defb 015h		;60d3	15		|.|
	defw 060d6h		;60d4	d6 60		|.`|
	defm "Ladder not configured"		;60d6	4c 61 64 64 65 72 20 6e 6f 74 20 63 6f 6e 66 69 67 75 72 65 64		|Ladder not configured|
s_data_filename:
	defb 00ah		;60eb	0a		|.|
	defw 060eeh		;60ec	ee 60		|.`|
	defm "LADDER.DAT"		;60ee	4c 41 44 44 45 52 2e 44 41 54		|LADDER.DAT|
s_key_r_upper:
	defb 001h		;60f8	01		|.|
	defw 060fbh		;60f9	fb 60		|.`|
	defm "R"		;60fb	52		|R|
l60fch:
	defb 000h		;60fc	00		.
	defb 0ffh		;60fd	ff		.
	defb 060h		;60fe	60		`
s_default_key_map:
	defb 00dh		;60ff	0d		|.|
	defw 06102h		;6100	02 61		|.a|
	defm "pbdqPbdbPpo-_"		;6102	70 62 64 71 50 62 64 62 50 70 6f 2d 5f		|pbdqPbdbPpo-_|
s_default_key_subset:
	defb 005h		;610f	05		|.|
	defw 06112h		;6110	12 61		|.a|
	defm "gpbqp"		;6112	67 70 62 71 70		|gpbqp|
s_actor_glyphs:
	defb 00bh		;6117	0b		|.|
	defw 0611ah		;6118	1a 61		|.a|
	defm " -=$|VH*^.&"		;611a	20 2d 3d 24 7c 56 48 2a 5e 2e 26		| -=$|VH*^.&|
s_actor_glyphs_alt:
	defb 00bh		;6125	0b		|.|
	defw 06128h		;6126	28 61		|(a|
	defm "g-=$|VH*^.&"		;6128	67 2d 3d 24 7c 56 48 2a 5e 2e 26		|g-=$|VH*^.&|
s_space:
	defb 001h		;6133	01		|.|
	defw 06136h		;6134	36 61		|6a|
	defm " "		;6136	20		| |
s_version_number:
	defb 004h		;6137	04		|.|
	defw 0613ah		;6138	3a 61		|:a|
	defm "1.10"		;613a	31 2e 31 30		|1.10|
l613eh:
	defb 000h		;613e	00		.
	defb 041h		;613f	41		A
	defb 061h		;6140	61		a
	defb 000h		;6141	00		.
	defb 000h		;6142	00		.
	defb 040h		;6143	40		@
	defb 082h		;6144	82		.
	defb 000h		;6145	00		.
	defb 000h		;6146	00		.
	defb 000h		;6147	00		.
	defb 07fh		;6148	7f		.
	defb 000h		;6149	00		.
	defb 000h		;614a	00		.
	defb 000h		;614b	00		.
	defb 080h		;614c	80		.
	defb 000h		;614d	00		.
	defb 050h		;614e	50		P
	defb 043h		;614f	43		C
	defb 08fh		;6150	8f		.
	defb 000h		;6151	00		.
	defb 000h		;6152	00		.
	defb 07ah		;6153	7a		z
	defb 08ah		;6154	8a		.
	defb 000h		;6155	00		.
	defb 000h		;6156	00		.
	defb 000h		;6157	00		.
	defb 081h		;6158	81		.
	defb 0d7h		;6159	d7		.
	defb 0a3h		;615a	a3		.
	defb 070h		;615b	70		p
	defb 03dh		;615c	3d		=
	defb 00ah		;615d	0a		.
	defb 0d7h		;615e	d7		.
	defb 023h		;615f	23		#
	defb 07ah		;6160	7a		z
	defb 0cdh		;6161	cd		.
	defb 0bbh		;6162	bb		.
	defb 068h		;6163	68		h
	defb 001h		;6164	01		.
	defb 000h		;6165	00		.
	defb 000h		;6166	00		.
; Plain ASCII footer following the compiled string pool
s_copyright_footer:
	defm "(c)1982 Yahoo Software"		;6167	28 63 29 31 39 38 32 20 59 61 68 6f 6f 20 53 6f 66 74 77 61 72 65		|(c)1982 Yahoo Software|
; Runtime entry: nonblocking keyboard poll through BDOS function 6
keyboard_poll:
	push hl			;617d	e5		.
; BDOS 6: direct console I/O
	ld c,006h		;617e	0e 06		. .
	ld e,0ffh		;6180	1e ff		. .
	call BDOS		;6182	cd 05 00	. . .
	cp 061h			;6185	fe 61		. a
	jp c,l6191h		;6187	da 91 61	. . a
	cp 07bh			;618a	fe 7b		. {
	jp nc,l6191h		;618c	d2 91 61	. . a
	sub 020h		;618f	d6 20		.  
l6191h:
	pop hl			;6191	e1		.
	ld (hl),a		;6192	77		w
	inc hl			;6193	23		#
	xor a			;6194	af		.
	ld (hl),a		;6195	77		w
	ret			;6196	c9		.
	push hl			;6197	e5		.
; BDOS 12: get version number
	ld c,00ch		;6198	0e 0c		. .
	call BDOS		;619a	cd 05 00	. . .
	ld a,h			;619d	7c		|
	or a			;619e	b7		.
	jp z,l61a3h		;619f	ca a3 61	. . a
	dec a			;61a2	3d		=
l61a3h:
	pop hl			;61a3	e1		.
	ld (hl),a		;61a4	77		w
	inc hl			;61a5	23		#
	ld (hl),a		;61a6	77		w
	ret			;61a7	c9		.
sub_61a8h:
	ld e,(hl)		;61a8	5e		^
	inc hl			;61a9	23		#
	ld d,(hl)		;61aa	56		V
	ex de,hl		;61ab	eb		.
	ld (l6214h),hl		;61ac	22 14 62	" . b
	ld de,l620bh		;61af	11 0b 62	. . b
	ld b,004h		;61b2	06 04		. .
	xor a			;61b4	af		.
	ld (l6213h),a		;61b5	32 13 62	2 . b
l61b8h:
	ld c,000h		;61b8	0e 00		. .
l61bah:
	ld a,(de)		;61ba	1a		.
	ld l,a			;61bb	6f		o
	inc de			;61bc	13		.
	ld a,(de)		;61bd	1a		.
	ld h,a			;61be	67		g
	push de			;61bf	d5		.
	ex de,hl		;61c0	eb		.
	ld hl,(l6214h)		;61c1	2a 14 62	* . b
	add hl,de		;61c4	19		.
	ld a,h			;61c5	7c		|
	and 080h		;61c6	e6 80		. .
	pop de			;61c8	d1		.
	jp nz,l61d4h		;61c9	c2 d4 61	. . a
	inc c			;61cc	0c		.
	ld (l6214h),hl		;61cd	22 14 62	" . b
	dec de			;61d0	1b		.
	jp l61bah		;61d1	c3 ba 61	. . a
l61d4h:
	push de			;61d4	d5		.
	push bc			;61d5	c5		.
	ld a,030h		;61d6	3e 30		> 0
	or c			;61d8	b1		.
	ld e,a			;61d9	5f		_
	ld a,(l6213h)		;61da	3a 13 62	: . b
	or a			;61dd	b7		.
	jp nz,l61ech		;61de	c2 ec 61	. . a
	ld a,e			;61e1	7b		{
	cp 030h			;61e2	fe 30		. 0
	jp nz,l61ech		;61e4	c2 ec 61	. . a
	ld e,020h		;61e7	1e 20		.  
	jp l61f1h		;61e9	c3 f1 61	. . a
l61ech:
	ld a,0ffh		;61ec	3e ff		> .
	ld (l6213h),a		;61ee	32 13 62	2 . b
l61f1h:
; BDOS 6: direct console I/O
	ld c,006h		;61f1	0e 06		. .
	call BDOS		;61f3	cd 05 00	. . .
	pop bc			;61f6	c1		.
	pop de			;61f7	d1		.
	inc de			;61f8	13		.
	dec b			;61f9	05		.
	jp nz,l61b8h		;61fa	c2 b8 61	. . a
	ld hl,(l6214h)		;61fd	2a 14 62	* . b
	ld e,l			;6200	5d		]
; BDOS 6: direct console I/O
	ld c,006h		;6201	0e 06		. .
	ld a,030h		;6203	3e 30		> 0
	or e			;6205	b3		.
	ld e,a			;6206	5f		_
	call BDOS		;6207	cd 05 00	. . .
	ret			;620a	c9		.
l620bh:
	ret p			;620b	f0		.
	ret c			;620c	d8		.
	jr l620bh		;620d	18 fc		. .
	sbc a,h			;620f	9c		.
	rst 38h			;6210	ff		.
	or 0ffh			;6211	f6 ff		. .
l6213h:
	inc h			;6213	24		$
l6214h:
	inc h			;6214	24		$
	ld (07ed5h),hl		;6215	22 d5 7e	" . ~
	ld (l6373h),a		;6218	32 73 63	2 s c
	or a			;621b	b7		.
	jp z,l622fh		;621c	ca 2f 62	. / b
	ld b,a			;621f	47		G
	inc hl			;6220	23		#
	ld e,(hl)		;6221	5e		^
	inc hl			;6222	23		#
	ld d,(hl)		;6223	56		V
	ld hl,l6373h+1		;6224	21 74 63	! t c
l6227h:
	ld a,(de)		;6227	1a		.
	ld (hl),a		;6228	77		w
	inc hl			;6229	23		#
	inc de			;622a	13		.
	dec b			;622b	05		.
	jp nz,l6227h		;622c	c2 27 62	. ' b
l622fh:
	pop hl			;622f	e1		.
	ld a,(hl)		;6230	7e		~
	ld (06473h),a		;6231	32 73 64	2 s d
	or a			;6234	b7		.
	ret z			;6235	c8		.
	ld b,a			;6236	47		G
	inc hl			;6237	23		#
	ld e,(hl)		;6238	5e		^
	inc hl			;6239	23		#
	ld d,(hl)		;623a	56		V
	ld hl,06474h		;623b	21 74 64	! t d
l623eh:
	ld a,(de)		;623e	1a		.
	ld (hl),a		;623f	77		w
	inc hl			;6240	23		#
	inc de			;6241	13		.
	dec b			;6242	05		.
	jp nz,l623eh		;6243	c2 3e 62	. > b
	ret			;6246	c9		.
sub_6247h:
	ld a,(hl)		;6247	7e		~
	ld (06573h),a		;6248	32 73 65	2 s e
	or a			;624b	b7		.
	ret z			;624c	c8		.
	ld b,a			;624d	47		G
	inc hl			;624e	23		#
	ld e,(hl)		;624f	5e		^
	inc hl			;6250	23		#
	ld d,(hl)		;6251	56		V
	ld hl,06574h		;6252	21 74 65	! t e
l6255h:
	ld a,(de)		;6255	1a		.
	ld (hl),a		;6256	77		w
	inc hl			;6257	23		#
	inc de			;6258	13		.
	dec b			;6259	05		.
	jp nz,l6255h		;625a	c2 55 62	. U b
	ret			;625d	c9		.
sub_625eh:
	ld a,(hl)		;625e	7e		~
	ld (06673h),a		;625f	32 73 66	2 s f
	ld a,(de)		;6262	1a		.
	ld (l6674h),a		;6263	32 74 66	2 t f
	ld a,(bc)		;6266	0a		.
	ld (l6674h+1),a		;6267	32 75 66	2 u f
	ret			;626a	c9		.
sub_626bh:
	ld a,(hl)		;626b	7e		~
	ld b,a			;626c	47		G
	ld a,(l6674h)		;626d	3a 74 66	: t f
	add a,b			;6270	80		.
	ld (l6677h),a		;6271	32 77 66	2 w f
	ld a,(de)		;6274	1a		.
	ld b,a			;6275	47		G
	ld a,(l6674h+1)		;6276	3a 75 66	: u f
	add a,b			;6279	80		.
	ld (l6674h+2),a		;627a	32 76 66	2 v f
	ld a,(l6373h)		;627d	3a 73 63	: s c
	or a			;6280	b7		.
	jp z,l628bh		;6281	ca 8b 62	. . b
	ld hl,l6373h+1		;6284	21 74 63	! t c
	ld b,a			;6287	47		G
	call sub_630bh		;6288	cd 0b 63	. . c
l628bh:
	ld a,(06673h)		;628b	3a 73 66	: s f
	cp 001h			;628e	fe 01		. .
	jp z,l62b8h		;6290	ca b8 62	. . b
	cp 002h			;6293	fe 02		. .
	jp z,l62afh		;6295	ca af 62	. . b
	cp 003h			;6298	fe 03		. .
	jp z,l62a6h		;629a	ca a6 62	. . b
	ld a,(l6674h+2)		;629d	3a 76 66	: v f
	call sub_6315h		;62a0	cd 15 63	. . c
	jp l62beh		;62a3	c3 be 62	. . b
l62a6h:
	ld a,(l6677h)		;62a6	3a 77 66	: w f
	call sub_6315h		;62a9	cd 15 63	. . c
	jp l62beh		;62ac	c3 be 62	. . b
l62afh:
	ld a,(l6674h+2)		;62af	3a 76 66	: v f
	call sub_6366h		;62b2	cd 66 63	. f c
	jp l62beh		;62b5	c3 be 62	. . b
l62b8h:
	ld a,(l6677h)		;62b8	3a 77 66	: w f
	call sub_6366h		;62bb	cd 66 63	. f c
l62beh:
	ld a,(06473h)		;62be	3a 73 64	: s d
	or a			;62c1	b7		.
	jp z,l62cch		;62c2	ca cc 62	. . b
	ld b,a			;62c5	47		G
	ld hl,06474h		;62c6	21 74 64	! t d
	call sub_630bh		;62c9	cd 0b 63	. . c
l62cch:
	ld a,(06673h)		;62cc	3a 73 66	: s f
	cp 001h			;62cf	fe 01		. .
	jp z,l62f9h		;62d1	ca f9 62	. . b
	cp 002h			;62d4	fe 02		. .
	jp z,l62f0h		;62d6	ca f0 62	. . b
	cp 003h			;62d9	fe 03		. .
	jp z,l62e7h		;62db	ca e7 62	. . b
	ld a,(l6677h)		;62de	3a 77 66	: w f
	call sub_6315h		;62e1	cd 15 63	. . c
	jp l62ffh		;62e4	c3 ff 62	. . b
l62e7h:
	ld a,(l6674h+2)		;62e7	3a 76 66	: v f
	call sub_6315h		;62ea	cd 15 63	. . c
	jp l62ffh		;62ed	c3 ff 62	. . b
l62f0h:
	ld a,(l6677h)		;62f0	3a 77 66	: w f
	call sub_6366h		;62f3	cd 66 63	. f c
	jp l62ffh		;62f6	c3 ff 62	. . b
l62f9h:
	ld a,(l6674h+2)		;62f9	3a 76 66	: v f
	call sub_6366h		;62fc	cd 66 63	. f c
l62ffh:
	ld a,(06573h)		;62ff	3a 73 65	: s e
	or a			;6302	b7		.
	ret z			;6303	c8		.
	ld b,a			;6304	47		G
	ld hl,06574h		;6305	21 74 65	! t e
	jp sub_630bh		;6308	c3 0b 63	. . c
sub_630bh:
	ld a,(hl)		;630b	7e		~
	call sub_6366h		;630c	cd 66 63	. f c
	inc hl			;630f	23		#
	dec b			;6310	05		.
	jp nz,sub_630bh		;6311	c2 0b 63	. . c
	ret			;6314	c9		.
sub_6315h:
	ld e,a			;6315	5f		_
	ld d,000h		;6316	16 00		. .
	ld b,000h		;6318	06 00		. .
	ld c,000h		;631a	0e 00		. .
l631ch:
	ld hl,0ff9ch		;631c	21 9c ff	! . .
	add hl,de		;631f	19		.
	ld a,h			;6320	7c		|
	and 080h		;6321	e6 80		. .
	jp nz,l632bh		;6323	c2 2b 63	. + c
	inc c			;6326	0c		.
	ex de,hl		;6327	eb		.
	jp l631ch		;6328	c3 1c 63	. . c
l632bh:
	ld a,030h		;632b	3e 30		> 0
	or c			;632d	b1		.
	ld c,a			;632e	4f		O
	ld a,b			;632f	78		x
	or a			;6330	b7		.
	jp nz,l633ah		;6331	c2 3a 63	. : c
	ld a,c			;6334	79		y
	cp 030h			;6335	fe 30		. 0
	jp z,l633fh		;6337	ca 3f 63	. ? c
l633ah:
	ld b,0ffh		;633a	06 ff		. .
	call sub_6366h		;633c	cd 66 63	. f c
l633fh:
	ld c,000h		;633f	0e 00		. .
l6341h:
	ld hl,0fff6h		;6341	21 f6 ff	! . .
	add hl,de		;6344	19		.
	ld a,h			;6345	7c		|
	and 080h		;6346	e6 80		. .
	jp nz,l6350h		;6348	c2 50 63	. P c
	inc c			;634b	0c		.
	ex de,hl		;634c	eb		.
	jp l6341h		;634d	c3 41 63	. A c
l6350h:
	ld a,b			;6350	78		x
	or a			;6351	b7		.
	jp nz,l635ah		;6352	c2 5a 63	. Z c
	ld a,c			;6355	79		y
	or a			;6356	b7		.
	jp z,l6360h		;6357	ca 60 63	. ` c
l635ah:
	ld a,030h		;635a	3e 30		> 0
	or c			;635c	b1		.
	call sub_6366h		;635d	cd 66 63	. f c
l6360h:
	ld a,030h		;6360	3e 30		> 0
	or e			;6362	b3		.
	jp sub_6366h		;6363	c3 66 63	. f c
sub_6366h:
	push hl			;6366	e5		.
	push de			;6367	d5		.
	push bc			;6368	c5		.
	ld e,a			;6369	5f		_
; BDOS 6: direct console I/O
	ld c,006h		;636a	0e 06		. .
	call BDOS		;636c	cd 05 00	. . .
	pop bc			;636f	c1		.
	pop de			;6370	d1		.
	pop hl			;6371	e1		.
	ret			;6372	c9		.
l6373h:
	jr nz,$+34		;6373	20 20		   
	jr nz,$+34		;6375	20 20		   
	jr nz,l63d7h		;6377	20 5e		  ^
	jr nz,l639bh		;6379	20 20		   
	ld e,(hl)		;637b	5e		^
	jr nz,l639eh		;637c	20 20		   
	jr nz,l63a0h		;637e	20 20		   
	jr nz,l63a2h		;6380	20 20		   
	jr nz,l63e2h		;6382	20 5e		  ^
	ld e,(hl)		;6384	5e		^
	ld e,(hl)		;6385	5e		^
	ld e,(hl)		;6386	5e		^
	ld e,(hl)		;6387	5e		^
	ld e,(hl)		;6388	5e		^
	ld e,(hl)		;6389	5e		^
	ld e,(hl)		;638a	5e		^
	ld e,(hl)		;638b	5e		^
	ld e,(hl)		;638c	5e		^
	ld e,(hl)		;638d	5e		^
	ld e,(hl)		;638e	5e		^
	ld (0c300h),hl		;638f	22 00 c3	" . .
	exx			;6392	d9		.
	add hl,sp		;6393	39		9
	sbc a,039h		;6394	de 39		. 9
	jr nz,l63bah		;6396	20 22		  "
	dec a			;6398	3d		=
	dec a			;6399	3d		=
	dec a			;639a	3d		=
l639bh:
	dec a			;639b	3d		=
	dec a			;639c	3d		=
	dec a			;639d	3d		=
l639eh:
	dec a			;639e	3d		=
	dec a			;639f	3d		=
l63a0h:
	dec a			;63a0	3d		=
	dec a			;63a1	3d		=
l63a2h:
	dec a			;63a2	3d		=
	dec a			;63a3	3d		=
	dec a			;63a4	3d		=
	dec a			;63a5	3d		=
	dec a			;63a6	3d		=
	dec a			;63a7	3d		=
	dec a			;63a8	3d		=
	dec a			;63a9	3d		=
	dec a			;63aa	3d		=
	dec a			;63ab	3d		=
	dec a			;63ac	3d		=
	dec a			;63ad	3d		=
	dec a			;63ae	3d		=
	dec a			;63af	3d		=
	dec a			;63b0	3d		=
	dec a			;63b1	3d		=
	dec a			;63b2	3d		=
	dec a			;63b3	3d		=
	dec a			;63b4	3d		=
	dec a			;63b5	3d		=
	dec a			;63b6	3d		=
	dec a			;63b7	3d		=
	dec a			;63b8	3d		=
	dec a			;63b9	3d		=
l63bah:
	dec a			;63ba	3d		=
	dec a			;63bb	3d		=
	dec a			;63bc	3d		=
	dec a			;63bd	3d		=
	dec a			;63be	3d		=
	dec a			;63bf	3d		=
	dec a			;63c0	3d		=
	dec a			;63c1	3d		=
	dec a			;63c2	3d		=
	dec a			;63c3	3d		=
	dec a			;63c4	3d		=
	dec a			;63c5	3d		=
	dec a			;63c6	3d		=
	dec a			;63c7	3d		=
	dec a			;63c8	3d		=
	dec a			;63c9	3d		=
	dec a			;63ca	3d		=
	dec a			;63cb	3d		=
	dec a			;63cc	3d		=
	dec a			;63cd	3d		=
	dec a			;63ce	3d		=
	dec a			;63cf	3d		=
	dec a			;63d0	3d		=
	dec a			;63d1	3d		=
	dec a			;63d2	3d		=
	dec a			;63d3	3d		=
	dec a			;63d4	3d		=
	dec a			;63d5	3d		=
	dec a			;63d6	3d		=
l63d7h:
	dec a			;63d7	3d		=
	dec a			;63d8	3d		=
	dec a			;63d9	3d		=
	dec a			;63da	3d		=
	dec a			;63db	3d		=
	dec a			;63dc	3d		=
	dec a			;63dd	3d		=
	dec a			;63de	3d		=
	dec a			;63df	3d		=
	dec a			;63e0	3d		=
	dec a			;63e1	3d		=
l63e2h:
	dec a			;63e2	3d		=
	dec a			;63e3	3d		=
	dec a			;63e4	3d		=
	dec a			;63e5	3d		=
	dec a			;63e6	3d		=
	ld (0c300h),hl		;63e7	22 00 c3	" . .
	jp po,l6439h		;63ea	e2 39 64	. 9 d
	ld h,c			;63ed	61		a
	jr nz,l641dh		;63ee	20 2d		  -
	ld sp,l3a00h		;63f0	31 00 3a	1 . :
	add a,b			;63f3	80		.
	nop			;63f4	00		.
	ld l,a			;63f5	6f		o
	ld h,000h		;63f6	26 00		& .
	ld (l0f1ah),hl		;63f8	22 1a 0f	" . .
	ld de,l0f1ch		;63fb	11 1c 0f	. . .
	ld hl,l60fch		;63fe	21 fc 60	! . `
	call 0108ah		;6401	cd 8a 10	. . .
	ld hl,(l0f1ah)		;6404	2a 1a 0f	* . .
	ld (l0f1fh),hl		;6407	22 1f 0f	" . .
	ld hl,00001h		;640a	21 01 00	! . .
	jp l3a1dh		;640d	c3 1d 3a	. . :
	ld de,00080h		;6410	11 80 00	. . .
	ld hl,(l0f1fh+2)	;6413	2a 21 0f	* ! .
	add hl,de		;6416	19		.
	ld l,(hl)		;6417	6e		n
	ld h,000h		;6418	26 00		& .
	call 00000h		;641a	cd 00 00	. . .
l641dh:
	ld de,l0f1ch		;641d	11 1c 0f	. . .
	call 00000h		;6420	cd 00 00	. . .
	ld de,l0f1ch		;6423	11 1c 0f	. . .
	call sub_39f1h+1	;6426	cd f2 39	. . 9
	ld hl,(l0f1fh+2)	;6429	2a 21 0f	* ! .
	inc hl			;642c	23		#
	ld (l0f1fh+2),hl	;642d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;6430	2a 21 0f	* ! .
	ex de,hl		;6433	eb		.
	ld hl,(l0f1fh)		;6434	2a 1f 0f	* . .
	ld a,d			;6437	7a		z
	xor h			;6438	ac		.
l6439h:
	ld a,h			;6439	7c		|
	jp m,l3a31h		;643a	fa 31 3a	. 1 :
	ld a,l			;643d	7d		}
	sub e			;643e	93		.
	ld a,h			;643f	7c		|
	sbc a,d			;6440	9a		.
	rla			;6441	17		.
	jp nc,l3a00h		;6442	d2 00 3a	. . :
	call 00000h		;6445	cd 00 00	. . .
	ld hl,s_key_r_upper	;6448	21 f8 60	! . `
	call 00000h		;644b	cd 00 00	. . .
	ld bc,00001h		;644e	01 01 00	. . .
	ld de,s_data_filename	;6451	11 eb 60	. . `
	ld hl,00020h		;6454	21 20 00	!   .
	call 00000h		;6457	cd 00 00	. . .
	ld hl,00001h		;645a	21 01 00	! . .
	call 00000h		;645d	cd 00 00	. . .
	ld de,l0f23h		;6460	11 23 0f	. # .
	ld hl,00020h		;6463	21 20 00	!   .
	call 00000h		;6466	cd 00 00	. . .
	ld de,00001h		;6469	11 01 00	. . .
	ld hl,00001h		;646c	21 01 00	! . .
	call 00000h		;646f	cd 00 00	. . .
	ld hl,00001h		;6472	21 01 00	! . .
	call 00000h		;6475	cd 00 00	. . .
	ld a,h			;6478	7c		|
	cpl			;6479	2f		/
	ld h,a			;647a	67		g
	ld a,l			;647b	7d		}
	cpl			;647c	2f		/
	ld l,a			;647d	6f		o
	ld a,h			;647e	7c		|
	or l			;647f	b5		.
	jp nz,l3b2fh		;6480	c2 2f 3b	. / ;
	ld hl,00001h		;6483	21 01 00	! . .
	call 00000h		;6486	cd 00 00	. . .
	ld hl,s_data_filename	;6489	21 eb 60	! . `
	call 00000h		;648c	cd 00 00	. . .
	call 00000h		;648f	cd 00 00	. . .
	ld hl,l613eh		;6492	21 3e 61	! > a
	call 00000h		;6495	cd 00 00	. . .
	call 03a80h		;6498	cd 80 3a	. . :
	ld hl,l613eh		;649b	21 3e 61	! > a
	call 03a86h		;649e	cd 86 3a	. . :
	call 03a89h		;64a1	cd 89 3a	. . :
	ld hl,s_not_configured	;64a4	21 d3 60	! . `
	call 03a8fh		;64a7	cd 8f 3a	. . :
	ld hl,s_key_r_upper	;64aa	21 f8 60	! . `
	call 03a3ch		;64ad	cd 3c 3a	. < :
	ld bc,00001h		;64b0	01 01 00	. . .
	ld de,s_ladconf_filename	;64b3	11 c5 60	. . `
	ld hl,00020h		;64b6	21 20 00	!   .
	call 03a48h		;64b9	cd 48 3a	. H :
	ld hl,00001h		;64bc	21 01 00	! . .
	call 03a4eh		;64bf	cd 4e 3a	. N :
	ld de,l0f23h		;64c2	11 23 0f	. # .
	ld hl,00020h		;64c5	21 20 00	!   .
	call 03a57h		;64c8	cd 57 3a	. W :
	ld de,00001h		;64cb	11 01 00	. . .
	ld hl,00001h		;64ce	21 01 00	! . .
	call 03a60h		;64d1	cd 60 3a	. ` :
	ld hl,00001h		;64d4	21 01 00	! . .
	call 03a66h		;64d7	cd 66 3a	. f :
	ld a,h			;64da	7c		|
	cpl			;64db	2f		/
	ld h,a			;64dc	67		g
	ld a,l			;64dd	7d		}
	cpl			;64de	2f		/
	ld l,a			;64df	6f		o
	ld a,h			;64e0	7c		|
	or l			;64e1	b5		.
	jp nz,l3b08h		;64e2	c2 08 3b	. . ;
	ld hl,00001h		;64e5	21 01 00	! . .
	call 03a77h		;64e8	cd 77 3a	. w :
	ld hl,s_ladconf_filename	;64eb	21 c5 60	! . `
	call 03a7dh		;64ee	cd 7d 3a	. } :
	call 03a92h		;64f1	cd 92 3a	. . :
	ld hl,l613eh		;64f4	21 3e 61	! > a
	call 03a98h		;64f7	cd 98 3a	. . :
	call 03ae2h		;64fa	cd e2 3a	. . :
	ld hl,l613eh		;64fd	21 3e 61	! > a
	call 03ae8h		;6500	cd e8 3a	. . :
	call 03aebh		;6503	cd eb 3a	. . :
	ld hl,s_config_link_error	;6506	21 a5 60	! . `
	call 03af1h		;6509	cd f1 3a	. . :
	call 03af4h		;650c	cd f4 3a	. . :
	ld hl,s_config_missing	;650f	21 7e 60	! ~ `
	call 03afah		;6512	cd fa 3a	. . :
	call 00000h		;6515	cd 00 00	. . .
	ld hl,00001h		;6518	21 01 00	! . .
	call 03ad9h		;651b	cd d9 3a	. . :
	call 03afdh		;651e	cd fd 3a	. . :
	ld hl,l613eh		;6521	21 3e 61	! > a
	call 03b03h		;6524	cd 03 3b	. . ;
	call 03b0fh		;6527	cd 0f 3b	. . ;
	ld hl,l613eh		;652a	21 3e 61	! > a
	call 03b15h		;652d	cd 15 3b	. . ;
	call 03b18h		;6530	cd 18 3b	. . ;
	ld hl,s_linking_config	;6533	21 58 60	! X `
	call 03b1eh		;6536	cd 1e 3b	. . ;
	ld hl,s_ladconf_name	;6539	21 4e 60	! N `
	call 00000h		;653c	cd 00 00	. . .
	ld de,l0f23h		;653f	11 23 0f	. # .
	ld hl,00001h		;6542	21 01 00	! . .
	call 00000h		;6545	cd 00 00	. . .
	call 00000h		;6548	cd 00 00	. . .
	ld (l0f26h),hl		;654b	22 26 0f	" & .
	ld bc,l0f23h		;654e	01 23 0f	. # .
	ld de,00002h		;6551	11 02 00	. . .
	ld hl,(l0f26h)		;6554	2a 26 0f	* & .
	call 00000h		;6557	cd 00 00	. . .
	ld de,l0f26h+2		;655a	11 28 0f	. ( .
	call 03a17h		;655d	cd 17 3a	. . :
	ld de,00001h		;6560	11 01 00	. . .
	ld hl,00002h		;6563	21 02 00	! . .
	call 03ac2h		;6566	cd c2 3a	. . :
	ld de,l0f23h		;6569	11 23 0f	. # .
	ld hl,00001h		;656c	21 01 00	! . .
	call 03b36h		;656f	cd 36 3b	. 6 ;
	call 03b39h		;6572	cd 39 3b	. 9 ;
	ld (l0f26h),hl		;6575	22 26 0f	" & .
	ld bc,l0f23h		;6578	01 23 0f	. # .
	ld de,00002h		;657b	11 02 00	. . .
	ld hl,(l0f26h)		;657e	2a 26 0f	* & .
	call 03b48h		;6581	cd 48 3b	. H ;
	ld de,l0f2bh		;6584	11 2b 0f	. + .
	call 03b4eh		;6587	cd 4e 3b	. N ;
	ld de,00001h		;658a	11 01 00	. . .
	ld hl,00003h		;658d	21 03 00	! . .
	call 03b57h		;6590	cd 57 3b	. W ;
	ld de,l0f23h		;6593	11 23 0f	. # .
	ld hl,00001h		;6596	21 01 00	! . .
	call 03b60h		;6599	cd 60 3b	. ` ;
	call 03b63h		;659c	cd 63 3b	. c ;
	ld (l0f26h),hl		;659f	22 26 0f	" & .
	ld bc,l0f23h		;65a2	01 23 0f	. # .
	ld de,00002h		;65a5	11 02 00	. . .
	ld hl,(l0f26h)		;65a8	2a 26 0f	* & .
	call 03b72h		;65ab	cd 72 3b	. r ;
	ld de,00f2eh		;65ae	11 2e 0f	. . .
	call 03b78h		;65b1	cd 78 3b	. x ;
	ld de,00001h		;65b4	11 01 00	. . .
	ld hl,00004h		;65b7	21 04 00	! . .
	call 03b81h		;65ba	cd 81 3b	. . ;
	ld de,l0f23h		;65bd	11 23 0f	. # .
	ld hl,00001h		;65c0	21 01 00	! . .
	call 03b8ah		;65c3	cd 8a 3b	. . ;
	call 03b8dh		;65c6	cd 8d 3b	. . ;
	ld (l0f26h),hl		;65c9	22 26 0f	" & .
	ld bc,l0f23h		;65cc	01 23 0f	. # .
	ld de,00002h		;65cf	11 02 00	. . .
	ld hl,(l0f26h)		;65d2	2a 26 0f	* & .
	call 03b9ch		;65d5	cd 9c 3b	. . ;
	ld de,l0f31h		;65d8	11 31 0f	. 1 .
	call 03ba2h		;65db	cd a2 3b	. . ;
	ld de,00001h		;65de	11 01 00	. . .
	ld hl,00005h		;65e1	21 05 00	! . .
	call 03babh		;65e4	cd ab 3b	. . ;
	ld de,l0f23h		;65e7	11 23 0f	. # .
	ld hl,00001h		;65ea	21 01 00	! . .
	call 03bb4h		;65ed	cd b4 3b	. . ;
	call 03bb7h		;65f0	cd b7 3b	. . ;
	ld (l0f26h),hl		;65f3	22 26 0f	" & .
	ld bc,l0f23h		;65f6	01 23 0f	. # .
	ld de,00002h		;65f9	11 02 00	. . .
	ld hl,(l0f26h)		;65fc	2a 26 0f	* & .
	call 03bc6h		;65ff	cd c6 3b	. . ;
	ld de,l0f34h		;6602	11 34 0f	. 4 .
	call 03bcch		;6605	cd cc 3b	. . ;
	ld de,00001h		;6608	11 01 00	. . .
	ld hl,00006h		;660b	21 06 00	! . .
	call 03bd5h		;660e	cd d5 3b	. . ;
	ld de,l0f23h		;6611	11 23 0f	. # .
	ld hl,00001h		;6614	21 01 00	! . .
	call 03bdeh		;6617	cd de 3b	. . ;
	call 03be1h		;661a	cd e1 3b	. . ;
	ld (l0f26h),hl		;661d	22 26 0f	" & .
	ld bc,l0f23h		;6620	01 23 0f	. # .
	ld de,00002h		;6623	11 02 00	. . .
	ld hl,(l0f26h)		;6626	2a 26 0f	* & .
	call 03bf0h		;6629	cd f0 3b	. . ;
	ld de,l0f37h		;662c	11 37 0f	. 7 .
	call 03bf6h		;662f	cd f6 3b	. . ;
	ld de,00001h		;6632	11 01 00	. . .
	ld hl,00007h		;6635	21 07 00	! . .
	call 03bffh		;6638	cd ff 3b	. . ;
	ld de,l0f23h		;663b	11 23 0f	. # .
	ld hl,00001h		;663e	21 01 00	! . .
	call 03c08h		;6641	cd 08 3c	. . <
	ld de,l0f3ah		;6644	11 3a 0f	. : .
	call 03c20h		;6647	cd 20 3c	.   <
	ld bc,l0f23h		;664a	01 23 0f	. # .
	ld de,00002h		;664d	11 02 00	. . .
	ld hl,00001h		;6650	21 01 00	! . .
	call 03c1ah		;6653	cd 1a 3c	. . <
	ld de,00f3dh		;6656	11 3d 0f	. = .
	call 03c38h		;6659	cd 38 3c	. 8 <
	ld bc,l0f23h		;665c	01 23 0f	. # .
	ld de,00003h		;665f	11 03 00	. . .
	ld hl,00002h		;6662	21 02 00	! . .
	call 03c44h		;6665	cd 44 3c	. D <
	call 00000h		;6668	cd 00 00	. . .
	ld (l0f40h),hl		;666b	22 40 0f	" @ .
	ld bc,l0f23h		;666e	01 23 0f	. # .
	ld de,00005h		;6671	11 05 00	. . .
l6674h:
	ld hl,00002h		;6674	21 02 00	! . .
l6677h:
	defb 0cdh		;6677	cd		.

; BLOCK 'baslib_banner' (start 0x6678 end 0x66ab)
baslib_banner_start:
	defb 05bh		;6678	5b		[
	defb 05bh		;6679	5b		[
	defb 05bh		;667a	5b		[
	defb 05bh		;667b	5b		[
	defb 020h		;667c	20		 
	defb 042h		;667d	42		B
	defb 041h		;667e	41		A
	defb 053h		;667f	53		S
	defb 04ch		;6680	4c		L
	defb 049h		;6681	49		I
	defb 042h		;6682	42		B
	defb 020h		;6683	20		 
	defb 023h		;6684	23		#
	defb 035h		;6685	35		5
	defb 030h		;6686	30		0
	defb 030h		;6687	30		0
	defb 032h		;6688	32		2
	defb 030h		;6689	30		0
	defb 033h		;668a	33		3
	defb 020h		;668b	20		 
	defb 035h		;668c	35		5
	defb 02eh		;668d	2e		.
	defb 032h		;668e	32		2
	defb 020h		;668f	20		 
	defb 02dh		;6690	2d		-
	defb 020h		;6691	20		 
	defb 04fh		;6692	4f		O
	defb 057h		;6693	57		W
	defb 04eh		;6694	4e		N
	defb 045h		;6695	45		E
	defb 044h		;6696	44		D
	defb 020h		;6697	20		 
	defb 042h		;6698	42		B
	defb 059h		;6699	59		Y
	defb 020h		;669a	20		 
	defb 04dh		;669b	4d		M
	defb 049h		;669c	49		I
	defb 043h		;669d	43		C
	defb 052h		;669e	52		R
	defb 04fh		;669f	4f		O
	defb 053h		;66a0	53		S
	defb 04fh		;66a1	4f		O
	defb 046h		;66a2	46		F
	defb 054h		;66a3	54		T
	defb 02ch		;66a4	2c		,
	defb 020h		;66a5	20		 
	defb 031h		;66a6	31		1
	defb 039h		;66a7	39		9
	defb 037h		;66a8	37		7
	defb 039h		;66a9	39		9
	defb 020h		;66aa	20		 
	xor a			;66ab	af		.
	inc a			;66ac	3c		<
	jp l66bdh		;66ad	c3 bd 66	. . f
l66b0h:
	xor a			;66b0	af		.
	jp l66bdh		;66b1	c3 bd 66	. . f
l66b4h:
	ld b,(hl)		;66b4	46		F
l66b5h:
	rrca			;66b5	0f		.
	push hl			;66b6	e5		.
l66b7h:
	ld hl,00003h		;66b7	21 03 00	! . .
l66bah:
	call 03c92h		;66ba	cd 92 3c	. . <
l66bdh:
	ld b,h			;66bd	44		D
	ld c,l			;66be	4d		M
	ld hl,(00006h)		;66bf	2a 06 00	* . .
	ld sp,hl		;66c2	f9		.
	push bc			;66c3	c5		.
	ld de,0ff00h		;66c4	11 00 ff	. . .
	add hl,de		;66c7	19		.
	ld (l76f9h),hl		;66c8	22 f9 76	" . v
	ld hl,(l7a36h)		;66cb	2a 36 7a	* 6 z
	inc hl			;66ce	23		#
	inc hl			;66cf	23		#
	ld (l76f5h+2),hl	;66d0	22 f7 76	" . v
	jp l683fh		;66d3	c3 3f 68	. ? h
sub_66d6h:
	ld a,0c3h		;66d6	3e c3		> .
	ld (l66b4h),a		;66d8	32 b4 66	2 . f
	ld (l66b7h),a		;66db	32 b7 66	2 . f
	ld hl,(00001h)		;66de	2a 01 00	* . .
	ld de,00004h		;66e1	11 04 00	. . .
	add hl,de		;66e4	19		.
	ld e,(hl)		;66e5	5e		^
	inc hl			;66e6	23		#
	ld d,(hl)		;66e7	56		V
	ex de,hl		;66e8	eb		.
	ld (l66b5h),hl		;66e9	22 b5 66	" . f
	ex de,hl		;66ec	eb		.
	inc hl			;66ed	23		#
	inc hl			;66ee	23		#
	ld e,(hl)		;66ef	5e		^
	inc hl			;66f0	23		#
	ld d,(hl)		;66f1	56		V
	ex de,hl		;66f2	eb		.
	ld (l66b7h+1),hl	;66f3	22 b8 66	" . f
; BDOS 12: get version number
	ld c,00ch		;66f6	0e 0c		. .
	call BDOS		;66f8	cd 05 00	. . .
	ld (l66bah),a		;66fb	32 ba 66	2 . f
	or a			;66fe	b7		.
	ld hl,l1514h		;66ff	21 14 15	! . .
	jp z,l6708h		;6702	ca 08 67	. . g
	ld hl,l2221h		;6705	21 21 22	! ! "
l6708h:
	ld (l66bah+1),hl	;6708	22 bb 66	" . f
	ld hl,l6839h		;670b	21 39 68	! 9 h
	ld (l6836h),hl		;670e	22 36 68	" 6 h
	ld (hl),001h		;6711	36 01		6 .
	inc hl			;6713	23		#
	ld (hl),050h		;6714	36 50		6 P
	ld a,084h		;6716	3e 84		> .
	ld (l683ch+1),a		;6718	32 3d 68	2 = h
	ld a,001h		;671b	3e 01		> .
	ld (l683ch),a		;671d	32 3c 68	2 < h
	ld a,0ffh		;6720	3e ff		> .
	ld (l6839h+2),a		;6722	32 3b 68	2 ; h
	ret			;6725	c9		.
	push bc			;6726	c5		.
	push de			;6727	d5		.
	push hl			;6728	e5		.
	call l66b4h		;6729	cd b4 66	. . f
	or a			;672c	b7		.
	jp l674dh		;672d	c3 4d 67	. M g
l6730h:
	push bc			;6730	c5		.
	push de			;6731	d5		.
	push hl			;6732	e5		.
	call l66b7h		;6733	cd b7 66	. . f
	jp l674dh		;6736	c3 4d 67	. M g
sub_6739h:
	push bc			;6739	c5		.
	ld bc,0ff02h		;673a	01 02 ff	. . .
	jp l6744h		;673d	c3 44 67	. D g
sub_6740h:
	push bc			;6740	c5		.
; BDOS 5: list output (C is the low byte of BC)
	ld bc,0ff05h		;6741	01 05 ff	. . .
l6744h:
	push de			;6744	d5		.
	push hl			;6745	e5		.
	push af			;6746	f5		.
	and b			;6747	a0		.
	ld e,a			;6748	5f		_
	call BDOS		;6749	cd 05 00	. . .
	pop af			;674c	f1		.
l674dh:
	pop hl			;674d	e1		.
	pop de			;674e	d1		.
	pop bc			;674f	c1		.
	ret			;6750	c9		.
l6751h:
	jp 00000h		;6751	c3 00 00	. . .
sub_6754h:
	call sub_6c17h		;6754	cd 17 6c	. . l
	call sub_87ebh		;6757	cd eb 87	. . .
	jp c,l6768h		;675a	da 68 67	. h g
	ld hl,l8551h		;675d	21 51 85	! Q .
	ld (hl),043h		;6760	36 43		6 C
	inc hl			;6762	23		#
	ld (hl),04fh		;6763	36 4f		6 O
	inc hl			;6765	23		#
	ld (hl),04dh		;6766	36 4d		6 M
l6768h:
	ld hl,0005ch		;6768	21 5c 00	! \ .
	ld a,021h		;676b	3e 21		> !
	call sub_9296h		;676d	cd 96 92	. . .
	ld de,l8548h		;6770	11 48 85	. H .
	ld hl,0005ch		;6773	21 5c 00	! \ .
	ld a,00ch		;6776	3e 0c		> .
	call sub_9177h		;6778	cd 77 91	. w .
	call sub_8aech		;677b	cd ec 8a	. . .
	ld de,l84b8h		;677e	11 b8 84	. . .
; BDOS 26: set DMA address
	ld c,01ah		;6781	0e 1a		. .
	call BDOS		;6783	cd 05 00	. . .
	ld de,0005ch		;6786	11 5c 00	. \ .
; BDOS 15: open file
	ld c,00fh		;6789	0e 0f		. .
	call BDOS		;678b	cd 05 00	. . .
	inc a			;678e	3c		<
	jp z,08e9fh		;678f	ca 9f 8e	. . .
	ld hl,00000h		;6792	21 00 00	! . .
	add hl,sp		;6795	39		9
	dec h			;6796	25		%
	ld l,000h		;6797	2e 00		. .
	ld de,l67bah		;6799	11 ba 67	. . g
	ld a,041h		;679c	3e 41		> A
	call sub_9177h		;679e	cd 77 91	. w .
	ld l,000h		;67a1	2e 00		. .
	push hl			;67a3	e5		.
	ld de,l67b6h		;67a4	11 b6 67	. . g
l67a7h:
	ld a,(de)		;67a7	1a		.
	or a			;67a8	b7		.
	jp z,l67b2h		;67a9	ca b2 67	. . g
	ld l,a			;67ac	6f		o
	ld (hl),h		;67ad	74		t
	inc de			;67ae	13		.
	jp l67a7h		;67af	c3 a7 67	. . g
l67b2h:
	ld hl,cpm_entry		;67b2	21 00 01	! . .
	ret			;67b5	c9		.
l67b6h:
	rra			;67b6	1f		.
	inc hl			;67b7	23		#
	ld h,000h		;67b8	26 00		& .
l67bah:
	ld de,00000h		;67ba	11 00 00	. . .
	push de			;67bd	d5		.
	ld de,cpm_entry		;67be	11 00 01	. . .
	push de			;67c1	d5		.
	ex de,hl		;67c2	eb		.
	push de			;67c3	d5		.
; BDOS 26: set DMA address
	ld c,01ah		;67c4	0e 1a		. .
	call BDOS		;67c6	cd 05 00	. . .
	ld de,0005ch		;67c9	11 5c 00	. \ .
; BDOS 20: write sequential
	ld c,014h		;67cc	0e 14		. .
	call BDOS		;67ce	cd 05 00	. . .
	pop de			;67d1	d1		.
	or a			;67d2	b7		.
	ret nz			;67d3	c0		.
	ld hl,00080h		;67d4	21 80 00	! . .
	add hl,de		;67d7	19		.
	ld a,000h		;67d8	3e 00		> .
	cp h			;67da	bc		.
	jp nz,00008h		;67db	c2 08 00	. . .
	ld de,0002fh		;67de	11 2f 00	. / .
; BDOS 9: print string
	ld c,009h		;67e1	0e 09		. .
	call BDOS		;67e3	cd 05 00	. . .
	jp 00000h		;67e6	c3 00 00	. . .
	ld hl,(0554fh)		;67e9	2a 4f 55	* O U
	ld d,h			;67ec	54		T
	jr nz,$+81		;67ed	20 4f		  O
	ld b,(hl)		;67ef	46		F
	jr nz,l683fh		;67f0	20 4d		  M
	ld b,l			;67f2	45		E
	ld c,l			;67f3	4d		M
	ld c,a			;67f4	4f		O
	ld d,d			;67f5	52		R
	ld e,c			;67f6	59		Y
	ld hl,(l0a0dh)		;67f7	2a 0d 0a	* . .
	inc h			;67fa	24		$
l67fbh:
	add hl,bc		;67fb	09		.
	nop			;67fc	00		.
l67fdh:
	ld hl,(l0f1fh+2)	;67fd	2a 21 0f	* ! .
l6800h:
	add hl,de		;6800	19		.
	ex de,hl		;6801	eb		.
l6802h:
	ld bc,l0f1ch		;6802	01 1c 0f	. . .
; Four-byte random state in a writable part of the linked runtime
random_seed_state:
	ld hl,000ffh		;6805	21 ff 00	! . .
	call 03d36h		;6808	cd 36 3d	. 6 =
	call 00000h		;680b	cd 00 00	. . .
l680eh:
	call 00000h		;680e	cd 00 00	. . .
	ld (00f50h),hl		;6811	22 50 0f	" P .
l6814h:
	ld de,l0f1ch		;6814	11 1c 0f	. . .
l6817h:
	ld hl,s_terminal_pro_men	;6817	21 2e 60	! . `
	call 03dc2h		;681a	cd c2 3d	. . =
	ld (l0f1fh+2),hl	;681d	22 21 0f	" ! .
	ld hl,(l0f1fh+2)	;6820	2a 21 0f	* ! .
	ld a,h			;6823	7c		|
l6824h:
	add a,a			;6824	87		.
	jp c,l3e1bh		;6825	da 1b 3e	. . >
l6828h:
	or l			;6828	b5		.
	sub 001h		;6829	d6 01		. .
	ccf			;682b	3f		?
l682ch:
	sbc a,a			;682c	9f		.
	ld h,a			;682d	67		g
	ld l,a			;682e	6f		o
	ex de,hl		;682f	eb		.
	ld hl,(l0f4ch+2)	;6830	2a 4e 0f	* N .
	ld a,h			;6833	7c		|
l6834h:
	or d			;6834	b2		.
l6835h:
	ld h,a			;6835	67		g
l6836h:
	ld a,l			;6836	7d		}
	or e			;6837	b3		.
	ld l,a			;6838	6f		o
l6839h:
	ld (l0f4ch+2),hl	;6839	22 4e 0f	" N .
l683ch:
	ld hl,(l0f1fh+2)	;683c	2a 21 0f	* ! .
l683fh:
	ld hl,00000h		;683f	21 00 00	! . .
	add hl,sp		;6842	39		9
	ld (l6802h+1),hl	;6843	22 03 68	" . h
	ld hl,(l100ch)		;6846	2a 0c 10	* . .
	ex de,hl		;6849	eb		.
	ld hl,(l1006h)		;684a	2a 06 10	* . .
	or a			;684d	b7		.
	jp z,l6857h		;684e	ca 57 68	. W h
	ex de,hl		;6851	eb		.
	ld hl,00007h		;6852	21 07 00	! . .
	add hl,de		;6855	19		.
	ex de,hl		;6856	eb		.
l6857h:
	ld (hl),000h		;6857	36 00		6 .
	inc hl			;6859	23		#
	ld a,l			;685a	7d		}
	cp e			;685b	bb		.
	jp nz,l6857h		;685c	c2 57 68	. W h
	ld a,h			;685f	7c		|
	cp d			;6860	ba		.
	jp nz,l6857h		;6861	c2 57 68	. W h
	ld de,00036h		;6864	11 36 00	. 6 .
	ld hl,06809h		;6867	21 09 68	! . h
l686ah:
	ld (hl),000h		;686a	36 00		6 .
	inc hl			;686c	23		#
	dec de			;686d	1b		.
	ld a,d			;686e	7a		z
	or e			;686f	b3		.
	jp nz,l686ah		;6870	c2 6a 68	. j h
	ld hl,(l100ah)		;6873	2a 0a 10	* . .
	ld a,h			;6876	7c		|
	or l			;6877	b5		.
	jp z,l688bh		;6878	ca 8b 68	. . h
	ld a,00ah		;687b	3e 0a		> .
	ld de,068d8h		;687d	11 d8 68	. . h
l6880h:
	ld (hl),0c3h		;6880	36 c3		6 .
	inc hl			;6882	23		#
	ld (hl),e		;6883	73		s
	inc hl			;6884	23		#
	ld (hl),d		;6885	72		r
	inc hl			;6886	23		#
	dec a			;6887	3d		=
	jp nz,l6880h		;6888	c2 80 68	. . h
l688bh:
	ld a,0dbh		;688b	3e db		> .
	ld (l67fdh),a		;688d	32 fd 67	2 . g
	ld a,0d3h		;6890	3e d3		> .
	ld (l6800h),a		;6892	32 00 68	2 . h
	ld a,0c9h		;6895	3e c9		> .
	ld (l67fdh+2),a		;6897	32 ff 67	2 . g
	ld (l6802h),a		;689a	32 02 68	2 . h
	ld (random_seed_state),hl	;689d	22 05 68	" . h
	ld hl,l6751h		;68a0	21 51 67	! Q g
	ld (l680eh+2),hl	;68a3	22 10 68	" . h
	call sub_66d6h		;68a6	cd d6 66	. . f
	jp l79f1h		;68a9	c3 f1 79	. . y
l68ach:
	call sub_7a46h		;68ac	cd 46 7a	. F z
	dec c			;68af	0d		.
	ld a,(bc)		;68b0	0a		.
	ld d,e			;68b1	53		S
	ld d,h			;68b2	54		T
	ld c,a			;68b3	4f		O
	ret nc			;68b4	d0		.
l68b5h:
	call sub_6b84h		;68b5	cd 84 6b	. . k
	jp program_end		;68b8	c3 bb 68	. . h
; Runtime entry: terminate the compiled BASIC program
program_end:
	call sub_6c0dh		;68bb	cd 0d 6c	. . l
	ld hl,(l680eh+2)	;68be	2a 10 68	* . h
	jp (hl)			;68c1	e9		.
l68c2h:
	jp (hl)			;68c2	e9		.
	ld l,003h		;68c3	2e 03		. .
	ld bc,00d2eh		;68c5	01 2e 0d	. . .
	ld bc,l092eh		;68c8	01 2e 09	. . .
	ld bc,l142eh		;68cb	01 2e 14	. . .
	ld bc,l0e2eh		;68ce	01 2e 0e	. . .
	ld bc,0102eh		;68d1	01 2e 10	. . .
	ld bc,l062eh		;68d4	01 2e 06	. . .
	ld bc,l052eh		;68d7	01 2e 05	. . .
	ld bc,0042eh		;68da	01 2e 04	. . .
	ld bc,0072eh		;68dd	01 2e 07	. . .
	ld bc,l022eh		;68e0	01 2e 02	. . .
l68e3h:
	call sub_78e1h		;68e3	cd e1 78	. . x
	ex de,hl		;68e6	eb		.
	ld hl,(0681eh)		;68e7	2a 1e 68	* . h
	ld a,h			;68ea	7c		|
	or l			;68eb	b5		.
	jp nz,l68c2h		;68ec	c2 c2 68	. . h
	ld a,(0681bh)		;68ef	3a 1b 68	: . h
	and a			;68f2	a7		.
	jp nz,l692bh		;68f3	c2 2b 69	. + i
	ld hl,(l6817h+2)	;68f6	2a 19 68	* . h
	ld a,h			;68f9	7c		|
	or l			;68fa	b5		.
	jp z,l692bh		;68fb	ca 2b 69	. + i
	push de			;68fe	d5		.
	call 06b10h		;68ff	cd 10 6b	. . k
	ex de,hl		;6902	eb		.
	ld hl,(l1006h)		;6903	2a 06 10	* . .
	ld bc,00003h		;6906	01 03 00	. . .
	add hl,bc		;6909	09		.
	ld (hl),e		;690a	73		s
	inc hl			;690b	23		#
	ld (hl),d		;690c	72		r
	pop de			;690d	d1		.
	ld hl,(l1006h)		;690e	2a 06 10	* . .
	ld bc,00001h		;6911	01 01 00	. . .
	add hl,bc		;6914	09		.
	ld a,e			;6915	7b		{
	ld (hl),a		;6916	77		w
	inc hl			;6917	23		#
	ld (hl),000h		;6918	36 00		6 .
	pop hl			;691a	e1		.
	ld (0681ch),hl		;691b	22 1c 68	" . h
	ld hl,(l6802h+1)	;691e	2a 03 68	* . h
	ld sp,hl		;6921	f9		.
	ld hl,(l6817h+2)	;6922	2a 19 68	* . h
	ld a,001h		;6925	3e 01		> .
	ld (0681bh),a		;6927	32 1b 68	2 . h
	jp (hl)			;692a	e9		.
l692bh:
	call sub_6c0dh		;692b	cd 0d 6c	. . l
	call sub_7a46h		;692e	cd 46 7a	. F z
	rlca			;6931	07		.
	ld b,l			;6932	45		E
	ld (hl),d		;6933	72		r
	ld (hl),d		;6934	72		r
	ld l,a			;6935	6f		o
	ld (hl),d		;6936	72		r
	jr nz,$+47		;6937	20 2d		  -
	and b			;6939	a0		.
	ld hl,l6958h		;693a	21 58 69	! X i
l693dh:
	ld a,(hl)		;693d	7e		~
	inc a			;693e	3c		<
	jp z,l6951h		;693f	ca 51 69	. Q i
	dec a			;6942	3d		=
	cp e			;6943	bb		.
	jp z,l6951h		;6944	ca 51 69	. Q i
	inc hl			;6947	23		#
l6948h:
	ld a,(hl)		;6948	7e		~
	and a			;6949	a7		.
	inc hl			;694a	23		#
	jp p,l6948h		;694b	f2 48 69	. H i
	jp l693dh		;694e	c3 3d 69	. = i
l6951h:
	inc hl			;6951	23		#
	call sub_7a4ch		;6952	cd 4c 7a	. L z
	jp l68b5h		;6955	c3 b5 68	. . h
l6958h:
	ld (bc),a		;6958	02		.
	ld d,e			;6959	53		S
	ld a,c			;695a	79		y
	ld l,(hl)		;695b	6e		n
	ld (hl),h		;695c	74		t
	ld h,c			;695d	61		a
	ld a,b			;695e	78		x
	jr nz,l69a6h		;695f	20 45		  E
	ld (hl),d		;6961	72		r
	ld (hl),d		;6962	72		r
	ld l,a			;6963	6f		o
	ld (hl),d		;6964	72		r
	jr nz,l69d0h		;6965	20 69		  i
	ld l,(hl)		;6967	6e		n
	jr nz,$+70		;6968	20 44		  D
	ld b,c			;696a	41		A
	ld d,h			;696b	54		T
	pop bc			;696c	c1		.
	inc bc			;696d	03		.
	ld d,d			;696e	52		R
	ld b,l			;696f	45		E
	ld d,h			;6970	54		T
	ld d,l			;6971	55		U
	ld d,d			;6972	52		R
	ld c,(hl)		;6973	4e		N
	jr nz,$+121		;6974	20 77		  w
	ld l,c			;6976	69		i
	ld (hl),h		;6977	74		t
	ld l,b			;6978	68		h
	ld l,a			;6979	6f		o
	ld (hl),l		;697a	75		u
	ld (hl),h		;697b	74		t
	jr nz,l69c5h		;697c	20 47		  G
	ld c,a			;697e	4f		O
	ld d,e			;697f	53		S
	ld d,l			;6980	55		U
	jp nz,l540dh		;6981	c2 0d 54	. . T
	ld a,c			;6984	79		y
	ld (hl),b		;6985	70		p
	ld h,l			;6986	65		e
	jr nz,l69d6h		;6987	20 4d		  M
	ld l,c			;6989	69		i
	ld (hl),e		;698a	73		s
	ld l,l			;698b	6d		m
	ld h,c			;698c	61		a
	ld (hl),h		;698d	74		t
	ld h,e			;698e	63		c
	ret pe			;698f	e8		.
	inc b			;6990	04		.
	ld c,a			;6991	4f		O
	ld (hl),l		;6992	75		u
	ld (hl),h		;6993	74		t
	jr nz,l6a05h		;6994	20 6f		  o
	ld h,(hl)		;6996	66		f
	jr nz,l69ddh		;6997	20 44		  D
	ld h,c			;6999	61		a
	ld (hl),h		;699a	74		t
	pop hl			;699b	e1		.
	dec b			;699c	05		.
	ld c,c			;699d	49		I
	ld l,h			;699e	6c		l
	ld l,h			;699f	6c		l
	ld h,l			;69a0	65		e
	ld h,a			;69a1	67		g
	ld h,c			;69a2	61		a
	ld l,h			;69a3	6c		l
	jr nz,l69ech		;69a4	20 46		  F
l69a6h:
	ld (hl),l		;69a6	75		u
	ld l,(hl)		;69a7	6e		n
	ld h,e			;69a8	63		c
	ld (hl),h		;69a9	74		t
	ld l,c			;69aa	69		i
	ld l,a			;69ab	6f		o
	ld l,(hl)		;69ac	6e		n
	jr nz,$+69		;69ad	20 43		  C
	ld h,c			;69af	61		a
	ld l,h			;69b0	6c		l
	call pe,sub_4f06h	;69b1	ec 06 4f	. . O
	halt			;69b4	76		v
	ld h,l			;69b5	65		e
	ld (hl),d		;69b6	72		r
	ld h,(hl)		;69b7	66		f
	ld l,h			;69b8	6c		l
	ld l,a			;69b9	6f		o
	rst 30h			;69ba	f7		.
	rlca			;69bb	07		.
	ld c,a			;69bc	4f		O
	ld (hl),l		;69bd	75		u
	ld (hl),h		;69be	74		t
	jr nz,$+113		;69bf	20 6f		  o
	ld h,(hl)		;69c1	66		f
	jr nz,l6a11h		;69c2	20 4d		  M
	ld h,l			;69c4	65		e
l69c5h:
	ld l,l			;69c5	6d		m
	ld l,a			;69c6	6f		o
	ld (hl),d		;69c7	72		r
	ld sp,hl		;69c8	f9		.
	add hl,bc		;69c9	09		.
	ld d,e			;69ca	53		S
	ld (hl),l		;69cb	75		u
	ld h,d			;69cc	62		b
	ld (hl),e		;69cd	73		s
	ld h,e			;69ce	63		c
	ld (hl),d		;69cf	72		r
l69d0h:
	ld l,c			;69d0	69		i
	ld (hl),b		;69d1	70		p
	ld (hl),h		;69d2	74		t
	jr nz,l6a24h		;69d3	20 4f		  O
	ld (hl),l		;69d5	75		u
l69d6h:
	ld (hl),h		;69d6	74		t
	jr nz,l6a48h		;69d7	20 6f		  o
	ld h,(hl)		;69d9	66		f
	jr nz,l6a2eh		;69da	20 52		  R
	ld h,c			;69dc	61		a
l69ddh:
	ld l,(hl)		;69dd	6e		n
	ld h,a			;69de	67		g
	push hl			;69df	e5		.
	dec bc			;69e0	0b		.
	ld b,h			;69e1	44		D
	ld l,c			;69e2	69		i
	halt			;69e3	76		v
	ld l,c			;69e4	69		i
	ld (hl),e		;69e5	73		s
	ld l,c			;69e6	69		i
	ld l,a			;69e7	6f		o
	ld l,(hl)		;69e8	6e		n
	jr nz,l6a2dh		;69e9	20 42		  B
	ld a,c			;69eb	79		y
l69ech:
	jr nz,l6a48h		;69ec	20 5a		  Z
	ld h,l			;69ee	65		e
	ld (hl),d		;69ef	72		r
	rst 28h			;69f0	ef		.
	ld c,04fh		;69f1	0e 4f		. O
	ld (hl),l		;69f3	75		u
	ld (hl),h		;69f4	74		t
	jr nz,l6a66h		;69f5	20 6f		  o
	ld h,(hl)		;69f7	66		f
	jr nz,l6a4dh		;69f8	20 53		  S
	ld (hl),h		;69fa	74		t
	ld (hl),d		;69fb	72		r
	ld l,c			;69fc	69		i
	ld l,(hl)		;69fd	6e		n
	ld h,a			;69fe	67		g
	jr nz,$+85		;69ff	20 53		  S
	ld (hl),b		;6a01	70		p
	ld h,c			;6a02	61		a
	ld h,e			;6a03	63		c
	push hl			;6a04	e5		.
l6a05h:
	djnz l6a5ah		;6a05	10 53		. S
	ld (hl),h		;6a07	74		t
	ld (hl),d		;6a08	72		r
	ld l,c			;6a09	69		i
	ld l,(hl)		;6a0a	6e		n
	ld h,a			;6a0b	67		g
	jr nz,$+72		;6a0c	20 46		  F
	ld l,a			;6a0e	6f		o
	ld (hl),d		;6a0f	72		r
	ld l,l			;6a10	6d		m
l6a11h:
	ld (hl),l		;6a11	75		u
	ld l,h			;6a12	6c		l
	ld h,c			;6a13	61		a
	jr nz,l6a6ah		;6a14	20 54		  T
	ld l,a			;6a16	6f		o
	ld l,a			;6a17	6f		o
	jr nz,$+69		;6a18	20 43		  C
	ld l,a			;6a1a	6f		o
	ld l,l			;6a1b	6d		m
	ld (hl),b		;6a1c	70		p
	ld l,h			;6a1d	6c		l
	ld h,l			;6a1e	65		e
	ret m			;6a1f	f8		.
	inc d			;6a20	14		.
	ld d,d			;6a21	52		R
	ld b,l			;6a22	45		E
	ld d,e			;6a23	53		S
l6a24h:
	ld d,l			;6a24	55		U
	ld c,l			;6a25	4d		M
	ld b,l			;6a26	45		E
	jr nz,l6aa0h		;6a27	20 77		  w
	ld l,c			;6a29	69		i
	ld (hl),h		;6a2a	74		t
	ld l,b			;6a2b	68		h
	ld l,a			;6a2c	6f		o
l6a2dh:
	ld (hl),l		;6a2d	75		u
l6a2eh:
	ld (hl),h		;6a2e	74		t
	jr nz,l6a76h		;6a2f	20 45		  E
	ld (hl),d		;6a31	72		r
	ld (hl),d		;6a32	72		r
	ld l,a			;6a33	6f		o
	jp p,l4631h+1		;6a34	f2 32 46	. 2 F
	ld l,c			;6a37	69		i
	ld h,l			;6a38	65		e
	ld l,h			;6a39	6c		l
	ld h,h			;6a3a	64		d
	jr nz,l6a8ch		;6a3b	20 4f		  O
	halt			;6a3d	76		v
	ld h,l			;6a3e	65		e
	ld (hl),d		;6a3f	72		r
	ld h,(hl)		;6a40	66		f
	ld l,h			;6a41	6c		l
	ld l,a			;6a42	6f		o
	rst 30h			;6a43	f7		.
	inc sp			;6a44	33		3
	ld c,c			;6a45	49		I
	ld l,(hl)		;6a46	6e		n
	ld (hl),h		;6a47	74		t
l6a48h:
	ld h,l			;6a48	65		e
	ld (hl),d		;6a49	72		r
	ld l,(hl)		;6a4a	6e		n
	ld h,c			;6a4b	61		a
	ld l,h			;6a4c	6c		l
l6a4dh:
	jr nz,l6a94h		;6a4d	20 45		  E
	ld (hl),d		;6a4f	72		r
	ld (hl),d		;6a50	72		r
	ld l,a			;6a51	6f		o
	jp p,l4234h		;6a52	f2 34 42	. 4 B
	ld h,c			;6a55	61		a
	ld h,h			;6a56	64		d
	jr nz,l6a9fh		;6a57	20 46		  F
	ld l,c			;6a59	69		i
l6a5ah:
	ld l,h			;6a5a	6c		l
	ld h,l			;6a5b	65		e
	jr nz,l6aach		;6a5c	20 4e		  N
	ld (hl),l		;6a5e	75		u
	ld l,l			;6a5f	6d		m
	ld h,d			;6a60	62		b
	ld h,l			;6a61	65		e
	jp p,04635h		;6a62	f2 35 46	. 5 F
	ld l,c			;6a65	69		i
l6a66h:
	ld l,h			;6a66	6c		l
	ld h,l			;6a67	65		e
	jr nz,l6ab8h		;6a68	20 4e		  N
l6a6ah:
	ld l,a			;6a6a	6f		o
	ld (hl),h		;6a6b	74		t
	jr nz,l6ab4h		;6a6c	20 46		  F
	ld l,a			;6a6e	6f		o
	ld (hl),l		;6a6f	75		u
	ld l,(hl)		;6a70	6e		n
	call po,04236h		;6a71	e4 36 42	. 6 B
	ld h,c			;6a74	61		a
	ld h,h			;6a75	64		d
l6a76h:
	jr nz,l6abeh		;6a76	20 46		  F
	ld l,c			;6a78	69		i
	ld l,h			;6a79	6c		l
	ld h,l			;6a7a	65		e
	jr nz,l6acah		;6a7b	20 4d		  M
	ld l,a			;6a7d	6f		o
	ld h,h			;6a7e	64		d
	push hl			;6a7f	e5		.
	scf			;6a80	37		7
	ld b,(hl)		;6a81	46		F
	ld l,c			;6a82	69		i
	ld l,h			;6a83	6c		l
	ld h,l			;6a84	65		e
	jr nz,l6ac8h		;6a85	20 41		  A
	ld l,h			;6a87	6c		l
	ld (hl),d		;6a88	72		r
	ld h,l			;6a89	65		e
	ld h,c			;6a8a	61		a
	ld h,h			;6a8b	64		d
l6a8ch:
	ld a,c			;6a8c	79		y
	jr nz,l6adeh		;6a8d	20 4f		  O
	ld (hl),b		;6a8f	70		p
	ld h,l			;6a90	65		e
	xor 039h		;6a91	ee 39		. 9
	ld b,h			;6a93	44		D
l6a94h:
	ld l,c			;6a94	69		i
	ld (hl),e		;6a95	73		s
	ld l,e			;6a96	6b		k
	jr nz,l6ae2h		;6a97	20 49		  I
	cpl			;6a99	2f		/
	ld c,a			;6a9a	4f		O
	jr nz,l6ae2h		;6a9b	20 45		  E
	ld (hl),d		;6a9d	72		r
	ld (hl),d		;6a9e	72		r
l6a9fh:
	ld l,a			;6a9f	6f		o
l6aa0h:
	jp p,l463ah		;6aa0	f2 3a 46	. : F
	ld l,c			;6aa3	69		i
	ld l,h			;6aa4	6c		l
	ld h,l			;6aa5	65		e
	jr nz,l6ae9h		;6aa6	20 41		  A
	ld l,h			;6aa8	6c		l
	ld (hl),d		;6aa9	72		r
	ld h,l			;6aaa	65		e
	ld h,c			;6aab	61		a
l6aach:
	ld h,h			;6aac	64		d
	ld a,c			;6aad	79		y
	jr nz,l6af5h		;6aae	20 45		  E
	ld a,b			;6ab0	78		x
	ld l,c			;6ab1	69		i
	ld (hl),e		;6ab2	73		s
	ld (hl),h		;6ab3	74		t
l6ab4h:
	di			;6ab4	f3		.
	dec a			;6ab5	3d		=
	ld b,h			;6ab6	44		D
	ld l,c			;6ab7	69		i
l6ab8h:
	ld (hl),e		;6ab8	73		s
	ld l,e			;6ab9	6b		k
	jr nz,l6b02h		;6aba	20 46		  F
	ld (hl),l		;6abc	75		u
	ld l,h			;6abd	6c		l
l6abeh:
	call pe,sub_493eh	;6abe	ec 3e 49	. > I
	ld l,(hl)		;6ac1	6e		n
	ld (hl),b		;6ac2	70		p
	ld (hl),l		;6ac3	75		u
	ld (hl),h		;6ac4	74		t
	jr nz,l6b17h		;6ac5	20 50		  P
	ld h,c			;6ac7	61		a
l6ac8h:
	ld (hl),e		;6ac8	73		s
	ld (hl),h		;6ac9	74		t
l6acah:
	jr nz,l6b11h		;6aca	20 45		  E
	ld l,(hl)		;6acc	6e		n
	call po,0423fh		;6acd	e4 3f 42	. ? B
	ld h,c			;6ad0	61		a
	ld h,h			;6ad1	64		d
	jr nz,$+84		;6ad2	20 52		  R
	ld h,l			;6ad4	65		e
	ld h,e			;6ad5	63		c
	ld l,a			;6ad6	6f		o
	ld (hl),d		;6ad7	72		r
	ld h,h			;6ad8	64		d
	jr nz,l6b29h		;6ad9	20 4e		  N
	ld (hl),l		;6adb	75		u
	ld l,l			;6adc	6d		m
	ld h,d			;6add	62		b
l6adeh:
	ld h,l			;6ade	65		e
	jp p,04240h		;6adf	f2 40 42	. @ B
l6ae2h:
	ld h,c			;6ae2	61		a
	ld h,h			;6ae3	64		d
	jr nz,$+72		;6ae4	20 46		  F
	ld l,c			;6ae6	69		i
	ld l,h			;6ae7	6c		l
	ld h,l			;6ae8	65		e
l6ae9h:
	jr nz,l6b39h		;6ae9	20 4e		  N
	ld h,c			;6aeb	61		a
	ld l,l			;6aec	6d		m
	push hl			;6aed	e5		.
	ld b,e			;6aee	43		C
	ld d,h			;6aef	54		T
	ld l,a			;6af0	6f		o
	ld l,a			;6af1	6f		o
	jr nz,l6b41h		;6af2	20 4d		  M
	ld h,c			;6af4	61		a
l6af5h:
	ld l,(hl)		;6af5	6e		n
	ld a,c			;6af6	79		y
	jr nz,$+72		;6af7	20 46		  F
	ld l,c			;6af9	69		i
	ld l,h			;6afa	6c		l
	ld h,l			;6afb	65		e
	di			;6afc	f3		.
	rst 38h			;6afd	ff		.
	ld d,l			;6afe	55		U
	ld l,(hl)		;6aff	6e		n
	ld (hl),b		;6b00	70		p
	ld (hl),d		;6b01	72		r
l6b02h:
	ld l,c			;6b02	69		i
	ld l,(hl)		;6b03	6e		n
	ld (hl),h		;6b04	74		t
	ld h,c			;6b05	61		a
	ld h,d			;6b06	62		b
	ld l,h			;6b07	6c		l
	ld h,l			;6b08	65		e
	jr nz,l6b50h		;6b09	20 45		  E
	ld (hl),d		;6b0b	72		r
	ld (hl),d		;6b0c	72		r
	ld l,a			;6b0d	6f		o
	jp p,0c500h		;6b0e	f2 00 c5	. . .
l6b11h:
	ld hl,00006h		;6b11	21 06 00	! . .
	add hl,sp		;6b14	39		9
	ld c,(hl)		;6b15	4e		N
	inc hl			;6b16	23		#
l6b17h:
	ld b,(hl)		;6b17	46		F
	ld hl,(startup_record_start)	;6b18	2a 00 10	* . .
	ld de,00000h		;6b1b	11 00 00	. . .
	push de			;6b1e	d5		.
l6b1fh:
	ld a,(hl)		;6b1f	7e		~
	sub c			;6b20	91		.
	inc hl			;6b21	23		#
	ld a,(hl)		;6b22	7e		~
	sbc a,b			;6b23	98		.
	jp nc,l6b41h		;6b24	d2 41 6b	. A k
	ld a,(hl)		;6b27	7e		~
	dec hl			;6b28	2b		+
l6b29h:
	or (hl)			;6b29	b6		.
	jp z,l6b47h		;6b2a	ca 47 6b	. G k
	ld a,(hl)		;6b2d	7e		~
	sub e			;6b2e	93		.
	inc hl			;6b2f	23		#
	ld a,(hl)		;6b30	7e		~
	sbc a,d			;6b31	9a		.
	jp c,l6b41h		;6b32	da 41 6b	. A k
	dec hl			;6b35	2b		+
	ld e,(hl)		;6b36	5e		^
	inc hl			;6b37	23		#
	ld d,(hl)		;6b38	56		V
l6b39h:
	inc hl			;6b39	23		#
	pop af			;6b3a	f1		.
	push hl			;6b3b	e5		.
	inc hl			;6b3c	23		#
	inc hl			;6b3d	23		#
	jp l6b1fh		;6b3e	c3 1f 6b	. . k
l6b41h:
	inc hl			;6b41	23		#
	inc hl			;6b42	23		#
	inc hl			;6b43	23		#
	jp l6b1fh		;6b44	c3 1f 6b	. . k
l6b47h:
	pop hl			;6b47	e1		.
	ld a,h			;6b48	7c		|
	or l			;6b49	b5		.
	jp z,l6b53h		;6b4a	ca 53 6b	. S k
	ld a,(hl)		;6b4d	7e		~
	inc hl			;6b4e	23		#
	ld h,(hl)		;6b4f	66		f
l6b50h:
	ld l,a			;6b50	6f		o
	pop bc			;6b51	c1		.
	ret			;6b52	c9		.
l6b53h:
	ld hl,0ffffh		;6b53	21 ff ff	! . .
	ld de,l6b5bh		;6b56	11 5b 6b	. [ k
	pop bc			;6b59	c1		.
	ret			;6b5a	c9		.
l6b5bh:
	call sub_7a46h		;6b5b	cd 46 7a	. F z
	dec c			;6b5e	0d		.
	ld a,(bc)		;6b5f	0a		.
	ld c,c			;6b60	49		I
	ld l,(hl)		;6b61	6e		n
	ld (hl),h		;6b62	74		t
	ld h,l			;6b63	65		e
	ld (hl),d		;6b64	72		r
	ld l,(hl)		;6b65	6e		n
	ld h,c			;6b66	61		a
	ld l,h			;6b67	6c		l
	jr nz,$+71		;6b68	20 45		  E
	ld (hl),d		;6b6a	72		r
	ld (hl),d		;6b6b	72		r
	ld l,a			;6b6c	6f		o
	ld (hl),d		;6b6d	72		r
	jr nz,$+47		;6b6e	20 2d		  -
	jr nz,l6bc0h		;6b70	20 4e		  N
	ld l,a			;6b72	6f		o
	jr nz,$+78		;6b73	20 4c		  L
	ld l,c			;6b75	69		i
	ld l,(hl)		;6b76	6e		n
	ld h,l			;6b77	65		e
	jr nz,l6bc8h		;6b78	20 4e		  N
	ld (hl),l		;6b7a	75		u
	ld l,l			;6b7b	6d		m
	ld h,d			;6b7c	62		b
	ld h,l			;6b7d	65		e
	ld (hl),d		;6b7e	72		r
	dec c			;6b7f	0d		.
	adc a,d			;6b80	8a		.
	jp l6751h		;6b81	c3 51 67	. Q g
sub_6b84h:
	ld hl,(startup_record_start)	;6b84	2a 00 10	* . .
	ld a,(hl)		;6b87	7e		~
	inc hl			;6b88	23		#
	or (hl)			;6b89	b6		.
	jp z,l6befh		;6b8a	ca ef 6b	. . k
	call sub_7a46h		;6b8d	cd 46 7a	. F z
	jr nz,$+99		;6b90	20 61		  a
	ld (hl),h		;6b92	74		t
	jr nz,l6c01h		;6b93	20 6c		  l
	ld l,c			;6b95	69		i
	ld l,(hl)		;6b96	6e		n
	ld h,l			;6b97	65		e
	and b			;6b98	a0		.
	call 06b10h		;6b99	cd 10 6b	. . k
	call sub_6ba2h		;6b9c	cd a2 6b	. . k
	jp sub_6c0dh		;6b9f	c3 0d 6c	. . l
sub_6ba2h:
	ex de,hl		;6ba2	eb		.
	ld a,004h		;6ba3	3e 04		> .
l6ba5h:
	push af			;6ba5	f5		.
	call sub_6bd6h		;6ba6	cd d6 6b	. . k
	add hl,de		;6ba9	19		.
	inc a			;6baa	3c		<
	jp c,l6bbbh		;6bab	da bb 6b	. . k
	call sub_6bcfh		;6bae	cd cf 6b	. . k
	pop af			;6bb1	f1		.
	sub 001h		;6bb2	d6 01		. .
	jp nz,l6ba5h		;6bb4	c2 a5 6b	. . k
l6bb7h:
	push af			;6bb7	f5		.
	call sub_6bd6h		;6bb8	cd d6 6b	. . k
l6bbbh:
	add hl,de		;6bbb	19		.
	inc a			;6bbc	3c		<
	jp c,l6bbbh		;6bbd	da bb 6b	. . k
l6bc0h:
	add a,030h		;6bc0	c6 30		. 0
	call sub_90a2h		;6bc2	cd a2 90	. . .
	call sub_6bcfh		;6bc5	cd cf 6b	. . k
l6bc8h:
	pop af			;6bc8	f1		.
	sub 001h		;6bc9	d6 01		. .
	jp nc,l6bb7h		;6bcb	d2 b7 6b	. . k
	ret			;6bce	c9		.
sub_6bcfh:
	ld a,l			;6bcf	7d		}
	sub e			;6bd0	93		.
	ld e,a			;6bd1	5f		_
	ld a,h			;6bd2	7c		|
	sbc a,d			;6bd3	9a		.
	ld d,a			;6bd4	57		W
	ret			;6bd5	c9		.
sub_6bd6h:
	ld hl,l6be5h		;6bd6	21 e5 6b	! . k
	rlca			;6bd9	07		.
	call sub_9172h		;6bda	cd 72 91	. r .
	ld a,(hl)		;6bdd	7e		~
	inc hl			;6bde	23		#
	ld h,(hl)		;6bdf	66		f
	ld l,a			;6be0	6f		o
	ex de,hl		;6be1	eb		.
	ld a,0ffh		;6be2	3e ff		> .
	ret			;6be4	c9		.
l6be5h:
	rst 38h			;6be5	ff		.
	rst 38h			;6be6	ff		.
	or 0ffh			;6be7	f6 ff		. .
l6be9h:
	sbc a,h			;6be9	9c		.
	rst 38h			;6bea	ff		.
	jr l6be9h		;6beb	18 fc		. .
	ret p			;6bed	f0		.
	ret c			;6bee	d8		.
l6befh:
	call sub_7a46h		;6bef	cd 46 7a	. F z
	jr nz,$+99		;6bf2	20 61		  a
	ld (hl),h		;6bf4	74		t
	jr nz,l6c58h		;6bf5	20 61		  a
	ld h,h			;6bf7	64		d
	ld h,h			;6bf8	64		d
	ld (hl),d		;6bf9	72		r
	ld h,l			;6bfa	65		e
	ld (hl),e		;6bfb	73		s
	ld (hl),e		;6bfc	73		s
	and b			;6bfd	a0		.
	pop hl			;6bfe	e1		.
	ex (sp),hl		;6bff	e3		.
	ld a,h			;6c00	7c		|
l6c01h:
	call sub_7047h		;6c01	cd 47 70	. G p
	ld a,l			;6c04	7d		}
	call sub_7047h		;6c05	cd 47 70	. G p
	ex (sp),hl		;6c08	e3		.
	push hl			;6c09	e5		.
	jp sub_6c0dh		;6c0a	c3 0d 6c	. . l
sub_6c0dh:
	ld a,00dh		;6c0d	3e 0d		> .
	call sub_90a2h		;6c0f	cd a2 90	. . .
	ld a,00ah		;6c12	3e 0a		> .
	jp sub_90a2h		;6c14	c3 a2 90	. . .
sub_6c17h:
	push hl			;6c17	e5		.
	ld hl,00004h		;6c18	21 04 00	! . .
	add hl,sp		;6c1b	39		9
	ld (l67fbh),hl		;6c1c	22 fb 67	" . g
	pop hl			;6c1f	e1		.
	ret			;6c20	c9		.
sub_6c21h:
	pop de			;6c21	d1		.
	ld hl,(l67fbh)		;6c22	2a fb 67	* . g
	ld sp,hl		;6c25	f9		.
	ex de,hl		;6c26	eb		.
	jp (hl)			;6c27	e9		.
	nop			;6c28	00		.
l6c29h:
	nop			;6c29	00		.
	nop			;6c2a	00		.
	nop			;6c2b	00		.
	nop			;6c2c	00		.
l6c2dh:
	nop			;6c2d	00		.
	nop			;6c2e	00		.
	nop			;6c2f	00		.
	add a,b			;6c30	80		.
; Runtime random-number generator; updates the state above
random_float:
	push bc			;6c31	c5		.
	push de			;6c32	d5		.
	push hl			;6c33	e5		.
	add hl,hl		;6c34	29		)
	jp c,l6c7bh		;6c35	da 7b 6c	. { l
	ld a,h			;6c38	7c		|
	or l			;6c39	b5		.
	ld hl,(random_seed_state)	;6c3a	2a 05 68	* . h
	ex de,hl		;6c3d	eb		.
	ld hl,(random_seed_state+2)	;6c3e	2a 07 68	* . h
	jp z,l6c62h		;6c41	ca 62 6c	. b l
	push hl			;6c44	e5		.
	push de			;6c45	d5		.
	ex de,hl		;6c46	eb		.
	add hl,hl		;6c47	29		)
	ex de,hl		;6c48	eb		.
	add hl,hl		;6c49	29		)
	call c,sub_6c88h	;6c4a	dc 88 6c	. . l
	ex de,hl		;6c4d	eb		.
	add hl,hl		;6c4e	29		)
	pop bc			;6c4f	c1		.
	add hl,bc		;6c50	09		.
	ex de,hl		;6c51	eb		.
	add hl,hl		;6c52	29		)
	call c,sub_6c88h	;6c53	dc 88 6c	. . l
	pop bc			;6c56	c1		.
	add hl,bc		;6c57	09		.
l6c58h:
	call c,sub_6c88h	;6c58	dc 88 6c	. . l
	ld bc,00003h		;6c5b	01 03 00	. . .
	add hl,bc		;6c5e	09		.
	call c,sub_6c88h	;6c5f	dc 88 6c	. . l
l6c62h:
	ld (random_seed_state+2),hl	;6c62	22 07 68	" . h
	ex de,hl		;6c65	eb		.
	ld (random_seed_state),hl	;6c66	22 05 68	" . h
	ex de,hl		;6c69	eb		.
	ld b,000h		;6c6a	06 00		. .
	ld c,e			;6c6c	4b		K
	ex de,hl		;6c6d	eb		.
	ld hl,08080h		;6c6e	21 80 80	! . .
	ld (l9287h+1),hl	;6c71	22 88 92	" . .
	call sub_9b0eh		;6c74	cd 0e 9b	. . .
	pop hl			;6c77	e1		.
	pop de			;6c78	d1		.
	pop bc			;6c79	c1		.
	ret			;6c7a	c9		.
l6c7bh:
	ld e,l			;6c7b	5d		]
	jp l6c62h		;6c7c	c3 62 6c	. b l
	push hl			;6c7f	e5		.
	ld hl,00001h		;6c80	21 01 00	! . .
	call random_float	;6c83	cd 31 6c	. 1 l
	pop hl			;6c86	e1		.
	ret			;6c87	c9		.
sub_6c88h:
	inc e			;6c88	1c		.
	ret			;6c89	c9		.
l6c8ah:
	rst 28h			;6c8a	ef		.
sub_6c8bh:
	ex (sp),hl		;6c8b	e3		.
	ld a,(hl)		;6c8c	7e		~
	ld (l6c8ah),a		;6c8d	32 8a 6c	2 . l
	inc hl			;6c90	23		#
	ex (sp),hl		;6c91	e3		.
	push de			;6c92	d5		.
	ld a,(hl)		;6c93	7e		~
	inc hl			;6c94	23		#
	ld e,(hl)		;6c95	5e		^
	inc hl			;6c96	23		#
	ld d,(hl)		;6c97	56		V
	ex de,hl		;6c98	eb		.
	call sub_7a38h		;6c99	cd 38 7a	. 8 z
	ex de,hl		;6c9c	eb		.
	dec hl			;6c9d	2b		+
	dec hl			;6c9e	2b		+
	call sub_78d7h		;6c9f	cd d7 78	. . x
	pop de			;6ca2	d1		.
	call sub_8eb9h		;6ca3	cd b9 8e	. . .
	jp c,l68ach		;6ca6	da ac 68	. . h
	ld a,(l6cd1h)		;6ca9	3a d1 6c	: . l
	or a			;6cac	b7		.
	ret			;6cad	c9		.
sub_6caeh:
	call sub_6c17h		;6cae	cd 17 6c	. . l
	push bc			;6cb1	c5		.
	push de			;6cb2	d5		.
	push hl			;6cb3	e5		.
	ld hl,(l680eh)		;6cb4	2a 0e 68	* . h
	ld a,h			;6cb7	7c		|
	or l			;6cb8	b5		.
	jp nz,l6ccdh		;6cb9	c2 cd 6c	. . l
	ld hl,l6cd1h		;6cbc	21 d1 6c	! . l
	call sub_78b7h		;6cbf	cd b7 78	. . x
	call sub_78c6h		;6cc2	cd c6 78	. . x
	pop de			;6cc5	d1		.
	call sub_74deh		;6cc6	cd de 74	. . t
	ex de,hl		;6cc9	eb		.
	pop de			;6cca	d1		.
	pop bc			;6ccb	c1		.
	ret			;6ccc	c9		.
l6ccdh:
	ld hl,(l6828h)		;6ccd	2a 28 68	* ( h
	jp (hl)			;6cd0	e9		.
l6cd1h:
	call 042b9h		;6cd1	cd b9 42	. . B
	ld hl,s_instructions_treasure	;6cd4	21 fe 5b	! . [
	call 042bfh		;6cd7	cd bf 42	. . B
	call 042c2h		;6cda	cd c2 42	. . B
	ld hl,s_instructions_bonus_expires	;6cdd	21 e7 5b	! . [
	call 042c8h		;6ce0	cd c8 42	. . B
	call 042cbh		;6ce3	cd cb 42	. . B
	ld hl,l613eh		;6ce6	21 3e 61	! > a
	call 042d1h		;6ce9	cd d1 42	. . B
	call 042d4h		;6cec	cd d4 42	. . B
	ld hl,s_instructions_extra_lad	;6cef	21 b2 5b	! . [
	call 042dah		;6cf2	cd da 42	. . B
	call 042ddh		;6cf5	cd dd 42	. . B
	ld hl,s_instructions_gold	;6cf8	21 81 5b	! . [
	call 042e3h		;6cfb	cd e3 42	. . B
	call 042e6h		;6cfe	cd e6 42	. . B
	ld hl,s_instructions_statues	;6d01	21 41 5b	! A [
	call 042ech		;6d04	cd ec 42	. . B
	call 042efh		;6d07	cd ef 42	. . B
	ld hl,s_instructions_bonus_remainder	;6d0a	21 0f 5b	! . [
	call 042f5h		;6d0d	cd f5 42	. . B
	call 042f8h		;6d10	cd f8 42	. . B
	ld hl,s_pause_hint	;6d13	21 eb 5a	! . Z
	call 042feh		;6d16	cd fe 42	. . B
	call 04301h		;6d19	cd 01 43	. . C
	ld hl,l613eh		;6d1c	21 3e 61	! > a
	call 04307h		;6d1f	cd 07 43	. . C
	call 0430ah		;6d22	cd 0a 43	. . C
	ld hl,s_good_luck	;6d25	21 da 5a	! . Z
	call 04310h		;6d28	cd 10 43	. . C
	call 04313h		;6d2b	cd 13 43	. . C
	ld hl,l613eh		;6d2e	21 3e 61	! > a
	call 04319h		;6d31	cd 19 43	. . C
	call 0431ch		;6d34	cd 1c 43	. . C
	ld hl,l613eh		;6d37	21 3e 61	! > a
	call 04322h		;6d3a	cd 22 43	. " C
	call 04325h		;6d3d	cd 25 43	. % C
	ld hl,l613eh		;6d40	21 3e 61	! > a
	call 0432bh		;6d43	cd 2b 43	. + C
	call 0432eh		;6d46	cd 2e 43	. . C
	ld hl,s_type_return_for_menu	;6d49	21 b3 5a	! . Z
	call 0415eh		;6d4c	cd 5e 41	. ^ A
	ld de,00001h		;6d4f	11 01 00	. . .
	ld hl,000ffh		;6d52	21 ff 00	! . .
	call 00000h		;6d55	cd 00 00	. . .
	ld de,00f64h		;6d58	11 64 0f	. d .
	call 041cdh		;6d5b	cd cd 41	. . A
	ld hl,0000dh		;6d5e	21 0d 00	! . .
	call 041c7h		;6d61	cd c7 41	. . A
	ex de,hl		;6d64	eb		.
	ld hl,00f64h		;6d65	21 64 0f	! d .
	call 03da8h		;6d68	cd a8 3d	. . =
	ccf			;6d6b	3f		?
	ld b,e			;6d6c	43		C
	jp l3eafh		;6d6d	c3 af 3e	. . >
	ld hl,(score_word+2)	;6d70	2a 07 0f	* . .
	call 00000h		;6d73	cd 00 00	. . .
	dec b			;6d76	05		.
	nop			;6d77	00		.
	inc hl			;6d78	23		#
	ld (score_word+2),hl	;6d79	22 07 0f	" . .
	jp l40f8h		;6d7c	c3 f8 40	. . @
	ld hl,(l0f52h)		;6d7f	2a 52 0f	* R .
	ld (lads_word),hl	;6d82	22 67 0f	" g .
	ld hl,00001h		;6d85	21 01 00	! . .
	ld (level_word),hl	;6d88	22 69 0f	" i .
	ld hl,(00f54h)		;6d8b	2a 54 0f	* T .
	ld (score_word),hl	;6d8e	22 05 0f	" . .
	ld hl,00001h		;6d91	21 01 00	! . .
	ld (l0f6bh),hl		;6d94	22 6b 0f	" k .
	ld hl,00064h		;6d97	21 64 00	! d .
	ld (l0f6dh),hl		;6d9a	22 6d 0f	" m .
	ld hl,(00f50h)		;6d9d	2a 50 0f	* P .
	ld (l0f6fh),hl		;6da0	22 6f 0f	" o .
	ld hl,(score_word+2)	;6da3	2a 07 0f	* . .
	ld (l0f71h),hl		;6da6	22 71 0f	" q .
	ld hl,00000h		;6da9	21 00 00	! . .
	ld (l0f73h),hl		;6dac	22 73 0f	" s .
	call 00000h		;6daf	cd 00 00	. . .
	ld hl,00000h		;6db2	21 00 00	! . .
	ld (l0f75h),hl		;6db5	22 75 0f	" u .
	ld hl,bonus_word	;6db8	21 77 0f	! w .
	call 00000h		;6dbb	cd 00 00	. . .
	ld hl,(bonus_word)	;6dbe	2a 77 0f	* w .
	ld de,00001h		;6dc1	11 01 00	. . .
	add hl,de		;6dc4	19		.
	ld a,h			;6dc5	7c		|
	or l			;6dc6	b5		.
	jp nz,l43e1h		;6dc7	c2 e1 43	. . C
	ld hl,00002h		;6dca	21 02 00	! . .
	ld (l0f6fh),hl		;6dcd	22 6f 0f	" o .
	ld hl,(l0f71h)		;6dd0	2a 71 0f	* q .
l6dd3h:
	inc hl			;6dd3	23		#
	inc hl			;6dd4	23		#
l6dd5h:
	ld (0cd71h),hl		;6dd5	22 71 cd	" q .
	rla			;6dd8	17		.
	ld l,h			;6dd9	6c		l
	ld a,l			;6dda	7d		}
	push bc			;6ddb	c5		.
	push de			;6ddc	d5		.
	push hl			;6ddd	e5		.
	call sub_8b41h		;6dde	cd 41 8b	. A .
	jp z,08e90h		;6de1	ca 90 8e	. . .
	cp 003h			;6de4	fe 03		. .
	jp nz,l8e8dh		;6de6	c2 8d 8e	. . .
	ld hl,000a9h		;6de9	21 a9 00	! . .
	add hl,bc		;6dec	09		.
	ld a,(hl)		;6ded	7e		~
	inc hl			;6dee	23		#
	ld h,(hl)		;6def	66		f
	ld l,a			;6df0	6f		o
	ld (l6dd3h),hl		;6df1	22 d3 6d	" . m
	ld hl,000b2h		;6df4	21 b2 00	! . .
	add hl,bc		;6df7	09		.
	ld (l6dd5h),hl		;6df8	22 d5 6d	" . m
	pop hl			;6dfb	e1		.
	pop de			;6dfc	d1		.
	pop bc			;6dfd	c1		.
	ret			;6dfe	c9		.
sub_6dffh:
	call sub_6c17h		;6dff	cd 17 6c	. . l
	ld a,h			;6e02	7c		|
	or a			;6e03	b7		.
	jp nz,068d8h		;6e04	c2 d8 68	. . h
	push hl			;6e07	e5		.
	push de			;6e08	d5		.
	ex de,hl		;6e09	eb		.
	ld hl,(l6dd3h)		;6e0a	2a d3 6d	* . m
	ld a,l			;6e0d	7d		}
	sub e			;6e0e	93		.
	ld l,a			;6e0f	6f		o
	ld a,h			;6e10	7c		|
	sbc a,d			;6e11	9a		.
	ld h,a			;6e12	67		g
	jp c,08ea2h		;6e13	da a2 8e	. . .
	ld (l6dd3h),hl		;6e16	22 d3 6d	" . m
	ld hl,(l6dd5h)		;6e19	2a d5 6d	* . m
	ex de,hl		;6e1c	eb		.
	add hl,de		;6e1d	19		.
	ld (l6dd5h),hl		;6e1e	22 d5 6d	" . m
	pop hl			;6e21	e1		.
	call 07957h		;6e22	cd 57 79	. W y
	inc hl			;6e25	23		#
	ld (hl),e		;6e26	73		s
	inc hl			;6e27	23		#
	ld (hl),d		;6e28	72		r
	dec hl			;6e29	2b		+
	dec hl			;6e2a	2b		+
	pop de			;6e2b	d1		.
	ld (hl),e		;6e2c	73		s
	ex de,hl		;6e2d	eb		.
	ret			;6e2e	c9		.
	call sub_6c17h		;6e2f	cd 17 6c	. . l
	call sub_6e9bh		;6e32	cd 9b 6e	. . n
	jp l6f7ch		;6e35	c3 7c 6f	. | o
	call sub_6c17h		;6e38	cd 17 6c	. . l
	call sub_6ea6h		;6e3b	cd a6 6e	. . n
	jp l6f7ch		;6e3e	c3 7c 6f	. | o
	call sub_6c17h		;6e41	cd 17 6c	. . l
	call sub_6eb1h		;6e44	cd b1 6e	. . n
	jp l6f7ch		;6e47	c3 7c 6f	. | o
	call sub_6c17h		;6e4a	cd 17 6c	. . l
	call sub_6e71h		;6e4d	cd 71 6e	. q n
	jp l6f7ch		;6e50	c3 7c 6f	. | o
	call sub_6c17h		;6e53	cd 17 6c	. . l
	call sub_6e9bh		;6e56	cd 9b 6e	. . n
	jp l6f99h		;6e59	c3 99 6f	. . o
	call sub_6c17h		;6e5c	cd 17 6c	. . l
	call sub_6ea6h		;6e5f	cd a6 6e	. . n
	jp l6f99h		;6e62	c3 99 6f	. . o
	call sub_6c17h		;6e65	cd 17 6c	. . l
	call sub_6eb1h		;6e68	cd b1 6e	. . n
	jp l6f99h		;6e6b	c3 99 6f	. . o
; Runtime string output, with and without a trailing line ending
print_string:
	call sub_6c17h		;6e6e	cd 17 6c	. . l
sub_6e71h:
	call sub_6f03h		;6e71	cd 03 6f	. . o
	jp l6fa7h		;6e74	c3 a7 6f	. . o
	call sub_6c17h		;6e77	cd 17 6c	. . l
	call sub_6e9bh		;6e7a	cd 9b 6e	. . n
	jp l6f4ch		;6e7d	c3 4c 6f	. L o
	call sub_6c17h		;6e80	cd 17 6c	. . l
	call sub_6ea6h		;6e83	cd a6 6e	. . n
	jp l6f4ch		;6e86	c3 4c 6f	. L o
	call sub_6c17h		;6e89	cd 17 6c	. . l
	call sub_6eb1h		;6e8c	cd b1 6e	. . n
	jp l6f4ch		;6e8f	c3 4c 6f	. L o
print_string_line:
	call sub_6c17h		;6e92	cd 17 6c	. . l
	call sub_6f03h		;6e95	cd 03 6f	. . o
	jp l6f4ch		;6e98	c3 4c 6f	. L o
sub_6e9bh:
	push bc			;6e9b	c5		.
	push de			;6e9c	d5		.
	push hl			;6e9d	e5		.
	ld de,l9285h		;6e9e	11 85 92	. . .
	ld b,004h		;6ea1	06 04		. .
	jp l6ebch		;6ea3	c3 bc 6e	. . n
sub_6ea6h:
	push bc			;6ea6	c5		.
	push de			;6ea7	d5		.
	push hl			;6ea8	e5		.
	ld de,09281h		;6ea9	11 81 92	. . .
	ld b,008h		;6eac	06 08		. .
	jp l6ebch		;6eae	c3 bc 6e	. . n
sub_6eb1h:
	ld (l9285h),hl		;6eb1	22 85 92	" . .
	push bc			;6eb4	c5		.
	push de			;6eb5	d5		.
	push hl			;6eb6	e5		.
	ld b,002h		;6eb7	06 02		. .
	jp l6ec5h		;6eb9	c3 c5 6e	. . n
l6ebch:
	ld c,b			;6ebc	48		H
l6ebdh:
	ld a,(hl)		;6ebd	7e		~
	ld (de),a		;6ebe	12		.
	inc hl			;6ebf	23		#
	inc de			;6ec0	13		.
	dec c			;6ec1	0d		.
	jp nz,l6ebdh		;6ec2	c2 bd 6e	. . n
l6ec5h:
	ld a,b			;6ec5	78		x
	ld (l7a7fh),a		;6ec6	32 7f 7a	2 . z
	ld a,(06831h)		;6ec9	3a 31 68	: 1 h
	and a			;6ecc	a7		.
	jp nz,l6f73h		;6ecd	c2 73 6f	. s o
	call sub_6f43h		;6ed0	cd 43 6f	. C o
	jp nz,l6ef2h		;6ed3	c2 f2 6e	. . n
	call sub_7e75h		;6ed6	cd 75 7e	. u ~
	call sub_78b7h		;6ed9	cd b7 78	. . x
	inc a			;6edc	3c		<
	ld c,000h		;6edd	0e 00		. .
	call sub_6fb3h		;6edf	cd b3 6f	. . o
l6ee2h:
	ld a,(hl)		;6ee2	7e		~
	and a			;6ee3	a7		.
	jp z,l6eeeh		;6ee4	ca ee 6e	. . n
	call l900ch+2		;6ee7	cd 0e 90	. . .
	inc hl			;6eea	23		#
	jp l6ee2h		;6eeb	c3 e2 6e	. . n
l6eeeh:
	pop hl			;6eee	e1		.
	pop de			;6eef	d1		.
	pop bc			;6ef0	c1		.
	ret			;6ef1	c9		.
l6ef2h:
	call sub_7e75h		;6ef2	cd 75 7e	. u ~
l6ef5h:
	ld a,(hl)		;6ef5	7e		~
	and a			;6ef6	a7		.
	jp z,l6eeeh		;6ef7	ca ee 6e	. . n
	cp 020h			;6efa	fe 20		.  
	call nz,l900ch+2	;6efc	c4 0e 90	. . .
	inc hl			;6eff	23		#
	jp l6ef5h		;6f00	c3 f5 6e	. . n
sub_6f03h:
	ld a,003h		;6f03	3e 03		> .
	ld (l7a7fh),a		;6f05	32 7f 7a	2 . z
	ld a,(06831h)		;6f08	3a 31 68	: 1 h
	and a			;6f0b	a7		.
	push bc			;6f0c	c5		.
	push de			;6f0d	d5		.
	push hl			;6f0e	e5		.
	jp nz,l6f73h		;6f0f	c2 73 6f	. s o
	ld b,(hl)		;6f12	46		F
	inc hl			;6f13	23		#
	ld a,(hl)		;6f14	7e		~
	inc hl			;6f15	23		#
	ld h,(hl)		;6f16	66		f
	ld l,a			;6f17	6f		o
	ld a,b			;6f18	78		x
	ld c,000h		;6f19	0e 00		. .
	call sub_6f43h		;6f1b	cd 43 6f	. C o
	call z,sub_6fb3h	;6f1e	cc b3 6f	. . o
	call sub_6f3ah		;6f21	cd 3a 6f	. : o
	inc b			;6f24	04		.
l6f25h:
	dec b			;6f25	05		.
	jp z,l6f31h		;6f26	ca 31 6f	. 1 o
	ld a,(hl)		;6f29	7e		~
	inc hl			;6f2a	23		#
	call l900ch+2		;6f2b	cd 0e 90	. . .
	jp l6f25h		;6f2e	c3 25 6f	. % o
l6f31h:
	call sub_6f3ah		;6f31	cd 3a 6f	. : o
	pop hl			;6f34	e1		.
	pop de			;6f35	d1		.
	pop bc			;6f36	c1		.
	jp sub_78d7h		;6f37	c3 d7 78	. . x
sub_6f3ah:
	call sub_6f43h		;6f3a	cd 43 6f	. C o
	ret z			;6f3d	c8		.
	ld a,022h		;6f3e	3e 22		> "
	jp l900ch+2		;6f40	c3 0e 90	. . .
sub_6f43h:
	push bc			;6f43	c5		.
	ld b,a			;6f44	47		G
	ld a,(l6835h)		;6f45	3a 35 68	: 5 h
	and a			;6f48	a7		.
	ld a,b			;6f49	78		x
	pop bc			;6f4a	c1		.
	ret			;6f4b	c9		.
l6f4ch:
	call sub_6f43h		;6f4c	cd 43 6f	. C o
	jp z,l90b6h		;6f4f	ca b6 90	. . .
	push hl			;6f52	e5		.
	ld hl,(l6836h)		;6f53	2a 36 68	* 6 h
	dec hl			;6f56	2b		+
	ld a,(hl)		;6f57	7e		~
	inc a			;6f58	3c		<
	jp z,l6f6fh		;6f59	ca 6f 6f	. o o
	dec a			;6f5c	3d		=
	jp z,l6f6fh		;6f5d	ca 6f 6f	. o o
	inc hl			;6f60	23		#
	inc hl			;6f61	23		#
	inc hl			;6f62	23		#
	ld a,(hl)		;6f63	7e		~
	cp 003h			;6f64	fe 03		. .
	jp nz,l6f6fh		;6f66	c2 6f 6f	. o o
	push hl			;6f69	e5		.
	ld hl,(l682ch)		;6f6a	2a 2c 68	* , h
	ex (sp),hl		;6f6d	e3		.
	ret			;6f6e	c9		.
l6f6fh:
	pop hl			;6f6f	e1		.
	jp l90b6h		;6f70	c3 b6 90	. . .
l6f73h:
	ex de,hl		;6f73	eb		.
	ld hl,l6eeeh		;6f74	21 ee 6e	! . n
	push hl			;6f77	e5		.
	ld hl,(06832h)		;6f78	2a 32 68	* 2 h
	jp (hl)			;6f7b	e9		.
l6f7ch:
	push hl			;6f7c	e5		.
	ld hl,(l6836h)		;6f7d	2a 36 68	* 6 h
	ld a,(hl)		;6f80	7e		~
	pop hl			;6f81	e1		.
	dec a			;6f82	3d		=
l6f83h:
	sub 00eh		;6f83	d6 0e		. .
	jp nc,l6f83h		;6f85	d2 83 6f	. . o
	cpl			;6f88	2f		/
	inc a			;6f89	3c		<
	ld c,001h		;6f8a	0e 01		. .
	call sub_6fb3h		;6f8c	cd b3 6f	. . o
l6f8fh:
	ret z			;6f8f	c8		.
	push af			;6f90	f5		.
	call sub_6fa2h		;6f91	cd a2 6f	. . o
	pop af			;6f94	f1		.
	dec a			;6f95	3d		=
	jp l6f8fh		;6f96	c3 8f 6f	. . o
l6f99h:
	call l6fa7h		;6f99	cd a7 6f	. . o
	ret nz			;6f9c	c0		.
	ld a,(06831h)		;6f9d	3a 31 68	: 1 h
	or a			;6fa0	b7		.
	ret nz			;6fa1	c0		.
sub_6fa2h:
	ld a,020h		;6fa2	3e 20		>  
	jp l900ch+2		;6fa4	c3 0e 90	. . .
l6fa7h:
	call sub_6f43h		;6fa7	cd 43 6f	. C o
	ret z			;6faa	c8		.
	ld a,02ch		;6fab	3e 2c		> ,
	call l900ch+2		;6fad	cd 0e 90	. . .
	or 001h			;6fb0	f6 01		. .
	ret			;6fb2	c9		.
sub_6fb3h:
	push hl			;6fb3	e5		.
	push de			;6fb4	d5		.
	push bc			;6fb5	c5		.
	ld d,a			;6fb6	57		W
	ld hl,(l6836h)		;6fb7	2a 36 68	* 6 h
	inc hl			;6fba	23		#
	ld e,(hl)		;6fbb	5e		^
	dec c			;6fbc	0d		.
	call z,sub_6fd6h	;6fbd	cc d6 6f	. . o
	inc e			;6fc0	1c		.
	jp z,l6fd0h		;6fc1	ca d0 6f	. . o
	dec hl			;6fc4	2b		+
	add a,(hl)		;6fc5	86		.
	dec a			;6fc6	3d		=
	cp e			;6fc7	bb		.
	jp c,l6fd0h		;6fc8	da d0 6f	. . o
	call l90b6h		;6fcb	cd b6 90	. . .
	ld d,000h		;6fce	16 00		. .
l6fd0h:
	ld a,d			;6fd0	7a		z
	pop bc			;6fd1	c1		.
	pop de			;6fd2	d1		.
	pop hl			;6fd3	e1		.
	and a			;6fd4	a7		.
	ret			;6fd5	c9		.
sub_6fd6h:
	push af			;6fd6	f5		.
	ld a,e			;6fd7	7b		{
	ld e,0ffh		;6fd8	1e ff		. .
l6fdah:
	sub 00eh		;6fda	d6 0e		. .
	jp c,l6fe8h		;6fdc	da e8 6f	. . o
	push af			;6fdf	f5		.
	ld a,e			;6fe0	7b		{
	add a,00eh		;6fe1	c6 0e		. .
	ld e,a			;6fe3	5f		_
	pop af			;6fe4	f1		.
	jp l6fdah		;6fe5	c3 da 6f	. . o
l6fe8h:
	pop af			;6fe8	f1		.
	ret			;6fe9	c9		.
; Runtime entry: BASCOM $PR0A, PRINT setup
print_setup:
	push hl			;6fea	e5		.
	ld hl,l6839h		;6feb	21 39 68	! 9 h
	ld (l6836h),hl		;6fee	22 36 68	" 6 h
	ld hl,00000h		;6ff1	21 00 00	! . .
	ld (l680eh),hl		;6ff4	22 0e 68	" . h
	xor a			;6ff7	af		.
	ld (06831h),a		;6ff8	32 31 68	2 1 h
	call sub_7000h		;6ffb	cd 00 70	. . p
	pop hl			;6ffe	e1		.
	ret			;6fff	c9		.
sub_7000h:
	ld hl,l6834h		;7000	21 34 68	! 4 h
	ld a,(hl)		;7003	7e		~
	ld (hl),000h		;7004	36 00		6 .
	inc hl			;7006	23		#
	ld (hl),a		;7007	77		w
	ret			;7008	c9		.
sub_7009h:
	pop hl			;7009	e1		.
	ld a,(hl)		;700a	7e		~
	ld hl,l7020h		;700b	21 20 70	!   p
	call sub_7035h		;700e	cd 35 70	. 5 p
	ld c,(hl)		;7011	4e		N
	jp z,l7017h		;7012	ca 17 70	. . p
	ld c,0ffh		;7015	0e ff		. .
l7017h:
	call sub_6c21h		;7017	cd 21 6c	. ! l
	ld l,c			;701a	69		i
	ld h,000h		;701b	26 00		& .
	jp l68e3h		;701d	c3 e3 68	. . h
l7020h:
	ld b,005h		;7020	06 05		. .
	adc a,d			;7022	8a		.
	dec b			;7023	05		.
	adc a,c			;7024	89		.
	dec bc			;7025	0b		.
	adc a,e			;7026	8b		.
	dec b			;7027	05		.
	rrca			;7028	0f		.
	ld b,010h		;7029	06 10		. .
	ld b,011h		;702b	06 11		. .
	ld b,013h		;702d	06 13		. .
	ld b,014h		;702f	06 14		. .
	ld b,017h		;7031	06 17		. .
	dec b			;7033	05		.
	nop			;7034	00		.
sub_7035h:
	push bc			;7035	c5		.
	ld b,a			;7036	47		G
l7037h:
	ld a,(hl)		;7037	7e		~
	inc hl			;7038	23		#
	cp b			;7039	b8		.
	jp z,l7045h		;703a	ca 45 70	. E p
	and a			;703d	a7		.
	inc hl			;703e	23		#
	jp nz,l7037h		;703f	c2 37 70	. 7 p
	dec hl			;7042	2b		+
	dec hl			;7043	2b		+
	or h			;7044	b4		.
l7045h:
	pop bc			;7045	c1		.
	ret			;7046	c9		.
sub_7047h:
	push af			;7047	f5		.
	rra			;7048	1f		.
	rra			;7049	1f		.
	rra			;704a	1f		.
	rra			;704b	1f		.
	call sub_7050h		;704c	cd 50 70	. P p
	pop af			;704f	f1		.
sub_7050h:
	and 00fh		;7050	e6 0f		. .
	add a,030h		;7052	c6 30		. 0
	cp 03ah			;7054	fe 3a		. :
	jp c,l705bh		;7056	da 5b 70	. [ p
	add a,007h		;7059	c6 07		. .
l705bh:
	jp sub_90a2h		;705b	c3 a2 90	. . .
; Runtime entry: BASCOM $WID, WIDTH setting
width_setting:
	ld a,h			;705e	7c		|
	or a			;705f	b7		.
	jp nz,068d8h		;7060	c2 d8 68	. . h
	ld a,l			;7063	7d		}
	cp 00fh			;7064	fe 0f		. .
	jp c,068d8h		;7066	da d8 68	. . h
	ld hl,l6839h+1		;7069	21 3a 68	! : h
	ld (hl),a		;706c	77		w
	ret			;706d	c9		.
sub_706eh:
	call sub_6c17h		;706e	cd 17 6c	. . l
	ld a,(de)		;7071	1a		.
	add a,(hl)		;7072	86		.
	jp c,068d8h		;7073	da d8 68	. . h
	push de			;7076	d5		.
	push hl			;7077	e5		.
	push de			;7078	d5		.
	call sub_785eh		;7079	cd 5e 78	. ^ x
	ex (sp),hl		;707c	e3		.
	call sub_708fh		;707d	cd 8f 70	. . p
	pop hl			;7080	e1		.
	ex (sp),hl		;7081	e3		.
	call sub_708fh		;7082	cd 8f 70	. . p
	call sub_78d7h		;7085	cd d7 78	. . x
	pop de			;7088	d1		.
	pop hl			;7089	e1		.
	call sub_78d7h		;708a	cd d7 78	. . x
	ex de,hl		;708d	eb		.
	ret			;708e	c9		.
sub_708fh:
	push hl			;708f	e5		.
	ld a,(hl)		;7090	7e		~
	inc hl			;7091	23		#
	push af			;7092	f5		.
	ld a,(hl)		;7093	7e		~
	inc hl			;7094	23		#
	ld h,(hl)		;7095	66		f
	ld l,a			;7096	6f		o
	pop af			;7097	f1		.
	ex de,hl		;7098	eb		.
	call sub_9177h		;7099	cd 77 91	. w .
	ex de,hl		;709c	eb		.
	pop hl			;709d	e1		.
	ret			;709e	c9		.
	ld a,(de)		;709f	1a		.
	sub (hl)		;70a0	96		.
	jp c,sub_70c1h		;70a1	da c1 70	. . p
	push bc			;70a4	c5		.
	push de			;70a5	d5		.
	push hl			;70a6	e5		.
	ex de,hl		;70a7	eb		.
	inc hl			;70a8	23		#
	ld c,(hl)		;70a9	4e		N
	inc hl			;70aa	23		#
	ld h,(hl)		;70ab	66		f
	ld l,c			;70ac	69		i
	call sub_70e8h		;70ad	cd e8 70	. . p
	ex de,hl		;70b0	eb		.
	ld a,(hl)		;70b1	7e		~
	inc hl			;70b2	23		#
	ld c,(hl)		;70b3	4e		N
	inc hl			;70b4	23		#
	ld h,(hl)		;70b5	66		f
	ld l,c			;70b6	69		i
	ex de,hl		;70b7	eb		.
	call sub_9177h		;70b8	cd 77 91	. w .
	pop hl			;70bb	e1		.
	pop de			;70bc	d1		.
	pop bc			;70bd	c1		.
	jp sub_78d7h		;70be	c3 d7 78	. . x
sub_70c1h:
	push bc			;70c1	c5		.
	push de			;70c2	d5		.
	push hl			;70c3	e5		.
	ld a,(de)		;70c4	1a		.
	sub (hl)		;70c5	96		.
	ld b,(hl)		;70c6	46		F
	ld c,a			;70c7	4f		O
	jp nc,l70cfh		;70c8	d2 cf 70	. . p
	ld a,(de)		;70cb	1a		.
	ld b,a			;70cc	47		G
	ld c,000h		;70cd	0e 00		. .
l70cfh:
	inc hl			;70cf	23		#
	ld a,(hl)		;70d0	7e		~
	inc hl			;70d1	23		#
	ld h,(hl)		;70d2	66		f
	ld l,a			;70d3	6f		o
	ex de,hl		;70d4	eb		.
	inc hl			;70d5	23		#
	ld a,(hl)		;70d6	7e		~
	inc hl			;70d7	23		#
	ld h,(hl)		;70d8	66		f
	ld l,a			;70d9	6f		o
	ld a,b			;70da	78		x
	call sub_9177h		;70db	cd 77 91	. w .
	ld a,c			;70de	79		y
	call sub_70e8h		;70df	cd e8 70	. . p
	pop hl			;70e2	e1		.
	pop de			;70e3	d1		.
	pop bc			;70e4	c1		.
	jp sub_78d7h		;70e5	c3 d7 78	. . x
sub_70e8h:
	sub 001h		;70e8	d6 01		. .
	ret c			;70ea	d8		.
	ld (hl),020h		;70eb	36 20		6  
	inc hl			;70ed	23		#
	jp sub_70e8h		;70ee	c3 e8 70	. . p
sub_70f1h:
	ld a,(hl)		;70f1	7e		~
	cp 002h			;70f2	fe 02		. .
	jp c,068d8h		;70f4	da d8 68	. . h
	push hl			;70f7	e5		.
	inc hl			;70f8	23		#
	ld a,(hl)		;70f9	7e		~
	inc hl			;70fa	23		#
	ld h,(hl)		;70fb	66		f
	ld l,a			;70fc	6f		o
	ld a,(hl)		;70fd	7e		~
	inc hl			;70fe	23		#
	ld h,(hl)		;70ff	66		f
	ld l,a			;7100	6f		o
	ex (sp),hl		;7101	e3		.
	call sub_78d7h		;7102	cd d7 78	. . x
	pop hl			;7105	e1		.
	ret			;7106	c9		.
	push de			;7107	d5		.
	ld de,l9285h		;7108	11 85 92	. . .
	ld a,004h		;710b	3e 04		> .
	jp l7116h		;710d	c3 16 71	. . q
	push de			;7110	d5		.
	ld de,09281h		;7111	11 81 92	. . .
	ld a,008h		;7114	3e 08		> .
l7116h:
	push hl			;7116	e5		.
	push af			;7117	f5		.
	dec a			;7118	3d		=
	cp (hl)			;7119	be		.
	jp nc,l712dh		;711a	d2 2d 71	. - q
	inc hl			;711d	23		#
	ld a,(hl)		;711e	7e		~
	inc hl			;711f	23		#
	ld h,(hl)		;7120	66		f
	ld l,a			;7121	6f		o
	pop af			;7122	f1		.
	ex de,hl		;7123	eb		.
	call sub_9177h		;7124	cd 77 91	. w .
	pop hl			;7127	e1		.
	call sub_78d7h		;7128	cd d7 78	. . x
	pop de			;712b	d1		.
	ret			;712c	c9		.
l712dh:
	pop hl			;712d	e1		.
	pop hl			;712e	e1		.
	pop hl			;712f	e1		.
	jp 068d8h		;7130	c3 d8 68	. . h
	xor a			;7133	af		.
	ld (l9287h+1),a		;7134	32 88 92	2 . .
	ret			;7137	c9		.
sub_7138h:
	push bc			;7138	c5		.
	push de			;7139	d5		.
	push hl			;713a	e5		.
	call sub_77eah		;713b	cd ea 77	. . w
	ld hl,(l76f5h)		;713e	2a f5 76	* . v
	inc hl			;7141	23		#
	ld d,(hl)		;7142	56		V
	inc hl			;7143	23		#
	ld c,(hl)		;7144	4e		N
	ld b,000h		;7145	06 00		. .
	ld e,b			;7147	58		X
	ld hl,08090h		;7148	21 90 80	! . .
	ld (l9287h+1),hl	;714b	22 88 92	" . .
	call sub_9b0eh		;714e	cd 0e 9b	. . .
	pop hl			;7151	e1		.
	pop de			;7152	d1		.
	pop bc			;7153	c1		.
	ret			;7154	c9		.
l7155h:
	ld (001c5h),a		;7155	32 c5 01	2 . .
	nop			;7158	00		.
	nop			;7159	00		.
	call sub_715fh		;715a	cd 5f 71	. _ q
	pop bc			;715d	c1		.
	ret			;715e	c9		.
sub_715fh:
	ld a,b			;715f	78		x
	and a			;7160	a7		.
	jp nz,068d8h		;7161	c2 d8 68	. . h
	push bc			;7164	c5		.
	or c			;7165	b1		.
	jp z,l716ah		;7166	ca 6a 71	. j q
	dec bc			;7169	0b		.
l716ah:
	push de			;716a	d5		.
	push hl			;716b	e5		.
	ld a,c			;716c	79		y
	inc a			;716d	3c		<
	ld (l7155h),a		;716e	32 55 71	2 U q
	ld b,(hl)		;7171	46		F
	ex de,hl		;7172	eb		.
	ld a,(hl)		;7173	7e		~
	sub c			;7174	91		.
	jp c,l71b4h		;7175	da b4 71	. . q
	sub b			;7178	90		.
	jp c,l71b4h		;7179	da b4 71	. . q
	push af			;717c	f5		.
	inc hl			;717d	23		#
	ld a,(hl)		;717e	7e		~
	inc hl			;717f	23		#
	ld h,(hl)		;7180	66		f
	ld l,a			;7181	6f		o
	ld a,c			;7182	79		y
	call sub_9172h		;7183	cd 72 91	. r .
	pop af			;7186	f1		.
	ld c,a			;7187	4f		O
	inc c			;7188	0c		.
	ex de,hl		;7189	eb		.
	inc hl			;718a	23		#
	ld a,(hl)		;718b	7e		~
	inc hl			;718c	23		#
	ld h,(hl)		;718d	66		f
	ld l,a			;718e	6f		o
	ld a,b			;718f	78		x
	and a			;7190	a7		.
	jp z,l71b8h		;7191	ca b8 71	. . q
l7194h:
	push bc			;7194	c5		.
	push de			;7195	d5		.
	push hl			;7196	e5		.
l7197h:
	ld a,(de)		;7197	1a		.
	cp (hl)			;7198	be		.
	jp nz,l71a8h		;7199	c2 a8 71	. . q
	inc de			;719c	13		.
	inc hl			;719d	23		#
	dec b			;719e	05		.
	jp nz,l7197h		;719f	c2 97 71	. . q
	pop af			;71a2	f1		.
	pop af			;71a3	f1		.
	pop af			;71a4	f1		.
	jp l71b8h		;71a5	c3 b8 71	. . q
l71a8h:
	ld hl,l7155h		;71a8	21 55 71	! U q
	inc (hl)		;71ab	34		4
	pop hl			;71ac	e1		.
	pop de			;71ad	d1		.
	pop bc			;71ae	c1		.
	inc de			;71af	13		.
	dec c			;71b0	0d		.
	jp nz,l7194h		;71b1	c2 94 71	. . q
l71b4h:
	xor a			;71b4	af		.
	ld (l7155h),a		;71b5	32 55 71	2 U q
l71b8h:
	pop de			;71b8	d1		.
	pop hl			;71b9	e1		.
	pop bc			;71ba	c1		.
	call sub_78d7h		;71bb	cd d7 78	. . x
	ex de,hl		;71be	eb		.
	call sub_78d7h		;71bf	cd d7 78	. . x
	ld hl,(l7155h)		;71c2	2a 55 71	* U q
	ld h,000h		;71c5	26 00		& .
	ret			;71c7	c9		.
sub_71c8h:
	push bc			;71c8	c5		.
	push de			;71c9	d5		.
	push hl			;71ca	e5		.
	call sub_9c05h		;71cb	cd 05 9c	. . .
	call nz,sub_99f5h	;71ce	c4 f5 99	. . .
	pop hl			;71d1	e1		.
	pop de			;71d2	d1		.
	pop bc			;71d3	c1		.
	ret			;71d4	c9		.
sub_71d5h:
	ld a,(hl)		;71d5	7e		~
	push af			;71d6	f5		.
	call sub_78d7h		;71d7	cd d7 78	. . x
	pop af			;71da	f1		.
	ld l,a			;71db	6f		o
	ld h,000h		;71dc	26 00		& .
	ret			;71de	c9		.
sub_71dfh:
	ld a,(hl)		;71df	7e		~
	and a			;71e0	a7		.
	jp z,068d8h		;71e1	ca d8 68	. . h
	push de			;71e4	d5		.
	inc hl			;71e5	23		#
	ld e,(hl)		;71e6	5e		^
	inc hl			;71e7	23		#
	ld d,(hl)		;71e8	56		V
	dec hl			;71e9	2b		+
	dec hl			;71ea	2b		+
	ld a,(de)		;71eb	1a		.
	pop de			;71ec	d1		.
	push af			;71ed	f5		.
	call sub_78d7h		;71ee	cd d7 78	. . x
	pop af			;71f1	f1		.
	ld l,a			;71f2	6f		o
	ld h,000h		;71f3	26 00		& .
	ret			;71f5	c9		.
l71f6h:
	nop			;71f6	00		.
	jp l023eh		;71f7	c3 3e 02	. > .
	ld (l71f6h),hl		;71fa	22 f6 71	" . q
	ld hl,l71f6h		;71fd	21 f6 71	! . q
	jp l720ah		;7200	c3 0a 72	. . r
	ld a,004h		;7203	3e 04		> .
	jp l720ah		;7205	c3 0a 72	. . r
	ld a,008h		;7208	3e 08		> .
l720ah:
	call sub_6c17h		;720a	cd 17 6c	. . l
	jp sub_78c6h		;720d	c3 c6 78	. . x
	call sub_6c17h		;7210	cd 17 6c	. . l
	push bc			;7213	c5		.
	push de			;7214	d5		.
	push hl			;7215	e5		.
	call sub_72deh		;7216	cd de 72	. . r
	call sub_7ab4h		;7219	cd b4 7a	. . z
	ld de,l9285h		;721c	11 85 92	. . .
	ld a,004h		;721f	3e 04		> .
	jp l724fh		;7221	c3 4f 72	. O r
	call sub_6c17h		;7224	cd 17 6c	. . l
	push bc			;7227	c5		.
	push de			;7228	d5		.
	push hl			;7229	e5		.
	call sub_72e7h		;722a	cd e7 72	. . r
	call sub_7ca0h		;722d	cd a0 7c	. . |
	call sub_72fdh		;7230	cd fd 72	. . r
	call sub_7acbh		;7233	cd cb 7a	. . z
	ld de,09281h		;7236	11 81 92	. . .
	ld a,008h		;7239	3e 08		> .
	jp l724fh		;723b	c3 4f 72	. O r
sub_723eh:
	call sub_6c17h		;723e	cd 17 6c	. . l
	push bc			;7241	c5		.
	push de			;7242	d5		.
	push hl			;7243	e5		.
	call sub_72deh		;7244	cd de 72	. . r
	call sub_7c19h		;7247	cd 19 7c	. . |
	ld de,l9285h		;724a	11 85 92	. . .
	ld a,002h		;724d	3e 02		> .
l724fh:
	pop hl			;724f	e1		.
	push hl			;7250	e5		.
	call sub_9177h		;7251	cd 77 91	. w .
	pop hl			;7254	e1		.
	pop de			;7255	d1		.
	pop bc			;7256	c1		.
	ret			;7257	c9		.
sub_7258h:
	call sub_6c17h		;7258	cd 17 6c	. . l
	push bc			;725b	c5		.
	push de			;725c	d5		.
	push hl			;725d	e5		.
	call sub_72e7h		;725e	cd e7 72	. . r
	ld a,(hl)		;7261	7e		~
	ld b,02ch		;7262	06 2c		. ,
	cp 022h			;7264	fe 22		. "
	jp nz,l726ch		;7266	c2 6c 72	. l r
	inc hl			;7269	23		#
	ld b,022h		;726a	06 22		. "
l726ch:
	push hl			;726c	e5		.
	ld c,000h		;726d	0e 00		. .
l726fh:
	ld a,(hl)		;726f	7e		~
	and a			;7270	a7		.
	jp z,l7283h		;7271	ca 83 72	. . r
	cp b			;7274	b8		.
	jp z,l7283h		;7275	ca 83 72	. . r
	inc hl			;7278	23		#
	inc c			;7279	0c		.
	jp nz,l726fh		;727a	c2 6f 72	. o r
	call sub_6c21h		;727d	cd 21 6c	. ! l
	jp 068d8h		;7280	c3 d8 68	. . h
l7283h:
	cp 022h			;7283	fe 22		. "
	jp nz,l7289h		;7285	c2 89 72	. . r
	inc hl			;7288	23		#
l7289h:
	call sub_72fdh		;7289	cd fd 72	. . r
	pop hl			;728c	e1		.
	ld a,c			;728d	79		y
	call sub_78c6h		;728e	cd c6 78	. . x
	pop de			;7291	d1		.
	call sub_74deh		;7292	cd de 74	. . t
	ex de,hl		;7295	eb		.
	pop de			;7296	d1		.
	pop bc			;7297	c1		.
	ret			;7298	c9		.
sub_7299h:
	push de			;7299	d5		.
	push hl			;729a	e5		.
	ld hl,(l1002h)		;729b	2a 02 10	* . .
	ld e,(hl)		;729e	5e		^
	inc hl			;729f	23		#
	ld d,(hl)		;72a0	56		V
	inc hl			;72a1	23		#
	ld a,e			;72a2	7b		{
	or d			;72a3	b2		.
	jp nz,l72aah		;72a4	c2 aa 72	. . r
	ld hl,06821h		;72a7	21 21 68	! ! h
l72aah:
	ld (0680ah),hl		;72aa	22 0a 68	" . h
	ex de,hl		;72ad	eb		.
	ld (0680ch),hl		;72ae	22 0c 68	" . h
	pop hl			;72b1	e1		.
	pop de			;72b2	d1		.
	ld a,001h		;72b3	3e 01		> .
	ld (06821h),a		;72b5	32 21 68	2 ! h
	ret			;72b8	c9		.
	call sub_7299h		;72b9	cd 99 72	. . r
	ex (sp),hl		;72bc	e3		.
	push bc			;72bd	c5		.
	push de			;72be	d5		.
	ld c,(hl)		;72bf	4e		N
	inc hl			;72c0	23		#
	ld b,(hl)		;72c1	46		F
	inc hl			;72c2	23		#
	push hl			;72c3	e5		.
l72c4h:
	ld hl,(0680ah)		;72c4	2a 0a 68	* . h
	ld a,(hl)		;72c7	7e		~
	dec a			;72c8	3d		=
	jp z,l72d9h		;72c9	ca d9 72	. . r
	ld a,l			;72cc	7d		}
	sub c			;72cd	91		.
	ld a,h			;72ce	7c		|
	sbc a,b			;72cf	98		.
	jp nc,l72d9h		;72d0	d2 d9 72	. . r
	call sub_730fh		;72d3	cd 0f 73	. . s
	jp l72c4h		;72d6	c3 c4 72	. . r
l72d9h:
	pop hl			;72d9	e1		.
	pop de			;72da	d1		.
	pop bc			;72db	c1		.
	ex (sp),hl		;72dc	e3		.
	ret			;72dd	c9		.
sub_72deh:
	call sub_72e7h		;72de	cd e7 72	. . r
	call 07ca7h		;72e1	cd a7 7c	. . |
	jp sub_72fdh		;72e4	c3 fd 72	. . r
sub_72e7h:
	ld a,(06821h)		;72e7	3a 21 68	: ! h
	and a			;72ea	a7		.
	call z,sub_7299h	;72eb	cc 99 72	. . r
	ld hl,(0680ah)		;72ee	2a 0a 68	* . h
	call sub_9166h		;72f1	cd 66 91	. f .
	ld a,(hl)		;72f4	7e		~
	dec a			;72f5	3d		=
	ret nz			;72f6	c0		.
	call sub_6c21h		;72f7	cd 21 6c	. ! l
	jp 068dbh		;72fa	c3 db 68	. . h
sub_72fdh:
	call sub_9166h		;72fd	cd 66 91	. f .
	ld a,(hl)		;7300	7e		~
	cp 02ch			;7301	fe 2c		. ,
	jp nz,l730bh		;7303	c2 0b 73	. . s
	inc hl			;7306	23		#
	ld (0680ah),hl		;7307	22 0a 68	" . h
	ret			;730a	c9		.
l730bh:
	and a			;730b	a7		.
	jp nz,l731eh		;730c	c2 1e 73	. . s
sub_730fh:
	ld hl,(0680ch)		;730f	2a 0c 68	* . h
	ld (0680ah),hl		;7312	22 0a 68	" . h
	dec hl			;7315	2b		+
	ld d,(hl)		;7316	56		V
	dec hl			;7317	2b		+
	ld e,(hl)		;7318	5e		^
	ex de,hl		;7319	eb		.
	ld (0680ch),hl		;731a	22 0c 68	" . h
	ret			;731d	c9		.
l731eh:
	call sub_6c21h		;731e	cd 21 6c	. ! l
	jp 068e1h		;7321	c3 e1 68	. . h
sub_7324h:
	call sub_6c17h		;7324	cd 17 6c	. . l
	ld a,(hl)		;7327	7e		~
	inc a			;7328	3c		<
	jp z,068d8h		;7329	ca d8 68	. . h
	push bc			;732c	c5		.
	push de			;732d	d5		.
	push hl			;732e	e5		.
	push hl			;732f	e5		.
	call sub_785eh		;7330	cd 5e 78	. ^ x
	ex (sp),hl		;7333	e3		.
	ld a,(hl)		;7334	7e		~
	push af			;7335	f5		.
	inc hl			;7336	23		#
	ld a,(hl)		;7337	7e		~
	inc hl			;7338	23		#
	ld h,(hl)		;7339	66		f
	ld l,a			;733a	6f		o
	pop af			;733b	f1		.
	ex de,hl		;733c	eb		.
	push hl			;733d	e5		.
	call sub_9177h		;733e	cd 77 91	. w .
	ld (hl),000h		;7341	36 00		6 .
	pop hl			;7343	e1		.
	dec hl			;7344	2b		+
	call 083bbh		;7345	cd bb 83	. . .
	call sub_7ca0h		;7348	cd a0 7c	. . |
	call sub_7acbh		;734b	cd cb 7a	. . z
	pop hl			;734e	e1		.
	call sub_78d7h		;734f	cd d7 78	. . x
	pop hl			;7352	e1		.
	pop de			;7353	d1		.
	pop bc			;7354	c1		.
	jp sub_78d7h		;7355	c3 d7 78	. . x
	ld a,004h		;7358	3e 04		> .
	jp l7373h		;735a	c3 73 73	. s s
sub_735dh:
	ld a,001h		;735d	3e 01		> .
	jp l7373h		;735f	c3 73 73	. s s
	ld a,006h		;7362	3e 06		> .
	jp l7373h		;7364	c3 73 73	. s s
	ld a,003h		;7367	3e 03		> .
	jp l7373h		;7369	c3 73 73	. s s
	ld a,005h		;736c	3e 05		> .
	jp l7373h		;736e	c3 73 73	. s s
	ld a,002h		;7371	3e 02		> .
l7373h:
	ex (sp),hl		;7373	e3		.
	push de			;7374	d5		.
	ld e,(hl)		;7375	5e		^
	inc hl			;7376	23		#
	ld d,(hl)		;7377	56		V
	inc hl			;7378	23		#
	push hl			;7379	e5		.
	ld hl,l9285h		;737a	21 85 92	! . .
	jp l90ceh		;737d	c3 ce 90	. . .
	ld a,004h		;7380	3e 04		> .
	jp l739bh		;7382	c3 9b 73	. . s
	ld a,001h		;7385	3e 01		> .
	jp l739bh		;7387	c3 9b 73	. . s
	ld a,006h		;738a	3e 06		> .
	jp l739bh		;738c	c3 9b 73	. . s
	ld a,003h		;738f	3e 03		> .
	jp l739bh		;7391	c3 9b 73	. . s
	ld a,005h		;7394	3e 05		> .
	jp l739bh		;7396	c3 9b 73	. . s
; Runtime string equality returns $FFFF for equal, zero otherwise
string_equal:
	ld a,002h		;7399	3e 02		> .
l739bh:
	call sub_76a6h		;739b	cd a6 76	. . v
	ld hl,00000h		;739e	21 00 00	! . .
	ret z			;73a1	c8		.
	dec hl			;73a2	2b		+
	ret			;73a3	c9		.
	ld a,004h		;73a4	3e 04		> .
	jp l73bfh		;73a6	c3 bf 73	. . s
	ld a,001h		;73a9	3e 01		> .
	jp l73bfh		;73ab	c3 bf 73	. . s
	ld a,006h		;73ae	3e 06		> .
	jp l73bfh		;73b0	c3 bf 73	. . s
	ld a,003h		;73b3	3e 03		> .
	jp l73bfh		;73b5	c3 bf 73	. . s
; Runtime string inequality branches through an inline 16-bit address
branch_if_strings_unequal:
	ld a,005h		;73b8	3e 05		> .
	jp l73bfh		;73ba	c3 bf 73	. . s
sub_73bdh:
	ld a,002h		;73bd	3e 02		> .
l73bfh:
	push hl			;73bf	e5		.
	call sub_76a6h		;73c0	cd a6 76	. . v
	pop hl			;73c3	e1		.
	ex (sp),hl		;73c4	e3		.
	jp z,l73ceh		;73c5	ca ce 73	. . s
	ld a,(hl)		;73c8	7e		~
	inc hl			;73c9	23		#
	ld h,(hl)		;73ca	66		f
	ld l,a			;73cb	6f		o
	ex (sp),hl		;73cc	e3		.
	ret			;73cd	c9		.
l73ceh:
	inc hl			;73ce	23		#
	inc hl			;73cf	23		#
	ex (sp),hl		;73d0	e3		.
	ret			;73d1	c9		.
	ex (sp),hl		;73d2	e3		.
	push de			;73d3	d5		.
	push bc			;73d4	c5		.
	call sub_9137h		;73d5	cd 37 91	. 7 .
l73d8h:
	ld e,(hl)		;73d8	5e		^
	inc hl			;73d9	23		#
	ld d,(hl)		;73da	56		V
	inc hl			;73db	23		#
	push hl			;73dc	e5		.
	ex de,hl		;73dd	eb		.
l73deh:
	call sub_6c17h		;73de	cd 17 6c	. . l
	call sub_987ch		;73e1	cd 7c 98	. | .
	pop hl			;73e4	e1		.
	pop bc			;73e5	c1		.
	pop de			;73e6	d1		.
	ex (sp),hl		;73e7	e3		.
	ret			;73e8	c9		.
sub_73e9h:
	ex (sp),hl		;73e9	e3		.
	push de			;73ea	d5		.
	push bc			;73eb	c5		.
	jp l73d8h		;73ec	c3 d8 73	. . s
	ex (sp),hl		;73ef	e3		.
	push de			;73f0	d5		.
	push bc			;73f1	c5		.
	ld e,(hl)		;73f2	5e		^
	inc hl			;73f3	23		#
	push hl			;73f4	e5		.
	call sub_912ch		;73f5	cd 2c 91	. , .
	jp l73deh		;73f8	c3 de 73	. . s
	ex (sp),hl		;73fb	e3		.
	push de			;73fc	d5		.
	push bc			;73fd	c5		.
	call sub_9137h		;73fe	cd 37 91	. 7 .
l7401h:
	ld e,(hl)		;7401	5e		^
	inc hl			;7402	23		#
	ld d,(hl)		;7403	56		V
	inc hl			;7404	23		#
	push hl			;7405	e5		.
	ex de,hl		;7406	eb		.
l7407h:
	call sub_6c17h		;7407	cd 17 6c	. . l
	call sub_997dh		;740a	cd 7d 99	. } .
	pop hl			;740d	e1		.
	pop bc			;740e	c1		.
	pop de			;740f	d1		.
	ex (sp),hl		;7410	e3		.
	ret			;7411	c9		.
sub_7412h:
	ex (sp),hl		;7412	e3		.
	push de			;7413	d5		.
	push bc			;7414	c5		.
	jp l7401h		;7415	c3 01 74	. . t
sub_7418h:
	ex (sp),hl		;7418	e3		.
	push de			;7419	d5		.
	push bc			;741a	c5		.
	ld e,(hl)		;741b	5e		^
	inc hl			;741c	23		#
	push hl			;741d	e5		.
	call sub_912ch		;741e	cd 2c 91	. , .
	jp l7407h		;7421	c3 07 74	. . t
	ex (sp),hl		;7424	e3		.
	push de			;7425	d5		.
	push bc			;7426	c5		.
	call sub_9144h		;7427	cd 44 91	. D .
l742ah:
	ld e,(hl)		;742a	5e		^
	inc hl			;742b	23		#
	ld d,(hl)		;742c	56		V
	inc hl			;742d	23		#
	push hl			;742e	e5		.
	ex de,hl		;742f	eb		.
l7430h:
	call sub_6c17h		;7430	cd 17 6c	. . l
	call sub_940fh		;7433	cd 0f 94	. . .
	pop hl			;7436	e1		.
	pop bc			;7437	c1		.
	pop de			;7438	d1		.
	ex (sp),hl		;7439	e3		.
	ret			;743a	c9		.
sub_743bh:
	ex (sp),hl		;743b	e3		.
	push de			;743c	d5		.
	push bc			;743d	c5		.
	jp l742ah		;743e	c3 2a 74	. * t
	ex (sp),hl		;7441	e3		.
	push de			;7442	d5		.
	push bc			;7443	c5		.
	ld e,(hl)		;7444	5e		^
	inc hl			;7445	23		#
	push hl			;7446	e5		.
	call sub_912ch		;7447	cd 2c 91	. , .
	jp l7430h		;744a	c3 30 74	. 0 t
sub_744dh:
	call sub_6c17h		;744d	cd 17 6c	. . l
	ld a,h			;7450	7c		|
	and a			;7451	a7		.
	jp nz,068d8h		;7452	c2 d8 68	. . h
	push bc			;7455	c5		.
	ld b,d			;7456	42		B
	ld c,e			;7457	4b		K
	ld de,00001h		;7458	11 01 00	. . .
l745bh:
	call sub_7487h		;745b	cd 87 74	. . t
	ld d,b			;745e	50		P
	ld e,c			;745f	59		Y
	pop bc			;7460	c1		.
	ret			;7461	c9		.
sub_7462h:
	call sub_6c17h		;7462	cd 17 6c	. . l
	ld a,h			;7465	7c		|
	and a			;7466	a7		.
	jp nz,068d8h		;7467	c2 d8 68	. . h
	push bc			;746a	c5		.
	ld b,d			;746b	42		B
	ld c,e			;746c	4b		K
	ld de,00001h		;746d	11 01 00	. . .
	ld a,(bc)		;7470	0a		.
	sub l			;7471	95		.
	jp nc,l7478h		;7472	d2 78 74	. x t
	ld a,(bc)		;7475	0a		.
	ld l,a			;7476	6f		o
	xor a			;7477	af		.
l7478h:
	ld e,a			;7478	5f		_
	ld d,000h		;7479	16 00		. .
	inc de			;747b	13		.
	jp l745bh		;747c	c3 5b 74	. [ t
sub_747fh:
	call sub_6c17h		;747f	cd 17 6c	. . l
	ld a,d			;7482	7a		z
	or h			;7483	b4		.
	jp nz,068d8h		;7484	c2 d8 68	. . h
sub_7487h:
	push bc			;7487	c5		.
	push de			;7488	d5		.
	ld a,d			;7489	7a		z
	or e			;748a	b3		.
	jp z,l748fh		;748b	ca 8f 74	. . t
	dec de			;748e	1b		.
l748fh:
	ld a,(bc)		;748f	0a		.
	cp e			;7490	bb		.
	jp nc,l7495h		;7491	d2 95 74	. . t
	ld e,a			;7494	5f		_
l7495h:
	sub e			;7495	93		.
	cp l			;7496	bd		.
	jp nc,l749bh		;7497	d2 9b 74	. . t
	ld l,a			;749a	6f		o
l749bh:
	inc bc			;749b	03		.
	ld a,(bc)		;749c	0a		.
	add a,e			;749d	83		.
	ld e,a			;749e	5f		_
	inc bc			;749f	03		.
	ld a,(bc)		;74a0	0a		.
	adc a,000h		;74a1	ce 00		. .
	ld d,a			;74a3	57		W
	ld a,l			;74a4	7d		}
	ex de,hl		;74a5	eb		.
	call sub_78c6h		;74a6	cd c6 78	. . x
	pop de			;74a9	d1		.
	ex (sp),hl		;74aa	e3		.
	call sub_78d7h		;74ab	cd d7 78	. . x
	ld b,h			;74ae	44		D
	ld c,l			;74af	4d		M
	pop hl			;74b0	e1		.
	ret			;74b1	c9		.
	ex (sp),hl		;74b2	e3		.
	push de			;74b3	d5		.
	call sub_9137h		;74b4	cd 37 91	. 7 .
	ld a,(l9287h+1)		;74b7	3a 88 92	: . .
	and a			;74ba	a7		.
	jp z,l74c2h		;74bb	ca c2 74	. . t
	add a,(hl)		;74be	86		.
	ld (l9287h+1),a		;74bf	32 88 92	2 . .
l74c2h:
	inc hl			;74c2	23		#
	pop de			;74c3	d1		.
	ex (sp),hl		;74c4	e3		.
	ret nc			;74c5	d0		.
	jp 068d5h		;74c6	c3 d5 68	. . h
sub_74c9h:
	ld a,(l9287h+1)		;74c9	3a 88 92	: . .
	ex (sp),hl		;74cc	e3		.
	and a			;74cd	a7		.
	jp z,l74d5h		;74ce	ca d5 74	. . t
	add a,(hl)		;74d1	86		.
	ld (l9287h+1),a		;74d2	32 88 92	2 . .
l74d5h:
	inc hl			;74d5	23		#
	ex (sp),hl		;74d6	e3		.
	ret nc			;74d7	d0		.
	jp 068d5h		;74d8	c3 d5 68	. . h
; Runtime entry: BASCOM $SASA, string assignment
string_assign:
	call sub_6c17h		;74db	cd 17 6c	. . l
sub_74deh:
	push bc			;74de	c5		.
	call sub_78a0h		;74df	cd a0 78	. . x
	call nc,sub_7518h	;74e2	d4 18 75	. . u
	ex de,hl		;74e5	eb		.
	ld a,(hl)		;74e6	7e		~
	inc hl			;74e7	23		#
	or (hl)			;74e8	b6		.
	inc hl			;74e9	23		#
	or (hl)			;74ea	b6		.
	dec hl			;74eb	2b		+
	dec hl			;74ec	2b		+
	call nz,07957h		;74ed	c4 57 79	. W y
	push de			;74f0	d5		.
	ld a,003h		;74f1	3e 03		> .
	call sub_9177h		;74f3	cd 77 91	. w .
	dec hl			;74f6	2b		+
	ld d,(hl)		;74f7	56		V
	dec hl			;74f8	2b		+
	ld e,(hl)		;74f9	5e		^
	dec hl			;74fa	2b		+
	ex de,hl		;74fb	eb		.
	ld a,(de)		;74fc	1a		.
	or a			;74fd	b7		.
	jp z,l750bh		;74fe	ca 0b 75	. . u
	dec hl			;7501	2b		+
	ld (hl),d		;7502	72		r
	dec hl			;7503	2b		+
	ld (hl),e		;7504	73		s
	pop hl			;7505	e1		.
	call sub_79a1h		;7506	cd a1 79	. . y
	pop bc			;7509	c1		.
	ret			;750a	c9		.
l750bh:
	pop hl			;750b	e1		.
	pop bc			;750c	c1		.
	ret			;750d	c9		.
sub_750eh:
	call sub_6c17h		;750e	cd 17 6c	. . l
	push de			;7511	d5		.
	ex de,hl		;7512	eb		.
	call sub_74deh		;7513	cd de 74	. . t
	pop de			;7516	d1		.
	ret			;7517	c9		.
sub_7518h:
	ld a,(hl)		;7518	7e		~
	inc hl			;7519	23		#
	push de			;751a	d5		.
	ld e,(hl)		;751b	5e		^
	inc hl			;751c	23		#
	ld d,(hl)		;751d	56		V
	ex de,hl		;751e	eb		.
	pop de			;751f	d1		.
	jp sub_78c6h		;7520	c3 c6 78	. . x
l7523h:
	inc hl			;7523	23		#
sub_7524h:
	xor a			;7524	af		.
	jp l752ah		;7525	c3 2a 75	. * u
	ld a,001h		;7528	3e 01		> .
l752ah:
	ld (l7523h),a		;752a	32 23 75	2 # u
	ld a,h			;752d	7c		|
	and a			;752e	a7		.
	jp nz,l7565h		;752f	c2 65 75	. e u
	dec hl			;7532	2b		+
	ld a,l			;7533	7d		}
	add hl,hl		;7534	29		)
	pop de			;7535	d1		.
	push de			;7536	d5		.
	ex de,hl		;7537	eb		.
	ld c,(hl)		;7538	4e		N
	inc hl			;7539	23		#
	ld b,000h		;753a	06 00		. .
	cp c			;753c	b9		.
	jp nc,l7561h		;753d	d2 61 75	. a u
	ex de,hl		;7540	eb		.
	add hl,de		;7541	19		.
	ld a,(hl)		;7542	7e		~
	inc hl			;7543	23		#
	ld h,(hl)		;7544	66		f
	ld l,a			;7545	6f		o
	ex de,hl		;7546	eb		.
	add hl,bc		;7547	09		.
	add hl,bc		;7548	09		.
	ex (sp),hl		;7549	e3		.
	ex de,hl		;754a	eb		.
	ld a,(l7523h)		;754b	3a 23 75	: # u
	and a			;754e	a7		.
	jp nz,l7554h		;754f	c2 54 75	. T u
	pop af			;7552	f1		.
	jp (hl)			;7553	e9		.
l7554h:
	push hl			;7554	e5		.
	ld hl,00002h		;7555	21 02 00	! . .
	add hl,sp		;7558	39		9
	ld (l6802h+1),hl	;7559	22 03 68	" . h
	ld hl,06809h		;755c	21 09 68	! . h
	inc (hl)		;755f	34		4
	ret			;7560	c9		.
l7561h:
	add hl,bc		;7561	09		.
	add hl,bc		;7562	09		.
	pop af			;7563	f1		.
	jp (hl)			;7564	e9		.
l7565h:
	pop hl			;7565	e1		.
	ld a,(hl)		;7566	7e		~
	add a,a			;7567	87		.
	call sub_9172h		;7568	cd 72 91	. r .
	inc hl			;756b	23		#
	push hl			;756c	e5		.
	jp 068d8h		;756d	c3 d8 68	. . h
sub_7570h:
	call sub_6c17h		;7570	cd 17 6c	. . l
	push de			;7573	d5		.
	ld de,00020h		;7574	11 20 00	.   .
	ex de,hl		;7577	eb		.
	call sub_7593h		;7578	cd 93 75	. . u
	pop de			;757b	d1		.
	ret			;757c	c9		.
	ld a,(hl)		;757d	7e		~
	and a			;757e	a7		.
	jp z,068d8h		;757f	ca d8 68	. . h
	push hl			;7582	e5		.
	inc hl			;7583	23		#
	ld a,(hl)		;7584	7e		~
	inc hl			;7585	23		#
	ld h,(hl)		;7586	66		f
	ld l,a			;7587	6f		o
	ld l,(hl)		;7588	6e		n
	ld h,000h		;7589	26 00		& .
	ex (sp),hl		;758b	e3		.
	call sub_78d7h		;758c	cd d7 78	. . x
	pop hl			;758f	e1		.
	call sub_6c17h		;7590	cd 17 6c	. . l
sub_7593h:
	push de			;7593	d5		.
	ex de,hl		;7594	eb		.
	ld a,d			;7595	7a		z
	or h			;7596	b4		.
	jp nz,l75afh		;7597	c2 af 75	. . u
	ld a,l			;759a	7d		}
	push de			;759b	d5		.
	call sub_785eh		;759c	cd 5e 78	. ^ x
	ld a,(hl)		;759f	7e		~
	ex (sp),hl		;75a0	e3		.
	ex de,hl		;75a1	eb		.
l75a2h:
	sub 001h		;75a2	d6 01		. .
	jp c,l75ach		;75a4	da ac 75	. . u
	ld (hl),e		;75a7	73		s
	inc hl			;75a8	23		#
	jp l75a2h		;75a9	c3 a2 75	. . u
l75ach:
	pop hl			;75ac	e1		.
	pop de			;75ad	d1		.
	ret			;75ae	c9		.
l75afh:
	call sub_6c21h		;75af	cd 21 6c	. ! l
	jp 068d8h		;75b2	c3 d8 68	. . h
; Runtime character-code to one-character string conversion
character_string:
	call sub_6c17h		;75b5	cd 17 6c	. . l
	ld a,h			;75b8	7c		|
	and a			;75b9	a7		.
	jp nz,068d8h		;75ba	c2 d8 68	. . h
	push hl			;75bd	e5		.
	ld hl,00000h		;75be	21 00 00	! . .
	add hl,sp		;75c1	39		9
	ld a,001h		;75c2	3e 01		> .
	call sub_78c6h		;75c4	cd c6 78	. . x
	pop af			;75c7	f1		.
	ret			;75c8	c9		.
sub_75c9h:
	ex de,hl		;75c9	eb		.
	ex (sp),hl		;75ca	e3		.
	push de			;75cb	d5		.
	ld e,(hl)		;75cc	5e		^
	inc hl			;75cd	23		#
	ld d,(hl)		;75ce	56		V
	inc hl			;75cf	23		#
	ex (sp),hl		;75d0	e3		.
l75d1h:
	call sub_6c17h		;75d1	cd 17 6c	. . l
	call sub_75eah		;75d4	cd ea 75	. . u
	ex de,hl		;75d7	eb		.
	pop hl			;75d8	e1		.
	ex (sp),hl		;75d9	e3		.
	ex de,hl		;75da	eb		.
	ret			;75db	c9		.
	call sub_6c17h		;75dc	cd 17 6c	. . l
sub_75dfh:
	push bc			;75df	c5		.
	push de			;75e0	d5		.
	call sub_9a7dh		;75e1	cd 7d 9a	. } .
	pop de			;75e4	d1		.
	pop bc			;75e5	c1		.
	ret			;75e6	c9		.
	call sub_6c17h		;75e7	cd 17 6c	. . l
sub_75eah:
	push de			;75ea	d5		.
	ex de,hl		;75eb	eb		.
	call sub_75dfh		;75ec	cd df 75	. . u
	pop de			;75ef	d1		.
	ret			;75f0	c9		.
	ex de,hl		;75f1	eb		.
	ex (sp),hl		;75f2	e3		.
	push de			;75f3	d5		.
	ld e,(hl)		;75f4	5e		^
	inc hl			;75f5	23		#
	ld d,(hl)		;75f6	56		V
	ex (sp),hl		;75f7	e3		.
	ex de,hl		;75f8	eb		.
	jp l75d1h		;75f9	c3 d1 75	. . u
sub_75fch:
	ex (sp),hl		;75fc	e3		.
	push de			;75fd	d5		.
	ld e,(hl)		;75fe	5e		^
	inc hl			;75ff	23		#
	push hl			;7600	e5		.
	call sub_912ch		;7601	cd 2c 91	. , .
	ld de,l9285h		;7604	11 85 92	. . .
	call sub_9154h		;7607	cd 54 91	. T .
	pop hl			;760a	e1		.
	pop de			;760b	d1		.
	ex (sp),hl		;760c	e3		.
	ret			;760d	c9		.
sub_760eh:
	push de			;760e	d5		.
	push bc			;760f	c5		.
	push hl			;7610	e5		.
	call sub_9a5dh		;7611	cd 5d 9a	. ] .
	pop hl			;7614	e1		.
	pop bc			;7615	c1		.
	pop de			;7616	d1		.
	ret			;7617	c9		.
sub_7618h:
	call sub_6c17h		;7618	cd 17 6c	. . l
	push de			;761b	d5		.
	push bc			;761c	c5		.
	call sub_762eh		;761d	cd 2e 76	. . v
	pop bc			;7620	c1		.
	pop de			;7621	d1		.
	ret			;7622	c9		.
sub_7623h:
	call sub_6c17h		;7623	cd 17 6c	. . l
	push de			;7626	d5		.
	push bc			;7627	c5		.
	call sub_763ah		;7628	cd 3a 76	. : v
	pop bc			;762b	c1		.
	pop de			;762c	d1		.
	ret			;762d	c9		.
sub_762eh:
	ld hl,l6c2dh		;762e	21 2d 6c	! - l
	call sub_987ch		;7631	cd 7c 98	. | .
	call sub_99f5h		;7634	cd f5 99	. . .
	jp l96dfh		;7637	c3 df 96	. . .
sub_763ah:
	ld hl,l6c29h		;763a	21 29 6c	! ) l
	call sub_9507h		;763d	cd 07 95	. . .
	call sub_935ch		;7640	cd 5c 93	. \ .
	jp l96a4h		;7643	c3 a4 96	. . .
; Runtime integer remainder with an inline 16-bit divisor
integer_mod_inline:
	ex de,hl		;7646	eb		.
	ex (sp),hl		;7647	e3		.
	push de			;7648	d5		.
	ld e,(hl)		;7649	5e		^
	inc hl			;764a	23		#
	ld d,(hl)		;764b	56		V
	inc hl			;764c	23		#
	ex (sp),hl		;764d	e3		.
l764eh:
	call sub_6c17h		;764e	cd 17 6c	. . l
	call sub_7666h		;7651	cd 66 76	. f v
	ex de,hl		;7654	eb		.
	pop hl			;7655	e1		.
	ex (sp),hl		;7656	e3		.
	ex de,hl		;7657	eb		.
	ret			;7658	c9		.
	call sub_6c17h		;7659	cd 17 6c	. . l
	push de			;765c	d5		.
	ex de,hl		;765d	eb		.
	call sub_7666h		;765e	cd 66 76	. f v
	pop de			;7661	d1		.
	ret			;7662	c9		.
	call sub_6c17h		;7663	cd 17 6c	. . l
sub_7666h:
	push bc			;7666	c5		.
	push de			;7667	d5		.
	ld a,d			;7668	7a		z
	or e			;7669	b3		.
	jp z,l7680h		;766a	ca 80 76	. . v
	ld a,h			;766d	7c		|
	or l			;766e	b5		.
	jp z,l7680h		;766f	ca 80 76	. . v
	ld a,h			;7672	7c		|
	or a			;7673	b7		.
	push af			;7674	f5		.
	push de			;7675	d5		.
	ex de,hl		;7676	eb		.
	call sub_9a7dh		;7677	cd 7d 9a	. } .
	pop hl			;767a	e1		.
	pop af			;767b	f1		.
	call m,sub_9aa4h	;767c	fc a4 9a	. . .
	ex de,hl		;767f	eb		.
l7680h:
	pop de			;7680	d1		.
	pop bc			;7681	c1		.
	ret			;7682	c9		.
	ex de,hl		;7683	eb		.
	ex (sp),hl		;7684	e3		.
	push de			;7685	d5		.
	ld e,(hl)		;7686	5e		^
	inc hl			;7687	23		#
	ld d,(hl)		;7688	56		V
	ex (sp),hl		;7689	e3		.
	ex de,hl		;768a	eb		.
	jp l764eh		;768b	c3 4e 76	. N v
; Runtime entry: BASCOM $IMUG, HL multiplied by inline 16-bit operand
integer_mul_inline:
	ex de,hl		;768e	eb		.
	ex (sp),hl		;768f	e3		.
	push de			;7690	d5		.
	ld e,(hl)		;7691	5e		^
	inc hl			;7692	23		#
	ld d,(hl)		;7693	56		V
	inc hl			;7694	23		#
	ex (sp),hl		;7695	e3		.
	call sub_769eh		;7696	cd 9e 76	. . v
	ex de,hl		;7699	eb		.
	pop hl			;769a	e1		.
	ex (sp),hl		;769b	e3		.
	ex de,hl		;769c	eb		.
	ret			;769d	c9		.
sub_769eh:
	push de			;769e	d5		.
	push bc			;769f	c5		.
	call sub_9ac9h		;76a0	cd c9 9a	. . .
	pop bc			;76a3	c1		.
	pop de			;76a4	d1		.
	ret			;76a5	c9		.
sub_76a6h:
	push bc			;76a6	c5		.
	push de			;76a7	d5		.
	push hl			;76a8	e5		.
	push af			;76a9	f5		.
	ld a,(de)		;76aa	1a		.
	ld b,a			;76ab	47		G
	ld c,(hl)		;76ac	4e		N
	and a			;76ad	a7		.
	jp z,l76d2h		;76ae	ca d2 76	. . v
	ld a,c			;76b1	79		y
	and a			;76b2	a7		.
	jp z,l76d2h		;76b3	ca d2 76	. . v
	inc de			;76b6	13		.
	inc hl			;76b7	23		#
	ld a,(hl)		;76b8	7e		~
	inc hl			;76b9	23		#
	ld h,(hl)		;76ba	66		f
	ld l,a			;76bb	6f		o
	ex de,hl		;76bc	eb		.
	ld a,(hl)		;76bd	7e		~
	inc hl			;76be	23		#
	ld h,(hl)		;76bf	66		f
	ld l,a			;76c0	6f		o
l76c1h:
	ld a,(de)		;76c1	1a		.
	cp (hl)			;76c2	be		.
	jp nz,l76dbh		;76c3	c2 db 76	. . v
	inc de			;76c6	13		.
	inc hl			;76c7	23		#
	dec b			;76c8	05		.
	jp z,l76d1h		;76c9	ca d1 76	. . v
	dec c			;76cc	0d		.
	jp nz,l76c1h		;76cd	c2 c1 76	. . v
	inc c			;76d0	0c		.
l76d1h:
	dec c			;76d1	0d		.
l76d2h:
	ld a,c			;76d2	79		y
	or b			;76d3	b0		.
	jp z,l76dbh		;76d4	ca db 76	. . v
	ld a,c			;76d7	79		y
	sub 001h		;76d8	d6 01		. .
	inc a			;76da	3c		<
l76dbh:
	ld l,001h		;76db	2e 01		. .
	jp c,l76e5h		;76dd	da e5 76	. . v
	add hl,hl		;76e0	29		)
	jp z,l76e5h		;76e1	ca e5 76	. . v
	add hl,hl		;76e4	29		)
l76e5h:
	pop af			;76e5	f1		.
	and l			;76e6	a5		.
	pop hl			;76e7	e1		.
	pop de			;76e8	d1		.
	pop bc			;76e9	c1		.
	push af			;76ea	f5		.
	call sub_78d7h		;76eb	cd d7 78	. . x
	ex de,hl		;76ee	eb		.
	call sub_78d7h		;76ef	cd d7 78	. . x
	pop af			;76f2	f1		.
	ret			;76f3	c9		.
l76f4h:
	nop			;76f4	00		.
l76f5h:
	ld bc,l5e19h		;76f5	01 19 5e	. . ^
	inc hl			;76f8	23		#
l76f9h:
	ld d,(hl)		;76f9	56		V
	push de			;76fa	d5		.
l76fbh:
	defb 0fdh,076h,000h ;illegal sequence	;76fb	fd 76 00	. v .
	ld (hl),a		;76fe	77		w
	rst 38h			;76ff	ff		.
	inc bc			;7700	03		.
	ld (hl),a		;7701	77		w
	jp c,l7706h		;7702	da 06 77	. . w
	add hl,de		;7705	19		.
l7706h:
	add hl,bc		;7706	09		.
	ld (hl),a		;7707	77		w
	sbc a,a			;7708	9f		.
	inc c			;7709	0c		.
	ld (hl),a		;770a	77		w
	ld (l770fh),hl		;770b	22 0f 77	" . w
	pop hl			;770e	e1		.
l770fh:
	ld (de),a		;770f	12		.
	ld (hl),a		;7710	77		w
	rst 38h			;7711	ff		.
	dec d			;7712	15		.
	ld (hl),a		;7713	77		w
	or l			;7714	b5		.
	jr l778eh		;7715	18 77		. w
	sbc a,a			;7717	9f		.
	dec de			;7718	1b		.
	ld (hl),a		;7719	77		w
	push hl			;771a	e5		.
	ld e,077h		;771b	1e 77		. w
	rrca			;771d	0f		.
	ld hl,l7c77h		;771e	21 77 7c	! w |
	inc h			;7721	24		$
	ld (hl),a		;7722	77		w
	ld a,l			;7723	7d		}
	daa			;7724	27		'
	ld (hl),a		;7725	77		w
	ld a,h			;7726	7c		|
	nop			;7727	00		.
	nop			;7728	00		.
	rst 30h			;7729	f7		.
sub_772ah:
	push bc			;772a	c5		.
l772bh:
	push de			;772b	d5		.
	ld e,a			;772c	5f		_
	ld d,000h		;772d	16 00		. .
	inc de			;772f	13		.
	inc de			;7730	13		.
	inc de			;7731	13		.
	ld hl,l76f4h		;7732	21 f4 76	! . v
	inc (hl)		;7735	34		4
	jp nz,l773ah		;7736	c2 3a 77	. : w
	dec (hl)		;7739	35		5
l773ah:
	ld hl,(l76f5h)		;773a	2a f5 76	* . v
l773dh:
	ld (l76f5h),hl		;773d	22 f5 76	" . v
	ld a,(hl)		;7740	7e		~
	inc hl			;7741	23		#
	ld c,(hl)		;7742	4e		N
	inc hl			;7743	23		#
	ld b,(hl)		;7744	46		F
	inc hl			;7745	23		#
	add a,a			;7746	87		.
	jp c,l777ah		;7747	da 7a 77	. z w
	jp m,l7754h		;774a	fa 54 77	. T w
	ld a,(bc)		;774d	0a		.
	call sub_9172h		;774e	cd 72 91	. r .
	jp l773dh		;7751	c3 3d 77	. = w
l7754h:
	ld a,c			;7754	79		y
	sub e			;7755	93		.
	ld a,b			;7756	78		x
	sbc a,d			;7757	9a		.
	jp nc,l775fh		;7758	d2 5f 77	. _ w
	add hl,bc		;775b	09		.
	jp l773dh		;775c	c3 3d 77	. = w
l775fh:
	push hl			;775f	e5		.
	add hl,de		;7760	19		.
	dec hl			;7761	2b		+
	dec hl			;7762	2b		+
	dec hl			;7763	2b		+
	ld (hl),040h		;7764	36 40		6 @
	inc hl			;7766	23		#
	ld a,c			;7767	79		y
	sub e			;7768	93		.
	ld (hl),a		;7769	77		w
	inc hl			;776a	23		#
	ld a,b			;776b	78		x
	sbc a,d			;776c	9a		.
	ld (hl),a		;776d	77		w
	pop hl			;776e	e1		.
	pop de			;776f	d1		.
	pop bc			;7770	c1		.
	dec hl			;7771	2b		+
	dec hl			;7772	2b		+
	dec hl			;7773	2b		+
	ld (hl),000h		;7774	36 00		6 .
	inc hl			;7776	23		#
	inc hl			;7777	23		#
	inc hl			;7778	23		#
	ret			;7779	c9		.
l777ah:
	ld hl,l76f4h		;777a	21 f4 76	! . v
	ld a,(hl)		;777d	7e		~
	ld (hl),000h		;777e	36 00		6 .
	cp 006h			;7780	fe 06		. .
	jp c,l778bh		;7782	da 8b 77	. . w
	call sub_77a0h		;7785	cd a0 77	. . w
	jp l773ah		;7788	c3 3a 77	. : w
l778bh:
	call sub_77eah		;778b	cd ea 77	. . w
l778eh:
	ld hl,(l76f5h)		;778e	2a f5 76	* . v
	inc hl			;7791	23		#
	ld a,(hl)		;7792	7e		~
	sub e			;7793	93		.
	inc hl			;7794	23		#
	ld a,(hl)		;7795	7e		~
	sbc a,d			;7796	9a		.
	jp nc,l773ah		;7797	d2 3a 77	. : w
	call sub_6c21h		;779a	cd 21 6c	. ! l
	jp 068cfh		;779d	c3 cf 68	. . h
sub_77a0h:
	push de			;77a0	d5		.
	ld hl,00000h		;77a1	21 00 00	! . .
	push hl			;77a4	e5		.
	ld b,000h		;77a5	06 00		. .
	ld hl,(l76f5h+2)	;77a7	2a f7 76	* . v
	ld (l76f5h),hl		;77aa	22 f5 76	" . v
l77adh:
	ld a,(hl)		;77ad	7e		~
	inc hl			;77ae	23		#
	ld e,(hl)		;77af	5e		^
	inc hl			;77b0	23		#
	ld d,(hl)		;77b1	56		V
	inc hl			;77b2	23		#
	add a,a			;77b3	87		.
	jp c,l77e7h		;77b4	da e7 77	. . w
	jp m,l77c6h		;77b7	fa c6 77	. . w
	ld a,(de)		;77ba	1a		.
	call sub_9172h		;77bb	cd 72 91	. r .
	pop de			;77be	d1		.
	ld de,00000h		;77bf	11 00 00	. . .
	push de			;77c2	d5		.
	jp l77adh		;77c3	c3 ad 77	. . w
l77c6h:
	ex (sp),hl		;77c6	e3		.
	ld a,h			;77c7	7c		|
	or l			;77c8	b5		.
	jp nz,l77d2h		;77c9	c2 d2 77	. . w
	pop hl			;77cc	e1		.
	push hl			;77cd	e5		.
	add hl,de		;77ce	19		.
	jp l77adh		;77cf	c3 ad 77	. . w
l77d2h:
	inc de			;77d2	13		.
	inc de			;77d3	13		.
	inc de			;77d4	13		.
	pop af			;77d5	f1		.
	dec hl			;77d6	2b		+
	dec hl			;77d7	2b		+
	ld a,(hl)		;77d8	7e		~
	add a,e			;77d9	83		.
	ld e,a			;77da	5f		_
	ld (hl),a		;77db	77		w
	inc hl			;77dc	23		#
	ld a,(hl)		;77dd	7e		~
	adc a,d			;77de	8a		.
	ld d,a			;77df	57		W
	ld (hl),a		;77e0	77		w
	inc hl			;77e1	23		#
	push hl			;77e2	e5		.
	add hl,de		;77e3	19		.
	jp l77adh		;77e4	c3 ad 77	. . w
l77e7h:
	pop de			;77e7	d1		.
	pop de			;77e8	d1		.
	ret			;77e9	c9		.
sub_77eah:
	push de			;77ea	d5		.
	call sub_77a0h		;77eb	cd a0 77	. . w
	ld hl,(l76f5h+2)	;77ee	2a f7 76	* . v
	ld b,h			;77f1	44		D
	ld c,l			;77f2	4d		M
l77f3h:
	ld a,(hl)		;77f3	7e		~
	inc hl			;77f4	23		#
	ld e,(hl)		;77f5	5e		^
	inc hl			;77f6	23		#
	ld d,(hl)		;77f7	56		V
	inc hl			;77f8	23		#
	add a,a			;77f9	87		.
	jp c,l7844h		;77fa	da 44 78	. D x
	jp p,l7804h		;77fd	f2 04 78	. . x
	add hl,de		;7800	19		.
	jp l77f3h		;7801	c3 f3 77	. . w
l7804h:
	dec hl			;7804	2b		+
	ld a,d			;7805	7a		z
	cp (hl)			;7806	be		.
	call nz,sub_790ah	;7807	c4 0a 79	. . y
	dec hl			;780a	2b		+
	ld a,e			;780b	7b		{
	cp (hl)			;780c	be		.
	call nz,sub_790ah	;780d	c4 0a 79	. . y
	inc hl			;7810	23		#
	inc hl			;7811	23		#
	xor a			;7812	af		.
	ld (bc),a		;7813	02		.
	inc bc			;7814	03		.
	ld a,e			;7815	7b		{
	ld (bc),a		;7816	02		.
	inc bc			;7817	03		.
	ld a,d			;7818	7a		z
	ld (bc),a		;7819	02		.
	inc bc			;781a	03		.
	ex de,hl		;781b	eb		.
	ld a,(hl)		;781c	7e		~
	inc hl			;781d	23		#
	ld (hl),c		;781e	71		q
	inc hl			;781f	23		#
	ld (hl),b		;7820	70		p
	ex de,hl		;7821	eb		.
	ld e,a			;7822	5f		_
	and a			;7823	a7		.
	jp z,l77f3h		;7824	ca f3 77	. . w
	ld a,c			;7827	79		y
	cp l			;7828	bd		.
	jp nz,l7839h		;7829	c2 39 78	. 9 x
	ld a,b			;782c	78		x
	cp h			;782d	bc		.
	jp nz,l7839h		;782e	c2 39 78	. 9 x
	ld d,000h		;7831	16 00		. .
	add hl,de		;7833	19		.
	ld b,h			;7834	44		D
	ld c,l			;7835	4d		M
	jp l77f3h		;7836	c3 f3 77	. . w
l7839h:
	ld a,(hl)		;7839	7e		~
	ld (bc),a		;783a	02		.
	inc bc			;783b	03		.
	inc hl			;783c	23		#
	dec e			;783d	1d		.
	jp nz,l7839h		;783e	c2 39 78	. 9 x
	jp l77f3h		;7841	c3 f3 77	. . w
l7844h:
	ld e,c			;7844	59		Y
	ld d,b			;7845	50		P
	dec hl			;7846	2b		+
	dec hl			;7847	2b		+
	dec hl			;7848	2b		+
	ex de,hl		;7849	eb		.
	ld (l76f5h),hl		;784a	22 f5 76	" . v
	ld (hl),040h		;784d	36 40		6 @
	inc hl			;784f	23		#
	inc hl			;7850	23		#
	inc hl			;7851	23		#
	ld a,e			;7852	7b		{
	sub l			;7853	95		.
	ld e,a			;7854	5f		_
	ld a,d			;7855	7a		z
	sbc a,h			;7856	9c		.
	ld d,a			;7857	57		W
	dec hl			;7858	2b		+
	ld (hl),d		;7859	72		r
	dec hl			;785a	2b		+
	ld (hl),e		;785b	73		s
	pop de			;785c	d1		.
	ret			;785d	c9		.
sub_785eh:
	or a			;785e	b7		.
	jp z,l7893h		;785f	ca 93 78	. . x
	push af			;7862	f5		.
	ld hl,(l76fbh)		;7863	2a fb 76	* . v
	ld a,h			;7866	7c		|
	or l			;7867	b5		.
	jp nz,l7871h		;7868	c2 71 78	. q x
	call sub_6c21h		;786b	cd 21 6c	. ! l
	jp 068d2h		;786e	c3 d2 68	. . h
l7871h:
	pop af			;7871	f1		.
	push af			;7872	f5		.
	push hl			;7873	e5		.
	call sub_772ah		;7874	cd 2a 77	. * w
	ex (sp),hl		;7877	e3		.
	ld e,(hl)		;7878	5e		^
	inc hl			;7879	23		#
	ld d,(hl)		;787a	56		V
	dec hl			;787b	2b		+
	ex de,hl		;787c	eb		.
	ld (l76fbh),hl		;787d	22 fb 76	" . v
	pop hl			;7880	e1		.
	pop af			;7881	f1		.
	ex de,hl		;7882	eb		.
	ld (hl),a		;7883	77		w
	inc hl			;7884	23		#
	ld (hl),e		;7885	73		s
	inc hl			;7886	23		#
	ld (hl),d		;7887	72		r
	dec hl			;7888	2b		+
	dec hl			;7889	2b		+
	ex de,hl		;788a	eb		.
	dec hl			;788b	2b		+
	ld (hl),d		;788c	72		r
	dec hl			;788d	2b		+
	ld (hl),e		;788e	73		s
	inc hl			;788f	23		#
	inc hl			;7890	23		#
	ex de,hl		;7891	eb		.
	ret			;7892	c9		.
l7893h:
	ld hl,l789ah		;7893	21 9a 78	! . x
	ld de,l789fh		;7896	11 9f 78	. . x
	ret			;7899	c9		.
l789ah:
	nop			;789a	00		.
	nop			;789b	00		.
	nop			;789c	00		.
	nop			;789d	00		.
	nop			;789e	00		.
l789fh:
	nop			;789f	00		.
sub_78a0h:
	push de			;78a0	d5		.
	ex de,hl		;78a1	eb		.
	ld hl,(l7a32h)		;78a2	2a 32 7a	* 2 z
	ld a,e			;78a5	7b		{
	sub l			;78a6	95		.
	ld a,d			;78a7	7a		z
	sbc a,h			;78a8	9c		.
	ld hl,(l7a32h+2)	;78a9	2a 34 7a	* 4 z
	ex de,hl		;78ac	eb		.
	ccf			;78ad	3f		?
	jp nc,l78b5h		;78ae	d2 b5 78	. . x
	ld a,l			;78b1	7d		}
	sub e			;78b2	93		.
	ld a,h			;78b3	7c		|
	sbc a,d			;78b4	9a		.
l78b5h:
	pop de			;78b5	d1		.
	ret			;78b6	c9		.
sub_78b7h:
	push hl			;78b7	e5		.
	push bc			;78b8	c5		.
	ld c,0ffh		;78b9	0e ff		. .
l78bbh:
	ld a,(hl)		;78bb	7e		~
	inc hl			;78bc	23		#
	inc c			;78bd	0c		.
	and a			;78be	a7		.
	jp nz,l78bbh		;78bf	c2 bb 78	. . x
	ld a,c			;78c2	79		y
	pop bc			;78c3	c1		.
	pop hl			;78c4	e1		.
	ret			;78c5	c9		.
sub_78c6h:
	push bc			;78c6	c5		.
	push de			;78c7	d5		.
	ld b,a			;78c8	47		G
	push hl			;78c9	e5		.
	call sub_785eh		;78ca	cd 5e 78	. ^ x
	ex (sp),hl		;78cd	e3		.
	ld a,b			;78ce	78		x
	ex de,hl		;78cf	eb		.
	call sub_9177h		;78d0	cd 77 91	. w .
	pop hl			;78d3	e1		.
	pop de			;78d4	d1		.
	pop bc			;78d5	c1		.
	ret			;78d6	c9		.
sub_78d7h:
	call sub_78a0h		;78d7	cd a0 78	. . x
	ret nc			;78da	d0		.
	call 07957h		;78db	cd 57 79	. W y
	jp sub_79a1h		;78de	c3 a1 79	. . y
sub_78e1h:
	push bc			;78e1	c5		.
	push de			;78e2	d5		.
	push hl			;78e3	e5		.
	ld hl,(l7a32h)		;78e4	2a 32 7a	* 2 z
l78e7h:
	ex de,hl		;78e7	eb		.
	ld hl,(l7a32h+2)	;78e8	2a 34 7a	* 4 z
	ex de,hl		;78eb	eb		.
	call sub_9185h		;78ec	cd 85 91	. . .
	jp z,l7906h		;78ef	ca 06 79	. . y
	call sub_79dah		;78f2	cd da 79	. . y
	jp z,l7900h		;78f5	ca 00 79	. . y
	call 07957h		;78f8	cd 57 79	. W y
	push hl			;78fb	e5		.
	call sub_79a1h		;78fc	cd a1 79	. . y
	pop hl			;78ff	e1		.
l7900h:
	inc hl			;7900	23		#
	inc hl			;7901	23		#
	inc hl			;7902	23		#
	jp l78e7h		;7903	c3 e7 78	. . x
l7906h:
	pop hl			;7906	e1		.
	pop de			;7907	d1		.
sub_7908h:
	pop bc			;7908	c1		.
	ret			;7909	c9		.
sub_790ah:
	call sub_792ch		;790a	cd 2c 79	. , y
	call sub_7a46h		;790d	cd 46 7a	. F z
	jr nz,l7976h		;7910	20 64		  d
	ld (hl),l		;7912	75		u
	ld (hl),d		;7913	72		r
	ld l,c			;7914	69		i
	ld l,(hl)		;7915	6e		n
	ld h,a			;7916	67		g
	jr nz,l7960h		;7917	20 47		  G
	ld l,043h		;7919	2e 43		. C
	ld l,00dh		;791b	2e 0d		. .
	adc a,d			;791d	8a		.
	jp l6751h		;791e	c3 51 67	. Q g
l7921h:
	call sub_792ch		;7921	cd 2c 79	. , y
	call sub_7a46h		;7924	cd 46 7a	. F z
	dec c			;7927	0d		.
	adc a,d			;7928	8a		.
	jp l6751h		;7929	c3 51 67	. Q g
sub_792ch:
	call sub_7a46h		;792c	cd 46 7a	. F z
	dec c			;792f	0d		.
	ld a,(bc)		;7930	0a		.
	ld c,c			;7931	49		I
	ld l,(hl)		;7932	6e		n
	ld (hl),h		;7933	74		t
	ld h,l			;7934	65		e
	ld (hl),d		;7935	72		r
	ld l,(hl)		;7936	6e		n
	ld h,c			;7937	61		a
	ld l,h			;7938	6c		l
	jr nz,l7980h		;7939	20 45		  E
	ld (hl),d		;793b	72		r
	ld (hl),d		;793c	72		r
	ld l,a			;793d	6f		o
	ld (hl),d		;793e	72		r
	jr nz,l796eh		;793f	20 2d		  -
	jr nz,l7996h		;7941	20 53		  S
	ld (hl),h		;7943	74		t
	ld (hl),d		;7944	72		r
	ld l,c			;7945	69		i
	ld l,(hl)		;7946	6e		n
	ld h,a			;7947	67		g
	jr nz,l799dh		;7948	20 53		  S
	ld (hl),b		;794a	70		p
	ld h,c			;794b	61		a
	ld h,e			;794c	63		c
	ld h,l			;794d	65		e
	jr nz,l7993h		;794e	20 43		  C
	ld l,a			;7950	6f		o
	ld (hl),d		;7951	72		r
	ld (hl),d		;7952	72		r
	ld (hl),l		;7953	75		u
	ld (hl),b		;7954	70		p
	call p,sub_23c9h	;7955	f4 c9 23	. . #
	push bc			;7958	c5		.
	ld c,(hl)		;7959	4e		N
	inc hl			;795a	23		#
	ld b,(hl)		;795b	46		F
	push hl			;795c	e5		.
	ld hl,(l76f5h+2)	;795d	2a f7 76	* . v
l7960h:
	ld a,c			;7960	79		y
	sub l			;7961	95		.
	ld a,b			;7962	78		x
	sbc a,h			;7963	9c		.
	jp c,l799ch		;7964	da 9c 79	. . y
	ld hl,(l76f9h)		;7967	2a f9 76	* . v
	ld a,c			;796a	79		y
	sub l			;796b	95		.
	ld a,b			;796c	78		x
	sbc a,h			;796d	9c		.
l796eh:
	jp nc,l799ch		;796e	d2 9c 79	. . y
	pop hl			;7971	e1		.
	push de			;7972	d5		.
	dec hl			;7973	2b		+
	dec hl			;7974	2b		+
	push hl			;7975	e5		.
l7976h:
	ld h,b			;7976	60		`
	ld l,c			;7977	69		i
	dec hl			;7978	2b		+
	ld d,(hl)		;7979	56		V
	dec hl			;797a	2b		+
	ld e,(hl)		;797b	5e		^
	pop hl			;797c	e1		.
	call sub_9185h		;797d	cd 85 91	. . .
l7980h:
	jp nz,l7921h		;7980	c2 21 79	. ! y
	inc hl			;7983	23		#
	inc hl			;7984	23		#
	pop de			;7985	d1		.
	ld (hl),000h		;7986	36 00		6 .
	dec hl			;7988	2b		+
	ld (hl),000h		;7989	36 00		6 .
	dec hl			;798b	2b		+
	ld a,(hl)		;798c	7e		~
	ld (hl),000h		;798d	36 00		6 .
	dec bc			;798f	0b		.
	dec bc			;7990	0b		.
	ld (bc),a		;7991	02		.
	dec bc			;7992	0b		.
l7993h:
	ld a,040h		;7993	3e 40		> @
	ld (bc),a		;7995	02		.
l7996h:
	inc bc			;7996	03		.
	inc bc			;7997	03		.
	xor a			;7998	af		.
	ld (bc),a		;7999	02		.
	pop bc			;799a	c1		.
	ret			;799b	c9		.
l799ch:
	pop hl			;799c	e1		.
l799dh:
	dec hl			;799d	2b		+
	dec hl			;799e	2b		+
	pop bc			;799f	c1		.
	ret			;79a0	c9		.
sub_79a1h:
	push de			;79a1	d5		.
	ex de,hl		;79a2	eb		.
	ld hl,(l76fbh)		;79a3	2a fb 76	* . v
	ex de,hl		;79a6	eb		.
	ld (l76fbh),hl		;79a7	22 fb 76	" . v
	ld (hl),e		;79aa	73		s
	inc hl			;79ab	23		#
	ld (hl),d		;79ac	72		r
	dec hl			;79ad	2b		+
	pop de			;79ae	d1		.
	ret			;79af	c9		.
sub_79b0h:
	push de			;79b0	d5		.
	push bc			;79b1	c5		.
	call sub_77eah		;79b2	cd ea 77	. . w
	pop bc			;79b5	c1		.
	ld hl,(l76f5h)		;79b6	2a f5 76	* . v
	inc hl			;79b9	23		#
	ld a,(hl)		;79ba	7e		~
	sub c			;79bb	91		.
	ld e,a			;79bc	5f		_
	inc hl			;79bd	23		#
	ld a,(hl)		;79be	7e		~
	sbc a,b			;79bf	98		.
	ld d,a			;79c0	57		W
	jp nc,l79cah		;79c1	d2 ca 79	. . y
	call sub_6c21h		;79c4	cd 21 6c	. ! l
	jp 068deh		;79c7	c3 de 68	. . h
l79cah:
	ld (hl),d		;79ca	72		r
	dec hl			;79cb	2b		+
	ld (hl),e		;79cc	73		s
	inc hl			;79cd	23		#
	inc hl			;79ce	23		#
	add hl,de		;79cf	19		.
	ld (hl),080h		;79d0	36 80		6 .
	ld (l76f9h),hl		;79d2	22 f9 76	" . v
	inc hl			;79d5	23		#
	inc hl			;79d6	23		#
	inc hl			;79d7	23		#
	pop de			;79d8	d1		.
	ret			;79d9	c9		.
sub_79dah:
	ex de,hl		;79da	eb		.
	ld hl,l76fbh		;79db	21 fb 76	! . v
l79deh:
	ld a,(hl)		;79de	7e		~
	inc hl			;79df	23		#
	ld h,(hl)		;79e0	66		f
	ld l,a			;79e1	6f		o
	or h			;79e2	b4		.
	jp z,l79eeh		;79e3	ca ee 79	. . y
	call sub_9185h		;79e6	cd 85 91	. . .
	jp nz,l79deh		;79e9	c2 de 79	. . y
	ex de,hl		;79ec	eb		.
	ret			;79ed	c9		.
l79eeh:
	inc a			;79ee	3c		<
	ex de,hl		;79ef	eb		.
	ret			;79f0	c9		.
l79f1h:
	ld hl,(l76f5h+2)	;79f1	2a f7 76	* . v
	ld (l76f5h),hl		;79f4	22 f5 76	" . v
	ex de,hl		;79f7	eb		.
	ld hl,(l76f9h)		;79f8	2a f9 76	* . v
	ld a,l			;79fb	7d		}
	sub e			;79fc	93		.
	ld l,a			;79fd	6f		o
	ld a,h			;79fe	7c		|
	sbc a,d			;79ff	9a		.
	ld h,a			;7a00	67		g
	ex de,hl		;7a01	eb		.
	ld (hl),040h		;7a02	36 40		6 @
	inc hl			;7a04	23		#
	ld (hl),e		;7a05	73		s
	inc hl			;7a06	23		#
	ld (hl),d		;7a07	72		r
	inc hl			;7a08	23		#
	add hl,de		;7a09	19		.
	ld (hl),080h		;7a0a	36 80		6 .
	ld (l76f9h),hl		;7a0c	22 f9 76	" . v
	ld hl,(l7a32h+2)	;7a0f	2a 34 7a	* 4 z
	ex de,hl		;7a12	eb		.
	ld hl,(l7a32h)		;7a13	2a 32 7a	* 2 z
	ld (l76fbh),hl		;7a16	22 fb 76	" . v
l7a19h:
	ld a,l			;7a19	7d		}
	add a,003h		;7a1a	c6 03		. .
	ld (hl),a		;7a1c	77		w
	ld a,000h		;7a1d	3e 00		> .
	adc a,h			;7a1f	8c		.
	inc hl			;7a20	23		#
	ld (hl),a		;7a21	77		w
	inc hl			;7a22	23		#
	inc hl			;7a23	23		#
	call sub_9185h		;7a24	cd 85 91	. . .
	jp nz,l7a19h		;7a27	c2 19 7a	. . z
	dec hl			;7a2a	2b		+
	dec hl			;7a2b	2b		+
	ld (hl),000h		;7a2c	36 00		6 .
	dec hl			;7a2e	2b		+
	ld (hl),000h		;7a2f	36 00		6 .
	ret			;7a31	c9		.
l7a32h:
	defb 0fdh,076h,02ah ;illegal sequence	;7a32	fd 76 2a	. v *
	ld (hl),a		;7a35	77		w
l7a36h:
	sbc a,l			;7a36	9d		.
	sbc a,h			;7a37	9c		.
sub_7a38h:
	and a			;7a38	a7		.
	ret z			;7a39	c8		.
l7a3ah:
	push af			;7a3a	f5		.
	ld a,(hl)		;7a3b	7e		~
	call sub_90a2h		;7a3c	cd a2 90	. . .
	pop af			;7a3f	f1		.
	inc hl			;7a40	23		#
	dec a			;7a41	3d		=
	jp nz,l7a3ah		;7a42	c2 3a 7a	. : z
	ret			;7a45	c9		.
sub_7a46h:
	ex (sp),hl		;7a46	e3		.
	call sub_7a4ch		;7a47	cd 4c 7a	. L z
	ex (sp),hl		;7a4a	e3		.
	ret			;7a4b	c9		.
sub_7a4ch:
	ld a,(hl)		;7a4c	7e		~
	and 07fh		;7a4d	e6 7f		. .
	call sub_90a2h		;7a4f	cd a2 90	. . .
	cp (hl)			;7a52	be		.
	inc hl			;7a53	23		#
	ret nz			;7a54	c0		.
	jp sub_7a4ch		;7a55	c3 4c 7a	. L z
l7a58h:
	adc a,c			;7a58	89		.
l7a59h:
	rrca			;7a59	0f		.
l7a5ah:
	ld hl,(l0fb6h)		;7a5a	2a b6 0f	* . .
	ld (l0f8bh),hl		;7a5d	22 8b 0f	" . .
	ld hl,(l0fb6h)		;7a60	2a b6 0f	* . .
	call 05007h		;7a63	cd 07 50	. . P
	ld d,c			;7a66	51		Q
	nop			;7a67	00		.
	ex de,hl		;7a68	eb		.
	ld hl,(l0fb4h)		;7a69	2a b4 0f	* . .
	add hl,de		;7a6c	19		.
	add hl,hl		;7a6d	29		)
	ld de,l010ah		;7a6e	11 0a 01	. . .
	add hl,de		;7a71	19		.
	ld e,(hl)		;7a72	5e		^
	inc hl			;7a73	23		#
	ld d,(hl)		;7a74	56		V
	ex de,hl		;7a75	eb		.
l7a76h:
	ld (l0fc4h),hl		;7a76	22 c4 0f	" . .
	ld hl,(l0fc4h)		;7a79	2a c4 0f	* . .
	ld de,0fff6h		;7a7c	11 f6 ff	. . .
l7a7fh:
	add hl,de		;7a7f	19		.
l7a80h:
	ld a,h			;7a80	7c		|
	or l			;7a81	b5		.
l7a82h:
	jp nz,l509eh		;7a82	c2 9e 50	. . P
	ld hl,(0d5cdh)		;7a85	2a cd d5	* . .
	add a,e			;7a88	83		.
	jp p,l7aa7h		;7a89	f2 a7 7a	. . z
	ld hl,(l9285h)		;7a8c	2a 85 92	* . .
	ld a,l			;7a8f	7d		}
	cpl			;7a90	2f		/
	ld l,a			;7a91	6f		o
	ld a,h			;7a92	7c		|
	cpl			;7a93	2f		/
	ld h,a			;7a94	67		g
	inc hl			;7a95	23		#
	ld (l9285h),hl		;7a96	22 85 92	" . .
	ld a,h			;7a99	7c		|
	xor 080h		;7a9a	ee 80		. .
	or l			;7a9c	b5		.
	ret nz			;7a9d	c0		.
	call 07ad8h		;7a9e	cd d8 7a	. . z
	call sub_9a5dh		;7aa1	cd 5d 9a	. ] .
	jp l7aa7h		;7aa4	c3 a7 7a	. . z
l7aa7h:
	ld hl,l9287h		;7aa7	21 87 92	! . .
	ld a,(hl)		;7aaa	7e		~
	xor 080h		;7aab	ee 80		. .
	ld (hl),a		;7aad	77		w
	ret			;7aae	c9		.
sub_7aafh:
	xor a			;7aaf	af		.
	ld (l9287h+1),a		;7ab0	32 88 92	2 . .
	ret			;7ab3	c9		.
sub_7ab4h:
	call sub_83d5h		;7ab4	cd d5 83	. . .
	ret po			;7ab7	e0		.
	jp m,l7ac2h		;7ab8	fa c2 7a	. . z
sub_7abbh:
	call sub_96adh		;7abb	cd ad 96	. . .
	call 07ad8h		;7abe	cd d8 7a	. . z
	ret			;7ac1	c9		.
l7ac2h:
	ld hl,(l9285h)		;7ac2	2a 85 92	* . .
	call 07ad8h		;7ac5	cd d8 7a	. . z
	jp sub_9a5dh		;7ac8	c3 5d 9a	. ] .
sub_7acbh:
	call sub_83d5h		;7acb	cd d5 83	. . .
	ret nc			;7ace	d0		.
	call m,l7ac2h		;7acf	fc c2 7a	. . z
sub_7ad2h:
	call sub_968dh		;7ad2	cd 8d 96	. . .
sub_7ad5h:
	ld a,008h		;7ad5	3e 08		> .
	ld bc,0043eh		;7ad7	01 3e 04	. > .
	jp l7c7dh		;7ada	c3 7d 7c	. } |
l7addh:
	ld a,(hl)		;7add	7e		~
	or a			;7ade	b7		.
	ret z			;7adf	c8		.
	call sub_6739h		;7ae0	cd 39 67	. 9 g
	inc hl			;7ae3	23		#
	jp l7addh		;7ae4	c3 dd 7a	. . z
	jp sub_6739h		;7ae7	c3 39 67	. 9 g
	ld de,l7a76h		;7aea	11 76 7a	. v z
	ld hl,l928ah+1		;7aed	21 8b 92	! . .
	jp l7afbh		;7af0	c3 fb 7a	. . z
	ld a,08eh		;7af3	3e 8e		> .
	ld hl,l928ah+1		;7af5	21 8b 92	! . .
sub_7af8h:
	ld de,09281h		;7af8	11 81 92	. . .
l7afbh:
	ld c,007h		;7afb	0e 07		. .
	ld (l7b02h),a		;7afd	32 02 7b	2 . {
	xor a			;7b00	af		.
l7b01h:
	ld a,(de)		;7b01	1a		.
l7b02h:
	adc a,(hl)		;7b02	8e		.
	ld (de),a		;7b03	12		.
	inc de			;7b04	13		.
	inc hl			;7b05	23		#
	dec c			;7b06	0d		.
	jp nz,l7b01h		;7b07	c2 01 7b	. . {
	ret			;7b0a	c9		.
sub_7b0bh:
	ld hl,l928ah+1		;7b0b	21 8b 92	! . .
	jp sub_9507h		;7b0e	c3 07 95	. . .
sub_7b11h:
	ld hl,l928ah+1		;7b11	21 8b 92	! . .
	call sub_7be2h		;7b14	cd e2 7b	. . {
	call sub_929fh		;7b17	cd 9f 92	. . .
	ld a,000h		;7b1a	3e 00		> .
	ret z			;7b1c	c8		.
	ld a,001h		;7b1d	3e 01		> .
	jp c,l7b24h		;7b1f	da 24 7b	. $ {
	ld a,0ffh		;7b22	3e ff		> .
l7b24h:
	and a			;7b24	a7		.
	ret			;7b25	c9		.
sub_7b26h:
	ld a,h			;7b26	7c		|
	sub d			;7b27	92		.
	ret nz			;7b28	c0		.
	ld a,l			;7b29	7d		}
	sub e			;7b2a	93		.
	ret			;7b2b	c9		.
sub_7b2ch:
	dec hl			;7b2c	2b		+
	ret			;7b2d	c9		.
sub_7b2eh:
	ld hl,l7c98h		;7b2e	21 98 7c	! . |
	jp sub_940fh		;7b31	c3 0f 94	. . .
sub_7b34h:
	call sub_7baah		;7b34	cd aa 7b	. . {
	call sub_9ae4h		;7b37	cd e4 9a	. . .
	dec hl			;7b3a	2b		+
	ld (hl),0b8h		;7b3b	36 b8		6 .
	ld hl,l9287h		;7b3d	21 87 92	! . .
	ld a,0b8h		;7b40	3e b8		> .
	sub b			;7b42	90		.
	call sub_9650h		;7b43	cd 50 96	. P .
	xor a			;7b46	af		.
	ld (09280h),a		;7b47	32 80 92	2 . .
	ret			;7b4a	c9		.
sub_7b4bh:
	ld hl,l7c94h		;7b4b	21 94 7c	! . |
	jp l98f1h		;7b4e	c3 f1 98	. . .
sub_7b51h:
	ld hl,l7c90h		;7b51	21 90 7c	! . |
	jp sub_940fh		;7b54	c3 0f 94	. . .
sub_7b57h:
	ld hl,l928ah+1		;7b57	21 8b 92	! . .
	jp sub_940fh		;7b5a	c3 0f 94	. . .
sub_7b5dh:
	ld a,(hl)		;7b5d	7e		~
	add a,e			;7b5e	83		.
	ld e,a			;7b5f	5f		_
	inc hl			;7b60	23		#
	ld a,(hl)		;7b61	7e		~
	adc a,d			;7b62	8a		.
	ld d,a			;7b63	57		W
	inc hl			;7b64	23		#
	ld a,(hl)		;7b65	7e		~
	adc a,c			;7b66	89		.
	ld c,a			;7b67	4f		O
	ret			;7b68	c9		.
l7b69h:
	call sub_9c2eh		;7b69	cd 2e 9c	. . .
	jp l987fh		;7b6c	c3 7f 98	. . .
sub_7b6fh:
	ld hl,l8359h		;7b6f	21 59 83	! Y .
	jp sub_987ch		;7b72	c3 7c 98	. | .
sub_7b75h:
	call sub_9a2fh		;7b75	cd 2f 9a	. / .
	jp nz,l7b7dh		;7b78	c2 7d 7b	. } {
	xor a			;7b7b	af		.
	ret			;7b7c	c9		.
l7b7dh:
	add a,a			;7b7d	87		.
	sbc a,a			;7b7e	9f		.
l7b7fh:
	inc a			;7b7f	3c		<
	ret nz			;7b80	c0		.
	sub 001h		;7b81	d6 01		. .
	ret			;7b83	c9		.
l7b84h:
	pop hl			;7b84	e1		.
	ret			;7b85	c9		.
sub_7b86h:
	ld l,a			;7b86	6f		o
	ld h,000h		;7b87	26 00		& .
	call 07ad8h		;7b89	cd d8 7a	. . z
	jp sub_9a5dh		;7b8c	c3 5d 9a	. ] .
sub_7b8fh:
	ex de,hl		;7b8f	eb		.
	ld hl,(l9285h)		;7b90	2a 85 92	* . .
	ex (sp),hl		;7b93	e3		.
	push hl			;7b94	e5		.
	ld hl,(l9287h)		;7b95	2a 87 92	* . .
	ex (sp),hl		;7b98	e3		.
	push hl			;7b99	e5		.
	ex de,hl		;7b9a	eb		.
	ret			;7b9b	c9		.
sub_7b9ch:
	call sub_7badh		;7b9c	cd ad 7b	. . {
sub_7b9fh:
	ex de,hl		;7b9f	eb		.
	ld (l9285h),hl		;7ba0	22 85 92	" . .
	ld h,b			;7ba3	60		`
	ld l,c			;7ba4	69		i
	ld (l9287h),hl		;7ba5	22 87 92	" . .
	ex de,hl		;7ba8	eb		.
	ret			;7ba9	c9		.
sub_7baah:
	ld hl,l9285h		;7baa	21 85 92	! . .
sub_7badh:
	ld e,(hl)		;7bad	5e		^
	inc hl			;7bae	23		#
	ld d,(hl)		;7baf	56		V
	inc hl			;7bb0	23		#
	ld c,(hl)		;7bb1	4e		N
	inc hl			;7bb2	23		#
	ld b,(hl)		;7bb3	46		F
sub_7bb4h:
	inc hl			;7bb4	23		#
	ret			;7bb5	c9		.
sub_7bb6h:
	ld hl,l7c94h		;7bb6	21 94 7c	! . |
	jp sub_997dh		;7bb9	c3 7d 99	. } .
sub_7bbch:
	call sub_9c1ch		;7bbc	cd 1c 9c	. . .
	ld a,b			;7bbf	78		x
	cp 098h			;7bc0	fe 98		. .
	ld a,e			;7bc2	7b		{
	jp nc,l9c11h		;7bc3	d2 11 9c	. . .
	ld hl,l9289h		;7bc6	21 89 92	! . .
	ld (hl),080h		;7bc9	36 80		6 .
	call sub_9af1h		;7bcb	cd f1 9a	. . .
	ld (hl),a		;7bce	77		w
	ld h,a			;7bcf	67		g
	ld a,098h		;7bd0	3e 98		> .
	sub b			;7bd2	90		.
	call sub_9c79h		;7bd3	cd 79 9c	. y .
	ld b,000h		;7bd6	06 00		. .
	ret			;7bd8	c9		.
l7bd9h:
	jp l9c35h		;7bd9	c3 35 9c	. 5 .
	ld b,004h		;7bdc	06 04		. .
	jp l7be6h		;7bde	c3 e6 7b	. . {
l7be1h:
	ex de,hl		;7be1	eb		.
sub_7be2h:
	ld a,(l7a7fh)		;7be2	3a 7f 7a	: . z
	ld b,a			;7be5	47		G
l7be6h:
	ld a,(de)		;7be6	1a		.
	ld (hl),a		;7be7	77		w
	inc de			;7be8	13		.
	inc hl			;7be9	23		#
	dec b			;7bea	05		.
	jp nz,l7be6h		;7beb	c2 e6 7b	. . {
	ret			;7bee	c9		.
sub_7befh:
	ld de,l7be1h		;7bef	11 e1 7b	. . {
	jp l7bfbh		;7bf2	c3 fb 7b	. . {
sub_7bf5h:
	ld hl,l928ah+1		;7bf5	21 8b 92	! . .
	ld de,sub_7be2h		;7bf8	11 e2 7b	. . {
l7bfbh:
	push de			;7bfb	d5		.
	ld de,l9285h		;7bfc	11 85 92	. . .
	call sub_83d5h		;7bff	cd d5 83	. . .
	ret c			;7c02	d8		.
	ld de,09281h		;7c03	11 81 92	. . .
	ret			;7c06	c9		.
sub_7c07h:
	call sub_83d5h		;7c07	cd d5 83	. . .
	jp p,l7bd9h		;7c0a	f2 d9 7b	. . {
	ld hl,(l9285h)		;7c0d	2a 85 92	* . .
	ld a,h			;7c10	7c		|
	or l			;7c11	b5		.
	ret z			;7c12	c8		.
	ld a,h			;7c13	7c		|
	rla			;7c14	17		.
	sbc a,a			;7c15	9f		.
	ret nz			;7c16	c0		.
	inc a			;7c17	3c		<
	ret			;7c18	c9		.
sub_7c19h:
	call sub_83d5h		;7c19	cd d5 83	. . .
l7c1ch:
	ld hl,(l9285h)		;7c1c	2a 85 92	* . .
	ret m			;7c1f	f8		.
	jp po,l7c35h		;7c20	e2 35 7c	. 5 |
	call sub_7bf5h		;7c23	cd f5 7b	. . {
	ld hl,l8355h		;7c26	21 55 83	! U .
	call sub_7befh		;7c29	cd ef 7b	. . {
	call sub_7b0bh		;7c2c	cd 0b 7b	. . {
	call sub_7abbh		;7c2f	cd bb 7a	. . z
	jp l7c38h		;7c32	c3 38 7c	. 8 |
l7c35h:
	call sub_7b6fh		;7c35	cd 6f 7b	. o {
l7c38h:
	ld a,(l9287h)		;7c38	3a 87 92	: . .
	or a			;7c3b	b7		.
	push af			;7c3c	f5		.
	and 07fh		;7c3d	e6 7f		. .
	ld (l9287h),a		;7c3f	32 87 92	2 . .
	ld a,(l9287h+1)		;7c42	3a 88 92	: . .
	cp 090h			;7c45	fe 90		. .
	jp nc,l84b2h		;7c47	d2 b2 84	. . .
	call sub_7bbch		;7c4a	cd bc 7b	. . {
	ld a,(l9287h+1)		;7c4d	3a 88 92	: . .
	or a			;7c50	b7		.
	jp nz,l7c59h		;7c51	c2 59 7c	. Y |
	pop af			;7c54	f1		.
	ex de,hl		;7c55	eb		.
	jp l7c5eh		;7c56	c3 5e 7c	. ^ |
l7c59h:
	pop af			;7c59	f1		.
	ex de,hl		;7c5a	eb		.
	jp p,l7c64h		;7c5b	f2 64 7c	. d |
l7c5eh:
	ld a,h			;7c5e	7c		|
	cpl			;7c5f	2f		/
	ld h,a			;7c60	67		g
	ld a,l			;7c61	7d		}
	cpl			;7c62	2f		/
	ld l,a			;7c63	6f		o
l7c64h:
	jp l7c78h		;7c64	c3 78 7c	. x |
	ld hl,l84b2h		;7c67	21 b2 84	! . .
	push hl			;7c6a	e5		.
	ld a,(l9287h+1)		;7c6b	3a 88 92	: . .
	cp 090h			;7c6e	fe 90		. .
	jp nc,l7c81h		;7c70	d2 81 7c	. . |
	call sub_7bbch		;7c73	cd bc 7b	. . {
	ex de,hl		;7c76	eb		.
l7c77h:
	pop de			;7c77	d1		.
l7c78h:
	ld (l9285h),hl		;7c78	22 85 92	" . .
	ld a,002h		;7c7b	3e 02		> .
l7c7dh:
	ld (l7a7fh),a		;7c7d	32 7f 7a	2 . z
	ret			;7c80	c9		.
l7c81h:
	ld bc,09080h		;7c81	01 80 90	. . .
	ld de,00000h		;7c84	11 00 00	. . .
	call sub_7b75h		;7c87	cd 75 7b	. u {
	ret nz			;7c8a	c0		.
	ld h,c			;7c8b	61		a
	ld l,d			;7c8c	6a		j
	jp l7c77h		;7c8d	c3 77 7c	. w |
l7c90h:
	nop			;7c90	00		.
	nop			;7c91	00		.
	nop			;7c92	00		.
	nop			;7c93	00		.
l7c94h:
	nop			;7c94	00		.
	nop			;7c95	00		.
	jr nz,l7c1ch		;7c96	20 84		  .
l7c98h:
	call 0cccch		;7c98	cd cc cc	. . .
	call z,0cccch		;7c9b	cc cc cc	. . .
	ld c,h			;7c9e	4c		L
	ld a,l			;7c9f	7d		}
sub_7ca0h:
	call sub_7aafh		;7ca0	cd af 7a	. . z
	call sub_7ad5h		;7ca3	cd d5 7a	. . z
	or 0afh			;7ca6	f6 af		. .
	ld bc,l849dh		;7ca8	01 9d 84	. . .
	push bc			;7cab	c5		.
	push af			;7cac	f5		.
	ld a,001h		;7cad	3e 01		> .
	ld (l7a58h),a		;7caf	32 58 7a	2 X z
	pop af			;7cb2	f1		.
	ex de,hl		;7cb3	eb		.
	ld bc,000ffh		;7cb4	01 ff 00	. . .
	ld h,b			;7cb7	60		`
	ld l,b			;7cb8	68		h
	call z,l7c78h		;7cb9	cc 78 7c	. x |
	ex de,hl		;7cbc	eb		.
	ld a,(hl)		;7cbd	7e		~
	cp 026h			;7cbe	fe 26		. &
	jp z,l83f0h		;7cc0	ca f0 83	. . .
	cp 02dh			;7cc3	fe 2d		. -
	push af			;7cc5	f5		.
	jp z,l7ccfh		;7cc6	ca cf 7c	. . |
	cp 02bh			;7cc9	fe 2b		. +
	jp z,l7ccfh		;7ccb	ca cf 7c	. . |
	dec hl			;7cce	2b		+
l7ccfh:
	call 083bbh		;7ccf	cd bb 83	. . .
	jp c,l7db6h		;7cd2	da b6 7d	. . }
	cp 02eh			;7cd5	fe 2e		. .
	jp z,l7d5ch		;7cd7	ca 5c 7d	. \ }
	cp 065h			;7cda	fe 65		. e
	jp z,l7ce1h		;7cdc	ca e1 7c	. . |
	cp 045h			;7cdf	fe 45		. E
l7ce1h:
	jp nz,l7d0bh		;7ce1	c2 0b 7d	. . }
	push hl			;7ce4	e5		.
	call 083bbh		;7ce5	cd bb 83	. . .
	cp 06ch			;7ce8	fe 6c		. l
	jp z,l7cf9h		;7cea	ca f9 7c	. . |
	cp 04ch			;7ced	fe 4c		. L
	jp z,l7cf9h		;7cef	ca f9 7c	. . |
	cp 071h			;7cf2	fe 71		. q
	jp z,l7cf9h		;7cf4	ca f9 7c	. . |
	cp 051h			;7cf7	fe 51		. Q
l7cf9h:
	pop hl			;7cf9	e1		.
	jp z,l7d0ah		;7cfa	ca 0a 7d	. . }
	ld a,(l7a7fh)		;7cfd	3a 7f 7a	: . z
	cp 008h			;7d00	fe 08		. .
	jp z,l7d24h		;7d02	ca 24 7d	. $ }
	ld a,000h		;7d05	3e 00		> .
	jp l7d24h		;7d07	c3 24 7d	. $ }
l7d0ah:
	ld a,(hl)		;7d0a	7e		~
l7d0bh:
	cp 025h			;7d0b	fe 25		. %
	jp z,l7d69h		;7d0d	ca 69 7d	. i }
	cp 023h			;7d10	fe 23		. #
	jp z,l7d7ah		;7d12	ca 7a 7d	. z }
	cp 021h			;7d15	fe 21		. !
	jp z,l7d7bh		;7d17	ca 7b 7d	. { }
	cp 064h			;7d1a	fe 64		. d
	jp z,l7d24h		;7d1c	ca 24 7d	. $ }
	cp 044h			;7d1f	fe 44		. D
	jp nz,l7d3bh		;7d21	c2 3b 7d	. ; }
l7d24h:
	or a			;7d24	b7		.
	call sub_7d84h		;7d25	cd 84 7d	. . }
	call 083bbh		;7d28	cd bb 83	. . .
	call sub_83e6h		;7d2b	cd e6 83	. . .
l7d2eh:
	call 083bbh		;7d2e	cd bb 83	. . .
	jp c,l7e29h		;7d31	da 29 7e	. ) ~
	inc d			;7d34	14		.
	jp nz,l7d3bh		;7d35	c2 3b 7d	. ; }
	xor a			;7d38	af		.
	sub e			;7d39	93		.
	ld e,a			;7d3a	5f		_
l7d3bh:
	push hl			;7d3b	e5		.
	ld a,e			;7d3c	7b		{
	sub b			;7d3d	90		.
	ld e,a			;7d3e	5f		_
l7d3fh:
	call p,sub_7d93h	;7d3f	f4 93 7d	. . }
	call m,sub_7da3h	;7d42	fc a3 7d	. . }
	jp nz,l7d3fh		;7d45	c2 3f 7d	. ? }
	pop hl			;7d48	e1		.
	pop af			;7d49	f1		.
	push hl			;7d4a	e5		.
	call z,07a86h		;7d4b	cc 86 7a	. . z
	pop hl			;7d4e	e1		.
	call sub_83d5h		;7d4f	cd d5 83	. . .
	ret pe			;7d52	e8		.
	push hl			;7d53	e5		.
	ld hl,l7b84h		;7d54	21 84 7b	! . {
	push hl			;7d57	e5		.
	call l7c81h		;7d58	cd 81 7c	. . |
	ret			;7d5b	c9		.
l7d5ch:
	call sub_83d5h		;7d5c	cd d5 83	. . .
	inc c			;7d5f	0c		.
	jp nz,l7d3bh		;7d60	c2 3b 7d	. ; }
	call c,sub_7d84h	;7d63	dc 84 7d	. . }
	jp l7ccfh		;7d66	c3 cf 7c	. . |
l7d69h:
	call 083bbh		;7d69	cd bb 83	. . .
	pop af			;7d6c	f1		.
	push hl			;7d6d	e5		.
	ld hl,l7b84h		;7d6e	21 84 7b	! . {
	push hl			;7d71	e5		.
	ld hl,sub_7c19h		;7d72	21 19 7c	! . |
	push hl			;7d75	e5		.
	push af			;7d76	f5		.
	jp l7d3bh		;7d77	c3 3b 7d	. ; }
l7d7ah:
	or a			;7d7a	b7		.
l7d7bh:
	call sub_7d84h		;7d7b	cd 84 7d	. . }
	call 083bbh		;7d7e	cd bb 83	. . .
	jp l7d3bh		;7d81	c3 3b 7d	. ; }
sub_7d84h:
	push hl			;7d84	e5		.
	push de			;7d85	d5		.
	push bc			;7d86	c5		.
	push af			;7d87	f5		.
	call z,sub_7ab4h	;7d88	cc b4 7a	. . z
	pop af			;7d8b	f1		.
	call nz,sub_7acbh	;7d8c	c4 cb 7a	. . z
	pop bc			;7d8f	c1		.
	pop de			;7d90	d1		.
	pop hl			;7d91	e1		.
	ret			;7d92	c9		.
sub_7d93h:
	ret z			;7d93	c8		.
sub_7d94h:
	push af			;7d94	f5		.
	call sub_83d5h		;7d95	cd d5 83	. . .
	push af			;7d98	f5		.
	call po,sub_7bb6h	;7d99	e4 b6 7b	. . {
	pop af			;7d9c	f1		.
	call pe,sub_7b51h	;7d9d	ec 51 7b	. Q {
	pop af			;7da0	f1		.
sub_7da1h:
	dec a			;7da1	3d		=
	ret			;7da2	c9		.
sub_7da3h:
	push de			;7da3	d5		.
	push hl			;7da4	e5		.
	push af			;7da5	f5		.
	call sub_83d5h		;7da6	cd d5 83	. . .
	push af			;7da9	f5		.
	call po,sub_7b4bh	;7daa	e4 4b 7b	. K {
	pop af			;7dad	f1		.
	call pe,sub_7b2eh	;7dae	ec 2e 7b	. . {
	pop af			;7db1	f1		.
	pop hl			;7db2	e1		.
	pop de			;7db3	d1		.
	inc a			;7db4	3c		<
	ret			;7db5	c9		.
l7db6h:
	push de			;7db6	d5		.
	ld a,b			;7db7	78		x
	adc a,c			;7db8	89		.
	ld b,a			;7db9	47		G
	push bc			;7dba	c5		.
	push hl			;7dbb	e5		.
	ld a,(hl)		;7dbc	7e		~
	sub 030h		;7dbd	d6 30		. 0
	push af			;7dbf	f5		.
	call sub_83d5h		;7dc0	cd d5 83	. . .
	jp p,l7defh		;7dc3	f2 ef 7d	. . }
	ld hl,(l9285h)		;7dc6	2a 85 92	* . .
	ld de,00ccdh		;7dc9	11 cd 0c	. . .
	call sub_7b26h		;7dcc	cd 26 7b	. & {
	jp nc,l7debh		;7dcf	d2 eb 7d	. . }
	ld d,h			;7dd2	54		T
	ld e,l			;7dd3	5d		]
	add hl,hl		;7dd4	29		)
	add hl,hl		;7dd5	29		)
	add hl,de		;7dd6	19		.
	add hl,hl		;7dd7	29		)
	pop af			;7dd8	f1		.
	ld c,a			;7dd9	4f		O
	add hl,bc		;7dda	09		.
	ld a,h			;7ddb	7c		|
	or a			;7ddc	b7		.
	jp m,l7de9h		;7ddd	fa e9 7d	. . }
	ld (l9285h),hl		;7de0	22 85 92	" . .
l7de3h:
	pop hl			;7de3	e1		.
	pop bc			;7de4	c1		.
	pop de			;7de5	d1		.
	jp l7ccfh		;7de6	c3 cf 7c	. . |
l7de9h:
	ld a,c			;7de9	79		y
	push af			;7dea	f5		.
l7debh:
	call l7ac2h		;7deb	cd c2 7a	. . z
	scf			;7dee	37		7
l7defh:
	jp nc,l7e0bh		;7def	d2 0b 7e	. . ~
	ld bc,09474h		;7df2	01 74 94	. t .
	ld de,l2400h		;7df5	11 00 24	. . $
	call sub_7b75h		;7df8	cd 75 7b	. u {
	jp p,l7e08h		;7dfb	f2 08 7e	. . ~
	call sub_7bb6h		;7dfe	cd b6 7b	. . {
	pop af			;7e01	f1		.
	call sub_7e1eh		;7e02	cd 1e 7e	. . ~
	jp l7de3h		;7e05	c3 e3 7d	. . }
l7e08h:
	call sub_7ad2h		;7e08	cd d2 7a	. . z
l7e0bh:
	call sub_7b51h		;7e0b	cd 51 7b	. Q {
	call sub_7bf5h		;7e0e	cd f5 7b	. . {
	pop af			;7e11	f1		.
	call sub_7b86h		;7e12	cd 86 7b	. . {
	call sub_7ad2h		;7e15	cd d2 7a	. . z
	call sub_7b0bh		;7e18	cd 0b 7b	. . {
	jp l7de3h		;7e1b	c3 e3 7d	. . }
sub_7e1eh:
	call sub_7b8fh		;7e1e	cd 8f 7b	. . {
	call sub_7b86h		;7e21	cd 86 7b	. . {
	pop bc			;7e24	c1		.
	pop de			;7e25	d1		.
	jp l7b69h		;7e26	c3 69 7b	. i {
l7e29h:
	ld a,e			;7e29	7b		{
	cp 00ah			;7e2a	fe 0a		. .
	jp nc,07e38h		;7e2c	d2 38 7e	. 8 ~
	rlca			;7e2f	07		.
	rlca			;7e30	07		.
	add a,e			;7e31	83		.
	rlca			;7e32	07		.
	add a,(hl)		;7e33	86		.
	sub 030h		;7e34	d6 30		. 0
	ld e,a			;7e36	5f		_
	jp m,l7f1eh		;7e37	fa 1e 7f	. . .
	jp l7d2eh		;7e3a	c3 2e 7d	. . }
	or a			;7e3d	b7		.
	jp l7e72h		;7e3e	c3 72 7e	. r ~
	pop af			;7e41	f1		.
	push hl			;7e42	e5		.
	ld hl,l9287h		;7e43	21 87 92	! . .
	call sub_83d5h		;7e46	cd d5 83	. . .
	jp po,l7e52h		;7e49	e2 52 7e	. R ~
	ld a,(l9291h)		;7e4c	3a 91 92	: . .
	jp l7e53h		;7e4f	c3 53 7e	. S ~
l7e52h:
	ld a,c			;7e52	79		y
l7e53h:
	xor (hl)		;7e53	ae		.
	rla			;7e54	17		.
	pop hl			;7e55	e1		.
	jp l7e72h		;7e56	c3 72 7e	. r ~
	ld a,(l9289h)		;7e59	3a 89 92	: . .
	jp l7e6eh		;7e5c	c3 6e 7e	. n ~
	pop af			;7e5f	f1		.
	pop af			;7e60	f1		.
	pop af			;7e61	f1		.
	ld a,(l9287h)		;7e62	3a 87 92	: . .
	rla			;7e65	17		.
	jp l7e72h		;7e66	c3 72 7e	. r ~
	pop af			;7e69	f1		.
	ld a,(l9289h)		;7e6a	3a 89 92	: . .
	cpl			;7e6d	2f		/
l7e6eh:
	rla			;7e6e	17		.
	jp l7e72h		;7e6f	c3 72 7e	. r ~
l7e72h:
	jp l84b2h		;7e72	c3 b2 84	. . .
sub_7e75h:
	xor a			;7e75	af		.
	call sub_7efeh		;7e76	cd fe 7e	. . ~
	and 008h		;7e79	e6 08		. .
	jp z,l7e80h		;7e7b	ca 80 7e	. . ~
	ld (hl),02bh		;7e7e	36 2b		6 +
l7e80h:
	ex de,hl		;7e80	eb		.
	call sub_7c07h		;7e81	cd 07 7c	. . |
	ex de,hl		;7e84	eb		.
	jp p,l7e92h		;7e85	f2 92 7e	. . ~
	ld (hl),02dh		;7e88	36 2d		6 -
	push bc			;7e8a	c5		.
	push hl			;7e8b	e5		.
	call 07a86h		;7e8c	cd 86 7a	. . z
	pop hl			;7e8f	e1		.
	pop bc			;7e90	c1		.
	or h			;7e91	b4		.
l7e92h:
	inc hl			;7e92	23		#
	ld (hl),030h		;7e93	36 30		6 0
	ld a,(l7a82h)		;7e95	3a 82 7a	: . z
	ld d,a			;7e98	57		W
	rla			;7e99	17		.
	ld a,(l7a7fh)		;7e9a	3a 7f 7a	: . z
	jp c,l8023h		;7e9d	da 23 80	. # .
	jp z,l801bh		;7ea0	ca 1b 80	. . .
	cp 004h			;7ea3	fe 04		. .
	jp nc,l7f07h		;7ea5	d2 07 7f	. . .
	ld bc,00000h		;7ea8	01 00 00	. . .
	call sub_8306h		;7eab	cd 06 83	. . .
sub_7eaeh:
	ld hl,l7a5ah+2		;7eae	21 5c 7a	! \ z
	ld b,(hl)		;7eb1	46		F
	ld c,020h		;7eb2	0e 20		.  
	ld a,(l7a82h)		;7eb4	3a 82 7a	: . z
	ld e,a			;7eb7	5f		_
	and 020h		;7eb8	e6 20		.  
	jp z,l7ecbh		;7eba	ca cb 7e	. . ~
	ld a,b			;7ebd	78		x
	cp c			;7ebe	b9		.
	ld c,02ah		;7ebf	0e 2a		. *
	jp nz,l7ecbh		;7ec1	c2 cb 7e	. . ~
	ld a,e			;7ec4	7b		{
	and 004h		;7ec5	e6 04		. .
	jp nz,l7ecbh		;7ec7	c2 cb 7e	. . ~
	ld b,c			;7eca	41		A
l7ecbh:
	ld (hl),c		;7ecb	71		q
	call 083bbh		;7ecc	cd bb 83	. . .
	jp z,l7eebh		;7ecf	ca eb 7e	. . ~
	cp 045h			;7ed2	fe 45		. E
	jp z,l7eebh		;7ed4	ca eb 7e	. . ~
	cp 044h			;7ed7	fe 44		. D
sub_7ed9h:
	jp z,l7eebh		;7ed9	ca eb 7e	. . ~
	cp 030h			;7edc	fe 30		. 0
	jp z,l7ecbh		;7ede	ca cb 7e	. . ~
	cp 02ch			;7ee1	fe 2c		. ,
	jp z,l7ecbh		;7ee3	ca cb 7e	. . ~
	cp 02eh			;7ee6	fe 2e		. .
	jp nz,l7eeeh		;7ee8	c2 ee 7e	. . ~
l7eebh:
	dec hl			;7eeb	2b		+
	ld (hl),030h		;7eec	36 30		6 0
l7eeeh:
	ld a,e			;7eee	7b		{
	and 010h		;7eef	e6 10		. .
	jp z,l7ef7h		;7ef1	ca f7 7e	. . ~
	dec hl			;7ef4	2b		+
	ld (hl),024h		;7ef5	36 24		6 $
l7ef7h:
	ld a,e			;7ef7	7b		{
	and 004h		;7ef8	e6 04		. .
	ret nz			;7efa	c0		.
	dec hl			;7efb	2b		+
	ld (hl),b		;7efc	70		p
	ret			;7efd	c9		.
sub_7efeh:
	ld (l7a82h),a		;7efe	32 82 7a	2 . z
	ld hl,l7a5ah+2		;7f01	21 5c 7a	! \ z
	ld (hl),020h		;7f04	36 20		6  
	ret			;7f06	c9		.
l7f07h:
	call sub_7b8fh		;7f07	cd 8f 7b	. . {
	ex de,hl		;7f0a	eb		.
	ld hl,(09281h)		;7f0b	2a 81 92	* . .
	push hl			;7f0e	e5		.
	ld hl,(l9283h)		;7f0f	2a 83 92	* . .
	push hl			;7f12	e5		.
	ex de,hl		;7f13	eb		.
	push af			;7f14	f5		.
	xor a			;7f15	af		.
	ld (l7a5ah),a		;7f16	32 5a 7a	2 Z z
	pop af			;7f19	f1		.
	push af			;7f1a	f5		.
	call sub_7fb2h		;7f1b	cd b2 7f	. . .
l7f1eh:
	ld b,045h		;7f1e	06 45		. E
	ld c,000h		;7f20	0e 00		. .
l7f22h:
	push hl			;7f22	e5		.
	ld a,(hl)		;7f23	7e		~
l7f24h:
	cp b			;7f24	b8		.
	jp z,l7f53h		;7f25	ca 53 7f	. S .
	cp 03ah			;7f28	fe 3a		. :
	jp nc,l7f33h		;7f2a	d2 33 7f	. 3 .
	cp 030h			;7f2d	fe 30		. 0
	jp c,l7f33h		;7f2f	da 33 7f	. 3 .
	inc c			;7f32	0c		.
l7f33h:
	inc hl			;7f33	23		#
	ld a,(hl)		;7f34	7e		~
	or a			;7f35	b7		.
	jp nz,l7f24h		;7f36	c2 24 7f	. $ .
	ld a,044h		;7f39	3e 44		> D
	cp b			;7f3b	b8		.
	ld b,a			;7f3c	47		G
	pop hl			;7f3d	e1		.
	ld c,000h		;7f3e	0e 00		. .
	jp nz,l7f22h		;7f40	c2 22 7f	. " .
l7f43h:
	pop af			;7f43	f1		.
	pop bc			;7f44	c1		.
	pop de			;7f45	d1		.
	ex de,hl		;7f46	eb		.
	ld (09281h),hl		;7f47	22 81 92	" . .
	ld h,b			;7f4a	60		`
	ld l,c			;7f4b	69		i
	ld (l9283h),hl		;7f4c	22 83 92	" . .
	ex de,hl		;7f4f	eb		.
	pop bc			;7f50	c1		.
	pop de			;7f51	d1		.
	ret			;7f52	c9		.
l7f53h:
	push bc			;7f53	c5		.
	ld b,000h		;7f54	06 00		. .
	inc hl			;7f56	23		#
	ld a,(hl)		;7f57	7e		~
l7f58h:
	cp 02bh			;7f58	fe 2b		. +
	jp z,l7f9ah		;7f5a	ca 9a 7f	. . .
	cp 02dh			;7f5d	fe 2d		. -
	jp z,l7f71h		;7f5f	ca 71 7f	. q .
	sub 030h		;7f62	d6 30		. 0
	ld c,a			;7f64	4f		O
	ld a,b			;7f65	78		x
	add a,a			;7f66	87		.
	add a,a			;7f67	87		.
	add a,b			;7f68	80		.
	add a,a			;7f69	87		.
	add a,c			;7f6a	81		.
	ld b,a			;7f6b	47		G
	cp 010h			;7f6c	fe 10		. .
	jp nc,l7f9ah		;7f6e	d2 9a 7f	. . .
l7f71h:
	inc hl			;7f71	23		#
	ld a,(hl)		;7f72	7e		~
	or a			;7f73	b7		.
	jp nz,l7f58h		;7f74	c2 58 7f	. X .
	ld h,b			;7f77	60		`
	pop bc			;7f78	c1		.
	ld a,b			;7f79	78		x
	cp 045h			;7f7a	fe 45		. E
	jp nz,l7f8fh		;7f7c	c2 8f 7f	. . .
	ld a,c			;7f7f	79		y
	add a,h			;7f80	84		.
	cp 009h			;7f81	fe 09		. .
	pop hl			;7f83	e1		.
	jp nc,l7f43h		;7f84	d2 43 7f	. C .
l7f87h:
	ld a,080h		;7f87	3e 80		> .
	ld (l7a5ah),a		;7f89	32 5a 7a	2 Z z
	jp l7f9fh		;7f8c	c3 9f 7f	. . .
l7f8fh:
	ld a,h			;7f8f	7c		|
	add a,c			;7f90	81		.
	cp 012h			;7f91	fe 12		. .
	pop hl			;7f93	e1		.
	jp nc,l7f43h		;7f94	d2 43 7f	. C .
	jp l7f87h		;7f97	c3 87 7f	. . .
l7f9ah:
	pop bc			;7f9a	c1		.
	pop hl			;7f9b	e1		.
	jp l7f43h		;7f9c	c3 43 7f	. C .
l7f9fh:
	pop af			;7f9f	f1		.
	pop bc			;7fa0	c1		.
	pop de			;7fa1	d1		.
	ex de,hl		;7fa2	eb		.
	ld (09281h),hl		;7fa3	22 81 92	" . .
	ld h,b			;7fa6	60		`
	ld l,c			;7fa7	69		i
	ld (l9283h),hl		;7fa8	22 83 92	" . .
	ex de,hl		;7fab	eb		.
	pop bc			;7fac	c1		.
	pop de			;7fad	d1		.
	call sub_7b9fh		;7fae	cd 9f 7b	. . {
	inc hl			;7fb1	23		#
sub_7fb2h:
	cp 005h			;7fb2	fe 05		. .
	push hl			;7fb4	e5		.
	sbc a,000h		;7fb5	de 00		. .
	rla			;7fb7	17		.
	ld d,a			;7fb8	57		W
	inc d			;7fb9	14		.
	call sub_81a8h		;7fba	cd a8 81	. . .
	ld bc,00300h		;7fbd	01 00 03	. . .
	push af			;7fc0	f5		.
	ld a,(l7a5ah)		;7fc1	3a 5a 7a	: Z z
	or a			;7fc4	b7		.
	jp p,l7fcdh		;7fc5	f2 cd 7f	. . .
	pop af			;7fc8	f1		.
	add a,d			;7fc9	82		.
	jp l7fd7h		;7fca	c3 d7 7f	. . .
l7fcdh:
	pop af			;7fcd	f1		.
	add a,d			;7fce	82		.
	jp m,l7fdbh		;7fcf	fa db 7f	. . .
	inc d			;7fd2	14		.
	cp d			;7fd3	ba		.
	jp nc,l7fdbh		;7fd4	d2 db 7f	. . .
l7fd7h:
	inc a			;7fd7	3c		<
	ld b,a			;7fd8	47		G
	ld a,002h		;7fd9	3e 02		> .
l7fdbh:
	sub 002h		;7fdb	d6 02		. .
	pop hl			;7fdd	e1		.
	push af			;7fde	f5		.
	call sub_8247h		;7fdf	cd 47 82	. G .
	ld (hl),030h		;7fe2	36 30		6 0
	call z,sub_7bb4h	;7fe4	cc b4 7b	. . {
	call sub_826eh		;7fe7	cd 6e 82	. n .
l7feah:
	dec hl			;7fea	2b		+
	ld a,(hl)		;7feb	7e		~
	cp 030h			;7fec	fe 30		. 0
	jp z,l7feah		;7fee	ca ea 7f	. . .
	cp 02eh			;7ff1	fe 2e		. .
	call nz,sub_7bb4h	;7ff3	c4 b4 7b	. . {
	pop af			;7ff6	f1		.
	jp z,l801ch		;7ff7	ca 1c 80	. . .
sub_7ffah:
	push af			;7ffa	f5		.
	call sub_83d5h		;7ffb	cd d5 83	. . .
	ld a,022h		;7ffe	3e 22		> "
	adc a,a			;8000	8f		.
	ld (hl),a		;8001	77		w
	inc hl			;8002	23		#
	pop af			;8003	f1		.
	ld (hl),02bh		;8004	36 2b		6 +
	jp p,l800dh		;8006	f2 0d 80	. . .
	ld (hl),02dh		;8009	36 2d		6 -
	cpl			;800b	2f		/
	inc a			;800c	3c		<
l800dh:
	ld b,02fh		;800d	06 2f		. /
l800fh:
	inc b			;800f	04		.
	sub 00ah		;8010	d6 0a		. .
	jp nc,l800fh		;8012	d2 0f 80	. . .
	add a,03ah		;8015	c6 3a		. :
	inc hl			;8017	23		#
	ld (hl),b		;8018	70		p
	inc hl			;8019	23		#
	ld (hl),a		;801a	77		w
l801bh:
	inc hl			;801b	23		#
l801ch:
	ld (hl),000h		;801c	36 00		6 .
	ex de,hl		;801e	eb		.
	ld hl,l7a5ah+2		;801f	21 5c 7a	! \ z
	ret			;8022	c9		.
l8023h:
	inc hl			;8023	23		#
	push bc			;8024	c5		.
	cp 004h			;8025	fe 04		. .
	ld a,d			;8027	7a		z
	jp nc,l809dh		;8028	d2 9d 80	. . .
	rra			;802b	1f		.
	jp c,l813ah		;802c	da 3a 81	. : .
	ld bc,00603h		;802f	01 03 06	. . .
	call sub_823fh		;8032	cd 3f 82	. ? .
	pop de			;8035	d1		.
	ld a,d			;8036	7a		z
	sub 005h		;8037	d6 05		. .
	call p,sub_821bh	;8039	f4 1b 82	. . .
	call sub_8306h		;803c	cd 06 83	. . .
l803fh:
	ld a,e			;803f	7b		{
	or a			;8040	b7		.
	call z,sub_7b2ch	;8041	cc 2c 7b	. , {
	dec a			;8044	3d		=
	call p,sub_821bh	;8045	f4 1b 82	. . .
l8048h:
	push hl			;8048	e5		.
	call sub_7eaeh		;8049	cd ae 7e	. . ~
	pop hl			;804c	e1		.
	jp z,l8052h		;804d	ca 52 80	. R .
	ld (hl),b		;8050	70		p
	inc hl			;8051	23		#
l8052h:
	ld (hl),000h		;8052	36 00		6 .
	ld hl,l7a5ah+1		;8054	21 5b 7a	! [ z
l8057h:
	inc hl			;8057	23		#
l8058h:
	ld a,(l7a80h)		;8058	3a 80 7a	: . z
	sub l			;805b	95		.
	sub d			;805c	92		.
	ret z			;805d	c8		.
	ld a,(hl)		;805e	7e		~
	cp 020h			;805f	fe 20		.  
	jp z,l8057h		;8061	ca 57 80	. W .
	cp 02ah			;8064	fe 2a		. *
	jp z,l8057h		;8066	ca 57 80	. W .
	dec hl			;8069	2b		+
	push hl			;806a	e5		.
l806bh:
	push af			;806b	f5		.
	ld bc,l806bh		;806c	01 6b 80	. k .
	push bc			;806f	c5		.
	call 083bbh		;8070	cd bb 83	. . .
	cp 02dh			;8073	fe 2d		. -
	ret z			;8075	c8		.
	cp 02bh			;8076	fe 2b		. +
	ret z			;8078	c8		.
	cp 024h			;8079	fe 24		. $
	ret z			;807b	c8		.
	pop bc			;807c	c1		.
	cp 030h			;807d	fe 30		. 0
	jp nz,l8095h		;807f	c2 95 80	. . .
	inc hl			;8082	23		#
	call 083bbh		;8083	cd bb 83	. . .
	jp nc,l8095h		;8086	d2 95 80	. . .
	dec hl			;8089	2b		+
	ld bc,l772bh		;808a	01 2b 77	. + w
	pop af			;808d	f1		.
	jp z,0808bh		;808e	ca 8b 80	. . .
	pop bc			;8091	c1		.
	jp l8058h		;8092	c3 58 80	. X .
l8095h:
	pop af			;8095	f1		.
	jp z,l8095h		;8096	ca 95 80	. . .
	pop hl			;8099	e1		.
	ld (hl),025h		;809a	36 25		6 %
	ret			;809c	c9		.
l809dh:
	push hl			;809d	e5		.
	rra			;809e	1f		.
	jp c,l8141h		;809f	da 41 81	. A .
	jp z,l80b9h		;80a2	ca b9 80	. . .
	ld de,l835dh		;80a5	11 5d 83	. ] .
	call sub_7b11h		;80a8	cd 11 7b	. . {
	ld d,010h		;80ab	16 10		. .
	jp m,l80c7h		;80ad	fa c7 80	. . .
l80b0h:
	pop hl			;80b0	e1		.
	pop bc			;80b1	c1		.
	call sub_7e75h		;80b2	cd 75 7e	. u ~
	dec hl			;80b5	2b		+
	ld (hl),025h		;80b6	36 25		6 %
	ret			;80b8	c9		.
l80b9h:
	ld bc,0b60eh		;80b9	01 0e b6	. . .
	ld de,l1bcah		;80bc	11 ca 1b	. . .
	call sub_7b75h		;80bf	cd 75 7b	. u {
	jp p,l80b0h		;80c2	f2 b0 80	. . .
	ld d,006h		;80c5	16 06		. .
l80c7h:
	call l7bd9h		;80c7	cd d9 7b	. . {
	call nz,sub_81a8h	;80ca	c4 a8 81	. . .
	pop hl			;80cd	e1		.
	pop bc			;80ce	c1		.
	jp m,l80ech		;80cf	fa ec 80	. . .
	push bc			;80d2	c5		.
	ld e,a			;80d3	5f		_
	ld a,b			;80d4	78		x
	sub d			;80d5	92		.
	sub e			;80d6	93		.
	call p,sub_821bh	;80d7	f4 1b 82	. . .
	call sub_8232h		;80da	cd 32 82	. 2 .
	call sub_826eh		;80dd	cd 6e 82	. n .
	or e			;80e0	b3		.
	call nz,sub_822bh	;80e1	c4 2b 82	. + .
	or e			;80e4	b3		.
	call nz,sub_825ah	;80e5	c4 5a 82	. Z .
	pop de			;80e8	d1		.
	jp l803fh		;80e9	c3 3f 80	. ? .
l80ech:
	ld e,a			;80ec	5f		_
	ld a,c			;80ed	79		y
	or a			;80ee	b7		.
	call nz,sub_7da1h	;80ef	c4 a1 7d	. . }
	add a,e			;80f2	83		.
	jp m,l80f7h		;80f3	fa f7 80	. . .
	xor a			;80f6	af		.
l80f7h:
	push bc			;80f7	c5		.
	push af			;80f8	f5		.
l80f9h:
	call m,sub_7da3h	;80f9	fc a3 7d	. . }
	jp m,l80f9h		;80fc	fa f9 80	. . .
	pop bc			;80ff	c1		.
l8100h:
	ld a,e			;8100	7b		{
	sub b			;8101	90		.
	pop bc			;8102	c1		.
	ld e,a			;8103	5f		_
	add a,d			;8104	82		.
	ld a,b			;8105	78		x
	jp m,l8115h		;8106	fa 15 81	. . .
	sub d			;8109	92		.
	sub e			;810a	93		.
	call p,sub_821bh	;810b	f4 1b 82	. . .
	push bc			;810e	c5		.
	call sub_8232h		;810f	cd 32 82	. 2 .
	jp l8126h		;8112	c3 26 81	. & .
l8115h:
	call sub_821bh		;8115	cd 1b 82	. . .
	ld a,c			;8118	79		y
	call sub_825eh		;8119	cd 5e 82	. ^ .
	ld c,a			;811c	4f		O
	xor a			;811d	af		.
	sub d			;811e	92		.
	sub e			;811f	93		.
	call sub_821bh		;8120	cd 1b 82	. . .
	push bc			;8123	c5		.
	ld b,a			;8124	47		G
	ld c,a			;8125	4f		O
l8126h:
	call sub_826eh		;8126	cd 6e 82	. n .
	pop bc			;8129	c1		.
	or c			;812a	b1		.
	jp nz,l8131h		;812b	c2 31 81	. 1 .
	ld hl,(l7a80h)		;812e	2a 80 7a	* . z
l8131h:
	add a,e			;8131	83		.
	dec a			;8132	3d		=
	call p,sub_821bh	;8133	f4 1b 82	. . .
	ld d,b			;8136	50		P
	jp l8048h		;8137	c3 48 80	. H .
l813ah:
	push hl			;813a	e5		.
	push de			;813b	d5		.
	call l7ac2h		;813c	cd c2 7a	. . z
	pop de			;813f	d1		.
	xor a			;8140	af		.
l8141h:
	jp z,08147h		;8141	ca 47 81	. G .
	ld e,010h		;8144	1e 10		. .
	ld bc,l061eh		;8146	01 1e 06	. . .
	call l7bd9h		;8149	cd d9 7b	. . {
	scf			;814c	37		7
	call nz,sub_81a8h	;814d	c4 a8 81	. . .
	pop hl			;8150	e1		.
	pop bc			;8151	c1		.
	push af			;8152	f5		.
	ld a,c			;8153	79		y
	or a			;8154	b7		.
	push af			;8155	f5		.
	call nz,sub_7da1h	;8156	c4 a1 7d	. . }
	add a,b			;8159	80		.
	ld c,a			;815a	4f		O
	ld a,d			;815b	7a		z
	and 004h		;815c	e6 04		. .
	cp 001h			;815e	fe 01		. .
	sbc a,a			;8160	9f		.
	ld d,a			;8161	57		W
	add a,c			;8162	81		.
	ld c,a			;8163	4f		O
	sub e			;8164	93		.
	push af			;8165	f5		.
	push bc			;8166	c5		.
l8167h:
	call m,sub_7da3h	;8167	fc a3 7d	. . }
	jp m,l8167h		;816a	fa 67 81	. g .
	pop bc			;816d	c1		.
	pop af			;816e	f1		.
	push bc			;816f	c5		.
	push af			;8170	f5		.
	jp m,l8175h		;8171	fa 75 81	. u .
	xor a			;8174	af		.
l8175h:
	cpl			;8175	2f		/
	inc a			;8176	3c		<
	add a,b			;8177	80		.
	inc a			;8178	3c		<
	add a,d			;8179	82		.
	ld b,a			;817a	47		G
	ld c,000h		;817b	0e 00		. .
	call sub_826eh		;817d	cd 6e 82	. n .
	pop af			;8180	f1		.
	call p,sub_8224h	;8181	f4 24 82	. $ .
	call sub_825ah		;8184	cd 5a 82	. Z .
	pop bc			;8187	c1		.
	pop af			;8188	f1		.
	jp nz,l8198h		;8189	c2 98 81	. . .
	call sub_7b2ch		;818c	cd 2c 7b	. , {
	ld a,(hl)		;818f	7e		~
	cp 02eh			;8190	fe 2e		. .
	call nz,sub_7bb4h	;8192	c4 b4 7b	. . {
	ld (l7a80h),hl		;8195	22 80 7a	" . z
l8198h:
	pop af			;8198	f1		.
	jp c,l819fh		;8199	da 9f 81	. . .
	add a,e			;819c	83		.
	sub b			;819d	90		.
	sub d			;819e	92		.
l819fh:
	push bc			;819f	c5		.
	call sub_7ffah		;81a0	cd fa 7f	. . .
	ex de,hl		;81a3	eb		.
	pop de			;81a4	d1		.
	jp l8048h		;81a5	c3 48 80	. H .
sub_81a8h:
	push de			;81a8	d5		.
	xor a			;81a9	af		.
	push af			;81aa	f5		.
	call sub_83d5h		;81ab	cd d5 83	. . .
	jp po,l81cch		;81ae	e2 cc 81	. . .
l81b1h:
	ld a,(l9287h+1)		;81b1	3a 88 92	: . .
	cp 091h			;81b4	fe 91		. .
	jp nc,l81cch		;81b6	d2 cc 81	. . .
	ld de,l833dh		;81b9	11 3d 83	. = .
	ld hl,l928ah+1		;81bc	21 8b 92	! . .
	call sub_7be2h		;81bf	cd e2 7b	. . {
	call sub_7b57h		;81c2	cd 57 7b	. W {
	pop af			;81c5	f1		.
	sub 00ah		;81c6	d6 0a		. .
	push af			;81c8	f5		.
	jp l81b1h		;81c9	c3 b1 81	. . .
l81cch:
	call sub_81feh		;81cc	cd fe 81	. . .
l81cfh:
	call sub_83d5h		;81cf	cd d5 83	. . .
	jp pe,l81e1h		;81d2	ea e1 81	. . .
	ld bc,l9143h		;81d5	01 43 91	. C .
	ld de,l4ff7h+2		;81d8	11 f9 4f	. . O
	call sub_7b75h		;81db	cd 75 7b	. u {
	jp l81e7h		;81de	c3 e7 81	. . .
l81e1h:
	ld de,l8345h		;81e1	11 45 83	. E .
	call sub_7b11h		;81e4	cd 11 7b	. . {
l81e7h:
	jp p,l81fah		;81e7	f2 fa 81	. . .
	pop af			;81ea	f1		.
	call sub_7d94h		;81eb	cd 94 7d	. . }
	push af			;81ee	f5		.
	jp l81cfh		;81ef	c3 cf 81	. . .
l81f2h:
	pop af			;81f2	f1		.
	call sub_7da3h		;81f3	cd a3 7d	. . }
	push af			;81f6	f5		.
	call sub_81feh		;81f7	cd fe 81	. . .
l81fah:
	pop af			;81fa	f1		.
	or a			;81fb	b7		.
	pop de			;81fc	d1		.
	ret			;81fd	c9		.
sub_81feh:
	call sub_83d5h		;81fe	cd d5 83	. . .
	jp pe,l8210h		;8201	ea 10 82	. . .
	ld bc,09474h		;8204	01 74 94	. t .
	ld de,023f8h		;8207	11 f8 23	. . #
	call sub_7b75h		;820a	cd 75 7b	. u {
	jp l8216h		;820d	c3 16 82	. . .
l8210h:
	ld de,l834dh		;8210	11 4d 83	. M .
	call sub_7b11h		;8213	cd 11 7b	. . {
l8216h:
	pop hl			;8216	e1		.
	jp p,l81f2h		;8217	f2 f2 81	. . .
	jp (hl)			;821a	e9		.
sub_821bh:
	or a			;821b	b7		.
l821ch:
	ret z			;821c	c8		.
	dec a			;821d	3d		=
	ld (hl),030h		;821e	36 30		6 0
	inc hl			;8220	23		#
	jp l821ch		;8221	c3 1c 82	. . .
sub_8224h:
	jp nz,sub_822bh		;8224	c2 2b 82	. + .
l8227h:
	ret z			;8227	c8		.
	call sub_825ah		;8228	cd 5a 82	. Z .
sub_822bh:
	ld (hl),030h		;822b	36 30		6 0
	inc hl			;822d	23		#
	dec a			;822e	3d		=
	jp l8227h		;822f	c3 27 82	. ' .
sub_8232h:
	ld a,e			;8232	7b		{
	add a,d			;8233	82		.
	inc a			;8234	3c		<
	ld b,a			;8235	47		G
	inc a			;8236	3c		<
l8237h:
	sub 003h		;8237	d6 03		. .
	jp nc,l8237h		;8239	d2 37 82	. 7 .
	add a,005h		;823c	c6 05		. .
	ld c,a			;823e	4f		O
sub_823fh:
	ld a,(l7a82h)		;823f	3a 82 7a	: . z
	and 040h		;8242	e6 40		. @
	ret nz			;8244	c0		.
	ld c,a			;8245	4f		O
	ret			;8246	c9		.
sub_8247h:
	dec b			;8247	05		.
	jp p,l825bh		;8248	f2 5b 82	. [ .
	ld (l7a80h),hl		;824b	22 80 7a	" . z
	ld (hl),02eh		;824e	36 2e		6 .
l8250h:
	inc hl			;8250	23		#
	ld (hl),030h		;8251	36 30		6 0
	inc b			;8253	04		.
	jp nz,l8250h		;8254	c2 50 82	. P .
	inc hl			;8257	23		#
	ld c,b			;8258	48		H
	ret			;8259	c9		.
sub_825ah:
	dec b			;825a	05		.
l825bh:
	jp nz,l8266h		;825b	c2 66 82	. f .
sub_825eh:
	ld (hl),02eh		;825e	36 2e		6 .
	ld (l7a80h),hl		;8260	22 80 7a	" . z
	inc hl			;8263	23		#
	ld c,b			;8264	48		H
	ret			;8265	c9		.
l8266h:
	dec c			;8266	0d		.
	ret nz			;8267	c0		.
	ld (hl),02ch		;8268	36 2c		6 ,
	inc hl			;826a	23		#
	ld c,003h		;826b	0e 03		. .
	ret			;826d	c9		.
sub_826eh:
	push de			;826e	d5		.
	call sub_83d5h		;826f	cd d5 83	. . .
	jp po,l82bdh		;8272	e2 bd 82	. . .
	push bc			;8275	c5		.
	push hl			;8276	e5		.
	call sub_7bf5h		;8277	cd f5 7b	. . {
	ld hl,l8355h		;827a	21 55 83	! U .
	call sub_7befh		;827d	cd ef 7b	. . {
	call sub_7b0bh		;8280	cd 0b 7b	. . {
	xor a			;8283	af		.
	call sub_7b34h		;8284	cd 34 7b	. 4 {
	pop hl			;8287	e1		.
	pop bc			;8288	c1		.
	ld de,l8365h		;8289	11 65 83	. e .
	ld a,00ah		;828c	3e 0a		> .
l828eh:
	call sub_825ah		;828e	cd 5a 82	. Z .
	push bc			;8291	c5		.
	push af			;8292	f5		.
	push hl			;8293	e5		.
	push de			;8294	d5		.
	ld b,02fh		;8295	06 2f		. /
l8297h:
	inc b			;8297	04		.
	pop hl			;8298	e1		.
	push hl			;8299	e5		.
	ld a,09eh		;829a	3e 9e		> .
	call sub_7af8h		;829c	cd f8 7a	. . z
	jp nc,l8297h		;829f	d2 97 82	. . .
	pop hl			;82a2	e1		.
	ld a,08eh		;82a3	3e 8e		> .
	call sub_7af8h		;82a5	cd f8 7a	. . z
	ex de,hl		;82a8	eb		.
	pop hl			;82a9	e1		.
	ld (hl),b		;82aa	70		p
	inc hl			;82ab	23		#
	pop af			;82ac	f1		.
	pop bc			;82ad	c1		.
	dec a			;82ae	3d		=
	jp nz,l828eh		;82af	c2 8e 82	. . .
	push bc			;82b2	c5		.
	push hl			;82b3	e5		.
	ld hl,09281h		;82b4	21 81 92	! . .
	call sub_7b9ch		;82b7	cd 9c 7b	. . {
	jp l82cah		;82ba	c3 ca 82	. . .
l82bdh:
	push bc			;82bd	c5		.
	push hl			;82be	e5		.
	call sub_7b6fh		;82bf	cd 6f 7b	. o {
	ld a,001h		;82c2	3e 01		> .
	call sub_7bbch		;82c4	cd bc 7b	. . {
	call sub_7b9fh		;82c7	cd 9f 7b	. . {
l82cah:
	pop hl			;82ca	e1		.
	pop bc			;82cb	c1		.
	xor a			;82cc	af		.
	ld de,l83abh		;82cd	11 ab 83	. . .
l82d0h:
	ccf			;82d0	3f		?
	call sub_825ah		;82d1	cd 5a 82	. Z .
	push bc			;82d4	c5		.
	push af			;82d5	f5		.
	push hl			;82d6	e5		.
	push de			;82d7	d5		.
	call sub_7baah		;82d8	cd aa 7b	. . {
	pop hl			;82db	e1		.
	ld b,02fh		;82dc	06 2f		. /
l82deh:
	inc b			;82de	04		.
	ld a,e			;82df	7b		{
	sub (hl)		;82e0	96		.
	ld e,a			;82e1	5f		_
	inc hl			;82e2	23		#
	ld a,d			;82e3	7a		z
	sbc a,(hl)		;82e4	9e		.
	ld d,a			;82e5	57		W
	inc hl			;82e6	23		#
	ld a,c			;82e7	79		y
	sbc a,(hl)		;82e8	9e		.
	ld c,a			;82e9	4f		O
	dec hl			;82ea	2b		+
	dec hl			;82eb	2b		+
	jp nc,l82deh		;82ec	d2 de 82	. . .
	call sub_7b5dh		;82ef	cd 5d 7b	. ] {
	inc hl			;82f2	23		#
	call sub_7b9fh		;82f3	cd 9f 7b	. . {
	ex de,hl		;82f6	eb		.
	pop hl			;82f7	e1		.
	ld (hl),b		;82f8	70		p
	inc hl			;82f9	23		#
	pop af			;82fa	f1		.
	pop bc			;82fb	c1		.
	jp c,l82d0h		;82fc	da d0 82	. . .
	inc de			;82ff	13		.
	inc de			;8300	13		.
	ld a,004h		;8301	3e 04		> .
	jp l830ch		;8303	c3 0c 83	. . .
sub_8306h:
	push de			;8306	d5		.
	ld de,l83b1h		;8307	11 b1 83	. . .
	ld a,005h		;830a	3e 05		> .
l830ch:
	call sub_825ah		;830c	cd 5a 82	. Z .
	push bc			;830f	c5		.
	push af			;8310	f5		.
	push hl			;8311	e5		.
	ex de,hl		;8312	eb		.
	ld c,(hl)		;8313	4e		N
	inc hl			;8314	23		#
	ld b,(hl)		;8315	46		F
	push bc			;8316	c5		.
	inc hl			;8317	23		#
	ex (sp),hl		;8318	e3		.
	ex de,hl		;8319	eb		.
	ld hl,(l9285h)		;831a	2a 85 92	* . .
	ld b,02fh		;831d	06 2f		. /
l831fh:
	inc b			;831f	04		.
	ld a,l			;8320	7d		}
	sub e			;8321	93		.
l8322h:
	ld l,a			;8322	6f		o
	ld a,h			;8323	7c		|
	sbc a,d			;8324	9a		.
	ld h,a			;8325	67		g
	jp nc,l831fh		;8326	d2 1f 83	. . .
	add hl,de		;8329	19		.
	ld (l9285h),hl		;832a	22 85 92	" . .
	pop de			;832d	d1		.
	pop hl			;832e	e1		.
	ld (hl),b		;832f	70		p
	inc hl			;8330	23		#
	pop af			;8331	f1		.
	pop bc			;8332	c1		.
	dec a			;8333	3d		=
	jp nz,l830ch		;8334	c2 0c 83	. . .
	call sub_825ah		;8337	cd 5a 82	. Z .
	ld (hl),a		;833a	77		w
	pop de			;833b	d1		.
	ret			;833c	c9		.
l833dh:
	nop			;833d	00		.
	nop			;833e	00		.
	nop			;833f	00		.
	nop			;8340	00		.
	ld sp,hl		;8341	f9		.
	ld (bc),a		;8342	02		.
	dec d			;8343	15		.
	and d			;8344	a2		.
l8345h:
	pop hl			;8345	e1		.
	rst 38h			;8346	ff		.
	sbc a,a			;8347	9f		.
	ld sp,l5fa9h		;8348	31 a9 5f	1 . _
	ld h,e			;834b	63		c
	or d			;834c	b2		.
l834dh:
	cp 0ffh			;834d	fe ff		. .
	inc bc			;834f	03		.
	cp a			;8350	bf		.
	ret			;8351	c9		.
	dec de			;8352	1b		.
	ld c,0b6h		;8353	0e b6		. .
l8355h:
	nop			;8355	00		.
	nop			;8356	00		.
	nop			;8357	00		.
	nop			;8358	00		.
l8359h:
	nop			;8359	00		.
	nop			;835a	00		.
	nop			;835b	00		.
	add a,b			;835c	80		.
l835dh:
	nop			;835d	00		.
	nop			;835e	00		.
	inc b			;835f	04		.
	cp a			;8360	bf		.
	ret			;8361	c9		.
	dec de			;8362	1b		.
	ld c,0b6h		;8363	0e b6		. .
l8365h:
	nop			;8365	00		.
	add a,b			;8366	80		.
	add a,0a4h		;8367	c6 a4		. .
	ld a,(hl)		;8369	7e		~
	adc a,l			;836a	8d		.
	inc bc			;836b	03		.
	nop			;836c	00		.
	ld b,b			;836d	40		@
	ld a,d			;836e	7a		z
	djnz $-11		;836f	10 f3		. .
	ld e,d			;8371	5a		Z
	nop			;8372	00		.
	nop			;8373	00		.
	and b			;8374	a0		.
	ld (hl),d		;8375	72		r
	ld c,(hl)		;8376	4e		N
	jr l8382h		;8377	18 09		. .
	nop			;8379	00		.
	nop			;837a	00		.
	djnz l8322h		;837b	10 a5		. .
	call nc,000e8h		;837d	d4 e8 00	. . .
	nop			;8380	00		.
	nop			;8381	00		.
l8382h:
	ret pe			;8382	e8		.
	halt			;8383	76		v
	ld c,b			;8384	48		H
	rla			;8385	17		.
	nop			;8386	00		.
	nop			;8387	00		.
	nop			;8388	00		.
	call po,0540bh		;8389	e4 0b 54	. . T
	ld (bc),a		;838c	02		.
	nop			;838d	00		.
	nop			;838e	00		.
	nop			;838f	00		.
	jp z,03b9ah		;8390	ca 9a 3b	. . ;
	nop			;8393	00		.
	nop			;8394	00		.
	nop			;8395	00		.
	nop			;8396	00		.
	pop hl			;8397	e1		.
	push af			;8398	f5		.
	dec b			;8399	05		.
	nop			;839a	00		.
	nop			;839b	00		.
	nop			;839c	00		.
	add a,b			;839d	80		.
	sub (hl)		;839e	96		.
	sbc a,b			;839f	98		.
	nop			;83a0	00		.
	nop			;83a1	00		.
	nop			;83a2	00		.
	nop			;83a3	00		.
	ld b,b			;83a4	40		@
	ld b,d			;83a5	42		B
	rrca			;83a6	0f		.
	nop			;83a7	00		.
	nop			;83a8	00		.
	nop			;83a9	00		.
	nop			;83aa	00		.
l83abh:
	and b			;83ab	a0		.
	add a,(hl)		;83ac	86		.
	ld bc,l270fh+1		;83ad	01 10 27	. . '
	nop			;83b0	00		.
l83b1h:
	djnz l83dah		;83b1	10 27		. '
	ret pe			;83b3	e8		.
	inc bc			;83b4	03		.
	ld h,h			;83b5	64		d
	nop			;83b6	00		.
	ld a,(bc)		;83b7	0a		.
	nop			;83b8	00		.
	ld bc,02300h		;83b9	01 00 23	. . #
	ld a,(hl)		;83bc	7e		~
	cp 03ah			;83bd	fe 3a		. :
	ret nc			;83bf	d0		.
	cp 020h			;83c0	fe 20		.  
	jp z,083bbh		;83c2	ca bb 83	. . .
	cp 009h			;83c5	fe 09		. .
	jp z,083bbh		;83c7	ca bb 83	. . .
	cp 00ah			;83ca	fe 0a		. .
	jp z,083bbh		;83cc	ca bb 83	. . .
	cp 030h			;83cf	fe 30		. 0
	ccf			;83d1	3f		?
	inc a			;83d2	3c		<
	dec a			;83d3	3d		=
	ret			;83d4	c9		.
sub_83d5h:
	ld a,(l7a7fh)		;83d5	3a 7f 7a	: . z
	cp 008h			;83d8	fe 08		. .
l83dah:
	jp nc,l83e2h		;83da	d2 e2 83	. . .
	sub 003h		;83dd	d6 03		. .
	or a			;83df	b7		.
	scf			;83e0	37		7
	ret			;83e1	c9		.
l83e2h:
	sub 003h		;83e2	d6 03		. .
	or a			;83e4	b7		.
	ret			;83e5	c9		.
sub_83e6h:
	dec d			;83e6	15		.
	cp 02dh			;83e7	fe 2d		. -
	ret z			;83e9	c8		.
	inc d			;83ea	14		.
	cp 02bh			;83eb	fe 2b		. +
	ret z			;83ed	c8		.
	dec hl			;83ee	2b		+
	ret			;83ef	c9		.
l83f0h:
	call 083bbh		;83f0	cd bb 83	. . .
	call sub_8478h		;83f3	cd 78 84	. x .
	cp 04fh			;83f6	fe 4f		. O
	jp z,l8401h		;83f8	ca 01 84	. . .
	cp 048h			;83fb	fe 48		. H
	jp z,l8401h		;83fd	ca 01 84	. . .
	dec hl			;8400	2b		+
l8401h:
	call sub_840dh		;8401	cd 0d 84	. . .
	jp c,l8416h		;8404	da 16 84	. . .
	ex de,hl		;8407	eb		.
	call l7c78h		;8408	cd 78 7c	. x |
	ex de,hl		;840b	eb		.
	ret			;840c	c9		.
sub_840dh:
	cp 048h			;840d	fe 48		. H
	inc hl			;840f	23		#
	jp z,l8442h		;8410	ca 42 84	. B .
	jp l841ch		;8413	c3 1c 84	. . .
l8416h:
	call sub_6c21h		;8416	cd 21 6c	. ! l
	jp 068d5h		;8419	c3 d5 68	. . h
l841ch:
	push bc			;841c	c5		.
	ld c,l			;841d	4d		M
	ex de,hl		;841e	eb		.
	ld hl,00000h		;841f	21 00 00	! . .
	call sub_842eh		;8422	cd 2e 84	. . .
	ex de,hl		;8425	eb		.
	jp c,l842ch		;8426	da 2c 84	. , .
	ld a,l			;8429	7d		}
	sub c			;842a	91		.
	and a			;842b	a7		.
l842ch:
	pop bc			;842c	c1		.
	ret			;842d	c9		.
sub_842eh:
	ld a,(de)		;842e	1a		.
	sub 030h		;842f	d6 30		. 0
	ccf			;8431	3f		?
	ret nc			;8432	d0		.
	cp 008h			;8433	fe 08		. .
	ret nc			;8435	d0		.
	add hl,hl		;8436	29		)
	ret c			;8437	d8		.
	add hl,hl		;8438	29		)
	ret c			;8439	d8		.
	add hl,hl		;843a	29		)
	ret c			;843b	d8		.
	or l			;843c	b5		.
	ld l,a			;843d	6f		o
	inc de			;843e	13		.
	jp sub_842eh		;843f	c3 2e 84	. . .
l8442h:
	push bc			;8442	c5		.
	ld c,l			;8443	4d		M
	ex de,hl		;8444	eb		.
	ld hl,00000h		;8445	21 00 00	! . .
	call sub_8454h		;8448	cd 54 84	. T .
	ex de,hl		;844b	eb		.
	jp c,l8452h		;844c	da 52 84	. R .
	ld a,l			;844f	7d		}
	sub c			;8450	91		.
	and a			;8451	a7		.
l8452h:
	pop bc			;8452	c1		.
	ret			;8453	c9		.
sub_8454h:
	ld a,(de)		;8454	1a		.
	call sub_8478h		;8455	cd 78 84	. x .
	sub 030h		;8458	d6 30		. 0
	ccf			;845a	3f		?
	ret nc			;845b	d0		.
	cp 00ah			;845c	fe 0a		. .
	jp c,l846ah		;845e	da 6a 84	. j .
	sub 011h		;8461	d6 11		. .
	ccf			;8463	3f		?
	ret nc			;8464	d0		.
	cp 006h			;8465	fe 06		. .
	ret nc			;8467	d0		.
	add a,00ah		;8468	c6 0a		. .
l846ah:
	add hl,hl		;846a	29		)
	ret c			;846b	d8		.
	add hl,hl		;846c	29		)
	ret c			;846d	d8		.
	add hl,hl		;846e	29		)
	ret c			;846f	d8		.
	add hl,hl		;8470	29		)
	ret c			;8471	d8		.
	or l			;8472	b5		.
	ld l,a			;8473	6f		o
	inc de			;8474	13		.
	jp sub_8454h		;8475	c3 54 84	. T .
sub_8478h:
	cp 061h			;8478	fe 61		. a
	ret c			;847a	d8		.
	cp 07bh			;847b	fe 7b		. {
	ret nc			;847d	d0		.
	sub 020h		;847e	d6 20		.  
	ret			;8480	c9		.
	ld bc,sub_7c19h		;8481	01 19 7c	. . |
	push bc			;8484	c5		.
	call sub_83d5h		;8485	cd d5 83	. . .
	ret m			;8488	f8		.
	ld a,(l9287h+1)		;8489	3a 88 92	: . .
	cp 090h			;848c	fe 90		. .
	ret nz			;848e	c0		.
	ld a,(l9287h)		;848f	3a 87 92	: . .
	or a			;8492	b7		.
	ret m			;8493	f8		.
	ld bc,l9180h		;8494	01 80 91	. . .
	ld de,00000h		;8497	11 00 00	. . .
	jp l7b69h		;849a	c3 69 7b	. i {
l849dh:
	push af			;849d	f5		.
	ld a,(l7a58h)		;849e	3a 58 7a	: X z
	ld (l7a59h),a		;84a1	32 59 7a	2 Y z
	pop af			;84a4	f1		.
	push af			;84a5	f5		.
	xor a			;84a6	af		.
	ld (l7a58h),a		;84a7	32 58 7a	2 X z
	pop af			;84aa	f1		.
	ret			;84ab	c9		.
	call sub_6c21h		;84ac	cd 21 6c	. ! l
	jp 068d5h		;84af	c3 d5 68	. . h
l84b2h:
	call sub_6c21h		;84b2	cd 21 6c	. ! l
	jp 068d5h		;84b5	c3 d5 68	. . h
l84b8h:
	nop			;84b8	00		.
l84b9h:
	nop			;84b9	00		.
	nop			;84ba	00		.
	nop			;84bb	00		.
	nop			;84bc	00		.
	nop			;84bd	00		.
	nop			;84be	00		.
	nop			;84bf	00		.
	nop			;84c0	00		.
	nop			;84c1	00		.
	nop			;84c2	00		.
	nop			;84c3	00		.
	nop			;84c4	00		.
	nop			;84c5	00		.
	nop			;84c6	00		.
	nop			;84c7	00		.
	nop			;84c8	00		.
	nop			;84c9	00		.
	nop			;84ca	00		.
	nop			;84cb	00		.
	nop			;84cc	00		.
	nop			;84cd	00		.
	nop			;84ce	00		.
	nop			;84cf	00		.
	nop			;84d0	00		.
	nop			;84d1	00		.
	nop			;84d2	00		.
	nop			;84d3	00		.
	nop			;84d4	00		.
	nop			;84d5	00		.
	nop			;84d6	00		.
	nop			;84d7	00		.
	nop			;84d8	00		.
	nop			;84d9	00		.
	nop			;84da	00		.
	nop			;84db	00		.
	nop			;84dc	00		.
	nop			;84dd	00		.
	nop			;84de	00		.
	nop			;84df	00		.
	nop			;84e0	00		.
	nop			;84e1	00		.
	nop			;84e2	00		.
	nop			;84e3	00		.
	nop			;84e4	00		.
	nop			;84e5	00		.
	nop			;84e6	00		.
	nop			;84e7	00		.
	nop			;84e8	00		.
	nop			;84e9	00		.
	nop			;84ea	00		.
	nop			;84eb	00		.
	nop			;84ec	00		.
	nop			;84ed	00		.
	nop			;84ee	00		.
	nop			;84ef	00		.
	nop			;84f0	00		.
	nop			;84f1	00		.
	nop			;84f2	00		.
	nop			;84f3	00		.
	nop			;84f4	00		.
	nop			;84f5	00		.
	nop			;84f6	00		.
	nop			;84f7	00		.
	nop			;84f8	00		.
	nop			;84f9	00		.
	nop			;84fa	00		.
	nop			;84fb	00		.
	nop			;84fc	00		.
	nop			;84fd	00		.
	nop			;84fe	00		.
	nop			;84ff	00		.
	nop			;8500	00		.
	nop			;8501	00		.
	nop			;8502	00		.
	nop			;8503	00		.
	nop			;8504	00		.
	nop			;8505	00		.
	nop			;8506	00		.
	nop			;8507	00		.
	nop			;8508	00		.
	nop			;8509	00		.
	nop			;850a	00		.
	nop			;850b	00		.
	nop			;850c	00		.
	nop			;850d	00		.
	nop			;850e	00		.
	nop			;850f	00		.
	nop			;8510	00		.
	nop			;8511	00		.
	nop			;8512	00		.
	nop			;8513	00		.
	nop			;8514	00		.
	nop			;8515	00		.
	nop			;8516	00		.
	nop			;8517	00		.
	nop			;8518	00		.
	nop			;8519	00		.
	nop			;851a	00		.
	nop			;851b	00		.
	nop			;851c	00		.
	nop			;851d	00		.
	nop			;851e	00		.
	nop			;851f	00		.
	nop			;8520	00		.
l8521h:
	nop			;8521	00		.
	nop			;8522	00		.
	nop			;8523	00		.
	nop			;8524	00		.
	nop			;8525	00		.
	nop			;8526	00		.
	nop			;8527	00		.
	nop			;8528	00		.
	nop			;8529	00		.
	nop			;852a	00		.
	nop			;852b	00		.
	nop			;852c	00		.
	nop			;852d	00		.
	nop			;852e	00		.
	nop			;852f	00		.
	nop			;8530	00		.
	nop			;8531	00		.
	nop			;8532	00		.
	nop			;8533	00		.
	nop			;8534	00		.
	nop			;8535	00		.
	nop			;8536	00		.
	nop			;8537	00		.
l8538h:
	nop			;8538	00		.
	nop			;8539	00		.
	nop			;853a	00		.
	nop			;853b	00		.
	nop			;853c	00		.
	nop			;853d	00		.
	nop			;853e	00		.
	nop			;853f	00		.
	nop			;8540	00		.
	nop			;8541	00		.
	nop			;8542	00		.
	nop			;8543	00		.
	nop			;8544	00		.
	nop			;8545	00		.
	nop			;8546	00		.
	nop			;8547	00		.
l8548h:
	nop			;8548	00		.
l8549h:
	nop			;8549	00		.
	nop			;854a	00		.
	nop			;854b	00		.
	nop			;854c	00		.
	nop			;854d	00		.
	nop			;854e	00		.
	nop			;854f	00		.
	nop			;8550	00		.
l8551h:
	nop			;8551	00		.
	nop			;8552	00		.
	nop			;8553	00		.
l8554h:
	nop			;8554	00		.
	nop			;8555	00		.
	nop			;8556	00		.
	nop			;8557	00		.
	nop			;8558	00		.
	nop			;8559	00		.
	nop			;855a	00		.
	nop			;855b	00		.
	nop			;855c	00		.
	nop			;855d	00		.
	nop			;855e	00		.
	nop			;855f	00		.
	nop			;8560	00		.
	nop			;8561	00		.
	nop			;8562	00		.
	nop			;8563	00		.
	nop			;8564	00		.
	nop			;8565	00		.
	nop			;8566	00		.
	nop			;8567	00		.
	nop			;8568	00		.
l8569h:
	nop			;8569	00		.
	nop			;856a	00		.
l856bh:
	nop			;856b	00		.
	nop			;856c	00		.
l856dh:
	nop			;856d	00		.
	nop			;856e	00		.
l856fh:
	nop			;856f	00		.
l8570h:
	nop			;8570	00		.
	nop			;8571	00		.
l8572h:
	nop			;8572	00		.
	nop			;8573	00		.
sub_8574h:
	call sub_6c17h		;8574	cd 17 6c	. . l
	push bc			;8577	c5		.
	push de			;8578	d5		.
	ld a,l			;8579	7d		}
	call sub_8b41h		;857a	cd 41 8b	. A .
	jp z,08e90h		;857d	ca 90 8e	. . .
	cp 002h			;8580	fe 02		. .
	jp z,l8e8dh		;8582	ca 8d 8e	. . .
l8585h:
	ld hl,00027h		;8585	21 27 00	! ' .
	add hl,bc		;8588	09		.
	ld a,(hl)		;8589	7e		~
	or a			;858a	b7		.
	jp z,l85afh		;858b	ca af 85	. . .
	ld a,(bc)		;858e	0a		.
	cp 003h			;858f	fe 03		. .
	jp z,l85afh		;8591	ca af 85	. . .
	inc hl			;8594	23		#
	ld a,(hl)		;8595	7e		~
	or a			;8596	b7		.
	jp nz,l85a4h		;8597	c2 a4 85	. . .
	push bc			;859a	c5		.
	ld h,b			;859b	60		`
	ld l,c			;859c	69		i
	call sub_878bh		;859d	cd 8b 87	. . .
	pop bc			;85a0	c1		.
	jp l8585h		;85a1	c3 85 85	. . .
l85a4h:
	ld a,080h		;85a4	3e 80		> .
	sub (hl)		;85a6	96		.
	ld c,a			;85a7	4f		O
	ld b,000h		;85a8	06 00		. .
	add hl,bc		;85aa	09		.
	inc hl			;85ab	23		#
	ld a,(hl)		;85ac	7e		~
	sub 01ah		;85ad	d6 1a		. .
l85afh:
	sub 001h		;85af	d6 01		. .
	sbc a,a			;85b1	9f		.
	ld h,a			;85b2	67		g
	ld l,a			;85b3	6f		o
	pop de			;85b4	d1		.
	pop bc			;85b5	c1		.
	ret			;85b6	c9		.
sub_85b7h:
	ld d,b			;85b7	50		P
	ld e,c			;85b8	59		Y
	inc de			;85b9	13		.
sub_85bah:
	ld hl,00027h		;85ba	21 27 00	! ' .
	add hl,bc		;85bd	09		.
	push bc			;85be	c5		.
	xor a			;85bf	af		.
	ld (hl),a		;85c0	77		w
	call sub_87bfh		;85c1	cd bf 87	. . .
	ld a,(l66bah+2)		;85c4	3a bc 66	: . f
	call sub_8a85h		;85c7	cd 85 8a	. . .
	cp 0ffh			;85ca	fe ff		. .
	jp z,08eabh		;85cc	ca ab 8e	. . .
	dec a			;85cf	3d		=
	jp z,08ea5h		;85d0	ca a5 8e	. . .
	dec a			;85d3	3d		=
	jp nz,l85e3h		;85d4	c2 e3 85	. . .
	pop de			;85d7	d1		.
	xor a			;85d8	af		.
	ld (de),a		;85d9	12		.
; BDOS 16: close file
	ld c,010h		;85da	0e 10		. .
	inc de			;85dc	13		.
	call BDOS		;85dd	cd 05 00	. . .
	jp 08e96h		;85e0	c3 96 8e	. . .
l85e3h:
	inc a			;85e3	3c		<
	jp z,08eabh		;85e4	ca ab 8e	. . .
	pop bc			;85e7	c1		.
	ld hl,00025h		;85e8	21 25 00	! % .
	add hl,bc		;85eb	09		.
	ld e,(hl)		;85ec	5e		^
	inc hl			;85ed	23		#
	ld d,(hl)		;85ee	56		V
	inc de			;85ef	13		.
	ld (hl),d		;85f0	72		r
	dec hl			;85f1	2b		+
	ld (hl),e		;85f2	73		s
	ret			;85f3	c9		.
sub_85f4h:
	call sub_6c17h		;85f4	cd 17 6c	. . l
sub_85f7h:
	ld a,l			;85f7	7d		}
	and a			;85f8	a7		.
	jp z,sub_8aech		;85f9	ca ec 8a	. . .
sub_85fch:
	push bc			;85fc	c5		.
	push de			;85fd	d5		.
	push hl			;85fe	e5		.
	ld hl,00000h		;85ff	21 00 00	! . .
	ld (l856bh),hl		;8602	22 6b 85	" k .
	pop hl			;8605	e1		.
	push hl			;8606	e5		.
	ld a,l			;8607	7d		}
	call sub_8b41h		;8608	cd 41 8b	. A .
	jp z,l8638h		;860b	ca 38 86	. 8 .
	push bc			;860e	c5		.
	ld a,(bc)		;860f	0a		.
	ld d,b			;8610	50		P
	ld e,c			;8611	59		Y
	inc de			;8612	13		.
	push de			;8613	d5		.
	cp 002h			;8614	fe 02		. .
	jp nz,l862eh		;8616	c2 2e 86	. . .
	ld hl,l8625h		;8619	21 25 86	! % .
	push hl			;861c	e5		.
	push hl			;861d	e5		.
	ld h,b			;861e	60		`
	ld l,c			;861f	69		i
	ld a,01ah		;8620	3e 1a		> .
	jp l8687h		;8622	c3 87 86	. . .
l8625h:
	ld hl,00027h		;8625	21 27 00	! ' .
	add hl,bc		;8628	09		.
	ld a,(hl)		;8629	7e		~
	or a			;862a	b7		.
	call nz,sub_85bah	;862b	c4 ba 85	. . .
l862eh:
	pop de			;862e	d1		.
	call sub_87bfh		;862f	cd bf 87	. . .
; BDOS 16: close file
	ld c,010h		;8632	0e 10		. .
	call BDOS		;8634	cd 05 00	. . .
	pop bc			;8637	c1		.
l8638h:
	call sub_8bdfh		;8638	cd df 8b	. . .
	pop hl			;863b	e1		.
	pop de			;863c	d1		.
	pop bc			;863d	c1		.
	ret			;863e	c9		.
	call sub_6c17h		;863f	cd 17 6c	. . l
	push bc			;8642	c5		.
	push de			;8643	d5		.
	ld a,l			;8644	7d		}
	call sub_8b41h		;8645	cd 41 8b	. A .
	jp z,08e90h		;8648	ca 90 8e	. . .
	cp 003h			;864b	fe 03		. .
	ld hl,00026h		;864d	21 26 00	! & .
	jp nz,l8656h		;8650	c2 56 86	. V .
	ld hl,000aeh		;8653	21 ae 00	! . .
l8656h:
	add hl,bc		;8656	09		.
	ld a,(hl)		;8657	7e		~
	dec hl			;8658	2b		+
	ld l,(hl)		;8659	6e		n
	ld h,a			;865a	67		g
	pop de			;865b	d1		.
	pop bc			;865c	c1		.
	ret			;865d	c9		.
	call sub_6c17h		;865e	cd 17 6c	. . l
	push bc			;8661	c5		.
	push de			;8662	d5		.
	ld a,l			;8663	7d		}
	call sub_8b41h		;8664	cd 41 8b	. A .
	jp z,08e90h		;8667	ca 90 8e	. . .
	ld hl,00010h		;866a	21 10 00	! . .
	add hl,bc		;866d	09		.
	ld l,(hl)		;866e	6e		n
	ld h,000h		;866f	26 00		& .
	pop de			;8671	d1		.
	pop bc			;8672	c1		.
	ret			;8673	c9		.
	pop hl			;8674	e1		.
	pop af			;8675	f1		.
	push hl			;8676	e5		.
	push af			;8677	f5		.
	ld hl,(l680eh)		;8678	2a 0e 68	* . h
	ld a,(hl)		;867b	7e		~
	cp 001h			;867c	fe 01		. .
	jp z,l8e8ah		;867e	ca 8a 8e	. . .
	cp 003h			;8681	fe 03		. .
	jp z,l8d9fh		;8683	ca 9f 8d	. . .
	pop af			;8686	f1		.
l8687h:
	push de			;8687	d5		.
	push bc			;8688	c5		.
	ld b,h			;8689	44		D
	ld c,l			;868a	4d		M
	push af			;868b	f5		.
	ld de,00027h		;868c	11 27 00	. ' .
	add hl,de		;868f	19		.
	ld a,(hl)		;8690	7e		~
	cp 080h			;8691	fe 80		. .
	push hl			;8693	e5		.
	call z,sub_85b7h	;8694	cc b7 85	. . .
	pop hl			;8697	e1		.
	inc (hl)		;8698	34		4
	ld c,(hl)		;8699	4e		N
	ld b,000h		;869a	06 00		. .
	inc hl			;869c	23		#
	pop af			;869d	f1		.
	push af			;869e	f5		.
	ld d,(hl)		;869f	56		V
	cp 00dh			;86a0	fe 0d		. .
	ld (hl),b		;86a2	70		p
	jp z,l86abh		;86a3	ca ab 86	. . .
	add a,0e0h		;86a6	c6 e0		. .
	ld a,d			;86a8	7a		z
	adc a,b			;86a9	88		.
	ld (hl),a		;86aa	77		w
l86abh:
	add hl,bc		;86ab	09		.
	pop af			;86ac	f1		.
	pop bc			;86ad	c1		.
	pop de			;86ae	d1		.
	ld (hl),a		;86af	77		w
	pop hl			;86b0	e1		.
	ret			;86b1	c9		.
l86b2h:
	dec de			;86b2	1b		.
	dec hl			;86b3	2b		+
	ld (hl),e		;86b4	73		s
	inc hl			;86b5	23		#
	ld (hl),d		;86b6	72		r
	inc hl			;86b7	23		#
	ld (hl),080h		;86b8	36 80		6 .
	inc hl			;86ba	23		#
	ld (hl),080h		;86bb	36 80		6 .
	pop hl			;86bd	e1		.
	ex (sp),hl		;86be	e3		.
	ld b,h			;86bf	44		D
	ld c,l			;86c0	4d		M
	push hl			;86c1	e5		.
	ld a,(l66bah)		;86c2	3a ba 66	: . f
	or a			;86c5	b7		.
	jp z,l86d6h		;86c6	ca d6 86	. . .
	ld hl,00022h		;86c9	21 22 00	! " .
	add hl,bc		;86cc	09		.
	ld (hl),e		;86cd	73		s
	inc hl			;86ce	23		#
	ld (hl),d		;86cf	72		r
	inc hl			;86d0	23		#
	ld (hl),000h		;86d1	36 00		6 .
	jp l871bh		;86d3	c3 1b 87	. . .
l86d6h:
	ld hl,0000dh		;86d6	21 0d 00	! . .
	add hl,bc		;86d9	09		.
	ld a,e			;86da	7b		{
	rla			;86db	17		.
	ld a,d			;86dc	7a		z
	rla			;86dd	17		.
	ld d,(hl)		;86de	56		V
	cp d			;86df	ba		.
	jp z,l8713h		;86e0	ca 13 87	. . .
	push de			;86e3	d5		.
	push af			;86e4	f5		.
	push hl			;86e5	e5		.
	push bc			;86e6	c5		.
	ld de,l84b8h		;86e7	11 b8 84	. . .
; BDOS 26: set DMA address
	ld c,01ah		;86ea	0e 1a		. .
	call BDOS		;86ec	cd 05 00	. . .
	pop de			;86ef	d1		.
	push de			;86f0	d5		.
	inc de			;86f1	13		.
; BDOS 16: close file
	ld c,010h		;86f2	0e 10		. .
	call BDOS		;86f4	cd 05 00	. . .
	pop de			;86f7	d1		.
	pop hl			;86f8	e1		.
	pop af			;86f9	f1		.
	ld (hl),a		;86fa	77		w
	push de			;86fb	d5		.
	inc de			;86fc	13		.
; BDOS 15: open file
	ld c,00fh		;86fd	0e 0f		. .
	push de			;86ff	d5		.
	call BDOS		;8700	cd 05 00	. . .
	pop de			;8703	d1		.
	inc a			;8704	3c		<
	jp nz,l8711h		;8705	c2 11 87	. . .
; BDOS 22: make file
	ld c,016h		;8708	0e 16		. .
	call BDOS		;870a	cd 05 00	. . .
	inc a			;870d	3c		<
	jp z,08eabh		;870e	ca ab 8e	. . .
l8711h:
	pop bc			;8711	c1		.
	pop de			;8712	d1		.
l8713h:
	ld hl,00021h		;8713	21 21 00	! ! .
	add hl,bc		;8716	09		.
	ld a,e			;8717	7b		{
	and 07fh		;8718	e6 7f		. .
	ld (hl),a		;871a	77		w
l871bh:
	pop hl			;871b	e1		.
	ld a,(l8e7ah)		;871c	3a 7a 8e	: z .
	or a			;871f	b7		.
	jp nz,l8728h		;8720	c2 28 87	. ( .
	call sub_878bh		;8723	cd 8b 87	. . .
	pop hl			;8726	e1		.
	ret			;8727	c9		.
l8728h:
	ld hl,00021h		;8728	21 21 00	! ! .
	add hl,bc		;872b	09		.
	ld a,(hl)		;872c	7e		~
	cp 07fh			;872d	fe 7f		. .
	push af			;872f	f5		.
	ld de,l84b8h		;8730	11 b8 84	. . .
	ld hl,00029h		;8733	21 29 00	! ) .
	add hl,bc		;8736	09		.
	push de			;8737	d5		.
	push hl			;8738	e5		.
	call z,sub_8749h	;8739	cc 49 87	. I .
	call sub_85b7h		;873c	cd b7 85	. . .
	pop de			;873f	d1		.
	pop hl			;8740	e1		.
	pop af			;8741	f1		.
	call z,sub_8749h	;8742	cc 49 87	. I .
	pop hl			;8745	e1		.
	jp l8e81h		;8746	c3 81 8e	. . .
sub_8749h:
	push bc			;8749	c5		.
	ld b,080h		;874a	06 80		. .
l874ch:
	ld a,(hl)		;874c	7e		~
	inc hl			;874d	23		#
	ld (de),a		;874e	12		.
	inc de			;874f	13		.
	dec b			;8750	05		.
	jp nz,l874ch		;8751	c2 4c 87	. L .
	pop bc			;8754	c1		.
	ret			;8755	c9		.
sub_8756h:
	push bc			;8756	c5		.
	push hl			;8757	e5		.
l8758h:
	ld hl,(l680eh)		;8758	2a 0e 68	* . h
	ld a,(hl)		;875b	7e		~
	cp 003h			;875c	fe 03		. .
	jp z,l8dcdh		;875e	ca cd 8d	. . .
	ld bc,00028h		;8761	01 28 00	. ( .
	add hl,bc		;8764	09		.
	ld a,(hl)		;8765	7e		~
	or a			;8766	b7		.
	jp z,l8776h		;8767	ca 76 87	. v .
	dec hl			;876a	2b		+
	ld a,(hl)		;876b	7e		~
	inc hl			;876c	23		#
	dec (hl)		;876d	35		5
	sub (hl)		;876e	96		.
	ld c,a			;876f	4f		O
	add hl,bc		;8770	09		.
	ld a,(hl)		;8771	7e		~
	or a			;8772	b7		.
	pop hl			;8773	e1		.
	pop bc			;8774	c1		.
	ret			;8775	c9		.
l8776h:
	dec hl			;8776	2b		+
	ld a,(hl)		;8777	7e		~
	or a			;8778	b7		.
	jp z,l8782h		;8779	ca 82 87	. . .
	call sub_8788h		;877c	cd 88 87	. . .
	jp nz,l8758h		;877f	c2 58 87	. X .
l8782h:
	scf			;8782	37		7
	pop hl			;8783	e1		.
	pop bc			;8784	c1		.
	ld a,01ah		;8785	3e 1a		> .
	ret			;8787	c9		.
sub_8788h:
	ld hl,(l680eh)		;8788	2a 0e 68	* . h
sub_878bh:
	push de			;878b	d5		.
	ld d,h			;878c	54		T
	ld e,l			;878d	5d		]
	inc de			;878e	13		.
	ld bc,00025h		;878f	01 25 00	. % .
	add hl,bc		;8792	09		.
	ld c,(hl)		;8793	4e		N
	inc hl			;8794	23		#
	ld b,(hl)		;8795	46		F
	inc bc			;8796	03		.
	dec hl			;8797	2b		+
	ld (hl),c		;8798	71		q
	inc hl			;8799	23		#
	ld (hl),b		;879a	70		p
	inc hl			;879b	23		#
	inc hl			;879c	23		#
	push hl			;879d	e5		.
	ld c,080h		;879e	0e 80		. .
l87a0h:
	inc hl			;87a0	23		#
	ld (hl),000h		;87a1	36 00		6 .
	dec c			;87a3	0d		.
	jp nz,l87a0h		;87a4	c2 a0 87	. . .
	call sub_87bfh		;87a7	cd bf 87	. . .
	ld a,(l66bah+1)		;87aa	3a bb 66	: . f
	call sub_8a85h		;87ad	cd 85 8a	. . .
	or a			;87b0	b7		.
	ld a,000h		;87b1	3e 00		> .
	jp nz,l87b8h		;87b3	c2 b8 87	. . .
	ld a,080h		;87b6	3e 80		> .
l87b8h:
	pop hl			;87b8	e1		.
	ld (hl),a		;87b9	77		w
	dec hl			;87ba	2b		+
	ld (hl),a		;87bb	77		w
	or a			;87bc	b7		.
	pop de			;87bd	d1		.
	ret			;87be	c9		.
sub_87bfh:
	push bc			;87bf	c5		.
	push de			;87c0	d5		.
	push hl			;87c1	e5		.
	ld hl,00028h		;87c2	21 28 00	! ( .
	add hl,de		;87c5	19		.
	ex de,hl		;87c6	eb		.
; BDOS 26: set DMA address
	ld c,01ah		;87c7	0e 1a		. .
	call BDOS		;87c9	cd 05 00	. . .
	pop hl			;87cc	e1		.
	pop de			;87cd	d1		.
	pop bc			;87ce	c1		.
	ret			;87cf	c9		.
sub_87d0h:
	call sub_8756h		;87d0	cd 56 87	. V .
	ret c			;87d3	d8		.
	cp 01ah			;87d4	fe 1a		. .
	scf			;87d6	37		7
	ccf			;87d7	3f		?
	ret nz			;87d8	c0		.
	push bc			;87d9	c5		.
	push hl			;87da	e5		.
	ld hl,(l680eh)		;87db	2a 0e 68	* . h
	ld bc,00027h		;87de	01 27 00	. ' .
	add hl,bc		;87e1	09		.
	ld (hl),000h		;87e2	36 00		6 .
	inc hl			;87e4	23		#
	ld (hl),000h		;87e5	36 00		6 .
	scf			;87e7	37		7
	pop hl			;87e8	e1		.
	pop bc			;87e9	c1		.
	ret			;87ea	c9		.
sub_87ebh:
	push hl			;87eb	e5		.
	ld a,(hl)		;87ec	7e		~
	or a			;87ed	b7		.
	jp z,08ea8h		;87ee	ca a8 8e	. . .
	push af			;87f1	f5		.
	inc hl			;87f2	23		#
	ld e,(hl)		;87f3	5e		^
	inc hl			;87f4	23		#
	ld h,(hl)		;87f5	66		f
	ld l,e			;87f6	6b		k
	ld e,a			;87f7	5f		_
	cp 002h			;87f8	fe 02		. .
	jp c,l8808h		;87fa	da 08 88	. . .
	ld c,(hl)		;87fd	4e		N
	inc hl			;87fe	23		#
	ld a,(hl)		;87ff	7e		~
	dec e			;8800	1d		.
	cp 03ah			;8801	fe 3a		. :
	jp z,l880ch		;8803	ca 0c 88	. . .
	dec hl			;8806	2b		+
	inc e			;8807	1c		.
l8808h:
	dec hl			;8808	2b		+
	inc e			;8809	1c		.
	ld c,040h		;880a	0e 40		. @
l880ch:
	dec e			;880c	1d		.
	jp z,08ea8h		;880d	ca a8 8e	. . .
	ld a,c			;8810	79		y
	sub 040h		;8811	d6 40		. @
	jp c,08ea8h		;8813	da a8 8e	. . .
	cp 01bh			;8816	fe 1b		. .
	jp nc,08ea8h		;8818	d2 a8 8e	. . .
	ld bc,l8548h		;881b	01 48 85	. H .
	ld (bc),a		;881e	02		.
	inc bc			;881f	03		.
	ld d,00bh		;8820	16 0b		. .
l8822h:
	inc hl			;8822	23		#
l8823h:
	dec e			;8823	1d		.
	jp m,l885dh		;8824	fa 5d 88	. ] .
	ld a,(hl)		;8827	7e		~
	cp 02eh			;8828	fe 2e		. .
	jp nz,l8836h		;882a	c2 36 88	. 6 .
	call sub_8849h		;882d	cd 49 88	. I .
	pop af			;8830	f1		.
	scf			;8831	37		7
	push af			;8832	f5		.
	jp l8822h		;8833	c3 22 88	. " .
l8836h:
	ld (bc),a		;8836	02		.
	inc bc			;8837	03		.
	inc hl			;8838	23		#
	dec d			;8839	15		.
	jp nz,l8823h		;883a	c2 23 88	. # .
l883dh:
	xor a			;883d	af		.
	ld (l8554h),a		;883e	32 54 85	2 T .
	pop af			;8841	f1		.
	pop hl			;8842	e1		.
	push af			;8843	f5		.
	call sub_78d7h		;8844	cd d7 78	. . x
	pop af			;8847	f1		.
	ret			;8848	c9		.
sub_8849h:
	ld a,d			;8849	7a		z
	cp 00bh			;884a	fe 0b		. .
	jp z,08ea8h		;884c	ca a8 8e	. . .
	cp 003h			;884f	fe 03		. .
	jp c,08ea8h		;8851	da a8 8e	. . .
	ret z			;8854	c8		.
	ld a,020h		;8855	3e 20		>  
	ld (bc),a		;8857	02		.
	inc bc			;8858	03		.
	dec d			;8859	15		.
	jp sub_8849h		;885a	c3 49 88	. I .
l885dh:
	inc d			;885d	14		.
	dec d			;885e	15		.
	jp z,l883dh		;885f	ca 3d 88	. = .
l8862h:
	ld a,020h		;8862	3e 20		>  
	ld (bc),a		;8864	02		.
	inc bc			;8865	03		.
	dec d			;8866	15		.
	jp nz,l8862h		;8867	c2 62 88	. b .
	jp l883dh		;886a	c3 3d 88	. = .
	call sub_6c17h		;886d	cd 17 6c	. . l
	push bc			;8870	c5		.
	push de			;8871	d5		.
	push hl			;8872	e5		.
	ex de,hl		;8873	eb		.
	call sub_87ebh		;8874	cd eb 87	. . .
	ld de,l84b8h		;8877	11 b8 84	. . .
; BDOS 26: set DMA address
	ld c,01ah		;887a	0e 1a		. .
	call BDOS		;887c	cd 05 00	. . .
	ld de,l8548h		;887f	11 48 85	. H .
; BDOS 15: open file
	ld c,00fh		;8882	0e 0f		. .
	call BDOS		;8884	cd 05 00	. . .
	inc a			;8887	3c		<
	jp z,08e9fh		;8888	ca 9f 8e	. . .
	ld hl,l8538h		;888b	21 38 85	! 8 .
	ld de,l8548h		;888e	11 48 85	. H .
	ld a,00ch		;8891	3e 0c		> .
	call sub_9177h		;8893	cd 77 91	. w .
	pop hl			;8896	e1		.
	push hl			;8897	e5		.
	call sub_87ebh		;8898	cd eb 87	. . .
	ld a,(l8548h)		;889b	3a 48 85	: H .
	ld hl,l8538h		;889e	21 38 85	! 8 .
	cp (hl)			;88a1	be		.
	jp nz,08eaeh		;88a2	c2 ae 8e	. . .
	ld de,l8548h		;88a5	11 48 85	. H .
; BDOS 15: open file
	ld c,00fh		;88a8	0e 0f		. .
	call BDOS		;88aa	cd 05 00	. . .
	inc a			;88ad	3c		<
	jp nz,08e99h		;88ae	c2 99 8e	. . .
; BDOS 23: rename file
	ld c,017h		;88b1	0e 17		. .
	ld de,l8538h		;88b3	11 38 85	. 8 .
	call BDOS		;88b6	cd 05 00	. . .
	pop hl			;88b9	e1		.
	pop de			;88ba	d1		.
	pop bc			;88bb	c1		.
	ret			;88bc	c9		.
sub_88bdh:
	push de			;88bd	d5		.
	push bc			;88be	c5		.
	ld hl,(l8569h)		;88bf	2a 69 85	* i .
	ld a,(hl)		;88c2	7e		~
	or a			;88c3	b7		.
	jp z,l8e8dh		;88c4	ca 8d 8e	. . .
	inc hl			;88c7	23		#
	ld c,(hl)		;88c8	4e		N
	inc hl			;88c9	23		#
	ld b,(hl)		;88ca	46		F
	dec hl			;88cb	2b		+
	dec hl			;88cc	2b		+
	call sub_78d7h		;88cd	cd d7 78	. . x
	ld a,(bc)		;88d0	0a		.
	and 0dfh		;88d1	e6 df		. .
	ld d,002h		;88d3	16 02		. .
	cp 04fh			;88d5	fe 4f		. O
	jp z,l88f6h		;88d7	ca f6 88	. . .
	ld d,001h		;88da	16 01		. .
	cp 049h			;88dc	fe 49		. I
	jp z,l88f6h		;88de	ca f6 88	. . .
	ld d,003h		;88e1	16 03		. .
	cp 052h			;88e3	fe 52		. R
	jp nz,l8e8dh		;88e5	c2 8d 8e	. . .
	ld hl,(l856bh)		;88e8	2a 6b 85	* k .
	ld a,h			;88eb	7c		|
	or l			;88ec	b5		.
	jp nz,l88f6h		;88ed	c2 f6 88	. . .
	ld hl,00080h		;88f0	21 80 00	! . .
	ld (l856bh),hl		;88f3	22 6b 85	" k .
l88f6h:
	pop hl			;88f6	e1		.
	push de			;88f7	d5		.
	ld a,l			;88f8	7d		}
	pop de			;88f9	d1		.
	ld e,a			;88fa	5f		_
	push de			;88fb	d5		.
	call sub_8b41h		;88fc	cd 41 8b	. A .
	jp nz,l8909h		;88ff	c2 09 89	. . .
	call sub_8bdfh		;8902	cd df 8b	. . .
	ld a,e			;8905	7b		{
	call sub_8b41h		;8906	cd 41 8b	. A .
l8909h:
	jp nz,08e9ch		;8909	c2 9c 8e	. . .
	pop de			;890c	d1		.
	ld a,d			;890d	7a		z
	ld (bc),a		;890e	02		.
	pop hl			;890f	e1		.
	push bc			;8910	c5		.
	push de			;8911	d5		.
	call sub_87ebh		;8912	cd eb 87	. . .
	pop de			;8915	d1		.
	pop bc			;8916	c1		.
	push bc			;8917	c5		.
	push af			;8918	f5		.
	ld a,(bc)		;8919	0a		.
	call sub_8c1bh		;891a	cd 1b 8c	. . .
	pop af			;891d	f1		.
	pop hl			;891e	e1		.
	ld (l680eh),hl		;891f	22 0e 68	" . h
	push hl			;8922	e5		.
	inc hl			;8923	23		#
	ld de,l8548h		;8924	11 48 85	. H .
	ld a,00ch		;8927	3e 0c		> .
	call sub_9177h		;8929	cd 77 91	. w .
	ld (hl),000h		;892c	36 00		6 .
	ld de,00014h		;892e	11 14 00	. . .
	add hl,de		;8931	19		.
	ld (hl),000h		;8932	36 00		6 .
	pop de			;8934	d1		.
	push de			;8935	d5		.
	inc de			;8936	13		.
	call sub_87bfh		;8937	cd bf 87	. . .
	pop hl			;893a	e1		.
	push hl			;893b	e5		.
	ld a,(hl)		;893c	7e		~
	cp 002h			;893d	fe 02		. .
	jp nz,l8955h		;893f	c2 55 89	. U .
	push de			;8942	d5		.
; BDOS 19: delete file
	ld c,013h		;8943	0e 13		. .
	call BDOS		;8945	cd 05 00	. . .
	pop de			;8948	d1		.
l8949h:
; BDOS 22: make file
	ld c,016h		;8949	0e 16		. .
	call BDOS		;894b	cd 05 00	. . .
	inc a			;894e	3c		<
	jp z,08eabh		;894f	ca ab 8e	. . .
	jp l896ah		;8952	c3 6a 89	. j .
l8955h:
; BDOS 15: open file
	ld c,00fh		;8955	0e 0f		. .
	call BDOS		;8957	cd 05 00	. . .
	inc a			;895a	3c		<
	jp nz,l896ah		;895b	c2 6a 89	. j .
	pop de			;895e	d1		.
	push de			;895f	d5		.
	ld a,(de)		;8960	1a		.
	cp 003h			;8961	fe 03		. .
	jp nz,08e9fh		;8963	c2 9f 8e	. . .
	inc de			;8966	13		.
	jp l8949h		;8967	c3 49 89	. I .
l896ah:
	pop de			;896a	d1		.
	push de			;896b	d5		.
	ld hl,00025h		;896c	21 25 00	! % .
	add hl,de		;896f	19		.
	xor a			;8970	af		.
	ld (hl),a		;8971	77		w
	inc hl			;8972	23		#
	ld (hl),a		;8973	77		w
	inc hl			;8974	23		#
	ld (hl),a		;8975	77		w
	inc hl			;8976	23		#
	ld (hl),a		;8977	77		w
	pop hl			;8978	e1		.
	ld a,(hl)		;8979	7e		~
	cp 003h			;897a	fe 03		. .
	jp z,l8986h		;897c	ca 86 89	. . .
	cp 001h			;897f	fe 01		. .
	ret nz			;8981	c0		.
	call sub_8788h		;8982	cd 88 87	. . .
	ret			;8985	c9		.
l8986h:
	ld bc,00029h		;8986	01 29 00	. ) .
	add hl,bc		;8989	09		.
	ld c,080h		;898a	0e 80		. .
l898ch:
	ld (hl),b		;898c	70		p
	inc hl			;898d	23		#
	dec c			;898e	0d		.
	jp nz,l898ch		;898f	c2 8c 89	. . .
	ret			;8992	c9		.
sub_8993h:
	push hl			;8993	e5		.
	push de			;8994	d5		.
	push bc			;8995	c5		.
	call sub_8aech		;8996	cd ec 8a	. . .
; BDOS 25: get current disk
	ld c,019h		;8999	0e 19		. .
	call BDOS		;899b	cd 05 00	. . .
	push af			;899e	f5		.
; BDOS 13: reset disk system
	ld c,00dh		;899f	0e 0d		. .
	call BDOS		;89a1	cd 05 00	. . .
	pop af			;89a4	f1		.
	ld e,a			;89a5	5f		_
; BDOS 14: select disk
	ld c,00eh		;89a6	0e 0e		. .
	call BDOS		;89a8	cd 05 00	. . .
	pop bc			;89ab	c1		.
	pop de			;89ac	d1		.
	pop hl			;89ad	e1		.
	ret			;89ae	c9		.
sub_89afh:
	call sub_6c17h		;89af	cd 17 6c	. . l
	push bc			;89b2	c5		.
	push de			;89b3	d5		.
	push hl			;89b4	e5		.
	call sub_87ebh		;89b5	cd eb 87	. . .
	ld de,l84b8h		;89b8	11 b8 84	. . .
; BDOS 26: set DMA address
	ld c,01ah		;89bb	0e 1a		. .
	call BDOS		;89bd	cd 05 00	. . .
	ld de,l8548h		;89c0	11 48 85	. H .
	push de			;89c3	d5		.
; BDOS 15: open file
	ld c,00fh		;89c4	0e 0f		. .
	call BDOS		;89c6	cd 05 00	. . .
	inc a			;89c9	3c		<
	pop de			;89ca	d1		.
	push de			;89cb	d5		.
	push af			;89cc	f5		.
; BDOS 16: close file
	ld c,010h		;89cd	0e 10		. .
	call nz,BDOS		;89cf	c4 05 00	. . .
	pop af			;89d2	f1		.
	pop de			;89d3	d1		.
	jp z,08e9fh		;89d4	ca 9f 8e	. . .
; BDOS 19: delete file
	ld c,013h		;89d7	0e 13		. .
	call BDOS		;89d9	cd 05 00	. . .
	pop hl			;89dc	e1		.
	pop de			;89dd	d1		.
	pop bc			;89de	c1		.
	ret			;89df	c9		.
	call sub_6c17h		;89e0	cd 17 6c	. . l
	push bc			;89e3	c5		.
	push de			;89e4	d5		.
	push hl			;89e5	e5		.
	ld hl,l8548h		;89e6	21 48 85	! H .
	ld (hl),000h		;89e9	36 00		6 .
	inc hl			;89eb	23		#
	ld c,00bh		;89ec	0e 0b		. .
	call sub_8a7dh		;89ee	cd 7d 8a	. } .
	jp l89fdh		;89f1	c3 fd 89	. . .
	call sub_6c17h		;89f4	cd 17 6c	. . l
	push bc			;89f7	c5		.
	push de			;89f8	d5		.
	push hl			;89f9	e5		.
	call sub_87ebh		;89fa	cd eb 87	. . .
l89fdh:
	xor a			;89fd	af		.
	ld (l8554h),a		;89fe	32 54 85	2 T .
	ld hl,l8549h		;8a01	21 49 85	! I .
	ld c,008h		;8a04	0e 08		. .
	call sub_8a79h		;8a06	cd 79 8a	. y .
	ld hl,l8551h		;8a09	21 51 85	! Q .
	ld c,003h		;8a0c	0e 03		. .
	call sub_8a79h		;8a0e	cd 79 8a	. y .
	ld de,l84b8h		;8a11	11 b8 84	. . .
; BDOS 26: set DMA address
	ld c,01ah		;8a14	0e 1a		. .
	call BDOS		;8a16	cd 05 00	. . .
	ld de,l8548h		;8a19	11 48 85	. H .
; BDOS 17: search for first
	ld c,011h		;8a1c	0e 11		. .
	call BDOS		;8a1e	cd 05 00	. . .
	cp 0ffh			;8a21	fe ff		. .
	jp z,08e9fh		;8a23	ca 9f 8e	. . .
l8a26h:
	and 003h		;8a26	e6 03		. .
	add a,a			;8a28	87		.
	add a,a			;8a29	87		.
	add a,a			;8a2a	87		.
	add a,a			;8a2b	87		.
	add a,a			;8a2c	87		.
	ld c,a			;8a2d	4f		O
	ld b,000h		;8a2e	06 00		. .
	ld hl,l84b9h		;8a30	21 b9 84	! . .
	add hl,bc		;8a33	09		.
	ld c,00bh		;8a34	0e 0b		. .
l8a36h:
	ld a,(hl)		;8a36	7e		~
	inc hl			;8a37	23		#
	call sub_8fdbh		;8a38	cd db 8f	. . .
	ld a,c			;8a3b	79		y
	cp 004h			;8a3c	fe 04		. .
	jp nz,l8a4ch		;8a3e	c2 4c 8a	. L .
	ld a,(hl)		;8a41	7e		~
	cp 020h			;8a42	fe 20		.  
	jp z,l8a49h		;8a44	ca 49 8a	. I .
	ld a,02eh		;8a47	3e 2e		> .
l8a49h:
	call sub_8fdbh		;8a49	cd db 8f	. . .
l8a4ch:
	dec c			;8a4c	0d		.
	jp nz,l8a36h		;8a4d	c2 36 8a	. 6 .
	ld a,(l6839h)		;8a50	3a 39 68	: 9 h
	add a,00dh		;8a53	c6 0d		. .
	ld d,a			;8a55	57		W
	ld a,(l6839h+1)		;8a56	3a 3a 68	: : h
	cp d			;8a59	ba		.
	jp c,l8a65h		;8a5a	da 65 8a	. e .
	ld a,020h		;8a5d	3e 20		>  
	call sub_8fdbh		;8a5f	cd db 8f	. . .
	call sub_8fdbh		;8a62	cd db 8f	. . .
l8a65h:
	call c,sub_8fd8h	;8a65	dc d8 8f	. . .
	ld de,l8548h		;8a68	11 48 85	. H .
; BDOS 18: search for next
	ld c,012h		;8a6b	0e 12		. .
	call BDOS		;8a6d	cd 05 00	. . .
	cp 0ffh			;8a70	fe ff		. .
	jp nz,l8a26h		;8a72	c2 26 8a	. & .
	pop hl			;8a75	e1		.
	pop de			;8a76	d1		.
	pop bc			;8a77	c1		.
	ret			;8a78	c9		.
sub_8a79h:
	ld a,(hl)		;8a79	7e		~
	cp 02ah			;8a7a	fe 2a		. *
	ret nz			;8a7c	c0		.
sub_8a7dh:
	ld (hl),03fh		;8a7d	36 3f		6 ?
	inc hl			;8a7f	23		#
	dec c			;8a80	0d		.
	jp nz,sub_8a7dh		;8a81	c2 7d 8a	. } .
	ret			;8a84	c9		.
sub_8a85h:
	push de			;8a85	d5		.
; BDOS function number comes from A
	ld c,a			;8a86	4f		O
	push bc			;8a87	c5		.
	call BDOS		;8a88	cd 05 00	. . .
	pop bc			;8a8b	c1		.
	pop de			;8a8c	d1		.
	push af			;8a8d	f5		.
	ld hl,00021h		;8a8e	21 21 00	! ! .
	add hl,de		;8a91	19		.
	inc (hl)		;8a92	34		4
	jp nz,l8a9dh		;8a93	c2 9d 8a	. . .
	inc hl			;8a96	23		#
	inc (hl)		;8a97	34		4
	jp nz,l8a9dh		;8a98	c2 9d 8a	. . .
	inc hl			;8a9b	23		#
	inc (hl)		;8a9c	34		4
l8a9dh:
	ld a,c			;8a9d	79		y
	cp 022h			;8a9e	fe 22		. "
	jp nz,l8ab2h		;8aa0	c2 b2 8a	. . .
	pop af			;8aa3	f1		.
	or a			;8aa4	b7		.
	ret z			;8aa5	c8		.
	cp 005h			;8aa6	fe 05		. .
	jp z,08eabh		;8aa8	ca ab 8e	. . .
	cp 003h			;8aab	fe 03		. .
	ld a,001h		;8aad	3e 01		> .
	ret z			;8aaf	c8		.
	inc a			;8ab0	3c		<
	ret			;8ab1	c9		.
l8ab2h:
	pop af			;8ab2	f1		.
	ret			;8ab3	c9		.
sub_8ab4h:
	ld (l8569h),hl		;8ab4	22 69 85	" i .
	ld a,001h		;8ab7	3e 01		> .
	ld (l6814h),a		;8ab9	32 14 68	2 . h
	push hl			;8abc	e5		.
	ld hl,l8e08h		;8abd	21 08 8e	! . .
	ld (l6814h+1),hl	;8ac0	22 15 68	" . h
	pop hl			;8ac3	e1		.
	ld a,(06812h)		;8ac4	3a 12 68	: . h
	and a			;8ac7	a7		.
	ret nz			;8ac8	c0		.
	inc a			;8ac9	3c		<
	ld (06812h),a		;8aca	32 12 68	2 . h
	push hl			;8acd	e5		.
	ld hl,(l680eh+2)	;8ace	2a 10 68	* . h
	ld (l856dh),hl		;8ad1	22 6d 85	" m .
	ld hl,l8b00h		;8ad4	21 00 8b	! . .
	ld (l680eh+2),hl	;8ad7	22 10 68	" . h
	pop hl			;8ada	e1		.
	ret			;8adb	c9		.
sub_8adch:
	call sub_6c17h		;8adc	cd 17 6c	. . l
	ld (l856bh),hl		;8adf	22 6b 85	" k .
	push hl			;8ae2	e5		.
	push de			;8ae3	d5		.
	push bc			;8ae4	c5		.
	call sub_88bdh		;8ae5	cd bd 88	. . .
	pop bc			;8ae8	c1		.
	pop de			;8ae9	d1		.
	pop hl			;8aea	e1		.
	ret			;8aeb	c9		.
sub_8aech:
	push hl			;8aec	e5		.
l8aedh:
	ld hl,(06822h)		;8aed	2a 22 68	* " h
	ld a,h			;8af0	7c		|
	or l			;8af1	b5		.
	jp z,l8afeh		;8af2	ca fe 8a	. . .
	inc hl			;8af5	23		#
	inc hl			;8af6	23		#
	ld l,(hl)		;8af7	6e		n
	call sub_85fch		;8af8	cd fc 85	. . .
	jp l8aedh		;8afb	c3 ed 8a	. . .
l8afeh:
	pop hl			;8afe	e1		.
	ret			;8aff	c9		.
l8b00h:
	ld l,000h		;8b00	2e 00		. .
	call sub_85f7h		;8b02	cd f7 85	. . .
	ld hl,(l856dh)		;8b05	2a 6d 85	* m .
	jp (hl)			;8b08	e9		.
	call sub_6c17h		;8b09	cd 17 6c	. . l
	or 001h			;8b0c	f6 01		. .
	jp l8b15h		;8b0e	c3 15 8b	. . .
sub_8b11h:
	call sub_6c17h		;8b11	cd 17 6c	. . l
	xor a			;8b14	af		.
l8b15h:
	ld (l856fh),a		;8b15	32 6f 85	2 o .
	push bc			;8b18	c5		.
	push de			;8b19	d5		.
	push hl			;8b1a	e5		.
	jp nz,l8c3dh		;8b1b	c2 3d 8c	. = .
	ld (l8570h),hl		;8b1e	22 70 85	" p .
	ex de,hl		;8b21	eb		.
	jp l8c3dh		;8b22	c3 3d 8c	. = .
	call sub_6c17h		;8b25	cd 17 6c	. . l
	or 001h			;8b28	f6 01		. .
	jp l8b31h		;8b2a	c3 31 8b	. 1 .
sub_8b2dh:
	call sub_6c17h		;8b2d	cd 17 6c	. . l
	xor a			;8b30	af		.
l8b31h:
	ld (l856fh),a		;8b31	32 6f 85	2 o .
	push bc			;8b34	c5		.
	push de			;8b35	d5		.
	push hl			;8b36	e5		.
	jp nz,l8c3dh+1		;8b37	c2 3e 8c	. > .
	ld (l8570h),hl		;8b3a	22 70 85	" p .
	ex de,hl		;8b3d	eb		.
	jp l8c3dh+1		;8b3e	c3 3e 8c	. > .
sub_8b41h:
	and a			;8b41	a7		.
	jp z,08e90h		;8b42	ca 90 8e	. . .
	inc a			;8b45	3c		<
	jp z,08e90h		;8b46	ca 90 8e	. . .
	dec a			;8b49	3d		=
	ld e,a			;8b4a	5f		_
	ld d,000h		;8b4b	16 00		. .
	push hl			;8b4d	e5		.
	ld hl,06822h		;8b4e	21 22 68	! " h
l8b51h:
	ld a,(hl)		;8b51	7e		~
	inc hl			;8b52	23		#
	ld h,(hl)		;8b53	66		f
	ld l,a			;8b54	6f		o
	or h			;8b55	b4		.
	jp z,l8b65h		;8b56	ca 65 8b	. e .
	inc hl			;8b59	23		#
	inc hl			;8b5a	23		#
	ld a,e			;8b5b	7b		{
	cp (hl)			;8b5c	be		.
	jp z,l8b7bh		;8b5d	ca 7b 8b	. { .
	dec hl			;8b60	2b		+
	dec hl			;8b61	2b		+
	jp l8b51h		;8b62	c3 51 8b	. Q .
l8b65h:
	ld hl,(06822h)		;8b65	2a 22 68	* " h
	push hl			;8b68	e5		.
	call sub_8b84h		;8b69	cd 84 8b	. . .
	ld (06822h),hl		;8b6c	22 22 68	" " h
	pop bc			;8b6f	c1		.
	ld (hl),c		;8b70	71		q
	inc hl			;8b71	23		#
	ld (hl),b		;8b72	70		p
	inc hl			;8b73	23		#
	ld (hl),e		;8b74	73		s
	inc hl			;8b75	23		#
	inc (hl)		;8b76	34		4
	inc hl			;8b77	23		#
	dec (hl)		;8b78	35		5
	dec hl			;8b79	2b		+
	dec hl			;8b7a	2b		+
l8b7bh:
	inc hl			;8b7b	23		#
	inc hl			;8b7c	23		#
	inc hl			;8b7d	23		#
	ld b,h			;8b7e	44		D
	ld c,l			;8b7f	4d		M
	ld a,(bc)		;8b80	0a		.
	and a			;8b81	a7		.
	pop hl			;8b82	e1		.
	ret			;8b83	c9		.
sub_8b84h:
	push bc			;8b84	c5		.
	push de			;8b85	d5		.
	ld hl,l6824h		;8b86	21 24 68	! $ h
l8b89h:
	ld (l8572h),hl		;8b89	22 72 85	" r .
	ld a,(hl)		;8b8c	7e		~
	inc hl			;8b8d	23		#
	ld h,(hl)		;8b8e	66		f
	ld l,a			;8b8f	6f		o
	or h			;8b90	b4		.
	jp z,l8bbdh		;8b91	ca bd 8b	. . .
	dec hl			;8b94	2b		+
	ld d,(hl)		;8b95	56		V
	dec hl			;8b96	2b		+
	ld e,(hl)		;8b97	5e		^
	inc hl			;8b98	23		#
	inc hl			;8b99	23		#
	push hl			;8b9a	e5		.
	ld hl,(l856bh)		;8b9b	2a 6b 85	* k .
	ld a,e			;8b9e	7b		{
	sub l			;8b9f	95		.
	ld a,d			;8ba0	7a		z
	sbc a,h			;8ba1	9c		.
	pop hl			;8ba2	e1		.
	jp c,l8b89h		;8ba3	da 89 8b	. . .
	ld b,d			;8ba6	42		B
	ld c,e			;8ba7	4b		K
	ld e,(hl)		;8ba8	5e		^
	inc hl			;8ba9	23		#
	ld d,(hl)		;8baa	56		V
	dec hl			;8bab	2b		+
	push hl			;8bac	e5		.
	ld hl,(l8572h)		;8bad	2a 72 85	* r .
	ld (hl),e		;8bb0	73		s
	inc hl			;8bb1	23		#
	ld (hl),d		;8bb2	72		r
	ld hl,000b9h		;8bb3	21 b9 00	! . .
	add hl,bc		;8bb6	09		.
	ld b,h			;8bb7	44		D
	ld c,l			;8bb8	4d		M
	pop hl			;8bb9	e1		.
	jp l8bcfh		;8bba	c3 cf 8b	. . .
l8bbdh:
	ld bc,000b9h		;8bbd	01 b9 00	. . .
	ld hl,(l856bh)		;8bc0	2a 6b 85	* k .
	push hl			;8bc3	e5		.
	add hl,bc		;8bc4	09		.
	ld b,h			;8bc5	44		D
	ld c,l			;8bc6	4d		M
	call sub_79b0h		;8bc7	cd b0 79	. . y
	pop de			;8bca	d1		.
	ld (hl),e		;8bcb	73		s
	inc hl			;8bcc	23		#
	ld (hl),d		;8bcd	72		r
	inc hl			;8bce	23		#
l8bcfh:
	push hl			;8bcf	e5		.
	dec bc			;8bd0	0b		.
	dec bc			;8bd1	0b		.
l8bd2h:
	ld (hl),000h		;8bd2	36 00		6 .
	inc hl			;8bd4	23		#
	dec bc			;8bd5	0b		.
	ld a,b			;8bd6	78		x
	or c			;8bd7	b1		.
	jp nz,l8bd2h		;8bd8	c2 d2 8b	. . .
	pop hl			;8bdb	e1		.
	pop de			;8bdc	d1		.
	pop bc			;8bdd	c1		.
	ret			;8bde	c9		.
sub_8bdfh:
	push bc			;8bdf	c5		.
	push de			;8be0	d5		.
	push hl			;8be1	e5		.
	dec bc			;8be2	0b		.
	dec bc			;8be3	0b		.
	dec bc			;8be4	0b		.
	dec bc			;8be5	0b		.
	dec bc			;8be6	0b		.
	ld hl,06822h		;8be7	21 22 68	! " h
l8beah:
	ld d,h			;8bea	54		T
	ld e,l			;8beb	5d		]
	ld a,(hl)		;8bec	7e		~
	inc hl			;8bed	23		#
	ld h,(hl)		;8bee	66		f
	ld l,a			;8bef	6f		o
	or h			;8bf0	b4		.
	jp z,08e90h		;8bf1	ca 90 8e	. . .
	ld a,b			;8bf4	78		x
	cp h			;8bf5	bc		.
	jp nz,l8beah		;8bf6	c2 ea 8b	. . .
	ld a,c			;8bf9	79		y
	cp l			;8bfa	bd		.
	jp nz,l8beah		;8bfb	c2 ea 8b	. . .
	ld a,(hl)		;8bfe	7e		~
	ld (de),a		;8bff	12		.
	inc hl			;8c00	23		#
	inc de			;8c01	13		.
	ld a,(hl)		;8c02	7e		~
	ld (de),a		;8c03	12		.
	dec hl			;8c04	2b		+
	ex de,hl		;8c05	eb		.
	ld hl,(l6824h)		;8c06	2a 24 68	* $ h
	ex de,hl		;8c09	eb		.
	ld (l6824h),hl		;8c0a	22 24 68	" $ h
	ld (hl),e		;8c0d	73		s
	inc hl			;8c0e	23		#
	ld (hl),d		;8c0f	72		r
	pop hl			;8c10	e1		.
	pop de			;8c11	d1		.
	pop bc			;8c12	c1		.
	ret			;8c13	c9		.
l8c14h:
	nop			;8c14	00		.
	nop			;8c15	00		.
l8c16h:
	nop			;8c16	00		.
	nop			;8c17	00		.
l8c18h:
	nop			;8c18	00		.
	nop			;8c19	00		.
l8c1ah:
	nop			;8c1a	00		.
sub_8c1bh:
	cp 003h			;8c1b	fe 03		. .
	ret nz			;8c1d	c0		.
	ld hl,(l856bh)		;8c1e	2a 6b 85	* k .
	push de			;8c21	d5		.
	ld de,00080h		;8c22	11 80 00	. . .
	ld a,h			;8c25	7c		|
	or l			;8c26	b5		.
	jp z,l8c2bh		;8c27	ca 2b 8c	. + .
	ex de,hl		;8c2a	eb		.
l8c2bh:
	ld hl,000a9h		;8c2b	21 a9 00	! . .
	add hl,bc		;8c2e	09		.
	ld (hl),e		;8c2f	73		s
	inc hl			;8c30	23		#
	ld (hl),d		;8c31	72		r
	xor a			;8c32	af		.
	ld e,007h		;8c33	1e 07		. .
l8c35h:
	inc hl			;8c35	23		#
	ld (hl),a		;8c36	77		w
	dec e			;8c37	1d		.
	jp nz,l8c35h		;8c38	c2 35 8c	. 5 .
	pop de			;8c3b	d1		.
	ret			;8c3c	c9		.
l8c3dh:
	or 0afh			;8c3d	f6 af		. .
	ld (l8c1ah),a		;8c3f	32 1a 8c	2 . .
	ld a,l			;8c42	7d		}
	call sub_8b41h		;8c43	cd 41 8b	. A .
	cp 003h			;8c46	fe 03		. .
	jp nz,l8e8dh		;8c48	c2 8d 8e	. . .
	push bc			;8c4b	c5		.
	ld hl,000adh		;8c4c	21 ad 00	! . .
	add hl,bc		;8c4f	09		.
	ld e,(hl)		;8c50	5e		^
	inc hl			;8c51	23		#
	ld d,(hl)		;8c52	56		V
	inc de			;8c53	13		.
	push hl			;8c54	e5		.
	ld a,(l856fh)		;8c55	3a 6f 85	: o .
	and a			;8c58	a7		.
	jp nz,l8c60h		;8c59	c2 60 8c	. ` .
	ld hl,(l8570h)		;8c5c	2a 70 85	* p .
	ex de,hl		;8c5f	eb		.
l8c60h:
	pop hl			;8c60	e1		.
	ld a,e			;8c61	7b		{
	or d			;8c62	b2		.
	jp z,08e93h		;8c63	ca 93 8e	. . .
	dec hl			;8c66	2b		+
	ld (hl),e		;8c67	73		s
	inc hl			;8c68	23		#
	ld (hl),d		;8c69	72		r
	dec de			;8c6a	1b		.
	pop bc			;8c6b	c1		.
	push bc			;8c6c	c5		.
	ld hl,000b0h		;8c6d	21 b0 00	! . .
	add hl,bc		;8c70	09		.
	xor a			;8c71	af		.
	ld (hl),a		;8c72	77		w
	inc hl			;8c73	23		#
	ld (hl),a		;8c74	77		w
	ld hl,000a9h		;8c75	21 a9 00	! . .
	add hl,bc		;8c78	09		.
	ld a,(hl)		;8c79	7e		~
	inc hl			;8c7a	23		#
	ld h,(hl)		;8c7b	66		f
	ld l,a			;8c7c	6f		o
	ex de,hl		;8c7d	eb		.
	push de			;8c7e	d5		.
	push hl			;8c7f	e5		.
	ld hl,00080h		;8c80	21 80 00	! . .
	call sub_8e7bh		;8c83	cd 7b 8e	. { .
	pop hl			;8c86	e1		.
	jp nz,l8c90h		;8c87	c2 90 8c	. . .
	ld de,00000h		;8c8a	11 00 00	. . .
	jp l8cceh		;8c8d	c3 ce 8c	. . .
l8c90h:
	ld b,d			;8c90	42		B
	ld c,e			;8c91	4b		K
	ld a,010h		;8c92	3e 10		> .
	ex de,hl		;8c94	eb		.
	ld hl,00000h		;8c95	21 00 00	! . .
	push hl			;8c98	e5		.
l8c99h:
	add hl,hl		;8c99	29		)
	ex (sp),hl		;8c9a	e3		.
	jp nc,l8ca3h		;8c9b	d2 a3 8c	. . .
	add hl,hl		;8c9e	29		)
	inc hl			;8c9f	23		#
	jp l8ca4h		;8ca0	c3 a4 8c	. . .
l8ca3h:
	add hl,hl		;8ca3	29		)
l8ca4h:
	ex (sp),hl		;8ca4	e3		.
	ex de,hl		;8ca5	eb		.
	add hl,hl		;8ca6	29		)
	ex de,hl		;8ca7	eb		.
	jp nc,l8cb2h		;8ca8	d2 b2 8c	. . .
	add hl,bc		;8cab	09		.
	ex (sp),hl		;8cac	e3		.
	jp nc,l8cb1h		;8cad	d2 b1 8c	. . .
	inc hl			;8cb0	23		#
l8cb1h:
	ex (sp),hl		;8cb1	e3		.
l8cb2h:
	dec a			;8cb2	3d		=
	jp nz,l8c99h		;8cb3	c2 99 8c	. . .
	ld a,l			;8cb6	7d		}
	and 07fh		;8cb7	e6 7f		. .
	ld e,a			;8cb9	5f		_
	ld d,000h		;8cba	16 00		. .
	pop bc			;8cbc	c1		.
	ld a,l			;8cbd	7d		}
	ld l,h			;8cbe	6c		l
	ld h,c			;8cbf	61		a
	add hl,hl		;8cc0	29		)
	jp c,08eaeh		;8cc1	da ae 8e	. . .
	rla			;8cc4	17		.
	jp nc,l8cc9h		;8cc5	d2 c9 8c	. . .
	inc hl			;8cc8	23		#
l8cc9h:
	ld a,b			;8cc9	78		x
	or a			;8cca	b7		.
	jp nz,08eaeh		;8ccb	c2 ae 8e	. . .
l8cceh:
	ld (l8c14h),hl		;8cce	22 14 8c	" . .
	pop hl			;8cd1	e1		.
	pop bc			;8cd2	c1		.
	push hl			;8cd3	e5		.
	ld hl,000b2h		;8cd4	21 b2 00	! . .
	add hl,bc		;8cd7	09		.
	ld (l8c16h),hl		;8cd8	22 16 8c	" . .
l8cdbh:
	ld hl,00029h		;8cdb	21 29 00	! ) .
	add hl,bc		;8cde	09		.
	add hl,de		;8cdf	19		.
	ld (l8c18h),hl		;8ce0	22 18 8c	" . .
	pop hl			;8ce3	e1		.
	push hl			;8ce4	e5		.
	ld hl,00080h		;8ce5	21 80 00	! . .
	ld a,l			;8ce8	7d		}
	sub e			;8ce9	93		.
	ld l,a			;8cea	6f		o
	ld a,h			;8ceb	7c		|
	sbc a,d			;8cec	9a		.
	ld h,a			;8ced	67		g
	pop de			;8cee	d1		.
	push de			;8cef	d5		.
	call sub_8e7bh		;8cf0	cd 7b 8e	. { .
	jp c,l8cf8h		;8cf3	da f8 8c	. . .
	ld h,d			;8cf6	62		b
	ld l,e			;8cf7	6b		k
l8cf8h:
	ld a,(l8c1ah)		;8cf8	3a 1a 8c	: . .
	or a			;8cfb	b7		.
	jp z,l8d3eh		;8cfc	ca 3e 8d	. > .
	ld de,00080h		;8cff	11 80 00	. . .
	call sub_8e7bh		;8d02	cd 7b 8e	. { .
	jp nc,l8d0dh		;8d05	d2 0d 8d	. . .
	push hl			;8d08	e5		.
	call sub_8d5ah+1	;8d09	cd 5b 8d	. [ .
	pop hl			;8d0c	e1		.
l8d0dh:
	push bc			;8d0d	c5		.
	ld b,h			;8d0e	44		D
	ld c,l			;8d0f	4d		M
	ld hl,(l8c18h)		;8d10	2a 18 8c	* . .
	ex de,hl		;8d13	eb		.
	ld hl,(l8c16h)		;8d14	2a 16 8c	* . .
	call sub_8d92h		;8d17	cd 92 8d	. . .
	ld (l8c16h),hl		;8d1a	22 16 8c	" . .
	ld d,b			;8d1d	50		P
	ld e,c			;8d1e	59		Y
	pop bc			;8d1f	c1		.
	call sub_8d5ah		;8d20	cd 5a 8d	. Z .
l8d23h:
	pop hl			;8d23	e1		.
	ld a,l			;8d24	7d		}
	sub e			;8d25	93		.
	ld l,a			;8d26	6f		o
	ld a,h			;8d27	7c		|
	sbc a,d			;8d28	9a		.
	ld h,a			;8d29	67		g
	or l			;8d2a	b5		.
	ld de,00000h		;8d2b	11 00 00	. . .
	push hl			;8d2e	e5		.
	ld hl,(l8c14h)		;8d2f	2a 14 8c	* . .
	inc hl			;8d32	23		#
	ld (l8c14h),hl		;8d33	22 14 8c	" . .
	jp nz,l8cdbh		;8d36	c2 db 8c	. . .
	pop hl			;8d39	e1		.
	pop hl			;8d3a	e1		.
	pop de			;8d3b	d1		.
	pop bc			;8d3c	c1		.
	ret			;8d3d	c9		.
l8d3eh:
	push hl			;8d3e	e5		.
	call sub_8d5ah+1	;8d3f	cd 5b 8d	. [ .
	pop hl			;8d42	e1		.
	push bc			;8d43	c5		.
	ld b,h			;8d44	44		D
	ld c,l			;8d45	4d		M
	ld hl,(l8c16h)		;8d46	2a 16 8c	* . .
	ex de,hl		;8d49	eb		.
	ld hl,(l8c18h)		;8d4a	2a 18 8c	* . .
	call sub_8d92h		;8d4d	cd 92 8d	. . .
	ex de,hl		;8d50	eb		.
	ld (l8c16h),hl		;8d51	22 16 8c	" . .
	ld d,b			;8d54	50		P
	ld e,c			;8d55	59		Y
	pop bc			;8d56	c1		.
	jp l8d23h		;8d57	c3 23 8d	. # .
sub_8d5ah:
	or 0afh			;8d5a	f6 af		. .
	ld (l8e7ah),a		;8d5c	32 7a 8e	2 z .
	push bc			;8d5f	c5		.
	push de			;8d60	d5		.
	push hl			;8d61	e5		.
	ld hl,(l8c14h)		;8d62	2a 14 8c	* . .
	ex de,hl		;8d65	eb		.
	ld hl,000abh		;8d66	21 ab 00	! . .
	add hl,bc		;8d69	09		.
	push hl			;8d6a	e5		.
	ld a,(hl)		;8d6b	7e		~
	inc hl			;8d6c	23		#
	ld h,(hl)		;8d6d	66		f
	ld l,a			;8d6e	6f		o
	inc de			;8d6f	13		.
	call sub_8e7bh		;8d70	cd 7b 8e	. { .
	pop hl			;8d73	e1		.
	ld (hl),e		;8d74	73		s
	inc hl			;8d75	23		#
	ld (hl),d		;8d76	72		r
	jp nz,l8d81h		;8d77	c2 81 8d	. . .
	ld a,(l8e7ah)		;8d7a	3a 7a 8e	: z .
	or a			;8d7d	b7		.
	jp z,l8d8eh		;8d7e	ca 8e 8d	. . .
l8d81h:
	ld hl,l8d8eh		;8d81	21 8e 8d	! . .
	push hl			;8d84	e5		.
	push bc			;8d85	c5		.
	push hl			;8d86	e5		.
	ld hl,00026h		;8d87	21 26 00	! & .
	add hl,bc		;8d8a	09		.
	jp l86b2h		;8d8b	c3 b2 86	. . .
l8d8eh:
	pop hl			;8d8e	e1		.
	pop de			;8d8f	d1		.
	pop bc			;8d90	c1		.
	ret			;8d91	c9		.
sub_8d92h:
	push bc			;8d92	c5		.
l8d93h:
	ld a,(hl)		;8d93	7e		~
	ld (de),a		;8d94	12		.
	inc hl			;8d95	23		#
	inc de			;8d96	13		.
	dec bc			;8d97	0b		.
	ld a,b			;8d98	78		x
	or c			;8d99	b1		.
	jp nz,l8d93h		;8d9a	c2 93 8d	. . .
	pop bc			;8d9d	c1		.
	ret			;8d9e	c9		.
l8d9fh:
	pop af			;8d9f	f1		.
	push de			;8da0	d5		.
	push bc			;8da1	c5		.
	push af			;8da2	f5		.
	ld b,h			;8da3	44		D
	ld c,l			;8da4	4d		M
	call sub_8dfbh		;8da5	cd fb 8d	. . .
	jp z,08ea2h		;8da8	ca a2 8e	. . .
	call sub_8df0h		;8dab	cd f0 8d	. . .
	ld hl,000b1h		;8dae	21 b1 00	! . .
	add hl,bc		;8db1	09		.
	add hl,de		;8db2	19		.
	pop af			;8db3	f1		.
	ld (hl),a		;8db4	77		w
	push af			;8db5	f5		.
	ld hl,00028h		;8db6	21 28 00	! ( .
	add hl,bc		;8db9	09		.
	ld d,(hl)		;8dba	56		V
	ld (hl),000h		;8dbb	36 00		6 .
	cp 00dh			;8dbd	fe 0d		. .
	jp z,l8dc8h		;8dbf	ca c8 8d	. . .
	add a,0e0h		;8dc2	c6 e0		. .
	ld a,d			;8dc4	7a		z
	adc a,000h		;8dc5	ce 00		. .
	ld (hl),a		;8dc7	77		w
l8dc8h:
	pop af			;8dc8	f1		.
	pop bc			;8dc9	c1		.
	pop de			;8dca	d1		.
	pop hl			;8dcb	e1		.
	ret			;8dcc	c9		.
l8dcdh:
	push de			;8dcd	d5		.
	call sub_8df9h		;8dce	cd f9 8d	. . .
	jp z,08ea2h		;8dd1	ca a2 8e	. . .
	call sub_8df0h		;8dd4	cd f0 8d	. . .
	ld hl,000b1h		;8dd7	21 b1 00	! . .
	add hl,bc		;8dda	09		.
	add hl,de		;8ddb	19		.
	ld a,(hl)		;8ddc	7e		~
	or a			;8ddd	b7		.
	pop de			;8dde	d1		.
	pop hl			;8ddf	e1		.
	pop bc			;8de0	c1		.
	ret			;8de1	c9		.
sub_8de2h:
	ld hl,000a9h		;8de2	21 a9 00	! . .
	jp l8debh		;8de5	c3 eb 8d	. . .
sub_8de8h:
	ld hl,000b0h		;8de8	21 b0 00	! . .
l8debh:
	add hl,bc		;8deb	09		.
	ld e,(hl)		;8dec	5e		^
	inc hl			;8ded	23		#
	ld d,(hl)		;8dee	56		V
	ret			;8def	c9		.
sub_8df0h:
	inc de			;8df0	13		.
	ld hl,000b0h		;8df1	21 b0 00	! . .
	add hl,bc		;8df4	09		.
	ld (hl),e		;8df5	73		s
	inc hl			;8df6	23		#
	ld (hl),d		;8df7	72		r
	ret			;8df8	c9		.
sub_8df9h:
	ld b,h			;8df9	44		D
	ld c,l			;8dfa	4d		M
sub_8dfbh:
	call sub_8de8h		;8dfb	cd e8 8d	. . .
	push de			;8dfe	d5		.
	call sub_8de2h		;8dff	cd e2 8d	. . .
	ex de,hl		;8e02	eb		.
	pop de			;8e03	d1		.
	call sub_8e7bh		;8e04	cd 7b 8e	. { .
	ret			;8e07	c9		.
l8e08h:
	push bc			;8e08	c5		.
	push de			;8e09	d5		.
	ld a,l			;8e0a	7d		}
	call sub_8b41h		;8e0b	cd 41 8b	. A .
	jp z,08e90h		;8e0e	ca 90 8e	. . .
	cp 001h			;8e11	fe 01		. .
	jp z,l8e1bh		;8e13	ca 1b 8e	. . .
	cp 003h			;8e16	fe 03		. .
	jp nz,l8e8dh		;8e18	c2 8d 8e	. . .
l8e1bh:
	ld h,b			;8e1b	60		`
	ld l,c			;8e1c	69		i
	ld (l680eh),hl		;8e1d	22 0e 68	" . h
	ld hl,l8e2bh		;8e20	21 2b 8e	! + .
	ld (l6817h),hl		;8e23	22 17 68	" . h
	pop de			;8e26	d1		.
	pop bc			;8e27	c1		.
	jp l8e58h		;8e28	c3 58 8e	. X .
l8e2bh:
	call sub_87d0h		;8e2b	cd d0 87	. . .
	ret nc			;8e2e	d0		.
	call sub_6c21h		;8e2f	cd 21 6c	. ! l
	ld hl,0003eh		;8e32	21 3e 00	! > .
	jp l68e3h		;8e35	c3 e3 68	. . h
; Runtime string input; the menu passes count 1 and console device $FF
input_string:
	call sub_6c17h		;8e38	cd 17 6c	. . l
	ld a,h			;8e3b	7c		|
	or d			;8e3c	b2		.
	jp nz,068d8h		;8e3d	c2 d8 68	. . h
	inc l			;8e40	2c		,
	jp z,l8e52h		;8e41	ca 52 8e	. R .
	dec l			;8e44	2d		-
	ld a,(l6814h)		;8e45	3a 14 68	: . h
	or a			;8e48	b7		.
	jp z,08e90h		;8e49	ca 90 8e	. . .
	push hl			;8e4c	e5		.
	ld hl,(l6814h+1)	;8e4d	2a 15 68	* . h
	ex (sp),hl		;8e50	e3		.
	ret			;8e51	c9		.
l8e52h:
	ld hl,l6730h		;8e52	21 30 67	! 0 g
	ld (l6817h),hl		;8e55	22 17 68	" . h
l8e58h:
	push bc			;8e58	c5		.
	push de			;8e59	d5		.
	ld a,e			;8e5a	7b		{
	call sub_785eh		;8e5b	cd 5e 78	. ^ x
	push hl			;8e5e	e5		.
	ld h,(hl)		;8e5f	66		f
	inc h			;8e60	24		$
l8e61h:
	dec h			;8e61	25		%
	jp z,l8e76h		;8e62	ca 76 8e	. v .
	push de			;8e65	d5		.
	push hl			;8e66	e5		.
	ld hl,l8e6fh		;8e67	21 6f 8e	! o .
	push hl			;8e6a	e5		.
	ld hl,(l6817h)		;8e6b	2a 17 68	* . h
	jp (hl)			;8e6e	e9		.
l8e6fh:
	pop hl			;8e6f	e1		.
	pop de			;8e70	d1		.
	ld (de),a		;8e71	12		.
	inc de			;8e72	13		.
	jp l8e61h		;8e73	c3 61 8e	. a .
l8e76h:
	pop hl			;8e76	e1		.
	pop de			;8e77	d1		.
	pop bc			;8e78	c1		.
	ret			;8e79	c9		.
l8e7ah:
	nop			;8e7a	00		.
sub_8e7bh:
	ld a,h			;8e7b	7c		|
	sub d			;8e7c	92		.
	ret nz			;8e7d	c0		.
	ld a,l			;8e7e	7d		}
	sub e			;8e7f	93		.
	ret			;8e80	c9		.
l8e81h:
	push hl			;8e81	e5		.
	ld hl,00000h		;8e82	21 00 00	! . .
	ld (l680eh),hl		;8e85	22 0e 68	" . h
	pop hl			;8e88	e1		.
	ret			;8e89	c9		.
l8e8ah:
	pop af			;8e8a	f1		.
	pop hl			;8e8b	e1		.
	ret			;8e8c	c9		.
l8e8dh:
	ld a,036h		;8e8d	3e 36		> 6
	ld bc,l343dh+1		;8e8f	01 3e 34	. > 4
	ld bc,03f3eh		;8e92	01 3e 3f	. > ?
	ld bc,l3d3dh+1		;8e95	01 3e 3d	. > =
	ld bc,l3a3eh		;8e98	01 3e 3a	. > :
	ld bc,0373eh		;8e9b	01 3e 37	. > 7
	ld bc,l353eh		;8e9e	01 3e 35	. > 5
	ld bc,l323eh		;8ea1	01 3e 32	. > 2
	ld bc,l333eh		;8ea4	01 3e 33	. > 3
	ld bc,l403eh		;8ea7	01 3e 40	. > @
	ld bc,0433eh		;8eaa	01 3e 43	. > C
	ld bc,0053eh		;8ead	01 3e 05	. > .
	call sub_6c21h		;8eb0	cd 21 6c	. ! l
	ld l,a			;8eb3	6f		o
	ld h,000h		;8eb4	26 00		& .
	jp l68e3h		;8eb6	c3 e3 68	. . h
sub_8eb9h:
	push hl			;8eb9	e5		.
	push de			;8eba	d5		.
	push bc			;8ebb	c5		.
	ld hl,00000h		;8ebc	21 00 00	! . .
	ld (l680eh),hl		;8ebf	22 0e 68	" . h
	ld hl,l6cd1h		;8ec2	21 d1 6c	! . l
	ld (06dd1h),hl		;8ec5	22 d1 6d	" . m
	call sub_8ecfh		;8ec8	cd cf 8e	. . .
	pop bc			;8ecb	c1		.
	pop de			;8ecc	d1		.
	pop hl			;8ecd	e1		.
	ret			;8ece	c9		.
sub_8ecfh:
	ld a,(l6c8ah)		;8ecf	3a 8a 6c	: . l
	and 002h		;8ed2	e6 02		. .
	jp nz,l8ee0h		;8ed4	c2 e0 8e	. . .
	call sub_7a46h		;8ed7	cd 46 7a	. F z
	ccf			;8eda	3f		?
	and b			;8edb	a0		.
	jp l8ee0h		;8edc	c3 e0 8e	. . .
l8edfh:
	ld (hl),b		;8edf	70		p
l8ee0h:
	call sub_9006h		;8ee0	cd 06 90	. . .
	jp l8f14h		;8ee3	c3 14 8f	. . .
l8ee6h:
	ld a,(l8fd7h)		;8ee6	3a d7 8f	: . .
	or a			;8ee9	b7		.
	ld a,05ch		;8eea	3e 5c		> \
	ld (l8fd7h),a		;8eec	32 d7 8f	2 . .
	jp nz,l8efah		;8eef	c2 fa 8e	. . .
	dec b			;8ef2	05		.
	jp z,l8edfh		;8ef3	ca df 8e	. . .
	call sub_8fdbh		;8ef6	cd db 8f	. . .
	inc b			;8ef9	04		.
l8efah:
	dec b			;8efa	05		.
	dec hl			;8efb	2b		+
	jp z,l8f0eh		;8efc	ca 0e 8f	. . .
	ld a,(hl)		;8eff	7e		~
	call sub_8fdbh		;8f00	cd db 8f	. . .
	jp l8f22h		;8f03	c3 22 8f	. " .
	dec b			;8f06	05		.
l8f07h:
	dec hl			;8f07	2b		+
	call sub_8fdbh		;8f08	cd db 8f	. . .
	jp nz,l8f22h		;8f0b	c2 22 8f	. " .
l8f0eh:
	call sub_8fdbh		;8f0e	cd db 8f	. . .
	call sub_8fd8h		;8f11	cd d8 8f	. . .
l8f14h:
	ld hl,l6cd1h		;8f14	21 d1 6c	! . l
	ld b,001h		;8f17	06 01		. .
	push af			;8f19	f5		.
	xor a			;8f1a	af		.
	ld (l8fd7h),a		;8f1b	32 d7 8f	2 . .
	pop af			;8f1e	f1		.
	jp l8f25h		;8f1f	c3 25 8f	. % .
l8f22h:
	call sub_9006h		;8f22	cd 06 90	. . .
l8f25h:
	ld c,a			;8f25	4f		O
	cp 07fh			;8f26	fe 7f		. .
	jp z,l8ee6h		;8f28	ca e6 8e	. . .
	ld a,(l8fd7h)		;8f2b	3a d7 8f	: . .
	or a			;8f2e	b7		.
	jp z,l8f3bh		;8f2f	ca 3b 8f	. ; .
	ld a,05ch		;8f32	3e 5c		> \
	call sub_8fdbh		;8f34	cd db 8f	. . .
	xor a			;8f37	af		.
	ld (l8fd7h),a		;8f38	32 d7 8f	2 . .
l8f3bh:
	ld a,c			;8f3b	79		y
	cp 007h			;8f3c	fe 07		. .
	jp z,l8fa5h		;8f3e	ca a5 8f	. . .
	cp 003h			;8f41	fe 03		. .
	call z,sub_8fdeh	;8f43	cc de 8f	. . .
	scf			;8f46	37		7
	ret z			;8f47	c8		.
	cp 00dh			;8f48	fe 0d		. .
	jp z,l8fcch		;8f4a	ca cc 8f	. . .
	cp 009h			;8f4d	fe 09		. .
	jp z,l8fa5h		;8f4f	ca a5 8f	. . .
	cp 00ah			;8f52	fe 0a		. .
	jp nz,l8f5fh		;8f54	c2 5f 8f	. _ .
	dec b			;8f57	05		.
	jp z,l8ee0h		;8f58	ca e0 8e	. . .
	inc b			;8f5b	04		.
	jp l8fa5h		;8f5c	c3 a5 8f	. . .
l8f5fh:
	cp 015h			;8f5f	fe 15		. .
	call z,sub_8fdeh	;8f61	cc de 8f	. . .
	jp z,l8ee0h		;8f64	ca e0 8e	. . .
	cp 008h			;8f67	fe 08		. .
	jp nz,l8f7dh		;8f69	c2 7d 8f	. } .
	dec b			;8f6c	05		.
	jp z,l8ee0h		;8f6d	ca e0 8e	. . .
	call sub_8fdbh		;8f70	cd db 8f	. . .
	ld a,020h		;8f73	3e 20		>  
	call sub_8fdbh		;8f75	cd db 8f	. . .
	ld a,008h		;8f78	3e 08		> .
	jp l8f07h		;8f7a	c3 07 8f	. . .
l8f7dh:
	cp 018h			;8f7d	fe 18		. .
	jp nz,l8f87h		;8f7f	c2 87 8f	. . .
	ld a,023h		;8f82	3e 23		> #
	jp l8f0eh		;8f84	c3 0e 8f	. . .
l8f87h:
	cp 012h			;8f87	fe 12		. .
	jp nz,l8fa0h		;8f89	c2 a0 8f	. . .
	push bc			;8f8c	c5		.
	push de			;8f8d	d5		.
	push hl			;8f8e	e5		.
	ld (hl),000h		;8f8f	36 00		6 .
	call sub_8fd8h		;8f91	cd d8 8f	. . .
	ld hl,l6cd1h		;8f94	21 d1 6c	! . l
	call sub_8ff0h		;8f97	cd f0 8f	. . .
	pop hl			;8f9a	e1		.
	pop de			;8f9b	d1		.
	pop bc			;8f9c	c1		.
	jp l8f22h		;8f9d	c3 22 8f	. " .
l8fa0h:
	cp 020h			;8fa0	fe 20		.  
	jp c,l8f22h		;8fa2	da 22 8f	. " .
l8fa5h:
	ld a,b			;8fa5	78		x
	inc a			;8fa6	3c		<
	ld a,007h		;8fa7	3e 07		> .
	jp z,l8fb0h		;8fa9	ca b0 8f	. . .
	ld a,c			;8fac	79		y
	ld (hl),c		;8fad	71		q
	inc hl			;8fae	23		#
	inc b			;8faf	04		.
l8fb0h:
	call sub_8fdbh		;8fb0	cd db 8f	. . .
	sub 00ah		;8fb3	d6 0a		. .
	jp nz,l8f22h		;8fb5	c2 22 8f	. " .
	ld a,00dh		;8fb8	3e 0d		> .
	call sub_8fdbh		;8fba	cd db 8f	. . .
l8fbdh:
	call sub_9006h		;8fbd	cd 06 90	. . .
	or a			;8fc0	b7		.
	jp z,l8fbdh		;8fc1	ca bd 8f	. . .
	cp 00dh			;8fc4	fe 0d		. .
	jp z,l8f22h		;8fc6	ca 22 8f	. " .
	jp l8f25h		;8fc9	c3 25 8f	. % .
l8fcch:
	ld a,(l6c8ah)		;8fcc	3a 8a 6c	: . l
	and 001h		;8fcf	e6 01		. .
	call z,sub_8fd8h	;8fd1	cc d8 8f	. . .
	xor a			;8fd4	af		.
	ld (hl),a		;8fd5	77		w
	ret			;8fd6	c9		.
l8fd7h:
	pop hl			;8fd7	e1		.
sub_8fd8h:
	jp sub_6c0dh		;8fd8	c3 0d 6c	. . l
sub_8fdbh:
	jp sub_90a2h		;8fdb	c3 a2 90	. . .
sub_8fdeh:
	push af			;8fde	f5		.
	ld a,05eh		;8fdf	3e 5e		> ^
	call sub_8fdbh		;8fe1	cd db 8f	. . .
	pop af			;8fe4	f1		.
	push af			;8fe5	f5		.
	or 040h			;8fe6	f6 40		. @
	call sub_8fdbh		;8fe8	cd db 8f	. . .
	call sub_8fd8h		;8feb	cd d8 8f	. . .
	pop af			;8fee	f1		.
	ret			;8fef	c9		.
sub_8ff0h:
	ld a,(hl)		;8ff0	7e		~
	and a			;8ff1	a7		.
	ret z			;8ff2	c8		.
	cp 00ah			;8ff3	fe 0a		. .
	jp nz,l8fffh		;8ff5	c2 ff 8f	. . .
	push af			;8ff8	f5		.
	ld a,00dh		;8ff9	3e 0d		> .
	call sub_8fdbh		;8ffb	cd db 8f	. . .
	pop af			;8ffe	f1		.
l8fffh:
	call sub_8fdbh		;8fff	cd db 8f	. . .
	inc hl			;9002	23		#
	jp sub_8ff0h		;9003	c3 f0 8f	. . .
sub_9006h:
	call l6730h		;9006	cd 30 67	. 0 g
	and 07fh		;9009	e6 7f		. .
	ret			;900b	c9		.
l900ch:
	jp 0e50bh		;900c	c3 0b e5	. . .
	ld hl,(l6836h)		;900f	2a 36 68	* 6 h
	cp 00dh			;9012	fe 0d		. .
	jp z,l9025h		;9014	ca 25 90	. % .
	push af			;9017	f5		.
	inc hl			;9018	23		#
	ld a,(hl)		;9019	7e		~
	dec hl			;901a	2b		+
	inc a			;901b	3c		<
	jp z,l9024h		;901c	ca 24 90	. $ .
	dec a			;901f	3d		=
	sub (hl)		;9020	96		.
	call c,l90b6h		;9021	dc b6 90	. . .
l9024h:
	pop af			;9024	f1		.
l9025h:
	push af			;9025	f5		.
	cp 00dh			;9026	fe 0d		. .
	call z,sub_908dh	;9028	cc 8d 90	. . .
	cp 008h			;902b	fe 08		. .
	call z,sub_9090h	;902d	cc 90 90	. . .
	cp 020h			;9030	fe 20		.  
	jp c,l9036h		;9032	da 36 90	. 6 .
	inc (hl)		;9035	34		4
l9036h:
	dec hl			;9036	2b		+
	ld a,(hl)		;9037	7e		~
	inc hl			;9038	23		#
	inc a			;9039	3c		<
	jp z,l9065h		;903a	ca 65 90	. e .
	dec a			;903d	3d		=
	jp nz,l9089h		;903e	c2 89 90	. . .
	pop af			;9041	f1		.
	cp 009h			;9042	fe 09		. .
	jp z,l9094h		;9044	ca 94 90	. . .
	pop hl			;9047	e1		.
	call sub_6739h		;9048	cd 39 67	. 9 g
	cp 00ah			;904b	fe 0a		. .
	ret nz			;904d	c0		.
	push af			;904e	f5		.
	push bc			;904f	c5		.
	ld a,(l683ch+2)		;9050	3a 3e 68	: > h
	ld b,a			;9053	47		G
	inc b			;9054	04		.
l9055h:
	dec b			;9055	05		.
	jp z,l9062h		;9056	ca 62 90	. b .
	xor a			;9059	af		.
	push bc			;905a	c5		.
	call sub_6739h		;905b	cd 39 67	. 9 g
	pop bc			;905e	c1		.
	jp l9055h		;905f	c3 55 90	. U .
l9062h:
	pop bc			;9062	c1		.
	pop af			;9063	f1		.
	ret			;9064	c9		.
l9065h:
	ld a,(06813h)		;9065	3a 13 68	: . h
	and a			;9068	a7		.
	jp nz,l907eh		;9069	c2 7e 90	. ~ .
	inc a			;906c	3c		<
	ld (06813h),a		;906d	32 13 68	2 . h
	push hl			;9070	e5		.
	ld hl,(l680eh+2)	;9071	2a 10 68	* . h
	ld (l900ch),hl		;9074	22 0c 90	" . .
	ld hl,l90c0h		;9077	21 c0 90	! . .
	ld (l680eh+2),hl	;907a	22 10 68	" . h
	pop hl			;907d	e1		.
l907eh:
	pop af			;907e	f1		.
	cp 009h			;907f	fe 09		. .
	jp z,l9094h		;9081	ca 94 90	. . .
	call sub_6740h		;9084	cd 40 67	. @ g
	pop hl			;9087	e1		.
	ret			;9088	c9		.
l9089h:
	ld hl,(0682ah)		;9089	2a 2a 68	* * h
	jp (hl)			;908c	e9		.
sub_908dh:
	ld (hl),001h		;908d	36 01		6 .
	ret			;908f	c9		.
sub_9090h:
	dec (hl)		;9090	35		5
	ret nz			;9091	c0		.
	inc (hl)		;9092	34		4
	ret			;9093	c9		.
l9094h:
	ld a,020h		;9094	3e 20		>  
	call l900ch+2		;9096	cd 0e 90	. . .
	ld a,(hl)		;9099	7e		~
	dec a			;909a	3d		=
	and 007h		;909b	e6 07		. .
	jp nz,l9094h		;909d	c2 94 90	. . .
	pop hl			;90a0	e1		.
	ret			;90a1	c9		.
sub_90a2h:
	push hl			;90a2	e5		.
	ld hl,(l6836h)		;90a3	2a 36 68	* 6 h
	push hl			;90a6	e5		.
	ld hl,l6839h		;90a7	21 39 68	! 9 h
	ld (l6836h),hl		;90aa	22 36 68	" 6 h
	call l900ch+2		;90ad	cd 0e 90	. . .
	pop hl			;90b0	e1		.
	ld (l6836h),hl		;90b1	22 36 68	" 6 h
	pop hl			;90b4	e1		.
	ret			;90b5	c9		.
l90b6h:
	ld a,00dh		;90b6	3e 0d		> .
	call l900ch+2		;90b8	cd 0e 90	. . .
	ld a,00ah		;90bb	3e 0a		> .
	jp l900ch+2		;90bd	c3 0e 90	. . .
l90c0h:
	ld a,00dh		;90c0	3e 0d		> .
	call sub_6740h		;90c2	cd 40 67	. @ g
	ld a,00ah		;90c5	3e 0a		> .
	call sub_6740h		;90c7	cd 40 67	. @ g
	ld hl,(l900ch)		;90ca	2a 0c 90	* . .
	jp (hl)			;90cd	e9		.
l90ceh:
	push bc			;90ce	c5		.
	ld bc,00003h		;90cf	01 03 00	. . .
	jp l90d9h		;90d2	c3 d9 90	. . .
	push bc			;90d5	c5		.
	ld bc,00007h		;90d6	01 07 00	. . .
l90d9h:
	add hl,bc		;90d9	09		.
	ex de,hl		;90da	eb		.
	add hl,bc		;90db	09		.
	ld b,a			;90dc	47		G
	call sub_90f2h		;90dd	cd f2 90	. . .
	and b			;90e0	a0		.
	pop bc			;90e1	c1		.
	pop hl			;90e2	e1		.
	jp z,l90edh		;90e3	ca ed 90	. . .
	ld a,(hl)		;90e6	7e		~
	inc hl			;90e7	23		#
	ld h,(hl)		;90e8	66		f
	ld l,a			;90e9	6f		o
	jp l90efh		;90ea	c3 ef 90	. . .
l90edh:
	inc hl			;90ed	23		#
	inc hl			;90ee	23		#
l90efh:
	pop de			;90ef	d1		.
	ex (sp),hl		;90f0	e3		.
	ret			;90f1	c9		.
sub_90f2h:
	call sub_90fch		;90f2	cd fc 90	. . .
	ld a,004h		;90f5	3e 04		> .
	ret c			;90f7	d8		.
	rrca			;90f8	0f		.
	ret z			;90f9	c8		.
	rrca			;90fa	0f		.
	ret			;90fb	c9		.
sub_90fch:
	ld a,(de)		;90fc	1a		.
	and a			;90fd	a7		.
	jp nz,l9109h		;90fe	c2 09 91	. . .
	ld a,(hl)		;9101	7e		~
	and a			;9102	a7		.
	ret z			;9103	c8		.
	dec hl			;9104	2b		+
	ld a,(hl)		;9105	7e		~
	rla			;9106	17		.
	ccf			;9107	3f		?
	ret			;9108	c9		.
l9109h:
	ld a,(hl)		;9109	7e		~
	and a			;910a	a7		.
	jp nz,l9114h		;910b	c2 14 91	. . .
	or 001h			;910e	f6 01		. .
	dec de			;9110	1b		.
	ld a,(de)		;9111	1a		.
	rla			;9112	17		.
	ret			;9113	c9		.
l9114h:
	dec de			;9114	1b		.
	dec hl			;9115	2b		+
	ld a,(de)		;9116	1a		.
	xor (hl)		;9117	ae		.
	ld a,(de)		;9118	1a		.
	inc de			;9119	13		.
	inc hl			;911a	23		#
	rla			;911b	17		.
	ret m			;911c	f8		.
	jp nc,l9121h		;911d	d2 21 91	. ! .
	ex de,hl		;9120	eb		.
l9121h:
	ld a,(de)		;9121	1a		.
	sub (hl)		;9122	96		.
	ret nz			;9123	c0		.
	dec de			;9124	1b		.
	dec hl			;9125	2b		+
	dec c			;9126	0d		.
	jp p,l9121h		;9127	f2 21 91	. ! .
	xor a			;912a	af		.
	ret			;912b	c9		.
sub_912ch:
	ex de,hl		;912c	eb		.
	ld h,000h		;912d	26 00		& .
	add hl,hl		;912f	29		)
	add hl,hl		;9130	29		)
	add hl,hl		;9131	29		)
	ld de,l0be4h		;9132	11 e4 0b	. . .
	add hl,de		;9135	19		.
	ret			;9136	c9		.
sub_9137h:
	ld e,(hl)		;9137	5e		^
	inc hl			;9138	23		#
	ld d,(hl)		;9139	56		V
	inc hl			;913a	23		#
	push hl			;913b	e5		.
	ld hl,l9285h		;913c	21 85 92	! . .
	call sub_9154h		;913f	cd 54 91	. T .
	pop hl			;9142	e1		.
l9143h:
	ret			;9143	c9		.
sub_9144h:
	ld e,(hl)		;9144	5e		^
	inc hl			;9145	23		#
	ld d,(hl)		;9146	56		V
	inc hl			;9147	23		#
	push hl			;9148	e5		.
	ld hl,09281h		;9149	21 81 92	! . .
	call sub_9151h		;914c	cd 51 91	. Q .
	pop hl			;914f	e1		.
	ret			;9150	c9		.
sub_9151h:
	call sub_9154h		;9151	cd 54 91	. T .
sub_9154h:
	ld a,(de)		;9154	1a		.
	ld (hl),a		;9155	77		w
	inc de			;9156	13		.
	inc hl			;9157	23		#
	ld a,(de)		;9158	1a		.
	ld (hl),a		;9159	77		w
	inc de			;915a	13		.
	inc hl			;915b	23		#
	ld a,(de)		;915c	1a		.
	ld (hl),a		;915d	77		w
	inc de			;915e	13		.
	inc hl			;915f	23		#
	ld a,(de)		;9160	1a		.
	ld (hl),a		;9161	77		w
	inc de			;9162	13		.
	inc hl			;9163	23		#
	ret			;9164	c9		.
l9165h:
	inc hl			;9165	23		#
sub_9166h:
	ld a,(hl)		;9166	7e		~
	cp 020h			;9167	fe 20		.  
	jp z,l9165h		;9169	ca 65 91	. e .
	cp 009h			;916c	fe 09		. .
	jp z,l9165h		;916e	ca 65 91	. e .
	ret			;9171	c9		.
sub_9172h:
	add a,l			;9172	85		.
	ld l,a			;9173	6f		o
	ret nc			;9174	d0		.
	inc h			;9175	24		$
	ret			;9176	c9		.
sub_9177h:
	and a			;9177	a7		.
	ret z			;9178	c8		.
	push bc			;9179	c5		.
	ld b,a			;917a	47		G
l917bh:
	ld a,(de)		;917b	1a		.
	ld (hl),a		;917c	77		w
	inc de			;917d	13		.
	inc hl			;917e	23		#
	dec b			;917f	05		.
l9180h:
	jp nz,l917bh		;9180	c2 7b 91	. { .
	pop bc			;9183	c1		.
	ret			;9184	c9		.
sub_9185h:
	ld a,e			;9185	7b		{
	xor l			;9186	ad		.
	ret nz			;9187	c0		.
	ld a,d			;9188	7a		z
	xor h			;9189	ac		.
	ret			;918a	c9		.
	xor a			;918b	af		.
	sub e			;918c	93		.
	ld e,a			;918d	5f		_
	push hl			;918e	e5		.
	ld a,e			;918f	7b		{
	sub b			;9190	90		.
	ld e,a			;9191	5f		_
	call p,sub_7d93h	;9192	f4 93 7d	. . }
	call m,sub_7da3h	;9195	fc a3 7d	. . }
	jp nz,l7d3fh		;9198	c2 3f 7d	. ? }
	pop hl			;919b	e1		.
	pop af			;919c	f1		.
	push hl			;919d	e5		.
	call z,07a86h		;919e	cc 86 7a	. . z
	pop hl			;91a1	e1		.
	call sub_7c19h+1	;91a2	cd 1a 7c	. . |
	ret pe			;91a5	e8		.
	push hl			;91a6	e5		.
	ld hl,l7b84h		;91a7	21 84 7b	! . {
	push hl			;91aa	e5		.
	call l7c81h		;91ab	cd 81 7c	. . |
	ret			;91ae	c9		.
	call 00050h		;91af	cd 50 00	. P .
	inc c			;91b2	0c		.
	jp nz,l7d3bh		;91b3	c2 3b 7d	. ; }
	call c,sub_7d84h	;91b6	dc 84 7d	. . }
l91b9h:
	jp l7ccfh		;91b9	c3 cf 7c	. . |
	call l7d2eh+1		;91bc	cd 2f 7d	. / }
	pop af			;91bf	f1		.
l91c0h:
	push hl			;91c0	e5		.
l91c1h:
	ld hl,l7b84h		;91c1	21 84 7b	! . {
	push hl			;91c4	e5		.
	ld hl,sub_7c19h		;91c5	21 19 7c	! . |
	push hl			;91c8	e5		.
	push af			;91c9	f5		.
	jp l7d3bh		;91ca	c3 3b 7d	. ; }
	or a			;91cd	b7		.
	call sub_7d84h		;91ce	cd 84 7d	. . }
	call l7d69h+1		;91d1	cd 6a 7d	. j }
	jp l7d3bh		;91d4	c3 3b 7d	. ; }
	push hl			;91d7	e5		.
	push de			;91d8	d5		.
	push bc			;91d9	c5		.
	push af			;91da	f5		.
	call z,sub_7ab4h	;91db	cc b4 7a	. . z
	pop af			;91de	f1		.
	call nz,sub_7acbh	;91df	c4 cb 7a	. . z
	pop bc			;91e2	c1		.
	pop de			;91e3	d1		.
	pop hl			;91e4	e1		.
	ret			;91e5	c9		.
	ret z			;91e6	c8		.
	push af			;91e7	f5		.
	call l7d5ch+1		;91e8	cd 5d 7d	. ] }
	push af			;91eb	f5		.
	call po,sub_7bb6h	;91ec	e4 b6 7b	. . {
	pop af			;91ef	f1		.
	call pe,sub_7b51h	;91f0	ec 51 7b	. Q {
	pop af			;91f3	f1		.
	dec a			;91f4	3d		=
	ret			;91f5	c9		.
	push de			;91f6	d5		.
	push hl			;91f7	e5		.
	push af			;91f8	f5		.
	call 07d96h		;91f9	cd 96 7d	. . }
	push af			;91fc	f5		.
	call po,sub_7b4bh	;91fd	e4 4b 7b	. K {
	pop af			;9200	f1		.
	call pe,sub_7b2eh	;9201	ec 2e 7b	. . {
	pop af			;9204	f1		.
	pop hl			;9205	e1		.
	pop de			;9206	d1		.
	inc a			;9207	3c		<
	ret			;9208	c9		.
	push de			;9209	d5		.
	ld a,b			;920a	78		x
	adc a,c			;920b	89		.
	ld b,a			;920c	47		G
	push bc			;920d	c5		.
	push hl			;920e	e5		.
	ld a,(hl)		;920f	7e		~
	sub 030h		;9210	d6 30		. 0
	push af			;9212	f5		.
	call 07da7h		;9213	cd a7 7d	. . }
	jp p,l7defh		;9216	f2 ef 7d	. . }
	ld hl,(l7c78h+1)	;9219	2a 79 7c	* y |
	ld de,00ccdh		;921c	11 cd 0c	. . .
	call sub_7b26h		;921f	cd 26 7b	. & {
	jp nc,l7debh		;9222	d2 eb 7d	. . }
	ld d,h			;9225	54		T
	ld e,l			;9226	5d		]
	add hl,hl		;9227	29		)
	add hl,hl		;9228	29		)
	add hl,de		;9229	19		.
	add hl,hl		;922a	29		)
	pop af			;922b	f1		.
	ld c,a			;922c	4f		O
	add hl,bc		;922d	09		.
	ld a,h			;922e	7c		|
	or a			;922f	b7		.
	jp m,l7de9h		;9230	fa e9 7d	. . }
	ld (07dc7h),hl		;9233	22 c7 7d	" . }
	pop hl			;9236	e1		.
	pop bc			;9237	c1		.
	pop de			;9238	d1		.
	jp l7ccfh		;9239	c3 cf 7c	. . |
	ld a,c			;923c	79		y
	push af			;923d	f5		.
	call l7ac2h		;923e	cd c2 7a	. . z
	scf			;9241	37		7
	jp nc,l7e0bh		;9242	d2 0b 7e	. . ~
	ld bc,09474h		;9245	01 74 94	. t .
	ld de,l2400h		;9248	11 00 24	. . $
	call sub_7b75h		;924b	cd 75 7b	. u {
	jp p,l7e08h		;924e	f2 08 7e	. . ~
	call sub_7bb6h		;9251	cd b6 7b	. . {
	pop af			;9254	f1		.
	call sub_7e1eh		;9255	cd 1e 7e	. . ~
	jp l7de3h		;9258	c3 e3 7d	. . }
	call sub_7ad2h		;925b	cd d2 7a	. . z
	call sub_7b51h		;925e	cd 51 7b	. Q {
l9261h:
	call sub_7bf5h		;9261	cd f5 7b	. . {
	pop af			;9264	f1		.
	call sub_7b86h		;9265	cd 86 7b	. . {
l9268h:
	call sub_7ad2h		;9268	cd d2 7a	. . z
	call sub_7b0bh		;926b	cd 0b 7b	. . {
l926eh:
	jp l7de3h		;926e	c3 e3 7d	. . }
	call sub_7b8fh		;9271	cd 8f 7b	. . {
	call sub_7b86h		;9274	cd 86 7b	. . {
	pop bc			;9277	c1		.
	pop de			;9278	d1		.
	jp l7b69h		;9279	c3 69 7b	. i {
	ld a,e			;927c	7b		{
	cp 00ah			;927d	fe 0a		. .
	jp nc,07e38h		;927f	d2 38 7e	. 8 ~
	rlca			;9282	07		.
l9283h:
	rlca			;9283	07		.
l9284h:
	add a,e			;9284	83		.
l9285h:
	rlca			;9285	07		.
	add a,(hl)		;9286	86		.
l9287h:
	sub 030h		;9287	d6 30		. 0
l9289h:
	ld e,a			;9289	5f		_
l928ah:
	jp m,l7f1eh		;928a	fa 1e 7f	. . .
	jp l7d2eh		;928d	c3 2e 7d	. . }
	or a			;9290	b7		.
l9291h:
	jp l3670h+2		;9291	c3 72 36	. r 6
	nop			;9294	00		.
	inc hl			;9295	23		#
sub_9296h:
	sub 001h		;9296	d6 01		. .
	jp nc,l9291h+2		;9298	d2 93 92	. . .
	ret			;929b	c9		.
	call sub_96c2h		;929c	cd c2 96	. . .
sub_929fh:
	ld de,l9291h+1		;929f	11 92 92	. . .
	ld a,(de)		;92a2	1a		.
	or a			;92a3	b7		.
	jp z,l92ceh		;92a4	ca ce 92	. . .
	call l9c35h		;92a7	cd 35 9c	. 5 .
	dec de			;92aa	1b		.
	ld a,(de)		;92ab	1a		.
	ld c,a			;92ac	4f		O
	jp z,l92d3h		;92ad	ca d3 92	. . .
	ld hl,l9c3dh		;92b0	21 3d 9c	! = .
	push hl			;92b3	e5		.
	ld hl,l9287h		;92b4	21 87 92	! . .
	xor (hl)		;92b7	ae		.
	ld a,c			;92b8	79		y
	ret m			;92b9	f8		.
	inc de			;92ba	13		.
	inc hl			;92bb	23		#
	ld b,008h		;92bc	06 08		. .
l92beh:
	ld a,(de)		;92be	1a		.
	sub (hl)		;92bf	96		.
	jp nz,l92cbh		;92c0	c2 cb 92	. . .
	dec de			;92c3	1b		.
	dec hl			;92c4	2b		+
	dec b			;92c5	05		.
	jp nz,l92beh		;92c6	c2 be 92	. . .
	pop bc			;92c9	c1		.
	ret			;92ca	c9		.
l92cbh:
	rra			;92cb	1f		.
	xor c			;92cc	a9		.
	ret			;92cd	c9		.
l92ceh:
	call l9c35h		;92ce	cd 35 9c	. 5 .
	ccf			;92d1	3f		?
	ret			;92d2	c9		.
l92d3h:
	jp l9c3dh		;92d3	c3 3d 9c	. = .
	push hl			;92d6	e5		.
	call sub_93b6h		;92d7	cd b6 93	. . .
	pop hl			;92da	e1		.
	call sub_9c05h		;92db	cd 05 9c	. . .
	call sub_968dh		;92de	cd 8d 96	. . .
	jp l92ech		;92e1	c3 ec 92	. . .
	push hl			;92e4	e5		.
	call sub_93b6h		;92e5	cd b6 93	. . .
	pop hl			;92e8	e1		.
	call sub_9684h		;92e9	cd 84 96	. . .
l92ech:
	call sub_9399h		;92ec	cd 99 93	. . .
	ld hl,l928ah+1		;92ef	21 8b 92	! . .
	call sub_96c2h		;92f2	cd c2 96	. . .
	jp z,l9358h		;92f5	ca 58 93	. X .
	ld a,(l9287h+1)		;92f8	3a 88 92	: . .
	or a			;92fb	b7		.
	jp z,l9c35h		;92fc	ca 35 9c	. 5 .
	ld a,(l9291h+1)		;92ff	3a 92 92	: . .
	cpl			;9302	2f		/
	inc a			;9303	3c		<
	ld b,a			;9304	47		G
	ld a,(l9291h)		;9305	3a 91 92	: . .
	ld c,a			;9308	4f		O
	call sub_99d5h		;9309	cd d5 99	. . .
	inc (hl)		;930c	34		4
	call sub_9639h		;930d	cd 39 96	. 9 .
	ld hl,l91c1h		;9310	21 c1 91	! . .
	ld (hl),c		;9313	71		q
	ld b,c			;9314	41		A
l9315h:
	ld de,l91b9h+1		;9315	11 ba 91	. . .
	ld hl,l928ah+1		;9318	21 8b 92	! . .
	call sub_9591h		;931b	cd 91 95	. . .
	ld a,(de)		;931e	1a		.
	sbc a,c			;931f	99		.
	ccf			;9320	3f		?
	jp c,0932fh		;9321	da 2f 93	. / .
	ld de,l91b9h+1		;9324	11 ba 91	. . .
	ld hl,l928ah+1		;9327	21 8b 92	! . .
	call sub_9584h		;932a	cd 84 95	. . .
	xor a			;932d	af		.
	jp c,l0412h		;932e	da 12 04	. . .
	ld a,(l9287h)		;9331	3a 87 92	: . .
	inc a			;9334	3c		<
	dec a			;9335	3d		=
	rra			;9336	1f		.
	jp m,l9556h		;9337	fa 56 95	. V .
	rla			;933a	17		.
	ld hl,09281h		;933b	21 81 92	! . .
	ld c,007h		;933e	0e 07		. .
	call sub_95f5h		;9340	cd f5 95	. . .
	ld hl,l91b9h+1		;9343	21 ba 91	! . .
	call sub_95f3h		;9346	cd f3 95	. . .
	ld a,b			;9349	78		x
	or a			;934a	b7		.
	jp nz,l9315h		;934b	c2 15 93	. . .
	ld hl,l9287h+1		;934e	21 88 92	! . .
	dec (hl)		;9351	35		5
	jp nz,l9315h		;9352	c2 15 93	. . .
	jp l9499h		;9355	c3 99 94	. . .
l9358h:
	call sub_7009h		;9358	cd 09 70	. . p
	adc a,c			;935b	89		.
sub_935ch:
	ld hl,l9287h		;935c	21 87 92	! . .
	ld c,(hl)		;935f	4e		N
	inc hl			;9360	23		#
	ld b,(hl)		;9361	46		F
	call sub_9ae4h		;9362	cd e4 9a	. . .
	xor (hl)		;9365	ae		.
	dec hl			;9366	2b		+
	ld (hl),0b8h		;9367	36 b8		6 .
	push af			;9369	f5		.
	call m,sub_938eh	;936a	fc 8e 93	. . .
	ld hl,l9287h		;936d	21 87 92	! . .
	ld a,0b8h		;9370	3e b8		> .
	sub b			;9372	90		.
	call sub_9650h		;9373	cd 50 96	. P .
	pop af			;9376	f1		.
	call m,sub_956ah	;9377	fc 6a 95	. j .
	xor a			;937a	af		.
	ld (09280h),a		;937b	32 80 92	2 . .
	ld a,(09281h)		;937e	3a 81 92	: . .
	push af			;9381	f5		.
	call sub_95b7h		;9382	cd b7 95	. . .
	call l9c35h		;9385	cd 35 9c	. 5 .
	pop bc			;9388	c1		.
	ld a,b			;9389	78		x
	ret p			;938a	f0		.
	cpl			;938b	2f		/
	inc a			;938c	3c		<
	ret			;938d	c9		.
sub_938eh:
	ld hl,09281h		;938e	21 81 92	! . .
l9391h:
	ld a,(hl)		;9391	7e		~
	dec (hl)		;9392	35		5
	or a			;9393	b7		.
	inc hl			;9394	23		#
	jp z,l9391h		;9395	ca 91 93	. . .
	ret			;9398	c9		.
sub_9399h:
	ld de,09281h		;9399	11 81 92	. . .
	ld hl,l928ah+1		;939c	21 8b 92	! . .
	ld b,008h		;939f	06 08		. .
l93a1h:
	ld c,(hl)		;93a1	4e		N
	ld a,(de)		;93a2	1a		.
	ld (hl),a		;93a3	77		w
	ld a,c			;93a4	79		y
	ld (de),a		;93a5	12		.
	inc de			;93a6	13		.
	inc hl			;93a7	23		#
	dec b			;93a8	05		.
	jp nz,l93a1h		;93a9	c2 a1 93	. . .
	jp l9c35h		;93ac	c3 35 9c	. 5 .
	ld de,09281h		;93af	11 81 92	. . .
	ex de,hl		;93b2	eb		.
	jp l96c5h		;93b3	c3 c5 96	. . .
sub_93b6h:
	ld hl,09281h		;93b6	21 81 92	! . .
	jp sub_96c2h		;93b9	c3 c2 96	. . .
sub_93bch:
	ld hl,l928ah+1		;93bc	21 8b 92	! . .
	jp l96d9h		;93bf	c3 d9 96	. . .
	call sub_9777h		;93c2	cd 77 97	. w .
	ld hl,sub_9777h		;93c5	21 77 97	! w .
	ex (sp),hl		;93c8	e3		.
	jp (hl)			;93c9	e9		.
	ld hl,l9291h+1		;93ca	21 92 92	! . .
	jp l93d3h		;93cd	c3 d3 93	. . .
sub_93d0h:
	ld hl,l9287h+1		;93d0	21 88 92	! . .
l93d3h:
	ld a,004h		;93d3	3e 04		> .
	pop de			;93d5	d1		.
l93d6h:
	ld b,(hl)		;93d6	46		F
	dec hl			;93d7	2b		+
	ld c,(hl)		;93d8	4e		N
	dec hl			;93d9	2b		+
	push bc			;93da	c5		.
	dec a			;93db	3d		=
	jp nz,l93d6h		;93dc	c2 d6 93	. . .
	ex de,hl		;93df	eb		.
	jp (hl)			;93e0	e9		.
sub_93e1h:
	ld hl,l928ah+1		;93e1	21 8b 92	! . .
	jp l93eah		;93e4	c3 ea 93	. . .
	ld hl,09281h		;93e7	21 81 92	! . .
l93eah:
	ld a,004h		;93ea	3e 04		> .
	pop de			;93ec	d1		.
l93edh:
	pop bc			;93ed	c1		.
	ld (hl),c		;93ee	71		q
	inc hl			;93ef	23		#
	ld (hl),b		;93f0	70		p
	inc hl			;93f1	23		#
	dec a			;93f2	3d		=
	jp nz,l93edh		;93f3	c2 ed 93	. . .
	ex de,hl		;93f6	eb		.
	jp (hl)			;93f7	e9		.
	ld hl,09281h		;93f8	21 81 92	! . .
	jp sub_940fh		;93fb	c3 0f 94	. . .
	pop hl			;93fe	e1		.
	ld (l91b9h),hl		;93ff	22 b9 91	" . .
	call sub_93e1h		;9402	cd e1 93	. . .
	call sub_93d0h		;9405	cd d0 93	. . .
	call sub_93bch		;9408	cd bc 93	. . .
	ld hl,(l91b9h)		;940b	2a b9 91	* . .
	jp (hl)			;940e	e9		.
sub_940fh:
	call sub_96c2h		;940f	cd c2 96	. . .
	jp z,l9bech		;9412	ca ec 9b	. . .
	ld a,(l9287h+1)		;9415	3a 88 92	: . .
	or a			;9418	b7		.
	jp z,l9bech		;9419	ca ec 9b	. . .
	ld hl,l9291h		;941c	21 91 92	! . .
	ld c,(hl)		;941f	4e		N
	inc hl			;9420	23		#
	ld b,(hl)		;9421	46		F
	call sub_99d5h		;9422	cd d5 99	. . .
	call sub_9639h		;9425	cd 39 96	. 9 .
	ld (hl),c		;9428	71		q
	inc de			;9429	13		.
	ld b,007h		;942a	06 07		. .
l942ch:
	ld a,(de)		;942c	1a		.
	inc de			;942d	13		.
	or a			;942e	b7		.
	push de			;942f	d5		.
	jp z,l944ch		;9430	ca 4c 94	. L .
	ld c,008h		;9433	0e 08		. .
l9435h:
	push bc			;9435	c5		.
	rra			;9436	1f		.
	ld b,a			;9437	47		G
	call c,sub_957eh	;9438	dc 7e 95	. ~ .
	call sub_967ch		;943b	cd 7c 96	. | .
	ld a,b			;943e	78		x
	pop bc			;943f	c1		.
	dec c			;9440	0d		.
	jp nz,l9435h		;9441	c2 35 94	. 5 .
l9444h:
	pop de			;9444	d1		.
	dec b			;9445	05		.
	jp nz,l942ch		;9446	c2 2c 94	. , .
	jp sub_95b7h		;9449	c3 b7 95	. . .
l944ch:
	ld hl,l9287h		;944c	21 87 92	! . .
	call sub_9658h		;944f	cd 58 96	. X .
	jp l9444h		;9452	c3 44 94	. D .
	or d			;9455	b2		.
	ld l,d			;9456	6a		j
	or 0f4h			;9457	f6 f4		. .
	and d			;9459	a2		.
	jr nc,l9465h		;945a	30 09		0 .
	ld a,a			;945c	7f		.
	ld d,h			;945d	54		T
	ld h,l			;945e	65		e
	jp nz,0d742h		;945f	c2 42 d7	. B .
	or e			;9462	b3		.
	ld e,l			;9463	5d		]
	add a,c			;9464	81		.
l9465h:
	jp nz,l2168h		;9465	c2 68 21	. h !
	and d			;9468	a2		.
	jp c,0490fh		;9469	da 0f 49	. . I
	add a,c			;946c	81		.
	ld l,09bh		;946d	2e 9b		. .
	ld l,e			;946f	6b		k
	pop bc			;9470	c1		.
	sub c			;9471	91		.
	ld a,(bc)		;9472	0a		.
	ld b,080h		;9473	06 80		. .
	nop			;9475	00		.
	nop			;9476	00		.
	nop			;9477	00		.
	nop			;9478	00		.
	nop			;9479	00		.
	nop			;947a	00		.
	nop			;947b	00		.
	add a,c			;947c	81		.
	push hl			;947d	e5		.
	call sub_93b6h		;947e	cd b6 93	. . .
	pop hl			;9481	e1		.
	call sub_9c05h		;9482	cd 05 9c	. . .
	call sub_968dh		;9485	cd 8d 96	. . .
	jp l9493h		;9488	c3 93 94	. . .
	push hl			;948b	e5		.
	call sub_93b6h		;948c	cd b6 93	. . .
	pop hl			;948f	e1		.
	call sub_9684h		;9490	cd 84 96	. . .
l9493h:
	ld hl,l928ah+1		;9493	21 8b 92	! . .
	jp sub_940fh		;9496	c3 0f 94	. . .
l9499h:
	call sub_7009h		;9499	cd 09 70	. . p
	rla			;949c	17		.
	ld hl,l9287h+1		;949d	21 88 92	! . .
	ld c,0ffh		;94a0	0e ff		. .
	ld (hl),c		;94a2	71		q
	inc hl			;94a3	23		#
	ld a,(hl)		;94a4	7e		~
	and 080h		;94a5	e6 80		. .
	or 07fh			;94a7	f6 7f		. .
	dec hl			;94a9	2b		+
	dec hl			;94aa	2b		+
	ld (hl),a		;94ab	77		w
	ld b,006h		;94ac	06 06		. .
l94aeh:
	dec hl			;94ae	2b		+
	ld (hl),c		;94af	71		q
	dec b			;94b0	05		.
	jp nz,l94aeh		;94b1	c2 ae 94	. . .
	jp l9c35h		;94b4	c3 35 9c	. 5 .
	nop			;94b7	00		.
	nop			;94b8	00		.
	nop			;94b9	00		.
	nop			;94ba	00		.
	nop			;94bb	00		.
	nop			;94bc	00		.
	nop			;94bd	00		.
	add a,b			;94be	80		.
	dec d			;94bf	15		.
	ld b,h			;94c0	44		D
	ld c,(hl)		;94c1	4e		N
	ld l,(hl)		;94c2	6e		n
	add a,e			;94c3	83		.
	ld sp,hl		;94c4	f9		.
	ld (0007eh),hl		;94c5	22 7e 00	" ~ .
	nop			;94c8	00		.
	nop			;94c9	00		.
	nop			;94ca	00		.
	nop			;94cb	00		.
	nop			;94cc	00		.
	nop			;94cd	00		.
	ld a,a			;94ce	7f		.
	nop			;94cf	00		.
	nop			;94d0	00		.
	nop			;94d1	00		.
	nop			;94d2	00		.
	nop			;94d3	00		.
	nop			;94d4	00		.
	add a,b			;94d5	80		.
	add a,d			;94d6	82		.
	ld h,b			;94d7	60		`
	sbc a,0f9h		;94d8	de f9		. .
	inc sp			;94da	33		3
	di			;94db	f3		.
	inc b			;94dc	04		.
	dec (hl)		;94dd	35		5
	add a,c			;94de	81		.
	ld a,d			;94df	7a		z
	rst 8			;94e0	cf		.
	pop de			;94e1	d1		.
	rst 30h			;94e2	f7		.
	rla			;94e3	17		.
	ld (hl),d		;94e4	72		r
	ld sp,l7b7fh		;94e5	31 7f 7b	1 . {
	rst 8			;94e8	cf		.
	pop de			;94e9	d1		.
	rst 30h			;94ea	f7		.
	rla			;94eb	17		.
	ld (hl),d		;94ec	72		r
	ld sp,0c080h		;94ed	31 80 c0	1 . .
	ld l,b			;94f0	68		h
	ld hl,0daa2h		;94f1	21 a2 da	! . .
	rrca			;94f4	0f		.
	ld c,c			;94f5	49		I
	add a,d			;94f6	82		.
l94f7h:
	call sub_96c2h		;94f7	cd c2 96	. . .
	jp z,l9c35h		;94fa	ca 35 9c	. 5 .
	ld a,c			;94fd	79		y
	xor 080h		;94fe	ee 80		. .
	ld c,a			;9500	4f		O
	ld (l9291h),a		;9501	32 91 92	2 . .
	jp l950dh		;9504	c3 0d 95	. . .
sub_9507h:
	call sub_96c2h		;9507	cd c2 96	. . .
	jp z,l9c35h		;950a	ca 35 9c	. 5 .
l950dh:
	ld a,(l9287h+1)		;950d	3a 88 92	: . .
	or a			;9510	b7		.
	jp z,sub_9399h		;9511	ca 99 93	. . .
	sub b			;9514	90		.
	jp nc,l951fh		;9515	d2 1f 95	. . .
	cpl			;9518	2f		/
	inc a			;9519	3c		<
	push af			;951a	f5		.
	call sub_9399h		;951b	cd 99 93	. . .
	pop af			;951e	f1		.
l951fh:
	cp 039h			;951f	fe 39		. 9
	jp nc,l9c35h		;9521	d2 35 9c	. 5 .
	push af			;9524	f5		.
	ld a,(l9291h)		;9525	3a 91 92	: . .
	ld c,a			;9528	4f		O
	call sub_9ae4h		;9529	cd e4 9a	. . .
	ld b,a			;952c	47		G
	xor a			;952d	af		.
	ld (l928ah),a		;952e	32 8a 92	2 . .
	pop af			;9531	f1		.
	ld hl,l9291h		;9532	21 91 92	! . .
	call sub_9650h		;9535	cd 50 96	. P .
	ld a,(l928ah)		;9538	3a 8a 92	: . .
	ld (09280h),a		;953b	32 80 92	2 . .
	ld a,b			;953e	78		x
	ld hl,l928ah+1		;953f	21 8b 92	! . .
	ld de,09281h		;9542	11 81 92	. . .
	ld c,007h		;9545	0e 07		. .
	or a			;9547	b7		.
	jp p,l959eh		;9548	f2 9e 95	. . .
	call sub_9587h		;954b	cd 87 95	. . .
	jp nc,l9556h		;954e	d2 56 95	. V .
	ex de,hl		;9551	eb		.
	inc (hl)		;9552	34		4
	call sub_967ch		;9553	cd 7c 96	. | .
l9556h:
	ld a,(09280h)		;9556	3a 80 92	: . .
	or a			;9559	b7		.
	call m,sub_956ah	;955a	fc 6a 95	. j .
	ld hl,l9289h		;955d	21 89 92	! . .
	ld a,(hl)		;9560	7e		~
	and 080h		;9561	e6 80		. .
	dec hl			;9563	2b		+
	dec hl			;9564	2b		+
	xor (hl)		;9565	ae		.
	ld (hl),a		;9566	77		w
	jp l9c35h		;9567	c3 35 9c	. 5 .
sub_956ah:
	ld hl,09281h		;956a	21 81 92	! . .
	ld b,007h		;956d	06 07		. .
l956fh:
	inc (hl)		;956f	34		4
	ret nz			;9570	c0		.
	inc hl			;9571	23		#
	dec b			;9572	05		.
	jp nz,l956fh		;9573	c2 6f 95	. o .
	inc (hl)		;9576	34		4
	jp z,l9499h		;9577	ca 99 94	. . .
	dec hl			;957a	2b		+
	ld (hl),080h		;957b	36 80		6 .
	ret			;957d	c9		.
sub_957eh:
	ld hl,l928ah+1		;957e	21 8b 92	! . .
	ld de,09281h		;9581	11 81 92	. . .
sub_9584h:
	ld c,007h		;9584	0e 07		. .
	xor a			;9586	af		.
sub_9587h:
	ld a,(de)		;9587	1a		.
	adc a,(hl)		;9588	8e		.
	ld (de),a		;9589	12		.
	inc de			;958a	13		.
	inc hl			;958b	23		#
	dec c			;958c	0d		.
	jp nz,sub_9587h		;958d	c2 87 95	. . .
	ret			;9590	c9		.
sub_9591h:
	xor a			;9591	af		.
	ld c,007h		;9592	0e 07		. .
l9594h:
	ld a,(de)		;9594	1a		.
	sbc a,(hl)		;9595	9e		.
	ld (de),a		;9596	12		.
	inc de			;9597	13		.
	inc hl			;9598	23		#
	dec c			;9599	0d		.
	jp nz,l9594h		;959a	c2 94 95	. . .
	ret			;959d	c9		.
l959eh:
	call l9594h		;959e	cd 94 95	. . .
	jp nc,sub_95b7h		;95a1	d2 b7 95	. . .
	inc de			;95a4	13		.
	ld a,(de)		;95a5	1a		.
	cpl			;95a6	2f		/
	ld (de),a		;95a7	12		.
	ld hl,09280h		;95a8	21 80 92	! . .
	ld b,008h		;95ab	06 08		. .
	xor a			;95ad	af		.
	ld c,a			;95ae	4f		O
l95afh:
	ld a,c			;95af	79		y
	sbc a,(hl)		;95b0	9e		.
	ld (hl),a		;95b1	77		w
	inc hl			;95b2	23		#
	dec b			;95b3	05		.
	jp nz,l95afh		;95b4	c2 af 95	. . .
sub_95b7h:
	xor a			;95b7	af		.
l95b8h:
	ld b,a			;95b8	47		G
	ld a,(l9287h)		;95b9	3a 87 92	: . .
	or a			;95bc	b7		.
	jp nz,l95e0h		;95bd	c2 e0 95	. . .
	ld hl,09280h		;95c0	21 80 92	! . .
	ld c,008h		;95c3	0e 08		. .
l95c5h:
	ld d,(hl)		;95c5	56		V
	ld (hl),a		;95c6	77		w
	ld a,d			;95c7	7a		z
	inc hl			;95c8	23		#
	dec c			;95c9	0d		.
	jp nz,l95c5h		;95ca	c2 c5 95	. . .
	ld a,b			;95cd	78		x
	sub 008h		;95ce	d6 08		. .
	cp 0c0h			;95d0	fe c0		. .
	jp nz,l95b8h		;95d2	c2 b8 95	. . .
	jp l9bech		;95d5	c3 ec 9b	. . .
l95d8h:
	dec b			;95d8	05		.
	ld hl,09280h		;95d9	21 80 92	! . .
	call sub_95f3h		;95dc	cd f3 95	. . .
	or a			;95df	b7		.
l95e0h:
	jp p,l95d8h		;95e0	f2 d8 95	. . .
	ld a,b			;95e3	78		x
	or a			;95e4	b7		.
	jp z,l9556h		;95e5	ca 56 95	. V .
	ld hl,l9287h+1		;95e8	21 88 92	! . .
	add a,(hl)		;95eb	86		.
	ld (hl),a		;95ec	77		w
	jp nc,l9bech		;95ed	d2 ec 9b	. . .
	jp l9556h		;95f0	c3 56 95	. V .
sub_95f3h:
	ld c,008h		;95f3	0e 08		. .
sub_95f5h:
	ld a,(hl)		;95f5	7e		~
	rla			;95f6	17		.
	ld (hl),a		;95f7	77		w
	inc hl			;95f8	23		#
	dec c			;95f9	0d		.
	jp nz,sub_95f5h		;95fa	c2 f5 95	. . .
	ret			;95fd	c9		.
	push hl			;95fe	e5		.
	call sub_93b6h		;95ff	cd b6 93	. . .
	pop hl			;9602	e1		.
	call sub_9c05h		;9603	cd 05 9c	. . .
	call sub_968dh		;9606	cd 8d 96	. . .
	jp l9614h		;9609	c3 14 96	. . .
	push hl			;960c	e5		.
	call sub_93b6h		;960d	cd b6 93	. . .
	pop hl			;9610	e1		.
	call sub_9684h		;9611	cd 84 96	. . .
l9614h:
	ld hl,l928ah+1		;9614	21 8b 92	! . .
	jp sub_9507h		;9617	c3 07 95	. . .
	push hl			;961a	e5		.
	call sub_93b6h		;961b	cd b6 93	. . .
	pop hl			;961e	e1		.
	call sub_9c05h		;961f	cd 05 9c	. . .
	call sub_968dh		;9622	cd 8d 96	. . .
	jp l9630h		;9625	c3 30 96	. 0 .
	push hl			;9628	e5		.
	call sub_93b6h		;9629	cd b6 93	. . .
	pop hl			;962c	e1		.
	call sub_9684h		;962d	cd 84 96	. . .
l9630h:
	call sub_9399h		;9630	cd 99 93	. . .
	ld hl,l928ah+1		;9633	21 8b 92	! . .
	jp l94f7h		;9636	c3 f7 94	. . .
sub_9639h:
	ld a,c			;9639	79		y
	ld (l9291h),a		;963a	32 91 92	2 . .
	ld hl,l9287h		;963d	21 87 92	! . .
	ld de,l91c0h		;9640	11 c0 91	. . .
	ld bc,l0700h		;9643	01 00 07	. . .
l9646h:
	ld a,(hl)		;9646	7e		~
	ld (de),a		;9647	12		.
	ld (hl),c		;9648	71		q
	dec de			;9649	1b		.
	dec hl			;964a	2b		+
	dec b			;964b	05		.
	jp nz,l9646h		;964c	c2 46 96	. F .
	ret			;964f	c9		.
sub_9650h:
	ld (hl),c		;9650	71		q
	push hl			;9651	e5		.
l9652h:
	sub 008h		;9652	d6 08		. .
	jp c,l9667h		;9654	da 67 96	. g .
	pop hl			;9657	e1		.
sub_9658h:
	push hl			;9658	e5		.
	ld de,00800h		;9659	11 00 08	. . .
l965ch:
	ld c,(hl)		;965c	4e		N
	ld (hl),e		;965d	73		s
	ld e,c			;965e	59		Y
	dec hl			;965f	2b		+
	dec d			;9660	15		.
	jp nz,l965ch		;9661	c2 5c 96	. \ .
	jp l9652h		;9664	c3 52 96	. R .
l9667h:
	add a,009h		;9667	c6 09		. .
	ld d,a			;9669	57		W
l966ah:
	xor a			;966a	af		.
	pop hl			;966b	e1		.
	dec d			;966c	15		.
	ret z			;966d	c8		.
l966eh:
	push hl			;966e	e5		.
	ld e,008h		;966f	1e 08		. .
l9671h:
	ld a,(hl)		;9671	7e		~
	rra			;9672	1f		.
	ld (hl),a		;9673	77		w
	dec hl			;9674	2b		+
	dec e			;9675	1d		.
	jp nz,l9671h		;9676	c2 71 96	. q .
	jp l966ah		;9679	c3 6a 96	. j .
sub_967ch:
	ld hl,l9287h		;967c	21 87 92	! . .
	ld d,001h		;967f	16 01		. .
	jp l966eh		;9681	c3 6e 96	. n .
sub_9684h:
	call sub_9a5dh		;9684	cd 5d 9a	. ] .
	jp sub_968dh		;9687	c3 8d 96	. . .
	call sub_9c05h		;968a	cd 05 9c	. . .
sub_968dh:
	ld b,004h		;968d	06 04		. .
	xor a			;968f	af		.
	ld hl,09281h		;9690	21 81 92	! . .
l9693h:
	ld (hl),a		;9693	77		w
	inc hl			;9694	23		#
	dec b			;9695	05		.
	jp nz,l9693h		;9696	c2 93 96	. . .
	jp l9c35h		;9699	c3 35 9c	. 5 .
	call l96a4h		;969c	cd a4 96	. . .
	ld a,l			;969f	7d		}
	ret			;96a0	c9		.
	call l96d9h		;96a1	cd d9 96	. . .
l96a4h:
	call sub_96adh		;96a4	cd ad 96	. . .
	jp l96dfh		;96a7	c3 df 96	. . .
	call l96d9h		;96aa	cd d9 96	. . .
sub_96adh:
	call sub_9ae4h		;96ad	cd e4 9a	. . .
	ld hl,l9284h		;96b0	21 84 92	! . .
	ld b,(hl)		;96b3	46		F
	inc hl			;96b4	23		#
	ld e,(hl)		;96b5	5e		^
	inc hl			;96b6	23		#
	ld d,(hl)		;96b7	56		V
	inc hl			;96b8	23		#
	ld c,(hl)		;96b9	4e		N
	jp l9bcch		;96ba	c3 cc 9b	. . .
	call l96dfh		;96bd	cd df 96	. . .
	ld a,l			;96c0	7d		}
	ret			;96c1	c9		.
sub_96c2h:
	ld de,l928ah+1		;96c2	11 8b 92	. . .
l96c5h:
	ld b,008h		;96c5	06 08		. .
l96c7h:
	ld a,(hl)		;96c7	7e		~
	ld (de),a		;96c8	12		.
	inc de			;96c9	13		.
	inc hl			;96ca	23		#
	dec b			;96cb	05		.
	jp nz,l96c7h		;96cc	c2 c7 96	. . .
	or a			;96cf	b7		.
	ld b,a			;96d0	47		G
	dec hl			;96d1	2b		+
	dec hl			;96d2	2b		+
	ld c,(hl)		;96d3	4e		N
	ret z			;96d4	c8		.
	ld a,c			;96d5	79		y
	jp l9c3dh		;96d6	c3 3d 9c	. = .
l96d9h:
	ld de,09281h		;96d9	11 81 92	. . .
	jp l96c5h		;96dc	c3 c5 96	. . .
l96dfh:
	ld hl,l9285h		;96df	21 85 92	! . .
	call sub_9c05h		;96e2	cd 05 9c	. . .
	ld a,090h		;96e5	3e 90		> .
	cp b			;96e7	b8		.
	jp z,l9716h		;96e8	ca 16 97	. . .
	jp nc,l96f4h		;96eb	d2 f4 96	. . .
l96eeh:
	call sub_7009h		;96ee	cd 09 70	. . p
	inc d			;96f1	14		.
	ld b,08fh		;96f2	06 8f		. .
l96f4h:
	call sub_9c2eh		;96f4	cd 2e 9c	. . .
	call sub_9724h		;96f7	cd 24 97	. $ .
	call sub_9c1ch		;96fa	cd 1c 9c	. . .
	ex de,hl		;96fd	eb		.
	ret z			;96fe	c8		.
	ex de,hl		;96ff	eb		.
	ld hl,l9289h		;9700	21 89 92	! . .
	ld (hl),080h		;9703	36 80		6 .
	call sub_9af1h		;9705	cd f1 9a	. . .
	ld h,a			;9708	67		g
	ld a,098h		;9709	3e 98		> .
	sub b			;970b	90		.
	call sub_9c79h		;970c	cd 79 9c	. y .
	ld a,h			;970f	7c		|
	rla			;9710	17		.
	call nc,sub_9ab2h	;9711	d4 b2 9a	. . .
	ex de,hl		;9714	eb		.
	ret			;9715	c9		.
l9716h:
	ld a,080h		;9716	3e 80		> .
	xor c			;9718	a9		.
	or d			;9719	b2		.
	or e			;971a	b3		.
	jp nz,l96eeh		;971b	c2 ee 96	. . .
	ld h,c			;971e	61		a
	ld l,e			;971f	6b		k
	ret			;9720	c9		.
	call sub_9c05h		;9721	cd 05 9c	. . .
sub_9724h:
	ret z			;9724	c8		.
	push af			;9725	f5		.
	call m,sub_9777h	;9726	fc 77 97	. w .
	call sub_99f5h		;9729	cd f5 99	. . .
	pop af			;972c	f1		.
	jp m,sub_9777h		;972d	fa 77 97	. w .
	jp l9c35h		;9730	c3 35 9c	. 5 .
	call sub_9c26h		;9733	cd 26 9c	. & .
	jp z,l9785h		;9736	ca 85 97	. . .
	push af			;9739	f5		.
	call l9c35h		;973a	cd 35 9c	. 5 .
	jp z,l978dh		;973d	ca 8d 97	. . .
	pop hl			;9740	e1		.
	call sub_9af9h		;9741	cd f9 9a	. . .
	jp p,l9755h		;9744	f2 55 97	. U .
	push bc			;9747	c5		.
	push de			;9748	d5		.
	call sub_99f8h		;9749	cd f8 99	. . .
	pop de			;974c	d1		.
	pop bc			;974d	c1		.
	push af			;974e	f5		.
	call sub_9a2fh		;974f	cd 2f 9a	. / .
	pop hl			;9752	e1		.
	ld a,h			;9753	7c		|
	rra			;9754	1f		.
l9755h:
	call l9c11h		;9755	cd 11 9c	. . .
	pop bc			;9758	c1		.
	pop de			;9759	d1		.
	jp nc,l9761h		;975a	d2 61 97	. a .
	ld hl,sub_9777h		;975d	21 77 97	! w .
	push hl			;9760	e5		.
l9761h:
	call z,sub_9772h	;9761	cc 72 97	. r .
	call sub_9af9h		;9764	cd f9 9a	. . .
	call sub_97f1h		;9767	cd f1 97	. . .
	pop bc			;976a	c1		.
	pop de			;976b	d1		.
	call sub_9983h		;976c	cd 83 99	. . .
	jp l9794h		;976f	c3 94 97	. . .
sub_9772h:
	ld a,07fh		;9772	3e 7f		> .
	and c			;9774	a1		.
	ld c,a			;9775	4f		O
	ret			;9776	c9		.
sub_9777h:
	ld hl,l9287h+1		;9777	21 88 92	! . .
	ld a,(hl)		;977a	7e		~
	or a			;977b	b7		.
	ret z			;977c	c8		.
	dec hl			;977d	2b		+
	ld a,080h		;977e	3e 80		> .
	xor (hl)		;9780	ae		.
	ld (hl),a		;9781	77		w
	jp l9c35h		;9782	c3 35 9c	. 5 .
l9785h:
	ld bc,l8100h		;9785	01 00 81	. . .
	ld d,c			;9788	51		Q
	ld e,c			;9789	59		Y
	jp l9c0eh		;978a	c3 0e 9c	. . .
l978dh:
	pop af			;978d	f1		.
	jp m,l9aa0h		;978e	fa a0 9a	. . .
	jp l9c35h		;9791	c3 35 9c	. 5 .
l9794h:
	ld a,(l9287h+1)		;9794	3a 88 92	: . .
	cp 088h			;9797	fe 88		. .
	jp nc,l97cbh		;9799	d2 cb 97	. . .
	cp 068h			;979c	fe 68		. h
	jp c,l97c3h		;979e	da c3 97	. . .
	call sub_9af9h		;97a1	cd f9 9a	. . .
	call sub_99f5h		;97a4	cd f5 99	. . .
	add a,081h		;97a7	c6 81		. .
	pop bc			;97a9	c1		.
	pop de			;97aa	d1		.
	jp z,l97cbh		;97ab	ca cb 97	. . .
	push af			;97ae	f5		.
	call sub_9ac0h		;97af	cd c0 9a	. . .
	call sub_98e4h		;97b2	cd e4 98	. . .
	ld hl,l97d4h		;97b5	21 d4 97	! . .
	call sub_9851h		;97b8	cd 51 98	. Q .
	pop bc			;97bb	c1		.
	ld de,00000h		;97bc	11 00 00	. . .
	ld c,d			;97bf	4a		J
	jp l9987h		;97c0	c3 87 99	. . .
l97c3h:
	ld bc,l8100h		;97c3	01 00 81	. . .
	ld d,c			;97c6	51		Q
	ld e,c			;97c7	59		Y
	jp l9c0eh		;97c8	c3 0e 9c	. . .
l97cbh:
	call l9c35h		;97cb	cd 35 9c	. 5 .
	jp m,l9bech		;97ce	fa ec 9b	. . .
	jp l9bbbh		;97d1	c3 bb 9b	. . .
l97d4h:
	rlca			;97d4	07		.
	ld a,h			;97d5	7c		|
	adc a,b			;97d6	88		.
	ld e,c			;97d7	59		Y
	ld (hl),h		;97d8	74		t
	ret po			;97d9	e0		.
	sub a			;97da	97		.
	ld h,077h		;97db	26 77		& w
	call nz,l1e1ch+1	;97dd	c4 1d 1e	. . .
	ld a,d			;97e0	7a		z
	ld e,(hl)		;97e1	5e		^
	ld d,b			;97e2	50		P
	ld h,e			;97e3	63		c
	ld a,h			;97e4	7c		|
	ld a,(de)		;97e5	1a		.
	cp 075h			;97e6	fe 75		. u
	ld a,(hl)		;97e8	7e		~
	jr l985dh		;97e9	18 72		. r
	ld sp,00080h		;97eb	31 80 00	1 . .
	nop			;97ee	00		.
	nop			;97ef	00		.
	add a,c			;97f0	81		.
sub_97f1h:
	call l9c0eh		;97f1	cd 0e 9c	. . .
	jp po,l97fbh		;97f4	e2 fb 97	. . .
	call sub_7009h		;97f7	cd 09 70	. . p
	adc a,d			;97fa	8a		.
l97fbh:
	ld a,080h		;97fb	3e 80		> .
	ld (l9287h+1),a		;97fd	32 88 92	2 . .
	xor b			;9800	a8		.
	push af			;9801	f5		.
	ld hl,l9818h		;9802	21 18 98	! . .
	call sub_9851h		;9805	cd 51 98	. Q .
	pop af			;9808	f1		.
	call sub_9af9h		;9809	cd f9 9a	. . .
	ld l,a			;980c	6f		o
	rla			;980d	17		.
	sbc a,a			;980e	9f		.
	ld h,a			;980f	67		g
	call sub_9a5dh		;9810	cd 5d 9a	. ] .
	pop bc			;9813	c1		.
	pop de			;9814	d1		.
	jp l9882h		;9815	c3 82 98	. . .
l9818h:
	add hl,bc		;9818	09		.
	ret c			;9819	d8		.
	xor 094h		;981a	ee 94		. .
	add a,d			;981c	82		.
	xor c			;981d	a9		.
	xor d			;981e	aa		.
	ld a,l			;981f	7d		}
	add a,h			;9820	84		.
	ld a,l			;9821	7d		}
	sbc a,c			;9822	99		.
	cp a			;9823	bf		.
	add a,(hl)		;9824	86		.
	ld a,e			;9825	7b		{
	push hl			;9826	e5		.
	jr z,$-119		;9827	28 87		( .
	adc a,d			;9829	8a		.
	ld (hl),c		;982a	71		q
	ret nz			;982b	c0		.
	add a,a			;982c	87		.
	ld l,(hl)		;982d	6e		n
	sub l			;982e	95		.
	inc d			;982f	14		.
	add a,a			;9830	87		.
	or d			;9831	b2		.
	ld e,0a0h		;9832	1e a0		. .
	add a,(hl)		;9834	86		.
	xor l			;9835	ad		.
	ld a,d			;9836	7a		z
	ld (bc),a		;9837	02		.
	add a,l			;9838	85		.
	add hl,bc		;9839	09		.
	sbc a,l			;983a	9d		.
	adc a,l			;983b	8d		.
	add a,e			;983c	83		.
	ex de,hl		;983d	eb		.
	call sub_9af9h		;983e	cd f9 9a	. . .
	push de			;9841	d5		.
	call sub_9c1ch		;9842	cd 1c 9c	. . .
	call sub_9983h		;9845	cd 83 99	. . .
	pop hl			;9848	e1		.
	call sub_9851h		;9849	cd 51 98	. Q .
	pop bc			;984c	c1		.
	pop de			;984d	d1		.
	jp sub_9983h		;984e	c3 83 99	. . .
sub_9851h:
	ex de,hl		;9851	eb		.
	call sub_9af9h		;9852	cd f9 9a	. . .
	ex de,hl		;9855	eb		.
	ld a,(hl)		;9856	7e		~
	push af			;9857	f5		.
	inc hl			;9858	23		#
	call sub_9c05h		;9859	cd 05 9c	. . .
l985ch:
	pop af			;985c	f1		.
l985dh:
	pop bc			;985d	c1		.
	pop de			;985e	d1		.
	dec a			;985f	3d		=
	ret z			;9860	c8		.
	push de			;9861	d5		.
	push bc			;9862	c5		.
	push af			;9863	f5		.
	push hl			;9864	e5		.
	ld a,b			;9865	78		x
	or c			;9866	b1		.
	call sub_9980h		;9867	cd 80 99	. . .
	pop hl			;986a	e1		.
	call sub_9c26h		;986b	cd 26 9c	. & .
	push hl			;986e	e5		.
	call l9882h		;986f	cd 82 98	. . .
	pop hl			;9872	e1		.
	jp l985ch		;9873	c3 5c 98	. \ .
	call sub_9a6fh		;9876	cd 6f 9a	. o .
	jp l987fh		;9879	c3 7f 98	. . .
sub_987ch:
	call sub_9c26h		;987c	cd 26 9c	. & .
l987fh:
	jp z,l9c35h		;987f	ca 35 9c	. 5 .
l9882h:
	ld a,(l9287h+1)		;9882	3a 88 92	: . .
	or a			;9885	b7		.
	jp z,l9c0eh		;9886	ca 0e 9c	. . .
	sub b			;9889	90		.
	jp nc,l9892h		;988a	d2 92 98	. . .
	cpl			;988d	2f		/
	inc a			;988e	3c		<
	call sub_9ac0h		;988f	cd c0 9a	. . .
l9892h:
	cp 019h			;9892	fe 19		. .
	jp nc,l9c35h		;9894	d2 35 9c	. 5 .
	push af			;9897	f5		.
	call sub_9ae4h		;9898	cd e4 9a	. . .
	ld h,a			;989b	67		g
	pop af			;989c	f1		.
	push hl			;989d	e5		.
	call sub_9c79h		;989e	cd 79 9c	. y .
	pop af			;98a1	f1		.
	or a			;98a2	b7		.
	ld hl,l9285h		;98a3	21 85 92	! . .
	jp p,l98c4h		;98a6	f2 c4 98	. . .
	ld a,(hl)		;98a9	7e		~
	add a,e			;98aa	83		.
	ld e,a			;98ab	5f		_
	inc hl			;98ac	23		#
	ld a,(hl)		;98ad	7e		~
	adc a,d			;98ae	8a		.
	ld d,a			;98af	57		W
	inc hl			;98b0	23		#
	ld a,(hl)		;98b1	7e		~
	adc a,c			;98b2	89		.
	ld c,a			;98b3	4f		O
	jp nc,l9bcch		;98b4	d2 cc 9b	. . .
	inc hl			;98b7	23		#
	inc (hl)		;98b8	34		4
	jp z,l9bbbh		;98b9	ca bb 9b	. . .
	ld l,001h		;98bc	2e 01		. .
	call sub_9c8fh		;98be	cd 8f 9c	. . .
	jp l9bcch		;98c1	c3 cc 9b	. . .
l98c4h:
	xor a			;98c4	af		.
	sub b			;98c5	90		.
	ld b,a			;98c6	47		G
	ld a,(hl)		;98c7	7e		~
	sbc a,e			;98c8	9b		.
	ld e,a			;98c9	5f		_
	inc hl			;98ca	23		#
	ld a,(hl)		;98cb	7e		~
	sbc a,d			;98cc	9a		.
	ld d,a			;98cd	57		W
	inc hl			;98ce	23		#
	ld a,(hl)		;98cf	7e		~
	sbc a,c			;98d0	99		.
	ld c,a			;98d1	4f		O
	call c,sub_9aach	;98d2	dc ac 9a	. . .
	jp sub_9b0eh		;98d5	c3 0e 9b	. . .
	call sub_9a6fh		;98d8	cd 6f 9a	. o .
	jp l98e1h		;98db	c3 e1 98	. . .
	call sub_9c26h		;98de	cd 26 9c	. & .
l98e1h:
	jp z,l9c35h		;98e1	ca 35 9c	. 5 .
sub_98e4h:
	ld a,080h		;98e4	3e 80		> .
	xor c			;98e6	a9		.
	ld c,a			;98e7	4f		O
	jp l9882h		;98e8	c3 82 98	. . .
	call sub_9a6fh		;98eb	cd 6f 9a	. o .
	jp l98f4h		;98ee	c3 f4 98	. . .
l98f1h:
	call sub_9c26h		;98f1	cd 26 9c	. & .
l98f4h:
	jp z,l9aa0h		;98f4	ca a0 9a	. . .
	call l9c35h		;98f7	cd 35 9c	. 5 .
	ret z			;98fa	c8		.
	xor a			;98fb	af		.
	sub b			;98fc	90		.
	ld b,a			;98fd	47		G
	call sub_99d5h		;98fe	cd d5 99	. . .
	ex de,hl		;9901	eb		.
	ld (l926eh),hl		;9902	22 6e 92	" n .
	ex de,hl		;9905	eb		.
	ld a,c			;9906	79		y
	ld (l926eh+2),a		;9907	32 70 92	2 p .
	ld b,(hl)		;990a	46		F
	xor a			;990b	af		.
	ld l,a			;990c	6f		o
	call sub_9ab7h		;990d	cd b7 9a	. . .
	call sub_9ac0h		;9910	cd c0 9a	. . .
	ld hl,00000h		;9913	21 00 00	! . .
	ld b,h			;9916	44		D
	push hl			;9917	e5		.
	ld hl,(l9285h)		;9918	2a 85 92	* . .
	ld a,(l9287h)		;991b	3a 87 92	: . .
	add hl,de		;991e	19		.
	adc a,c			;991f	89		.
	ld c,a			;9920	4f		O
	jp nc,l9931h		;9921	d2 31 99	. 1 .
	ld de,l9287h+1		;9924	11 88 92	. . .
	ex de,hl		;9927	eb		.
	inc (hl)		;9928	34		4
	ex de,hl		;9929	eb		.
	pop de			;992a	d1		.
	jp z,l9bbbh		;992b	ca bb 9b	. . .
	jp l9949h		;992e	c3 49 99	. I .
l9931h:
	pop de			;9931	d1		.
l9932h:
	call sub_9959h		;9932	cd 59 99	. Y .
	ld h,a			;9935	67		g
	ld l,000h		;9936	2e 00		. .
	push hl			;9938	e5		.
	ld hl,(l926eh)		;9939	2a 6e 92	* n .
	ld a,(l926eh+2)		;993c	3a 70 92	: p .
l993fh:
	add hl,de		;993f	19		.
	adc a,c			;9940	89		.
	ld c,a			;9941	4f		O
	pop de			;9942	d1		.
	ld a,d			;9943	7a		z
	adc a,e			;9944	8b		.
	pop de			;9945	d1		.
	jp nc,l9932h		;9946	d2 32 99	. 2 .
l9949h:
	call sub_9959h		;9949	cd 59 99	. Y .
	ld h,a			;994c	67		g
	ld l,0ffh		;994d	2e ff		. .
	push hl			;994f	e5		.
	ld hl,(l9285h)		;9950	2a 85 92	* . .
	ld a,(l9287h)		;9953	3a 87 92	: . .
	jp l993fh		;9956	c3 3f 99	. ? .
sub_9959h:
	ld a,b			;9959	78		x
	inc a			;995a	3c		<
	dec a			;995b	3d		=
	jp m,l9970h		;995c	fa 70 99	. p .
	ld a,e			;995f	7b		{
	rla			;9960	17		.
	ld e,a			;9961	5f		_
	ld a,d			;9962	7a		z
	rla			;9963	17		.
	ld d,a			;9964	57		W
	ld a,b			;9965	78		x
	rla			;9966	17		.
	ld b,a			;9967	47		G
	add hl,hl		;9968	29		)
	ld a,c			;9969	79		y
	rla			;996a	17		.
	ld c,a			;996b	4f		O
	sbc a,a			;996c	9f		.
	ex de,hl		;996d	eb		.
	ex (sp),hl		;996e	e3		.
	jp (hl)			;996f	e9		.
l9970h:
	rra			;9970	1f		.
	ld c,b			;9971	48		H
	ld b,a			;9972	47		G
	pop hl			;9973	e1		.
	jp l9bcch		;9974	c3 cc 9b	. . .
	call sub_9a6fh		;9977	cd 6f 9a	. o .
	jp sub_9980h		;997a	c3 80 99	. . .
sub_997dh:
	call sub_9c26h		;997d	cd 26 9c	. & .
sub_9980h:
	jp z,l9c11h		;9980	ca 11 9c	. . .
sub_9983h:
	call l9c35h		;9983	cd 35 9c	. 5 .
	ret z			;9986	c8		.
l9987h:
	call sub_99d5h		;9987	cd d5 99	. . .
	ld a,c			;998a	79		y
	ld c,000h		;998b	0e 00		. .
	push bc			;998d	c5		.
	ld c,008h		;998e	0e 08		. .
	dec hl			;9990	2b		+
	ld b,(hl)		;9991	46		F
	push bc			;9992	c5		.
	dec hl			;9993	2b		+
	ld b,(hl)		;9994	46		F
	push bc			;9995	c5		.
	dec hl			;9996	2b		+
	ld b,(hl)		;9997	46		F
	push bc			;9998	c5		.
	ld (hl),a		;9999	77		w
	ld bc,00000h		;999a	01 00 00	. . .
	ld h,b			;999d	60		`
	ld l,b			;999e	68		h
l999fh:
	ex (sp),hl		;999f	e3		.
l99a0h:
	ld a,h			;99a0	7c		|
	or a			;99a1	b7		.
	jp z,l99cdh		;99a2	ca cd 99	. . .
l99a5h:
	rra			;99a5	1f		.
	ld h,a			;99a6	67		g
	ld a,c			;99a7	79		y
	ex (sp),hl		;99a8	e3		.
	jp nc,l99b1h		;99a9	d2 b1 99	. . .
	add hl,de		;99ac	19		.
	ld a,(l9285h)		;99ad	3a 85 92	: . .
	adc a,c			;99b0	89		.
l99b1h:
	rra			;99b1	1f		.
	ld c,a			;99b2	4f		O
	ld a,h			;99b3	7c		|
	rra			;99b4	1f		.
	ld h,a			;99b5	67		g
	ld a,l			;99b6	7d		}
	rra			;99b7	1f		.
	ld l,a			;99b8	6f		o
	ld a,b			;99b9	78		x
	rra			;99ba	1f		.
	ld b,a			;99bb	47		G
	ex (sp),hl		;99bc	e3		.
	dec l			;99bd	2d		-
	ld a,h			;99be	7c		|
	jp nz,l99a5h		;99bf	c2 a5 99	. . .
	pop hl			;99c2	e1		.
	ex (sp),hl		;99c3	e3		.
	ld a,l			;99c4	7d		}
	or a			;99c5	b7		.
	jp nz,l99a0h		;99c6	c2 a0 99	. . .
	pop de			;99c9	d1		.
	jp sub_9b0eh		;99ca	c3 0e 9b	. . .
l99cdh:
	pop hl			;99cd	e1		.
	ld b,l			;99ce	45		E
	ld l,h			;99cf	6c		l
	ld h,c			;99d0	61		a
	ld c,a			;99d1	4f		O
	jp l999fh		;99d2	c3 9f 99	. . .
sub_99d5h:
	ld hl,l9287h+1		;99d5	21 88 92	! . .
	ld a,(hl)		;99d8	7e		~
	add a,b			;99d9	80		.
	ld b,a			;99da	47		G
	rra			;99db	1f		.
	xor b			;99dc	a8		.
	ld a,b			;99dd	78		x
	jp p,l99edh		;99de	f2 ed 99	. . .
	add a,080h		;99e1	c6 80		. .
	jp z,l9bebh		;99e3	ca eb 9b	. . .
	ld (hl),a		;99e6	77		w
	call sub_9ae4h		;99e7	cd e4 9a	. . .
	ld (hl),a		;99ea	77		w
	dec hl			;99eb	2b		+
	ret			;99ec	c9		.
l99edh:
	or a			;99ed	b7		.
	pop hl			;99ee	e1		.
	jp m,l9bbbh		;99ef	fa bb 9b	. . .
	jp l9bech		;99f2	c3 ec 9b	. . .
sub_99f5h:
	call sub_9c1ch		;99f5	cd 1c 9c	. . .
sub_99f8h:
	ld a,b			;99f8	78		x
	cp 098h			;99f9	fe 98		. .
	ld a,e			;99fb	7b		{
	jp nc,l9c11h		;99fc	d2 11 9c	. . .
	ld hl,l9289h		;99ff	21 89 92	! . .
	ld (hl),080h		;9a02	36 80		6 .
	call sub_9af1h		;9a04	cd f1 9a	. . .
	ld (hl),a		;9a07	77		w
	ld h,a			;9a08	67		g
	jp m,l9a13h		;9a09	fa 13 9a	. . .
	ld a,d			;9a0c	7a		z
	or e			;9a0d	b3		.
	jp nz,l9a12h		;9a0e	c2 12 9a	. . .
	dec c			;9a11	0d		.
l9a12h:
	dec de			;9a12	1b		.
l9a13h:
	ld a,098h		;9a13	3e 98		> .
	sub b			;9a15	90		.
	call sub_9c79h		;9a16	cd 79 9c	. y .
	ld a,h			;9a19	7c		|
	rla			;9a1a	17		.
	call nc,sub_9bdeh	;9a1b	d4 de 9b	. . .
	ld b,000h		;9a1e	06 00		. .
	ld a,e			;9a20	7b		{
	push af			;9a21	f5		.
	ld a,098h		;9a22	3e 98		> .
	ld (l9287h+1),a		;9a24	32 88 92	2 . .
	call sub_9b0eh		;9a27	cd 0e 9b	. . .
	pop af			;9a2a	f1		.
	ret c			;9a2b	d8		.
	cpl			;9a2c	2f		/
	inc a			;9a2d	3c		<
	ret			;9a2e	c9		.
sub_9a2fh:
	ld a,b			;9a2f	78		x
	or c			;9a30	b1		.
	jp z,l9c35h		;9a31	ca 35 9c	. 5 .
	ld hl,l9c3dh		;9a34	21 3d 9c	! = .
	push hl			;9a37	e5		.
	call l9c35h		;9a38	cd 35 9c	. 5 .
	ld a,c			;9a3b	79		y
	cpl			;9a3c	2f		/
	ret z			;9a3d	c8		.
	ld hl,l9287h		;9a3e	21 87 92	! . .
	xor (hl)		;9a41	ae		.
	ld a,(hl)		;9a42	7e		~
	ret p			;9a43	f0		.
	call sub_9a4ah		;9a44	cd 4a 9a	. J .
	rra			;9a47	1f		.
	xor c			;9a48	a9		.
	ret			;9a49	c9		.
sub_9a4ah:
	inc hl			;9a4a	23		#
	ld a,(hl)		;9a4b	7e		~
	cp b			;9a4c	b8		.
	ret nz			;9a4d	c0		.
	dec hl			;9a4e	2b		+
	ld a,(hl)		;9a4f	7e		~
	cp c			;9a50	b9		.
	ret nz			;9a51	c0		.
	dec hl			;9a52	2b		+
	ld a,(hl)		;9a53	7e		~
	cp d			;9a54	ba		.
	ret nz			;9a55	c0		.
	dec hl			;9a56	2b		+
	ld a,(hl)		;9a57	7e		~
	sub e			;9a58	93		.
	ret nz			;9a59	c0		.
	pop hl			;9a5a	e1		.
	pop hl			;9a5b	e1		.
	ret			;9a5c	c9		.
sub_9a5dh:
	ld c,h			;9a5d	4c		L
	ld d,l			;9a5e	55		U
	ld b,000h		;9a5f	06 00		. .
	ld e,b			;9a61	58		X
	add hl,hl		;9a62	29		)
	ld hl,08090h		;9a63	21 90 80	! . .
	ld (l9287h+1),hl	;9a66	22 88 92	" . .
	call c,sub_9aach	;9a69	dc ac 9a	. . .
	jp sub_9b0eh		;9a6c	c3 0e 9b	. . .
sub_9a6fh:
	ex de,hl		;9a6f	eb		.
	call sub_9af9h		;9a70	cd f9 9a	. . .
	ex de,hl		;9a73	eb		.
	call sub_9a5dh		;9a74	cd 5d 9a	. ] .
	pop bc			;9a77	c1		.
	pop de			;9a78	d1		.
	call sub_9ac0h		;9a79	cd c0 9a	. . .
	ret			;9a7c	c9		.
sub_9a7dh:
	ex de,hl		;9a7d	eb		.
	ld a,d			;9a7e	7a		z
	or e			;9a7f	b3		.
	jp z,l9aa0h		;9a80	ca a0 9a	. . .
	ld a,d			;9a83	7a		z
	or a			;9a84	b7		.
	ld b,d			;9a85	42		B
	call m,sub_9aa4h	;9a86	fc a4 9a	. . .
	ld a,h			;9a89	7c		|
	xor b			;9a8a	a8		.
	ld b,a			;9a8b	47		G
	ld a,h			;9a8c	7c		|
	or l			;9a8d	b5		.
	ret z			;9a8e	c8		.
	ld a,h			;9a8f	7c		|
	or a			;9a90	b7		.
	ex de,hl		;9a91	eb		.
	call m,sub_9aa4h	;9a92	fc a4 9a	. . .
	push bc			;9a95	c5		.
	call sub_9c45h		;9a96	cd 45 9c	. E .
	pop af			;9a99	f1		.
	or a			;9a9a	b7		.
	call m,sub_9aa4h	;9a9b	fc a4 9a	. . .
	ex de,hl		;9a9e	eb		.
	ret			;9a9f	c9		.
l9aa0h:
	call sub_7009h		;9aa0	cd 09 70	. . p
	adc a,c			;9aa3	89		.
sub_9aa4h:
	xor a			;9aa4	af		.
	ld c,a			;9aa5	4f		O
	sub e			;9aa6	93		.
	ld e,a			;9aa7	5f		_
	ld a,c			;9aa8	79		y
	sbc a,d			;9aa9	9a		.
	ld d,a			;9aaa	57		W
	ret			;9aab	c9		.
sub_9aach:
	ld hl,l9289h		;9aac	21 89 92	! . .
	ld a,(hl)		;9aaf	7e		~
	cpl			;9ab0	2f		/
	ld (hl),a		;9ab1	77		w
sub_9ab2h:
	xor a			;9ab2	af		.
	ld l,a			;9ab3	6f		o
	sub b			;9ab4	90		.
	ld b,a			;9ab5	47		G
	ld a,l			;9ab6	7d		}
sub_9ab7h:
	sbc a,e			;9ab7	9b		.
	ld e,a			;9ab8	5f		_
	ld a,l			;9ab9	7d		}
	sbc a,d			;9aba	9a		.
	ld d,a			;9abb	57		W
	ld a,l			;9abc	7d		}
	sbc a,c			;9abd	99		.
	ld c,a			;9abe	4f		O
	ret			;9abf	c9		.
sub_9ac0h:
	call sub_9af9h		;9ac0	cd f9 9a	. . .
	call l9c11h		;9ac3	cd 11 9c	. . .
	pop bc			;9ac6	c1		.
	pop de			;9ac7	d1		.
	ret			;9ac8	c9		.
sub_9ac9h:
	ld a,h			;9ac9	7c		|
	or l			;9aca	b5		.
	ret z			;9acb	c8		.
	ex de,hl		;9acc	eb		.
	ld a,h			;9acd	7c		|
	or l			;9ace	b5		.
	ret z			;9acf	c8		.
	ld b,h			;9ad0	44		D
	ld c,l			;9ad1	4d		M
	ld hl,00000h		;9ad2	21 00 00	! . .
	ld a,010h		;9ad5	3e 10		> .
l9ad7h:
	add hl,hl		;9ad7	29		)
	ex de,hl		;9ad8	eb		.
	add hl,hl		;9ad9	29		)
	ex de,hl		;9ada	eb		.
	jp nc,l9adfh		;9adb	d2 df 9a	. . .
	add hl,bc		;9ade	09		.
l9adfh:
	dec a			;9adf	3d		=
	jp nz,l9ad7h		;9ae0	c2 d7 9a	. . .
	ret			;9ae3	c9		.
sub_9ae4h:
	ld hl,l9287h		;9ae4	21 87 92	! . .
	ld a,(hl)		;9ae7	7e		~
	rlca			;9ae8	07		.
	scf			;9ae9	37		7
	rra			;9aea	1f		.
	ld (hl),a		;9aeb	77		w
	ccf			;9aec	3f		?
	rra			;9aed	1f		.
	inc hl			;9aee	23		#
	inc hl			;9aef	23		#
	ld (hl),a		;9af0	77		w
sub_9af1h:
	ld a,c			;9af1	79		y
	rlca			;9af2	07		.
	scf			;9af3	37		7
	rra			;9af4	1f		.
	ld c,a			;9af5	4f		O
	rra			;9af6	1f		.
	xor (hl)		;9af7	ae		.
	ret			;9af8	c9		.
sub_9af9h:
	ld hl,(l9285h)		;9af9	2a 85 92	* . .
	ex (sp),hl		;9afc	e3		.
	push hl			;9afd	e5		.
	ld hl,(l9287h)		;9afe	2a 87 92	* . .
	ex (sp),hl		;9b01	e3		.
	jp (hl)			;9b02	e9		.
	pop hl			;9b03	e1		.
	ex (sp),hl		;9b04	e3		.
	ld (l9287h),hl		;9b05	22 87 92	" . .
	pop hl			;9b08	e1		.
	ex (sp),hl		;9b09	e3		.
	ld (l9285h),hl		;9b0a	22 85 92	" . .
	ret			;9b0d	c9		.
sub_9b0eh:
	ld h,c			;9b0e	61		a
	ld l,d			;9b0f	6a		j
	ld d,e			;9b10	53		S
	ld e,b			;9b11	58		X
	call sub_9b55h		;9b12	cd 55 9b	. U .
	inc d			;9b15	14		.
	dec d			;9b16	15		.
	jp z,l9bech		;9b17	ca ec 9b	. . .
	ld c,d			;9b1a	4a		J
	ld d,e			;9b1b	53		S
	ld e,h			;9b1c	5c		\
	ld b,l			;9b1d	45		E
	ld hl,l9287h+1		;9b1e	21 88 92	! . .
	sub (hl)		;9b21	96		.
	jp nc,l9bech		;9b22	d2 ec 9b	. . .
	cpl			;9b25	2f		/
	inc a			;9b26	3c		<
	ld (hl),a		;9b27	77		w
	jp l9bcch		;9b28	c3 cc 9b	. . .
	ld b,000h		;9b2b	06 00		. .
l9b2dh:
	ld hl,l9268h		;9b2d	21 68 92	! h .
	ld a,(hl)		;9b30	7e		~
	or a			;9b31	b7		.
	jp nz,l9b48h		;9b32	c2 48 9b	. H .
	ld a,b			;9b35	78		x
	sub 038h		;9b36	d6 38		. 8
	jp nz,l9b3dh		;9b38	c2 3d 9b	. = .
	ld b,a			;9b3b	47		G
	ret			;9b3c	c9		.
l9b3dh:
	add a,040h		;9b3d	c6 40		. @
	ld b,a			;9b3f	47		G
	ld d,008h		;9b40	16 08		. .
	call sub_9bb3h		;9b42	cd b3 9b	. . .
	jp l9b2dh		;9b45	c3 2d 9b	. - .
l9b48h:
	jp m,l9b53h		;9b48	fa 53 9b	. S .
	call sub_9ba0h		;9b4b	cd a0 9b	. . .
	inc b			;9b4e	04		.
	or a			;9b4f	b7		.
	jp p,l9b48h		;9b50	f2 48 9b	. H .
l9b53h:
	ld a,b			;9b53	78		x
	ret			;9b54	c9		.
sub_9b55h:
	ld b,000h		;9b55	06 00		. .
	ld a,h			;9b57	7c		|
	or a			;9b58	b7		.
	jp nz,l9b82h		;9b59	c2 82 9b	. . .
	or l			;9b5c	b5		.
	jp nz,l9b69h		;9b5d	c2 69 9b	. i .
	or d			;9b60	b2		.
	jp nz,l9b72h		;9b61	c2 72 9b	. r .
	or e			;9b64	b3		.
	jp nz,l9b7bh		;9b65	c2 7b 9b	. { .
	ret			;9b68	c9		.
l9b69h:
	ld h,l			;9b69	65		e
	ld l,d			;9b6a	6a		j
	ld d,e			;9b6b	53		S
	ld e,b			;9b6c	58		X
	ld b,008h		;9b6d	06 08		. .
	jp l9b82h		;9b6f	c3 82 9b	. . .
l9b72h:
	ex de,hl		;9b72	eb		.
	ld de,00000h		;9b73	11 00 00	. . .
	ld b,010h		;9b76	06 10		. .
	jp l9b82h		;9b78	c3 82 9b	. . .
l9b7bh:
	ld h,e			;9b7b	63		c
	ld l,b			;9b7c	68		h
	ld de,00000h		;9b7d	11 00 00	. . .
	ld b,018h		;9b80	06 18		. .
l9b82h:
	ld a,h			;9b82	7c		|
l9b83h:
	or a			;9b83	b7		.
	jp m,l9b97h		;9b84	fa 97 9b	. . .
	ld a,e			;9b87	7b		{
	rla			;9b88	17		.
	ld e,a			;9b89	5f		_
	ld a,d			;9b8a	7a		z
	rla			;9b8b	17		.
	ld d,a			;9b8c	57		W
	ld a,l			;9b8d	7d		}
	rla			;9b8e	17		.
	ld l,a			;9b8f	6f		o
	ld a,h			;9b90	7c		|
	rla			;9b91	17		.
	ld h,a			;9b92	67		g
	inc b			;9b93	04		.
	jp l9b83h		;9b94	c3 83 9b	. . .
l9b97h:
	ld (l9261h+2),hl	;9b97	22 63 92	" c .
	ex de,hl		;9b9a	eb		.
	ld (l9261h),hl		;9b9b	22 61 92	" a .
	ld a,b			;9b9e	78		x
	ret			;9b9f	c9		.
sub_9ba0h:
	push hl			;9ba0	e5		.
	ld hl,l9261h		;9ba1	21 61 92	! a .
	ld e,008h		;9ba4	1e 08		. .
	or a			;9ba6	b7		.
l9ba7h:
	ld a,(hl)		;9ba7	7e		~
	rla			;9ba8	17		.
	ld (hl),a		;9ba9	77		w
	inc hl			;9baa	23		#
	dec e			;9bab	1d		.
	jp nz,l9ba7h		;9bac	c2 a7 9b	. . .
	pop hl			;9baf	e1		.
	ret			;9bb0	c9		.
	ld d,004h		;9bb1	16 04		. .
sub_9bb3h:
	call sub_9ba0h		;9bb3	cd a0 9b	. . .
	dec d			;9bb6	15		.
	jp nz,sub_9bb3h		;9bb7	c2 b3 9b	. . .
	ret			;9bba	c9		.
l9bbbh:
	ld de,l9bd4h		;9bbb	11 d4 9b	. . .
	push de			;9bbe	d5		.
l9bbfh:
	call sub_7009h		;9bbf	cd 09 70	. . p
	inc de			;9bc2	13		.
	ld de,0ffffh		;9bc3	11 ff ff	. . .
	ld c,d			;9bc6	4a		J
	ld hl,l9287h+1		;9bc7	21 88 92	! . .
	ld (hl),c		;9bca	71		q
	ret			;9bcb	c9		.
l9bcch:
	ld a,b			;9bcc	78		x
	ld hl,l9287h+1		;9bcd	21 88 92	! . .
	or a			;9bd0	b7		.
	call m,sub_9bdeh	;9bd1	fc de 9b	. . .
l9bd4h:
	ld b,(hl)		;9bd4	46		F
	inc hl			;9bd5	23		#
	ld a,(hl)		;9bd6	7e		~
	and 080h		;9bd7	e6 80		. .
	xor c			;9bd9	a9		.
	ld c,a			;9bda	4f		O
	jp l9c0eh		;9bdb	c3 0e 9c	. . .
sub_9bdeh:
	inc e			;9bde	1c		.
	ret nz			;9bdf	c0		.
	inc d			;9be0	14		.
	ret nz			;9be1	c0		.
	inc c			;9be2	0c		.
	ret nz			;9be3	c0		.
	ld c,080h		;9be4	0e 80		. .
	inc (hl)		;9be6	34		4
	ret nz			;9be7	c0		.
	jp l9bbfh		;9be8	c3 bf 9b	. . .
l9bebh:
	pop hl			;9beb	e1		.
l9bech:
	xor a			;9bec	af		.
	ld h,a			;9bed	67		g
	ld l,a			;9bee	6f		o
	ld (l9285h),hl		;9bef	22 85 92	" . .
	ld (l9287h),hl		;9bf2	22 87 92	" . .
	ret			;9bf5	c9		.
	push hl			;9bf6	e5		.
	call sub_9c1ch		;9bf7	cd 1c 9c	. . .
	pop hl			;9bfa	e1		.
	ld (hl),e		;9bfb	73		s
	inc hl			;9bfc	23		#
	ld (hl),d		;9bfd	72		r
	inc hl			;9bfe	23		#
	ld (hl),c		;9bff	71		q
	inc hl			;9c00	23		#
	ld (hl),b		;9c01	70		p
	jp sub_9c2eh		;9c02	c3 2e 9c	. . .
sub_9c05h:
	call sub_9c26h		;9c05	cd 26 9c	. & .
	push hl			;9c08	e5		.
	call l9c11h		;9c09	cd 11 9c	. . .
	pop hl			;9c0c	e1		.
	ret			;9c0d	c9		.
l9c0eh:
	call sub_9c2eh		;9c0e	cd 2e 9c	. . .
l9c11h:
	ex de,hl		;9c11	eb		.
	ld (l9285h),hl		;9c12	22 85 92	" . .
	ex de,hl		;9c15	eb		.
	ld h,b			;9c16	60		`
	ld l,c			;9c17	69		i
	ld (l9287h),hl		;9c18	22 87 92	" . .
	ret			;9c1b	c9		.
sub_9c1ch:
	ld hl,(l9285h)		;9c1c	2a 85 92	* . .
	ex de,hl		;9c1f	eb		.
	ld hl,(l9287h)		;9c20	2a 87 92	* . .
	ld b,h			;9c23	44		D
	ld c,l			;9c24	4d		M
	ret			;9c25	c9		.
sub_9c26h:
	ld e,(hl)		;9c26	5e		^
	inc hl			;9c27	23		#
	ld d,(hl)		;9c28	56		V
	inc hl			;9c29	23		#
	ld c,(hl)		;9c2a	4e		N
	inc hl			;9c2b	23		#
	ld b,(hl)		;9c2c	46		F
	inc hl			;9c2d	23		#
sub_9c2eh:
	ld a,b			;9c2e	78		x
	or a			;9c2f	b7		.
	ret z			;9c30	c8		.
	ld a,c			;9c31	79		y
	jp l9c3dh		;9c32	c3 3d 9c	. = .
l9c35h:
	ld a,(l9287h+1)		;9c35	3a 88 92	: . .
	or a			;9c38	b7		.
	ret z			;9c39	c8		.
	ld a,(l9287h)		;9c3a	3a 87 92	: . .
l9c3dh:
	rla			;9c3d	17		.
	sbc a,a			;9c3e	9f		.
	or a			;9c3f	b7		.
	scf			;9c40	37		7
	ret nz			;9c41	c0		.
	add a,001h		;9c42	c6 01		. .
	ret			;9c44	c9		.
sub_9c45h:
	ld a,h			;9c45	7c		|
	cpl			;9c46	2f		/
	ld b,a			;9c47	47		G
	ld a,l			;9c48	7d		}
	cpl			;9c49	2f		/
	ld c,a			;9c4a	4f		O
	inc bc			;9c4b	03		.
	ld hl,00000h		;9c4c	21 00 00	! . .
	ld a,011h		;9c4f	3e 11		> .
	push af			;9c51	f5		.
	or a			;9c52	b7		.
	jp l9c60h		;9c53	c3 60 9c	. ` .
l9c56h:
	push af			;9c56	f5		.
	push hl			;9c57	e5		.
	add hl,bc		;9c58	09		.
	jp nc,09c5fh		;9c59	d2 5f 9c	. _ .
	pop af			;9c5c	f1		.
	scf			;9c5d	37		7
	ld a,0e1h		;9c5e	3e e1		> .
l9c60h:
	ld a,e			;9c60	7b		{
	rla			;9c61	17		.
	ld e,a			;9c62	5f		_
	ld a,d			;9c63	7a		z
	rla			;9c64	17		.
	ld d,a			;9c65	57		W
	ld a,l			;9c66	7d		}
	rla			;9c67	17		.
	ld l,a			;9c68	6f		o
	ld a,h			;9c69	7c		|
	rla			;9c6a	17		.
	ld h,a			;9c6b	67		g
	pop af			;9c6c	f1		.
	dec a			;9c6d	3d		=
	jp nz,l9c56h		;9c6e	c2 56 9c	. V .
	ld a,h			;9c71	7c		|
	or a			;9c72	b7		.
	rra			;9c73	1f		.
	ld h,a			;9c74	67		g
	ld a,l			;9c75	7d		}
	rra			;9c76	1f		.
	ld l,a			;9c77	6f		o
	ret			;9c78	c9		.
sub_9c79h:
	ld b,000h		;9c79	06 00		. .
l9c7bh:
	sub 008h		;9c7b	d6 08		. .
	jp c,l9c88h		;9c7d	da 88 9c	. . .
	ld b,e			;9c80	43		C
	ld e,d			;9c81	5a		Z
	ld d,c			;9c82	51		Q
	ld c,000h		;9c83	0e 00		. .
	jp l9c7bh		;9c85	c3 7b 9c	. { .
l9c88h:
	add a,009h		;9c88	c6 09		. .
	ld l,a			;9c8a	6f		o
l9c8bh:
	xor a			;9c8b	af		.
	dec l			;9c8c	2d		-
	ret z			;9c8d	c8		.
	ld a,c			;9c8e	79		y
sub_9c8fh:
	rra			;9c8f	1f		.
	ld c,a			;9c90	4f		O
	ld a,d			;9c91	7a		z
	rra			;9c92	1f		.
	ld d,a			;9c93	57		W
	ld a,e			;9c94	7b		{
	rra			;9c95	1f		.
	ld e,a			;9c96	5f		_
	ld a,b			;9c97	78		x
	rra			;9c98	1f		.
	ld b,a			;9c99	47		G
	jp l9c8bh		;9c9a	c3 8b 9c	. . .
	add a,l			;9c9d	85		.
	sub d			;9c9e	92		.
	ex de,hl		;9c9f	eb		.
	ld hl,(l9287h)		;9ca0	2a 87 92	* . .
	ld b,h			;9ca3	44		D
	ld c,l			;9ca4	4d		M
	ret			;9ca5	c9		.
	ld e,(hl)		;9ca6	5e		^
	inc hl			;9ca7	23		#
	ld d,(hl)		;9ca8	56		V
	inc hl			;9ca9	23		#
	ld c,(hl)		;9caa	4e		N
	inc hl			;9cab	23		#
	ld b,(hl)		;9cac	46		F
	inc hl			;9cad	23		#
	ld a,b			;9cae	78		x
	or a			;9caf	b7		.
	ret z			;9cb0	c8		.
	ld a,c			;9cb1	79		y
	jp l9c3dh		;9cb2	c3 3d 9c	. = .
	ld a,(l9287h+1)		;9cb5	3a 88 92	: . .
	or a			;9cb8	b7		.
	ret z			;9cb9	c8		.
	ld a,(l9287h)		;9cba	3a 87 92	: . .
	rla			;9cbd	17		.
	sbc a,a			;9cbe	9f		.
	or a			;9cbf	b7		.
	scf			;9cc0	37		7
	ret nz			;9cc1	c0		.
	add a,001h		;9cc2	c6 01		. .
	ret			;9cc4	c9		.
	ld a,h			;9cc5	7c		|
	cpl			;9cc6	2f		/
	ld b,a			;9cc7	47		G
	ld a,l			;9cc8	7d		}
	cpl			;9cc9	2f		/
	ld c,a			;9cca	4f		O
	inc bc			;9ccb	03		.
	ld hl,00000h		;9ccc	21 00 00	! . .
	ld a,011h		;9ccf	3e 11		> .
	push af			;9cd1	f5		.
	or a			;9cd2	b7		.
	jp l9c60h		;9cd3	c3 60 9c	. ` .
	push af			;9cd6	f5		.
	push hl			;9cd7	e5		.
	add hl,bc		;9cd8	09		.
	jp nc,09c5fh		;9cd9	d2 5f 9c	. _ .
	pop af			;9cdc	f1		.
	scf			;9cdd	37		7
	ld a,0e1h		;9cde	3e e1		> .
	ld a,e			;9ce0	7b		{
	rla			;9ce1	17		.
	ld e,a			;9ce2	5f		_
	ld a,d			;9ce3	7a		z
	rla			;9ce4	17		.
	ld d,a			;9ce5	57		W
	ld a,l			;9ce6	7d		}
	rla			;9ce7	17		.
	ld l,a			;9ce8	6f		o
	ld a,h			;9ce9	7c		|
	rla			;9cea	17		.
	ld h,a			;9ceb	67		g
	pop af			;9cec	f1		.
	dec a			;9ced	3d		=
	jp nz,l9c56h		;9cee	c2 56 9c	. V .
	ld a,h			;9cf1	7c		|
	or a			;9cf2	b7		.
	rra			;9cf3	1f		.
	ld h,a			;9cf4	67		g
	ld a,l			;9cf5	7d		}
	rra			;9cf6	1f		.
	ld l,a			;9cf7	6f		o
	ret			;9cf8	c9		.
	ld b,000h		;9cf9	06 00		. .
	sub 008h		;9cfb	d6 08		. .
	jp c,l9c88h		;9cfd	da 88 9c	. . .
