TITLE Example of ASM  
INCLUDE Irvine32.inc
main          EQU start@0

printstartmessage PROTO
read PROTO
reset PROTO
startgame PROTO
put PROTO
;frontend
showBoard PROTO
calPosition PROTO
movChess PROTO
initBoard PROTO
;frontend
.data
board byte 3,3,3,3,3,3,3,3,3,3,3
Rowsize = ($-board)	   
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
	   byte 3,0,0,0,0,0,0,0,0,0,3
   	   byte 3,3,3,3,3,3,3,3,3,3,3

row_size DWORD ?
outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0

turn BYTE 0
x BYTE 0			;落子座標x
Y BYTE 0			;落子座標y
flag BYTE 0			;可不可以落在這
state BYTE 0 			;0 沒贏 1 贏
buffer BYTE 512 DUP(0)
position byte 0
titleStr BYTE "GoBang",0
Msg1 BYTE "Player1's turn ", 040h, 0
Msg2 BYTE "Player2's turn ", 0FEh, 0
finalBoard BYTE 2 DUP(05Eh), 'FINAL', 2 DUP(05Eh), 10, 13, 0
winMsg1 BYTE "Congradulation!!!! Player1 win", 10, 13, 0
winMsg2 BYTE "Congradulation!!!! Player2 win", 10, 13, 0
illegalputMsg BYTE "xx    You can't place here     xx", 10, 13,0
Confirm BYTE "Press Any Key to Continue", 10, 13,0
LeaveMSG BYTE "Press ESC to Leave", 10, 13,0
startMsg1 BYTE 11 DUP(040h,0FEh,040h),0
startMsg2 BYTE 33 DUP(' '),0
startMsg3 BYTE "-|     Welcome to Gobang5!     |-",0
;startMsg4 BYTE "-|							    |-",0
;startMsg5 BYTE "-------------------------------------------------------------",0
EndMsg 	  BYTE "-|           Bye Bye           |-", 10, 13,0
startMsg6 BYTE "(any key)Start a new game",0
startMsg7 BYTE "(esc)quit",0
PlayAgain BYTE "play again?(y/n)",10,13,0

askXposition BYTE "Please enter your X coordinate:",0
askYposition BYTE "Please enter your Y coordinate:",0

;frontend
ChessBoard BYTE 0DAh, 7 DUP(0C2h), 0BFh, 10, 13, 7 DUP(0C3h, 7 DUP(0C5h), 0B4h, 10, 13), 0C0h, 7 DUP(0C1h), 0D9h, 10, 13, 0
ChessBoardInit BYTE 0DAh, 7 DUP(0C2h), 0BFh, 10, 13, 7 DUP(0C3h, 7 DUP(0C5h), 0B4h, 10, 13), 0C0h, 7 DUP(0C1h), 0D9h, 10, 13, 0
ChessBlack BYTE 0FEh
ChessWhite BYTE 040h
YConst WORD 11
SubConst WORD 12
BoardIndex WORD ?
Codepage DWORD 437
ConsoleSize COORD <33,12>
; WindowAbsolute DWORD 1
; WindowSize SMALL_RECT <0,0,33,11>
;frontend

.code

main PROC 
    INVOKE SetConsoleTitle, ADDR titleStr
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE; Get the console ouput handle
	invoke SetConsoleOutputCP, Codepage
    mov outputHandle, eax; save console handle
	;;;
	INVOKE SetConsoleScreenBufferSize,
        outputHandle,
        ConsoleSize
	;;;
     
start:
     invoke printstartmessage			;print startMsg
     call ReadChar
	 cmp ax , 011bh
	 je quit
	 invoke initBoard
     invoke showBoard
     jmp player1	

player1:					;player1's turn
	mov edx,OFFSET Msg1
	call WriteString
	call  Crlf 								
	mov turn,1
	invoke read       		;read from the screen store into position
	cmp flag ,1 			;if it's illgegal flag = 1
	je illegalput			
	jmp test1
	
player2:
	mov edx,OFFSET Msg2 
	call WriteString 			;player2's turn
	call  Crlf
	mov turn,2
	invoke read
	cmp flag ,1     			;if it's illgegal flag = 1
	je illegalput
	jmp test1

	
notwin:
	invoke calPosition
    invoke movChess
    invoke showBoard
	cmp turn ,1 ;next player
	je player2
	jmp player1
illegalput:					;print the text and return to original player
	;;;
	call Clrscr
	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx, OFFSET illegalputMsg	
	call WriteString

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf
	
	;;;
	mov edx, OFFSET Confirm
	call WriteString
	call ReadChar
	invoke showBoard
	mov flag , 0
	cmp turn , 1
	je player1
	jmp player2
	
test1:	;測試橫向,是否獲勝
	push eax 
	push esi
	push ebx
	push edx
	mov ebx,OFFSET board
	movzx edx,position
	mov esi , 0
	mov al , turn

	cmp al ,[ebx+edx+1]
	jne L1
	inc esi
	cmp al ,[ebx+edx+2]
	jne L1 
	inc esi
	cmp al ,[ebx+edx+3]
	jne L1 
	inc esi
	cmp al ,[ebx+edx+4]
	jne L1 
	inc esi
L1:
	
	cmp al ,[ebx+edx-1]
	jne L2 
	inc esi
	cmp al ,[ebx+edx-2]
	jne L2
	inc esi
	cmp al ,[ebx+edx-3]
	jne L2
	inc esi
	cmp al ,[ebx+edx-4]
	jne L2
	inc esi
L2:
	cmp esi , 4
	jb test2
	jmp win

test2:	;測試垂直,是否獲勝
	mov esi , 0

	cmp al ,[ebx+edx+11]
	jne L3 
	inc esi
	cmp al ,[ebx+edx+22]
	jne L3
	inc esi
	cmp al ,[ebx+edx+33]
	jne L3 
	inc esi
	cmp al ,[ebx+edx+44]
	jne L3 
	inc esi

L3:
	cmp al ,[ebx+edx-11]
	jne L4 
	inc esi
	cmp al ,[ebx+edx-22]
	jne L4
	inc esi
	cmp al ,[ebx+edx-33]
	jne L4
	inc esi
	cmp al ,[ebx+edx-44]
	jne L4
	inc esi
L4:
	cmp esi , 4
	jb test3
	jmp win
test3:	;測試斜左,是否獲勝
	mov esi , 0

	cmp al ,[ebx+edx+12]
	jne L5
	inc esi
	cmp al ,[ebx+edx+24]
	jne L5 
	inc esi
	cmp al ,[ebx+edx+36]
	jne L5 
	inc esi
	cmp al ,[ebx+edx+48]
	jne L5
	inc esi
L5:
	cmp al ,[ebx+edx-10]
	jne L6 
	inc esi
	cmp al ,[ebx+edx-20]
	jne L6
	inc esi
	cmp al ,[ebx+edx-30]
	jne L6
	inc esi
	cmp al ,[ebx+edx-40]
	jne L6
	inc esi
L6:
	cmp esi , 4
	jb test4
	jmp win
test4:	;測試斜右,是否獲勝
	mov esi , 0

	cmp al ,[ebx+edx+10]
	jne L7
	inc esi
	cmp al ,[ebx+edx+20]
	jne L7
	inc esi
	cmp al ,[ebx+edx+30]
	jne L7
	inc esi
	cmp al ,[ebx+edx+40]
	jne L7
	inc esi
L7:
	cmp al ,[ebx+edx-12]
	jne L8
	inc esi
	cmp al ,[ebx+edx-24]
	jne L8
	inc esi
	cmp al ,[ebx+edx-36]
	jne L8
	inc esi
	cmp al ,[ebx+edx-48]
	jne L8
	inc esi
L8:
	cmp esi , 4
	pop edx
	pop ebx
	pop eax 
	pop esi
	jb notwin
	jmp win
	
win:
	invoke calPosition
    invoke movChess
    cmp turn ,1 
    je player1win 
    jne player2win
player1win:
	;call Clrscr
    invoke showBoard
	mov edx, OFFSET finalBoard
	call WriteString
	mov edx,OFFSET winMsg1
	call WriteString
	call WaitMsg 
	call Crlf
	jmp regame
player2win:
	;call Clrscr
	invoke showBoard
	mov edx, OFFSET finalBoard
	call WriteString
	mov edx,OFFSET winMsg2
	call WriteString
	call WaitMsg 
	call Crlf
	jmp regame
	
	
regame:
	call Clrscr
	invoke reset
	mov edx, OFFSET PlayAgain
	call WriteString
	call ReadChar
	cmp ax,1579h
	je start

quit:
	call Clrscr
	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx,OFFSET EndMsg
	call WriteString

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf
		
	call WaitMsg

main ENDP

reset PROC USES esi ecx ax
    mov esi,OFFSET board
    mov ecx,11
    mov flag,0

L1:
    mov ax,3
    mov [esi], ax
    inc esi
    loop L1

    mov ecx,9

L2:
    push ecx
    mov ecx,11
L3:
    .IF ecx == 11
        mov ax,3
        mov [esi],ax
    .ENDIF

    .IF ecx == 1
        mov ax,3
        mov [esi],ax
    .ENDIF

    .IF ecx < 11 && ecx >1
        mov ax,0
         mov [esi],ax
    .ENDIF

     inc esi
    loop L3

    pop ecx
    loop L2
    mov ecx,11
L4:
    mov ax,3
    mov [esi],ax
    inc esi
    loop L4

    ret

reset ENDP

printstartmessage PROC USES edx

	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg3
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg2
	call WriteString
	call Crlf

	mov edx,OFFSET startMsg1
	call WriteString
	call Crlf
	
	mov edx,OFFSET startMsg6
	call WriteString
	call Crlf
	
	mov edx,OFFSET startMsg7
	call WriteString
	call Crlf
	ret

printstartmessage ENDP


	
read PROC USES ebx ecx eax edx esi	;read message from keyboard
	
	mov eax,0
	mov ebx,0
	mov ecx,0
	mov row_size,11
	
	mov edx,OFFSET askXposition
	call WriteString
	call ReadInt
	.IF al > 9 || al < 1
		mov flag,1
		ret
	.ENDIF
	mov x,al



	mov edx,OFFSET askYposition
	call WriteString
	call ReadInt
	.IF al > 9 || al < 1
		mov flag,1
		ret
	.ENDIF
	mov y,al



	mov ebx,OFFSET board
	movzx eax,x
	mul row_size
	add ebx,eax
	movzx ecx,y
	mov esi,0
L1:
	inc esi	
	loop L1

	 mov al,[ebx + esi]
	.IF ax != 0000h ;
		mov flag,1
		ret
	.ENDIF

	.IF turn == 0001h ;
		mov al,1
	.ENDIF
	.IF turn == 0002h ;
		mov al,2
	.ENDIF

	mov [ebx + esi],al
	
	add bl,y
	mov position,bl

	ret	
read ENDP

;frontend
showBoard PROC USES edx
    call Clrscr
    mov edx,OFFSET ChessBoard
	call WriteString
    ret
showBoard ENDP

calPosition PROC USES ax bx
    movzx ax, y
    mul YConst
	movzx bx, x
    add ax, bx
    sub ax, SubConst
    mov BoardIndex, ax
    ret
calPosition ENDP

movChess PROC USES ecx eax
    movzx ecx, BoardIndex
    cmp turn, 1
    je movWhite
    jmp movBlack
movWhite:
    mov al, ChessWhite
    jmp finalMov
movBlack:
    mov al, ChessBlack
finalMov:
    mov ChessBoard[ecx], al
    ret
movChess ENDP

initBoard PROC USES ecx eax ebx edx esi
	mov eax, OFFSET ChessBoard
	mov ebx, OFFSET ChessBoardInit
	mov esi, 0
	mov ecx, 97
init:
	mov edx, [ebx + esi]
	mov [eax + esi], edx
	inc esi
	LOOP init
	
	ret
initBoard ENDP
;frontend

END main