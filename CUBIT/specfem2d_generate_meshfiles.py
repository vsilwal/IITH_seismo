#!python
# 2D simulation in P-SV domain
# always see that there are atleast 4 soil layers and the pile is embedded in the bottommost layer, otherwise a number of parameters change

import cubit
import cubit2specfem2d_abs4
import os
import sys
import random
# 100-400 strato 0 step of 50  vp=1100
# 300-600 strato 1 step of 50 vp =1100
# 100-500 strato 2 step of 50 vp =1200
#thicknes strato 

def add_beam(xr,hr,lr):
    cmd='create vertex '+str(xr-lr/2)+' 0 0'; cubit.cmd(cmd)
    id_v1 = cubit.get_last_id("vertex")
    cmd='create vertex '+str(xr+lr/2)+' 0 0'; cubit.cmd(cmd)
    id_v2 = cubit.get_last_id("vertex")
    cmd='create curve vertex '+str(id_v1)+' '+str(id_v2); cubit.cmd(cmd)
    id_curv = cubit.get_last_id("curve")
    cmd='sweep curve '+str(id_curv)+' vector 0 0 -1 distance '+str(hr); cubit.cmd(cmd)
    #cmd='delete curve '+str(id_curv); cubit.cmd(cmd)
    id_torre = cubit.get_last_id("volume")
    id_torre_surf_orig = cubit.get_last_id("surface")
    return id_torre,id_torre_surf_orig,id_curv

cubit.cmd('reset')
x1=-30;y1=0;  #first vertex x,y coord's
x2=220;y2=0;  #second vertex x,y coord's
nt=30; #30         #no. of piles
dx=3.0;         #spacing b/w piles - divisibile per la lunghezza della mesh
lr=0.3;      #thickness(dia) of pile
xr=70;        #position of first pile from source in x direction
hr=25;         #height of pile
dh=0.0#0.34  difference in height of adjacent piles

#thickness of soil layers from the top
thick_l1=0.7
thick_l2=1.3
thick_l3=3.0
thick_l4=45.0

#mesh size
#mesh_size = 0.5;


fid1 = open('L_layer_srldata', 'w')
fid2 = open('pile_pos_srldata', 'w')
fid3 = open('source_pos_srldata', 'w')
fid1.write("%04.1f\n" % (thick_l1))
fid1.write("%04.1f\n" % (thick_l2))
fid1.write("%04.1f\n" % (thick_l3))
fid1.write("%04.1f\n" % (thick_l4))
fid3.write("%04.1f\n" % (xr))
fid1.close();fid3.close();

#creating first layer of soil
cmd='create vertex '+str(x1)+' '+str(y1)+' 0'
cubit.cmd(cmd)
cmd='create vertex '+str(x2)+' '+str(y2)+' 0'
cubit.cmd(cmd)
cmd='create curve vertex 1 2'
cubit.cmd(cmd)
cmd='sweep curve 1 vector 0 0 -1 distance '+str(thick_l1); cubit.cmd(cmd)
id_base0 = cubit.get_last_id("volume")
#cmd='delete curve 1'; cubit.cmd(cmd)
cmd='rotate 90 about world X';cubit.cmd(cmd)

#creating second layer of soil
cubit.cmd('create vertex x '+str(x1)+' '+str(y1)+' '+str(-thick_l1)); 
id_v1 = cubit.get_last_id("vertex"); print 'v1', id_v1
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-thick_l1));
id_v2 = cubit.get_last_id("vertex");print 'v2', id_v2
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-(thick_l1+thick_l2)));
id_v3 = cubit.get_last_id("vertex"); print 'v3', id_v3
cubit.cmd('create surface parallelogram vertex '+str(id_v1)+' '+str(id_v2)+' '+str(id_v3));
id_base1 = cubit.get_last_id("surface");
id_base_v1 = cubit.get_last_id("volume");
cmd='imprint volume all'; cubit.cmd(cmd)
cmd='merge volume all'; cubit.cmd(cmd)

#creating third layer of soil
cubit.cmd('create vertex x '+str(x1)+' '+str(y1)+' '+str(-(thick_l1+thick_l2))); 
id_v1 = cubit.get_last_id("vertex"); print 'v1', id_v1
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-(thick_l1+thick_l2)));
id_v2 = cubit.get_last_id("vertex");print 'v2', id_v2
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-(thick_l3+(thick_l1+thick_l2))));
id_v3 = cubit.get_last_id("vertex"); print 'v3', id_v3
cubit.cmd('create surface parallelogram vertex '+str(id_v1)+' '+str(id_v2)+' '+str(id_v3));
id_base2 = cubit.get_last_id("surface");
id_base_v2 = cubit.get_last_id("volume");
cmd='imprint volume all'; cubit.cmd(cmd)
cmd='merge volume all'; cubit.cmd(cmd)

#creating fourth layer of soil
cubit.cmd('create vertex x '+str(x1)+' '+str(y1)+' '+str(-(thick_l3+thick_l1+thick_l2))); 
id_v1 = cubit.get_last_id("vertex"); print 'v1', id_v1
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-(thick_l3+thick_l1+thick_l2)));
id_v2 = cubit.get_last_id("vertex");print 'v2', id_v2
cubit.cmd('create vertex x '+str(x2)+' '+str(y2)+' '+str(-(thick_l3+thick_l4+(thick_l1+thick_l2))));
id_v3 = cubit.get_last_id("vertex"); print 'v3', id_v3
cubit.cmd('create surface parallelogram vertex '+str(id_v1)+' '+str(id_v2)+' '+str(id_v3));
id_base3 = cubit.get_last_id("surface");
id_base_v3 = cubit.get_last_id("volume");
cmd='imprint volume all'; cubit.cmd(cmd)
cmd='merge volume all'; cubit.cmd(cmd)

#defining/initializing array for collecting topo curves in bordo, pile vol id's in id_torre and pile surf's in id_torre_surf   
bordo=[i for i in range(nt)];  #(array of size 30 from 0 to 29)
id_torre=[i for i in range(nt)];   # torre means tower, here pile
id_torre_surf_orig=[i for i in range(nt)]; 
id_torre_surf=[i for i in range(4*nt)]; #each pile is divided into 4 surfaces after imprint and merge with 4 soil layers

id_layer0=[i for i in range(nt+1)];
id_layer1=[i for i in range(nt+1)];
id_layer2=[i for i in range(nt+1)];
id_layer3=[i for i in range(1)];
#sheet body are volume, though surface-like

for n in range(0,nt,1):
    fid2.write("%04.1f\n" % (xr+dx*n))
    id_torre[n],id_torre_surf_orig[n],id_curv=add_beam(xr+dx*n,hr-n*dh,lr)
    c=cubit.get_relatives("volume",id_torre[n],"curve");
    bordo[n]=c[2];
    cmd='imprint volume '+str(id_base0)+' '+str(id_base1)+' '+str(id_base2)+' '+str(id_base3)+' with '+str(id_torre[n]); cubit.cmd(cmd)
    cmd='merge volume '+str(id_base0)+' '+str(id_base1)+' '+str(id_base2)+' '+str(id_base3)+' '+str(id_torre[n]); cubit.cmd(cmd)
    p=cubit.get_relatives("volume",id_torre[n],"surface");
    id_torre_surf[4*n] = p[0]; id_torre_surf[4*n+1] = p[1]; id_torre_surf[4*n+2] = p[2]; id_torre_surf[4*n+3] = p[3];
    cmd='surf '+str(id_torre_surf[4*n])+' '+str(id_torre_surf[4*n+1])+' '+str(id_torre_surf[4*n+2])+' '+str(id_torre_surf[4*n+3])+' size 1.0';
   

fid3.close();

s=cubit.get_relatives("volume",id_base0,"surface");	
print s
for ns in range(0,nt,1):
    id_layer0[ns]=id_torre_surf[4*ns+2]+2;
    id_layer1[ns]=id_torre_surf[4*ns+1]+6;
    id_layer2[ns]=id_torre_surf[4*ns+0]+10;


id_layer0[nt]=id_layer0[nt-1]+1;
id_layer1[nt]=id_layer1[nt-1]+1;
id_layer2[nt]=id_layer2[nt-1]+1;

s=cubit.get_relatives("volume",id_base3,"surface");
id_layer3[0]=s[-1]

print id_layer0
print id_layer1
print id_layer2
print id_layer3


#MESHING	
for m in range(0,nt+1,1):
    cmd='surf '+str(id_layer0[m])+' size 1.0'; cubit.cmd(cmd)
    cmd='surf '+str(id_layer1[m])+' size 1.0'; cubit.cmd(cmd)
    cmd='surf '+str(id_layer2[m])+' size 1.0'; cubit.cmd(cmd)

cmd='surf '+str(id_layer3[0])+' size 2.0'; cubit.cmd(cmd)
	
cmd='mesh surf all'; cubit.cmd(cmd)




# creating blocks for materials
l=0
if nt!=0:
  l=l+1;
  
# block 1 - all pile elements only below ground level (z<0)
for i in id_torre_surf:
  cmd='block '+str(l)+' face in surf '+str(i); cubit.cmd(cmd)

cubit.cmd('block '+str(l)+' attribute count 4')
cubit.cmd('block '+str(l)+' attribute index 1 '+str(l))     # material 2
cubit.cmd('block '+str(l)+' element type QUAD4')     # material 1
cubit.cmd('block '+str(l)+' attribute index 2 6300 ')  # vp (air 20 C)
cubit.cmd('block '+str(l)+' attribute index 3 3100 ') 
cubit.cmd('block '+str(l)+' attribute index 4 2710 ')  # rho (air 20 C):
#cubit.cmd('Draw Block 1') # to view the defined block 1 entities


#block 2 uppermost layer of soil
l=l+1;
for i in id_layer0:
  cmd='block '+str(l)+' face in surf '+str(i); cubit.cmd(cmd)
 
cubit.cmd('block '+str(l)+' attribute count 4')
cubit.cmd('block '+str(l)+' attribute index 1 '+str(l))     # material 1
cubit.cmd('block '+str(l)+' element type QUAD4')     # material 1
cubit.cmd('block '+str(l)+' attribute index 2 6300 ')  # vp (air 20 C)
cubit.cmd('block '+str(l)+' attribute index 3 3100 ') 
cubit.cmd('block '+str(l)+' attribute index 4 2710 ')  # rho (air 20 C):


#block 3 second layer of soil from top
l=l+1;
for i in id_layer1:
  cmd='block '+str(l)+' face in surf '+str(i); cubit.cmd(cmd)
  
cubit.cmd('block '+str(l)+' attribute count 4')
cubit.cmd('block '+str(l)+' attribute index 1 '+str(l))     # material 2
cubit.cmd('block '+str(l)+' element type QUAD4')     # material 1
cubit.cmd('block '+str(l)+' attribute index 2 6300 ')  # vp (air 20 C)
cubit.cmd('block '+str(l)+' attribute index 3 3100 ') 
cubit.cmd('block '+str(l)+' attribute index 4 2710 ')  # rho (air 20 C):

#block 4 third layer of soil from top
l=l+1;
for i in id_layer2:
  cmd='block '+str(l)+' face in surf '+str(i); cubit.cmd(cmd)
  
cubit.cmd('block '+str(l)+' attribute count 4')
cubit.cmd('block '+str(l)+' attribute index 1 '+str(l))     # material 2
cubit.cmd('block '+str(l)+' element type QUAD4')     # material 1
cubit.cmd('block '+str(l)+' attribute index 2 6300 ')  # vp (air 20 C)
cubit.cmd('block '+str(l)+' attribute index 3 3100 ') 
cubit.cmd('block '+str(l)+' attribute index 4 2710 ')  # rho (air 20 C):

#block 5 fourth layer of soil from top
l=l+1;
cmd='block '+str(l)+' face in surf '+str(id_layer3[0]);cubit.cmd(cmd)
cubit.cmd('block '+str(l)+' attribute count 4')
cubit.cmd('block '+str(l)+' attribute index 1 '+str(l))     # material 2
cubit.cmd('block '+str(l)+' element type QUAD4')     # material 1
cubit.cmd('block '+str(l)+' attribute index 2 6300 ')  # vp (air 20 C)
cubit.cmd('block '+str(l)+' attribute index 3 3100 ') 
cubit.cmd('block '+str(l)+' attribute index 4 2710 ')  # rho (air 20 C):

#block 6 topology of the model i.e. model interface with the air (all curves at the top)
l=l+1;
for n in range(0,nt,1):
    cmd='block '+str(l)+' edge in curve '+str(bordo[n]); cubit.cmd(cmd)
for ns in range(0,nt+1,1):
    c=cubit.get_relatives("surface",id_layer0[ns],"curve");
    if ns==nt:         
      cmd='block '+str(l)+' edge in curve '+str(c[1]); cubit.cmd(cmd)
    else:
      cmd='block '+str(l)+' edge in curve '+str(c[-1]); cubit.cmd(cmd)
cubit.cmd('Block '+str(l)+' name "topo"')

#block 7 absorbing layer at the bottom (curves)
l=l+1;
c=cubit.get_relatives("surface",id_layer3[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[3]); cubit.cmd(cmd)
cubit.cmd('Block '+str(l)+' name "abs_bottom"')

#block 8 absorbing layer at the left (curves)
l=l+1;
c=cubit.get_relatives("surface",id_layer0[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer1[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer2[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer3[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[4]); cubit.cmd(cmd)
cubit.cmd('Block '+str(l)+' name "abs_left"')

#block 9 absorbing layer at the right (curves)
l=l+1;
c=cubit.get_relatives("surface",id_layer0[-1],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer1[-1],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer2[-1],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
c=cubit.get_relatives("surface",id_layer3[0],"curve");
cmd='block '+str(l)+' edge in curve '+str(c[2]); cubit.cmd(cmd)
cubit.cmd('Block '+str(l)+' name "abs_right"')


cubit.cmd('set info on')
cubit.cmd('set echo on')
os.system('mkdir -p d1s5h2/')
sem_mesh=cubit2specfem2d_abs4.mesh()
sem_mesh.write('d1s5h2/')
