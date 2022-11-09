%% LFP4CPT 0 sirenia2mat

% this is the companion script for using the sirenia2mat function... user will
% need to have marked, or on hand, what mouse corresponds to what chamber
% for naming purposes...

% for a 1st time user, this info can be found in the performance tracking
% sheets in excel, or on ABET software logs
 
% - Written by Suhaas S. Adiraju

%% Warning

% So you must first open your Ephys recording files in Sirenia, and export
% them as .edf files (when naming these .edfs, BE VERY CAREFUL TO INDICATE
% CAGE CARD IF BOTH CHAMBERS RECORDED, OR, IF ONLY 1 CHAMBER WAS RECORDING, WHICH ONE!!!)

%... then come back 

%... if you have already done so you may simply select 'Run' in the
%'Editor' tab at the top of matlab



%     h = figure('units','pixels','position',[500 500 200 50],'windowstyle','modal');
%     uicontrol('style','text','string','Running...','units','pixels','position',[75 10 50 30]);
    sirenia2mat(edfpath,edfname,saveplace);
    

%     close(h)

            % elseif runstyle == 2
            %     edfpath = []
            %     edfname = []
            %     saveplace = []
            %     sprintf('\n\nGo ahead and manually define the required inputs starting at Line 50\nThen run the function in the next section!\nBy highlighting and evaluating\n''sirenia2mat(edfpath,edfname,saveplace);'',\nwithout the percent sign')
            % 
            % end
end

%%  NOW RUN THE FUNCTION 

% sirenia2mat(edfpath,edfname,saveplace);


% after you run the function fully (answering all the questions), your .mat
% file will show up on the right hand side. you can proceed to convert as
% many files as you wish in one session



% when you are finished, move on to the section below 
  
%% Saving once all desired files have been processed
%{
% once you have successfully converted all of your .edf's, define your
% saveplace, and and use this sourced code loop to go
% through and save all your structures taken from:
    % (https://superuser.com/questions/1190023/matlab-save-all-variables-separately)

% saveplace = {'pathofwhereyouwanttosave'};
saveplace = ('Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP');

% now run this chunk of code, to save your structures in saveplace and
% delete the other variables we dont want
clear edf
vars=who;
vars = vars(1:(end-2),:)
for i=1:length(vars)
    if i == 1
        cd(saveplace);
        clear saveplace
    end
fprintf('\nSaving %s...',(vars{i}))
save(vars{i},vars{i})   
end

clear 
%}
waitfor(msgbox(sprintf('Okay, this script is finished, moving on to the next option in the pipeline')))

