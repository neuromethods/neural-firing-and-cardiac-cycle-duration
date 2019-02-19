# neural-firing-and-cardiac-cycle-duration
Implementations of the methods applied in: __Kim, Ladenbauer, Babo-Rebelo, Buot, Lehongre, Adam, Hasboun, Lambrecq, Navarro, Ostojic, Tallon-Baudry,__ ___Resting-state neural firing rate is linked to cardiac cycle duration in the human cingulate and parahippocampal cortices,___ __Journal of Neuroscience 2019__ <!-- [bioRxiv preprint](https://www.biorxiv.org/content/early/2018/02/07/261016) -->

The code contains Matlab scripts for the analysis of neural spike data (scripts 1,2), detection of R-peaks in ECG data (script 3) and joint analyses of spiking and R-peaks (scripts 4-12), all tested using Matlab 2013a.
1. Adaptive_filtering.m (requires removePLI.m)  
filtering of raw time series data from each micro-electrode channel (prior to spike sorting) 
2. Make_spike_density.m  
generates spike density from spike times using a Gaussian kernel; adopts data format from wave_clus.m which performs sorting of waveforms and extraction of spike times (not included here, but freely available for download, cf. Quian Quiroga, 2004)
3. Rpeak_detection.m  
extracts R-peak from ECG trace
4. Make_Rpeak_aligned_density_fr.m  
using the outputs from #2 (spike times, spike density) and #3 (R-peak times), this script aligns the spike density to the R-peaks and computes the firing rate (spikes/s) for each cardiac cycle
5. Make_CCD_timeseries.m  
generates an interpolated time-series of cardiac cycle duration (CCD) from R-peak times
6. FR_CCD_correlation.m	 
calculation of Pearson correlation between firing rate (spikes/s) and CCD
7. Make_CCD_surrogates_forstats  (requires getRandomStartingPoint.m)  
generates a surrogate CCD distribution used for statistical significance testing to derive Monte Carlo-P values
8. Zsum_clustering_transient_density_changes_forstats.m  
performs significance testing with respect to transient increases or decreases in firing rate locked to R-peak
9. Coherence_density_CCD.m (requires getdata_fieldtrip.m)  
computes coherence between spike density and CCD time series 
10. FanoFactor.m  
calculation of Fano factor
11.	Find_sys_dias.m  
extracts systole and diastole
12. FR_CCDplus_correlation.m
calculation of Pearson correlation between firing rate (spikes/s) and CCD extended over several cycles

Some of the Matlab scripts utilize functions from the freely available [Fieldtrip package](http://www.fieldtriptoolbox.org/download#download_the_fieldtrip_toolbox) (version 20130926)

In addition, an efficient Python implementation for phase response analysis between two generic event time series is included (phase_response_analysis.py), tested using Python 2.7.  
Required libraries: numpy, numba, matplotlib. 
These libraries can be conveniently obtained, for example, via a recent [Anaconda distribution](https://www.anaconda.com/download/)

For questions please contact Kayeon Kim (Matlab code) or Josef Ladenbauer (Python code)
