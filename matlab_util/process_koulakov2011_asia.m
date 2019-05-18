% Interpolate Koulakov 3D Asia model
% Interpolated model will be used within specfem for simulation
%
clear all
close all
ax0 = [60 100 30 50];
[x,y,z,Vp,Vs,dVp,dVs] = read_koulakov2011_asia(ax0);
%
% 1. These points needs to be projected to the universal lat-lon
%    Since this is a large region, projection should be done separately for
%    for smaller sub-regions
% 2. Put shallow layers from different models(?)

% Make a fine and uniform 3D grid for interpolation

%---------------------------------------------------------
zrange = [10:20:50]*1e3; % layer depths in meters
iz = nearest(zrange/20000); % layer number (in original model layers are separated by 20km)

%dV = dVp; V0 = Vp; stag = 'P wave';
dV = dVs; V0 = Vs; stag = 'S wave';

%---------------------------------------------------------
Nz = length(x)/length(unique(z)); % Number of elements in each layer (=45)
XX = x(1:Nz);
YY = y(1:Nz);

xx = repmat(XX,length(zrange),1);
yy = repmat(YY,length(zrange),1);
zz = [];
for ii=1:length(zrange)
    zz = [zz; ones(Nz,1)*zrange(ii)];
end

V1_hor = [];

% STEP 1: HORIZONTAL INTERPOLATION
% Reference model is ak135
for ii = 1:length(zrange)
    last = ii*Nz;
    first = last - Nz +1;
    dV_dep = dV(first:last);
    V = V0(first:last);
    %xx = x(first:last);
    %yy = y(first:last);
    
    % Before interpolation
    figure
    subplot(2,1,1)
    scatter(XX,YY,10,V)
    colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); %caxis([3 5])
    hold on
    plot_borders(axis)
    title(sprintf('Koulakov 2011, %s velocity (before interp); depth: %.1f km',stag, unique(z(first:last))/1e3));
    
    % INTERPOLATE (IN EACH LAYER) 
    % Remove NaNs from the velocity vectors
    vv1 = V;
    xx1 = XX;
    yy1 = YY;
    xx1(find(isnan(vv1)))=[];
    yy1(find(isnan(vv1)))=[];
    vv1(find(isnan(vv1)))=[];
    V1 = griddata(xx1,yy1,vv1,XX,YY,'cubic'); % KEY 
    V1_hor = [V1_hor; V1];
    subplot(2,1,2)
    scatter(XX,YY,10,V1);
    colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); %caxis([3 5])
    hold on
    plot_borders(axis)
    title(sprintf('Koulakov 2011, %s velocity (after interp); depth: %.1f km',stag, unique(z(first:last))/1e3));
end

%------------------------------------------------------------
% STEP 2: VERTICAL INTERPOLATION
zvec = [10:10:50]*1e3;

xx2 = repmat(XX,length(zvec),1);
yy2 = repmat(YY,length(zvec),1);
zz2 = [];
for ii=1:length(zvec)
    zz2 = [zz2; ones(Nz,1)*zvec(ii)];
end

V2 = griddata(xx,yy,zz,V1_hor,xx2,yy2,zz2,'linear'); 

for ii = 1:length(zvec)
    last = ii*Nz;
    first = last - Nz +1;
    dV_dep = dV(first:last);
    V = V2(first:last);
    %xx = x(first:last);
    %yy = y(first:last);
    
    % Before interpolation
    figure
    scatter(XX,YY,10,V)
    colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); %caxis([3 5])
    hold on
    plot_borders(axis)
    title(sprintf('Koulakov 2011, %s velocity (after interp); depth: %.1f km',stag, zvec(ii)/1e3));

end