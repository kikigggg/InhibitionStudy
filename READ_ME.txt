###

Title: Training data analysis protocol
Date: 26/06/2020
Author: C. R. Smid

These scripts document the process of cleaning the data downloaded from the server of the online training games.
These scripts use the raw data downloaded from the server, but they have been compiled into .csv files per group
as listed below by J. Spowage.

These are the raw data files used:

OCT_Pilot_Action_Select.csv
OCT_Pilot_Control.csv
OCT_Pilot_Experimental.csv

Data was downloaded for each of the 6 games (Mining, Treasure Collect, Conveyor Belt, Chest picking, AB driving 
and HR driving) per group (action select, control and experimental). This is the raw data besides that all data 
for the 6 games per group were compiled into one .csv file, and a column for game was added.

Below are the steps taken for cleaning, recoding and calculating of SSRT for the data. This was done for each group 
separately as outlined in the steps below using Matlab. Additional analyis conducted with the training data were 
then done in R.

By running the script 'Main_Script.m' you can run all the analyses in one go. 

1. Recoding and cleanup & calculating SSRT
These scripts will: 
* Step 1: recode sessions per date (a 'session' will be all games completed by a participant on the same date)
* Step 2:
*	2.1: recode trial numbers (errors in raw data as sessions originally coded wrong)
*	2.2: log presence of bonus games
*	2.3: remove games that were too short as based on the mean trial number per game per group 
	(trial numbers were based on duration rather than a fixed trial number, so 
	this differs per group)
*	2.4: trim games that went on too long
*	2.5: remove invalid key responses (this only happened to a small percentage of the games (<5%)
* 	2.6/2.7: remove enitre game if more than 30% of trials were removed 
* Step 3:
*	3.1: calculate number of go and inhibit trials (if present)
* recode correct and incorrect responses (as this was not always done correctly in the raw data)
* calculate behavioural results such as overall accuracy and reaction time for all (go) trials, 
false alarms on stop trials (stopRT), mean correct and mean incorrect reaction time 
* calculate d-prime and d-prime bias
* calculate SSRT in 3 ways
and do this per group

Scripts used:
Step1_Clean_Recode_Analyse_SSRT_EXP_Group_July20.m
Step1_Clean_Recode_Analyse_SSRT_ACT_Group_July20.m
Step1_Clean_Recode_Analyse_RTs_CON_Group_July20.m

2. Cleaning up sessions
These scripts
scripts used
Cleanup_afterSSRT_EXP.m
Cleanup_afterSSRT_ACT.m
Cleanup_afterRTs_CON.m

3. Analysing training data and mixed models used
This was done with R scripts, in the folder titled 2_Analysing_training_data_R
