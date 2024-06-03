.equ DATA_REGISTER, 0x10001000 /* endereço do DATA Register */
.equ RVALID_MASK, 0x8000  /* máscara para pegar o valor de RVALID */
.equ DATA_MASK, 0xFF  /* máscara para pegar o valor de DATA (codigo ascii) */
.equ MAX_CHAR, 24
.equ ASCII_ENTER, 10
.equ TIMER, 0x10002000 /* Status Register */

.org 0x20
RTI:
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
/* Exception handler */

    rdctl et, ipending /* Check if external interrupt occurred */
    beq et, r0, GO_BACK /* If zero, check exceptions */
    subi ea, ea, 4 /* Hardware interrupt, decrement ea to execute the interrupted */
    
    /* instruction upon return to main program */

    andi r13, et, 1 /* Check if irq0 asserted */
    beq r13, r0, GO_BACK /* If not, check other external interrupts */
    call TRATA_ANIMACAO /* If yes, go to IRQ1 service routine */
    call TRATA_CRONOMETRO /* If yes, go to IRQ1 service routine */

GO_BACK:
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

    eret /* Return from exception */

.global _start
_start:
    /* configura stack pointer */
    movia sp, 0x10000

    /* ******* seta a contagem do temporizador ******* */
    movia r8, TIMER
    movia r9, 10000000 /* 200ms (50MHz * 200 / 5) */
    # manipulaçao da parte baixa e alta do timer
    andi r10, r9, 0xFFFF
    stwio r10, 8(r8) # parte baixa
    srli r10, r9, 16
    stwio r10, 12(r8) # parte alta
    /* ********************************************** */

    /* ******* ativa a interrupção com PIE e ienable ******* */
    movi r11, 7 /* valor do bit de controle ITO do Control Register */

    # configura botao da interrupção (PB1)
    stwio r11, 4(r8) /* escreve o bit de controle no Control Register */

    # seta a interrupção do TIMER no sistema - IRQ0
    movi r11, 1
    wrctl ienable, r11

    # configura bit PIE do processador
    wrctl status, r11   
    /* *************************************************** */


    movia r9, DATA_REGISTER
    movia r10, RVALID_MASK
    movia r11, DATA_MASK
    movi r14, ASCII_ENTER
    movi r15, MAX_CHAR

POLLING:
    /* print("Entre com o comando: ") */
    movia r8, MESSAGE

    /* ************************************** PRINTA A MENSAGEM ************************************** */
MESSAGE_LOOP:
    ldb r12, (r8) /* pego o conteúdo de r8 (um caractere) */
    beq r12, r0, EXIT_MESSAGE_LOOP /* se o caractere lido for 0, fim da string! */
    stbio r12, (r9) /* imprime na tela o caractere lido */

    addi r8, r8, 1 /* avança um caractere da mensagem */
    br MESSAGE_LOOP

EXIT_MESSAGE_LOOP:
    movia r8, BUFFER

    /* *********************************************************************************************** */

    /* ****************************** LÊ O COMANDO DO USUÁRIO **************************************** */
READING_LOOP:
    ldwio r12, (r9) /* salva o conteúdo do DATA Register */
    and r13, r12, r10 /* salva o valor de RVALID */
    beq r13, r0, READING_LOOP /* o usuário não escreveu nada */

    /* se tem algo escrito, então... */
    and r13, r12, r11 /* mascara para pegar o valor de DATA */
    stbio r13, (r9) /* escrevo na tela */
    /* salvar no buffer na posição i */
    stb r13, (r8)
    addi r8, r8, 1

    /* verificar se é ENTER */
    beq r13, r14, SWITCH

    br READING_LOOP

SWITCH:
    movia r8, BUFFER
    ldb r8, (r8)

CHECK_LED:
    movi r12, 0x30
    bne r8, r12, CHECK_ANIMACAO
    call LED 
    br RESTART_LOOP
CHECK_ANIMACAO:
    movi r12, 0x31
    bne r8, r12, CHECK_CRONOMETRO
    call ANIMACAO 
    br RESTART_LOOP  
CHECK_CRONOMETRO:
    movi r12, 0x32
    bne r8, r12, POLLING
    call CRONOMETRO
    br RESTART_LOOP

RESTART_LOOP:
    br POLLING
    /* volta ao polling */

END:
    br END

.org 0x500
DADOS:

.global BUFFER
BUFFER:
    .skip 6 * 4 /* max. 5 caracteres no buffer (comando + SPACE + ENTER) */

.global STATUS_ANIMACAO 
STATUS_ANIMACAO:
    .word 0 # animacao inicialmente desabilitada

.global LED_ATUAL_ANIMACAO
LED_ATUAL_ANIMACAO:
    .word 1 # o led inicial da primeira animacao eh 0

.global CONTA_CICLO
CONTA_CICLO:
    .word 0 # conta o numero de ciclos de 200ms que teve

.global STATUS_CRONOMETRO 
STATUS_CRONOMETRO:
    .word 0 # animacao inicialmente desabilitada

.align 4
MESSAGE:
    .asciz "Entre com o comando: "
.end