# Le arquivos 2D e escreve um arquivo 3D contendo as imagens.
# O header da saida é o header da primeira imagem

procedure write3Dfits(fileroot)

string  fileroot="" {prompt="Fits filename (without the .fits, '*' is accepted)"}
struct *flist1 

begin

int i,naxis1,naxis2,nframes
string fileout,root,lista,imag

root = fileroot
fileout = "3D_"+root+".fits"

#Gera lista de arquivos a serem processados
lista = mktemp("lista")
files(root//"*", > lista)

#Conta quantos arquivos ha
flist1 = lista
nframes = 0
while (fscan(flist1, imag) != EOF) {
	nframes = nframes + 1
}

print ("# Writing ", nframes, " images in file ", fileout)
print ("# Creating empty image:")

imdel (images=fileout,go_ahead=yes, verify=no, >& "dev$null")
#$

#Gera imagem vazia
#Obtem tamanhos x e y
	unlearn imgets
	imgets(imag,"i_naxis1")
	naxis1 = int(imgets.value)
	unlearn imgets
	imgets(imag,"i_naxis2")
	naxis2 = int(imgets.value)
	
	imexpr ("I*0.0+J*0.0+K*0.0",fileout,dims=""//naxis1//","//naxis2//","//nframes)

flist1 = lista
i = 0
while (fscan(flist1, imag) != EOF) {
	i = i + 1
	imcopy (imag,fileout//"[*,*,"//i//"]")
}

delete (lista, ver-, >& "dev$null")
#$

#Add header NUMKIN
hedit(images=fileout,fields="NUMKIN",value=nframes,
			      add=yes,addonly=no,delete=no,verify=no,
				 show=no,update=yes)

flist1 = ""


end
