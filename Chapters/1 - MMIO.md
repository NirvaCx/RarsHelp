## **1 - Memory Mapped Input and Output**
<div style="text-align: justify">

<a href="../index.html">Voltar ao índice</a>

(Entrada e saída mapeada em memória)

### **1.1 Bitmap Display**

**Importante: a notação "0x" antes de números significa que estamos representando-os na base hexadecimal (base 16)**

O bitmap display é uma ferramenta que possibilita a visualização e geração de imagens, modificando píxeis mapeados na memória. Seus endereços são:

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

Os pixels em cada frame do BMD são codificados utilizando 8 bits (ou 1 byte) de memória (Diferentemente dos usuais 24 bits - 1 byte representando a intensidade de cada cor), 

Eles possuem o seguinte formato:<br>
`0bBBGGGRRR`<br>
Ou seja, os dois bits mais significativos codificam a cor azul, os três dispostos no meio codificam a cor verde e os três menos significativos representam o vermelho.

A cor branca, por exemplo, é representada na memória como `0xff`

Note que o endereçamento no RARS é de 8 em 8 bits, então podemos usar `sb` para carregar pixels no display:

```r
li	t0, 0xff000000 # carrega em t0 o endereco do frame 0
li	t1, 0xff # carrega o numero que representa a cor branca
			 # em t1
sb	t1, 0(t0) # poe a cor branca no primeiro pixel
			  # do display, que fica no canto superior
			  # esquerdo
			  
sb	t1, 2(t0) # faz o mesmo no terceiro pixel
```

Note que, com o comando `sw`, podemos salvar quatro píxeis de uma vez. Isso é útil para a renderização de imagens, especialmente imagens cujos tamanhos em largura sejam múltiplos de quatro. Ainda é possível utilizar esse método para a renderização de imagens de outros tamanhos, mas é necessário tomar bastante cuidado para evitar bugs e overflows.

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

### **1.2 - Acessando o Teclado**



<a href="../index.html">Voltar ao índice</a>

</div>