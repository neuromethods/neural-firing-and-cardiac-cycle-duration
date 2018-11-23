%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script runs for R-Peak detection,
%%% The analysis steps are 
%%% Step 1. make QRS complex template, 
%%% Step 2. template matched r-peaks are chosen
%%% manual detection and visual checking are needed
%%% Eveything is in sample here
% -- written by Kayeon Kim

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step1: make r-peak template

ecg = [];  % input data, 1 x dim array ECG trace 

% - the user has the opportunity to change the polarity of
% the ecg data. This is necessary when the r-peaks have
% negative polarity since then the amplitude threshold would
% not be able to pick r-peaks.
% - where the user is asked if the template has the right
% polarity, the question is changed from '... i.e. do r- and
% t-peaks point up?' into 'do r- and t-peaks point in the
% original direction?'. This is since r- and t-peaks are not
% necessarily positive (although this is most often the
% case). What is important is that the template fits the
%     polarity of the raw ecg data.
%     - originallty, the template could not be computed based on
%     a single peak detected by the user. This is chanfged in
%     this function such that if the user gives only one peak as
%     example, the template is just the peak.

% standardize ecg
ecg2 = ecg.^2;
ecg2_m = mean(ecg2);
ecg2_std = std(ecg2);

ecg_z = (ecg2 - ecg2_m)./ecg2_std;

% instruct the user to select the on- and offset of a clean time window
% within which r-peaks are clearly detectable

figure
plot(ecg_z);
title('z-transformed ecg data')

fprintf('Please zoom in to find a suitable time window containing clean r-peaks\n')
s1 = input('Press <y> if you found a suitable time window: ', 's');

if strcmp(s1,'y')
    title('Select time window ONSET with mouse')
    [onset,~] = ginput(1);
    title('Select time window OFFSET with mouse')
    [offset,~] = ginput(1);
end

% extract the ecg data that correspond to the time window selected by the

ecg_tw = ecg(onset:offset);

% adapt an amplitude threshold to pick the r-peaks in the ecg time window

thresh = 3; % default z-threshold, change the threhold by inserting it 
s1 = 'y';
s0 = 'y';
while strcmp(s1,'y')
    
    % detect peaks above threshold separated by at least 0.35 seconds
    [p, v] = peakdetect2(ecg_tw, thresh, 300.*0.35);
    close
    figure
    plot(ecg_tw);
    hold on
    plot(p,v,'ok')
    axis tight
    line(get(gca,'xlim'),[thresh thresh],'linestyle','--','color','r')
    xlabel('samples')
    ylabel('z-score')
    zoom
    
    % give the user the option to change the polarity of the ecg data in
    % case the r-peaks are negative - else the amplitudee threshold could
    % not pick them
    while strcmp(s0,'y')
        s0 = input('Would you like to inverse the polarity? (y/n) ', 's');
        if strcmp(s0,'y')
            ecg_tw=-ecg_tw;

            [p, v] = peakdetect2(ecg_tw, thresh, 300.*0.35);
            close
            figure
            plot(ecg_tw);
            hold on
            plot(p,v,'ok')
            axis tight
            line(get(gca,'xlim'),[thresh thresh],'linestyle','--','color','r')
            xlabel('samples')
            ylabel('z-score')
            zoom

            s0 = input('Would you like to inverse the polarity? (y/n) ', 's');
        end
    end
    
    s1 = input('Would you like to change the threshold (y/n)? ', 's');
    if strcmp(s1,'y')
        thresh = input('New threshold (z-score): ');
    end
    close
end

% build template based on identified r-peaks
temp=[];
% if only one peak has been detected, the template is just the peak
if length(p)==1
    temp=ecg_tw;
% in alll other cases, it is the mean of the peaks detected
else
    for ii=1:length(p);
        if p(ii)-200 > 1 && p(ii)+200 < length(ecg_tw)
            temp(ii,:) = ecg_tw(p(ii)-200:p(ii)+200);
        end
    end

    temp = mean(temp);
end

close
figure
plot(temp)
axis tight
s = input('Is the polarity correct, i.e. do r and t peaks point in the original direction (y/n)? ', 's');
close
while strcmp(s,'n')
    ecg_tw = -ecg_tw;
    temp = -temp;
    figure
    plot(temp)
    axis tight
    s = input('Is the polarity correct, i.e. do r and t peaks point in the original direction (y/n)? ', 's');
    close
end

rpeak_template = temp; % OUTPUT, ecg template


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step2: Find r-peaks using the template and complete ecg trace

% extract ecg of current trial
ecg = []; % input ecg trace
fs = [];
% fs - sampling frequency, e.g. 4000 = 4kHz
% Need 'eegfilt.m' (EEGLAB)

% high pass filter ecg above 1 Hz
% ecg = eegfilt(ecg,300,1,0);
ecg = eegfilt(ecg,fs,5,0);

%% Compute the correlation with the ecg channel
   
% normalize ecg
ecg_n = ecg./max(ecg);

% pad ecg
ecg_pad = [zeros(1,1000) ecg zeros(1,1000)];
cr = zeros(size(ecg_pad));

% compute correlation
for ii=1:length(ecg_pad)-length(temp)
    cr(ii+round(length(temp)/2)-1) = sum(ecg_pad(ii:ii+length(temp)-1).*temp);
end

cr = cr./max(cr); % normalize correlation to 1

% find peaks in correlation

thresh = 0.5;

s1 = 'y';
first_run=1;
while strcmp(s1,'y')
    [p, v] = peakdetect2(cr(1001:end-1000), thresh);
    peak_indx = zeros(size(ecg));
    peak_indx(p) = 1;
    peak_indx = logical(peak_indx);
    figure('Position',[150 150 1200 900]);
    subplot(2,1,1)
    plot(ecg_n);
    hold on
    plot(cr(1001:end-1000),'r')
    plot(find(peak_indx),ecg_n(peak_indx),'ko','markersize',8)
    axis tight
    line(get(gca,'xlim'),[thresh thresh],'linestyle','--','color','k')
    xlabel('samples')
    ylabel('a.u.')
    legend('ECG','corr','R-peak')
    title('Zoom in on plot to confirm proper peak picking')
    zoom
    IBI = diff(find(peak_indx));

    % convert IBI from samples to seconds
    IBI_s = IBI./fs;
        
subplot(2,1,2)
% precaution for when none or one peak has been detected since no
    % IBI then:
    if length(IBI_s)>1
            
        hist(IBI_s,sqrt(length(IBI_s)))
        xlabel('IBI (s)')
    % if none or only one peak detected: empty plot
    else
        xlabel('no IBI')
    end
    
    if first_run
        change_pol= input('Would you like to change the polarity (y/n)? ', 's');
        while strcmp(change_pol,'y')
            
            close
            ecg=-ecg;
            % normalize ecg
            ecg_n = ecg./max(ecg);
            
            % pad ecg
            ecg_pad = [zeros(1,1000) ecg zeros(1,1000)];
            cr = zeros(size(ecg_pad));
            
            % compute correlation
            for ii=1:length(ecg_pad)-length(temp)
                cr(ii+round(length(temp)/2)-1) = sum(ecg_pad(ii:ii+length(temp)-1).*temp);
            end
            
            cr = cr./max(cr); % normalize correlation to 1
            
            [p, v] = peakdetect2(cr(1001:end-1000), thresh);
            peak_indx = zeros(size(ecg));
            peak_indx(p) = 1;
            peak_indx = logical(peak_indx);
            figure('Position',[150 150 1200 900]);
            subplot(2,1,1)
            plot(ecg_n);
            hold on
            plot(cr(1001:end-1000),'r')
            plot(find(peak_indx),ecg_n(peak_indx),'ko','markersize',8)
            axis tight
            line(get(gca,'xlim'),[thresh thresh],'linestyle','--','color','k')
            xlabel('samples')
            ylabel('a.u.')
            legend('ECG','R-peak','corr')
            title('Zoom in on plot to confirm proper peak picking')
            zoom
            IBI = diff(find(peak_indx));
            
            % convert IBI from samples to seconds
            IBI_s = IBI./fs;
            
            subplot(2,1,2)
            % precaution for when none or one peak has been detected since no
            % IBI then:
            if length(IBI_s)>1
                
                hist(IBI_s,sqrt(length(IBI_s)))
                xlabel('IBI (s)')
                % if none or only one peak detected: empty plot
            else
                xlabel('no IBI')
            end
            change_pol= input('Would you like to change the polarity (y/n)? ', 's');
        end
    end
    
    s1 = input('Would you like to change the threshold (y/n)? ', 's');
    if strcmp(s1,'y')
        thresh = input('New threshold (0-1): ');
    else
        s2 = input('Would you like to check peaks manually? (y/n)? ', 's');
        if strcmp(s2,'y')
            close
            figure('Position',[150 150 1200 900]);

            plot(ecg_n);
            hold on
            plot(find(peak_indx),ecg_n(peak_indx),'ko','markersize',8)

            s3 = input('Would you like to add/remove peaks (a/r/n) (a = add / r = remove / n = no)? ', 's');
            while any(strcmp(s3,{'a' 'r'}))
                title('Click with mouse to add or remove peaks')
                [ol,au] = ginput(1);
                ol = round(ol);

                % remove the selected peak
                if strcmp(s3,'r')
                    display('Deleting peak...')
                    hold on
                    % mark the deleted peak
                    % plot(ecg);
                    hold on
                    plot(ol,au,'or','markersize',8)
                    if ol - 5 <= 0 % this takes care of the start of the window
                        peak_indx(1:ol+5) = 0;
                    elseif ol + 5 > length(peak_indx) % this takes care of the end of the window
                        peak_indx(ol-5:end) = 0;
                    else
                        peak_indx(ol-5:ol+5) = 0;
                    end

                    % add the desired peak
                elseif strcmp(s3,'a')
                    display('Adding peak...')
                    % plot the added peak
                    % plot(ecg);
                    hold on
                    plot(ol,au,'og','markersize',8)
                    if ol - 5 <= 0 % this takes care of the start of the window
                        [~,mx] = max(ecg(1:ol+5));
                        peak_indx(mx) = 1;
                    elseif ol + 5 > length(peak_indx) % this takes care of the end of the window
                        [~,mx] = max(ecg(ol-5:end));
                        peak_indx(mx + ol -5 - 1) = 1;
                    else
                        [~,mx] = max(ecg(ol-5:ol+5));
                        peak_indx(mx + ol -5 - 1) = 1;
                    end
                end
                s3 = input('Would you like to add/remove further peaks (a/r/n) (a = add / r = remove / n = no)? ', 's');
            end
        end

    end
    close
    first_run=0;
end

clc

% OUTPUT: rpeak_indx
Time = [];   Time = find(rpeak_indx==1);
Rpeaktimes = Time;

       
       
       



