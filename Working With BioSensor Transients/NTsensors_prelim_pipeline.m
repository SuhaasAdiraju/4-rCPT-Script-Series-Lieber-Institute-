%% Simplified Pipeline GRABNE processing 
%-Written 06.25.22 ~ Suhaas Adiraju


FirstTimeRun = questdlg('Is this the first time you are running the pipeline today?')
if strcmp('Yes',FirstTimeRun) == 1
    mkdir('Z:\Circuits projects (CPT)\rCPT_Analyses');
    addpath(genpath('Z:\Circuits projects (CPT)\rCPT_Analyses'));
end

waitfor(msgbox(sprintf('This script will be a one-stop-shop for the Neurotransmitter processing pipeline, combining all the basic processing scripts together in one script that can be simply run using ''Editor(tab)-Run''')))


%% INDICATE WHAT STAGE YOU NEED TO START FROM 
clc; clear; close all
stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of NT transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of NT transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
end

stage = str2num(stageCell{1})
while isempty(stage) == 1
    waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of NT transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
    if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning (creating a structure of NT transients + behavioral timestamps),\n\n2- for slicing transients based on Tstamps,\n\n3- for event-based Avg repsonse window\n\n4- for basic analyses'))
    end
    stage = str2num(stageCell{1})
end


%% for step 1
if stage == 1
run createStrucNTsensors.m
run sliceNTsensors.m
run AllEventAvg_NTsensor.m  
run BehavioralAvgPlot_NTsensor.m  

stage =1;
end

%% for step 2
if stage == 2
run sliceNTsensors.m
run AllEventAvg_NTsensor.m   
run BehavioralAvgPlot_NTsensor.m  
stage = 2
end

%% for step 3
if stage == 3
run AllEventAvg_NTsensor.m 
run BehavioralAvgPlot_NTsensor.m  
stage = 3
end


%% for step 4
if stage == 4
run BehavioralAvgPlot_NTsensor.m  
stage = 4
end
 
 
%% Signal analysis
%{
 figure;
 subplot 211
 plot(Transients)
 subplot 212
 pspectrum(Transients,10,'power');

 figure; 
 subplot 211 
 plot(detrendTransients)
 subplot 212
 pspectrum(detrendTransients,10,'power');
%}