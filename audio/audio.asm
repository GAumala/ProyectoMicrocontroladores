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
	tempTMR0        ;almacena el valor inicial del TMR0	
        count1
        count2
        count3
    ENDC							

;PROGRAMA
    ORG		0x00		;Vector de RESET
    GOTO	MAIN
    ORG		0X04
    GOTO	INTER

;-----------------------------Interrupciones----------------------------------;*

INTER 	                        ; Interrupcion de sonido
    BTFSC       INTCON,T0IF     ; se desbordo TMR0?
    GOTO        INTTMR0	        ; Si
    RETFIE

; EL sonido se produce al enviar 1's y 0's al SOUNDER a una frecuencia 
; determinada

INTTMR0			        ; SRI usado para sonido	
    BCF	        INTCON, T0IF    ; borro la bandera
    BTFSC       PORTE, 0	; hay un 1
    GOTO        hacer0	        ; si
    BSF	        PORTE, 0	; hacer 1
    MOVF        tempTMR0, w		
    MOVWF       TMR0	        ; cargo al TMR0
    RETFIE

hacer0
    BCF	        PORTE,0	        ; hacer 0
    MOVF        tempTMR0, w		
    MOVWF       TMR0	        ; cargo TMR0
    RETFIE
;------------------------------SUBRUTINAS MUSICALES----------------------------*
;-------------------------------------nota do---------------------------------;*
DO									
    MOVLW	0X11							
    MOVWF	TMR0						
    MOVWF	tempTMR0				
    RETURN					
;-------------------------------------nota re---------------------------------;*
RE				
	MOVLW	0X2C			
	MOVWF	TMR0	
	MOVWF	tempTMR0	
	RETURN		
;-------------------------------------nota mi---------------------------------;*
MI								
	MOVLW	0X42					
	MOVWF	TMR0				
	MOVWF	tempTMR0		
	RETURN			
;-------------------------------------nota fa---------------------------------;*
FA														
	MOVLW	0X4D											
	MOVWF	TMR0										
	MOVWF	tempTMR0								
	RETURN									
;------------------------------------nota sol---------------------------------;*
SOL										
	MOVLW	0X60							
	MOVWF	TMR0						
	MOVWF	tempTMR0				
	RETURN					
;-------------------------------------nota la---------------------------------;*
LA					
	MOVLW	0X72		
	MOVWF	TMR0	
	MOVWF	tempTMR0
	RETURN	
;-------------------------------------nota si---------------------------------;*
SI								
	MOVLW	0X82					
	MOVWF	TMR0				
	MOVWF	tempTMR0		
	RETURN			
;----------------------------------nota do agudo------------------------------;*
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

retardo
        movlw 0x1       ;este numero controla la duracion del retardo
        movwf count3
ciclo3  movlw d'50'    ;1 (CI) ,donde M=20
        movwf count2    ;1 (CI) 
ciclo2  movlw d'50'    ;1 (CI),donde N=255
        movwf count1     ;1 (CI)
ciclo   decfsz count1,f  ;1*(N-1) +2  (CI)
        goto ciclo      ;2*(N-1)     (CI)
        decfsz count2,f ;1*(M-1) +2   (CI)
        goto ciclo2     ;2*(M-1)     (CI)
        decfsz count3,f
        goto ciclo3 

return
;si sumamos lo que tarda cada instruccion seria [(3N+1)M+3M+1 ]
;queremos un retardo de 15289,02us, dando valores M Y N
;la frecuencia es de 4MHZ entonces el CI= 1us
;el (ciclo)se demorara 766us  (contando con la el mov de w al counter)
; Codigo para sonido por notas


;*******************************CODIGO PRINCIPAL********************************

;------------------------inicializacion de registros SFR----------------------;*
MAIN								

    BANKSEL 	OPTION_REG			
    MOVLW       0X01
    MOVWF       OPTION_REG      ;SE LE ASIGNA EL PRESCALADOR 1:4 AL TMR0 

    banksel	TRISB		; Selects bank containing register TRISB
    clrf        TRISB		; All port B pins are configured as outputs                 

												
    BANKSEL     ANSEL								
    CLRF        ANSEL   ; configura puertos con entradas digitales
    CLRF        ANSELH	; configura puertos con entradas digitales
    banksel     TRISA
    MOVLW       b'00000011'
    MOVWF       TRISA

    BCF     STATUS,RP0		;regresa al banco cero		


LOOP
    BSF	        INTCON,T0IE						
    ;CALL       sol							
    ;CALL       retardo								
    ;CALL       mi									
    ;CALL       retardo										
    ;CALL       do											
    ;CALL       retardo												

    CALL        mi				
    CALL        retardo					
    CALL        retardo						
    CALL        retardo					
    CALL        retardo					
    CALL        retardo						
    CALL        retardo						
    CALL        do							
    CALL        retardo								
    CALL        retardo					
    CALL        retardo					
    CALL        retardo						
    CALL        retardo						
    CALL        retardo									
    CALL        mi										
    CALL        retardo											
    CALL        retardo					
    CALL        retardo					
    CALL        retardo						
    CALL        retardo						
    CALL        retardo												
    CALL        do													
    CALL        retardo	
    CALL        retardo		
    CALL        retardo				
    CALL        retardo			
    CALL        retardo						
    CALL        retardo					
    CALL        retardo							
    CALL        retardo								
    CALL        retardo	
    CALL        retardo		
    CALL        retardo				
    CALL        retardo			
    CALL        retardo						
    CALL        retardo					
    CALL        retardo							
    CALL        retardo								
    CALL        retardo	
    CALL        retardo		
    CALL        retardo				
    CALL        retardo			
    CALL        retardo						
    CALL        retardo					
    CALL        retardo							
    CALL        retardo								



    BCF	        INTCON,T0IE									
    GOTO        LOOP										

END
