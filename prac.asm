.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
clearArea_C PROTO C, value:SDWORD, value1: SDWORD
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C


TECLA_S EQU 115   ;ASCII letra s es el 115


.data          
teclaSalir DB 0




.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreenP1, getMoveP1, moveCursorP1, movContinuoP1, openP1, openContinuousP1
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, sea: BYTE, taulell: BYTE, sunk: SDWORD, indexMat: SDWORD, tocat: SDWORD
extern C rowCur: SDWORD, colCur: BYTE, rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy:
   push ebp
   mov  ebp, esp
    Push_all
   

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax,[colScreen]
   push eax
   mov eax,[rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
    Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch:
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch:
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 7 
; i convertir el char de la columna (A..H) a un número entre 0 i 7.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; rowScreen : fila on volem posicionar el cursor a la pantalla.
; colScreen : columna on volem posicionar el cursor a la pantalla.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1:
    push ebp
	mov  ebp, esp

	;Comencem aqui

	push  eax
	push  ebx
	xor  eax, eax
	mov  eax, [row] ;row assignat a eax
	dec	 eax
	shl  eax, 1
	add  eax, [rowScreenIni]
	mov  [rowScreen], eax

	xor  ebx, ebx
	mov  bl, [col] ;assignar col a ax
	sub  bl, 'A' ;passar char a numero
	shl  bl, 2
	add  ebx, [colScreenIni]
	mov  [colScreen], ebx

	call  gotoxy

	pop  ebx
	pop  eax 

	mov  esp, ebp
	pop  ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', o la tecla espai
; i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
; op: Variable que indica en quina opció del menú principal estem
; 
; Paràmetres d'entrada : 
; Cap
;    
; Paràmetres de sortida: 
; El caracter llegit s'emmagatzema a la variable carac2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMoveP1:
   push ebp
   mov  ebp, esp
   
   ;Comencem aqui

esperar:
   call  getch
   cmp   [carac2], 's'
   je    finish
   cmp   [carac2], ' '
   je	 finish
   cmp   [carac2], 'i'
   jl    esperar
   cmp   [carac2], 'l'
   jg    esperar
   jmp finish

finish:
	
   mov   esp, ebp
   pop   ebp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (rowCur) i (colCur) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, (rowCur) i (colCur) només poden 
; prendre els valors [1..8] i [0..7]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
; carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
; rowCur : fila del cursor a la matriu sea.
; colCur : columna del cursor a la matriu sea.
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorP1:
   push  ebp
   mov   ebp, esp 

   cmp   [carac2], 'i'
   je    adalt
   cmp   [carac2], 'j'
   je    esquerra
   cmp   [carac2], 'k'
   je    abaix
   cmp   [carac2], 'l'
   je    dreta
      
adalt:
   cmp   [rowCur], 1
   jle   final
   dec   [rowCur]
   jmp   final
esquerra:
   cmp   [colCur], 'A'
   jle   final
   dec   [colCur]
   jmp   final
abaix:
   cmp   [rowCur], 8
   jge   final
   inc   [rowCur]
   jmp   final
dreta:
   cmp   [colCur], 'H'
   jge   final
   inc   [colCur]
   jmp   final

final:

   mov esp, ebp
   pop ebp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;		carac2   : variable on s’emmagatzema el caràcter llegit
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
; 
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movContinuoP1:
	push  ebp
	mov   ebp, esp
	;push eax
	;xor eax, eax
	Push_all

inici_bucle:
	call getMoveP1

	cmp [carac2], 's'
	je fora_bucle

	cmp [carac2], ' '
	je fora_bucle

	call moveCursorP1

	mov eax,[rowCur]
	mov [row], eax
	xor eax,eax
	mov al, [colCur]
	mov [col], al
	call posCurScreenP1

	jmp inici_bucle
	
fora_bucle:
	
	Pop_all
		;pop eax
		mov esp, ebp
		pop ebp
		ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; sea[row][col] en C, és [sea+indexMat] en assemblador.
; on indexMat = row*8 + col (col convertir a número).
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; col       : columna per a accedir a la matriu sea
; indexMat	: índex per a accedir a la matriu sea
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndexP1:
	push ebp
	mov  ebp, esp

	push eax
	push ebx
	xor eax, eax
	mov eax, [row]
	dec eax
	shl eax, 3
	mov [indexMat], eax

	xor ebx, ebx
	mov bl, [col]
	sub bl, 'A' ;passar char a numero
	add [indexMat], ebx

	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Obrim una casella de la matriu sea
; En primer lloc calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la 
; subrutina calcIndexP1 i mostrar 'T' si hi ha un barco o 'O' si és aigua
; cridant a la subrutina printch. L'índex per a accedir
; a la matriu (sea) el calcularem cridant a la subrutina calcIndexP1.
; No es pot obrir una casella que ja tenim oberta.
;
; Variables utilitzades:	
; row       : fila per a accedir a la matriu sea
; rowCur	: fila actual del cursor a la matriu
; col       : columna per a accedir a la matriu sea
; colCur	: columna actual del cursor a la matriu
; indexMat	: Índex per a accedir a la matriu sea
; tocat		: indica si em tocat un vaixell
; sea		: Matriu 8x8 on tenim les posicions dels borcos. 
; carac		: caràcter per a escriure a pantalla.
; taulell   : Matriu en la que anem indicant els valors de les nostres tirades 
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openP1:
	push ebp
	mov  ebp, esp
	push eax
	;xor eax, eax

	;comprobar si esta obert HOT, si ho esta saltem a fet
	;sino hem de comprobar sea+indexMat [1-0]
	;si es aigua moure una O a sea+indexMat / taulell+indexMat, si tocat moure una T
	;fas el printch


	call calcIndexP1
	mov eax, [indexMat]

	cmp [sea+eax], 'O'
	je ja_fet
	cmp [sea+eax], 'T'
	je ja_fet
	cmp [sea+eax], 'H'
	je ja_fet

	cmp [sea+eax], 1
	jne fallat
	;cmp [carac], 'T'
	;je  ja_fet
	mov [carac], 'T'
	mov [sea+eax], 'T'
	call printch
	jmp ja_fet
fallat:
	;cmp [carac], 'O'
	;je  ja_fet
    mov [carac], 'O'
	mov [sea+eax], 'O'
	call printch
ja_fet:
	
	pop eax
	mov esp, ebp
	pop ebp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa l’obertura continua de caselles. S’ha d’utiliitzar
; la tecla espai per a obrir una casella i la 's' per a sortir. 
;
; Variables utilitzades: 
; carac2   : Caràcter introduït per l’usuari
; rowCur   : Fila del cursor a la matriu sea
; colCur   : Columna del cursor a la matriu sea
; row      : Fila per a accedir a la matriu sea
; col      : Columna per a accedir a la matriz sea
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openContinuousP1:
	push ebp
	mov  ebp, esp

inici_bucle_open_cont:

	call movContinuoP1
	cmp [carac2], 's'
	je fi_bucle_open_cont
	call openP1
	call sunk_boat
	call border
	jmp inici_bucle_open_cont

fi_bucle_open_cont:
	mov esp, ebp
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que comprova si un vaixell que hem tocat està enfonsat
; i en cas afirmatiu marca totes les caselles del vaixell amb una H 
;
; Variables utilitzades: 
;	carac		: Caràcter a imprimir per pantalla
;	rowCur		: Fila del cursor a la matriu sea
;	colCur		: Columna del cursor a la matriu sea
;	row			: Fila per a accedir a la matriu sea
;	col			: Columna per a accedir a la matriz sea
;	sea			: Matriu en la que tenim emmagatzemats el mapa i els bracos
;	indexMat	: Variable que indica la posició de la matriu sea a la que
;				  volem accedir
;	sunk		: Variable que indica si un barco ha estat enfonsat (1) o no (0)
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sunk_boat:
	push ebp
	mov  ebp, esp
	Push_all
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'T'
	jne errore

	
comprovacio_esquerra:
	cmp [col], 'A' ;comparo si soc a paret
	je punt_inicial_abans_dreta
	dec [col]
	call calcIndexP1 ;nova posicio (-1 de x)
	mov eax, [indexMat]
	cmp [sea+eax], 1
	je errore
	cmp [sea+eax], 'O'
	je punt_inicial_abans_dreta
	cmp [sea+eax], 0
	je punt_inicial_abans_dreta
	;fer coses no necesari
	jmp comprovacio_esquerra

punt_inicial_abans_dreta:
	;inici-nou
	xor ebx, ebx
	;fi-nou
	mov bl, [colCur]
	mov [col], bl
	call calcIndexP1

comprovacio_dreta:
	cmp [col], 'H' ;comparem si es paret
	je  punt_inicial_abans_amunt
	inc [col]
	call calcIndexP1 ;nova posicio (+1 de x)
	mov eax, [indexMat]
	cmp [sea+eax], 1
	je errore
	cmp [sea+eax], 'O'
	je  punt_inicial_abans_amunt
	cmp [sea+eax], 0
	je  punt_inicial_abans_amunt
	;fer coses no necesari
	jmp comprovacio_dreta

	
punt_inicial_abans_amunt:
	;inici-nou
	xor ebx, ebx
	;fi-nou
	mov bl, [colCur]
	mov [col], bl
	mov ebx, [rowCur]
	mov [row], ebx
	call calcIndexP1

comprovacio_amunt:
	cmp [row], 0 ;comparem si es paret
	je punt_inicial_abans_abaix
	dec [row]
	call calcIndexP1 ;nova posicio (-1 de y)
	mov eax, [indexMat]
	cmp [sea+eax], 1
	je errore
	cmp [sea+eax], 'O'
	je punt_inicial_abans_abaix
	cmp [sea+eax], 0
	je punt_inicial_abans_abaix
	;fer coses no necesari
	jmp comprovacio_amunt


punt_inicial_abans_abaix:
	;inici-nou
	xor ebx, ebx
	;fi-nou
	mov bl, [colCur]
	mov [col], bl
	mov ebx, [rowCur]
	mov [row], ebx
	call calcIndexP1

comprovacio_abaix:
	cmp [row], 7 ;comparem si es paret
	je correcte
	inc [row]
	call calcIndexP1 ;nova posicio (+1 de y)
	mov eax, [indexMat]
	cmp [sea+eax], 1
	je errore
	cmp [sea+eax], 'O'
	je correcte
	cmp [sea+eax], 0
	je correcte
	;fer coses no necesari
	jmp comprovacio_abaix

correcte:
	;inici-nou
	xor ebx,ebx
	;fi-nou
	mov bl, [colCur]
	mov [col], bl
	mov eax, [rowCur]
	mov [row], eax
	call calcIndexP1
	
	

	comprovacio_esquerra_correcte:

		mov eax, [indexMat]
		cmp [col], 'A' ;comparo si soc a paret
		jl punt_inicial_abans_dreta_correcte
		cmp [sea+eax], 'T'
		jne punt_inicial_abans_dreta_correcte
		
		mov [sea+eax], 'H'
		mov [carac], 'H'
		call posCurScreenP1
	    call printch
	
		dec [col]
		call calcIndexP1
		jmp comprovacio_esquerra_correcte

	punt_inicial_abans_dreta_correcte:
		xor ebx, ebx
		mov bl, [colCur]
		mov [col], bl
		mov eax, [rowCur]
		mov [row], eax
		call calcIndexP1

	comprovacio_dreta_correcte:

		mov eax, [indexMat]
		cmp [col], 'H' ;comparem si es paret
		jg  punt_inicial_abans_amunt_correcte
		
		cmp [sea+eax],'O'
		je punt_inicial_abans_amunt_correcte  
		cmp [sea+eax], 0
		je punt_inicial_abans_amunt_correcte
		
		mov [sea+eax], 'H'
		mov [carac], 'H'
		call posCurScreenP1
		call printch
	
		inc [col]
		call calcIndexP1
		jmp comprovacio_dreta_correcte

	punt_inicial_abans_amunt_correcte:

		xor ebx, ebx
		mov bl, [colCur]
		mov [col], bl
		mov eax, [rowCur]
		mov [row], eax
		call calcIndexP1


	comprovacio_amunt_correcte:

		mov eax, [indexMat]
		cmp [row], 0 ;comparem si es paret
		jl punt_inicial_abans_abaix_correcte

		cmp [sea+eax],'O'
		je punt_inicial_abans_abaix_correcte  
		cmp [sea+eax], 0
		je punt_inicial_abans_abaix_correcte
		
		;canvio t per H
		mov [sea+eax], 'H'
		mov [carac], 'H'
		call posCurScreenP1
		call printch

		dec [row]
		call calcIndexP1
		jmp comprovacio_amunt_correcte


	punt_inicial_abans_abaix_correcte:
		xor ebx,ebx
		mov bl, [colCur]
		mov [col], bl
		mov eax, [rowCur]
		mov [row], eax
		call calcIndexP1

	comprovacio_abaix_correcte:

		mov eax, [indexMat]
		cmp [row], 7 ;comparem si es paret
		jg errore

		cmp [sea+eax],'O'
		je errore 
		cmp [sea+eax], 0
		je errore

		;canvio el valor de T per H
		mov [sea+eax], 'H'
		mov [carac], 'H'
		call posCurScreenP1
		call printch
		inc [row]
		call calcIndexP1
		jmp comprovacio_abaix_correcte

errore:
		xor ebx,ebx
		mov bl, [colCur]
		mov [col], bl
		mov eax, [rowCur]
		mov [row], eax
		call calcIndexP1

	Pop_all
	mov esp, ebp
	pop ebp
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que marca com aigua totes les caselles que envolten un 
; vaixell enfonsat 
;
; Variables utilitzades: 
;		carac    : Caràcter a imprimir per pantalla
;		rowCur   : Fila del cursor a la matriu sea
;		colCur   : Columna del cursor a la matriu sea
;		row      : Fila per a accedir a la matriu sea
;		col      : Columna per a accedir a la matriu sea
;		rowIni	 : Fila on hem fet la tirada
;		colIni	 : Columna on hem fet la tirada
;		sea		 : Matriu en la que tenim emmagatzemats el mapa i els bracos
;		indexMat : Variable que indica la posició on està emmagatzemada
;	               la cel·la de la matriu sea a la que volem accedir
;		indexMatIni: Variable que indica la posició on està emmagatzemada
;	                 la cel·la de la matriu sea a la que hem fet la tirada
;
; Paràmetres d'entrada : 
; Cap
;
; Paràmetres de sortida: 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
border:
	push ebp
	mov  ebp, esp
	Push_all
	
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'H'
	jne patata
	call calcIndexP1

miro_dreta:
	cmp [col], 'H'
	je resetejar_abans_esquerra
	inc [col]
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'H'
	jne pinto_dreta
	
	dec[row]
	cmp [row], 1
	jl no_pinto_just_amunt_fent_dreta
	
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
	 
no_pinto_just_amunt_fent_dreta:
	inc [row]
	cmp [row], 8
	jge no_pinto_just_abaix_fent_dreta
	inc [row]
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
no_pinto_just_abaix_fent_dreta:
	dec [row]
	jmp miro_dreta

pinto_dreta:
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch


;DIAGONAL DERECHA ABAJO
	;cmp [col], 'H'
	;jge no_fare_diagonal_dreta_col_fent_dreta
	;inc [row]
	;cmp [row],8
	;jge no_fare_diagonal_dreta_row_fent_dreta
	;call calcIndexP1
	;mov eax, [indexMat]
	;mov [sea+eax], 'O'
	;mov [carac], 'O'
	;call posCurScreenP1
	;call printch
;no_fare_diagonal_dreta_col_fent_dreta:
;	dec [col]
;no_fare_diagonal_dreta_row_fent_dreta:
;	dec [row]

resetejar_abans_esquerra:
	mov bl, [colCur]
	mov [col], bl
	mov eax, [rowCur]
	mov [row], eax
	call calcIndexP1

miro_esquerra:
	cmp [col], 'A'
	je resetejar_abans_amunt
	dec [col]
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'H'
	jne pinto_esquerra
	
	dec[row]
	cmp [row], 1
	jle no_pinto_just_amunt_fent_esquerra
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
	 
no_pinto_just_amunt_fent_esquerra:
	inc [row]
	cmp [row], 8
	jge no_pinto_just_abaix_fent_esquerra
	inc [row]
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
no_pinto_just_abaix_fent_esquerra:
	dec[row]
	jmp miro_dreta

pinto_esquerra:
call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch

resetejar_abans_amunt:
	
	mov bl, [colCur]
	mov [col], bl
	mov eax, [rowCur]
	mov [row], eax
	call calcIndexP1

miro_amunt:
	cmp [row], 1
	je resetejar_abans_abaix
	dec [row]
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'H'
	jne pinto_amunt

	inc[col]
	cmp [col], 'H'
	jge no_pinto_just_dreta_fent_amunt

	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
	
no_pinto_just_dreta_fent_amunt:
	dec [col]
	cmp [col], 'A'
	jle no_pinto_just_esquerra_fent_amunt
	dec [col]
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
	
no_pinto_just_esquerra_fent_amunt:
inc [col]

	jmp miro_amunt

pinto_amunt:
call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch

resetejar_abans_abaix:

	mov bl, [colCur]
	mov [col], bl
	mov eax, [rowCur]
	mov [row], eax
	call calcIndexP1

miro_abaix:
	cmp [row], 8
	je acabo
	inc [row]
	call calcIndexP1
	mov eax, [indexMat]
	cmp [sea+eax], 'H'
	jne pinto_abaix

	inc[col]
	cmp [col], 'H'
	jge no_pinto_just_dreta_fent_abaix

	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
	
no_pinto_just_dreta_fent_abaix:
	dec [col]
	cmp [col], 'A'
	jle no_pinto_just_esquerra_fent_abaix
	dec [col]
	call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch
no_pinto_just_esquerra_fent_abaix:
	inc [col]
	jmp miro_abaix

pinto_abaix:
call calcIndexP1
	mov eax, [indexMat]
	mov [sea+eax], 'O'
	mov [carac], 'O'
	call posCurScreenP1
	call printch

acabo:

patata:

	Pop_all
	mov esp, ebp
	pop ebp
	ret

END


