
load "/public/home/wab/lijh/module_check.ncl"
;Purpose :
; check the cmor result(Amon) in experiment-AMIP 
; 2019-08-08, lijianghao,  original code 
; 2019-08-10, lijianghao , refactor and then can process all variables(48) in Amon at last.
;=============================================== 
exper_name      = "amip";"amip"
cmor_member     = "r3i1p1f1"; "r2i1p1f1";"r1i1p1f1"
gamil_member    = "amip-ee14d-05"; "amip-ee14d-06"; "amip-ee14d-07"
cmor_data_root  = "/public1/wab/CMIP6/cmor/CMIP6/CMIP6/CMIP/CAS/FGOALS-g3/" + exper_name + "/"+ cmor_member + "/Amon/"
gamil_data_root = "/public1/wab/CMIP6/run/" + gamil_member + "/run/"
output_root     = "/public/home/wab/lijh/Amon"

;========================================
undef("plot_pfull_phalf")
procedure plot_pfull_phalf(variable, year, month, level_cmor)
begin
  cmor_data_path  = cmor_data_root +variable + "/gn/v20190806/"
  file_cmor = cmor_data_path + "/"+ variable+ "_Amon_FGOALS-g3_" + exper_name+ "_" + cmor_member +"_gn_" + year+"01-" + year +"12.nc"
  f_cmor    = addfile(file_cmor, "r")
  var_cmor  = f_cmor->$variable$
  ptop      = f_cmor->ptop
  ps        = f_cmor->ps
  sigama    = f_cmor->lev 
  lat       = f_cmor->lat
  lon       = f_cmor->lon
  var_cmor  = f_cmor->$variable$
  months = cd_string(f_cmor->time, "%N")
  outputfile = output_root +"/" + variable + "_" + year + "-" + months(month)
  wks    = gsn_open_wks("pdf", outputfile)
  system("echo '===> output file:"+ outputfile +".pdf" +"'")
  p = new((/12, dimsizes(sigama), dimsizes(lat), dimsizes(lon)/), double)
  do it = 0, 11
    do ilev = 0, dimsizes(sigama)-1
      p(it, ilev,:,:) = ptop + sigama(ilev) *(ps(it,:,:) - ptop)
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
  p@long_name     = "Reverse computed pressure at model levels"
  p&time          = ispan(0,11,1)
  p&lev           = sigama
  p&lat           = lat
  p&lon           = lon
  
  optArg = False
  spatial_plot(p(month, level_cmor, :,:), var_cmor(month, level_cmor,:,:), wks, optArg)
  profile_plot(p(month, :, 40,90), sigama, var_cmor(month,:,40,90), sigama, wks)
  series_plot(p(:, level_cmor, 40,90), var_cmor(0:11, level_cmor,40,90), wks)
end 

undef("plot_main")
procedure plot_main(variable, var_name, year, month, level_cmor, level_gamil)
  begin
  if(variable .eq. "prw" .or. variable .eq. "clivi" .or. variable .eq. "clwvi" .or. variable .eq. "hurs" .or. \\
     variable .eq. "prsn".or. variable .eq. "sfcWind" .or. variable .eq. "tasmax" .or. variable .eq. "tasmin") then 
    cmor_data_path  = cmor_data_root +variable + "/gn/v20190809/"
  else
    cmor_data_path  = cmor_data_root +variable + "/gn/v20190806/"
  end if 
  ;=============================================
  ; read in file 
  ;=============================================
  file_cmor = cmor_data_path + "/"+ variable+ "_Amon_FGOALS-g3_amip_" + cmor_member+ "_gn_" + year+"01-" + year +"12.nc"
  f_cmor    = addfile(file_cmor, "r")
  var_cmor  = f_cmor->$variable$

  dnames_cmor      = getfilevardimnames(f_cmor, variable)
  var_dimsize_cmor = dimsizes(dnames_cmor)
  ; year_month_days = cd_string(f_cmor->time, "%Y%N%D%H")
  ; print(year_month_days)

  ;------------------------------------------------------
  files    = systemfunc("ls " + gamil_data_root + gamil_member + ".gamil.h0."+year +"*.nc")
  fs_gamil = addfiles(files, "r")

  ListSetType(fs_gamil, "cat")
  ; tmp = cd_string(fs_gamil[1:5]->time, "%Y%N%D%H")
  ; print(tmp)
  ; exit()
  ;=============================================
  ; plot 
  ;=============================================
  if(variable .eq. "rtmt") then
    vars_name = str_split(var_name, "-")
    var1_name = vars_name(0)
    var2_name = vars_name(1)
    vars_gamil = fs_gamil[:]->$var1_name$ - fs_gamil[:]->$var2_name$

    dnames_gamil      = getfilevardimnames(fs_gamil[month], var1_name)
    var_dimsize_gamil = dimsizes(dnames_gamil)

    lat = fs_gamil[month]->lat
    lon = fs_gamil[month]->lon
    vars_gamil!0 = "time"
    vars_gamil!1 = "lat"
    vars_gamil!2 = "lon"
    lat@units    = "degrees_north"
    lon@units    = "degrees_east"
    vars_gamil&lat = lat
    vars_gamil&lon = lon
  else if(variable .eq. "clwvi" .or. variable .eq. "prsn") then
    vars_name  = str_split(var_name, "+")
    var1_name  = vars_name(0)
    var2_name  = vars_name(1)
    vars_gamil = fs_gamil[:]->$var1_name$ + fs_gamil[:]->$var2_name$

    dnames_gamil      = getfilevardimnames(fs_gamil[month], var1_name)
    var_dimsize_gamil = dimsizes(dnames_gamil)

    lat = fs_gamil[month]->lat
    lon = fs_gamil[month]->lon
    vars_gamil!0   = "time"
    vars_gamil!1   = "lat"
    vars_gamil!2   = "lon"
    lat@units      = "degrees_north"
    lon@units      = "degrees_east"
    vars_gamil&lat = lat
    vars_gamil&lon = lon
  else 
    dnames_gamil      = getfilevardimnames(fs_gamil[month], var_name)
    var_dimsize_gamil = dimsizes(dnames_gamil)
    vars_gamil        = fs_gamil[:]->$var_name$
  end if 
  end if 
  ; dsizes            = getfilevardimsizes(fs_gamil[month], var1_name)
  months = cd_string(f_cmor->time, "%N")
  outputfile = output_root +"/" + variable + "_" + year + "-" + months(month)
  wks    = gsn_open_wks("pdf", outputfile)
  system("echo '===> output file:"+ outputfile +".pdf" +"'")
  ;============================================
  ; spatial distribution pLot 
  ;============================================
  optArg   = True
  optArg@scale  = 1.0
  optArg@names = (/variable, var_name/)

  if(var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  ; if(getVarDimNames(var_cmor)(1) .eq. "plev" .and. getVarDimNames(vars_gamil)(1) .eq. "lev")  
    system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"," + dnames_cmor(3) +"'")
    if(isfilevar(f_cmor, "plev")) then
      plev  = f_cmor->plev 
      intyp = 1 ; 1=LINEAR, 2=LOG, 3=LOG LOG
      interped_gamil = vinth2p(vars_gamil(month,:,:,:), 1-fs_gamil[month]->lev, fs_gamil[month]->lev, plev * 0.01, \\
                    fs_gamil[:]->PS(month,:,:), intyp, 2.194, 1, False)
      spatial_plot(var_cmor(month, level_cmor, :,:), interped_gamil(level_cmor,:,:), wks, optArg)
    else
      if(variable .eq. "mc") then
        level_gamil   = 26 - level_cmor
      else
        level_gamil   = 25 - level_cmor
      end if 

      if(variable .eq. "cl") then
        optArg@scale  = 100
      end if 
        spatial_plot(var_cmor(month, level_cmor, :,:), vars_gamil(month, level_gamil,:,:), wks, optArg)
    end if 
  else
    system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"'")
    if (variable .eq. "clt" .or. variable .eq. "hurs") then
      optArg@scale = 100.0
    else if (variable .eq. "clivi" .or. variable .eq. "clwvi") then
      optArg@scale = 0.001
    else if (variable .eq. "pr" .or. variable .eq. "prc" .or. variable .eq. "prsn") then
      optArg@scale = 1000.0
    end if 
    end if 
    end if 
    if (variable .eq. "hurs") then
      new_array = new((/dimsizes(vars_gamil(month,:,0)), dimsizes(vars_gamil(month,0,:))/), float)
      new_array = 1.05
      vars_gamil(month,:,:) = where(vars_gamil(month,:,:) .gt. 1.05, new_array, vars_gamil(month,:,:))
    end if 
    spatial_plot(var_cmor(month, :, :), vars_gamil(month,:,:), wks, optArg)
  end if 
  ;============================================
  ; plot vertical profile
  ;============================================
  if (var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
    if(isfilevar(f_cmor, "plev")) then
      lev_cmor = f_cmor->plev
    else
      lev_cmor = f_cmor->lev
    end if
    if(var_name .eq. "CMFMC") then
      lev_gamil = fs_gamil[month]->ilev
    else
      lev_gamil = fs_gamil[month]->lev
    end if 
    profile_plot(var_cmor(month, :, 40,90), lev_cmor, vars_gamil(month, :, 40, 90), lev_gamil, wks)
  end if
  ;============================================
  ;plot time series 
  ;============================================
  times = ispan(0, 11, 1)
  if(var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
    if(isfilevar(f_cmor, "plev")) then
      plev  = f_cmor->plev
      intyp = 1 ; 1=LINEAR, 2=LOG, 3=LOG LOG
      inter_gamil = vinth2p(vars_gamil(0:11,:,:,:), 1-fs_gamil[month]->lev, fs_gamil[month]->lev, plev * 0.01, \\
                   fs_gamil[:]->PS(0:11,:,:), intyp, 2.194, 1, False)
      series_plot(var_cmor(times, level_cmor, 40,90), inter_gamil(times, level_cmor, 40,90), wks)
    else
      series_plot(var_cmor(times, level_cmor, 40,90), vars_gamil(times, level_gamil, 40,90), wks)
    end if 
  else
    series_plot(var_cmor(times, 40,90), vars_gamil(times,40,90), wks)
  end if 
  system("echo '===> 'end plot' '")
end

;============================================
; Main program
;============================================
begin
  file_table = "var_table-Amon.csv"
  lines = asciiread(file_table, -1, "string")
  strs = str_split_csv(lines, ",", 0)
  variables = strs(:,0)
  var_names = strs(:,1)
;============================================
; please choose variable in cmor and associtated var_name in GAMIL, date, level for check
;============================================
  do ivar = 0, dimsizes(variables)-1
    variable   = str_strip(variables(ivar))
    var_name   = str_strip(var_names(ivar))
    year       = 2010
    month      = 10 ; note the index in NCL not is the real index 
    level_cmor = 5 ; 5-500hPa [0-17]
    level_gamil= 18;  25-7 ; about 500hPa
    system("echo '=========> Variable:" + variable + " <=========" + "'")
    if (variable .eq. "pfull" .or. variable .eq. "phalf") then
      plot_pfull_phalf(variable, year, month, level_cmor)
    else
      plot_main(variable, var_name, year, month, level_cmor, level_gamil)
    end if 
  end do
end 
