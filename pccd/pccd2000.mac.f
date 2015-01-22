	Program PCCD
c
c	Calculo da Polarizacao de Estrelas a partir de
c	fotometria de abertura usando qphot ou apphot.
c
c
c       
c       Numero estrelas        =  2000
c       Numero posicoes lamina =  16    
c       Numero aberturas       =  10 
c
c       ano(# estrelas, pos. lamina, aberturas)
c
	implicit real*8 (a-h, o-z)
	dimension ano(2000,16,10), ane(2000,16,10), skyo(2000,16)
	dimension skye(2000,16)
	dimension ap(10), areao(2000,16,10), areae(2000,16,10)
	dimension a(4000)
	dimension sko(16), ske(16), ao(16), ae(16), areo(16)
	dimension aree(16)
	dimension z(16),areaso(2000,16),arease(2000,16)
        integer nimages
	character*60 filename
	character*12  image
        character*1 calc
	character*1000 line
c
        common/delta/deltatheta,ganho,npsky
c
	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
	print*, '$$$$pccd2000.f VERSION 09/12/02      $$$$$$$$$$$$$'
	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
c
	print*, '*.dat file to reduce: '
	read *, filename
c	filename = filename(1:index(filename,' ')-1) // '.dat'
	print*
	print*, '***** FILENAME = ',filename, '*****'
	print*
c
	print*, '# of stars in the file :'
	read*, nstars
	print*, 'No. of stars : ', nstars
c
	print*, '# of waveplate positions observed :'
	read*, nhw
	print*, 'No. of waveplate positions : ', nhw
c
	print*, '# of apertures observed :'
	read*, nap
	print*, 'No. of apertures observed: ', nap
c
	print*, 'Calcita (c) ou polaroide (p) ?'
	read(*,'(a1)') calc
	print*, 'Calcita (c) ou polaroide (p) ? ',calc 	
c
	print*, 'Readnoise - ADU'
	read*, readnoise
	print*, 'Readnoise - ADU : ',readnoise
c
	print*, 'Gain - e/adu '
	read*, ganho
	print*, 'Gain (e/adu) : ',ganho
c
	print*, 'Delta of angle : '
	read*, deltatheta
	print*, 'Delta of angle : ',deltatheta
c
        if ((calc.eq.'c').or.calc.eq.'C') then
          nimages=2
          else
          if ((calc.eq.'p').or.calc.eq.'P') nimages=1
        end if
c
        print*, 'Number of images of 1 star: ',nimages
c
	open(8, file=filename, status='old')
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
                        if (nimages.eq.2) then
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
                        end if
		end do
	end do
c
	close (unit=8)
c
	print*, 'REDUCAO CCD'
	do j=1,nstars
		print*, 'STAR #',j,' ******************************' 
		do k=1, nap
		        npsky=0.d+0     
			do i=1, nhw
				sko(i)=skyo(j,i)
				if (nimages.eq.2) ske(i)=skye(j,i)
				ao(i)=ano(j,i,k)
				if (nimages.eq.2) ae(i)=ane(j,i,k)
				areo(i)=areao(j,i,k)
				if (nimages.eq.2) aree(i)=areae(j,i,k)
				npsky=npsky+areaso(j,i)+arease(j,i)
			end do
			npsky=npsky/2.
		call polar(ao,ae,nhw,sko,ske,areo,aree,nimages,
     $                      q,u,sigma,sigmatheor,p,theta,z,readnoise)
c
		print*, 'APERTURE = ', ap(k)
		print*,'   Q        U        SIGMA        P    THETA
     $ SIGMAtheor.'
		print 2000, q,u,sigma,p,theta,sigmatheor
		print*
		print*,' Z(I)= Q*cos(4psi(I)) + U*sin(4psi(I))'
		print 3000, (z(l), l=1,nhw)
		print*
c
		end do
	end do
1000	format(a10)
2000	format(1x, 4(f10.6), 2x, f8.2, 2x, f10.6)
3000	format((1x,4(f10.6)))
c
	end
c
	Subroutine polar (ano,ane,n,skyo,skye,areao,areae,nim,
     $			 q,u,sigma,sigmatheor,p,theta,z,readnoise)
c
        implicit real*8 (a-h, o-z)
        integer nim
	dimension ano(n), ane(n), z(n), areao(n), areae(n)
	dimension skyo(n), skye(n)
	dimension psi(16)
c
        common/delta/deltatheta,ganho,npsky
c        
	sumo=0.
	sume=0.
	an=0.
	sky=0.
        r2t=0.
        npstar=0.
c	readnoise=9.86
	r2= readnoise*readnoise
c	deltatheta = 91.8
c        deltatheta = 0.d+0
        raiz=sqrt(2.)
c
	do i=1,n
		psi(i) = 22.5*(i-1)*3.14159/180
		skyoo = skyo(i)*areao(i)
		ano(i) = ano(i) - skyoo
		sumo = sumo + ano(i)
		if (nim.eq.2) then 
                   skyee = skye(i)*areae(i)
		   ane(i) = ane(i) - skyee
		   an = an + (ane(i) + ano(i))/2.
      		   sume = sume + ane(i)
		   sky= sky + (skyee + skyoo)/2.
                   r2t = r2t + r2*(areae(i)+areao(i))/2.
                   npstar = npstar + (areae(i)+areao(i))/2.
                   else
                   r2t = r2t + r2*areao(i)
                   npstar = npstar + areao(i)
                   an = an + ano(i)
                   sky = sky + skyoo
                end if
	end do
	ak = sume / sumo
	an = an / n
	sky = sky / n
        r2t = r2t / n
	r2t = r2t*ganho
c
	sigmatheor = an/sqrt(an + (1 + npstar/npsky)*(sky + r2t))
	sigmatheor = sigmatheor*sqrt(ganho)
	sigmatheor = 1. / sigmatheor
	sigmatheor = sigmatheor / sqrt (float(n))
        if (nim.eq.1.) sigmatheor=sigmatheor*2.
c
	sumz2 = 0.
	q = 0.
	u = 0.
c
	do i=1,n
		if (nim.eq.2) then
                  z(i) = (ane(i) - ano(i)*ak)/(ane(i) + ano(i)*ak)
                  else
                  z(i) = -(ano(i)/an - 1.)
                end if
		sumz2 = sumz2 + z(i) * z(i)
		q = q + z(i) * cos(4*psi(i))
		u = u + z(i) * sin(4*psi(i))
	end do
c
	q = q/(n/2.)
	u = u/(n/2.)
	p = sqrt (q*q + u*u)
	sigma = sqrt ((sumz2/(n/2.) - q*q - u*u)/(n-2.))
	theta = atan(u/q)
        theta = theta*180/3.14159
	if (q.lt.0) then
		theta = theta + 180.
	end if
	if (u.lt.0. .and. q.gt.0) then
		theta = theta + 360.
	end if
	theta = theta/2.
	if (theta.ge.180.) then
		theta = theta -180
	end if
	theta = 180 - theta + deltatheta
	if (theta.ge.180.) then
		theta = theta - 180
	end if
c
	q = p*cos(2*theta*3.14159/180)
	u = p*sin(2*theta*3.14159/180)
c
	return
c
	end
c


