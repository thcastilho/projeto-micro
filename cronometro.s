.equ PUSH_BUTTON, 0x1000005C
.equ DISPLAY, 0x10000020

.global TRATA_CRONOMETRO
TRATA_CRONOMETRO:
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

    movia r10, STATUS_CRONOMETRO
    ldw r10, (r10)
    beq r10, r0, SAI_CRONOMETRO /* pergunta se o bit de cronometro esta "aceso" */

    movia r8, CONTA_CICLO /* recupero a quantidade de ciclos que ja se passaram */
    ldw r9, (r8)
    movi r10, 5 /* 5 eh a quantidade de ciclos que é necessáiro para alterar o cronometro */
    addi r9, r9, 1 /* somo mais um ciclo */
    stw r9, (r8) /* salvo em memoria */
    blt r9, r10, SAI_CRONOMETRO /* se nao atingiu 5 ciclos, entao nao faço nada */
    # senao...

    /* ADICIONO 1 SEGUNDO NO CRONOMETRO E RESETO O CONTADOR DE CICLOS */

    movi r11, 128

    stw r0, (r8) /* reseto a quantidade de ciclos que ja se passaram */
    
SAI_CRONOMETRO:
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


.global CRONOMETRO
CRONOMETRO:
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
    beq r9, r8, COMECA_CRONOMETRO # se o segundo caractere é 0, então acenda led
    movi r8, 0x31
    beq r9, r8, PARA_CRONOMETRO # se o segundo caractere é 1, então apaga led
    br CALLBACK

COMECA_CRONOMETRO:
        movia r10, STATUS_CRONOMETRO
        movi r8, 1
        stw r8, (r10)

        br CALLBACK
PARA_CRONOMETRO:
        movia r10, STATUS_CRONOMETRO
        movi r8, 0
        stw r8, (r10)

    movia r11, PUSH_BUTTON
    ldw r12, (r11)
    andi r12, r12, 0x02 # mascara pro key1
    
    # adicionar o display de 7 seg tambem
    
    # resetar o key1 aqui #

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
    ret /* Return from the interrupt-service routine */
