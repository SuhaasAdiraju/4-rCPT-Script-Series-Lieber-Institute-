% this is a exmple script for using the sireniatomat function... user will
% need to have marked, or on hand, what mouse corresponds to what chamber
% for naming purposes...

% for a 1st time user, this info can be found in the performance tracking
% sheets in excel, or on ABET software logs

% Run this line alone
help sirenia2mat


%%

% So you must first open your Ephys recording files in Sirenia, and export
% them as .edf files (when naming these .edfs, BE VERY CAREFUL TO INDICATE
% CAGE CARD IF BOTH CHAMBERS RECORDED, OR, IF ONLY 1 CHAMBER WAS RECORDING, WHICH ONE!!!)

%... then come back 

%... if you have already done so start HERE


clc; clear;
% change directory to the location of your .edf files ('path')
cd ('D:\08.11.21 ONWARDS\EPHYS');



% sirenia2mat requires 1 pre-defined variable, that should be defined as
% such 
    %edf = {'NameOfyour.EDF'}; dont forget the .edf
        
% after that simply run the sirenia2mat(edf) line; and then follow the
% prompts
   
%%
% like so... THIS WILL READ FROM WHATEVER FOLDER YOU ARE IN CURRENTLY
% (left-hand side)
edf = {'1328_BOTH_S3GOOD_TTLRECORD_2021-11-03_13_04_30_export.edf'};
%edfread(edf{1})


% NOW RUN THE FUNCTION 
sirenia2mat(edf);


% after you run the function fully (answering all the questions), your .mat
% file will show up on the right hand side. you can proceed to convert as
% many files as you wish in one session



% when you are finished, move on to the section below 
  
%%
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


