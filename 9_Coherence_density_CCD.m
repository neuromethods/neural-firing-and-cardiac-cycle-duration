%% frequency, coherence analysis using fieldtrip "ft_connectivityanalysis.m"
% Sampling frequency: 1kHz,  unit: ms
% function needed: getdata_fieldtrip.m
% -- written by Kayeon Kim

% Inputs: 
% 1.filename, 2.electrode name (elect_name) to make the data format compatible for
% fieldtrip function
% 3. interp_IBIms (interpolated CCD time series), 1dim 
% 4. spike density, the same starting point of the signal as the
% interpolated IBI signal, 1dim

% Outputs: 
%1.freqspec (struct with frequency spectrum)
%2.Coherence

% Inputs
filename = ''; % patient's names, e.g. 2135
elect_name = ''; % electrode name, e.g. mCing
interp_IBIms = []; % interpolated CCD time series, 1D
spikedensity = [];  % spike density, 1D

% example input
% filename = '2135'; % patient's names, e.g. 2135
% elect_name = 'mCing'; % electrode name, e.g. mCing
% interp_IBIms = 1 dimension data ; % interpolated CCD time series, 1D
% spikedensity = 1 dimension data;  % spike density, 1D

% get data as fieldtrip compatible format, setpath fieldtrip, recommendedn
% version: "fieldtrip_20130926"

[data] = getdata_fieldtrip(interp_IBIms,spikedensity,filename);

        
%% computing fourier, insert inputs according to your data length/window
cfgWelch = [];
cfgWelch.lengthWindow = 60; %seconds (1/60= 0.017Hz)
cfgWelch.overlap = 6;% propotion i.e 1/6
len = data.fsample*cfgWelch.lengthWindow; % length of subtrials cfg.length s in samples
data.sampleinfo(1,:) = [1 size(interp_IBIms,2)];

cfg = [];  % put trial info
cfg.trl(:,1) = data.sampleinfo(1):len:data.sampleinfo(2)-len+1;
cfg.trl(:,2) = data.sampleinfo(1)+len-1:len:data.sampleinfo(2);
cfg.trl(:,3) = 0;
data_trials = ft_redefinetrial(cfg,data);  % conf file making with trials

cfg = [];
cfg.method = 'mtmfft';
cfg.taper = 'hanning';
cfg.output = 'powandcsd';
cfg.pad = round(length(data.time{1})/data.fsample);  % spectral interpolation
%     cfg.pad = ceil(max(cellfun(@numel, data.time)/data.fsample));

%     number, 'nextpow2', or 'maxperlen' (default), length
%                     in seconds to which the data can be padded out. The
%                     padding will determine your spectral resolution. If you
%                     want to compare spectra from data pieces of different
%                     lengths, you should use the same cfg.pad for both, in
%                     order to spectrally interpolate them to the same
%                     spectral resolution.  The new option 'nextpow2' rounds
%                     the maximum trial length up to the next power of 2.  By
%                     using that amount of padding, the FFT can be computed
%                     more efficiently in case 'maxperlen' has a large prime
%                     factor sum.
cfg.foilim = [1/cfgWelch.lengthWindow 1]; % 0 - 6 cpm
cfg.keeptrials = 'yes';
cfg.channel    = {'RRseries' 'Spikeseries'};

freqspec = ft_freqanalysis(cfg,data_trials);  %frequency spectrum


% coherence analysis 
cfg            = [];
cfg.method     = 'coh';  
coherence = [];
coherence = ft_connectivityanalysis(cfg, freqspec);


