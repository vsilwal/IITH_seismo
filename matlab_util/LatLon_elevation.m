%%
% Import required files

import matlab.net.*
import matlab.net.http.*
format long g

%%
% Inputs

Lon = 83.5:0.1:87;
Lat = 26.5:0.1:29;
[Lat,Lon] = ndgrid(Lat,Lon);

%%
% Request and extract data
len = length(Lat(:));
% result = zeros(len,3);

n1 = 1:10:len;
n2 = [10:10:len, len];
nLen = length(n1);
tic
for i = 1:nLen
    points = sprintf('(%f,%f)',Lat(n1(i)),Lon(n1(i)));
    for j = n1(i)+1:n2(i)
        points = sprintf('%s,(%f,%f)',points,Lat(j),Lon(j));
    end
    
    req = RequestMessage;
    uri = URI(strcat('https://elevation-api.io/api/elevation?points=',points));
    options = matlab.net.http.HTTPOptions('ConnectTimeout',60);
    resp = send(req,uri,options);
    
    % status = resp.StatusCode
    
    data = resp.Body.Data.elevations;
    
    % extract data
    result(n1(i):n2(i),1) = extractfield(data,'lat');
    result(n1(i):n2(i),2) = extractfield(data,'lon');
    result(n1(i):n2(i),3) = extractfield(data,'elevation');
%     if (mod(i,15)==0), disp(i); pause(15); end
end
toc
disp(result)
disp 'Writing to file...'
%%
% Write to file

points = '';
for j = 1:len
    points = sprintf('%s%f\t%f\t%f\n',points,result(j,:));
end

fid = fopen('topo.txt','W');
fprintf(fid,'%s',points);
fclose(fid);
disp 'Completed.'