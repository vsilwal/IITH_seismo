function [Northing, Easting] = latlon2NE(lat1,lon1,lat2,lon2)
% Modified by : Srihari Sangaraju, IIT Hyderabad.
% calculate Northing and Easting between two points on earth's surface
% given by their latitude-longitude pair.
% Input lat1,lon1,lat2,lon2 are in degrees, without 'NSWE' indicators.
%
% Northing(Y) and Easting(X)(in Meters) are given considering lat1,lon1 as origin.
% Returns -99999 if input argument(s) is/are incorrect.
% 
% Distance between two points are calculated assuming Earth as a Ellipsoid
% As per 'World Geodetic System 1984'
%
% Flora Sun, University of Toronto, Jun 12, 2004.

if nargin < 4
    dist = -99999;
    disp('Number of input arguments error! distance = -99999');
    return;
end
if abs(lat1)>90 | abs(lat2)>90 | abs(lon1)>360 | abs(lon2)>360
    dist = -99999;
    disp('Degree(s) illegal! distance = -99999');
    return;
end
if lon1 < 0
    lon1 = lon1 + 360;
end
if lon2 < 0
    lon2 = lon2 + 360;
end

% Caluculating Distance.
% Ysign=sign(lat2-lat1);
% Xsign=sign(lon2-lon1);

Elpse=referenceEllipsoid('earth');
% Northing = Ysign*distance(lat1,lon1,lat2,lon1,Elpse);
% Easting = Xsign*distance(lat1,lon1,lat1,lon2,Elpse);
[dis, azm]=distance(lat1,lon1,lat2,lon2,Elpse);

Northing=dis.*cosd(azm);
Easting=dis.*sind(azm);


end