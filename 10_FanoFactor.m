% This script computes for fano factor, var(spike count)/mean (spike count)
% The analysis is computed over 1s segemented window as a trial
% -- written by Kayeon Kim

% Inputs: the r-peak and spike times data that are exactly time-aligned
% Rpeak_times (ms), 1kHz
% Spike_times (ms), 1kHz

% Output: 
% Fano Factor


Rpeak_times = [];

TW = [1000];  % Time window= 1second segment, unit in ms, you can chnage the time window to compare results


Trial_1s = [];  % make 1s segment trial from the data

% Start segment from the 1st Rpeak used in the other analysis until one
% r-peak before to the last r-peak to make sure that all the r-peaks
% used here are not outside the valid data range.
Valid_rpeak = [];
Valid_rpeak = Rpeak_times(1):TW:Rpeak_times(end-1);
Trial_1s = [Trial_1s round(Valid_rpeak)];

% find spikes count within each trial (one trial = one 1s segment)
SpikeTimes = [];
for iTrial = 1:length(Trial_1s)-1
    SpikeCount(iTrial) = length(find(SpikeTimes>=Trial_1s(iTrial) & SpikeTimes<Trial_1s(iTrial+1))); 
end

FanoFactor = var(SpikeCount)/mean(SpikeCount);  % compute fano








    
    
    