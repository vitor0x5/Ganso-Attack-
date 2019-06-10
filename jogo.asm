; Implementa��o do jogo Ganso Attack!! em assembly pelos alunos
; Matheus de Brito Soares Porto RA: 744348
; Vitor Hugo Guilherme          RA: 744359
; Da disciplina Arquitetura e Organiza��o de Computadores 2 - DC- UFSCar
; Professor: Dr. Luciano Neres

INCLUDE Irvine32.inc

.data

outHandle    DWORD ? 
scrSize COORD <85,50>
PosX BYTE ?
PosY BYTE ?

;constantes utilizadas no desenho da moldura
LARGURA = 110
ALTURA = 30

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
ganso 	BYTE "          __ ",0ah,0dh  
		BYTE "         /  >",0ah,0dh  
		BYTE "        /  \ ",0ah,0dh  
		BYTE "  _____/   / ",0ah,0dh  
		BYTE " <        /  ",0ah,0dh  
		BYTE "  \_    _/   ",0ah,0dh  
		BYTE "   |   |     ",0ah,0dh  
		BYTE "   |   |     ",0ah,0dh  
		BYTE "   ^   ^     ",0ah,0dh,0


		
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
	mov dh, 6
	call GotoXY
	mov edx, OFFSET logo
    call WriteString

	mov eax, white
	call SetTextColor 
	mov dh, 14
	call GotoXY
    mov edx, OFFSET menu   
	call WriteString  
	ret
DesenhaMenu ENDP
;===================================================================

;==============Desenha a moldura da tela=============================
;Recebe: eax com a cor da moldura, LARGURA e ALTURA da tela
;Retorna: desenho da moldura na tela 
;====================================================================
Moldura PROC USES edx ecx
	call SetTextColor

	;Superior
	mov dl, 1
	mov dh, 1
	mov ecx, LARGURA ;LARGURA da tela do jogo
	mov al, 220	;caracter ASCII que compõe as barras superior e inferior
	jmp HORIZONTAL

	INFERIOR:
		mov dl, 1
		mov dh, ALTURA	; posição da barra inferior
		mov ecx, LARGURA ;LARGURA da tela do jogo

	;Desenha as barras superior e inferior(uma por vez)
	HORIZONTAL:          
		call GotoXY
		call WriteChar
		inc dl
	loop HORIZONTAL
	cmp dh, ALTURA
	jne INFERIOR ;se dh != 24 vai para inferior desenhar a outra barra

	;Laterais
	mov dl, 1
	mov dh, 2
	mov ecx, ALTURA-1
	mov al, 219 ;caracter que compõe as barras laterais

	;Desenha as barras verticais(as duas juntas)
	VERTICAL:            
		call GotoXY
		call WriteChar
		add dl, LARGURA-1	;pula para a esquerda
		call GotoXY
		call WriteChar
		sub dl, LARGURA-1	;volta para a direita
		inc dh
	loop VERTICAL
	ret
Moldura ENDP

;======================Desenha o Ganso==============================
;Recebe: PosX, PosY
;Retorna: desenho do ganso na tela
;===================================================================
DesenhaGanso PROC USES eax edx
	mov eax, white
	call SetTextColor
	mov dl,PosX
	mov dh,PosY
	call GotoXY
	mov edx, OFFSET ganso
	call WriteString
ret
DesenhaGanso ENDP
;===================================================================

main PROC
	;INVOKE GetStdHandle,STD_OUTPUT_HANDLE 
	;mov outHandle, eax										;DESCOBRIR O QUE FAZ (???)
	;INVOKE SetConsoleScreenBufferSize,outHandle,scrSize
	call Clrscr
	
	;Desenha menu
	call DesenhaMenu  
	mov eax, red     ;cor da moldura
	call Moldura

	;Esperando tecla ser pressionada
	EsperandoTecla:
		mov  eax,50          ; sleep, to allow OS to time slice
		call Delay           ; (otherwise, some key presses are lost)
		call ReadKey         ; look for keyboard input 
		push edx

	.IF al == "1"
		;TODO jogo fácil
		call Clrscr
		mov eax, green
		mov PosX,4
		mov PosY,10
		call DesenhaGanso
		call Moldura
		jmp SAIR
	.ELSEIF al == "2"
		;TODO jogo dificil
		call Clrscr
		call moldura
		jmp SAIR
	.ELSEIF al == VK_ESCAPE
		exit
	.ENDIF
	
	jmp   EsperandoTecla    ; nenhuma tecla válida pressionada, tenta novamente
SAIR:
	exit
main ENDP
END main