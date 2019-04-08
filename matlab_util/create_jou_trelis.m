% Write jou file for creating topography surface in cubit
clear all
close all

filename = '/home/vipul/trelis_scripts/';
load(filename);

ftag = 'nepal';
lonmin=82; latmin=26; 
szone = '45R'; 
xran = 60000; yran = 50000;

[xmin,ymin] = utm2ll(lonmin,latmin,szone,0);
% construct bounding rectangle using xran and yran
axx = [xmin xmin+xran ymin ymin+yran];

dx = 1*1e3;
ismooth = 0;
% this command will NOT write the file, since odir is not provided
[X,Y,Ztopo,Zmoho,nx,ny] = write_topo_moho_ind(xmin,ymin,xran,yran,dx,szone,ismooth);

% write *.jou file
jou_filename = strcat(ftag,'_topo_matlab.jou');
create_vertex = 'create vertex location';
create_curve ='create	curve	spline	vertex';

fid = fopen(jou_filename,'w');
for i=1:length(X(:))
    fprintf(fid,'%s %f %f %f\n',create_vertex,X(i),Y(i),Ztopo(i));
end

[nx,ny]=size(X);
start_vertex=1;
end_vertex=ny;
for i=1:nx
    fprintf(fid,'%s %0.f to %.0f\n',create_curve,start_vertex,end_vertex);
    start_vertex=1+end_vertex;
    end_vertex=start_vertex+ny;
end
fclose(fid);

