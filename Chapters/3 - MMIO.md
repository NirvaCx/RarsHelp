## **3 - Memory Mapped Input and Output**
<div style="text-align: justify">

<a href="./2 - Data.html">2 - Arquivos de Dados e Imagens</a><br>
<a href="../index.html">Voltar ao índice</a>

(Entrada e saída mapeada em memória)

### **3.1 Bitmap Display**

O bitmap display é uma ferramenta que possibilita a visualização e geração de imagens, modificando píxeis mapeados na memória. O BMD possui um espaço especial na memória, que iremos acessar normalmente com as instruções de escrita. Especificamente, são dois espaços, cada um tendo início em:

Bitmap Display (Frame 1): `0xff000000`<br>
Bitmap Display (Frame 2): `0xff100000`

A seleção do frame do bitmap display que está sendo mostrado é feita no alterando o valor armazenado no endereço de memória `0xff200604`
onde o valor `0` significa que o frame sendo mostrado é o primeiro, e o valor `1` indica que o segundo frame está sendo mostrado.

O código abaixo exemplifica uma forma simples de trocar de um frame pro outro:

```r
li	t1, 0xff200604 # t1 tem o endereco de frame
lw	t0, 0(t1) # carrega em t0 o valor contido nesse endereco
# a instrucao xor abaixo, quando aplicada dessa forma,
# ira alternar o bit menos significativo em t1.
# ou seja - se for 1, vira 0, se for 0, vira 1
xori t1, t1, 1
```
Isso é particularmente útil quando queremos mostrar um frame enquanto o próximo ainda está sendo renderizado.

Os pixels em cada frame do BMD são codificados utilizando 8 bits (ou 1 byte) de memória. Eles possuem o seguinte formato:<br>
`0bBBGGGRRR` (A notação `0b` indica que estamos trabalhando com valores na base 2)<br>
Ou seja, os dois bits mais significativos codificam a cor azul, os três dispostos no meio codificam a cor verde e os três menos significativos representam o vermelho.

A cor branca, por exemplo, é representada na memória como `0xff`

Lembre que o endereçamento no RARS é de 8 em 8 bits, então podemos usar `sb` para carregar pixels individualmente no display:

```r
li	t0, 0xff000000 # carrega em t0 o endereco do frame 0
				   # note que quando queremos carregar um endereco
				   # sem utilizar uma label, basta usar a instrucao "load immediate"
li	t1, 0xff # carrega o numero que representa a cor branca
			 # em t1
sb	t1, 0(t0) # poe a cor branca no primeiro pixel
			  # do display, que fica no canto superior
			  # esquerdo
			  
sb	t1, 2(t0) # faz o mesmo no terceiro pixel
```

Note que, com o comando `sw`, podemos salvar quatro píxeis de uma vez. Isso é útil para a renderização de imagens, especialmente imagens cujos tamanhos em largura sejam múltiplos de 4. Ainda é possível utilizar esse método para a renderização de imagens de outros tamanhos, mas é necessário tomar bastante cuidado para evitar overflows.

Botando em prática:

```r
li	t0, 0xff000000
li	t1, 0xff0738c0
# t1 acima codifica quatro bytes, nessa ordem, todos em hexadecimal:
# c0 representa a cor azul
# 38 representa a cor verde
# 07 representa a cor vermelha
# ff representa a cor branca
sw	t1, 0(t0) # vai carregar os quatro pixeis acima contiguamente no
			  # canto superior esquerdo do bitmap.
```

Esse método de renderização é, de fato, quatro vezes mais rápido que o método `sb`.

**Escolhendo a posição de um pixel**

O bitmap display nessa versão possui uma largura de 320 e uma altura de 240, ambas configuráveis. Vamos trabalhar com esse padrão. Por motivos ditáticos, por enquanto, vamos tratar o endereço inicial do primeiro frame `0xff000000` como sendo o endereço `0` (Sem perda de generalidade - os métodos utilizados para o primeiro frame são os mesmos para o segundo!). A primeira linha do bitmap display possui 320 pixels, que são acessados pelos endereços `0 - 319`

É natural se perguntar o que está no endereço `320` - e a resposta é intuitiva: é o primeiro pixel da *segunda* linha. Dessa forma, a aritmética utilizada para determinar a posição de um pixel fica evidente. Temos um número inteiro não negativo que representa a posição do pixel. Suponhamos que esse número seja 5078. A coluna do pixel é dada pelo resto da divisão de 5078 por 320 - que seria a coluna 278. Note que essa é a *279ª* coluna, já que contamos começando pela coluna 0. A linha do pixel seria dada pelo quociente da divisão, que é 15 (ou seja, a 16ª linha!).

Podemos definir essa posição como sendo `15 * 320 + 78` e, de uma forma mais geral, 
`0xffX00000 + (linha * 320) + (coluna)`
onde `coluna` vai de 0 a 319 e `linha` vai de 0 a 239. O `X` maiúsculo no número hexadecimal `0xffX00000` é um dígito que pode ser 0 ou 1, indicando o número do frame a ser utilizado.

O código abaixo gera um pixel branco na linha 79 (80ª linha), coluna 29 (30ª linha). Apesar de ser repetitivo, é importante sempre lembrarmos que começamos a contar as linhas e as colunas pelo 0.

```r
li	t0, 0xff100000 # utilizaremos o segundo frame neste exemplo
li	t1, 320
li	t2, 79
mul	t1, t2, t1 # multiplicamos 320 por 79 e salvamos em t1
li	t2, 29
add	t1, t1, t2 # t1 = (320 * 79) + 29
add	t0, t1, t0 # temos o endereco do novo pixel em t0
li	t1, 0xff # cor branca
sb	t1, 0(t0) # geramos o pixel
```

Fica como exercício ao leitor realizar a operação acima utilizando apenas dois registradores.

**Cor transparente**

Com bastante frequência ao longo do projeto, os alunos lidarão com imagens. Uma nuância da utilização de imagens é que elas sempre são retangulares independentemente do seu conteúdo. Para imprimir polígonos e outras formas que estão em uma imagem retangular na tela, utilizamos a cor "transparente".

Essa cor é o magenta, codificado como `0xc7`. Quando tentamos salvar esse número em qualquer endereço de memória dentro do espaço reservado para o Bitmap Display na memória (de 0xff000000 até 0xff1fffff) ele é ignorado e a memória naquela posição fica inalterada.

Na prática, podemos preencher os espaços vazios na nossa imagem utilizando essa cor. Em codificacão RGB 24 bits, essa cor é dada como `ff00ff` e podemos especificar ela em programas de edicão de imagem como um "plano de fundo" - efetivamente uma tela sobre a qual podemos confeccionar outras imagens, que será ignorada pelo bitmap display.

A renderização de imagens completas no BD será tradada com mais profundidade na seção **4**, mas perceba que entender esta primeira seção é fundamental para conseguir compreender os próximos assuntos. É recomendado que você brinque e mexa no rars.

Fica como exercício ao leitor **criar um programa em Assembly que preencha um frame com uma cor e preencha o outro frame com outra cor, e alterne entre os dois frames repetidamente num intervalo de tempo arbitrário**

*Dica: o código abaixo pausa a execução do código por 500ms (aproximadamente)*

```r
li	a7, 32
li	a0, 500
ecall
```

### **3.2 - Acessando o Teclado**

Para acessar o teclado, precisamos saber se alguma tecla está sendo pressionada, e qual delas está sendo pressionada. Infelizmente, o RARS tem uma taxa de polling dependente na velocidade de entrada do sistema operacional, mas ainda é melhor que nada, e é possível mudar essa configuração. Para fins desse guia, não consideraremos entrada por interrupção.

O endereço de acesso aos dados do teclado são:<br>
`0xff200000` - O primeiro bit indica se alguma tecla está pressionada. Não altere o segundo bit, pois ele que seleciona polling ou interrupção.<br>
`0xff200004` - Código ASCII da tecla pressionada.

O código abaixo exemplifica o uso de entradas no teclado em um menu de um jogo.

```r
# [...]

mainMenuSelect:
		# Código abaixo obtém a entrada
		lw	t0, 0xff200000 # carrega em t0 o endereço do status do teclado.
		lw	t1, 0(t0) # carrega o status do teclado em t1.
		
		andi	t1, t1, 1 # isso é um processo de mascaramento. Apenas queremos saber sobre o primeiro bit de t1, que indica se alguma tecla foi pressionada.
		
		beq	t1, zero, mainMenuSelect # se a tecla ainda não tiver sido pressionada (status 0), continuamos aguardando a entrada.
		
		lb	t1, 4(t0) # estamos acessando o byte guardado em 0xff200004, ou seja, em t0 + 4.
		
		li	t2, 0x031 # Código ASCII do caractere '1'.
		beq	t1, t2, storyScreen # verifica se a tecla pressionada é o número 1. Se sim, pulamos para a próxima parte do código.
		
		li	t2, '2' # Essa notação também é válida. Isso representa o código ASCII do caractere '2'.
		# note a diferença do processo abaixo com o processo acima. é essencialmente a mesma coisa, porém a instrução "j" (jump) tem um alcance maior que a instrução branch.
		# em geral, se estivermos pulando para uma label que está muito longe, é melhor utilizar a instrução jump. Nesse caso, apesar de omitida, a label exitProgram está a aproximadamente 1500 linhas de código de distância! (veja a referência da linguagem de máquina do RISC-V para entender melhor o alcance das instruções de jump e de branch)
		# Portanto, primeiro verificamos se a entrada NÃO foi 2
		# Se não foi, pulamos para "continueMMSelect" que nos retorna ao loop que aguarda a entrada do teclado, essencialmente evitando problemas causados por entradas inválidas como "3" nesse caso.
		# Por outro lado, se foi 2, a instrução seguinte será executada e pularemos para a label exitProgram.
		bne	t1, t2, continueMMSelect
		j	exitProgram
	continueMMSelect:
		j	mainMenuSelect
		
# [...]
```

<a href="../index.html">Voltar ao índice</a><br>
<a href="./4 - Render.html">4 - Renderização de Imagens</a>

</div>