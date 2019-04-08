% This only to be run occasionally to update the matlab stations file
% Stations are obtained from:
% http://ds.iris.edu/gmap/
% 
% Another script XXX reads these matlab file and returns selected stations

clear all
close all

ddir = '/home/vipul/dlib/stations/GMAP/';

% AUSPASS
% BGR
% GEOFON
% ICGC
% INGV
% IPGP
% IRISDMC
% IRISPH5
% KNMI
% KOERI
% LMU
% NCEDC
% NIEP
% NOA
% ORFEUS
% RASPISHAKE
% RESIF
% SCEDC
% SED
% USPSC

datacenter = 'RESIF';
stations_file = strcat(ddir,datacenter);

% Read stations file
c=textread(stations_file,'%s','delimiter','\n','whitespace','');

netwk={};
stnm={};
lat=[];
lon=[];
elev=[];   % in meters
sitenam={};
start_time=[];
end_time=[];

% Read contents line-by-line
for ii=1:length(c)-1
    % Don't read the header file
    C = strsplit(c{ii+1},'|'); 
    netwk(ii)=C(1);
    stnm(ii)=C(2);
    lat(ii)=str2double(C{3});
    lon(ii)=str2double(C{4});
    elev(ii)=str2double(C{5});
    try
        sitenam(ii)=C(6);
        tt=strsplit(C{7},{'T'});
        start_time(ii)=datenum([tt{1} ' ' tt{2}]);
        tt=strsplit(C{8},{'T'});
        end_time(ii)=datenum([tt{1} ' ' tt{2}]);
    catch
        sitenam(ii)={' '}; % Not site info
        tt=strsplit(C{6},{'T'});
        start_time(ii)=datenum([tt{1} ' ' tt{2}]);
        tt=strsplit(C{7},{'T'});
        end_time(ii)=datenum([tt{1} ' ' tt{2}]);  
    end
end

% save as matlab file

outdir = '/home/vipul/dlib/stations/GMAP/matlab/';
output_mat_file = strcat(outdir,datacenter);

if 0
    save(output_mat_file,'netwk','stnm','lat','lon','elev','sitenam','sitenam','start_time','end_time');
end

%% Merge all mat files

Folder = '/home/vipul/dlib/stations/GMAP/matlab/';
 FileList = dir(fullfile(Folder, '*.mat'));  % List of all MAT files
allData  = struct();
for iFile = 1:numel(FileList)               % Loop over found files
  Data   = load(fullfile(Folder, FileList(iFile).name));
  Fields = fieldnames(Data);
  for iField = 1:numel(Fields)              % Loop over fields of current file
    aField = Fields{iField};
    if isfield(allData, aField)             % Attach new data:
       allData.(aField) = [allData.(aField), Data.(aField)];
    else
       allData.(aField) = Data.(aField);
    end
  end
end
save(fullfile(Folder, 'AllData.mat'), '-struct', 'allData');   