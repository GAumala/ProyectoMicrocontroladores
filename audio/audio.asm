;*******************************************************************************
;	            ***ESCUELA SUPERIOR POLITECNICA DEL LITORAL***	               *
;			                        ESPOL				                       *
;	            FACULTAD DE INGENIERIA ELECTRICA Y COMPUTACION		           *
;		                LABORATORIO DE MICROCONTROLADORES		               *
;			                      PROYECTO 1P				                   *
;			                 GENERADOR DE SONIDO 			                   *
;		                    PROGRAMADOR: JOSE CUEVA			                   *	
;*******************************************************************************

    LIST    p=16F887	;Tipo de microcontrolador
	INCLUDE P16F887.INC	;Define los SFRs y bits del P16F887

    ;Setea parámetros de configuración
	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_XT_OSC 

	errorlevel	 -302	;Deshabilita mensajes de advertencia por cambio bancos	
		
	CBLOCK	0X020
	DATO		; Señal de entrada por bit
	VECES		; Cuantas veces se presenta la señal			
	tempTMR0	;  variable para realizar retardo en el sonido
	d1
	d2	
	d3			; Ayudan en subrutina de Retardo 1SEG
	TEMPO		; Ayuda a mostrar una presentacion adecuada de la señal
	TEMPO2		; Ayuda a mostrar una presentacion adecuada de la señal
	RANDOM		; Genera un numero aleatorio
	ALTO		; Bandera que me avisa si hay un cambio de nivel logico
    count3
    count2
    count
	ENDC

;**********************************************************

    ;PROGRAMA
        ORG		0x00		;Vector de RESET
        GOTO	MAIN
        ORG		0X04
        GOTO	INTER

    INTER 							; Interrupcion de sonido
        BTFSC		INTCON,T0IF		; se desbordo TMR0?
        GOTO		INTTMR0			; Si
        RETFIE

; EL sonido se produce al enviar 1's y 0's al SOUNDER 
; a una frecuencia determinada

    INTTMR0			; SRI usado para sonido	
        BCF			INTCON,T0IF		; borro la bandera
        BTFSC		PORTE,2			; hay un 1
        GOTO		hacer0			; si
        BSF			PORTE,2			; hacer 1
        MOVF		tempTMR0,w		
        MOVWF		TMR0			; cargo al TMR0
        RETFIE
    hacer0
        BCF			PORTE,2			; hacer 0
        MOVF		tempTMR0,w		
        MOVWF		TMR0			; cargo TMR0
        RETFIE
        
    retardo
            movlw 0x1
           movwf count3
    ciclo3 movlw d'255' 			;1 (CI) ,donde M=20
           movwf count2		;1 (CI) 
    ciclo2 movlw d'255'			;1 (CI),donde N=255
           movwf count		;1 (CI)
    ciclo decfsz count,f  	;1*(N-1) +2  (CI)
          goto ciclo 		;2*(N-1)     (CI)
          decfsz count2,f 	;1*(M-1) +2   (CI)
          goto ciclo2  		;2*(M-1)     (CI)
          decfsz count3,f
          goto ciclo3 

    return
     
    ;si sumamos lo que tarda cada instruccion seria [(3N+1)M+3M+1 ]
    ;queremos un retardo de 15289,02us, dando valores M Y N
    ;la frecuencia es de 4MHZ entonces el CI= 1us
    ;el (ciclo)se demorara 766us  (contando con la el mov de w al counter)
    ; Codigo para sonido por notas


    DO
        MOVLW	0X11
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    RE
        MOVLW	0X2C
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    MI
        MOVLW	0X42
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    FA
        MOVLW	0X4D
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    SOL
        MOVLW	0X60
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    LA
        MOVLW	0X72
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    SI
        MOVLW	0X82
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN

    ; NOTAS TIPO 2

    do
        MOVLW	0X88
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    re
        MOVLW	0X96
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    mi
        MOVLW	0XA1
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    fa
        MOVLW	0XA6
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    sol
        MOVLW	0XB0
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    la
        MOVLW	0XB9
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    si
        MOVLW	0XC0
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN

    SONIDO1						; Sonido para codificación RZ
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		LA			;carga la nota
        CALL		retardo	;suena la nota 1 seg
        CALL		MI
        CALL		retardo
        CALL		FA			;carga la nota
        CALL		retardo	;suena la nota 1 seg
        CALL		SOL
        CALL		retardo
        CALL		FA			;carga la nota
        CALL		retardo	;suena la nota 1 seg

        CALL		MI			;carga la nota
        CALL		retardo	;suena la nota 1 seg
        CALL		RE
        CALL		retardo
        CALL		RE			;carga la nota
        CALL		retardo	;suena la nota 1 seg
        CALL		FA
        CALL		retardo
        CALL		LA			;carga la nota
        CALL		retardo	;suena la nota 1 seg
        CLRF		INTCON		; Deshabilita las interrupciones	
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF			PORTE,2
        GOTO 		LOOP 

    SONIDO2
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		mi														
        CALL		retardo												
        CALL		retardo											
        CALL		do											
        CALL		retardo									
        CALL		retardo								
        CALL		mi								
        CALL		retardo		
        CALL		retardo			
        CALL		do					
        CALL		retardo		
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CLRF		INTCON		; Deshabilita las interrupciones	
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF			PORTE,2
        GOTO        LOOP
			
    TESTNOTA
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		do														
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CALL		retardo	
        CLRF		INTCON		; Deshabilita las interrupciones	
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF			PORTE,2
        GOTO        LOOP

    MAIN
    ;SETEO DE PUERTOS 
        BANKSEL		ANSEL		; Selecciona el Bank3
        CLRF		ANSEL
        CLRF		ANSELH		; Pines como digitales
        BANKSEL 	TRISA		; Selecciona el Bank1
        MOVLW		B'11111111'
        MOVWF		TRISA		; PORTA declarado como entrada
        CLRF		TRISC		
        CLRF		TRISB
        CLRF		TRISE		; PORT B,C,E declarados como salidas
        MOVLW		B'00000001'
        movwf		TRISD		; PORTD,0 declarado como entrada
        MOVLW		B'10010001'
        MOVWF		OPTION_REG	; Configuro con un preescalador de 4
        CLRF 		INTCON
        
    INICIALIZACION	      
        BANKSEL 	PORTA		; Selecciona el Bank0		
        CLRF		PORTB		; Borra latch de salida de PORTB
        CLRF		PORTC		; Borra latch de salida de PORTC
        CLRF   		PORTE		; Borra latch de salida de PORTE
        CLRF		PORTD		; Borra latch de salida de PORTD
        MOVLW		.3			; señal se mostrara 2 veces
        MOVWF		VECES
        MOVLW		.255
        MOVWF		TEMPO
        MOVLW		.10
        ; Configuracion de retardo para conseguir buena apreciacion
        MOVWF		TEMPO2		
    LOOP
        GOTO 	TESTNOTA

END 
