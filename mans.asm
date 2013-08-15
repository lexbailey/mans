section .data

startString: db "Program start...", 10, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

myString: db "Mancala Sequence:", 10, 0
handHas: db "The hand has: ", 0
pitName: db "Pit ", 0
pitHas: db " has ", 0
pitCounters: db " counters", 10, 0
pits: db 0,0,0,0,0,0 ;six pits, one byte each
hand: db 0 ;number in hand

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printASCII: db 49
section .text

global _start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
myProg:
	mov esi, myString	;get string pointer
	call writeStr		;call nice function

	mov esi, handHas	;get string pointer
	call writeStr		;call nice function

	mov eax, [hand]		;get number in hand
	call printNumber	;print it

	call printNewLine	;print a new line

	call printAllPits

.sweepIter:
	mov al, 1		;start on pit one
	mov [hand], al

	call printNewLine
	call doIter
	call printAllPits
	inc ecx
	cmp ecx, 20
	jle .sweepIter

	ret

doIter:
	push eax
	push ebx
	mov ebx, eax	;put the start pit number in ebx

.iterPit:
	call getPit	
	;do pit stuff

	cmp eax, 0
	jg .iterPitGreater	
.iterPitZero:
	;set this pit to the hand value and empty the hand
	xor eax, eax
	mov al, [hand]
	mov [pits-1+ebx], al
	mov al, 0
	mov [hand], al
	jmp .iterPitEnd
.iterPitGreater:
	;take one from this pit and add it to the hand
	dec al
	mov [pits-1+ebx], al
	mov al, [hand]
	inc al
	mov [hand], al
	inc ebx		;go to next pit
	cmp ebx, 6 	;check if this pit exists
	jle .iterPit	;if it does then loop again

.iterPitEnd:
	pop ebx
	pop eax
	ret

getPit:
	push esi
	push ebx
	mov esi, pits-1
	mov ebx, eax
	xor eax, eax
	mov al, [esi+ebx]
	pop ebx
	pop esi
	ret

printPit:
	push esi
	mov esi, pitName
	call writeStr

	call printNumber

	mov esi, pitHas
	call writeStr
	push eax
	call getPit
	call printNumber
	pop eax
	mov esi, pitCounters
	call writeStr
	pop esi
	ret

printAllPits:
	mov eax, 1 	;start at pit 1
.repPit:
	call printPit	;print this pit
	inc eax		;go to next pit
	cmp eax, 6 	;check if this pit exists
	jle .repPit	;if it does then loop again
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_start:
	mov esi, startString	;get string pointer
	call writeStr		;call nice function
	call myProg		;run the program
	call exitProgram	;exit

writeStr:
	push eax
	push ebx
	push ecx
	push edx
	call strLen		;find length
	mov eax, 4		;sys_write call
	mov edx, ecx		;length of string
	mov ecx, esi		;thing to write	
	mov ebx, 0		;0 is std out
	int 80h			;system call interupt
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

strLen:
	xor ecx, ecx
strLenLoop:
	mov al, [esi+ecx]	;read next byte of string
	inc ecx			;count this byte
	cmp al, 0		;compare the byte to 0
	jne strLenLoop		;if they are equal, get the next byte
	dec ecx			;subtract one for counting the null
	ret
	;length of string is now in ecx

printNumber:
	push eax
	push edx
	push ebx
	xor edx,edx          ;edx:eax = number
   	;div dword [const10]  ;eax = quotient, edx = remainder
	mov ebx,10
	div ebx
	test eax,eax         ;Is quotient zero?
	je .l1               ; yes, don't display it
	call printNumber     ;Display the quotient
.l1:
	mov eax, edx
	add eax, '0'
	mov [printASCII], eax
	mov eax, printASCII
	call printCharacter  ;Display the remainder
	pop ebx
	pop edx
	pop eax
	ret

printNewLine:
	push eax
	mov eax, 10
	mov [printASCII], eax
	mov eax, printASCII
	call printCharacter
	pop eax
	ret


printCharacter:
	push eax
	push ebx
	push ecx
	push edx
	mov ecx, eax		;thing to write	
	mov eax, 4		;sys_write call
	mov edx, 1		;length of string
	mov ebx, 0		;0 is std out
	int 80h			;system call interupt
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

exitProgram:
	mov ebx, 0		;exit with 0
	mov eax, 1		;linux system call 1 (exit)
	int 80h			;system call interupt
