## Enunciado del Programa

Este proyecto es una implementación del popular juego de
video **Racer** en lenguaje ensamblador con microcontroladores PIC16F887.

![Poster Racer](speed_racer_poster.jpg)

El juego consiste en controlar un pequeño vehículo en una pista de dos carriles
esquivando los demás vehículos. Si el jugador toca algún otro vehículo
automáticamente pierde una vida. El juego empieza con un máximo de cinco vidas.
Mientras más vehículos esquiva, la dificultad del juego va incrementando. 

El hardware del juego consiste en 3 microcontroladores PIC16F887, 3 botones, 2
displays de 7 segmentos y un parlante. Existe un pic principal que controla a 
los otros dos, además de las matrices de puntos. Los otros dos tienen tareas más
específicas, controlar los displays y el parlante. 

El programa principal periódicamente cambia la imagen mostrada en la matriz de
puntos en base a: el estado actual del juego y los botones que presiona el
jugador. A través de interrupciones, durante ciertos eventos, se activan los
otros pic para generar effectos de sonido y cambiar los valores mostrados en los
display.

## Diagrama de Bloques

![Diagrama Bloques](diagrama_bloques.jpeg)

## Diagrama de Flujo

![Diagrama Main](diagramas/diagrama_main.png)

![Diagrama 1](diagramas/diagrama1.png)

![Diagrama 2](diagramas/diagrama2.png)

![Diagrama 3](diagramas/diagrama3.png)

![Diagrama 4](diagramas/diagrama4.png)

![Diagrama 5](diagramas/diagrama5.png)

![Diagrama 6](diagramas/diagrama6.png)


## Descripción del algoritmo o estrategia utilizada

La estrategia principal consiste en dividir el problema en 3 partes, cada pic se
enfoca en una parte. Hay un pic para los efectos de sonido, otro pic para
mostrar datos en el display, y otro que contiene el estado del juego y controla
la matriz de puntos. El programa principal sigue estos pasos:

1) Declara las variables a utilizar en `CBLOCK`, setea los modos de operación de
cada puerto y configura los registros de interrupciones.
2) inicializa variables que controlan el estado de la matriz de puntos y otras mas
que contienen el estado del juego.
3) En cada iteración del lazo infinito llena la matriz de led en base al estado
actual de las variables declaradas en `CBLOCK` y se cambia la posicion del
jugador en una unidad. 
4) Con las interrupciones generadas por los botones cambian las variables de
estado del juego.  durante ciertos eventos, se activan los otros pic para 
generar efectos de sonido o modificar los display.

## Programa del PIC16F887

### Programa Principal

```armasm

;***********************************ENCABEZADO************************************
;-----------------------------Configuracion inicial-----------------------------;*
	LIST		p=16F887		;Tipo de microcontrolador						;*
	INCLUDE 	P16F887.INC		;Define los SFRs y bits del P16F887				;*
																				;*
	__CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_INTOSCIO								;*
	errorlevel	 -302			;Deshabilita mensajes de advertencia por cambio ;*
								;bancos											;*
;----------------------------Declaracion de variables---------------------------;*
	CBLOCK	0X20																;*
	tempTMR0					;almacena el valor inicial del TMR0				;*
	fila 					;registro que indica la columna a mostrar		;*
    desp0
	desp						;indica el desplazamiento dentro de la tabla	;*
	dieciseis
    ocho						;Variable usada para obtener hasta maximo 8		;*
								;valores de la tabla para mostrar en la matriz	;*
	temp						;Determina el retardo entre los carros			;*
	d1							;Variables para los retardos 	

		counta				;	used in the delay routines
		countb 				;	used in the delay routines
		pc_track			;	this is our track data program counter
		pc_end_graphics		;	this is our end graphics program counter
		vram_0
		vram_1				;	a video ram location
		vram_2				;	a video ram location
		vram_3				;	a video ram location
		vram_4				;	a video ram location
		vram_5				;	a video ram location
		vram_6				;	a video ram location
		vram_7				;	a video ram location
		vram_8				;	a video ram location
	
		vram_9				;	a video ram location
		vram_10				;	a video ram location
		vram_11				;	a video ram location
		vram_12				;	a video ram location
		vram_13				;	a video ram location
		vram_14				;	a video ram location
		vram_15				;	a video ram location
		vram_16				;	a video ram location	
        vram_17
		comp_vram_17
		comp_vram_16
		comp_vram_15
		comp_vram_14
		comp_vram_13

		vtemp_1				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_2				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_3				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_4				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_5				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_6				;	a temporary video ram location (used when tranfering vram data to the next vram location)
		vtemp_7				;	a temporary video ram location (used when tranfering vram data to the next vram location)
	    vtemp_8	
		vtemp_9	
	    vtemp_10	
		vtemp_11
	    vtemp_12
		vtemp_13
	    vtemp_14
		vtemp_15
	    vtemp_16	
		datocarro1
		datocarro2
		datocarro3
		datocarro4
		comp_datocarro1
		comp_datocarro2
		comp_datocarro3
		comp_datocarro4
	repeat_frame		;	used to determine how many times we will be repeating each 'frame'
		car_data			;	we need to know where the car is on the screen, this variable holds that data
		button_timer		;	used to help in slowing down the button repeat rate (it prevents the car from moving many times for one button press)
		button_adjust		;	used to help in slowing down the button repeat rate (it prevents the car from moving many times for one button press)
		stop_repeat			;	used to help in slowing down the button repeat rate (it prevents the car from moving many times for one button press)
		level				;	a variable to hold the level data (so we know what level we are on)
		speed				;	we set the initial speed in the setup routine (this determines how fast the car is going)
		end_hold			;	used to prevent us from pushing a button at the end for a specified amount of time
						;	end of general purpose registers				;*
		count_carro
		count
		count2
		count3
		delay_1	
		delay_2		
		const_acelerar
		numero1
		numero2
		flag_inter
		count_vida
		speed2   ; guardamos las velocidad con que estamos trabajando													;*
	ENDC																		;*
;-----------------------------INICIO DEL PROGRAMA-------------------------------;*
	ORG 	0x00			; Comienzo del programa (Vector de Reset)			;*
	GOTO	MAIN
	Org 0x04 ; vector de interrupción
	Goto inter ; salto a interrupción
	org 0x05 ; continuación de programa																;*
															;*
;-----------------------------------TABLAS--------------------------------------;*

PISTA2
	incf pc_track, f		;	increment pc_track by one and then
	movf pc_track, w	
	ADDWF   PCL,F

	;carros (01)(10)	(desp=32)
	retlw b'01111110'; Ahora cada vez que se llama a esta rutina, agarraremos la
	retlw b'11111111'; Siguiente byte sucesivo de datos!
	retlw b'01111110'; Esto significa que la pantalla se desplazará de arriba a abajo
	retlw b'01111110'
	retlw b'11111111'
	retlw b'01111110'
	retlw b'01111110'
	retlw b'11111111'

;esta es la salida del segundo carro a la izquierda
	retlw b'00101110'
	retlw b'01011110'
	retlw b'10001111'
	retlw b'01011110'




	
	retlw b'01111110'; 
	retlw b'11111111'
	retlw b'01111110'; 


    retlw b'01111110'; Ahora cada vez que se llama a esta rutina, agarraremos la
	retlw b'11111111';
	retlw b'01111110'; Siguiente byte sucesivo de datos!
	retlw b'01111110'
	retlw b'11111111'; 
	;retlw b'01111110'
	
;esta es la salida del segundo carro por derecha
	;retlw b'01111110'
	retlw b'11110101'
	retlw b'01111010'	
	retlw b'11110001'
	retlw b'11111011'


	decfsz count_carro
	goto $+2

	call aumentar_nivel

	Movlw .1 ; Y ahora restablecer nuestra pc_track variable para que podamos
	Movwf pc_track; Dibujar la pista de nuevo desde el principio
	Retlw b'01111110'; Y volver a donde venimos con la primera parte de nuestra pista.													;*




;*******************************CODIGO PRINCIPAL**********************************
;------------------------inicializacion de registros SFR------------------------;*
MAIN																			;*
	banksel	TRISC		; Selects bank containing register TRISB
	clrf		TRISC		; All port B pins are configured as outputs                 
	banksel	TRISD		; Selects bank containing register TRISB
	clrf		TRISD		; All port B pins are configured as outputs   
	banksel	TRISE		; Selects bank containing register TRISB
    MOVLW b'111'
	MOVWF		TRISE  ; selecciono el puerto e como salida
						;*
	BANKSEL		ANSEL															;*
	CLRF		ANSEL			; configura puertos con entradas digitales		;*
	CLRF		ANSELH			; configura puertos con entradas digitales		;*
	banksel TRISA
    clrf		TRISA
    BANKSEL     TRISB
	movlw       b'00000001'
	movwf        TRISB
	BANKSEL 	PORTB															;*

    movlw b'11111111'
    movwf       PORTC															;*
	CLRF        PORTB														;*
	CLRF		PORTD
	CLRF		PORTA
    CLRF        PORTE															;*
;------habilitar las interrupcion externa por bit 0 del puerto b

	movlw b'10110000' ;habilita interrupción por Timer 0 y Global
	; GIE=1 (BIT 7); habilita interrupciones globales
	; TMR0IE=1 (BIT 5); habilita interrupciones por TMR0
	;INTE=1 (BIT 4); habilita interrupciones por RB0
	movwf INTCON

																					;*

	BCF			STATUS,RP0		;regresa al banco cero							;*
;--------------------------inicializacion de variables--------------------------;*
inicio 
	
	call retardo
	Bsf   PORTB,1
    movlw .0
    movwf ocho
	movlw b'01111110'
	movwf vram_0   

	movlw b'01111110'
	movwf vram_1				;	
	movwf vram_2				;	
   
	 movlw b'11111111'
	movwf vram_3
   
	 movlw b'01111110'				;	
	movwf  vram_4				;	
	movwf vram_5
  
 	movlw b'11111111'				;	
	movwf vram_6				;	....
	
	movlw b'01111110'
	movwf vram_7				;	....
	movwf vram_8
	
	movlw b'11111111'				;	....
	movwf vram_9

	movlw b'01111110'			
	movwf vram_10				;	....
	movwf vram_11

	movlw b'11111111'				;	....
	movwf vram_12	

   movlw b'01111110'		;	....
	movwf vram_13			;	....
	movwf vram_14

	movlw b'11111111'			;	....
	movwf vram_15

   movlw b'01111110'				;	....
	movwf vram_16			;	....
	
	clrf pc_track			;	clear pc_track (so we start from the top of this data)
    movlw d'01'				;	setup our level counter (start from level
	movwf level				;	one of course...)
	movlw d'17'				;	setup our game scrolling speed.
	movwf speed				;	(the higher the number, the slower the scroll speed)
	movlw d'50'				;	this prevents us from pushing a button to reset the game straight
	movwf end_hold			;	away - which allows you to see your score beforehand
	movlw .255
	movwf ocho
	movlw .7
	movwf const_acelerar
	movlw d'17'				;	setup our game scrolling speed.
	movwf speed2				;	(the higher the number, the slower the scroll speed)
	movlw  .4
	
	movwf count_carro   ; contador de carro
	movlw .3
	movwf count_vida
	clrf flag_inter
	movlw b'11111011'
	movwf	datocarro1
	movlw b'11110001'
	movwf	datocarro2
	movlw b'11111011'
	movwf	datocarro3
	movlw b'11110101' 
	movwf	datocarro4
LOOP 
   call dibujar
   call fill_vram

   goto LOOP
;---------------------------------lazo infinito---------------------------------;*
;Si PORTB=0xFF entonces ningun switch esta activado y no hace nada				;*
;Sino verfica cual bit esta en cero y salta a la subrutina correspondiente		;*
dibujar			

	movf speed, w					;	We need to set the speed that our game is running at,
	movwf repeat_frame				;	so we grab that data from speed and copy it to our frame_rate			

	BTFSC flag_inter,0  ; me ayuda a generar el sonido del aumento de velocidad , es cero? continuo
	Bsf   PORTB,2   ; si es uno la bandera genero del sonido

	lazo	
			

				movlw b'00000000'
				movwf PORTA
                
				movf vram_1, w	
       				;	
				movwf PORTC				;	copia lo que en la pista en el puerto C
				call delay			;	Call the delay (to hold that one row ON for a split second)
          
          		 movlw b'11111111'
           		movwf PORTC
;...................................................................................
				movlw b'00000001'
				movwf PORTA
                
				movf vram_2, w	
       				;	
				movwf PORTC				;	copia lo que en la pista en el puerto C
				call delay			;	Call the delay (to hold that one row ON for a split second)
          
         		movlw b'11111111'
         	    movwf PORTC	
;...................................................................................									
				movlw b'00000010'
				movwf PORTA
                ;movlw b'00000010'
				movf vram_3, w	

		;	
				movwf PORTC				;	copia lo que en la pista en el puerto C				;					;	
				call delay						;
	 			movlw b'11111111'
       	  		  movwf PORTC
;...................................................................................										
				movlw b'00000011'
				movwf PORTA
                ;movlw b'00000100'
				movf vram_4, w					;
				movwf PORTC				
				call delay						;
	            ;MOVF  desp,W								
				;CALL  PISTA				
				;movwf PORTC	
 				movlw b'11111111'
        	   movwf PORTC
	
;...................................................................................							
				movlw b'00000100'
				movwf PORTA
               ;movlw b'00001000'
				movf vram_5, w	
				movwf PORTC		
				call delay						;	
 				movlw b'11111111'
          		 movwf PORTC
;...................................................................................										
				movlw b'00000101'
				movwf PORTA
                ;movlw b'00010000'
                
				movf vram_6, w				
				movwf PORTC							;
				call delay						;
	 			movlw b'11111111'
         		movwf PORTC
;...................................................................................										
				movlw b'00000110'
				movwf PORTA
				;movlw b'00100000'
				movf vram_7, w					;			
				movwf PORTC					;	
				call delay						;	
	 			movlw b'11111111'
         		movwf PORTC	
;...................................................................................										
				movlw b'00000111'
				movwf PORTA
				;movlw b'01000000'
				movf vram_8, w					;			
				movwf PORTC						;
				call delay						;
	 			movlw b'11111111'
         		movwf PORTC
									
;-----------------------------llamada del carro-------------------------------;*
				call verificar_carro
																			;*
																				;*
;-------------------------------------------------------------------------;*		
				movlw b'00001000'
				movwf PORTA



				;movlw b'10000000'
				movf vram_9, w					;			
				movwf PORTD		
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD

                
  ;________________________________________
            	movlw b'00001001'
				movwf PORTA



				;movlw b'00000001'
				movf vram_10, w					;			
				movwf PORTD	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD
;_________________________________________
            	movlw b'00001010'
				movwf PORTA



				;movlw b'00000010'
				movf vram_11, w		
				movwf PORTD		;	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD
;____________________________________________
            	movlw b'00001011'
				movwf PORTA



				;movlw b'00000100'
				movf vram_12, w					;			
				movwf PORTD			;	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD
;_________________________________________________
            	movlw b'00001100'
				movwf PORTA


				movf	datocarro1,w
                movwf PORTD
				call delay

				;movlw b'00001000'
				movf vram_13, w					;			
				movwf PORTD				;	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD
;_______________________________________________
            	movlw b'00001101'
				movwf PORTA


				movf	datocarro2,w
                movwf PORTD
				call delay

				;movlw b'00000001'
				movf vram_14, w					;	
			
				movwf PORTD					;	
				call delay					;	
				clrf PORTB
	 			movlw b'11111111'
         		movwf PORTD
;_______________________________________________
            	movlw b'00001110'
				movwf PORTA


				movf	datocarro3,w
                movwf PORTD
				call delay

				;movlw b'01000000'
				movf vram_15, w					;	
				movwf PORTD				;	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD

;____________________________________________________
            	movlw b'00001111'
				movwf PORTA

				movf	datocarro4,w
                movwf PORTD
				call delay
                ;movlw .0
                ;movwf ocho   ; importante (reseteo el valor de la constante

				movlw b'10000000'
				movf vram_16, w					;				
				movwf PORTD			;	
				call delay					;	
	 			movlw b'11111111'
         		movwf PORTD
;-----------------------------chequeamos si hay colision-------------------------------;*
				call check_colision
 
              decfsz repeat_frame	;	then decrease repeat_frame by one, 
		       goto lazo			;	if its not zero then draw it all again!
			   return


volver_pantalla
;--------------------PANTALLA CON ENCENDIDO LOS LED-----
				movlw b'00000000'
				movwf PORTA

				movlw b'00000000'
       				;	
				movwf PORTC				;	copia el codigo para prender las luces en el puerto C
				call retardo			;	Call the delay (to hold that one row ON for a split second)
          		movlw b'11111111'
         	    movwf PORTC	         
 
;..................................................
				movlw b'00000001'
				movwf PORTA

				movlw b'00000000'
       				;	
				movwf PORTC				;	copia lo que en la pista en el puerto C
				call retardo			;	Call the delay (to hold that one row ON for a split second)       
         		movlw b'11111111'
         	    movwf PORTC	

;...................................................									
				movlw b'00000010'
				movwf PORTA

				movlw b'00000000'
				movwf PORTC				;	copia lo que en la pista en el puerto C				;					;	
				call retardo						;
	 			movlw b'11111111'
       	  		  movwf PORTC
;.....................................										
				movlw b'00000011'
				movwf PORTA

				movlw b'00000000'

				movwf PORTC				
				call retardo						;

 				movlw b'11111111'
        	   movwf PORTC
	
;.........................							
				movlw b'00000100'
				movwf PORTA

				movlw b'00000000'

				movwf PORTC		
				call retardo						;	
 				movlw b'11111111'
          		 movwf PORTC
;.....................................										
				movlw b'00000101'
				movwf PORTA

				movlw b'00000000'		
				movwf PORTC							;
				call retardo						;
	 			movlw b'11111111'
         		movwf PORTC
;...................................										
				movlw b'00000110'
				movwf PORTA
	
				movlw b'00000000'				;			
				movwf PORTC					;	
				call retardo						;	
	 			movlw b'11111111'
         		movwf PORTC	
										
				movlw b'00000111'
				movwf PORTA
				movlw b'00000000'				;			
				movwf PORTC						;
				call retardo						;
	 			movlw b'11111111'
         		movwf PORTC

;-------------------------------------------------------------------------;*		
				movlw b'00001000'
				movwf PORTA

				movlw b'00000000'				;			
				movwf PORTD		
				call retardo					;	
	 			movlw b'11111111'
         		movwf PORTD

                
  ;________________________________________
            	movlw b'00001001'
				movwf PORTA

				movlw b'00000000'			;			
				movwf PORTD	
				call retardo					;	
	 			movlw b'11111111'
         		movwf PORTD
;_________________________________________
            	movlw b'00001010'
				movwf PORTA

				movlw b'00000000'	
				movwf PORTD		;	
				call retardo					;	
	 			movlw b'11111111'
         		movwf PORTD
;____________________________________________
            	movlw b'00001011'
				movwf PORTA

				movlw b'00000000'		;			
				movwf PORTD			;	
				call retardo					;	
	 			movlw b'11111111'
         		movwf PORTD
;_________________________________________________
            	movlw b'00001100'
				movwf PORTA

				movlw b'00000000'				;			
				movwf PORTD				;	
				call retardo					;	
	 			movlw b'11111111'
         		movwf PORTD
;_______________________________________________
            	movlw b'00001101'
				movwf PORTA
				;call end_data

				;movlw b'00000000'				;	
			
				movwf PORTD					;	
				call retardo				;	

	 			movlw b'11111111'
         		movwf PORTD
;_______________________________________________
            	movlw b'00001110'
				movwf PORTA
				;call end_data
				movlw b'00000000'			;	
				movwf PORTD				;	
				call retardo					;	
	 			;movlw b'11111111'
         		movwf PORTD

;____________________________________________________
            	movlw b'11001111'
				movwf PORTA
				;call end_data				
				movlw b'00000000'			;				
				movwf PORTD			;	
				call retardo					;	
	 			;movlw b'11111111'
         		movwf PORTD


goto inicio



verificar_carro

;-----verificar el boton de mover a la derecha
pulsado
	BTFSS	PORTE,1			; espero que presione boton
	GOTO 	sig_boton
	GOTO 	pulsado2
pulsado2
	BTFSC 	PORTE,1			; espero a que suelte boton
	GOTO 	pulsado2
	call	go_right
sig_boton
;-----verificar el boton de mover a la izquierda
pulsado3
	BTFSS	PORTE,2			; espero que presione boton
	GOTO 	continuar
	GOTO 	pulsado4
pulsado4
	BTFSC 	PORTE,2			; espero a que suelte boton
	GOTO 	pulsado4
	call	go_left

continuar
	return					;	and finally, return back to the main program!

inter

		movf const_acelerar, w					;	We need to set the speed that our game is running at,
	movwf speed				;	so we grab that data from speed and copy it to our frame_rate			
	bsf flag_inter,0

	Bsf   PORTB,2
	bcf INTCON,INTF  ;
	retfie ; Return from interrupt routine

aumentar_nivel
	bcf STATUS,0
	rlf level, 1;	now we have made it to the next level
	movlw  .4
	movwf count_carro   ; contador de carro	
	bsf PORTA,5
	call retardo
	btfsc level, 3		;	have we reached the end of the game yet? if yes then:
	goto volver_pantalla
	decf speed, 1

	return

go_right  ;me guarda los datos de la nueva posicion del carro a la derecha
	
	movlw b'11111011'
	movwf	datocarro1
	movlw b'11110001'
	movwf	datocarro2
	movlw b'11111011'
	movwf	datocarro3
	movlw b'11110101' 
	movwf	datocarro4
	BTFSS	level,1
	movlw .17	
	BTFSS	level,2
	movlw .16	
	BTFSS	level,3
	movlw .15	
	movwf speed				;	setup our game scrolling speed.
	clrf flag_inter
return

go_left; me guarda los datos de la nueva posicion del carro a la izquierda
	movlw b'11011111'
	movwf	datocarro1
	movlw b'10001111'
	movwf	datocarro2
	movlw b'11011111'
	movwf	datocarro3
	movlw b'10101111' 
	movwf	datocarro4

	BTFSS	level,1
	movlw .17	
	BTFSS	level,2
	movlw .16	
	BTFSS	level,3
	movlw .15	
	movwf speed				
	clrf flag_inter
	return

check_colision
	bcf STATUS, Z	
	comf vram_16,w
	movwf	comp_vram_16				;	Here we are going to check if we have hit a wall or not...
	comf  datocarro1,w				;	
	andwf comp_vram_16, w			;	then and our car_data with vram_8
	btfss STATUS, Z			;	If the answer is NOT zero (status bit is NOT set) then -	
	goto chocado			;	goto chocado routine

	comf vram_15,w
	movwf	comp_vram_15			
	comf  datocarro2,w
	andwf comp_vram_15, w			;	then and our car_data with vram_8
	btfss STATUS, Z			;	If the answer is NOT zero (status bit is NOT set) then -	
	goto chocado			;	goto chocado routine


	comf vram_14,w
	movwf	comp_vram_14			
	comf  datocarro3,w
	andwf comp_vram_14, w			;	then and our car_data with vram_8
	btfss STATUS, Z			;	If the answer is NOT zero (status bit is NOT set) then -	
	goto chocado			;	goto chocado routine

	comf vram_13,w
	movwf	comp_vram_13			
	comf  datocarro4,w
	andwf comp_vram_13, w			;	then and our car_data with vram_8
	btfss STATUS, Z			;	If the answer is NOT zero (status bit is NOT set) then -	
	goto chocado			;	goto chocado routine

	return					;	otherwise, just return from where we came from...


chocado						;	We come here if we have hit a wall or we complete the game
	call retardo
	Bsf   PORTB,3

	goto volver_pantalla


loop3
	nop
	goto loop3


fill_vram
		movf vram_1, 0		;	Copy vram_1 into vtemp_1 to use as a backup
		movwf vtemp_1		;	storage location. (just before we overwrite vram_1)
		movf vram_2, 0		;	Copy vram_1 into vtemp_2 to use as a backup
		movwf vtemp_2		;	storage location. (just before we overwrite vram_2)
		movf vram_3, 0		;	Copy vram_1 into vtemp_3 to use as a backup
		movwf vtemp_3		;	storage location. (just before we overwrite vram_3)
		movf vram_4, 0		;	Copy vram_1 into vtemp_4 to use as a backup
		movwf vtemp_4		;	storage location. (just before we overwrite vram_4)
		movf vram_5, 0		;	Copy vram_1 into vtemp_5 to use as a backup
		movwf vtemp_5		;	storage location. (just before we overwrite vram_5)
		movf vram_6, 0		;	Copy vram_1 into vtemp_6 to use as a backup
		movwf vtemp_6		;	storage location. (just before we overwrite vram_6)
		movf vram_7, 0		;	Copy vram_7 into vtemp_7 to use as a backup
		movwf vtemp_7		;	storage location. (just before we overwrite vram_7)
		movf vram_8, 0		
		movwf vtemp_8
		movf vram_9, 0		
		movwf vtemp_9
		movf vram_10, 0		
		movwf vtemp_10
		movf vram_11, 0		
		movwf vtemp_11
		movf vram_12,0		
		movwf vtemp_12
		movf vram_13, 0		
		movwf vtemp_13
		movf vram_14, 0		
		movwf vtemp_14
		movf vram_15, 0		
		movwf vtemp_15
		movf vram_16, 0		
		movwf vtemp_16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																	;
;	Did you notice that we don't need to make a backup of vram_8?	;
;	That's because there are only 8 lines on the screen. So after 	;
;	we display the 8th line, it is then shifted out of the screen.	;
;																	;
;	Now that we have backed up our old vram data, we then need to	;
;	copy them to the next successive vram location - this basically	;
;	shifts everything on the screen down one space. It also grabs	;
;	a brand new byte of data and copies it into vram_1 (which		;
;	means it will be displayed at the top of the screen, before		;
;	It gets shifted again...										;
;																	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		call PISTA2	;	Call track_data routine and return with a byte of data in the w register
		movwf vram_1		;	then copy the new byte of data to the first vram location
		movf vtemp_1, 0		;	copy what was in vram_1 into vram_2 (remember how we made
		movwf vram_2		;	a backup of vram_1 and called it vtemp_1.)
		movf vtemp_2, 0		;	copy what was in vram_2 into vram_3 (remember how we made
		movwf vram_3		;	a backup of vram_2 and called it vtemp_2.)
		movf vtemp_3, 0		;	copy what was in vram_3 into vram_4 (remember how we made
		movwf vram_4		;	a backup of vram_3 and called it vtemp_3.)
		movf vtemp_4, 0		;	copy what was in vram_4 into vram_5 (remember how we made
		movwf vram_5		;	a backup of vram_4 and called it vtemp_4.)
		movf vtemp_5, 0		;	copy what was in vram_5 into vram_6 (remember how we made
		movwf vram_6		;	a backup of vram_5 and called it vtemp_5.)
		movf vtemp_6, 0		;	copy what was in vram_6 into vram_7 (remember how we made
		movwf vram_7		;	a backup of vram_6 and called it vtemp_6.)
		movf vtemp_7, 0		;	copy what was in vram_7 into vram_8 (remember how we made
		movwf vram_8		;	a backup of vram_7 and called it vtemp_7.)
		movf vtemp_8, 0	
		movwf vram_9		;	
		movf vtemp_9, 0	
		movwf vram_10		;
		movf vtemp_10, 0	
		movwf vram_11		;	
		movf vtemp_11, 0	
		movwf vram_12		;	
		movf vtemp_12, 0	
		movwf vram_13		;
		movf vtemp_13, 0	
		movwf vram_14		;	
		movf vtemp_14, 0	
		movwf vram_15		;	
		movf vtemp_15, 0	
		movwf vram_16		;


	
		return					;	Now that we're all done here, go back to our main program.

;***********************************SUBRUTINAS************************************
;-----------------------------SUBRUTINAS DE RETARDOS----------------------------;*
;----------------------------------retardo 1 ms---------------------------------;*
delay1ms																		;*
	MOVLW		.249															;*
	MOVWF		d1																;*
loop1ms																			;*
	NOP																			;*
	DECFSZ		d1,F															;*
	GOTO		loop1ms															;*
	RETURN		
;-----------------------------SUBRUTINAS PARA MATRIZ----------------------------;*
;--------------------------------carros estaticos -------------------------------;*


delay									;	This first delay is a rather fast one.
	movlw d'03'					;	You can make the delay longer by
	movwf counta				;	increasing the decimal value. Or you
	movwf countb				;	can make the delay shorter by decreasing
	again	decfsz counta, 1				;	the decimal value.
			goto again					;
			decfsz countb, 1			;
			goto again					;	once counta and countb have reached zero
	return								;	it will return to the main program
		
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

	END	
;_-------------
			
```

### Programa para efectos de sonido

``` armasm
    LIST    p=16F887	;Tipo de microcontrolador
    INCLUDE P16F887.INC	;Define los SFRs y bits del P16F887

    ;Setea parámetros de configuración
    __CONFIG _CONFIG1, _CP_OFF&_WDT_OFF&_XT_OSC 

    ;Deshabilita mensajes de advertencia por cambio bancos	
    errorlevel	 -302	

    CBLOCK	0X020
    DATO		; Señal de entrada por bit
    VECES		; Cuantas veces se presenta la señal			
    tempTMR0	        ;  variable para realizar retardo en el sonido
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

;******************************************************************************

    ;PROGRAMA
    ORG		0x00		;Vector de RESET
    GOTO	MAIN
    ORG		0X04
    GOTO	INTER

    INTER 	; Interrupcion de sonido
        BTFSC		INTCON,T0IF  ; se desbordo TMR0?
        GOTO		INTTMR0			; Si
        RETFIE

; EL sonido se produce al enviar 1's y 0's al SOUNDER 
; a una frecuencia determinada

    INTTMR0			; SRI usado para sonido	
        BCF	INTCON,T0IF     ; borro la bandera
        BTFSC   PORTE,2	        ; hay un 1
        GOTO    hacer0	        ; si
        BSF     PORTE,2	        ; hacer 1
        MOVF    tempTMR0,w		
        MOVWF   TMR0	        ; cargo al TMR0
        RETFIE
    hacer0
        BCF     PORTE,2	        ; hacer 0
        MOVF    tempTMR0,w		
        MOVWF   TMR0	        ; cargo TMR0
        RETFIE
        
    retardo
           movlw 0x1
           movwf count3
    ciclo3 movlw d'170'         ;1 (CI) ,donde M=20
           movwf count2		;1 (CI) 
    ciclo2 movlw d'170'	        ;1 (CI),donde N=255
           movwf count		;1 (CI)
    ciclo  decfsz count,f  	;1*(N-1) +2  (CI)
           goto ciclo 		;2*(N-1)     (CI)
           decfsz count2,f 	;1*(M-1) +2   (CI)
           goto ciclo2          ;2*(M-1)     (CI)
           decfsz count3,f
           goto ciclo3 

    return

    semiretardo
           movlw 0x1
           movwf count3
    ciclo6 movlw d'90' 	        ;1 (CI) ,donde M=20
           movwf count2		;1 (CI) 
    ciclo5 movlw d'90'	        ;1 (CI),donde N=255
           movwf count		;1 (CI)
    ciclo4 decfsz count,f  	;1*(N-1) +2  (CI)
           goto ciclo4 		;2*(N-1)     (CI)
           decfsz count2,f 	;1*(M-1) +2   (CI)
           goto ciclo5          ;2*(M-1)     (CI)
           decfsz count3,f
           goto ciclo6 

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
        MOVLW	0X76
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
        MOVLW	0X8C
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    do#
        MOVLW	0X93
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    re
        MOVLW	0X99
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    mi
        MOVLW	0XA5
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN
    fa
        MOVLW	0XAA
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
    mute
        MOVLW	0XFE
        MOVWF	TMR0
        MOVWF	tempTMR0
        RETURN

    SONIDO1	; Sonido para codificación RZ
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		sol	        ;carga la nota
        CALL		semiretardo	;suena la nota 1 seg
        CALL		mi
        CALL		semiretardo
        CALL		do	        ;carga la nota
        CALL		semiretardo	;suena la nota 1 seg
        CLRF		INTCON		; Deshabilita las interrupciones
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF	PORTE,2
        return

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
        CALL            mute
        CLRF		INTCON		; Deshabilita las interrupciones	
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF			PORTE,2
		return

    SONIDO3
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		re														
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		fa											
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		re								
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
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
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		retardo												
        CALL		LA					
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
        CALL            mute
        CLRF		INTCON		; Deshabilita las interrupciones	
        BANKSEL		PORTA	
        CLRF		TMR0
        BCF			PORTE,2
		return
    ;SONIDO3_WAIT
    ;    GOTO        SONIDO3_WAIT
			
    TESTNOTA
        CLRF 		TMR0
        ; Habilito interrupcion por TMR0 y las globales
        MOVLW		B'10100000'	
        MOVWF		INTCON	
        BANKSEL		PORTA
        CALL		LA														
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
;        GOTO        LOOP

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


   

loop
	BTFSC   PORTA,0
	CALL    SONIDO3
	BTFSC   PORTA,1
	CALL    SONIDO1
	BTFSC   PORTA,2
	CALL	SONIDO2
  	nop
	goto loop

END 
```

### Programa de displays

```armasm
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
```

![Diseño Proteus](circuito_proteus.png)

## Conclusiones

- En proyectos de mayor complejidad, usar más de un pic ayuda bastante a dividir
  el problema en varios problemas pequeños y poder manejar un mayor nivel de
  abstracción. Esto facilita significativamente el mantenimiento del código
  fuente del programa.
- El PIC16F887 tiene un poder de procesamiento más que suficiente para correr
  videojuegos de la década de 1970. Los videojuegos escritos en lenguaje
  de ensamblador fácilmente entran en la memoria ROM del pic. La frecuencia del
  pic es lo suficientemente rápida para leer entradas y pintar una matriz de
  puntos, incluso con los videojuegos de alta velocidad.
- El TIMER0 es efectivo para generar ondas de sonido para un parlante.
  Modificando los 8 bits de frecuencia con la que cambia el estado del bit de 
  salida pueden representar por lo menos dos octavas de notas musicales, lo cual
  es más que suficiente para melodías cortas y memorables, características de un
  videojuego.

## Recomendaciones

- En Proteus, siempre hay que revisar que los botones no se mantengan en estadio
  presionado. Uno siempre asume que al iniciar la simulación, el botón esta en
  estado abierto, pero a veces no es así, lo cual lleva a errores cuya causa 
  es difícil de detectar ya que no tiene nada que ver con la programación del 
  PIC.
- Los proyectos elaborados en Proteus 8, no pueden ser abiertos en Proteus 7. Al
  colaborar con varias personas, es necesario primero que todos se pongan de
  acuerdo en la versión de Proteus a usar.
- En MPLAB, es bueno prestar atención al log que se genera al compilar. En el
  log se pueden encontrar los comandos que corre MPLAB para compilar y enlazar
  el programa resultante. Si estos comandos son copiados a un script, se puede
  compilar el programa desde una terminal con mayor rapidez que usando la
  interfaz gráfica de MPLAB.
  
  
