function [otime,lon,lat,dep,depc,Mw,stk1,dip1,rak1,stk2,dip2,rak2] = read_mech_schurr2014

ddir = '/home/vipul/dlib/MTs/regional/Schurr2014/';
fname = 'Schurr2014_cmt';

fid = fopen(strcat(ddir,fname));

% date	time	lat	lon	depth	centroid_depth Mw (7)
% strike1 rake1 dip1 strike2 rake2 dip2 (13)
% P_plunge P_azimuth T_plunge T_azimuth (17)
% M0 mxx myy mzz mxy myz mxz dc[%] label (26)
a = textscan(fid,['%s %s %f %f %f %f %f',  ...
    '%f %f %f %f %f %f ', ...
    '%f %f %f %f ', ...
    '%f %f %f %f %f %f %f %f %s'] ,'Headerlines',1);

for ii=1:length(a{1})
        otimestr = [a{1}{ii} ' ' a{2}{ii}];
        otime(ii) = datenum(otimestr);
end

lat = a{3};
lon = a{4};
dep = a{5};
depc = a{6};
Mw = a{7};
stk1 = a{8};
rak1 = a{9};
dip1 = a{10};
stk2 = a{11};
rak2 = a{12};
dip2 = a{13};
M0 = a{18};
mxx = a{19};
myy = a{20};
mzz = a{21};
mxy = a{22};
myz = a{23};
mxz = a{24};

