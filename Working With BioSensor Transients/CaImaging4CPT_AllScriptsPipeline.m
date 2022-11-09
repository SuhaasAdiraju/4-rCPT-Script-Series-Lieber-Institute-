%% All-scripts CA2 imaging
%% Post CPT basic analysis pipeline, stringing together all of the existing Ca2imaging_4CPT scripts

FirstTimeRun = questdlg('Is this the first time you are running the pipeline today?')
if strcmp('Yes',FirstTimeRun) == 1
       startup_path = uigetdir('','PLEASE SELECT THE FOLDER OF THE SCRIPTS YOU DOWNLOADED FROM THE MAIN GITHUB REPOSITORY')
       addpath(genpath(startup_path))
       disp('all necessary functions for running these scripts have been added')
end


waitfor(msgbox(sprintf('This script will be a one-stop-shop for the Ca2imaging4CPT processing pipeline, combining all the basic processing scripts together in one script that can be simply run using ''Editor(tab)-Run''')))

% -- All scripts associated and functions written by Suhaas Adiraju 03.2022

%% INDICATE WHAT STAGE YOU NEED TO START FROM 
clear; clc;
stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of Ca transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of Ca transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
end

stage = str2num(stageCell{1})
while isempty(stage) == 1
    waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of Ca transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
    if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of Ca transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
    end
    stage = str2num(stageCell{1})
end





%% FOR STAGE 1 START
if stage == 1
    run createStrucCa.m
    %% 2nd
    run sliceCa.m
    
    run AllEventAvgCa.m

    run AnalyzingCAtransients.m
    stage = 1

end


%% FOR STAGE 2 START
if stage == 2 
    %% 2nd
    run sliceCa.m

    run AllEventAvgCa.m

    run AnalyzingCAtransients.m
    stage = 2
end


%% FOR Event Based Avging
if stage == 3
    %% 3rd
    run AllEventAvgCa.m

    run AnalyzingCAtransients.m
    stage = 3;

end

%% FOR prelim analyses
if stage == 4
    %% 3rd
    run AnalyzingCAtransients.m
end
