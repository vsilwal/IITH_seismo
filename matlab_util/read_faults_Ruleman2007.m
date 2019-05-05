% Read most complete active fault dataset of Afghanistan
% Map and Database of Probable and Possible Quaternary Faults in Afghanistan
% By C.A. Ruleman, A.J. Crone, M.N. Machette, K.M. Haller and K.S. Rukstales
%
% https://pubs.usgs.gov/of/2007/1103/

ddir = '/home/vipul/dlib/FAULTS/USGS_Afghanistan/';
shpfilename = 'faults.shp';

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
    title('Active Faults in Aghanistan, Ruleman 2007')
    axis equal
end

% Save as mat file
%save(strcat(ddir,'USGZ_Ruleman2007'),'data')

% save pdf plot
print('USGS_Ruleman2007','-dpdf','-fillpage')