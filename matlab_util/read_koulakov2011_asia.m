function [x,y,z,Vp,Vs,dVp,dVs] = read_koulakov2011_asia(ax0)

ddir = '/home/vipul/dlib/TOMO/koulakov/DATA/ASIA_ALL/';
load(strcat(ddir,'koulakov2011'));

if nargin > 0
    [inds,x,y] = getsubset(x,y,ax0);
    z = z(inds);
    Vp = Vp(inds);
    Vs = Vs(inds);
    dVp = dVp(inds);
    dVs = dVs(inds);
end
whos
%------------------------------------------------------------
if 0
    ax0 = [60 100 30 50];
    [x,y,z,Vp,Vs,dVp,dVs] = read_koulakov2011_asia(ax0);
    
    zrange = [50 50]*1e3;
    iz = nearest(zrange/20000);
    
    dV = dVp; V = Vp; stag = 'P wave';
    %dV = dVs; V = Vs; stag = 'S wave';
    
    Nz = length(x)/45; % because there are 45 layers in the model
    
    % Actual Koulakov data contians vp, vs percent anomalies
    % Reference model is ak135
    for ii = iz(1):iz(2)
        last = ii*Nz;
        first = last - Nz +1;
        dV_dep = dV(first:last);
        V = dV(first:last);
        
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