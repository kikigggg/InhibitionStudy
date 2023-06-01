% Date: 24/09/2020
% author: C. R. Smid



%% Step 1. load in particpant data

load Cleaned_PPData_ACT.mat 

% remove all incorrect rows
Final_ACT_Pdata(Final_ACT_Pdata.Correct == 0,:) = [];

% keep only relevant columns
columnIndicesToKeep = [8 10 19 23 27 34]; 
extract = Final_ACT_Pdata(:,columnIndicesToKeep);

% no signal trials are 'respond', signal trials are 'inhibit' and
% 'nonrespond'
% signal delay is SSD

% define a slowed RT -- using a median split of trial RTs?


for t = 1:trials
    if RT(t) - SSD(t) > 
    
end

% To calculate TOSD, we subtracted the signal delay from the nth percentile 
% of no signal trial RTs, where n corresponds to the proportion of RTs classified 
% as unslowed at that signal delay. This approach is conceptually identical 
% to that used to calculate SSRT in the race model, in which the signal delay 
% is subtracted from the nth percentile of No Signal RTs, where n corresponds 
% to the proportion of unsuccessful stop trials at that signal delay. TOSD was
% calculated for each subject as the median of these estimates across all signal
% delays.”  https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0031546

%It’s a similar method to the SSRT but it seems like there’s some fitting necessary
% first to categorise trials as unslowed vs slowed.

% Where N is the total number of observations, D is the total number of distributions
% fit, Dp is the total number of free parameters used in fitting those distributions,
% d is the weight of the dth distribution, and Ld(RTn) is the likelihood of
% the nth RT given the best fit parameters for the dth distribution (? and 
% ? for Gaussian and k and ? for Gamma).

% We next categorized individual trials as slowed or unslowed using the 
% likelihood of observing each RT under either of the two fitted distributions.
% RTs were categorized as slowed if there was even weak evidence in favor of
% the RT belonging to that distribution (as quantified by a difference in BIC
% of ?2.35); otherwise RTs were categorized as unslowed. Other standards of
% evidence lead to similar results as those presented here, but do not as
% cleanly separate the slowed and unslowed trials (c.f. Fig. 6D).

extract(strcmp(extract.TrialType,'nonrespond'),:); 
idx = extract(strcmp(extract.TrialType,'nonrespond'),:); 
extract.TrialType(idx) = 'inhibit';

% extract(extract.TrialType == 'nonrespond') = extract.TrialType;

% save as csv
writetable(extract,'TOSD_Prep_Data.csv','Delimiter',',')

