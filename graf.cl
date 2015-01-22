#
# Ver. Jun07
#

procedure graf (filein,starin,aperturein)

string filein        {prompt="input pccd file (.log)"}
int    starin        {prompt="star number to analyze"}
int    aperturein    {prompt="aperture to analyze"}
bool   postype = no  {prompt="positions of wave-plate are contiguous?"}
bool   metafile = no {prompt="create output metacode file?"}
real   step=22.5     {prompt="wavelength step?"}
struct *flist 

begin

     int    nl = 0
     int    nla = 0
     int    nlaa = 0
     int    nstar = 0
     int    naperture = 0
     real    positions = 0
                  
     int    stars, apertures, apermin, i, j, estar, eaperture,k
     string lix, imagem, file1, file2, file3, file4, file_in, lix1
     struct line, line7, line10, line12, line14, line26, linestar
     struct lineaperture, linedata, line22, line18, line13, line11
     struct linegraf5, linegraf6, linegraf7, linegraf8, line19
     string kq,ku,ks,kp,kt,kst,waveplate,kv,ksv
     real   q,u,s,p,t,st,pi,r1,top1,top2,bot1,bot2,top,bot,v,sv,sfull
     real   z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,z13,z14,z15,z16
     real   m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16
     real   z[16]
     real   m[16] , mm[16], ri[360]
     real   theta_inst, deltatheta, q_inst, u_inst, zerolam, ss, retar
     real   gtau, htau
     real   nhw_used = 0

     z = 0
     estar = starin
     eaperture = aperturein
     
          
     # Inicializa o puntero de lectura 'flist' ao archivo (.log)
     file_in = filein
     imagem = file_in
     flist = file_in

     pi = 3.14159265359



     print("")
     print ("Analyzing file...")
     print("")

     # Comeca letura do archivo (.log) com 'flist'
     while (fscan (flist, line) != EOF) {
         
      
         # Conta o numero de linha
         nl = nl + 1 

         # lee nome de imagem
         #if (nl == 7)
         #    line7 = fscan(line,imagem)


         # lee o numero de estrelas do arquivo de entrada (.log)
         if (nl == 10) {
             line10 = fscan (line, lix, lix, lix, lix, stars)
             if (estar > stars){
	         print("Selected star is out of star range")
		 print("")
                 stop
             } 
         }

         #lee o tipo de lamina retardadora usada
	 if (nl == 11)
	     line11 = fscan(line,lix,lix,lix,waveplate)

	 # lee o numero de posicoes do arquivo de entrada (.log)
         if (nl == 12) 
             line12 = fscan (line, lix, lix, lix, lix, lix, positions)

	 # read the position used from pccdgen output
	 if (nl == 13) {
	 m1  = 0 ; m2  = 0 ; m3  = 0 ; m4  = 0
	 m5  = 0 ; m6  = 0 ; m7  = 0 ; m8  = 0
	 m9  = 0 ; m10 = 0 ; m11 = 0 ; m12 = 0
	 m13 = 0 ; m14 = 0 ; m15 = 0 ; m16 = 0
	 line13 = fscan(line,lix,lix,lix,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,lix,nhw_used)
  	 m[1]  = m1  ; m[2]  = m2  ; m[3]  = m3  ; m[4]  = m4
         m[5]  = m5  ; m[6]  = m6  ; m[7]  = m7  ; m[8]  = m8
	 m[9]  = m9  ; m[10] = m10 ; m[11] = m11 ; m[12] = m12
	 m[13] = m13 ; m[14] = m14 ; m[15] = m15 ; m[16] = m16
	 }


         # lee o numero de aperturas do arquivo de entrada (.log)
         if (nl == 14) 
             line14 = fscan (line, lix, lix, lix, lix, apertures)
             
         # lee tamanho da primeira apertura
         if (nl == 26) {
             line26 = fscan (line, lix, lix, apermin)
             if (eaperture >= apertures+apermin || eaperture < apermin) {
                 print("Selected aperture is out of aperture range")
		 print("")
                 stop
             }
         }

         # lee deltatheta (y retardancia p/ "other")
	 if (nl == 18)
	     line18 = fscan(line, lix1, lix, lix, lix, deltatheta)



	 if (nl == 22) {
             if (lix1 == "Readnoise") {
	      ##line22 = fscan(line, lix, lix, retar, lix, deltatheta)
              line22 = fscan(line, lix, lix, lix, lix, deltatheta)
             }
             else {
             line22 = fscan(line, lix, lix, retar)
             }
	 }

         # lee zerolam
         if (nl == 19)
	         line19 = fscan(line,lix,lix,lix,lix, zerolam)


         # lee numero de estrela 
         if (substr (line,1,5) == " STAR") 
             linestar = fscan(line,lix,lix,nstar,lix) 
         
         
         # lee numero de abertura 
         if (substr (line,1,9) == " APERTURE") 
             lineaperture = fscan(line,lix,lix,naperture)
         
         
              
         if (nstar == estar && naperture == eaperture) {
             nla = nla + 1

             #if (substr (line,1,4) == " NaN") {
             #print("Selected aperture without data...")
             #stop
             #}

	     if ((stridx("n",line)-stridx("a",line) == -1) || (stridx("N",line)-stridx("a",line) == -1)){
             print("Selected aperture without data...")
             stop
             }


             nlaa = nla

             if (nstar >1 && naperture == (apermin + apertures - 1))
                 nlaa = nla - 1 
                 
             if (nlaa == 1)
                 print (" STAR # ",estar)
    
             if (nlaa != 5) print(line)
             
             if (nlaa == 3) { 

	         if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other")) {

                 linedata = fscan(line,v,sv,q,u,s,p,t,st,sfull)


                 theta_inst = 180 - t + deltatheta
                 q_inst = p*cos(2*theta_inst*pi/180)
                 u_inst = p*sin(2*theta_inst*pi/180)
                 print("")
                 if (waveplate == "quarter") {
		   print("    Q_inst   U_inst   deltaTHETA  zerolam")
		   printf("%10.5f %8.5f %8.1f %10.1f",q_inst,u_inst,deltatheta,zerolam,sfull)
		 } 
                 if ((waveplate == "other") || (waveplate == "v0other")) {
		   print("    Q_inst   U_inst   deltaTHETA  zerolam  retardance")
		   printf("%10.5f %8.5f %8.1f %10.1f %10.1f",q_inst,u_inst,deltatheta,zerolam,retar,sfull)
		 }
                 print("")
                 }

		 else {

		 linedata = fscan(line,q,u,s,p,t,st)

                 theta_inst = 180 - t + deltatheta
                 q_inst = p*cos(2*theta_inst*pi/180)
                 u_inst = p*sin(2*theta_inst*pi/180)
                 print("")
                 print("    Q_inst   U_inst   deltaTHETA")
		 printf("%10.5f %8.5f %8.1f",q_inst,u_inst,deltatheta)
		 print("")

		 }
             }

             if (lix1 != "Readnoise") positions = nhw_used

	     if (nlaa == 5) {

		 if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other")) {

                 if (waveplate == "quarter") {
		 print(" Z(I)= Q_inst*cos(2psi(I)+2zerolam)*cos(2psi(I)+2zerolam) +")
		 print("       U_inst*sin(2psi(I)+2zerolam)*cos(2psi(I)+2zerolam) -")
		 print("       V*sin(2psi(I)+2zerolam)")
		 print("")
                 }
                 if (waveplate == "other") {
                 print(" G = 0.5*(1+cos(retar))")
                 print(" H = 0.5*(1-sin(retar))")
		 print(" Z(I)= Q_inst * ( G + H * cos(4*(psi(I)+zerolam)) ) +")
		 print("       U_inst * H * sin(4*(psi(I)+zerolam)) -")
		 print("       V * sin(retar) * sin(2*(psi(I)+zerolam))")
		 print("")
                 }
                 if (waveplate == "v0other") {
                 print(" G = 0.5*(1+cos(retar))")
                 print(" H = 0.5*(1-sin(retar))")
		 print(" Z(I)= Q_inst * ( G + H * cos(4*(psi(I)+zerolam)) ) +")
		 print("       U_inst * H * sin(4*(psi(I)+zerolam))")
		 print("")
                 }
		 }

		 else {

		 print(" Z(I) = Q_inst*cos(4psi(I)) + U_inst*sin(4psi(I))")
                 print("")

		 }
	     }

             if (nlaa == 6) {
		 z1 = 0; z2 = 0; z3 = 0; z4 = 0
                 linegraf5 = fscan(line, z1, z2, z3, z4)
                 z[1] = z1; z[2] = z2; z[3] = z3; z[4] = z4
             }

             if (nlaa == 7 && positions/4 > 1) {
	         z5 = 0; z6 = 0; z7 = 0; z8 = 0
                 linegraf6 = fscan(line, z5, z6, z7, z8)
                 z[5] = z5; z[6] = z6; z[7] = z7; z[8] = z8
             }

             if (nlaa == 8 && positions/4 > 2) {
		 z9 = 0; z10 = 0; z11 = 0; z12 = 0
                 linegraf7 = fscan(line, z9, z10, z11, z12)
                 z[9] = z9; z[10] = z10; z[11] = z11; z[12] = z12
             }

             if (nlaa == 9 && positions/4 > 3) {
	         z13 = 0; z14 = 0; z15 = 0; z16 = 0
                 linegraf8 = fscan(line, z13, z14, z15, z16)
                 z[13] = z13; z[14] = z14; z[15] = z15; z[16] = z16
             }

         }  

     }

 #    file1 = "ajuste"
     file1 = mktemp("tmp$graf") 

     for (i=1; i <= 360; i += 1) {
          if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other")) {
        
          if (waveplate == "quarter") {
	  r1 = q_inst*cos((2*i+2*zerolam)*pi/180)*cos((2*i+2*zerolam)*pi/180) +
	       u_inst*sin((2*i+2*zerolam)*pi/180)*cos((2*i+2*zerolam)*pi/180) -
	       v*sin((2*i+2*zerolam)*pi/180)
          }

          if (waveplate == "other") {
          gtau = 0.5*(1+cos(retar*pi/180))
          htau = 0.5*(1-cos(retar*pi/180))
	  r1 = q_inst*(gtau+htau*cos(4*(i+zerolam)*pi/180)) +
	       u_inst*htau*sin(4*(i+zerolam)*pi/180) -
	       v*sin(retar*pi/180)*sin(2*(i+zerolam)*pi/180)
          }
          if (waveplate == "v0other") {
          gtau = 0.5*(1+cos(retar*pi/180))
          htau = 0.5*(1-cos(retar*pi/180))
	  r1 = q_inst*(gtau+htau*cos(4*(i+zerolam)*pi/180)) +
	       u_inst*htau*sin(4*(i+zerolam)*pi/180)
          }
	  }

	  else {

	  r1 = q_inst*cos(4*i*pi/180) + u_inst*sin(4*i*pi/180)

	  }

	  print (i, r1, >> file1)
	  ri[i] = r1
     }                
     
 #    file2 = "dados"
     file2 = mktemp("tmp$graf")

     if (lix1 == "Readnoise") {
       if (positions == 8 && postype == no)
           for (j=0; j <= 3; j += 1) {
                z[9+j] = z[5+j]
                z[5+j] = 0
           }
     }
     else {
       j=0
       for (k = 1; k <= 16 ; k += 1) {
         if (m[k] == 1) {
             j += 1
             mm[k] = z[j]
         }
         else mm[k] = 0
       }
       for (k=1; k <= 16 ; k += 1) z[k] = mm[k]
     }


#     top1 = sqrt(abs(q)**2 + abs(u)**2)
#     bot1 = -top1

     top1 = 0
     bot1 = 0

     for (i=1; i <= 360; i+=1) {
          if (ri[i] > top1) top1 = ri[i]
	  if (ri[i] < bot1) bot1 = ri[i]
     }

     top2 = 0
     bot2 = 0
          
     for (i = 1; i <= 16; i+= 1) 
          if (z[i] != 0) {
              print (step*(i-1),z[i],s, >> file2)
              if (z[i] > top2)
                  top2 = z[i] 
              if (z[i] < bot2)
                  bot2 = z[i]   
          }        
     

     if (top2 > top1)
         top1 = top2

     if (bot2 < bot1)
         bot1 = bot2

     ss = st
     if (st < s) ss = s

 #    file3 = "igi1"
     file3 = mktemp("tmp$graf")  
 
     print ("erase", >> file3)
     if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other"))
          print ("location .10 1 .10 .70", >> file3)
     else print ("location .10 1 .10 .80", >> file3)
     print ("data "//file2, >> file3)
     print ("xcolumn 1; ycolumn 2; ecolumn 3", >> file3)
     print ("limits 0 361 "//bot1-s//" "//top1+s//"; margin .04", >> file3)
     print ("points", >> file3)
     print ("etype 1; errorbar 2; errorbar -2", >> file3)

     print ("data "//file1, >> file3)
     print ("xcolumn 1; ycolumn 2", >> file3)
     print ("limits 0 361 "//bot1-s//" "//top1+s//"; margin .04", >> file3)
     print ("connect", >> file3)
     print ("ticksize 11.25 45", >> file3)
     print ("notation 0 370 1e-3 2", >> file3)
     print ("expand 1.1; box", >> file3)
     print ("ltype 1; lweight 1", >> file3)
     print ("xlabel '\\\iWaveplate position (degrees)'", >> file3)
     print ("ylabel '\\\iAmplitude of Modulation'", >> file3)

     print ("location .10 1 .80 .93", >> file3)
     print ("expand 1.7", >> file3)
     print ("fillpat 2", >> file3)
     print ("title "//imagem//" star "//estar, >> file3)

     print ("vmove .05 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iQ'", >> file3)
     print ("vmove .15 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iU'", >> file3)
     print ("vmove .25 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iSIGMA'", >> file3)
     print ("vmove .35 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iP'", >> file3)
     print ("vmove .45 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iTHETA'", >> file3)
     print ("vmove .55 .90", >> file3)
     print ("justify 5; expand 1; label '\gD\\\iTHETA'", >> file3)
     print ("vmove .65 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iSIGMAth.'", >> file3)
     print ("vmove .75 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iAPERT.'", >> file3)
     print ("vmove .85 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iQ\\\dinst'", >> file3)
     print ("vmove .95 .90", >> file3)
     print ("justify 5; expand 1; label '\\\iU\\\dinst'", >> file3)



    # q = int(q * 1e5) / 1e5
    # u = int(u * 1e5) / 1e5
    # print (q," ",u)
          
     print ("vmove .05 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",q, >> file3)
     print ("vmove .15 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",u, >> file3)
     print ("vmove .25 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",s, >> file3)
     print ("vmove .35 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",p, >> file3)
     print ("vmove .45 .85", >> file3)
     printf ("justify 5; expand 1; label %8.1f\n",t, >> file3)
     print ("vmove .55 .85", >> file3)
     printf ("justify 5; expand 1; label %8.1f\n",deltatheta, >> file3)
     print ("vmove .65 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",st, >> file3)
     print ("vmove .75 .85", >> file3)
     print ("justify 5; expand 1; label "//eaperture, >> file3)
     print ("vmove .85 .85", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",q_inst, >> file3)
     print ("vmove .95 .85", >> file3)
     printf ("justify 5; expand 1; label %8.5f\n",u_inst, >> file3)

     if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other")){
     print ("vmove .05 .80", >> file3)
     print ("justify 5; expand 1; label '\\\iV'", >> file3)
     print ("vmove .15 .80", >> file3)
     print ("justify 5; expand 1; label '\\\isigmaV'", >> file3)
     print ("vmove .25 .80", >> file3)
     print ("justify 5; expand 1; label '\\\izerolam'", >> file3)
     print ("vmove .35 .80", >> file3)
     print ("justify 5; expand 1; label '\\\irms'", >> file3)
     if ((waveplate == "other") || (waveplate == "v0other")) {
        print ("vmove .45 .80", >> file3)
        print ("justify 5; expand 1; label '\\\itau'", >> file3)
     }
     print ("vmove .05 .75", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",v, >> file3)
     print ("vmove .15 .75", >> file3)
     printf ("justify 5; expand 1; label %10.5f\n",sv, >> file3)
     print ("vmove .25 .75", >> file3)
     printf ("justify 5; expand 1; label %8.1f\n",zerolam, >> file3)
     print ("vmove .35 .75", >> file3)
     printf ("justify 5; expand 1; label %10.7f\n",sfull, >> file3)
     if ((waveplate == "other") || (waveplate == "v0other"))  {
        print ("vmove .45 .75", >> file3)
        printf ("justify 5; expand 1; label %8.1f\n",retar, >> file3)
     }
     }

     
     unlearn igi
 #    igi <igi1
     igi < file3//""
     
     if (metafile == yes) {
          if (access(imagem//".mc")) delete(imagem//".mc")  
          igi < file3//"", >G imagem//".mc"
     }
      
     unlearn igi  
    
           
     delete(file1,ver-)
     delete(file2,ver-)
     delete(file3,ver-)

     flist=""
     
end 
  

 
 
 
 
 


