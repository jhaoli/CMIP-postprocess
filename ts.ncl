;*************************************************
; gsn_xy_2.ncl
;*************************************************
;
; This file is loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;*************************************************

begin

diri = "/public1/wab/CMIP6/cmor/CMIP6/CMIP6/CMIP/CAS/FGOALS-g3/1pctCO2/r1i1p1f1/Amon/pr/gn/v20191215/"   ; input directory
fils = systemfunc ("ls "+diri+"*[3-5][0-9][0-9]*.nc") ; file paths

f    = addfiles (fils, "r")   ; note the "s" of addfile
f_gw = addfile("./gw_gamil.nc", "r")

gw = f_gw->gw

ts = f[:]->pr
lon = f[0]->lon
lat = f[0]->lat

jlat = dimsizes(lat)

rad  = 4.0*atan(1.0)/180.0
clat = cos(lat * rad)
re = 6371220.0
rr = re * rad

dlon = abs(lon(2) - lon(1)) * rr
dx = dlon * cos(lat*rad)
dy = new(jlat, typeof(dx))

; dy(0) = abs(lat(2) - lat(1)) * rr
; dy(1:jlat-2) = abs(lat(2:jlat-1) - lat(0:jlat-3)) * rr * 0.5
; dy(jlat -1)  = abs(lat(jlat-1) - lat(jlat-2)) * rr

dy(0) = abs(lat(1)-lat(0)) * rr
dy(1:jlat-2) = abs(lat(2:jlat-1) - lat(1:jlat-2)) * rr
dy(jlat-1) = abs(lat(jlat-1) - lat(jlat-2)) * rr

area = dx * dy

; tsAve_area = wgt_areaave(ts(:,10:70,:), area(10:70), 1.0, 0)
; tsAve_clat = wgt_areaave(ts(:,10:70,:), clat(10:70), 1.0, 0)
tsAve_area = wgt_areaave(ts, area, 1.0, 0)
tsAve_clat = wgt_areaave(ts,   gw, 1.0, 0)


;ts_ave_area = new(150,"float")
;ts_ave_clat = new(150,"float")
;do year=0,149,1
;  ts_ave_area(year)= avg(tsAve_area(year*12:year*12+11))
;  ts_ave_clat(year)= avg(tsAve_clat(year*12:year*12+11))
;end do

ts_ave_area= month_to_annual(tsAve_area, 1)
ts_ave_clat= month_to_annual(tsAve_clat, 1)

data = new((/2, dimsizes(ts_ave_area)/), float)
data(0,:) = ts_ave_area
data(1,:) = ts_ave_clat

time = ispan(1,150,1)


;**************************************************
; create plot
;**************************************************
wks = gsn_open_wks("pdf","gsn_xy")         ; send graphics to PNG file

res               = True                   ; plot mods desired
res@gsnPaperOrientation = "portrait"
res@gsnDraw       = False
res@gsnFrame      = False
res@gsnMaximize   = True
res@vpHeightF= 0.4                    ; change aspect ratio of plot
res@vpWidthF = 0.8  

res@tiMainString  = "Temperature"   ; title
res@tiYAxisString = "ts"           ; y axis title
res@tiXAxisString = "Time"                 ; x axis title
res@xyLineColors  = "black"
res@xyDashPatterns = 0
res@pmLegendDisplayMode    = "Always"
res@pmLegendSide           = "Top"
res@pmLegendOrthogonalPosF = -0.54
res@pmLegendParallelPosF   = 0.2
res@pmLegendWidthF         = 0.2
res@pmLegendHeightF        = 0.12
res@xyExplicitLegendLabels = (/"area weighted", "gamil weights"/)
res@xyLineColor = (/"red","blue"/)
plot = gsn_xy(wks,time,data*8.64e4, res)               ; Draw an XY plot with 1 curve.

draw(plot)
frame(wks)
end

