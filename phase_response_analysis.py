# -*- coding: utf-8 -*-
"""
Calculation of phase response histogram (phase response curve; PRC) for two event
time series, cf. Kim et al. 2018 "Resting-state neural firing rate is linked to 
cardiac cycle duration in the human cingulate and parahippocampal cortices"
Fig. 5 and Methods section "Phase response analysis" (cf. also Blot et al. 2016, 
J. Physiol.) -- written by Josef Ladenbauer 
"""
import numpy as np
import matplotlib.pyplot as plt
import numba

# 1) generation of synthetic example data:

#event times 1: Poisson process with rate 1/mean_IEI 
#(spike time series in Kim et al. 2018)
mean_IEI = 200.0  #ms
IEIs = np.random.exponential(mean_IEI, 2000)
eventtimes1 = np.cumsum(IEIs)

#event times 2: Gaussian distributed inter-event intervals (IEI)
#(heart beat time series in Kim et al. 2018)
IEIs = 800.0 + 50.0*np.random.randn(500)  
IEIs = IEIs[IEIs>0]
eventtimes2 = np.cumsum(IEIs)

#event times 2a: same as event times 2, but with phase-dependent effect  
eventtimes2a = eventtimes2.copy()
for i_s, ts in enumerate(eventtimes1):
    if ts<eventtimes2a[-1]:
        j = 0
        while ts>eventtimes2a[j+1]:  
        # determine the closest previous event time of series 2
            j += 1
        if ts-eventtimes2a[j]<400:
            eventtimes2a[j+1] -= 20
        else:
            eventtimes2a[j+1] += 20


# main function for computation of phase response histogram/curve:
            
@numba.njit  # for low-level machine acceleration
def compute_PRC(event_times1, event_times2, IEI2, left_bin_edges): 
    # 1) for each event time of series 1 in an IEI of series 2 collect
    # the time to next event time of series 2 as a function of the time
    # from the last event of series 2
    idx = (event_times1>=event_times2[0]) & (event_times1<=event_times2[-1])
    event_times1 = event_times1[idx]
    Tback_observed = np.zeros_like(event_times1)
    Tforw_observed = np.zeros_like(event_times1)
    for i_s, ts in enumerate(event_times1):
        j = 0
        while ts>event_times2[j+1]:  
        # determine the closest previous event time of series 2
            j += 1
        Tback_observed[i_s] = ts - event_times2[j]
        Tforw_observed[i_s] = event_times2[j+1] - ts
    
    # 2) calculate Tforw means, expected from the IEI2 distribution, as a
    # function of Tback for values from Tback array
    Tforw_expected = np.zeros_like(Tback_observed)
    for i_tb, tb in enumerate(Tback_observed):  
        IEI_tmp = IEI2[IEI2>=tb]
        Tforw_expected[i_tb] = np.mean(IEI_tmp) - tb
  
    PRC_values = Tforw_observed-Tforw_expected
    
    # 3) bin Tback values and sum PRC values for each bin 
    n_bins = len(left_bin_edges)
    PRC_sum_per_bin = np.zeros_like(left_bin_edges)
    PRC_cnt_per_bin = np.zeros_like(left_bin_edges)
    for i_tb, tb in enumerate(Tback_observed):
        for i_bin in range(n_bins-1):
            if tb>=left_bin_edges[i_bin] and tb<=left_bin_edges[i_bin+1]:
                PRC_cnt_per_bin[i_bin] += 1
                PRC_sum_per_bin[i_bin] += PRC_values[i_tb]
        else: #last bin
            PRC_cnt_per_bin[n_bins-1] += 1
            PRC_sum_per_bin[n_bins-1] += PRC_values[i_tb]
    # for bins that do not contain PRC values:
    PRC_sum_per_bin[PRC_sum_per_bin==0] = np.nan  
    PRC_cnt_per_bin[PRC_cnt_per_bin==0] = np.nan 
    return Tback_observed, PRC_values, PRC_sum_per_bin, PRC_cnt_per_bin


binwidth = 100.0  #ms

# compute phase response histogram (eventtimes1 --> eventtimes2)
IEIs = np.diff(eventtimes2)
left_bin_edges = np.arange(0.0, np.max(IEIs)-0.95*binwidth, binwidth)
Tback, PRC_vals, PRC_sum_per_bin, PRC_cnt_per_bin = \
    compute_PRC(eventtimes1, eventtimes2, IEIs, left_bin_edges)
PRC_means = PRC_sum_per_bin/PRC_cnt_per_bin

# plotting:
plt.figure()
plt.subplot(121)
plt.title(r'PRC: event times 1 $\rightarrow$ event times 2', fontsize=14)
plt.plot(Tback, PRC_vals, 'o', mew=0, mfc='gray', alpha=0.6, markersize=4)
plt.bar(left_bin_edges, PRC_means, width=binwidth, color='g', alpha=0.8, align='edge')
plt.xlabel('time since previous event (ms)', fontsize=14) # of series 2
plt.ylabel('change of inter-event interval duration (ms)', fontsize=14) # of series 2
plt.ylim([-350, 350])

# compute phase response histogram (eventtimes1 --> eventtimes2a)
IEIs = np.diff(eventtimes2a)
left_bin_edges = np.arange(0.0, np.max(IEIs)-0.95*binwidth, binwidth)
Tback, PRC_vals, PRC_sum_per_bin, PRC_cnt_per_bin = \
    compute_PRC(eventtimes1, eventtimes2a, IEIs, left_bin_edges)
PRC_means = PRC_sum_per_bin/PRC_cnt_per_bin

# plotting:
plt.subplot(122)
plt.title(r'PRC: event times 1 $\rightarrow$ event times 2a', fontsize=14)
plt.plot(Tback, PRC_vals, 'o', mew=0, mfc='gray', alpha=0.6, markersize=4)
plt.bar(left_bin_edges, PRC_means, width=binwidth, color='g', alpha=0.8, align='edge')
plt.xlabel('time since previous event (ms)', fontsize=14) # of series 2a
plt.ylabel('change of inter-event interval duration (ms)', fontsize=14) # of series 2a
plt.ylim([-350, 350])