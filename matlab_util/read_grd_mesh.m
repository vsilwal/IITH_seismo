function [X,Y,Z,nx,ny,d] = read_grd_mesh(grdfile,ax0)
%READ_GRD_MESH read a grdfile and return data as standard matlab arrays.
%
% This uses grdread.m, which requires that GMT has been installed
% with the mex option.
%
% INPUT
%   grdfile     filename as a string
%   ax0         optional: subset region to extract
%
% OUTPUT
%   X           x-values stored as a matrix
%   Y           y-values stored as a matrix
%   Z           z-values stored as a matrix
%   nx          number of points in x-direction
%   ny          number of points in y-direction
%   d           full header for ORIGINAL grdfile
%
% See also write_grd_mesh.m
%
% Carl Tape, 27-Oct-2010
%

if ~exist(grdfile,'file')
    disp(grdfile);
    error('file does not exist');
end
grdfile = '/home/vipul/dlib/topography/GLOBAL/ETOPO1/ETOPO1_Ice_g.grd';
[x,y,Z,d] = grdread2(grdfile);
whos x y Z d
nx = length(x);
ny = length(y);
[X,Y] = meshgrid(x,y);
% figure; imagesc(Z);

if nargin > 1
    if max(ax0(1:2)) > 180
       disp('converting etopo longitude values to [0 360] range');
       % cut lon=180 column, since it is included as lon=180 already
       % WARNING: THIS CANNOT BE LON=-180 FOR SOME REASON
       whos X Y Z
       i180 = find(x==180);
       X(:,i180) = [];
       Y(:,i180) = [];
       Z(:,i180) = [];
       nx = nx-1;
       whos X Y Z
       % convert longitudes to range [0 360]
       X = wrapTo360(X);
       % shift the position of the entries
       ineg = 1:nx/2;
       ipos = nx/2+1:nx;
       X = [X(:,ipos) X(:,ineg)];
       Y = [Y(:,ipos) Y(:,ineg)];
       Z = [Z(:,ipos) Z(:,ineg)];
       %figure; imagesc(Z);
    end
    
    % take subset
    [X,Y,Z,nx,ny] = getsubset_3d(X,Y,Z,ax0);
end

%==========================================================================
% EXAMPLES

