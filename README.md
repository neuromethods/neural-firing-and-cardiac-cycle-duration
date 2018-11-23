# neural-firing-and-cardiac-cycle-duration
Analyses for the relationship between spontaneous neural firing and cardiac cycle duration

Implementations of the methods applied in: __Kim, Ladenbauer, Babo-Rebelo, Buot, Lehongre, Adam, Hasboun, Lambrecq, Navarro, Ostojic, Tallon-Baudry,__ ___Resting-state neural firing rate is linked to cardiac cycle duration in the human cingulate and parahippocampal cortices___ (under review) <!-- [bioRxiv preprint](https://www.biorxiv.org/content/early/2018/02/07/261016) -->

The code contains Matlab scripts for the analysis of neural spike data (scripts 1,2), detection of R-peaks in ECG data (script 3) and joint analyses of spiking and R-peaks (scripts 4-11), all tested using Matlab 2013a.  
In addition, an efficient Python implementation for phase response analysis between two generic event time series is included (phase_response_analysis.py), tested using Python 2.7. 

Some of the Matlab scripts utilize functions from the freely available [Fieldtrip package](http://www.fieldtriptoolbox.org/download#download_the_fieldtrip_toolbox) (version 20130926)

Required libraries for Python code: numpy, numba, matplotlib. 
These libraries can be conveniently obtained, for example, via a recent [Anaconda distribution](https://www.anaconda.com/download/)

For questions please contact Kayeon Kim or Josef Ladenbauer
