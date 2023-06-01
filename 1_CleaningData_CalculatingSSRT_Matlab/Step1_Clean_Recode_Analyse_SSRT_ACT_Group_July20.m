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

function Step1_Clean_Recode_Analyse_SSRT_ACT_Group_July20

% clc;

%% Step 0. Importing data, selecting relevant columns
% import data
fprintf('\n\nWorking on Action Select Group data.\n\n')
fprintf('Importing main data file, finding participant numbers and removing uneccessary columns...\n\n')
qdat = readtable('OCT_Pilot_Action_Select.csv');

% remove unnecessary columns
% these columns refer to unused Id numbers, NaN columns etc
columnIndicesToDelete = [2 4 5 15 16 17 18 25 26 27 42 43]; 
qdat(:,columnIndicesToDelete) = [];

% first, recode sessions per date
% find all participants. We have 21 participants in the Action select group
IDs = unique(qdat.ParticipantPublicID);

Extra_ACT_Measures = [];
Final_ACT_output = [];
Final_ACT_Pdata = [];
Total_Game_Rec = [];
Pdata = [];

%% Loop through participants

% per participant
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
    
    Tot_Bonus = 0;
    Tot_session = 0;
    Inc_session = 0;
    SpacebarKey = [];
    SpacebarRelease = [];
    
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
        
        BonusPresent = 0; % initialise to 0
       

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
   
            % see which game it is, to see which key presses we will
            % code as valid responses. The number for Max_allowed_trials
            % was determined by using these analyses first without cutoff,
            % then finding the mean amount of trials per game across all
            % participants, then finding the standard deviation for these
            % (this included some participants who had a high number of
            % trials). Then we set the limit as mean + 3SD of number of
            % trials. We used 3SD since the number of trials was determined
            % by duration if all went well, but in some cases sessions went
            % overtime. We used the Total_Game_Rec.Tot_Trials from the 
            % 'Trial_Count' scripts for this. Numbers are rounded.
            
                if strcmp(Gams(y),'Mining') == 1 
                   % For mining, the only correct responses are 'spacebar
                   % single' and 'spacebar double', although 'enter' is
                   % also in the list of responses. 
                   validResp = {'none', 'spacebar single', 'spacebar double', 'enter'};
                   % For mining, the mean amount of trials per participant
                   % is 107. The SD is 33, and 3SD is 100 trials. So all
                   % trials over M+3SD length (207) will now be excluded.
                   Max_allowed_Trials = 207;
                   Min_needed_Trials = 7;
                   Game_num = 1;
                   error = 0;

               elseif strcmp(Gams(y),'Chest_Picking') == 1
                   % For Chest picking, the only correct responses should
                   % be 'spacebar single' and 'spacebar double' 
                   validResp = {'none', 'spacebar single', 'spacebar double', 'enter'};
                   % For chest picking, the mean amount of trials is 109.
                   % the SD is 20 and 3SD is 59. So all trials over M+3SD
                   % length (167) will now be excluded.
                   Max_allowed_Trials = 167;
                   Min_needed_Trials = 50;
                   Game_num = 2;
                   error = 0;

               elseif strcmp(Gams(y),'Treasure_Collect') == 1 
                   % For mining, the only correct responses are 'spacebar
                   % single' and 'spacebar double', although 'enter' is
                   % also in the list of responses. 
                   validResp = {'none', 'spacebar single', 'spacebar double','enter'};
                   % For Treasure collect, the mean amount of trials per
                   % participant is 128. the SD is 30 and 2SD is 91 trials.
                   % So all trials over M+3SD length(220) will now be
                   % excluded
                   Max_allowed_Trials = 220; % calculated without excluding any
                   Min_needed_Trials = 37;
                   Game_num = 3;
                   error = 0;

               elseif strcmp(Gams(y),'Conveyor_Belt') == 1
                   % The mean for conveyor belt for trials was 105, SD was
                   % 41, and 3SD is 122. All trials over 227 ar now
                   % excluded.
                   validResp = {'none', 'spacebar single', 'spacebar double','enter'};
                   Max_allowed_Trials = 227;
                   Min_needed_Trials = 0;
                   Game_num = 4;
                   error = 0;

               elseif strcmp(Gams(y),'AB_Driving') == 1
                   % For AB driving, the mean was 84. SD was 18, 3SD was
                   % 55. All trials over 139 now excluded.
                   validResp = {'none', 'ArrowLeft', 'ArrowRight', 'ArrowUp','enter'};
                   Max_allowed_Trials = 139;
                   Min_needed_Trials = 29;
                   Game_num = 5;
                   error = 0;

               elseif strcmp(Gams(y),'HR_Driving') == 1
                   % For HR driving, the correct responses should have been
                   % 'spacebar' and 'enter'. However, we took 'spacebar
                   % double' as a correct action select response too.
                   validResp = {'none', 'spacebar', 'spacebar single', 'spacebar double', 'enter'};
                   % For HR driving, the mean was 94. SD was 41, 3SD was
                   % 122. Trials over 216 now excluded.
                   Max_allowed_Trials = 216;
                   Min_needed_Trials = 0;
                   Game_num = 6;
                   error = 0;

               else
                   error = 'Error!';
                   Max_allowed_Trials = 500;
                   Min_needed_Trials = 0;
                end
               
               % 2.2 log presence of bonus game completed for motivation
                if Game_recode.BonusGame(1) == 1 % bonus game present
                    BonusPresent = 1;
                    Tot_Bonus = Tot_Bonus + 1;
                    fprintf('Bonus game in session: %s. logged.\n',Game_recode.Game{1})
                else
                    BonusPresent = 0;
                end
                
                % save before cleaning
                Game_Rec_ACT.Particpant = IDs(pp);
                Game_Rec_ACT.TotalSessions = Tot_session;
                Game_Rec_ACT.Game = Gams(y);
                Game_Rec_ACT.GameNo = Game_num;
                Game_Rec_ACT.BonusGame = BonusPresent;
                              
                
                % Here, we will just count the presence of key presses for
                % each participant. e.g. arrow keys, enter keys, spacebars,
                % etc.
                a = cellfun(@(x) sum(ismember(Game_recode.Key,'spacebar single')),{'spacebar single'},'un',0);
                Game_Rec_ACT.SingleSpaceOcc = cell2mat(a);
                b = cellfun(@(x) sum(ismember(Game_recode.Key,'spacebar double')),{'spacebar double'},'un',0);
                Game_Rec_ACT.DoubleSpaceOcc = cell2mat(b); 
                c = cellfun(@(x) sum(ismember(Game_recode.Key,'spacebar')),{'spacebar'},'un',0);
                Game_Rec_ACT.SpaceOcc = cell2mat(c); 
                d = cellfun(@(x) sum(ismember(Game_recode.Key,'enter')),{'enter'},'un',0);
                Game_Rec_ACT.EntOcc = cell2mat(d);
                e = cellfun(@(x) sum(ismember(Game_recode.Key,'ArrowLeft')),{'ArrowLeft'},'un',0);
                Game_Rec_ACT.LeftArrOcc = cell2mat(e);   
                f = cellfun(@(x) sum(ismember(Game_recode.Key,'ArrowRight')),{'ArrowRight'},'un',0);
                Game_Rec_ACT.RightArrOcc = cell2mat(f);
                g = cellfun(@(x) sum(ismember(Game_recode.Key,'ArrowUp')),{'ArrowUp'},'un',0);
                Game_Rec_ACT.UpArrOcc = cell2mat(g);    
                h = cellfun(@(x) sum(ismember(Game_recode.Key,'none')),{'none'},'un',0);
                Game_Rec_ACT.NoPressOcc = cell2mat(h);
                                   
                
                 % 2.4 remove games that were too short
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
                % also, check if more than 50% of the presses in the game
                % were invalid. If true, remove the whole game.
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
                Game_Rec_ACT.Tot_trials = Tot_trials; 
                Game_Rec_ACT.New_Tot_trials = size(Game_recode,1);
                Game_Rec_ACT.Missed_trials = missedtrialsrem;
                Game_Rec_ACT.ValidResps = validResp;
                Game_Rec_ACT.Error = error;
                Game_Rec_ACT.MaxLengthTrials = Max_allowed_Trials;
                Game_Rec_ACT.MinLengthTrials = Min_needed_Trials;
                Game_Rec_ACT.RemTrialsLength = TooLongTrialRem;
                Game_Rec_ACT.RemInvKeyResps = InvalidsRem;
                Game_Rec_ACT.RemInvKeyPerc = PercentageRem;
                Game_Rec_ACT.KeysExcluded = ExcludedKeys;
                Game_Rec_ACT.DayNightVariation = DayNight;
                Game_Rec_ACT.HotColdVariation = HotCold;
                Game_Rec_ACT.FullGameExcluded = FullGameExcl;
                
                % 2.8 skip the rest of the loop if the game was deleted
            if isempty(Game_recode) == 1
                Game_Rec_ACT.FullGameExcluded = 1;
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_ACT];
                continue;  % skip rest of loop
                
            else % save the game log here and continue rest of loop
                % save log of data cleaning for this pp (and all pps)
                Total_Game_Rec = [Total_Game_Rec,Game_Rec_ACT];
            end
                   
           % rename this pps cleaned data to the format we use further down 
            Sesh_Game = Game_recode;
       
            

            %% Step 3. Recoding correct and incorrect responses 
            
            % empty variables for every game in a session
            all_goRT = [];
            Corr_goRT = [];
            inCorr_goRT = [];
            all_Act_Trial_RT = [];
            Corr_Act_Trial_RT = [];
            InCorr_Act_Trial_RT = [];
            ssd = [];
            hits = 0;
            go_error = 0;
            go_omissions = 0;
            go_omissions_all = 0;
            correct = 0;
            miss_actselect = 0;
            corr_actselect = 0;
            wrong_actselect = 0;
            
            % length of (remaining) game trials after cleaning
            Glen = size(Sesh_Game);
            
            % 3.1 calculate total number of trials 
            go_trials = sum(strcmp(Sesh_Game.TrialType,'respond'));
            % there are two types of 'action select trials' they are either
            % labelled as 'inhibit' or 'nonrespond' trials in the data
            act_select_trials = sum(strcmp(Sesh_Game.TrialType,'inhibit')) + sum(strcmp(Sesh_Game.TrialType,'nonrespond'));
            
            all_trials = go_trials + act_select_trials;
            
            % 3.2 Recoding correct and incorrect line by line
            % Be careful with the difference between single (|) or double
            % (||) operators here, and the need for brackets to establish 
            % priority. the code below has been carefully checked by Claire 
            % on 16/07/2020 and should be correct. But changing any 
            % brackets or single to double operators will change the output
            
            for z = 1:Glen(1)
                
                %% 3.2.1 FOR RESPONSE TRIALS, e.g. NOT ACTION SELECT TRIALS
                if strcmp(Sesh_Game.TrialType(z),'respond') == 1
                    
                    % KG 05/02/20: leave in 5 seconds and 100 ms window.                         
                    % KG: Edit 05/02/20: maybe without the time limit here.
                        % So, if they did make a response, then technically
                        % it's not a go-omissions, it's just a fast response.
                        % ASK JOSH. (But for d-prime we need to know the
                        % go-omission... maybe just do it differently. e.g. maybe use two types of 
                        % go-omission. Consensus: ok let's do both.  
                    
                   % 3.2.1.1 for HR driving
                   if strcmp(Gams(y),'HR_Driving') == 1
                       % It's confusing, for HR driving for ACT, the correct
                       % responses are to keep holding space, but on some
                       % trials to either release space or press enter.
                       % However, a 'spacebar' response could also be
                       % correct here, so I've included that for this game
                       % only.
                       
                            % CORRECT GO TRIAL: CORRECT RESPONSE
                       if (strcmp(Sesh_Game.Key(z),'spacebar single') == 1 | strcmp(Sesh_Game.Key(z),'spacebar') == 1) && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                           Sesh_Game.Correct(z) = 1;
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            
                            % MISSED GO TRIAL: NO RESPONE
                       elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            end
                            
                            % INCORRECT GO TRIAL: WRONG RESPONSE (double
                            % response, which should be the only ones left)
                       elseif (strcmp(Sesh_Game.Key(z),'enter') == 1 | strcmp(Sesh_Game.Key(z),'spacebar double') == 1) | (strcmp(Sesh_Game.Response(z),'out of bounds') == 1)
                            Sesh_Game.Correct(z) = 0;
                            go_error = go_error + 1;
                            inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            

                            % MISSED GO TRIAL: TOO LATE / TOO FAST (response out of RT bounds)     
                       elseif (strcmp(Sesh_Game.Key(z),'spacebar single') == 1 | strcmp(Sesh_Game.Key(z),'spacebar') == 1) && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                            % code in different go-omission outside of RT
                            % limit. 
                            Sesh_Game.Correct(z) = 0;
                            go_omissions_all = go_omissions_all + 1;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                       end
 
                   % 3.2.1.2 for AB driving
                   elseif strcmp(Gams(y),'AB_Driving') == 1
                       % For AB driving for action select, the only correct
                       % answers should have been left or right arrow for
                       % respond trials, and the up arrow for the action
                       % select trials. However, spacebar and enter
                       % responses were also taken. I suggest taking 
                       % spacebar, enter and arrowup responses as correct
                       % for action select, but only left/right arrow or
                       % none for respond trials. 
                       
                       % additionally, we have no way of coding for correct
                       % or incorrect responses (as in which direction they needed to press), as this was not logged, so
                       % we have to use the correct column here in the raw data to know if
                       % they had to press left or right. 
                       
                            % CORRECT GO TRIAL: CORRECT RESPONSE
                       if (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && Sesh_Game.Correct(z) == 1 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                            Sesh_Game.Correct(z) = 1;
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                       
                            % MISSED GO TRIAL: NO RESPONSE 
                       elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                                inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                            end
                            
                            % INCORRECT GO TRIAL: WRONG RESPONSE (double
                            % action select response)
                       elseif isnan(Sesh_Game.Correct(z)) == 1 & (strcmp(Sesh_Game.Key(z),'none') == 0 | strcmp(Sesh_Game.Response(z),'out of bounds') == 1) 
                            Sesh_Game.Correct(z) = 0;
                            inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            go_error = go_error + 1;
                           
                           % MISSED GO TRIAL: TOO LATE / TOO FAST (response out of RT bounds)    
                       elseif (strcmp(Sesh_Game.Key(z),'ArrowRight') == 1 | strcmp(Sesh_Game.Key(z),'ArrowLeft') == 1) && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                            Sesh_Game.Correct(z) = 0;
                            go_omissions_all = go_omissions_all + 1;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                       end
                       
                   % 3.2.1.3 for the rest of the games
                   else
                       % For the rest of the games, the correct response is always a single spacebar press.
                       % For the rest of the games, we also removed
                       % 'spacebar' from the correct responses, since we
                       % can't be sure if this is a single or double press.
                       % so only 'spacebar single' is taken as a
                       % correct response for Mining, Treasure Collect,
                       % Conveyor Belt and Chest picking
                        
                            % CORRECT GO TRIAL: SINGLE SPACEBAR PRESS
                        if strcmp(Sesh_Game.Key(z),'spacebar single') == 1 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                            Sesh_Game.Correct(z) = 1;
                            hits = hits + 1;
                            correct = correct + 1;
                            Corr_goRT = [Corr_goRT; Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];

                        	% MISSED GO TRIAL: NO RESPONSE
                        elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            go_omissions = go_omissions + 1;
                            go_omissions_all = go_omissions_all + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                                inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                            end
                            
                            % INCORRECT GO TRIAL: WRONG RESPONSE
                        elseif (strcmp(Sesh_Game.Key(z),'enter') == 1 | strcmp(Sesh_Game.Key(z),'spacebar double') == 1) | (strcmp(Sesh_Game.Response(z),'out of bounds') == 1)
                            Sesh_Game.Correct(z) = 0;
                            go_error = go_error + 1;
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                            inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];

                            % MISSED GO TRIAL: TOO LATE / TOO FAST (response out of RT bounds)      
                        elseif (strcmp(Sesh_Game.Key(z),'spacebar single') == 1) && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                            Sesh_Game.Correct(z) = 0;
                            go_omissions_all = go_omissions_all + 1;
                            inCorr_goRT = [inCorr_goRT, Sesh_Game.ReactionTime(z)];
                            all_goRT = [all_goRT; Sesh_Game.ReactionTime(z)];
                        end
                    
                   end
                   
                %% 3.2.2 Action select trials (different key or double spacebar)
                elseif (strcmp(Sesh_Game.TrialType(z),'inhibit') == 1 | strcmp(Sesh_Game.TrialType(z),'nonrespond') == 1)
                    ssd = [ssd, Sesh_Game.StopSignalStartTime(z)]; % save SSD
                    
                    % 3.2.2.1 All games besides AB Driving
                    if strcmp(Gams(y),'AB_Driving') == 0
                       % For HR driving, 'enter' and 'spacebar double' are
                       % taken as correct act select trial responses.
                       % should we take the same for the other games?
                        % for treasure collect, spacebar double and enter?
                        % for conveyor belt, spacebar double and enter?
                        % for mining, spacebar double and enter?
                        % for chest picking, also double spacebar and
                        % enter?
                       
                            % CORRECT ACT SELECT TRIAL: CORRECT RESPONSE
                       if (strcmp(Sesh_Game.Key(z),'spacebar double') == 1 | strcmp(Sesh_Game.Key(z),'enter') == 1) && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                            Sesh_Game.Correct(z) = 1;
                            correct = correct + 1;
                            corr_actselect = corr_actselect + 1;
                            Corr_Act_Trial_RT = [Corr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            
                            % MISSED ACT SELECT TRIAL: NO RESPONSE
                       elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            miss_actselect = miss_actselect + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                                all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            end
                            
                            % INCORRECT ACT SELECT TRIAL: WRONG RESPONSE
                       elseif (strcmp(Sesh_Game.Key(z),'spacebar single') == 1 | strcmp(Sesh_Game.Key(z),'spacebar') == 1) | (strcmp(Sesh_Game.Response(z),'out of bounds') == 1)
                            Sesh_Game.Correct(z) = 0; 
                            wrong_actselect = wrong_actselect + 1;
                            InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            
                            % MISSED ACT SELECT TRIAL: TOO LATE / TOO FAST (response out of RT bounds)      
                       elseif (strcmp(Sesh_Game.Key(z),'spacebar double') == 1 | strcmp(Sesh_Game.Key(z),'enter') == 1) && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                            Sesh_Game.Correct(z) = 0;
                            miss_actselect = miss_actselect + 1;
                            InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                       end
                       
                    % 3.3.2 for AB driving
                    elseif strcmp(Gams(y),'AB_Driving') == 1
                        % For AB driving, a correct act trial response is
                        % either 'ArrowUp' or 'enter'. 
                        
                        % CORRECT ACT SELECT TRIAL: CORRECT RESPONSE
                       if (strcmp(Sesh_Game.Key(z),'ArrowUp') == 1 | strcmp(Sesh_Game.Key(z),'enter') == 1) && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
                            Sesh_Game.Correct(z) = 1;
                            correct = correct + 1;
                            Corr_Act_Trial_RT = [Corr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            corr_actselect = corr_actselect + 1;
                            
                            % MISSED ACT SELECT TRIAL: NO RESPONSE
                       elseif (strcmp(Sesh_Game.Key(z),'none') == 1) && (strcmp(Sesh_Game.Response(z),'out of bounds') == 0)
                            Sesh_Game.Correct(z) = 0;
                            miss_actselect = miss_actselect + 1;
                            if isempty(Sesh_Game.ReactionTime(z)) == 0
                                InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                                all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            end
                            
                            % INCORRECT ACT SELECT TRIAL: WRONG RESPONSE
                       elseif (strcmp(Sesh_Game.Key(z),'ArrowUp') == 0 | strcmp(Sesh_Game.Key(z),'enter') == 0) | (strcmp(Sesh_Game.Response(z),'out of bounds') == 1) 
                            Sesh_Game.Correct(z) = 0; 
                            InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)]; 
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            wrong_actselect = wrong_actselect + 1;
                            
                            % MISSED ACT SELECT TRIAL: TOO LATE / TOO FAST (response out of RT bounds)      
                       elseif (strcmp(Sesh_Game.Key(z),'ArrowUp') == 1 | strcmp(Sesh_Game.Key(z),'enter') == 1) && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
                            Sesh_Game.Correct(z) = 0;
                            miss_actselect = miss_actselect + 1;
                            InCorr_Act_Trial_RT = [InCorr_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                            all_Act_Trial_RT = [all_Act_Trial_RT, Sesh_Game.ReactionTime(z)];
                       end
                        
                    
                    end
                    
                end
               
            end
            
            % Save recoded data with valid responses here
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
            % should we use wrong responses here as well as missed
             % trials? For go trials only:
             all_wrong_responses = go_omissions_all + go_error;

             pHit = 1-(all_wrong_responses / go_trials);
             pFa = 1-(corr_actselect / act_select_trials); % probability for wrong response during action select trials, so it's 1-correct double presses
             [dprime_val,dprime_bias] = dprime(pHit,pFa);
                 
%             % calculate variables of interest
%            if length(go_RT) ~= 0 
%             %% UPDATE: NEED TO SEE IF ONLY CORRECT RTs SHOULD BE TAKEN HERE??
%             % yes I think only correct
%                
%             % set within 2 SD limit for reaction times
%                 upper_go_RT = mean(go_RT) + (std(go_RT))*2;  
%                 lower_go_RT = mean(go_RT) - (std(go_RT))*2;  
%                 
%                 go_RT_sd = [];
%                 
%                 % To Do: KG 05/02/20: we leave this in, but add a counter
%                 % for keeping track of how many RTs are discarded.
%                 % filter out go RTs that are beyond 2 SDs of the mean
%                 excluded_RTs = 0;
%                 for i = 1:length(go_RT)
%                     if go_RT(i) < upper_go_RT && go_RT(i) > lower_go_RT
%                         go_RT_sd = [go_RT_sd, go_RT(i)]; % accepted
%                     else 
%                         excluded_RTs = excluded_RTs + 1; % rejected
%                     end
%                 end
%                 
%                 if (isempty(go_RT_sd)) == 1
%                     go_RT_sd = 0;
%                 end

                combined_go_RT = all_goRT;
                combined_go_RT = sort(combined_go_RT);
                
                % checking whether there has been a false alarm response
                % at all (if not, SSRT can't be accurately measured, and
                % participants likely employed slowing of some kind).
                if isempty(all_Act_Trial_RT) == 1
                    all_Act_Trial_RT = 0;
                end
                
                % 13/07/2020: UPDATE. Now only measure SSRT if this holds.
                % From Verbruggen et al 2019 Elife.
                if (mean(all_Act_Trial_RT) > mean(combined_go_RT))
                    mean_SSRT1 = 'NaN';
                    mean_SSRT2 = 'NaN';
                    mean_SSRT3 = 'NaN';
                    nRT1 = 'NaN';
                    nRT2 = 'NaN';
                    nRT3 = 'NaN';
                    SSRT1_error = 'stop RT larger than all go rt';
                    SSRT2_error = 'stop RT larger than all go rt';
                    SSRT3_error = 'stop RT larger than all go rt';
                    mean_SSD = mean(ssd);
                    Stim_dur = Sesh_Game.StimulusDuration;
                    p_val_adj = 'NaN';
                
                    % mean Stop RT is not greater than ALL go RTs
                    % Also the SSD exists
                elseif (isempty(ssd) == 0) & (isnan(ssd) == 0)  
                    
                    all_wrong_actselect = wrong_actselect + miss_actselect; % wrong responses + missed responses
                    mean_SSD = mean(ssd); % this is only calculated once here
                    Stim_dur = Sesh_Game.StimulusDuration;
                    p_values = all_wrong_actselect / act_select_trials; % this is also only calculated once here
                    
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
                     p_val_adj = 1-( (corr_actselect/act_select_trials - go_omissions/go_trials) / (1-(go_omissions/go_trials)));

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
                output.Group = 2; % experimental group is group 1
                output.Tot_session = Tot_session;
                output.Inc_session = Tot_session;
                output.Game = Gams(y);
                output.BonusGames = Tot_Bonus;
                output.TotalTrials = all_trials;
                output.Perc_ActSelTrials = (100*act_select_trials) / all_trials;
                output.Perc_correct = (100*correct) / all_trials;
                output.CorrResponses = correct;
                output.hits = hits;
                output.go_trials = go_trials;
                output.go_omissions = go_omissions;
                output.go_omissions_all = go_omissions_all;
                output.go_error = go_error;
                output.P_go_errors = go_error / go_trials;
                output.ActSel_trials = act_select_trials;
                output.corr_actselect_trials = corr_actselect;
                output.Incorr_actselect_trials = miss_actselect + wrong_actselect;
                output.miss_actselect_trials = miss_actselect;
                output.wrong_actselect_trials = wrong_actselect;
                output.P_go_omission = go_omissions_all / go_trials;
                output.P_Hit = hits / go_trials;
                output.P_miss_ActSelTrial = pFa;
                output.P_corr_actselect = corr_actselect / act_select_trials;
                output.P_val_adjusted = p_val_adj;
                output.dprime = dprime_val;
                output.dprime_bias = dprime_bias;
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
                output.mean_all_go_RT = mean(all_goRT);
                output.mean_Corr_go_RT = mean(Corr_goRT);
                output.mean_InCorr_go_RT = mean(inCorr_goRT);
                output.mean_all_ActSel_RT = mean(all_Act_Trial_RT);
                output.mean_CorrActSel_RT = mean(Corr_Act_Trial_RT);
                output.mean_InCorrActSel_RT = mean(InCorr_Act_Trial_RT);
                output.mean_inCorr_Go_RT = mean(inCorr_goRT);
                output.std_all_goRT = std(all_goRT);
                output.std_Corr_goRT = std(Corr_goRT);
                output.std_InCorr_goRT = std(inCorr_goRT);
                output.std_all_ActSel_RT = std(all_Act_Trial_RT);
                output.std_Corr_ActSel_RT = std(Corr_Act_Trial_RT);
                output.std_InCorr_ActSel_RT = std(InCorr_Act_Trial_RT);
                output.CovVar_all_goRT = std(all_goRT) / mean(all_goRT);
                output.CovVar_Corr_goRT = std(Corr_goRT) / mean(Corr_goRT);
                output.CovVar_InCorr_goRT = std(inCorr_goRT) / mean(inCorr_goRT);
                output.CovVar_all_ActSel_RT = std(all_Act_Trial_RT) / mean(all_Act_Trial_RT);
                output.CovVar_Corr_ActSel_RT = std(Corr_Act_Trial_RT) / mean(Corr_Act_Trial_RT);
                output.CovVar_InCorr_ActSel_RT = std(InCorr_Act_Trial_RT) / mean(InCorr_Act_Trial_RT);
                output.meanStimDur = mean(Stim_dur);
                

                
                %%% save line by line
                Final_ACT_output = [Final_ACT_output,output];
                
%                 % Save recoded data with valid responses here
%                 if s == 1 && y == 1
%                     Final_Pdata = Sesh_Game;
%                 else
%                     Final_Pdata = [Final_Pdata; Sesh_Game];
%                 end
                
%                 Final_ACT_Pdata = [Final_ACT_Pdata; Pdata];
                      
        end
                 
%                  save output.mat output   
%                  save Participant.mat Participant
            
    end
    
    Final_ACT_Pdata = [Final_ACT_Pdata; Pdata];
    
    fprintf('Participant %d completed.\n\n\n',IDs(pp))
        
    Measures.Participant = IDs(pp);
    Measures.Group = 2;
    Measures.TotalSessions = max([output.Tot_session]);
    Measures.TotalBonusGames = max([output.BonusGames]);
    Measures.PercentageBonusDone = (100*max([output.BonusGames]))/max([output.Tot_session]);
    
    Extra_ACT_Measures = [Extra_ACT_Measures, Measures];


        
end
    Extra_ACT_Measures = struct2table(Extra_ACT_Measures);
writetable(Final_ACT_Pdata,'Cleaned_PPData_ACT.csv','Delimiter',',')
writetable(Extra_ACT_Measures,'Extra_ACT_Measures.csv','Delimiter',',')
    
% save final output
fprintf('COMPLETED. saving all...\n\nThe outputted final datasets will be:\n\n"Final_ACT_output.mat"\n\n"Total_game_cleaning_log_ACT.mat"\n\n"Cleaned_PPData_ACT.mat"\n\nand are saved in the current folder.\n\n')
    save Final_ACT_output.mat Final_ACT_output
    save Total_game_cleaning_log_ACT.mat Total_Game_Rec
    save Cleaned_PPData_ACT.mat Final_ACT_Pdata
    save Extra_ACT_Measures.mat Extra_ACT_Measures
    
end
