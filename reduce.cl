#
#Ver 2.2, 15may10
#
procedure reduce

string pref="tpyx" {prompt="Prefix of filenames (WITHOUT '_')"}
string suf="_f"   {prompt="Suffix of filenames (same of calib. images)"}
string calib="../calib"   {prompt="Path to calib directory (WITHOUT last '/')"}
bool  dov1=yes    {prompt="Do the reduction without calibrations?"}
bool  dov2=yes    {prompt="Do the reduction using the calib. images?"}
bool  head=yes    {prompt="(obsolete) Use gain and readnoise values from headers?"}
bool  usecoords=yes    {prompt="Use previous daofind coordinates to next filters?"}
bool  dograph=no    {prompt="Generate all .png graphs?"}
real ganho="INDEF"   {prompt="(obsolete) CCD gain to be used if head=no (e/adu)"}
real readno="INDEF"  {prompt="(obsolete) ReadNoise (ADUs) to be used if head=no (adu)"}
int	reject=0     {prompt="Reject images with counts larger than this value (0 to use value from ccdrap)"}
string pccdpath="/iraf/iraf-2.16.1/extern/beacon/pccd/" {prompt="Path to .e pccd files (blank to use values from ccdrap/pccdgen)"}
string graphpol="/iraf/iraf-2.16.1/extern/beacon/grafpol.py"   {prompt="Path to the grafpol.py code"}

struct *fstruct


begin

string ftemp, ftemp2, fname, flatname, inname, rinname, filter[5], verbose, coordfile, outamp, ccd, bin, serno
int i, n, test
real nreject

!rm -f verb*  &> /dev/null

test=0
verbose = mktemp("verb")
coordfile=""
filter[1]="u"
filter[2]="b"
filter[3]="v"
filter[4]="r"
filter[5]="i"

# Set pccdgen parameters
pccdgen.wavetyp="half"
pccdgen.calc="c"
pccdgen.retar=180.

if(pccdpath != "" && pccdpath != " " && pccdpath != "  "){
  pccdgen.fileexe=pccdpath//"pccd2000gen05.mac.e"
  ccdrap.fileexe=pccdpath//"ccdrap_e.e"
  ccdrap.icom=pccdpath//"icom.sh"

  if (!access(pccdgen.fileexe) || !access(ccdrap.fileexe)){
    print("# ERROR: file pccd2000gen05.mac.e and/or ccdrap_e.e not found on ", pccdpath,"\n\nIf this directory really exists, be sure that you have putted a \"/\" at the end of \"pccdpath\" parameter")
    error(1,1)
  }
}

if( !access(ccdrap.icom) && usecoords ) {
  print("# ERROR: script ", ccdrap.icom, ", used for \"usecoords=yes\", not found!\nVerify and try again.")
  error(1,1)
}

# Set gain and readnoise from prompt
if(!head) {
  ccdrap.readnoise = readno
  ccdrap.ganho = ganho
}

# Setting reject
if(reject != 0){
  ccdrap.reject=reject
}


# Set zero parameters of ccdrap
ccdrap.zero = calib//"/avg_bias"//suf//".fits"
if(dov2 && access(ccdrap.zero))
  ccdrap.zerocor=yes
else
  ccdrap.zerocor=no

if(suf==" " || suf=="  ")
  suf=""


# Loop on filters
for (i = 1; i < 6; i=i+1) {

  ftemp = mktemp("ftemp_"//filter[i])
  inname = pref//"_"//filter[i]//suf
  rinname = pref//suf//"_"//filter[i]


  # List only images of type pref_filter[i]_suf_####.fits, where #### are only digits. It's essential to not get a second suffix (e.g. if suffix parameter is "_g5", it gets only "dsco_v_g5_0000.fits" files and not "dsco_v_g5_f_0000.fits")
  files(inname//"_[0-9]*.fits", > ftemp)
  fstruct = ftemp

  # COUNT LINES
  n = 0
  while (fscan(fstruct, fname) != EOF)
    n = n+1
  delete (ftemp, ver-, >& "dev$null")


# Verify if "filter" and "suf" are inverted in filenames. Case yes, rename.
  if( n == 0 ){

    print("rename ", "'s/"//rinname//"_/"//inname//"_/' ", rinname//"_[0-9]*.fits &> /dev/null", > "roda")
    !source roda
    delete("roda", ver-, >& "dev$null")

    ftemp = mktemp("ftemp_"//filter[i])
    files(inname//"_[0-9]*.fits", > ftemp)
    fstruct = ftemp

    # COUNT LINES again
    while (fscan(fstruct, fname) != EOF)
      n = n+1
    delete (ftemp, ver-, >& "dev$null")

    # If no objects
    if(n == 0)
      next
    else
      print("FILTER "//filter[i]//": fits renamed \""//rinname//"_[0-9]*.fits\"  ->  \""//inname//"_[0-9]*.fits\"", >> verbose)

  }

  # Verify if reject is correct
  imgets(fname, "VBIN")
  bin = imgets.value
  imgets(fname, "SERNO")
  serno = imgets.value
  if(serno == "4335"){
    ccd = "iXon"
    imgets(fname, "OUTPTAMP")
    outamp = imgets.value
  }
  if(serno == "10127"){
    ccd = "iKon 10127"
    outamp = "Conventional"
  }
  if(serno == "9867"){
    ccd = "iKon 9867"
    outamp = "Conventional"
  }
  if(serno != "9867" && serno != "10127" && serno != "4335"){
    ccd = "Unknown (Serial No. "//serno//")"
    outamp = "Unknown"
  }

  nreject = 0
  if(bin == "2" && outamp == "Conventional")
    nreject = 62000
  if(bin == "2" && outamp == "Electron Multiplying")
    nreject = 22000

  if(nreject == 0){
    print("\n# FILTER "//filter[i]//": WARNING! Be sure about the used reject value, because CCD was not identified automatically.")
    test = 1
    print("FILTER "//filter[i]//": WARNING! Be sure about the used reject value, because CCD was not identified automatically.", >> verbose)
  }
  else
    if( ccdrap.reject - nreject > 1000 || ccdrap.reject - nreject < -1000){
#      print("FILTER "//filter[i]//": \'reject\' value may be wrong.")
#      sleep(1)
#      print("FILTER "//filter[i]//": ABORTED!\n\n)
      print("\nABORTED! Reject value (saturation level) should be "//nreject//", not the assigned value of "//ccdrap.reject//" for CCD "//ccd//", bin "//bin//", "//outamp//".\nChange \'reject\' parameter and run again.", >> verbose)
      break
    }


  # Receive gain and readnoise from headers
  if(head) {
    imgets(fname, "GAIN")
    if (imgets.value != "0") {
      ccdrap.ganho=real(imgets.value)
      imgets(fname, "RDNOISE")
      ccdrap.readnoise=real(imgets.value)/ccdrap.ganho
    }
    else {
      print("\n# FILTER "//filter[i]//": WARNING! \"GAIN\" and \"RDNOISE\" don't exist in headers.")
      print("FILTER "//filter[i]//": NOT REDUCED! Fits haven't fields \"GAIN\" and \"RDNOISE\" in headers. Pass manually these values through the reduce parameters.", >> verbose)
      next
    }
  }


  # Reduce without calib images
  if(dov1==yes) {

    # The '|| access("coord_"//inname//".ord")' condition is redundant with ccdrap statments
    if( !usecoords || (coordfile=="" && !access("coord_"//inname//".ord")) || access("coord_"//inname//".ord"))
      ccdrap(inname, version=".1", zerocor=no, flatcor=no, zero="", flat="", coordref=no, coord="")
    else
      ccdrap(inname, version=".1", zerocor=no, flatcor=no, zero="", flat="", coordref=yes, coord=coordfile)

    if(n<=16)
      polrap(n=n)
    if(n>8)
      polrap(n=8)
    if(n>16)
      polrap(n=16)

    print("FILTER "//filter[i]//" .1: DONE!", >> verbose)
  }


  # Reduce with calib images
  if(dov2==yes) {

    flatname = calib//"/avg_flat_"//filter[i]//suf//".fits"
    if (access(flatname)) 
      ccdrap.flatcor=yes
    else
      ccdrap.flatcor=no

    if(ccdrap.flatcor || ccdrap.zerocor){

      if( !usecoords || (coordfile=="" && !access("coord_"//inname//".ord")) || access("coord_"//inname//".ord"))
        ccdrap(inname, version=".2", flat=flatname, coordref=no, coord="")
      else
        ccdrap(inname, version=".2", flat=flatname, coordref=yes, coord=coordfile)

      if(n<=16)
        polrap(n=n)
      if(n>8)
        polrap(n=8)
      if(n>16)
        polrap(n=16)

      if(!ccdrap.flatcor)
        print("FILTER "//filter[i]//" .2: DONE without flat.", >> verbose)
      else if(!ccdrap.zerocor)
        print("FILTER "//filter[i]//" .2: DONE without bias.", >> verbose)
      else
        print("FILTER "//filter[i]//" .2: DONE!", >> verbose)
    }
    else
      print("FILTER "//filter[i]//" .2: NOT REDUCED! Calibration images not found.", >> verbose)

  }

  coordfile="coord_"//inname//".ord"
  print("")
}


# Bednarski: generate .png modulation graphs:
if(dograph) {
  print("\n# Generating graphs...")
  print(graphpol, " ", suf, > "roda")
  !source roda
  delete("roda", ver-, >& "dev$null")
}


# Print the sumary of reductions
if(test == 1)
  print("\nWARNING! Be sure that the reject value (saturation level) is correct for unknown configuration: CCD "//ccd//", bin "//bin//", "//outamp//".", >> verbose)
print("", >> verbose)
    
if(access(verbose)){
  print("\n================")
  cat(verbose)
  delete(verbose, ver-, >& "dev$null")
}
else
  print("# Nothing done.")


fstruct = ""

end
