# 
# Script phot_pol  (Ver 1.0)
#
#
# Esse script roda um executavel (phot_pol_e.e) baseado na rotina 
# 
# Claudia V. Rodrigues - 08/1999
#
procedure phot_pol (file_in, file_out)
#
int	  nstars      {min=0, prompt="Numero de estrelas"}
int	  nhw         {min=0, prompt="Numero de posicoes da lamina"}
int       nap         {min=0, prompt="Numero de aberturas"}
int       star        {min=0, prompt="Numero da estrela a se fazer (fotometria"}
int       star_out    {min=0, prompt="Estrela que nao eh incluida na soma dos fluxos, alem da star"}
string    file_in     {prompt="Arquivo com saida txdump"}
string    file_out    {prompt="Nome archivo de saida"}
real	  ganho	      {prompt="Ganho - e/adu"}

begin 

string out,in,file2

out=file_out
in=file_in

if (access(out)) delete (out,ver-)
#print(in,out,nstars,nhw,nap,star,star_out,ganho)
#phot_pol_e(in, out, nstars, nhw, nap, star, star_out,ganho)  
#print(ganho)

file2 = "roda"
if (access(file2)) delete(file2,ver-)

print ("/iraf/extern/pccdpack/pccd/phot_pol_e.e"," ",in," ", out," ", nstars," ", nhw," ", nap," ", star," ", star_out," ",ganho, >> file2)

!source roda

#delete(file2, ver-)


end 
