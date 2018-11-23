% This script makes 1. r-peak aligned spike density and 2. resample the 
% density to the minimum IBI out of the total IBI distribution. So that all
% trials (one trial = one CCD) have the same data length for each cell. 
% -- written by Kayeon Kim

% Inputs: 
% 1. R-peak times and the IBI in ms extracted from the previous analysis,  "3_Rpeak_detection.m". 
% 2. Spike density that was also made from the previous analysis, "2_Make_spike_density.m". 
% 3. Spike times that was extracted using wave_clus.m
% make sure that all data are sampled in 1kHz (both spike times and r-peak
% times)

% Outputs: 
% 1. Spike density aligned to each r-peak (original, resampled)
% 2. number of spikes in each CCD
% 3. Firing rate (spikes/s) of each CCD


% Step 1. get density, firing rate, number of spikes from one r-peak to the next r-peak for each CCD (One CCD = one trial)

RpeakNum_ms = []; 
IBI_ms = diff(RpeakNum_ms); 
SpikeTimes = [];  % spike times from wave_clus.m output (make sure that the fs is 1kHz)
Spike_dens = [];  % spike density converted from the spike times

Min_IBI = min(IBI_ms); % This will be used for resampling the r-peak alinged density to the minimum IBI

Spikenum = [];
FR_spikes_s = [];
SpikeDens = [];
SpikeT = [];

Rpeak_aligned_SpikeDensity.DensityOriginal = []; 
Rpeak_aligned_SpikeDensity.DensityResampled = [];

for itrial = 1:length(IBI_ms)  % one trial = one cardiac cycle duration (CCD)
    % find spikes belonging between the current R-peak to the start of the next r-peak (one CCD)
    SpikenumPre = [];
    SpikenumPre = length(find(SpikeTimes>=RpeakNum_ms(itrial) & SpikeTimes<RpeakNum_ms(itrial)+IBI_ms(itrial)));
    
    % convert the spikes within the CCD into firing rate (spikes/s)
    Spikenum = [Spikenum; SpikenumPre];
    FR_spikes_s = [FR_spikes_s; SpikenumPre/(IBI_ms(itrial)/1e3)];
    
    % one long spike density timeseries that was previously made is organized into trial format, alinged to each r-peak
    Rpeak_aligned_SpikeDensity.DensityOriginal = [Rpeak_aligned_SpikeDensity.DensityOriginal; SpikeInfoCell.Density(RpeakNum_ms(itrial):RpeakNum_ms(itrial)+IBI_ms(itrial))];
    
    
    % Step 2. SpikeDensity aligned to each r-peak is resampled to the minimum IBI duration
    a = [];  x = [];  xp = [];  y = [];
    a = Rpeak_aligned_SpikeDensity{itrial}.DensityOriginal;
    x = 1:numel(a);
    xp = linspace(x(1),x(end),Min_IBI);
    y = interp1(x,a,xp);
    
    % Final product
    Rpeak_aligned_SpikeDensity.DensityResampled = [Rpeak_aligned_SpikeDensity.DensityResampled; y];    
end

Density = Rpeak_aligned_SpikeDensity; % output 1
Spikenum = Spikenum; % output 2
FR_spikes_s = FR_spikes_s;% output 3






