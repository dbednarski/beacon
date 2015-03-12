#
# Ver. Mar05
#

procedure pccd(filename)

string  filename        {prompt="input file (.dat)"}
int     nstars          {prompt="number of stars (max. 2000)"}
string  wavetype="half" {enum="half|quarter|other|v0other", prompt="wave-plate used ? (half,quarter,other,v0other)"}
real    retar=180       {prompt="retardance of waveplate (degrees)"}
int     nhw             {prompt="number of total wave-plate positions in input file? (max. 16)"}
pset    pospars         {prompt="wave-plate positions used to calculus? :e"}
int     nap             {prompt="number of apertures (max. 10)"}
string  calc="c"        {enum="c|p", prompt="analyser: calcite (c) / polaroid (p)"}
real    readnoise       {prompt="CCD readnoise (adu)"}
real    ganho           {prompt="CCD gain (e/adu)"}
real    deltatheta      {prompt="correction in polarization angle (degrees)"}
real    zero=0          {prompt="Zero of waveplate"}
string  fileout         {prompt="output file (.log)"}
string  fileexe="/iraf/iraf-2.16.1/extern/beacon/pccd/pccd2000gen05.mac.e"       {prompt="pccd execute file (.exe)"}
bool    norm = yes      {prompt="include normalization?"}
struct  *flist
struct  line1            {length=1000}
struct  line2            {length=1000}

begin

 string file1, file2, roda, aa, temp0, file_name, image, tmp, dum
 int pt[16] = 16(0)
 int pu[16] = 16(0)
 int nhw_used = 0
 int posline = 1
 int i = 1
 int j = 1
 int k = 0


 if  (pospars.pos_1 == yes)  pt[1]  = 1
 if  (pospars.pos_2 == yes)  pt[2]  = 1
 if  (pospars.pos_3 == yes)  pt[3]  = 1
 if  (pospars.pos_4 == yes)  pt[4]  = 1
 if  (pospars.pos_5 == yes)  pt[5]  = 1
 if  (pospars.pos_6 == yes)  pt[6]  = 1
 if  (pospars.pos_7 == yes)  pt[7]  = 1
 if  (pospars.pos_8 == yes)  pt[8]  = 1
 if  (pospars.pos_9 == yes)  pt[9]  = 1
 if  (pospars.pos_10 == yes) pt[10] = 1
 if  (pospars.pos_11 == yes) pt[11] = 1
 if  (pospars.pos_12 == yes) pt[12] = 1
 if  (pospars.pos_13 == yes) pt[13] = 1
 if  (pospars.pos_14 == yes) pt[14] = 1
 if  (pospars.pos_15 == yes) pt[15] = 1
 if  (pospars.pos_16 == yes) pt[16] = 1

 for (i=1; i <= 16; i+=1) {
 nhw_used = nhw_used + pt[i]
 }



 if ((pt[5] == 0) && (pt[6] == 0) && (pt[7] == 0) && (pt[8] == 0) && (nhw == 8)) {

 for (i=1; i <= 4; i+=1) pu[i] = pt[i]
 for (i=9; i <= 12; i+=1) {
 pu[i-4] = pt[i]
 }
 }
 else {
 for (i=1; i<=16; i+=1) pu[i] = pt[i]
 }





 #for (i=1; i<=16; i+=1) {
 #print(pu[i])
 #}

 tmp = envget("tmp")
  
 file_name = filename
 copy(file_name,tmp,ver-)
 cd tmp

 temp0 = mktemp("pccdgen")
 flist = file_name



 for (i=1; i <= nhw; i += 1) {
      for (k=1; k <= nstars ; k += 1) {
           aa = fscan(flist,line1)
           aa = fscan(flist,line2)
           
           if (pu[i] == 1) {
               print(line1, >> temp0)
               print(line2, >> temp0)
               
           }
      }
 }



 print("Extracting sequence of waveplate positions from ",file_name)

 flist = temp0
 while (fscan(flist,line1) != EOF) {
 aa = fscan(line1,image)
 print(image)
 }


 file1 = "entrada"
 if (access(file1)) delete(file1, ver-)

# print ("'", file_name, "'", >> file1)
 print ("'", temp0, "'", >> file1)
 print (nstars, >> file1)
 print (nhw, >> file1)
 print (nap, >> file1)
 print (calc, >> file1)
 print (readnoise, >> file1)
 print (ganho, >> file1)
 print (deltatheta, >> file1)
 print (zero, >> file1)
 print (wavetype, >> file1)
 i = 1
 while (i <= 16) {
 print (pt[i], >> file1)
 i = i + 1
 }
 print (nhw_used, >> file1)
 if (norm == no) print ("0",>> file1)
 if (norm == yes) print ("1",>> file1)
 if (wavetype == 'other') print (retar, >> file1)
 if (wavetype == 'v0other') print (retar, >> file1)





 file2 = "roda"
 if (access(file2)) delete(file2,ver-)

 if (access(fileout)) delete(fileout,ver-)
 print (fileexe, " <", file1, " >&", fileout, >> file2)




 !source roda

 delete(file1, ver-)
#print (temp0)
 delete(temp0, ver-)
 delete(file2, ver-)
 delete(file_name, ver-)
 

 dum = mktemp("tmp$dum")
 back > dum//""
 delete(dum,ver-)

 if (access(fileout)) delete(fileout)
 copy(tmp//fileout,".")
 delete(tmp//fileout,ver-)


end







