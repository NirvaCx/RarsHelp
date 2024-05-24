## **3 - Utilizando a Memória**

<div style="text-align: justify">

<a href="../index.html">Voltar ao índice</a>

Os registradores, apesar de rápidos, são de número limitado, e fácilmente estaremos trabalhando com mais dados do que conseguimos lidar utilizando apenas registradores. A memória, nesse caso, pode ser utilizada como uma "Reserva" para dados que não estamos utilizando no momento, mas que precisamos acessar depois.

### **3.1 - Word, Half Word e Byte**

Na seção `.data`, podemos reservar espaço utilizando as diretivas `.word`, `.half` e `.byte` - correspondentes a 32, 16 e 8 bits de memória respectivamente. Por exemplo:

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

<a href="../index.html">Voltar ao índice</a>

</div>