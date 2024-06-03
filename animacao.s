.equ RED_LED_ADDR, 0x10000000 /* endereço do led vermelho */
.equ SLIDER_SWITCH, 0x10000040 /* endereco do slider switch */
.equ SW0_MASK, 0x01
.equ TIMER, 0x10002000 /* Status Register */

.global TRATA_ANIMACAO
TRATA_ANIMACAO:
    /* saving on stack frame */
    addi sp, sp, -32 # 8 registradores x 4
    stw r8, 32(sp)
    stw r9, 28(sp)
    stw r10, 24(sp)
    stw r11, 20(sp)
    stw r12, 16(sp)
    stw r13, 12(sp)
    stw r14, 8(sp)
    stw r15, 4(sp)
    /* ********************* */
    movia r10, STATUS_ANIMACAO
    ldw r10, (r10)
    beq r10, r0, SAI_ANIMACAO /* pergunta se o bit de animacao esta "aceso" */
    
    /* ********************************************** */
    movia r10, SLIDER_SWITCH /* carrega o endereço do slider switch */
    ldwio r10, (r10) /* carrega o conteúdo do slider switch */
    movi r11, SW0_MASK /* pega o slider switch 0 */
    and r10, r10, r11 # r10 é o valor do switch0
    movi r8, 1 # checa o sentido mas tambem eh quem itera
    beq r10, r8, ANTI_HORARIO /* se esta para cima, anti-horario. senão, horario */
    HORARIO:
        movia r12, LED_ATUAL_ANIMACAO # carrega o led atual da animacao
        ldw r13, (r12) # carrega o conteudo do led atual da animacao
        bne r13, r0, TEM_DIREITA
        NAO_TEM_DIREITA:
            movia r13, 0b100000000000000000
            br ANIMA_HORARIO
        TEM_DIREITA:
            srli r13, r13, 1 # joga para a direita
        ANIMA_HORARIO:
            stw r13, (r12) # salva o novo valor do led atual da animacao
            movia r14, RED_LED_ADDR # carrega o endereço da placa
            stwio r13, (r14) # salva o led atual da animacao na placa
            br SAI_ANIMACAO
    ANTI_HORARIO:
        movia r12, LED_ATUAL_ANIMACAO # carrega o led atual da animacao
        ldw r13, (r12) # carrega o conteudo do led atual da animacao
        movia r15, 0b100000000000000000
        bne r13, r15, TEM_ESQUERDA
        NAO_TEM_ESQUERDA:
            movi r13, 1
            br ANIMA_ANTI_HORARIO
        TEM_ESQUERDA:
            slli r13, r13, 1 # joga para a esquerda
        ANIMA_ANTI_HORARIO:
        stw r13, (r12) # salva o novo valor do led atual da animacao
        movia r14, RED_LED_ADDR # carrega o endereço da placa
        stwio r13, (r14) # salva o led atual da animacao na placa
        br SAI_ANIMACAO

SAI_ANIMACAO:
    movia r8, TIMER
    stwio r0, (r8)

    /* reset stack frame */
    ldw r8, 32(sp)
    ldw r9, 28(sp)
    ldw r10, 24(sp)
    ldw r11, 20(sp)
    ldw r12, 16(sp)
    ldw r13, 12(sp)
    ldw r14, 8(sp)
    ldw r15, 4(sp)
    addi sp, sp, 32 # 8 registradores x 4
    /* ********************* */
    ret /* Return from the interrupt-service routine */

.global ANIMACAO

ANIMACAO:
    /* saving on stack frame */
    addi sp, sp, -32 # 8 registradores x 4
    stw r8, 32(sp)
    stw r9, 28(sp)
    stw r10, 24(sp)
    stw r11, 20(sp)
    stw r12, 16(sp)
    stw r13, 12(sp)
    stw r14, 8(sp)
    stw r15, 4(sp)
    /* ********************* */
    movia r8, BUFFER # pega o buffer de entrada
    ldb r9, 1(r8) # pega o segundo valor no buffer

CHECK_OPTION:
    movi r8, 0x30
    beq r9, r8, COMECA_ANIMACAO # se o segundo caractere é 0, então acenda led
    movi r8, 0x31
    beq r9, r8, PARA_ANIMACAO # se o segundo caractere é 1, então apaga led
    br CALLBACK

COMECA_ANIMACAO:
        movia r10, STATUS_ANIMACAO
        movi r8, 1
        stw r8, (r10)

        br CALLBACK
PARA_ANIMACAO:
        movia r10, STATUS_ANIMACAO
        movi r8, 0
        stw r8, (r10)
CALLBACK:
    /* reset stack frame */
    ldw r8, 32(sp)
    ldw r9, 28(sp)
    ldw r10, 24(sp)
    ldw r11, 20(sp)
    ldw r12, 16(sp)
    ldw r13, 12(sp)
    ldw r14, 8(sp)
    ldw r15, 4(sp)
    addi sp, sp, 32 # 8 registradores x 4
    /* ********************* */
    ret

    