% The scirpt is to perform significance testing whether transient increase
% or decrease exists in firing rate locked to r-peak.
% The analysis steps are
% 1. run and get 10,000 surrogate CCD data set (use code #7)
% 2. using the surrogate dataset, derive Monte-carlo p-value in time dimension in the original data
% 3. define candidate clusters where the adjacent time points with a
% Monte-Carlo p-value  <0.01 (=alpha).
% 4. Convert spike density into z-scores for z-summation process
% 5. Sum over time the z-scores of each candidate cluster
% 6. Repeat the above procedure on the 10,000 surrogate datasets, retain
% for each surrogate dataset the largest z-sum
% 7. Determine if the original max z-sum could be obtained under the null
% hypothesis
% -- written by Kayeon Kim

% Inputs: 
% Spike density Real (averaged across trials=CCD).
% Spike density surrogates (averaged across trials=CCD).

% Outputs:
% Cluster.ClustMaxZsum = max z-sum or original data
% Cluster.RandomClustmaxZAll = surrogate distribution of max z-sum

Exc_Inhi = 1;  % if 1, test for transient Excitation if 2, test for transient Inhibition
Alpha = 0.01;

% Input data
SpikeRealmeanDensity = []; % 1d vector,e.g.(1 x time) mean density across CCD, alinged to R-peak, and resampled to the minimum CCD, result from code #4, e.g. mean(Density.DensityResampled,1)
SpikeBootmeanDensity = []; % 1d matrix e.g. (10000 x time) data format same as the real density, but here, use 10,000 mean densities derived using surrogate CCD
pval = [];

% Get Monte Carlo P value for each time point using the surrogates
for t=1:size(SpikeBootmeanDensity,2)
    RealDens = zeros(1); RealDens = SpikeRealmeanDensity(1,t);
    SurrDens = zeros(10000,1);  SurrDens = SpikeBootmeanDensity(:,t); % 10,000 surrogates at time t
    if Exc_Inhi==1
        p = (length(find(SurrDens>RealDens))/10000);  % for excitation
    elseif Exc_Inhi==2
        p = (length(find(SurrDens<RealDens))/10000);  % for inhibition
    end
    pval(t) = p;
end

% find z threshold for either excitation/inhibition that exceeds Monte carlo p<0.01
SigAlpha = find(pval<Alpha);
znum = zscore(SpikeRealmeanDensity);
if Exc_Inhi==1 % find z threshold 
    Zthresh = min(znum(SigAlpha));  %% min for Excitation, max for inhibition
elseif Exc_Inhi==2
    Zthresh = max(znum(SigAlpha));
end
                    
                    
% z-sum clustering 
if ~isempty(Zthresh)
    base = [];   base = zeros(1,size(SpikeDens,2));
    base(SigAlpha)=1;  data = [];
    data(:,1) = [base 0];  % Get the peaks using zero-crossing point(max)= to find candidate clusters above threshold
    data(:,2) = [0 base];
    StartT = [];  EndT = [];
    StartT = find(data(:,1)==1 & data(:,2)==0);
    EndT = find(data(:,1)==0 & data(:,2)==1);
    EndT = EndT-1;
    
    ClustT = [];
    for seg = 1:length(StartT)
        if EndT(seg)-StartT(seg)>=1
            ClustT = [ClustT; sum(znum(StartT(seg):EndT(seg)))];
        elseif EndT(seg)-StartT(seg)<1
            ClustT = [ClustT; znum(StartT(seg))];
        end
    end
    if Exc_Inhi==1
        aaa = [];  aaa = find(ClustT==max(ClustT));  %Excitation
    elseif Exc_Inhi==2
        aaa = [];  aaa = find(ClustT==min(ClustT)); %Inhibition
    end
    
    Cluster.underAlpha =  SigAlpha;
    Cluster.Zval =  znum; % zscored spike density
    Cluster.CandClustTval = ClustT; % candidate clustering time points
    Cluster.CandClustStartT = StartT; % start of the clusters exceeding the threshold
    Cluster.CandClustEndT = EndT; % end of the clusters exceeding the threshold
    Cluster.ClustMaxWindow = [StartT(aaa) EndT(aaa)]; % Time window of max z-sum cluster
    Cluster.ClustMaxZsum = ClustT(aaa); % largest z-sum, what will be used in the next step
                        
    %%%%%%%% work on surrogate spike density for max cluter z value distribution
    MaxZAll = [];
    Thresh = Zthresh;
    for Surrnum = 1:10000 % # of surrogates
        PermuteDens = [];   zPermuteDens = [];
        PermuteDens = SpikeBootDens(Surrnum,:);
        zPermuteDens = zscore(PermuteDens);
        
        if Exc_Inhi==1
            SigAlpha = find(zPermuteDens>Thresh);  %%% > for excitation
        elseif Exc_Inhi==2
            SigAlpha = find(zPermuteDens<Thresh);  %%%  < for inhibition
        end
        
        base = [];   base = zeros(1,size(zPermuteDens,2));
        base(SigAlpha)=1;  data = [];
        data(:,1) = [base 0];  % Get the peaks using zero-crossing point(max)= to find candidate clusters above threshold
        data(:,2) = [0 base];
        StartT = [];  EndT = [];
        StartT = find(data(:,1)==1 & data(:,2)==0);
        EndT = find(data(:,1)==0 & data(:,2)==1);
        EndT = EndT-1;
        
        ClustT = [];
        for seg = 1:length(StartT)
            if EndT(seg)-StartT(seg)>=1
                ClustT = [ClustT; sum(zPermuteDens(StartT(seg):EndT(seg)))];
            elseif EndT(seg)-StartT(seg)<1
                ClustT = [ClustT; zPermuteDens(StartT(seg))];
            end
        end
        
        if Exc_Inhi ==1
            FMax = find(ClustT==max(ClustT));  %Exc
        elseif Exc_Inhi ==2
            FMax = find(ClustT==min(ClustT));  %inhi
        end
        
        if isempty(FMax)
            MaxZAll = [MaxZAll; 0];
        else
            MaxZAll = [MaxZAll; ClustT(FMax)];
        end
        disp([num2str(Surrnum),'th Surrogate is done']);
    end
    Cluster.RandomClustmaxZAll = MaxZAll;
else
    Cluster.Zval =  znum;
    Cluster.RandomClustmaxZAll = [];
end
    











