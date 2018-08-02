/*
 *  wurzbach_ledring_plusminus.asm
 *
 *  Created: 01.08.2018
 *  Author: nullsibnelf
 */ 


  /*
	Registerübersicht
	
	r16		Arbeitsregister

	r17		Arbeitsregister Zwischenergebnis
	r18		Schleifen-Zähler
	r19		LED-Arbeits-register

	r20		grün
	r21		rot
	r22		blau
	r23		sollwert leuchtende leds
	
	r24		AD Rechnung
	r25		AD Rechnung


						----u---
			PB5		1 -|		|- 8	VCC
			PB3		2 -|		|- 7	PB2	(SCK)
	(LED)	PB4		3 -|		|- 6	PB1 (MISO)
			GND		4 -|		|- 5	PB0 (MOSI)
						--------
 */
 
.include "tn13def.inc"


 init:

	ldi		r16, 0x55
	out		OSCCAL, r16			// Korrekturwert für int. Oscillator
 
	sbi		DDRB, 4				// LED als Ausgang
	sbi		PORTB, 2			// PU für Taster
	sbi		PORTB, 1			// PU für Taster
	sbi		PORTB, 0			// PU für Taster

	ldi		r20, 0x00			// gn
	ldi		r21, 0x00			// rt
	ldi		r22, 0x00			// bl
	ldi		r23, 0x00			// 0x0D -> vollausschlag - 13 LEDs
	
    ldi     r16, (1<<ADEN) | (1<<ADSC) | (1<<ADATE) | (1<<ADPS1) | (1<<ADPS0)
    out     ADCSRA, r16
	
	ldi     r16, (1<<ADLAR) | (1<<MUX1) | (1<<MUX0)
    out     ADMUX, r16
	
	rcall	pause
	rcall	pause
	rcall	pause
	rcall	pause
	rcall	pause
	
main:

	rcall	get_io

	rcall	ad_wandlung

	rjmp	main



// ---------------------------------------
//        S U B R O U T I N E S
// ---------------------------------------

get_io:
	ldi		r17, 0x00

	sbis	PINB, 2
	rjmp	get_io_weiter_1
	inc		r17
	inc		r17
	inc		r17
	inc		r17
get_io_weiter_1:

	sbis	PINB, 1
	rjmp	get_io_weiter_2
	inc		r17
	inc		r17
get_io_weiter_2:

	sbis	PINB, 0
	rjmp	get_io_weiter_3
	inc		r17
get_io_weiter_3:

	
	cpi		r17, 0x08
	brlo	color_8_hoeher
	rjmp	color_8_weiter
color_8_hoeher:
	ldi r20, 0x10
	ldi r21, 0x10
	ldi r22, 0x10
color_8_weiter:

	
	cpi		r17, 0x07
	brlo	color_7_hoeher
	rjmp	color_7_weiter
color_7_hoeher:
	ldi r20, 0x10
	ldi r21, 0x00
	ldi r22, 0x10
color_7_weiter:

	
	cpi		r17, 0x06
	brlo	color_6_hoeher
	rjmp	color_6_weiter
color_6_hoeher:
	ldi r20, 0x00
	ldi r21, 0x10
	ldi r22, 0x10
color_6_weiter:

	
	cpi		r17, 0x05
	brlo	color_5_hoeher
	rjmp	color_5_weiter
color_5_hoeher:
	ldi r20, 0x10
	ldi r21, 0x10
	ldi r22, 0x00
color_5_weiter:

	
	cpi		r17, 0x04
	brlo	color_4_hoeher
	rjmp	color_4_weiter
color_4_hoeher:
	ldi r20, 0x10
	ldi r21, 0x00
	ldi r22, 0x00
color_4_weiter:

	
	cpi		r17, 0x03
	brlo	color_3_hoeher
	rjmp	color_3_weiter
color_3_hoeher:
	ldi r20, 0x00
	ldi r21, 0x10
	ldi r22, 0x00
color_3_weiter:


	cpi		r17, 0x02
	brlo	color_2_hoeher
	rjmp	color_2_weiter
color_2_hoeher:
	ldi r20, 0x00
	ldi r21, 0x00
	ldi r22, 0x10
color_2_weiter:


	cpi		r17, 0x01
	brlo	color_1_hoeher
	rjmp	color_1_weiter
color_1_hoeher:
	ldi r20, 0x01
	ldi r21, 0x01
	ldi r22, 0x01
color_1_weiter:
	
	ret

	
// ---------------------------------------


ad_wandlung:

	in r25, ADCL		// ADCL
	in r23, ADCH		// ADCH	
	lsr r25
	lsr r25
	lsr r25
	lsr r25
	lsr r25
	lsr r25

	mov r24, r23		// zu große Werte abfangen
	cpi r23, 0xFB
	brsh not_to_great
	add r24, r25		// Flackern dazurechnen
not_to_great:

	cpi r24, 254		// Grenzwert 11te LED
	brlo hoeher_11
	rcall send_color
	rjmp weiter_11
hoeher_11:
	rcall send_blank
weiter_11:

	cpi r24, 230		// Grenzwert 10te LED
	brlo hoeher_10
	rcall send_color
	rjmp weiter_10
hoeher_10:
	rcall send_blank
weiter_10:
		
	cpi r24, 204		// Grenzwert  9te LED
	brlo hoeher_9
	rcall send_color
	rjmp weiter_9
hoeher_9:
	rcall send_blank
weiter_9:
	
	cpi r24, 179		// Grenzwert  8te LED
	brlo hoeher_8
	rcall send_color
	rjmp weiter_8
hoeher_8:
	rcall send_blank
weiter_8:
	
	cpi r24, 153		// Grenzwert  7te LED
	brlo hoeher_7
	rcall send_color
	rjmp weiter_7
hoeher_7:
	rcall send_blank
weiter_7:
	
	rcall send_color	// Mitten - LED

	cpi r24, 102		// Grenzwert  5te LED
	brlo hoeher_5
	rcall send_blank
	rjmp weiter_5
hoeher_5:
	rcall send_color
weiter_5:
	
	cpi r24, 77			// Grenzwert  4te LED
	brlo hoeher_4
	rcall send_blank
	rjmp weiter_4
hoeher_4:
	rcall send_color
weiter_4:
	
	cpi r24, 51			// Grenzwert  3te LED
	brlo hoeher_3
	rcall send_blank
	rjmp weiter_3
hoeher_3:
	rcall send_color
weiter_3:
	
	cpi r24, 26			// Grenzwert  2te LED
	brlo hoeher_2
	rcall send_blank
	rjmp weiter_2
hoeher_2:
	rcall send_color
weiter_2:

	cpi r24, 1			// Grenzwert  1te LED
	brlo hoeher_1
	rcall send_blank
	rjmp weiter_1
hoeher_1:
	rcall send_color
weiter_1:

	ret



// ---------------------------------------
// Pause für Übernahme
// ---------------------------------------
pause:
	ldi		r16, 0xC0	// 50µs Pause für Übernahme der gesendeten Werte
pausenloop:
	dec		r16
	brne	pausenloop
	ret


// ---------------------------------------
// 1 High-Bit senden
// ---------------------------------------
high_:
	sbi		PORTB, 4
	nop
	nop
	nop
	nop
	nop
	nop

	cbi		PORTB, 4
	nop
	ret


// ---------------------------------------
// 1 Low-Bit senden
// ---------------------------------------
low_:
	sbi		PORTB, 4
	nop
	
	cbi		PORTB, 4
	nop
	nop
	nop
	nop
	nop
	nop
	ret


// ---------------------------------------
// 24 Bit übertragen (3 Farben)
// ---------------------------------------
send_color:
 	ldi		r18, 0x08		// Schleifencounter 8 Bit
	mov		r17, r20
send_loop1:
	sbrc	r17, 7
	rcall	high_
	sbrs	r17, 7
	rcall	low_
	lsl		r17
	dec		r18
	brne	send_loop1
	
 	ldi		r18, 0x08		// Schleifencounter 8 Bit
	mov		r17, r21
send_loop2:
	sbrc	r17, 7
	rcall	high_
	sbrs	r17, 7
	rcall	low_
	lsl		r17
	dec		r18
	brne	send_loop2
	
 	ldi		r18, 0x08		// Schleifencounter 8 Bit
	mov		r17, r22
send_loop3:
	sbrc	r17, 7
	rcall	high_
	sbrs	r17, 7
	rcall	low_
	lsl		r17
	dec		r18
	brne	send_loop3
	ret


// ---------------------------------------
// LED aus
// ---------------------------------------
send_blank:
 	ldi		r18, 0x18		// Schleifencounter 24 Bit
	ldi		r17, 0x00
send_loop:
	sbrc	r17, 7
	rcall	high_
	sbrs	r17, 7
	rcall	low_
	lsl		r17
	dec		r18
	brne	send_loop
	ret


// ENDE -------------------------------------------------------------- ENDE //
/*
11 LEDS Grenzwerte 5V Betrieb 3,3V Poti-Versorgung

	cpi r24, 0xA9
	cpi r24, 0xA3
	cpi r24, 0x8F
	cpi r24, 0x7C
	cpi r24, 0x68
	cpi r24, 0x53
	cpi r24, 0x3C
	cpi r24, 0x29
	cpi r24, 0x16
	cpi r24, 0x05
	cpi r24, 0x01
	

11 LEDS Grenzwerte 5V Betrieb 5V Poti-Versorgung

	cpi r24, 254
	cpi r24, 230
	cpi r24, 204
	cpi r24, 179
	cpi r24, 153
	cpi r24, 128
	cpi r24, 102
	cpi r24, 77
	cpi r24, 51
	cpi r24, 26
	cpi r24, 1


13 LEDs Grenzwerte 5V Betrieb 5V Poti-Versorgung
	
	cpi r24, 0xFE
	cpi r24, 0xEF
	cpi r24, 0xD8
	cpi r24, 0xC1
	cpi r24, 0xAA
	cpi r24, 0x93
	cpi r24, 0x7C
	cpi r24, 0x65
	cpi r24, 0x4E
	cpi r24, 0x37
	cpi r24, 0x20
	cpi r24, 0x09
	cpi r24, 0x01

	*/
