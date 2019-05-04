% Read most complete active fault dataset of India
% compiled by Dasgupta et al, 2000 (Geological Survey of India)
%
% Shapefiles obtained from Kiran Kumar Thingbaijam
% Nath and Thingbaijam 2012 used an even larger dataset that included
% faults from Afghanistan (USGS) and China (He and Thusukuda 2003).

ddir = '/home/vipul/dlib/FAULTS/Dasgupta2000/';
shpfilename = 'xfaults.shp';

data = shaperead(strcat(ddir,shpfilename));

ifigure = 1;
if ifigure
    figure
    hold on
    
    for ii=1:length(data)
        x = data(ii).X;
        y = data(ii).Y;
        plot(x,y)
    end
end

save(strcat(ddir,'GIS2000'),'data')

print('faults_GIS2000','-dpdf','-fillpage')