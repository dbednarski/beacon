c
c	program phot_pol (ver 1.0 - agosto/1999)
c
c	fortran-iraf para fazer fotometria de campos com calcita
c
c	Usa pccd do Antonio Mario Magalhaes
c
c
c	uso: phot_pol arq_mag
c
c
c Resumo:  
c
c	1. le arquivo com contagens - saida do phot   
c
c
	program phot_pol_e
c
c
c       Numero maximo de aberturas= 18
c       Numero de estrelas=100    *    06 Jun 95    *    VEM - CVR
c
c       ano(# estrelas, pos. lamina, aberturas)
c
	implicit real*8 (a-h, o-z)
	integer i,j,k,nap,nhw,nstars
	dimension ano(100,1000,18), ane(100,1000,18), skyo(100,1000), skye(100,1000)
	dimension an(100,1000,18),dif(100,1000,18)
	dimension ap(18), areao(100,1000,18), areae(100,1000,18), a(60)
	dimension areaso(100,1000),arease(100,1000),antot(100,1000),ceu(100,18)
	dimension ruido(100,18),erro(100,18)
	dimension anos(100,1,18), anes(100,1,18), skyos(100,1), skyes(100,1)
	dimension areasos(100,1),areases(100,1)
	dimension areaos(100,1,18), areaes(100,1,18)
	character*60 arq_in,arq_out
	character*12  image
	character*380 line
c
c
c	lendo parametros da linha de comando
c
	call clnarg(nargs)
	if (nargs.eq.5) then
		call clargc(1,arq_in,ier)
		if (ier.ne.0) goto 100
		call clargc(2,arq_out,ier)
		if (ier.ne.0) goto 100
		call clargi(3,nstars,ier)
		if (ier.ne.0) goto 100
		call clargi(4,nhw,ier)
		if (ier.ne.0) goto 100
		call clargi(5,nap,ier)
		if (ier.ne.0) goto 100
	else
		write(*,*)'No. de parametros incorreto em PHOT_POL'
		write(*,*)' '
		write(*,*)'Uso: phot_pol ??? '
		goto 110
	endif
	
c
c	Verificando se valores de variaveis estao dentro do intervalo
c		permitido
c
	if (nap.gt.18) then
		print*, 'Numero de aberturas fora do limite'
		stop
	end if
	if (nstars.gt.100) then
		print*, 'Numero de estrelas fora do limite'
		stop
	end if
	if (nhw.gt.1000) then
		print*, 'Numero de laminas fora do limite'
		stop
	end if
	
c
c lendo arquivos com fotometria
c
	open(8, file=arq_in, status='old')
c
	do i=1, nhw
		do j=1, nstars
c			print*, j
			read(8,'(a)') line
			image = line(1:index(line,' '))
c			print*, line
			read(line(index(line,' '):),*) (a(l),
     $							l=1,2+3*nap)
c      			print*,a 
c			stop
			skyo(j,i) = a(1)
			areaso(j,i) =a(2)
c			print*
c			print*, skyo(j,i)
c			print*
			if (i.eq.1 .and. j.eq.1) then
				do k=1, nap
					ap(k) = a(2+k)
				end do
			end if
			do k=1, nap
				ano(j,i,k) = a(2+nap+k)
			end do
			do k=1, nap
				areao(j,i,k) = a(2+nap+nap+k)
			end do
c
		     read(8,'(a)') line
			image = line(1:index(line,' '))
			read(line(index(line,' '):),*) (a(l),
     $							l=1,2+3*nap)
		 	skye(j,i) = a(1)
			arease(j,i) = a(2)
			do k=1, nap
			 	ane(j,i,k) = a(2+nap+k)
			end do
			do k=1, nap
				areae(j,i,k) = a(2+nap+nap+k)
			end do
		end do
	end do
c
	close (unit=8)
	
c
c
c	Calculando soma para cada todas as exposicoes
c
c
	open(8, file=arq_out, status='new')
	
	do j=1, nstars
	   do k=1,nap
	   	 anos(j,1,k) = 0.
	   	 anes(j,1,k) = 0.
	   	 areaos(j,1,k) = 0.
	   	 areaes(j,1,k) = 0.
		 do i=1, nhw
		 	anos(j,1,k) = anos(j,1,k) + ano(j,i,k)   
		 	anes(j,1,k) = anes(j,1,k) + ane(j,i,k)   
		 	areaos(j,1,k) = areaos(j,1,k) + areao(j,i,k)   
		 	areaes(j,1,k) = areaes(j,1,k) + areae(j,i,k)   
		 end do
		 areaos(j,1,k) = areaos(j,1,k)/nhw
		 areaes(j,1,k) = areaes(j,1,k)/nhw   
	  end do
	end do
	
	do j=1, nstars
	   	 skyos(j,1) = 0.
	   	 skyes(j,1) = 0.
		 areasos(j,1) = 0.
		 areases(j,1) = 0.
		 do i=1, nhw
		 	skyos(j,1) = skyos(j,1) + skyo(j,i)   
		 	skyes(j,1) = skyes(j,1) + skye(j,i)   
		 	areasos(j,1) = areasos(j,1) + areaso(j,i)   
		 	areases(j,1) = areases(j,1) + arease(j,i) 
		 end do
		 areasos(j,1) = areasos(j,1)/nhw
		 areases(j,1) = areases(j,1)/nhw
	end do
	
c Escreve Resultado

   10 format(a,300G13.5) 
   11 format(a,300G14.8)
c
	do j=1,nstars
		write(8,11) "CCDRAP.o ",skyos(j,1),areasos(j,1),(ap(k),k=1,nap),(anos(j,1,k),k=1,nap),(areaos(j,1,k),k=1,nap)
		write(8,11) "CCDRAP.e ",skyes(j,1),areases(j,1),(ap(k),k=1,nap),(anes(j,1,k),k=1,nap),(areaes(j,1,k),k=1,nap)
	end do
	close(8)
c
	goto 120
100	call imemsg(ier,errmsg)
	write(*,'(''Erro: '',a80)')errmsg
110	stop
120	end
