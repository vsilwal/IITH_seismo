% Read most complete active fault dataset of India
% compiled by Dasgupta et al, 2000 (Geological Survey of India)
%
% Shapefiles obtained from Kiran Kumar Thingbaijam
% Nath and Thingbaijam 2012 used an even larger dataset that included
% faults from Afghanistan (USGS) and China (He and Thusukuda 2003).

clear all
ddir = '/home/vipul/dlib/FAULTS/Dasgupta2000/';
shpfilename = 'xfaults.shp';

ifigure = 0;

data = shaperead(strcat(ddir,shpfilename));

x = [];  % save as mat file
y = [];

ivtk = 1;
ftag = 'f';
for ii=1:length(data)
    x = [x data(ii).X];
    y = [y data(ii).Y];
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
%print('faults_GIS2000','-dpdf','-fillpage')

% Write vtk files
odir = '~/test/';
count=1;
xvtk=[];
yvtk=[];
for ii=1:length(x)
    xvtk = [xvtk x(ii)];
    yvtk = [yvtk y(ii)];
    if or(isnan(x(ii)),isnan(y(ii)))
        xvtk(end)=[];% remove NaN
        yvtk(end)=[]; 
        ftag = strcat('f',num2str(count),'.vtk');
        zvtk = 5000 * ones(1,length(xvtk));
        vtkwrite(ftag,'polydata','lines',xvtk,yvtk,zvtk)
        count = count+1;
        xvtk=[];
        yvtk=[];
    end
end

indx = find(isnan(x));
xvtk=x;
yvtk=y;
xvtk(indx)=[];
yvtk(indx)=[];
ftag = 'Dasgupta2000';
zvtk = 5000 * ones(1,length(xvtk));
write_vtk_xyz(ftag,xvtk,yvtk,zvtk)
