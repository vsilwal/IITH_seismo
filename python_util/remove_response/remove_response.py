import obspy
import os
from obspy.signal.invsim import paz_to_freq_resp, corn_freq_2_paz


# See here for description of RESP format
# https://ds.iris.edu/ds/nodes/dmc/data/formats/resp/
ddir = 'EQ_DATA'
fname = 'Hindukush_October_EQ.TEST__014'

filename = os.path.join(ddir,fname)

# Read seisan file
st = obspy.read(filename)

# Select Stations of New Delhi (NDI)
st = st[8:11]
st.plot()

# See Here description of obspy remove response function
# https://docs.obspy.org/packages/autogen/obspy.core.stream.Stream.simulate.html
paz_sts2 = {
    'poles': [-0.037 - 0.037j, -0.037 + 0.037j, -10.95, -98.44 - 442.8j, 
              -98.44 + 442.8j, -556.8 - 60.05j, -556.8 + 60.05j, 1391, 
              -4936 - 4713j, -4936 + 4713j, -6227, -6909 - 9208j, 
              -6909 + 9208j, -255.097],
    'zeros': [0, 0, -10.75, -294.6, -555.1, -683.9 - 175.5j, 
              -683.9 + 175.5j, -5907 - 3411j, -5907 + 3411j],
    'gain': 235222000000000000.0, # this is A0
    'sensitivity': 550660500.0}   # this is product of ALL the gains

paz_1hz = corn_freq_2_paz(1.0, damp=0.707)  # 1Hz instrument (standard)
paz_1hz['sensitivity'] = 1.0

st.simulate(paz_remove=paz_sts2, paz_simulate=paz_1hz)
st.plot()

# Save as SAC
st[0].write('NDI.Z.sac')
st[0].write('NDI.N.sac')
st[0].write('NDI.E.sac')

# Visualize Filtered waveforms
temp = st.copy()
temp.filter('lowpass',freq=0.1,corners=4, zerophase=False)
temp.plot()
