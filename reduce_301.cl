#
# Ver 2.0, 13nov05
#
# Changes: 1) proceduro to U filter now
#          2) polrap.pout parameter is changed as "00" by the script
#          3) New reporting message in terminal
#          4) swap.tol parameter defined by reduce_301 now
#

procedure reduce_301

string pre = "s" 	{prompt="Preffix of corresponding dark images"}
string suf = "1" 	{prompt="Suffix of corresponding flat images (excluding the last 0 character)"}
bool    trim = yes 	{prompt="Trim the images?"}
bool    texpcor = yes   {prompt="Check the *real* integration time?"}
real    tol = 2.        {prompt="Exptime error tolerance (%)"}
bool    headcor = no 	{prompt="Reset exptime values in headers?"}
string  trimsec = "301s" {prompt="Trim data section"}
string  texpimg = "uu.u bb.b vv.v rr.r ii.i" 	{prompt="Real images exptimes (*00.0* to use header value)"}
struct *flist1
struct *flist2

# ABOUT texpimg parameter:
# Is necessary the five values (UBVRI), even that just one header value be wrong. Example: texpimg must be "00.0 bb.b 00.0 00.0 00.0", case only B value be wrong.


begin

string temp1, temp2, item
string image, lixo, darkpath, filter[5]
real texp, darktime
int i, n
# Dummy variable to fix a bug:
string dark

filter[1]="u"
filter[2]="b"
filter[3]="v"
filter[4]="r"
filter[5]="i"


# Set routines parameters (if texpcor == yes, ccdrap_301.exptime is changed inside of loop)
ccdrap_301.trim = trim
ccdrap_301.trimsec = trimsec
ccdrap_301.exptime = 0.
polrap.pout = "00"
swap.tcheck = texpcor
swap.tol = tol

print ("WARNING: It is necessary some previous running of calib_301 on calib images!")
sleep 1

# Loop on the filters directories
for (i = 1; i < 6; i=i+1) {

  if (! access (filter[i]))
    next
 
  chdir (filter[i])
# para que serve essa linha abaixo?
  imdel (images="p*.fits", verify=no, >& "dev$null")

# Obtaining exptime of images
  texp = 0.
  if (headcor) {
    item  = substr(texpimg,1+(i-1)*5,5+(i-1)*5)
    lixo = fscan(item,texp)
  }

# Register number of waveplates
  temp2 = mktemp("templist")
  files("p*", > temp2)
  flist2 = temp2
  n = 0
  while (fscan(flist2, item) != EOF)
    n = n+1
  delete (temp2, ver-, >& "dev$null")

# Case headcor == no or current parameter from texpimg equals zero
  if (texp == 0) {

    chdir(item)
    temp2 = mktemp("templist")
    files("p*", > temp2)
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

    chdir("..")
  }

# Set parameters
  ccdrap_301.fw = n
  ccdrap_301.darkcor = no
  ccdrap_301.flatcor = no
  ccdrap_301.dark = ""
  ccdrap_301.flat = ""
  if (texpcor)
    ccdrap_301.exptime = texp

# Run ccdrap_301 and polrap
  ccdrap_301 (version=".1")

  if (n >= 32) {
    polrap(n=8)
    polrap(n=16)
  }
  else
    polrap(n=n)

# Procedure to .2 version

  if (access("../../dark")) {

    temp2 = mktemp("../dark_base")
    files("../../dark/"//pre//"*.fits", > temp2)
    flist2 = temp2

# Loop on the dark images to find what to substract of corrent images
    while (fscan(flist2, darkpath) != EOF){
    
      temp1= mktemp("darktemp")
      hselect(images=darkpath, fields="DARKTIME", expr=yes, > temp1)
      flist1 = temp1
      lixo = fscan (flist1, darktime)
      delete (temp1, ver-, >& "dev$null")

      if (texp == darktime) {
        ccdrap_301.darkcor = yes
        ccdrap_301.dark = "../"//darkpath
        break
      }
    }
  }

  print("\n"//filter[i]//" filter: Exptime "//texp//"s")

  if (ccdrap_301.darkcor)
    print(filter[i]//" filter: Using "//darkpath//" dark")
  else
    print (filter[i]//" filter: Dark image of "//texp//"s not found. Caution: Dark headers can be wrong in case of no previous running of calib_301.")

  if (access("../../flat/f"//filter[i]//suf//"avg.fits")) {
    ccdrap_301.flatcor = yes
    ccdrap_301.flat="../../../flat/f"//filter[i]//suf//"avg.fits"
    print(filter[i]//" filter: Using "//ccdrap_301.flat//" flat")
  }
  else
    print (filter[i]//" filter: Flat image not found.")

  print ("")
  sleep 3

# Run ccdrap_301 and polrap
  if (ccdrap_301.flatcor || ccdrap_301.darkcor) {
    ccdrap_301 (version=".2")

    if (n >= 32) {
      polrap(n=8)
      polrap(n=16)
    }
    else
      polrap(n=n)
  }

  delete (temp2, ver-, >& "dev$null")
  chdir ("..")

}

flist1 = ""
flist2 = ""

end
