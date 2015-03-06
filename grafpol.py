#!/usr/bin/env python

"""
Program to plot the best adjust and its residuals

Author: Moser, August 2013
Version modified by Bednarski, July 2014
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.transforms import offset_copy
import glob
from sys import argv

tela = False
todos = False
for i in range(len(argv)):
    if argv[i] == '--screen' or argv[i] == '-s':
        tela = True
    if argv[i] == '--all' or argv[i] == '-a':
        todos = True

def arraycheck(refs,values):
    if len(refs) != len(values):
        print('# PROBLEM HERE!')
        print refs, values
        raise SystemExit(0)
    outvec = []
    for i in range(len(refs)):
        if refs[i] != '0':
            outvec += [i]
    return values[outvec]

#ler *.log
def readlog(filename,sigma):
    file = np.loadtxt(filename, dtype=str, delimiter='\n')
    npts = int(file[8].split()[-1])
    delta = float(file[14].split()[-1])
    sigma = 1.
    for i in range(25, len(file)):
        if 'APERTURE' in file[i]:
            sig = float(file[i+2].split()[2])
            if sig < sigma:
                sigma = sig
                # Bed: Os Q e U sao os abaixo, conforme copiei da rotina graf.cl
                if float(file[i+2].split()[4]) < 0:
                    thet = - float(file[i+2].split()[4])
                else:
                    thet = 180. - float(file[i+2].split()[4])
                Q = float(file[i+2].split()[3])*np.cos(2.*thet*np.pi/180.)
                U = float(file[i+2].split()[3])*np.sin(2.*thet*np.pi/180.)
                n = npts/4 
                if npts%4 != 0:
                    n = n+1
                P_pts = []
                for j in range(n):
                    P_pts += file[i+4+j].split()
                P_pts = np.array(P_pts, dtype=float)
                th_pts = 22.5*np.arange(npts)-delta/2.
                j = filename.find('.')
                delta2 = int(filename[-2+j:j])-1
                # Bed: Modifiquei abaixo para as pos lam >= 10 terem o num impresso corretamente no grafico
                str_pts = map(str, np.arange(1,npts+1)+delta2)
                if int(file[9].split()[-1]) != npts:
                    refs = file[9].split()[3:-2]
                    #P_pts = arraycheck(refs,P_pts)
                    th_pts = arraycheck(refs,th_pts)
                    str_pts = arraycheck(refs,str_pts)
    if sigma == 1.:
        print('# ERROR reading the file %s !' % filename)
        Q = U = 0
        P_pts = th_pts = np.arange(1)
        str_pts = ['0','0']
    return(Q, U, sigma, P_pts, th_pts,str_pts)

def plotlog(Q,U,sigma,P_pts,th_pts,str_pts,filename):    
    
    fig = plt.figure(1)
    fig.clf()
    ax1 = plt.subplot(2, 1, 1)
    plt.title('Ajuste do arquivo '+filename)
    plt.ylabel('Polarizacao')
    
    ysigma = np.zeros(len(th_pts))+sigma
    plt.errorbar(th_pts,P_pts,yerr=ysigma, linewidth=0.7)

    th_det = np.linspace(th_pts[0]*.98,th_pts[-1]*1.02,100)
    P_det = Q*np.cos(4*th_det*np.pi/180)+U*np.sin(4*th_det*np.pi/180)

    plt.plot(th_det, P_det)
    plt.plot([th_det[0],th_det[-1]], [0,0], 'k--')    
    ax1.set_xlim([th_pts[0]*.98,th_pts[-1]*1.02])
    plt.setp( ax1.get_xticklabels(), visible=False)
    
    # Bed: Retirei o compartilhamento do eixo y com ax1, pois as escalas devem ser independentes
    ax2 = plt.subplot(2, 1, 2, sharex=ax1)
    plt.xlabel('Posicao lamina (graus)')
    plt.ylabel('Residuo (sigma)')
    
    P_fit = Q*np.cos(4*th_pts*np.pi/180)+U*np.sin(4*th_pts*np.pi/180)
    
    transOffset = offset_copy(ax2.transData, fig=fig, x = 0.00, y=0.10, units='inches')
    # Bed: Agora plota os residuos relativos (residuos divididos por sigma)
    plt.errorbar(th_pts, (P_pts-P_fit)/sigma, yerr=1)

    for i in range(len(th_pts)):
        plt.text(th_pts[i], (P_pts-P_fit)[i]/sigma, str_pts[i], transform=transOffset)  
    plt.plot([th_det[0],th_det[-1]], [0,0], 'k--')  
    
    if tela:
        plt.show()
    else:
        plt.savefig(filename.replace('.log','.png'))
    return

fileroot = raw_input('Digite o nome do arquivo (ou parte dele): ')
print('# Lembre-se de que se houver mais de um arquivo com os caracteres acima')
print("  sera' o grafico do que tiver menor incerteza.")
print("# Para gerar todos os graficos, use a flag '-a'; para exibir na tela '-s'")

fileroot = fileroot.replace('.log','')

files = glob.glob('*'+fileroot+'*.log')

if len(files) == 0:
    print('# Nenhum arquivo encontrado com *'+fileroot+'*.log !!')
    raise SystemExit(0) 

sigmaf = 1.
sigma = 1.
for filename in files:
    Q, U, sigma, P_pts, th_pts, str_pts = readlog(filename,sigma)
    if todos:
        plotlog(Q,U,sigma,P_pts,th_pts,str_pts,filename)
        
    if sigma < sigmaf:
        Qf=Q
        Uf=U
        sigmaf=sigma
        P_ptsf=P_pts
        th_ptsf=th_pts
        str_ptsf=str_pts
        filenamef=filename

if todos == False:
    plotlog(Qf,Uf,sigmaf,P_ptsf,th_ptsf,str_ptsf,filenamef)

print('\n# Fim da rotina de plot! Ver arquivo '+filenamef.replace('.log','.png'))
