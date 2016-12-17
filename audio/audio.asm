;*******************************************************************************
;		***ESCUELA SUPERIOR POLITECNICA DEL LITORAL***		       *
;	                                ESPOL				       *
;	        FACULTAD DE INGENIERIA ELECTRICA Y COMPUTACION		       *
;	                LABORATORIO DE MICROCONTROLADORES	               *
;		                     PROYECTO 1P			       *
;									       *
                ;	PROGRAMADOR: JOSE CUEVA TUMBACO		       *	
;*******************************************************************************

;***********************************ENCABEZADO*********************************;

;-----------------------------Configuracion inicial----------------------------;
    LIST        p=16F887		;Tipo de microcontrolador	       
    INCLUDE 	P16F887.INC		;Define los SFRs y bits del P16F887
                                                                          
    __CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_INTOSCIO			 
    errorlevel	 -302	;Deshabilita mensajes de advertencia por cambio bancos

;----------------------------Declaracion de variables--------------------------;
	CBLOCK	0X20							
	ENDC							

;*******************************CODIGO PRINCIPAL********************************

;------------------------inicializacion de registros SFR----------------------;*
MAIN								
    banksel	TRISB		; Selects bank containing register TRISB
    clrf        TRISB		; All port B pins are configured as outputs                 

												
    BANKSEL     ANSEL								
    CLRF        ANSEL   ; configura puertos con entradas digitales
    CLRF        ANSELH	; configura puertos con entradas digitales
    banksel     TRISA
    MOVLW       b'00000011'
    MOVWF       TRISA

    BCF     STATUS,RP0		;regresa al banco cero		


;PROGRAMA
    ORG		0x00		;Vector de RESET
    GOTO	MAIN
    ORG		0X04
    GOTO	INTER

INTER 	        ; Interrupcion de sonido
    BTFSC       INTCON,T0IF  ; se desbordo TMR0?
    GOTO        INTTMR0	 ; Si
    RETFIE

; EL sonido se produce al enviar 1's y 0's al SOUNDER a una frecuencia determinada

INTTMR0			; SRI usado para sonido	
	BCF			INTCON,T0IF		; borro la bandera
	BTFSC		PORTE,0			; hay un 1
	GOTO		hacer0			; si
	BSF			PORTE,0			; hacer 1
	MOVF		tempTMR0,w		
	MOVWF		TMR0			; cargo al TMR0
	RETFIE
hacer0
	BCF			PORTE,0			; hacer 0
	MOVF		tempTMR0,w		
	MOVWF		TMR0			; cargo TMR0
	RETFIE


