%  Read P and S wave anomalies from Koulakov 2011
close all
clear all
ddir = '/home/vipul/dlib/TOMO/koulakov/DATA/ASIA_ALL/';

% Read model
dvp_fname = 'MOD_3D_1.dat'; % P wave anomalies
fid = fopen(strcat(ddir,dvp_fname));
a = textscan(fid,'%f %f %f %f %f','Headerlines',3);
dvp = [a{1} a{2} a{3} a{4} a{5}];

% Prepare model
[nx,ny] = size(dvp);
N = nx*ny; % total elements in the model
dVp = reshape(dvp',[nx*ny,1]);
% replace -999 by NaN
indx = find(dVp==-999);
dVp(indx) = NaN;

dvs_fname = 'MOD_3D_2.dat'; % P wave anomalies
fid = fopen(strcat(ddir,dvs_fname));
a = textscan(fid,'%f %f %f %f %f','Headerlines',3);
dvs = [a{1} a{2} a{3} a{4} a{5}];

% Prepare model
[nx,ny] = size(dvs);
N = nx*ny; % total elements in the model
dVs = reshape(dvs',[nx*ny,1]);
% replace -999 by NaN
indx = find(dVs==-999);
dVs(indx) = NaN;
%----------------------------------------------------

% Prepare mesh for locating model elements
% These could be read from the file ('MOD_3D_1.dat') header
xvec = [35:0.15:140]'; % 701 (longitude)
yvec = [10:0.15:60]';  % 334 (latitude)
[X,Y] = meshgrid(xvec,yvec);

dz = 20*1e3; % in meters
zvec = [10:20:900]*1e3';   % 45 (depth)

[nx,ny] = size(X);
Nz = nx*ny; % number of element in one depth cross-section
xx = reshape(X',[Nz,1]);
yy = reshape(Y',[Nz,1]);

x = repmat(xx,length(zvec),1);
y = repmat(yy,length(zvec),1);
z = [];
for ii=1:length(zvec)
    z = [z; ones(Nz,1)*zvec(ii)];
end

% Read reference model
[z1,rho1,vp1,vs1,qkappa1,qmu1] = read_1D_ak135;

Vp = [];
Vs = [];

for imodel = 1:2
    % Vp and Vs model
    if imodel==1
        V1 = vp1;
        dV = dVp;
    elseif imodel==2
        V1 = vs1;
        dV = dVs;
    end
    V = [];
    for ii = 1 : length(zvec)
        last = ii*Nz;
        first = last - Nz +1;
        % get anomaly
        dV_dep = dV(first:last);
        % get vs or vp value
        % XXX get interpolated value
        [val,idx] = min(abs(z1-zvec(ii)/1e3)); % XXX getting the nearest value from ak135
        
        v0 = V1(idx);
        % actual value
        V = [V; v0*(1 + dV_dep/100)];
    end
    
    if imodel==1
        Vp = V;
    elseif imodel==2
        Vs = V;
    end   
end

% save as mat file
save(strcat(ddir,'koulakov2011'),'x','y','z','dVp','dVs','Vp','Vs');
%----------------------------------------------------
%% EXAMPLES
if 0
    % Plot P or S Anomaly    
    ddir = '/home/vipul/dlib/TOMO/koulakov/DATA/ASIA_ALL/';
    load(strcat(ddir,'koulakov2011'));
    
    zrange = [10:20:50]*1e3;
    iz = nearest(zrange/20000);
    
    dV = dVp; V0 = Vp; stag = 'P wave';
    %dV = dVs; V0 = Vs; stag = 'S wave';
    
    Nz = length(unique(x))*length(unique(y)); % This will depend on ax (specify in read_koulakov2011_asia.m)
    
    % Actual Koulakov data contians vp, vs percent anomalies
    % Reference model is ak135
    for ii = iz(1):iz(end)
        last = ii*Nz;
        first = last - Nz +1;
        dV_dep = dV(first:last);
        V = V0(first:last);
        
        figure
        subplot(2,1,1)
        scatter(x(first:last),y(first:last),10,dV_dep)
        colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); caxis([-3 3])
        hold on
        plot_borders(axis)
        title(sprintf('Koulakov 2011, %s anomaly; depth: %.1f km',stag, unique(z(first:last))/1e3));
        
        subplot(2,1,2)
        scatter(x(first:last),y(first:last),10,V)
        colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); %caxis([-3 3])
        hold on
        plot_borders(axis)
        title(sprintf('Koulakov 2011, %s velocity; depth: %.1f km',stag, unique(z(first:last))/1e3));
    end
end
