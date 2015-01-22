#
# Ver. Jun03
#

procedure pccd (filename)

string  filename     {prompt="input file (.dat)"}
int     nstars       {prompt="number of stars (maximum 2000)"}
int     nhw          {prompt="number of postions of wave-plate (maximum 16)"}
int     nap          {prompt="number of apertures (maximum 10)"}
string  calc         {enum="c|p", prompt="analyser: calcite (c) / polaroid (p)"}
real    readnoise    {prompt="CCD readnoise (adu)"}
real    ganho        {prompt="CCD gain (e/adu)"}
real    deltatheta   {prompt="correction in polarization angle (degrees)"}
string  fileout      {prompt="output file (.log)"}
string  fileexe      {prompt="pccd execute file (.exe)"}


begin
  
 string file1, file2, roda, tmp, file11, file_name, dum
  
 tmp = envget("tmp")

 file_name = filename
 copy(file_name,tmp,ver-)
 cd tmp
 
 
 file1 = "entrada"
 if (access(file1)) delete(file1, ver-)

 print ("'", file_name, "'", >> file1)
 print (nstars, >> file1)
 print (nhw, >> file1)
 print (nap, >> file1)
 print (calc, >> file1)
 print (readnoise, >> file1)
 print (ganho, >> file1)
 print (deltatheta, >> file1)
 
 
 
 file2 = "roda"
 if (access(file2)) delete(file2,ver-)

 if (access(fileout)) delete(fileout,ver-)
 print (fileexe, " <", file1, " >&", fileout, >> file2)  
 
 
 !source roda

 delete(file1, ver-)
 delete(file2, ver-)
 delete(file_name, ver-)
  
 dum = mktemp("tmp$dum")
 back > dum//""
 delete(dum,ver-)

 if (access(fileout)) delete(fileout)
 copy(tmp//fileout,".")
 delete(tmp//fileout,ver-)
   
  
end 
  





