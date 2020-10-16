procedure reduce(pref,suf)

string pref="tpyx"         {prompt="Prefix of filenames (WITHOUT '_')"}
string suf="_f"            {prompt="Suffix of filenames (same of calib. images)"}
string calib="../calib"    {prompt="Path to calib directory (WITHOUT last '/')"}
bool   dov1=yes            {prompt="Do the reduction without calibrations?"}
bool   dov2=yes            {prompt="Do the reduction using the calib. images?"}
bool   head=yes            {prompt="Use gain and readnoise values from headers?"}
bool   ver1stwp=yes        {prompt="Verify if first image is the WP position L0?"}
bool   usecoords=yes       {prompt="Use previous daofind coordinates to next filters?"}
bool   dograph=no          {prompt="Generate all .png graphs?"}
real   ganho="INDEF"       {prompt="CCD gain to be used if head=no (e/adu)"}
real   readno="INDEF"      {prompt="ReadNoise (ADUs) to be used if head=no (adu)"}
int    reject=0            {prompt="Reject images with counts larger than this value (0 to use value from ccdrap)"}
string pccdpath="/iraf/iraf-2.16.1/extern/beacon/pccd/"       {prompt="Path to .e pccd files (blank to use values from ccdrap/pccdgen)"}
string graphpol="/iraf/iraf-2.16.1/extern/beacon/grafpol.py"  {prompt="Path to the grafpol.py code"}

struct *fstruct


begin

string ftemp, fname, flatname, inname, rinname, filter[5], verbose, coordfile, outamp, ccd, bin, serno
string preamp_serie, preamp_flat, preamp_bias, lixo
int i, n, test
real nreject

!rm -f verb* var roda &> /dev/null

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

ccdrap.ver1stwp=ver1stwp

if(pccdpath != "" && pccdpath != " " && pccdpath != "  "){
  pccdgen.fileexe=pccdpath//"pccd2000gen05.mac.e"
  ccdrap.fileexe=pccdpath//"ccdrap_e.e"
  ccdrap.icom=pccdpath//"icom.sh"
  ccdrap.meancol=pccdpath//"meancol.sh"

  if (!access(pccdgen.fileexe) || !access(ccdrap.fileexe) || !access(ccdrap.meancol)){
    print("# ERROR: one or more files below were not found in ", pccdpath,":\n\n   - pccd2000gen05.mac.e\n   - ccdrap_e.e\n   - meancol.sh\n\n(Note: be sure that you have putted a \"/\" at the end of \"pccdpath\" parameter.")
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
if(reject != 0)
  ccdrap.reject=reject


# Set zero parameters of ccdrap
ccdrap.zero = calib//"/avg_bias"//suf//".fits"
if(dov2 && access(ccdrap.zero)){
  # Verify if PREAMP field at bias header is a float type (and not string). Case yes, rename the field.
#  hedit(ccdrap.zero, "PREAMP", "((str($) ?= '*.')? str(int($))//'x' : ((str($) ?= '*x')? $ : str($)//'x'))", ver-, >& "dev$null")
  ccdrap.zerocor=yes
} else{
  ccdrap.zerocor=no
}

if(suf==" " || suf=="  ")
  suf=""

####################
### Loop on filters
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


  ##########################
  ### Verify if "filter" and "suf" are inverted in filenames. Case yes, rename.
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


  ##########################
  ### Verify if reject is correct
  imgets(fname, "VBIN")
  bin = imgets.value
  imgets(fname, "SERNO")
  serno = imgets.value
  if(serno == "4335" || serno == "4269"){
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
  if(serno != "9867" && serno != "10127" && serno != "4335" && serno != "4269"){
    ccd = "Unknown (Serial No. "//serno//")"
    outamp = "Unknown"
  }
  nreject = 0
  if(bin == "2" && outamp == "Conventional")
    nreject = 63000
  if(bin == "2" && outamp == "Electron Multiplying")
    nreject = 30000

  if(nreject == 0){
    print("\n# FILTER "//filter[i]//": WARNING! Be sure about the used reject value, because CCD was not identified automatically.")
    test = 1
    print("FILTER "//filter[i]//": WARNING! Be sure about the reject value.", >> verbose)
  }
  else if( ccdrap.reject > nreject ){
    print("\nABORTED! Reject value (saturation level) should be less than "//nreject//" for CCD "//ccd//", bin "//bin//", "//outamp//". (Assigned value: "//ccdrap.reject//")\nChange \'reject\' parameter and run again.", >> verbose)
    break
  }
  else if(nreject == 63000 && ccdrap.reject < 30000){
    print("\nABORTED! Reject value (saturation level) should be less than "//nreject//", but close of this value for CCD "//ccd//", bin "//bin//", "//outamp//" and the assigned value is too low ("//ccdrap.reject//"), compatible with the value used for Electron Multiplying output amplifier.\nCheck and run again.", >> verbose)
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
      print("\n# FILTER "//filter[i]//": WARNING! \"GAIN\" and/or \"RDNOISE\" don't exist in headers.")
      print("FILTER "//filter[i]//": NOT REDUCED! Fits haven't fields \"GAIN\" and/or \"RDNOISE\" in headers. Pass manually these values through the reduce parameters.", >> verbose)
      next
    }
  }


  #######################
  ### Reduce without calib images
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


  #########################
  ### Reduce with calib images
  if(dov2==yes) {

    flatname = calib//"/avg_flat_"//filter[i]//suf//".fits"
    if (access(flatname))
      ccdrap.flatcor=yes
    else
      ccdrap.flatcor=no

    if(ccdrap.flatcor || ccdrap.zerocor){

      imgets(fname, "PREAMP")
      preamp_serie = imgets.value

      #==================
      # Verify if PREAMP field at images header are float type (and not string). Case yes, rename the fields.
      print("echo "//preamp_serie//" | awk '{split($0,var,\".\"); if(substr(var[1],length(var[1]))==\"x\"){print var[1]} else{print var[1]\"x\"}}'", > "roda")    # Cansei de tentar fazer isso abaixo atraves do lixo de linguagem IRAF
      !source roda > var
      fstruct = "var"
      lixo = fscan(fstruct, preamp_serie)
      delete("roda", ver-, >& "dev$null")
      delete("var", ver-, >& "dev$null")
      
      if (ccdrap.flatcor) {
        imgets(flatname, "PREAMP")
        preamp_flat = imgets.value

        #==================
        # Verify if PREAMP field at flat header is a float type (and not string). Case yes, rename the fields.
        print("echo "//preamp_flat//" | awk '{split($0,var,\".\"); if(substr(var[1],length(var[1]))==\"x\"){print var[1]} else{print var[1]\"x\"}}'", > "roda")    # Cansei de tentar fazer isso abaixo atraves do lixo de linguagem IRAF
        !source roda > var
        fstruct = "var"
        lixo = fscan(fstruct, preamp_flat)
        delete("roda", ver-, >& "dev$null")
        delete("var", ver-, >& "dev$null")
      } else {
        # Only assigns the same value to work when flat image is not found
        preamp_flat = preamp_serie
      }

      if (ccdrap.zerocor) {
        imgets(ccdrap.zero, "PREAMP")
        preamp_bias = imgets.value

        #==================
        # Verify if PREAMP field at bias header is a float type (and not string). Case yes, rename the fields.
        print("echo "//preamp_bias//" | awk '{split($0,var,\".\"); if(substr(var[1],length(var[1]))==\"x\"){print var[1]} else{print var[1]\"x\"}}'", > "roda")    # Cansei de tentar fazer isso abaixo atraves do lixo de linguagem IRAF
        !source roda > var
        fstruct = "var"
        lixo = fscan(fstruct, preamp_bias)
        delete("roda", ver-, >& "dev$null")
        delete("var", ver-, >& "dev$null")
      } else {
        # Only assigns the same value to work when bias image is not found
        preamp_bias = preamp_serie
      }

      #==================
      # Reduce or display error messages (the preamps values are "0x" in case such keyword doesn't exist)
      if(preamp_serie == "0x" || ((preamp_serie == preamp_flat || preamp_flat == "0x") && (preamp_serie == preamp_bias || preamp_bias == "0x"))) {
#     if(1==1) {

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
      else if(preamp_serie != preamp_flat && preamp_serie != preamp_bias && (preamp_serie != "0x" && preamp_flat != "0x" && preamp_bias != "0x" ))
        print("FILTER "//filter[i]//" .2: NOT REDUCED! This serie, flat and bias have same suffix '"//suf//"'\n    and distinct pre-amplifier values: "//preamp_serie//" (serie), "//preamp_flat//" (flat) and "//preamp_bias//" (bias).", >> verbose)
      else if(preamp_serie != preamp_flat && preamp_serie != "0x" && preamp_flat != "0x")
        print("FILTER "//filter[i]//" .2: NOT REDUCED! This serie and flat have same suffix '"//suf//"'\n    and distinct pre-amplifier values: "//preamp_serie//" (serie) and "//preamp_flat//" (flat).", >> verbose)
      else if(preamp_serie != preamp_bias && preamp_serie != "0x" && preamp_bias != "0x")
        print("FILTER "//filter[i]//" .2: NOT REDUCED! This serie and bias have same suffix '"//suf//"'\n    and distinct pre-amplifier values: "//preamp_serie//" (serie) and "//preamp_bias//" (bias).", >> verbose)
    }
    else
      print("FILTER "//filter[i]//" .2: NOT REDUCED! Calibration images not found.", >> verbose)

  }

  coordfile="coord_"//inname//".ord"
  print("")
}


######################
### Bednarski: generate .png modulation graphs:
if(dograph) {
  print("\n# Generating graphs...")
  print(graphpol, " ", suf, > "roda")
  !source roda
  delete("roda", ver-, >& "dev$null")
}


######################
### Print the sumary of reductions
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
