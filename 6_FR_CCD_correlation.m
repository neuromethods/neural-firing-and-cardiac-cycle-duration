% This script compute pearson correlation coefficient between CCD and firing rate
% -- written by Kayeon Kim

% Inputs: 
% Rpeak times, spike times, all in ms and fs=1kHz

% Outputs:
% Spikenum, spike number for each CCD 
% Spikes_per_s, Firing rate for each CCD

RpeakAll_ms = [];
IBI_ms = diff(RpeakAll_ms);
IBI_s = IBI_ms/1e3;

SpikeTimes  = []; % 1khz, ms, same format as wave_clus.m output 



for iTrial = 1:length(RpeakAll_ms)
    % find spikes within each CCD
    FindSpikenum = [];
    FindSpikenum = length(find(SpikeTimes>=RpeakAll_ms(iTrial) & SpikeTimes<RpeakAll_ms(iTrial)+IBI_ms(iTrial)));
    
    Spikenum(iTrial) = FindSpikenum;
    Spikes_per_s(iTrial) = FindSpikenum/IBI_s(iTrial);
end
                

[r,p] = corr(Spikes_per_s',IBI_s','type','Pearson');










