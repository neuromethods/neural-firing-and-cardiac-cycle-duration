%% An example code of transforming r-peak times into an interpolated time-series 
%% of heart rate variability
%% Related to Results on coherence between spike density and HRV time-series
% -- written by Kayeon Kim

% unit in millisecond, 1kHz sampling rate
% inputs: 
% 1. r-peak times (e.g. successive r-peaks during 5-minute resting state)
% 2. Inter beat interval (IBI) of the r-peaks

% outputs:
% 1. interp_IBIms :  interpolated HRV time series
% 2. timinig_IBIms : time points of interpolation (mid-point of two
% R-peaks), This value is needed to plot and checke the interpolated
% signal

function [interp_IBIms,timing_IBIms] = Make_CCD_timeseries_interpolation(inter_beat_interval,Rpeak_times)


IBIms = inter_beat_interval;
timing_Rpeaks = Rpeak_times; 

%align IBIs at the mid-point of two R-peaks
timing_IBIms = [];

for i=1:length(IBIms)
    if i == 1
        timing_IBIms(i) = timing_Rpeaks(i)+IBIms(i)/2;  %original
    else
        timing_IBIms(i) = timing_IBIms(i-1)+IBIms(i-1)/2+IBIms(i)/2;
    end
end

%conduct interpolation
t = timing_IBIms;
y = IBIms;
t2 = timing_IBIms(1):1:timing_IBIms(end);  
interp_IBIms = interp1(t,y,t2,'spline'); 


figure; 
subplot(2,2,1);
plot(timing_IBIms(1):timing_IBIms(19),interp_IBIms(1:length(timing_IBIms(1):timing_IBIms(19))),'r');
ylabel('IBI (ms)');
xlabel('r-peak times (ms)');
legend('r-peak times','IBI timeseries (interp)');










