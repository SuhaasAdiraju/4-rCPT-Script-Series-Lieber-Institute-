%% Post CPT basic analysis pipeline, stringing together all of the existing LFP4CPT scripts
if ~exist('Z:\Suhaas A\Analysis things\chronux_2_12\chronux_2_12','dir') == 1
    mkdir('Z:\Suhaas A\Analysis things\chronux_2_12\chronux_2_12')
    addpath(genpath('Z:\Suhaas A\Analysis things\chronux_2_12\chronux_2_12'))
end

if ~exist('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings','dir') == 1
    mkdir('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings')
    addpath(genpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings'))
end

if ~exist('Z:\Suhaas A\Analysis things\HH_PAC_FunctionFiles','dir') == 1
    mkdir('Z:\Suhaas A\Analysis things\HH_PAC_FunctionFiles')
    addpath(genpath('Z:\Suhaas A\Analysis things\HH_PAC_FunctionFiles'))
end


waitfor(msgbox(sprintf('This script will be a one-stop-shop for the LFP4CPT processing pipeline, combining all the basic processing scripts together in one script that can be simply run using ''Editor(tab)-Run''')))

% -- All scripts associated and functions written by Suhaas Adiraju 02.2022
%% 1st
clear; clc;
stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for Avg repsonse window\n\n5- for straight to basic analysis of data\n\n6- for plotting all subjects\n'))
if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for Avg repsonse window\n\n5- for straight to basic analysis of data\n\n6- for plotting all subjects\n'))
end
stage = str2num(stageCell{1})
while isempty(stage) == 1
    waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
    stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for Avg repsonse window\n\n5- for straight to basic analysis of data\n\n6- for plotting all subjects\n'))
    if (isempty(stageCell)==1)
        waitfor(warndlg('You did not indicate what stage you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stageCell = inputdlg(sprintf('What stage do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for Avg repsonse window\n\n5- for straight to basic analysis of data\n\n6- for plotting all subjects\n'))
    end
    stage = str2num(stageCell{1})
end

if stage == 1
    run LFP4CPT1_sirenia2mat.m
    %% 2nd
    run LFP4CPT2_createStructLFP.m
    %% 3rd
    run LFP4CPT3_sliceLFP.m
    %% 4th
    run LFP4CPT4_AvgSignalWindow.m
        loop = questdlg(sprintf('Are you finished creating avg response windows for all your subjects?\n\nIf no, the script will end, and you should RERUN THE SCRIPT TO PROCESS YOUR NEXT SUBJECT''S DATA'))
        if strcmp(loop,"Yes") == 1
            %% Average across subjects for avg response windows you just created 
                ansAcrossSubs = questdlg('Are you finished creating avg response windows for each subject? And now ready to average ACROSS ALL SUBJECTS?')
                if (strcmp(ansAcrossSubs, "Yes")) == 1
                    [AcrossSubjectsAvgResponse] = AvgSubsLFP
                elseif (strcmp(ansAcrossSubs, "Yes")) == 0
                end
           %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
            
        elseif strcmp(loop,"Yes") == 0
            %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
        end

end

if stage == 2 
    %% 2nd
    run LFP4CPT2_createStructLFP.m
    %% 3rd
    run LFP4CPT3_sliceLFP.m
    %% 4th
    run LFP4CPT4_AvgSignalWindow.m
           loop = questdlg(sprintf('Are you finished creating avg response windows for all your subjects?\n\nIf no, the script will end, and you should RERUN THE SCRIPT TO PROCESS YOUR NEXT SUBJECT''S DATA'))
        if strcmp(loop,"Yes") == 1
            %% Average across subjects for avg response windows you just created 
                ansAcrossSubs = questdlg('Are you finished creating avg response windows for each subject? And now ready to average ACROSS ALL SUBJECTS?')
                if (strcmp(ansAcrossSubs, "Yes")) == 1
                    [AcrossSubjectsAvgResponse] = AvgSubsLFP
                elseif (strcmp(ansAcrossSubs, "Yes")) == 0
                end
           %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
            
        elseif strcmp(loop,"Yes") == 0
            %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
        end
end

if stage == 3
    %% 3rd
    run LFP4CPT3_sliceLFP.m
    %% 4th
    run LFP4CPT4_AvgSignalWindow.m
           loop = questdlg(sprintf('Are you finished creating avg response windows for all your subjects?\n\nIf no, the script will end, and you should RERUN THE SCRIPT TO PROCESS YOUR NEXT SUBJECT''S DATA'))
        if strcmp(loop,"Yes") == 1
            %% Average across subjects for avg response windows you just created 
                ansAcrossSubs = questdlg('Are you finished creating avg response windows for each subject? And now ready to average ACROSS ALL SUBJECTS?')
                if (strcmp(ansAcrossSubs, "Yes")) == 1
                    [AcrossSubjectsAvgResponse] = AvgSubsLFP
                elseif (strcmp(ansAcrossSubs, "Yes")) == 0
                end
           %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
            
        elseif strcmp(loop,"Yes") == 0
            %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
        end
end



if stage == 4
     %% 4th
    run LFP4CPT4_AvgSignalWindow.m
   loop = questdlg(sprintf('Are you finished creating avg response windows for all your subjects?\n\nIf no, the script will end, and you should RERUN THE SCRIPT TO PROCESS YOUR NEXT SUBJECT''S DATA'))
        if strcmp(loop,"Yes") == 1
            %% Average across subjects for avg response windows you just created 
                ansAcrossSubs = questdlg('Are you finished creating avg response windows for each subject? And now ready to average ACROSS ALL SUBJECTS?')
                if (strcmp(ansAcrossSubs, "Yes")) == 1
                    [AcrossSubjectsAvgResponse] = AvgSubsLFP
                elseif (strcmp(ansAcrossSubs, "Yes")) == 0
                end
           %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
            
        elseif strcmp(loop,"Yes") == 0
            %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
                ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Power Spectrum 
                    run SignalAssessment.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end
                ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
                if (strcmp(ansAnalysis,'Yes')) == 1
                    % Phase amplitude coupling
                    run PAC_4CPT.m
                elseif (strcmp(ansAnalysis,'Yes')) == 0
                end 
        end
end

if stage == 5  
    %% Analysis of the data you just created (power spectrum and phase-amplitude coupling + associated analyses)
    ansAnalysis = questdlg('Do you want to perform signal-assessment analysis on this generated data set now? i.e. power-spectrum')
        if (strcmp(ansAnalysis,'Yes')) == 1
            % Power Spectrum 
            run SignalAssessment.m
        elseif (strcmp(ansAnalysis,'Yes')) == 0
        end
           
    ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis on this generated data set now?')
        if (strcmp(ansAnalysis,'Yes')) == 1
            % Phase amplitude coupling
            run PAC_4CPT.m
        elseif (strcmp(ansAnalysis,'Yes')) == 0
        end 

end

   
