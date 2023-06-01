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
alldatstruct=[];

%% Loop through participants
fprintf('starting to loop through participants\n');

% per participant
for pp = 1:1%length(IDs)
    pp = 19;
   %% Step 1. Recode session by date
    fprintf('Currently analysing participant: %d\n',IDs(pp))
    
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
    fprintf('Total sessions found for this participant: %d\n',length(Seshs))
    
    Tot_session = 0;
    Inc_session = 0;
    SpacebarKey = [];
    SpacebarRelease = [];
    
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
%         fprintf('Games: \n\n')
        
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
               
                % recode new trial numbers per game
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
                   spacebarcheck = 0;
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
                Game_Rec_EXP.Particpant = IDs(pp);
                Game_Rec_EXP.Session = Inc_session;
                Game_Rec_EXP.Game = Gams(y);
                Game_Rec_Exp.Bonus = BonusPresent;
                Game_Rec_EXP.Tot_trials = Tot_trials; 
                Game_Rec_EXP.ValidResps = validResp;
                Game_Rec_EXP.Error = error;
                Game_Rec_EXP.MaxLengthTrials = Max_allowed_Trials;
                

                % trim games that went on too long
                Game_recode(Game_recode.NewTrials > Max_allowed_Trials,:) = [];
                Trials_rem_1 = size(Game_recode,1);
                
                % save recoding info
                Game_Rec_EXP.RemovedKeyResp = Tot_trials - Trials_rem_1;
                
                 % if both 'spacebar' and 'spacebar release' are present
                if any(strcmp(Game_recode.Key,'spacebar')) == 1 && any(strcmp(Game_recode.Key,'spacebar release')) == 1
                    
                    SB_P = Game_recode(strcmp(Game_recode.Key,'spacebar'),:);
                    SB_R = Game_recode(strcmp(Game_recode.Key,'spacebar release'),:);

                    Game_Rec_EXP.SpaceP_RT = SB_P.ReactionTime;
                    Game_Rec_EXP.SpaceR_RT = SB_R.ReactionTime;

                else
                    Game_Rec_EXP.SpaceP_RT = NaN;
                    Game_Rec_EXP.SpaceR_RT = NaN;
                end
                                
                % clean invalid key responses here
                Game_recode(~ismember(Game_recode.Key,validResp),:) = [];
                
                % save recoding info
                Game_Rec_EXP.RemovedLengthTrls = Trials_rem_1 - size(Game_recode,1);
                
               
                    
%                     % check if there is data for both keys
%                     if isempty(SpacebarKey) == 1 && isempty(SpacebarRelease) == 1
%                         SpacebarKey = SB_P;
%                         SpacebarRelease = SB_R;
%                     else
%                         SpacebarKey = [SpacebarKey; SB_P];
%                         SpacebarRelease = [SpacebarRelease; SB_R];
%                     end
                    
                    % get reaction times
%                     SpaceP_RT = SpacebarKey.ReactionTime;
%                     SpaceR_RT = SpacebarRelease.ReactionTime;
%                 end
                
            % save log of data cleaning
            Total_Game_Rec = [Total_Game_Rec,Game_Rec_EXP];
            
            % save remaining valid responses for further analysis
            if i == 1 && y == 1
                Pdata = Game_recode;
            else
                Pdata = [Pdata; Game_recode];
            end
            
%             output.PP = IDs(pp);
%             output.Sesh = Inc_session;
%             output.GameData = Pdata;
%             output.SpacebarP = SpacebarKey;
%             output.SpacebarR = SpacebarRelease;
%             alldatstruct = [alldatstruct,output];
            
%            % convert this to the format we use further down 
%             Sesh_Game = Game_recode;
            
            
%             %% Step 3. Recoding correct and incorrect responses 
%             
%             % empty variables for every game in a session
%             go_RT = [];
%             go_RT2 = [];
%             stop_RT = [];
%             ssd = [];
%             hits = 0;
%             go_omissions = 0;
%             go_omissions_all = 0;
%             false_alarms = 0;
%             correct_inhibits = 0;
%             
%             % data subset. Only this game per session for a pp (now done
%             % above)
% %             Sesh_Game = P_Sesh(strcmp(P_Sesh.Game,Gams(y)),:);
%             Glen = size(Sesh_Game);
%             
%             % calculate total number of trials 
%             go_trials = sum(strcmp(Sesh_Game.TrialType,'respond'));
%             stop_trials = sum(strcmp(Sesh_Game.TrialType,'inhibit'));
%             
%             
%             % Recoding correct and incorrect line by line
%             for z = 1:Glen(1)
%                 
%                 % RESPONSE (GO) TRIAL
%                 if strcmp(Sesh_Game.TrialType(z),'respond') == 1
%                     
%                     % KG 05/02/20: leave in 5 seconds and 100 ms window. 
%                     
%                     % CORRECT: valid key and within RT bounds (changed this to use new recoding)
%                     if strcmp(Sesh_Game.Key(z),'none') == 0 && Sesh_Game.ReactionTime(z) < 5000 && Sesh_Game.ReactionTime(z) > 100
%                         hits = hits + 1;
%                         go_RT = [go_RT, Sesh_Game.ReactionTime(z)];
%                     
%                     % KG: Edit 05/02/20: maybe without the time limit here.
%                     % So, if they did make a response, then technically
%                     % it's not a go-omissions, it's just a fast response.
%                     % ASK JOSH. (But for d-prime we need to know the
%                     % go-omission... maybe just do it differently. e.g. maybe use two types of 
%                     % go-omission. Consensus: ok let's do both. 
%                   
%                     % INCORRECT: no response given
%                     elseif strcmp(Sesh_Game.Key(z),'none') == 1
%                         go_omissions = go_omissions + 1;
%                         go_omissions_all = go_omissions_all + 1;
%                         
%                     % TOO LATE: response out of RT bounds    
%                     elseif strcmp(Sesh_Game.Key(z),'none') == 0 && Sesh_Game.ReactionTime(z) >= 5000 && Sesh_Game.ReactionTime(z) < 100
%                         % code in different go-omission outside of RT
%                         % limit. 
%                         go_omissions_all = go_omissions_all + 1;
%                     end
%                     
%                 % NO RESPONSE (NO-GO) TRIAL
%                 elseif strcmp(Sesh_Game.TrialType(z),'inhibit') == 1
%                     % save SSD
%                     ssd = [ssd, Sesh_Game.StopSignalStartTime(z)];
%                     
%                     % CORRECT: no response given
%                     if strcmp(Sesh_Game.Key(z),'none') == 1
%                         correct_inhibits = correct_inhibits + 1;
%                         
%                     % INCORRECT: false alarm response, responded on inhibit trial
%                     elseif strcmp(Sesh_Game.Key(z),'none') == 0
%                         false_alarms = false_alarms + 1;
%                         stop_RT = [stop_RT, Sesh_Game.ReactionTime(z)];
%                         
%                     end
%                     
%                 end
%                
%             end %% end for recoding of correct incorrect responses

        end % end for all games in this session
    end % end of sessions for a pp
end % end for all pps