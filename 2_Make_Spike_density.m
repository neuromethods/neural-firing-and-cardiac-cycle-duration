% This converts spike times (from wave_clus.m) to spike density using Gaussian kernel SD 20ms.
% It's a simple fuction that requires one dimension of spike times data (use 
% "spike times" output from wave_clus.m sorting program
% units in ms and fs =1kHz (both spike times and datalength input)
% -- written by Kayeon Kim

% Inputs: 
% 1. Datalength, length of the data (e.g. length(spike times(1):spike times(end))
% 2. data, 1d array contatining spike times

% inputs
Datalength = round(size(data,2));  % data array example= 1x350000, need data length for density function, 
SpikeTimes = data;


% get Gaussian kernel
dt = 1;
sigma = 20;   %%% gaussian kernel standar deviation, ms
x=-sigma*5:dt:sigma*5;  %%% window size 
s = exp(-(x/sigma).^2/2)/(sigma*sqrt(2*pi));

Gaussk = s*1e3;   %%% Firing rate 


% spike and kernel convolution to get spike density
base = [];  base= zeros(1,Datalength);
base(round(SpikeTimes)) = 1;
iStart = [];  fr = [];
iStart = find(Gaussk==max(Gaussk));
fr = conv(base,Gaussk); % convolve spike times and gaussian kernel made
fr = fr(iStart:iStart+length(base)-1);

SpikeDensity = fr;
                                
 
                

