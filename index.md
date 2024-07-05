# Documentação e referência para o RARS versão UnB
Por Nirva Neves de Macedo, Universidade de Brasília
## **0 - Introdução**
<div style="text-align: justify">
O RARS da UnB apresenta algumas nuâncias e diferenças em relação ao RARS normal (que pode ser baixado do github). Esse documento tem por objetivo sanar dúvidas de alunos da UnB em relação à nossa versão do programa e ajudá-los em geral com a programação em Assembly a nível da disciplina de Introdução aos Sistemas Computacionais.

Esse documento é direcionado para alunos que já compreenderam o básico de Assembly para RISC-V, então é presumido que você já saiba trabalhar com as instruções mais simples e compreenda a estrutura do programa no RARS. O intuito é realmente aprofundar os conhecimentos para possibilitar a realização do projeto final.

É aconselhável testar programas mais extensos no FPGRARS. O RARS é repleto de bugs e nuâncias - programas maiores quebram com bastante facilidade, alguns nem passam da montagem. O FPGRARS não possui essas limitações. Para programas menores, no entanto, vale a pena utilizar o RARS pois ele fornece maiores detalhes sobre a execução.

Ademais, as informações apresentadas nesse texto não são técnicas, nem objetivas. Elas foram formuladas a partir do conhecimento prático da autora, e não são conselhos finais, e o texto está aberto a sugestões de melhorias e retificações técnicas, desde que estas não atrapalhem o entendimento do leitor.

Finalmente, recomendo que vocês acessem o repositório <a href="https://github.com/victorlisboa/LAMAR">Learning Assembly for Machine Architecture and RISC-V (LAMAR)</a>, que é uma compilação de vários outros recursos úteis para  a disciplina de ISC.

### **0.1 - Recursos**

Os materiais e arquivos utilizados neste texto estão disponíveis no repositório <a href="https://github.com/NirvaCx/RarsHelp">RarsHelp</a>, exceto os códigos-fonte, já que basta copiá-los deste texto. Entre em contato ou crie um issue caso você ache que algo está faltando.

### **0.1.1 - Recursos que estão faltando**

O `bmp2oac3` de Linux está faltando - vou recompilar pra Linux uma outra hora. Mas, a princípio, você pode encontrar o código fonte em C dele na pasta *System Rars* no Aprender3 de ISC. Basta compilar o código.

### **0.2 - Índice**

<a href="./Chapters/1 - Memory.html">1 - Utilizando a Memória</a><br>
<a href="./Chapters/2 - Data.html">2 - Arquivos de Dados e Imagens</a><br>
<a href="./Chapters/3 - MMIO.html">3 - Entrada e Saída Mapeada Em Memória</a><br>
<a href="./Chapters/4 - Render.html">4 - Renderização de Imagens</a><br>

</div>