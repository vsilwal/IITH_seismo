function [otime,lon,lat,dep,Mw,eid,depunc] = read_eq_iscgem(arg1,ax3,Mwran)
%READ_EQ_ISCGEM read the ISC-GEM global earthquake catalog
%
% EXAMPLES:
%   [otime,lon,lat,dep,Mw,eid,depunc] = read_eq_iscgem;
%   figure; plot_histo(year(otime),[1900:2015]);
%   figure; plot_histo(Mw,[5:0.1:10]);
%   [Ncum,N,Medges] = seis2GR(Mw,0.1); GR2plot(Ncum,N,Medges,[],[6 8]);
%
%   Alaska events (only one event prior to 1917):
%   [otime,lon,lat,dep,Mw,eid,depunc] = read_eq_iscgem([],[-180 -130 50 72],[]);
%   display_eq_list([],otime,lon,lat,dep,Mw,eid);
%
%   far north earthquakes:
%   [otime,lon,lat,dep,Mw,eid,depunc] = read_eq_iscgem([],[-180 180 65 90],[7 10]);
%   display_eq_list([],otime,lon,lat,dep,Mw,eid);
%
% calls read_eq_isc.m
%

ddir = '/home/vipul/dlib/seismicity/globe/isc-gem/';
%ddir = '/home/carltape/dwrite/iscgem/';     % temporary
odir = ddir;                                % temporary
ofile = [odir 'isc-gem.mat'];
ifile = [ddir 'isc-gem-cat.csv'];

if ~exist(ofile,'file')
    ifile
    [otime,lon,lat,dep,Mw,eid,smajax,sminax,strike,qepi,depunc,qdep,magunc,fac,mo_auth,M] = read_eq_isc(ifile);
    disp(['saving ' ofile]);
    save(ofile,'otime','lon','lat','dep','Mw',...
        'smajax','sminax','strike','qepi','depunc','qdep',...
        'magunc','fac','mo_auth','M','eid');
else
   load(ofile); 
end

%whos
%figure; plot(lon,lat,'.')


disp(sprintf('reading the full ISC-GEM catalog (%i events)',length(otime)));
% display_eq_summary(otime,lat,lon,dep,Mw);

% subset
if nargin==3
    disp('subsetting the ISC-GEM catalog');
    [otime,lat,lon,dep,Mw,isubset] = get_seis_subset(otime,lat,lon,dep,Mw,arg1,ax3,Mwran);
    depunc = depunc(isubset);
    eid = eid(isubset);
    if isempty(isubset)
        disp('NO EVENTS IN THE SUBSET');
        return
    end
end

%%
% EXAMPLE
