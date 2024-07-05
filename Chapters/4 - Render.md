## **4 - Renderização de Imagens**
<div style="text-align: justify">

<a href="./3 - MMIO.html">3 - Entrada e Saída Mapeada em Memória</a><br>
<a href="../index.html">Voltar ao índice</a>

Muito provavelmente, a etapa inicial para a realização do projeto é criar um programa que inclua um arquivo de imagem e faça sua renderização. Esta seção irá se aprofundar nesse processo. Utilizaremos o Bitmap Display e nosso programa irá renderizar uma imagem em qualquer posição da tela, e ainda incluirá testes preventivos caso tentemos renderizar uma imagem fora da tela.

### **4.1 - Chamando uma Função**

Retomemos o que aprendemos na seção de dados e na seção anterior. A imagem a ser utilizada será a mesma que foi apresentada antes:

<center>
<figure>
<img src="../breakable.bmp" width="200" height="200">
<figcaption><font size = 2 color = "gray">Breakable.bmp  (16x16)</font></figcaption>
</figure>
</center>

Incluiremos ela no nosso código, na seção de dados, após utilizar o `bmp2oac3` para formatá-la em um arquivo `.data`. Além disso, definiremos variáveis na memória guardando a posição na qual queremos renderizar nossa imagem (x e y). Vamos supor, por exemplo, a posição X = 168, Y = 80:

```r
.data # seção de dados
 
.include "breakable.data"

imageX:
.word 168

imageY:
.word 80

 # [...]
```

Vamos relembrar a estrutura desse arquivo.

```r
# breakable.data
breakable: 
.word 16, 16
.byte 199,11,11,11,11,11,11,11,11,11,11,11,11,11,11,199,
11,11,111,111,183,183,111,111,183,111,111,111,183,183,11,11,
11,111,111,183,23,31,31,183,111,111,23,31,183,31,111,11,
11,111,183,23,31,31,183,111,111,23,31,183,31,183,111,11,
11,183,23,31,31,183,111,111,23,31,183,31,183,111,111,11,
11,103,31,31,183,111,111,23,31,183,31,183,111,111,103,11,
11,183,30,103,103,103,22,30,103,30,103,103,103,30,183,11,
11,183,183,183,183,31,31,183,31,183,183,183,31,31,183,11,
11,183,183,183,31,31,183,31,183,183,183,31,31,31,183,11,
11,183,183,31,31,183,31,183,183,183,31,31,31,31,183,11,
11,183,31,31,183,31,183,183,183,31,31,31,31,31,183,11,
11,183,31,183,31,183,183,183,31,31,31,31,31,31,183,11,
11,255,183,31,183,183,183,31,31,31,31,31,31,183,255,11,
10,13,255,255,255,255,255,255,255,255,255,255,255,255,13,10,
1,13,22,13,22,13,13,13,22,22,22,22,13,13,13,1,
199,1,1,1,1,1,1,1,1,1,1,1,1,1,1,199,
```

Note que o arquivo já nos fornece uma label correspondente `breakable`. Utilizaremos essa label no nosso código para acessar os dados da imagem. Novamente, temos duas words que descrevem a largura e a altura da imagem, seguidas de `largura * altura` bytes descrevendo cada pixel da imagem.

Podemos, agora, escrever o código de renderização. Vamos começar resgatando as variáveis da memória, e vamos definir a função dos registradores:

```r
.text

main:
	
	# Passando argumentos
	la	a0, breakable
	lw	a1, imageX
	lw	a2, imageY
	# Chamando a função
	jal	renderImage
	
	# Terminar programa
	li	a7, 10 
	ecall
	
renderImage:
	# Argumentos da função:
	# a0 terá o endereço inicial da imagem
	# a1 terá a posição X da imagem
	# a2 terá a posição Y da imagem
	ret
```

A instrução `jal` salva no registrador especial de retorno o endereço da próxima instrução, e pula pra outra parte do código. Isso é útil para organizar funções. No contexto de ISC, trabalharemos apenas com funções simples, que não chamam outras funções. Para os curiosos, trabalhar com funções que chamam outras funções requer trabalhar com pilhas, uma estrutura de dados que vocês conhecerão em outra disciplina.

Essa instrução trabalha em conjunto com a função `ret`, que simplesmente pula para a instrução indicada pelo registrador de retorno. Isso significa que a ordem de execução desse código vai ser da forma:

```
main -> renderImage -> continuar main de onde parou

ou seja as instruções vão ser executadas nessa ordem no código acima:

la -> lw -> lw -> jal -> ret -> li -> ecall
```

Note que `main` apenas *chama* a função `renderImage`. Explicitamos isso para esclarecer a estrutura de uma chamada de função em assembly. A partir de agora, trabalharemos apenas com o código dessa função. 

### **4.2 - Carregando as Informações**

O código abaixo realiza as etapas preliminares para começarmos a renderizar a imagem - organizando todas as informações para começar o loop.

```r

renderImage:
	# Argumentos da função:
	# a0 contém o endereço inicial da imagem
	# a1 contém a posição X da imagem
	# a2 contém a posição Y da imagem
	
	
	lw		s0, 0(a0) # Guarda em s0 a largura da imagem
	lw		s1, 4(a0) # Guarda em s1 a altura da imagem
	
	mv		s2, a0 # Copia o endereço da imagem para s2
	addi	s2, s2, 8 # Pula 2 words - s2 agora aponta para o primeiro pixel da imagem
	
	li		s3, 0xff000000 # carrega em s3 o endereço do bitmap display
	
	# [...]

```

### **4.3 - Tratamento de Dados**

Agora, devemos realizar algumas operações com essas informações - principalmente, definir o endereço no bitmap display no qual começaremos a renderizar a imagem, e, além disso, verificar se não estamos tentando renderizar numa posição inválida. Vamos fazer a primeira coisa.

```r

	li		t1, 320 # t1 é o tamanho de uma linha no bitmap display
	mul		t1, t1, a2 # multiplica t1 pela posição Y desejada no bitmap display.
	# Multiplicamos 320 pela posição desejada para obter um offset em relação ao endereço inicial do bimap display correspondente à linha na qual queremos desenhar a imagem. Basta agora obter mais um offset para chegar até a coluna que queremos. Isso é mais simples, basta adicionar a posição X.
	add		t1, t1, a1
	# t1 agora tem o offset completo, basta adicioná-lo ao endereço do bitmap.
	add		s3, s3, t1
	# O endereço em s3 agora representa exatamente a posição em que o primeiro pixel da nossa imagem deve ser renderizado.
	
```

### **4.4 - Prevenção de Bugs**

Vamos agora escrever o código que impede que desenhemos a imagem em uma posição inválida. A lógica é particularmente simples, apesar de o código parecer complicado. Primeiro, verificamos se a posição X ou a posição Y são negativas. Automaticamente isso é inválido.

Depois, verificamos se a posição X somada à largura da imagem ultrapassa 320, ou se a posição Y somada à altura da imagem ultrapassa 240. Em ambos os casos, estaríamos tentando desenhar coisas além das bordas do bitmap display e, portanto, a renderização deve ser abortada.

```r
	blt		a1, zero, endRender # se X < 0, não renderizar
	blt		a2, zero, endRender # se Y < 0, não renderizar
	
	li		t1, 320
	add		t0, s0, a1
	bgt		t0, t1, endRender # se X + larg > 320, não renderizar
	
	li		t1, 240
	add		t0, s1, a2
	bgt		t0, t1, endRender # se Y + alt > 240, não renderizar
	
	# [...]
	
	endRender:
	ret
	
```

### **4.5 - Loop de Renderização**

Finalmente, faremos o loop de renderização. A ideia é simples: iremos iterar por cada pixel na imagem e, simultaneamente, por cada endereço no Bitmap Display correspondente. Copiamos a informação da imagem para o display até chegar no final de uma linha da imagem, adicionamos 320 ao endereço do display para "pular uma linha", e repetimos o processo para cada linha até chegarmos ao final da imagem. Em pseudocódigo:

```
para cada linha na imagem {
	para cada pixel na linha{
		pixel no display = pixel na imagem
	}
}
```
Agora, em assembly:

```r
	
	li		t1, 0 # t1 = Y (linha) atual
	lineLoop:
		bge		t1, s1, endRender # Se terminamos a última linha da imagem, encerrar
		li		t0, 0 # t0 = X (coluna) atual
		
		columnLoop:
			bge		t0, s0, columnEnd # Se terminamos a linha atual, ir pra próxima
			
			lb		t2, 0(s2) # Pega o pixel da imagem
			sb		t2, 0(s3) # Põe o pixel no display
			
			# Incrementa os endereços e o contador de coluna
			addi	s2, s2, 1
			addi	s3, s3, 1
			addi	t0, t0, 1
			j		columnLoop
			
		columnEnd:
		
		addi	s3, s3, 320 # próxima linha no bitmap display
		sub		s3, s3, s0 # reposiciona o endereço de coluna no bitmap display (subtraindo a largura da imagem). Note que essa subtração é necessária - verifique os efeitos da ausência dela você mesmo, montando esse código.
		
		addi	t1, t1, 1 # incrementar o contador de altura
		j		lineLoop
		
	endRender:
	
	ret
```

Isso conclui a função de renderização de uma imagem. Essa implementação é bem básica - no projeto vocês provavelmente vão utilizar mais parâmetros, como por exemplo o frame no qual a imagem deve ser renderizada, uma mecânica para tratar *spritesheets*, entre outras coisas. Abaixo segue o código completo dessa seção:

```r
.data # seção de dados
 
.include "breakable.data"

imageX:
.word 168

imageY:
.word 80

.text # seção de execução

main:
	
	# Passando argumentos
	la	a0, breakable
	lw	a1, imageX
	lw	a2, imageY
	# Chamando a função
	jal	renderImage
	
	# Terminar programa
	li	a7, 10 
	ecall
	
renderImage:
	# Argumentos da função:
	# a0 contém o endereço inicial da imagem
	# a1 contém a posição X da imagem
	# a2 contém a posição Y da imagem
	
	
	lw		s0, 0(a0) # Guarda em s0 a largura da imagem
	lw		s1, 4(a0) # Guarda em s1 a altura da imagem
	
	mv		s2, a0 # Copia o endereço da imagem para s2
	addi	s2, s2, 8 # Pula 2 words - s2 agora aponta para o primeiro pixel da imagem
	
	li		s3, 0xff000000 # carrega em s3 o endereço do bitmap display
	
	li		t1, 320 # t1 é o tamanho de uma linha no bitmap display
	mul		t1, t1, a2 # multiplica t1 pela posição Y desejada no bitmap display.
	# Multiplicamos 320 pela posição desejada para obter um offset em relação ao endereço inicial do bimap display correspondente à linha na qual queremos desenhar a imagem. Basta agora obter mais um offset para chegar até a coluna que queremos. Isso é mais simples, basta adicionar a posição X.
	add		t1, t1, a1
	# t1 agora tem o offset completo, basta adicioná-lo ao endereço do bitmap.
	add		s3, s3, t1
	# O endereço em s3 agora representa exatamente a posição em que o primeiro pixel da nossa imagem deve ser renderizado.

	blt		a1, zero, endRender # se X < 0, não renderizar
	blt		a2, zero, endRender # se Y < 0, não renderizar
	
	li		t1, 320
	add		t0, s0, a1
	bgt		t0, t1, endRender # se X + larg > 320, não renderizar
	
	li		t1, 240
	add		t0, s1, a2
	bgt		t0, t1, endRender # se Y + alt > 240, não renderizar
	
	li		t1, 0 # t1 = Y (linha) atual
	lineLoop:
		bge		t1, s1, endRender # Se terminamos a última linha da imagem, encerrar
		li		t0, 0 # t0 = X (coluna) atual
		
		columnLoop:
			bge		t0, s0, columnEnd # Se terminamos a linha atual, ir pra próxima
			
			lb		t2, 0(s2) # Pega o pixel da imagem
			sb		t2, 0(s3) # Põe o pixel no display
			
			# Incrementa os endereços e o contador de coluna
			addi	s2, s2, 1
			addi	s3, s3, 1
			addi	t0, t0, 1
			j		columnLoop
			
		columnEnd:
		
		addi	s3, s3, 320 # próxima linha no bitmap display
		sub		s3, s3, s0 # reposiciona o endereço de coluna no bitmap display (subtraindo a largura da imagem). Note que essa subtração é necessária - verifique os efeitos da ausência dela você mesmo, montando esse código.
		
		addi	t1, t1, 1 # incrementar o contador de altura
		j		lineLoop
		
	endRender:
	
	ret
```

<center>
<figure>
<img src="../resultado.png">
<figcaption><font size = 2 color = "gray">O resultado do código no Bitmap Display</font></figcaption>
</figure>
</center>

<a href="../index.html">Voltar ao índice</a>
</div>