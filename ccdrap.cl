#
# Ver. Agosto de 2014
#
# Para IRAF 3.0
#

procedure ccdrap(rootin)

string  rootin=""          {prompt="Filename root (DO NOT PUT THE '_' AT THE END)"}
bool    intera=no          {prompt="Use interactive selection for objects?"}
int     modo=2             {min=1, max=2, prompt="1-Register images; 2-Run PHOT"}
string  version=".1"       {prompt="Version of the output files"}
bool    trim=no            {prompt="Trim the image?"}
bool    overscan=no        {prompt="Apply overscan strip correction?"}
bool    zerocor=no         {prompt="Apply zero level correction?"}
bool    darkcor=no         {prompt="Apply dark count correction?"}
bool    flatcor=no         {prompt="Apply flat field correction?"}
bool    coordref=no        {prompt="Use a reference coordinate file?"}
string  biassec=""         {prompt=" Overscan strip image section"}
string  trimsec=""         {prompt=" Trim data section"}
string  zero=""            {prompt="Zero level calibration image"}
string  dark=""            {prompt="Dark Count calibration image"}
string  flat=""            {prompt="Flat field images"}
string  coord=""           {prompt="Reference coordinate file"}
real    readnoise=2.19     {prompt="CCD readnoise (adu)"}
real    ganho=3.7          {prompt="CCD gain (e/adu)"}
int     nap=10             {prompt="phot: number of apertures (maximum 10)"}
string  apertures="5:14:1" {prompt="phot: List of aperture radii in pixels"}
real    annulus=30.        {prompt="phot: Inner radius of sky annulus in scale units"}
real    dannulus=10.       {prompt="phot: Width of sky annulus in scale units"}
real    boxsize=7          {prompt="Imalign: Size of the small centering box"}
real    bigbox=11          {prompt="Imalign: Size of the big centering box"}
int	    reject=63000       {prompt="Reject images with pixel values larger than this value"}
bool    stack1st=no        {prompt="Attempt to automatically stack 1st WP position?"}
string  fileexe="/iraf/iraf-2.16.1/extern/beacon/pccd/ccdrap_e.e"  {prompt="CCDRAP executable file"}
string  icom="/iraf/iraf-2.16.1/extern/beacon/pccd/icom.sh"  {prompt="Script for icommands of daoedit"}

struct *flist1
struct *flist2
struct *flist3
struct *flist4
struct *flist5


begin

string workingimage, root
string suffix, suffix2

string temp0, temp1, temp2, temp3, temp4, temp5, temp6, tempshift, aa, linedata, tempcoord, comm
string fname, fname2, fname3, fname4
struct line1, line2
string diret, raiz, lista
string lixo1
string imagem, fileord, fileout, filetemp, imname, filecounts
string zeroi, flati
string arq, arqim
string biasseci=""
string trimseci=""
string darki=""

real   xxx, yyy, xcomp, ycomp, deltax, deltay
real   sky_mean, skysigma_mean, fwhm_mean, count, actcount[100], basecount[100]
real   maxdata
real   JD[1000]

int iw, nw, i, j, u, n=0
int nframes, nimages, nstars, nlin
int xx[100], yy[100]


bool trimi, fileexists, ver, ver1
bool bb=no
bool uselast=no
bool swap=yes
bool eraseccdproc=yes
bool global=no

unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars
unlearn setimpars


root=rootin
trimi=trim

#zeroi="../"//zero
zeroi=zero
#flati="../"//flat
flati=flat
trimseci=trimsec

temp1=""


if( modo == 2 && !access(fileexe) ){
  print("ERROR: file ", fileexe, " not found!\nVerify and try again.")
  error(1,1)
}

if( !access(icom) && coordref ) {
  print("ERROR: script ", icom, ", used for \"usecoords=yes\", not found!\nVerify and try again.")
  error(1,1)
}


delete("daoedit* imalign* tmpcont* counts* coordtmp.ord", ver-, >& "dev$null")
  

if (modo == 2) {

  # Step Zero 
  # Register the imagens of the first WP position. This is necessary to include
  # faint objects in the object's list below

  # Search for first image
  lista=mktemp("lista")
  files(root//"_*.fits", > lista)
  flist3=lista
  lixo1=fscan(flist3, imagem)
  delete(lista, ver-, >& "dev$null")

  workingimage=substr(imagem,1,(strlen(imagem)-5))

  print ("# Registering images in "//workingimage)
  print ("# Extracting 2D Fits files from 3D File")

  imdel (images="cp_"//workingimage//"*",go_ahead=yes, verify=no, >& "dev$null")

  unlearn imgets
  #imgets(workingimage,"NUMKIN")
  imgets(workingimage,"i_naxis3")
  nframes=real(imgets.value)

  if (nframes > 1) {
    for (i=1; i <= nframes; i += 1) {

      suffix2="_"//i

      if (i < 100) suffix2="_0"//i
      if (i < 10) suffix2="_00"//i	

      imcopy(input=workingimage//"[*,*,"//i//"]",
             output="cp_//"//workingimage//suffix2,verbose=no)
    }
  } else {

    imcopy(input=workingimage, output="cp_//"//workingimage//"_001",verbose=no)
  }

  workingimage="cp_"//workingimage//"*"
  fname=mktemp("lista")
  files(workingimage, > fname)
  #"@"//fname,output="ccdp_//@"//fname
  imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")


  if (overscan || zerocor ||  darkcor || flatcor || trim) {
    print "# Running ccdproc..."

    ccdproc(images="@"//fname,output="ccdp_//@"//fname,ccdtype="",
	   noproc=no,fixpix=no,overscan=overscan,trim=trimi,
	   zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
	   fringecor=no,readcor=no,scancor=no,
	   readaxis="column",biassec=biasseci,trimsec=trimseci,
	   zero=zeroi,flat=flati,dark=darki)
			   
#	delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")


  } else {

    print "# No ccdproc processing..."
    imcopy(input="@"//fname,output="ccdp_//@"//fname,verbose=no)
  }

  delete(fname, ver-, >& "dev$null")

  #Delete 2D copies
  imdel (images=workingimage,go_ahead=yes, verify=no, >& "dev$null")

  #Search for first image
  lista=mktemp("lista")
  files("ccdp_"//workingimage, > lista)
  flist3=lista
  lixo1=fscan(flist3, imagem)
  delete (lista, ver-, >& "dev$null")
 	
  #The code below stacks all images of the 1st WP position
  temp0=mktemp("sum")//".fits"

  if (stack1st) {

    temp1=mktemp("erasethis")
    imstatistics (images=imagem, fields="max", lower=INDEF, upper=INDEF, 
                  binwidth=0, format=no, >> temp1)

    flist1=temp1
    lixo1=fscan (flist1, maxdata)
    delete (temp1, ver-, >& "dev$null")

    unlearn datapars
    datapars.datamin=maxdata*1./7.	

    temp1=mktemp("coordtmp")
    unlearn daofind
    daofind(image=imagem,output=temp1,verify="no")

    imdel(images="shifts_*.fits",go_ahead=yes, verify=no, >& "dev$null")


    if (access("shifts")) {		
      print ("# Using 'shifts' file present in the folder...")

      fname2=mktemp("lista")
      files("ccdp_*.fits", > fname2)
      #"@"//fname,output="ccdp_//@"//fname

      imalign(input="@"//fname2,reference=imagem,
              coords=temp1, output="shifts_//@"//fname2, shifts="shifts",
              boxsize=boxsize, bigbox=bigbox, trimimages=no, shiftimages=yes)

    } else {

      fname2=mktemp("lista")
      files("ccd_*.fits", > fname2)
      imalign(input="@"//fname2,reference=imagem,
              coords=temp1,output="shifts_//@"//fname2,shifts="",
	      boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
    }

    delete(fname2, ver-, >& "dev$null")
    delete(temp1, ver-, >& "dev$null")
    imsum(input="shifts_*.fits", output=temp0, title="",hparams="",
           pixtype="double",calctype="double",option="sum", verbose=no)

  } else {

    imrename(imagem,temp0,>& "dev$null")
  }

  imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")
  imdel (images="shifts_*.fits",go_ahead=yes, verify=no, >& "dev$null")


  # Before staring the loop on the WP positions, find the coordinates of
  # input star(s). The first image of the first WP position will be used

  print("# FIRST STEP: find the coordinate of the star(s).")


# BEDNARSKI, 14jun16: Acrescentei as próximas ~20 linhas abaixo para não necessitar indicar novamente as coordenadas quando há registros anteriores para o mesmo objeto e filtro.
# IMPORTANTE, IMPORTANTE: automatizar para nem o "yes" necessitar ser dado, após fazer os testes e verificar que está tudo certo.

  fileexists=access("coord_"//root//".ord")
  if(fileexists)
    temp1="coord_"//root//".ord"
  else{
    fileexists=access("coord_"//root//"_001.ord")
    if(fileexists && intera)
      temp1="coord_"//root//"_001.ord"
    if(fileexists && !intera)
      fileexists = no
  }

  if(fileexists) {
    #temp1="coord_"//root//".ord"

    print"# Running DISPLAY ...")
    print("")
    display(image=temp0,frame=1)

    tvmark(1, temp1, label=no, number=yes, radii=10, mark="circle", color=204)
    # Descomentar depois
#    sleep 1

# BEDNARSKI, 14ago05: Comentei abaixo e adicionei "bb=yes" para não precisar mais confirmar as coordenadas		
#    print("")
#    print("# Is it correct (yes|no)?")
#    aa=scan(bb)
     bb=yes

#     print("GRANDE TESTE: havia coordenadas de uma rodada anterior")
  }



# BEDNARSKI, 14ago16: Acrescentei as próximas ~20 linhas abaixo para quando utilizando uma imagem de referência. (Caso já exista arquivo de coordenadas para o alvo/filtro em questão, ignorará a imagem de referência!)

  if(coordref && access(coord) && !fileexists) {

    comm=mktemp("icommands")
    temp1="coord_"//root//".ord"

    # O parâmetro iccomands são os comandos que se daria interativamente no daoedit, mas registrados num arquivo de texto
    print(icom, " ", coord, " ", comm, > "roda")
    !source roda

    centerpars.cbox=20.
    daoedit(image=temp0, icommands=comm, gcommands="", > temp1)
    type (temp1)

    print"# Running DISPLAY ...")
    print("")
    display(image=temp0,frame=1)

    tvmark(1, temp1, label=no, number=yes, radii=10, mark="circle", color=204)
    print("")
    print("# Is it correct (yes|no)?")
    aa=scan(bb)

#   print("GRANDE TESTE: usado como base o arquivo passado como parâmetro")
    delete(comm, ver-, >& "dev$null")
  }

# BEDNARSKI, 14ago16: Até aqui minhas modificações


  while (bb == no) {	

    delete(temp1, ver-, >& "dev$null")

    print"# Running DISPLAY ...")
    print("")
    display(image=temp0,frame=1)
#    sleep 1

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
		
    temp1=mktemp("daoedit")
    daoedit(image=temp0, icommands="", gcommands="",> temp1)
    type (temp1)
		
    print("")
    print("Running TVMARK ...")
    print("")
		
    tvmark(1, temp1, label=no, number=yes, radii=10, mark="circle", color=204)
		
    print("")
    print("# Is it correct (yes|no)?")
    aa=scan(bb)


#   print("GRANDE TESTE: modo convencional")
  }


# BEDNARSKI, 14jun15: Tive de comentar esse filecalc, pois não funciona no meu IRAF 2.16. Ele não faz diferença.
#  temp2=mktemp("filecalc")
#  unlearn filecalc
#  print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG", > temp2)
#  filecalc.format="%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"
#  filecalc(temp1,"$1;$2;$3;$4;$5", calctyp="double", >> temp2)


  if(temp1=="coord_"//root//".ord") {
    copy(temp1, "coordtmp.ord")
  } else {
    unlearn rename
    rename(temp1, "coordtmp.ord")
  }

  # BEDNARSKI: 2015, Added. Get pixel values of selected coordinates to prevent object missing in the further steps.
  type("coordtmp.ord")
  flist2="coordtmp.ord"
  filecounts=mktemp("counts")
  lixo1 = fscan(flist2, line1)
  lixo1 = fscan(flist2, line1)
  k=1
  while(fscan(flist2, line1) != EOF) {
#    print(line1)
    temp6=mktemp("tmpconta")
    linedata=fscan(line1, xxx,yyy,lixo1,lixo1)
    print(xxx,yyy)
    listpixels(images=temp0//"["//nint(xxx)//":"//nint(xxx)//","//nint(yyy)//":"//nint(yyy)//"]", > temp6)
    # Saving the value inside basecount[k] variable
    flist4=temp6
    lixo1 = fscan(flist4,lixo1,count)
    basecount[k]=count
    print("# Reference counts: "//basecount[k])
    k=k+1
    delete (temp6, ver-, >& "dev$null")

  }

  print("")


# BEDNARSKI 01-08-2011: INICIO DAS MODIFICAÇÕES, comentei abaixo e adicionei linha acima
#  if (modo == "2") {
#		rename(temp1,"coordtmp.ord")
#	} else {
#		rename(temp1,"coordtmp.ord")
#		temp1="coordtmp"
#	}

  # BEDNARSKI 01-08-2011: Criei uma variável que 'contém o endereço' do arquivo de coordenadas (será utilizado posteriormente)
  if (intera == no)
    tempcoord="coordtmp.ord"
	
  type "coordtmp.ord"
  print("")

  unlearn tstat
  tstat("coordtmp.ord",3)
  sky_mean=tstat.mean
  tstat("coordtmp.ord",4)
  skysigma_mean=tstat.mean
  tstat("coordtmp.ord",5)
  fwhm_mean=tstat.mean

  print("")
  print("Mean values")
  print("sky      : ",sky_mean)
  print("skysigma : ",skysigma_mean)
  print("fwhm     : ",fwhm_mean)	


}


# HERE THE LOOP OF THE WP POSITIONS BEGINS. THE COORDINATE FILE GENERATED
# BEFORE (STORED IN TEMP2) WILL BE USED

filetemp=mktemp ("lista")
files(root//"_*.fits", > filetemp)
flist2=filetemp
iw=0

while (fscan(flist2, arqim) != EOF) {

  print ""
  print ""
  print "# Processing image "//arqim	

  iw=iw + 1
  suffix=""//iw

  if (iw < 100) suffix="0"//iw
  if (iw < 10) suffix="00"//iw	

  fileout="sum_"//root//"_"//suffix//version//".dat"
		
  print ("# Extracting 2D Fits files from 3D File")

  workingimage=arqim
  imdel (images="cp_"//workingimage//"*", go_ahead=yes, verify=no, >& "dev$null")

  unlearn imgets
  imgets(workingimage,"i_naxis3")
  nframes=real(imgets.value)
  workingimage=substr(workingimage,1,(strlen(workingimage)-5))

  if (nframes > 1) {
    for (i=1; i <= nframes; i += 1) {
      suffix2="_"//i
      if (i < 100) suffix2="_0"//i
      if (i < 10) suffix2="_00"//i	
      imcopy(input=workingimage//"[*,*,"//i//"]",
             output="cp_//"//workingimage//suffix2,verbose=no)
    }
  } else {

    imcopy(input=workingimage, output="cp_//"//workingimage//"_001", verbose=no)
  }
		

  workingimage="cp_"//workingimage//"*"
  fname3=mktemp("lista")
  files(workingimage, > fname3)
  #"@"//fname,output="ccdp_//@"//fname

  # Get JD of first image in the series
  lista=mktemp("lista")
  files(workingimage//"*.fits", > lista)
  flist3=lista
  lixo1=fscan(flist3, imagem)
  delete (lista, ver-, >& "dev$null")


  # Set the observatory name
  #hedit(images=imagem,fields="OBSERVAT",value="LNA",add=yes,del-,ver-,sho+, >& "dev$null")

  setjd(images=imagem, observa="LNA", date="FRAME", exposure="exposure", ra="ra", dec="dec",
        epoch="epoch", jd="jd", hjd="", ljd="", utdate+, uttime+, listo-, >& "dev$null")

  imgets(imagem,"JD")
  JD[iw]=real(imgets.value)


  # Remove stuff from previous runs
  imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")


  if (overscan || zerocor ||  darkcor || flatcor || trim) {
    print "# Running ccdproc..."

    ccdproc(images="@"//fname3,output="ccdp_//@"//fname3,ccdtype="",
            noproc=no,fixpix=no,overscan=overscan,trim=trimi,
            zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
            fringecor=no,readcor=no,scancor=no,
            readaxis="column",biassec=biasseci,trimsec=trimseci,
            zero=zeroi,flat=flati,dark=darki)

#    delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")

  } else {

    print "# No ccdproc processing..."
    imcopy(input="@"//fname3,output="ccdp_//@"//fname3,verbose=no)
  }

  delete(fname3, ver-, >& "dev$null")
  # Delete 2D copies
  imdel(images=workingimage,go_ahead=yes, verify=no, >& "dev$null")


  # Erase images with pixel values larger than reject
  arq=mktemp("tmpvar")
  files("ccdp_*.fits", > arq)
  flist3=arq

  while (fscan(flist3, arqim) != EOF) {

    delete("TEMP_1.txt", ver-, >& "dev$null")

    imstatistics(images=arqim, fields="max", lower=INDEF, upper=INDEF, 
                 binwidth=0, format=no, >> "TEMP_1.txt")
    flist1="TEMP_1.txt"
    lixo1=fscan (flist1, maxdata)
    delete ("TEMP_1.txt", ver-, >& "dev$null")

    if (maxdata > reject) {

      imdel (images=arqim,go_ahead=yes, verify=no, >& "dev$null")

      print "# WARNING! Image:"
      print (arqim)
      print ("has pixel values out of bounds: ", maxdata)
      print "Deleting it. "
    }
  }

  delete (arq, ver-, >& "dev$null")

		
# BEDNARSKI 01-08-2011: Comentei abaixo para que o intera se aplicasse a ambos os modos
# if (modo == 1) {

  if (intera) {

    temp2="coordtmp.ord"
	
    # Search for first image
    lista=mktemp("lista")
    files("c*.fits", > lista)
    flist3=lista
    lixo1=fscan(flist3, imagem)
    delete(lista, ver-, >& "dev$null")

    fileexists=no
    fileexists=access("coord_"//root//"_"//suffix//".ord")

    if (fileexists==yes) {

      # There exists a coordinate list from a previous run.
      print("# Using coordinate file from a previous run...")
      delete(temp2, ver-, >& "dev$null")

      copy("coord_"//root//"_"//suffix//".ord","coordtmp.ord", ver-, >& "dev$null")

      uselast=yes
      #temp1="coordtmp.ord"
#     print("GRANDE TESTE: INTERA, havia coordenadas de uma rodada anterior")

    } else {

      print("# Using coordinate file from the previous WP position...")
      uselast=yes
      #temp1="coordtmp.ord"

#     print("GRANDE TESTE: INTERA, usando coordenada da posição de lâmina anterior")

      # BEDNARSKI 01-08-2011: Se for a primeira posição de lâmina, não usa a coordenada anterior, desde que o modo seja 1, pois se 2, há sim coordenada anterior, obtida no if (modo==2) que inicia na linha aaaa
      if (i == iw && modo == 1) {

        #temp1="a"
        uselast=no
      }
    }


    bb=no

    while (bb == no) {
      if (uselast == no) {

        #delete (temp1, ver-, >& "dev$null")

        display(image=imagem,frame=1)
#        sleep 1

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


        temp1=mktemp("daoedit")
        daoedit(image=imagem, icommands="", gcommands="",> temp1)
        type(temp1)
				   
        delete (temp2, ver-, >& "dev$null")
        rename(files=temp1,newname=temp2,field="all")

      } else {
        uselast=no

        # Bednarski, 14ago16: adicionei abaixo para atualizar coordenadas no modo interativo
        comm=mktemp("icommands")
        print(icom, " ", temp2, " ", comm, > "roda")
        !source roda

        centerpars.cbox=20.
        daoedit(image=imagem, icommands=comm, gcommands="", > temp2)
        type(temp2)
        delete(comm, ver-, >& "dev$null")
        display(image=imagem,frame=1)

#     print("GRANDE TESTE: Intera, atualizando coordenadas")
      }

      print("")
      print("Running TVMARK ...")
      print("")

      tvmark(1,temp2,label=no,number=yes,radii=10,mark="circle",color=204)
				   
      print("")
      print("# Is it correct (yes|no)?")
      aa=scan(bb)
    }


    # Update the files coord_
    delete("coord_"//root//"_"//suffix//".ord", ver-, >& "dev$null")
    copy(temp2,"coord_"//root//"_"//suffix//".ord",ver-, >& "dev$null")


    # BEDNARSKI 01-08-2011: tempcoord para o caso de intera == yes
    tempcoord="coord_"//root//"_"//suffix//".ord"

  }
#
# FIM do if (intera)
#


# BEDNARSKI 01-08-2011: No lugar do else para o "if (intera)", acrescentei novos ifs para deixar adequado.

  # In case modo == 1
  if (modo == 1) {
    PRINT ("CCDRAP IKON PROGRAMAR")
    STOP
		
  # BEDNARSKI 01-08-2011: No caso de intera == no, executa os procedimentos abaixo (que têm de ser programados corretamente ainda, para o modo 1!)
    if (intera == no) {

      # Search for first image
      lista=mktemp("lista")
      files("c*.fits", > lista)
      flist3=lista
      lixo1=fscan(flist3, imagem)
      delete(lista, ver-, >& "dev$null")

      fileexists=access("coord_"//root//"_"//suffix//".ord")

      if (fileexists==yes) {

        print("# Using coordinate file from a previous run...")
        delete ("coordtmp.ord", ver-, >& "dev$null")
        copy("coord_"//root//"_"//suffix//".ord","coordtmp.ord", ver-, >& "dev$null")

        display(image=imagem,frame=1)

        print("")
        print("Running TVMARK ...")
        print("")

        tvmark(1,"coordtmp.ord",label=no,number=yes,radii=10,mark="circle",color=204)

      } else {	

        print "# Automatically finding star coordinates with daofind..."
        delete("TEMP_1.txt", ver-, >& "dev$null")

        imstatistics(images=imagem, fields="max", lower=INDEF, upper=INDEF, 
                     binwidth=0, format=no, >> "TEMP_1.txt")

        flist1="TEMP_1.txt"
        lixo1=fscan(flist1, maxdata)
        delete("TEMP_1.txt", ver-, >& "dev$null")
        datapars.datamin=maxdata*1./10.	
        delete ("coordtmp.ord", ver-, >& "dev$null")

        daofind (image=imagem, output="coordtmp.ord", verify="no")
      }
    }
#
# FIM do if (intera == no)
#		
		

    # Continues until the end of procedures to modo == 1

    print "# Aligning images..."
    temp2="coordtmp.ord"
    imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")


    if (access("shifts")) {

      fname4=mktemp("lista")
      files("c*.fits", > fname4)    

      print ("# Using 'shifts' file present in the folder...")
      imalign(input="@"//fname4,reference=imagem,
              coords=temp2, output="sh//@"//fname4, shifts="shifts",
              boxsize=boxsize, bigbox=bigbox, trimimages=no, shiftimages=yes)
    } else {

      fname4=mktemp("lista")
      files("c*.fits", > fname4)  
      imalign(input="@"//fname4, reference=imagem,
              coords=temp2, output="sh//@"//fname4, shifts="",
              boxsize=boxsize, bigbox=bigbox, trimimages=no, shiftimages=yes)
    }

    delete(fname4, ver-, >& "dev$null")

    if (intera==no) 
      delete ("coordtmp.ord", ver-, >& "dev$null")


    print "# Summing images..."
    imdel (images="../sum"//raiz//version//".fits",go_ahead=yes, verify=no, >& "dev$null")

    imsum(input="shc*.fits",output="../sum"//raiz//version//".fits",
          title="",hparams="",pixtype="double",calctype="double",option="sum",
			  verbose=no)
		
    imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")

		
    #display(image="../sum"//raiz//version//".fits",frame=1)
    #sleep 1		
    #tvmark(1,temp5,label=no,number=yes,radii=10,mark="circle",color=204)

  } else {


    # Mode 2, runs phot and calls ccdrap.e to combine the *mag.1 into a .dat file

    print("# Running IMALIGN ...")
    tempshift=mktemp("imalign")
    unlearn imalign

    if (access("shifts")) {		
      print ("# Using 'shifts' file present in the folder...")

      # BEDNARSKI 01-08-2011: Atualizado abaixo
      imalign(input="ccdp_*.fits", reference=temp0,
              coords=tempcoord, output="", shifts="shifts",
              boxsize=boxsize, bigbox=bigbox, trimimages=no, shiftimages=no,
              niterate=10, tolerance=1, > tempshift//"") 
    } else {

      # BEDNARSKI 01-08-2011: Atualizado abaixo
      imalign(input="ccdp_*.fits", reference=temp0,
              coords=tempcoord, output="", shifts="",
              boxsize=boxsize, bigbox=bigbox, trimimages=no, shiftimages=no,
              niterate=10, tolerance=1, > tempshift//"")
    }

    #delete (temp3, ver-, >& "dev$null")


    print("# Running PHOT ...")
    delete ("*.mag.*", ver-, >& "dev$null")

    unlearn datapars
    datapars.readnoise=readnoise*ganho*sqrt(nframes)
    datapars.epadu=ganho
    datapars.fwhm=fwhm_mean
    datapars.sigma=skysigma_mean

    unlearn phot
    unlearn centerpars
    centerpars.calgori="centroid"
    centerpars.cbox=fwhm_mean*2.5
    unlearn fitskypars
    fitskypars.salgorithm="mode"
    fitskypars.annulus=annulus
    fitskypars.dannulus=dannulus
    unlearn photpars
    photpars.apertures=apertures


    # Create list of input star images in a temporary file
    # Determine the number of stars
    unlearn tstat


    # BEDNARSKI 01-08-2011: Atualizado abaixo (funciona para os dois modos)
    tstat(tempcoord,1, >& "dev$null")
    #tstat(temp2//".ord",1, >& "dev$null")

    nstars=tstat.nrows/2
    temp4=mktemp("lista")
    files ("ccdp_*.fits", > temp4)
    flist1=temp4
    flist3=tempshift


    # Search the file to find the line that starts with "#C"
    ver=yes

    while (ver) {
      lixo1=fscan(flist3,line1)
      if ((substr(line1,1,2) == "#C"))
        ver=no
    }

    j=0
    temp3=mktemp("phot")
    temp5=mktemp("daoedit")

    # BEDNARSKI: 2015. I changed this block to identify when WP position is missed. I need to test.
    while (fscan(flist1, imagem) != EOF) {
      j=j+1
      k=1

      while (k<=nstars) {

        # Reading ordinary beam
        lixo1=fscan(flist3,line1)
        linedata=fscan(line1,imname,xxx,lixo1,yyy,lixo1,lixo1)
        print (xxx,yyy," 1 a", >>temp5)
        xx[2*k-1]=nint(xxx)
        yy[2*k-1]=nint(yyy)
        temp6=mktemp("tmpcont")
        listpixels(images=imname//"["//xx[2*k-1]//":"//xx[2*k-1]//","//yy[2*k-1]//":"//yy[2*k-1]//"]", > temp6)
        flist5=temp6
        lixo1=fscan(flist5,lixo1,count)
        actcount[2*k-1] = count
        delete (temp6, ver-, >& "dev$null")

        # Reading extraordinary beam
        lixo1=fscan(flist3,line1)
        linedata=fscan(line1,imname,xxx,lixo1,yyy,lixo1,lixo1)
        print (xxx,yyy," 1 a", >>temp5)
        temp6=mktemp("tmpcont")
        xx[2*k]=nint(xxx)
        yy[2*k]=nint(yyy)
        listpixels(images=imname//"["//xx[2*k]//":"//xx[2*k]//","//yy[2*k]//":"//yy[2*k]//"]", > temp6)
        flist5=temp6
        lixo1=fscan(flist5,lixo1,count)
        actcount[2*k] = count
        delete (temp6, ver-, >& "dev$null")

        print("ORD: basecount[k] "//basecount[2*k-1])
        print("ORD: actcount[k] "//actcount[2*k-1])
        print("EXORD: basecount[k] "//basecount[2*k])
        print("EXORD: actcount[k] "//actcount[2*k])

        # Calculating if the coordinates were missed
        # 1) Verify if a same coordinate was used for more than once time
        if(xx[2*k-1] - xx[2*k] < 5  &&  xx[2*k-1] - xx[2*k] > -5 &&
           yy[2*k-1] - yy[2*k] < 5  &&  yy[2*k-1] - yy[2*k] > -5)
          print("delta*************************Missing position!")
        for (u=1; u <= 2*k-2; u += 1) {
          if(xx[2*k-1] - xx[u] < 5  &&  xx[2*k-1] - xx[u] > -5 &&
             yy[2*k] - yy[u] < 5  &&  yy[2*k] - yy[u] > -5)
            print("delta*************************Missing position!")
        }
        # 2) Verify if the pixel value is small, probably value of sky
        if (real(basecount[2*k-1]) > 10*real(actcount[2*k-1]) || real(basecount[2*k]) > 10*real(actcount[2*k]))
          print("count*************************Missing position!")

        k += 1
      }

      if (j == 1 && intera == no) {

        print("# Displaying first image of the series ...")
        display(image=imagem, frame=1)
        tvmark(1, temp5, label=no, number=yes, radii=10, mark="circle", color=204)
# Descomentar depois
        sleep 0.9
      }

			
      # Jump the space			
      lixo1=fscan(flist3,line1)
      delete (temp3, ver-, >& "dev$null")


      phot(image=imagem,skyfile="",coords=temp5,interactive=no,
           verify=no,verbose=no,output=imagem//".mag.1")
           #datapars="/Users/carciofi/data/iraf/uparm/aptdataps.par",
           #fitskypars="/Users/carciofi/data/iraf/uparm/aptfitsks.par",
           #centerpars="/Users/carciofi/data/iraf/uparm/aptcentes.par",
           #photpars="/Users/carciofi/data/iraf/uparm/aptphotps.par")

      delete (temp5, ver-, >& "dev$null")

    }


    nimages=j
    delete (temp4, ver-, >& "dev$null")
    delete (tempshift, ver-, >& "dev$null")


    # Run TXDUMP
    print("# Running TXDUMP ...")

    temp4=mktemp("txdump")

    unlearn txdump
    txdump.textfiles="*.mag.1"
    txdump.fields="image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]"
    txdump(text="*.mag.1",
           fiel="image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]",
           expr=yes,>> temp4//"")


    # Run pccdrap_e
    delete ("roda", ver-, >& "dev$null")
    delete (fileout, ver-, >& "dev$null")

    print (fileexe," ",temp4," ", fileout," ", nstars," ", nimages," ", nap," ", >> "roda")
    !source roda

    delete ("roda", ver-, >& "dev$null")
    delete ("*.mag.1", ver-, >& "dev$null")
    delete (temp4, ver-, >& "dev$null")


  }		
		
  # Delect ccdproc images
  if (eraseccdproc) 	
    imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")

}
#
# FIM DO LAÇO SOBRE AS POSIÇÕES DE LÂMINA
#


delete (filetemp, ver-, >& "dev$null")

		
if (modo==1 && global) {

  print ""
  print "# Aligning the summed images..."

  if (iw <= 9) {
    raiz="0"//iw
  } else {
    raiz=""//iw
  }

  imstatistics(images="sum"//raiz//version//".fits", 
               fields="max", lower=INDEF, upper=INDEF, 
               binwidth=0, format=no, >> "TEMP_1.txt")

  flist1="TEMP_1.txt"
  lixo1=fscan (flist1, maxdata)
  delete("TEMP_1.txt", ver-, >& "dev$null")

  datapars.datamin=maxdata*1./3.
  delete("coordtmp", ver-, >& "dev$null")


  daofind (image="sum"//raiz//version//".fits", output="coordtmp", verify="no")
		
  imdel(images="shsum*"//version//".fits",go_ahead=yes, verify=no, >& "dev$null")

  imalign(input="sum*"//version//".fits", reference="sum"//raiz//version//".fits",
         coords="coordtmp", output="sh//sum*"//version//".fits",shifts="",
         boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)

  delete("coordtmp", ver-, >& "dev$null")

} 


if (modo == 2) {

  delete (temp0, ver-, >& "dev$null")
  #delete (temp2//".ord", ver-, >& "dev$null")

  # BEDNARSKI 01-08-2011 (atualizado 14jun16): Deixa uma versao final das coordenadas no caso intera==no (o que ainda não havia sido feito)
  if (intera==no) {

  fileexists = access("coord_"//root//".ord")
  if (fileexists==no)
    rename (tempcoord, "coord_"//root//".ord")
  }
}


delete("coordtmp.ord", ver-, >& "dev$null")
delete ("tmpcont2", ver-, >& "dev$null")
delete (filecounts, ver-, >& "dev$null")
#delete("lista*", ver-, >& "dev$null")

flist1=""
flist2=""
flist3=""
datapars.datamin=INDEF
phot.interac=no
print("")
print("# Setting 'nstars', 'nap' & 'readnoise' parameters in pccd & pccdgen...")


if (modo==2) {
  pccd.nstars=nstars
  pccdgen.nstars=nstars
} else {

  print ("PROGRAMAR!!!!")
}


pccd.nap=nap
pccdgen.nap=nap
pccd.readnoise=readnoise*sqrt(nframes)
pccdgen.readnoise=readnoise*sqrt(nframes)
pccdgen.ganho=ganho

polrap.rootout="w"//root//"_"
polrap.rootin="sum_"//root//"_"
polrap.version1=version
grafrap.root=polrap.rootout
grafrap.version1=polrap.version1


print("# ",>> "ccdraplog")
print("# CCDRAP",>> "ccdraplog")
print("# ",>> "ccdraplog")
time(>> "ccdraplog")
print("# ",>> "ccdraplog")
print("#  root      : ", root, >> "ccdraplog")
print("#  intera    : ", intera, >> "ccdraplog")
print("#  modo      : ", modo,   >> "ccdraplog")
print("#  version   : ", version,    >> "ccdraplog")
print("#  trim      : ", trim,   >> "ccdraplog")
print("#  overscan  : ", overscan,   >> "ccdraplog")
print("#  zerocor   : ", zerocor,    >> "ccdraplog")
print("#  darkcor   : ", darkcor , >> "ccdraplog")
print("#  flatcor   : ", flatcor , >> "ccdraplog")
print("#  coordref  : ", coordref,>> "ccdraplog")
print("#  biassec   : ", biasseci , >> "ccdraplog")
print("#  trimsec   : ", trimseci , >> "ccdraplog")
print("#  zero      : ", zero,>> "ccdraplog")
print("#  dark      : ", dark,>> "ccdraplog")
print("#  flat      : ", flat,>> "ccdraplog")
print("#  coord     : ", coord,>> "ccdraplog")
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
#print("#  exptime   : ", exptime, >> "ccdraplog")
print("#  stack1st  : ", stack1st, >> "ccdraplog")
print("#  fileexe   : ", fileexe, >> "ccdraplog")
print("#  icom      : ", icom, >> "ccdraplog")



# Running jdrap
#jdrap(iw=iw,fw=fw,contiguous=contiguous)

fileout="JD_"//root
delete (fileout, ver-, >& "dev$null")
print("# Writing JD values in file: ",fileout)

for (i=1; i <= iw; i += 1) {
  print("WP "//i//"  "//JD[i], >> fileout)
}


end

