
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes filtering, to remove line interference, noise harmonics
% Simply, input 1 dimension data recorded and use the function removePLI.m 
% -- written by Kayeon Kim

%% PLI removal, adaptive filtering
% parameter setting depends on the signal sampling rate. parameters within
% for recommended ranges, refer to (Keshtkaran & Yang., 2014, Table2)

% Input: data, 1dim
% Ouput: datafiltered, 1dim
data = [];  % insert data input


x = data;  % data
fs = 32e3;  % sampling frequency
M = 15;  %   M, number of harmonics to  remove
B = [50 0.05 5];  % when removing 1 harmonic
P = [0.1 4 8];  W = 2;
datafiltered = removePLI(x,fs,M,B,P,W);
     
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
%%% Sample code
% x = data;  % data
% fs = 32e3;  % sampling frequency
% M = 60;  %   M, number of harmonics to  remove
% % M = 1;
% B = [50 0.05 5];  % when removing 1 harmonic
% % B = [50 0.2 1];   % 0.001 if harmonics are up to 100th order
% %   B, contains three elements [B0,Binf,Bst]: 
% %	- B0, Initial notch bandwidth of the frequency estimator
% %	- Binf, Asymptotic notch bandwidth of the frequency estimator
% %	- Bst, Rate of convergence to 95% of the asymptotic bandwidth Binf
% % P = [0.1 4 1];
% P = [0.1 4 8];
% % P = [0.001 2 5];  % when removing 1 harmonic
% %   P, contains three elements [P0,Pinf,Pst]: 
% %	- P0, Initial settling time of the frequency estimator
% %	- Pinf, Asymptotic settling time of the frequency estimator
% %	- Pst, Rate of convergence to 95% of the asymptotic settling time
% W = 2;  %	W, Settling time of the amplitude and phase estimator
% % W = 3;  % when removing 1 harmonic
% datafiltered = removePLI(x,fs,M,B,P,W);
% 


