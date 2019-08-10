load "/public/home/wab/lijh/module_check.ncl"
;Purpose :
; check the cmor result(3hr) in experiment-AMIP 
; 08/08/2019, lijianghao
;
begin

;{ "clt"   ;"hfls"   ;"hfss" ;"huss"   ;"pr"    ;"prc"   ;"ps" ;"rlds" ；"rldscs"; "rsdxdiff"   ;"rsus" ; "rsuscs"; "tas"}
;{ "CLDTOT";"LHFLX"  ;"SHFLX";"QREFHT" ;"PRECT" ;"PRECC" ;"PS" ;"FLDS" ; "FLDSC" ; "SOLLD+SOLSD";"FSUS" ; "FSUSC" ; "TREFHT" }

;============================================
; please choose variable in cmor and associtate var_name in GAMIL, date, level for check
;============================================
variable   = "clt" 
var_name   = "CLDTOT"
year       = 1994 ; year, month, and day must be determined by the name of files in GAMIL data directory, not be 
month      = 8 ;  given arbitrarily
day        = 14 ;
item       = 0 ;  represent the sequence number of gamil file would be ploted, maximum is 29, because one single file only has 30 times
level_cmor = 3 ; 3-500hPa [0-7]
level_gamil= 18;  25-7 ; about 500hPa

;============================================
; data directory
;============================================
cmor_data_root  = "/public1/wab/CMIP6/cmor/CMIP6/CMIP6/CMIP/CAS/FGOALS-g3/amip/r1i1p1f1/3hr/" +variable + "/gn/v20190807/"
gamil_data_root = "/public1/wab/CMIP6/run/amip-ee14d-07/run/"
cmor_data_path  = cmor_data_root 
output_root     = "/public/home/wab/lijh/3hr"
;=============================================
; read in file 
;=============================================
file_cmor = cmor_data_path + "/"+ variable+ "_3hr_FGOALS-g3_amip_r1i1p1f1_gn_" + year + "01010130" +"-" + year +"12312230.nc"

f_cmor    = addfile(file_cmor, "r")
doy       = day_of_year(year, month, day)
; tmp = cd_string(f_cmor->time, "%Y%N%D%H")


var_cmor  = f_cmor->$variable$

dnames_cmor      = getfilevardimnames(f_cmor, variable)
var_dimsize_cmor = dimsizes(dnames_cmor)

;------------------------------------------------------
file_gamil    = gamil_data_root + "amip-ee14d-07.gamil.h3."+year + "-" \\
                      + sprinti("%0.2i", month) + "-" + sprinti("%0.2i", day) +"-" +"00000.nc"
f_gamil           = addfile(file_gamil, "r")
var_gamil         = f_gamil->$var_name$
dnames_gamil      = getfilevardimnames(f_gamil, var_name)
var_dimsize_gamil = dimsizes(dnames_gamil)

; dsizes            = getfilevardimsizes(fs_gamil[month], var1_name)

;============================================
; spatial distribution pLot 
;============================================
year_month_days = cd_string(f_gamil->time, "%Y%N%D%H")

system("echo '===> first date in file:" + year_month_days(0) +"'")

outputfile = output_root +"/" + variable + "_" + year_month_days(item)
wks    = gsn_open_wks("pdf", outputfile)
system("echo '===> output file:"+ outputfile +".pdf" +"'")

wks    = gsn_open_wks("pdf", output_root +"/" + variable + "_" + year_month_days(item))

ts = (doy-1)*8-1+item
;============================================
; plot spatial pattern
;============================================
optArg   = True
if(var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"," + dnames_cmor(3) +"'")
  optArg@scale  = 1.0
  spatial_plot(var_cmor(ts, level_cmor, :,:), var_gamil(item, level_gamil,:,:), wks, optArg)
else
  system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"'")
  if (variable .eq. "clt") then
    optArg@scale = 100.0
  else
    optArg@scale = 1.0
  end if 
  spatial_plot(var_cmor(ts, :, :), var_gamil(item,:,:), wks, optArg)
end if 
;============================================
; plot vertical profile
;============================================
if (var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  if (variable .eq. "ta" .or. variable .eq. "ua" .or. variable .eq. "va" \\
      .or. variable .eq. "wap" .or. variable .eq. "zg") then
    lev_cmor = f_cmor->plev
  else 
    lev_cmor = f_cmor->lev
  end if 
  lev_gamil = f_gamil->lev
  profile_plot(var_cmor(ts, :, 40,90), lev_cmor, var_gamil(item, :, 40, 90), lev_gamil, wks)
end if 
;============================================
;plot time series 
;============================================
te = (doy-1)*8-1+item+29
if(var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  series_plot(var_cmor(ts:te, level_cmor, 40,90), var_gamil(0:29, level_gamil, 40,90), wks)
else
  series_plot(var_cmor(ts:te, 40,90), var_gamil(0:29,40,90), wks)
end if 
system("echo '===> 'end plot' '")
end
