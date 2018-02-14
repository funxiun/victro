LINES = 312
CYCLES_PER_LINE = 71
TIMER_VALUE = LINES * CYCLES_PER_LINE - 2

Delay = $50

			*=$1004

			jsr $1c00

			jsr wraptext
			
			lda $9005
			and #$f0
			ora #%00001101
 			sta $9005

			ldx #0
-
			lda #$0
			sta $1e00,x
			sta $1f00,x
			lda #$06
			sta $9400,x
			sta $9500,x
			sta $9600,x
			sta $9700,x
			inx
			bne -
			
			ldx #0
			
-
			lda screen+(0*22),x
			sta $1e00 +(7*22),x
			lda screen+(1*22),x
			sta $1e00 +(8*22),x
			lda screen+(2*22),x
			sta $1e00 +(9*22),x
			lda screen+(3*22),x
			sta $1e00 +(10*22),x
			lda screen+(4*22),x
			sta $1e00 +(11*22),x
			lda screen+(5*22),x
			sta $1e00 +(12*22),x
			lda screen+(6*22),x
			sta $1e00 +(13*22),x
			lda screen+(7*22),x
			sta $1e00 +(14*22),x
			lda screen+(8*22),x
		 	sta $1e00 +(15*22),x
			inx
			cpx #22
			bne -

			ldx #0
			ldy #$99
-
			tya
			sta $1e00+(17*28)-12,x
			pha
			lda #$1
			sta $9600+(17*28)-12,x
			pla
			tay
			iny
			inx
			cpx #28
			bne -

			

			lda #$7f
			sta $912e     ; disable and acknowledge interrupts
			sta $912d
			sta $911e     ; disable NMIs (Restore key)

			ldx #28       ; wait for this raster line (times 2)
-
			cpx $9004
			bne -        ; at this stage, the inaccuracy is 7 clock cycles


			lda #$40      ; enable Timer A free run of both VIAs
			sta $911b
			sta $912b

			lda #<TIMER_VALUE
			ldx #>TIMER_VALUE
			sta $9116     ; load the timer low byte latches
			sta $9126

			ldy #7        ; make a little delay to get the raster effect to the
			dey           ; right place
			bne *-1
			nop
			nop
			stx $9125     ; start the IRQ timer A
				        ; 6560-101: 65 cycles from $9004 change
			                ; 6561-101: 77 cycles from $9004 change
			ldy #10       ; spend some time (1+5*9+4=55 cycles)
			dey           ; before starting the reference timer
			bne *-1
			stx $9115     ; start the reference timer

			lda #<irq
			ldy #>irq
			sta $0314
			sty $0315
			lda #$c0
			sta $912e     ; enable Timer A underflow interrupts

			jmp *

irq

			lda #$0c
			sta $9000
			lda #$26
			sta $9001
			lda #$96
			sta $9002


			lda #$40
			cmp $9004
			bne *-3


			ldx #$b
-			dex
			bne -

			
			ldx #0
-
			lda colors,x
			sta $1000; sta $900f
			ldy #$9
			dey
			bne *-1
			nop
			nop
			nop
			nop
			nop
			inx
			cpx #80
			bne -

			nop

			nop
			nop
			nop
			nop
			nop
			nop
			nop


		;	lda #$90
		;	sta $9004
			lda #$06
			sta $9000

			lda #$2c
			sta $9001

			lda #$9c
			sta $9002

			jsr $1c06

			jsr rolscroller


			jmp $eabf

rolscroller

			ldx #0
doscroll

			rol $1400+($b5*8),x
			rol $1400+($b4*8),x
			rol $1400+($b3*8),x
			rol $1400+($b2*8),x
			rol $1400+($b1*8),x
			rol $1400+($b0*8),x
			rol $1400+($af*8),x
			rol $1400+($ae*8),x
			rol $1400+($ad*8),x
			rol $1400+($ac*8),x
			rol $1400+($ab*8),x
			rol $1400+($aa*8),x
			rol $1400+($a9*8),x
			rol $1400+($a8*8),x
			rol $1400+($a7*8),x
			rol $1400+($a6*8),x
			rol $1400+($a5*8),x
			rol $1400+($a4*8),x
			rol $1400+($a3*8),x
			rol $1400+($a2*8),x
			rol $1400+($a1*8),x
			rol $1400+($a0*8),x
			rol $1400+($9f*8),x
			rol $1400+($9e*8),x
			rol $1400+($9d*8),x
			rol $1400+($9c*8),x
			rol $1400+($9b*8),x
			rol $1400+($9a*8),x
			rol $1400+($99*8),x

			inx
			cpx #8
			bne doscroll

			lda delay
			sec
			sbc #1
			and #7
			sta delay
			bcc dochar
			rts
dochar

			ldy #0
			lda ($f0),y
			beq wraptext
			asl
			asl
			asl
			tax

			bcc noextrachar
			inc char+2
			
noextrachar

			ldy #0
char
			lda $8000,x
			sta $1400+($b5*8),y
			inx
			iny
			cpy #8
			bne char
			inc $f0
			lda #$80
			sta char+2

			rts
wraptext
			lda #<tekst
			ldy #>tekst
			sta $f0
			sty $f1
			rts
;---------------------------------------------------------------


colors
			.byte $ee,$00
	
.rept 75
			.byte $ee		
.next

			.byte $00,$ee,$00

screen

			.binary "pic2.sc1",2

*=$1300
.enc screen
tekst
			.text "yoohoo!silicon is on the vic20!okay,this thingy's nothing special but i wanted to show you"
			.text " my first steps exploring this neat 8bit machine.credits:everything by scout.some quick"
			.text " greetings to dekadence,cosine,ate bit,pwp,cncd,k2,orb and you.gotta wrap!  ",0

;-----------------------------------------------------
*=$1400
			.binary "pic2.chr",2

.rept 8*29
			.byte 255
.next

;-------------------------------------------------------

			*=$1a00

	;		.binary "vic20.prg",2

		.binary "testvier.prg",2