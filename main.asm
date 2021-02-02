; Author: Joshua Revels
; Last Modified: 3/2/2020
; Description: This program fills an array with randomly generated numbers between 10 and 29, inclusive, then subsequently 
;			   sorts that array, calculates and displays the median number of the array, and calculates and displays 
;			   counts of how frequently each individual number appears in the array.

INCLUDE Irvine32.inc

LO = 10

HI = 29

ARRAYSIZE = 200

RANGE = 20

.data

program_title			BYTE			"				Random Generator and Sorter			by Joshua Revels", 0
instruct_1				BYTE			"This program generates 200 random numbers in the range [10 ... 29]", 0
instruct_2				BYTE			"This program will then display the original list, sort the list, displays the median value, displays the list sorted in ascending order.", 0
instruct_3				BYTE			"Finally this program will then display the number of instances of each generated value", 0
non_sort_header			BYTE			"Here is your non-sorted list", 0
sorted_header			BYTE			"Here is your sorted list", 0
median_header			BYTE			"List Median: ", 0
count_header			BYTE			"Your list of instances of each generated number, starting with the number of 10s:", 0
array					DWORD			200 DUP(?)
sorted_array			DWORD			200 DUP(?)
count_array				DWORD			20 DUP(?)
spacer					BYTE			"  ", 0
goodbye_1				BYTE			"Goodbye!", 0

.code
main PROC

call	Randomize

push	OFFSET instruct_3			; pass instruct_3 by reference
push	OFFSET instruct_2			; pass instruct_2 by reference
push	OFFSET instruct_1			; pass instruct_1 by reference
push	OFFSET program_title		; pass program_title by reference

call	intro

push	OFFSET array				; pass array by reference
push	LO							; pass LO by value
push	ARRAYSIZE					; pass ARRAYSIZE by value
push	RANGE						; pass RANGE by value

call	fillArray

push	OFFSET	spacer				; pass spacer by reference
push	OFFSET	non_sort_header		; pass non_sort_header by reference
push	OFFSET	array				; pass array by reference
push	ARRAYSIZE					; pass ARRAYSIZE by value

call	displayList

push	OFFSET array				; pass array by reference
push	ARRAYSIZE					; pass ARRAYSIZE by value

call	sortList

push	OFFSET median_header		; pass median_header by reference
push	ARRAYSIZE					; pass ARRAYSIZE by value
push	OFFSET array				; pass array by reference

call	calculateMedian

push	OFFSET	spacer				; pass spacer by reference
push	OFFSET	sorted_header		; pass sorted_header by reference
push	OFFSET	array				; pass array by reference
push	ARRAYSIZE					; pass ARRAYSIZE by value

call	displayList

push	LO							; pass LO by value
push	ARRAYSIZE					; pass ARRAYSIZE by value
push	OFFSET array				; pass array by reference
push	OFFSET count_array			; pass count_array by reference

call	countList

push	OFFSET spacer				; pass spacer by reference
push	OFFSET count_header			; pass count_header by reference
push	OFFSET count_array			; pass count_array by reference
push	RANGE

call	displayList

push	OFFSET goodbye_1			; pass goodbye_1 by reference

call	goodbye

	exit	; exit to operating system
main ENDP


; *******************************************************************************
; Procedure to introduce the program.
;
; receives: address program title and instruct strings on the system stack
;
; returns: none
;
; preconditions: none
;
; registers changed: edx
; *******************************************************************************

intro PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 8]
	call	WriteString							; Displays program title
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 12]
	call	WriteString							; Displays instructions to user
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 20]
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp
	ret		16
	intro ENDP


; ******************************************************************************************
; ##### SOURCES CITED: PORTIONS OF THIS CODE COME FROM DEMO 5 PROGRAM BY PAUL PAULSON #####
;
; Procedure to fill array with random integers.
;
; receives: RANGE, LO, and ARRAYSIZE global constants. Address for array
;
; returns: array filled with random integers
;
; preconditions: Randomize is initiated
;
; registers changed: eax, edi, ecx
; *******************************************************************************************

fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp + 8]						; value of range
	mov		edi, [ebp + 20]						; address of array
	mov		ecx, [ebp + 12]						; value of ARRAYSIZE
L1:	call	RandomRange
	add		eax, [ebp + 16]						; value of LO
	mov		[edi], eax
	mov		eax, 0
	mov		eax, [ebp + 8]						; value of Range
	add		edi, 4
	loop	L1
	pop		ebp
	ret		16
fillArray ENDP



; ***************************************************************************************************
; Procedure to display a list
;
; receives: address of header, address of array, address of spacer. Global ARRAYSIZE constant
;
; returns: none
;
; preconditions: none
;
; registers changed: eax, ebx, ecx, edx, esi
; ***************************************************************************************************

displayList PROC
	call	CrLf
	call	CrLf
	call	CrLf
	call	CrLf
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 16]						; address of non_sort_header
	call	WriteString							; displays header
	call	CrLf
	call	CrLf
	mov		ecx, [ebp + 8]						; value of ARRAYSIZE
	mov		esi, [ebp + 12]						; address of array
	mov		ebx, 1								; instantiate counter
	mov		edx, [ebp + 20]						; address of spacer
L2:	mov		eax, [esi]							; move current index of array to eax
	call	WriteDec							; print current index of array
	call	WriteString							; print spacer
	add		esi, 4								; move to next index in array
	cmp		ebx, 20								; compare counter to 20
	jge		B1									; jump if greater or equal
	inc		ebx									; increment counter
	jmp		B2
B1: mov		ebx, 1								; reset counter to 1
	call	CrLf								; move to next line
	call	CrLf
B2: loop	L2
	pop		ebp
	ret		16
displayList ENDP



; ******************************************************************************************************************
;   ###### SOURCES CITED: PORTIONS OF THIS CODE COME FROM BUBBLE SORT ALGORITHM FROM TEXTBOOK BY KIP IRVINE ######
;
; Procedure to sort a list/array
;
; receives: address of array. Global ARRAYSIZE constant
;
; returns: sorted version of list/array
;
; preconditions: array has 200 integers 
;
; registers changed: eax, ebx, ecx, edx, esi
; ******************************************************************************************************************

sortList PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]						; value of ARRAYSIZE
	dec		ecx									; decrement loop counter by one to set up loop correctly
X1:	push	ecx									; save outer loop count
	mov		esi, [ebp + 12]						; address of array
X2: mov		eax, [esi]							; move current index of array to eax
	mov		ebx, esi							; move array to ebx
	add		ebx, 4								; increment index of list by one in ebx
	cmp		[ebx], eax							; compare indices of array/list
	jg		X3									; jump to X3 if index ebx is greater
	call	exchangeElements					; if not, call exchangeElements
X3: add		esi, 4								; increment index of list by one in esi
	loop	X2
	pop		ecx									; restore outer loop counter
	loop	X1
	pop		ebp
	ret		8
sortList ENDP



; ***************************************************************************************************
; subprocedure of sortList, procedure to exchange elements in an array/list
;
; receives: none

; returns: exchanged indices of list/array
;
; preconditions: none
;
; registers changed: eax, ebx, esi, edi
; ***************************************************************************************************

exchangeElements PROC
	push	ebp
	mov		ebp, esp
	mov		edi, esi							; move copy of array/list to edi
	add		edi, 4								; increment index of edi by one
	mov		eax, [esi]							; temporarily move number at index of esi to eax
	mov		ebx, [edi]							; temporarily move number at index of edi to ebx
	mov		[edi], eax							; exchange numbers
	mov		[esi], ebx
	pop		ebp
	ret
exchangeElements ENDP




; ***************************************************************************************************
; Procedure to calculate the median of a sorted list/array
;
; receives: address of median_header, address of array. Global constant ARRAYSIZE
;
; returns: Median of sorted array/list
;
; preconditions: list/array must be sorted
;
; registers changed: eax, ebx, ecx, edx, esi
; ***************************************************************************************************


calculateMedian PROC
	push	ebp
	mov		ebp, esp							
	call	CrLf
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]							; address of median_header
	call	WriteString								; print median_header
	mov		esi, [ebp + 8]							; address of array
	sub		esi, 4									; decrement index of esi by one
	mov		eax, [ebp + 12]							; value of ARRAYSIZE
	cdq
	mov		ebx, 2									; put the divisor of 2 into ebx
	idiv	ebx										; divide ARRAYSIZE by 2
	cmp		edx, 0									; if it divides evenly, jump to J1
	je		J1
	add		eax, 1									; if it does not, round the number up to the next integer and return that number as median
	jmp		A1
J1:	mov		ebx, eax								; move a copy of halved ARRAYSIZE to ebx
	add		ebx, 1									; add one to ebx
	mov		ecx, 4									
	mul		ecx										; multiply eax by 4
	push	eax										; save value of eax
	mov		eax, ebx
	mul		ecx
	pop		ebx										; pop old value of eax into ebx
	add		esi, ebx								; by multiplying the two middle indices by 4, we get the true index/address of the two middle numbers of the array
	mov		eax, [esi]								; then we can index into the array for those numbers, and assign them to eax and ebx, respectively
	add		esi, 4									; 
	mov		ebx, [esi]								
	cmp		eax, ebx								; if eax and ebx are the same number, jump to A1
	je		A1
	add		eax, ebx								; if not, average the two numbers
	mov		ebx, 2
	cdq	
	idiv	ebx	
	add		eax, 1									; round up to next integer
A1: call	WriteDec								; print median
	call	CrLf
	call	CrLf
	call	CrLf
	pop		ebp
	ret		12
calculateMedian ENDP



; ***************************************************************************************************
; Procedure to display a list of counts
;
; receives: address of array, address of count_array. Global constants LO and ARRAYSIZE
;
; returns: list of how frequently each individual number shows up in the array
;
; preconditions: list must be sorted
;
; registers changed: ebx, ecx, edx, esi, edi
; ***************************************************************************************************


countList PROC
	push	ebp
	mov		ebp, esp
	mov		esi, 0
	mov		ebx, 0					; counter
	mov		esi, [ebp + 12]			; array
	mov		edi, [ebp + 8]			; count_array
	mov		edx, [ebp + 20]			; LO
	mov		ecx, [ebp + 16]			; ARRAYSIZE	
Z1:	cmp		edx, [esi]				; compare number a array index to number within range, if equal, jump to C1
	je		C1
	mov		[edi], ebx				; if not, move total to index of count array
	mov		ebx, 1					; reset counter to one
	add		edi, 4					; advance to next index of count array
	add		esi, 4					; advance to next index of sorted array
	add		edx, 1					; advance to next number of range to compare
	loop	Z1
C1:	inc		ebx						; add one to individual number counter
	add		esi, 4
	loop	Z1
	mov		[edi], ebx				; move final total to final index of count array
	pop		ebp
	ret		16
countList ENDP




; ***************************************************************************************************
; Procedure to display a goodbye message
;
; receives: address of goodbye
;
; returns: none
;
; preconditions: none
;
; registers changed: edx
; ***************************************************************************************************


goodbye PROC
	push	ebp
	mov		ebp, esp
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 8]
	call	WriteString
	call	CrLf
	call	CrLf
	call	CrLf
	pop		ebp
	ret		4
goodbye ENDP

END main
