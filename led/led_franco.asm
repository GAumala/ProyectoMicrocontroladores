	LIST	p=16F887	;Tipo de microcontrolador
	INCLUDE P16F887.INC	;Define los SFRs y bits del 
						;P16F887
	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_INTOSCIO	
						;Setea parámetros de 
						;configuración

	errorlevel	 -302	;Deshabilita mensajes de advertencia por cambio bancos	
	CBLOCK	0X020
	contador
	cuatro
	count
	count2
	count3
	nivel
	flag_nivel
	ENDC
	;PROGRAMA
	ORG		0x00		;Vector de RESET
	GOTO	MAIN
	ORG		0X04

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

	CLRF		TRISD		; PORTD,0 declarado como entrada


	
INICIALIZACION	      
	BANKSEL 	PORTA		; Selecciona el Bank0		
	CLRF		PORTB		; Borra latch de salida de PORTB
	CLRF		PORTC		; Borra latch de salida de PORTC
	CLRF   		PORTE		; Borra latch de salida de PORTE
	
nuevo_juego
	call retardo
	 MOVLW    b'00000001'
	MOVWF    nivel
	movlw    b'00000011'
	movwf     flag_nivel
   MOVLW    b'00000100'
	MOVWF    contador
	movWf cuatro 
	movwf   PORTD

loop 
	btfsc   	PORTA,5

	call      incre_nivel
	btfss       PORTA,7
	goto siguiente
	goto     decrementar 
siguiente

    movf    contador,w
	movwf   PORTD

	movf nivel,w
	movwf PORTE
	;call retardo
	btfsc   	PORTA,5

	call      incre_nivel
	call retardo
	btfss       PORTA,7
    goto siguiente
	goto loop

incre_nivel
	MOVLW    b'0000001'
	incf     nivel
	decfsz flag_nivel ;
	return
	movwf nivel
	movlw    b'00000011'
	movwf     flag_nivel	
	return

decrementar
	MOVLW    b'00000101'; le coloco cinco porque en la otra linea lo decrementa mostrando 4
	call retardo
	Decfsz    contador
	goto siguiente
	movwf     contador
	goto vida_0


vida_0
    MOVLW    b'00000000'
	MOVWF		PORTD	
					; Presenta 0 en el DISPLAY
 	;MOVLW    b'00000001'
	movwf     PORTE 
	btfss PORTA,7
	goto vida_0
	goto nuevo_juego

;-----------------------------SUBRUTINAS DE RETARDOS----------------------------;*
retardo
 		movlw 0x1
       movwf count3
ciclo3 movlw d'100' 			;1 (CI) ,donde M=20
       movwf count2		;1 (CI) 
ciclo2 movlw d'100'			;1 (CI),donde N=255
       movwf count		;1 (CI)
ciclo decfsz count,f  	;1*(N-1) +2  (CI)
      goto ciclo 		;2*(N-1)     (CI)
      decfsz count2,f 	;1*(M-1) +2   (CI)
      goto ciclo2  		;2*(M-1)     (CI)
      decfsz count3,f
      goto ciclo3 

return

vida_2
	MOVLW    b'00000010'
	MOVWF		PORTD			; Presenta 2 en el DISPLAY
	goto vida_2

vida_3
	MOVLW    b'00000011'
	MOVWF		PORTD			; Presenta 3 en el DISPLAY
	goto vida_3





	End 