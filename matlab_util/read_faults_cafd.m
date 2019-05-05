% Read most complete active fault dataset of Central Asia
% Solmaz Mohadjer et al., 2006, A Quaternary fault database for central Asia
% 
% https://www.nat-hazards-earth-syst-sci.net/16/529/2016/nhess-16-529-2016.pdf

ddir = '/home/vipul/dlib/FAULTS/CAFD/';
shpfilename = 'cafd_faults_27072015.shp';

data = shaperead(strcat(ddir,shpfilename));

x = [];
y = [];

ifigure = 1;

for ii=1:length(data)
    x = [x data(ii).X];
    y = [y data(ii).Y];
end

if ifigure
    figure
    hold on
    plot(x,y,'r','LineWidth',1)
    plot_borders(axis);    
    title('Active Faults in Central Asia, Mohadjer 2016')
end

% Save as mat file
save(strcat(ddir,'CAFD2016_complete'),'data')
save(strcat(ddir,'CAFD2016_complete'),'x','y')

% save pdf plot
print('CAFD2016','-dpdf','-fillpage')