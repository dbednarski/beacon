	Program PCCD
c
c       Polarimetry reduction
c
c       ***************************************
c
c       Max. number os stars                   =  2000
c       Max. number of positions of waveplates =  16
c       Max. number of apertures               =  10
c
c       ano(# stars, pos. waveplate, apertures)
c
	implicit real*8 (a-h, o-z)
	dimension ano(2000,16,10), ane(2000,16,10), skyo(2000,16), skye(2000,16)
	dimension ap(10), areao(2000,16,10), areae(2000,16,10), a(4000)
	dimension sko(16), ske(16), ao(16), ae(16), areo(16), aree(16)
	dimension z(16),areaso(2000,16),arease(2000,16)
        integer nimages
	character*60 filename
	character*12  image
        character*1 calc
	character*1000 line
	character*7 wavetype
c
        common/delta/deltatheta,ganho,npsky
	common/lamina/zerolam
	common/wavepos/wave(16)
	common/posit/nhw_used,norm,retar
	common/type/typewave
c
	read *, filename
	read*, nstars
	read*, nhw
	read*, nap
	read(*,'(a1)') calc
	if ((calc.eq.'c').or.calc.eq.'C') then
          nimages=2
          else
          if ((calc.eq.'p').or.calc.eq.'P') nimages=1
        end if
	read*, readnoise
	read*, ganho
	read*, deltatheta
	read*, zerolam
	read(*,'(a7)') wavetype
	do i=1, 16
	    read*,wave(i)
	end do
	read*, nhw_used
	read*, norm
        if (wavetype.eq.'other') read*, retar
	if (wavetype.eq.'v0other') read*, retar

	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
	print*, '$$$$$$$$$$$$$ pccd2000gen.f VERSION 16/10/03 $$$$$$$$$$$$$$$$'
	print*, '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
c
	print*, '*.dat file to reduce: '
	print *
	print*, '***** FILENAME = '
	print*, filename
	print *
	print *
	print*, 'No. of stars : ', nstars
	if (wavetype.eq.'half') then
	    print*, 'Waveplate type :  half'
	    typewave = 1
	end if
	if (wavetype.eq.'quarter') then
	    print*, 'Waveplate type :  quarter'
	    typewave = 2
	end if
        if (wavetype.eq.'other') then
	    print*, 'Waveplate type :  other'
	    typewave = 3
	end if
        if (wavetype.eq.'v0other') then
	    print*, 'Waveplate type :  v0other'
	    typewave = 4
	end if
	print*, 'No. of waveplate positions : ', nhw
	print*, 'Waveplate pos. :', (int(wave(i)), i=1,16), ' =',nhw_used
	print*, 'No. of apertures observed: ', nap
	print*, 'Calcite (c) or polaroide (p) ? ', calc
	print*, 'Readnoise - ADU :', readnoise
	print*, 'Gain (e/adu) :', ganho
	print*, 'Delta of angle :', deltatheta
	print*, 'Zero of waveplate :', zerolam
	print*, 'No. of images of 1 star : ', nimages
	if (norm.eq.0) then
	print*, 'normalization included: no'
        else
	print*, 'normalization included: yes'
	end if
        if ((wavetype.eq.'other') .or. (wavetype.eq.'v0other')) then
        print*, 'waveplate retardance: ',retar
        else
        print *
        end if
	print *
c
	open(8, file=filename, status='old')
c
	do i=1, nhw_used
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
		print*, 'STAR #',j,' *********************************************'
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
c
		call polar(ao,ae,nhw,nhw_used,sko,ske,areo,aree,nimages,
     $                      q,u,v,sigma,sigmav,sigmatheor,p,theta,
     $			    z,readnoise,typewave,norm,retar,sigmafull)
c
		if (wavetype.eq.'half') then
		print*, 'APERTURE = ', ap(k)
		print*,'   Q        U        SIGMA        P    THETA
     $ SIGMAtheor.'
		print 2000,q,u,sigma,p,theta,sigmatheor
		print*
		print*,' Z(I)= Q*cos(4psi(I)) + U*sin(4psi(I))'
		print 3000, (z(l), l=1,nhw_used)
		print*
	        end if
c
	        if ((wavetype.eq.'quarter') .or. (wavetype.eq.'other') .or. (wavetype.eq.'v0other') ) then
		print*, 'APERTURE = ', ap(k)
		print*,'    V     SIGMAV      Q        U      SIGMA      P    THETA
     $ SIGMAtheor. rms'
		print 4000, v,sigmav,q,u,sigma,p,theta,sigmatheor,sigmafull
		print*
                if (wavetype.eq.'quarter') then
		print*,' Z(I)= Q*cos(2psi(I))**2 + U*sin(2psi(I))*cos(2psi(I))
     $ - V*sin(2psi(I))'
                end if
                if (wavetype.eq.'other') then
		print*,' Z(I)= Q*(G+H*cos(4psi(I))) + U*H*sin(4psi(I))
     $ - V*sin(ret)*sin(2psi(I))'
                end if
                if (wavetype.eq.'v0other') then
		print*,' Z(I)= Q*(G+H*cos(4psi(I))) + U*H*sin(4psi(I))'
                end if


		print 5000, (z(l), l=1,nhw_used)
		print*
	        end if


c
		end do
	end do
c
1000	format(a10)
2000	format(1x, 4(f10.6), 2x, f8.2, 2x, f10.6)
3000	format((1x,4(f10.6)))
4000	format(f9.5,f9.5,2f9.5,2f9.5,f6.1,f9.5,f11.7)
5000	format((1x,4(f10.5)))
c
	end
c
	Subroutine polar (ano,ane,n,n_used,skyo,skye,areao,areae,nim,
     $			 q,u,v,sigma,sigmav,sigmatheor,p,theta,
     $			 z,readnoise,typewave,norm,retar,sigmafull)
c
	implicit real*8 (a-h, o-z)
        integer nim
	real sumr2,as,bs,cs,hs,fs,gs,det,wq,wu,wv,aa,bb,cc,ff,gg,hh,gtau,htau
	dimension ano(n), ane(n), z(n), areao(n), areae(n)
	dimension skyo(n), skye(n)
	dimension psi(16)
	dimension ano1(16), ane1(16), z1(16), areao1(16), areae1(16)
	dimension skyo1(16), skye1(16)
	dimension a(16), b(16), c(16)
c
        common/delta/deltatheta,ganho,npsky
	common/lamina/zerolam
	common/wavepos/wave(16)
c
	sumo=0.
	sume=0.
	an=0.
	sky=0.
        r2t=0.
        npstar=0.
	r2= readnoise*readnoise
	q=0.
	u=0.
	v=0.
	sumr2=0.
	as=0.
	bs=0.
	cs=0.
	fs=0.
	gs=0.
	hs=0.
	det=0.
        gtau=0.
        htau=0.
c
	i=0

	do j=1,16
c	    print*,ano(j)
c	    print*,wave(j)
            if (wave(j).eq.1) then
               i = i + wave(j)
               ano1(j)    = ano(i)
	       ane1(j)    = ane(i)
	       areao1(j)  = areao(i)
	       areae1(j)  = areae(i)
	       skyo1(j)   = skyo(i)
	       skye1(j)   = skye(i)
	    else
	       ano1(j)    = 0
	       ane1(j)    = 0
	       areao1(j)  = 0
	       areae1(j)  = 0
	       skyo1(j)   = 0
	       skye1(j)   = 0
            end if
c	    print*,ano1(j)
	end do

	do i=1,16
	    skyoo = skyo1(i)*areao1(i)
	    ano1(i) = ano1(i) - skyoo
	    sumo = sumo + ano1(i)
	    if (nim.eq.2) then
                skyee = skye1(i)*areae1(i)
		ane1(i) = ane1(i) - skyee
		
		
		an = an + (ane1(i) + ano1(i))/2.
      		sume = sume + ane1(i)
		sky= sky + (skyee + skyoo)/2.
                r2t = r2t + r2*(areae1(i)+areao1(i))/2.
                npstar = npstar + (areae1(i)+areao1(i))/2.
	    else
                r2t = r2t + r2*areao1(i)
                npstar = npstar + areao1(i)
                an = an + ano1(i)
                sky = sky + skyoo
            end if
	end do
c
	ak = sume / sumo
	an = an / n_used
	sky = sky / n_used
        r2t = r2t / n_used
	r2t = r2t*ganho
	sigmatheor = an/sqrt(an + (1 + npstar/npsky)*(sky + r2t))
	sigmatheor = sigmatheor*sqrt(ganho)
	sigmatheor = 1. / sigmatheor
	sigmatheor = sigmatheor / sqrt (float(n_used))
        if (nim.eq.1.) sigmatheor=sigmatheor*2.
c
c
	do i=1,16
            psi(i) = (22.5*(i-1) + zerolam)*3.14159/180
c
	    if (typewave.eq.1) then
	        a(i) = cos(4.*psi(i))*wave(i)
	        b(i) = sin(4.*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        hs = hs + a(i)*b(i)
            end if
c
	    if (typewave.eq.2) then
	        a(i) = cos(2*psi(i))*cos(2*psi(i))*wave(i)
	        b(i) = sin(2*psi(i))*cos(2*psi(i))*wave(i)
	        c(i) = -1.*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        cs = cs + c(i)*c(i)
	        fs = fs + b(i)*c(i)
	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if

	    if (typewave.eq.3) then
c
                gtau = 0.5*(1+cos(retar*3.14159/180))
                htau = 0.5*(1-cos(retar*3.14159/180))
c
	        a(i) = (gtau + htau*(2*cos(2*psi(i))**2 - 1))*wave(i)
	        b(i) = htau*2*sin(2*psi(i))*cos(2*psi(i))*wave(i)
	        c(i) = -1.*sin(retar)*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
	        cs = cs + c(i)*c(i)
	        fs = fs + b(i)*c(i)
	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if

            if (typewave.eq.4) then
c
                gtau = 0.5*(1+cos(retar*3.14159/180))
                htau = 0.5*(1-cos(retar*3.14159/180))
c
	        a(i) = (gtau + htau*(2*cos(2*psi(i))**2 - 1))*wave(i)
	        b(i) = htau*2*sin(2*psi(i))*cos(2*psi(i))*wave(i)
c	        c(i) = -1.*sin(retar)*sin(2*psi(i))*wave(i)
c
	        as = as + a(i)*a(i)
	        bs = bs + b(i)*b(i)
c	        cs = cs + c(i)*c(i)
c	        fs = fs + b(i)*c(i)
c	        gs = gs + a(i)*c(i)
	        hs = hs + a(i)*b(i)
	    end if

c
	end do
c
        if ((typewave.eq.1) .or. (typewave.eq.4)) then
	    det = as*bs - hs**2
	    wq = det / as
	    wu = det / bs
        end if
c
	if ((typewave.eq.2) .or. (typewave.eq.3)) then
	    aa = bs*cs - fs**2
	    bb = cs*as - gs**2
	    cc = as*bs - hs**2
	    ff = gs*hs - as*fs
	    gg = fs*hs - bs*gs
	    hh = fs*gs - cs*hs
c
	    det = as*aa + hs*hh + gs*gg
	    wq = det / aa
	    wu = det / bb
	    wv = det / cc
c
	end if

c
	do i=1,16
	    if ((typewave.eq.1) .or. (typewave.eq.4)) then
	        if (norm.eq.0) then
		   ak = 1
	        end if
	        if (nim.eq.2) then
		    z1(i) = (ane1(i) - ano1(i)*ak)/(ane1(i) + ano1(i)*ak)
                else
                    z1(i) = -(ano1(i)/an - 1.)
                end if
	    end if
c
	    if ((typewave.eq.2) .or. (typewave.eq.3)) then
	        if (norm.eq.0) then
		   ak = 1
	        end if
		if (nim.eq.2) then
	            z1(i) = (ane1(i) - ano1(i)*ak)/(ane1(i) + ano1(i)*ak)
                else
                    z1(i) = -(ano1(i)/an - 1.)
                end if
	    end if
	end do

	i = 0

	do j=1,16
	    if (wave(j).eq.1) then
              i = i + wave(j)
	      z(i) = z1(j)
	    else
	      z1(j) = 0
            end if
c       print*,z1(j)
	end do

	do i=1,16
	    if ((typewave.eq.1) .or. (typewave.eq.4)) then
	        q = q + z1(i)*(a(i)*bs - b(i)*hs)/det
	        u = u + z1(i)*(b(i)*as - a(i)*hs)/det
	    end if
c
	    if ((typewave.eq.2) .or. (typewave.eq.3))then
	        q = q + z1(i)*(a(i)*aa + b(i)*hh + c(i)*gg)/det
	        u = u + z1(i)*(a(i)*hh + b(i)*bb + c(i)*ff)/det
	        v = v + z1(i)*(a(i)*gg + b(i)*ff + c(i)*cc)/det
	    end if
c
	end do
c
	do i=1,16
	    if ((typewave.eq.1) .or. (typewave.eq.4)) then
	        sumr2 = sumr2 + (q*a(i) + u*b(i) - z1(i))**2
	    end if
c
	    if ((typewave.eq.2) .or. (typewave.eq.3))then
		sumr2 = sumr2 + (q*a(i) + u*b(i) + v*c(i) - z1(i))**2
	    end if
	end do
c
	if  ((typewave.eq.1) .or. (typewave.eq.4)) then
	    sigma  = sqrt(sumr2/(n_used-2.))
	    sigmaq = sigma / sqrt(wq)
	    sigmau = sigma / sqrt(wu)
	    p = sqrt(q**2 + u**2)
c	    sigmap = sqrt( (q*sigmaq/p)**2 +
c     $                    (u*sigmau/p)**2 +
c     $                    2*q*u*sigmaq*sigmau/p**2 )
	    sigma = sigmaq
	end if
c
	if ((typewave.eq.2) .or. (typewave.eq.3)) then
	    sigma  = sqrt(sumr2/(n_used-3.))
	    sigmafull = sigma
c	    print*, sigma
	    sigmaq = sigma / sqrt(wq)
	    sigmau = sigma / sqrt(wu)
	    sigmav = sigma / sqrt(wv)
	    p = sqrt(q**2 + u**2)
	    sigmap = sqrt( (q*sigmaq/p)**2 +
     $	                   (u*sigmau/p)**2 +
     $	                   (2*sigma**2/det)*(hh*q*u/p**2) )
c
	    sigma = sigmap
c            print*, wq
c	    print*, wu
c	    print*, wv

        end if

	theta = atan (u/q)
	theta = theta*180/3.14159
c
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



