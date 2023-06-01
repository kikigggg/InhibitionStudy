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
               
            % see which game it is, to see which key presses we will
            % code as valid responses
            
                if strcmp(Gams(y),'Mining') == 1 
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   Game_num = 1;
                   error = 0;

               elseif strcmp(Gams(y),'Chest_Picking') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   Game_num = 2;
                   error = 0;

               elseif strcmp(Gams(y),'Treasure_Collect') == 1 
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   Game_num = 3;
                   error = 0;

               elseif strcmp(Gams(y),'Conveyor_Belt') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   Game_num = 4;
                   error = 0;

               elseif strcmp(Gams(y),'AB_Driving') == 1
                   validResp = {'none', 'ArrowLeft', 'ArrowRight'};
                   Max_allowed_Trials = 500;
                   Game_num = 5;
                   error = 0;

               elseif strcmp(Gams(y),'HR_Driving') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
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
            
            % how to subset structure by game, e.g.: 
            % ZZ = Total_Game_Rec([Total_Game_Rec.GameNo] == 3);
            % M = mean([ZZ.Tot_trials])
            % SD = std([ZZ.Tot_trials])
            % 3SD = 3*std([ZZ.Tot_trials])
            % M3SD = M+3SD
            
        end
        
    end
    
end
