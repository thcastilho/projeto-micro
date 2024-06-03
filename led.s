.equ DATA_MASK, 0xFF  /* máscara para pegar o valor de DATA (codigo ascii) */
.equ RED_LED_ADDR, 0x10000000 /* endereço do led vermelho */

.global LED

LED:
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
    beq r9, r8, ACENDE # se o segundo caractere é 0, então acenda led
    movi r8, 0x31
    beq r9, r8, APAGA # se o segundo caractere é 1, então apaga led
    br CALLBACK

ACENDE:
    movi r12, 1

    movia r8, BUFFER # pega o buffer de entrada
    ldb r9, 3(r8) # pega o penultimo numero

    movi r8, 0x31
    bne r9, r8, ADICIONA_1_ACENDE
    ADICIONA_10_ACENDE:
        movi r10, 10
        br SOMA_ULTIMO_ACENDE
    ADICIONA_1_ACENDE:
        movi r10, 0
    SOMA_ULTIMO_ACENDE:
        movia r8, BUFFER # pega o buffer de entrada
        ldb r9, 4(r8) # pega o penultimo numero
        subi r9, r9, 0x30 # transformo em decimal
        add r9, r9, r10  
        sll r12, r12, r9
        
    MOSTRA_LED_ACENDE:
        movia r11, RED_LED_ADDR
        ldw r11, (r11) # pega o conteudo do led vermelho
        or r12, r12, r11 # adiciono apenas o novo bit nos leds
        movia r11, RED_LED_ADDR 
        stwio r12, (r11)

    br CALLBACK 

APAGA:
    addi r12, r0, -2

    movia r8, BUFFER # pega o buffer de entrada
    ldb r9, 3(r8) # pega o penultimo numero

    movi r8, 0x31
    bne r9, r8, ADICIONA_1_APAGA
    ADICIONA_10_APAGA:
        movi r10, 10
        br SOMA_ULTIMO_APAGA
    ADICIONA_1_APAGA:
        movi r10, 0
    SOMA_ULTIMO_APAGA:
        movia r8, BUFFER # pega o buffer de entrada
        ldb r9, 4(r8) # pega o penultimo numero
        subi r9, r9, 0x30 # transformo em decimal
        add r9, r9, r10  
        rol r12, r12, r9
        
    MOSTRA_LED_APAGA:
        movia r11, RED_LED_ADDR
        ldw r11, (r11) # pega o conteudo do led vermelho
        and r12, r12, r11 # adiciono apenas o novo bit nos leds
        movia r11, RED_LED_ADDR 
        stwio r12, (r11)


CALLBACK:
    /* saving on stack frame */
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