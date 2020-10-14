BEACON PACKAGE v.2.1.4
======================

IRAF tools for reducing polarimetry and spectroscopy taken at OPD.

Beacon Group page: http://beacon.iag.usp.br/

Reduction tutorial: http://www.astro.iag.usp.br/~bednarski/obs/ixon-tutorial.pdf

General reduction guide: http://www.astro.iag.usp.br/~bednarski/obs/roteiro_reducao.txt


Installing Beacon Package
------

1. First, install the required package `bc`. For instance, in Debian-based
distributions, type

```
$ sudo apt-get install bc
```

2. Now, assuming that you are within your IRAF installation directory,
go to `extern/` subdirectory to install the Beacon package and type

```
$ git clone https://github.com/dbednarski/beacon.git
```

3. Edit the file `unix/hlib/extern.pkg` inside IRAF directory, adding the
following lines before the line containing `keep` command:

```
reset beacon     =  iraf$extern/beacon
task beacon.pkg  =  beacon$beacon.cl
```

4. Open IRAF and compile the .f Fortran codes below.
PS: if you are using a 64-bits Debian-based distribution, maybe you can
skip this step because there are binary files already, which should work
in you computer.

```
ecl> cd PATH_TO_BEACON_PACKAGE/pccd
ecl> !sudo chmod -R 777 .
ecl> !rm pccd2000gen05.mac.e ccdrap_e.e
ecl> fc pccd2000gen05.mac.f -o pccd2000gen05.mac.e
ecl> fc ccdrap_e.f -o ccdrap_e.e
```

Change log
------
See [./changes.log](changes.log) file. unfortunately, almost the content is in portuguese. 


Contact
------
Daniel Bednarski: daniel.bednarski.ramos@gmail.com


License
------
GNU General Public License v3.0
