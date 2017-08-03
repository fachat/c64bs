10000 SYS7*4096:.OPT OO
10005 *=$33C:Z0 =$FC:Z1 =$FE
10010 LDY #0:STY Z0:LDX #$20
10020 LDA #$E0:STA Z0+1
10040 L1 LDA (Z0),Y:STA (Z0),Y
10050 INY:BNE L1:INC Z0+1
10060 DEX:BNE L1
10070 LDA #$A0:STA Z0+1:LDX #$20
10080 L2 LDA (Z0),Y:STA (Z0),Y
10090 INY:BNE L2:INC Z0+1
10092 DEX:BNE L2:RTS
10099 .END
10100 SYS828:CLR:REM LABELS LOESCHEN
10110 SYS7*4096:.OPT OO
11000 FLAG =$0298
11005 ACIA =$D600
11010 SERI2 =$029B:SERI1 =$029C
11020 SERO2 =$029E:SERO1 =$029D
11030 SERST =$0297
11040 MAP  =$0299
19999 ;********************************
20000 ;--------------------------------
20005 ;AENDERUNGEN AM ROM
20010 ;--------------------------------
20045 ;FARBE FUER CLR/HOME HINTERGRUND
20050 *=$E4DA : LDA $0286
20060 *=$EB1C : LDY #3; CURSOR SPEED
20070 *=$FF7D : RTS; CLKHI BEI RESET
21000 ;********************************
21005 ;--------------------------------
21010 ;        RS 232 PER ACIA
21020 ;--------------------------------
21021 ; BELEGT     $F014-$F0AC
21022 ;            $F409-$F49D
21023 ;--------------------------------
21030 ;-------OPEN
21040 *=$F409: RSOPEN
21050 LDY #0:STY SERST:RS0 CPY $B7
21060 BEQ RS1:LDA ($BB),Y:STA $0293,Y
21070 INY:CPY #$04:BNE RS0
21080 RS1 LDA $0293:ORA #16:SEI
21090 STA ACIA+1:STA ACIA+3
21100 LDA $0294:AND #$F0:ORA #$07
21110 STA ACIA+2
21120 LDA ACIA+1
21130 LDA #0:STA $02A1:CLI
21140 JSR $FE27:LDA $F8:BNE RS2:DEY
21150 STY $F8:STX $F7
21160 RS2 LDA $FA:BNE RS3:DEY
21170 STY $FA:STX $F9
21180 RS3 SEC:LDA #$F0:JMP $FE2D
21190 ;-------- RESET
21200 RSRESET SEI:LDA #2:STA ACIA+1
21210 STA ACIA+2:CLI:RTS
21220 ;-------- BASIN
21230 RSBASIN LDA SERST:LDY SERI1
21240 CPY SERI2:BEQ RSBIE:AND #$F7
21250 STA SERST:LDA ($F7),Y
21260 INC SERI1:PHA
21270 LDA $0294:AND #1:BEQ RSBI1
21280 LDA SERI1:SEC:SBC SERI2
21290 CMP #$C0:BCC RSBI1
21300 LDA ACIA+2:AND #$F3:ORA #$04
21310 STA ACIA+2:RSBI1 PLA:CLC:RTS
21320 RSBIE ORA #$08:STA SERST:LDA #0
21330 RTS
21340 ;-------- CLOSE
21350 *=$F2AF:JSR RSRESET
21360 *=$F2C5:JMP RS3
21370 ;-------- CHKIN
21380 *=$F227:JMP RSCHKIN
21390 ;-------- CHKOUT
21400 *=$F26C:JMP RSCKOUT
21410 ;-------- BSOUT
21420 *=$F014:NOP:NOP:NOP
21430 RSBSOUT LDY SERO2:INY:CPY SERO1
21440 BEQ RSBSOUT:STY SERO2:DEY
21450 LDA $9E:STA ($F9),Y:CRTS CLC:RTS
21460 ;-------- IRQ
21470 RSIR1 TAX
21480 LDA SERST:AND #$0C:STA SERST
21490 TXA:AND #$63:ORA SERST:STA SERST
21500 ;----
21510 TXA:AND #%00001000:BEQ SI3
21520 LDA ACIA:LDY SERI2:STA ($F7),Y
21530 INY:LDA SERST
21540 CPY SERI1:BNE SI2
21550 ORA #4:STA SERST
21560 SI2 STY SERI2
21570 ;----
21580 LDA $0294:AND #1:BEQ SI3
21590 LDA SERI1:SEC:SBC SERI2;=FREI
21600 CMP #$40:BCS SI3; MEHR ALS 1/4
21610 LDA ACIA+2:AND #$F3:STA ACIA+2
21620 ;----
21630 SI3 TXA:AND #%00010000:BEQ SI6
21640 LDY SERO1:CPY SERO2:BEQ SI6
21650 LDA ($F9),Y:JMP SII
21660 ;----: JMP RSBASIN ;(*=F086)
21670 SII STA ACIA:INY
21680 STY SERO1
21690 ;----
21700 SI6 LDA ACIA+1:RTS
21710 ;----
21720 RSIRQ LDA ACIA+1:BPL RSIR2
21730 JSR RSIR1:JMP $EA81
21740 RSIR2 JMP RSIR3:NOP:NOP:RTS; F0A4
21749 RSIR3 JSR $FFEA:JMP $EA34
21750 ;-------- CHKIN/CKOUT
21760 RSCHKIN STA $99:CLC:RTS
21770 RSCKOUT STA $9A:CLC:RTS
21775 ;--------------------------------
21780 ;-------- NMIOUT ADRS
21790 *=$ED0E:NOP:NOP:NOP
21800 *=$F88A:NOP:NOP:NOP
21810 ;-------- NMI-EINSPRUNG LOESCHEN
21820 *=$FE54:NOP:NOP
21830 *=$FE72:JMP $FEB6
21840 ;-------- IRQ SETZEN
21850 *=$EA31:JMP RSIRQ
21860 ;********************************
22000 ;-------------------------------
22010 *=$E1E6:JSR LSP; LOAD/SAVE IM DIR
22020 *=$E1D9:LDX #8:LDY #1:JSR LSD;
22030 *=$E5E7:JSR KEY; F-TASTEN
22040 *=$ECE7 ; SHIFT RUN/STOP
22050 .BYT "L","�",34,"*"
22060 *=$E455:LDA TTAB,X;BASIC-VEKTOREN
22099 ;--------------------------------
22100 *=$EEBB
22101 LSD STY $B9:JMP TSTBA
22105 LSP JSR $0079:CMP #",":BEQ LSP1
22107 LDY #1:STY $B9:JSR TSTBA
22110 PLA:PLA:JMP $A8F8:LSP1 RTS
22200 KEY JSR $E5B4:BIT FLAG:BMI LSP1
22210 CMP #141:BCS LSP1
22220 CMP #133:BCC LSP1
22230 SBC #133:TAY:LDX KEY1,Y:LDY #1
22240 K1 LDA KT,X:BEQ K2
22250 KTX STA $0276,Y:INY:INX:BNE K1
22260 K2 STY $C6:PLA:PLA:JMP $E5CD
22270 KEY1 .BYT 0,KT3-KT,KT5-KT,KT7-KT
22275 .BYT KT2-KT,KT4-KT,KT6-KT,KT8-KT
22280 KT  .ASC "LIST":.BYT 13,0
22281 KT3 .ASC "RUN:":.BYT 13,0
22282 KT5 .ASC "LOAD":.BYT 13,0
22283 KT7 .ASC ">$0":.BYT 13,0
22284 KT2 .ASC "�":.BYT 0
22285 KT4 .ASC "_":.BYT 13,0
22286 KT6 .ASC "SAVE":.BYT 0
22287 KT8 .ASC "�":.BYT 0
22290 TTAB .WORD $E38B,$A483,NEUBEF
22295 .WORD $A71A,$A7E4,GETAUS
22300 GETAUS LDA #0:STA $0D
22310 JSR $0073:CMP #"$":BEQ GTA1
22320 CMP #"%":BEQ GTA2:JSR $0079
22330 JMP $AE8D
22340 GTA2 LDA #0:STA $63:STA $62
22350 GTA2A JSR $0073:BCS GTAE
22360 CMP #"2":BCS GTAERR
22370 LSR:ROL $63:ROL $62:BCC GTA2A
22380 GTAERR JMP $B248 ; ILL. QUANTITY
22390 GTA1 LDA #0:STA $62:GTA1A STA $63
22400 JSR $0073:SEC:SBC #"0"
22410 BCC GTAE:CMP #10:BCC GTA1O
22420 SBC #"A"-"9"-1:CMP #10:BCC GTAE
22430 CMP #16:BCS GTAERR
22440 GTA1O PHA:LDY #4:GTA3
22450 ASL $63:ROL $62:BCS GTAERR
22460 DEY:BNE GTA3:PLA:ORA $63
22470 JMP GTA1A
22480 GTAE LDX #$90:SEC:JSR $BC49
22490 JMP $0079
22500 NEUBEF LDA $0200
22510 CMP #"@":BEQ NBA1:CMP #">"
22520 BEQ NBA1:CMP #"!":BEQ NBA2
22530 CMP #"_":BEQ SYSOFF:JMP $A57C
22540 NBA2 LDA #1:TAY:STA ($2B),Y
22550 JSR $A533:LDA $22:CLC:ADC #2
22560 STA $2D:LDA $23:ADC #0:STA $2E
22570 JSR $A663:JMP $E386
22580 NBA1 JSR $0073:BCC NBZ1:JMP NB1F
22581 NBZ1 JSR $B79E:TXA:AND #15
22582 STA FLAG:NBA1EX JMP NBA1E
22600 SYSOFF LDX #$0B
22610 SO1 LDA $E447,X:STA $0300,X
22620 DEX:BPL SO1:LDA FLAG
22630 ORA #128:STA FLAG:BNE NBA1EX
22700 TSTBA
22705 LDA FLAG:AND #15:STA $BA:TST1 RTS
22710 NRESET LDA #8:STA FLAG
22715 LDA #128:STA 650
22720 LDA #2:STA ACIA+2
22725 JMP $FF6E
22990 ;--------------------------------
22995 *=$FDF6:JMP NRESET
22999 ;--------------------------------
23000 *=$FE75:NB1F JSR TSTBA
23005 LDA #0:STA $90:LDA $BA:JSR $FFB1
23010 LDA $0201:CMP #"$":BNE NB1C
23015 LDA #$F0:.BYT $2C
23020 NB1C LDA #$FF:JSR $FF93
23025 LDA $90:BMI NBA1E
23030 LDY #0:NBA1A LDA $0201,Y:BEQ NB1E
23035 JSR $FFA8:INY:BNE NBA1A
23040 NB1E JSR $FFAE:LDA $90:BNE NBA1E
23045 LDA $BA:JSR $FFB4
23050 LDA $0201
23055 CMP #"$":JMP NB1G
23057 ;--------------------------------
23058 *=$FEC2
23060 NB1G BEQ NB1D:LDA #$FF
23063 JSR $FF96
23065 NB1B JSR $FFA5:JSR $E716:LDA $90
23070 BEQ NB1B:NBDE JSR $FFAB
23075 NBA1E PLA:PLA:JMP $E386
23085 NB1D LDA #$F0:JSR $FF96
23090 JSR $FFA5:JSR $FFA5
23095 NBDL JSR $FFA5:JSR $FFA5
23100 LDX $90:BNE EDL3
23105 JSR $FFA5:TAX:JSR $FFA5:JSR $BDCD
23110 EDL1 JSR $FFA5:LDX $90:BNE EDL2
23115 JSR $E716:CMP #0
23120 BNE EDL1
23125 EDL2 LDA #13:JSR $E716
23130 JSR $FFE4:BNE EDL3
23135 LDA $90:BEQ NBDL:EDL3 JSR $FFAB
23140 LDA $BA:JSR $FFB1:LDA #$E0
23145 JSR $FF93:JSR $FFAE:JMP NBA1E
23999 ;******** KASSETTE LOESCHEN *****
24000 *=$F5F8: BCC $F5F1 ; SAVE
24010 *=$F4B6: BCC $F4AF ; LOAD
24020 *=$F38B: JMP $F713 ; OPEN
24030 *=$F2C8: JMP $F713 ; CLOSE
24040 *=$F26F: JMP $F713 ; CKOUT
24050 *=$F225: BNE $F26F ; CHKIN
24060 *=$F1E5: SEC:BCS $F1FD ; BSOUT
24070 *=$F179: SEC:RTS   ; BASIN
24999 ;******* PARALLELER IEC-BUS *****
25000 Z1 =$94:Z2 =$95:Z3 =$0285
25010 B1 =$FE1C:B2 =$DC07:B3 =$DC0D
25020 B4 =$DC0F:B5 =$DF00:B6 =$DF01
25030 B7 =$DF03:B8 =$DF04
25040 C1 =$DF00:C2 =$DF02:C3 =$DF03
25050 C4 =$DF04
25055 *=$F72C
25060 IECINI LDA C2:AND # 239:STA C2
25070 LDY # 0:STY C4:LDA # 58
25080 STA C1:LDA # 63:STA C3
25090 LDA C2:AND # 254:STA C2
25100 LDY # 255:L0 DEY :NOP
25110 BNE L0:LDA C2:ORA # 1
25120 STA C2:LDA # 57:STA C1
25130 RTS
25140 ;*****
25150 IECTALK ORA # 64:.BYT $2C
25160 IECLISTEN ORA # 32
25170 IECTL L1 PHA :LDA # 59:STA B7
25180 LDA # 255:STA B6:STA B8
25190 LDA # 250:STA B5:LDA Z1
25200 BPL L2:LDA B5:AND # 223
25210 STA B5:LDA Z2:JSR L7
25220 LDA Z1:AND # 127:STA Z1
25230 LDA B5:ORA # 32:STA B5
25240 L2 LDA B5:AND # 247:STA B5
25250 PLA :JMP L7:SECLISTEN JSR L7
25260 L3 LDA B5:ORA # 8:STA B5
25270 RTS
25280 SECTALK JSR L7:L4 LDA # 61
25290 AND B5:STA B5:LDA # 195
25300 STA B7:LDA # 0:STA B8
25310 BEQ L3:IECOUT PHA :LDA Z1
25320 BPL L5:LDA Z2:JSR L7
25330 LDA Z1:L5 ORA # 128:STA Z1
25340 PLA :STA Z2:CLC 
25350 RTS :UNTALK LDA # 95:BNE L6
25360 UNLISTEN LDA # 63:L6 JSR L1:JSR L4
25370 LDA # 253:ORA B5:STA B5:CLI
25380 RTS :L7 EOR # 255:STA B6
25390 LDA B5:ORA # 18:STA B5
25400 BIT B5:BVC L8:BPL L8
25410 LDA # 128:JSR B1:BNE L12
25420 L8 LDA B5:BPL L8:AND # 239
25430 STA B5:L9 JSR L18:L10 BIT B5
25440 BVS L11:LDA B3:AND # 2
25450 BEQ L10:LDA Z3:BMI L9
25460 LDA # 1:JSR B1:L11 LDA B5
25470 ORA # 16:STA B5:L12 LDA # 255
25480 STA B6:RTS :IECIN LDA B5
25490 AND # 189:ORA # 129:STA B5
25500 L13 JSR L18:L14 LDA B5:AND # 16
25510 BEQ L15:LDA B3:AND # 2
25520 BEQ L14:LDA Z3:BMI L13
25530 LDA # 2:JSR B1:LDA B5
25540 AND # 61:STA B5:LDA # 13
25550 CLC :RTS :L15 LDA B5
25560 AND # 127:STA B5:AND # 32
25570 BNE L16:LDA # 64:JSR B1
25580 L16 LDA B6:EOR # 255:PHA 
25590 LDA B5:ORA # 64:STA B5
25600 L17 LDA B5:AND # 16:BEQ L17
25610 LDA B5:AND # 191:STA B5
25620 PLA :CLC :RTS 
25630 L18 LDA # 255:STA B2:LDA # 17
25640 STA B4:LDA B3:RTS
25700 ;**** EINBINDUNG
25705 NINI STA $DC00
25708 JSR IECINI:JMP $FDAE
25710 NTALK JSR SETDEV
25720 BIT MAP:BPL OTL:JMP IECTL
25730 OTL JSR $F0A4:JMP $ED11
25740 NSECL BIT MAP:BPL OSL:JMP SECLISTEN
25750 OSL JSR $ED36:JMP $EDBE
25760 NSECT BIT MAP:BPL OST:JMP SECTALK
25770 OST JSR $ED36:JMP $EDCC
25780 NOUT BIT MAP:BPL OOUT:JMP IECOUT
25790 OOUT BIT $94:BMI OOUT1:JMP $EDE1
25800 OOUT1 JMP $EDE6
25810 NUT BIT MAP:BPL OUT:JMP UNTALK
25820 OUT JSR $EE8E:JMP $EDF3
25830 NUL BIT MAP:BPL OUL:JMP UNLISTEN
25840 OUL JSR $ED11:JMP $EE03
25850 NIN BIT MAP:BPL OIN:JMP IECIN
25860 OIN SEI:LDA #0:JMP $EE16
25870 SETDEV PHA:STY Z1
25871 AND #15:SEC:SBC #4:BCC PIEC
25872 CMP #7:BCS PIEC:TAY
25873 LDA POT2,Y:LDY Z1:AND MAP:BEQ PIEC
25880 LDA MAP:AND #127:STA MAP:PLA:RTS
25881 PIEC
25885 LDA MAP:ORA #128:STA MAP:PLA:RTS
25886 POT2 .BYT 1,2,4,8,$10,$20,$40
25887 NMINI LDA #0:TAY:JSR $FD53
25888 LDA #%10100001:STA MAP:RTS
25890 *=$FDAB: JSR NINI
25895 *=$FD50: JMP NMINI
25900 *=$ED0E: JMP NTALK; UND LISTEN
25910 *=$EDBB: JMP NSECL
25920 *=$EDC9: JMP NSECT
25930 *=$EDDD: JMP NOUT:NOP
25940 *=$EDF0: JMP NUT
25950 *=$EE00: JMP NUL
25960 *=$EE13: JMP NIN
29990 ;******** LEERE BEREICHE LOESCHEN
49999 ;*******************************
50000 .END
50010 END
50020 OPEN2,2,2,CHR$(6)+CHR$(16)
50030 GET#2,A$:PRINTA$;
50040 GETA$:PRINT#2,A$;
50050 A=ST:IF (AAND247) <>0 THEN PRINTA
50060 IF A$<>"_" THEN50030
50070 CLOSE2
