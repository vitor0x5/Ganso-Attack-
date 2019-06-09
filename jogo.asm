; Implementa��o do jogo Ganso Attack!! em assembly pelos alunos
; Matheus de Brito Soares Porto RA: 744348
; Vitor Hugo Guilherme          RA: 744359
; Da disciplina Arquitetura e Organiza��o de Computadores 2 - DC- UFSCar

INCLUDE Irvine32.inc

.data

outHandle    DWORD ? 
scrSize COORD <85,50>
PosX BYTE ?
PosY BYTE ?

; Logo do jogo
logo BYTE "         ____                            _   _   _             _    _ _ ",0ah, 0dh  
	 BYTE "	 / ___| __ _ _ __  ___  ___      / \ | |_| |_ __ _  ___| | _| | |",0ah, 0dh  
	 BYTE "	| |  _ / _` | '_ \/ __|/ _ \    / _ \| __| __/ _` |/ __| |/ / | |",0ah, 0dh  
	 BYTE "	| |_| | (_| | | | \__ \ (_) |  / ___ \ |_| || (_| | (__|   <|_|_|",0ah, 0dh  
	 BYTE "	 \____|\__,_|_| |_|___/\___/  /_/   \_\__|\__\__,_|\___|_|\_(_|_)",0ah, 0dh, 0 

; MENU
 menu   BYTE "	    Selecione uma dificuldade para jogar:",0ah, 0dh, 0ah
		BYTE "				1 - Facil",0ah, 0dh
		BYTE "				2 - Dificil",0ah, 0dh
        BYTE "				ESC - SAIR",0ah, 0dh
		BYTE "				",0
		
; Ganso
ganso 	BYTE "     __ ",0ah,0dh  
		BYTE "        /  >",0ah,0dh  
		BYTE "       /  \ ",0ah,0dh  
		BYTE " _____/   / ",0ah,0dh  
		BYTE "<        / ",0ah,0dh  
		BYTE " \_    _/  ",0ah,0dh  
		BYTE "  |   |    ",0ah,0dh  
		BYTE "  |   |    ",0ah,0dh  
		BYTE "  ^   ^    ",0ah,0dh,0
		
; Ganso Agachado
ganso_agachado 	BYTE "    __  ",0ah,0dh  
				BYTE "       /  >",0ah,0dh  
				BYTE " _____/  \ ",0ah,0dh  
				BYTE "<        /  ",0ah,0dh  
				BYTE " \_   _/   ",0ah,0dh  
				BYTE "  |   |     ",0ah,0dh  
				BYTE "  ^   ^     ",0ah,0dh,0
				
; Obstaculos
obstaculo 	BYTE "!!!!!",0ah,0dh
			BYTE "!   !",0ah,0dh
			BYTE "!   !",0ah,0dh,0
			
obstaculo2  BYTE " /",0ah,0dh
			BYTE "x------",0ah,0dh
			BYTE " \ ",0ah,0dh,0
			
.code

;==================Desenha o menu inicial ==========================
;Recebe: nda
;Retorna: Desenho do menu na tela
;===================================================================
DesenhaMenu PROC
	mov  eax, red
	call SetTextColor
	mov dl, 1
	mov dh, 8
	call GotoXY
	mov edx, OFFSET logo
    call WriteString

	mov eax, white
	call SetTextColor 
	mov dh, 16
	call GotoXY
    mov edx, OFFSET menu   
	call WriteString  
	ret
DesenhaMenu ENDP
;===================================================================

;======================Desenha o Ganso==============================
;Recebe: PosX, PosY
;Retorna: desenho do ganso na tela
;===================================================================

DesenhaGanso PROC
	mov eax, white
	call SetTextColor
	mov dl,PosX
	mov dh,PosY
	call GotoXY
	mov edx, OFFSET ganso
	call WriteString
ret
DesenhaGanso ENDP

main PROC
	INVOKE GetStdHandle,STD_OUTPUT_HANDLE 
	mov outHandle, eax
	INVOKE SetConsoleScreenBufferSize,outHandle,scrSize
	call Clrscr
	
	;Desenha menu
	call DesenhaMenu  

	;Esperando tecla ser pressionada
EsperandoTecla:
		mov  eax,50          ; sleep, to allow OS to time slice
		call Delay           ; (otherwise, some key presses are lost)
		call ReadKey         ; look for keyboard input 
		push edx

	.IF al == "1"
		;TODO jogo fácil
		call Clrscr
		mov PosX,4
		mov PosY,10
		call DesenhaGanso
		;call WriteChar
		jmp SAIR
	.ELSEIF al == "2"
		;TODO jogo dificil
		call WriteChar
		jmp SAIR
	.ELSEIF al == VK_ESCAPE
		exit
	.ENDIF
	
	jmp   EsperandoTecla    ; nenhuma tecla válida pressionada, tenta novamente
SAIR:
	call ReadChar
	exit
main ENDP
END main