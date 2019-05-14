function [xlon,xlat] = plot_borders(ax0)

ddir = '/home/vipul/dlib/borders/';
load(strcat(ddir,'borders_data'));

%NOTE: Don't subset  otherwise NaN separting countries borders disappear
%[inds,xlon,ylat] = getsubset(LON,LAT,ax0);
%plot(xlon,ylat,'.k');

plot(LON,LAT,'k')
axis(ax0)