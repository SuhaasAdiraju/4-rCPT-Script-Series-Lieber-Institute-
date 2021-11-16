% This script is a walkthrough of how to handle CPT recorded LFP data. 
% More specifically how to combine the event data with recordings 

% - Written by Suhaas S. Adiraju 09.30.21

%% HEADS UP !

% This script assumes the user has already been through the Sirenia 2 Matlab
% example script!!!!

% Thus they now have .mat files within structures for each
% mouse... as well as *ACCESS* the matching CPT behavioral events taken
% from ABET software, and chamber # info


%% Walkthrough...

% toggle to the folder with the saved mouse structure containing LFP (created using sirenia2mat
% function) 

 %'yourpath'
clear; clc 

cd('Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP');



%%
load ('S3Good_1700S.mat'); %load said structure, you need '.mat'


% rename the mouse structure you want to complete so we can add to it.
savename = S3Good_1700S; % you dont need '.mat'
saveplace = ['Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP']% path to folder you'd like to save resulting structure in

% BUT, also define a mousename, so we can re-save the structure w/ the
% correct name 
vars= whos;
mousename = vars.name;


% OPEN your cpt behavioral events file (these are taken off of CPT chamber
% computer in the back-room via hard-drive; and are in the form of .csv
% file) (matching the correct behavioral event data to the proper LFP
% output file takes care in naming and may require some data sleuthing
% using dates etc., so it's a good thing to keep in mind when naming
% behavioral/recording sessions)

cd('D:\08.11.21 ONWARDS\CSV Behavioral Event Files\new timestamps');



%% Next

% now, identify which file from the left-hand side directory you'd like to
% use

filename = '1700 S final.csv'; 

[Tstamps,Titles,EventsFull] = xlsread(filename); % convert to cell arrays
% this pops out three things to work with, just the TStamp values, just the
% titles, and both together 


parCh3 = 'Chamber3';
parCh4 = 'Chamber4';


% This loop will go through your events sheet, see if there is both
% chambers 3 and 4, or just 3, or just 4, let you know what it found, and
% create distinct variables with the associated timestamps for chambers 3
% and 4 

for z = 1:length(EventsFull(:,3))
        if (startsWith((EventsFull(z,3)),parCh3))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 3...');
            end
            Ch3Events = EventsFull(:,:); 
            chamber = Ch3Events;
        end
        if (startsWith((EventsFull(z,3)),parCh4))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 4...');
            end
            Ch4Events = EventsFull(:,:);
            chamber = Ch4Events;
        end
        
        if z == length(EventsFull(:,3))
            if (exist('Ch3Events')) == 1
                fprintf('\n\nChamber 3 data extracted!')
            end
            if (exist ('Ch3Events')) == 0
                fprintf('\n\nChamber 3 not found.')
            end
            if (exist ('Ch4Events')) == 1 
                fprintf('\n\nChamber 4 data extracted!')
            end
            if (exist ('Ch4Events')) == 0
                fprintf('\n\nChamber 4 not found.')
            end
        end
end
     
                
            

% initialize variables for events of desire (good practice to predefine)

FIRBeam_On = {};
FIRBeam_Off = {};
Center_ScTouch = {}; 
Start_ITI = {};
Stimulus = {};
Hit = {};
Miss = {};
Correct_Rej = {};
False_Alarm = {};


%% in loop fashion, grab the timestamps event titles and save them seperately 

%(if you are confident in the applicability of this section to your dataset, you can 'run section' for speed)

% just dont forget to choose the correct chamber (%chamber = Ch3Events;) 
    % EDIT ON THIS: now, the loop in the ^ prev. section will automatically
    % define chamber for you. if for some rzn you need to, you could
    % hard-code 'chamber = whatever;'

% event array of given chamber; define based on what chamber you want data from (aka what ch. your mouse was in) 

% For FIRBeam On
pat = 'FIRBeam On'; %event name (this is 'pattern' and used to grab event TStamps based on the title they're under)
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            FIRBeam_On{z} = chamber(:,z);
            FIRBeam_On = FIRBeam_On{z}(2:end)
        end

        if z == (length(chamber(1,:)))
        FIRBeam_On = cell2mat(FIRBeam_On);  %change from cell array to a double for future computational ease
        FIRBeam_On = FIRBeam_On'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat,'''s have been extracted!\n']);
        end
end

% For FIRBeam Off
pat = 'FIRBeam Off';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            FIRBeam_Off{z} = chamber(:,z);
            FIRBeam_Off = FIRBeam_Off{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
        FIRBeam_Off = cell2mat(FIRBeam_Off);  %change from cell array to a double for future computational ease
        FIRBeam_Off = FIRBeam_Off'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat,'''s have been extracted!\n']);
        end
end


% For Center screen touch 
pat = 'Center Screen Touch';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Center_ScTouch{z} = chamber(:,z);
            Center_ScTouch = Center_ScTouch{z}(2:end);
        end
        
        if z == (length(chamber(1,:)))
        Center_ScTouch = cell2mat(Center_ScTouch);  %change from cell array to a double for future computational ease
        Center_ScTouch = Center_ScTouch'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat,'es have been extracted!\n']);
        end
end

% For Start ITI
pat = 'Start ITI';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Start_ITI{z} = chamber(:,z);
            Start_ITI = Start_ITI{z}(2:end)
        end
        %
        if z == (length(chamber(1,:)))
        Start_ITI = cell2mat(Start_ITI);  %change from cell array to a double for future computational ease
        Start_ITI = Start_ITI'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat,'es have been extracted!\n']);
        end
end

% For Stimulus (stimulus presentation)
pat = 'Stim Onset';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Stimulus{z} = chamber(:,z);
            Stimulus = Stimulus{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
        Stimulus = cell2mat(Stimulus);  %change from cell array to a double for future computational ease
        Stimulus = Stimulus'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat,'es have been extracted!\n']);
        end
end


% Hit
pat = 'Hit';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Hit{z} = chamber(:,z);
            Hit = Hit{z}(2:end)
        end

        if z == (length(chamber(1,:)))
            Hit = cell2mat(Hit);  %change from cell array to a double for future computational ease
            Hit = Hit'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat,'es have been extracted!\n']);
        end
end


% Miss
pat = 'Misses';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Miss{z} = chamber(:,z);
            Miss = Miss{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            Miss = cell2mat(Miss);  %change from cell array to a double for future computational ease
            Miss = Miss'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat,'es have been extracted!\n']);
        end
end

% Correct_Rej
pat = 'Correct Rejection';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            Correct_Rej{z} = chamber(:,z);
            Correct_Rej = Correct_Rej{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            Correct_Rej = cell2mat(Correct_Rej);  %change from cell array to a double for future computational ease
            Correct_Rej = Correct_Rej'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat,'es have been extracted!\n']);
        end
end

% False_Alarm
pat = 'Mistakes'; %in abet an S- miss is called 'mistake', but we call it a FAlarm
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat)) == 1
            False_Alarm{z} = chamber(:,z);
            False_Alarm = False_Alarm{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            False_Alarm = cell2mat(False_Alarm);  %change from cell array to a double for future computational ease
            False_Alarm = False_Alarm'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat,' have been extracted!\n']);
        end
end

%% lfp formatting 
% for now, need to convert lfp from timetable to matrix; and flip it into
% the desired orientation
lfp = table2cell(savename.lfp);
lfp = cell2mat(lfp);
lfp = lfp';

%%
% remove excess zeros, and add to loaded mousename structure
savename. lfp = lfp;
savename. FIRBeam_On = FIRBeam_On(isnan(FIRBeam_On) == 0);
savename. FIRBeam_Off = FIRBeam_Off(isnan(FIRBeam_Off) == 0);
savename. Center_ScTouch = Center_ScTouch(isnan(Center_ScTouch) == 0);
savename. Start_ITI = Start_ITI(isnan(Start_ITI(2:end)) == 0);
savename. Stimulus = Stimulus(isnan(Stimulus(2:end)) == 0);
savename. Hit = Hit(isnan(Hit) == 0);
savename. Miss = Miss(isnan(Miss) == 0);
savename. Correct_Rej = Correct_Rej(isnan(Correct_Rej) == 0);
savename. False_Alarm = False_Alarm(isnan(False_Alarm) == 0);
savename. ChamberSource  = chamber(3,3);

% resave the structure to the correct folder
cd(saveplace);
save(mousename,'-struct','savename');

%% 
fprintf('\n\nDONE! Checkout your structure on the left-hand side, if it looks complete, press any key to clear the workspace');


pause   

clear;