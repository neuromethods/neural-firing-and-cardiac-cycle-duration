% This script computes CCD surrogates by shuffling the original CCD.
% Run this script as many times as the user wants to establish a certain
% number of surrogates. In the paper, n=10,000 surrogates were
% used, which means this function was run for 10,000 times. 
% -- written by Kayeon Kim

% Inputs:
% R-peak times, CCD (cardiac cycle duration), in millisecond
RpeakTimes = []; % ms  

% recommend to suppress the first and last r-peaks in the analysis to
% provide enough space in the beginning and ending point of the data during surrogate
% making process
First_suppressed_rpeak = RpeakTimes(1);
Last_suppressed_rpeak = RpeakTimes(end);
RpeakTimes_new = RpeakTimes(2:end-1);  
CCD = diff(RpeakTimes_new);

% Outputs:
% Rpeaks_surr_ms, surrogate r-peaks from one run

% Make Rpeak surrogate by cumsum of all CCD surrogate
% Find those rpeaks within the range. Then update the remaining.

Rpeak_surr_ms = []; % output of this run

% shuffle cardiac cycle duration (CCD), this original CCD will be used for making surrogate CCD
CCDTable(:,1) = 1:length(CCD);
CCDTable(:,2) = CCD;
CCDTable(:,3) = randperm(length(CCD));
CCDTableShuffled = sortrows(CCDTable,3);
CCDTableShuffled_Final = CCDTableShuffled(:,2);
Updated_CCD_surr = CCDTableShuffled_Final;

% total length of CCD
SummedCCD = [];
SummedCCD = cumsum(CCDTableShuffled_Final);

% get a random starting point of the surrogate CCD
[RndVector] = get_RandomStartingPoint(CCD);%% input, output in ms

% Pick one time from the the randomized matrix, ms
Make_PeakStartRand_ms = zeros(1);
Make_PeakStartRand_ms = RndVector(1);

% first Rpeak of the surrogate CCD
Get_RpeakStart_ms = [];
Get_RpeakStart_ms = First_suppressed_rpeak+Make_PeakStartRand_ms;   %%% first Rpeak of the first block

% updating/shifting cumulated CCD according to the start point
Updated_summedCCD = Get_RpeakStart_ms+SummedCCD;

% find the Rpeaks that are within the data length to make sure that allnew r-peaks are within the same data length as the original
Find_WithinDatalength = [];
Find_WithinDatalength = find(Updated_summedCCD<Last_suppressed_rpeak);

PreRpeak = [];
PreRpeak = Updated_summedCCD(Find_WithinDatalength);

% stack the start of the first r-peak from the previous step with rest of the surrogate r-peaks that are made
Rpeak_surr_ms = [Get_RpeakStart_ms; PreRpeak];


% plot the results
figure; 
subplot(2,1,1);
plot(RpeakTimes_new(1:20),1,'ro'); hold on;  % original r-peaks  
plot(Rpeak_surr_ms(1:20),1,'ko');  % surrogate r-peaks
xlabel('Rpeak times (ms)');

subplot(2,2,3);  % to visualize that the original and shuffled CCD are identical
hist(CCD,50); 
h = findobj(gca,'Type','patch');  set(h,'FaceColor',[1 0 0]);
title('original');
xlabel('CCD (ms)'); ylabel('No. of CCD');
subplot(2,2,4);
hist(CCDTableShuffled_Final,50); 
h = findobj(gca,'Type','patch');  set(h,'FaceColor',[0 0 0]);
title('shuffled');
xlabel('CCD (ms)');



