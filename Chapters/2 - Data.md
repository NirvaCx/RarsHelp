## **2 - Inclusão de Arquivos de Dados e Conversão de Imagens para .data**

<div style="text-align: justify">

<a href="./1 - Memory.html">1 - Utilizando a Memória</a><br>
<a href="../index.html">Voltar ao índice</a>

Para trabalharmos com imagens no nosso programa, precisamos primeiro convertê-las para um formato compreensível no nosso nível. A princípio, o programa que iremos utilizar simplesmente converte cada pixel da nossa imagem em números que representam cores correspondentes no formato de 8 bits descrito na seção anterior.

### **2.1 - bmp2oac3**

Efetivamente, esse é o programa que será utilizado para realizar a conversão. No terminal, no diretório correspondente, execute (substituindo `<file>` pelo nome do arquivo de imagem bitmap):
```bash
# para linux (executavel bmp2oac3)
./bmp2oac3 <file>.bmp
# para windows (executavel bmp2oac3.exe)
.\bmp2oac3.exe <file>.bmp
```
Esse comando vai gerar, no mesmo diretório, três arquivos, dos quais o único que nos interessa no momento é o que tem o mesmo nome do arquivo original, com extensão `.data`.

É importante lembrar que o executável tem que estar no mesmo diretório que o arquivo de imagem para o comando funcionar.

Tomamos como exemplo a seguinte imagem `breakable.bmp` (16x16):
<center>
<figure>
<img src="../breakable.bmp" width="200" height="200">
<figcaption><font size = 2 color = "gray">Breakable.bmp</font></figcaption>
</figure>
</center>

Após formatá-la usando bmp2oac3, teremos o seguinte arquivo de texto:
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
Apesar de parecer desorganizado, sua estrutura é bem simples: duas `words` codificam a largura e a altura da imagem, respectivamente. Depois disso, `largura * altura` bytes codificam as cores de cada pixel na imagem. Com apenas essas informações, é possível renderizar a imagem no Bitmap Display

O início do arquivo tem uma label de conveniência com o mesmo nome do arquivo, sem a extensão. Assim, quando incluirmos o arquivo na seção `.data` do nosso código, poderemos acessar essas informações a partir da label correspondente. Falaremos sobre inclusão de arquivos adiante.

### **2.2 - Incluindo Arquivos de Dados no Código Principal**

A inclusão de um arquivo basicamente "insere" os conteúdos do arquivo no texto do seu código implicitamente. Ela é feita utilizando a diretiva `.include` seguida de uma string delimitada por aspas duplas descrevendo o diretório do arquivo relativo ao código fonte. Por exemplo, no código abaixo, queremos incluir `foo.data`, que se encontra no mesmo diretório que nosso código fonte, e `bar.data` que se encontra na pasta `newdir` nesse mesmo diretório.

```r
.data

# external data

.include "foo.data"
.include "newdir/bar.data"

.text
# [...]

```

É boa prática criar labels dentro de arquivos de dados para que tenhamos uma forma geral de acessar um dado externo. Nos nossos arquivos de imagem, teremos as labels criadas para nós, mas é conveniente criar nossos próprios arquivos de dados. Por exemplo, o arquivo a seguir, descrevendo informações de uma fase em um jogo:
```r
# level2_info.data
level2_info:
# enemy amount
.word	2
# enemy positions
# x, y, ID
.byte	
	7, 4, 0,
	16, 11, 1,
	0, 0, 2,
	0, 0, 3,
	0, 0, 4,
	0, 0, 5,
	0, 0, 6,
	0, 0, 7
# [...]
```
Apesar da falta de contexto, sabemos que quando quisermos acessar algum desses dados na execução do código, podemos carregar o endereço de `level2_info` e indexá-lo apropriadamente.

Interessantemente, é possível incluir arquivos de *código* utilizando a `.include`. Isso é útil para organizar seu código, mas tenha cautela ao utilizar esse tipo de técnica.

Após inclusos, e desde que eles tenham as respectivas labels definidas para que sejam acessíveis pelas instruções de leitura e escrita, podemos tratar os dados em arquivos desse tipo como dados normais na memória e formular nosso programa.

<a href="../index.html">Voltar ao índice</a><br>
<a href="./3 - MMIO.html">3 - Entrada e Saída Mapeada em Memória</a>

</div>