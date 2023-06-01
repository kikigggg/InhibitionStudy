%%% remove NaNs and the session if less than 2 games left

function Cleanup_afterSSRT_EXP

clearvars;
clc;

load Final_EXP_output.mat
    
Cleanup = struct2table(Final_EXP_output);

% % subset the rows where not ALL SSRTS are NaNs (so at least one of them
% % isnt a NaN)
% Cleanup = T(T.FullSSRTExclude == 0,:);

% Find all the participants in the table
IDs = unique(Cleanup.Participant);

fprintf('\n\nWorking on Experimental Group data.\n\n')

Final_Cleanup_Log_EXP = [];

%% Version 1: only include sessions with two games minimum.
% the two games need to have valid SSRT measures to be included.

for pp = 1:length(IDs)
    
    removedSessions = 0;
    reminvSSRTs = 0;
   
    fprintf('Now finalising session coding for participant: %d\n\n',IDs(pp))
    
    % extract a new table per participant
    Participant = Cleanup(Cleanup.Participant == IDs(pp), :);
    
    % find all the sessions for that participant
    Seshs = unique(Participant.Inc_session);
    maxSesh = max(Seshs);
    
    All_games = size(Participant,1);
    
    Participant(Participant.FullSSRTExclude == 1,:) = [];
    reminvSSRTs = All_games - size(Participant,1);
%     
%     Participant(Participant.FullSSRTExclude == 1,:) = [];
%     reminvSSRTs = All_games - size(Participant,1);
%        
%     Participant(Participant.P_false_alarm < 0.25 , :) = [];
%     under25 = reminvSSRTs - size(Participant,1);
%     
%     Participant(Participant.P_false_alarm > 0.75 , :) = [];
%     over75 = under25 - size(Participant,1);
    
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
%     Log.RemPValMin25 = under25;
%     Log.RemPValOver75 = over75;
    Log.RemSSRT = reminvSSRTs;
    Log.RemSesh = removedSessions;

    Final_Cleanup_Log_EXP = [Final_Cleanup_Log_EXP, Log];

    
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
        Clean_EXP_SSRT_V1 = Participant;
        save Clean_EXP_SSRT_V1.mat  Clean_EXP_SSRT_V1
        
    else
        load Clean_EXP_SSRT_V1.mat; 
        Clean_EXP_SSRT_V1 = [Clean_EXP_SSRT_V1; Participant];
    
        save Clean_EXP_SSRT_V1.mat Clean_EXP_SSRT_V1
    end
    
    
    
% save Final_Cleanup_Log_EXP.mat Final_Cleanup_Log_EXP
% for experimental group
% Clean_EXP_SSRT(:,'fullPdata') = []; % remove this column
writetable(Clean_EXP_SSRT_V1,'Clean_EXP_SSRT_V1.csv','Delimiter',',')
        
end
    
end


% %% Version 2: Don't set a minimum on games. Recode sessions if any were skipped due to removal of invalid SSRTs
% % If a session was skipped because e.g. it only had one game and that game
% % had an invalid SSRT response, then only relabel the sessions
% % consecutively here.
% 
% for pp = 1:length(IDs)
%     
% %     removedSessions = 0;
%    
% %     fprintf('Now finalising session coding for participant: %d\n\n',IDs(pp))
%     
%     % extract a new table per participant
%     Participant = Cleanup(Cleanup.Participant == IDs(pp), :);
%     
% %     % find all the sessions for that participant
% %     Seshs = unique(Participant.Inc_session);
% %     
% %     for z = 1:length(Seshs)
% %         
% %         % separate table per session
% %         P_Sesh = Participant(Participant.Inc_session(:,end)==Seshs(z),:);
% %         
% %         % if less than 2 games in a session remove. 
% %         if size(P_Sesh,1) < 2
% %             Participant(Participant.Inc_session(:,end)==Seshs(z),:) = [];
% % %             removedSessions = removedSessions + 1;
% %  
% %         end
% % 
% %     end    
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
%         Clean_EXP_SSRT_V2 = Participant;
%         save Clean_EXP_SSRT_V2.mat  Clean_EXP_SSRT_V2
%         
%     else
%         load Clean_EXP_SSRT_V2.mat; 
%         Clean_EXP_SSRT_V2 = [Clean_EXP_SSRT_V2; Participant];
%     
%         save Clean_EXP_SSRT_V2.mat Clean_EXP_SSRT_V2
%     end
%     
%     
% fprintf('All done!\n\n')
% 
% % for experimental group
% % Clean_EXP_SSRT(:,'fullPdata') = []; % remove this column
% writetable(Clean_EXP_SSRT_V2,'Clean_EXP_SSRT_V2.csv','Delimiter',',')
%         
% end

