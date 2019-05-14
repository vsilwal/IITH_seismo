function [otime,lon,lat,dep,mag] = read_eq_sippl2013
%
% Read earthquake catalog from:
% 
% Geometry of the Pamir-Hindu Kush intermediate-depth earthquake zone from local seismic data
% C. Sippl1, B. Schurr1, X. Yuan1, J. Mechie1, F.M. Schneider1, M. Gadoev2, S.
% Orunbaev3, I. Oimahmadov2, C. Haberland1, U. Abdybachaev3, V. Minaev2,
% S. Negmatullaev4, N. Radjabov2

if 0
    ddir = '/home/vipul/dlib/seismicity/regional/pamir/Sippl2013/';
    fname = 'Sippl2013.dat';
    
    fid = fopen(strcat(ddir,fname));
    a=textscan(fid,'%s %s %s %s %f %f','Headerlines',1);
    
    for ii=1:length(a{1})
        otimestr = [a{1}{ii} ' ' a{2}{ii}];
        otime(ii) = datenum(otimestr);
        lat(ii) = str2num(a{3}{ii}(1:end-1));
        lon(ii) = str2num(a{4}{ii}(1:end-1));
    end
    
    dep = a{5};
    mag = a{6};
    
    % save as mat file
    save(strcat(ddir,'sippl2013'),'otime','lat','lon','dep','mag')
end

load('sippl2013')