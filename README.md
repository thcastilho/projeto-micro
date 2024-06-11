# Projeto de Microprocessadores
## 1º semestre de 2024

Neste projeto final seu grupo deve desenvolver um aplicativo console que aceite comandos do usuário e, para cada comando, desempenhe uma certa ação na placa DE2 Altera. O console deve ser implementado via comunicação UART, utilizando a janela terminal do programa Altera Monitor. Ao ser iniciado, seu programa deve mostrar a seguinte frase no terminal:

`Entre com o comando: `


e esperar que o usuário entre com algum comando. Os comandos são compostos por, no máximo, dois inteiros conforme a tabela a seguir.

### Tabela de comandos

| Comando | Ação |
|---------|------|
| 00 xx | Acender xx-ésimo led vermelho. |
| 01 xx | Apagar xx-ésimo led vermelho. |
| 10 | Animação com os leds vermelhos dada pelo estado da chave SW0: se para baixo, no sentido horário; se para cima, sentido anti-horário. A animação consiste em acender um led vermelho por 200ms, apagá-lo e então acender seu vizinho (direita ou esquerda, dependendo do estado da chave SW0). Este processo deve ser continuado repetidamente para todos os leds vermelhos. |
| 11 | Parar animação dos leds. |
| 20 | Inicia cronômetro de segundos, utilizando 4 displays de 7 segmentos. Adicionalmente, o botão KEY1 deve controlar a pausa do cronômetro: se contagem em andamento, deve ser pausada; se pausada, contagem deve ser resumida. |
| 21 | Cancela cronômetro. |

Observe que o enunciado deixa algumas questões em aberto. Por exemplo, o que deve acontecer caso exista um led aceso e um comando de animação seja entrado: perder o estado do led aceso ou restaurá-lo assim que a animação for cancelada? O grupo está livre para escolher a melhor forma de enfrentar essa e outras questões. No entanto, isso deve estar presente no relatório do projeto a ser entregue ao professor no final do semestre.

Para implementação do aplicativo utilize a linguagem de montagem do Nios II e os recursos da DE2 Media Computer.
