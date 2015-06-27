#!/usr/bin/env python

"""
Program to plot the best adjust and its residuals.
pyhdust package is required.

grafpol [path] [suf] [extension]

'path' is path to the log files. If not specified, it is suposed as '.' dir.
'suf' is to generate only the graphs for log files having 'suf' suffix. 'suf' must begin with one '_' character. If not specified, generate for all logfile found.
'extension' is the extension for the graphs ('png', 'eps' or 'jpg'). If not specified, is used 'png'.


Daniel Bednarski, June 2015
"""

import os
import numpy as np
from glob import glob
from sys import argv

try:
    import pyhdust.poltools as polt
except:
    print('ERROR: pyhdust package not installed!')
    raise SystemExit(1)

# default values
path = os.getcwd()
extens = 'png'
suf = ''

# argv[0] is the command name
for i in range(1,len(argv)):
    if argv[i][0] == '_':
        suf = argv[i]
    elif argv[i] in ('eps','png','jpg'):
        extens=argv[i]
    else:
        path = argv[i]
        if not os.path.exists(path):
            print('ERROR: path {0} doesn\'t exist!'.format(path))
            raise SystemExit(1)

logs = glob('{0}/*{1}_*.log'.format(path,suf))
if len(logs) == 0:
    print('ERROR: no *.log files found!')
    print('{0}/*{1}_*.log'.format(path,suf))
    raise SystemExit(1)

print('Please wait, generating graphs...')
for log in logs:
    f0 = np.loadtxt(log, dtype=str, delimiter='\n', comments=None)
    nstars = int(f0[6].split()[-1])
    for nstar in range(1,nstars+1):
        polt.grafpol(log, nstar=nstar, save=True, extens=extens)

print('Done!')
