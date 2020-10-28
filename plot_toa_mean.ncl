load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
filename = "toa_timemean.nc"
f = addfile(filename, "r")
net = f->net(0,:,:)

res                   = True 
res@gsnMaximize       = True 
res@cnFillOn          = True 
res@cnLinesOn         = False
res@cnLineLabelsOn    = False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels          = (/-120,-100,-80,-60,-40,-20,0,20,40,60,80,100,120/)


res@mpDataBaseVersion = "MediumRes"
res@mpGridAndLimbOn   = True 
res@mpGridLineColor   = -1
res@mpPerimOn         = False
res@mpFillDrawOrder   = "PreDraw"

res@gsnRightString    = ""
res@gsnLeftString     = ""
res@tiMainFontHeightF = 0.02

res@lbLabelBarOn      = True
res@lbTitleString     = "Net Radiation (w m~S~-2~N~)"
res@lbTitleFontHeightF=0.015
res@lbLabelFontHeightF= 0.01 ; control the size of the labels
res@lbTopMarginF      = -0.3
res@lbTitleOffsetF    = -0.1
res@pmLabelBarHeightF = 0.05 ;control the height of labelbar


out_name = "toa_time_mean"
wks = gsn_open_wks("ps", out_name)

mpres = res 
mpres@mpProjection   = "Robinson"
mpres@mpCenterLonF   = 180


plot = gsn_csm_contour_map(wks, net, mpres)

delete(wks)
system("convert -trim -density 300 -rotate -90 " + out_name + ".ps" + " " + out_name + ".png")
end 

