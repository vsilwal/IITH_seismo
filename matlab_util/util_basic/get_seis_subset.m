function [otime,lat,lon,dep,Mw,isubset] = get_seis_subset(otime,lat,lon,dep,Mw,oran,ax3,Mwran,blon,blat)
%GET_SEIS_SUBSET gets a subset of earthquakes from a larger set
%
% INPUT
%   oran    option A: range of origin times
%           option B: target origin time and half-duration of time window;
%                       this is used for picking a single event
%   ax3     3D box in space: [lonmin lonmax latmin latmax depmin depmax]
%           note: longitude ranges shold be wrapped to 360 (wrapTo360)
%   Mwran   range of magnitudes
%   blon,blat   OPTIONAL: custom boundary to use
%
% OUTPUT
%   otime   origin time
%   lat     latitude
%   lon     longitude
%   dep     depth from moment tensor inversion (AEIC webpages only), km
%   Mw      moment magnitude computed from M0
%   isubset index into input vectors that will return the subset
%
% calls mintersect.m, display_eq_summary.m
%
% Carl Tape, 2011-04-20
%

n = length(otime);

disp('get_seis_subset.m:');

spdy = 86400;
ioneevent = 0;

% maximum allowable half window for searching a target event
% note: this allows oran(2) to be used in two different ways:
%          A. oran(1) = target otime, oran(2) = half window in seconds
%          B. oran(1) = start time, oran(2) = end time
MAX_HWIN_SEC = 2*spdy;

% display input set
display_eq_summary(otime,lon,lat,dep,Mw);

buse_depth = true;
if isempty(dep)
   buse_depth = false;
   warning('input depth is empty -- ignoring subset by depth'); 
end

% check input arguments
% origin time
if isempty(oran)
    oran = [datenum(-2000,1,1) datenum(4000,1,1)];
    warning('input range of origin time is empty -- setting default to %s to %s',...
        datestr(oran(1),29),datestr(oran(2),29));
elseif length(oran)==1
    oran(2) = now; 
    warning('latest origin time not specified -- setting default to %s',...
    datestr(oran(2),29));
elseif length(oran)==2
    if oran(2) < MAX_HWIN_SEC
        ioneevent = 1;
        OTAR = oran(1);
        HWIN_SEC = oran(2);
        oran(1) = OTAR - HWIN_SEC/spdy;
        oran(2) = OTAR + HWIN_SEC/spdy;
        ax3 = [];
        magran = [];
        disp(sprintf('Targeting an event at %s within +/- %.1f s',datestr(OTAR,29),HWIN_SEC));
    end
else
    error('oran must have length 0,1, or 2');
end
% volumetric region
if isempty(ax3)
    ax3 = [-180 180 -90 90 -100 700];
    warning('input bounding volume is empty -- setting default to [%.1f %.1f %.1f %.1f %.1f %.1f]',ax3);
else
    bboundar_custom = false;
    if length(ax3)==4
        ax3 = [ax3 -100 700];
        warning('input depths are empty -- setting default to [%.1f %.1f]',ax3(5:6));
    end
    if length(ax3)==2
        ax3 = [-180 180 -90 90 ax3];
        warning('input bounding region is empty -- setting default to [%.1f %.1f %.1f %.1f]',ax3(1:4));
    end
end
% magnitude range
ballmags = false;
if isempty(Mwran)
    Mwran = [-1000 1000];
    %warning('input magnitude range is empty -- setting default to [%.1f %.1f]',Mwran);
    ballmags = true;
    warning('input magnitude range is empty -- including all mags (as well as NaN or [])');
end

if nargin==10
    bboundary_custom = true;
    warning('input bounding region is specified by a set of lon-lat points');
else
    bboundary_custom = false;
end

otime1 = oran(1);
otime2 = oran(2);
lon1   = ax3(1);
lon2   = ax3(2);
lat1   = ax3(3);
lat2   = ax3(4);
dep1   = ax3(5);
dep2   = ax3(6);
mag1   = Mwran(1);
mag2   = Mwran(2);

% if bounds longitudes are [0 360], then wrap input longitudes to same interval
% NOTE: The output will remain as [-180 180]
if or(lon1 > 180, lon2 > 180)
    %iwrap = 1;
    disp('wrapping input longitudes');
    lonw = wrapTo360(lon);
else
    lonw = lon;
end

% if input longitudes are [0 360], then wrap bounds longitudes to [0 360]
if any(lon > 180)
    %iwrap = 1;
    disp('wrapping bounding box longitudes');
    if and(lon1==-180, lon2==180)
        lon1 = 0; lon2 = 360;
    else
        lon1 = wrapTo360(lon1);
        lon2 = wrapTo360(lon2);
    end
end

% oyr0 = year(otime0);
% bsub = (lon0>=ax3(1)).*(lon0<=ax3(2)).*(lat0>=ax3(3)).*(lat0<=ax3(4)).*...
%     (dep0>=ax3(5)).*(dep0<=ax3(6)).*(oyr0>=yrange(1)).*(oyr0<=yrange(2));
% isub = find(bsub==1);
% nsub = length(isub);

if bboundary_custom
    ibox = find(inpolygon(lonw,lat,blon,blat)==1);
else
    ibox = find( and( and( lonw >= lon1 , lonw <= lon2), and(lat >= lat1, lat <= lat2)) );
end
    
idep = find( and( dep >= dep1, dep <= dep2 ) );
itim = find( and( otime >= otime1, otime <= otime2 ) );
imag = find( and( Mw >= mag1, Mw <= mag2 ) );
if ballmags, imag = [1:n]'; end
if buse_depth
    isubset = mintersect(ibox,idep,itim,imag);
else
    isubset = mintersect(ibox,itim,imag);
end

disp(sprintf('%i/%i events between %s and %s (interval %.1f years)',...
    length(itim),n,datestr(otime1,31),datestr(otime2,31),(otime2-otime1)/365.25 ));
disp(sprintf('%i/%i events within lon-lat box [%.1f %.1f %.1f %.1f]',length(ibox),n,lon1,lon2,lat1,lat2));
disp(sprintf('%i/%i events within depth range [%.1f %.1f]',length(idep),n,dep1,dep2));
disp(sprintf('%i/%i events within Mw range [%.1f %.1f]',length(imag),n,mag1,mag2));
disp(sprintf('%i/%i events satisfying all criteria',length(isubset),n));

if ~isempty(isubset)

    otime  = otime(isubset);
    lat    = lat(isubset);
    lon    = lon(isubset);
    if buse_depth, dep = dep(isubset); end
    Mw     = Mw(isubset);

    % display subset
    display_eq_summary(otime,lon,lat,dep,Mw);

    ifig = 0;
    if ifig==1
        figure; nr=2; nc=2;
        subplot(nr,nc,1); plot(Mw,'.'); ylabel('Mw');
        title(sprintf('get_seis_subset.m: %i events',length(Mw)),'interpreter','none');
        subplot(nr,nc,2); plot(year(otime),'.'); ylabel('year');
        subplot(nr,nc,3); plot(lon,lat,'.'); xlabel('Longitude'); ylabel('Latitude');
        subplot(nr,nc,4); plot(dep,'.'); ylabel('Depth, km');
    else
        disp('get_seis_subset.m: ifig=0 -- no figure shown');
    end
    
else
    % alternatively we could return empty variables
    disp('NO EVENTS IN THE SUBSET');
    otime = []; lat = []; lon = []; dep = []; Mw = [];
    %disp('--> output variables will be same as input variables');
    return
end

if and(ioneevent==1,length(otime)~=1)
    warning('you are NOT returning one event, as expected');
end

disp('leaving get_seis_subset.m');

%==========================================================================
