function [Xlon,Ylat,Z,nx,ny,d] = get_etopo(ax0)
%GET_ETOPO loads ETOPO1 and extracts a subset
%
% ETOPO1 has a resolution of about 1.8 km.
%   1.8532 = 6371*pi/180/60
%

dlib = '/home/vipul/dlib/';
dlibtopo = [dlib 'topography/GLOBAL/ETOPO1/'];
grdfile = [dlibtopo 'ETOPO1_Ice_g.grd'];

% this loads the full global file, then extracts a portion of it
disp('get_etopo.m: loading ETOPO1 global file (be patient)');
disp(grdfile);
if ~exist(grdfile,'file'), error('file does not exist'); end

if nargin==1
    [Xlon,Ylat,Z,nx,ny,d] = read_grd_mesh(grdfile,ax0);
else
    [Xlon,Ylat,Z,nx,ny,d] = read_grd_mesh(grdfile);
end
    
ifigure = 0;
if ifigure==1
    figure; pcolor(Xlon,Ylat,Z); shading flat;
    xlabel('Longitude'); ylabel('Latitude');
    title('ETOPO1 from NOAA');
    axis equal, axis(ax0), colorbar
end

if 0
%-------------------------------------
% EXAMPLES 
% Also save topograaphy in .mat format for quick access
    
    % India
    ax0 = [65 100 5 40];
    cax = [0 6000];
    [Xlon,Ylat,Zt,nx,ny,d] = get_etopo(ax0);
    figure; pcolor(Xlon,Ylat,Zt); shading flat;
    xlabel('Longitude'); ylabel('Latitude');
    axis equal, axis(ax0), caxis(cax); colorbar
    title('India (ETOPO1: resolution 1.8 km)');
    save('/home/vipul/dlib/topography/india/etopo1_india','Xlon','Ylat','Zt','nx','ny','d');
    
    % Himalayas
    ax0 = [75 95 25 35];
    cax = [0 6000];
    [Xlon,Ylat,Zt,nx,ny,d] = get_etopo(ax0);
    figure; pcolor(Xlon,Ylat,Zt); shading flat;
    xlabel('Longitude'); ylabel('Latitude');
    axis equal, axis(ax0), caxis(cax); colorbar
    title('India (ETOPO1: resolution 1.8 km)');
    save('/home/vipul/dlib/topography/india/etopo1_him','Xlon','Ylat','Zt','nx','ny','d');
    
    
end