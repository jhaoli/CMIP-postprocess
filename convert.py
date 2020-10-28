#!/usr/bin/env python3
#_*_coding: utf-8 _*_

# extract precipitaion, ts from gamil output 

import os, sys
import numpy as np

gamil_root = '/public1/wab/CMIP6/run/abrupt-ee14d-05'

out_root = '/public/home/wab/lijh/CMIP6/tmp_data'

for iyear in np.arange(463,613): #613
#for iyear in np.arange(613,638): #613
  for imonth in np.arange(1,13):
    #cmd ='cdo -selvar,PRECC,PRECL,PRECT,TREFHT,TS,gw /public1/wab/CMIP6/run/abrupt-ee14d-05-reoutput/run/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-{im:02d}.nc ~/lijh/CMIP6/tmp_data/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-{im:02d}.nc'.format(iy=iyear, im=imonth)
    cmd ='cdo -selvar,FLUTOA,FSNTOA,gw /public1/wab/CMIP6/run/abrupt-ee14d-05-reoutput/run/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-{im:02d}.nc ~/lijh/CMIP6/tmp_data/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-{im:02d}.nc'.format(iy=iyear, im=imonth)
    os.system(cmd)
  cmd = 'cdo -O mergetime ~/lijh/CMIP6/tmp_data/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-??.nc ~/lijh/CMIP6/tmp_data/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}.nc'.format(iy=iyear)
  os.system(cmd)
  cmd ='rm -fr ~/lijh/CMIP6/tmp_data/abrupt-ee14d-05-reoutput.gamil.h0.0{iy:03d}-??.nc'.format(iy=iyear)
  os.system(cmd)
