#
# Ver 2.0, 13nov05
#
# Changes: 1) proceduro to U filter now
#          2) swap.tol parameter defined by calib_301 now
#

procedure calib_301

string pre = "s" 	{prompt="Preffix of dark images"}
string suf = "1" 	{prompt="Suffix of flat images (excluding the last 0 character)"}
bool    trim = yes 	{prompt="Trim the images?"}
bool    texpcor = yes   {prompt="Check the *real* integration time?"}
real    tol = 2.        {prompt="Exptime error tolerance (%)"}
bool    headcor = no 	{prompt="Reset exptime values in headers?"}
string  trimsec = "301s" {prompt="Trim data section"}
string  texpdarks = "" 	{prompt="Real dark exptimes (format xx.x; *00.0* to use header value)"}
string  texpflats = "uu.u bb.b vv.v rr.r ii.i" 	{prompt="Real flat exptimes (*00.0* to use header value)"}
struct *flist1
struct *flist2

# ABOUT texpdarks and texpflats parameters:
# Example: if there are n = 5 dark images, "texpdarks" format allways must be "t1 t2 t3 t4 t5" (since headcor=yes),
# even if the values of four last darks are correct in respectives images. Thereby, texpdarks must be explicitly "t1 00.0 00.0 00.0 00.0".
# The values must correspond to exptimes of the directories in alphabetical order


begin

string temp1, temp2, item
string image, lixo, trimseci, directory, darkpath, filter[5]
real texp, darktime
int i

filter[1]="u"
filter[2]="b"
filter[3]="v"
filter[4]="r"
filter[5]="i"

#Pre-defined trim sections
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


#Clean the routines parameters
unlearn flatcombine
unlearn darkcombine
unlearn ccdproc
flatcombine.delete = yes
flatcombine.ccdtype = ""
darkcombine.delete = yes
darkcombine.ccdtype = ""
ccdproc.ccdtype = ""
ccdproc.fixpix = no
ccdproc.overscan = no
ccdproc.trim = trim
ccdproc.flatcor = no
ccdproc.darkcor = no
ccdproc.zerocor = no
ccdproc.trimsec = trimseci
swap.tol = tol


# Procedure to combine darks

if (access("dark")) {

  chdir("dark")
  temp1 = mktemp("../dark_list")
  imdel(images=pre//"*.fits", verify=no, >& "dev$null")
  files(pre//"*"//"0", > temp1)
  flist1 = temp1
  i = 1

#Loop on the dark directories
  while (fscanf(flist1, "%3c %c", directory, lixo) != EOF) {

    chdir (directory//"0")
    imdel (images="*.fits", verify=no, >& "dev$null")

# Obtaining exptime of images
    texp = 0.
    if (headcor) {
      item  = substr(texpdarks,1+(i-1)*5,5+(i-1)*5)
      lixo = fscan(item,texp)
    }

# Case headcor=no or current parameter from texpdarks equals zero
    if (texp == 0) {
      temp2 = mktemp("../templist")
      files(pre//"*", > temp2)
      flist2 = temp2
      lixo = fscan (flist2, image)
      delete (temp2, ver-, >& "dev$null")
      swap (image, tcheck=no)
 
      temp2 = mktemp("tempexp")
      hselect(images=image//".fits", fields="EXPTIME", expr=yes, > temp2)
      flist2 = temp2
      lixo = fscan (flist2, texp)
      delete (temp2, ver-, >& "dev$null")
      imdel (images=image//".fits", verify=no, >& "dev$null")
    }

    print(directory//": Exptime "//texp//"s")
    print (directory//": Extracting dark imagens with swap...")
    if(texpcor)
      swap (directory//"*", exptime=texp, tcheck=yes)
    else
      swap (directory//"*", tcheck=no)

    print (directory//": Combining dark images with darkcombine...")
    darkcombine ("*.fits", output="../"//directory//"avg.fits")
    hedit(images="../"//directory//"avg.fits", fields="DARKTIME", value=texp, verify=no)
    print ("")
    chdir ("..")
    i = i + 1

  }

  delete (temp1, ver-, >& "dev$null")
  chdir("..")
}


# Procedure to combine flats

if (access("flat")) {

  chdir ("flat")
  imdel(images="f*"//suf//"avg.fits", verify=no, >& "dev$null")

#Loop on the flat directories
  for (i = 1; i < 6; i=i+1) {

    directory = "f"//filter[i]//suf
    if (! access (directory//"0"))
      next

    chdir (directory//"0")
    imdel (images="*.fits", verify=no, >& "dev$null")
    ccdproc.darkcor = no

# Obtaining exptimes of images
    texp = 0
    if (headcor) {
      item  = substr(texpflats,1+(i-1)*5,5+(i-1)*5)
      lixo = fscan(item,texp)
    }

# Case headcor=no or current parameter from texpflats equals zero
    if (texp == 0) {
      temp2 = mktemp("../templist")
      files(directory//"*", > temp2)
      flist2 = temp2
      lixo = fscan (flist2, image)
      delete (temp2, ver-, >& "dev$null")
      swap (image, tcheck=no)

      temp2 = mktemp("tempexp")
      hselect(images=image//".fits", fields="EXPTIME", expr=yes, > temp2)
      flist2 = temp2
      lixo = fscan (flist2, texp)
      delete (temp2, ver-, >& "dev$null")
      imdel (images=image//".fits", verify=no, >& "dev$null")
    }

    print(directory//": Exptime "//texp//"s")
    print (directory//": Extracting flat imagens with swap...")

    if(texpcor)  
      swap (directory//"*", exptime=texp, tcheck=yes)
    else
      swap (directory//"*", tcheck=no)

    if (access("../../dark")) {

      temp2 = mktemp("../dark_base")
      files("../../dark/"//pre//"*.fits", > temp2)
      flist2 = temp2

# Loop on the dark images to find what to substract of corrent flat
      while (fscan(flist2, darkpath) != EOF){
    
        temp1 = mktemp("darktemp")
        hselect(images=darkpath, fields="DARKTIME", expr=yes, > temp1)
        flist1 = temp1
        lixo = fscan (flist1, darktime)
        delete (temp1, ver-, >& "dev$null")

        if (texp == darktime) {
          ccdproc.darkcor = yes
          ccdproc.dark = darkpath
          break
        }
      }

    }

# Only enables the dark correction if was found the correct dark image in loop above
    if (ccdproc.darkcor)
      print (directory//": Combining flat images with flatcombine, using dark "//darkpath//"...")
    else
      print (directory//": Combining flat images with flatcombine, WITHOUT dark subtraction...")

    flatcombine ("*.fits", output="../"//directory//"avg.fits")
    delete (temp2, ver-, >& "dev$null")
    print ("")
    chdir ("..")

  }

  chdir ("..")

}

flist1 = ""
flist2 = ""

end
