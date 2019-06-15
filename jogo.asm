; Implementa��o do jogo Ganso Attack!! em assembly pelos alunos
; Matheus de Brito Soares Porto RA: 744348
; Vitor Hugo Guilherme          RA: 744359
; Da disciplina Arquitetura e Organiza��o de Computadores 2 - DC- UFSCar
; Professor: Dr. Luciano Neres

INCLUDE Irvine32.inc

.data

outHandle    DWORD ? 
scrSize COORD <85,50>
contadorTempo DWORD 0
contadorObstaculo DWORD 0
contadorPulo DWORD 0 
contadorAgacha DWORD 0

;constantes utilizadas no desenho da moldura
LARGURA = 105
ALTURA = 30

;Variáveis auxiliares para impressão e exclusão de objetos da tela
PosY BYTE ?
PosX BYTE ?
larguraO BYTE ?
alturaO BYTE ?

statusGanso BYTE 1 ; 0 = Agachado, 1 = em pé, 2 = pulando

;Tamanho dos desenhos
LARGURA_OBJ1 = 5
ALTURA_OBJ1 = 3
LARGURA_OBJ2 = 5
ALTURA_OBJ2 = 3
LARGURA_GANSO = 12
ALTURA_GANSO = 9
ALTURA_GANSO_AGACHADO = 7
;Posição no eixo Y dos desenhos
Y_GANSO_EM_PE = 20
Y_GANSO_PULANDO =  15
Y_GANSO_AGACHADO = 22
Y_OBSTACULO1 = 26
Y_OBSTACULO2 = 19

;Fila de posição dos obstáculos
PosObs1 BYTE 7 DUP(?)
PosObs2 BYTE 7 DUP(?)
CtrlObs1 BYTE 0			;posições atuais da fila
CtrlObs2 BYTE 0


; Logo do jogo
logo BYTE "                      ____                            _   _   _             _    _ _ ",0ah, 0dh  
	 BYTE "	              / ___| __ _ _ __  ___  ___      / \ | |_| |_ __ _  ___| | _| | |",0ah, 0dh  
	 BYTE "	             | |  _ / _` | '_ \/ __|/ _ \    / _ \| __| __/ _` |/ __| |/ / | |",0ah, 0dh  
	 BYTE "	             | |_| | (_| | | | \__ \ (_) |  / ___ \ |_| || (_| | (__|   <|_|_|",0ah, 0dh  
	 BYTE "	              \____|\__,_|_| |_|___/\___/  /_/   \_\__|\__\__,_|\___|_|\_(_|_)",0ah, 0dh, 0 

; MENU
 menu   BYTE "Selecione uma dificuldade para jogar:",0ah, 0dh, 0ah
		BYTE "				              1 - Facil",0ah, 0dh
		BYTE "				              2 - Dificil",0ah, 0dh
        BYTE "				              ESC - SAIR",0ah, 0dh
		BYTE "				",0
		
;Ganso
ganso1 	BYTE                          "__",0ah,0dh,0  
ganso2	BYTE                         "/  >",0ah,0dh,0  
ganso3	BYTE                        "/  \",0ah,0dh,0  
ganso4	BYTE                  "_____/   /",0ah,0dh,0  
ganso5	BYTE                 "<        /",0ah,0dh,0  
ganso6	BYTE                  "\_    _/",0ah,0dh,0  
ganso7	BYTE                    "|   |",0ah,0dh,0  
ganso8	BYTE                    "|   |",0ah,0dh,0  
ganso9	BYTE                    "^   ^",0
	
; Ganso Agachado
ganso_agachado1 	BYTE                         "__",0ah,0dh,0  
ganso_agachado2		BYTE                       "/  >",0ah,0dh,0  
ganso_agachado3		BYTE                 "_____/  \ ",0ah,0dh,0  
ganso_agachado4		BYTE                "<        /  ",0ah,0dh,0  
ganso_agachado5		BYTE                  "\_   _/   ",0ah,0dh,0  
ganso_agachado6		BYTE                   "|   |     ",0ah,0dh,0  
ganso_agachado7		BYTE                   "^   ^     ",0
				
; Obstaculos
;obstaculo1 	BYTE "!!!!!",0ah,0dh
;			BYTE "!   !",0ah,0dh
;			BYTE "!   !",0ah,0dh,0
			
;obstaculo2  BYTE " /",0ah,0dh
;			BYTE "x----",0ah,0dh
;			BYTE " \ ",0ah,0dh,0

nuvem   BYTE "		                                         ____     ____        ",0ah,0dh 
    	BYTE "	                                              __/    \___/    \____   ",0ah,0dh 
       	BYTE "	                                             /                     \  ",0ah,0dh 
   		BYTE "                                                    |                       \ ",0ah,0dh 
    	BYTE "	                                             \___      __         __| ",0ah,0dh 
        BYTE "	                                                 \____/  \       /    ",0ah,0dh 
        BYTE " 			                                          \_____/     ",0 



sol     BYTE"          \     /      ",0ah,0dh 
        BYTE"            \___/       ",0ah,0dh
        BYTE"           /     \      ",0ah,0dh
        BYTE"      ____|       |____ ",0ah,0dh
        BYTE"           \ ___ /      ",0ah,0dh
        BYTE"           /     \      ",0ah,0dh
        BYTE"          /       \     ",0

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
	mov dl,32
	mov dh, 15
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

;======================Desenha o Ganso Em Pe =======================
;Recebe: PosY
;Retorna: desenho do ganso na tela
;===================================================================
DesenhaGansoEmPe PROC USES eax edx ecx
	mov eax, white
	call SetTextColor
	mov dl,1
	mov dh,PosY
	call GotoXY
	;mov edx, OFFSET ganso
	call WriteString
	
	;redesenha moldura que é apagada
	mov eax, green
    call SetTextColor
	mov dl, 1
	mov dh, PosY
	mov ecx, 9
	mov al, 219
	REMOLDURA:
		call GotoXY
		call WriteChar
		inc dh
	loop REMOLDURA
ret
DesenhaGansoEmPe ENDP
;===================================================================

DesenhaGansoEmPE2 PROC USES edx eax
	mov eax, white
	call SetTextColor
    mov dl, 25
	mov dh, PosY
	push edx
	call GotoXY
	mov edx, OFFSET ganso1
	call WriteString

	pop edx
    mov dl, 24
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso2
	call WriteString

    pop edx
	mov dl, 23
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso3
	call WriteString

	pop edx
	mov dl, 17
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso4
	call WriteString

	pop edx
	mov dl, 16
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso5
	call WriteString	

	pop edx
	mov dl, 17
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso6
	call WriteString

	pop edx
	mov dl, 19
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso7
	call WriteString

	pop edx
	mov dl, 19
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso8
	call WriteString

	pop edx
	mov dl, 19
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso9
	call WriteString 
	pop edx
	ret
DesenhaGansoEmPE2 ENDP

DesenhaGansoAgachado2 PROC USES eax
    mov eax, white
	call SetTextColor
    mov dl, 24
	mov dh, PosY
	push edx
	call GotoXY
	mov edx, OFFSET ganso_agachado1
	call WriteString

	pop edx
    mov dl, 23
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado2
	call WriteString

	pop edx
	mov dl, 17
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado3
	call WriteString

	pop edx
	mov dl, 16
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado4
	call WriteString

	pop edx
	mov dl, 18
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado5
	call WriteString	

	pop edx
	mov dl, 19
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado6
	call WriteString

	pop edx
	mov dl, 19
	inc dh
	call GotoXY
	push edx
	mov edx, OFFSET ganso_agachado7
	call WriteString
	pop edx

	ret
	exit
DesenhaGansoAgachado2 ENDP

;======================Desenha o Ganso agachado=====================
;Recebe: PosY
;Retorna: desenho do ganso na tela
;===================================================================
DesenhaGansoAgachado PROC USES eax edx
	mov eax, white
	call SetTextColor
	mov dl,1
	mov dh,Y_GANSO_AGACHADO
	call GotoXY
	;mov edx, OFFSET ganso_agachado
	call WriteString
ret
DesenhaGansoAgachado ENDP
;===================================================================

;======================Deleta Desenho===============================
;Recebe:PosX, PosY(ganso em pé = 20, obstaculo1 = 26, obstaculo2 = 19),
;		larguraO, alturaO
;Retorna:
;===================================================================
DeletaDesenho PROC USES edx eax ecx
	mov dl, PosX
	mov dh, PosY
	call GotoXY
	
	movzx ecx, alturaO   ; Nr de Linhas do Desenho
	mov al, 32   ; Barra de Espaço
	LINHA:
		push ecx
		movzx ecx, larguraO   ; Nr de Colunas do Desenho
		COLUNA:
			call WriteChar
		loop COLUNA
		pop ecx
		inc dh
		call GotoXY
	loop LINHA

	ret
DeletaDesenho ENDP

;=====================Desenha Obstaculo1============================
;Recebe: PosX
;Retorna: obstaculo desenhado na tela
;===================================================================
DesenhaObstaculo1 PROC USES ecx
	mov eax, brown
	call SetTextColor
	mov dl, PosX
	mov dh, Y_OBSTACULO1
	mov al, "!"
	mov ecx, 5
	CIMA:
		call GotoXY
		call WriteChar
		inc dl
	loop CIMA
	
	mov dl, PosX
	mov dh, 27
	mov ecx, 2
	LADOS:
		call GotoXY
		call WriteChar
		add dl, 4
		call GotoXY
		call WriteChar
		sub dl, 4
		inc dh
	loop LADOS
	ret
DesenhaObstaculo1 ENDP
;====================================================================

;=====================Desenha Obstaculo2============================
;Recebe: PosXObstaculo2
;Retorna: obstaculo desenhado na tela
;===================================================================
DesenhaObstaculo2 PROC USES ecx
	mov eax, red
	call SetTextColor
	add PosX, 1
	mov dl, PosX
	mov dh, Y_OBSTACULO2
	dec PosX

	mov al, "/"
	call GotoXY
	call WriteChar

	inc dh
	dec dl
	mov al, "x"
	call GotoXY
	call WriteChar

	inc dl
	mov al, "-"
	mov ecx, 4
	L1: 
		call GotoXY
		call WriteChar
		inc dl
	loop L1

	inc dh
	sub dl, 4
	mov al, "\"
	call GotoXY
	call WriteChar
	ret
DesenhaObstaculo2 ENDP
;====================================================================

;=========================Desenha Céu===============================
;Recebe: nda
;Retorna: dsenho do ceu do jogo na tela
;===================================================================
DesenhaCeu PROC 
	;SOL
	mov eax, yellow
	call SetTextColor
	mov dl, 1
	mov dh, 3
	call GotoXY
	mov edx, OFFSET sol
	call WriteString
	;NUVEM
	mov eax, white
	call SetTextColor
	mov dl, 1
	mov dh, 10
	call GotoXY
	mov edx, OFFSET nuvem
	call WriteString
	ret
DesenhaCeu ENDP
;==================================================================

;=======================Inicializa Jogo==============================
;Recebe: nda
;Retorna: Tela inicial do jogo
;====================================================================
InicializaJogo PROC
	call Clrscr
	mov PosY, Y_GANSO_EM_PE
	call DesenhaGansoEmPE2
	call DesenhaCeu
	mov eax, green	;cor da moldura
	call Moldura
	
	call CriaObstaculo
	ret
InicializaJogo ENDP
;====================================================================

;=====================Cria Obstaculo ================================
;Gera os obstáculos de forma aleatória
;Recebe: nda
;Retorna: um obstáculo(ou nada) na tela
;====================================================================
CriaObstaculo PROC
	call Randomize
	mov eax, 3
	call RandomRange
	.IF al == 1
		mov PosX, 100
		call DesenhaObstaculo1
		movzx ebx, CtrlObs1
		mov PosObs1[ebx], 100
		inc CtrlObs1
		jmp FIM
	.ELSEIF al == 2
		mov PosX, 99
		call DesenhaObstaculo2
		movzx ebx, CtrlObs2
		mov PosObs2[ebx], 100
		inc CtrlObs2
		jmp FIM
	.ENDIF
	FIM:
	ret
CriaObstaculo ENDP
;====================================================================

;=======================JOGO=========================================
;Rotina do jogo. Faz a leitura da tecla de salto(W) e agachamento (S) e chama os 
;procedimentos de movimentação e criação de obstaculos
;Recebe: nda
;Retorna: jogo na tela
;====================================================================
Jogo PROC
	JOGO_LOOP:
		mov eax, 50
		call Delay
		call ReadKey
		add contadorTempo, 50
		add contadorObstaculo, 50
		add contadorPulo, 50
		add contadorAgacha, 50
		
		.IF al == "w"        ;Faz o Ganso Pular
			;Deletando o Desenho do Ganso
			mov statusGanso, 2
			mov PosX,16
			mov PosY, Y_GANSO_EM_PE
			mov larguraO, LARGURA_GANSO
			mov alturaO,ALTURA_GANSO
			call DeletaDesenho
			;Desenhando o Ganso no Ar
			mov PosY, Y_GANSO_PULANDO
			mov contadorPulo, 0
			mov contadorAgacha, 0
			call DesenhaGansoEmPe2
			jmp DELAY_MOVIMENTO
		
		.ELSEIF al ==  "s"    ;Faz o Ganso Agachar
			;Deletando o Desenho do Ganso
			mov PosX,16
			cmp statusGanso, 2
			jne NPULANDO
				mov PosY, Y_GANSO_PULANDO
				jmp DELETA_
			NPULANDO:
			cmp statusGanso, 1
			jne AGACHADO_
				mov PosY, Y_GANSO_EM_PE
				jmp DELETA_
			AGACHADO_:
				jmp DELAY_MOVIMENTO
			DELETA_:
			mov larguraO, LARGURA_GANSO
			mov alturaO,ALTURA_GANSO
			call DeletaDesenho
			;Desenhando o Ganso Agachado
			mov PosY, Y_GANSO_AGACHADO
			mov contadorAgacha, 0
			mov contadorPulo, 0
			call DesenhaGansoAgachado2
			mov statusGanso, 0
			jmp DELAY_MOVIMENTO
			
		.ENDIF
		
		DELAY_MOVIMENTO:
		.IF contadorPulo == 1700 && statusGanso == 2
			;Deleta o Ganso no Ar
			mov statusGanso, 1
			mov PosX, 16
			mov PosY, Y_GANSO_PULANDO
			mov larguraO, LARGURA_GANSO
			mov alturaO, ALTURA_GANSO
			call DeletaDesenho
			;Desenha o Ganso de volta ao chao
			mov PosY, Y_GANSO_EM_PE
			call DesenhaGansoEmPe2
			
			mov contadorPulo, 0
			jmp DELAY_MOVIMENTO2
		.ENDIF

		DELAY_MOVIMENTO2:
		.IF contadorAgacha == 1500 && statusGanso == 0
			;Deleta o Ganso agachado
			mov statusGanso, 1
			mov PosX, 16
			mov PosY, Y_GANSO_AGACHADO-1
			mov larguraO, LARGURA_GANSO
			mov alturaO, ALTURA_GANSO
			call DeletaDesenho
			;Desenha o Ganso de volta ao chao
			mov PosY, Y_GANSO_EM_PE
			call DesenhaGansoEmPe2
			
			mov contadorAgacha, 0
			jmp ATUALIZA_OBSTACULOS
		.ENDIF
		
		ATUALIZA_OBSTACULOS:
		.IF contadorTempo == 500
			call AtualizaObstaculos
			mov contadorTempo, 0
			jmp OBSTACULOS
		.ENDIF

		OBSTACULOS:
		.IF contadorObstaculo >= 2500
			call CriaObstaculo
			mov contadorObstaculo, 0
			jmp JOGO_LOOP
		.ENDIF
	jmp JOGO_LOOP

	ret
Jogo ENDP
;====================================================================

;=======================Atualiza Obstaculos==========================
;Atualiza posição de todos os obstáculos desenhados na tela
;Recebe: Lista com posição dos obstáculos existentes
;Retorna: Lista de posições atualizada
;====================================================================
AtualizaObstaculos PROC USES ecx
	;Obstaculos do tipo 1 =============================
	mov ecx, 0
	mov cl, CtrlObs1
	cmp cl, 0
	je TIPO2	;Se não existir obstáculo do tipo 1 pula para tipo 2
	PERCORRE1:
		;Deletando objeto1 da posição PosObs1[ecx]
		dec ecx
		mov bl, PosObs1[ecx]
		mov PosX, bl
		mov PosY, Y_OBSTACULO1
		mov larguraO, LARGURA_OBJ1
		mov alturaO, ALTURA_OBJ1
		call DeletaDesenho

		;Desenhando na nova posição
		.IF PosX >= 6 
			sub PosX, 5
			mov bl, PosX
			mov PosObs1[ecx], bl
			mov PosX, bl
			call DesenhaObstaculo1
			jmp INCREMENTA1
		.ELSE
			mov edx, OFFSET PosObs1
			dec CtrlObs1
			mov bl, CtrlObs1
			call ShiftLeftVetorPosicao
			jmp INCREMENTA2
		.ENDIF
		INCREMENTA1:
		inc ecx
	loop PERCORRE1
	;=================================================

	;Obstáculos do tipo 2 ============================
	TIPO2:
	mov cl, CtrlObs2
	cmp cl, 0
	je SAIR		;Se não existir obstáculo do tipo 2, sai
	PERCORRE2:
		;Deletando objeto2 da posição PosObs2[ecx]
		dec ecx
		mov bl, PosObs2[ecx]
		mov PosX, bl
		mov PosY, Y_OBSTACULO2
		mov larguraO, LARGURA_OBJ2
		mov alturaO, ALTURA_OBJ2
		call DeletaDesenho

		;Desenhando na nova posição
		.IF PosX >= 6
			sub PosX, 5
			mov bl, PosX
			mov PosObs2[ecx], bl
			mov PosX, bl
			call DesenhaObstaculo2
			jmp INCREMENTA2
		.ELSE
			mov edx, OFFSET PosObs2
			dec CtrlObs2
			mov bl, CtrlObs2
			call ShiftLeftVetorPosicao
			jmp INCREMENTA2
		.ENDIF
		INCREMENTA2:
		inc ecx
	loop PERCORRE2
	;=================================================

	SAIR:
	ret
AtualizaObstaculos ENDP
;====================================================================

;=====================Shift Vetor Posição=========================
;Recebe: edx = OFFSET do Vetor, ebx = numero de elementos do vetor -1
;retorna: 
;====================================================================
ShiftLeftVetorPosicao PROC USES ecx ebx edx
	mov ecx, ebx
	cmp ecx, 0
	je EXCEPTION_ ;Se ecx = 0 loop não funciona corretamente
	PERCORRE:
		inc edx
		mov bl, [edx]
		dec edx
		mov [edx], bl 
		inc edx
	loop PERCORRE
	jmp SAIR

	EXCEPTION_:
		inc edx
		mov bl, [edx]
		dec edx
		mov [edx], bl 
		inc edx
	SAIR:
	ret
ShiftLeftVetorPosicao ENDP
;====================================================================

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
		call InicializaJogo
		call Jogo
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
	mov dh, 40
	call GotoXY
	exit
main ENDP
END main