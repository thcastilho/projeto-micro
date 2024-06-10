.equ DISPLAY, 0x10000020
.equ PB, 0x10000050

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

    movia r10, PAUSE_CRONOMETRO
    ldw r10, (r10)
    beq r10, r0, SAI_CRONOMETRO /* pergunta se o bit de cronometro esta pausado */

    movia r8, CONTA_CICLO /* recupero a quantidade de ciclos que ja se passaram */
    ldw r9, (r8)
    movi r10, 5 /* 5 eh a quantidade de ciclos que é necessáiro para alterar o cronometro */
    addi r9, r9, 1 /* somo mais um ciclo */
    stw r9, (r8) /* salvo em memoria */
    blt r9, r10, SAI_CRONOMETRO /* se nao atingiu 5 ciclos, entao nao faço nada */
    # se atingiu ...

    /* ADICIONO 1 SEGUNDO NO CRONOMETRO E RESETO O CONTADOR DE CICLOS */

    movi r13, 9 /* movo o numero 9 para um registrador que fará as comparações */

    movi r11, UNIDADE_CRONOMETRO
    ldw r12, (r11) /* carrega a contagem atual de unidade na memória */
    beq r12, r13, SOMA_DEZENA /* se for 9, soma a DEZENA */
    addi r12, r12, 1 /* adiciona mais um segundo na contagem */
    stw r12, (r11)
    br MOSTRA_DISPLAY

SOMA_DEZENA:
    movi r12, 0
    stw r12, (r11) /* muda o valor da unidade na memoria para 0 */

    movi r11, DEZENA_CRONOMETRO
    ldw r12, (r11) /* carrega a contagem atual da dezena na memória */
    beq r12, r13, SOMA_CENTENA /* se for 9, soma a CENTENA */
    addi r12, r12, 1 /* adiciona mais um segundo na contagem */
    stw r12, (r11)
    br MOSTRA_DISPLAY
SOMA_CENTENA:
    movi r12, 0
    stw r12, (r11) /* muda o valor da unidade na memoria para 0 */

    movi r11, CENTENA_CRONOMETRO
    ldw r12, (r11) /* carrega a contagem atual da CENTENA na memória */
    beq r12, r13, SOMA_MILHAR /* se for 9, soma o MILHAR */
    addi r12, r12, 1 /* adiciona mais um segundo na contagem */
    stw r12, (r11)
    br MOSTRA_DISPLAY

SOMA_MILHAR:
    movi r12, 0
    stw r12, (r11) /* muda o valor da unidade na memoria para 0 */

    movi r11, MILHAR_CRONOMETRO
    ldw r12, (r11) /* carrega a contagem atual da MILHAR na memória */
    beq r12, r13, ZERA_MILHAR /* se for 9, soma o MILHAR */
    addi r12, r12, 1 /* adiciona mais um segundo na contagem */
    stw r12, (r11)
    br MOSTRA_DISPLAY
ZERA_MILHAR:
    movi r12, 0
    stw r12, (r11) /* muda o valor da unidade na memoria para 0 */

MOSTRA_DISPLAY:
    movia r13, DISPLAY

        ############ HEX0 ############
    movia r14, code7seg # endereço base do vetor
    movi r13, UNIDADE_CRONOMETRO
    ldw r13, (r13)
    add r14, r14, r13 # calcula endereço efetivo

    ldb r14, (r14)

    movia r13, DISPLAY
    stbio r14, (r13)

        ############ HEX1 ############
    movia r14, code7seg # endereço base do vetor
    movi r13, DEZENA_CRONOMETRO
    ldw r13, (r13)
    add r14, r14, r13 # calcula endereço efetivo

    ldb r14, (r14)

    movia r13, DISPLAY
    stbio r14, 1(r13)
    
        ############ HEX2 ############
    movia r14, code7seg # endereço base do vetor
    movi r13, CENTENA_CRONOMETRO
    ldw r13, (r13)
    add r14, r14, r13 # calcula endereço efetivo

    ldb r14, (r14)

    movia r13, DISPLAY
    stbio r14, 2(r13)

        ############ HEX3 ############
    movia r14, code7seg # endereço base do vetor
    movi r13, MILHAR_CRONOMETRO
    ldw r13, (r13)
    add r14, r14, r13 # calcula endereço efetivo

    ldb r14, (r14)

    movia r13, DISPLAY
    stbio r14, 3(r13)

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


.global TRATA_BOTAO
TRATA_BOTAO:
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
    movia r8, PAUSE_CRONOMETRO
    ldw r9, (r8) # valor do pause
    bne r9, r0, PAUSA # se nao for igual a 0, entao esta em execucao. chamo o pausa
START: 
    # se for igual a 1, entao retoma
    movi r10, 1
    stw r10, (r8) # seta o start
    br RESET
PAUSA:
    stw r0, (r8) # seta o pause
RESET:
    movia r9, PB
    stwio r0, 12(r9) # reseto o botao

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
        movi r8, 1 # ativa o cronometro
        stw r8, (r10)

        movia r10, PAUSE_CRONOMETRO
        movi r8, 1 # despausa o cronometro
        stw r8, (r10)

        movia r13, DISPLAY

            ############ HEX0 ############
        movia r14, code7seg # endereço base do vetor
        movi r13, UNIDADE_CRONOMETRO
        ldw r13, (r13)
        add r14, r14, r13 # calcula endereço efetivo

        ldb r14, (r14)

        movia r13, DISPLAY
        stbio r14, (r13)

            ############ HEX1 ############
        movia r14, code7seg # endereço base do vetor
        movi r13, DEZENA_CRONOMETRO
        ldw r13, (r13)
        add r14, r14, r13 # calcula endereço efetivo

        ldb r14, (r14)

        movia r13, DISPLAY
        stbio r14, 1(r13)
        
            ############ HEX2 ############
        movia r14, code7seg # endereço base do vetor
        movi r13, CENTENA_CRONOMETRO
        ldw r13, (r13)
        add r14, r14, r13 # calcula endereço efetivo

        ldb r14, (r14)

        movia r13, DISPLAY
        stbio r14, 2(r13)

            ############ HEX3 ############
        movia r14, code7seg # endereço base do vetor
        movi r13, MILHAR_CRONOMETRO
        ldw r13, (r13)
        add r14, r14, r13 # calcula endereço efetivo

        ldb r14, (r14)

        movia r13, DISPLAY
        stbio r14, 3(r13)

        br CALLBACK
PARA_CRONOMETRO:
        movia r10, STATUS_CRONOMETRO
        movi r8, 0 # deativa o cronometro
        stw r8, (r10)

        movia r10, PAUSE_CRONOMETRO
        movi r8, 0 # pausa o cronometro
        stw r8, (r10)

        /* zero os valores na memoria */
        movi r13, UNIDADE_CRONOMETRO
        stw r0, (r13)
        movi r13, DEZENA_CRONOMETRO
        stw r0, (r13)
        movi r13, CENTENA_CRONOMETRO
        stw r0, (r13)
        movi r13, MILHAR_CRONOMETRO
        stw r0, (r13)

        /* apaga os valores no display */
        movia r13, DISPLAY
        stbio r0, (r13)
        stbio r0, 1(r13)
        stbio r0, 2(r13)
        stbio r0, 3(r13)

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

code7seg:
.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
/*     0     1     2     3     4     5     6     7     8     9 */