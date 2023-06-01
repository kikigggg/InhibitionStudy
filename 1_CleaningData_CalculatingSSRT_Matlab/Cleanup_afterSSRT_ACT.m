%%% remove NaNs and the session if less than 2 games left

function Cleanup_afterSSRT_ACT

clearvars;
clc;

load Final_ACT_output.mat
%     
Cleanup = struct2table(Final_ACT_output);


% Find all the participants in the table
IDs = unique(Cleanup.Participant);
% 
fprintf('\n\nWorking on Action Select Group data.\n\n')



Final_Cleanup_Log_ACT = [];


%% Version 1: only include sessions with two games minimum.
% the two games need to have valid SSRT measures to be included.

for pp = 1:length(IDs)
    
    removedSessions = 0;
    reminvSSRTs = 0;
    
    fprintf('Now finalising session coding: "Clean", for participant: %d\n\n',IDs(pp))
    
    % extract a new table per participant
    Participant = Cleanup(Cleanup.Participant == IDs(pp), :);
    
    % find all the sessions for that participant
    Seshs = unique(Participant.Inc_session);
    maxSesh = max(Seshs);
    
    All_games = size(Participant,1);
    
%     Participant(sum(isnan(Participant.mean_CorrActSel_RT), 2) == 1, :) = [];
    
    
%     Participant = ~isnan(Participant.mean_CorrActSel_RT,:);
    
%     Participant=Participant(~any(ismissing(Participant.mean_CorrActSel_RT),2),:);
%     reminvSSRTs = All_games - size(Participant,1);
    
    for z = 1:length(Seshs)
        
        % separate table per session
        P_Sesh = Participant(Participant.Inc_session(:,end)==Seshs(z),:);
        
        % if less than 2 games in a session remove. 
        if size(P_Sesh,1) < 2
            Participant(Participant.Inc_session(:,end)==Seshs(z),:) = [];
            removedSessions = removedSessions + 1;
 
        end

    end    
    
    Log.Participant = IDs(pp);
    Log.TotalSesh = maxSesh;
    Log.RemRTs = reminvSSRTs;
    Log.RemSesh = removedSessions;
    
    Final_Cleanup_Log_ACT = [Final_Cleanup_Log_ACT, Log];
    
   % we need to set the first session to 1
    if isempty(Participant) == 1 
        continue; 
    elseif Participant.Inc_session(1) ~= 1
        a = Participant.Inc_session(1);
        Participant.Inc_session(Participant.Inc_session == a) = 1;
    end 
    
    % renaming sessions
    for tt = 1:size(Participant,1)-1
          
        addT = 1;
        
        if abs(Participant.Inc_session(tt+addT)-Participant.Inc_session(tt)) > 1 && Participant.Tot_session(tt+addT) ~= Participant.Tot_session(tt)% eg this is a jump from 9 to 12
            Participant.Inc_session(tt+addT) = Participant.Inc_session(tt)+1; % then we say 12 is 9 + 1 (10)
        elseif Participant.Tot_session(tt+addT) == Participant.Tot_session(tt) % if it's like 9 + 
            Participant.Inc_session(tt+addT) = Participant.Inc_session(tt);
        end
    end
    
    if max(Participant.Inc_session) == 1
        Participant = [];
    end
        
    
    if pp == 1
        Clean_ACT_SSRT_V1 = Participant;
        save Clean_ACT_SSRT_V1.mat  Clean_ACT_SSRT_V1
        
    else
        load Clean_ACT_SSRT_V1.mat; 
        Clean_ACT_SSRT_V1 = [Clean_ACT_SSRT_V1; Participant];
    
        save Clean_ACT_SSRT_V1.mat Clean_ACT_SSRT_V1
    end
    
save Final_Cleanup_Log_ACT.mat Final_Cleanup_Log_ACT
% for action select group
% Clean_ACT_SSRT(:,'fullPdata') = []; % remove this column
writetable(Clean_ACT_SSRT_V1,'Clean_ACT_SSRT_V1.csv','Delimiter',',')
    
        
end

clear Log
clear Participant






%% Version 1.1 Make a cleaned SSRT version for Act select as well, to compare against Exp group

Final_CLEANER_Log_ACT2 = [];

load Final_ACT_output.mat
    
Cleanup = struct2table(Final_ACT_output);

% Find all the participants in the table
IDs = unique(Cleanup.Participant);

for pp = 1:length(IDs)
    
    removedSessions = 0;
    reminvSSRTs = 0;
    
    fprintf('Now finalising session coding: "CLEANER", for participant: %d\n\n',IDs(pp))
    
    % extract a new table per participant
    Participant = Cleanup(Cleanup.Participant == IDs(pp), :);
    
    % find all the sessions for that participant
    Seshs = unique(Participant.Inc_session);
    maxSesh = max(Seshs);
    
    All_games = size(Participant,1);
    
    Participant(Participant.FullSSRTExclude == 1,:) = [];
    Participant(Participant.mean_CorrActSel_RT == 1,:) = [];
    reminvSSRTs = All_games - size(Participant,1);
       
    Participant(Participant.P_miss_ActSelTrial < 0.25 , :) = [];
    under25 = reminvSSRTs - size(Participant,1);
    
    Participant(Participant.P_miss_ActSelTrial > 0.75 , :) = [];
    over75 = under25 - size(Participant,1);
    
    for z = 1:length(Seshs)
        
        % separate table per session
        P_Sesh = Participant(Participant.Inc_session(:,end)==Seshs(z),:);
        
        % if less than 2 games in a session remove. 
        if size(P_Sesh,1) < 2
            Participant(Participant.Inc_session(:,end)==Seshs(z),:) = [];
            removedSessions = removedSessions + 1;
 
        end

    end    
    
    Log.Participant = IDs(pp);
    Log.TotalSesh = maxSesh;
    Log.IncSesh = maxSesh - removedSessions;
    Log.RemPValMin25 = under25;
    Log.RemPValOver75 = over75;
    Log.RemSSRT = reminvSSRTs;
    Log.RemSesh = removedSessions;
    
    Final_CLEANER_Log_ACT2 = [Final_CLEANER_Log_ACT2, Log];
    
   % we need to set the first session to 1
    if isempty(Participant) == 1 
        continue; 
    elseif Participant.Inc_session(1) ~= 1
        a = Participant.Inc_session(1);
        Participant.Inc_session(Participant.Inc_session == a) = 1;
    end 
    
    % renaming sessions
    for tt = 1:size(Participant,1)-1
          
        addT = 1;
        
        if abs(Participant.Inc_session(tt+addT)-Participant.Inc_session(tt)) > 1 && Participant.Tot_session(tt+addT) ~= Participant.Tot_session(tt)% eg this is a jump from 9 to 12
            Participant.Inc_session(tt+addT) = Participant.Inc_session(tt)+1; % then we say 12 is 9 + 1 (10)
        elseif Participant.Tot_session(tt+addT) == Participant.Tot_session(tt) % if it's like 9 + 
            Participant.Inc_session(tt+addT) = Participant.Inc_session(tt);
        end
    end
    
    if pp == 1
        Clean_ACT_SSRT2 = Participant;
        save Clean_ACT_SSRT2.mat  Clean_ACT_SSRT2
        
    elseif exist('Clean_ACT_SSRT2.mat') == 0
        Clean_ACT_SSRT2 = Participant;
        save Clean_ACT_SSRT2.mat  Clean_ACT_SSRT2
    else
        load Clean_ACT_SSRT2.mat; 
        Clean_ACT_SSRT2 = [Clean_ACT_SSRT2; Participant];
    
        save Clean_ACT_SSRT2.mat Clean_ACT_SSRT2
    end
    
save Final_CLEANER_Log_ACT2.mat Final_CLEANER_Log_ACT2
% for action select group
% Clean_ACT_SSRT(:,'fullPdata') = []; % remove this column
writetable(Clean_ACT_SSRT2,'Clean_ACT_SSRT2.csv','Delimiter',',')
    
        
end

end

% %% Version 2: Don't set a minimum on games. Recode sessions if any were skipped due to removal of invalid SSRTs
% % If a session was skipped because e.g. it only had one game and that game
% % had an invalid SSRT response, then only relabel the sessions
% % consecutively here.
% 
% for pp = 1:length(IDs)
%     
%     % extract a new table per participant
%     Participant = Cleanup(Cleanup.Participant == IDs(pp), :);
%     
%     % we need to set the first session to 1
%     if isempty(Participant) == 1 
%         continue; 
%     elseif Participant.Inc_session(1) ~= 1
%         a = Participant.Inc_session(1);
%         Participant.Inc_session(Participant.Inc_session == a) = 1;
%     end 
%     
%     % renaming sessions
%     for tt = 1:size(Participant,1)-1
%           
%         addT = 1;
%         
%         if abs(Participant.Inc_session(tt+addT)-Participant.Inc_session(tt)) > 1 && Participant.Tot_session(tt+addT) ~= Participant.Tot_session(tt)% eg this is a jump from 9 to 12
%             Participant.Inc_session(tt+addT) = Participant.Inc_session(tt)+1; % then we say 12 is 9 + 1 (10)
%         elseif Participant.Tot_session(tt+addT) == Participant.Tot_session(tt) % if it's like 9 + 
%             Participant.Inc_session(tt+addT) = Participant.Inc_session(tt);
%         end
%     end
%     
%     
%     if pp == 1
%         Clean_ACT_SSRT_V2 = Participant;
%         save Clean_ACT_SSRT_V2.mat  Clean_ACT_SSRT_V2
%         
%     else
%         load Clean_ACT_SSRT_V2.mat; 
%         Clean_ACT_SSRT_V2 = [Clean_ACT_SSRT_V2; Participant];
%     
%         save Clean_ACT_SSRT_V2.mat Clean_ACT_SSRT_V2
%     end
%     
%     
% fprintf('All done!\n\n')
% 
% % for experimental group
% % Clean_EXP_SSRT(:,'fullPdata') = []; % remove this column
% writetable(Clean_ACT_SSRT_V2,'Clean_ACT_SSRT_V2.csv','Delimiter',',')
%         
% end
    
