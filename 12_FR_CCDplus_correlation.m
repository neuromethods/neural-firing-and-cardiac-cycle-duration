% This code runs to compute pearson correlation between firing rate and CCD+10..20..30.. (up to the point that you'd like to see if data length allows)
% and then normlize the correlation coefficient to the current CCD.

% For this analysis, I recomment using data length >=5minute 
% The inputs are the same as when computing correlation betweein firing
% rate and CCD (6_FR_CCD_correlation.m)


% inputs: Rpeak times, spike times, all in ms and fs=1kHz

% Outputs:
% Spikes_per_s,  Firing rate for each CCD
% correlation coefficient between Spikes_per_s and CCD+(e.g CCD+10..12..etc)

RpeakAll_ms = [];
IBI_ms = diff(RpeakAll_ms);
IBI_s = IBI_ms/1e3;

SpikeTimes = [];  % 1kHz, ms, same format as wave_clus.m output

% Step 1. derive firing rate using Rpeak times and spike times
for iTrial = 1:length(RpeakAll_ms)
    % find spikes within each CCD
    FindSpikenum = [];
    FindSpikenum = length(find(SpikeTimes>=RpeakAll_ms(iTrial) & SpikeTimes<RpeakAll_ms(iTrial)+IBI_ms(iTrial)));
    
    Spikenum(iTrial) = FindSpikenum;
    Spikes_per_s(iTrial) = FindSpikenum/IBI_s(iTrial);
end

% correlation between firing rate and current CCD (CCD+0)
[r_CCD0,p] = corr(Spikes_per_s',IBI_s','type','pearson');


% Step 2. construct firing rate (use the 'Spikes_per_s') and CCD pairs up to CCD+10 or ..+20..+30
CCDplus = [12]; % change input as you wish

for iccdadd = 1:CCDplus
    ccdadd{iccdadd}.IBI_s = IBI_s(1,1+iccdadd:end);
    ccdadd{iccdadd}.Spikes_per_s = Spikes_per_s(1,1:end-iccdadd);
    
    [r,p] = corr(ccdadd{iccdadd}.IBI_s',ccdadd{iccdadd}.Spikes_per_s','type','pearson');
    
    corr_r(iccdadd) = r;
    corr_p(iccdadd) = p;
end
   
dataall = [];
dataall = [dataall; r_CCD0 corr_r];  % attach ccd0: ccd+12 together

x=13;  % CCD+

% normalize the correlation coefficient to the coefficient between firing rate and current CCD (CCD0)
% so the y-axis always starts from 1 (=firing rate and CCD0 correlation)
data_normalized = [r_CCD0/r_CCD0 corr_r/r_CCD0];  % ccd0: ccd+10


figure;
for icell=1:4   
    plot(1:4:x,data_normalized(1,1:4:13),'k.-','color',[0.6 0.75 0.5],'MarkerSize',15,'lineWidth',1); hold on; 
end
set(gca,'xlim',[0 x+1],'xtick',1:4:x,'xticklabel',0:4:x-1,'ylim',[-1 2],'box','off');
plot([0 x+1],[1 1],'k-','lineWidth',0.3);    
plot([0 x+1],[0 0],'k-','lineWidth',0.3);    
set(gcf,'color','w');

ylabel('Normalized correlation coefficient between firing and CCD at CCD0')
xlabel('CCD+')







    