; @file: corrimiento de leds
; @author: PERICHE RUIZ ELVIS JOEL    
; @brief description: se presenta un corrimiento de leds con retardos pares e impares 
; @date: 09/01/2023

       
PROCESSOR 18F57Q84
#include "Bit_conf.inc"		    // config statements should precede project file includes./
#include <xc.inc>
#include "RETARDOS.inc"
PSECT udata_acs
    contador_1: DS 1			    ;reserva 1 byte en access ram
    contador_2: DS 1			    ;reserva 1 byte en access ram
    contador_3: DS 1			    ;reserva 1 byte en access ram
    
PSECT resetVect,class=CODE,reloc=2
resetVect:
    goto Main
    
PSECT CODE
Main:
    CALL Config_OSC,1
    CALL Config_Port,1
    MOVLW 00000000B
    MOVWF TRISC,0
codigo:   

    MOVLW 1
    MOVWF PORTC,0
    CALL Delay_500ms
    
    MOVLW 2
    MOVWF PORTC,0
    CALL Delay_250ms   

    MOVLW 00000100B
    MOVWF PORTC,0
    CALL Delay_500ms
    
    MOVLW 00001000B
    MOVWF PORTC,0
    CALL Delay_250ms

    MOVLW 00010000B
    MOVWF PORTC,0
    CALL Delay_500ms
    
    MOVLW 00100000B
    MOVWF PORTC,0
    CALL Delay_250ms
    
    MOVLW 01000000B
    MOVWF PORTC,0
    CALL Delay_500ms
    
    MOVLW 10000000B
    MOVWF PORTC,0
    CALL Delay_250ms
    
Config_OSC:
    ;Configuracion del Oscilador Interno a una frecuencia de 4MHz
    BANKSEL OSCCON1
    MOVLW 0x60				    ;seleccionamos el bloque del osc interno con un div:1
    MOVWF OSCCON1,1
    MOVLW 0x02				    ;seleccionamos una frecuencia de 4MHz
    MOVWF OSCFRQ ,1
    RETURN

Config_Port:  ;PORT-LAT-ANSEL-TRIS	    LED:RF3	BUTTON:RA3
    ;Config Led
    BANKSEL PORTC
    CLRF    PORTC,1			    ; PORTF = 0 
    BSF	    LATC,3,1			    ; LATF<3> =1
    CLRF    ANSELC,1			    ; ANSELF<7:0> = 0 -PORT F DIGITAL
    BCF	    TRISC,3,1			    ; TRISF<3> = 0 - RF3 COMO SALIDA 

    ;Config Button
    BANKSEL PORTA
    CLRF    PORTA,1			    ; PORTA<7:0> = 0
    CLRF    ANSELA,1			    ; PortA digital
    BSF	    TRISA,3,1			    ; RA3 como entrada
    BSF	    WPUA,3,1			    ; Activamos la resistencia Pull-Up del pin RA3
    RETURN 
    
Delay_250:
    MOVLW   250				    ; 1 Tcy -> (k2)
    MOVWF   contador_2,0			    ; 1 Tcy
;T= 6 + 4k
Ext_loop_250ms:				    ; 2 Tcy -- Call
    MOVLW   249				    ; 1 Tcy -> (k1)
    MOVWF   contador_1,0			    ; 1 Tcy
Int_loop_250ms:
    NOP					    ; (k1 * Tcy)
    DECFSZ  contador_1,1,0		    ; (k1-1) + 3 Tcy
    GOTO    Int_loop_250ms
    DECFSZ  contador_2,1,0
    GOTO    Ext_loop_250ms			    ; (k2-1) * 2 Tcy
    RETURN

Delay_500ms:
    MOVLW   50				    ; 1 Tcy -> (k2)
    MOVWF   contador_3,0			    ; 1 Tcy
;T= 6 + 4k
Ciclo3:
    MOVLW   10				    ; 1 Tcy -> (k1)
    MOVWF   contador_2,0			    ; 1 Tcy
Ext_loop_500ms:				    ; 2 Tcy -- Call
    MOVLW   250				    ; 1 Tcy -> (k1)
    MOVWF   contador_1,0			    ; 1 Tcy
Int_loop_500ms:
    NOP					    ; (k1 * Tcy)
    DECFSZ  contador_1,1,0		    ; (k1-1) + 3 Tcy
    GOTO    Int_loop_500ms
    DECFSZ  contador_2,1,0		    ; (k1-1) + 3 Tcy
    GOTO    Ext_loop_500ms
    DECFSZ  contador_3,1,0
    GOTO    Ciclo3			    ; (k2-1) * 2 Tcy
    RETURN
    
END resetVect


