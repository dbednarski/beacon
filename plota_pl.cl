#
# Task que imprime polarizacao como funcao de HJD/Fase orbital
#
# Voce deve ter saida do macrol_lista ou macrol_v
#thet
# Claudia V. Rodrigues - Maio/2003
# 
# Atualizado em Set/2004 - CVR

procedure	plota_pl (macrol)

string	macrol		{"", prompt="Input macrol file"}
string  tempo		{"hjd.lis", prompt="File with time input"}
bool	l2		{yes,prompt="(Y) Half-wave data; (N) quarter-wave"}
bool	pl		{no,prompt="Plot linear polar, if l/4"}
int	datnumber	{8, prompt="Number of images in a datfile"}
bool	conecta		{no,prompt="Connect the points"}
bool	pontos		{yes ,prompt="Plot points"}
bool	erros		{yes ,prompt="Plot errorbars"}
bool	theta		{no, prompt="Plot polarization angle"}
bool 	redund		{yes, prompt="Plot redundant data points"}
string  title		{"", prompt="Title of the graphics"}
bool	phase		{no, prompt="Convert HJD to orbital phase"}
real 	to		{0., prompt="To das efemerides"}
real	per		{0., prompt="Periodo (dias)"}
bool	metafile	{no, prompt="Create mc file"}
bool	eps    	        {no, prompt="Create eps file"}
string	arqout		{"", prompt="Phase, pol file, null to not create"}

struct  *flist
struct  *flist2

begin
	real lixo,pmin,pmax,emax,tto,pper,vmin,vmax,evmax
	real lixo4 = 0
	real tt = 0
	real t1 = 0
	real t2 = 0
	real t3 = 0
	real t4 = 0
	real t5 = 0
	real t[500],tn[500],p[500],ep[500],et[500],fase[500]
	real v[500],ev[500],hhjd[500],tttheta[500]
	string igifile,ttitle,mmacrol,vtmpfile,ttempo,namev
	string tempofile,etfile,hjd,lixos
	bool cconecta,eerros,ppontos,mmetafile,ttheta,rredund,eeps
	bool pphase,ll2,ppl
	struct line,linedata,line2,linedata2
	int i,j,n,ddat
#
	cconecta=conecta
	eerros=erros
	ppontos=pontos
	ttitle=title
	mmetafile=metafile
	mmacrol=macrol
	ddat=datnumber
	ttheta=theta
	rredund=redund
	eeps=eps
	pphase=phase
	tto=to
	pper=per
	ll2=l2
	ppl=pl
#	print (tto)
#	
	igifile = "igi_in"
	tempofile="ttfile"
	etfile="errthfile"
#
# deleta versao anterior de arquivo de entrada 
#
     	delete(igifile,ver-)
     	delete(tempofile,ver-)
     	delete(etfile,ver-)
        delete("dlist.lixo",ver-)
	delete(arqout,ver-)
#	unlearn(rename)
#
# 	Lendo arquivo de entrada com tempos
#
	flist=tempo
	i=1
        while (fscan(flist, line) != EOF) {
         linedata=fscan(line,tt)
         t[i]=tt
         i=i+1
	}
	n=i-ddat
# 
# Se plota HJD, pega parte fracioanario;
# se plota fase orbital, calcula a dita cuja
#
# corrigindo: tempo eh igual media do tempo da primeira imagem e
# da ultima imagem
#
	if (pphase) {
 	  for (j=1; j <= n; j+=1) {
 	   fase[j]=t[j]-tto
# 	   print (fase[j])
	   fase[j]=fase[j]/pper
#	   print (fase[j])
	   if (fase[j]< 0.) {
	        print(mod(fase[j],1))
	   	fase[j]=fase[j]-(int(fase[j])-1)
   	        print (fase[j])
#	   	print(int(fase[j]))
	   }
	   fase[j]=mod(fase[j],1)
#	   print (fase[j])
# 	   print ("oi")
	   print (fase[j], >> tempofile)
	  }
	 }
	 else {
          hjd=str(int(t[1]))
 	  for (j=1; j <= n; j+=1) {
   	   tn[j]=(t[j]+t[j+ddat-1])/2 
           hhjd[j]=tn[j]
           tn[j]=tn[j]-int(tn[j])
	   print (tn[j], >> tempofile )
          }
         }
         t[1]=tn[1]
         t[n]=tn[n]
#	 print (t[1],t[n])
# 
#	
# 	Lendo arquivo de entrada com polarizacao e theta
#
	flist2=mmacrol
	i=1
 #
 	if (ll2) {
	 lixos=fscan(flist2,line2)
         while (fscan(flist2,line2) != EOF) {
          linedata2=fscan(line2,lixo,lixo,t2,t1,t5)
          p[i]=t1
          ep[i]=t2
     	  if (arqout != "") 
            print (hhjd[i],100.*p[i],100.*ep[i],t5, >> arqout)
          i=i+1
   	 }
   	 }
	 else 
	 lixos=fscan(flist2,line2)
         while (fscan(flist2,line2) != EOF) {
          linedata2=fscan(line2,lixos,t3,t4,lixo,lixo,t2,t1,t5)
          v[i]=t3
          ev[i]=t4
          p[i]=t1
          ep[i]=t2
          # print(i)
     	  if (arqout != "") 
            print (hhjd[i],100.*v[i],100.*ev[i],100.*p[i],100.*ep[i],t5, >> arqout)
          i=i+1
	 }
#
 	for (i=1; i <= n; i+=1) {
         if (p[i] != 0.) 
           et[i]=ep[i]/p[i]*28.6479
           else
           et[i]=180.
         print (et[i], >> etfile)
        }
	pmin=p[1]
	pmax=p[1]
	emax=ep[1]
	vmin=v[1]
	vmax=v[1]
	evmax=ev[1]
	for (j=2; j <= n; j+=1) {
	 pmin=min(pmin,p[j])
	 pmax=max(pmax,p[j])
	 emax=max(emax,ep[j])
	 if (ll2 == no) {
	  vmin=min(vmin,v[j])
	  vmax=max(vmax,v[j])
	  evmax=max(evmax,ev[j])
	 }
  	}
  	pmin=pmin-emax
  	pmax=pmax+emax
  	pmin=100.*pmin
  	pmax=pmax*100.
  	vmin=vmin-evmax
  	vmax=vmax+evmax
  	vmin=100.*vmin
  	vmax=vmax*100.
	# print (vmin,vmax)
#
#
# colocando comandos no arquivo de entrada do IGI
#
# se l/2 = yes
#
	if (ll2) {
	print ("erase", >> igifile) 
        print ("data "//tempofile, >> igifile)
        print ("xcolumn 1", >> igifile)
        print ("data "//mmacrol, >> igifile)
	if (ttheta) 
          print ("location .075 .98 0.52 0.94 ", >> igifile)
        else
          print ("window 1 1 1", >> igifile)
        print ("ycolumn 4;ecolumn 3", >> igifile)
        print ("yevaluate y*100.; eevaluate e*100", >> igifile)
        if (pphase)
         print ("limits 0. 1. "//pmin//" "//pmax, >> igifile)
 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//pmin//" "//pmax, >> igifile)
#         print ("limits ", >> igifile)
        if (rredund == no) {
      	 delete(tempofile,ver-)
	 for (j=1; j <= n; j+=1) {
	  if ((frac((real(j)/ddat))) != 0) 
	   if (pphase) 
	     fase[j] = -1.
	     else
	     tn[j]=  0
	  if (pphase)
	   print (fase[j], >> tempofile)
	   else
	   print (tn[j], >> tempofile)
	 }
         print ("data "//tempofile, >> igifile)
         print ("xcolumn 1", >> igifile)
         print ("data "//mmacrol, >> igifile)
        }
        print ("margin 0.050", >> igifile)
        if (ttheta)
          print ("box 0 2", >> igifile)
          else {
          print ("box", >> igifile)
          if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
        } 
#        print ("dlist", >> igifile) 
        print ("ylabel P(%)", >> igifile)
        if (ppontos) { 
	  print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
	  print ("expand 1.0", >> igifile)
        }
        if (eerros) {
	  print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	  print ("expand 1.0", >> igifile)
        }
        if (cconecta)
          print ("connect", >> igifile)
        print ("title "//ttitle, >>igifile)  
	#
	# imprimindo theta
	#
	if (ttheta) {
          print ("location .075 .98 0.10 0.52", >> igifile)
          print ("ycolumn 5", >> igifile)
          print ("data "//etfile, >> igifile)
          print ("ecolumn 1", >> igifile)
          print ("margin 0.5", >> igifile)          
          if (pphase) {
           print ("limits 0. 1. 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel Orbital phase ",>> igifile)
           }
           else {
           print ("limits "//t[1]//" "//t[n]//" 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel HJD - "//hjd,>> igifile)
           }
          print ("ylabel \gq (deg)", >> igifile)
          if (ppontos)  {
	    print ("expand 0.5", >> igifile)
            print ("points", >> igifile)
            print ("expand 1.0", >> igifile)
          }
          if (eerros)  {
 	    print ("expand 0.5", >> igifile)
            print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	    print ("expand 1.0", >> igifile)
          }
          if (cconecta)
            print ("connect", >> igifile)
          }
	}
#
# else abaixo: se ll2 = no
#
	else {
	print ("erase", >> igifile)
	print ("ptype 7 3", >> igifile)
        print ("data "//tempofile, >> igifile)
        print ("xcolumn 1", >> igifile)
        print ("data "//mmacrol, >> igifile)
	if (ppl)
         if (ttheta) 
           print ("location .075 .98 0.66 0.94 ", >> igifile)
           else
           print ("location .075 .98 0.52 0.94", >> igifile)
          else
           print ("window 1 1 1", >> igifile)     
        print ("ycolumn 2;ecolumn 3", >> igifile)     
        print ("yevaluate y*100.; eevaluate e*100", >> igifile)
	print ("dlist dlist.lixo", >> igifile)
        if (pphase)
         print ("limits 0. 1. "//vmin//" "//vmax, >> igifile)
 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//vmin//" "//vmax, >> igifile)
        if (rredund == no) {
      	 delete(tempofile,ver-)
	 for (j=1; j <= n; j+=1) {
	  if ((frac((real(j)/ddat))) != 0) 
	   if (pphase) 
	     fase[j] = -1.
	     else
	     tn[j]=  0
	  if (pphase)
	   print (fase[j], >> tempofile)
	   else
	   print (tn[j], >> tempofile)
	 }
         print ("data "//tempofile, >> igifile)
         print ("xcolumn 1", >> igifile)
         print ("data "//mmacrol, >> igifile)
        }
        print ("margin 0.050", >> igifile)
        if (ppl)
          print ("box 0 2", >> igifile)
          else {
          print ("box", >> igifile)
          if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
          }
        print ("ylabel V(%)", >> igifile)
        if (ppontos) { 
	  print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
   	  print ("expand 1.0", >> igifile)
        }
        if (eerros) {
	  print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	  print ("expand 1.0", >> igifile)
	}
        if (cconecta)
          print ("connect", >> igifile)
        print ("title "//ttitle, >>igifile)  
	#
	# imprimindo pol.linear 
	#
	if (ppl) {
        print ("data "//mmacrol, >> igifile)
        if (ttheta) 
           print ("location .075 .98 0.38 0.66 ", >> igifile)
           else
           print ("location .075 .98 0.10 0.52", >> igifile)
        print ("ycolumn 7;ecolumn 6", >> igifile)     
        print ("yevaluate y*100.; eevaluate e*100", >> igifile)
        if (pphase)
         print ("limits 0. 1. "//pmin//" "//pmax, >> igifile)
 	 else 
         print ("limits "//t[1]//" "//t[n]//" "//pmin//" "//pmax, >> igifile)
        print ("margin 0.050", >> igifile)
        if (theta)
          print ("box 0 2", >> igifile)
          else {
          print ("box", >> igifile)
          if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
          }
        print ("ylabel P(%)", >> igifile)
        if (ppontos) {
	  print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
	  print ("expand 1.0", >> igifile)
	}
        if (eerros) {
       	  print ("expand 0.5", >> igifile)
          print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	  print ("expand 1.0", >> igifile)
	}
        if (cconecta)
          print ("connect", >> igifile)
	#
	# imprimindo theta
	#
	if (ttheta) {
          print ("location .075 .98 0.10 0.38", >> igifile)
          print ("ycolumn 8", >> igifile)
          print ("data "//etfile, >> igifile)
          print ("ecolumn 1", >> igifile)
          if (pphase) {
           print ("limits 0. 1. 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel Orbital phase ",>> igifile)
           }
           else {
           print ("limits "//t[1]//" "//t[n]//" 0. 180. ", >> igifile)
           print ("margin 0.050", >> igifile)
           print ("box", >> igifile)
           print ("xlabel HJD - "//hjd,>> igifile)
           }
          print ("ylabel \gq (deg)", >> igifile)
          if (ppontos) {
	    print ("expand 0.5", >> igifile)
            print ("points", >> igifile)
	    print ("expand 1.0", >> igifile)
          }
          if (eerros) {
	    print ("expand 0.5", >> igifile)
            print ("etype 1; errorbar 2; errorbar -2", >> igifile)
	    print ("expand 1.0", >> igifile)
          }
          if (cconecta)
            print ("connect", >> igifile)
          } # fecha o if theta
         }
	}
        print ("end", >>igifile)
#     
#     
     	unlearn igi 
     	igi < igi_in
#
# criando metacode file
#
	if (eps) {
          delete("dlist.lixo",ver-)
	  mmetafile=yes
          }
        if (mmetafile) {
          delete("dlist.lixo",ver-)
          delete(mmacrol//".mc")  
          igi <igi_in, >G mmacrol//".mc"
        }
        if (eps) {
          delete(mmacrol//".eps",ver-)
          set stdplot = epsl
          stdplot(mmacrol//".mc")
          sleep 1
          rename ("sgi*.eps",mmacrol//".eps",field="all")
          delete(mmacrol//".mc",ver-)
        }
        #
     	delete(igifile,ver-)
     	
   	delete("dlist.lixo",ver-)
     	delete(tempofile,ver-)
     	delete(etfile,ver-)
end
