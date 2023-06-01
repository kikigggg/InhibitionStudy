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

clc;

%% Step 0. Importing data, selecting relevant columns
% import data
fprintf('Importing main data file, finding participant numbers and removing uneccessary columns...\n\n')
qdat = readtable('OCT_Pilot_Experimental.csv');

% remove unnecessary columns
% these columns refer to unused Id numbers, NaN columns etc
columnIndicesToDelete = [2 4 5 15 16 17 18 25 26 27 42 43]; 
qdat(:,columnIndicesToDelete) = [];

% first, recode sessions per date
% find all participants. We have 21 participants in the Action select group
IDs = unique(qdat.ParticipantPublicID);

Final_Exp_output = [];
Final_Pdata = [];
Total_Game_Rec = [];
Pdata = [];

%% Loop through participants
%fprintf('\nStarting to loop through participants.\n');

for pp = 1:length(IDs)
   %% Step 1. Recode session by date
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
        
        % 1.5 subset bonus games and remove bonus game trials (we will
        % only use this as a motivation measure, because the trials for
        % a bonus game are shorter)
        Bonus_Game = P_Sesh(P_Sesh.BonusGame == 1,:);

        if size(Bonus_Game,1) ~= 0 % bonus game subset not empty
            Bonus = 1;
            fprintf('Bonus game in session, logged and trials removed.\n')
        else
            Bonus = 0;
        end

        % remove bonus game trials
        P_Sesh(P_Sesh.BonusGame == 1,:) = [];
        Gams = unique(P_Sesh.Game); % find remaining games
        
        include = 'yes';
        
        % KG. 05/02/20 TO DO: add in check if length session is not >=2, throw away and skip to
        % next. 
        if length(Gams) < 2
            include = 'no';
            continue;
        end

        % session counter for all included sessions (these were
        % sessions with at least 2 games played)
        Inc_session = Inc_session + 1;

        fprintf('Session included? %s\n\n', include)
        %fprintf('Actual current session: %d.\n\nNow executing Step 2. cleaning invalid responses.\n\n',Inc_session)

        P_Sesh.IncSessions(:) = Inc_session;

        
        %% Step 2. Clean invalid responses and recode trial numbers per game inside a session
        for y = 1:length(Gams)

            % 2.1 Subset the trials per game
%             currG = string(Gams(y));
%             fprintf('%d: %s\n\n',y,currG)

            % select all rows for that game and see how many trials
            Game_recode = P_Sesh(strcmp(P_Sesh.Game,Gams(y)),:); 
            Tot_trials = size(Game_recode,1);

            % 2.1 recode new trial numbers per game (we need to do this due
            % to mis labeling of sessions in raw data)
            new_trial_nums = (1:Tot_trials)';
            Game_recode.NewTrials = new_trial_nums;
               
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
                   Max_allowed_Trials = 500;
                   Game_num = 1;
                   error = 0;

               elseif strcmp(Gams(y),'Chest_Picking') == 1
                   % For chest picking, the mean amount of trials was 119.
                   % SD was 28 and 3SD 83. Trials over M + 3SD (202) will
                   % now be excluded
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 202;
                   Game_num = 2;
                   error = 0;

               elseif strcmp(Gams(y),'Treasure_Collect') == 1
                   % For treasure collect, mean trials were 134, SD was 32,
                   % and 3SD was 97. Trials over 231 will now be excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 231;
                   Game_num = 3;
                   error = 0;

               elseif strcmp(Gams(y),'Conveyor_Belt') == 1
                   % For conveyor belt, the mean was 90, SD was 17, and 3SD
                   % was 50. Trials over 140 will now be excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 140;
                   Game_num = 4;
                   error = 0;

               elseif strcmp(Gams(y),'AB_Driving') == 1
                   % For AB driving, the mean of trials was 93, SD was 27,
                   % 3SD was 82. Trials over 175 will now be excluded.
                   validResp = {'none', 'ArrowLeft', 'ArrowRight'};
                   Max_allowed_Trials = 175;
                   Game_num = 5;
                   error = 0;

               elseif strcmp(Gams(y),'HR_Driving') == 1
                   % For HR driving, the mean of trials will be 99, the SD
                   % was 31, 3SD 94, and trials over 193 now excluded.
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 193;
                   Game_num = 6;
                   error = 0;

               else
                   error = 'Error!';
                   Max_allowed_Trials = 500;
                end
               
               % 2.3 log presence of bonus game completed for motivation
                if y == 1 % only log one instance of a bonus game completed per session for transparency.
                    BonusPresent = Bonus;
                else
                    BonusPresent = NaN;
                end
                
                % save before cleaning
                Game_Rec_EXP.Particpant = IDs(pp);
                Game_Rec_EXP.Session = Inc_session;
                Game_Rec_EXP.Game = Gams(y);
                Game_Rec_EXP.GameNo = Game_num;
                Game_Rec_EXP.BonusCompThisSession = BonusPresent;
                Game_Rec_EXP.Tot_trials = Tot_trials; 
                
                % 2.4 trim games that went on too long
                Game_recode(Game_recode.NewTrials > Max_allowed_Trials,:) = [];
                TooLongTrialRem = size(Game_recode,1);
                
                % if both 'spacebar' and 'spacebar release' are present,
                % we log reaction time for both presses separately so we
                % can later check if we should only include one type of
                % spacebar key press
                % UPDATE: for Experimental, there was only 1 session this
                % was the case, and there was no difference in RT between
                % the keypresses as measured by a ttest (independent
                % samples, because different length of trials)
                % p = .4071
                if any(strcmp(Game_recode.Key,'spacebar')) == 1 && any(strcmp(Game_recode.Key,'spacebar release')) == 1
                    
                    % subset per press
                    SB_P = Game_recode(strcmp(Game_recode.Key,'spacebar'),:);
                    SB_R = Game_recode(strcmp(Game_recode.Key,'spacebar release'),:);
                    
                    % get reaction time (do we need mean RT here)
                    Game_Rec_EXP.SpaceP_RT = SB_P.ReactionTime;
                    Game_Rec_EXP.SpaceR_RT = SB_R.ReactionTime;

                else
                    Game_Rec_EXP.SpaceP_RT = NaN;
                    Game_Rec_EXP.SpaceR_RT = NaN;
                end
                
                % 2.5 clean invalid key responses here
                KeysUsed = unique(Game_recode.Key); % check which keys were used
                Game_recode(~ismember(Game_recode.Key,validResp),:) = []; % remove invalid keys here
                InvalidsRem = size(Game_recode,1); % how many trials were removed for invalid keys
                ExcludedKeys = KeysUsed(~ismember(KeysUsed,validResp))'; % which keys were excluded, if they were. I tried 'setdiff' and '~ismember'
                
                % check if there aren't just 'none' presses left for a game
                % with full or partial invalid responses.
                if strcmp(unique(Game_recode.Key),'none') == 1
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
                Game_Rec_EXP.RemTrialsTooLong = Tot_trials - TooLongTrialRem;
                Game_Rec_EXP.RemInvKeyResps = TooLongTrialRem - InvalidsRem;
                Game_Rec_EXP.KeysExcluded = ExcludedKeys;
                Game_Rec_Exp.FullGameExcluded = FullGameExcl;
                     
            % save log of data cleaning for this pp (and all pps)
            Total_Game_Rec = [Total_Game_Rec,Game_Rec_EXP];
            
            % save remaining valid responses for further analysis for all
            % pps
            if s == 1 && y == 1
                Pdata = Game_recode;
            else
                Pdata = [Pdata; Game_recode];
            end
            
           % rename this pps cleaned data to the format we use further down 
            Sesh_Game = Game_recode;
            
            
            %% Step 3. Recoding correct and incorrect responses 
            %fprintf('Step 2. Re-coding correct and incorrect responses.\n\n') % just for logging on screen
            
            % empty variables for every game in a session
            go_RT = [];
            go_RT2 = [];
            stop_RT = [];
            ssd = [];
            hits = 0;
            go_omissions = 0;
            go_omissions_all = 0;
            false_alarms = 0;
            correct_inhibits = 0;
            
            % length of (remaining) game trials after cleaning
            Glen = size(Sesh_Game);
            
            % 3.1 calculate total number of go and no-go trials 
            go_trials = sum(strcmp(Sesh_Game.TrialType,'respond'));
            stop_trials = sum(strcmp(Sesh_Game.TrialType,'inhibit'));
            
            
            % 3.2 Recoding correct and incorrect line by line
            for z = 1:Glen(1)
                
                % RESPONSE (GO) TRIAL
                if strcmp(Sesh_Game.TrialType(z),'respond') == 1
                    
                    % KG 05/02/20: leave in 5 seconds and 100 ms window. 
                    
                    % CORRECT: valid key and within RT bounds (changed this
                    % to use new recoding) This is coded as no 'none'
                    % response. This should be correct because all invalid
                    % responses have been removed.
                    if strcmp(Sesh_Game.Key(z),'none') == 0 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                        Sesh_Game.Correct(z) = 1; % recoding the correct / incorrect column in file
                        hits = hits + 1;
                        go_RT = [go_RT, Sesh_Game.ReactionTime(z)];
                    
                    % KG: Edit 05/02/20: maybe without the time limit here.
                    % So, if they did make a response, then technically
                    % it's not a go-omissions, it's just a fast response.
                    % ASK JOSH. (But for d-prime we need to know the
                    % go-omission... maybe just do it differently. e.g. maybe use two types of 
                    % go-omission. Consensus: ok let's do both. 
                  
                    % MISSED: no response given
                    elseif strcmp(Sesh_Game.Key(z),'none') == 1
                        Sesh_Game.Correct(z) = 0;
                        go_omissions = go_omissions + 1;
                        go_omissions_all = go_omissions_all + 1;
                        
                    % INCORRECT: wrong response given?? Should I include
                    % this here??
                    elseif strcmp(Sesh_Game.Key(z),'none') == 0
                        Sesh_Game.Correct(z) = 0;
                        go_omissions = go_omissions + 1;
                        go_omissions_all = go_omissions_all + 1;
                        
                    % TOO LATE: response out of RT bounds    
                    elseif strcmp(Sesh_Game.Key(z),'none') == 0 && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                        % code in different go-omission outside of RT
                        % limit. 
                        Sesh_Game.Correct(z) = 0;
                        go_omissions_all = go_omissions_all + 1;
                    end
                    
                % NO RESPONSE (NO-GO) TRIAL
                elseif strcmp(Sesh_Game.TrialType(z),'inhibit') == 1 || strcmp(Sesh_Game.TrialType(z),'nonrespond') == 1
                    % save SSD
                    ssd = [ssd, Sesh_Game.StopSignalStartTime(z)];
                    
                    % CORRECT: no response given
                    if strcmp(Sesh_Game.Key(z),'none') == 1
                        Sesh_Game.Correct(z) = 1;
                        correct_inhibits = correct_inhibits + 1;
                        
                    % INCORRECT: false alarm response, responded on inhibit trial
                    elseif strcmp(Sesh_Game.Key(z),'none') == 0
                        Sesh_Game.Correct(z) = 0;
                        false_alarms = false_alarms + 1;
                        stop_RT = [stop_RT, Sesh_Game.ReactionTime(z)];
                        
                    end
                    
                end
               
            end
            
            %% Step 4. Calculating SSRT, dprime. conducting analysis of training data.
%              fprintf('Step 4. Now analysing dprime, SSRT, RT, etc.\n\n')
             
             % 4.1 d-prime
             pHit = 1-(go_omissions_all / go_trials);
             pFa = 1-(correct_inhibits / stop_trials);
             [dprime_val,dprime_bias] = dprime(pHit,pFa);
                 
            % 4.1 calculate SSRT - 3 methods
           if length(go_RT) ~= 0 
            % set within 2 SD limit for reaction times
                upper_go_RT = mean(go_RT) + (std(go_RT))*2;  
                lower_go_RT = mean(go_RT) - (std(go_RT))*2;  
                
                go_RT_sd = [];
                
                % To Do: KG 05/02/20: we leave this in, but add a counter
                % for keeping track of how many RTs are discarded.
                % filter out go RTs that are beyond 2 SDs of the mean
                excluded_RTs = 0;
                for i = 1:length(go_RT)
                    if go_RT(i) < upper_go_RT && go_RT(i) > lower_go_RT
                        go_RT_sd = [go_RT_sd, go_RT(i)]; % accepted
                    else 
                        excluded_RTs = excluded_RTs + 1; % rejected
                    end
                end
                
                
                %% SSRT Method 1
                % p values is the p of go omissions.
                % then we use the 2SD of the mean corrected go RT, we sort
                % those. I then discard all the ones that are NaN for some
                % reason or if they are 0. 
                pGo_om = (go_omissions / go_trials);
                p_values = pGo_om;
                 n = ceil(p_values * length(go_RT_sd));
                 
                 go_RT_sd = sort(go_RT_sd);
                 
                 % check here if n is 0 or if it's NaN. 
                 if n ~= 0 && isnan(n) == 0
                     nRT = go_RT_sd(n);
                 elseif n == 0
                    nRT = go_RT_sd(n+1);
                 else
                     nRT = go_RT_sd(end);
                 end
                 
                 mean_SSD = mean(ssd); % this is only calculated once here
                 mean_SSRT1 = nRT - mean_SSD;
                 
                %% SSRT Method 2. Go omission replacement
                % here we replace all go omissions with the max RT from the
                % corrected 2SD Go RT
                go_RT2 = go_RT_sd;
                if go_omissions ~= 0
                    for i = 1:length(go_omissions)
                        go_RT2 = [go_RT2, max(go_RT_sd)];
                    end
                end
                
                n2 = ceil(p_values * length(go_RT2));
                go_RT2 = sort(go_RT2);
                
                 if n2 ~= 0 && isnan(n) == 0
                     nRT = go_RT2(n2);
                 elseif n2 == 0
                    nRT = go_RT2(n2+1);
                 else
                    nRT = go_RT2(end); 
                 end
                 
                 mean_SSRT2 = nRT - mean_SSD;
                 
                 %% SSRT Method 3. adjusting p(respond|signal)
                 % this is the formula from the Verbruggen paper. 
                 % here I used non-corrected RT.
                 % TO DO edit 05/02/20: Use the corrected RT rather than
                 % Go_RT.m
                 p_val_adj = 1-((correct_inhibits/stop_trials - go_omissions/go_trials) / (1-(go_omissions/go_trials)));
                 
%                  n3 = ceil(p_val_adj * length(go_RT)); % used uncorrected
%                  RT

                 n3 = ceil(p_val_adj * length(go_RT_sd));
                 
%                  go_RT_sd = sort(go_RT_sd); % already done previously
                 
                 if n3 ~= 0 && length(go_RT_sd) >= n3 && isnan(n) == 0
                     nRT = go_RT_sd(n3);
                 elseif length(go_RT_sd) < n3
                     nRT = go_RT_sd(end);
                 elseif n3 == 0
                    nRT = go_RT_sd(n3+1);
                 else
                     nRT = go_RT_sd(end);
                 end
                
                 mean_SSRT3 = nRT - mean_SSD;

                 % should we exclude them here? 
%            elseif mean(stop_RT) > mean(go_RT) && is.nan(stop_RT) == 0
%                disp(mean(stop_RT))
%                disp(mean(go_RT))
%                mean_SSRT1 = NaN;
%                mean_SSRT2 = NaN;
%                mean_SSRT3 = NaN;
           else % in case it can't be calculated for any reason. 
               % what to do with negative SSRTs? --> probably exclude later
               mean_SSRT1 = [];
               mean_SSRT2 = [];
               mean_SSRT3 = [];
           end
           
           % removing negative SSRTs
           if mean_SSRT1 < 0
               mean_SSRT1 = NaN;
           end
           
           if mean_SSRT2 < 0
               mean_SSRT2 = NaN;
           end
           
           if mean_SSRT3 < 0
               mean_SSRT3 = NaN;
           end
                 
                 %% save variables
                output.Participant = IDs(pp);
                output.Tot_session = Tot_session;
                output.Inc_session = Inc_session;
                output.Game = Gams(y);
                output.hits = hits;
                output.go_trials = go_trials;
                output.go_omissions = go_omissions;
                output.go_omissions_all = go_omissions_all;
                output.stop_trials = stop_trials;
                output.correct_inhibits = correct_inhibits;
                output.false_alarms = false_alarms;
                output.dprime = dprime_val;
                output.dprime_bias = dprime_bias;
                output.mean_SSD = mean_SSD;
                output.mean_SSRT1 = mean_SSRT1;
                output.mean_SSRT2 = mean_SSRT2;
                output.mean_SSRT3 = mean_SSRT3;
                output.P_go_omission = go_omissions / go_trials;
                output.P_false_alarm = pFa;
                output.mean_goRT = mean(go_RT);
                output.mean_goRT_sd = mean(go_RT_sd);
                output.mean_stopRT = mean(stop_RT);
                output.excluded_RTs = excluded_RTs;
                output.goRT_SD = std(go_RT);
                output.goRT_sd_SD = std(go_RT_sd);
                output.goRT_CovVar = std(go_RT) / mean(go_RT);
                output.goRT_sd_CovVar = std(go_RT_sd) / mean(go_RT_sd);
                output.fullPdata = Pdata;
                
                %%% save line by line
                Final_Exp_output = [Final_Exp_output,output];
                Final_Pdata = [Final_Pdata; Pdata];
                
                      
        end
                 
%                  save output.mat output   
%                  save Participant.mat Participant
            
    end
        
    fprintf('Participant %d completed.\n\n\n',IDs(pp))
        
end
    
% save final output
fprintf('COMPLETED. saving all...\n\nThe outputted final datasets will be:\n\n"Final_Exp_output.mat"\n\n"Total_game_cleaning_log.mat"\n\n"CleanedPPData.mat"\n\nand are saved in the current folder.\n\n')
    save Final_Exp_output.mat Final_Exp_output
    save Total_game_cleaning_log_EXP.mat Total_Game_Rec
    save CleanedPPData_EXP.mat Final_Pdata
    

