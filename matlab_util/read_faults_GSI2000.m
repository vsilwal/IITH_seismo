% Read most complete active fault dataset of India
% compiled by Dasgupta et al, 2000 (Geological Survey of India)
%
% Shapefiles obtained from Kiran Kumar Thingbaijam
% Nath and Thingbaijam 2012 used an even larger dataset that included
% faults from Afghanistan (USGS) and China (He and Thusukuda 2003).

ddir = '/home/vipul/dlib/FAULTS/Dasgupta2000/';
shpfilename = 'xfaults.shp';

data = shaperead(strcat(ddir,shpfilename));

x = [];
y = [];

ifigure = 1;

for ii=1:length(data)
    x = [x data(ii).X];
    y = [y data(ii).Y];
    %plot(x,y,'LineWidth',2)
end

if ifigure
    figure
    hold on
    plot(x,y,'r','LineWidth',1)
    plot_borders(axis);
        title('Active Faults in India, Dasgupta 2000')
end

% Save as mat file
%save(strcat(ddir,'GIS2000_complete'),'data')
%save(strcat(ddir,'GIS2000'),'x','y')

% save pdf plot
print('faults_GIS2000','-dpdf','-fillpage')