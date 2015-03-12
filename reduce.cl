#
#Ver 2.1, 15mar10
#
procedure reduce(pref)

string pref="tpyx" {prompt="Prefix of filenames (WITHOUT '_')"}
string suf="_f"   {prompt="Suffix of filenames (same of calib. images)"}
string calib="../calib"   {prompt="Path to calib directory (WITHOUT last '/')"}
bool  dov1=yes    {prompt="Do the reduction without calibrations?"}
bool  dov2=yes    {prompt="Do the reduction using the calib. images?"}
bool  head=yes    {prompt="Use gain and readnoise values from headers?"}
bool  usecoords=yes    {prompt="Use previous daofind coordinates to next filters?"}
bool  dograph=yes    {prompt="Generate all .png graphs?"}
real ganho="INDEF"   {prompt="CCD gain to be used if head=no (e/adu)"}
real readno="INDEF"  {prompt="ReadNoise (ADUs) to be used if head=no (adu)"}
string pccdpath="/iraf/iraf-2.16.1/extern/beacon/pccd/" {prompt="Path to pccd files .e (blank to use values on ccdrap/pccdgen)"}
string graphpol="/iraf/iraf-2.16.1/extern/beacon/grafpol.py"   {prompt="Path to the grafpol.py code"}

struct *fstruct


begin

string ftemp, ftemp2, fname, flatname, inname, rinname, filter[5], verbose, coordfile
int i, n

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
    print("ERROR: file pccd2000gen05.mac.e and/or ccdrap_e.e not found on ", pccdpath,"\n\nIf this directory really exists, be sure that you have putted a \"/\" at the end of \"pccdpath\" parameter")
    error(1,1)
  }
}

if( !access(ccdrap.icom) && usecoords ) {
  print("ERROR: script ", ccdrap.icom, ", used for \"usecoords=yes\", not found!\nVerify and try again.")
  error(1,1)
}

# Set gain and readnoise from prompt
if(!head) {
  ccdrap.readnoise = readno
  ccdrap.ganho = ganho
}

# Set zero parameters of ccdrap
ccdrap.zero = calib//"/avg_bias"//suf//".fits"
if(dov2 && access(ccdrap.zero))
  ccdrap.zerocor=yes
else
  ccdrap.zerocor=no

if(suf==" " || suf=="  ")
  suf=""



# Loop at the filters
for (i = 1; i < 6; i=i+1) {

  ftemp = mktemp("ftemp_"//filter[i])
  inname = pref//"_"//filter[i]//suf
  rinname = pref//suf//"_"//filter[i]


  # List only images of type pref_filter[i]_suf_####.fits, where #### are only digits. It's essential to avoid get a second suffix (e.g. if suffix parameter is "_g5", it gets only "dsco_v_g5_0000.fits" files and not "dsco_v_g5_f_0000.fits")
  files(inname//"_[0-9]*.fits", > ftemp)
  fstruct = ftemp

  # COUNT LINES
  n = 0
  while (fscan(fstruct, fname) != EOF)
    n = n+1
  delete (ftemp, ver-, >& "dev$null")


# Verify if "filter" and "suf" are inverted in filenames. Case yes, rename.
  if( n == 0 ){

    print("rename ", "'s/"//rinname//"_/"//inname//"_/' ", rinname//"_[0-9]*.fits", > "roda")
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

  # Receive gain and readnoise from headers
  if(head) {
    imgets(fname, "GAIN")
    if (imgets.value != "0") {
      ccdrap.ganho=real(imgets.value)
      imgets(fname, "RDNOISE")
      ccdrap.readnoise=real(imgets.value)/ccdrap.ganho
    }
    else {
      print("FILTER "//filter[i]//": \"GAIN\" and \"RDNOISE\" don't exist in headers.")
      sleep(1)
      print("FILTER "//filter[i]//": nothing done! Fits haven't fields \"GAIN\" and \"RDNOISE\" in headers. Pass manually these values through the reduce parameters.", >> verbose)
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
      print("FILTER "//filter[i]//" .2: ERROR - calibration images not found.", >> verbose)

  }

  coordfile="coord_"//inname//".ord"

}


# Bednarski: generate .png modulation graphs:
if(dograph) {
  print("\n# Generating graphs...\n")
  print(graphpol, " -a ", > "roda")
  !source roda
  delete("roda", ver-, >& "dev$null")
}


# Print the sumary of reductions
if(access(verbose)){
  print("\n\n================")
  cat(verbose)
  delete(verbose, ver-, >& "dev$null")
}
else
  print("Nothing done.")


fstruct = ""

end
