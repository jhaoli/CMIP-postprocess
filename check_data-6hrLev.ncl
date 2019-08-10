load "/public/home/wab/lijh/module_check.ncl"
;Purpose :
; check the cmor result(6hrLev) in experiment-AMIP 
; 08/08/2019, lijianghao
;
begin

;{ "hus"; "pfull"   ;"ps" ; "ta" ; "ua"; "va" }
;{ "Q"  ;"<pfull>"  ;"PS" ; "T"  ; "U" ; "V"  }

;============================================
; please choose variable in cmor and associtate var_name in GAMIL, date, level for check
;============================================
variable   = "va" 
var_name   = "V"
year       = 1979 ; year, month, and day must be determined by the name of files in GAMIL data directory, not be 
month      = 3 ;  given arbitrarily
day        = 2 ;
hour       = 00
item       = 2 ;  represent the sequence number of gamil file would be ploted, maximum is 29, because one single file only has 30 times
level_cmor = 7 ; about 500hPa
level_gamil= 18;  25-7 ; about 500hPa

;============================================
; data directory
;============================================
cmor_data_root  = "/public1/wab/CMIP6/cmor/CMIP6/CMIP6/CMIP/CAS/FGOALS-g3/amip/r1i1p1f1/6hrLev/" +variable + "/gn/v20190807/"
gamil_data_root = "/public1/wab/CMIP6/run/amip-ee14d-07/run/"
cmor_data_path  = cmor_data_root 
output_root     = "/public/home/wab/lijh/6hrLev"
;=============================================
; read in file 
;=============================================
file_cmor = cmor_data_path + "/"+ variable+ "_6hrLev_FGOALS-g3_amip_r1i1p1f1_gn_" + year + "01010300" +"-" + year +"12312100.nc"
f_cmor    = addfile(file_cmor, "r")
;---------------------------------
file_gamil    = gamil_data_root + "amip-ee14d-07.gamil.h2."+year + "-" \\
                      + sprinti("%0.2i", month) + "-" + sprinti("%0.2i", day) +"-" +"00000.nc"
f_gamil       = addfile(file_gamil, "r")

year_month_days = cd_string(f_gamil->time, "%Y%N%D%H")
;===================================================
system("echo '===> first date in file:" + year_month_days(0) +"'")

outputfile = output_root +"/" + variable + "_" + year_month_days(item)
wks    = gsn_open_wks("pdf", outputfile)
system("echo '===> output file:"+ outputfile +".pdf" +"'")

if (variable .eq. "pfull") then
  ptop      = f_cmor->ptop
  ps        = f_cmor->ps
  sigama    = f_cmor->lev 
  lat       = f_cmor->lat
  lon       = f_cmor->lon
  var_cmor  = f_cmor->$variable$
  doy       = day_of_year(year, month, day)
  ts = (doy-1)*4-1

  p = new((/30, dimsizes(sigama), dimsizes(lat), dimsizes(lon)/), double)
  do it = 0, 29
    do ilev = 0, dimsizes(sigama)-1
      p(it, ilev,:,:) = ptop + sigama(ilev) *(ps(ts+it,:,:) - ptop)
    end do 
  end do 
  p!0 = "time"
  p!1 = "lev"
  p!2 = "lat"
  p!3 = "lon"
  lat@units       = "degrees_north"
  lon@units       = "degrees_east"
  p@units         = "Pa"
  p@standard_name = "air_pressure"
  p@long_name     = "Reverse computed pressure at model full levels"
  p&time          = ispan(0,29,1)
  p&lev           = sigama
  p&lat           = lat
  p&lon           = lon
  spatial_plot(p(item, level_cmor, :,:), var_cmor(ts+item, level_cmor,:,:), 1.0 wks)
  profile_plot(p(item, :, 40,90), sigama, var_cmor(ts+item,:,40,90), sigama, wks)
  series_plot(p(:, level_cmor, 40,90), var_cmor(ts:ts+29, level_cmor,40,90), wks)
  exit()
end if

;-------------------------------------
;
; call procedure in "module_plot.ncl"
;
spatial_pattern_plot(f_cmor, f_gamil, variable, var_name, \\
                    level_cmor, level_gamil, \\
                    year, month, day, item, wks)
vertical_profile_plot(f_cmor, f_gamil, variable, var_name, year, month, day, item, wks)
time_series_plot(f_cmor, f_gamil, variable, var_name, \\
                 level_cmor, level_gamil, year, month, day, wks)

system("echo '===> 'end plot' '")
end 


