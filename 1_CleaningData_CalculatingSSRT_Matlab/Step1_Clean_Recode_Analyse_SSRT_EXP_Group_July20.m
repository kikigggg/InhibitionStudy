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

function Step1_Clean_Recode_Analyse_SSRT_EXP_Group_July20

clc;

%% Step 0. Importing data, selecting relevant columns
% import data
fprintf('\n\nWorking on Experimental Group data.\n\n')
fprintf('Importing main data file, finding participant numbers and removing uneccessary columns...\n\n')
qdat = readtable('OCT_Pilot_Experimental.csv');

% remove unnecessary columns
% these columns refer to unused Id numbers, NaN columns etc
columnIndicesToDelete = [2 4 5 15 16 17 18 25 26 27 42 43]; 
qdat(:,columnIndicesToDelete) = [];

% first, recode sessions per date
% find all participants. We have 21 participants in the Action select group
IDs = unique(qdat.ParticipantPublicID);

Extra_EXP_Measures = [];
Final_EXP_output = [];
Final_EXP_Pdata = [];
Total_Game_Rec = [];
Pdata = [];


%% Step 1. Recode session by date
% Loop through participants
for pp = 1:length(IDs)

    fprintf('Currently analysing participant: %d\n\n',IDs(pp))
    
    % 1.1 extract a new table per participant
    ParticipantPrep = qdat(qdat.ParticipantPublicID == IDs(pp), :);
    
    % 1.2 change formatting of raw data date and times to just date
    ParticipantPrep.UTCDate.Format = 'yyyy-MM-dd'; % put year first, then month then day, so they can be sorted chronologically
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
    SpacebarKey = [];
    SpacebarRelease = [];
    
    %% Next, analyse per session of a participant
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
        
        BonusPresent = 0; % initialise to 0
        
        %% Step 2. Clean invalid responses and recode trial numbers per game inside a session
        for y = 1:length(Gams)
            
            % select all rows for that game and see how many trials
            Game_recode = P_Sesh(strcmp(P_Sesh.Game,Gams(y)),:); 
            Tot_trials = size(Game_recode,1);

            % 2.1 recode new trial numbers per game (we need to do this due
            % to mis labeling of sessions in raw data)
            new_trial_nums = (1:Tot_trials)';
            Game_recode.NewTrials = new_trial_nums;
            DayNight = Game_recode.DayNightVariation(1); % code if this has been logged for game type
            HotCold = Game_recode.HotOrCold(1); % code if this has been logged for game type
               
            % Here we see which game it is, to see which key presses we will
            % code as valid responses. The number for Max_allowed_trials
            % was determined by using these analyses first without cutoff,
            % then finding the mean amount of trials per game across all
            % participants, then finding the standard deviation for these
            % (this included some participants who had a high number of
            % trials). Then we set the limit as mean + 3SD of number of
            % trials. We used 3SD since the number of trials was determined
            % by duration if all went well, but in some cases sessions went
            % overtime. Numbers are rounded. (based on Exp_Trial_Count.m
            % script). 
            
                if strcmp(Gams(y),'Mining') == 1 
                   % For Mining, the mean number of trials was 110. the SD
                   % was 40, 3SD is 120. All trials beyond M + 3SD (231)
                   % will now be excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 231;
                   Min_needed_Trials = 0;
                   Game_num = 1;
                   error = 0;

               elseif strcmp(Gams(y),'Chest_Picking') == 1
                   % For chest picking, the mean amount of trials was 119.
                   % SD was 28 and 3SD 83. Trials over M + 3SD (202) will
                   % now be excluded
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 202;
                   Min_needed_Trials = 36;
                   Game_num = 2;
                   error = 0;

               elseif strcmp(Gams(y),'Treasure_Collect') == 1
                   % For treasure collect, mean trials were 134, SD was 32,
                   % and 3SD was 97. Trials over 231 will now be excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 231;
                   Min_needed_Trials = 37;
                   Game_num = 3;
                   error = 0;

               elseif strcmp(Gams(y),'Conveyor_Belt') == 1
                   % For conveyor belt, the mean was 90, SD was 17, and 3SD
                   % was 50. Trials over 140 will now be excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 140;
                   Min_needed_Trials = 40;
                   Game_num = 4;
                   error = 0;

               elseif strcmp(Gams(y),'AB_Driving') == 1
                   % For AB driving, the mean of trials was 93, SD was 27,
                   % 3SD was 82. Trials over 175 will now be excluded.
                   validResp = {'none', 'ArrowLeft', 'ArrowRight'};
                   Max_allowed_Trials = 175;
                   Min_needed_Trials = 11;
                   Game_num = 5;
                   error = 0;

               elseif strcmp(Gams(y),'HR_Driving') == 1
                   % For HR driving, the mean of trials was 99, the SD
                   % was 31, 3SD 94, and trials over 193 now excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 193;
                   Min_needed_Trials = 5;
                   Game_num = 6;
                   error = 0;

               else
                   error = 'Error!';
                   Max_allowed_Trials = 500;
                   Min_needed_Trials = 0;
                end
                

                % 2.2 log presence of bonus games
                if Game_recode.BonusGame(1) == 1 % bonus game subset not empty
                    BonusPresent = 1;
                    Tot_Bonus = Tot_Bonus + 1;
                    fprintf('Bonus game in session: %s. logged.\n',Game_recode.Game{1})
                else
                    BonusPresent = 0;
                end
                
                % save before cleaning
                Game_Rec_EXP.Particpant = IDs(pp);
                Game_Rec_EXP.TotalSessions = Tot_session;
%                 Game_Rec_EXP.IncludedSessions = Inc_session;
                Game_Rec_EXP.Game = Gams(y);
                Game_Rec_EXP.GameNo = Game_num;
                Game_Rec_EXP.BonusGame = BonusPresent;
                Game_Rec_EXP.Tot_trials = Tot_trials; 
                
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
                
                % Taken part below out, since both 'spacebar' and 'spacebar
                % release' did not differ in RTs for this group. 
%                 % if both 'spacebar' and 'spacebar release' are present,
%                 % we log reaction time for both presses separately so we
%                 % can later check if we should only include one type of
%                 % spacebar key press
%                 % UPDATE: for Experimental, there was only 1 session this
%                 % was the case, and there was no difference in RT between
%                 % the keypresses as measured by a ttest (independent
%                 % samples, because different length of trials)
%                 % p = .4071
%                 if any(strcmp(Game_recode.Key,'spacebar')) == 1 && any(strcmp(Game_recode.Key,'spacebar release')) == 1
%                     
%                     % subset per press
%                     SB_P = Game_recode(strcmp(Game_recode.Key,'spacebar'),:);
%                     SB_R = Game_recode(strcmp(Game_recode.Key,'spacebar release'),:);
%                     
%                     % get reaction time (do we need mean RT here)
%                     Game_Rec_EXP.SpaceP_RT = SB_P.ReactionTime;
%                     Game_Rec_EXP.SpaceR_RT = SB_R.ReactionTime;
% 
%                 else
%                     Game_Rec_EXP.SpaceP_RT = NaN;
%                     Game_Rec_EXP.SpaceR_RT = NaN;
%                 end
                
                % 2.5 clean invalid key responses here
                KeysUsed = unique(Game_recode.Key); % check which keys were used
                Game_recode(~ismember(Game_recode.Key,validResp),:) = []; % remove invalid keys here
                remaining2 = size(Game_recode,1);
                InvalidsRem = (remaining1 - remaining2); % how many trials were removed for invalid keys
                PercentageRem = (100*InvalidsRem)/remaining1; % the percentage of trials removed for invalid keys
                ExcludedKeys = KeysUsed(~ismember(KeysUsed,validResp))'; % which keys were excluded, if they were. I tried 'setdiff' and '~ismember'
                
                % 2.6 check if there aren't just 'none' presses left for a game
                % with full or partial invalid responses.
                if (strcmp(unique(Game_recode.Key),'none') == 1) | (PercentageRem > 50) | (size(Game_recode,1) < Min_needed_Trials)
                    Game_recode(:,:) = [];
                    FullGameExcl = 1;
                else
                    FullGameExcl = 0;
                end
                
                % save recoding info
                Game_Rec_EXP.New_Tot_trials = size(Game_recode,1);
                Game_Rec_EXP.ValidResps = validResp;
                Game_Rec_EXP.Error = error;
                Game_Rec_EXP.MaxLengthTrials = Max_allowed_Trials;
                Game_Rec_EXP.MinLengthTrials = Min_needed_Trials;
                Game_Rec_EXP.RemTrialsLength = TooLongTrialRem;
                Game_Rec_EXP.RemInvKeyResps = InvalidsRem;
                Game_Rec_EXP.RemInvKeyPerc = PercentageRem;
                Game_Rec_EXP.KeysExcluded = ExcludedKeys;
                Game_Rec_EXP.DayNightVariation = DayNight;
                Game_Rec_EXP.HotColdVariation = HotCold;
                Game_Rec_EXP.FullGameExcluded = FullGameExcl;
                     
            % 2.7 skip the rest of the loop if the game was deleted
            if isempty(Game_recode) == 1
                Game_Rec_EXP.FullGameExcluded = 1;
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_EXP];
                continue;  % skip rest of loop
                
            else % save the game log here and continue rest of loop
                % save log of data cleaning for this pp (and all pps)
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_EXP];
            end
            
       
           % rename this pps cleaned data to the format we use further down 
            Sesh_Game = Game_recode;
            
            
            %% Step 3. Recoding correct and incorrect responses 
            
            % empty variables for every game in a session
            all_goRT = [];
            Corr_goRT = [];
            InCorr_goRT = [];
            stop_RT = [];
            ssd = [];
            hits = 0;
            correct = 0;
            go_omissions = 0;
            go_omissions_all = 0;
            go_error = 0;
            false_alarms = 0;
            correct_inhibits = 0;
            
            % length of (remaining) game trials after cleaning
            Glen = size(Sesh_Game,1);
            
            % 3.1 calculate total number of go and no-go trials 
            go_trials = sum(strcmp(Sesh_Game.TrialType,'respond'));
            stop_trials = sum(strcmp(Sesh_Game.TrialType,'inhibit')) + sum(strcmp(Sesh_Game.TrialType,'nonrespond'));
            
            all_trials = go_trials + stop_trials;
            
            % 3.2 Recoding correct and incorrect line by line
            % Be careful with the difference between single (|) or double
            % (||) operators here, and the need for brackets to establish 
            % priority. the code below has been carefully checked by Claire 
            % on 16/07/2020 and should be correct. But changing any 
            % brackets or single to double operators will change the output
            
            for z = 1:Glen
                
                % 3.2.1 RESPONSE (GO) TRIAL
                if strcmp(Sesh_Game.TrialType(z),'respond') == 1
                    
                    % 3.2.1.1 For HR driving....
                    if strcmp(Gams(y),'HR_Driving') == 1
                        % if it was a 'respond' trial, they needed to
                        % release the spacebar
                        
                            % CORRECT GO TRIAL: release spacebar in time
                        if (strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && (Sesh_Game.ReactionTime(z) < 5000) && (Sesh_Game.ReactionTime(z) > 100)
                            Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            
                            % INCORRECT GO TRIAL: they didn't respond
                        elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                                InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            end
                            
                            % GO ERROR: Out of bounds response?
                        elseif (strcmp(Sesh_Game.Response(z),'out of bounds') == 1) | (strcmp(Sesh_Game.Key(z),'spacebar release') == 0 && strcmp(Sesh_Game.Key(z),'none') == 0)
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            Sesh_Game.Correct(z) = 0;
                            go_error = go_error + 1;
                            
                            % TOO LATE: response out of RT bounds    
                        elseif (strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && (Sesh_Game.ReactionTime(z) >= 5000) && (Sesh_Game.ReactionTime(z) < 100)
                            % code in different go-omission outside of RT
                            % limit. 
                            Sesh_Game.Correct(z) = 0;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            go_omissions_all = go_omissions_all + 1;
                            
                        end
                        
                        % 3.2.1.2 For AB Driving....
                    elseif strcmp(Gams(y),'AB_Driving') == 1
                        % because we don't know which was the correct
                        % direction to press (e.g. left or right). we need
                        % to use the 'correct' coded in the raw data here
                        % to match with the arrow key presses to see if
                        % actually correct. 
                        
                        % CORRECT GO TRIAL: Left or right arrow key that
                        % was coded as correct in raw data
                        if (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && Sesh_Game.Correct(z) == 1 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                            Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            
                        % INCORRECT GO TRIAL: they didn't respond
                        elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                                InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            end
                            
                            % GO ERROR: Out of bounds response?
                        elseif isnan(Sesh_Game.Correct(z)) == 1 & (strcmp(Sesh_Game.Key(z),'none') == 0 | strcmp(Sesh_Game.Response(z),'out of bounds') == 1) 
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            Sesh_Game.Correct(z) = 0;
                            go_error = go_error + 1;
                            
                            % TOO LATE: response out of RT bounds    
                        elseif (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && (Sesh_Game.Correct(z) == 1) && (Sesh_Game.ReactionTime(z) >= 5000) && (Sesh_Game.ReactionTime(z) < 100)
                            % code in different go-omission outside of RT
                            % limit. 
                            Sesh_Game.Correct(z) = 0;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            go_omissions_all = go_omissions_all + 1;
                            
                        end
                        
                        % 3.2.1.3 for all the other games
                    elseif (strcmp(Gams(y),'AB_Driving') == 0) && (strcmp(Gams(y),'HR_Driving') == 0) 
                        % KG 05/02/20: leave in 5 seconds and 100 ms window. 

                        % CORRECT: valid key and within RT bounds (changed this
                        % to use new recoding) This is coded as no 'none'
                        % response. This should be correct because all invalid
                        % responses have been removed.
                        if (strcmp(Sesh_Game.Key(z),'spacebar') == 1 | strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && (Sesh_Game.ReactionTime(z) < 5000) && (Sesh_Game.ReactionTime(z) > 100)
                            Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];

                        % KG: Edit 05/02/20: maybe without the time limit here.
                        % So, if they did make a response, then technically
                        % it's not a go-omissions, it's just a fast response.
                        % ASK JOSH. (But for d-prime we need to know the
                        % go-omission... maybe just do it differently. e.g. maybe use two types of 
                        % go-omission. Consensus: ok let's do both. 

                        % MISSED: no response given
                        elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                                InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                            end

                        % INCORRECT: wrong response given?? Should I include
                        % this here??
                        elseif (strcmp(Sesh_Game.Response(z),'out of bounds') == 1) | (strcmp(Sesh_Game.Key(z),'spacebar') == 0 && strcmp(Sesh_Game.Key(z),'spacebar release') == 0 && strcmp(Sesh_Game.Key(z),'none') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_error = go_error + 1;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];

                        % TOO LATE: response out of RT bounds    
                        elseif (strcmp(Sesh_Game.Key(z),'spacebar') == 1 | strcmp(Sesh_Game.Key(z),'spacebar release') == 1) && (Sesh_Game.ReactionTime(z) >= 5000) && (Sesh_Game.ReactionTime(z) < 100)
                            % code in different go-omission outside of RT
                            % limit. 
                            Sesh_Game.Correct(z) = 0;
                            go_omissions_all = go_omissions_all + 1;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            InCorr_goRT = [InCorr_goRT; Sesh_Game.ReactionTime(z)];
                        end
                        
                    end
                    
                % 3.2.2 NO RESPONSE (NO-GO) TRIAL
                elseif (strcmp(Sesh_Game.TrialType(z),'inhibit') == 1 | strcmp(Sesh_Game.TrialType(z),'nonrespond') == 1)
                    % save SSD
                    ssd = [ssd; Sesh_Game.StopSignalStartTime(z)];
                    
                    % this is the same for all games. 
                    % CORRECT: no response given
                    if (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                        Sesh_Game.Correct(z) = 1;
                        correct = correct + 1;
                        correct_inhibits = correct_inhibits + 1;
                        
                    % INCORRECT: false alarm response, responded on inhibit trial
                    elseif (strcmp(Sesh_Game.Key(z),'none') == 0 | strcmp(Sesh_Game.Response(z),'out of bounds') == 1)
                        Sesh_Game.Correct(z) = 0;
                        false_alarms = false_alarms + 1;
                        stop_RT = [stop_RT; Sesh_Game.ReactionTime(z)];
                        
                    end
                    
                end
               
            end
            
            
            % 3.3 Save recoded data with valid responses here
            if s == 1 && y == 1
                Pdata = Sesh_Game;
            else
                Pdata = [Pdata; Sesh_Game];
            end
            

            
            %% Step 4. Calculating SSRT, dprime. conducting analysis of training data.
%              fprintf('Step 4. Now analysing dprime, SSRT, RT, etc.\n\n')

            SSRT1_error = '';
            SSRT2_error = '';
            SSRT3_error = '';
            mean_SSRT1 = 0;
            mean_SSRT2 = 0;
            mean_SSRT3 = 0;
            nRT1 = 0;
            nRT2 = 0;
            nRT3 = 0;

             % 4.1 d-prime
             pHit = 1-(go_omissions_all / go_trials); % probability of hit, so it's 1-probability to miss
             pFa = 1-(correct_inhibits / stop_trials); % probability to falsely hit, so it's 1-probability to inhibit
             
             if (pHit < 0) | (pFa < 0)
                 dprime_val = NaN;
                 dprime_bias = NaN;
             else
                [dprime_val,dprime_bias] = dprime(pHit,pFa);
             end
                 

             % we used to trim RTs to two 2SD of the mean. Taken out now
%            if length(corr_go_RT) ~= 0 
%             % set within 2 SD limit for reaction times
%                 upper_go_RT = mean(corr_go_RT) + (std(corr_go_RT))*2;  
%                 lower_go_RT = mean(corr_go_RT) - (std(corr_go_RT))*2;  
%                 
%                 go_RT_sd = [];
%                 
%                 % To Do: KG 05/02/20: we leave this in, but add a counter
%                 % for keeping track of how many RTs are discarded.
%                 % filter out go RTs that are beyond 2 SDs of the mean
%                 excluded_RTs = 0;
%                 for i = 1:length(corr_go_RT)
%                     if corr_go_RT(i) < upper_go_RT && corr_go_RT(i) > lower_go_RT
%                         go_RT_sd = [go_RT_sd, corr_go_RT(i)]; % accepted
%                     else 
%                         excluded_RTs = excluded_RTs + 1; % rejected
%                     end
%                 end
%                 
%            end
           
                % 4.1 calculate SSRT - 3 methods
                % 13/07/2020: Changed to use pFa rather than Pgo_Om, since
                % false alarms are used to calculate  SSRT
%                 pGo_om = (go_omissions / go_trials);
                % From Verbruggen et al. 2019 Elife - p_values =  p[respond/stop
                % signal] (so a false alarm). Using ALL go RT here now as well.
                
                combined_go_RT = all_goRT;
                combined_go_RT = sort(combined_go_RT);
                
                % checking whether there has been a false alarm response
                % at all (if not, SSRT can't be accurately measured, and
                % participants likely employed slowing of some kind).
                if isempty(stop_RT) == 1
                    stop_RT = 0;
                end
                
                % 13/07/2020: UPDATE. Now only measure SSRT if this holds.
                % From Verbruggen et al 2019 Elife.
                if (mean(stop_RT) > mean(combined_go_RT))
                    mean_SSRT1 = 'NaN';
                    mean_SSRT2 = 'NaN';
                    mean_SSRT3 = 'NaN';
                    nRT1 = 'NaN';
                    nRT2 = 'NaN';
                    nRT3 = 'NaN';
                    SSRT1_error = 'stop RT larger than all go rt';
                    SSRT2_error = 'stop RT larger than all go rt';
                    SSRT3_error = 'stop RT larger than all go rt';
                
                    % mean Stop RT is not greater than ALL go RTs
                    % Also the SSD exists
                elseif (isempty(ssd) == 0) & (isnan(ssd) == 0)        
                    
                    mean_SSD = mean(ssd); % this is only calculated once here
                    p_values = false_alarms / stop_trials; % this is also only calculated once here
                    
                    %% SSRT Method 1
                    % p values is the p of go omissions.
                    % then we use the 2SD of the mean corrected go RT, we sort
                    % those. I then discard all the ones that are NaN for some
                    % reason or if they are 0. 

                     n1 = ceil(p_values * length(combined_go_RT));

                     % check here if n is 0 or if it's NaN. 
                     if (n1 ~= 0) && (isnan(n1) == 0)
                        nRT1 = combined_go_RT(n1);
                        mean_SSRT1 = nRT1 - mean_SSD;
                     elseif n1 == 0
                        nRT1 = 0;
                        mean_SSRT1 = 'NaN';
                        SSRT1_error = 'n is 0';
                     end
                 
                 
                    %% SSRT Method 2. Go omission replacement
                    % here we replace all go omissions with the max RT from the
                    % corrected 2SD Go RT. 
                    % 13/07/2020: UPDATE for this method, we include ALL go
                    % reaction times, also the incorrect ones or out of bounds
                    % ones. according to Verbruggen 2019 elife paper.
                    % all go trials with a response error are included, also
                    % with the wrong go-response, or an out-of-bounds response.

                    % use this one all_go_RT

                    % SSRT should not be estimated, if the reaction time for
                    % unsuccesful stop trials is longer than the go RT on ALL
                    % go trials.
                    
                    combined_go_RT2 = combined_go_RT;
                    addRTs = [];
                    

                    % 13/07/2020: Redid this, adding didn't work properly.
                        if go_omissions ~= 0
                            addRTs = zeros(go_omissions,1);
                            % replace missing go-trial responses with the
                            % maximum RT value of ALL go responses
                            for i = 1:length(addRTs)
                                addRTs(i) = max(all_goRT);
                            end
                            combined_go_RT2 = [combined_go_RT; addRTs];
                        end

                        n2 = ceil(p_values * length(combined_go_RT2));

                         if (n2 ~= 0) && (isnan(n2) == 0)
                             nRT2 = combined_go_RT2(n2);
                             mean_SSRT2 = nRT2 - mean_SSD;
                         elseif n2 == 0
                             nRT2 = 0;
                             mean_SSRT2 = 'NaN';
                             SSRT2_error = 'n value at 0';
                         else
                             nRT2 = 0;
                             mean_SSRT2 = 'NaN';
                             SSRT2_error = 'n value invalid';
                              
                         end


                     %% SSRT Method 3. adjusting p(respond|signal)
                     % this is the formula from the Verbruggen paper. 
                     % here I used non-corrected RT.
                     % TO DO edit 05/02/20: Use the corrected RT rather than
                     % Go_RT
                     p_val_adj = 1-( (correct_inhibits/stop_trials - go_omissions/go_trials) / (1-(go_omissions/go_trials)));

    %                  n3 = ceil(p_val_adj * length(go_RT)); % used uncorrected
    %                  RT

                     % 13/07/2020: UPDATE, edited this to use ALL go reaction
                     % times rather than the 2SD reaction times.
                     n3 = ceil(p_val_adj * length(combined_go_RT));

    %                  go_RT_sd = sort(go_RT_sd); % already done previously

                     if (n3 ~= 0) && (length(combined_go_RT) >= n3) && (isnan(n3) == 0)
                         nRT3 = combined_go_RT(n3);
                         mean_SSRT3 = nRT3 - mean_SSD;
                     elseif length(combined_go_RT) < n3 % take the last value here?
                         nRT3 = combined_go_RT(end);
                         SSRT3_error = 'took last RT, length(RT) < n3';
                     elseif n3 == 0
                         nRT3 = 0;
                         mean_SSRT3 = 'NaN';
                         SSRT3_error = 'n value at 0';
                     else
                         nRT3 = 0;
                         mean_SSRT3 = 'NaN';
                         SSRT3_error = 'n value invalid';
                     end


                elseif(isempty(ssd) == 1) | (isnan(ssd) == 1)
                     mean_SSD = 'NaN';
                     SSRT1_error = 'SSD is empty or NaN';
                end
       

%            else % in case it can't be calculated for any reason. 
%                % what to do with negative SSRTs? --> probably exclude later
%                
%                mean_SSRT1 = [];
%                mean_SSRT2 = [];
%                mean_SSRT3 = [];
%            end
           
           % logging negative SSRTs or emtpy SSRTs
           if isempty(mean_SSRT1) == 1
               mean_SSRT1 = 'NaN';
               SSRT1_error = 'SSRT1 is empty';
           elseif mean_SSRT1 < 0 
%                mean_SSRT1 = 'NaN';
               SSRT1_error = 'SSRT1 is negative';
           end
           
           if isempty(mean_SSRT2) == 1  
               mean_SSRT2 = 'NaN';
               SSRT2_error = 'SSRT2 is empty';
           elseif mean_SSRT2 < 0 
               %mean_SSRT2 = 'NaN';
               SSRT2_error = 'SSRT2 is negative';
           end
           
           if isempty(mean_SSRT3) == 1
               mean_SSRT3 = 'NaN';
               SSRT3_error = 'SSRT3 is empty';
           elseif mean_SSRT3 < 0 
               %mean_SSRT3 = 'NaN';
               SSRT3_error = 'SSRT3 is negative';
           end
           
           if isempty(mean_SSD) == 1 
               mean_SSD = 'NaN';
           end
           
           % remove SSRT if all SSRTs are invalid (in the next cleaning
           % script)
           if (strcmp(mean_SSRT1, 'NaN')) == 1 && (strcmp(mean_SSRT2, 'NaN')) == 1 && (strcmp(mean_SSRT3, 'NaN')) == 1
               FullSSRTExclude = 1;
               
           elseif mean_SSRT1 < 0 & mean_SSRT2 < 0 & mean_SSRT3 < 0
               FullSSRTExclude = 1;
           else
               FullSSRTExclude = 0;
           end
                 
                 %% save variables
                output.Participant = IDs(pp);
                output.Group = 1; % experimental group is group 1
                output.Tot_session = Tot_session;
                output.Inc_session = Tot_session;
                output.Game = Gams(y);
                output.BonusGames = Tot_Bonus;
                output.TotalTrials = all_trials;
                output.Perc_inhibitTrials = (100*stop_trials) / all_trials;
                output.Perc_correct = (100*correct) / all_trials;
                output.CorrResponses = correct;
                output.hits = hits;
                output.go_trials = go_trials;
                output.go_omissions = go_omissions;
                output.go_omissions_all = go_omissions_all;
                output.go_errors = go_error;
                output.P_go_errors = go_error / go_trials;
                output.stop_trials = stop_trials;
                output.correct_inhibits = correct_inhibits;
                output.false_alarms = false_alarms;
                output.P_go_omission = go_omissions_all / go_trials;
                output.P_Hit = hits / go_trials;
                output.P_false_alarm = pFa;
                output.P_corr_inhibit = correct_inhibits / stop_trials;
                output.P_val_adjusted = p_val_adj;
                output.dprime = dprime_val;
                output.dprime_bias = dprime_bias;
                output.mean_all_goRT = mean(all_goRT);
                output.mean_stopRT = mean(stop_RT);
                output.mean_SSD = mean_SSD;
                output.SSD_std = std(ssd);
                output.mean_SSRT1 = mean_SSRT1;
                output.mean_SSRT2 = mean_SSRT2;
                output.mean_SSRT3 = mean_SSRT3;
                output.SSRT1_nRT = nRT1;
                output.SSRT2_nRT = nRT2;
                output.SSRT3_nRT = nRT3;
                output.SSRT1_error_msg = SSRT1_error;
                output.SSRT2_error_msg = SSRT2_error;
                output.SSRT3_error_msg = SSRT3_error;
                output.FullSSRTExclude = FullSSRTExclude;
                output.mean_all_goRT2 = mean(combined_go_RT2);
                output.mean_Corr_goRT = mean(Corr_goRT);
                output.mean_InCorr_goRT = mean(InCorr_goRT);
                output.std_all_goRT = std(all_goRT);
                output.std_combined_goRT2 = std(combined_go_RT2);
                output.std_Corr_goRT = std(Corr_goRT);
                output.std_InCorr_goRT = std(InCorr_goRT);
                output.std_StopRT = std(stop_RT);
                output.CovVar_all_goRT = std(all_goRT) / mean(all_goRT);
                output.CovVar_all_goRT2 = std(combined_go_RT2) / mean(combined_go_RT2);
                output.CovVar_Corr_goRT = std(Corr_goRT) / mean(Corr_goRT);
                output.CovVar_InCorr_goRT = std(InCorr_goRT) / mean(InCorr_goRT);
                output.CovVar_StopRT = std(stop_RT) / mean(stop_RT);
                
                %%% save line by line
                Final_EXP_output = [Final_EXP_output,output];
                
              
        end
                 
            
    end
    
    Final_EXP_Pdata = [Final_EXP_Pdata;Pdata];
%     Final_EXP_Pdata = struct2table(Final_EXP_Pdata);
    
        
    fprintf('Participant %d completed.\n\n\n',IDs(pp))
    
    
    Measures.Participant = IDs(pp);
    Measures.Group = 1;
    Measures.TotalSessions = max([output.Tot_session]);
    Measures.TotalBonusGames = max([output.BonusGames]);
    Measures.PercentageBonusDone = (100*max([output.BonusGames]))/max([output.Tot_session]);
    
    Extra_EXP_Measures = [Extra_EXP_Measures, Measures];

    
        
end

Extra_EXP_Measures = struct2table(Extra_EXP_Measures);
writetable(Final_EXP_Pdata,'Cleaned_PPData_EXP.csv','Delimiter',',')
writetable(Extra_EXP_Measures,'Extra_EXP_Measures.csv','Delimiter',',')
    
% save final output
fprintf('COMPLETED. saving all...\n\nThe outputted final datasets will be:\n\n"Final_EXP_output.mat"\n\n"Total_game_cleaning_log_EXP.mat"\n\n"Cleaned_PPData_EXP.mat"\n\nand are saved in the current folder.\n\n')
    save Final_EXP_output.mat Final_EXP_output
    save Total_game_cleaning_log_EXP.mat Total_Game_Rec
    save Cleaned_PPData_EXP.mat Final_EXP_Pdata
    save Extra_EXP_Measures.mat Extra_EXP_Measures
   
Final_EXP_output = struct2table(Final_EXP_output);
writetable(Final_EXP_output,'Final_EXP_output.csv','Delimiter',',')
    
end

