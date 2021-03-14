TITLE Low-level I/O procedures     (program6a.asm)

; Author: Chi Hin Ng
; Last Modified: 4/12/2019
; OSU email address: ngchi@oregonstate.edu
; Course number/section: CS271/400
; Project Number: 6a                Due Date: 8/12/2019
; Description: This program prompts users to enter 10 decimal integers, validate the input, then
; displays the integers, the sum of the integers and the average of the integers.

INCLUDE Irvine32.inc

; Macros
displayString	MACRO	consoleHandle, message, messageSize, bytesWritten
		push	eax

		INVOKE	GetStdHandle, STD_OUTPUT_HANDLE
		mov		consoleHandle, eax
		INVOKE	WriteConsole,
				consoleHandle,
				message,
				messageSize,
				ADDR bytesWritten,
				0

		pop		eax
ENDM

displayDec		MACRO	consoleHandle, message, messageSize, bytesWritten
		push	eax

		INVOKE	GetStdHandle, STD_OUTPUT_HANDLE
		mov		consoleHandle, eax
		INVOKE	WriteConsole,
				consoleHandle,
				ADDR message,
				messageSize,
				ADDR bytesWritten,
				0

		pop		eax
ENDM

getString		MACRO	stdInHandle, buffer, bytesRead
		push	eax

		INVOKE	GetStdHandle, STD_INPUT_HANDLE
		mov		stdInHandle, eax
		INVOKE	ReadConsole,
				stdInHandle,
				buffer,
				100,
				ADDR bytesRead,
				0

		pop		eax
ENDM

.data

; Program instructions and prompt statements
endl		EQU		 <0dh, 0ah>
program		LABEL BYTE
			BYTE	"Demonstrating low-level I/O procedures", endl
			BYTE	"Written by: Chi Hin Ng", endl
			BYTE	"**EC: Number each line of user input and display a running subtotal of the", endl
			BYTE	"user's numbers.", endl
			BYTE	"**EC: Correctly handles signed integers.", endl
			BYTE	"**EC: Implement the getString and displayString macros using the Win32 API", endl
			BYTE	"functions.", endl
			BYTE	"Please provide 10 decimal integers.", endl
			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", endl
			BYTE	"After you have finished inputting the raw numbers I will display a list of", endl
			BYTE	"the integers, their sum, and their average value.", endl
programSize	DWORD	($ - program)
bracket		LABEL BYTE
			BYTE	"("
bracketSize	DWORD	($ - bracket)
prompt		LABEL BYTE
			BYTE	")Please enter an integer number: "
promptSize	DWORD	($ - prompt)
prompt2		LABEL BYTE
			BYTE	")Please try again: "
prompt2Size	DWORD	($ - prompt2)
error		LABEL BYTE
			BYTE	"ERROR: You did not enter an integer number or your number was too big.", endl
errorSize	DWORD	($ - error)
showNum		LABEL BYTE
			BYTE	"You entered the following numbers:", endl
showNumSize	DWORD	($ - showNum)
showSum		LABEL BYTE
			BYTE	"The sum of these numbers is: "
showSumSize	DWORD	($ - showSum)
showAvg		LABEL BYTE
			BYTE	"The average is: ", endl
showAvgSize	DWORD	($ - showAvg)
separate	LABEL BYTE
			BYTE	", "
sepSize		DWORD	($ - separate)
thanks		LABEL BYTE
			BYTE	"Thanks for playing!", endl
thanksSize	DWORD	($ - thanks)

; Data variables
count			DWORD	0
num				DWORD	0
total			DWORD	0
average			DWORD	?
array			DWORD	10 DUP(?)
inString		BYTE	100 DUP(?), 0, 0
outString		LABEL BYTE
				BYTE	10 DUP(?)
revString		LABEL BYTE
				BYTE	10 DUP(?)
stringSize		DWORD	?
line			DWORD	49
consoleHandle	HANDLE	0
stdInHandle		HANDLE	?
bytesWritten	DWORD	?
bytesRead		DWORD	?

.code
main PROC

; Introduce the program and display instructions
		push	consoleHandle
		push	OFFSET program
		push	programSize
		push	bytesWritten
		call	introduction

; Prompt the user to enter 10 decimal integers
		push			OFFSET revString						; [esp+92] / [ebp+120]
		push			stringSize								; [esp+88] / [ebp+116]
		push			OFFSET outString						; [esp+84] / [ebp+112]
		push			OFFSET showSum							; [esp+80] / [ebp+108]
		push			showSumSize								; [esp+76] / [ebp+104]
		push			total									; [esp+72] / [ebp+100]
		push			count									; [esp+68] / [ebp+96]
		push			consoleHandle							; [esp+64] / [ebp+92]
		push			OFFSET bracket							; [esp+60] / [ebp+88]
		push			bracketSize								; [esp+56] / [ebp+84]
		push			OFFSET prompt							; [esp+52] / [ebp+80]
		push			promptSize								; [esp+48] / [ebp+76]
		push			OFFSET prompt2							; [esp+44] / [ebp+72]
		push			prompt2Size								; [esp+40] / [ebp+68]
		push			OFFSET error							; [esp+36] / [ebp+64]
		push			errorSize								; [esp+32] / [ebp+60]
		push			bytesWritten							; [esp+28] / [ebp+56]
		push			num										; [esp+24] / [ebp+52]
		push			line									; [esp+20] / [ebp+48]
		push			OFFSET array							; [esp+16] / [ebp+44]
		push			stdInHandle								; [esp+12] / [ebp+40]
		push			OFFSET inString							; [esp+8] / [ebp+36]
		push			bytesRead								; [esp+4] / [ebp+32]
		call			ReadVal									; [esp] / [ebp+28]

; Display decimal integers
		push			OFFSET revString						; [esp+64] / [ebp+92]
		push			total									; [esp+60] / [ebp+88]
		push			OFFSET showAvg							; [esp+56] / [ebp+84]
		push			showAvgSize								; [esp+52] / [ebp+80]
		push			OFFSET showSum							; [esp+48] / [ebp+76]
		push			showSumSize								; [esp+44] / [ebp+72]
		push			OFFSET separate							; [esp+40] / [ebp+68]
		push			sepSize									; [esp+36] / [ebp+64]
		push			OFFSET array							; [esp+32] / [ebp+60]
		push			OFFSET showNum							; [esp+28] / [ebp+56]
		push			showNumSize								; [esp+24] / [ebp+52]
		push			consoleHandle							; [esp+20] / [ebp+48]
		push			stringSize								; [esp+16] / [ebp+44]
		push			bytesWritten							; [esp+12] / [ebp+40]
		push			num										; [esp+8] / [ebp+36]
		push			OFFSET outString						; [esp+4] / [ebp+32]
		call			printResult								; [esp] / [ebp+28]

; Exit the program
		push			consoleHandle
		push			OFFSET thanks
		push			thanksSize
		push			bytesWritten
		call			terminate

	exit	; exit to operating system
main ENDP

; Procedure to introduce the program to users
; receives:				consoleHandle, @program, programSize, bytesWritten
; returns:				same as above
; preconditions:		None
; registers changed:	None
introduction	PROC
		push			ebp
		mov				ebp, esp

		displayString	[ebp+20], [ebp+16], [ebp+12], [ebp+8]

		pop				ebp
		ret				16
introduction	ENDP

; Procedure to read the input from the user, validate it, and convert it to an integer.
; receives:				consoleHandle, @bracket, bracketSize, @prompt, promptSize, @prompt2, prompt2Size,
;						@error, errorSize, bytesWritten, total, num, line, @array, stdInHandle, @inString,
;						bytesRead, count, @outString, @showSum, showSumSize, stringSize, @revString
; returns:				same as above
; preconditions:		None
; registers changed:	None
ReadVal			PROC
		push			ebp										; [ebp+24]
		push			edi										; [ebp+20]
		push			esi										; [ebp+16]
		push			eax										; [ebp+12]
		push			ebx										; [ebp+8]
		push			ecx										; [ebp+4]
		push			edx										; [ebp]
		mov				ebp, esp
		mov				edi, [ebp+44]							; move array to edi
		cld														; set direction: forward

	getData:
		mov				eax, 0
		mov				[ebp+52], eax							; reset num
		displayString	[ebp+92], [ebp+88], [ebp+84], [ebp+56]	; print the prompt statement
		mov				edx, [ebp+48]
		cmp				edx, 57
		jg				lastLine
		displayDec		[ebp+92], [ebp+48], 1, [ebp+56]			; print the line no.
		displayString	[ebp+92], [ebp+80], [ebp+76], [ebp+56]	; print the prompt statement
		jmp				getAgain

	lastLine:
		mov				edx, 49
		mov				[ebp+48], edx
		displayDec		[ebp+92], [ebp+48], 1, [ebp+56]			; print the line no.
		mov				edx, 48
		mov				[ebp+48], edx
		displayDec		[ebp+92], [ebp+48], 1, [ebp+56]			; print the line no.
		displayString	[ebp+92], [ebp+80], [ebp+76], [ebp+56]	; print the prompt statement

	getAgain:
		getString		[ebp+40], [ebp+36], [ebp+32]			; get the input
		mov				esi, [ebp+36]							; move @inString to esi
		mov				ecx, [ebp+32]							; move the size of the input array to ecx
		sub				ecx, 2									; -2 to get the correct size
		mov				al, [esi]								; move the 1st char to al
		cmp				al, 45									; check to see if it is '-' sign
		je				negInt									; go to negative int session if so
		cmp				ecx, 9
		jg				invalid

	checkNum:
		mov				eax, [ebp+52]							; move num to eax
		mov				ebx, 10
		mul				ebx
		mov				[ebp+52], eax							; move the multiplied num to num
		xor				eax, eax
		lodsb
		cmp				al, 48									; compare 1st char and '0'
		jl				invalid									; go to error session if not numbers
		cmp				al, 57									; compare 1st char and '9'
		jg				invalid									; go to error session if not numbers
		sub				al, 48									; convert char to int
		add				[ebp+52], al							; add int to num to get the new value
		loop			checkNum
		mov				eax, [ebp+52]
		cmp				eax, 214748364
		jg				invalid
		add				[ebp+100], eax							; calculate the sum
		mov				eax, [ebp+52]
		mov				[edi], eax								; move num to array
		add				edi, 4									; index of array + 1
		jmp				subtotal

	contCheck:
		mov				eax, [ebp+48]
		inc				eax
		mov				[ebp+48], eax							; line no. + 1
		mov				eax, [ebp+96]
		inc				eax
		mov				[ebp+96], eax							; count + 1
		cmp				eax, 10
		je				exitProc								; array is full
		jmp				getData

	negInt:
		lodsb													; skip the '-' sign
		sub				ecx, 1
		cmp				ecx, 9
		jg				invalid

	checkNegNum:
		mov				eax, [ebp+52]							; move num to eax
		mov				ebx, 10
		imul			ebx
		mov				[ebp+52], eax							; move the multiplied num to num
		xor				eax, eax
		lodsb
		cmp				al, 48									; compare 1st char and '0'
		jl				invalid									; go to error session if not numbers
		cmp				al, 57									; compare 1st char and '9'
		jg				invalid									; go to error session if not numbers
		sub				al, 48									; convert char to int
		add				[ebp+52], al							; add int to num to get the new value
		loop			checkNegNum
		mov				eax, [ebp+52]
		cmp				eax, 214748364
		jg				invalid
		mov				ebx, -1
		cdq
		idiv			ebx										; convert the number to negative
		add				[ebp+100], eax							; calculate the sum
		mov				[ebp+52], eax
		mov				[edi], eax								; move num to array
		add				edi, 4									; index of array + 1
		jmp				subtotal

	subtotal:
		displayString	[ebp+92], [ebp+108], [ebp+104], [ebp+56]; print subtotal statement
		push			[ebp+120]
		push			[ebp+92]
		push			[ebp+116]
		push			[ebp+56]
		push			[ebp+100]
		push			[ebp+112]
		call			WriteVal
		call			CrLf
		jmp				contCheck

	invalid:
		displayString	[ebp+92], [ebp+64], [ebp+60], [ebp+56]	; print the error message
		displayString	[ebp+92], [ebp+88], [ebp+84], [ebp+56]	; print the re-prompt statement
		mov				edx, [ebp+48]
		cmp				edx, 57
		jg				lastLine
		displayDec		[ebp+92], [ebp+48], 1, [ebp+56]			; print the line no.
		displayString	[ebp+92], [ebp+72], [ebp+68], [ebp+56]	; print the re-prompt statement
		mov				eax, 0
		mov				[ebp+52], eax							; reset num
		jmp				getAgain

	exitProc:
		pop				edx
		pop				ecx
		pop				ebx
		pop				eax
		pop				esi
		pop				edi
		pop				ebp
		ret				92
ReadVal			ENDP

; Procedure to convert an integer to a string and display it.
; receives:				an integer, 2 @string, statement printing related variables
; returns:				the integer, 2 @string, statement printing related variables
; preoconditions:		None
; registers changed:	None
WriteVal		PROC
		push			ebp										; [ebp+24]
		push			edi										; [ebp+20]
		push			esi										; [ebp+16]
		push			eax										; [ebp+12]
		push			ebx										; [ebp+8]
		push			ecx										; [ebp+4]
		push			edx										; [ebp]
		mov				ebp, esp
		mov				edi, [ebp+32]							; move @outString to edi to write in
		mov				eax, [ebp+36]							; move the integer to eax
		cmp				eax, 0
		je				case0
		xor				ecx, ecx
		cld

	getSize:
		xor				edx, edx
		cmp				eax, 0
		je				prepare
		mov				ebx, 10
		cdq
		idiv			ebx
		inc				ecx										; size of string + 1
		jmp				getSize

	prepare:
		mov				[ebp+44], ecx
		mov				eax, [ebp+36]							; move the integer to eax
		cmp				eax, 0
		jl				negative

	convert:
		xor				edx, edx
		cmp				eax, 0
		je				getOutput								; finish converting int to string
		mov				ebx, 10
		cdq
		idiv			ebx
		add				edx, 48
		push			eax
		mov				eax, edx
		stosb
		pop				eax
		jmp				convert

	negative:
		mov				esi, ecx
		mov				edx, 45
		mov				[ebp+44], edx
		displayDec		[ebp+48], [ebp+44], 1, [ebp+40]			; print '-' sign
		xor				edx, edx
		cdq
		mov				ebx, -1
		idiv			ebx
		mov				[ebp+44], esi
		mov				ecx, esi
		jmp				convert

	getOutput:
	    mov				ecx, [ebp+44]
		xor				esi, esi
		mov				esi, [ebp+32]
		xor				edi, edi
		mov				edi, [ebp+52]
		add				esi, ecx
		dec				esi

	reverse:
		mov				al, [esi]
		dec				esi
		cld
		stosb
		loop			reverse

	endRev:
		displayString	[ebp+48], [ebp+52], [ebp+44], [ebp+40]	; display the number in string
		jmp				exitProc

	case0:
		mov				eax, 48
		mov				[ebp+44], eax
		displayDec		[ebp+48], [ebp+44], 1, [ebp+40]

	exitProc:
		pop				edx
		pop				ecx
		pop				ebx
		pop				eax
		pop				esi
		pop				edi
		pop				ebp
		ret				24
WriteVal		ENDP

; Procedure to print the results.
; receives:				the int array, statement printing related variables
; returns:				the int array, statement printing related variables
; preconditions:		None
; registers changed:	None
printResult		PROC
		push			ebp
		push			edi
		push			esi
		push			eax
		push			ebx
		push			ecx
		push			edx
		mov				ebp, esp
		mov				esi, [ebp+60]							; move @array to esi

		displayString	[ebp+48], [ebp+56], [ebp+52], [ebp+40]
		mov				ebx, 10

	displayList:
		mov				eax, [esi]								; get int from array
		add				[ebp+88], eax							; calculate sum
		mov				[ebp+36], eax
		push			[ebp+92]
		push			[ebp+48]
		push			[ebp+44]
		push			[ebp+40]
		push			[ebp+36]
		push			[ebp+32]
		call			WriteVal
		displayString	[ebp+48], [ebp+68], [ebp+64], [ebp+40]
		add				esi, 4
		dec				ebx										; ecx is affected with unknow reason
		cmp				ebx, 0
		je				displaySum
		jmp				displayList								; 'loop' instruction will fail here

	displaySum:
		call			CrLf
		displayString	[ebp+48], [ebp+76], [ebp+72], [ebp+40] ; display sum
		push			[ebp+92]
		push			[ebp+48]
		push			[ebp+44]
		push			[ebp+40]
		push			[ebp+88]
		push			[ebp+32]
		call			WriteVal
		
		call			CrLf
		displayString	[ebp+48], [ebp+84], [ebp+80], [ebp+40]	; display average
		xor				edx, edx
		mov				eax, [ebp+88]
		mov				ebx, 10
		cdq
		idiv			ebx
		mov				[ebp+36], eax							; pass average to WriteVal
		push			[ebp+92]
		push			[ebp+48]
		push			[ebp+44]
		push			[ebp+40]
		push			[ebp+36]
		push			[ebp+32]
		call			WriteVal
		call			CrLf

		pop				edx
		pop				ecx
		pop				ebx
		pop				eax
		pop				esi
		pop				edi
		pop				ebp
		ret				64
printResult		ENDP

; Procedure to terminate the program by displaying a message
; receives:				consoleHandle, @thanks, thanksSize, bytesWritten
; returns:				same as above
; preconditions:		None
; registers changed:	None
terminate		PROC
		push			ebp
		mov				ebp, esp

		displayString	[ebp+20], [ebp+16], [ebp+12], [ebp+8]

		pop				ebp
		ret				16
terminate		ENDP

END main
