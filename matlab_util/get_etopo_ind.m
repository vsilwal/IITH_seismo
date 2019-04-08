function [Xlon,Ylat,Zt,nx,ny,d] = get_etopo_ind(ismooth,smoothfig,bfigure)
%GET_ETOPO_AK loads a pre-saved grid of ETOPO1 points covering Alaska
%
%   ETOPO1 has a resolution of about 1.8 km
%   The file is a uniform lon-lat grid, so spacing will vary (on the sphere).
%   The file was saved with the commands
%       ax0 = [-180 -130 48 74];
%       [Xlon,Ylat,Zt,nx,ny,d] = get_etopo(ax0);
%       save('etopo_ak','Xlon','Ylat','Zt','nx','ny','d');
%
%   figure; pcolor(Xlon,Ylat,Zt); shading flat;
%

if ~or(nargin==0,nargin==3), error('nargin = 0 or 3'); end

if nargin==0
    ismooth = 0;
    smoothfig = false;
    bfigure = false;    
end

load('/home/vipul/dlib/topography/india/etopo1_india');
%load('/home/vipul/dlib/topography/india/etopo1_him')
whos

if ismooth > 0

    Xlon = Xlon'; Ylat = Ylat'; Zt = Zt';    
    x = Xlon(:);
    y = Ylat(:);
    zt = Zt(:);     
    Ztorig = Zt;   
    
    switch ismooth
        case 1      % smooth the entire model
            disp('SMOOTH ENTIRE MODEL');
            axtar1 = [min(Xlon(:)) max(Xlon(:)) min(Ylat(:)) max(Ylat(:))];
            NPTG = 4;
            zt = smooth_box(x,y,zt,axtar1,NPTG,smoothfig);
        case 2
            disp('NO SMOOTHING OF SPECIFIC REGIONS IS IMPLEMENTED');
    end
    
    Zt = reshape(zt,nx,ny);
    Xlon = Xlon'; Ylat = Ylat'; Zt = Zt';

    if bfigure
        Ztorig = Ztorig';
        figure; pcolor(Xlon,Ylat,Ztorig); shading flat;
        xlabel('Longitude'); ylabel('Latitude');
        title('ETOPO1 from NOAA');
        axis equal, axis tight; colorbar

        figure; pcolor(Xlon,Ylat,Zt); shading flat;
        xlabel('Longitude'); ylabel('Latitude');
        title('ETOPO1 from NOAA, smoothed');
        axis equal, axis tight; colorbar

        figure; hold on; pcolor(Xlon,Ylat,Zt-Ztorig); shading flat;
        %plot(axtar1([1 2 2 1 1]),axtar1([3 3 4 4 3]),'k','linewidth',2);
        axis equal, axis tight; colorbar
        title('Znew minus Zorig');
    end

end
