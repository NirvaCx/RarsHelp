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
