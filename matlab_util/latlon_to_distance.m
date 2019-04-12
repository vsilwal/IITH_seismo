
lat=(27.5:0.01:27.8);
long=(85.2:0.01:85.6);
Elpse=referenceEllipsoid('earth');
% Northing = Ysign*distance(lat1,lon1,lat2,lon1,Elpse);
% Easting = Xsign*distance(lat1,lon1,lat1,lon2,Elpse);
N=length(long);
M=length(lat);
lat1=lat(1,1);
long1=long(1,1);
npt=0;
for i=1:N
    long2=long(1,i);
    for j=1:M
        lat2=lat(1,j);
        [dis, azm]=distance(lat1,long1,lat2,long2,Elpse);
        npt=npt+1;
        cartesian_coords(npt,2)=dis.*cosd(azm);
        cartesian_coords(npt,1)=dis.*sind(azm);
    end
end

    





