% Date: 26/06/2020
% author: C. R. Smid
% purpose: this file will clean the raw data as donwloaded from the servers
% for the online training games used in the 2019 October Pilot Training at
% the Developmental Change and Plasticity Lab at UCL.
% There are errors in the raw data in the form of, incorrectly logged
% responses, responses incorrectly coded as correct/incorrect, sessions
% continued on for too long, and sessions coded incorrectly (e.g. over
% multiple days). The errors in the raw data are addressed in Step 1, and
% afterwards the data is further cleaned to set up for the scripts that
% will calculate SSRT/SSD or RTs.

function Step1_Clean_Recode_Analyse_RTs_CON_Group_July20

% clc;

%% Step 0. Importing data, selecting relevant columns
% import data
fprintf('\n\nWorking on Control Group data.\n\n')
fprintf('Importing main data file, finding participant numbers and removing uneccessary columns...\n\n')
qdat = readtable('OCT_Pilot_Control.csv');

% remove unnecessary columns
% these columns refer to unused Id numbers, NaN columns etc
columnIndicesToDelete = [2 4 5 15 16 17 18 25 26 27 42 43]; 
qdat(:,columnIndicesToDelete) = [];

% first, recode sessions per date
% find all participants. We have 21 participants in the Action select group
IDs = unique(qdat.ParticipantPublicID);

Extra_CON_Measures = [];
Final_CON_output = [];
Final_CON_Pdata = [];
Total_Game_Rec = [];
Pdata = [];

%% Step 1. Recode session by date
% Loop through participants
for pp = 1:length(IDs)

    fprintf('Currently analysing participant: %d\n\n',IDs(pp))
    
    % 1.1 extract a new table per participant
    ParticipantPrep = qdat(qdat.ParticipantPublicID == IDs(pp), :);
    
    % 1.2 change formatting of raw data date and times to just date
    ParticipantPrep.UTCDate.Format = 'yyyy-MM-dd';
    ParticipantPrep = sortrows(ParticipantPrep,'UTCDate'); % sorted by date
    
    % extract dates
    Dates = ParticipantPrep.UTCDate;
    Z = string(Dates);
    ParticipantPrep.DateStrings = Z; % assign new session identifier (date as a string)
    
    % 1.3 find all the sessions for that participant
    Seshs = unique(ParticipantPrep.DateStrings);
    fprintf('Total sessions found for this participant: %d\n\n',length(Seshs))
    
    Tot_Bonus = 0;
    Tot_session = 0;
    Inc_session = 0;
    
    %% per session of a participant
    for s = 1:length(Seshs)
        
        % session counter for total sessions available per participant
        % (these are a date and time stamp)
        Tot_session = Tot_session + 1;
        
        fprintf('Currently on session: %d.\n\nCleaning, recoding and analysing data.\n\n', Tot_session)
        
        % 1.4 separate table per session
        P_Sesh = ParticipantPrep(strcmp(ParticipantPrep.DateStrings,Seshs(s)),:);
        P_Sesh.InitSessions(:) = Tot_session;
        
        % find all the games in that session
        Gams = unique(P_Sesh.Game); 
        fprintf('Games in this session: \n')
        disp(Gams)
        
        BonusPresent = 0;
        
        %% Step 2. Clean invalid responses and recode trial numbers per game inside a session
        for y = 1:length(Gams)

            % select all rows for that game and see how many trials
            Game_recode = P_Sesh(strcmp(P_Sesh.Game,Gams(y)),:); 
            Tot_trials = size(Game_recode,1); % the finding of max_allowed_Trials was based on this number across pps.

            % 2.1 recode new trial numbers per game (we need to do this due
            % to mis labeling of sessions in raw data)
            new_trial_nums = (1:Tot_trials)';
            Game_recode.NewTrials = new_trial_nums;
            DayNight = Game_recode.DayNightVariation(1); % code if this has been logged for game type
            HotCold = Game_recode.HotOrCold(1); % code if this has been logged for game type
            
            % The number for Max_allowed_trials
            % was determined by using these analyses first without cutoff,
            % then finding the mean amount of trials per game across all
            % participants, then finding the standard deviation for these
            % (this included some participants who had a high number of
            % trials). Then we set the limit as mean + 3SD of number of
            % trials. We used 3SD since the number of trials was determined
            % by duration if all went well, but in some cases sessions went
            % overtime. Numbers are rounded. (based on Exp_Trial_Count.m
            % script).
            
            % check valid responses for each game.
            
            if strcmp(Gams(y),'Mining') == 1 
               % For Mining, the mean number of trials was 121. the SD
               % was 18, 3SD is 54. All trials beyond M + 3SD (175)
               % will now be excluded.
               validResp = {'none', 'spacebar', 'spacebar release'};
               Max_allowed_Trials = 175;
               Min_needed_Trials = 67;
               Game_num = 1;
               error = 0;

            elseif strcmp(Gams(y),'Chest_Picking') == 1
               % For chest picking, the mean amount of trials was 128.
               % SD was 37 and 3SD 112. Trials over M + 3SD (240) will
               % now be excluded
               validResp = {'none', 'spacebar', 'spacebar release'};
               Max_allowed_Trials = 240;
               Min_needed_Trials = 16;
               Game_num = 2;
               error = 0;

            elseif strcmp(Gams(y),'Treasure_Collect') == 1
               % For treasure collect, mean trials were 147, SD was 47,
               % and 3SD was 97. Trials over 231 will now be excluded.
               validResp = {'none', 'spacebar', 'spacebar release'};
               Max_allowed_Trials = 231;
               Min_needed_Trials = 50;
               Game_num = 3;
               error = 0;

            elseif strcmp(Gams(y),'Conveyor_Belt') == 1
               % For conveyor belt, the mean was 108, SD was 45, and 3SD
               % was 135. Trials over 243 will now be excluded.
               validResp = {'none', 'spacebar', 'spacebar release'};
               Max_allowed_Trials = 287;
               Min_needed_Trials = 0;
               Game_num = 4;
               error = 0;

            elseif strcmp(Gams(y),'AB_Driving') == 1
               % For AB driving, the mean of trials was 93, SD was 22,
               % 3SD was 65. Trials over 158 will now be excluded.
               validResp = {'none', 'ArrowLeft', 'ArrowRight'};
               Max_allowed_Trials = 158;
               Min_needed_Trials = 28;
               Game_num = 5;
               error = 0;

            elseif strcmp(Gams(y),'HR_Driving') == 1
               % For HR driving, the mean of trials will be 108, the SD
               % was 28, 3SD 85, and trials over 193 now excluded.
               validResp = {'none', 'spacebar', 'spacebar release'};
               Max_allowed_Trials = 193;
               Min_needed_Trials = 23;
               Game_num = 6;
               error = 0;

            else
               error = 'Error!';
               Max_allowed_Trials = 500;
               Min_needed_Trials = 0;
            end
               

            % 2.2 log presence of bonus games
                if Game_recode.BonusGame(1) == 1 % bonus game present
                    BonusPresent = 1;
                    Tot_Bonus = Tot_Bonus + 1; 
                    fprintf('Bonus game in session: %s. logged.\n',Game_recode.Game{1})
                else
                    BonusPresent = 0;
                end
                
                % save before cleaning
                Game_Rec_CON.Particpant = IDs(pp);
                Game_Rec_CON.TotalSessions = Tot_session;
%                 Game_Rec_CON.Session = Inc_session;
                Game_Rec_CON.Game = Gams(y);
                Game_Rec_CON.GameNo = Game_num;
                Game_Rec_CON.BonusGame = BonusPresent;
                Game_Rec_CON.Tot_trials = Tot_trials; 
                
                % 2.3 remove games that were too short
                if size(Game_recode,1) < Min_needed_Trials
                    Game_recode(:,:) = [];
                    FullGameExcl = 1;
                else
                    FullGameExcl = 0;
                end
                
                % 2.4 trim games that went on too long
                Game_recode(Game_recode.NewTrials > Max_allowed_Trials,:) = [];
                remaining1 = size(Game_recode,1);
                TooLongTrialRem = (Tot_trials - remaining1);
            
                % 2.5 clean invalid key responses here
                KeysUsed = unique(Game_recode.Key); % check which keys were used
                Game_recode(~ismember(Game_recode.Key,validResp),:) = []; % remove invalid keys here
                remaining2 = size(Game_recode,1);
                InvalidsRem = (remaining1 - remaining2); % how many trials were removed for invalid keys
                PercentageRem = (100*InvalidsRem)/remaining1;
                ExcludedKeys = KeysUsed(~ismember(KeysUsed,validResp))'; % which keys were excluded, if they were. I tried 'setdiff' and '~ismember'
                missedtrialsrem = cell2mat(cellfun(@(x) sum(ismember(Game_recode.Key,'none')),{'none'},'un',0));
                
                % 2.6 check if there aren't just 'none' presses left for a game
                % with full or partial invalid responses.
                if (strcmp(unique(Game_recode.Key),'none') == 1) | (PercentageRem > 30)
                    Game_recode(:,:) = [];
                    FullGameExcl = 1;
                else
                    FullGameExcl = 0;
                end
                
                % 2.7 if more than 50% of trials are missed trials, exclude
                % game as well
                if (missedtrialsrem*100/remaining2) > 50
                    Game_recode(:,:) = [];
                    FullGameExcl = 1;
                else
                    FullGameExcl = 0;
                end
                
                
                % save recoding info
                Game_Rec_CON.New_Tot_trials = size(Game_recode,1);
                Game_Rec_CON.Missed_trials = missedtrialsrem;
                Game_Rec_CON.ValidResps = validResp;
                Game_Rec_CON.Error = error;
                Game_Rec_CON.MaxLengthTrials = Max_allowed_Trials;
                Game_Rec_CON.MinLengthTrials = Min_needed_Trials;
                Game_Rec_CON.RemTrialsLength = TooLongTrialRem;
                Game_Rec_CON.RemInvKeyResps = InvalidsRem;
                Game_Rec_CON.RemInvKeyPerc = (100*InvalidsRem)/remaining1;
                Game_Rec_CON.KeysExcluded = ExcludedKeys;
                Game_Rec_CON.DayNightVariation = DayNight;
                Game_Rec_CON.HotColdVariation = HotCold;
                Game_Rec_CON.FullGameExcluded = FullGameExcl;
                     
             % 2.8 skip the rest of the loop if the game was deleted
            if isempty(Game_recode) == 1
                Game_Rec_CON.FullGameExcluded = 1;
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_CON];
                continue;  % skip rest of loop
                
            else % save the game log here and continue rest of loop
                % save log of data cleaning for this pp (and all pps)
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_CON];
            end
            
           % rename this pps cleaned data to the format we use further down 
            Sesh_Game = Game_recode;
            
            
            %% Step 3. Analyse
            
            % empty variables for every game in a session
            all_goRT = [];
            Corr_goRT = [];
            InCorr_goRT = [];
            hits = 0;
            late_hits = 0;
            correct = 0;
            go_error = 0;
            go_omissions = 0;
            go_omissions_all = 0;
            
            Glen = size(Sesh_Game);
            
            % calculate total number of trials 
            go_trials = sum(strcmp(Sesh_Game.TrialType,'respond'));
            stop_trials = sum(strcmp(Sesh_Game.TrialType,'inhibit')) + sum(strcmp(Sesh_Game.TrialType,'nonrespond'));;
            
            all_trials = go_trials + stop_trials;
            
            %% 3.1 for every line in the game, coding correct and incorrect responses
            for z = 1:Glen(1)
                
                % KG 05/02/20: leave in 5 seconds and 100 ms window. 
                
                % KG: Edit 05/02/20: maybe without the time limit here.
                % So, if they did make a response, then technically
                % it's not a go-omissions, it's just a fast response.
                % ASK JOSH. (But for d-prime we need to know the
                % go-omission... maybe just do it differently. e.g. maybe use two types of 
                % go-omission. Consensus: ok let's do both. 
                    
                % 3.1.1 For AB driving....
                if strcmp(Gams(y),'AB_Driving') == 1
                    % check if correct by matching a left or right
                    % arrow key press with the raw coded correct or
                    % incorrect value

                    % CORRECT GO TRIAL: Left or right arrow key that
                    % was coded as correct in raw data
                    if (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && Sesh_Game.Correct(z) == 1 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                        Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                        hits = hits + 1;
                        correct = correct + 1;
                        all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                        Corr_goRT = [Corr_goRT, Sesh_Game.ReactionTime(z)];

                    % INCORRECT GO TRIAL: they didn't respond
                    elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                        Sesh_Game.Correct(z) = 0;
                        go_omissions = go_omissions + 1;
                        go_omissions_all = go_omissions_all + 1;
                        if isempty(Sesh_Game.ReactionTime(z)) == 0
                            all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];
                        end

                        % GO ERROR: Out of bounds response?
                    elseif isnan(Sesh_Game.Correct(z)) == 1 & (strcmp(Sesh_Game.Key(z),'none') == 0 | strcmp(Sesh_Game.Response(z),'out of bounds') == 1) 
                        Sesh_Game.Correct(z) = 0;
                        go_error = go_error + 1;
                        all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                        InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];

                        % TOO LATE: response out of RT bounds    
                    elseif (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && Sesh_Game.Correct(z) == 1 && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                        % code in different go-omission outside of RT
                        % limit. 
                        Sesh_Game.Correct(z) = 0;
                        go_omissions_all = go_omissions_all + 1;
                        late_hits = late_hits + 1;
%                         all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
%                         InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];

                    end

                    % 3.2.2 All other games (so not AB_Driving)
                elseif strcmp(Gams(y),'AB_Driving') == 0

                    % this will take either a spacebar press or
                    % spacebar release. (e.g. not a 'none' response)
                    if (strcmp(Sesh_Game.Key(z),'spacebar') == 1 | strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                        Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                        hits = hits + 1;
                        correct = correct + 1;
                        all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                        Corr_goRT = [Corr_goRT, Sesh_Game.ReactionTime(z)];

                    % INCORRECT GO TRIAL: they didn't respond
                    elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                        Sesh_Game.Correct(z) = 0;
                        go_omissions = go_omissions + 1;
                        go_omissions_all = go_omissions_all + 1;
                        if isempty(Sesh_Game.ReactionTime(z)) == 0
                            all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];
                        end

                        % GO ERROR: Out of bounds response?
                    elseif isnan(Sesh_Game.Correct(z)) == 1 |(strcmp(Sesh_Game.Response(z),'out of bounds') == 1) | (strcmp(Sesh_Game.Key(z),'spacebar release') == 0 && strcmp(Sesh_Game.Key(z),'spacebar') == 0)
                        Sesh_Game.Correct(z) = 0;
                        go_error = go_error + 1;
                        all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
                        InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];

                        % TOO LATE: response out of RT bounds    
                    elseif (strcmp(Sesh_Game.Key(z),'spacebar') == 1 | strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && Sesh_Game.Correct(z) == 1 && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                        % code in different go-omission outside of RT
                        % limit. 
                        Sesh_Game.Correct(z) = 0;
                        go_omissions_all = go_omissions_all + 1;
                        late_hits = late_hits + 1;
%                         all_goRT = [all_goRT, Sesh_Game.ReactionTime(z)];
%                         InCorr_goRT = [InCorr_goRT, Sesh_Game.ReactionTime(z)];
                    end
                    
                end
                
            end
                

            % save remaining valid responses for further analysis for all
            % pps
            if s == 1 && y == 1
                Pdata = Sesh_Game;
            else
                Pdata = [Pdata; Sesh_Game];
            end
            
            
%                  %% d-prime
%                  pHit = 1-(go_omissions_all / go_trials);
%                  pFa = 1-(correct_inhibits / stop_trials);
%                  [dprime_val,dprime_bias] = dprime(pHit,pFa);
                 

                excluded_RTs = [];
                
            %% Step 3. calculate variables of interest
           if isempty(all_goRT) == 0 
            % set within 2 SD limit for reaction times
                upper_go_RT = mean(all_goRT) + ((std(all_goRT))*2);  
                lower_go_RT = mean(all_goRT) - ((std(all_goRT))*2);  
                
                all_goRT_sd = all_goRT;
                % To Do: KG 05/02/20: we leave this in, but add a counter
                % for keeping track of how many RTs are discarded.
                % filter out go RTs that are beyond 2 SDs of the mean
                                
                all_goRT_sd(all_goRT_sd > upper_go_RT) = [];
                all_goRT_sd(all_goRT_sd < lower_go_RT) = [];
                Exclude = 0;
           else
               all_goRT_sd = NaN;
               Exclude = 1;
           end
                 
           
%            if isempty(excluded_RTs) == 1
%                excluded_RTs = NaN;
%            end
          
           
           % repeat this for corr_goRT? since there seems to be a big
           % spread.
           
%            Corr_goRT_sd = [];
           excluded_CorrRTs = [];
                
           if isempty(Corr_goRT) == 0 
            % set within 2 SD limit for reaction times
               upper_go_RT = mean(Corr_goRT) + ((std(Corr_goRT))*2);  
                lower_go_RT = mean(Corr_goRT) - ((std(Corr_goRT))*2);  
                
                Corr_goRT_sd = Corr_goRT;
                % To Do: KG 05/02/20: we leave this in, but add a counter
                % for keeping track of how many RTs are discarded.
                % filter out go RTs that are beyond 2 SDs of the mean
                                
                Corr_goRT_sd(Corr_goRT_sd > upper_go_RT) = [];
                Corr_goRT_sd(Corr_goRT_sd < lower_go_RT) = [];
                
           else
               Corr_goRT_sd = NaN;
               Exclude = 1;
           end
           
           
%            excluded_CorrRTs = [];
           Stim_dur = Sesh_Game.StimulusDuration;
                
           if isempty(Stim_dur) == 0 
            % set within 2 SD limit for reaction times
               upper_go_RT = mean(Stim_dur) + ((std(Stim_dur))*2);  
                lower_go_RT = mean(Stim_dur) - ((std(Stim_dur))*2);  
                
                StimulusDuration_sd = Stim_dur;
                % To Do: KG 05/02/20: we leave this in, but add a counter
                % for keeping track of how many RTs are discarded.
                % filter out go RTs that are beyond 2 SDs of the mean
                                
                StimulusDuration_sd(StimulusDuration_sd > upper_go_RT) = [];
                StimulusDuration_sd(StimulusDuration_sd < lower_go_RT) = [];
                
           else
               StimulusDuration_sd = NaN;
%                Exclude = 1;
           end
           
%            if isempty(excluded_CorrRTs) == 1
%                excluded_CorrRTs = NaN;
%            end
           
                 %% save variables
                output.Participant = IDs(pp);
                output.Group = 3; % control group is group 3
                output.Tot_session = Tot_session;
                output.Inc_session = Tot_session;
                output.Excludegame = Exclude;
                output.Game = Gams(y);
                output.BonusGames = Tot_Bonus;
                output.TotalTrials = all_trials;
                output.Perc_correct = (100*correct) / all_trials;
                output.CorrResponses = correct;
                output.hits = hits;
                output.latehits = late_hits;
                output.go_trials = go_trials;
                output.go_omissions = go_omissions;
                output.go_omissions_all = go_omissions_all;
                output.go_error = go_error;
                output.stop_trials = stop_trials;
                output.P_Hit = hits / go_trials;
                output.P_go_errors = go_error / go_trials;
                output.P_go_omission = go_omissions / go_trials;
                output.mean_all_goRT = mean(all_goRT);
                output.mean_all_goRT_2SD = mean(all_goRT_sd);
                output.mean_Corr_goRT = mean(Corr_goRT);
                output.mean_Corr_goRT_2SD = mean(Corr_goRT_sd);
%                 output.mean_InCorr_go_RT = mean(InCorr_goRT); % no log
%                 output.excluded_RTs = excluded_RTs;
%                 output.excluded_CorrRTs = excluded_CorrRTs;
                output.std_all_goRT = std(all_goRT);
                output.std_all_goRT_2SD = std(all_goRT_sd);
                output.std_Corr_goRT = std(Corr_goRT);
                output.std_Corr_goRT_2SD = std(Corr_goRT_sd);
%                 output.std_InCorr_goRT = std(InCorr_goRT);
                output.CovVar_all_goRT = std(all_goRT) / mean(all_goRT);
                output.CovVar_all_goRT_2SD = std(all_goRT_sd) / mean(all_goRT_sd);
                output.CovVar_Corr_goRT = std(Corr_goRT) / mean(Corr_goRT);
                output.CovVar_Corr_goRT_2SD = std(Corr_goRT_sd) / mean(Corr_goRT_sd);
%                 output.CovVar_InCorr_goRT = std(InCorr_goRT) / mean(InCorr_goRT);
                output.mean_Stim_dur = mean(StimulusDuration_sd);
%                 output.mean_next_Stim_dur = mean([Sesh_Game.NextStimulusDuration]);
                                 
                %%% save line by line
                Final_CON_output = [Final_CON_output,output];
                

%                 Final_CON_Pdata = [Final_CON_Pdata; Pdata];
                      
        end
                 
            
    end
        
    Final_CON_Pdata = [Final_CON_Pdata; Pdata];
    
    fprintf('Participant %d completed.\n\n\n',IDs(pp))
    
    Measures.Participant = IDs(pp);
    Measures.Group = 3;
    Measures.TotalSessions = max([output.Tot_session]);
    Measures.TotalBonusGames = max([output.BonusGames]);
    Measures.PercentageBonusDone = (100*max([output.BonusGames]))/max([output.Tot_session]);
    
    Extra_CON_Measures = [Extra_CON_Measures, Measures];



        
end
    Extra_CON_Measures = struct2table(Extra_CON_Measures);
writetable(Final_CON_Pdata,'Cleaned_PPData_CON.csv','Delimiter',',')
writetable(Extra_CON_Measures,'Extra_CON_Measures.csv','Delimiter',',')
    
% save final output
    fprintf('COMPLETED. saving all...\n\nThe outputted final datasets will be:\n\n"Final_CON_output.mat"\n\n"Total_game_cleaning_log_CON.mat"\n\n"Cleaned_PPData_CON.mat"\n\nand are saved in the current folder.\n\n')
    save Final_CON_output.mat Final_CON_output
    save Total_game_cleaning_log_CON.mat Total_Game_Rec
    save Cleaned_PPData_CON.mat Final_CON_Pdata
    save Extra_CON_Measures.mat Extra_CON_Measures
    
end
