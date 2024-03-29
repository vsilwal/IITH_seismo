function [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] = get_stations(ax0,time_range,datacenter)
%
% Files: /home/vipul/dlib/stations/GMAP
% Files last updated: 2019-04-07
% 
% 
% if nargin == 1
%     subset by ax0 [xmin xmax ymin ymax]
%     ALL datacenters
% if nargin ==2 
%     subset by ax0 and time range = [timemin maxtimemax]
%     ALL datacenters
% if nargin ==2 
%     subset by ax0 and time range
%     User specified datacenter
       
% XXX Also subset by time
% XXX if length(ax0)==3; ax0 = [xlon, ylat, radius]

if nargin < 3
    datacenter = {'AllData'};
    %datacenter = {'AUSPASS' 'GEOFON' 'ICGC' 'IPGP' 'IRISPH5' 'KOERI' 'NIEP' ...
    %              'ORFEUS' 'RESIF'  'SED' 'BGR'  'INGV'  'IRISDMC'  'KNMI' ...
    %              'LMU' 'NCEDC' 'NOA'  'RASPISHAKE'  'SCEDC'  'USPSC'};
end

if nargin == 0
    ax0 = [-180 180 -90 90];
    time_range = [datenum('1700-01-01') now];
elseif nargin == 1
    time_range = [datenum('1900-01-01') now];
elseif and(nargin == 2, iscell(time_range))
    % second arguement is 'char' most probably is datacenter
    datacenter = time_range;
    time_range = [datenum('1900-01-01') now];
end

for ii=1:length(datacenter)
    dc = datacenter{ii};
    ddir='/home/vipul/dlib/stations/GMAP/matlab/';
    stations_file = strcat(ddir,dc);
    stations_file
    
    load(stations_file);
    indx = [];
    % Subset by location
    [indx,lon_sub,lat_sub] = getsubset(lon,lat,ax0);
    netwk_sub = netwk(indx);
    stnm_sub = stnm(indx);
    starttime_sub = start_time(indx);
    endtime_sub = end_time(indx);
    
    whos
    % Now subset by time
    datestr(time_range);
    indx=find(or(or(and(time_range(1) < starttime_sub,time_range(2) > starttime_sub),...
        and(time_range(1) > starttime_sub,time_range(2) < endtime_sub)),...
        and(time_range(1) < endtime_sub,time_range(2) > endtime_sub)));
    disp(sprintf('%0.f stations after time subset',length(indx)));
    
    netwk_sub = netwk_sub(indx);
    stnm_sub = stnm_sub(indx);
    starttime_sub = starttime_sub(indx);
    endtime_sub = endtime_sub(indx);
    lon_sub = lon_sub(indx);
    lat_sub = lat_sub(indx);
    
    % Plotting
    figure
    hold on
    plot(lon_sub,lat_sub,'v'); box on; grid on
    title(sprintf('Datacenter: %s; Time Range: %s - %s',dc, datestr(time_range(1)),datestr(time_range(2),1)));
    
    % Print
    if 0
        for jj = 1:length(indx)
            disp(sprintf('%s \t %s \t %.2f \t %.2f \t %s \t %s',netwk_sub{jj},...
                stnm_sub{jj},lon_sub(jj),lat_sub(jj),datestr(starttime_sub(jj),1),datestr(endtime_sub(jj),1)));
        end
    end
    
end
    
%%
% EXAMPLES
if 0
    clear all
    % Get ALL Stations
    [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] = get_stations;
    
    %==========================================================
    % Get ALL stations within certain lat-lon region
    clear all
    %----------------------------------------------------------
    %ax0 = [60 100 20 45];
    ax0 = [77 83 29 33]; 
    time_range = [datenum('2010-06-21') datenum('2010-07-07')];
    %----------------------------------------------------------
    [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] = get_stations(ax0,time_range);
    plot_borders(ax0);  axis(ax0); axis equal
    axis(ax0)
    wrtie_vtk_xyz('stations',lon_sub,lat_sub,ones(1,length(lat_sub)))
    %----------------------------------------------------------
    % Get earthquakes
    [otime,lon,lat,dep,Mw,eid,depunc] = read_eq_iscgem(time_range,[ax0 0 200],[3 10]);
    display_eq_list([],otime,lon,lat,dep,Mw);
    hold on    
    plot(lon,lat,'o','MarkerSize',7,'MarkerEdgeColor','black','MarkerFaceColor',[1 .6 .6]);
    plot(lon_sub,lat_sub,'vb')
    xlabel('Lon'); ylabel('Lat');
    % Get CMT Solutions
    [otimeCMT,tshift,hdur,latCMT,lonCMT,depCMT,M,M0,MwCMT,eid,elabel,...
        str1,dip1,rk1,str2,dip2,rk2,lams,pl1,az1,pl2,az2,pl3,az3,...
        icmt,dataused,itri,M0gcmt,Mb,Ms] = readCMT(time_range,[ax0 0 200],[4 10]);
    plot(lonCMT,latCMT,'p','MarkerSize',13,'MarkerEdgeColor','black','MarkerFaceColor',[1 0 0])
    display_eq_list([],otimeCMT,lonCMT,latCMT,depCMT,MwCMT);
    % save as pdf
    %print('stations_event','-dpdf','-fillpage')
    %==========================================================
    
    % Get stations from a specfic Datacenter for ALL time-period
    clear all
    ax0 = [60 100 20 45];
    datacenter = {'RESIF'};
    [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] =get_stations(ax0,datacenter);
    for jj = 1:length(indx)
       disp(sprintf('%s \t %s \t %.2f \t %.2f \t %s \t %s',netwk_sub{jj},...
           stnm_sub{jj},lon_sub(jj),lat_sub(jj),datestr(starttime_sub(jj),1),datestr(endtime_sub(jj),1)));
    end
    
    % Get stations from a specfic Datacenter
    clear all
    ax0 = [60 100 20 45];
    time_range = [datenum('2000-01-01') datenum('2010-01-01')];
    datacenter = {'IRISDMC'};
    [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] =get_stations(ax0,time_range,datacenter);
    %==========================================================
    %
    clear all
    close all
    
    %----------------------------------------------------------
    ax0 = [55 105 5 45]; % Indian subcontinent
    time_range = [datenum('1990-01-01') datenum('2019-01-01')];
    %----------------------------------------------------------
    [indx,lon_sub,lat_sub,netwk_sub,stnm_sub,starttime_sub,endtime_sub] = get_stations(ax0,time_range);
    plot_borders(ax0);  axis(ax0); axis equal
    axis(ax0)
    
    figure
    scatter(lon_sub,lat_sub,20,starttime_sub,'v')
    colormap(lines(7))
    h = colorbar;
    datetick(h,'y');

end