function [xlon,xlat] = plot_borders(ax0)

ddir = '/home/vipul/dlib/borders/';
load(strcat(ddir,'borders_data'));

[inds,xlon,ylat] = getsubset(LON,LAT,ax0);
plot(xlon,ylat,'.');