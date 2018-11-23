%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is to find systole, diastole using Fridericia(2003), Ann Noninvasive Electrocardiol 8:343-351.
% For results on "effects of spikes and their timining on CCD" (systole vs.
% diastole)
% From each run, the calculation will give one systole using mean IBI, then
% diastole of each IBI is IBI-systole
% -- written by Kayeon Kim

% Input = inter beat interval (in second here)
% Output = 1. systole_ms_f (systole in ms),  2. diastole_ms_v (diastole in
% ms)

IBI_s = [];  % insert input here= inter beat interval

RRmu_s = mean(IBI_s);  % in second
RRmu_forcompute = RRmu_s*100; % has to be in 1/100 seconds
systole_1_100s = 8.22*(RRmu_forcompute.^(1/3));
systole_s = systole_1_100s/100; % systole in second
systole_ms_f = systole_s*1e3; % systole in ms
    
IBIms = (IBI/4);
for inum = 1:length(IBIms)
    diastole_ms_v(inum) = IBIms(inum)-systole_ms_f;
end

