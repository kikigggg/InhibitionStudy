%% Main script to run full training data analysis
% date: 06/07/2020
% author: C. R. Smid
% This script will run all cleaning and analysis steps to recreate the
% analysis done for the training data for the online games for the October
% pilot training done at the DCP Lab at UCL. 
% After running these scripts and producing the final data output, the
% remaining mixed model analyses and graphs were produced in R.

%% Step 1: cleaning data files for each group and calculating SSRT
% In this step, invalid responses are checked and discarded (this only
% happened for <5% of the data. Sessions are labelled properly using date,
% and correct and incorrect responses are recoded. Only sessions with at
% least 2 games are included, to produce reliable SSRT estimates per
% session. A log is kept of all changes made to the data (and which
% sessions were excluded), the cleaned participant data is saved, and the
% final data output with the SSRT measures is saved.

% before cleaning, the trial counts to estimate the mean trial length per
% game per group per participant was calculated to see at which point
% trials should be cut off. This was implemented because some sessions
% continued on too long due to fault in the developer's code. Sessions
% should be duration based rather than based on trial length (e.g. 60
% seconds) so the number of trials per participant differs. However, we
% excluded trials that went past 3 standard deviations of the mean trial
% length to capture these invalid sessions. The scripts 'Trial_Count_ACT.m'
% etc were used to find the mean and SD of the trial lengths. 

% 1.1 Experimental group 
clearvars;
Step1_Clean_Recode_Analyse_SSRT_EXP_Group_July20;

% 1.2 Action select group
clearvars;
Step1_Clean_Recode_Analyse_SSRT_ACT_Group_July20;

% 1.3 Control group
clearvars;
Step1_Clean_Recode_Analyse_RTs_CON_Group_July20;

%% Step 2: last cleaning of sessions
% in this step, if any of the SSRT measures were invalid (e.g. negative or
% 0), they are excluded. If this leads to the session having less than 2
% games in total, the whole session is removed and sessions are relabelled
% consecutively. 

% 2.1 Experimental group 
clearvars;
Cleanup_afterSSRT_EXP

% 2.2 Action select group
clearvars;
Cleanup_afterSSRT_ACT

% 2.3 Control group
clearvars;
Cleanup_afterRTs_CON

%% Step 3: Collate the extra measures (how many bonus games done etc)

load Extra_EXP_Measures.mat

Extra_Measures = [Extra_EXP_Measures];

load Extra_ACT_Measures.mat

Extra_Measures = [Extra_Measures; Extra_ACT_Measures];

load Extra_CON_Measures.mat

Extra_Measures = [Extra_Measures; Extra_CON_Measures];

writetable(Extra_Measures,'Extra_Measures.csv','Delimiter',',')
% done.



