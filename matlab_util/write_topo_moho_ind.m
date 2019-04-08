function [X,Y,Ztopo,Zmoho,nx,ny] = write_topo_moho_ind(xmin,ymin,xran,yran,dx,szone,ismooth,odir,ftag)
%WRITE_TOPO_MOHO_AK write topo and moho surfaces needed for mesh construction
%
% INPUT
%   xmin    lower left of region, utmx, meters (in some utm zone)
%   ymin    lower left of region, utmy, meters (in some utm zone)
%   xran    length in east-west direction, meters
%   yran    length in north-south direction, meters
%   dx      gridpoint increment, meters
%   szone   UTM zone
%   ismooth smoothing flag 
%   odir    optional: directory for writing file
%   ftag    optional: name of region
%
% OUTPUT
%   X       matrix for utmX, meters
%   Y       matrix for utmY, meters
%   Ztopo   matrix for topography, meters
%   Zmoho   matrix for moho, meters [NOT the moho for the mesh, zmohomod]
%

NARGWRITE = 9;
if ~or(nargin==NARGWRITE-2,nargin==NARGWRITE)
    error('nargin = %i or %i',NARGWRITE-2,NARGWRITE);
end

checkfig = true;
%szone = '5V';
msize = 4^2;

% input grid
ax = [xmin xmin+xran ymin ymin+yran];
xvec = ax(1):dx:ax(2);
yvec = ax(3):dx:ax(4);
[X,Y] = meshgrid(xvec,yvec);
[lonX,latY] = utm2ll(X,Y,szone,1);
%lonX = wrapTo360(lonX);
%[a,b] = size(X);

% interpolate ETOPO1 onto input grid
smoothfig = true;
bfigure = true;
[Xlont,Ylatt,Zt,nx,ny,d] = get_etopo_ind(ismooth,smoothfig,bfigure);
%[Xlont,Ylatt,Zt] = get_etopo_ind;
whos Xlont Ylatt Zt lonX latY
%Xlont = wrapTo360(Xlont);
Ztopo = interp2(Xlont,Ylatt,Zt,lonX,latY);

if checkfig
    %figure; scatter(lonX(:),latY(:),msize,Ztopo(:),'filled');
    %figure; pcolor(Xlont,Ylatt,Zt); shading flat;
    figure; scatter(X(:),Y(:),msize,Ztopo(:)/1e3,'filled');
    axis equal, axis tight; colorbar;
    title('topography, km');
end

% depth of Moho in tactmod 1D model
ZFLATMOHO = -45*1e3;
Zmoho = ZFLATMOHO*ones(size(Ztopo));

if or(nargin==NARGWRITE, nargout > 0)
    [ny,nx] = size(X);
    % WARNING: GEOCUBIT expects a certain ordering of points
    X = X'; Y = Y'; Ztopo = Ztopo'; Zmoho = Zmoho';
    whos X Y Ztopo Zmoho
        
    if nargin==NARGWRITE
        omoho = sprintf('%s/moho_%5.5i_%s_utm%s_%i_%isurf.xyz',odir,-ZFLATMOHO,ftag,szone,nx,ny);
        otopo = sprintf('%s/topo_%s_utm%s_ismooth%i_%i_%isurf.xyz',odir,ftag,szone,ismooth,nx,ny);
        % if either the topo or the moho file does not exist
        if or(~exist(otopo,'file'),~exist(omoho,'file'))
            write_surf_xy(otopo,X(:),Y(:),Ztopo(:));
            write_surf_xy(omoho,X(:),Y(:),Zmoho(:));
        else
           warning('NOT WRITING A FILE -- moho and topo files exist');
        end
    end
end

if checkfig
    whos X Y Ztopo Zmoho
    figure; pcolor(X,Y,Zmoho/1e3); shading flat; colorbar; title('final moho, km');
    figure; pcolor(X,Y,Ztopo/1e3); shading flat; colorbar; title('final topo, km');
end

%==========================================================================
% EXAMPLES

if 0==1

    % note: the velocity model can be slightly larger (or smaller),
    % but mesh size is controlled by the topographic surface footprint
    
    %% bounds for alaska meshes
    % note: it is best to check this on a NON-SQUARE dimension
    clear, clc, close all
    ismooth = 0;
    ipick = 4;
    switch ipick
        case 1
            % Garhwal-Kumaon (Western Himalayas)
            ftag = 'GK';
            lonmin=76.5; latmin=28;
            szone = '44R';
            xran = 500*1e3; yran = 400*1e3;
        case 2
            % Central Himalayas
            ftag = 'nepal';
            lonmin=82; latmin=26; 
            szone = '45R'; 
            xran = 600*1e3; yran = 500*1e3;
        case 3
            % Eastern Himalayas
            ftag = 'bhutan';
            lonmin=-156.1; latmin=59; % NOT SET YET
            szone = '46R';
            xran = 400*1e3; yran = 500*1e3;
        case 4
            % Eastern Himalayas
            ftag = 'deccan';
            lonmin=72; latmin=10; % NOT SET YET
            szone = '43P';
            xran = 900*1e3; yran = 500*1e3;
    end
    % get UTM for the lower left (SW) point
    [xmin,ymin] = utm2ll(lonmin,latmin,szone,0);
    % construct bounding rectangle using xran and yran
    axx = [xmin xmin+xran ymin ymin+yran];
    %axxll = axes_utm2ll(axx,szone,1);
    
    % boundaries of zones (For plotting purpose)
    NPT = 200;
    [xbox,ybox] = boxpts(axx,NPT);
    [xboxll,yboxll] = utm2ll(xbox,ybox,szone,1);
    %write_sim_bounds(xbox,ybox,xboxll,yboxll,szone,ftag);
%     if 0==1
%         ddir = '/home/carltape/REPOSITORIES/GEOTOOLS/datalib_util/txtfiles/boundaries/';
%         bfile = sprintf('%salaska_simulation_%s_%s',ddir,ftag,szone)
%         write_xy_points(bfile,xboxll,yboxll);
%         bfile = sprintf('%salaska_simulation_%s_%s_utm',ddir,ftag,szone)
%         write_xy_points(bfile,xbox,ybox);
%     end
    
    fprintf('%.1f %.1f %.1f %.1f\n',xmin,ymin,xran,yran);

    %-----------------------
%% generate topo and moho files
    % note 1: set checkfig = true to plot figures
    % note 2: delete all *.xyz files in the local directory
    
    % grid spacing for topographic surfaces
    % 1 km for final mesh, 10 km for testing
    dx = 1*1e3;
    % this command will NOT write the file, since odir is not provided
    [X,Y,Ztopo,Zmoho,nx,ny] = write_topo_moho_ind(xmin,ymin,xran,yran,dx,szone,ismooth);

    % display bounds for GEOCUBIT configuration file
    disp(sprintf('xmin = %.1f\nxmax = %.1f\nymin = %.1f\nymax = %.1f',...
        min(X(:)),max(X(:)),min(Y(:)),max(Y(:)) ));
    disp(sprintf('ax = [ %.1f %.1f %.1f %.1f ]',...
        min(X(:)),max(X(:)),min(Y(:)),max(Y(:)) ));
    
    % check for Nan
    sum(isnan(Ztopo(:)))
    
    % load coast; [cx,cy] = utm2ll(long,lat,szone,0); hold on; plot(cx,cy,'-');
    % axis equal; axis tight; caxis([-1 1]); colorbar
    
    % check topo
    ax0 = check_topo(X,Y,Ztopo);
    
    % this command WILL write the file, since odir is provided
    %odir = '/home/vipul/dlib/topography/india/xyz';
    %[X,Y,Ztopo,Zmoho,nx,ny] = write_topo_moho_ind(xmin,ymin,xran,yran,dx,szone,ismooth,odir,ftag);
    
    %% this is a crude approach -- it is better to fine-tune the boundaries
    % by examining the GMT plots
    ifile = '/home/vipul/dlib/stations/IN';
    [rlon,rlat,relev,rburial,stnm,netwk,stnmnet] = read_station_specfem(ifile);
    %load coast;
    %figure; hold on; plot(long,lat);
    %axis([-160 -135 55 73]);
    figure; plot(rlon,rlat,'v');
    %text(rlon,rlat,stnmnet);
    text(rlon,rlat,stnm); hold on
    
    %[otime,lon,lat,dep,Mw,eid,depunc] = read_eq_isc([datenum(2000,1,1) now],[],[3 10]);
    %plot(lon,lat,'m.'); hold on
    %plot(axxll([1 2 2 1 1]),axxll([3 3 4 4 3]),'c','linewidth',2);
    plot(xboxll,yboxll,'g','linewidth',2);
    
end   