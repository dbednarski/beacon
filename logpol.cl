#
# Ver 1.0, 14out16
#
# Bednarski
#
procedure logpol


string stand="/iraf/iraf-2.16.1/extern/beacon/std_published.dat"   {prompt="File list of standards"}
struct *fstruct
struct *sstruct


begin

string ftemp1, ftemp2, stemp, std, prenm, filenm, calcite, filter, target, path, field, lixo, lixo2, lixo3, jd
real var
int test


ftemp1 = mktemp("ftemp1")
ftemp2 = mktemp("ftemp2")

# Find fits files and select only one for each object/filter
find("-name *.fits | sed -E s/_[0-9]\*\.fits// | grep -v calib | sort", > ftemp1)
unique(ftemp1, > ftemp2)
fstruct=ftemp2

delete ("std.log", ver-, >& "dev$null")
delete ("obj.log", ver-, >& "dev$null")
printf("#%11s%7s%7s%18s%9s%25s\n", "Target", "Filt", "Calc", "JD", "Ang_pub", ".out", > "std.log")
printf("#%11s%7s%7s%18s%25s\n", "Target", "Filt", "Calc", "JD", ".out", > "obj.log")


# Loop on files
while (fscan(fstruct, path) != EOF) {

  calcite = "a?"
  jd = "no-reduced"

  # Verify if calcite is in path name
  test = strstr("_a", path)
  if(test != 0)
    calcite = substr(path,test+1,test+2)

  # Extract the name of file (without the whole path)
  test = strlstr("/", path)
  filenm = substr(path,test+1,strlen(path))
  prenm = substr(path,1,test)

  # Extract the name of target
  test = strstr("_", filenm)
  target = substr(filenm,1,test-1)

  # Receive the filter
  if (strstr("_u", filenm) != 0){
    filter = "u"
    field = 4
  }
  else if (strstr("_b", filenm) != 0){
    filter = "b"
    field = 7
  }
  else if (strstr("_v", filenm) != 0){
    filter = "v"
    field = 10
  }
  else if (strstr("_r", filenm) != 0){
    filter = "r"
    field = 13
  }
  else if (strstr("_i", filenm) != 0){
    filter = "i"
    field = 16
  }
  else{
    filter = "?"
    field = 0
  }

  # Get JD, if object reduced
  sstruct = prenm//"JD_"//filenm
  if (access(prenm//"JD_"//filenm)){
    lixo = fscanf(sstruct, "%s %s %f", lixo2, lixo3, var)
    jd = str(var)
  }

#  head("JD_"//filenm, nl=1, )

  # Test if is an object or polarimetric standard and get the published value of theta
  stemp = mktemp("stemp")
  sstruct = stemp
  cat(stand//" | grep "//target//" | sed 's/\(\\t\| \)\+/\\t/g' | cut -f'"//field//"'", > stemp)
  
  if (fscan(sstruct, std) != EOF)
    printf("%12s%7s%7s%18s%9s   \n", target, filter, calcite, jd, std, >> "std.log")
  else
    printf("%12s%7s%7s%18s   \n", target, filter, calcite, jd, >> "obj.log")

  print(path, "   ", filenm, "   ", target, "   ", filter, "   ", calcite, "   ", jd, "   ", std)

  delete (stemp, ver-, >& "dev$null")

}


delete ("ftemp*", ver-, >& "dev$null")


end
