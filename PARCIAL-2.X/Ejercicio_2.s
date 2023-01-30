;#AUTHOR: PERICHE RUIZ ELVIS JOEL
;GROUP:	5
;#DATE: 30/01/2023
;#VERSION: v6.00    
PROCESSOR 18F57Q84
#include "Bit_config.inc"   ;/config statements should precede project file includes./
#include <xc.inc>
    
PSECT resetVect,class=CODE,reloc=2
resetVect:
    goto Main
    
PSECT ISRVectLowPriority,class=CODE,reloc=2
ISRVectLowPriority:
    BTFSS   PIR1,0,0	; �Se ha producido la INT0?
    GOTO    Exit0
Leds_on:
    BCF	    PIR1,0,0	; limpiamos el flag de INT0
    GOTO    Reload_1
Exit0:
    RETFIE

    
PSECT ISRVectHighPriority,class=CODE,reloc=2
ISRVectHighPriority:
    BTFSS   PIR10,0,0	; �Se ha producido la INT2?
    RETFIE
    GOTO    FIN

     
PSECT udata_acs
contador_1:  DS 1	    
contador_2:  DS 1
contador_3:  DS 1
offset:	    DS 1
offset1:    DS 1
counter:    DS 1
counter_1:   DS 1 
    
       
PSECT CODE    
Main:
    CALL    Config_OSCILADOR,1
    CALL    Config_Port,1
    CALL    Config_PPS,1
    CALL    Config_INT0_INT1_INT2,1
    GOTO    toggle
   
       
toggle:			    ; alternar
   BTG	   LATF,3,0	    ;toggle Led
   CALL    Delay_500ms,1
   BTG	   LATF,3,0	    ;toggle Led
   CALL    Delay_500ms,1
   goto	   toggle
   
     
Loop_1:
    GOTO    Loop_1
Loop:
    BSF	    LATF,3,0	    ;toggle off
    BANKSEL PCLATU
    MOVLW   low highword(Table)
    MOVWF   PCLATU,1
    MOVLW   high(Table)
    MOVWF   PCLATH,1
    RLNCF   offset,0,0
    CALL    Table
    MOVWF   LATC,0
    CALL    Delay_250ms,1
    DECFSZ  counter,1,0
    GOTO    Next_Sequence
    
 Verify:
    DECFSZ  counter_1,1,0
    GOTO    Reload_2
    GOTO    FIN
    
 Next_Sequence:
    INCF    offset,1,0
    GOTO    Loop
    
Reload_1:
    MOVLW   0x05	
    MOVWF   counter_1,0	; carga del contador con el numero de offsets
    MOVLW   0x00	
    MOVWF   offset,0	; definimos el valor del offset inicial
    
Reload_2:
    MOVLW   0x0A	
    MOVWF   counter,0	; carga del contador con el numero de offsets
    MOVLW   0x00	
    MOVWF   offset,0	; definimos el valor del offset inicial
    GOTO    Loop  
    
Config_OSCILADOR:
    ;Configuracion del Oscilador Interno a una frecuencia de 4MHz
    BANKSEL OSCCON1
    MOVLW   0x60    ;seleccionamos el bloque del osc interno(HFINTOSC) con DIV=1
    MOVWF   OSCCON1,1 
    MOVLW   0x02    ;seleccionamos una frecuencia de Clock = 4MHz
    MOVWF   OSCFRQ,1
    RETURN
    
Config_Port:	
    ;Config Led
    BANKSEL PORTF
    CLRF    PORTF,1	
    BSF	    LATF,3,1
    BSF	    LATF,2,1
    CLRF    ANSELF,1	
    BCF	    TRISF,3,1
    BCF	    TRISF,2,1
    
    ;Config User Button
    BANKSEL PORTA
    CLRF    PORTA,1	
    CLRF    ANSELA,1	
    BSF	    TRISA,3,1	
    BSF	    WPUA,3,1
    
    ;Config Ext Button
    BANKSEL PORTB
    CLRF    PORTB,1	
    CLRF    ANSELB,1	
    BSF	    TRISB,4,1	
    BSF	    WPUB,4,1
    
    ;Config Ext Button2
    BANKSEL PORTF
    CLRF    PORTF,1	
    CLRF    ANSELF,1	
    BSF	    TRISF,2,1	
    BSF	    WPUF,2,1
    
    ;Config PORTC
    BANKSEL PORTC
    CLRF    PORTC,1	
    CLRF    LATC,1	
    CLRF    ANSELC,1	
    CLRF    TRISC,1
    RETURN
    
Config_PPS:
    ;Config INT0
    BANKSEL INT0PPS
    MOVLW   0x03
    MOVWF   INT0PPS,1		; INT0 -> RA3
    
    ;Config INT1
    BANKSEL INT1PPS
    MOVLW   0x0C
    MOVWF   INT1PPS,1		; INT1 -> RB4
    
    ;Config INT2
    BANKSEL INT2PPS
    MOVLW   0x2A
    MOVWF   INT2PPS,1		; INT2 -> RF2
    
    RETURN
    
;   Secuencia para configurar interrupcion:
;    1. Definir prioridades
;    2. Configurar interrupcion
;    3. Limpiar el flag
;    4. Habilitar la interrupcion
;    5. Habilitar las interrupciones globales
Config_INT0_INT1_INT2:
    ;Configuracion de prioridades
    BSF	INTCON0,5,0 ; INTCON0<IPEN> = 1 -- HABILITAMOS LAS PRIORIDADES
    BANKSEL IPR1
    BCF	IPR1,0,1    ; IPR1<INT0IP> = 0 -- INT0 de baja prioridad
    BSF	IPR6,0,1    ; IPR6<INT1IP> = 0 -- INT1 de Alta prioridad
    BSF	IPR10,0,1   ; IPR6<INT1IP> = 0 -- INT2 de Alta prioridad
    ;Config INT0
    BCF	INTCON0,0,0 ; INTCON0<INT0EDG> = 0 -- INT0 por flanco de bajada
    BCF	PIR1,0,0    ; PIR1<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE1,0,0    ; PIE1<INT0IE> = 1 -- habilitamos la interrupcion ext0
    
    ;Config INT1
    BCF	INTCON0,1,0 ; INTCON0<INT1EDG> = 0 -- INT1 por flanco de bajada
    BCF	PIR6,0,0    ; PIR6<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE6,0,0    ; PIE6<INT0IE> = 1 -- habilitamos la interrupcion ext1
    
    ;Config INT2
    BCF	INTCON0,2,0 ; INTCON0<INT1EDG> = 0 -- INT2 por flanco de bajada
    BCF	PIR10,0,0    ; PIR10<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE10,0,0    ; PIE10<INT0IE> = 1 -- habilitamos la interrupcion ext1 
    
    ;Habilitacion de interrupciones
    BSF	INTCON0,7,0 ; INTCON0<GIE/GIEH> = 1 -- habilitamos las interrupciones de forma global y de alta prioridad
    BSF	INTCON0,6,0 ; INTCON0<GIEL> = 1 -- habilitamos las interrupciones de baja prioridad
    RETURN

Table:
    ADDWF   PCL,1,0
    RETLW   10000001B	; offset: 0
    RETLW   01000010B	; offset: 1
    RETLW   00100100B	; offset: 2
    RETLW   00011000B	; offset: 3
    RETLW   00000000B	; offset: 4 -> se apagan todos
    RETLW   00011000B	; offset: 5
    RETLW   00100100B	; offset: 6
    RETLW   01000010B	; offset: 7
    RETLW   10000001B	; offset: 8
    RETLW   00000000B	; offset: 9
    
; de 250ms
Delay_250ms:		    ; 2Tcy -- Call
    MOVLW   250		    ; 1Tcy -- k2
    MOVWF   contador_2,0    ; 1Tcy
; T = (6 + 4k)us	    1Tcy = 1us
Ext_Loop:		    
    MOVLW   249		    ; 1Tcy -- k1
    MOVWF   contador_1,0    ; 1Tcy
Int_Loop:
    NOP			     ; k1*Tcy
    DECFSZ  contador_1,1,0   ; (k1-1)+ 3Tcy
    GOTO    Int_Loop	     ; (k1-1)*2Tcy
    DECFSZ  contador_2,1,0
    GOTO    Ext_Loop
    RETURN		     ; 2Tcy
    
; de 500ms
Delay_500ms:
    MOVLW 2
    MOVWF contador_3,0
    Loop_250ms:		      ;2tcy
    MOVLW 250		      ;1tcy
    MOVWF contador_2,0	      ;1tcy
    Loop_1ms:			     
    MOVLW   249		     ;k Tcy
    MOVWF   contador_1,0     ;k tcy
    INT_LOOP:			    
    Nop			     ;249k TCY
    DECFSZ  contador_1,1,0		 ;251k TCY 
    Goto    INT_LOOP			 ;496k TCY
    DECFSZ  contador_2,1,0		 ;(k-1)+3tcy
    GOTO    Loop_1ms			 ;(k-1)*2tcy
    DECFSZ  contador_3,1,0
    GOTO     Loop_250ms
    RETURN  

FIN:
End resetVect