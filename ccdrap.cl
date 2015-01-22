#
# Ver. 13Abr17
#

procedure ccdrap_ikon(rootin)

string  rootin=""       {prompt="Filename root (DO NOT PUT THE '_' AT THE END)"}
bool    intera = no     {prompt="Use interactive selection for objects?"}
int     modo = 2        {min=1,max=2, prompt="1-Register images; 2-Run PHOT"}
string  version=".1"    {prompt="Version of the output files"}
bool    trim = no       {prompt="Trim the image?"}
bool    overscan = no   {prompt="Apply overscan strip correction?"}
bool    zerocor = no    {prompt="Apply zero level correction?"}
bool    darkcor = no    {prompt="Apply dark count correction?"}
bool    flatcor = no    {prompt="Apply flat field correction?"}
string  biassec = ""    {prompt=" Overscan strip image section"}
string  trimsec = ""    {prompt=" Trim data section"}
string  zero = ""       {prompt="Zero level calibration image"}
string  dark = ""       {prompt="Dark Count calibration image"}
string  flat = ""       {prompt="Flat field images"}
real    readnoise = 2.19    {prompt="CCD readnoise (adu)"}
real    ganho = 3.7     {prompt="CCD gain (e/adu)"}
int     nap = 10        {prompt="phot: number of apertures (maximum 10)"}
string  apertures = "5:14:1"    {prompt="phot: List of aperture radii in pixels"}
real    annulus = 30.   {prompt="phot: Inner radius of sky annulus in scale units"}
real    dannulus = 10.  {prompt="phot: Width of sky annulus in scale units"}
real    boxsize=7       {prompt="Imalign: Size of the small centering box"}
real    bigbox=11       {prompt="Imalign: Size of the big centering box"}
int     reject=65000  {prompt="Reject images with pixel values larger than this value"}
bool    stack1st = no   {prompt="Attempt to automatically stack 1st WP position?"}
string  fileexe ="/iraf/iraf/extern/beacon/pccd/ccdrap_e.e" {prompt="CCDRAP executable file"}

struct *flist1
struct *flist2
struct *flist3

begin

string workingimage,root
string suffix
string temp0,temp1, temp2, temp3, temp4, temp5, tempshift, aa, linedata
string diret,raiz,lista
string lixo1
string imagem,fileord,fileout,filetemp
string zeroi,flati
string arq,arqim
string biasseci=""
string trimseci=""
string darki=""
string fname,fname2,fname3,fname4

struct line1, line2

real    xxx, yyy, xcomp, ycomp, deltax, deltay
real    sky_mean, skysigma_mean, fwhm_mean
real    maxdata
real    JD[1000]

bool    bb=no
bool    uselast=no
bool    fileexists
bool    trimi=no
bool    ver, ver1
bool    swap=yes
bool    eraseccdproc=yes
bool    global=yes

int nframes,iw
int n=0
int nlin
int i,j, nw
int nimages
int nstars

global = no

unlearn datapars
unlearn findpars
unlearn centerpars
unlearn fitskypars
unlearn photpars
unlearn daopars
unlearn setimpars

root = rootin
trimi = trim
#zeroi = "../"//zero
zeroi = zero
#flati = "../"//flat
flati = flat
trimseci = trimsec

temp1 = "a"

if (modo == 2) {
    # Step Zero 
    # Register the imagens of the first WP position. This is necessary to include
    # faint objects in the object's list below

    #search for first image
    lista = mktemp("lista")
    files(root//"_*.fits", > lista)
    flist3 = lista
    lixo1 = fscan(flist3, imagem)
    delete (lista, ver-, >& "dev$null")

    workingimage = substr(imagem,1,(strlen(imagem)-5))
    #workingimage = root//"_001" #WITHOUT THE .FITS!

    print ("# Registering images in "//workingimage)
    print ("# Extracting 2D Fits files from 3D File")

    imdel (images="cp_"//workingimage//"*",go_ahead=yes, verify=no, >& "dev$null")

    unlearn imgets
    #imgets(workingimage,"NUMKIN")
    imgets(workingimage,"i_naxis3")
    nframes = real(imgets.value)

    if (nframes > 1) {
        for (i = 1; i <= nframes; i += 1) {
            suffix = "_"//i
            if (i < 100) suffix = "_0"//i
            if (i < 10) suffix = "_00"//i    
            imcopy(input=workingimage//"[*,*,"//i//"]",
              output="cp_//"//workingimage//suffix,verbose=no)
        }
    } else {
    imcopy(input=workingimage,
              output="cp_//"//workingimage//"_001",verbose=no)
    }

    workingimage = "cp_"//workingimage//"*"
    fname = mktemp("lista")
    files(workingimage, > fname)
    #"@"//fname,output="ccdp_//@"//fname

    imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")

    if (overscan || zerocor ||  darkcor || flatcor || trim) {
        print "# Running ccdproc..."

        ccdproc(images="@"//fname,output="ccdp_//@"//fname,ccdtype = "",
               noproc=no,fixpix=no,overscan=overscan,trim=trimi,
               zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
               fringecor=no,readcor=no,scancor=no,
               readaxis = "column",biassec=biasseci,trimsec=trimseci,
               zero=zeroi,flat=flati,dark=darki)
               
        #delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")

    } else {
        print "# No ccdproc processing..."
        imcopy(input="@"//fname,output="ccdp_//@"//fname,verbose=no)
    }
    delete (fname, ver-, >& "dev$null") 

    #Delete 2D copies
    imdel (images=workingimage,go_ahead=yes, verify=no, >& "dev$null")

    #Search for first image
    lista = mktemp("lista")
    files("ccdp_"//workingimage, > lista)
    flist3 = lista
    lixo1 = fscan(flist3, imagem)
    delete (lista, ver-, >& "dev$null")
   

    #The code below stacks all images of the 1st WP position
    temp0 = mktemp("sum")//".fits"

    if (stack1st) {

        temp1 = mktemp("erasethis")
        imstatistics (images = imagem, 
              fields = "max", lower = INDEF, upper = INDEF, 
              binwidth = 0, format = no, >> temp1)

        flist1 = temp1
        lixo1 = fscan (flist1, maxdata)
        delete (temp1, ver-, >& "dev$null")

        unlearn datapars
        datapars.datamin=maxdata*1./7.    

        temp1 = mktemp("coordtmp")
        unlearn daofind
        daofind (image=imagem,output=temp1,verify="no")

        imdel (images="shifts_*.fits",go_ahead=yes, verify=no, >& "dev$null")

        if (access("shifts")) {        
            print ("# Using 'shifts' file present in the folder...")
    
            fname2 = mktemp("lista")
            files("ccdp_*.fits", > fname2)
            #"@"//fname,output="ccdp_//@"//fname
    
            imalign(input="@"//fname2,reference=imagem,
                #coords=temp1,output="shifts_//@"//fname2,shifts="shifts",
                coords=temp1,output="shifts_//ccdp_*.fits",shifts="shifts",
                boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
        } else {
            fname2 = mktemp("lista")
            files("ccd_*.fits", > fname2)    
    
            imalign(input="@"//fname2,reference=imagem,
                #coords=temp1,output="shifts_//@"//fname2,shifts="",
                coords=temp1,output="shifts_//ccdp_*.fits",shifts="shifts",
                boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
        }
        delete (fname2, ver-, >& "dev$null") 
        
        delete (temp1, ver-, >& "dev$null")

        imsum (input="shifts_*.fits",output=temp0,
            title="",hparams="",pixtype="double",calctype="double",option="sum",
            verbose=no)
    } else {
        imrename(imagem,temp0,>& "dev$null")
    }

    imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")

    imdel (images="shifts_*.fits",go_ahead=yes, verify=no, >& "dev$null")


    #Before staring the loop on the WP positions, find the coordinates of
    #input star(s). The first image of the first WP position will be used
    
    print("# FIRST STEP: find the coordinate of the star(s).")
    print"# Running DISPLAY ...")
    print("")
    
    display(image=temp0,frame=1)
    
    sleep 1
    
    while (bb == no) {
        delete (temp1, ver-, >& "dev$null")

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
        
        tvmark(1,temp1,label=no,number=yes,radii=10,mark="circle",color=220)
        
        print("")
        print("# Is it correct (yes|no)?")
        aa=scan(bb)
    }
    
    temp2 = mktemp("filecalc")

    unlearn filecalc

    print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG",>temp2)

    filecalc.format = "%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"
    
    #filecalc(temp1,"$1;$2;$3;$4;$5;$6;$7",calctyp="double",>>temp2)

    filecalc(temp1,"$1;$2;$3;$4;$5",calctyp="double",>& "dev$null")
    filecalc(temp1,"$1;$2;$3;$4;$5",calctyp="double",>>temp2)

    unlearn rename
    #if (modo == "2") {
        rename(temp2,temp2//".ord")
    #} else {
    #    rename(temp2,"coordtmp.ord")
    #    temp2 = "coordtmp"
#    }

    print("")
    type temp2//".ord"
    print("")

    unlearn tstat
    tstat(temp2//".ord",3)
    sky_mean = tstat.mean
    tstat(temp2//".ord",4)
    skysigma_mean = tstat.mean
    tstat(temp2//".ord",5)
    fwhm_mean = tstat.mean

    print("")
    print("Mean values")
    print("sky      : ",sky_mean)
    print("skysigma : ",skysigma_mean)
    print("fwhm     : ",fwhm_mean)    

    #Delete Stacked Image
    #imdel (images=temp0,go_ahead=yes, verify=no, >& "dev$null")

}

#HERE THE LOOP OF THE WP POSITIONS BEGINS. THE COORDINATE FILE GENERATED
#BEFORE (STORED IN TEMP2) WILL BE USED

filetemp = mktemp ("lista")
files (root//"_*.fits", > filetemp)
flist2 = filetemp
iw = 0

while (fscan(flist2, arqim) != EOF) {
    print ""
    print ""
    print "# Processing image "//arqim    

    iw = iw + 1
    suffix = ""//iw
    if (iw < 100) suffix = "0"//iw
    if (iw < 10) suffix = "00"//iw    

    fileout = "sum_"//root//"_"//suffix//version//".dat"
        
    print ("# Extracting 2D Fits files from 3D File")

    workingimage = arqim

    imdel (images="cp_"//workingimage//"*",go_ahead=yes, 
              verify=no, >& "dev$null")

    unlearn imgets
    imgets(workingimage,"i_naxis3")
    nframes = real(imgets.value)
    workingimage = substr(workingimage,1,(strlen(workingimage)-5))

    if (nframes > 1) {
        for (i = 1; i <= nframes; i += 1) {
            suffix = "_"//i
            if (i < 100) suffix = "_0"//i
            if (i < 10) suffix = "_00"//i    
            imcopy(input=workingimage//"[*,*,"//i//"]",
                    output="cp_//"//workingimage//suffix,verbose=no)
        }
    } else {
        imcopy(input=workingimage,
                  output="cp_//"//workingimage//"_001",verbose=no)
    }
        
    workingimage = "cp_"//workingimage//"*"
    fname3 = mktemp("lista")
    files(workingimage, > fname3)
    #"@"//fname,output="ccdp_//@"//fname
        
    #Get JD of first image in the series
    lista = mktemp("lista")
    files(workingimage//"*.fits", > lista)
    flist3 = lista
    lixo1 = fscan(flist3, imagem)
    delete (lista, ver-, >& "dev$null")
    
    # Set the observatory name
    #hedit(images=imagem,fields="OBSERVAT",value="LNA",add=yes,del-,ver-,sho+, >& "dev$null")

    setjd(images=imagem,observa="LNA",date="FRAME",exposure="exposure",
        ra="ra",dec="dec",epoch="epoch",
        jd="jd",hjd="",ljd="",utdate+,uttime+,listo-, >& "dev$null")

    imgets(imagem,"JD")
        
    JD[iw] = real(imgets.value)

    #Remove stuff from previous runs
    imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")

    if (overscan || zerocor ||  darkcor || flatcor || trim) {
        print "# Running ccdproc..."

        ccdproc(images="@"//fname3,output="ccdp_//@"//fname3,ccdtype = "",
               noproc=no,fixpix=no,overscan=overscan,trim=trimi,
               zerocor=zerocor,darkcor=darkcor,flatcor=flatcor,illumcor=no,
               fringecor=no,readcor=no,scancor=no,
               readaxis = "column",biassec=biasseci,trimsec=trimseci,
               zero=zeroi,flat=flati,dark=darki)
               
        #delete (files="logfile",go_ahead=yes, verify=no, >& "dev$null")

    } else {
        print "# No ccdproc processing..."
        imcopy(input="@"//fname3,output="ccdp_//@"//fname3,verbose=no)
    }
    delete (fname3, ver-, >& "dev$null") 
        
    #Delete 2D copies
    imdel (images=workingimage,go_ahead=yes, verify=no, >& "dev$null")
        
    #Erase images with pixel values larger than reject
    arq = mktemp ("tmpvar")
    files ("ccdp_*.fits", > arq)
    flist3 = arq
    while (fscan(flist3, arqim) != EOF) {
    #Fev. 2010: implementar solucao do Daniel B.
        delete ("TEMP_1.txt", ver-, >& "dev$null")

        imstatistics (images = arqim, 
                fields = "max", lower = INDEF, upper = INDEF, 
                binwidth = 0, format = no, >> "TEMP_1.txt")
        flist1 = "TEMP_1.txt"
        lixo1 = fscan (flist1, maxdata)
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
          
    if (modo == 1) {

        PRINT ("CCDRAP IKON PROGRAMAR")
        STOP
    #} #Added by Moser@USA
        
    if (intera) {
        temp2 = "../coordtmp.ord"

        #Search for first image
        lista = mktemp("lista")
        files("c*.fits", > lista)
        flist3 = lista
        lixo1 = fscan(flist3, imagem)
        delete (lista, ver-, >& "dev$null")
  
        fileexists = access("ccdrapcoord.ord")
        if (fileexists==yes) {
                #There exists a coordinate list from a previous run.
                print("# Using coordinate file from a previous run...")
                delete (temp2, ver-, >& "dev$null")
      
                copy("ccdrapcoord.ord","../coordtmp.ord", ver-, >& "dev$null")

                uselast = yes
                #temp1 = "../coordtmp.ord"
        } else {
                print("# Using coordinate file from the previous WP position...")
                uselast = yes
                #temp1 = "../coordtmp.ord"
                if (i == iw) {
                    #temp1 = "a"
                    uselast = no
                }
        } 

        bb = no
        while (bb == no) {
            if (uselast == no) {
                #delete (temp1, ver-, >& "dev$null")

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

                rename(files=temp1,newname=temp2,field="all")
                   
            } else {
                    uselast = no
                    display(image=imagem,frame=1)
            }
                   
            print("")
            print("Running TVMARK ...")
            print("")
                                      
            tvmark(1,temp2,label=no,number=yes,radii=10,mark="circle",color=220)
                   
            print("")
            print("# Is it correct (yes|no)?")
            aa=scan(bb)
        } 

        #unlearn filecalc
        #print("#  XCENTER   YCENTER       SKY  SKYSIGMA      FWHM    COUNTS       MAG",>temp2)
        #filecalc.format = "%10.2f%10.2f%10.1f%10.2f%10.2f%10.1f%10.2f"
        #filecalc(temp1,"$1;$2;$3;$4;$5",calctyp="double",>>temp2)

        #Update the file ccdrapcoord.ord
        delete ("ccdrapcoord.ord", ver-, >& "dev$null")

        copy(temp2,"ccdrapcoord.ord",ver-, >& "dev$null")

    } else {
        #Search for first image
        lista = mktemp("lista")
        files("c*.fits", > lista)
        flist3 = lista
        lixo1 = fscan(flist3, imagem)
        delete (lista, ver-, >& "dev$null")
       
        fileexists = access("ccdrapcoord.ord")
        if (fileexists==yes) {
                print("# Using coordinate file from a previous run...")
                delete ("../coordtmp.ord", ver-, >& "dev$null")
               
                copy("ccdrapcoord.ord","../coordtmp.ord", ver-, >& "dev$null")

                display(image=imagem,frame=1)
                print("")
                print("Running TVMARK ...")
                print("")
                                      
                tvmark(1,"../coordtmp.ord",label=no,number=yes,radii=10,mark="circle",color=220)
        } else {    
                print "# Automatically finding star coordinates with daofind..."
        
                delete ("TEMP_1.txt", ver-, >& "dev$null")

                imstatistics (images = imagem, 
                      fields = "max", lower = INDEF, upper = INDEF, 
                      binwidth = 0, format = no, >> "TEMP_1.txt")

                flist1 = "TEMP_1.txt"
                lixo1 = fscan (flist1, maxdata)
                delete ("TEMP_1.txt", ver-, >& "dev$null")

                datapars.datamin=maxdata*1./10.    
        
                delete ("../coordtmp.ord", ver-, >& "dev$null")

                daofind (image=imagem,
                        output="../coordtmp.ord",verify="no")
        }
    }
         
    print "# Aligning images..."
    temp2 = "coordtmp"
        
    imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")

    if (access("shifts")) {        
            fname4 = mktemp("lista")
            files("c*.fits", > fname4)            
        
            print ("# Using 'shifts' file present in the folder...")
            imalign(input="@"//fname4,reference=imagem,
                coords="../"//temp2//".ord",output="sh//@"//fname4,shifts="shifts",
               boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
    } else {
            fname4 = mktemp("lista")
            files("c*.fits", > fname4)            
        
            imalign(input="@"//fname4,reference=imagem,
                coords="../"//temp2//".ord",output="sh//@"//fname4,shifts="",
               boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)
    }
    delete (fname4, ver-, >& "dev$null") 
        
    if (intera==no) #{ Added by Moser@USA
        delete ("../coordtmp.ord", ver-, >& "dev$null")
        
        print "# Summing images..."
        
        imdel (images="../sum"//raiz//version//".fits",go_ahead=yes, 
               verify=no, >& "dev$null")

        imsum (input="shc*.fits",output="../sum"//raiz//version//".fits",
               title="",hparams="",pixtype="double",calctype="double",option="sum",
               verbose=no)
        
        imdel (images="shc*.fits",go_ahead=yes, verify=no, >& "dev$null")

        
        #display(image="../sum"//raiz//version//".fits",frame=1)
        #sleep 1        
        #tvmark(1,temp5,label=no,number=yes,radii=10,mark="circle",color=220)

    } else {
        #Mode 2, runs phot and calls ccdrap.e to combine the *mag.1 into a .dat file
        
        print("# Running IMALIGN ...")
        
        tempshift = mktemp("imalign")
        
        unlearn imalign
        if (access("shifts")) {        
                print ("# Using 'shifts' file present in the folder...")
                imalign(input="ccdp_*.fits",reference=temp0,
                    coords=temp2//".ord",output="",shifts="shifts",
                    boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=no,
                    niterate=10,tolerance=1,
                    > tempshift//"") 
        } else {
                imalign(input="ccdp_*.fits",reference=temp0,
                    coords=temp2//".ord",output="",shifts="",
                    boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=no,
                    niterate=10,tolerance=1,
                    > tempshift//"")
        }

        #delete (temp3, ver-, >& "dev$null")

        print("# Running PHOT ...")
        delete ("*.mag.*", ver-, >& "dev$null")
           
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
        tstat(temp2//".ord",1, >& "dev$null")

        nstars = tstat.nrows/2
        temp4 = mktemp("lista")
        files ("ccdp_*.fits", > temp4)
        flist1 = temp4
        

        flist3 = tempshift
        #Search the file to find the line that starts with "#C"
        ver=yes
        while (ver) {
            lixo1 = fscan(flist3,line1)
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
                lixo1 = fscan(flist3,line1)
                linedata = fscan(line1,lixo1,xxx,lixo1,yyy,lixo1,lixo1)
                print (xxx,yyy," 1 a", >>temp5)
                lixo1 = fscan(flist3,line1)
                linedata = fscan(line1,lixo1,xxx,lixo1,yyy,lixo1,lixo1)
                print (xxx,yyy," 1 a", >>temp5)
                k += 1
            }

            if (j == 1) {
                print("# Displaying first image of the series ...")
                display(image=imagem,frame=1)
                tvmark(1,temp5,label=no,number=yes,radii=10,
                      mark="circle",color=220)
                sleep 1
            }

            # jump the space            
            lixo1 = fscan(flist3,line1)
            
            #type (temp5)
                        
            #daoedit(image=imagem, icommands=temp5, gcommands="", >>temp3)
            
            #unlearn tstat
            #tstat(temp3,3,>& "dev$null")

            #sky_mean = tstat.mean
            #tstat(temp3,4,>& "dev$null")

            #skysigma_mean = tstat.mean
            #tstat(temp3,5,>& "dev$null")

            #fwhm_mean = tstat.mean
            
            #print(skysigma_mean,fwhm_mean)
            
            delete (temp3, ver-, >& "dev$null")

            phot(image=imagem,skyfile="",coords=temp5,interactive=no,
			     verify=no,verbose=no,output=imagem//".mag.1")
                 #datapars="/Users/carciofi/data/iraf/uparm/aptdataps.par",
                 #fitskypars="/Users/carciofi/data/iraf/uparm/aptfitsks.par",
                 #centerpars="/Users/carciofi/data/iraf/uparm/aptcentes.par",
                 #photpars="/Users/carciofi/data/iraf/uparm/aptphotps.par")

            delete (temp5, ver-, >& "dev$null")

        }
        
        nimages = j
        
        delete (temp4, ver-, >& "dev$null")

        delete (tempshift, ver-, >& "dev$null")


        #Run TXDUMP
        print("# Running TXDUMP ...")
           
        temp4 = mktemp("txdump")
           
        unlearn txdump
           
        txdump.textfiles = "*.mag.1"
        txdump.fields = "image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]"
           
        txdump(text="*.mag.1",
               fiel="image,msky,nsky,rapert[1-"//str(nap)//"],sum[1-"//str(nap)//"],area[1-"//str(nap)//"]",
               expr=yes,>> temp4//"")

        #Run pccdrap_e
        delete ("roda", ver-, >& "dev$null")

        delete (fileout, ver-, >& "dev$null")
        
        print (fileexe," ",temp4," ", fileout," ", nstars," ", nimages," ", nap," ", >> "roda")
        !source roda
        delete ("roda", ver-, >& "dev$null")

        delete ("*.mag.1", ver-, >& "dev$null")

        delete (temp4, ver-, >& "dev$null")

    }
        
    #Delect ccdproc images
    if (eraseccdproc)     
        imdel (images="ccdp_*.fits",go_ahead=yes, verify=no, >& "dev$null")

}

delete (filetemp, ver-, >& "dev$null")
        
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

        datapars.datamin=maxdata*1./3.
        
        delete ("coordtmp", ver-, >& "dev$null")

        daofind (image="sum"//raiz//version//".fits",
                 output="coordtmp",verify="no")
        
        imdel (images="shsum*"//version//".fits",go_ahead=yes, verify=no, >& "dev$null")


        imalign(input="sum*"//version//".fits",
               reference="sum"//raiz//version//".fits",
                coords="coordtmp",
               output="sh//sum*"//version//".fits",shifts="",
               boxsize=boxsize,bigbox=bigbox,trimimages=no,shiftimages=yes)

        delete ("coordtmp", ver-, >& "dev$null")

}
    
if (modo == 2) {
        delete (temp0, ver-, >& "dev$null")

        #delete (temp2//".ord", ver-, >& "dev$null")

        rename (temp2//".ord", "coord_"//root//version//".ord")

        delete (temp2//".ord", ver-, >& "dev$null")
}
    
delete (temp1, ver-, >& "dev$null")

delete ("coordtmp.ord", ver-, >& "dev$null")

flist1=""
flist2=""
flist3=""
datapars.datamin=INDEF
phot.interac = no
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
pccdgen.ganho = ganho

polrap.rootout = "w"//root//"_"
polrap.rootin = "sum_"//root//"_"
polrap.version1 = version
grafrap.root = polrap.rootout
grafrap.version1 = polrap.version1

if (1 == 1) {

    print("# ",>> "ccdraplog")
    print("# CCDRAP",>> "ccdraplog")
    print("# ",>> "ccdraplog")
    time(>> "ccdraplog")
    print("# ",>> "ccdraplog")

    print("#  root      : ", root, >> "ccdraplog")
    print("#  intera    : ", intera, >> "ccdraplog")
    print("#  modo      : ", modo,   >> "ccdraplog")
    print("#  version   : ", version,    >> "ccdraplog")
    print("#  overscan  : ", overscan,   >> "ccdraplog")
    print("#  zerocor   : ", zerocor,    >> "ccdraplog")
    print("#  darkcor   : ", darkcor , >> "ccdraplog")
    print("#  flatcor   : ", flatcor , >> "ccdraplog")
    #print("#  biassec   : ", biasseci , >> "ccdraplog")
    #print("#  trimsec   : ", trimseci , >> "ccdraplog")
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
    #print("#  exptime   : ", exptime, >> "ccdraplog")
    print("#  fileexe   : ", fileexe , >> "ccdraplog")

}

#Running jdrap
#jdrap(iw=iw,fw=fw,contiguous=contiguous)

fileout = "JD_"//root
delete (fileout, ver-, >& "dev$null")

print("# Writing JD values in file: ",fileout)

for (i = 1; i <= iw; i += 1) {
    print("WP "//i//"  "//JD[i], >> fileout)
}

end

