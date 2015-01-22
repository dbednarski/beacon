#
# Task que imprime fotometria como funcao de HJD/Fase orbital
#
# Voce deve ter saida do phot_pol.cl
#
# Claudia V. Rodrigues - Maio/2003
# 
#

procedure	plota_luz (arqpht)

string	arqpht		{"", prompt="Input pht file"}
string  tempo		{"hjd.lis", prompt="File with time input"}
int	comp		{1,prompt="Number of the comparison star"}
int 	aper		{1,prompt="Ordinal number of the aperture"}
bool	conecta		{no,prompt="Connect the points"}
bool	pontos		{yes ,prompt="Plot points"}
#bool	erros		{yes ,prompt="Plot errorbars"}
string  title		{"", prompt="Title of the graphics"}
bool	phase		{no, prompt="Convert HJD to orbital phase"}
real 	to		{0., prompt="To das efemerides"}
real	per		{0., prompt="Periodo (dias)"}
bool	ffile		{no, prompt="Create hjd,mag file?"}
string	mmagfile	{"", prompt="Name of the hjd,mag file"}
bool	metafile	{no, prompt="Create mc file"}
bool	eps    	        {no, prompt="Create eps file"}

struct  *flist

begin
	real tto,pper
	real tt = 0
	real t[1000],fase[1000]
	int i,j,n,inicio,fim,ccomp,aaper
	string igifile,ttitle,aarqpht,tempofile,hjd,magfile
	bool cconecta,pphase,ppontos,mmetafile,eeps,nofirst,cont
	bool arq

	struct line,linedata
#	struct line,linedata,line2,linedata2
#
	cconecta=conecta
#	eerros=erros
	ppontos=pontos
	ttitle=title
	mmetafile=metafile
	aarqpht=arqpht
	eeps=eps
	pphase=phase
	tto=to
	pper=per
	aaper=aper
	ccomp=comp
	arq=ffile
	magfile=mmagfile
#
	cont=yes
	nofirst=no
#
	igifile = "igi_in"
	tempofile="ttfile"
     	delete(tempofile,ver-)
     	delete("dlist.lixo",ver-)
     	delete("lixo*",ver-)
	delete(magfile,ver-)
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
	n=i-1
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
	   fase[j]=fase[j]/pper
	   fase[j]=mod(fase[j],1)
#	   if (fase[j]<0) fase[j]=fase[j]+1.
	   print (fase[j], >> tempofile)
	  }
	 }
	 else {
          hjd=str(int(t[1]))
 	  for (j=1; j <= n; j+=1) {
           t[j]=t[j]-int(t[j])
	   print (t[j], >> tempofile )
          }
 	 }
#
# Entrando no loop de display
#
#	print ("oi")
	while (cont) {
	if (nofirst) {
	 print("Digite: #star #apertura ")
	 scan(ccomp, aaper)
	}
	else
	  nofirst=yes
#
# deleta versao anterior de arquivo de entrada 
#
     	delete(igifile,ver-)
#
# calculando parametros de entrada do IGI
#
	aaper=aaper+1
	inicio=1+(ccomp-1)*n
	fim=n+(ccomp-1)*n
#	
#
# colocando comandos no arquivo de entrada do IGI
#
	print ("erase", >> igifile)
	print ("ptype 7 3", >> igifile)
        print ("data "//tempofile, >> igifile)
        print ("xcolumn 1", >> igifile)
        print ("data "//aarqpht, >> igifile)
        print ("lines "//inicio//" "//fim, >> igifile
        print ("window 1 1 1", >> igifile)
        print ("ycolumn "//aaper, >> igifile)
	print ("yevaluate -2.5*log10(y)", >> igifile)
	print ("dlist dlist.lixo", >> igifile)
        print ("limits ", >> igifile)
	print ("margin 0.05", >> igifile)
        print ("yflip; box", >> igifile)
        if (pphase)
           print ("xlabel Orbital phase", >> igifile)
           else
           print ("xlabel HJD - "//hjd,>> igifile)
        print ("ylabel \gD(mag)", >> igifile)
        if (ppontos) {
          print ("expand 0.5", >> igifile)
          print ("points", >> igifile)
          print ("expand 1.0", >> igifile)
        }
        if (cconecta)
          print ("connect", >> igifile)
        print ("title "//ttitle//" - Estrela: "//ccomp//" - Apert: "//aaper-1, >>igifile)  
        print ("end", >>igifile)
#     
#     
     	unlearn igi 
     	igi < igi_in
     	print(" ")
     	print("   Average          Sigma           N")
	columns("dlist.lixo",3,outroot="lixo.")
	average < "lixo.3"
	print(" ")  
	if (arq) {
	  delete(magfile,ver-)
	  joinlines(tempo,"lixo.3",out=magfile)
	  }
        delete("dlist.lixo",ver-)
        delete("lixo*",ver-)
        #
#
#
# criando metacode file
#
	if (eeps) 
	  mmetafile=yes
        if (mmetafile) {
          delete(aarqpht//".mc")  
          igi <igi_in, >G aarqpht//".mc"
        }
        if (eeps) {
          delete(aarqpht//".eps",ver-)
          stdplot(aarqpht//".mc",device='epsl')
          sleep 1
          rename ("sgi*.eps",aarqpht//".eps",field="all")
          delete(aarqpht//".mc",ver-)
        }
        #
        delete("dlist.lixo",ver-)
        delete("lixo*",ver-)
        #
        print("Continua? Sim [y]; Nao [n]")
        scan (cont)
        }
     	delete(igifile,ver-)
     	delete(tempofile,ver-)
end
