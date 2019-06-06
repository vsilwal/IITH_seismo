function [z,rho,vp,vs,qkappa,qmu] = read_1D_ak135
%
% Original source
% uafseismo/GEOTOOLS

bdir = '/home/vipul/dlib/TOMO/ak135/';
dtemp = load([bdir 'ak135f.txt']);

z  = dtemp(:,1);
rho = dtemp(:,2);
vp  = dtemp(:,3);
vs  = dtemp(:,4);
qkappa = dtemp(:,5);
qmu    = dtemp(:,6);

%==========================================================================
% EXAMPLES

if 0==1
    %%
    [z,rho,vp,vs,qkappa,qmu] = read_1D_ak135;
    for kk=1:2
        figure; hold on;
        plot(vp,z,'r.-','markersize',12);
        plot(vs,z,'b.-','markersize',12);
        plot(rho,z,'k.-','markersize',12);
        legend('Vp (km/s)','Vs (km/s)','Rho (g/cm3)');
        set(gca,'ydir','reverse');
        ylabel('Depth, km');
        title('ak135f: Montagner and Kennett (1995)');
        grid on;
        if kk==1, ylim([0 6371]); else axis([-0.5 9 -5 45]); end
    end

    %-----------------------------------
    % Save file for CAP
    [z,rho,vp,vs,qkappa,qmu] = read_1D_ak135;
    
    
end

