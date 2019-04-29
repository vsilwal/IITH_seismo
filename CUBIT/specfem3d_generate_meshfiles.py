#!/usr/bin/env python

import cubit
import cubit2specfem3d

import os
import sys

#Domain parameters
Lx = 250;
Ly = 200;
depth = 50;
Cx = Lx/2
Cy = Ly/2
mesh_size = 2.5
cubit.cmd('brick x '+str(Lx)+' y '+str(Ly)+' z '+str(depth))
cubit.cmd('volume 1 move x '+str(Lx/2)+' y '+str(Ly/2)+' z '+str(-depth/2))

id_intern = cubit.get_last_id("volume")
s = cubit.get_relatives("volume",id_intern,"surface");
print s
side_xmin=[];side_xmax=[];side_ymin=[];side_ymax=[];side_zmin=[]
side_xmax.append(s[5]);side_xmin.append(s[3]);
side_ymax.append(s[4]);side_ymin.append(s[2]);side_zmin.append(s[1]);
surf_id=s[0]

#meshing
cubit.cmd('volume all size '+str(mesh_size));
cubit.cmd('mesh volume all');

# Defining Blocks

b = 1;
cubit.cmd('block '+str(b)+' hex in vol 1')
cubit.cmd('block '+str(b)+' name "elastic 1" ')       # elastic material region
cubit.cmd('block '+str(b)+' attribute count 6')
cubit.cmd('block '+str(b)+' attribute index 1 '+str(b))     # material 1
cubit.cmd('block '+str(b)+' attribute index 2 2800 ')  # vp (air 20 C)
cubit.cmd('block '+str(b)+' attribute index 3 1400 ')	   # vs
cubit.cmd('block '+str(b)+' attribute index 4 1800 ')  # rho (air 20 C):
cubit.cmd('block '+str(b)+' attribute index 5 70.0')  # Qmu
cubit.cmd('block '+str(b)+' attribute index 6 0 ')	# anisotropy_flag

b=b+1;
for i in side_xmin:
  cmd='block '+str(b)+' face in surface '+str(i); cubit.cmd(cmd)
cubit.cmd('Block '+str(b)+' name "face_abs_xmin"')

b=b+1;
for i in side_ymin:
  cmd='block '+str(b)+' face in surface '+str(i); cubit.cmd(cmd)
cubit.cmd('Block '+str(b)+' name "face_abs_ymin"')

b=b+1;
for i in side_xmax:
    cmd='block '+str(b)+' face in surface '+str(i); cubit.cmd(cmd)
cubit.cmd('Block '+str(b)+' name "face_abs_xmax"')

b=b+1;
for i in side_ymax:
  cmd='block '+str(b)+' face in surface '+str(i); cubit.cmd(cmd)
cubit.cmd('Block '+str(b)+' name "face_abs_ymax"')

b=b+1;
for i in side_zmin:
  cmd='block '+str(b)+' face in surface '+str(i); cubit.cmd(cmd)
cubit.cmd('Block '+str(b)+' name "face_abs_bottom"')

b=b+1;
cubit.cmd('Block '+str(b)+' face in surface '+str(s[0]))
cubit.cmd('Block '+str(b)+' name "face_topo"')

print '##total number of hex: ',cubit.get_hex_count(),' ##'

os.system('mkdir -p MESH')
#### Export to SESAME format using cubit2specfem3d.py of GEOCUBIT

cubit2specfem3d.export2SESAME('MESH')
