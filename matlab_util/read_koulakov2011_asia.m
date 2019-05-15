%function [] = read_koulakov2011_asia
%  Read P and S wave anomalies from Koulakov 2011

ddir = '/home/vipul/dlib/TOMO/koulakov/DATA/ASIA_ALL/';
imodel = 1;
zrange = [50 50]*1e3;
iplot_anomaly = 1;

if imodel==1
    fname = 'MOD_3D_1.dat'; % P wave anomalies
    stag = 'P wave';
elseif imodel==2
    fname = 'MOD_3D_2.dat'; % S wave anomalies
    stag = 'S wave';
end

% Read model
fid = fopen(strcat(ddir,fname));
a = textscan(fid,'%f %f %f %f %f','Headerlines',3);

model_raw = [a{1} a{2} a{3} a{4} a{5}];

% Prepare model
[nx,ny] = size(model_raw);
N = nx*ny; % total elements in the model
model = reshape(model_raw',[nx*ny,1]);
% replace -999 by NaN
indx = find(model==-999);
model(indx) = NaN;
%----------------------------------------------------

% Prepare mesh for locating model elements
% These could be read from the file ('MOD_3D_1.dat') header
xvec = [35:0.15:140]'; % 701 (longitude)
yvec = [10:0.15:60]';  % 334 (latitude)

dz = 20*1e3;
zvec = [10:20:900]*1e3';   % 45 (depth)

zvec_subset = zvec(find(and(zvec>=zrange(1),zvec<=zrange(2))));
iz = nearest(zrange/dz);

[X,Y] = meshgrid(xvec,yvec);

[nx,ny] = size(X);
Nz = nx*ny; % number of element in one depth cross-section
xx=reshape(X',[Nz,1]);
yy=reshape(Y',[Nz,1]);

% XXX put a repmat here
% XXX save as mat file and load

if iplot_anomaly
    % Actual Koulakov data contians vp, vs percent anomalies
    % Reference model is ak135
    for ii = iz(1):iz(2)
        last = ii*Nz;
        first = last - Nz +1;
        zz = model(first:last);
        figure
        subplot(2,1,1)
        scatter(xx,yy,10,zz)
        colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); caxis([-3 3])
        hold on
        plot_borders(axis)
        title(sprintf('Koulakov 2011, %s anomaly; depth: %.1f km',stag, zvec(ii)/1e3));
    end
end
%----------------------------------------------------

% Read reference model
[z,rho,vp,vs,qkappa,qmu] = read_1D_ak135;

if imodel==1
    v = vp;
elseif imodel==2
    v = vs;
end

for ii = iz(1):iz(2)
    last = ii*Nz;
    first = last - Nz +1;
    % get anomaly
    zz = model(first:last);
    % get vs or vp value
    % XXX get interpolated value
    [val,idx] = min(abs(z-zvec(ii)/1e3)); % XXX getting the nearest value from ak135
    
    imodel = 2;
    v0 = v(idx);
    % actual value
    zz = v0*(1 + zz/100);
    
    %figure
    subplot(2,1,2)
    scatter(xx,yy,10,zz)
    colorbar; cmap = colormap('jet'); colormap(flipud(cmap)); %caxis([-3 3])
    hold on
    plot_borders(axis)
    title(sprintf('Koulakov 2011, %s velocity; depth: %.1f km',stag, zvec(ii)/1e3));
end
