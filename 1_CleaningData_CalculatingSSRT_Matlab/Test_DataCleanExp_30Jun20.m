% test for cleaning the data for the experimental group

%% Step 0. Importing data, selecting relevant columns
% import data
fprintf('importing and cleaning file...')
qdat = readtable('OCT_Pilot_Experimental.csv');

% remove unnecessary columns
% these columns refer to unused Id numbers, NaN columns etc
columnIndicesToDelete = [2 4 5 15 16 17 18 25 26 27 42 43]; 
qdat(:,columnIndicesToDelete) = [];

% first, recode sessions per date
% find all participants. We have 21 participants in the Action select group
IDs = unique(qdat.ParticipantPublicID);

Final_output = [];
Total_Game_Rec = [];
Pdata = [];

%% Loop through participants
fprintf('starting to loop through participants\n');
% per participant
for pp = 1:1
    
    %% Step 1. Recode session by date
    fprintf('Currently analysing participant: %d\n',IDs(pp))
%     disp(IDs(pp)); % show which pp we're on
    
    % extract a new table per participant
    ParticipantPrep = qdat(qdat.ParticipantPublicID == IDs(pp), :);
    
    % change formatting of raw data date and times to just date
    ParticipantPrep.UTCDate.Format = 'yyyy-MM-dd';
    ParticipantPrep = sortrows(ParticipantPrep,'UTCDate'); % sorted by date
    
    % extract dates
    Dates = ParticipantPrep.UTCDate;
    Z = string(Dates);
    ParticipantPrep.DateStrings = Z; % assign new session identifier (date as a string)
    
    % find all the sessions for that participant
    Seshs = unique(ParticipantPrep.DateStrings);
%     disp(Seshs)
    fprintf('Total sessions found for this participant: %d\n',length(Seshs))
    
    Tot_session = 0;
    Inc_session = 0;
    

%     Pdata = [];
    
    %% per session of a participant
    for i = 1:length(Seshs)
        
        % session counter for total sessions available per participant
        % (these are a date and time stamp)
        Tot_session = Tot_session + 1;
        
%         output.Session = Seshs(i);
        fprintf('\n\nCurrently on session: %d\n\n', Tot_session)
%         disp(Tot_session);
        
        % separate table per session
        P_Sesh = ParticipantPrep(strcmp(ParticipantPrep.DateStrings,Seshs(i)),:);
        P_Sesh.InitSessions(:) = Tot_session;
        
        % find all the games in that session
        Gams = unique(P_Sesh.Game); 
        fprintf('Games in this session: \n')
        disp(Gams)
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
            fprintf('Actual current session: %d\n\n',Inc_session)

            P_Sesh.IncSessions(:) = Inc_session;
            fprintf('Games: \n\n')
        
        %% per game inside a session
        for y = 1:length(Gams)
            
            %% Step 2.Code valid /invalid responses per game + remove any trials past cut-off point per game
            
            % subset bonus games
            Bonus_Game = P_Sesh(P_Sesh.BonusGame == 1,:);
            if size(Bonus_Game,1) == 0
                BonusPresent = 0;
            else
                BonusPresent = 1;
            end
            % remove bonus game trials
            P_Sesh(P_Sesh.BonusGame == 1,:) = [];

%             % for each separate game in a session, subset it
%             for q = 1:length(Gams)
                currG = string(Gams(y));
                fprintf('%d: %s\n\n',y,currG)

                % select all rows for that game and see how many trials
               Game_recode = P_Sesh(strcmp(P_Sesh.Game,Gams(y)),:); 
               Tot_trials = size(Game_recode,1);
               new_trial_nums = (1:Tot_trials)';
               Game_recode.NewTrials = new_trial_nums;
               
               % see which game it is
               if strcmp(Gams(y),'Mining') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   error = 0;

               elseif strcmp(Gams(y),'Chest_Picking') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   error = 0;
                   
               elseif strcmp(Gams(y),'Treasure_Collect') == 1 
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   error = 0;
                   
               elseif strcmp(Gams(y),'Conveyor_Belt') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   error = 0;
                   
               elseif strcmp(Gams(y),'AB_Driving') == 1
                   validResp = {'none', 'ArrowLeft', 'ArrowRight'};
                   Max_allowed_Trials = 500;
                   error = 0;
                   
               elseif strcmp(Gams(y),'HR_Driving') == 1
                   validResp = {'none', 'spacebar', 'spacebar release'};
                   Max_allowed_Trials = 500;
                   error = 0;
                   
               else
                   error = 'Error!';
                   Max_allowed_Trials = 500;
               end
               
               % save before cleaning
                Game_Rec_EXP.Particpant = pp;
                Game_Rec_EXP.Session = Inc_session;
                Game_Rec_EXP.Game = Gams(y);
                Game_Rec_EXP.Tot_trials = Tot_trials; 
                Game_Rec_EXP.ValidResps = validResp;
                Game_Rec_EXP.Error = error;
                Game_Rec_EXP.MaxLengthTrials = Max_allowed_Trials;
                
                % trim games that went on too long
                Game_recode(Game_recode.NewTrials > Max_allowed_Trials,:) = [];
                Trials_rem_1 = size(Game_recode,1);
                
                % save recoding info
                Game_Rec_EXP.RemovedKeyResp = Tot_trials - Trials_rem_1;
                
                % clean invalid key responses here
                Game_recode(~ismember(Game_recode.Key,validResp),:) = [];
                
                % save recoding info
                Game_Rec_EXP.RemovedLengthTrls = Trials_rem_1 - size(Game_recode,1);
                
                % allocate empty column for new recoding of correct
                % responses
                Game_recode.CorrectRec = zeros(height(Game_recode),1);
                
                %recode correct responses here
                for ii = 1:size(Game_recode,1)
                    % recode respond trials
                    if strcmp(Game_recode.TrialType(ii),'respond') == 1
                        if strcmp(Game_recode.Key(ii),'none') == 0
                            Game_recode.CorrectRec(ii) = 1;
                        else
                            Game_recode.CorrectRec(ii) = 0;
                        end
                        % recode inhibition trials
                    elseif strcmp(Game_recode.TrialType(ii),'respond') == 0
                        if strcmp(Game_recode.Key(ii),'none') == 1
                            Game_recode.CorrectRec(ii) = 1;
                        else
                            Game_recode.CorrectRec(ii) = 0;
                        end
                        
                    end
                    
                end % finish correct recoding loop
                
            
            % save log of data cleaning
            Total_Game_Rec = [Total_Game_Rec,Game_Rec_EXP];
            
            % save remaining valid responses for further analysis
            if i == 1 && y == 1
                Pdata = Game_recode;
            else
                Pdata = [Pdata; Game_recode];
            end
            
           
            Sesh_Game = Game_recode;
            
        end
    end
        
end
            
