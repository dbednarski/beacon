#
# Ver. Agosto de 2011
#

procedure ccdrap_301

bool    intera = no      {prompt="Use interactive selection for objects?"}
int  modo = 2 {min=1,max=2, prompt="1-Register images; 2-Run PHOT"}
int     iw = 1 {prompt="From waveplate position number iw"}
int     fw = 8 {prompt="to waveplate position number fw"}
bool    contiguous = yes {prompt="Positions of wave-plate are contiguous?"}
string  version=".1" {prompt="Version of the output files"}
bool    trim = no {prompt="Trim the image?"}
bool    overscan = no {prompt="Apply overscan strip correction?"}
bool    zerocor = no {prompt="Apply zero level correction?"}
bool    darkcor = no {prompt="Apply dark count correction?"}
bool    flatcor = no {prompt="Apply flat field correction?"}
string  biassec = ""      {prompt=" Overscan strip image section"}
string  trimsec = ""      {prompt=" Trim data section"}
string  zero = ""      {prompt="Zero level calibration image"}
string  dark = ""      {prompt="Dark Count calibration image"}
string  flat = ""      {prompt="Flat field images"}
real    readnoise = 2.12    {prompt="CCD readnoise (adu)"}
real    ganho = 4.      {prompt="CCD gain (e/adu)"}
int     nap = 10         {prompt="phot: number of apertures (maximum 10)"}
string  apertures = "5:14:1" {prompt="phot: List of aperture radii in pixels"}
real    annulus = 30.      {prompt="phot: Inner radius of sky annulus in scale units"}
real    dannulus = 10.      {prompt="phot: Width of sky annulus in scale units"}
real boxsize=7 {prompt="Imalign: Size of the small centering box"}
real bigbox=11 {prompt="Imalign: Size of the big centering box"}
int	reject=30000 {prompt="Reject images with pixel values larger than this value"}
real exptime=0.   {prompt="SWAP: correct exposure time"}
#string  subdir = "temp"      {prompt="sub-directory to create for temporary files"}
string fileexe ="/iraf/extern/beacon/pccd/ccdrap_e.e" {prompt="CCDRAP executable file"}

#string  imgref = ""      {prompt="Input reference image"}
#string  images = ""      {prompt="Input images to align"}
#string  shifts = "shifts" {prompt="shifts file"}
struct *flist1
struct *flist2
struct *flist3

begin

string temp0,temp1, temp2, temp3, temp4, temp5, tempshift, aa, linedata, tempcoord
string xlong, ylong
struct line1, line2
string diret,raiz,lista
string lixo1
string imagem,fileord,fileout
string zeroi,flati,darki
string arq,arqim
string biasseci,trimseci

real   xxx, yyy, xcomp, ycomp, deltax, deltay
real   sky_mean, skysigma_mean, fwhm_mean
real   maxdata

int nframes

bool   bb=no
bool   uselast=no
bool   fileexists
bool   trimi
bool   ver, ver1

int    n=0
int    nlin
int i,j, nw
int nimages
int nstars

bool swap=yes
bool eraseccdproc=yes
bool global=yes

global = no

# A linha abaixo foi apagada junto de demais comentários, e é necessária
trimi = trim 

unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars
unlearn setimpars

zeroi = zero
flati = flat
darki = dark

trimseci = trimsec
if (trimsec == "301b") {
	trimseci = "[15:385,10:270]"
} 
if (trimsec == "301s") {
	trimseci = "[15:200,1:170]"
} 
if (trimsec == "301m") {
	trimseci = "[15:160,1:130]"
}
if (trimsec == "301a") {
	trimseci = "[15:250,1:170]"
}
if (trimsec == "301n") {
	trimseci = "[15:140,1:120]"
}
	
biasseci = biassec
if (biassec == "301b") {
	biasseci = "[*,286:289]"
} 
if (biassec == "301s") {
	biasseci = "[*,186:190]"
} 
if (biassec == "301m") {
	biasseci = "[*,146:150]"
} 
if (biassec == "301a") {
	biasseci = "[*,186:190]"
} 

#unlearn findpars
#unlearn datapars
#datapars.fwhmpsf=fwhmpsf
#datapars.sigma=sigma
temp1 = "a"

if (modo == 2) {
# Step Zero 
# Register the imagens of the first WP position. This is necessary to include
# faint objects in the object's list below

print "# Registering images of  WP position # "//iw//"..."

if (iw <= 9) {
	raiz = "0"//iw
} else {
	raiz = ""//iw
}

#ATUALIZAR
chdir ("p"//raiz//"0")
#chdir ("0"//raiz//"0")

#ATUALIZAR
del (files="p*0000",go_ahead=yes, verify=no, >& "dev$null")
#del (files="0*0000",go_ahead=yes, verify=no, >& "dev$null")

if (swap) {
#ATUALIZAR
# Some imagens that there were alread in directory will be deleted
	imdel (images="p*.fits",go_ahead=yes,verify=no, >& "dev$null")
#	imdel (images="0*.fits",go_ahead=yes,verify=no, >& "dev$null")
#$
#ATUALIZAR
	del (files="pp*,hp*",go_ahead=yes, verify=no, >& "dev$null")
#	del (files="p0*,h0*",go_ahead=yes, verify=no, >& "dev$null")
#$		
#ATUALIZAR
# Run suape script for each p* and generate p*.fits
	!/iraf/extern/beacon/suape "p*"
#	!/Users/carciofi/data/iraf/lna/scripts/suape "p*"
#	!/Users/carciofi/data/iraf/lna/scripts/suape "0*"
}

delete ("TEMP_1.txt", ver-, >& "dev$null")
#$
if (overscan || zerocor ||  darkcor || flatcor || trim) {
	print "# Running ccdproc..."
#ATUALIZAR
	imdel (images="cp*.fits",go_ahead=yes, verify=no, >& "dev$null")
#	imdel (images="c0*.fits",go_ahead=yes, verify=no, >& "dev$null")

#ATUALIZAR
	ccdproc(images="p*.fits",output="c//p*.fits",ccdtype = "",
#	ccdproc(images="0*.fits",output="c//0*.fits",ccdtype = "",
			   noproc=no,fixpix=no,overscan=overscan,trim=trimi,
			   zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
			   fringecor=no,readcor=no,scancor=no,
			   readaxis = "column",biassec=biasseci,trimsec=trimseci,
			   zero=zeroi,flat=flati,dark=darki)
			   
#			delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")
#$

# Delete fits images (maintain only the original files and cp* files)
	if (swap)
#ATUALIZAR
		imdel (images="p*.fits",go_ahead=yes, verify=no, >& "dev$null")
#		imdel (images="0*.fits",go_ahead=yes, verify=no, >& "dev$null")
	} else {
		if (swap) 
#ATUALIZAR
			imrename(oldnames="p*.fits",newnames="c//p*.fits",verbose=no)
#			imrename(oldnames="0*.fits",newnames="c//0*.fits",verbose=no)
		else
#ATUALIZAR
			imcopy(input="p*.fits",output="c//p*.fits",verbose=no)
#			imcopy(input="0*.fits",output="c//0*.fits",verbose=no)
	}

#Search for first image
lista = mktemp("lista")
files("c*.fits", > lista)
flist3 = lista
lixo1 = fscan(flist3, imagem)
delete (lista, ver-, >& "dev$null")
#$   	
	
imstatistics (images = imagem, 
              fields = "max", lower = INDEF, upper = INDEF, 
		    binwidth = 0, format = no, >> "TEMP_1.txt")

flist1 = "TEMP_1.txt"
lixo1 = fscan (flist1, maxdata)
delete ("TEMP_1.txt", ver-, >& "dev$null")
#$

unlearn datapars
datapars.datamin=maxdata*1./10.	
		
delete ("coordtmp", ver-, >& "dev$null")
#$

# DAOFIND IS USED TO OBTAIN A 'DEFAULT COORDINATE' TO ALIGN THE IMAGES IN FIRST DIRECTORY
unlearn daofind
daofind (image=imagem,output="coordtmp",verify="no")

imdel (images="sh*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$

# ALIGN IMAGES USING COORDINATES OBTAINED WITH DAOFIND
if (access("shifts")) {		
	print ("# Using 'shifts' file present in the folder...")
	imalign(input="c*.fits",reference=imagem,
     	   coords="coordtmp",output="sh//c*.fits",shifts="shifts",
		   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
} else {
	imalign(input="c*.fits",reference=imagem,
     	   coords="coordtmp",output="sh//c*.fits",shifts="",
		   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
}
delete ("coordtmp", ver-, >& "dev$null")
#$

	# ERASING C*.FITS, MAINTAINING ONLY ORIGINAL FILES AND SHC*.FITS
imdel (images="c*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$


temp0 = mktemp("sum")//".fits"

imsum (input="shc*.fits",output="../"//temp0,
       title="",hparams="",pixtype="double",calctype="double",option="sum",
	  verbose=no)
		
imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$

		
chdir ("..")

	#Before staring the loop on the WP positions, find the coordinates of
	#input star(s). The first image of the first WP position will be used
	
	
	print("# FIRST STEP: find the coordinate of the star(s).")
	print"# Running DISPLAY ...")
	print("")
	
	display(image=temp0,frame=1)
	
	sleep 1
	
	while (bb == no) {
		
		delete (temp1, ver-, >& "dev$null")
#$
		print("")
		print("Running DAOEDIT ...")
		print("")
		print("1. put the cursor on the BOTTOM image of a object")
		print("2. type <r> to see the profile (in a tek window) and check the position")
		print("3. type <a> to save the position")
		print("4. put the cursor on the top image of a object and repeat 2 and 3")
		print("5. repeat 1 to 4 for another object, if you wish")
		print("6. type <q> to quit of daoedit")
		print("")
		
		temp1 = mktemp("daoedit")
		
		daoedit(image=temp0, icommands="", gcommands="",> temp1)
		
		type (temp1)
		
		print("")
		print("Running TVMARK ...")
		print("")
		
		display(image=temp0,frame=1)
		
		tvmark(1,temp1,label=no,number=yes,radii=15,color=202)
		
		print("")
		print("# Is it correct (yes|no)?")
		aa=scan(bb)
	}
	
	temp2 = mktemp("filecalc")

	unlearn filecalc

print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG",>temp2)

	filecalc.format = "%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"
	filecalc(temp1,"$1;$2;$3;$4;$5",calctyp="double",>>temp2)
#$
	unlearn rename
#	if (modo == "2") {
#		rename(temp2,temp2//".ord")
		rename(temp2,"coordtmp.ord")
#	} else {
#		rename(temp2,"coordtmp.ord")
#		temp2 = "coordtmp"
#	}

	print("")
# BEDNARSKI 06-06-2010: INICIO DAS MODIFICAÇÕES - Criei uma variável que 'contém o endereço' do arquivo de coordenadas (será utilizado posteriormente)
	if (intera == no)
	    tempcoord = "../coordtmp.ord"
	
	type "coordtmp.ord"
	print("")

	unlearn tstat
	tstat("coordtmp.ord",3)
	sky_mean = tstat.mean
	tstat("coordtmp.ord",4)
	skysigma_mean = tstat.mean
	tstat("coordtmp.ord",5)
	fwhm_mean = tstat.mean

	print("")
	print("Mean values")
	print("sky      : ",sky_mean)
	print("skysigma : ",skysigma_mean)
	print("fwhm     : ",fwhm_mean)	


}
#
# FIM do if (modo == 2)
#



# HERE THE LOOP OF THE WP POSITIONS BEGINS. THE COORDINATE FILE GENERATED
# BEFORE (STORED IN TEMP2) WILL BE USED
	for (i = iw; i <= fw; i += 1) {
		nw = i
		if (contiguous == no) {
			if (i >= 5 && i <=8) {
				nw = nw+4
			}
		}
		if (nw <= 9) {
			raiz = "0"//nw
		} else {
			raiz = ""//nw
		}
		
#ATUALIZAR
		diret = "p"//raiz//"0"
#		diret = "0"//raiz//"0"
		
		fileout = "../sum"//raiz//version//".dat"
		
		print ""
		print ""
		print "# Processing images for waveplate position # "//nw
				
		chdir (diret)
		
		print "# Erasing first image..."
		
#ATUALIZAR
		del (files="p*0000",go_ahead=yes, verify=no, >& "dev$null")
#		del (files="0*0000",go_ahead=yes, verify=no, >& "dev$null")

		if (swap) {
#ATUALIZAR
			imdel (images="p*.fits",go_ahead=yes, 
#			imdel (images="0*.fits",go_ahead=yes, 
		     	  verify=no, >& "dev$null")
#$		
			print "# Performing bit swap"
#ATUALIZAR
			del (files="pp*,hp*",go_ahead=yes, verify=no, >& "dev$null")
#			del (files="p0*,h0*",go_ahead=yes, verify=no, >& "dev$null")

#ATUALIZAR
			swap(files="p*",exptime=exptime)
#			swap(files="0*",exptime=exptime)
		}

#		if (overscan || zerocor ||  darkcor || flatcor) {
#			print "# Updating image headers..."
#			hedit(images="p*.fits",fields="imagetyp",value="object",
#			      add=yes,addonly=no,delete=no,verify=no,
#				 show=no,update=yes)
#		}
			 
		imdel (images="c*.fits",go_ahead=yes, 
		       verify=no, >& "dev$null")
#$
		if (overscan || zerocor ||  darkcor || flatcor || trim) {
			print "# Running ccdproc..."

#ATUALIZAR
			ccdproc(images="p*.fits",output="c//p*.fits",ccdtype = "",
#			ccdproc(images="0*.fits",output="c//0*.fits",ccdtype = "",
			   noproc=no,fixpix=no,overscan=overscan,trim=trimi,
			   zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
			   fringecor=no,readcor=no,scancor=no,
			   readaxis = "column",biassec=biasseci,trimsec=trimseci,
			   zero=zeroi,flat=flati,dark=darki)
			   
#			delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")
#$
			if (swap) {
# Delect fits images (maintain only the original files)
#ATUALIZAR
				imdel (images="p*.fits",go_ahead=yes, verify=no, >& "dev$null")
#				imdel (images="0*.fits",go_ahead=yes, verify=no, >& "dev$null")
			}

		} else {
			if (swap) 
#ATUALIZAR
			   imrename(oldnames="p*.fits",newnames="c//p*.fits",verbose=no)
#			   imrename(oldnames="0*.fits",newnames="c//0*.fits",verbose=no)
			else
#ATUALIZAR
			   imcopy(input="p*.fits",output="c//p*.fits",verbose=no)
#			   imcopy(input="0*.fits",output="c//0*.fits",verbose=no)
		}
		
# Begining the code section to erase images with pixel values larger than reject

		arq = mktemp ("tmpvar")

# BEDNARSKI 26-12-09: Modificada a linha abaixo, retirando o .fits dos arquivos de flist2 para refazer o laço logo em seguida
		files ("cp*", > arq)
		flist2 = arq

# ALEX 24-05-10: Solução para calcular nframes
		nframes = 0

# BEDNARSKI 26-12-09: Refeito o laço de maneira alternativa
		while (fscan(flist2, arqim) != EOF) {

			nframes = nframes + 1
#			delete ("TEMP_1.txt", ver-, >& "dev$null")
#$
			imstatistics (images = arqim, 
		              fields = "max", lower = INDEF, upper = INDEF, 
				    binwidth = 0, format = no, > "TEMP"//arqim//".txt")
			flist1 = "TEMP"//arqim//".txt"
			lixo1 = fscan (flist1, maxdata)
#			print ("Count to ", arqim, ": ", maxdata)
			delete ("TEMP"//arqim//".txt", ver-, >& "dev$null")
#$
			if (maxdata > reject) {
				imdel (images="c"//arqim//".fits",go_ahead=yes, verify=no, >& "dev$null")
#$
				print "# WARNING! Image:"
				print (arqim, ".fits")
				print ("has pixel values out of bounds: ", maxdata)
				print "Deleting the corresponding CCDPROC image. "
			}
	  	}
		delete (arq, ver-, >& "dev$null")
#$		


# BEDNARSKI 04-06-2010: Comentei o 'if modo' para que a opção do intera se aplique a qualquer modo
#		if (modo == 1) {
		
		if (intera) {
			temp2 = "../coordtmp.ord"

#Search for first image
			lista = mktemp("lista")
			files("c*.fits", > lista)
			flist3 = lista
			lixo1 = fscan(flist3, imagem)
			delete (lista, ver-, >& "dev$null")
#$   	
			fileexists = access("ccdrapcoord.ord")
			if (fileexists==yes) {
# There exists a coordinate list from a previous run.
				   print("# Using coordinate file from a previous run...")
				   delete (temp2, ver-, >& "dev$null")
#$				
				   copy("ccdrapcoord.ord","../coordtmp.ord", ver-, >& "dev$null")
#$
				   uselast = yes
#				   temp1 = "../coordtmp.ord"
			} else {
  			   	print("# Using coordinate file from the previous WP position...")
				uselast = yes
#				temp1 = "../coordtmp.ord"

# BEDNARSKI 23-06-2010: Se for a primeira posição de lâmina, não usa a coordenada anterior, desde que o modo seja 1, pois se 2, há sim coordenada anterior, obtida no if (modo==2) que inicia na linha 131
				if (i == iw && modo == 1) {
#					temp1 = "a"
					uselast = no
				}
			}

		     bb = no
		   	while (bb == no) {
				   if (uselast == no) {
			
#				   delete (temp1, ver-, >& "dev$null")
#$   	
				   display(image=imagem,frame=1)
				   sleep 1
				   
				   print("")
				   print("Running DAOEDIT ...")
				   print("")
				   print("1. put the cursor on the bottom image of a object")
				   print("2. type <r> to see the profile (in a tek window) and check the position")
				   print("3. type <a> to save the position")
				   print("4. put the cursor on the top image of a object and repeat 2 and 3")
				   print("5. repeat 1 to 4 for another object, if you wish")
				   print("6. type <q> to quit of daoedit")
				   print("")
				   beep
				   
				   
				   temp1 = mktemp("../daoedit")
				   
				   daoedit(image=imagem, icommands="", gcommands="",> temp1)
				   
				   type (temp1)
				   
				   delete (temp2, ver-, >& "dev$null")
#$
				   rename(files=temp1,newname=temp2,field="all")
				   
				   } else {
				   		uselast = no
						display(image=imagem,frame=1)
				   }
				   
				   print("")
				   print("Running TVMARK ...")
				   print("")
				   				   
				   tvmark(1,temp2,label=no,number=yes,radii=15,color=202)
				   
				   print("")
				   print("# Is it correct (yes|no)?")
				   aa=scan(bb)
		   	}
	

#			unlearn filecalc
#print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG",>temp2)
#			filecalc.format = "%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"
#			filecalc(temp1,"$1;$2;$3;$4;$5",calctyp="double",>>temp2)
#$

#Update the file ccdrapcoord.ord
			delete ("ccdrapcoord.ord", ver-, >& "dev$null")
#$
			copy(temp2,"ccdrapcoord.ord",ver-, >& "dev$null")
#$

# BEDNARSKI 06-06-2010: grava as coordenadas de cada posição de lâmina em um arquivo principal
# Na primeira posição de lâmina, exclui eventual arquivo no diretório
			if (i == iw)
				delete ("../coord"//version//".ord", ver-, >& "dev$null")
			print ("Directory: ", diret, >> "../coord"//version//".ord")
			cat ("ccdrapcoord.ord", >> "../coord"//version//".ord")
			print ("", >> "../coord"//version//".ord")

# BEDNARSKI 06-06-2010: a variável tempcoord 'contém o endereço' do arquivo de coordenadas que será utilizado a partir do if da linha 700
			tempcoord = "ccdrapcoord.ord"
		
		}
#
# FIM do if (intera)
#


# BEDNARSKI 04-06-2010: No lugar do else para o "if (intera)", acrescentei novos ifs para deixar adequado.
		# In case modo == 1
		if (modo == 1) {

# BEDNARSKI 04-06-2010: No caso de intera == no, executa os procedimentos abaixo (para o modo == 1)
		    if (intera == no) {

#Search for first image
 			lista = mktemp("lista")
			files("c*.fits", > lista)
			flist3 = lista
			lixo1 = fscan(flist3, imagem)
			delete (lista, ver-, >& "dev$null")
#$   	
			fileexists = access("ccdrapcoord.ord")
			if (fileexists==yes) {
				print("# Using coordinate file from a previous run...")
				delete ("../coordtmp.ord", ver-, >& "dev$null")
#$				
				copy("ccdrapcoord.ord","../coordtmp.ord", ver-, >& "dev$null")
#$
				display(image=imagem,frame=1)
				print("")
				print("Running TVMARK ...")
				print("")
				   				   
				tvmark(1,"../coordtmp.ord",label=no,number=yes,radii=15,color=202)
			} else {	
				print "# Automatically finding star coordinates with daofind..."
		
				delete ("TEMP_1.txt", ver-, >& "dev$null")
#$
				imstatistics (images = imagem, 
		              fields = "max", lower = INDEF, upper = INDEF, 
				    binwidth = 0, format = no, >> "TEMP_1.txt")

				flist1 = "TEMP_1.txt"
				lixo1 = fscan (flist1, maxdata)
				delete ("TEMP_1.txt", ver-, >& "dev$null")
#$

				datapars.datamin=maxdata*1./10.	
		
				delete ("../coordtmp.ord", ver-, >& "dev$null")
#$
				daofind (image=imagem,
					    output="../coordtmp.ord",verify="no")
			}
		}
#
# FIM do if (intera == no)
#		
		
# Continues until the end of procedures to modo == 1
		 
		print "# Aligning images..."
		temp2 = "coordtmp"
		
		imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$
		if (access("shifts")) {		
			print ("# Using 'shifts' file present in the folder...")
			imalign(input="c*.fits",reference=imagem,
		        coords="../"//temp2//".ord",output="sh//c*.fits",shifts="shifts",
			   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
		} else {
			imalign(input="c*.fits",reference=imagem,
		        coords="../"//temp2//".ord",output="sh//c*.fits",shifts="",
			   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
		}
		
		if (intera==no) 
			delete ("../coordtmp.ord", ver-, >& "dev$null")
#$
		
		print "# Summing images..."
		
		imdel (images="../sum"//raiz//version//".fits",go_ahead=yes, 
		       verify=no, >& "dev$null")
#$
		imsum (input="shc*.fits",output="../sum"//raiz//version//".fits",
		       title="",hparams="",pixtype="double",calctype="double",option="sum",
			  verbose=no)
		
		imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$
		
#		display(image="../sum"//raiz//version//".fits",frame=1)
#		sleep 1		
#		tvmark(1,temp5,label=no,number=yes,radii=15)

		}
#
# FIM do if (modo == 1)
#

# BEDNARSKI 04-06-2010: A partir daqui não mexi mais nas estruturas dos if, apenas atualizei onde era temp2//".ord" para a variável tempcoord, que contém o 'endereço' do arquivo de coordenadas para cada caso de intera

	if (modo == 2) {
# Mode 2, runs phot and calls ccdrap.e to combine the *mag.1 into a .dat file
		
		print("# Running IMALIGN ...")
		
		tempshift = mktemp("imalign")
		
		unlearn imalign
		if (access("shifts")) { 
			print ("# Using 'shifts' file present in the folder...")
			imalign(input="c*.fits",reference="../"//temp0,
# BEDNARSKI 06-06-2010: Atualizado abaixo (funciona para os dois modos)
			coords=tempcoord,output="",shifts="shifts",
#			coords="../"//temp2//".ord",output="",shifts="shifts",
			   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=no,
			   > tempshift//"") 
		} else {
			imalign(input="c*.fits",reference="../"//temp0,
# BEDNARSKI 06-06-2010: Atualizado abaixo (funciona para os dois modos)
			coords=tempcoord,output="",shifts="",
#			coords="../"//temp2//".ord",output="",shifts="",
			   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=no,
			   > tempshift//"")
		}

#		delete (temp3, ver-, >& "dev$null")
#$
	   	print("# Running PHOT ...")
		delete ("*.mag.*", ver-, >& "dev$null")
#$
	   	

	   	unlearn datapars
	   	datapars.readnoise = readnoise*ganho*sqrt(nframes)
	   	datapars.epadu = ganho
	   	datapars.fwhm = fwhm_mean
		datapars.sigma = skysigma_mean
			

		
	   	unlearn phot
	   	unlearn centerpars
		centerpars.calgori="centroid"
		centerpars.cbox=fwhm_mean*2.5
	   	unlearn fitskypars
	   	fitskypars.salgorithm = "mode"
	   	fitskypars.annulus = annulus
	   	fitskypars.dannulus = dannulus
	   	unlearn photpars
	   	photpars.apertures = apertures
		
# Create list of input star images in a temporary file
# Determine the number of stars
		unlearn tstat
# BEDNARSKI 06-06-2010: Atualizado abaixo (funciona para os dois modos)
		tstat(tempcoord,1, >& "dev$null")
#		tstat("../"//temp2//".ord",1, >& "dev$null")
#$
	     nstars = tstat.nrows/2
		
		temp4 = mktemp("lista")
		files ("c*.fits", > temp4)
		flist1 = temp4
		

		flist2 = tempshift
#Search the file to find the line that starts with "#C"
	     ver=yes
          while (ver) {
		   lixo1 = fscan(flist2,line1)
             if ((substr(line1,1,2) == "#C"))
	        		ver = no
		}

		j = 0
		
		temp3 = mktemp("phot")
		temp5 = mktemp("daoedit")
		while (fscan(flist1, imagem) != EOF) {
			j = j+1
			
			k=1
			while (k<=nstars) {
				lixo1 = fscan(flist2,line1)
				linedata = fscan(line1,lixo1,xxx,lixo1,yyy,lixo1,lixo1)
				print (xxx,yyy," 1 a", >>temp5)
				lixo1 = fscan(flist2,line1)
				linedata = fscan(line1,lixo1,xxx,lixo1,yyy,lixo1,lixo1)
				print (xxx,yyy," 1 a", >>temp5)
				k += 1
			}

# BEDNARSKI 01-08-2011: Copiei isso abaixo do ccdrap do ikon/ixon
			if (j == 1 && intera == no) {
				print("# Displaying first image of the series ...")
				display(image=imagem,frame=1)
				tvmark(1,temp5,label=no,number=yes,radii=15,color=202)
				sleep 1
			}
			
# Usar AQUI para verificar se a implementacao foi adequada
#		    display(image=imagem,frame=1)
#		    sleep 1		
#		    tvmark(1,temp5,label=no,number=yes,radii=15,color=202)
#		    sleep 2

			
# jump the space			
			lixo1 = fscan(flist2,line1)
			
#			type (temp5)
						
#			daoedit(image=imagem, icommands=temp5, gcommands="", >>temp3)
			
#		   	unlearn tstat
#		   	tstat(temp3,3,>& "dev$null")
#$
#		   	sky_mean = tstat.mean
#		   	tstat(temp3,4,>& "dev$null")
 #$
#		   	skysigma_mean = tstat.mean
#		   	tstat(temp3,5,>& "dev$null")
#$
#		   	fwhm_mean = tstat.mean
			
#			print(skysigma_mean,fwhm_mean)
			
			delete (temp3, ver-, >& "dev$null")
#$
# AQUI é feita fotometria de abertura
			phot(image=imagem,skyfile="",coords=temp5,interactive=no,
			     verify=no,verbose=no)
#			     datapars="/Users/carciofi/data/iraf/uparm/aptdataps.par",
#				fitskypars="/Users/carciofi/data/iraf/uparm/aptfitsks.par",
#				centerpars="/Users/carciofi/data/iraf/uparm/aptcentes.par",
#				photpars="/Users/carciofi/data/iraf/uparm/aptphotps.par")
			
			delete (temp5, ver-, >& "dev$null")
#$
		}
		nimages = j
		
		delete (temp4, ver-, >& "dev$null")
#$
		delete (tempshift, ver-, >& "dev$null")
#$

# Run TXDUMP
	   	print("# Running TXDUMP ...")
	   	
	   	temp4 = mktemp("txdump")
	   	
	   	unlearn txdump
	   	
	   	txdump.textfiles = "*.mag.1"
	   	txdump.fields = "image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]"
	   	
	   	txdump(text="*.mag.1",
		       fiel="image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]",
			  expr=yes,>> temp4//"")

# Run pccdrap_e
		delete ("roda", ver-, >& "dev$null")
#$
		delete (fileout, ver-, >& "dev$null")
#$

		print ("# Running ccdrap_e and calculating photometry ...")
		print (fileexe," ",temp4," ", fileout," ", nstars," ", nimages," ", nap," ", >> "roda")
#		print ("Os parametros passados ao ccdrap_e sao:")		# TIRAR
#		print (temp4," ", fileout," ", nstars," ", nimages," ", nap," ")		# TIRAR
		!source roda
		delete ("roda", ver-, >& "dev$null")
#$

		
		delete ("*.mag.1", ver-, >& "dev$null")
#$
		delete (temp4, ver-, >& "dev$null")
#$
		

	}
#
# FIM do if (modo == 2)
#	
		
# Delect ccdproc images
		if (eraseccdproc) 	
		imdel (images="c*.fits",go_ahead=yes, verify=no, >& "dev$null")
#$
		chdir ("..")

	}
#
# Fim do laço das posições de lâmina
#
		
	if (modo==1 && global) {
		print ""
		print "# Aligning the summed images..."
		if (iw <= 9) {
			raiz = "0"//iw
		} else {
			raiz = ""//iw
		}
		imstatistics (images = "sum"//raiz//version//".fits", 
		              fields = "max", lower = INDEF, upper = INDEF, 
				    binwidth = 0, format = no, >> "TEMP_1.txt")

		flist1 = "TEMP_1.txt"
		lixo1 = fscan (flist1, maxdata)
		delete ("TEMP_1.txt", ver-, >& "dev$null")
#$
		datapars.datamin=maxdata*1./5.
		
		delete ("coordtmp", ver-, >& "dev$null")
#$
		daofind (image="sum"//raiz//version//".fits",
		         output="coordtmp",verify="no")
		
		imdel (images="shsum*"//version//".fits",go_ahead=yes, verify=no, >& "dev$null")
#$

		imalign(input="sum*"//version//".fits",
			   reference="sum"//raiz//version//".fits",
		        coords="coordtmp",
			   output="sh//sum*"//version//".fits",shifts="",
			   boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)

		delete ("coordtmp", ver-, >& "dev$null")
#$
	} 
	if (modo == 2) {
		delete (temp0, ver-, >& "dev$null")
#$
#		delete (temp2//".ord", ver-, >& "dev$null")
#$
# BEDNARSKI 06-06-2010: Deixa uma versao final das coordenadas no caso intera==no (o que ainda não havia sido feito)
		if (intera==no)
			rename (temp2//".ord", "coord"//version//".ord")
	}
delete (temp1, ver-, >& "dev$null")
#$
delete ("coordtmp.ord", ver-, >& "dev$null")
#$

flist1=""
flist2=""
flist3=""
datapars.datamin=INDEF
phot.interac = no
print("# Setting 'ganho', 'nstars', 'nap' & 'readnoise' parameters in pccd & pccdgen...")
if (modo==2) {
	pccd.nstars=nstars
	pccdgen.nstars=nstars
} else {
	print ("PROGRAMAR!!!!")
}

# Some parameters are passed to next tasks that will be executed
pccd.nap=nap
pccdgen.nap=nap
pccd.readnoise=readnoise*sqrt(nframes)
pccdgen.readnoise=readnoise*sqrt(nframes)
pccdgen.ganho = ganho

polrap.rootout = "w"
polrap.rootin = "sum"
polrap.version1 = version
grafrap.root = polrap.rootout
grafrap.version1 = polrap.version1

print("# ",>> "ccdraplog")
print("# CCDRAP",>> "ccdraplog")
print("# ",>> "ccdraplog")
time(>> "ccdraplog")
print("# ",>> "ccdraplog")

print("#  intera    : ", intera, >> "ccdraplog")
print("#  modo      : ", modo,   >> "ccdraplog")
print("#  iw        : ", iw,   >> "ccdraplog")
print("#  fw        : ", fw,   >> "ccdraplog")
print("#  contiguous: ", contiguous, >> "ccdraplog") 
print("#  version   : ", version,    >> "ccdraplog")
print("#  trim      : ", trimi,       >> "ccdraplog")
print("#  overscan  : ", overscan,   >> "ccdraplog")
print("#  zerocor   : ", zerocor,    >> "ccdraplog")
print("#  darkcor   : ", darkcor , >> "ccdraplog")
print("#  flatcor   : ", flatcor , >> "ccdraplog")
print("#  biassec   : ", biasseci , >> "ccdraplog")
print("#  trimsec   : ", trimseci , >> "ccdraplog")
print("#  zero      : ", zero,>> "ccdraplog")
print("#  dark      : ", dark,>> "ccdraplog")
print("#  flat      : ", flat,>> "ccdraplog")
print("#  readnoise : ", readnoise , >> "ccdraplog")
print("#  real RON  : ", readnoise*sqrt(nframes) , >> "ccdraplog")
print("#  ganho     : ", ganho,>> "ccdraplog")
print("#  nap       : ", nap,>>"ccdraplog")
print("#  apertures : ", apertures , >> "ccdraplog")
print("#  annulus   : ", annulus , >> "ccdraplog")
print("#  dannulus  : ", dannulus , >> "ccdraplog")
print("#  boxsize   : ", boxsize , >> "ccdraplog")
print("#  bigbox    : ", bigbox, >> "ccdraplog")
print("#  reject    : ", reject, >> "ccdraplog")
print("#  exptime   : ", exptime, >> "ccdraplog")
print("#  fileexe   : ", fileexe , >> "ccdraplog")

#Running jdrap


jdrap(iw=iw,fw=fw,contiguous=contiguous)


end

