#
# Ver. Mar05
#

procedure macrol 

string file_in           {prompt="pccd output file (.log) or list(@*)"}
string file_out          {prompt="output file (.out)"}
string minimun="first"   {enum="first|full", prompt="minimum? (first,full)"}
  
struct *flist,*flistvar

begin

     int    nl = 0
     int    ml = 0
     int    gl = 0
     int    tl = 0 
     
     real   naper = 0
     int    nstar = 0
     int    stars = 0
     real   positions = 0
     real   apertures = 0 
     int    nnstar = 0
     
     
     real qq = 0
     real uu = 0
     real ss = 0
     real pp = 0
     real tt = 0
     real st = 0
     real vv = 0
     real svv = 0
     real sfull = 0

     real ssconst = 100 
 
     real qqq = 0
     real uuu = 0
     real sss  
     real ppp = 0
     real ttt = 0
     real stt = 0
 
     real aperval = 0
     real aperok = 0
     real qq1, uu1, ss1, pp1, tt1, st1
     real nhw_used = 0
     bool primin
     int  nfile
     
     string outfile, lix, cadena, filein_list, vtmpfile, namev
     string waveplate, tmp
     struct line, line10, line12, line14, line26, linedata, lineaper
     struct line11, line13
     
     sss = ssconst
     lineaper = "   0.       0.       0.       0.         0.     0.    "

     filein_list = file_in

     # Create list of input files in a temporary file
     vtmpfile = mktemp ("tmp$tmpvar")
     files (filein_list, > vtmpfile)
     flistvar = vtmpfile

     #Elimina arquivo de saida se existe, no diretorio local
     delete(file_out//".out",ver-)

     # Define nome do archivo de saida (.out), no diretorio tmp$
     tmp = envget("tmp")
     outfile = tmp // file_out // ".out"
     if (access(outfile)) delete(outfile, ver-)
 
     # Imprime cabecario no archivo de saida 


     # print ("     Q        U        SIGMA   P       THETA  SIGMAtheor.  APERTURE  STAR", >> outfile)

     nfile = 0

     # Fazendo o "do" nos arquivos da lista de entrada
     while (fscan(flistvar, namev) != EOF) {

     nfile = nfile + 1

     # Inicializa o puntero de lectura 'flist' ao archivo (.log)
     flist = namev
     print("File : ",namev)
     nl = 0
     nstar = 0

     waveplate = "half"
         
     # Comeca letura do archivo (.log) com 'flist'
     while (fscan (flist, line) != EOF) {
     
     
         # Conta o numero de linha
         nl = nl + 1 
         
         # Pega os dados da linha nl
         if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other"))
             linedata = fscan (line, vv, svv, qq, uu, ss, pp, tt, st, sfull)
	 else
             linedata = fscan (line, qq, uu, ss, pp, tt, st)

         # Elimina do calculo as linhas con dados espureos
         #cadena = substr (line,1,4)
         #if (cadena == " NaN" )

          if ( (stridx(line,"nan") != 0) || (stridx(line,"NaN") != 0))
	     ss = ssconst

         
         # lee o numero de estrelas do arquivo de entrada (.log)
         if (nl == 10)
	     line10 = fscan (line, lix, lix, lix, lix, stars)

         #lee o tipo de lamina retardadora usada
	 if (nl == 11)
	     line11 = fscan(line,lix,lix,lix,waveplate)


	 # lee o numero de posicoes do arquivo de entrada (.log)
         if (nl == 12)
             line12 = fscan (line, lix, lix, lix, lix, lix, positions)

	 # read the position number used from pccdgen output
	 if (nl == 13) {
             line13 = fscan(line,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,lix,nhw_used)
             if (nhw_used != 0) {
	         if (mod(nhw_used,4) !=0) positions = int(nhw_used/4)*4 + 4
		 else positions = int(nhw_used/4)*4
	     }
	 }

         # lee o numero de aperturas do arquivo de entrada (.log)
         if (nl == 14)
             line14 = fscan (line, lix, lix, lix, lix, apertures)
             
         # lee tamanho da apertura
         if (substr(line,1,9) == " APERTURE")
             line26 = fscan (line, lix, lix, aperval)
	 
             
         if (substr(line,1,5) == " STAR")  
             primin = no
        
                    
         # Verifica letura ate o numero massimo de estrelas 
         if (stars > nstar) {
 
             if (frac(positions / 4) == 0)
                  gl = 6 + (positions / 4)
             else              
                  gl = 7 + int(positions / 4)
                   
             ml = 1 + (apertures * gl)
        
             tl = 28 + (nstar * ml) + (naper * gl)
             
           
             
             # Verfica letura ate o numero massimo de aperturas
             if (apertures > naper) { 
             
                
  
                 # Verifica sim o numero de linha contem os dados Q, U, ,,,
                 # e evalua cada apertura para a estrela nstar
                 if (nl == tl) { 
             
                     naper  = naper + 1 
                     nnstar = nstar + 1 
                     print ("Evaluating...star ", nnstar, " of ", stars, ", aperture ", naper, " of ", apertures)  
                    
                     if (minimun == "first") {
		         if (ss > sss)
                             primin = yes
	             }
                       
                     # Verifica se o SIGMA e' minimo 
                     if (ss < sss && primin == no) {
                       
                         lineaper = line         
                         qqq = qq 
                         uuu = uu 
                         sss = ss 
                         ppp = pp  
                         ttt = tt  
                         stt = st
                         aperok = aperval
                         
                     }
                      
                     # Verifica se termino evaluacao de aperturas para a estrela nstar                     
                     if (naper == apertures) {
                 
                         # Imprime apertura dados de apertura com menor SIGMA
                         if ((waveplate == "quarter") || (waveplate == "other") || (waveplate == "v0other")) {
			     if (nstar == 0 && nfile == 1) print ("     V     SIGMAV      Q        U      SIGMA      P    THETA SIGMAth.    rms     APER. STAR", >>outfile)
                             print (lineaper, "  ", aperok, "  ", nnstar,>> outfile)
                             }
			 else {
                             if (nstar == 0 && nfile == 1) print ("     Q        U        SIGMA   P       THETA  SIGMAtheor.  APERTURE  STAR", >> outfile)
			     print (lineaper, "        ", aperok, "     ", nnstar,>> outfile)
		         }


			 # Atualiza variaveis para prossima letura
                         nstar = nstar + 1 
                         qqq   = 0
                         uuu   = 0
                         sss   = ssconst
                         ppp   = 0
                         ttt   = 0
                         stt   = 0
                         naper = 0
                         lineaper  = "   0.       0.       0.       0.         0.     0.    "
                      }
                      
                   }       
   
                }          
          }         
     }
     }


movefiles(outfile,".")


delete(vtmpfile, ver-)
flistvar=""
flist=""
end
  

 
 
 
 
 
  




