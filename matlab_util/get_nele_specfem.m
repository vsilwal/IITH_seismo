function [zele,dz,zdoublingele] = get_nele_specfem(dx, zmax,zlayers,zdoubling)
% INPUT
% dx            size of the surface element 
% zmax          maximum depth of mesh
% zlayers       depth from surface to each interface (=[] if medium is homogeneous)
% zdoubling     depth from surface to each doubling layer (=[] if no doubling layer)
%               It is suggested to put doubling at the interfaces
%
% zmax, zlayers and zdoubling should be in negative
%
% OUTPUT
% zele          Number of elements in each layer
% zdoublingele  Element number from bottom at which we want doubling

% If there is doubling layer below the last layer interface
if and(and(~isempty(zlayers),~isempty(zdoubling)),zdoubling(end)<zlayers(end))
    indx = find(zdoubling<zlayers(end));
    zlayers = [zlayers zdoubling(indx)];
end
    
% If homogeneous put 2 interfaces - top and bottom
% Make bottom of mesh as last interface
if isempty(zlayers)
    zlayers = [0 zmax];
else
    zlayers = [zlayers zmax]; 
end

% If no doubling just use surface element size throughout
if isempty(zdoubling)
    zdoubling = zlayers(end);
else
    zdoubling = [zdoubling zlayers(end)];
end

N = length(zlayers)-1;

% Find which layers will have approx what size
count = 1;
for ii=1:N
    if zlayers(ii) <= zdoubling(count)    
        count = count + 1;
    end
    
    dz(ii) = dx * (2^(count-1)); % thickness of elements in this layer    
    zthick(ii) = zlayers(ii) - zlayers(ii+1); % thickness of this layer
    zele(ii) = abs(nearest(zthick(ii)/dz(ii))); % number of elements in this layer
    zlayers_mesh(ii) = zele(ii) * dz(ii);
end

% count number of elements from bottom of the mesh to the douling layer 
zdoublingele=[];
zcompare = dz(end);
zele_flip=cumsum(flip(zele));
for ii=1:N
    if dz(N-ii+1) < zcompare
        zdoublingele = [zdoublingele zele_flip(ii-1)];
        zcompare = dz(N-ii+1);
    end
end

disp('Doubling layers are at:')
zdoublingele

% print
disp('---------------------------------------------------')
disp(sprintf('thickness(m) \t Nele \t element_size \t thickness(mesh)'));
disp('---------------------------------------------------')
for ii=1:N
    disp(sprintf('%0.2f \t %0.0f \t %0.1f \t %0.1f',zthick(ii), zele(ii), dz(ii), zlayers_mesh(ii)));
end
disp('---------------------------------------------------')
disp(sprintf('%0.1f \t %0.0f \t N/A \t\t %0.1f',sum(zthick),sum(zele),sum(zlayers_mesh)))



%%
% EXAMPLES
if 0
    % scak
    dx = 1e3;
    zmax = -300*1e3; 
    zlayers = [0 -4 -9 -14 -19 -24 -33 -49 -66]*1e3;
    zdoubling = [-9 -66]*1e3;

    [zele,dz,zdoublingele]= get_nele_specfem(dx, zmax,zlayers,zdoubling);
    
    %----------------------------
    % homogeneous
    dx = 1e3;
    zmax = -300*1e3; 
    zlayers = [];
    zdoubling = [];

    [zele,dz,zdoublingele]= get_nele_specfem(dx, zmax,zlayers,zdoubling);
    
    %----------------------------
    % scak (NO doubling)
    dx = 1e3;
    zmax = -300*1e3; 
    zlayers = [0 -4 -9 -14 -19 -24 -33 -49 -66]*1e3;
    zdoubling = [];

    [zele,dz,zdoublingele]= get_nele_specfem(dx, zmax,zlayers,zdoubling);
    
    %----------------------------
    % tactmod
    dx = 1e3;
    zmax = -300*1e3; 
    zlayers =  [0 -3 -11 -24 -31 -76]*1e3
    zdoubling = [-11 -76]*1e3;

    [zele,dz,zdoublingele]= get_nele_specfem(dx, zmax,zlayers,zdoubling);
    
    %----------------------------
    % himalayas
    x = 1e3;
    zmax = -200*1e3; 
    zlayers =  [0 -4 -16 -20 -27 -37 -42 -56]*1e3;
    zdoubling = [-10 -56 -100]*1e3;

    [zele,dz,zdoublingele]= get_nele_specfem(dx, zmax,zlayers,zdoubling);
end
