.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
victory_C PROTO C
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
   
   
public C posCurScreen, getMove, moveCursor, moveCursorContinuo, moveTile, playTile, playBlock
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, puzzle: BYTE, indexMat: SDWORD, rowEmpty: SDWORD, colEmpty: BYTE, victory: SDWORD, moves: SDWORD
extern C rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gotoxy:
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printch:
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
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
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getch:
getch proc
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
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal convertir el char de la columna (A..D) a un número
; entre 0 i 3, i el int de la fila (1..4) a un número entre 0 i 3.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu sea
;	col       : columna per a accedir a la matriu sea
;	rowScreen : fila on volem posicionar el cursor a la pantalla.
;	colScreen : columna on volem posicionar el cursor a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;posCurScreen:
posCurScreen proc
    push ebp
	mov  ebp, esp

	;Push de registros
	push eax
	xor eax, eax
	push ebx

	;Traduccion col (columnas)
	mov al, [col]
	sub eax, 'A'

	;Traduccion row (filas)
	mov ebx, [row]
	dec ebx

	;Calculo colScreen
	shl eax, 2
	add eax, [colScreenIni]
	mov [colScreen], eax

	;Calculo rowScreen
	shl ebx, 1
	add ebx, [rowScreenIni]
	mov [rowScreen], ebx

	;Llamada a Subrutina
	call gotoxy

	;Pop de registros
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai 'm' o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
;	carac2 : Variable on s'emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getMove:
getMove proc
   push ebp
   mov  ebp, esp

   ;Push de registro
   push eax
   xor eax, eax

   bucle:
   call getch
   mov al, [carac2]

   cmp al,'i'
   jl bucle
   cmp al, 'l'
   jle fibucle
   cmp al, 'm'
   je fibucle
   cmp al, 's'
   je fibucle
   jmp bucle
   
   fibucle:

   ;Pop de registro
   pop eax

   mov esp, ebp
   pop ebp
   ret

getMove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'índex per a accedir a les matrius en assemblador.
; puzzle[row][col] en C, és [puzzle+indexMat] en assemblador.
; on indexMat = row*4 + col (col convertir a número).
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu puzzle
;	col       : columna per a accedir a la matriu puzzle
;	indexMat  : índex per a accedir a la matriu puzzle
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calcIndex: proc endp
calcIndex proc
	push ebp
	mov  ebp, esp
	
	;Push de registros
	push eax
	xor eax, eax
	push ebx

	;Traduccion col (columnas)
	mov al, [col]
	sub eax, 'A'

	;Traduccion row (filas)
	mov ebx, [row]
	dec ebx
	
	;Calculos
	shl ebx, 2
	add ebx, eax
	mov [indexMat], ebx

	;Pop de registros
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

calcIndex endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (row) i (col) en funció de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del taulell, (row) i (col) només poden 
; prendre els valors [1..4] i [A..D]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
;	carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
;	row : fila del cursor a la matriu puzzle.
;	col : columna del cursor a la matriu puzzle.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursor: proc endp
moveCursor proc
   push ebp
   mov  ebp, esp 

   ;Push de registros
	push eax
	xor eax, eax
	push ebx
	push ecx
	xor ecx, ecx

	;Asignacion de caracter
	mov cl, [carac2]

	;Traduccion col (columnas)
	mov al, [col]
	sub eax, 'A'

	;Traduccion row (filas)
	mov ebx, [row]
	sub ebx, 1

	;Comparaciones JE
	cmp ecx, 'i'
	je comprovacion_i
	cmp ecx, 'j'
	je comprovacion_j
	cmp ecx, 'k'
	je comprovacion_k
	cmp ecx, 'l'
	je comprovacion_l
	jmp fin

	comprovacion_i:
	cmp ebx, 0
	jle fin
	dec ebx
	jmp fin
	comprovacion_j:
	cmp eax, 0
	jle fin
	dec eax
	jmp fin
	comprovacion_k:
	cmp ebx, 3
	jge fin
	inc ebx
	jmp fin
	comprovacion_l:
	cmp eax, 3
	jge fin
	inc eax

	fin:
	;Movs y Pops de registros
	add eax, 'A'
	add ebx, 1
	mov [col], al
	mov [row], ebx
	pop ecx
	pop ebx
	pop eax

   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;	carac2   : variable on s’emmagatzema el caràcter llegit
;	row      : Fila per a accedir a la matriu puzzle
;	col      : Columna per a accedir a la matriu puzzle
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursorContinuo: proc endp
moveCursorContinuo proc
	push ebp
	mov  ebp, esp

	;Push de registros
	push ecx
	xor ecx, ecx

	inici:
	call getch
	mov cl, [carac2]
	cmp cl, 'm'
	je fi
	cmp cl, 's'
	je fi
	call moveCursor
	call posCurScreen
	jmp inici
	fi:
	
	;pops
	pop ecx

	mov esp, ebp
	pop ebp
	ret

moveCursorContinuo endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Desplaçar una fitxa cap al forat. La fitxa ha desplaçar serà la que
; indiquin les variables (row) i (col) i primerament s'ha de comprovar
; si és una posició vàlida per ser desplaçada. Una posició vàlida vol
; dir que és contigua al forat, sense comptar diagonals. Si no és una
; posició vàlida no fer el moviment.
; També s'ha de desplaçar el forat cap a la casella que s'ha mogut. I
; incrementar la variable moves si el moviment ha estat vàlid.
;
; Variables utilitzades: 
;	carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
;	row : fila del cursor a la matriu puzzle.
;	col : columna del cursor a la matriu puzzle.
;	rowEmpty : fila de la casella buida
;	colEmpty : columna de la casella buida
;	puzzle : matriu on es guarda l'estat del joc.
;   moves : enter que guarda el nombre de moviments fets.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveTile:
moveTile proc
	push ebp
	mov  ebp, esp

	;Push de registros
	push eax
	xor eax, eax
	push ebx
	push ecx
	xor ecx, ecx
	push edx
	
	call calcIndex

	;Traduccion col (columnas)
	mov al, [colEmpty]
	sub eax, 'A'

	mov cl, [col]
	sub ecx, 'A'

	;Traduccion row (filas)
	mov ebx, [rowEmpty]
	sub ebx, 1

	mov edx, [row]
	sub edx, 1

	;Comprovaciones
	cmp eax, ecx
	je cmpF
	cmp ebx, edx
	je cmpC
	jmp fin2

	cmpF:
	sub ebx, edx
	cmp ebx, 1
	je movArriba
	cmp ebx, -1
	je movAbajo
	jmp fin2

	cmpC:
	sub eax, ecx
	cmp eax, -1
	je movDerecha
	cmp eax, 1
	je movIzquierda
	jmp fin2	

	movDerecha:

	mov eax, [indexMat]
	mov bl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call printch

	inc [colEmpty]
	dec eax
	mov [puzzle+eax], bl
	dec [col]
	mov [carac], bl
	call posCurScreen	
	call printch
	inc [col]	
	jmp fin

	movIzquierda:

	mov eax, [indexMat]
	mov bl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call printch

	dec [colEmpty]
	inc eax
	mov [puzzle+eax], bl
	inc [col]
	mov [carac], bl
	call posCurScreen	
	call printch
	dec [col]	
	jmp fin

	movArriba:

	mov eax, [indexMat]
	mov bl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call printch

	dec [rowEmpty]
	add eax,4
	mov [puzzle+eax], bl
	inc [row]
	mov [carac], bl
	call posCurScreen	
	call printch
	dec [row]	
	jmp fin

	movAbajo:

	mov eax, [indexMat]
	mov bl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call printch

	inc [rowEmpty]
	sub eax,4
	mov [puzzle+eax], bl
	dec [row]
	mov [carac], bl
	call posCurScreen	
	call printch
	inc [row]	
	jmp fin

	fin:
	add [moves], 1
	fin2:

	;Movs y Pops de registros
	pop edx
	pop ecx
	pop ebx
	pop eax


	mov esp, ebp
	pop ebp
	ret

moveTile endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo de fitxes. S'ha
; d'utilitzar la tecla 'm' per moure una fitxa i la tecla 's' per
; sortir del joc. 
;
; Variables utilitzades: 
;	carac2   : variable on s’emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;playTile:
playTile proc
	push ebp
	mov  ebp, esp

	;push variables
	push eax
	xor eax, eax

	init:
	call posCurScreen
	call moveCursorContinuo	

	;llegim caracter
	mov al, [carac2]

	;comprovaciones
	cmp al, 's'
	je fin
	cmp al, 'm'
	je moveT	
	jmp init
	moveT:
	call moveTile
	call updateMovements
	call checkVictory
	cmp [victory], 1
	je fin
	jmp init

	fin:

	;pops variables
	pop eax

	mov esp, ebp
	pop ebp
	ret

playTile endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Comprovar si s'ha guanyat el joc. Es considera una victòria si totes
; les lletres estan ordenades i el forat està al final.
;
; Si es compleixen les condicions de victòria, cridar a la funció victory_C,
; que s'encarrega d'imprimir el missatge de victòria per pantalla.
;
; Variables utilitzades: 
; puzzle : matriu on es guarda l'estat del joc.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;checkVictory:
checkVictory proc
	push ebp
	mov  ebp, esp

	;declaracion variables
	push eax
	push ebx

	xor eax, eax
	xor ebx, ebx

	mov bl, [puzzle+eax]
	cmp bl, ' '
	je fi

	init:
	inc eax
	cmp bl, [puzzle+eax]
	jge fi
	mov bl, [puzzle+eax]	
	cmp eax, 14
	je fi2
	jmp init

	fi2:
	call victory_C
	mov [victory], 1
	fi:

	;pops 
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

checkVictory endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Actualitzar el nombre de moviments realitzats, és a dir, imprimir el 
; nou valor de la variable moves.
; Imprimir el nou valor a la posició indicada (rowScreen = 3, colScreen = 57), 
; però s'ha d'imprimir amb dues xifres (amb un zero davant si és menor a 10).
; Per poder dividir saber les dues xifres del número us recomanem usar la 
; instrucció div.
;
; Variables utilitzades: 
; rowScreen : Fila de la pantalla
; colScreen : Columna de la pantalla
; moves : Comptador de moviments
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;updateMovements:
updateMovements proc
	push ebp
	mov  ebp, esp

	;pusheamos
	push eax
	push ebx
	push ecx
	push edx
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	;passem moves a char
	mov ebx, 10
	mov eax, [moves]
	cmp eax, 10
	jl print1
	div ebx
	jmp print2

	print1:
	mov edx, eax
	add edx, 48
	mov cl, dl
	jmp printprimeraxifra
	

	print2:
	add edx, 48
	mov cl, dl
	add eax, 48

	;imprimim
	printprimeraxifra:
	mov [rowScreen], 2
	mov [colScreen], 59
	call gotoxy
	mov [carac], cl
	call printch

	cmp eax, 48
	jl fin
	

	;imprimim la segona xifra
	mov cl, al
	mov [rowScreen], 2
	mov [colScreen], 58
	call gotoxy
	mov [carac], cl
	call printch

	fin:
	;pulls
	pop edx
	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

updateMovements endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Desplaçar una fitxa o un bloc de fitxes cap al forat. 
; L'inici del bloc de fitxes a desplaçar l'indicaran les variables 
; (row) i (col). I el final quedarà implícit pel forat. S'ha de 
; comprovar que el bloc de fitxes estigui tot el "línea" i acabi 
; en el forat. Si només es tracta d'una fitxa només s'ha de comprovar 
; que estigui contigua al forat, no diagonalment.
; Al moure el bloc cap a direcció el forat, el forat es desplacà a la
; fitxa inicial i el bloc es desplaçarà una posició cap on estava el 
; forat. En el cas d'una sola fitxa, només s'han d'intercanviar el
; forat i la fitxa.
; Si les condicions no es compleixen no es farà cap moviment.
; S'ha d'incrementar la variable moves si el moviment ha estat vàlid,
; sempre s'incrementa només en un els moviments encara que es moguin
; més d'una fitxa.
;
; Variables utilitzades: 
;   carac2 : caràcter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
;   row : fila del cursor a la matriu puzzle.
;   col : columna del cursor a la matriu puzzle.
;   rowEmpty : fila de la casella buida
;   colEmpty : columna de la casella buida
;   puzzle : matriu on es guarda l'estat del joc.
;   moves : enter que guarda el nombre de moviments fets.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveBlock:
moveBlock proc
	push ebp
	mov  ebp, esp

	;Push Registros
	push eax
	push ebx
	push ecx
	xor ebx, ebx
	xor ecx, ecx
	
	mov eax, [row]
	mov bl, [col]
	cmp bl, [colEmpty]
	je mismaColum
	cmp eax, [rowEmpty]
	je mismaRow
	jmp fi
	
	mismaColum:
	cmp eax, [rowEmpty]
	jg movArriba
	cmp eax, [rowEmpty]
	jl movAbajo
	jmp fi

	movArriba:
	cmp eax, [rowEmpty]
	je fi2
	mov ebx, [rowEmpty]
	inc ebx
	mov [row], ebx
	call calcIndex
	mov ebx, [indexMat]
	mov cl, [puzzle+ebx]
	mov [puzzle+ebx], ' '
	mov [carac], ' '
	call posCurScreen
	call printch
	mov ebx, [rowEmpty]
	mov [row], ebx
	call calcIndex
	mov ebx, [indexMat]
	mov [puzzle+ebx], cl
	mov [carac], cl
	call posCurScreen
	call printch
	inc [rowEmpty]
	mov [row], eax	
	jmp movArriba

	movAbajo:
	cmp eax, [rowEmpty]
	je fi2
	mov ebx, [rowEmpty]
	dec ebx
	mov [row], ebx
	call calcIndex
	mov ebx, [indexMat]
	mov cl, [puzzle+ebx]
	mov [puzzle+ebx], ' '
	mov [carac], ' '
	call posCurScreen
	call printch
	mov ebx, [rowEmpty]
	mov [row], ebx
	call calcIndex
	mov ebx, [indexMat]
	mov [puzzle+ebx], cl
	mov [carac], cl
	call posCurScreen
	call printch
	dec [rowEmpty]
	mov [row], eax	
	jmp movAbajo

	mismaRow:
	cmp bl, [colEmpty]
	jg movIzquierda
	cmp bl, [colEmpty]
	jl movDerecha
	jmp fi

	movIzquierda:
	cmp bl, [colEmpty]
	je fi2
	xor eax, eax
	mov al, [colEmpty]
	inc al
	mov [col], al
	call calcIndex
	mov eax, [indexMat]
	mov cl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call posCurScreen
	call printch
	xor eax, eax
	mov al, [colEmpty]
	mov [col], al
	call calcIndex
	mov eax, [indexMat]
	mov [puzzle+eax], cl
	mov [carac], cl
	call posCurScreen
	call printch
	inc [colEmpty]
	mov [col], bl	
	jmp movIzquierda

	movDerecha:
	cmp bl, [colEmpty]
	je fi2
	xor eax, eax
	mov al, [colEmpty]
	dec al
	mov [col], al
	call calcIndex
	mov eax, [indexMat]
	mov cl, [puzzle+eax]
	mov [puzzle+eax], ' '
	mov [carac], ' '
	call posCurScreen
	call printch
	xor eax, eax
	mov al, [colEmpty]
	mov [col], al
	call calcIndex
	mov eax, [indexMat]
	mov [puzzle+eax], cl
	mov [carac], cl
	call posCurScreen
	call printch
	dec [colEmpty]
	mov [col], bl	
	jmp movDerecha


	fi2:
	inc [moves]

	fi:
	
	;Pop Registros
	pop ecx
	pop ebx
	pop eax

	mov esp, ebp
	pop ebp
	ret

moveBlock endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo de blocs. S'ha
; d'utilitzar la tecla 'm' per moure una fitxa i la tecla 's' per
; sortir del joc. 
;
; Variables utilitzades: 
;	carac2   : variable on s’emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;playBlock:
playBlock proc
	push ebp
	mov  ebp, esp

	;push variables
	push eax
	xor eax, eax

	init:
	call posCurScreen
	call moveCursorContinuo

	;llegim caracter
	mov al, [carac2]

	;comprovaciones
	cmp al, 's'
	je fin
	cmp al, 'm'
	je moveB	
	jmp init
	moveB:
	call moveBlock
	call updateMovements
	call checkVictory
	cmp [victory], 1
	je fin
	jmp init

	fin:

	;pops variables
	pop eax

	mov esp, ebp
	pop ebp
	ret

playBlock endp

END