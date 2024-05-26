## **1 - Utilizando a Memória**

<div style="text-align: justify">

<a href="../index.html">Voltar ao índice</a>

Os registradores, apesar de rápidos, são de número limitado, e facilmente estaremos trabalhando com mais dados do que conseguimos lidar utilizando apenas registradores. A memória, nesse caso, pode ser utilizada como uma "Reserva" para dados que não estamos utilizando no momento, mas que precisamos acessar depois. Essa primeira seção é um pouco cansativa, mas entender os conceitos apresentados aqui é o primeiro, e talvez mais importante passo para conseguir realizar o projeto da disciplina.

### **1.1 - Word, Half Word e Byte**

Na seção `.data` do nosso código fonte, podemos reservar e inicializar espaço utilizando as diretivas `.word`, `.half` e `.byte` - correspondentes a 32, 16 e 8 bits de memória respectivamente. Por exemplo:

```r
.data

.word 0xf7892abe
.half 0xe77c
.byte 0xff
```

Também é possível atribuir labels a cada um desses espaços, permitindo-nos modificar esses valores facilmente:

```r
.data

values:

	value1:
	.word 0x000080ff
	
	value2:
	.word 2
	
	value3:
	.word 1
```
**Leitura de valores na memória**

Podemos ler valores da memória e carregá-los em registradores utilizando as instruções `lb`, `lh` e `lw`, que carregam um byte, uma half-word e uma word respectivamente. Note que todos os registradores têm tamanho de uma word, portanto carregar uma half-word ou um byte irá preencher apenas uma parte dos bits do registrador. Isso causa uma ambiguidade quando estamos trabalhando com números que tenham sinal - se carregamos um byte negativo (ou seja, seu bit mais significativo é 1), queremos que, ao carregar ele em um registrador, ele continue sendo negativo. O nome disso é extensão de sinal, e basicamente significa preencher os bits à esquerda do byte no registrador de acordo com o bit de sinal do nosso número. As instruções `lb`, `lh` fazem isso automaticamente. Caso não queiramos extensão de sinal, devemos usar `lbu` e `lhu` (Do inglês "load byte unsigned" e "load half word unsigned" - ou seja, sem sinal).

Veja no código acima a word `value1`. Convertendo pra binário, verificaríamos que esse número é:
```
HEX	   0    0    0    0    8    0    F    F
BIN	0000 0000 0000 0000 1000 0000 1111 1111
	|-------------------:---------:-------| word (32 bits)
						|---------:-------| half-word (16 bits)
								  |-------| byte (8 bits)
```
Vamos observar o comportamento das diferentes instruções de carregamento para esse número. **Importante: lembre-se que o código a ser executado tem que ser escrito na seção** `.text` **!**
```r
# word value1 = 0xff0080ff

lbu		t0, value1 # Nesse caso, a extensao de sinal nao ocorre, e t0 carrega 0x000000ff - 
				   # note que apenas os 8 bits menos significativos (0xff) foram carregados.

lb		t0, value1 # Nesse caso, t0 vai carregar 0xffffffff.
				   # o ultimo bit do numero 0xff eh 1, portanto houve extensao de sinal.

lhu		t0, value1 # t0 carrega 0x000080ff. Perceba que apenas a parte 0x80ff (16 bits) do numero foi considerada - metade da word.

lh		t0, value1 # Aqui, t0 carrega 0xffff80ff. 
				   # houve extensao de sinal nesse caso.

lw		t0, value1 # t0 aqui carrega 0xff0080ff - que seria o dado completo.
```
Isso conclui as instruções de carregamento. Lembre que também podemos copiar dados de um registrador para outro utilizando a instrução `mv <alvo>, <origem>`

*Observação:* o estilo de instrução aprensentado acima na verdade é uma pseudoinstrução. Labels não são acessadas diretamente. O montador do nosso código vai traduzir a instrução `lw t0, value1`, por exemplo, para:
```r
la	t0, value1 # salva o endereco de value1 em t0
lw	t0, 0(t0) # carrega o valor no endereco apontado por t0, no proprio t0
```
Entenderemos a instrução `la` (load address) a seguir.

**Escrita de valores na memória**

A escrita de valores na memória é feita utilizando as instruções `sb`, `sh` e `sw` para salvar bytes, half-words e words respectivamente (o "s" nessas instruções vem do inglês "store"). Não existem instruções sem sinal nesse caso - é esperado que saibamos o tipo de dado que estamos salvando. Para salvarmos, precisamos de *dois* registradores - um que vai conter o dado a ser salvo e outro que vai conter o endereço da memória onde vamos salvar. Para por um endereço da memória em um registrador, utilizamos a instrução `la <registrador>, <label>`. Veja um exemplo desse processo, salvando um byte de valor `69` no endereço de `value3` (veja a nossa seção `.data` um pouco acima).
```r
la		t0, value3 # carregamos o endereco alvo
li		t1, 69 # o valor que iremos salvar
sb		t1, 0(t0) # salva o byte de valor 69 no endereco dado por t0 (value3)
```
Existe uma pseudoinstrução disponível por conveniência das instruções de escrita que diminuem o tamanho do código acima, tornando-o mais legível (similar ao que acontece com as instruções de carregamento):
```r
li		t1, 69
sb		t1, value3, t0 # "salvar o byte de t1 em value3 utilizando t0 como temporario"
```
Os dois codigos acima fazem literalmente a mesma coisa. O código abaixo zera as words dadas pelas labels na memória:
```r
# salva o valor do registrador especial "zero" (lembrando que o valor nesse registrador eh sempre zero)
# no enderecos dados pelas respectivas labels utilizando t0 
sw		zero, value1, t0
sw		zero, value2, t0
sw		zero, value3, t0
```
Quando temos um endereço guardado em um registrador, podemos acessar endereços adjacentes adicionando um índice na instrução de escrita:
```r
la		t0, values
sw		zero, 0(t0) # o proprio endereco de t0
sw		zero, 4(t0) # o endereco 4 bytes a frente de t0
sw		zero, 8(t0) # o endereco 8 bytes a frente de t0
```
Como cada word tem 4 bytes, devemos somar 4 ao índice para acessar a word seguinte (Observação: podemos usar índices negativos para acessar endereços `x` bytes *antes* do endereço guardado). Vamos ver mais um exemplo do mesmo código, dessa vez alterando o valor de t0 ao invés de indexá-lo estaticamente para acessar as words seguintes.
```r
.text

la		t0, values
sw		zero, 0(t0)
addi	t0, t0, 4
sw		zero, 0(t0)
addi	t0, t0, 4
sw		zero, 0(t0)
```

### **1.2 - "Space"  e  Cópia de Dados**

Também podemos reservar uma quantidade arbitrária de bytes em um local na memória de nossa escolha utilizando a diretiva `.space`. Nós não especificamos os dados que serão guardados nesse espaço e, sim, o tamanho desse espaço. Isso é útil, por exemplo, se quisermos criar uma cópia de algum dado na memória para efetuar operações utilizando esses dados, sem perder as informações originais. No exemplo abaixo, os espaço é reservado para conter uma cópia temporária de alguns dados da fase de um jogo.
```r
.data

# [...]

level_1_data: # 5 words
.word 1, 6, 16, -7, 0

level_2_data: # 5 words
.word 2, 2, 5, 6, 0

level_3_data: # 5 words
.word 3, 10, 16, 2, 1

# [...]

levelData:
.space	20	# 5 words = 5 * 4 bytes = 20 bytes

# [...]
```
A questão agora é como utilizar esse espaço. O código abaixo demonstra como fazer isso, copiando dados da segunda fase para o espaço temporário:
```r

# [...]

loadLevel:
	la		s0, level_2_data # endereco dos dados da fase que vamos carregar
	la		s1, levelData # endereco do espaco onde vamos criar a copia desses dados
	
	li		t0, 5 # tamanho do nosso espaco, em words (20 bytes!)
	li		t1, 0 # contador
	
	loadLevelLoop:
	bge		t1, t0, loadLevelEnd # se o contador for igual a 5, significa que copiamos 5 words,
									  # que era nosso objetivo e podemos sair do loop de carregamento.
	
		lw		t3, 0(s0) # t3 vai ser usado para copiar a informacao. Como os dados sao compostos apenas por words,
						  # podemos copiar word por word
		sw		t3, 0(s1) # so -> t3; t3 -> s1
		
		addi 	s0, s0, 4 # proxima word da origem
		addi 	s1, s1, 4 # os enderecos de s0 e s1 tem que "caminhar juntos" para garantir
						  # que estamos copiando os dados nos lugares correspondentes.
		
		addi 	t1, t1, 1 # incrementa o contador
		
		j		loadLevelLoop # continuar o loop
	
loadLevelEnd:

# [...]
	
```
Perceba que nós fizemos a cópia *word por word* utilizando `lw` e `sw` nesse exemplo porque sabíamos que o tamanho do nosso dado era 5 words exatamente, mas você deve ficar atento ao tamanho do espaço de memória com o qual você está trabalhando. A forma mais segura de copiar dados é byte por byte, incrementando os endereços por 1 a cada cópia feita. Isso previne, por exemplo, carregamentos falhos em casos em que o tamanho do dado em bytes não é um múltiplo de 4, e, portanto, perigoso pra ser acessado com words. Reforça-se que é trabalho do programador saber a natureza dos dados na memória. Note também que, para carregar um dado corretamente, o espaço reservado para ele sempre tem que ter exatamente o seu tamanho ou ser maior, caso o contrário iremos acabar acessando pedaços da memória que podem estar sendo usados para outras coisas - não há indicação concreta na memória sobre onde algo termina e outra coisa começa - essas indicações são deliberadas pelo programador quando se programa em assembly.

<a href="../index.html">Voltar ao índice</a></br>
<a href="./2 - Data.html">2 - Arquivos de Dados e Imagens</a>

</div>