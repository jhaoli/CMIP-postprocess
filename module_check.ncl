load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

;============================================
; spatial distribution pLot 
;============================================
undef("spatial_pattern_plot")
procedure spatial_pattern_plot(f_cmor, f_gamil, variable, var_name, \\
                               level_cmor:integer, level_gamil:integer, \\
                                 year:integer, month:integer, day:integer, item:integer, wks)
local var_cmor, var_gamil, var_dimsize_cmor, var_dimsize_gamil, \\
      dnames_cmor, dnames_gamil, year_month_days, tmp, lat, lon
begin
var_cmor  = f_cmor->$variable$
var_gamil = f_gamil->$var_name$
var_dimsize_cmor  = dimsizes(dimsizes(var_cmor))
var_dimsize_gamil = dimsizes(dimsizes(var_gamil))
doy       = day_of_year(year, month, day)
dnames_cmor      = getfilevardimnames(f_cmor, variable)
dnames_gamil      = getfilevardimnames(f_gamil, var_name)
year_month_days = cd_string(f_gamil->time, "%Y%N%D")

system("echo '===> 'plot spatial distribution' '")
plot = new(3, graphic)

res0                    = True 
res0@gsnDraw            = False
res0@gsnFrame           = False
res0@gsnFrame           = False
res0@vpHeightF          = 0.32
res0@vpWidthF           = 0.32
res0@mpOutlineOn        = True
res0@mpFillOn           = False
res0@cnLineLabelsOn     = True
res0@cnConstFEnableFill = True
res0@cnLinesOn          = True
res0@cnFillOn           = True
res0@cnFillMode         = "RasterFill"
res0@cnFillPalette      = "GMT_panoply" 


if (var_dimsize_cmor .eq. 4) then
  system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"," + dnames_cmor(3) +"'")
  res0@tiMainString = "CMOR-" + variable +"-" + tostring(f_cmor->lev(level_cmor)) +"-" + year_month_days(item)
  plot(0) = gsn_csm_contour_map(wks, var_cmor((doy-1)*4-1 + item, level_cmor,:,:), res0)
  ; printVarSummary(var_cmor(month,level_cmor,:,:))
else 
  system("echo 'cmor dimnames= " + dnames_cmor(0) + "," + dnames_cmor(1) + "," + dnames_cmor(2) +"'")
  res0@tiMainString = "CMOR-" + variable
  plot(0) = gsn_csm_contour_map(wks, var_cmor((doy-1)*4-1 + item, :,:), res0)
end if 

res1 = res0

if (var_dimsize_gamil .eq. 4) then
  system("echo 'gamil dimnames= " + dnames_gamil(0) +"," + dnames_gamil(1) + "," + dnames_gamil(2) + "," + dnames_gamil(3) +"'")
  res1@tiMainString = "GAMIL-" + var_name + "-" + tostring(f_gamil->lev(level_gamil)) +"-" + year_month_days(item)
  plot(1) = gsn_csm_contour_map(wks, var_gamil(item, level_gamil, :, :), res1)
else if (var_dimsize_gamil .eq. 3) then
  system("echo 'gamil dimnames= " + dnames_gamil(0) +"," + dnames_gamil(1) + "," + dnames_gamil(2) + "'")
  res1@tiMainString = "GAMIL-" + var_name 
  plot(1) = gsn_csm_contour_map(wks, var_gamil(item, :, :), res1)
  ; printVarSummary(var_gamil(:,:,:))
else 
  print("dimsize is not 3 or 4")
  exit() 
end if
end if  

res2 = res0
res2@tiMainString = "CMOR-GAMIL"
if (var_dimsize_cmor .eq.4 .and. var_dimsize_gamil .eq. 4) then
  if(variable .eq. "cl") then
    tmp = var_cmor((doy-1)*4-1+item,level_cmor,:,:) - var_gamil(item,level_gamil,:,:) * 100.0 
  else
    tmp = var_cmor((doy-1)*4-1+item,level_cmor,:,:) - var_gamil(item,level_gamil,:,:)
  end if
  lat   = f_gamil->lat
  lon   = f_gamil->lon
  tmp!0 = "lat"
  tmp!1 = "lon"
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  tmp&lat = lat
  tmp&lon = lon
  plot(2) = gsn_csm_contour_map(wks, tmp, res2)
else 
  tmp = var_cmor((doy-1)*4-1+item,:,:) - var_gamil(item,:,:)
  lat = f_gamil->lat
  lon = f_gamil->lon
  tmp!0 = "lat"
  tmp!1 = "lon"
  lat@units = "degrees_north"
  lon@units = "degrees_east"
  tmp&lat = lat
  tmp&lon = lon
  plot(2) = gsn_csm_contour_map(wks, tmp, res2)
end if 

res_panel = True
gsn_panel(wks, plot, (/2,2/), res_panel)
delete(res0)
delete(res1)
delete(res2)
system("echo '===> 'end plot spatial distribution' '")
end

;============================================
;  vertical profile plot
;============================================
undef("vertical_profile_plot")
procedure vertical_profile_plot(f_cmor, f_gamil, variable, var_name, \\
                                 year:integer, month:integer, day:integer, item:integer, wks)
local doy, var_cmor, var_gamil, lev_cmor, lev_gamil, var_dimsize_cmo, var_dimsize_gamil
begin
var_cmor  = f_cmor->$variable$
var_gamil = f_gamil->$var_name$
var_dimsize_cmor  = dimsizes(dimsizes(var_cmor))
var_dimsize_gamil = dimsizes(dimsizes(var_gamil))
doy       = day_of_year(year, month, day)

if (var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  system("echo '===> 'plot vertical profile' '")
  res1                 = True
  res1@gsnDraw         = False
  res1@gsnFrame        = False
  res1@xyMarkLineMode  = "MarkLines"
  res1@xyMarkerColor   = "red"
  res1@trYReverse      = True
  res1@tiMainString    = "CMOR"

  lev_cmor = f_cmor->lev 
  plot0 = gsn_csm_xy(wks, var_cmor((doy-1)*4-1+item,:,40,90), lev_cmor, res1)

  res2                 = res1
  res2@xyMarkerColor   = "blue"
  res2@tiMainString    = "GAMIL"
  lev_gamil = f_gamil->lev
  plot1 = gsn_csm_xy(wks, var_gamil(item,:,40,90), lev_gamil, res2)

  res_panel = True
  gsn_panel(wks, (/plot0,plot1/), (/1,2/), res_panel)
  delete(res1)
  delete(res2)
  system("echo '===> 'end plot vertical profile' '")
end if 
end

;============================================
; time series plot
;============================================
undef("time_series_plot")
procedure time_series_plot(f_cmor, f_gamil, var_name_cmor, var_name_gamil, level_cmor:integer, level_gamil:integer, year:integer, month:integer, day:integer, wks)
local var_cmor, var_gamil, var_dimsize_cmor, var_dimsize_gamil, times, doy 
begin 
var_cmor = f_cmor->$var_name_cmor$
var_gamil = f_gamil->$var_name_gamil$
var_dimsize_cmor  = dimsizes(dimsizes(var_cmor))
var_dimsize_gamil = dimsizes(dimsizes(var_gamil))
doy       = day_of_year(year, month, day)

res0                 = True
res0@gsnDraw         = False
res0@gsnFrame        = False
res0@xyMarkLineMode  =  "MarkLines"
res0@tiXAxisString   = "6hour"

times = ispan(0, 29, 1)

if (var_dimsize_cmor .eq. 4 .and. var_dimsize_gamil .eq. 4) then
  system("echo '===> 'plot time series' '")
  res0@xyMarkerColor   = "red"
  res0@tiMainString    = "CMOR"
  plot0 = gsn_csm_xy(wks, times, var_cmor((doy-1)*4-1:(doy-1)*4-1+29,level_cmor,40,90), res0)

  res1 = res0
  res1@xyMarkerColor   = "blue"
  res1@tiMainString = "GAMIL"
  plot1 = gsn_csm_xy(wks, times, var_gamil(0:29,level_gamil,40,90), res1)
  res_panel = True
  gsn_panel(wks, (/plot0, plot1/), (/1,2/), res_panel)
  delete(res0)
  delete(res1)
  system("echo '===> 'end plot time series' '")
else
  system("echo '===> 'plot time series' '")
  res0@xyMarkerColor   = "red"
  res0@tiMainString    = "CMOR" 
  plot0 = gsn_csm_xy(wks, times, var_cmor((doy-1)*4-1:(doy-1)*4-1+29,40,90), res0)
  ; print(var_cmor((doy-1)*4-1:(doy-1)*4-1+29,40,90))
  res1 = res0
  res1@xyMarkerColor   = "blue"
  res1@tiMainString    = "GAMIL"
  plot1 = gsn_csm_xy(wks, times, var_gamil(0:29,40,90), res1)
  ; print(var_gamil(0:29,40,90))
  res_panel = True
  gsn_panel(wks, (/plot0, plot1/), (/1,2/), res_panel)
  delete(res0)
  delete(res1)
  system("echo '===> 'end plot time series' '")
end if
end
;============================================
; spatial plot with only two spatial field 
;============================================
undef("spatial_plot")
procedure spatial_plot(var1_field, var2_field, wks, opt:logical)
begin
  system("echo '===> 'plot spatial field' '")
  plot = new(3, graphic)

  res0                    = True 
  res0@gsnDraw            = False
  res0@gsnFrame           = False
  res0@gsnFrame           = False
  res0@vpHeightF          = 0.32
  res0@vpWidthF           = 0.32
  res0@mpOutlineOn        = True
  res0@mpFillOn           = False
  res0@cnLineLabelsOn     = True
  res0@cnConstFEnableFill = True
  res0@cnLinesOn          = True
  res0@cnFillOn           = True
  res0@cnFillMode         = "RasterFill"
  res0@cnFillPalette      = "GMT_panoply" 
  if(opt .and. isatt(opt, "names")) then
    res0@tiMainString = "CMOR" + "-" + opt@names(0)
  else
    res0@tiMainString = "CMOR"
  end if 
  plot(0) = gsn_csm_contour_map(wks, var1_field, res0)

  copy_VarCoords(var1_field, var2_field)
  res1 = res0
  if(opt .and. isatt(opt, "names")) then
    res1@tiMainString = "GAMIL" + "-" + opt@names(1)
  else
    res1@tiMainString = "GAMIL"
  end if 
  plot(1) = gsn_csm_contour_map(wks, var2_field, res1)
  if (opt .and. isatt(opt, "scale")) then 
    diff = var1_field - var2_field * opt@scale
  else
    diff = var1_field - var2_field
  end if 
  copy_VarCoords(var1_field, diff)

  res2=res0
  res2@tiMainString = "CMOR-GAMIL"
  plot(2) = gsn_csm_contour_map(wks, diff, res2)
  res_panel = True
  gsn_panel(wks, plot, (/2,2/), res_panel)
  delete(res0)
  delete(res1)
  delete(res2)
  system("echo '===> 'end plot spatial field' '")
end 

;============================================
; profile plot
;============================================
undef("profile_plot")
procedure profile_plot(var1_field, var1_lev, var2_field, var2_lev, wks)
 
begin
  system("echo '===> 'plot profile' '")
  res1                 = True
  res1@gsnDraw         = False
  res1@gsnFrame        = False
  res1@xyMarkLineMode  = "MarkLines"
  res1@trYReverse      = True

  res1@xyMarkerColor   = "red"
  res1@tiMainString    = "CMOR"
  plot0 = gsn_csm_xy(wks, var1_field, var1_lev, res1)
 
  res2                 = res1
  res2@xyMarkerColor   = "blue"
  res2@tiMainString    = "GAMIL"
  plot1 = gsn_csm_xy(wks, var2_field, var2_lev, res2)

  res_panel = True
  gsn_panel(wks, (/plot0,plot1/), (/1,2/), res_panel)
  delete(res1)
  delete(res2)
  system("echo '===> 'end plot profile' '")
end
;============================================
; time series plot
;============================================
undef("series_plot")
procedure series_plot(var1_field, var2_field, wks)
local times1, times2
begin 

res1                 = True
res1@gsnDraw         = False
res1@gsnFrame        = False
res1@xyMarkLineMode  =  "MarkLines"
res1@tiXAxisString   = "times"

; times = ispan(0, 29, 1)

  system("echo '===> 'plot time series' '")

  res1@xyMarkerColor   = "red"
  res1@tiMainString    = "CMOR" 
  times1 = ispan(0, dimsizes(var1_field)-1, 1)
  plot1 = gsn_csm_xy(wks, times1, var1_field, res1)
  ; print(var_cmor((doy-1)*4-1:(doy-1)*4-1+29,40,90))
  res2 = res1
  res2@xyMarkerColor   = "blue"
  res2@tiMainString    = "GAMIL"
  times2 = ispan(0, dimsizes(var2_field)-1, 1)
  plot2 = gsn_csm_xy(wks, times2, var2_field, res2)
  ; print(var_gamil(0:29,40,90))
  res_panel = True
  gsn_panel(wks, (/plot1, plot2/), (/1,2/), res_panel)
  delete(res1)
  delete(res2)
  system("echo '===> 'end plot time series' '")

end

undef("sigma2pres")
function sigma2pres(var_sigama, var_pres, hbcofa, hbcofb, pres, ps, p0, inter_method)
  begin
  ; hbcofb          = f_gamil[month]->lev
  ; hbcofa          = 1 - hbcofb
  ; plevo           = f_cmor->plev * 0.01
  ; plevo!0         = "levout"
  ; plevo&levout    = plevo
  ; plevo@long_name = "pressure level"
  ; plevo@units     = "hPa"
  ; plevo@positive  = "up"
  ; psfc            = fs_gamil[month]->PS
  ; intyp           = 1 ; 1=LINEAR, 2=LOG, 3=LOG LOG
  ; p0              = 2.194
  ; kxtrp           = False
  ; vinth2p(vars_gamil(month,:,:,:), hbcofa, hbcofb, plevo, psfc(0,:,:), intyp, p0, 1, kxtrp)
  var_pres = vinth2p(var_sigama, hbcofa, hbcofb, plevo, psfc(0,:,:), inter_method, p0, inter_method, kxtrp)
  return(var_pres)
  end 
