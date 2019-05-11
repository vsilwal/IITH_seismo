function [zslab,X,Y,Z] = read_slab_him(islab,plon,plat)
% Read slab2.0 (Hayes 2018) for Himalayas
%
% INPUT
%   islab   choice of region
%               =1: Western Himlayas (Hindukush)
%               =2: Central Himlayas
%               =3: Eastern Himlayas
%   plon    optional: target longitude
%   plat    optional: target latitude
%
% OUTPUT
%   zslab   optional: slab elevation, METERS, at target points
%
% The distance calculations are performed on the sphere; an ellipsoid could
% easily be incorporated.
%
% Modified from: uafseismo/GEOTOOLS/read_slab_alaska.m (Carl Tape)

stlabs = {'Hayes2018'};

bfigure = false;
zslab = [];

switch islab
    case 1
        % Western Himlayas (Hindukush)
        bdir = '/home/vipul/dlib/slab/hin/';
        ifile = strcat(bdir,'hin_slab2_dep_02.24.18.grd');
        [X,Y,Z,nx,ny,d] = read_grd_mesh(ifile);
        Z = Z*1e3;          % z points upward, meters
    case 2
        % Central Himlayas
        bdir = '/home/vipul/dlib/slab/him/';
        ifile = strcat(bdir,'him_slab2_dep_02.24.18.grd');
        [X,Y,Z,nx,ny,d] = read_grd_mesh(ifile);
        Z = Z*1e3;          % z points upward, meters
    case 3
        % Eastern Himlayas
        bdir = '/home/vipul/dlib/slab/sum/';
        ifile = strcat(bdir,'sum_slab2_dep_02.23.18.grd');
        [X,Y,Z,nx,ny,d] = read_grd_mesh(ifile);
        Z = Z*1e3;          % z points upward, meters         
end

if exist('X','var'), X = wrapTo360(X); end
if exist('x','var'), x = wrapTo360(x); end

if nargin == 3
    plon = wrapTo360(plon);
    
    % larger region around the target points
    axsub = [min(plon) max(plon) min(plat) max(plat)] + 0.1*[-1 1 -1 1];
    zslab = interp2(X,Y,Z,plon,plat);
    
end

%---------

if bfigure
    stit = sprintf('elevation of slab interface (%s), km',stlabs{islab});
    
    if nargin==3
        figure; scatter(plon,plat,4^2,zslab/1e3,'filled'); colorbar;
        xlabel('longitude'); ylabel('latitude'); title(stit);
    else
        figure;
        plot_borders([60 100 20 45]);
%         if islab <=2
%             scatter(x,y,4^2,z/1e3,'filled');
%         else
            pcolor(X,Y,Z/1e3); shading flat;
%         end
        caxis([-200 0]); colormap(flipud(jet)); colorbar;
        %hold on; load coast; plot(wrapTo360(long),lat);
        xlabel('Longitude'); ylabel('Latitude'); title(stit);
    end
end

%==========================================================================
% EXAMPLES

if 0==1
    %% extract values along a profile
    iprofile = 3;
    if iprofile==1
        % Hindukush
        lon1 = 76.75; lat1 = 32.00;
        lon2 = 67; lat2 = 39;
        preseg = 50; postseg = 50; dx = 1;
        islab = 1;
    elseif iprofile==2
        % Central Himalayas
        lon1 = 81; lat1 = 25.00;
        lon2 = 85.5; lat2 = 33.5;
        preseg = 50; postseg = 50; dx = 1;
        islab = 2;
    elseif iprofile==3
        % Myanmar Himalayas
        lon1 = 88.75; lat1 = 24.00;
        lon2 = 99; lat2 = 24;
        preseg = 50; postseg = 50; dx = 1;
        islab = 3;
    end
    % extract profile
    [plon,plat,rdist,azis] = get_profile(lon1,lat1,lon2,lat2,preseg,postseg,dx);
    %if iprofile==2, rdist = -rdist; end
    % interpolate to profile
    [zslab,X,Y,Z] = read_slab_him(islab,plon,plat);
    % plot
    figure; pcolor(X,Y,Z); shading flat; hold on
    plot(plon,plat,'-k')
    figure; hold on; ylim([-200 10]); grid on
    plot(rdist,zslab/1e3,'r');
    legend('Hayes2018');
    xlabel('horizontal distance, km');
    ylabel('vertical distance, km');
    %%

end

%==========================================================================
