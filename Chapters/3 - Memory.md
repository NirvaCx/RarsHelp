## **3 - Utilizando a Memória**

<div style="text-align: justify">

<a href="./2 - Data.html">2 - Arquivos de Dados e Imagens</a><br>
<a href="../index.html">Voltar ao índice</a>

Os registradores, apesar de rápidos, são de número limitado, e fácilmente estaremos trabalhando com mais dados do que conseguimos lidar utilizando apenas registradores. A memória, nesse caso, pode ser utilizada como uma "Reserva" para dados que não estamos utilizando no momento, mas que precisamos acessar depois.

### **3.1 - Word, Half Word e Byte**

Na seção `.data`, podemos reservar e inicializar espaço utilizando as diretivas `.word`, `.half` e `.byte` - correspondentes a 32, 16 e 8 bits de memória respectivamente. Por exemplo:

```r
.data

.word 0xf7892abe
.half 0xe77c
.byte 0xff
```

Também é possível atribuir labels a cada um desses espaços, permitindo-nos modificar esses valores facilmente. O código abaixo zera os valores na memória:

```r

.data

value1:
.word 3
value2:
.word 2
value3:
.word 1

.text

main:
	# salva o valor do registrador especial "zero"
	# no enderecos dados pelas respectivas labels utilizando t0 
	sw		zero, value1, t0
	sw		zero, value2, t0
	sw		zero, value3, t0

	# encerra o programa
	li	a7, 10
	ecall
```

Outro código interessante que faz a mesma coisa, mas de uma forma diferente:

```r
.data

values:
.word 3
.word 2
.word 1

.text

main:
	la		t0, values
	sw		zero, 0(t0)
	sw		zero, 4(t0)
	sw		zero, 8(t0)
	
	li	a7, 10
	ecall
```

Dessa vez, nós indexamos uma label. Como cada word tem 4 bytes, devemos somar 4 ao índice para acessar a word seguinte. Vamos ver mais um exemplo do mesmo código, dessa vez alterando o valor de t0 para acessar as words seguintes.

```r
.data

values:
.word 3
.word 2
.word 1

.text

main:
	la		t0, values
	sw		zero, 0(t0)
	addi	t0, t0, 4
	sw		zero, 0(t0)
	addi	t0, t0, 4
	sw		zero, 0(t0)
	
	li	a7, 10
	ecall
```

Também podemos reservar uma quantidade arbitrária de bytes em um local na memória de nossa escolha utilizando a diretiva `.space`. Nós não especificamos os dados que serão guardados nesse espaço e, sim, o tamanho desse espaço. Isso é útil, por exemplo, se quisermos criar uma cópia de algum dado na memória para efetuar operações e modificá-lo, sem perder as informações originais. No exemplo abaixo, os espaço é reservado para conter uma cópia temporária de alguma das imagens fornecidas.
```r
.data

.include "background_image_1.data" # 320*240
.include "background_image_2.data" # 320*240
.include "background_image_3.data" # 320*240

# [...]

levelBackground:
.space	76808	# 320 * 240 bytes (quantidade de pixels na imagem) + 2 words (informação de largura e altura)

# [...]
```

A questão agora é como utilizar esse espaço; o código abaixo demonstra como fazer isso, copiando a segunda imagem para o espaço temporário:

```r

# [...]

loadBackground:
	la	s0, background_image_2 # endereco da imagem que vamos carregar
	la	s1, levelBackground # endereco do espaco onde vamos guardar a imagem.
	
	# Note que, para carregar um dado corretamente, o espaco reservado para ele tem que
	# ter exatamente o seu tamanho ou ser maior. Sempre temos que saber o tamanho dos
	# dados com os quais estamos trabalhando em assembly, pois nao ha indicacao concreta
	# na memoria sobre onde algo comeca e outra coisa termina - essas indicacoes sao
	# deliberadas pelo programador.
	
	li	t0, 76808 # tamanho do nosso espaco
	li	t1, 0 # contador
	
	loadBackgroundLoop:
	# enquanto o contador for menor que o espaco disponivel
	bge	t1, t0, loadBackgroundEnd
	
		lb	t3, 0(s0) #t3 vai ser usado para copiar a informacao
		sb	t3, 0(s1) # copia de s0 -> s1
		
		addi s0, s0, 1 # proximo byte de dado
		addi s1, s1, 1
		
		addi t1, t1, 1 # t1++
		
		j	loadBackgroundLoop # continuar o loop
	
loadBackgroundEnd:

# [...]
	
```

<a href="../index.html">Voltar ao índice</a></br>
<a href="./4 - Render.html">4 - Renderização de Imagens</a>

</div>